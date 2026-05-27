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
- **Agent-engine credentials** — per role engine in fleet: `CLAUDE_CODE_OAUTH_TOKEN` for `claude`, `OPENAI_API_KEY` (or provider equivalent) for `codex`.

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
   │ Agent CLI panes           │   │ ψ/ vault (md files,      │
   │ (claude/codex via wake)   │   │   source of truth, git)  │
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

## 3b. `.secrets/` files: central fleet store + per-repo worktree symlinks

`.secrets/` holds runtime credentials (e.g. `.secrets/supabase.env`). Like `.agent/`, it is **gitignored** — so it is **not carried into a fresh git worktree**. Before this convention, agents reconstructed `.secrets/supabase.env` by hand in every new worktree; worse, some values — a hosted DB password needed by `supabase db push` — **cannot be reconstructed from any API**, so manual recovery physically could not restore them.

**The fix mirrors §3a's `.agent` pattern:** one central, non-git store; per-repo worktree symlinks.

**Layout:**

```
~/.arra-oracle-v2/fleet-secrets/            ← central store root (outside any git repo)
└── <repo>/                                 ← one dir per repo, chmod 700
    └── supabase.env                         ← chmod 600 — the canonical credentials

<repo>.wt-*/.secrets → ~/.arra-oracle-v2/fleet-secrets/<repo>     ← symlink, gitignored
```

**Rules:**

- The central store is the **single source of truth**. Never copy a secret value into a worktree, a thread, an envelope, a commit, or a retro — refer to the store by path only.
- Worktree `.secrets` symlinks are injected automatically by `maw` at worktree-creation and wake (`injectWorktreeSymlinks()` in maw-js `src/commands/shared/wake-session.ts`) — the same mechanism that injects the `.agent` symlink. **Never reconstruct `.secrets/` by hand.**
- Onboarding another repo is purely populating `fleet-secrets/<repo>/` — no code change. `arra-oracle-v3/scripts/backfill-worktree-secrets.sh <repo>` links any pre-existing worktrees.
- A worktree `.secrets` that is a *real directory* (a legacy hand-reconstructed copy) shadows the store — replace it with the symlink.

---

## 3c. Runtime checkouts: `feat/all-prs-rebased` is the deploy source-of-truth

Two **primary checkouts** are live runtimes, not scratch space:

| Primary checkout | Runtime role |
|---|---|
| `~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3` | cwd of the `inbox-watcher.sh` daemon — the fleet's wake mechanism |
| `~/Code/github.com/Soul-Brews-Studio/maw-js` | what `~/.local/bin/maw` execs (`bun src/cli.ts`) on every invocation |

**The discipline (binding on every agent):**

1. **Both primary checkouts stay on `feat/all-prs-rebased`.** That branch is the integration branch every fork PR targets (SKILL.md §maw-js PR workflow) and the deploy source-of-truth. A primary checkout must never be parked on a feature branch.
2. **New code lands by merge-then-pull.** Branch → PR into `feat/all-prs-rebased` → merge → fast-forward the primary checkout (`git fetch` + `git merge --ff-only`). Never live-edit a file in a running checkout, and never `git checkout <feature-branch>` inside a primary checkout.
3. **A live hotfix is a debt, not a workflow.** If a genuine emergency forces a direct edit to a running checkout, that edit is *unmerged work*: until it is PR'd, merged, and the checkout re-synced, the runtime has drifted from source control and nobody else can reproduce it. Close the loop promptly — merge, then re-sync.
4. **A running bash daemon re-reads its own file.** After re-syncing the arra-oracle-v3 primary, restart `inbox-watcher.sh` (`stop` → `start`) so it executes the committed branch code, not a file that changed under it. `maw` re-execs `src/cli.ts` per invocation, so the maw-js primary needs no restart — but it still must be on `feat/all-prs-rebased`.

**Verify before discarding.** When re-syncing a checkout that carries an uncommitted edit, first diff the working-tree file against the merged tip — `git diff <remote>/feat/all-prs-rebased -- <file>`. Empty diff → the edit is fully contained in the merged PRs; safe to discard and fast-forward. Non-empty → there is unmerged work; **stop and flag it**, do not discard.

> Precedent: the 2026-05-17 re-sync (thread #149) cleaned up exactly this drift — a #71/#72 hotfix had been live-edited into `scripts/inbox-watcher.sh`, and the maw-js primary had been parked on `feat/worktree-secrets-injection` instead of `feat/all-prs-rebased`.

**Sibling discipline — `mb-next-payment-gateway` primary stays on `main`.** Added 2026-05-21 after thread #199 / parent #181 (the wt-48 / PR #215 stale-base trap). Unlike `arra-oracle-v3` + `maw-js`, the `mb-next-payment-gateway` primary is not a runtime — but its **local `main` ref is** the freshness anchor every maw-spawned wt inherits. If the primary parks on a non-`main` branch, local `main` freezes; maw-js PR #8 fast-forwards local default on `createWorktree` (closing the fresh-spawn side), and `inbox-watcher.sh` Path 1 pre-resume fetch does the same on resume, but the primary's own state still drifts visibly when no one fast-forwards it directly. Discipline: `git fetch origin && git merge --ff-only origin/main` on the primary regularly; never let it park on a feature branch (precedent: `poc-implement/admin-web-dark-theme-2026-05-13` sat on the primary for 8 days; local `main` froze at `a24175c` while `origin/main` advanced to `52a4530`).

---

## 3d. Branching from `main` — never trust local `main` blindly (thread #199)

When any agent (architect / writer / impl / brew-ops) opens a feature branch off `main`, the canonical form is:

```bash
git fetch origin --quiet
git switch -c <role>/<slug> origin/main   # or origin/<default-branch>
```

**Not** `git checkout main && git checkout -b <branch>`. That second form branches off whatever the local `main` ref currently is — which is the primary checkout's last-pulled SHA. On a §3c primary parked on a non-default branch, that ref can be days stale. **Reproduced 2026-05-21:** writer's wt-48 local `main` = `a24175c` (8 days stale); `origin/main` = `52a4530` (current); PR #215 opened against the stale base; orchestrator caught it via `gh pr view --json baseRefOid` mismatch with `git merge-base`.

maw `createWorktree` + `inbox-watcher.sh` Path 1 now fast-forward local `main` automatically on spawn / resume, so the natural form works on a maw-spawned wt. But the explicit `origin/main` form is defense-in-depth — it stays correct even when (a) `git fetch` silently fails (offline), (b) `update-ref` is refused (default branch checked out elsewhere), (c) the agent is on a manual checkout that maw never touched. The cost is one extra word per branch creation; the benefit is "stale-base trap" simply cannot happen.

Skill-level boilerplate carries this form (next-architect W1 + W2, next-writer W1, brew-ops maw-js PR workflow). When you author a new workflow, follow the same pattern.

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
| `implementation-architect` (next-impl) | `kxlahsimx09/mb-next-payment-gateway` | `#next` | Materializes ratified ADRs as cheap runnable PoCs + spec tests + drift reports. Mines `#current` evidence into PoC fixtures + spec-test cite blocks. Sibling to next-architect (upstream) and future next-dev (downstream). Activated 2026-05-04. |

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

1. **On startup**, read this file (`.agent/AGENTS.md`) and the repo runtime guide (`CLAUDE.md` and/or engine-specific notes) in the repo root.
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

## 8a. Delegation defaults — shared sub-agents (every role, every repo)

Two **sonnet** sub-agents are installed user-level (`~/.claude/agents/`, deployed by `arra-oracle-v3/scripts/install-fleet-subagents.sh`) and are available to every role in every repo. **Delegate to them by default** — don't do these two jobs inline in your main session. Reason: both produce large/noisy/PII-heavy tool output; running them in a sub-agent keeps that out of your (often opus) main context and runs cheaper, and you get back only the distilled conclusion.

| Sub-agent | Delegate when you need to… | Don't |
|---|---|---|
| **`code-finder`** (sonnet) | search code — find a symbol/definition, who-calls-X, where-is-Y-implemented, config/constant lookup, any multi-file sweep where you only want the conclusion (file:line + excerpt) | edit code (read-only); "what changed recently" → that's `context-finder` |
| **`dpay-finder`** (sonnet) | look up anything in the **dpay PRODUCTION payment DB** (transactions, ts_deposits, ts_payouts, wallets, bank_accounts, merchants, settlements, callback_logs, audit_trail, …) | mutate prod (read-only) |

Defaults, not handcuffs: a single trivial grep you already know the path for, or one quick `count`, can stay inline — but the moment a search fans across files or a prod query might return volume/PII, hand it off. The orchestrator delegating here is still coordination (a read-only lookup to inform routing), not agent work — it is exempt from the §Scope guard's edit block since these sub-agents do not Edit/Write.

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
| `implementation-architect` | `next-impl` |
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
parent_thread: 100             # optional — set by orchestrator when fanning out
parent_oracle: orchestrator    # optional — pairs with parent_thread; identifies who is aggregating
parent_session: /Users/dev01/Code/.../arra-oracle-v3.wt-9-inbox-…  # optional — §151 sticky ownership; the dispatcher's own worktree path (its cwd)
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

`parent_thread` + `parent_oracle` are introduced for the orchestrator fan-out pattern (§11k). They are optional fields with no impact on routing — recipients ignore them in the standard sweep. The orchestrator's Step 0.5 sweep groups incoming reply envelopes by `parent_thread` to know which sub-tasks of which parent request have completed.

`parent_session` (§151 sticky thread→session ownership) is set by the **dispatcher** on every **outbound dispatch** envelope it writes — its value is the dispatcher's own worktree path (its `pwd`). It carries the worktree, not the session-id UUID, because an agent session cannot reliably self-discover its UUID mid-run but always knows its cwd; the watcher derives the UUID from the worktree when it needs one. Only the dispatcher populates it, and only on dispatch envelopes — workers do **not** echo it onto reply envelopes. The watcher reads it off the outbound dispatch envelope and records the campaign owner (see §11f); reply routing then sends the reply back to that exact session. Absent `parent_session` ⇒ the watcher falls back to its pre-§151 behaviour (a fresh session becomes de-facto owner).

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
2. **Campaign-scope the sweep (thread #214).** `for-{oracle}/` is shared across *all* sessions of that oracle. Under the §181 parallel-sessions-same-role pattern an oracle can have several concurrent sessions, each owning a *different* campaign — so the dir holds envelopes that belong to your **sibling** sessions, not you. Establish **your** campaign's wake key = `parent_thread` (else `thread`) of the envelope the watcher handed you (the `inbox: <fname>` you were woken with), and handle **only** envelopes whose wake key matches. Leave the rest in place — a sibling session owns them, and the watcher has delivered (or will deliver) them there. This mirrors the watcher's own routing key (§11f) and the §11l Stop-hook gate, so the two never disagree. **Exception — the orchestrator** is the multi-campaign hub: `for-orchestrator/` legitimately collects replies from *every* campaign it owns (one hub session spans many wake keys), so the orchestrator **sweeps** whole-dir, not wake_key-scoped. But under §181 there can be *concurrent* orchestrator sessions, each owning a different subset of campaigns — so the orchestrator's §11l Stop-hook **gate** (close-out enforcement) is scoped by **§151 ownership**, not whole-dir: each session is gated only on campaigns whose owner worktree is its own (§238). Sweep-reads-all, close-out-owns-own — a sibling-owned reply the session sees in the dir is the sibling's to close, exactly as §151 routing delivered it. The orchestrator gate and the §151 routing never disagree (both key the orchestrator on owner); every other oracle keys on wake_key.
3. For each **in-scope** unread envelope: read frontmatter → `arra_thread_read` → respond per type → archive.
4. Only after the sweep settles does the agent proceed with its main workflow task.

If the inbox file says `type=escalate`, treat it as **higher priority** than the original wake reason.

### 11f. Wake semantics — session-per-thread (not session-per-oracle)

Default `maw wake <oracle>` resumes the oracle's most-recent engine session (engine-native resume, e.g. `claude --continue`). For directed-inbox traffic this is wrong — a follow-up consult on thread #56 must continue **the thread-#56 session for that oracle**, not "whatever the oracle was doing last." But the first message in a thread should be `--fresh` so reasoning isn't biased by unrelated prior work.

**Decision rule (by inbox event):**

| Scenario | Wake mode |
|---|---|
| First inbox file for thread `N` to oracle `O` | `--fresh` — no prior session for `O+thread-N` |
| Follow-up inbox file for thread `N` to oracle `O` | `--resume <session-id>` — `O`'s thread-`N` session |
| `type=notify` with no `thread:` field | `--fresh` — fire-and-forget, no continuity |
| `type=notify` with `thread:` field | `--resume` if session-id exists, else `--fresh` |
| Session-id lookup misses (cache evicted, JSONL gone, engine-path/version migration) | Fallback `--fresh` + log warning. Correctness preserved because the thread itself carries content. |

**Wake key — campaign-scoped, not always `thread:` (§11k):** the session map is keyed by a *wake key*, not always the envelope's own `thread:`. **Any** envelope carrying a `parent_thread:` (a §11k fan-out sub-task envelope) keys on `parent_thread` — for **every** oracle, not just the orchestrator. This bounds sessions to **one per oracle per campaign**, not one per sub-thread:

- **orchestrator:** every reply of one fan-out campaign resumes the **same** orchestrator session instead of each `--fresh`-spawning its own. Without this, N concurrent sub-thread replies spawn N orchestrator sessions that each re-run Step 0.5 and re-dispatch the same follow-up (the 2026-05-16 triple-dispatch incident — see §11k).
- **worker agents** (`next-impl` / `next-writer` / `pg-writer` / `bot-writer` / `next-architect`): a new sub-thread of an in-flight campaign `--resume`s the agent's campaign session rather than `--fresh`-spawning a per-sub-thread session — the per-thread session-sprawl source. A **new** campaign (new `parent_thread`) still gets a new session, so context stays campaign-scoped: no cross-campaign bias bleed, parallelism across campaigns preserved. It is deliberately **not** collapsed to one-session-per-agent-forever.

Envelopes with no `parent_thread` (campaign-parent threads, standalone consults) key on their own `thread:` id, unchanged. The session-id file is `sessions/<oracle>/thread-<wake-key>.session-id`.

**Sticky thread→session ownership (§151) — routing replies to the OWNER.** The wake key tells the watcher *which campaign* a reply belongs to; it does not tell it *which session* owns that campaign. Before §151, the owner was whatever session the watcher itself last spawned — so a thread opened *inside* an already-running session (a human-driven session, or any session that called `arra_thread` directly) was never recorded as owner, and the first reply `--fresh`-spawned a new session that usurped ownership (the #140/#141 context-fragmentation + session-sprawl incident).

§151 closes this: the dispatcher stamps `parent_session` (its worktree path) on outbound dispatch envelopes (§11b); the watcher records `sessions/<parent_oracle>/thread-<parent_thread>.owner = <worktree path>` the moment it scans that dispatch envelope — before any reply exists. A later reply for that campaign routes back to the **owner**:

| Owner worktree state | Watcher action |
|---|---|
| process up, JSONL **active** (mid-turn) | `deferred` — re-checked each scan |
| process up, JSONL **idle** (at prompt) | `tmux send-keys` the prompt into the owner's live window — `status=delivered_to_owner` |
| **no process**, worktree present | `maw wake --resume` the owner's session in its own worktree |
| worktree **gone** | `--fresh` spawn; new worktree **inherits ownership** (owner record rewritten) |

An owned campaign's replies are serialized through the one owner session (`campaign_inflight`): one reply is routed at a time, the rest defer. Owner-routed worktrees are retire-exempt — the watcher never retires a worktree it did not spawn. Human-collision policy: send-keys fires only on the JSONL-idle gate (never mid-turn); a human who typed-but-did-not-submit sees the appended text in their input buffer — visible and recoverable, the accepted residual.

**Why session-per-thread is correct:**

- A consult exchange is a **conversation about a topic**, not a continuation of `O`'s most-recent unrelated work.
- It scales naturally: `O` can be active in several threads in parallel, each with its own clean context window.
- Cross-oracle symmetry: when oracles `A` and `B` exchange in thread `N`, each has their own session for thread `N` — neither reads the other's JSONL, but both share the thread (the content layer) as the source of truth.
- It honors P-003 (External Brain): the thread is the durable record; the JSONL is convenience caching for the oracle that owns it.

**Storage layout (operational state, not vault — eviction allowed):**

```
~/.cache/w2-watcher/inbox-sessions/
├── brew-ops/
│   ├── thread-56.session-id           ← Agent session UUID
│   └── thread-58.session-id
└── next-architect/
    └── thread-56.session-id           ← different session from brew-ops's thread-56
```

**Eviction:** when a campaign's worktree is retired (thread `status=closed` + safety gates pass), the watcher drops the corresponding `<oracle>/thread-<wake-key>.session-id` file — guarded so a live campaign sibling keeps its session. TTL backstop: the §11i Path 2b GC sweep drops any session-id idle for 30 days (assume the campaign is cold/abandoned). Eviction does not violate P-001 — `~/.cache/` is ephemeral state, not vault content; the thread itself remains intact in Oracle.

### 11g. Loop termination

A directed-inbox conversation ends in one of three ways:

| Termination | Trigger | What happens |
|---|---|---|
| **Resolved** | Sender (initiator) is satisfied with the answer | Sender: `arra_thread_update(threadId=N, status="closed")`, archive last received envelope (no follow-up envelope). |
| **Moot** | Receiver finds the thread already closed (e.g. user ratified out-of-band) | Receiver: archive incoming envelope with `handled_note: thread N already closed at message <last>` (no reply envelope, no thread message — closed thread is read-only by convention). |
| **Escalated** | Either side cannot continue without human input | See §11h. |

**Receiver discipline when reading any inbox file:**

1. After `arra_thread_read(threadId)` in Step 0.5 sweep, check the thread's `status` field.
2. If `status == "closed"`:
   - Don't post a new message in the thread (closed = read-only).
   - Don't write a reply envelope.
   - Just archive the incoming envelope with `handled_note: thread N already closed at message <last>`.
3. If `status == "active"` or `"pending"`:
   - Process the envelope normally (consult/escalate/notify per §11c).

**Sender discipline when satisfied with a consult:**

1. Last message in thread is the answer; sender writes nothing more in the thread (or writes a brief "thanks, closing" note if helpful for trace clarity).
2. `arra_thread_update(threadId=N, status="closed")` to mark the thread closed.
3. Archive the final reply envelope received (per §11d).
4. Resume primary work — `[AWAITING_AGENT:{oracle}:thread-N]` markers in own work doc are now resolvable.

**Loop guards (advisory, not enforced in v1):**

- Soft round limit: if a thread exceeds 6 round-trips between two oracles without converging, treat as an escalation candidate.
- Idle timeout: a thread with no activity for 24h triggers a sender-side review (is the thread still relevant? close or escalate).

The watcher (§11i) surfaces stuck threads via the failure-detection pipeline (`failed_stuck` state).

### 11h. Escalation to human

Escalation = the agents cannot resolve the question among themselves and need the human to weigh in. Two flavors:

| Flavor | Marker | Action |
|---|---|---|
| **Block-on-human** | `[ESCALATE_TO_HUMAN:thread-N:reason]` in own work doc | Stop work on the dependent path; thread stays `active`/`pending`; brew-ops-bot detector (see SKILL.md operations infrastructure) picks up the marker and sends a Telegram alert with the marker text. Phase 3 wires the auto-alert; until then, the marker is a documentation signal that an `rrr` retro carries forward. |
| **Soft-ask** | Thread message addressed to user (`@user` mention or "needs ratification") | Thread stays `pending`; user reads in studio dashboard (`/forum`) and responds when ready. No Telegram unless the marker pattern above is also written. |

**When to escalate:**

- Decision exceeds either agent's authority (e.g. architectural direction, security trade-off, merging to upstream).
- Two agents disagree after a fair exchange (3+ rounds without convergence).
- New surface area is exposed that wasn't in scope (e.g. a consult about ADR-9 reveals an ADR-11 gap).
- Either agent hits a non-obvious gate (auth, credentials, infra change) that the human owns.

**Don't escalate for:**

- Fact lookups one agent can do alone (`arra_search`, `git log`).
- Work the agent is qualified to do (per its role's "what I own" table in the SKILL.md).
- Mere lack of context — that's what the thread is for.

**Marker placement convention:**

The `[ESCALATE_TO_HUMAN:thread-N:reason]` marker lives in the agent's own work artifact (`docs/adr.md`, `docs/current-system.md`, retro file, etc.) — wherever the work would have continued if the escalation hadn't happened. The marker is a beacon: any reader of the work doc sees the escalation, the reason, and the thread for context.

### 11i. Watcher integration + delivery verification

The watcher (`scripts/inbox-watcher.sh`) closes the directed-inbox loop by firing `maw wake` in response to new envelopes and verifying that each wake actually delivered. Without verification, silent-fails (agent CLI crashed, prompt truncated, agent stuck) accumulate invisibly.

**Cadence + state directory:**

- Poll every `INBOX_POLL_INTERVAL=60s` (default; configurable via env).
- State at `~/.cache/inbox-watcher/state/<oracle>/<filename>.state` per envelope.
- Session map at `~/.cache/inbox-watcher/sessions/<oracle>/thread-<wake-key>.session-id` — the wake key is `parent_thread` for any fan-out sub-task envelope (every oracle), else the envelope's own `thread:` (§11f).
- Log at `~/.cache/inbox-watcher/inbox-watcher.log`.

**State machine per envelope file:**

```
NEW                                      (no state file)
  ├─ orchestrator envelope whose parent campaign already has a live or
  │  in-flight session (§11k dedup)       → status=deferred, deferred_since=<ts>
  │                                        (no wake fired — queued, not dropped)
  └─ otherwise                            → fire_wake → status=fired,
                                            fired_at=<ts>, wt_path=<from maw>

deferred                                  (re-checked every scan)
  ├─ parent campaign idle (no fired/verified sibling for the wake key, prior
  │  prior engine session not active)     → fire_wake (--resume into the
  │                                          campaign worktree) → fired
  └─ parent campaign still busy           → keep deferring (alert past T2,
                                            but the envelope is never dropped)

fired                                    (T1 gate — delivery probe)
  ├─ JSONL has user message containing "inbox: <fname>"
  │                                      → status=verified + capture session-id
  ├─ T1_DELIVERY_DEADLINE elapsed (default 60s) and no JSONL/no prompt
  │                                      → status=failed_no_prompt + alert
  └─ otherwise                           → keep polling

verified                                 (T2 gate — processing)
  ├─ envelope file moved out of for-{oracle}/ root
  │                                      → status=completed
  ├─ T2_PROCESSING_DEADLINE elapsed (default 1800s = 30 min) and file still present
  │                                      → status=failed_stuck + alert
  └─ otherwise                           → keep polling

completed | failed_*                     (terminal — kept for audit)
```

`deferred` is **not** a failure — it is a queued state for orchestrator fan-out dedup (§11k). A deferred envelope has had no wake fired yet; it is re-evaluated each scan and fires (as a `--resume`) the moment its parent campaign's session goes idle. It is never dropped.

**Three failure modes the watcher distinguishes:**

| Status | Cause | Operator action |
|---|---|---|
| `failed_no_prompt` | `maw wake` returned 0 but JSONL never appeared, or JSONL exists without a user message containing the inbox filename. Indicates a wake-mechanism regression (silent-fail returned, prompt was truncated, JSONL written to unexpected path). | Re-read silent-fail learnings (`2026-04-22`, `2026-04-30`); `maw peek <pane>`; rebuild maw if recently changed; re-fire manually for that envelope. |
| `failed_stuck` | Wake delivered (JSONL has the prompt) but envelope is still in `for-{oracle}/` after T2. Agent received the prompt but didn't archive — could be stuck in a tool, errored, lost the protocol thread, or simply slow. | Read the agent's JSONL to see what they did; manually archive if appropriate; raise to Telegram if the pattern repeats per receiver. |
| `completed` | Envelope archived under `handled/YYYY-MM/`. | None — clear state file after audit retention window (default 7 days). |

**Toggle:** `INBOX_SCAN_ENABLED=1` env (default on once `inbox-watcher.sh` is running).

**Idempotency:**

The watcher is safe to restart. State files are per-envelope and only re-fire on `NEW` (no state file). Restart never re-fires a `fired`/`verified` envelope unless its state file is manually deleted. The state dir (`~/.cache/inbox-watcher/`) persists across restart, so a code-swap restart (`stop` → swap → `start`) drops no in-flight envelopes.

**Path 2b — periodic campaign GC sweep:**

The per-envelope retire (`maybe_retire_worktree`) only fires the instant an envelope reaches `completed`. A periodic sweep (`gc_sweep`, cadence `INBOX_GC_INTERVAL`, default 600s; gated by `INBOX_AUTO_CLEAN`) mops up what it misses:

1. **Late-close retire** — an envelope that reached `completed` *before* its thread closed had its retire SKIPPED (`thread-not-closed` gate) and the thread closing later triggers nothing. The sweep re-runs the retire gate on every `completed`-but-not-`retired_at` envelope.
2. **Session-id eviction** — drops session-id cache files on retire (§11f) and via a 30-day idle TTL.
3. **Orphan-worktree prune** — worktrees abandoned by crashes / manual `tmux` kills (no tmux window, no live agent CLI process, not referenced by any envelope state) are removed under the same git-clean + no-unpushed gate as the per-envelope retire (#116). This makes the manual 47→5 worktree purge routine.

`.agent.bak-*` directories are deliberately **not** GC'd — they can hold pre-symlink `.agent/` memory content, so auto-deletion would risk a P-001 violation (see §3a). Pruning them stays a human-ratified action.

**Operational integration:**

- Lives alongside `w2-watcher.sh` and `brew-ops-bot/` in `arra-oracle-v3/scripts/` (see SKILL.md operations infrastructure).
- Started under `nohup ... & disown` like the other daemons.
- `pgrep -fl inbox-watcher` for liveness.
- `bash scripts/inbox-watcher.sh status` for state + recent transitions.

**Failure alerting (Phase 3):**

Phase 1 surfaces failures via the watcher log only. Phase 3 wires `failed_no_prompt` and `failed_stuck` into `brew-ops-bot/detector.sh` so Telegram alerts go out automatically without reading the log.

### 11k. Orchestrator fan-out pattern

The `orchestrator` oracle is a coordinator role (Phase 4). It does not do agent work — it dispatches to other agents and aggregates their replies. The fan-out pattern uses two optional envelope fields, `parent_thread` and `parent_oracle` (§11b), to link sub-task threads back to a parent request thread.

**Fan-out shape (orchestrator's perspective):**

```
User request → orchestrator opens parent thread #100
                                        │
              ┌─────────────────────────┼─────────────────────────┐
              ▼                         ▼                         ▼
         sub-thread #101           sub-thread #102           sub-thread #103
         (ortho ↔ writer)          (ortho ↔ tester)          (ortho ↔ arch)
              │                         │                         │
         envelope                  envelope                  envelope
         to: pg-writer             to: pg-tester             to: next-architect
         thread: 101               thread: 102               thread: 103
         parent_thread: 100        parent_thread: 100        parent_thread: 100
         parent_oracle: orchestrator (×3)
              │                         │                         │
              ▼                         ▼                         ▼
         (each agent runs §11e Step 0.5 sweep, replies in own sub-thread,
          writes notify envelope back to for-orchestrator/)
              │                         │                         │
              └─────────────────────────┼─────────────────────────┘
                                        ▼
              orchestrator's Step 0.5 sweep groups by parent_thread
              ↓ when all subs are closed (or stuck)
              orchestrator posts aggregated final to parent #100
              orchestrator closes parent #100
              orchestrator notifies user (via orchestrator-bot daemon)
```

**Parent-thread lifecycle:**

| Stage | Trigger | Action |
|---|---|---|
| Open | New request envelope arrives at `for-orchestrator/` | Open parent thread, post plan; for each sub-task, open sub-thread + write envelope with `parent_thread=<parent>` |
| Mid-stream | Each time orchestrator wakes via inbox sweep (sub reply landed) | Post short progress update to parent thread; chat-watcher mirrors to user Telegram |
| Aggregate | Last sub-thread reaches `closed` status | Post aggregated final to parent thread (cite each sub by id); close parent (`status=closed`) |
| Stuck | Watcher reports `failed_stuck` for any sub | Post warning to parent; either retry, redirect, or escalate per §11h |

**Recipient discipline (other agents):**

Other agents are **unchanged** by §11k at the *behaviour* level. They process incoming envelopes per §11e Step 0.5, reply in their own sub-thread, and write a reply envelope back to `for-{from}/` per §11d. The `parent_thread` field is metadata they ignore for their own routing — only the orchestrator reads it during aggregation.

What *did* change (2026-05-16): the **watcher** now keys every oracle's wake on `parent_thread` (§11f), so a worker agent's repeated sub-task envelopes for one campaign `--resume` a single campaign session instead of `--fresh`-spawning one per sub-thread.

**Updated 2026-05-17 (§153) — workers now also get the dedup logic.** The 2026-05-16 carve-out ("a worker's each sub-task is genuine new work, not a re-dispatch") held only while the worker was *idle* — `fire_wake` Path 1 `--resume`s an idle/dead campaign session. A *busy* worker (mid-turn) getting a 2nd same-campaign dispatch fell through to `--fresh` and spawned a **sibling** worker session (the wt-43/wt-46 incident — thread #151 — where the sibling flailed and tripped the §11l circuit-breaker). §153 closes this: the §151 owner map (oracle-agnostic — `fire_wake` records `owner[oracle][wake_key]` for every oracle) already routes a 2nd dispatch with a recorded owner; and the `parent_session_busy` fallback below is un-gated from the orchestrator, so even a no-owner-record case defers a same-campaign sibling and serializes onto the existing session. Un-defer still routes through `fire_wake` Path 1 `--resume`, so campaign-session reuse is unchanged — only the busy-worker case flips from `--fresh` sibling to defer-then-resume. Watcher impl: arra-oracle-v3 fork PR #77; dispatched on thread #153.

**Why parent + sub (not single thread):**

- Voice separation: parent thread is user ↔ orchestrator's reasoning; sub threads are orchestrator ↔ specific agent (1-on-1, focused).
- Existing infrastructure reuse: sub-threads use the same session-per-thread mapping (§11f) as any other directed-inbox conversation, so warm-context resume works per agent per topic.
- Studio UI shows hierarchy cleanly (parent thread links to its subs).
- Closing logic cascades: sub closes when its agent finishes, parent closes when all subs close.

**Watcher dedup — one orchestrator session per campaign:**

The §11i watcher keys orchestrator wakes on `parent_thread` (the *wake key*, §11f), not on the individual sub-thread. When a fan-out reply lands while the campaign's orchestrator session is still live or in-flight, the watcher does **not** `--fresh`-spawn a sibling — it marks the envelope `deferred` and, once that session goes idle, fires `--resume` into the **same** worktree so the reply is processed by the one orchestrator session. This serializes a campaign's replies through a single session.

Without this, N concurrent sub-thread replies each spawned a separate orchestrator session, and each ran its own Step 0.5 sweep and independently re-dispatched the same follow-up — one fan-out task implemented N times in parallel (the 2026-05-16 triple-dispatch incident: PR #129/#130/#131 for one task; escalation #348, thread #134). Genuinely distinct campaigns (different `parent_thread`) are unaffected and still run concurrently.

**Sticky ownership (§151, 2026-05-17) — the dedup target is the OWNER.** The dedup above keyed a campaign onto whatever session the watcher last spawned. But a campaign opened *inside* an already-running orchestrator session (a human-driven one, or any session that called `arra_thread` directly) has no watcher-spawn event — so the first reply still `--fresh`-spawned a new orchestrator that became de-facto owner (the #140/#141 fragmentation + sprawl, on top of what the 2026-05-16 fix already addressed). §151 fixes this: the dispatcher stamps `parent_session` on the dispatch envelope (§11b), the watcher records the campaign owner, and replies route back to that exact session — `send-keys` into it if live, `--resume` it if down, `--fresh` + ownership-transfer only if its worktree is gone (full routing table in §11f). The recipient discipline for **other agents is still unchanged** — they reply in their sub-thread and write a reply envelope per §11d; only the watcher's routing changed.

Multi-recipient broadcast (one envelope to many recipients) is still **not** in scope. Fan-out writes one envelope per recipient — that's the explicit, observable contract.

### 11l. Loop-closure enforcement (the Stop hook)

§11c–§11g describe what a recipient *must* do; §11e Step 0.5 puts it in every workflow. But a workflow step is advice — agents skip it. **Observed 2026-05-17 (thread #140):** next-impl (PR #135) and next-writer (PR #139) were dispatched `needs_response: true` on thread #132, did the work, pushed their PRs — and exited without sending a reply envelope or posting to the thread. Several inbound envelopes also sat unarchived (threads #124/#125/#128/#130/#136). Two recurring gaps: (a) no reply envelope on `needs_response: true`; (b) no §11d archive of the inbound envelope.

The fix is **not** another workflow step. It is a harness-level gate: `scripts/inbox-loop-closure-hook.sh`, currently registered as a **Claude Code** `Stop` hook (installed via `scripts/install-inbox-loop-closure-hook.sh` into `~/.claude/settings.json`). A dispatched oracle's session **cannot end** while its loop is open.

**What the hook checks**, every time an oracle session tries to stop:

1. **Who am I?** Reverse-looks-up the session id (from the Stop-hook payload) against the inbox-watcher's `state/<oracle>/*.state` and `sessions/<oracle>/*.session-id` maps. **Self-gating:** if the session was not spawned by the inbox-watcher to handle an envelope, the hook is a silent no-op. Regular dev sessions and non-oracle panes are never affected — which is why a global install is safe.
2. **Archive gap.** Any `*.md` still in `for-{oracle}/` root → block the stop (exit 2; the agent sees the reason and continues). The agent must run §11c/§11d — reply, then `git mv` to `handled/`.
3. **Reply gap.** Any envelope in `for-{oracle}/handled/` (recent mtime window) with `needs_response: true` but missing **both** `handled_by_inbox` and `handled_note` → block. A `needs_response` envelope archived with neither field was archived without a reply (a correctly-closed one has `handled_by_inbox`; a §11g moot one has `handled_note`).
4. **Circuit breaker.** After `MAX_BLOCKS` (default 3) consecutive blocks on the same session the hook stops blocking — but it does **not** fail silently: it writes a `priority: high` `notify` envelope to `for-orchestrator/` and logs to `~/.cache/inbox-loop-closure/escalations.log`. A genuinely stuck agent becomes a visible orchestrator signal, not a silent stall.

**Per-session scoping (checks 2–3 are not whole-dir).** Under concurrent same-oracle sessions (§181), `for-{oracle}/` holds envelopes belonging to *sibling* sessions' campaigns; a whole-dir gate would false-block a session on envelopes it does not own (and that it must not archive — doing so corrupts the sibling's audit trail). So the archive-gap and reply-gap checks are scoped to the campaigns **this session owns**:
- **Non-orchestrator oracles** — by **wake_key** (`parent_thread` else `thread`, the §11f/#214 key), derived from the watcher `state/<oracle>/*.state` files that name this session's `session_id`. One session owns one campaign.
- **The orchestrator** — the multi-campaign hub, where one session legitimately spans many wake_keys, so wake_key scoping cannot apply. Scoped instead by **§151 ownership** (§238): an envelope is in scope iff its campaign's recorded owner worktree (`sessions/orchestrator/thread-<wake_key>.owner`) equals this session's worktree. This fixes the multi-session false-block re-hit ~5× during campaign #228/#234/#237 (2026-05-26), where wt-20 was gated on thread-216 envelopes owned by wt-21.

Unattributable scope (cache miss / unknown sid / no owner record / no wake_key) falls back to gating whole-dir: over-blocking is safe (the T2 `failed_stuck` backstop below), whereas silently skipping a genuinely-owned envelope would re-open the #140 silent-stall class.

**Fail-open.** Any unexpected error in the hook allows the stop — a hook must never wedge a session. The inbox-watcher T2 `failed_stuck` gate (§11i) remains the out-of-band backstop.

The hook is the enforcement layer; §11c–§11g remain the source of truth for *what* correct close-out looks like. Owner: `brew-ops`. Re-run the installer after editing the hook (the repo copy is canonical; Claude deployment target is `~/.claude/hooks/`).

**Follow-up (not yet done):** move hook injection into `maw wake` (set `ARRA_ORACLE` + a fleet `--settings`) so the gate is fleet-runtime-owned and survives multi-node, instead of relying on a node-global `~/.claude/settings.json`. This is also where `codex` parity should be wired (same loop-closure policy, engine-specific hook plumbing).

### 11j. Phase status (as of 2026-05-03)

- **Phase 1 (shipped 2026-04-30):** Manual fire — envelope spec + 3 flows + archive protocol + session-per-thread wake decision rule. Dogfooded with thread #56 (ADR-9 dispatcher placement) — manual round-trip ~3 min. Cold cross-oracle wake test 2026-04-30 21:00 GMT+7 passed end-to-end after Phase 2b-i landed: next-architect (no §11 in own charter) self-discovered the protocol via vault grep and followed §11d archive correctly.
- **Phase 2b-i (shipped 2026-04-30):** `maw wake` silent-fail fix in `kxlahsimx09/maw-js` PR #3 → merge `4e441b57` on `feat/all-prs-rebased`. Filesystem-probe `~/.claude/projects/<encoded>/` before emitting the command; `--fresh` strips `--continue`/`--resume` and the `||` fallback; prompt baked into both branches when fallback emitted. Verified end-to-end: clean `claude -p '<prompt>'` lands at running session, prompt delivered.
- **Phase 2a (in progress 2026-05-03):** `scripts/inbox-watcher.sh` per §11i. Implements 3-gate state machine (delivery T1 + processing T2 + stuck-detect), session-per-thread capture from JSONL, fail-aware logging. PR target arra-oracle-v3 fork main per `feedback_fork_prs_not_upstream`. No template-fallback workaround needed (Phase 2b-i removed the silent-fail root cause).
- **Phase 2b-ii (deferred):** `maw wake <oracle> --thread <N>` native flag in maw-js. Useful but not blocking — Phase 2a watcher implements the session-per-thread mapping client-side. Becomes ergonomics improvement when picked up.
- **Phase 3:** Telegram escalation alerts (extend `brew-ops-bot/detector.sh` for `[ESCALATE_TO_HUMAN:*]` markers and `failed_*` watcher states); `arra_inbox` MCP tool gains `type=directed, oracle=X` filter so `for-{oracle}/` files are first-class in the tool surface (currently Step 0.5 sweep falls back to `Read` on the vault path); §11 sibling-sync to writer/tester/architect AGENTS.md (cold-test proved self-discovery is sufficient, so this drops to convenience-only priority).
- **Phase 4 (in progress 2026-05-03):** Orchestrator role + Telegram daemon (§11k fan-out pattern). User → Telegram → `orchestrator-bot/bot.sh` writes envelope → watcher fires orchestrator → orchestrator dispatches via fan-out, aggregates, reports back via chat-watcher. New daemon under `scripts/orchestrator-bot/` mirroring `scripts/brew-ops-bot/` shape. New role at `.agent/skills/orchestrator/`. New chat: `mb_orchrestrator_bot` (chat 2002026175).

Multi-recipient broadcast is intentionally **not** in scope. If multiple oracles need the same notification, write multiple files (one per recipient) referencing the same thread. Each recipient gets its own session-per-thread mapping.

---

**Created:** 2026-04-16 (GMT+7)
**Maintainers:** `brew-ops` proposes edits; human approves via PR.
**Updated:** 2026-04-30 — added §11 (directed inbox protocol); same-day fix: routing key is oracle name (not role label), envelope gains `to_role` / `from_role` documentation fields. Same-day discovery: maw wake silent-fail blocks Phase 2a; Phase 2b reordered to land first with the silent-fail root fix as scope item (i).
**Updated:** 2026-05-03 — added §11g (Loop termination), §11h (Escalation to human), §11i (Watcher integration + delivery verification); §11j renamed from §11g (Phase status) and updated to reflect Phase 2b-i shipped + Phase 2a in progress.
**Updated:** 2026-05-03 (later) — added §11b `parent_thread`/`parent_oracle` fields and §11k Orchestrator fan-out pattern (Phase 4). Phase 2a watcher PR merged; Phase 4 daemon + role next.
**Updated:** 2026-05-16 — §11f/§11i/§11k: watcher keys orchestrator wakes on `parent_thread` (wake key) and adds the `deferred` state, so a fan-out campaign's replies converge on ONE orchestrator session instead of spawning parallel siblings (fixes the triple-dispatch incident — escalation #348, thread #134).
**Updated:** 2026-05-16 (later) — §11f/§11i/§11k: `parent_thread` wake-keying extended to **all** oracles (worker agents now reuse one campaign session, not one per sub-thread); §11i gains Path 2b — the periodic campaign GC sweep (late-close retire, session-id eviction + TTL, orphan-worktree prune). Thread #139, PR #71.
**Updated:** 2026-05-17 — added §11l (loop-closure enforcement): the `Stop`-hook gate that blocks a dispatched oracle session from ending while its inbox loop is open (no reply envelope / no §11d archive). Fixes the gap observed on thread #132 → diagnosed on thread #140.
**Updated:** 2026-05-17 (later) — added §3c (runtime-checkout deploy discipline): both primary checkouts stay on `feat/all-prs-rebased`; new code lands by merge-then-pull, never by live-editing the running checkout or parking it on a feature branch. Codified after the thread #149 fleet re-sync.
**Updated:** 2026-05-17 (§151) — §11b gains the optional `parent_session` envelope field; §11f gains the sticky thread→session ownership routing table; §11k notes the dedup target is now the recorded campaign owner. The dispatcher stamps `parent_session` (its worktree path) on outbound dispatch envelopes; the watcher records the owner and routes every reply back to the owning session (send-keys / --resume / --fresh+transfer) instead of spawning a fresh orchestrator. Fixes the #140/#141 context-fragmentation + session-sprawl. Watcher impl: arra-oracle-v3 fork PR #75; design ratified on thread #151.
**Updated:** 2026-05-17 (§153) — §11k: workers now also get the `deferred`/dedup logic — a 2nd dispatch to a *busy* worker for an in-flight campaign defers and serializes onto the existing session instead of `--fresh`-spawning a sibling worker session. Mirrors PR #75 onto the dispatch/worker-receiving side; reverses the 2026-05-16 "workers don't dedup" carve-out (which held only while the worker was idle). Fixes the wt-43/wt-46 sibling-spawn + §11l circuit-breaker trip observed during thread #151's own implementation. Watcher impl: arra-oracle-v3 fork PR #77; dispatched on thread #153.
**Updated:** 2026-05-22 (§214) — §11e: the directed-inbox sweep is now **campaign-scoped** — a session handles only envelopes whose wake key (`parent_thread` else `thread`) matches the campaign it was woken for, leaving sibling same-oracle sessions' envelopes in place. The **orchestrator is the explicit whole-dir exception** (multi-campaign hub). Closes the cross-campaign-pickup rough edge of the #181 parallel-sessions-same-role pattern (observed: next-impl wt-5/campaign-208 pulled into wt-1/campaign-203). Same `wake_key` discriminator now scopes the §11l Stop hook (arra-oracle-v3 fork PR #88); role cheat-sheets sibling-synced (brew-ops, next-impl, next-architect; orchestrator marked whole-dir-exception).
**Updated:** 2026-05-27 (§238) — §11e/§11l: the §214 "orchestrator stays whole-dir" carve-out was correct for the *sweep* but wrong for the §11l Stop-hook *gate* under §181 **concurrent** orchestrator sessions — each session's whole-dir gate false-blocked on sibling-owned `for-orchestrator/` envelopes (re-hit ~5× during campaign #228/#234/#237 on 2026-05-26; drift known since 2026-05-22). Fix: the orchestrator's archive-gap + reply-gap checks are now scoped by **§151 ownership** (the campaign's `sessions/orchestrator/thread-<wake_key>.owner` worktree must equal this session's worktree), mirroring how §214 scoped the non-orchestrator gate by `wake_key`. Sweep stays whole-dir (sweep-reads-all, close-out-owns-own). Unattributable scope falls back to gating. Hook + regression tests: arra-oracle-v3 fork PR (thread #238); the §214 "the two never disagree" claim amended — for the orchestrator the gate now tracks §151 owner, not the whole-dir sweep.
