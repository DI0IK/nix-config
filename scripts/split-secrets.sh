#!/usr/bin/env bash
set -euo pipefail

# Splits secrets/secrets.yaml into per-host + common encrypted files.
# Usage: run from the repo root (or pass repo path as $1).
#   nix shell nixpkgs#sops nixpkgs#yq nixpkgs#age-plugin-yubikey -c bash split-secrets.sh
# Requires the YubiKey for decryption. No plaintext is written to stdout.

REPO="${1:-$(pwd)}"
cd "$REPO"
[ -f secrets/secrets.yaml ] || { echo "error: secrets/secrets.yaml not found in $REPO" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

command -v sops >/dev/null 2>&1 || { echo "error: sops not in PATH (run via 'nix shell nixpkgs#sops ...')" >&2; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "error: yq not in PATH (run via 'nix shell nixpkgs#yq ...')" >&2; exit 1; }

# Make the YubiKey identity discoverable (as install.sh does).
if [ -z "${SOPS_AGE_KEY_FILE:-}" ] && command -v age-plugin-yubikey >/dev/null 2>&1; then
    YUBI_STUB="$(mktemp)"
    age-plugin-yubikey --identity > "$YUBI_STUB"
    export SOPS_AGE_KEY_FILE="$YUBI_STUB"
fi

echo "Decrypting secrets/secrets.yaml (YubiKey PIN/touch)..."
sops -d --output "$WORK/plain.yaml" secrets/secrets.yaml

yq -Y 'with_entries(select(.key == "dominik-password" or .key == "borg-repo-passphrase" or .key == "borg-ssh-pass"))' \
    "$WORK/plain.yaml" > "$WORK/common.yaml"
yq -Y 'with_entries(select(.key == "wg-private-key" or .key == "system-ssh-key"))' \
    "$WORK/plain.yaml" > "$WORK/fw13.yaml"
yq -Y 'with_entries(select(.key == "homelab-wg-private-key" or .key == "cloudflare-api-token"))' \
    "$WORK/plain.yaml" > "$WORK/homelab.yaml"

for f in common fw13 homelab; do
    yq -e '. != {}' "$WORK/$f.yaml" >/dev/null || { echo "error: $f.yaml would be empty" >&2; exit 1; }
done

cp secrets/secrets.yaml "$WORK/secrets.yaml.bak"

for f in common fw13 homelab; do
    echo "Encrypting secrets/$f.yaml ..."
    cp "$WORK/$f.yaml" "secrets/$f.yaml"
    sops -e -i "secrets/$f.yaml"
    sops filestatus "secrets/$f.yaml"
done

rm secrets/secrets.yaml

echo "Done. New files: secrets/common.yaml, secrets/fw13.yaml, secrets/homelab.yaml"
echo "Old file backed up in $WORK/secrets.yaml.bak (removed on exit)."
