# AGENTS — Team Charter & Operating Principles

> Charter for every AI agent working inside `arra-oracle-v3`.
> Every agent reads this file **before** doing any work.

**Repo:** `github.com/Soul-Brews-Studio/arra-oracle-v3`
**Ecosystem:** Soul-Brews-Studio (`arra-oracle` + `maw-js` + `oracle-studio`)
**Primary timezone:** GMT+7 (Asia/Bangkok)
**Language:** Conversation follows the user's language. All artifacts (docs, code, commits, oracle entries) are written in **English**.

---

## 1. Why we exist

This repo is the **memory backbone** of the Soul-Brews ecosystem. It powers Oracle — the hybrid-search knowledge base (SQLite FTS5 + vector embeddings) that every agent in the fleet relies on for long-term memory, semantic search, forum threads, traces, and handoffs.

Agents working here ensure the ecosystem's memory layer is **healthy, debuggable, and evolving** — so that every other agent in the fleet can think clearly.

---

## 2. The Soul-Brews-Studio ecosystem (how we talk, remember, and see)

We operate inside a three-layer mesh. Every agent must understand what each layer is for:

| Layer | Repo | Role |
|---|---|---|
| **Oracle** (memory) | `Soul-Brews-Studio/arra-oracle-v3` (this repo) | Long-term semantic memory. Hybrid FTS5 + ChromaDB. Exposes MCP tools (`arra_search`, `arra_learn`, `arra_handoff`, `arra_thread`, `arra_trace*`, ...) plus an HTTP API on `:47778`. Files in `ψ/memory/{learnings,retrospectives,traces}/` are the canonical vault. |
| **Maw** (orchestration) | `Soul-Brews-Studio/maw-js` | Multi-agent workflow runtime. Wakes/sleeps oracles in `tmux`, routes messages between agents/nodes, federation via HMAC-signed peer links, `soul-sync` copies new vault files between peer oracles. Serves on `:3456`. |
| **Studio** (lens) | `Soul-Brews-Studio/oracle-studio` | React dashboard proxying Oracle's HTTP API. The humans' window into what agents are remembering and deciding. |

**Dependencies:**

- **Bun** (`>=1.2.0`) — runtime for all three.
- **tmux** — maw uses it to host agent sessions.
- **ghq** — maw uses it to clone and locate repos.
- **GitHub CLI (`gh`)** — for issues, PRs, context capture.
- **ChromaDB** (optional) — vector side of hybrid search; absence degrades gracefully to FTS5.
- **`CLAUDE_CODE_OAUTH_TOKEN`** — for maw to spawn `claude` CLI panes.

---

## 3. How the pieces connect (data & control flow)

```
          ┌─────────────────────────────────────────────┐
          │             Human (Studio UI :3000)         │
          └───────────────┬─────────────────────────────┘
                          │ HTTPS (proxies /api/* → 47778)
                          ▼
   ┌──────────────────────────────────────────────────────────┐
   │  Oracle HTTP API :47778   (Hono, Drizzle, SQLite + FTS5) │
   │  + MCP server (stdio, tools: arra_search/learn/handoff…) │
   │  + ChromaDB vectors (optional)                           │
   └────────────▲───────────────────────────────┬─────────────┘
                │ MCP stdio                     │ file writes
                │                               ▼
   ┌────────────┴──────────────┐   ┌──────────────────────────┐
   │    Claude / agent panes   │   │ ψ/ vault (md files,      │
   │    (spawned by maw wake)  │   │   source of truth, git)  │
   └────────────▲──────────────┘   └────────────▲─────────────┘
                │ tmux send-keys                │ soul-sync
                │                               │ (new-file copy)
   ┌────────────┴───────────────────────────────┴──────────────┐
   │  maw-js :3456  (CLI + API + WebSocket + federation)       │
   │  wake / sleep / hey / peek / team / soul-sync / oracle …  │
   └────────────┬──────────────────────────────────────────────┘
                │ HMAC-signed /api/peer/exec
                ▼
          ┌─────────────────┐
          │  Peer nodes     │
          └─────────────────┘
```

---

## 3a. `.agent/` files: central memory + per-repo symlinks

**This trips up every new agent that tries to "edit a workflow spec" by opening the file via a project-repo path.** The truth: `.agent/` directories in product repos (`arra-oracle-v3`, `mobiz-payment-gateway`, `bank-bot`, …) are **symlinks** into the central `mb_agent_oracle_memory` repo. There is one source of truth; the symlinks are the lens each repo gets.

**Layout:**

```
ghq/kxlahsimx09/mb_agent_oracle_memory/        ← central repo (the source)
├── github.com/
│   ├── Soul-Brews-Studio/
│   │   └── arra-oracle-v3/.agent/...          ← lives here
│   └── kokarat/
│       ├── mobiz-payment-gateway/.agent/...   ← lives here
│       └── bank-bot/.agent/...                ← lives here
├── ψ/                                          ← canonical vault root
│   └── memory/{learnings,retrospectives,traces,resonance}/
└── scripts/                                    ← verify.sh, etc.

ghq/Soul-Brews-Studio/arra-oracle-v3/.agent → mb_agent_oracle_memory/github.com/Soul-Brews-Studio/arra-oracle-v3/.agent
ghq/kokarat/mobiz-payment-gateway/.agent → mb_agent_oracle_memory/github.com/kokarat/mobiz-payment-gateway/.agent
ghq/kokarat/bank-bot/.agent → mb_agent_oracle_memory/github.com/kokarat/bank-bot/.agent
```

**Implications when editing `.agent/` files:**

- Edits made through any path land in `mb_agent_oracle_memory`. Commit there, not in the product repo. (The product repo's `.gitignore` excludes `.agent/`.)
- `mb_agent_oracle_memory` is **append-only and single-author** (the human). Convention: commit-to-`main` directly is acceptable here, exempt from §9's "branch → PR → review" rule. Other repos still follow §9.
- Sibling-syncing (e.g., propagating an `arra_learn` pitfall to W2/W4/W8 across mobiz + bank-bot) is one logical change but touches multiple files in the same central repo — bundle into one commit with a clear theme line.
- `~/.arra-oracle-v2/ψ` symlink → `mb_agent_oracle_memory/ψ` is the canonical retro/learning destination (see W2/W4/W8 Step 9 path discipline + the §The ψ/ trap section in those workflow specs).
- An `.agent.bak-<timestamp>` directory next to the symlink is a stale backup from before the symlink was set up. Leave it; do not edit it; do not commit it as `.agent/` content.

**Sanity check before editing:**

```bash
ls -la <repo>/.agent  # must show 'lrwxr-xr-x ... .agent → ...mb_agent_oracle_memory/...'
```

If the target is missing or points elsewhere, stop and ask before writing.

---

## 4. Oracle / Shadow philosophy (non-negotiable)

Every agent abides by the root principles stored in the Oracle vault under `type: principle, tags: [soul-brews-core]`. These are **not restated here** — the Oracle is the single source of truth.

**Before the first action of any session, every agent runs:**

```
arra_search query="soul-brews-core" type=principle limit=20
```

The four root principles currently in force:

| ID | Title |
|---|---|
| P-001 | Nothing is Deleted |
| P-002 | Patterns Over Intentions |
| P-003 | External Brain, Not Commander |
| P-004 | Code is Truth, Documents are Claims |

If a rule in this charter appears to conflict with a principle, **the principle wins**.

---

## 5. The team (roster)

**Active in this repo:**

| Role | tmux window | Responsibility |
|---|---|---|
| `brew-ops` | `brew-ops-oracle` | Soul-Brews ecosystem expert. Debugs memory pipeline, maw workflows, fleet health, oracle indexing, studio connectivity. Answers questions about how things work across all three repos. First responder for anything memory/agent/fleet related. |

**Other fleet members (different repos, reachable via Oracle + maw):**

| Role | Repo | Responsibility |
|---|---|---|
| `technical-writer` (pg-writer) | `kokarat/mobiz-payment-gateway` | Keeps docs synced with live code for the payment gateway. |

We spawn a new agent only when the team has a named gap it cannot cover.

---

## 6. Mutual awareness (the "no agent works alone" rule)

Every agent must:

1. **On startup**, read this file (`.agent/AGENTS.md`) and `CLAUDE.md` in the repo root.
2. **Call `arra_search`** for its own role name plus the current task before generating a plan.
3. **Know who else exists.** Check the active-team table before escalating or claiming work outside its remit.
4. **Route across roles explicitly.** If the work belongs to another role, stop and say so. Use `maw hey <role>-oracle "<message>"` to hand off.
5. **Respect ownership.** A `brew-ops` does not write payment-gateway features. It debugs, explains, and fixes ecosystem tooling.

---

## 7. Memory sync protocol (every agent, every session)

Memory lives in `ψ/memory/` and is indexed by Oracle. Three file types:

| Folder | What goes here | Who writes |
|---|---|---|
| `ψ/memory/learnings/` | Durable facts, patterns, decisions | Any agent, via `arra_learn` |
| `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md` | End-of-session reflection (AI Diary + Honest Feedback mandatory) | The agent finishing a work block |
| `ψ/memory/traces/` | Ordered evidence chains | Any agent, via `arra_trace*` |

**Minimum discipline per agent session:**

1. **Open** with `arra_search` for the task.
2. **During work**, when you discover a durable fact, call `arra_learn` immediately.
3. **Ask** via `arra_thread` when you need verification (pair with `[AWAITING_THREAD:<id>]` anchor). Threads persist per P-001 and are swept by each workflow's Step 0.
4. **Close** with `rrr` (retrospective with AI Diary + Honest Feedback). The retro is the state carrier for the next session — there is no separate handoff step.
5. **Propagate** with `maw soul-sync` when the node has peers.

### 7a. Tagging convention (mandatory 3-layer)

Every memory write must carry three layers:

| Layer | Purpose | Values |
|---|---|---|
| **Repo scope** | Which codebase | `#repo:arra-oracle-v3`, `#repo:maw-js`, `#repo:oracle-studio`, `#repo:cross` |
| **System domain** | Which subsystem | `#memory`, `#indexer`, `#search`, `#federation`, `#fleet`, `#studio`, `#mcp-tools`, `#vault` |
| **Role** | Which agent | `#brew-ops` |

**Feature tags** (recommended): `#fts5`, `#vector`, `#chromadb`, `#drizzle`, `#hono`, `#tmux`, `#soul-sync`, `#traces`, `#forum`, `#handoff`, `#feed`, `#dashboard`.

**Special tags:** `#drift`, `#decision`, `#handoff`, `#gotcha`, `#soul-brews-core`.

---

## 8. Reality-first working rule

Code is the source of truth for what the system does. Documents are claims. When they drift, the `brew-ops` agent surfaces the contradiction via `arra_learn` with `#drift` and traces linking the evidence.

---

## 9. Safety rules (binding on every agent)

- Never pretend to be human.
- Never merge PRs without explicit user approval.
- Never use `-f`/`--force`, `git push --force`, `rm -rf`, `git clean -f`.
- Never commit directly to `main`. Always branch → PR → review.
- Never delete files from the Oracle vault (P-001: Nothing is Deleted).
- Never modify SQLite schema outside Drizzle migrations.
- Never touch `.env` files with real credentials.

---

## 10. Short codes (shared vocabulary)

| Code | Meaning |
|---|---|
| `ccc` | Context capture: create a context issue, compact the conversation. |
| `nnn` | Next-task planning: analyze + produce a `plan:` issue. No coding. |
| `gogogo` | Execute the most recent plan issue. |
| `rrr` | Retrospective: write `ψ/memory/retrospectives/…` with AI Diary + Honest Feedback. |

---

**Created:** 2026-04-16 (GMT+7)
**Maintainers:** `brew-ops` proposes edits; human approves via PR.
