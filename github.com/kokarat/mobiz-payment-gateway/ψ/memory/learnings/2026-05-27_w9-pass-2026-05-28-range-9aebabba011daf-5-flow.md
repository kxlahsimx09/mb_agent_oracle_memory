---
title: W9 pass 2026-05-28: range 9aebabb..a011daf, 5 flows pointer-refreshed (Class A/B
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, bot-ops]
created: 2026-05-27
source: docs/flows/*.md @a011daf
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-05-28: range 9aebabb..a011daf, 5 flows pointer-refreshed (Class A/B

W9 pass 2026-05-28: range 9aebabb..a011daf, 5 flows pointer-refreshed (Class A/B), flows-baseline LEFT at 9aebabb (8 prior over-threshold deferrals awaiting W8 still block the bump). Cause: #490 (83a2513) inserted PUT /cloud-provider into routes/bot.go at :51 and UpdateCloudProvider into BotConfigController.go at :652 — both shifted shared bot pointers. Outcomes: (A — hash bump, line stable, route above the :51 insert) `payout-request.md` routes/bot.go:25/31/32/33 @4e84ad5→@83a2513; `withdrawal-queue-dispatch-and-claim.md` routes/bot.go:27/29 @252849e→@83a2513. (B — line relocation) `deposit-auto-match-from-statement.md`, `deposit-qr-request.md`, `payout-auto-reconcile-from-statement.md`: routes/bot.go /bank-statements route :50→:54; BotConfigController.go SaveBankStatements handler relocated :648→:702 (+54, verified 9aebabb=648 vs HEAD=702 — entire shift = my commit), dedup-loop+insert 683-816→738-870, MatchNewStatements spawn 817-820→871, success return 823-825→884-886, deposit-qr handler 650→702 — all @063983c→@83a2513. Side cleanup: deposit-auto-match Step 5 :660 (a prior-pass prose-vs-line drift candidate that pointed at the input-validation early-return) relocated to the actual success return :884-886. Behavior unchanged everywhere (purely additive #490 endpoint) → zero Class C/D/E/F, zero new threads. main.go pointers @2f35356 in deposit-auto-expire-pending + payout-auto-cancel-pending-timeout LEFT intact: already [DRIFT]-marked and in the 8-deferral set for W8; a011daf #492 ErrorHandler insert compounds their line drift but they are processed/queued. 8.B new PR docs/flow-track-9aebabb-a011daf.

---
*Added via Oracle Learn*
