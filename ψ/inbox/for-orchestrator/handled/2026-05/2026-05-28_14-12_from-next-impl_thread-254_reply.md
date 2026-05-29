---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: fail-open KV patch on rateLimitHit DELIVERED — PR #277; ready for brew-ops redeploy
needs_response: true
priority: high
created: 2026-05-28T14:12:00+07:00
handled_at: 2026-05-28T21:18:00+07:00
handled_by_thread: 254
handled_note: >
  DEDUPLICATED. This envelope is the inbox-write for thread msg 1246 (next-impl PR #277
  fail-open patch delivery). Real time per thread API = 2026-05-28T14:12:47Z =
  21:12 GMT+7 (next-impl writer's UTC-mislabel pattern as +07:00). Already covered in
  the orchestrator's prior milestone relay (Telegram msg 47, thread marker msg 1248)
  on 2026-05-28T21:17+07:00, which included PR #277 status, the (b) fail-open patch
  description, the brew-ops-redeploy-after-merge path, and the user-facing review/merge
  ask. needs_response=true is satisfied by the existing campaign plan: per wt-21's
  msg 1244 dispatch + brew-ops's msg 1247 follow-up, the (b) patch ships as a separate
  hygiene PR — user merges → brew-ops redeploys (follow-up dispatch, NOT blocking the
  §D re-run). next-impl session waits for the post-merge dispatch. No new Telegram sent
  (would be duplicate of msg 47); no new thread marker posted (msg 1248 already covers).
  This envelope likely landed in the inbox while wt-36 was processing the brew-ops
  19:30 envelope concurrently — out-of-order delivery is consistent with the watcher's
  per-envelope routing (not strict ordering). §151 owner remains wt-21.
---

Narrow, surgical, ~30-line diff to one function. PR #277 https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/277 (branch `next-impl/perf-cf-gateway-fail-open`, off origin/main, commit `47ff8ce`). Thread #254 msg 1246 has the full table.

**Patch:** wrap both `KV.get` reads + both `KV.put` writes in try/catch, log structured warns (`evt=rate_limit_kv_get_fail_open` / `evt=rate_limit_kv_put_fail_open`), return `{allowed: true}` on infra error. Counter drift on transient errors accepted; gateway never emits 5xx from rate-limit-side failure.

**Local-verify (forced-error matrix):**
- Happy path (no force): signed request reaches EF; 0 `rate_limit_kv_*_fail_open` warnings in wrangler log.
- Forced-failure (uncommitted `throw new Error(...)` injected inside the KV.put try-block): structured warning fires with full context (kMin/kDay/vMin/vDay/client_id/scope/err), and the response detail is the EF's downstream `create_deposit` schema-cache error — proves the request **REACHED the EF**. Without the patch, throw would propagate → Hono 500 BEFORE the EF was contacted (the bug brew-ops escalated).
- Revert verified: temp throw removed, warning count back to 0, no leftover in source.

**Brew-ops handoff:** redeploy after merge (`cd gateway/cf-worker && wrangler deploy`). Folds with the user-ratified CF Paid upgrade (a) — once both land, **next-impl re-runs §D** for the apples-to-apples ceiling vs `evidence/cf-gateway-216` (this fix + paid-tier KV headroom + R1+R2 hygiene from #276 all stacked).

Scope guard-rails respected: ONE-function diff, no other Worker changes, no migrations/EFs/driver touched. P-001 lane-cross mark continued.
