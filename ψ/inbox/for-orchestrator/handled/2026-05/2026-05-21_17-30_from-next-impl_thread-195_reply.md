---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 195
parent_thread: 189
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#195 — §D9 substrate-bootstrap complete; PR #7 OPEN, 12/12 assertions PASS"
in_reply_to: 2026-05-21_17-13_from-orchestrator_thread-195_reply.md
needs_response: false
priority: normal
created: 2026-05-21T17:30:00+07:00
handled_at: 2026-05-21T17:32:00+07:00
handled_by_thread: 195
handled_note: "p2p-hub#7 substrate-bootstrap PR ready (34 min vs 6-10h estimate). 13 files +2603/-1: 5 migrations (provider_wallets, provider_topups, settle_p2p_match, topup_rpcs) + Edge Function admin-approval + TS harness. 12/12 hosted assertions PASS (provider_wallets invariants, settle_p2p_match success/insufficient/idempotent/notfound, topup CAS/credit/reject/fallback/slip-attach, change_log snapshot, outbound_messages payload). Flagged follow-ups for impl-pass-2: partner-MDR distribution (§D5 explicit skip), next-system adapter ADR (deferred), [STUB] supporting tables expansion, PI-3 dispatcher process, hosted-Supabase provisioning, §ADR-13 F1-F4 admin-tier JWT (Phase-1 accepts any bearer + X-Approver-Email). Local port 54421-54427 coexists cleanly with mb-next. Surfaced to user via #189 msg 800 for merge."
---

# next-impl → orchestrator (reply on thread #195)

GO bundle 1A+2A+3A+4A executed end-to-end. Full detail on thread #195 msg 799.

## PR

**https://github.com/kxlahsimx09/p2p-hub/pull/7**

Title: `next-impl: §D9 substrate bootstrap — provider_wallets + settle_p2p_match + mobiz-port topup`

Branch: `impl/195-substrate-bootstrap` off `main@1323e14` (post-#6-merge).

## §D9 5-item coverage

| Item | File | Hosted-asserted |
|---|---|---|
| 1. `provider_wallets` | `migrations/002_provider_wallets.sql` | A1 |
| 2. `provider_topups` | `migrations/003_provider_topups.sql` | A6, A7, A8, A9, A10 |
| 3. `settle_p2p_match` | `migrations/004_settle_p2p_match.sql` | A2, A3, A4, A5, A11, A12 |
| 4. Top-up RPCs (mobiz-port) | `migrations/005_topup_rpcs.sql` | A6, A7, A8, A9, A10 |
| 5. Admin-approval EF | `functions/admin-approve-topup/index.ts` | smoke only |

## Hosted-assertions

```
=== p2p-hub §D9 hosted-assertions (target: http://127.0.0.1:54421) ===
  PASS  A1   provider_wallets CHECK invariants
  PASS  A2   settle_p2p_match success path
  PASS  A3   settle_p2p_match insufficient RAISE
  PASS  A4   settle_p2p_match idempotent on SETTLED
  PASS  A5   settle_p2p_match callable + NOT_FOUND path
  PASS  A6   process_topup_approval CAS race-guard
  PASS  A7   process_topup_approval credits balance + change_log
  PASS  A8   reject_topup status=2 / no balance
  PASS  A9   process_topup fallback path
  PASS  A10  attach_topup_slip pre/post approval
  PASS  A11  change_log snapshot-per-row
  PASS  A12  outbound_messages MatchSettled payload
=== 12 PASS / 0 FAIL in 1.30s ===
```

## Diff stat

13 files changed, 2603 insertions(+), 1 deletion(-). 5 migrations + 1 Edge Function + 1 TS harness + tooling.

## Flagged follow-ups

- Partner-MDR distribution NOT carried (§D5 explicit; no partner structure Phase-1)
- `next-system` adapter ADR deferred per §D9 architect note
- `[STUB]` supporting tables marked inline for follow-up architect-pass expansion (§C3 / §C4 / §C5 / PI-3)
- PI-3 outbound-message dispatcher process — rows enqueued correctly; dispatcher is impl-pass-2 scope per §D11
- Hosted-Supabase provisioning deferred per GO 2A; assertion harness env-flippable
- §ADR-13 F1-F4 admin-tier JWT check in Edge Function — flagged inline `[FOLLOWUP §ADR-13 F1-F4]`; Phase-1 accepts any valid bearer + requires X-Approver-Email for service-role audit

## Notes

- Local Supabase port range shifted to 54421-54427 (mb-next on default 54321-54327; coexists cleanly).
- Local stack stopped post-test (no leftover containers).
- Worktree `p2p-hub.wt-impl-195` retained for review-cycle iteration.

State: PR #7 OPEN, ready for user merge once scope match confirmed.

`[AWAITING_MERGE:thread-195:pr-7]`
