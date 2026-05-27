---
from: pg-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 227
parent_thread: 225
parent_oracle: orchestrator
subject: Sub-task B DONE — #current-lens gap analysis. 4 in-epic gaps the internally-clean Phase-1 epics silently drop (per-bank maintenance-cancel, fair-router withdrawal amount-range, per-client rate-limit, slip-expire divergence) + production do-not-lose detail on the planned surfaces (#226 overlap) + 2 to ratify.
needs_response: false
priority: normal
created: 2026-05-26T15:20:00+07:00
handled_at: 2026-05-26T15:30:00+07:00
handled_by_thread: 225
handled_note: Aggregated into campaign #225 (parent msg 1018) alongside sub-A (#226). needs_response was false (report deliverable) — no reply envelope required. Parent + both subs being closed.
---

Full findings on **thread #227 msg 1017** (reply posted). Review-only pass — no files edited. mb-next `docs/requirements/` @b8facce vs current production per `docs/current-system.md` @16467ff + live code. Evidence cited per P-004.

**HEADLINE:** #226 (next-writer, sub-A) correctly found the authored Phase-1 epics *internally* clean. An internal-completeness pass structurally **cannot** see where an authored epic silently drops a CURRENT production behavior — that's this pass's non-redundant core: **4 in-epic gaps, none with a recorded decision.**

**BUCKET A — gaps INSIDE the "internally-clean" authored epics (unique find, no recorded decision):**
- **A1 [HIGH] Per-bank maintenance-window payout cancel.** Current `cancelPendingOnMaintenanceBanks` (`scheduler/maintenance_cancel.go@0424cdc` #417) cancels+refunds pending payouts on any bank entering its OWN `maintenance_time` (so client money isn't locked overnight). mb-next: system-wide bulk-cancel is **unratified** (PAYOUT-008 §"not-yet-ratified mechanism"); deposit-side deferred (epic-deposit:204); **per-bank variant unmentioned**. → unratified + silent.
- **A2 [MED-HIGH] Fair-router per-bank withdrawal amount-range filter.** Current `findBestBankForItem` skips banks where `item.Amount` is outside `withdrawal_min_amount..withdrawal_max_amount` (0=no limit) for payout/settlement/DT/pullout (current-system §5 `@ae6f523` #335). BOT-001's fair-router filter list (method/heartbeat/idle/balance/max-outstanding/daily-txn/tier-cap/pool) **omits it** (distinct from balance & max-outstanding). → no recorded decision.
- **A3 [MED] Per-client API rate-limit on create.** Current per-client per-scope per-min+per-day caps (`helpers/ratelimit.go@33664cd`/`@c7b2232`, §7.2: deposit 1000/min+600k/day, payout 1000/min+300k/day). DEPOSIT-001/PAYOUT-001 ACs cover auth+idempotency+amount-range+callback-endpoint — no request-rate cap (§ADR-11=dedup≠rate). Confirmed absent from requirements (grep clean). → flag so not dropped.
- **A4 [MED] Slip-bearing-deposit expiry — OPPOSITE outcomes, divergence not flagged.** Current (#460 `9aebabb` 2026-05-22) **excludes** slip-bearing pending deposits from expiry → **escalates to admin** (§5/§8.5). mb-next DEPOSIT-004 three-timer model: "deadline first → expired" → would **auto-expire + expiry callback**. Not flagged deliberate (model likely predates #460). → ratify.

**BUCKET B — planned-epic surfaces (overlap w/ #226): production do-not-lose detail.**
- **Settlement** (no epic): create→debit; approve→MDR distribute; reject/cancel→refund; `waiting_to_review`=int 3; CSV export; UPDATE/DELETE removed by design (DRIFT-7).
- **Pullout** (no epic) — **highest loss risk**: 4 time strategies (jitter/window/weighted/burst, overnight) + opt-in demand-refill (`6b07f51`) + DestCap random bands + two-layer in-flight reservation (pending + settled-unsynced 60-min floor `c5ee388`) + source-side reservation + execute-now/preview/logs.
- **Direct Transfer** (no epic): one-shot bank-to-bank (no wallet) + deposit-refund-via-DT (`SyncDepositRefundStatus`, `refund_pending_review`, `815418e` #399) — refund half = DEPOSIT-011 (deferred).
- **Auth/RBAC, OTP, Callback-core, Admin-Audit, Fleet, Monitoring, Idempotency** — concur w/ #226; production specifics not to lose: **2FA mandatory all user logins + step-up TOTP on money-out (refund)**; DB-driven RBAC (roles/resources/actions CRUD + dynamic menu); per-handler tenant-ownership guard (`d2a2738`); **OTP dual-source email+SMS/MacroDroid auto-parse**; JWT cache + secret-rotation fingerprint; **force-logout UNWIRED** (DRIFT-14); Telegram hourly/daily MDR reports + broadcast + wallet-alert channel (ReportScheduler in-process DISABLED, DRIFT-10); bank-statement admin read (list/stats/accounts); BankAccount approval workflow; per-client rate-limit (=A3).

**BUCKET C — deliberate divergences (recorded; NOT gaps):** terminal `success`/`rejected`-vs-`failed` (§ADR-9 TS); append-not-destructive + 202 all-tier resend (§ADR-9 AM3/AM4); computed `available` (§ADR-10 AM1); raw callback_url rejected→preconfigured snapshot (§ADR-9/#223 — closes my 2026-05-25 create-time-only SSRF drift); Idempotency-Key REQUIRED (§ADR-11, new); server-derived `request_id`; SSE→Supabase Realtime (§ADR-1/8); MDR `mdr_skip` no-silent-drop (§ADR-10 D4, closes thread #6); stuck-claim always→`review`, drop `bank_transaction_id` auto-fail discriminator (§ADR-4a 2026-05-16); drop `PUT …/success|failed` admin debug endpoints (§ADR-4a D8); V13/V14 enforced + V3 new + V1 single-path (§ADR-4d); count-dedup NULL-safe (§ADR-4b); DEPOSIT-006/011 deferred. All carry decisions.

**BUCKET D — ratify:** A1 (per-bank maintenance-cancel keep/drop), A4 (slip-expire escalate-vs-expire).

Method: #current-lens complement to #226. Bucket A is the non-redundant core; B gives production do-not-lose detail on #226's planned surfaces; D = 2 divergences needing an explicit decision. Ready to run W1 / draft current↔target migration-notes rows on whichever surface(s) the user picks. needs_response=false — deliverable for campaign #225 aggregation.
