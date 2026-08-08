# Homelab Plan — k8s → single NixOS host

Migration of the homelab from the talos/Kubernetes cluster (`~/projects/homelab-cluster`, apps under `homelab/apps/`, enabled set defined by `homelab/apps/kustomization.yaml`) to the single NixOS host in this repo (flake host `homelab`). One self-contained Nix file per app under a `homelab.<...>` namespace, each independently enableable.

## Key constraints / decisions

- The host has **no public IPv4** (CGNAT). External requests route through an external VPS (inbound only). Outbound app traffic keeps the normal default route and does **not** traverse the VPS.
- App data lives under `/persist/apps/<app>` (flat, per app, override-able). Already covered by the borg backup in `hosts/homelab/backup.nix` (`paths = [ "/persist/apps" ]`).
- **Media** stays on NFS: `192.168.179.10:/mnt/user/media` (not under `/persist`).
- Prefer **native nixpkgs packages**; fall back to **rootless podman** for custom images.
- Secrets via **sops-nix** (already in the flake).
- Root is tmpfs (impermanence); `/persist` is a btrfs subvolume, so anything under `/persist` persists automatically. Modules only need to create dirs (tmpfiles).

## Ported apps (final)

**Core / infra**
- `homelab.core.*` — domain (`dominikstahl.dev`), timezone, letsencrypt (Cloudflare DNS-01, `cloudflareApiTokenFile`), `trustedNetworks`, postgres (`/persist/apps/postgres`, per-app users/dbs), NFS media mount, sops wiring
- `homelab.traefik` — dashboard, entrypoints (below), forward-auth to authentik for `.sso` apps
- `homelab.authentik` — SSO + blueprints
- `homelab.logging` — prometheus + grafana + alertmanager + discord webhook
- `homelab.wireguard` — inbound-only VPS tunnel (see Networking)

**Media suite** (`apps/media.nix` for the NFS mount; no per-app VPN)
- Native: `sonarr`, `radarr`, `lidarr`, `prowlarr`, `jellyfin` (gpu/VA-API), `navidrome`, `sabnzbd` (no VPN), `recyclarr` (systemd timer), `unpackerr` (systemd timer)
- Podman: `cross-seed`, `prowlarr-cross-seed`, `bazarr`, `lingarr`, `trailarr`, `mediathekarr`, `jellyseerr`, `qui`, `autobrr` (sso), `yata`, `unit3d-exporter`

**Standalone**
- `adguard` (web `dns.dominikstahl.dev` + DoT on `dot` entrypoint)
- `forgejo` (web `git.dominikstahl.dev` + SSH on `ssh` entrypoint)
- `immich` (gpu), `homeassistant` (mosquitto, piper, whisper, modbus proxy; MQTT on `mqtt` entrypoint), `invidious`, `searxng`, `redlib`, `lounge`
- `scrobble` — multi-scrobbler + koito only (maloja dropped)
- `spotifyIsrcApi` — pure reverse proxy to `192.168.179.10`

## Dropped (final)

- k8s infra: `metallb`, `descheduler`, CNPG operator (replaced by `core.postgres`), intel-gpu-plugin (replaced by host i915/VA-API), `homek8arr` (Traefik-CRD dependent)
- New drops: `slskd`, `gatus`, `gatn-assetlinks`, `razzia`, `twonote`, `maloja`, **PIA VPN entirely** (sabnzbd over Usenet SSL doesn't need it; re-add later if slskd/qbittorrent return)
- Disabled in cluster (not ported): `anyconnect`, `dhbw-irc`, `gameservers`, `glance`, `it-tools`, `libretranslate`, `longhorn`, `znc`, and disabled arr apps (`gameyfin`, `ersatztv`, `soularr`, `qbittorrent`, `qbit_manage`, `bookshelf`, `sftp`)

## Module tree to create

```
modules/homelab/
├── default.nix        # imports core + infra + apps/*.nix, each guarded by enable
├── lib.nix            # helpers: mkSystemdService, mkPodmanApp, mkPort, mkReverseProxy, firewallPort, tmpfiles dir helper
├── core.nix           # homelab.core.* + homelab.ports.allocated registry
├── traefik.nix        # homelab.traefik
├── authentik.nix      # homelab.authentik
├── logging.nix        # homelab.logging
├── wireguard.nix      # homelab.wireguard  (VPS tunnel, inbound)
└── apps/
    ├── media.nix      # NFS mount 192.168.179.10:/mnt/user/media
    ├── sonarr.nix radarr.nix lidarr.nix prowlarr.nix
    ├── jellyfin.nix navidrome.nix sabnzbd.nix recyclarr.nix unpackerr.nix
    ├── bazarr.nix lingarr.nix trailarr.nix mediathekarr.nix jellyseerr.nix qui.nix
    ├── autobrr.nix cross-seed.nix prowlarr-cross-seed.nix yata.nix unit3d-exporter.nix
    ├── adguard.nix forgejo.nix immich.nix homeassistant.nix invidious.nix
    ├── searxng.nix redlib.nix lounge.nix scrobble.nix spotify-isrc-api.nix
```

## Module conventions

- `homelab.<app>.enable` (default `false`) — every file self-contained, independently toggleable.
- `homelab.<app>.dataDir` default `/persist/apps/<app>`; module adds `systemd.tmpfiles.rules = [ "d <dataDir> 0700 <user> - -" ]` and points the service at it.
- `homelab.<app>.domain` → auto-generated traefik rule + letsencrypt cert; `.sso = true` → authentik forward-auth.
- Services bind `127.0.0.1` by default (only traefik entrypoints + direct-expose apps bind all interfaces).

## Port helper (auto-assigning, app ⇄ traefik in sync)

- `homelab.<app>.port` is `types.nullOr port`, default `null`.
  - Set → registered in `homelab.ports.explicit` (`[ { app, port } ]`).
  - `null` (and enabled) → registered in `homelab.ports.auto` (`[ <app> ]`).
- `core.nix` computes `homelab.ports.allocated` (attrset `app → port`), cycle-free (depends only on the name lists, not port values):
  - explicit ports taken as-is;
  - auto apps allocated **sorted by app name** (stable — adding an app never reshuffles existing ports), first free port in `8000–9999`, skipping explicit ports, prior auto ports, and traefik entrypoint ports;
  - readable error if the range is exhausted; duplicate explicit ports error naming both apps.
- App systemd service **and** its traefik rule both read `config.homelab.ports.allocated.<app>` → guaranteed to match.
- Helper `mkPort name defaultPort`: canonical default used when free, otherwise auto-shifts (e.g. sonarr `8989`).
- Allocated ports never need firewall rules (services bind localhost).

## Traefik entrypoints

- Keep: `web` 80, `websecure` 443 (+HTTP/3), `dot` 853 (adguard DoT), `ssh` 2222 (forgejo SSH), `mqtt` 1883 (homeassistant).
- Drop: `irc` 6697, `sftp` 2022, `minecraft` 25565, `supertuxkart-discovery` (no enabled users; dhbw-irc/znc/sftp/gameservers all disabled). Easy to re-add later.

## Networking

### VPS tunnel (`homelab.wireguard`) — inbound-only

- Standard WireGuard **client** tunnel to the VPS via systemd-networkd (netdev + network).
- `AllowedIPs` = **tunnel subnet only** — **no** `0.0.0.0/0` / `::/0`. Outbound app traffic keeps the normal default route (LAN router/CGNAT); the VPS is **not** an outbound hop.
- Host gets its tunnel IPv4 (+ optional IPv6 addr) so the VPS can route inbound IPv6 into the tunnel.
- **Inbound:** VPS DNATs public ports → host's WG IP (443/80/853/2222/1883). This is manual VPS-side config — document it, not in this repo. Traefik + direct services bind all interfaces so they are reachable on the WG address.
- Host firewall opens only the entrypoint ports + WG.

## Secrets → sops (one-time migration step)

- Decrypt sealed secrets from the old cluster and re-encrypt into sops:
  - `traefik-wireguard-config` → `wg0.conf` (VPS endpoint/keys/address) for `homelab.wireguard`
  - `pia-credentials`, `soulseek-credentials`, `SLSKD_API_KEY` → **not needed** (slskd/PIA dropped)
  - cloudflare API token (wildcard cert), authentik bootstrap, and per-app API keys: autobrr, yata, unit3d-exporter, recyclarr, forgejo admin, invidious, etc.
- Wire sops decryption into the modules (sops-nix already configured in the flake).

## Implementation order

1. `default.nix` + `lib.nix` + `core.nix` (ports, postgres, sops, NFS) + `traefik.nix` — foundation must build clean
2. `wireguard.nix` (VPS tunnel)
3. DB-consuming apps: `forgejo`, `immich`, `invidious`
4. Media suite: `media.nix` + first `*arr`, then remaining arr apps
5. Standalone apps, then `spotify-isrc-api` reverse proxy
6. `nix flake check` / `nixos-rebuild build --flake .#homelab` after each batch

## Acceptance criteria

- [ ] `nix flake check` and `nixos-rebuild build --flake .#homelab` pass with the full app set enabled
- [ ] Every enabled cluster app is reachable at its old hostname via traefik (HTTP(S) + dot/ssh/mqtt TCP entrypoints)
- [ ] App data persisted in `/persist/apps/<app>` and included in borg backup
- [ ] Media served from the NFS mount unchanged
- [ ] External requests arrive via the VPS tunnel; outbound traffic does not traverse it
- [ ] No two apps share a port; traefik targets match each app's allocated port
- [ ] Each app independently disableable via `homelab.<app>.enable`
- [ ] Secrets live in sops (no plaintext keys in repo)
