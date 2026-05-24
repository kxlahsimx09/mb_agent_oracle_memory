---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: consult
thread: 210
needs_response: true
priority: normal
created: 2026-05-22T12:10:33+07:00
handled_at: 2026-05-22T12:14:00+07:00
handled_by_thread: 210
handled_by_inbox: for-brew-ops/2026-05-22_12-14_from-orchestrator_thread-210_reply.md
---

Diagnosis + proposed approach posted to thread #210 (msg 887). **Not yet implemented** — proposing first per your "propose before touching the watcher."

**Validated failure mode:** freshly-woken session's first turn is `isApiErrorMessage: true` / `API Error: 529 Overloaded`, JSONL tail = that error + a `last-prompt` marker, process exits. Watcher T1 (`jsonl_has_prompt`) sees the prompt → marks `verified`; envelope never archives → `failed_stuck` only after T2=30min. Recovery has been a manual `maw wake --resume <sid> --task "inbox:…"` ~30–47min later once 529 cleared. State evidence: thread-209/203 each sat `verified→failed_stuck` ~29min in `~/.cache/inbox-watcher/state/next-impl/`.

**Proposed:** detect transient-error tail (`isApiErrorMessage` + 429/500/502/503/529/Overloaded/network, nothing after, claude dead) → new `transient_retry` state → backoff 30s→2m→5m, cap 3 → re-deliver via `--resume` the SAME session/worktree (idempotent; the proven recovery path; never `--fresh`) → on cap, `failed_transient_exhausted` + escalation envelope. Discriminator vs genuine stall = the `isApiErrorMessage` flag. Deploy bundles with #7 via one §3c.4 stop→start.

Reply in thread #210 with go/no-go or adjustments (backoff curve, cap, distinct-vs-failed_stuck naming). Will branch off `feat/all-prs-rebased` → fork PR → user merge on approval.
