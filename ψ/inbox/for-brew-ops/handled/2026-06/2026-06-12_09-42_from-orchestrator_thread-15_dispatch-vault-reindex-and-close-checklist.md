---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 15
parent_thread: 15
parent_oracle: orchestrator
subject: Vault full-reindex (fresh retros invisible to FTS) + orchestrator SKILL.md close-checklist amendment
priority: high
created: 2026-06-12T09:42:00+07:00
needs_response: true
handled_at: 2026-06-12T09:53:04+07:00
handled_by_thread: 15
handled_by_inbox: for-orchestrator/2026-06-12_09-53_from-brew-ops_thread-15_reply.md
---

# Two tasks: Oracle vault reindex + orchestrator close-checklist hardening

Context: this session's round-1 grounding missed BOTH predecessor orchestrator sessions (build2, bankbot2) — the owner had to correct the picture twice. Root-cause post-mortem is in learning `2026-06-12_orchestrator-session-grounding-why-round-1-ground` (read it first — it motivates both tasks).

## Task A — Full vault reindex (the fresh-files-invisible bug)

**Symptom:** `arra_search` FTS for the literal token `bankbot2` returns **0 hits**, even though `ψ/memory/retrospectives/2026-06/12/01.19_orchestrator-bankbot2-campaign-close-handoff.md` (and the build2 retro `2026-06/11/18.26_...`) are committed AND pushed to the vault repo. Files written directly into the vault are not being ingested; only MCP-written docs (arra_learn/arra_handoff) embed immediately.

**Procedure (the two recorded traps are real — ~864 learnings silently vanished on 2026-05-29 when they were ignored):**

```bash
cd ~/Code/github.com/Soul-Brews-Studio/arra-oracle-v3        # MAIN checkout (has the _universal/ψ discovery fix), NOT a worktree
export ORACLE_REPO_ROOT=~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory   # vault GIT ROOT, NOT ~/.arra-oracle-v2
# back up lancedb/oracle_knowledge_bge_m3.lance first (vector step deleteCollection()s before rebuild)
bun src/indexer/cli.ts                  # STEP 1: SQLite + FTS5 (seconds)
bun src/scripts/index-model.ts bge-m3   # STEP 2: vector embeddings (~84 min; NEVER two instances at once — LanceDB corrupts)
```

Record `arra_stats` (or the indexer's own counts) BEFORE and AFTER.

**Acceptance:**
1. `arra_search` mode=fts `bankbot2` → returns the 2026-06-12 bankbot2 retro; `build2` → returns the 2026-06-11 build2 retro.
2. learning + retro counts AFTER ≥ BEFORE (no silent per-repo drop — that is exactly what the wrong ORACLE_REPO_ROOT does).
3. Spot-check one per-repo learning (e.g. anything under `github.com/kxlahsimx09/mb-next-payment-gateway/ψ/`) still searchable.

**Stretch (only if obvious while you're in there):** say in your reply WHY the scanner didn't pick these files up on its own (no watcher on the vault? cadence? scanner pointed at the wrong root?) and what the cheap durable fix is — a finding is enough, don't build it unbriefed.

## Task B — Orchestrator SKILL.md: close-checklist + grounding order

**File:** `github.com/Soul-Brews-Studio/arra-oracle-v3/.agent/skills/orchestrator/SKILL.md` (in the vault repo — you own charter mechanics). Keep house style and the ≤250-line file rule; commit + push to the vault repo as usual.

**Amendment 1 — session-close checklist.** Orchestrator session close MUST produce BOTH:
1. the full retrospective in `ψ/memory/retrospectives/YYYY-MM/DD/HH.MM_slug.md` (existing practice), AND
2. a ≤10-line pointer handoff filed **via the `arra_handoff` MCP tool** (NOT a hand-written file): current state, path to the retro, OUTSTANDING list, items awaiting owner.

Rationale to capture in the text: `ψ/inbox/handoff/` is the next session's front door (`arra_inbox` is read first), and MCP-written docs are embedded/searchable immediately while hand-written vault files wait for the scanner. build2 + bankbot2 both closed retro-only → the next orchestrator's inbox check came up empty.

**Amendment 2 — grounding order on session start/resume.** GitHub ground truth FIRST (`gh pr list` open+recently-merged, `git log origin/main` on the work repos) → filesystem-by-date in the vault (`find ψ/memory/retrospectives -newermt …` + `ψ/inbox/handoff/`) → `arra_search` LAST, as a supplement. Narrative docs (STATUS.md/handoffs/retros) are snapshots — verify every "open/pending/landing" claim against GitHub before repeating it. Reference the learning above.

## Reply

→ `for-orchestrator/` + thread #15: A) before/after counts + the three acceptance checks + (if found) the why-no-auto-ingest finding; B) the SKILL.md diff summary + commit hash.
