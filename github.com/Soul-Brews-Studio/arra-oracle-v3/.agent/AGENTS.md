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

| Role | Repo | System lifecycle | Responsibility |
|---|---|---|---|
| `technical-writer` (pg-writer) | `kokarat/mobiz-payment-gateway` | `#current` | Keeps docs synced with live code for the payment gateway. |
| `technical-writer` (bot-writer) | `kokarat/bank-bot` | `#current` | Keeps docs synced with the Playwright bank-bot. |
| `tester` (pg-tester) | `kokarat/mobiz-payment-gateway` | `#current` | Static-analysis auditor for integration-tests + mock-bank contract. |
| `system-architect` (next-architect) | `kxlahsimx09/mb-next-payment-gateway` | `#next` | Designs the next-generation payment gateway. Reads current-system learnings via Oracle, produces ADRs + subsystem designs. Activated 2026-04-22. |

**System-lifecycle tagging (ecosystem-wide).** Two families of product systems live in parallel:

| Tag | Applies to | Repos |
|---|---|---|
| `#current` | The running production stack | `kokarat/mobiz-payment-gateway`, `kokarat/bank-bot` |
| `#next` | The next-generation successor under design/build | `kxlahsimx09/mb-next-payment-gateway` |
| `#migration-map` | Cross-family mappings (current↔next) | any repo, usually paired with `#repo:cross` |

`#current` vs `#next` is about *which system family* a fact describes, not about recency. A learning written today about `mobiz-payment-gateway` is still `#current` because the fact is about the current production system.

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

## 11. Cross-agent communication (directed inbox)

Threads (`arra_thread`) carry the **content** of agent-to-agent conversations. They are durable and searchable, but they are message boards — they do not wake the recipient. The directed inbox is the **notification** layer that pairs with threads to make agent-to-agent communication actually flow.

**Three-layer separation** (do not collapse):

| Layer | Tool | Purpose |
|---|---|---|
| Notification | `~/.arra-oracle-v2/ψ/inbox/for-{role}/*.md` | Doorbell — its presence wakes the recipient |
| Content | `arra_thread` | Full discussion, persists per P-001 |
| Wake | `scripts/w2-watcher.sh` (Phase 1) | Scans inbox, fires `maw wake <role>` |

### 11a. Path layout — routing by **oracle name**, not role label

Inbox directories are named after the **oracle** (the maw fleet entity that `maw wake` targets), **not** the role label. This matters because role labels can be 1:N with oracles:

| Role label (semantic) | Oracle name(s) (operational) |
|---|---|
| `brew-ops` | `brew-ops` |
| `system-architect` | `next-architect` |
| `technical-writer` | `pg-writer`, `bot-writer` (two oracles, same role) |
| `tester` | `pg-tester` |

The watcher (Phase 2) reads `for-{oracle}/` and fires `maw wake {oracle}`. Routing uses the oracle name because that is the address `maw wake` resolves. Use `maw oracle ls` to discover the current set.

```
~/.arra-oracle-v2/ψ/inbox/                       (symlinked into mb_agent_oracle_memory/ψ/inbox/)
├── handoff/                                     ← existing: self-to-self context pass (unchanged)
├── for-brew-ops/                                ← addressed to oracle "brew-ops"
│   ├── 2026-04-30_14-00_from-next-architect_thread-56_consult.md   ← unread (active)
│   ├── .gitkeep
│   └── handled/
│       └── 2026-04/
│           └── 2026-04-30_13-15_from-pg-writer_thread-42_notify.md   ← archived after read
├── for-next-architect/                          ← addressed to oracle "next-architect"
│   └── …same shape…
├── for-pg-writer/                               ← Phase 3+ when writers/testers join the protocol
├── for-bot-writer/
└── for-{oracle}/                                ← one dir per maw oracle, not per role
```

**Per-node, single-node-local in practice.** Although the path resolves into the central vault repo, in current single-node operation this is a per-node inbox. We do not yet propagate `ψ/inbox/for-*/` via `soul-sync`. When the fleet adds peer nodes, decide explicitly whether to sync (cross-node messaging) or filter (keep per-node).

### 11b. File naming + envelope

**Filename convention** (uses oracle name, matches dir convention):

```
YYYY-MM-DD_HH-MM_from-{source-oracle}_thread-{id}_{type}.md
```

`{type}` ∈ `consult` | `escalate` | `notify`. `_thread-{id}` is omitted only for `notify` envelopes that carry no thread.

**Envelope frontmatter (minimal — do not duplicate thread content here):**

```yaml
---
from: next-architect           # oracle name (routing)
from_role: system-architect    # role label (semantic context, optional)
to: brew-ops                   # oracle name — must match an entry in `maw oracle ls`
to_role: brew-ops              # role label (optional; redundant when oracle == role)
type: consult                  # consult | escalate | notify
thread: 56                     # omit for notify-without-thread
subject: pre-Input-5 checkpoint externalization proposal
context: see thread #56 — if pass-2 still misses, need tooling fix
needs_response: true           # consult/escalate=true; notify=false
priority: normal               # normal | high (escalate uses high)
created: 2026-04-30T14:00:00+07:00
# filled by recipient on archive:
# handled_at: 2026-04-30T15:30:00+07:00
# handled_by_thread: 56
# handled_by_inbox: for-next-architect/2026-04-30_15-30_from-brew-ops_thread-56_reply.md
---

(optional short body — full discussion belongs in the thread)
```

`from`/`to` are the **routing keys** — they must match oracle names. `from_role`/`to_role` are documentation only; the watcher and Step 0.5 sweep do not parse them. They exist so the receiver immediately understands what the sender does in fleet terms (e.g., "this came from `next-architect` who plays the `system-architect` role"), without a round-trip to `maw oracle ls`.

### 11c. Three flows

| Flow | When | Sender writes | Receiver does | Sender continues? |
|---|---|---|---|---|
| **consult** | Need input but can keep working around it | Open thread → write inbox file → mark work doc `[AWAITING_AGENT:{oracle}:thread-{id}]` | Read envelope → `arra_thread_read` → reply in thread → write reply inbox file → archive own inbox file | Yes, around the blocked section |
| **escalate** | Cannot continue — handover required | Open thread → write inbox file (`type=escalate`, `priority=high`) → mark work doc `[BLOCKED:{oracle}:thread-{id}]` → retro + stop | Same as consult, but may need to perform work, not just answer | No — wait for unblock signal (reply inbox file) |
| **notify** | FYI — no response expected | Write inbox file (`needs_response=false`); thread optional | Read on next wake → archive | N/A — fire and forget |

### 11d. Archive protocol (P-001 compliant — never delete)

When the recipient has handled an inbox file, they **move** it (do not delete):

```bash
# from for-brew-ops/, after reading + replying
month=$(date +%Y-%m)
mkdir -p handled/$month
git mv 2026-04-30_14-00_from-next-architect_thread-56_consult.md handled/$month/
```

Before moving, append `handled_at`, `handled_by_thread`, and (if a reply was sent) `handled_by_inbox` to the envelope frontmatter — this is the audit trail the next session reads.

The watcher scans **only** the oracle-root (`for-{oracle}/*.md`); `handled/` is invisible to the wake trigger but remains searchable in git history and via `arra_search` once indexed.

### 11e. Workflow integration (Step 0.5)

Every agent that participates in directed-inbox flows must add a **Step 0.5: directed inbox sweep** to its workflow, immediately after the existing thread sweep (Step 0). The sweep:

1. `ls ~/.arra-oracle-v2/ψ/inbox/for-{my-oracle-name}/*.md` (or via `arra_inbox` once tool-extended in Phase 3). Use `maw whoami` (or check the active tmux session name) to know your oracle name.
2. For each unread envelope: read frontmatter → `arra_thread_read` → respond per type → archive.
3. Only after the sweep settles does the agent proceed with its main workflow task.

If the inbox file says `type=escalate`, treat it as **higher priority** than the original wake reason.

### 11f. Wake semantics — session-per-thread (not session-per-oracle)

Default `maw wake <oracle>` resumes the oracle's most-recent Claude session (via `claude --continue`). For directed-inbox traffic this is wrong — a follow-up consult on thread #56 must continue **the thread-#56 session for that oracle**, not "whatever the oracle was doing last." But the first message in a thread should be `--fresh` so reasoning isn't biased by unrelated prior work.

**Decision rule (by inbox event):**

| Scenario | Wake mode |
|---|---|
| First inbox file for thread `N` to oracle `O` | `--fresh` — no prior session for `O+thread-N` |
| Follow-up inbox file for thread `N` to oracle `O` | `--resume <session-id>` — `O`'s thread-`N` session |
| `type=notify` with no `thread:` field | `--fresh` — fire-and-forget, no continuity |
| `type=notify` with `thread:` field | `--resume` if session-id exists, else `--fresh` |
| Session-id lookup misses (cache evicted, JSONL gone, claude version migration) | Fallback `--fresh` + log warning. Correctness preserved because the thread itself carries content. |

**Why session-per-thread is correct:**

- A consult exchange is a **conversation about a topic**, not a continuation of `O`'s most-recent unrelated work.
- It scales naturally: `O` can be active in several threads in parallel, each with its own clean context window.
- Cross-oracle symmetry: when oracles `A` and `B` exchange in thread `N`, each has their own session for thread `N` — neither reads the other's JSONL, but both share the thread (the content layer) as the source of truth.
- It honors P-003 (External Brain): the thread is the durable record; the JSONL is convenience caching for the oracle that owns it.

**Storage layout (operational state, not vault — eviction allowed):**

```
~/.cache/w2-watcher/inbox-sessions/
├── brew-ops/
│   ├── thread-56.session-id           ← Claude Code session UUID
│   └── thread-58.session-id
└── next-architect/
    └── thread-56.session-id           ← different session from brew-ops's thread-56
```

**Eviction:** when a thread reaches `status=closed`, the watcher drops the corresponding `<oracle>/thread-<N>.session-id` file. TTL backstop: a session-id not resumed for 30 days is dropped (assume thread cold/abandoned). Eviction does not violate P-001 — `~/.cache/` is ephemeral state, not vault content; the thread itself remains intact in Oracle.

### 11g. Phase status (as of 2026-04-30)

- **Phase 1 (current):** Manual fire — sender writes inbox file, human/sender invokes `maw wake <oracle>` directly. Used to validate envelope format on real consult traffic before automating. Dogfooded 2026-04-30 with thread #56 (ADR-9 dispatcher placement) — round-trip ~3 min, envelope format validated. Routing-key correction (oracle name not role label) applied same day before any cross-oracle wake fired. Cold cross-oracle wake test 2026-04-30 18:22 GMT+7 was aborted at startup by the maw-wake silent-fail described under Phase 2b — see learning `2026-04-30_title-maw-wake-template-silent-fail-blocks-phase` and the prior `2026-04-22_maw-wake-role-fresh-prompt-exits-0-as-so`.
- **Phase 2b (now blocking — must land first):** PR into `kxlahsimx09/maw-js` (target `feat/all-prs-rebased` per SKILL.md maw-js workflow). Two scope items, in priority order: **(i) fix `maw wake` silent-fail** — when no continuable session exists for the target oracle, the current `claude --continue || claude -p '<prompt>'` template exits 0 and skips the fallback, leaving the pane at an empty shell. This breaks every `--fresh` wake to a clean worktree. Fix in maw so a `--fresh --task '<prompt>'` invocation always lands at a running claude session that has received the prompt. **(ii) add `maw wake <oracle> --thread <N>` native flag** so maw handles the session-id mapping internally and watcher / future `arra_inbox` MCP / manual ops all become provider-agnostic. Phase 2a is blocked until at least scope item (i) ships and a new local `maw` is installed; without it, every Phase 2a inbox wake silent-fails.
- **Phase 2a (blocked on Phase 2b-i):** Watcher extension in `scripts/w2-watcher.sh` to scan inbox dirs every poll and fire `maw wake <oracle>` automatically. Implements session-per-thread mapping (§11f) entirely in the watcher: lookup `~/.cache/w2-watcher/inbox-sessions/<oracle>/thread-<N>.session-id`, wake with `--resume <sid>` or `--fresh` accordingly. Capture new session-id from newest JSONL after a `--fresh` wake. Floor: `INBOX_MIN_GAP=300s` per oracle. Toggle: `INBOX_SCAN_ENABLED=1` env (default off until merge soak). Implementation deferred until Phase 2b-i lands so the watcher does not need to repeat the template-fallback workaround already carried by `scripts/w2-watcher.sh` commit `6b3662d`.
- **Phase 3:** Telegram alerts for `priority: high` (escalate) envelopes via brew-ops-bot's existing `[BLOCK_*]` detector pattern. `arra_inbox` MCP tool gains `type=directed, oracle=X` filter. "Step 0.5: directed inbox sweep" added to writer/tester workflows fleet-wide (sibling-sync per §3a discipline). When this lands for `pg-writer` / `bot-writer` / `pg-tester`, create their `for-{oracle}/` dirs at the same time.

Multi-recipient broadcast is intentionally **not** in scope. If multiple oracles need the same notification, write multiple files (one per recipient) referencing the same thread. Each recipient gets its own session-per-thread mapping.

---

**Created:** 2026-04-16 (GMT+7)
**Maintainers:** `brew-ops` proposes edits; human approves via PR.
**Updated:** 2026-04-30 — added §11 (directed inbox protocol); same-day fix: routing key is oracle name (not role label), envelope gains `to_role` / `from_role` documentation fields. Same-day discovery: maw wake silent-fail blocks Phase 2a; Phase 2b reordered to land first with the silent-fail root fix as scope item (i).
