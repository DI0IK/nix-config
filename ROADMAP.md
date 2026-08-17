# Homelab Roadmap

> Self-hosted services and Ollama model recommendations for this infrastructure.
> Generated: August 2026

---

## Current Stack

| Category | Service |
|----------|---------|
| Identity | Authentik |
| Smart Home | Home Assistant + Mosquitto |
| Search | SearXNG |
| Content | RedLib |
| Reverse Proxy | Traefik |
| Databases | PostgreSQL + Redis |
| VPN | WireGuard |
| Health Checks | Gatus |
| Monitoring | Prometheus + Grafana |
| Logging | Loki + Alloy |
| Backup | Borg |

---

### Adding new apps (Authentik blueprint system)

Declare apps in the relevant module using `homelab.authentik.apps.<name>`:

```nix
# Forward auth (Traefik forward_single)
homelab.authentik.apps.<name> = {
  type = "forward-auth";
  name = "App Name";
  group = "App Name";                    # optional, defaults to name
  externalHost = "https://app.example.com";
  roleGroups = [ "Admins" "Editors" ];   # optional child groups
};

# OIDC confidential
homelab.authentik.apps.<name> = {
  type = "oidc";
  name = "App Name";
  group = "App Name";
  roleGroups = [ "Admins" ];
  clientId = "my-app";                      # plain string, not a secret
  clientSecret = config.sops.placeholder.<app>-oauth-secret;
  redirectUris = [
    { url = "https://app.example.com/callback"; matching_mode = "strict"; }
  ];
};
```

Blueprints are auto-generated and placed in `/etc/authentik-blueprints/`.

### Blueprint helper functions

- `mkForwardAuthBlueprint` — generates proxy provider (forward_single) blueprints
- `mkOidcBlueprint` — generates confidential OAuth2 provider blueprints
- Located in `modules/homelab/apps/authentik-helpers.nix`
- Options exposed via `homelab.authentik.apps.*` in `modules/homelab/apps/authentik.nix`

---

## Recommended Apps by Category

### Identity & Security

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Vaultwarden** | 43.5k | Bitwarden-compatible password manager | #1 community recommendation. 256MB RAM, works with all Bitwarden clients. Uses PostgreSQL |
| **Authelia** | 23k | Lightweight SSO/2FA gateway | Lighter than Authentik, config-file driven |
| **PocketID** | 2k | Passkey-based OIDC provider | Passwordless login across all services. Rising fast |
| **CrowdSec** | 10k | Collaborative intrusion prevention | Crowd-sourced IP blocklist |
| **TinyAuth** | 1k | Minimal OIDC proxy | "Authentik for humans." 5-minute setup |

### Networking & DNS

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **AdGuard Home** | 27k | Network-wide DNS ad blocking | Cleaner UI than Pi-hole, DoH/DoT built-in |
| **Pi-hole** | 51k | DNS ad blocking | The classic, huge community |
| **Headscale** | 25k | Self-hosted Tailscale control server | WireGuard mesh without cloud dependency |
| **NetBird** | 10k | Self-hosted mesh VPN | Built-in SSO/MFA/ACLs |
| **Caddy** | 74.8k | Reverse proxy with auto-HTTPS | "Set it and forget it" TLS |
| **Pangolin** | 13k | Self-hosted tunnel platform | Cloudflare Tunnel alternative |
| **Unbound** | - | Recursive DNS resolver | Pairs with Pi-hole/AdGuard for ultimate privacy |

### Document & File Management

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Paperless-ngx** | 22k | Document management + OCR | Scan receipts, search everything, auto-tag. Uses PostgreSQL |
| **Homebox** | 3k | Home inventory tracker | Track what you own, where it is, warranty expiry |
| **Calibre-Web** | 14k | Ebook library web UI | Browse and read your Calibre library |
| **Kavita** | 5k | Books/comics/manga server | OPDS, reading progress across devices |
| **Syncthing** | 64k | P2P file sync (no server) | E2E encrypted, no accounts. The Dropbox replacement |
| **Nextcloud** | 28k | Full cloud platform | Drive + Calendar + Contacts + 200+ apps |
| **Seafile** | 13k | Fast file sync | Lighter than Nextcloud, excellent clients |
| **MinIO** | 50k | S3-compatible object storage | Any S3-speaking tool talks to it |

### Media & Entertainment

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Jellyfin** | 47.9k | Media server (movies/TV/music) | No subscriptions, no tracking. #1 media server |
| **Immich** | 62.6k | Google Photos alternative | Face recognition, smart search, phone auto-upload |
| **PhotoPrism** | 37.3k | AI-powered photo management | Beautiful, mature |
| **Navidrome** | 15k | Music streaming (Subsonic API) | Tiny footprint, pair with Symfonium on Android |
| **Audiobookshelf** | 10.4k | Audiobook/podcast server | Gorgeous apps, podcast auto-download |
| **Sonarr** | 26k | TV show automation | Auto-download new episodes |
| **Radarr** | 26k | Movie automation | Same as Sonarr for movies |
| **Prowlarr** | 5k | Indexer manager | Unifies torrent/usenet sources |
| **Jellyseerr** | 5k | Media request manager | Users browse and request content |
| **Stump** | 2k | Comics/manga server | OPDS support, browser-based reading |
| **Pinchflat** | 1k | YouTube archiver | Auto-download channels, pairs with Jellyfin |

### Note-Taking & Knowledge

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Trilium Notes** | 28k | Hierarchical personal KB | Encryption, relation maps, scripting |
| **Outline** | 30k | Team wiki (Notion-like) | Beautiful editor, real-time collaboration |
| **BookStack** | 15k | Structured wiki | "The Confluence that doesn't make you cry" |
| **Docmost** | 12k | Confluence/Notion replacement | Single container, clean block editor |
| **Memos** | 15k | Microblog/quick notes | Radical simplicity |
| **Joplin** | 49k | Markdown note-taking | E2E encryption, cross-platform sync |
| **HedgeDoc** | 10k | Collaborative Markdown editor | NixOS-native, real-time collaboration |

### Bookmarks & Read-It-Later

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Karakeep** | 8k | AI-powered bookmark manager | Save links/notes/PDFs, AI auto-tagging |
| **Linkding** | 7k | Simple bookmark manager | Minimal, fast, great mobile support |
| **Linkwarden** | 10k | Collaborative bookmarks + archiving | Auto-archives linked pages |
| **Readeck** | 2k | Read-it-later article archive | Clean reading experience, full-text search |

### RSS & Feeds

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **FreshRSS** | 9k | RSS feed aggregator | Works with Reeder, NetNewsWire. Multi-user |
| **Miniflux** | 6k | Minimalist RSS reader | Single Go binary, zero bloat |

### Task & Project Management

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Vikunja** | 13k | Task management (Todoist alt) | Kanban, Gantt charts, reminders |
| **Plane** | 42k | Issue tracking (Linear/Jira alt) | Beautiful UI, sprints, cycles |
| **Focalboard** | 22k | Project management (Trello/Notion) | Kanban, table, gallery, calendar views |

### Finance & Budgeting

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Actual Budget** | 16k | Local-first budgeting (YNAB alt) | Envelope budgeting, bank sync |
| **Firefly III** | 16k | Personal finance (double-entry) | Budgets, reports, recurring transactions |

### Home Automation & IoT

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Frigate** | 22k | NVR with AI object detection | Coral TPU support, pairs with HA |
| **ESPHome** | 8k | ESP device firmware | Define devices in YAML |
| **Node-RED** | 21k | Visual flow-based automation | Drag-and-drop IoT glue |

### Monitoring & Observability

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Uptime Kuma** | 89.6k | Beautiful uptime monitoring | Status pages, 60+ notification methods |
| **Beszel** | 12k | Lightweight server monitoring | Hub idles at 30MB |
| **Dozzle** | 9k | Real-time Docker log viewer | Browse container logs without CLI |
| **Scrutiny** | 2k | Hard drive health monitoring | SMART scans, early failure warning |

### Dashboards

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Homepage** | 23k | Auto-discovering dashboard | Scans Docker labels, zero manual config |
| **Dashy** | 19k | Customizable home dashboard | Widget-rich, themeable |

### Automation & Workflows

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **n8n** | 66.2k | Workflow automation (Zapier alt) | 400+ integrations, AI workflows |
| **Activepieces** | 21.5k | Workflow automation (MIT) | Cleaner than n8n, MIT licensed |
| **Huginn** | 46.5k | Automated task agents | "If IFTTT were a database" |

### AI & Local LLMs

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Ollama** | 135k | Local LLM runtime | One command to run any model |
| **Open WebUI** | 92k | ChatGPT interface for local LLMs | Multi-user, RAG, document uploads |
| **AnythingLLM** | 37k | RAG + document intelligence | "Talk to your docs" with source citations |
| **Dify** | 95k | LLM app platform | Build AI workflows others can use |
| **LocalAI** | 28k | OpenAI API-compatible backend | Drop-in replacement |
| **Tabby** | 27k | Self-hosted code completion | Copilot alternative |

### Communication & Messaging

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Mailcow** | 9.5k | All-in-one mail server | Postfix + Dovecot + SOGo + antispam |
| **Stalwart** | 5k | Rust-native mail server | Modern, lightweight |
| **Ghost** | 40k | Publishing/newsletter platform | Self-hosted Substack |
| **Listmonk** | 15k | Newsletter manager | Send millions of emails |
| **Mattermost** | 30k | Team messaging (Slack alt) | Full-featured, plugins |
| **Rocket.Chat** | 42k | Team communication | E2E encryption, federation |
| **Matrix + Element** | 55k | Federated messaging | E2E encrypted, decentralized |

### Development Tools

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Forgejo** | 10k | Self-hosted Git | Community fork of Gitea |
| **Gitea** | 48k | Self-hosted Git | 256MB RAM, extremely lightweight |
| **code-server** | 46k | VS Code in the browser | Code from any device |
| **Woodpecker CI** | 5k | CI/CD pipelines | Community fork of Drone |
| **Meilisearch** | 50k | Lightning-fast search engine | Sub-50ms, typo-tolerant |

### Location & Personal Tracking

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Dawarich** | 5k | Self-hosted location history | Google Timeline replacement |
| **Nightscout** | 2k | CGM glucose monitoring | Life-changing for diabetics |
| **Beaver Habit Tracker** | 1k | Minimalist habit tracker | Just track what you do |

### Push Notifications

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **ntfy** | 19k | HTTP push notifications | Send alerts from scripts/monitoring |
| **Gotify** | 13k | Push notification server | Simple, reliable, Android app |
| **Apprise** | 13k | Universal notification aggregator | One API to 90+ services |

### PaaS & Deployment

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Coolify** | 60.6k | Self-hosted PaaS (Heroku/Vercel alt) | Git-push deploys, auto-SSL |
| **Portainer** | 31k | Docker management UI | Visual container management |
| **Dockge** | 10k | Docker Compose management | By Uptime Kuma dev |

### Specialized & Niche

| Service | Stars | What it does | Notes |
|---------|-------|-------------|-------|
| **Mealie** | 5k | Recipe management | Auto-import from URLs, shopping lists |
| **Kiwix** | 3k | Offline Wikipedia | ZIM files, works without internet |
| **Blackbox** | 1k | Event correlation forensics | Correlates crashes, config changes, alerts |
| **FileFlows** | 2k | File processing automation | Batch convert/compress/rename |
| **BentoPDF** | 1k | PDF tools (merge/split/compress) | All processing local |
| **Slink** | 1k | Self-hosted image hosting | Imgur replacement |

---

## Priority: What to Install Next

### Tier 1 — High Impact, Low Effort

| Priority | Service | Why | Uses Existing Infra |
|----------|---------|-----|---------------------|
| 1 | **Vaultwarden** | Passwords. Everyone needs this. | PostgreSQL |
| 2 | **AdGuard Home** | Block ads network-wide | Standalone |
| 3 | **Paperless-ngx** | Document OCR/search | PostgreSQL |
| 4 | **Syncthing** | P2P file sync between devices | Standalone |

### Tier 2 — High Value Additions

| Priority | Service | Why | Uses Existing Infra |
|----------|---------|-----|---------------------|
| 5 | **Immich** | Phone photo backup, Google Photos replacement | PostgreSQL, Redis |
| 6 | **n8n** | Automate anything, connect services | PostgreSQL |
| 7 | **FreshRSS** | RSS feeds, reclaim attention from algorithms | Standalone |
| 8 | **Uptime Kuma** | Pretty status pages for family | Standalone |

### Tier 3 — Nice When You Have Time

| Service | Category | Effort |
|---------|----------|--------|
| **Ollama + Open WebUI** | Local AI | Medium |
| **Jellyfin** | Media server | Medium |
| **Forgejo** | Self-hosted Git | Low |
| **Linkding** | Bookmarks | Low |
| **Homepage** | Dashboard | Low |
| **Homebox** | Inventory tracker | Low |
| **Mealie** | Recipes | Low |
| **Trilium Notes** | Personal KB | Low |

---

## Ollama Model Guide

### Hardware Profile

- **Total RAM:** 60 GB
- **Available for models:** ~40-50 GB (after OS, Ollama runtime, other services)
- **CPU cores:** 5
- **No GPU:** CPU inference only, memory-bandwidth-bound

### CPU Inference Speed Estimates

| Model Size | Q4_K_M RAM | Expected Speed |
|---|---|---|
| 3-4B | 2-3 GB | 8-15 tok/s |
| 7-8B | 4-5 GB | 3-6 tok/s |
| 14B | 8-10 GB | 1.5-3 tok/s |
| 30B MoE | 17 GB | 2-5 tok/s |
| 32B dense | 20 GB | 0.5-1.5 tok/s |
| 70B dense | 43 GB | 0.3-0.7 tok/s |

### The MoE Advantage

MoE (Mixture-of-Experts) models like `qwen3:30b-a3b` load 30B parameters into RAM but only activate ~3B per token. Generation speed approaches a small model while quality matches a much larger one. This is the key to usable local AI on CPU-only hardware.

### Models to Pull

#### Essential (36 GB disk total)

| Model | Tag | Size | Purpose |
|---|---|---|---|
| **Qwen3-30B-A3B** | `qwen3:30b-a3b` | 17 GB | General chat, all-purpose daily driver |
| **Qwen3-Coder 30B** | `qwen3-coder:30b` | 19 GB | Coding assistant |
| **nomic-embed-text** | `nomic-embed-text` | 274 MB | RAG embeddings |

#### Nice to Have (+32 GB disk)

| Model | Tag | Size | Purpose |
|---|---|---|---|
| Qwen3-8B | `qwen3:8b` | 5 GB | Quick tasks, fast responses |
| DeepSeek-R1 14B | `deepseek-r1:14b` | 9 GB | Reasoning, math, debugging |
| Gemma 4 12B | `gemma4:12b` | 7.6 GB | Vision/multimodal |
| Qwen3-14B | `qwen3:14b` | 9 GB | Balanced quality/speed |

#### Batch Processing Only (too slow for interactive)

| Model | Tag | Size | Use Case |
|---|---|---|---|
| Llama 3.3 70B | `llama3.3:70b` | 43 GB | Overnight summarization, document analysis |

### Embedding Models for RAG

| Model | Tag | Size | Dimensions | Notes |
|---|---|---|---|---|
| **nomic-embed-text** | `nomic-embed-text` | 274 MB | 768 | 81M+ pulls, 37 chunks/sec on CPU. Default choice |
| qwen3-embedding 0.6B | `qwen3-embedding:0.6b` | 639 MB | 1024 | 32K context, multilingual |
| bge-m3 | `bge-m3` | 1.2 GB | 1024 | 100+ languages |
| mxbai-embed-large | `mxbai-embed-large` | 670 MB | 1024 | High MTEB score |

### Recommended RAG Stack

```
Embedding:  nomic-embed-text (274 MB, fast on CPU)
Vector DB:  ChromaDB or Qdrant
Generation: qwen3:30b-a3b or qwen3:14b
Reranker:   bge-reranker-v2-m3 (optional)
```

### Coding Models

| Model | Tag | Size | HumanEval | Notes |
|---|---|---|---|---|
| **Qwen3-Coder 30B** | `qwen3-coder:30b` | 19 GB | N/A (MoE) | 256K context, best for CPU |
| Qwen2.5-Coder 32B | `qwen2.5-coder:32b` | 20 GB | 92.7% | Dense champion, beats GPT-4o |
| Qwen2.5-Coder 14B | `qwen2.5-coder:14b` | 9 GB | ~89% | Balanced option |
| Qwen2.5-Coder 7B | `qwen2.5-coder:7b` | 4.7 GB | 88.4% | Quick code tasks |

### Reasoning Models

| Model | Tag | Size | Notes |
|---|---|---|---|
| **DeepSeek-R1 32B** | `deepseek-r1:32b` | 20 GB | Local "o1" equivalent. Math, logic, debugging |
| DeepSeek-R1 14B | `deepseek-r1:14b` | 9 GB | Balanced reasoning |
| DeepSeek-R1 8B | `deepseek-r1:8b` | 5.2 GB | Best small reasoning distill |

### Vision / Multimodal Models

| Model | Tag | Size | Notes |
|---|---|---|---|
| **Gemma 4 12B** | `gemma4:12b` | 7.6 GB | Vision, tool-calling, thinking. Best compact multimodal |
| Qwen3-VL 8B | `qwen3-vl:8b` | 6.1 GB | OCR, UI screenshots, visual agents |
| Gemma 3 27B | `gemma3:27b` | 17 GB | 140+ languages, DocVQA 85.6. Batch only |

### Quantization Guide

| Format | Bits | Quality | When to Use |
|---|---|---|---|
| Q3_K_M | 3.3 | ~93% | When Q4 does not fit |
| **Q4_K_M** | 4.8 | ~98% | **Default — best balance for large models** |
| **Q5_K_M** | 5.7 | ~99.5% | Code/math when RAM allows |
| Q6_K | 6.6 | ~99.8% | Precision-sensitive tasks |
| **Q8_0** | 8.0 | ~100% | **Use for models ≤14B (you have the RAM)** |

Decision rule for CPU-only: use the highest quantization that leaves room for OS + context overhead. Unlike GPU where smaller quant = faster, on CPU quality scales directly with quantization level.

### Environment Variables

```bash
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0
export OMP_NUM_THREADS=5
```

### What to Expect vs Cloud

| Task | Local (Qwen3-30B-A3B) | Cloud Equivalent | Gap |
|---|---|---|---|
| General chat | Very good | GPT-4 | Small |
| Coding | Very good | GPT-4o | Small |
| Reasoning | Excellent (R1) | GPT-4 + CoT | Moderate |
| Vision/OCR | Workable | GPT-4V | Large |
| Speed | 2-5 tok/s | 50-100 tok/s | Very large |

Quality is surprisingly close to cloud. Speed is the real tradeoff. Interactive chat at 2-5 tok/s is usable but noticeably slower. Batch processing (overnight) is where CPU-only shines.

### Quick Reference

```bash
# Essential models
ollama pull qwen3:30b-a3b           # General (17 GB)
ollama pull qwen3-coder:30b         # Coding (19 GB)
ollama pull nomic-embed-text         # Embeddings (274 MB)

# Optional models
ollama pull qwen3:8b                 # Fast responses (5 GB)
ollama pull deepseek-r1:14b          # Reasoning (9 GB)
ollama pull gemma4:12b               # Vision (7.6 GB)
ollama pull qwen3:14b                # Balanced (9 GB)

# Batch processing
ollama pull llama3.3:70b             # Best quality (43 GB)

# Check installed models
ollama list
```

---

## Upgrade Path

The single biggest improvement to local AI performance would be adding a GPU:

| Upgrade | Cost | Speed Improvement |
|---|---|---|
| Used RTX 3060 12GB | ~$200 | 5-10x faster than CPU |
| Used RTX 3090 24GB | ~$700 | 10-20x faster, can run 70B Q4 |
| New RTX 5070 12GB | ~$550 | 15-25x faster |

With a GPU, even a budget one, local LLM inference becomes genuinely competitive with cloud APIs for interactive use.
