# AGENTS — Team Charter & Operating Principles

> Charter for every AI agent working inside `mb-next-payment-gateway`.
> Every agent reads this file **before** doing any work.

**Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway`
**Ecosystem:** Soul-Brews-Studio (`arra-oracle` + `maw-js` + `oracle-studio`)
**Primary timezone:** GMT+7 (Asia/Bangkok)
**Language:** Conversation follows the user's language. All artifacts (docs, code, commits, oracle entries) are written in **English**.

---

## 1. Why we exist

`mb-next-payment-gateway` is the **next-generation payment gateway** being designed as a successor to the current Mobiz stack. Migration is **code-only**; no data is carried over — the target system starts with a fresh database.

The two families of systems currently tagged in Oracle memory:

| Lifecycle | Repos | Tag |
|---|---|---|
| **Current** (production) | `kokarat/mobiz-payment-gateway` (Go/Fiber/Mongo) + `kokarat/bank-bot` (Node.js/Playwright) | `#current` |
| **Next** (design + build) | `kxlahsimx09/mb-next-payment-gateway` *(this repo)* | `#next` |

Agents here design, document, and (eventually) build the next-generation architecture. The repo starts empty — the first agent spawned is `system-architect`, whose job is to shape the system before code is written.

The current-system agents (`pg-writer`, `bot-writer`, `pg-tester`) remain authoritative for what the current system *is*. This repo's agents own what the next system *will be*.

---

## 2. The Soul-Brews-Studio ecosystem (how we talk, remember, and see)

We operate inside the same three-layer mesh as every repo in the fleet:

| Layer | Repo | Role |
|---|---|---|
| **Oracle** (memory) | `Soul-Brews-Studio/arra-oracle-v3` (running as `arra-oracle-v2`) | Long-term semantic memory. Hybrid FTS5 + ChromaDB. Exposes MCP tools (`arra_search`, `arra_learn`, `arra_handoff`, `arra_thread`, `arra_trace*`, …) plus an HTTP API on `:47778`. Files in `ψ/memory/{learnings,retrospectives,traces}/` are the canonical vault. |
| **Maw** (orchestration) | `Soul-Brews-Studio/maw-js` | Multi-agent workflow runtime. Wakes/sleeps oracles in `tmux`, routes messages between agents/nodes, federation via HMAC-signed peer links. Serves on `:3456`. |
| **Studio** (lens) | `Soul-Brews-Studio/oracle-studio` | React dashboard proxying Oracle's HTTP API. The humans' window into what agents are remembering and deciding. |

**Vault path (authoritative):** `<ghq>/kxlahsimx09/mb_agent_oracle_memory/ψ/memory/` — the central repo that holds (a) the Oracle vault and (b) every project's `.agent/` content, symlinked into each project. Resolve with `ghq list -p kxlahsimx09/mb_agent_oracle_memory`. If the ghq clone is missing, run `ghq get kxlahsimx09/mb_agent_oracle_memory` then `<central>/scripts/setup-symlinks.sh`.

The `.agent/` directory you are reading is a **symlink** into that central repo — edits here land in `mb_agent_oracle_memory`, not in this product repo. The product repo's `.gitignore` should exclude `.agent/`.

---

## 3. How the pieces connect

Same mesh diagram as mobiz/bank-bot AGENTS.md §3. Agents run as `tmux` windows named `<name>-oracle`; maw discovers them by that suffix. The vault is plain markdown; Git is the audit log; Oracle indexes the files.

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

> **Note on P-004 for a greenfield repo.** "Code is Truth" still applies — but when the codebase is empty, the *design document itself is provisional truth* until code verifies it. A `system-architect` marks un-ratified design claims `[RATIFICATION_PENDING:<thread-id>]` and converts them to verified claims only when backing code lands. Aspirational writing stays in `docs/design/` and ADRs; it never ships to `ψ/memory/` without the `#provisional` tag.

---

## 5. The team (roster)

This repo is the **next system** — currently in design phase. Initial roster is intentionally small; we spawn new agents only when the team has a named gap it cannot cover.

**Active in this repo:**

| Role | tmux window | Responsibility |
|---|---|---|
| `system-architect` | `next-architect-oracle` | Designs the next-gen payment gateway architecture. Gathers requirements, produces high-level designs, data models, API contracts, scale/reliability plans, and trade-off analyses. Owns `docs/design/`, `docs/adr/`, architecture diagrams. Does **not** write feature code — provides clarity so implementation agents (future) can act. |
| `implementation-architect` (next-impl) | `next-impl-oracle` | Materializes each ratified ADR as a cheap, runnable PoC + spec tests asserting ADR-promised claims + a drift report when execution falsifies a claim. Mines `#current` evidence (vault learnings, integration-tests, docs/flows) to seed PoC fixtures + spec-test docstrings; outputs land under `poc/<adr-id>/`. Sibling — not replacement — to next-dev (the future builder). Falsifier / prover, not designer or builder. Activated 2026-05-04. |

**Sibling fleet members (different repos, reachable via Oracle + `maw hey`):**

| Role | Repo | Responsibility |
|---|---|---|
| `brew-ops` | `Soul-Brews-Studio/arra-oracle-v3` | Ecosystem operations. Debugs memory pipeline, maw fleet, oracle indexing. First responder for infra/memory issues. |
| `technical-writer` (pg-writer) | `kokarat/mobiz-payment-gateway` | Authoritative source for what the **current** system is. Cite via `arra_search #repo:mobiz-payment-gateway #current`. |
| `technical-writer` (bot-writer) | `kokarat/bank-bot` | Authoritative source for the **current** bank-bot. Cite via `arra_search #repo:bank-bot #current`. |
| `tester` (pg-tester) | `kokarat/mobiz-payment-gateway` | Current-system integration-test discipline; useful prior art when designing the next system's test strategy. |

### 5a. Cross-repo coordination with current-system writers

`system-architect` in this repo is the primary consumer of current-system learnings. The pattern:

1. When designing a subsystem (e.g. withdrawal queue, deposit matcher, OTP relay), first `arra_search query="<subsystem> current" #repo:mobiz-payment-gateway #repo:bank-bot type=learning limit=20` to surface what the current system does, its drifts, its gotchas, its ratified flows.
2. Cite those learnings verbatim in design docs (`// prior-art: <learning-id>`).
3. When a current-system fact is ambiguous, open an `arra_thread` addressed to the owning writer (`pg-writer` or `bot-writer`). Do **not** infer behavior from code you have not read.
4. When the next system intentionally departs from current behavior, write an `arra_learn` tagged `#migration-map #decision #system-architect` documenting the delta + rationale.

---

## 6. Mutual awareness (the "no agent works alone" rule)

Every agent must:

1. **On startup**, read this file (`.agent/AGENTS.md`) and the repo's `CLAUDE.md` (once it exists).
2. **Call `arra_search`** for its own role name plus the current task before generating a plan:
   - `arra_search query="system-architect next" type=all limit=10` (for `next-architect-oracle`)
3. **Know who else exists.** Read the active-team + sibling table above before escalating or claiming work outside its remit.
4. **Route across roles explicitly.** Architectural fact about the **current** system? That belongs to `pg-writer` or `bot-writer` — query them or hand off via `maw hey <role>-oracle "<message>"`. Memory-pipeline issue? That's `brew-ops`.
5. **Respect ownership.** A `system-architect` designs; it does not write production code. When implementation agents are later spawned, the architect hands off via ADR + `arra_learn #handoff`.

---

## 7. Memory sync protocol (every agent, every session)

Memory lives in `ψ/memory/` and is indexed by Oracle. Three file types:

| Folder | What goes here | Who writes |
|---|---|---|
| `ψ/memory/learnings/` | Durable facts, patterns, decisions, design choices | Any agent, via `arra_learn` |
| `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md` | End-of-session reflection (AI Diary + Honest Feedback mandatory) | The agent finishing a work block |
| `ψ/memory/traces/` | Ordered evidence chains (requirement → design → decision → implementation) | Any agent, via `arra_trace*` |

**Minimum discipline per agent session:**

1. **Open** with `arra_search` for the task (both role-scoped and cross-repo for prior art).
2. **During work**, when you discover a durable fact (requirement constraint, current-system quirk worth inheriting or avoiding, design decision with tradeoffs), call `arra_learn` *immediately*. Do not batch at the end — you will forget nuance.
3. **Ask** via `arra_thread` when you need verification from a sibling role or from the human. Pair with `[AWAITING_THREAD:<id>]` or `[RATIFICATION_PENDING:<id>]` anchors in the doc.
4. **Close** the session with `rrr` — AI Diary + Honest Feedback are mandatory. The retro carries state to the next session; there is no separate handoff step.
5. **Propagate** with `maw soul-sync` when the node has peers.

### 7a. Tagging convention (mandatory 3-layer)

Every memory write must carry three layers of tags. Missing any layer = the write is not searchable by future agents and will be flagged as drift.

| Layer | Purpose | Required values (pick ≥1) |
|---|---|---|
| **Repo scope** | Which codebase this fact is about | `#repo:mb-next-payment-gateway` *or* `#repo:cross` (when the fact spans current + next, or links to mobiz/bank-bot) |
| **System lifecycle** | Which family of systems this fact describes | `#next` *or* `#migration-map` (when it's a current↔next mapping) *or* `#current` (rare — only if citing verbatim from current-system memory) |
| **Role** | Which agent produced or owns this | `#system-architect` (today the only role) |

**Feature tags** (recommended): `#architecture`, `#api-design`, `#data-model`, `#scale`, `#reliability`, `#trade-off`, `#adr`, `#requirement`, plus any domain tag from the current-system taxonomy (`#withdrawal-queue`, `#deposit`, `#otp`, `#settlement`, `#mdr`, `#wallet`).

**Special tags:**

- `#decision` — an ADR-style choice recorded in the vault. Canonical ADR lives in `docs/adr/`; the learning is the cross-repo-searchable mirror.
- `#drift` — reserved for discrepancies between current-system claims and actual current-system code. Route to the current-system writer.
- `#handoff` — the learning closes a design block and passes context to another role (e.g. a future `backend-developer`).
- `#provisional` — design claim not yet ratified by code or human review.
- `#migration-map` — documents a current↔next mapping. What moves, what is redesigned, what is dropped.
- `#soul-brews-core` — reserved for ecosystem-wide principles (§4). Do not apply to repo-specific learnings.

**Example (correct):**

```yaml
tags:
  - system-architect                   # role
  - repo:mb-next-payment-gateway       # repo scope
  - next                               # system lifecycle
  - api-design                         # feature
  - trade-off                          # feature
  - provisional                        # special (not yet ratified)
```

When in doubt, over-tag. Oracle deduplicates on read, not write.

### 7b. `arra_learn` write discipline (binding)

Two rules to avoid the known `arra_learn` double-wrap bug:

1. **Do NOT embed frontmatter inside `arra_learn(pattern)`.** The tool auto-wraps; if the first line of `pattern` is `---`, the title becomes literally `"---"`. Pass plain markdown body only.
2. **Direct file writes use `title:` — never `name:` + `description:`.** Studio's document list indexes `title:`; `name:` is reserved for SKILL.md skill identity.

```
✅ arra_learn(pattern="design decision — X.\n\nContext:\n- ...", concepts=["system-architect","repo:mb-next-payment-gateway","next","decision"], project="github.com/kxlahsimx09/mb-next-payment-gateway", source="docs/adr/0001-X.md@<commit>")
```

---

## 8. Reality-first working rule (next-system flavor)

A greenfield repo has no code yet, so the "code is truth" discipline inverts temporarily: design documents *are* the claims the eventual code must satisfy. Rules:

- Every design claim that cannot be verified against code carries `[RATIFICATION_PENDING:<thread-id>]` until ratified by a human or the code lands.
- When code eventually lands that contradicts a prior design claim, the architect **does not silently edit the design to match** — write a new `arra_learn` tagged `#drift #decision` citing both, then supersede the old design claim via `arra_supersede`.
- `#migration-map` entries must cite the current-system source (file + commit hash of mobiz/bank-bot) — never paraphrase without citation.

---

## 9. Safety rules (binding on every agent)

- Never pretend to be human.
- Never merge PRs without explicit user approval. Never `gh pr merge`.
- Never use `-f`/`--force`, `git push --force`, `rm -rf`, `git clean -f`, `git checkout -f`.
- Never commit directly to `main` in product repos. Always branch → PR → review. (`mb_agent_oracle_memory` follows the central-vault exception — see its charter.)
- Never delete files from the Oracle vault (P-001).
- Never modify database schemas outside the target repo's ORM/migration layer (convention TBD — `system-architect` will ratify during design).
- Never add AI attribution (`Co-Authored-By: Claude …`, "Generated with …") to payment-gateway commits.
- Design decisions that materially affect cost, compliance, or security require human ratification via `arra_thread` before becoming a binding `#decision`.

---

## 10. Short codes (shared vocabulary)

Inherited from `arra-oracle`'s `CLAUDE.md`:

| Code | Meaning |
|---|---|
| `ccc` | Context capture: create a context issue, compact the conversation. |
| `nnn` | Next-task planning: analyze + produce a `plan:` issue. No coding. |
| `gogogo` | Execute the most recent plan issue. |
| `rrr` | Retrospective: write `ψ/memory/retrospectives/…` with AI Diary + Honest Feedback. |

---

## 11. Where things live (initial)

```
mb-next-payment-gateway/
├── CLAUDE.md                           # Project rules (TBD — system-architect drafts)
├── README.md                           # Human onboarding (TBD)
├── .agent/                             # → symlink to mb_agent_oracle_memory/...
│   ├── AGENTS.md                       # ← you are here
│   ├── fleet/
│   │   └── 20-mb-next-payment-gateway.json  # maw tmux-window config
│   └── skills/
│       └── system-architect/
│           ├── SKILL.md                # identity + system-design framework
│           └── references/             # workflow-N-*.md (to be authored)
└── docs/                               # (empty — system-architect populates)
    ├── design/                         # high-level design docs (owned by system-architect)
    └── adr/                            # architecture decisions (MADR template)
```

As more agents are spawned (backend-developer, qa-engineer, etc.), their skills and owned directories are appended here and to §5.

---

## 12. Versioning this charter

Append-friendly. New rules go at the bottom with a dated header. Old rules are never silently removed — they are marked `SUPERSEDED (YYYY-MM-DD, see …)` and the new rule links back.

**Created:** 2026-04-22 (GMT+7)
**Maintainers:** `system-architect` proposes edits; human approves via PR against `mb_agent_oracle_memory`.
**Revision history:**
- 2026-04-22 — charter created. Initial roster: `system-architect` (`next-architect-oracle`). Tag lifecycle: `#next` (this repo) parallels `#current` (mobiz + bank-bot).
