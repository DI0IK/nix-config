#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO_URL="https://github.com/di0ik/nix-config"
TARGET_HOST="fw13"
SECRET_FILE="secrets/secrets.yaml" 
DISK_DEVICE="/dev/nvme0n1"

# Use a Bash array for experimental flags to handle whitespace safely
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")

export GPG_TTY=$(tty)

# --- Resource Tracking & Cleanup ---
TMP_DIR=""
YUBI_STUB=""
PCSCD_PID=""

cleanup() {
    echo -e "\nCleaning up temporary deployment assets..."
    [ -n "${PCSCD_PID:-}" ] && sudo kill "$PCSCD_PID" 2>/dev/null || true
    [ -n "${YUBI_STUB:-}" ] && rm -f "$YUBI_STUB"
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
sudo nix "${NIX_FLAGS[@]}" run github:nix-community/disko -- --mode zap_create_mount "./hosts/$TARGET_HOST/disko.nix" --argstr device "$DISK_DEVICE"

# 4. The Seed: Decrypt SSH Key via YubiKey
YUBI_STUB=$(mktemp -t yubi-stub.XXXXXX)
nix "${NIX_FLAGS[@]}" run nixpkgs#age-plugin-yubikey -- --identity > "$YUBI_STUB"

TARGET_PERSIST_DIR="/mnt/persist/etc/ssh"
TARGET_KEY_PATH="$TARGET_PERSIST_DIR/ssh_host_ed25519_key"

sudo mkdir -p "$TARGET_PERSIST_DIR"
sudo chmod 755 /mnt/persist /mnt/persist/etc

echo "Extracting 'system-ssh-key' to persistence... (Check YubiKey for PIN/Touch)"
sudo -E SOPS_AGE_KEY_FILE="$YUBI_STUB" nix "${NIX_FLAGS[@]}" shell nixpkgs#sops nixpkgs#age-plugin-yubikey -c \
    sops -d --extract '["system-ssh-key"]' "$SECRET_FILE" | \
    sudo tee "$TARGET_KEY_PATH" > /dev/null

sudo chmod 600 "$TARGET_KEY_PATH"

# 5. NixOS Installation
echo "Starting NixOS installation..."
sudo nixos-install --flake ".#$TARGET_HOST" --no-root-passwd

echo "----------------------------------------------------"
echo "Installation complete. You can safely reboot $TARGET_HOST now."