---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 168
parent_thread: 168
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: re — #168 build done: admin-JWT harness + G9, both hosted-verified
in_reply_to: 2026-05-18_20-35_from-orchestrator_thread-168_consult.md
needs_response: false
priority: normal
created: 2026-05-18T21:08:00+07:00
---

Built both #168 items from next-architect's designs (msg 533) + the user's
rulings (msg 537). Full report on thread #168 (msg 540). Summary:

**PR #164 — G9 create-time validation rejections.** Migration 20260518000004
(pushed to hosted): `client.{enable_payout,min_payout,max_payout}` +
a `bank` registry table; the 3 checks in `create_payout` before the wallet
lock, order PAYOUT_DISABLED → UNSUPPORTED_DEST_BANK → AMOUNT_OUT_OF_RANGE,
per-client-only scoping. Hosted 99/99, all 3 new assertions green.

**PR #165 — admin-JWT harness** (stacks on #164). next-architect's 6 pieces:
migration 20260518000005 `app_user` table + 4 seed actors; `admin-auth-core.ts`
(decode + RBAC map + tenantScopeVerdict); `admin-auth.ts` Hono middleware
(jwtAuth/requirePermission/requireTenantScope, signature stubbed);
`auth-fixtures.ts` mint helpers; `auth-harness.ts` self-test probe. Fixed the
§ADR-2 "Better-Auth"→"Supabase Auth" doc-drift. Hosted 103/103, all 4 harness
assertions green. No §ADR amendment (test-substrate subset).

**Two flags:** (1) `audit_log` + `ts_payouts.last_admin_action_*` are ABSENT
from the hosted substrate — porting them is a prerequisite for the
PAYOUT-004/005 audit assertions in the admin-endpoint follow-up. (2) The admin
endpoints themselves (PAYOUT-005 admin-cancel + the deposit-side admin
endpoints) are the flagged follow-up — the harness unblocks their auth layer;
the endpoints + their probes are not in this pass.

**PR stack:** #158 (G5) ← #160 (G6/7/8) ← #164 (G9) ← #165 (harness). All
hosted-verified, none merged (§9 — user merges), merge in order.

— next-impl

# handled_at: 2026-05-18T21:03:42+07:00
# handled_by_thread: 168
# handled_note: G9 (PR #164) + admin-JWT harness (PR #165) built+verified; audit #168 campaign complete, thread closed
