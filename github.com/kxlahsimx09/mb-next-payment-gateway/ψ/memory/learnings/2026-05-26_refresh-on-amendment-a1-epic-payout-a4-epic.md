---
title: refresh-on-amendment — A1 (epic-payout) + A4 (epic-deposit) — campaign #228 clos
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, refresh-on-amendment, payout, deposit, s2-ratified, campaign-228, thread-230, decision]
created: 2026-05-26
source: docs/requirements/epic-payout.md + epic-deposit.md @writer/a1-a4-refresh-campaign229
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# refresh-on-amendment — A1 (epic-payout) + A4 (epic-deposit) — campaign #228 clos

refresh-on-amendment — A1 (epic-payout) + A4 (epic-deposit) — campaign #228 closer.

Two existing-epic refreshes (workflow-3), ratified in PR #246 / thread #229, authored back-to-back in one PR off latest merged main (aec4a39, has #253). Closes campaign #228 authoring.

A1 — §ADR-4a §Amendment 2026-05-15 PA7 (per-bank maintenance-window payout-cancel, KEEP, ratified 2026-05-26):
- NEW story PAYOUT-010 (per the PA7 writer-handoff "give it its own mechanism"): always-on per-bank maintenance sweep cancels a pending payout whose ASSIGNED system bank is inside that bank's own maintenance_time window. ~1-min pg_cron; same atomic cancel body as cancel_stale_payout (CAS pending→cancelled, unfreeze frozen-=(amount+fee), wallets_change_logs payout_unfreeze, cancel withdrawal_queue items, callback_queue payout.cancelled with distinct failureCode='bank_maintenance'); lock order withdrawal_queue→ts_payouts→wallet. Ships ON (unlike PAYOUT-008 per-age, flag-OFF). Closes the ~12h overnight frozen-funds case; it's why PAYOUT-008 can ship OFF.
- PAYOUT-008 §Open-questions ("maintenance-window bulk-cancel is a separate, not-yet-ratified mechanism") → resolved/ratified, re-pointed to PAYOUT-010 (moved to Edge cases).
- PAYOUT-001 pool-scoping edge case → refined: an unroutable/assigned-bank-asleep pending payout's backstops = PAYOUT-010 (always-on per-bank maintenance) OR PAYOUT-008 (per-age, flag-on) OR PAYOUT-005 (admin).
- Story-shape table +PAYOUT-010 row; INDEX +PAYOUT-010; revision-log entry.

A4 — §ADR-4c §Amendment 2026-05-26 (slip-bearing deposit deadline-expiry exclusion, DA1-DA4, ratified 2026-05-26):
- DEPOSIT-003: expire sweep now selects pending deposits past deadline AND slip_uploaded_at IS NULL (DA1); new AC = slip-bearing pending past deadline is SKIPPED (not expired, no deposit.expired callback, effective_status not expired) → escalates to checking (DA1/DA2/DA4); new edge case (false-negative-on-real-money rationale + auto-match-still-wins DA3); Sources cite §ADR-4c §Amdt 2026-05-26.
- DEPOSIT-004 three-timer edge case (was "deadline first → expired"): rewritten — for a slip-bearing deposit the deadline does NOT expire it; it escalates to review/checking (Thunder/admin lane), never terminal expired, never fires deposit.expired; auto-match still wins → paid; slip-LESS deposit's deadline still → expired (unchanged). Supersedes prior wording. Rationale: per-client deadlines 5–45 min often < 15-min Thunder threshold.
- Slip-presence signal = slip_uploaded_at (§ADR-4d D1 audit-triple), greenfield analogue of mobiz slip_image emptiness check (#460). Revision-log entry.

Both are doc-only refreshes following ratified ADRs — no new product/money-flow decision, no ratification. Gates: epic-payout mermaid 9/9 PASS (incl. new PAYOUT-010 block), epic-deposit 1/1 PASS; MDX clean (only braced addition is the fenced PAYOUT-010 mermaid line).

Campaign #228 authoring COMPLETE: 7 net-new epics (source-flows/auth-rbac/callback-delivery/admin-audit/fleet-control/monitoring/client-api) + A1/A4 existing-epic refreshes. Files: epic-payout.md + epic-deposit.md + their revision-logs + INDEX.md.

Deferred (separate cleanup pass, flagged to orchestrator): the earlier refresh-on-amendment batch (#223 DEPOSIT-001/PAYOUT-001 callback_url already done in prior cleanup; #95 DEPOSIT-004 taxonomy already done; #120 PAYOUT-003 rejected; #132 PAYOUT-004/009 review-callback) + the now-stale AUTH-006 rate-limit line (ratified, now CLIENT-002).

---
*Added via Oracle Learn*
