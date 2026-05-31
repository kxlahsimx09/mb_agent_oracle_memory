---
title: mb-next campaign archamd1 — all 3 HIGH ADR amendments now ratified #decision (us
tags: [orchestrator, team-dispatch, mb-next-payment-gateway, campaign-archamd1, pr-284, adr-12, adr-13, ratified, user-correction, review-not-waiting-to-review, direct-transfer-no-wallet, step-up-required, next-architect, repo:arra-oracle-v3, fleet]
created: 2026-05-31
source: PR #284 head 3ba3f21; orchestrator session 2026-05-31
project: github.com/soul-brews-studio/arra-oracle-v3
---

# mb-next campaign archamd1 — all 3 HIGH ADR amendments now ratified #decision (us

mb-next campaign archamd1 — all 3 HIGH ADR amendments now ratified #decision (user GO 2026-05-31); PR #284 ready to merge

PR #284 (branch arch/archamd1-high3, head 3ba3f21) closes 3 HIGH admin coverage gaps in docs/adr.md, all now ratified #decision (0 #provisional / 0 RATIFICATION_PENDING left):
- §ADR-12 Settlement Confirm-Review (CR1–CR4) — RATIFIED. Admin adjudicates an uncertain settlement outcome: success→settle-out / reject→release via §ADR-10 freeze; load-bearing CAS-409; §ADR-13 + §ADR-2 step-up. Naming fix applied: next-system holding state is `review` (NOT mobiz `waiting_to_review`; renamed by §ADR-4a §Amд 2026-05-16 thread #123).
- §ADR-12 Direct-Transfer Admin Override (DTO1–DTO4) — RATIFIED after user correction + rewrite. A plain admin DT NEVER touches a wallet (bank-to-bank operator money; epic-source-flows.md:329 + README "never touches a wallet"); the architect's first draft wrongly added freeze settle/release — REMOVED. DTO is now a PURE status reconciliation `review` → {completed, failed}: source-state tightening (only `review` valid; prod's arbitrary/terminal-state override dropped) + load-bearing CAS-409 + dispatcher-authoritative withdrawal_queue status-sync (port-fidelity) + §ADR-13 admin-write/audit (no wallet_change_logs cross-link — no wallet). DTO4 step-up: user ruled option (a) — §ADR-2 step-up (AUTH-007) REQUIRED (the override finalizes the recorded outcome of a real operator bank money-movement).
- §ADR-13 Admin Deposit List/Read Surface (DL1–DL3) — RATIFIED class (a) port-fidelity. Architect caught 2 gap-finder fabrications: NO sparse-btree index on ts_deposits.custom_bank_account_number (unindexed regex scan); NO read-time fraud-preview badge (DEPOSIT-007 cascade runs only at approve-time; DL3 carved it out + flagged next-writer).

TWO USER CORRECTIONS this review cycle (both binding, both fixed): (1) next-system has NO `waiting_to_review` state — only `review`; architect had imported the old mobiz name. (2) a plain Direct-Transfer has no wallet/freeze — only the deposit-refund DT subtype (DTR-002, Phase-2-deferred) touches a wallet.

NEXT: user merges PR #284 (orchestrator does not merge). After merge → next-writer follow-on authors SETTLE-002 confirm-review story + DTR-001 override story (now unblocked, ADR-backed) + resolve DEPOSIT-007 fraud-preview-badge presupposition per DL3. Remaining gap backlog unchanged: 5 new-ADR (provisioning epic biggest, deposit QR/fee, pullout CRUD, key-lifecycle) + ~9 medium amendments. Updates supersede the resume-state in learning 2026-05-30_mb-next-gap-sweep-campaign-resume-state.

---
*Added via Oracle Learn*
