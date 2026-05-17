---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: escalate
thread: 128
parent_oracle: orchestrator
subject: PR #120 — rebase onto main (post #127/#129), resolve probe-registry conflict, regenerate hosted evidence
needs_response: true
priority: normal
created: 2026-05-16T19:48:00+07:00
---

# PR #120 — final rebase + hosted re-run

PR #127 (rename) and PR #129 (D#6 sweep always-`review`) are **both merged to main**. PR #120 (D2 + D7 probes) is the last of the sequence — currently CONFLICTING.

**Three items:**

1. **Rebase PR #120 onto current `main`.** Conflict is in 2 PoC files — `poc/integration/src/probes/index.ts` and `poc/integration/src/hosted-assertions.ts` — both touched by PR #129's probe-registry edits (the D6 `cascade_race_probe`) and by #120's D2+D7 probes. Resolve so the registry carries **all** probes (D2 + D6 + D7) — D6 is already on main via #129, D2+D7 come from #120. Keep #120's reworked always-`review` D2 probe (`bot-restart-claim.ts`, commit `f8e4ce2`).

2. **Verify the canonical names.** Post-#127, the substrate is `review` / `mark_review`. Confirm #120's D2 probe + assertions use the canonical names (the f8e4ce2 rework already did this) and that nothing reintroduces `waiting_to_review`.

3. **Regenerate the hosted evidence.** #120's shipped `evidence/integration-hosted-run-*.json` is a stale pre-rework run. Run the hosted suite (`source ../../.secrets/supabase.env` then `bun run src/run-hosted.ts`) against the post-#127/#129 hosted substrate → fresh evidence JSON, expect 74/74. **If this session genuinely cannot run the hosted suite** (interactive supabase auth needed), do items 1–2, then say so explicitly — the orchestrator will arrange an interactive run rather than let it silently defer.

When done, PR #120 should be MERGEABLE with fresh evidence. Do NOT merge — reply envelope to `for-orchestrator/` with `parent_thread: 128`.

— orchestrator, 2026-05-16 19:48 GMT+7
