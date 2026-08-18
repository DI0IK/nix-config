#!/usr/bin/env bash
set -euo pipefail

# Reinstall the Ionos VPS as the NixOS "gateway" host using nixos-anywhere.
#
# It:
#   1. bootstraps the YubiKey to decrypt sops secrets,
#   2. injects the host identity (from secrets/gateway.yaml) into /persist,
#   3. wipes the device and installs NixOS from this flake.
#
# Usage: ./scripts/install-gateway.sh [ssh-target] [device]
#   ssh-target   running VPS, e.g. root@217.154.87.4
#   device       disk to repartition, default /dev/vda

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

TARGET_HOST="${1:-root@217.154.87.4}"
DEVICE="${DEVICE:-/dev/vda}"
HOST="gateway"
SECRET_FILE="secrets/${HOST}.yaml"
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")

TMP_DIR="$(mktemp -d -t gateway-bootstrap-XXXXXX)"
HOST_KEY="$TMP_DIR/hostkey"
EXTRA_FILES="$TMP_DIR/extra-files"
YUBI_STUB=""
PCSCD_PID=""

cleanup() {
  [ -n "${PCSCD_PID:-}" ] && sudo kill "$PCSCD_PID" 2>/dev/null || true
  [ -n "${YUBI_STUB:-}" ] && rm -f "$YUBI_STUB"
  [ -n "${TMP_DIR:-}" ] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT

step() {
  echo "### $* ###"
}

read -r -p "This wipes $TARGET_HOST and reinstalls NixOS. Continue? [y/N] " yn
[ "$yn" = "y" ] || [ "$yn" = "Y" ] || { echo "Aborted."; exit 1; }

# --- 1. YubiKey bootstrap ---------------------------------------------------
step "Bootstraping YubiKey identity (check YubiKey for PIN/Touch)"
YUBI_STUB="$(mktemp)"
if ! systemctl is-active --quiet pcscd; then
  CCID_DROPDIR="$(nix "${NIX_FLAGS[@]}" build --no-link --print-out-paths nixpkgs#ccid)/pcsc/drivers"
  sudo PCSCLITE_HP_DROPDIR="$CCID_DROPDIR" nix "${NIX_FLAGS[@]}" run nixpkgs#pcsclite -- -f &
  PCSCD_PID=$!
  sleep 2
fi
nix "${NIX_FLAGS[@]}" run nixpkgs#age-plugin-yubikey -- --identity > "$YUBI_STUB"

# --- 2. Inject host key into /persist for first boot ------------------------
mkdir -p "$EXTRA_FILES/persist/etc/ssh"
step "Extracting system-ssh-key from $SECRET_FILE (check YubiKey for PIN/Touch)"
SOPS_AGE_KEY_FILE="$YUBI_STUB" nix "${NIX_FLAGS[@]}" run nixpkgs#sops -- -d --extract '["system-ssh-key"]' "$SECRET_FILE" > "$HOST_KEY"
chmod 600 "$HOST_KEY"
ssh-keygen -y -f "$HOST_KEY" > "$HOST_KEY.pub"
cp "$HOST_KEY" "$EXTRA_FILES/persist/etc/ssh/ssh_host_ed25519_key"
cp "$HOST_KEY.pub" "$EXTRA_FILES/persist/etc/ssh/ssh_host_ed25519_key.pub"

# --- 3. Install -------------------------------------------------------------
step "Installing NixOS on $TARGET_HOST ($DEVICE)"
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#$HOST" \
  --extra-files "$EXTRA_FILES" \
  "$TARGET_HOST"

echo
echo "----------------------------------------------------"
echo "Install complete. Once $HOST is reachable:"
echo "  git add .sops.yaml secrets/common.yaml secrets/${HOST}.yaml"
echo "  nixos-rebuild switch --flake .#${HOST} --target-host dominik@<vps-ip>"
echo "  ssh <vps-ip>  # verify wg0, haproxy and DNAT are up"
