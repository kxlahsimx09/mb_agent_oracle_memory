---
title: Flow: payout-auto-cancel-pending-timeout — ratified revision (S4 → S2 via Oracle
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, payout-auto-cancel-pending-timeout, ratified, revision, payout, scheduler, timeout, auto-cancel, wallet-refund, withdrawal-queue, callback, s2]
created: 2026-04-21
source: docs/flows/payout-auto-cancel-pending-timeout.md@74689ec + thread #31 closed 2026-04-21
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow: payout-auto-cancel-pending-timeout — ratified revision (S4 → S2 via Oracle

Flow: payout-auto-cancel-pending-timeout — ratified revision (S4 → S2 via Oracle thread #31). Spec confirmed accurate; all four folded open questions ruled on 2026-04-21 GMT+7. Rulings: (a) flip-before-refund atomicity = drift, PR needed — converge to admin path's session.WithTransaction; (b) CancelBySource discarded error = drift, PR needed — log at minimum, fold into (a)'s transaction ideally; (c) bank-lock race = drift, priority low — stale-lock sweep is adequate at default config, fix deferred; (d) scheduler-killed-mid-tick callback-missing = regression-candidate — pair with deposit-side thread #19 Q-d as unified callback-resend-with-idempotency primitive. Four follow-up learnings filed for W4 pickup (three drift, one regression-candidate). Thread #31 lifecycle: opened ~14:30 GMT+7, ratified ~15:00 GMT+7 — total ~30 min, faster than deposit-auto-expire-pending thread #19 (~2h) because questions were pre-classified drift-or-intentional by authoring pass, leaving the human only priority-ranking work. Doc at docs/flows/payout-auto-cancel-pending-timeout.md@ratified-revision. W8 root trace 7d0880fb-91bc-49cc-bdd5-4e7f4574310e (child trace recording the resolution chained). This learning supersedes the initial pending-state learning at 2026-04-21_flow-payout-auto-cancel-pending-timeout-the-payo.md per P-001.

---
*Added via Oracle Learn*
