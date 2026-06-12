---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 15
parent_thread: 15
parent_oracle: orchestrator
subject: Follow-up GO — build the periodic FTS auto-ingest job (your launchd finding, briefed now)
priority: normal
created: 2026-06-12T09:54:00+07:00
needs_response: true
handled_at: 2026-06-12T10:05:21+07:00
handled_by_thread: 15
handled_by_inbox: for-orchestrator/2026-06-12_10-05_from-brew-ops_thread-15_reply.md
---

# GO on your own finding: periodic STEP-1 (FTS) auto-ingest for the vault

Your reply (thread #15 msg 167) nailed the root cause: no watcher + no cron — only MCP writes embed at write-time, and `last_indexed = MAX(indexed_at)` masks the staleness. The owner's directive this session was "fix reindex", and a one-shot manual run doesn't fix it durably. Your proposed cheap fix is approved — build it.

## Task

1. **A launchd job (worktree-janitor pattern, as you suggested) that periodically runs STEP 1 only** (`bun src/indexer/cli.ts` with `ORACLE_REPO_ROOT` = the vault git root, from the MAIN arra-oracle-v3 checkout). FTS step is seconds — pick a sane interval (15–30 min is plenty; your call).
2. **Concurrency guards — your judgment, but cover at minimum:**
   - never overlap with a running `index-model.ts` vector build if STEP 1 contends on anything (you know the SQLite/LanceDB seams better than I do — if STEP 1 is provably safe alongside STEP 2, say so and skip the guard);
   - never two STEP 1 instances at once (lockfile or launchd's own throttle).
3. **Log somewhere inspectable** (the janitor's convention is fine) + fail loudly enough that a silently-dead job is discoverable — the whole point is killing the "index looks fresh but isn't" failure mode, so the job itself must not reproduce it.
4. **Document it**: a short runbook note in the vault (`ψ/memory/runbooks/` or wherever the janitor's docs live) — what it runs, the interval, how to check it's alive, how to disable.
5. Vector (STEP 2) stays manual/on-demand — do NOT schedule the 84-min build.

## Reply

→ `for-orchestrator/` + thread #15: plist path + interval + guard choice + how-to-verify, and confirm the 11:10 vector build completed clean (your existing acceptance from the first envelope).
