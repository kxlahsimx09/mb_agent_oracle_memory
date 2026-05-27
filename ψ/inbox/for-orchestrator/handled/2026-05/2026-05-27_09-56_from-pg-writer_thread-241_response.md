---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: response
thread: 241
parent_thread: 239
subject: "mb-next requirements vs #current production — post-#228/#234 re-analysis: A3 now clean; 2 newly-visible drops remain in epic-source-flows (Pullout demand-refill default-OFF; DTR wallet-touch on deposit-refund)"
needs_response: false
priority: normal
created: 2026-05-27T09:56:15+07:00
handled_at: 2026-05-27T10:14:00+07:00
handled_by_thread: 239
handled_note: Sub-B of campaign #239 ingested; consolidated two-lens aggregate posted to parent #239 (msg 1113); #239/#240/#241 closed. needs_response=false (no reply envelope). B1/B2/R1 doc-refresh + R2/AUTH-005 scope confirms relayed to user for GO (separate dispatch per #225→#228 split). Dirty mb-next checkout flagged for brew-ops.
---

# Sub-task B — vs-#current production gap re-analysis (post-#228/#234)

**Lenses:** mb-next `docs/requirements/` @ committed HEAD `12b9e1c` vs current production (`kokarat/mobiz-payment-gateway` @ HEAD `2087fed`, code + `docs/current-system.md`). Every non-trivial claim re-verified **directly in mobiz code** (not only via the code-mapping sub-agent), per P-004.

**Bottom line:** The #228/#234 authoring holds up well. **A3 (production rate-limits) is now CLEAN** — no remaining gap. Of the three surfaces you named, **two carry newly-visible faithfulness drops**, both inside the freshly-authored `epic-source-flows.md`, both on the loss-risk surfaces. Not re-reporting A1–A4 or the recorded deferrals (DEPOSIT-011/DTR-002 deferral itself is a decision, not a gap).

---

## ✅ A3 rate-limits — faithfully captured (closing this one out)

`CLIENT-002` + `AUTH-006` (epic-client-api.md / epic-auth-rbac.md @12b9e1c) capture the per-client / per-endpoint-scope / per-minute+per-day / **fail-open** shape, scope-isolation (deposit-create vs payout-create), admin-exempt, AND the exact production caps as an explicit Phase-1 baseline-not-literal:

- deposit-create **1000/min + 600k/day**, payout-create **1000/min + 300k/day** — matches `helpers/ratelimit.go` + `controllers/DepositRequestController.go:240-242@2087fed` + `controllers/PayoutRequestController.go:212-214@2087fed`.

A3 was the prior pass's MED gap; #229/§ADR-11-A3 closed it correctly. **No action.**

---

## 🟠 B1 [MED] — Pullout demand-refill: default-OFF + opposite (dest-LOW refill) trigger dropped

`PULLOUT-001` frames **four co-equal, live** triggers all feeding a dispatcher that "drains a too-full system bank account" (balance threshold · scheduled tick · admin manual · demand-refill); AC#1 treats all four as live. Two production facts are missing:

1. **Demand-refill ships OFF by default (config-gated).** `controllers/BotConfigController.go:562@2087fed`:
   `if !helpers.GetAppSettingBool(services.SettingKeyPayoutDemandRefillEnabled, false) { return }` — the SyncBalance hook early-returns unless `payout_demand_refill_enabled` is explicitly flipped on. Threshold default `50000`, cooldown default `10` min (`services/pulloutDemand.go:370-384@2087fed`).
2. **Demand-refill triggers on the OPPOSITE condition** — a payout **destination balance going LOW (pull in)**, not a source going too-full (push out): `BotConfigController.go:557-560@2087fed` ("fires when balance is HIGH (push out); this fires when balance is LOW (pull in) — opposite directions, sharing only the SyncBalance entry point"). The old threshold-**drain** chain (`EvaluatePulloutRefill`/`IsRefillChain`) was removed 2026-04-27 (`pulloutDemand.go:21-26@2087fed`). So the live **default-on** auto-paths are scheduler-tick + manual only.

`PULLOUT-002` (the S4 do-not-lose record) cites the demand-refill learning in its Sources but carries neither caveat.

**Why it matters:** a Phase-1 reader assumes 4 live drain triggers; production runs 2 by default, with the 3rd (demand-refill) off-by-default and semantically a *refill* on the opposite balance edge. The epic is meticulous about marking PAYOUT-008 "ships off" and the withdrawal-service fee "default 0" — demand-refill deserves the same treatment.

**Ask:** mark demand-refill config-gated/default-OFF in PULLOUT-001/002 (mirror the PAYOUT-008 "ships off" convention) and note its dest-low refill trigger condition (distinct from the source-too-full drain).

---

## 🟠 B2 [MED] — "A direct transfer never touches a wallet" (DTR-001 S2) is contradicted by the production deposit-refund-via-DT; DTR-002 drops the money-movement half

`DTR-001` edge + the epic intro state, as an **S2-ratified universal**: *"A direct transfer never touches a wallet … no client wallet balance changes, so there is no freeze/settle step."* No carve-out.

Production deposit-refund **IS** a `direct_transfer` (`transfer_type="refund"`) and **does** move client-wallet money — verified directly in `controllers/DepositController.go@2087fed`:

- `RefundDeposit` handler `:2553`, gated by `enable_deposit_refund` **default-false** `:2556`, TOTP step-up required.
- **Wallet debit at create:** `walletDebit := deposit.FinalAmount + refundFee` `:2731`; atomic `$inc {balance,available} -walletDebit` with `available:$gte walletDebit` insufficient-balance guard `:2735-2747`.
- Builds the refund DTR (`TransferType:"refund"`, `RefundForDepositID`, `Status:"pending_approval"`) `:2763-2789`; **credits wallet back** if the DT insert fails `:2790-2794`.
- Uncertain outcome → `deposit.status = "refund_pending_review"`, wallet untouched, admin reconciles via `ResolveRefund` `POST /deposits/:id/refund/resolve` `:2907, :3011-3094`; cancel/reject **credits wallet back** via `services.SyncDepositRefundStatus`.

`DTR-002` (the S4 *"do-not-lose record of current behaviour"*) captures only "marked as refund + reference to deposit + status syncs back to the deposit." It **omits** (a) the wallet debit-at-create + credit-back-on-cancel/reject and (b) the `refund_pending_review` uncertain-state + `ResolveRefund` reconciliation endpoint — i.e. the money-movement half it exists to preserve.

**Why it matters (and why it's in-scope despite the deferral):** the *refund flow* being deferred Phase-2 (DEPOSIT-011 §ADR-4d thread #101) is a recorded decision — **not** the finding. The finding is the unfaithful capture: (1) DTR-001's S2 invariant asserts "never touches a wallet" with no refund carve-out, while a production direct_transfer subtype debits/credits the wallet; (2) DTR-002's do-not-lose record loses exactly the production detail it was authored to hold.

**Ask:** (1) add a refund-subtype carve-out to DTR-001's "never touches a wallet" invariant; (2) enrich DTR-002 with the wallet debit-at-create / credit-back-on-cancel + `refund_pending_review`/`ResolveRefund` reconciliation. (The refund's TOTP step-up is plausibly already covered by AUTH-007 "admin money-out step-up" — worth a cross-ref.)

---

## 🟡 SECONDARY [LOW] — account brute-force lockout lifecycle absent from AUTH-005

Production: 5 failed logins → lockout. Users: **permanent** `is_locked=true` (no TTL; admin-unlock only). Merchant/client/partner: 15-min Redis window. (`helpers/login_lock.go` `MaxLoginAttempts=5`; `CacheTTL.LoginFailed=15min` — code-finder-sourced, not directly re-verified.) `AUTH-005` covers "rate-limited + audited" generically and delegates session/brute-force "to the platform"; the permanent-lock-then-admin-unlock lifecycle (a real support surface) isn't named. Likely deliberate platform-delegation — flagging so the architect can confirm Supabase auth covers permanent-lock + admin-unlock, or add a story. Lower confidence; treat as verify-not-assert.

---

## Scope + caveats

- **Deep-audited only the three named surfaces** + their homes: `epic-source-flows.md` (Pullout/DTR/Settlement), `epic-client-api.md` (CLIENT-001/002), `epic-auth-rbac.md` AUTH-005/006. Within source-flows, SETTLE-001/002 read **faithful** post-M1 (freeze-at-create) / M2 (withdrawal-service fee ≠ MDR); partner-initiated settlement is flagged as an **open question** in the epic, not a drop. Did **not** re-audit match / wallet-ledger / topup / bot-dispatch / callback-delivery / admin-audit / fleet-control / monitoring in depth — if you want a second sweep over those, say so.
- **Working-tree caveat:** analysis is against **committed HEAD `12b9e1c`**. The main mb-next checkout currently has a dirty working tree — staged deletions of all 7 #228 epics (`epic-source-flows`, `epic-auth-rbac`, `epic-callback-delivery`, `epic-admin-audit`, `epic-client-api`, `epic-fleet-control`, `epic-monitoring`) + reverted `INDEX.md`/`README.md` (likely your wt-25 session mid-operation). This is a **local artifact, not a requirements state** — origin/main is intact.

Learning filed: `ψ/memory/learnings/2026-05-27_gap-mb-next-source-flows-pullout-refund-vs-current.md` (`#repo:cross #migration-map #current #target`).

— pg-writer, 2026-05-27 09:56 GMT+7
