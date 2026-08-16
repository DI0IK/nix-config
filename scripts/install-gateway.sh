#!/usr/bin/env bash
set -euo pipefail

# Reinstall the Ionos VPS as the NixOS "gateway" host using nixos-anywhere.
#
# It:
#   1. extracts the wireguard state from the currently running VPS
#      (private key -> sops, peer public keys -> hosts/gateway/default.nix),
#   2. generates a fresh host identity and registers it in .sops.yaml +
#      secrets/gateway.yaml (encrypted to the YubiKey + the new host key),
#   3. injects the host key into /persist so sops-nix can decrypt on first boot,
#   4. wipes /dev/vda and installs NixOS from this flake.
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
SOPS_YAML=".sops.yaml"
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")

TMP_DIR="$(mktemp -d -t gateway-bootstrap-XXXXXX)"
HOST_KEY="$TMP_DIR/hostkey"
EXTRA_FILES="$TMP_DIR/extra-files"
WG_CONF="$TMP_DIR/wg.conf"

cleanup() {
  [ -n "${TMP_DIR:-}" ] && rm -rf "$TMP_DIR"
}
trap cleanup EXIT

step() {
  echo "### $* ###"
}

# --- 1. Preflight the running VPS -----------------------------------------
step "Preflight checks on $TARGET_HOST"
ssh "$TARGET_HOST" '
  [ -d /sys/firmware/efi ] && echo "boot: UEFI" || echo "boot: BIOS"
  ip -4 -o addr show scope global
  lsblk -d -o NAME,SIZE,MODEL
  for f in /etc/wireguard/*.conf; do [ -f "$f" ] && echo "wg config: $f"; done
'
read -r -p "Continue with install? [y/N] " yn
[ "$yn" = "y" ] || [ "$yn" = "Y" ] || { echo "Aborted."; exit 1; }

# --- 2. Extract wireguard state -------------------------------------------
step "Extracting wireguard config from $TARGET_HOST"
ssh "$TARGET_HOST" 'for f in /etc/wireguard/*.conf; do [ -f "$f" ] && cat "$f"; done' > "$WG_CONF" || true

WG_PRIV=""
if [ -s "$WG_CONF" ]; then
  WG_PRIV="$(grep -E '^\s*PrivateKey\s*=' "$WG_CONF" | tail -n1 | awk '{print $3}')"
  WG_PRIV_FILE="$(grep -E '^\s*PrivateKeyFile\s*=' "$WG_CONF" | tail -n1 | awk '{print $3}')"
  if [ -z "$WG_PRIV" ] && [ -n "$WG_PRIV_FILE" ]; then
    WG_PRIV="$(ssh "$TARGET_HOST" "cat \"$WG_PRIV_FILE\"")"
  fi
fi

step "Patching peer keys into hosts/${HOST}/default.nix"
if command -v python3 >/dev/null; then
  python3 - "$WG_CONF" "hosts/$HOST/default.nix" <<'PY'
import re, sys

wg_conf, default_nix = sys.argv[1], sys.argv[2]

known = {
    "172.30.32.2": "homelab",
    "fd86:ea04:1115::2": "homelab",
    "172.30.32.20": "fw13",
    "fd86:ea04:1115::20": "fw13",
}

if not wg_conf or not __import__("os").path.exists(wg_conf):
    print("  no wg config found - peer keys left as placeholders")
    sys.exit(0)

with open(wg_conf) as f:
    text = f.read()

with open(default_nix) as f:
    cfg = f.read()

n_peers = 0
for block in re.split(r"(?m)^\[Peer\]\s*$", text)[1:]:
    pk = re.search(r"(?m)^\s*PublicKey\s*=\s*(\S+)", block)
    allowed = re.search(r"(?m)^\s*AllowedIPs\s*=\s*(.+)", block)
    if not pk or not allowed:
        continue
    n_peers += 1
    ips = [i.strip().split("/")[0] for i in allowed.group(1).split(",")]
    name = next((known[i] for i in ips if i in known), "peer")
    if name == "peer":
        print(f"  WARNING: unmapped peer {pk.group(1)} allowedIPs={allowed.group(1).strip()}")
        continue
    cfg, n = re.subn(
        rf'(name = "{re.escape(name)}";\n\s*publicKey = ")[^"]*(")',
        rf"\g<1>{pk.group(1)}\g<2>",
        cfg,
        count=1,
    )
    print(f"  peer '{name}' -> {pk.group(1)}" if n else f"  WARNING: peer '{name}' not found in default.nix")

with open(default_nix, "w") as f:
    f.write(cfg)
print(f"  {n_peers} peer(s) parsed")
PY
else
  echo "  python3 not found - patch hosts/$HOST/default.nix peer keys manually"
fi

# --- 3. Host identity + secrets -------------------------------------------
if [ ! -f "$SECRET_FILE" ]; then
  step "Generating fresh host identity for $HOST"
  ssh-keygen -t ed25519 -N "" -C "$HOST" -f "$HOST_KEY"

  AGE_PUB="$(nix "${NIX_FLAGS[@]}" run nixpkgs#ssh-to-age -- -i "$HOST_KEY.pub")"
  echo "Host age public key: $AGE_PUB"

  if ! grep -q '&gateway' "$SOPS_YAML"; then
    step "Registering $HOST in $SOPS_YAML"
    awk -v pub="$AGE_PUB" '/^  - &homelab /{print; print "  - &gateway " pub; next} {print}' "$SOPS_YAML" > "$SOPS_YAML.new"
    mv "$SOPS_YAML.new" "$SOPS_YAML"
    cat >> "$SOPS_YAML" <<'EOF'

  - path_regex: secrets/gateway\.yaml$
    key_groups:
      - age:
          - *yubikey
          - *gateway
EOF
  fi

  step "Encrypting $SECRET_FILE (YubiKey + new host key)"
  {
    echo "system-ssh-key: |"
    sed 's/^/  /' "$HOST_KEY"
    if [ -n "$WG_PRIV" ]; then
      echo "wg-private-key: ${WG_PRIV}"
    else
      echo "wg-private-key: PLACEHOLDER_UPDATE_ME"
    fi
  } > "$SECRET_FILE"
  nix "${NIX_FLAGS[@]}" run nixpkgs#sops -- -e "$SECRET_FILE" > "$SECRET_FILE.enc"
  mv "$SECRET_FILE.enc" "$SECRET_FILE"
else
  step "$SECRET_FILE exists - keeping existing host identity"
fi

# --- 4. Inject host key into /persist for first boot -----------------------
mkdir -p "$EXTRA_FILES/persist/etc/ssh"
if [ -f "$HOST_KEY" ]; then
  cp "$HOST_KEY" "$EXTRA_FILES/persist/etc/ssh/ssh_host_ed25519_key"
  cp "$HOST_KEY.pub" "$EXTRA_FILES/persist/etc/ssh/ssh_host_ed25519_key.pub"
else
  echo "ERROR: no host key available; delete $SECRET_FILE and re-run to regenerate." >&2
  exit 1
fi

# --- 5. Install ------------------------------------------------------------
step "Installing NixOS on $TARGET_HOST ($DEVICE)"
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#$HOST" \
  --extra-files "$EXTRA_FILES" \
  "$TARGET_HOST"

echo
echo "----------------------------------------------------"
echo "Install complete. Once $HOST is reachable:"
echo "  git add .sops.yaml secrets/${HOST}.yaml hosts/${HOST} modules/gateway home/dominik/${HOST}.nix flake.nix"
echo "  nixos-rebuild switch --flake .#${HOST} --target-host dominik@<vps-ip>"
echo "  ssh <vps-ip>  # verify wg0, haproxy and DNAT are up"
