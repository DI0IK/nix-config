#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO_URL="https://github.com/di0ik/nix-config"
TARGET_HOST="${TARGET_HOST:-fw13}"
COMMON_FILE="secrets/common.yaml"
HOST_FILE="secrets/${TARGET_HOST}.yaml"
DISK_DEVICE="${DISK_DEVICE:-/dev/nvme0n1}"
BORG_USER="u599352-sub2"
[ "$TARGET_HOST" = "homelab" ] && BORG_USER="u599352-sub3"
[ "$TARGET_HOST" = "gateway" ] && BORG_USER="u599352-sub4"
BORG_REPO="ssh://${BORG_USER}@${BORG_USER}.your-storagebox.de:23/./${TARGET_HOST}"

# Use a Bash array for experimental flags to handle whitespace safely
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")

export GPG_TTY=$(tty)

# --- Resource Tracking & Cleanup ---
TMP_DIR=""
YUBI_STUB=""
BORG_SSH_PASS_STUB=""
BORG_PASS_STUB=""
PCSCD_PID=""

cleanup() {
    echo -e "\nCleaning up temporary deployment assets..."
    [ -n "${PCSCD_PID:-}" ] && sudo kill "$PCSCD_PID" 2>/dev/null || true
    [ -n "${YUBI_STUB:-}" ] && rm -f "$YUBI_STUB"
    [ -n "${BORG_SSH_PASS_STUB:-}" ] && rm -f "$BORG_SSH_PASS_STUB"
    [ -n "${BORG_PASS_STUB:-}" ] && rm -f "$BORG_PASS_STUB"
    [ -d "${TMP_DIR:-}" ] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Starting YubiKey bootstrap for $TARGET_HOST..."

# 1. Setup Ephemeral Smart Card Daemon
if ! systemctl is-active --quiet pcscd; then
    echo "Configuring ephemeral pcscd with CCID drivers..."
    CCID_DROPDIR=$(nix "${NIX_FLAGS[@]}" build --no-link --print-out-paths nixpkgs#ccid)/pcsc/drivers
    sudo PCSCLITE_HP_DROPDIR="$CCID_DROPDIR" nix "${NIX_FLAGS[@]}" run nixpkgs#pcsclite -- -f &
    PCSCD_PID=$!
    sleep 2
fi

# 2. Clone Configuration to a unique, dynamic temporary directory
TMP_DIR=$(mktemp -d -t nix-bootstrap-XXXXXX)
echo "Cloning configuration repository..."
nix "${NIX_FLAGS[@]}" run nixpkgs#git -- clone "$REPO_URL" "$TMP_DIR"
cd "$TMP_DIR"

# 3. Storage Provisioning (Disko)
if [ ! -b "$DISK_DEVICE" ]; then
    DISK_DEVICE="/dev/vda"
fi

echo "Provisioning disks on $DISK_DEVICE..."
sudo nix "${NIX_FLAGS[@]}" run github:nix-community/disko -- --mode zap_create_mount "./hosts/$TARGET_HOST/disk.nix" --argstr device "$DISK_DEVICE"

# 4. Persist configuration for post-reboot access
PERSIST_REPO="/mnt/persist/nix-config"
echo "Copying configuration to $PERSIST_REPO..."
sudo mkdir -p "$(dirname "$PERSIST_REPO")"
sudo cp -a "$TMP_DIR" "$PERSIST_REPO"

# 5. The Seed: Decrypt SSH Key via YubiKey
YUBI_STUB=$(mktemp -t yubi-stub.XXXXXX)
nix "${NIX_FLAGS[@]}" run nixpkgs#age-plugin-yubikey -- --identity > "$YUBI_STUB"

TARGET_PERSIST_DIR="/mnt/persist/etc/ssh"
TARGET_KEY_PATH="$TARGET_PERSIST_DIR/ssh_host_ed25519_key"

sudo mkdir -p "$TARGET_PERSIST_DIR"
sudo chmod 755 /mnt/persist /mnt/persist/etc

echo "Extracting 'system-ssh-key' to persistence... (Check YubiKey for PIN/Touch)"
sudo -E SOPS_AGE_KEY_FILE="$YUBI_STUB" nix "${NIX_FLAGS[@]}" shell nixpkgs#sops nixpkgs#age-plugin-yubikey -c \
    sops -d --extract '["system-ssh-key"]' "$HOST_FILE" | \
    sudo tee "$TARGET_KEY_PATH" > /dev/null

sudo chmod 600 "$TARGET_KEY_PATH"

# 6. Restore user data from Borg backup
BORG_SSH_PASS_STUB=$(mktemp -t borg-pass.XXXXXX)
BORG_PASS_STUB=$(mktemp -t borg-pass.XXXXXX)

sudo -E SOPS_AGE_KEY_FILE="$YUBI_STUB" nix "${NIX_FLAGS[@]}" shell nixpkgs#sops -c \
    sops -d --extract '["borg-ssh-pass"]' "$COMMON_FILE" > "$BORG_SSH_PASS_STUB"

sudo -E SOPS_AGE_KEY_FILE="$YUBI_STUB" nix "${NIX_FLAGS[@]}" shell nixpkgs#sops -c \
    sops -d --extract '["borg-repo-passphrase"]' "$COMMON_FILE" > "$BORG_PASS_STUB"

echo "Restoring user data from Borg backup..."
export BORG_RSH="sshpass -f $BORG_SSH_PASS_STUB ssh -o StrictHostKeyChecking=accept-new -p 23"
BORG_PASSPHRASE=$(cat "$BORG_PASS_STUB") nix "${NIX_FLAGS[@]}" shell nixpkgs#borgbackup nixpkgs#sshpass -c \
    borg list "$BORG_REPO" > /dev/null 2>&1 && \
  BORG_PASSPHRASE=$(cat "$BORG_PASS_STUB") nix "${NIX_FLAGS[@]}" shell nixpkgs#borgbackup nixpkgs#sshpass -c \
    borg extract --destination /mnt "$BORG_REPO"::latest \
  || echo "No existing Borg backup found — skipping restore."

# 7. NixOS Installation
echo "Starting NixOS installation..."
sudo nixos-install --flake ".#$TARGET_HOST" --no-root-passwd

echo "----------------------------------------------------"
echo "Installation complete. You can safely reboot $TARGET_HOST now."