---
title: Cross-repo sync (bot → mobiz) — bank-bot PR #110 (20289a3, 2026-04-30) swapped t
tags: [technical-writer, repo:bank-bot, repo:cross, repo:mobiz-payment-gateway, current, cross-repo-sync, scb, balance, dispatcher-headroom, pg-writer-handoff]
created: 2026-05-01
source: commits bank-bot 20289a3 + sibling mobiz docs/flows/payout-request.md@HEAD
project: github.com/kokarat/bank-bot
---

# Cross-repo sync (bot → mobiz) — bank-bot PR #110 (20289a3, 2026-04-30) swapped t

Cross-repo sync (bot → mobiz) — bank-bot PR #110 (20289a3, 2026-04-30) swapped the SCB→backend balance-field mapping at every api.updateBalance SCB call site. Wire format unchanged; semantics swapped: backend `balance` now carries SCB "ยอดเงินสดที่ใช้ได้" (cash available, more conservative); backend `available_balance` now carries SCB "ยอดเงินในบัญชี" (account total, larger). Mobiz dispatcher's bank.AvailableBalance headroom check therefore now reads against the larger account-total figure for SCB banks (less conservative than before). Mobiz-side flow doc that names these fields: docs/flows/payout-request.md (lines 26, 62, 91 — `system_banks.available_balance` / `balance` semantics in eligibility + on-success decrement). Mobiz W9 cannot detect this drift directly — the change is entirely inside bot territory and the wire shape is untouched; this breadcrumb is the channel. Bot W2 trace: 16fe84a6-4805-4718-b4b3-8ccc3828cefc (range 4b968a4..84e6649). Mobiz sibling W2 trace 5900d287-20a2-4883-bef1-55e52e74c857 created within the same minute today (2026-05-01) but covers an unrelated mobiz-internal range (#345 DestCap effective dest balance + #346 Restart Bot + #349 resend-callback async + #342 pullout demand-refill). No matching mobiz commit for SCB balance semantics — defer trace link and wait for mobiz back-link. Action for pg-writer's next pass: confirm whether payout-request.md §Preconditions and §Postconditions need a side-note that "for SCB banks post-2026-04-30, `available_balance` now reflects ยอดเงินในบัญชี (account total) and `balance` reflects ยอดเงินสดที่ใช้ได้ (cash available); for KTB banks both still reflect KTB's own labels — see banks/scb/dashboard.js@84e6649 and banks/ktb/dashboard.js§unchanged for the per-bank semantics".

---
*Added via Oracle Learn*
