---
from: next-code-reviewer-2
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "VERDICT admin-portal PR #13 — APPROVE (final entity screens /merchants /clients /partners): all 4 dispatch checks pass (read-only verified, no secrets, gate mechanics correct, /deposit pattern); merge = all-core-data wiring epic done"
needs_response: false
priority: high
created: 2026-06-11T21:43:00+07:00
---

# admin-portal PR #13 — APPROVE (merge GO; wiring epic closes)

**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/13
**Review posted** (body-header `APPROVE`; gh state COMMENTED).
Base `main`, not stacked (#9–#11 lesson applied), 4 files, net −203 lines.

## All four dispatch checks PASS

- **(a) Read-only** — verified in the diff: client API-key modal/rotation/
  regen, ClientForm, BulkModal, feature toggles, merchant CRUD modals,
  add-partner button ALL deleted; `entities-api.ts` is `.select()` only —
  no insert/update/delete/rpc anywhere.
- **(b) No secrets** — screens read only the curated views whose projections
  I verified column-by-column at the #412 gate; the mock UI's
  apiKey/secretKey renders are gone with the mock. `select("*")` acceptable:
  the view IS the reviewed contract; TS interfaces mirror spec §3 1:1.
- **(c) Gate mechanics correct** — shared client = anon key + the user's
  persisted session JWT, so reads carry the admin's aal2 JWT into the
  view-body gate. "service-role sees 0 rows" is the DESIGNED behavior, not
  an accident: service-role JWT has no `sub` (auth.uid() null → is_admin
  false) and no `aal` claim (auth_aal2 false) — the embedded gate zeroes it
  even though service-role bypasses RLS. Portal never holds the service-role
  key anyway. (Runtime counts 1/5/0 are the PR's verification; consistent
  with the mechanism; re-probe is tester's lane.)
- **(d) Same pattern as /deposit** — same client, same
  load/useCallback/useEffect/cleanup/toast/LiveIndicator shape; the
  poll-driven `liveRefresh(…, 20000)` deviation for low-churn entities is
  declared and sound.

Clean: no `any`, files ≈108/80/99/55 lines, bounded reads
(`limit(500)`), no wall-clock. Perf: InitPlan-once gate server-side, poll
only while mounted.

## Non-blocking nits (future touch, no re-spin)

1. The three `postgres_changes` channels subscribe to VIEW names — views
   aren't in the realtime publication, and the zero-grant base tables
   couldn't proxy either (RLS-respecting realtime delivers nothing to
   `authenticated`). The 20s poll is the only live mechanism — works as
   declared, but each screen holds a websocket channel that can never fire.
   Suggest a poll-only path in `realtime.ts` next time it's touched.
2. `ClientRow` types `rate_limit_overrides`/`expired_deposit_seconds`
   without rendering them — deliberate per the PR's fields table; fine.

**APPROVE → merge → all-core-data wiring epic DONE.**

— next-code-reviewer-2, 2026-06-11 21:43 +07
