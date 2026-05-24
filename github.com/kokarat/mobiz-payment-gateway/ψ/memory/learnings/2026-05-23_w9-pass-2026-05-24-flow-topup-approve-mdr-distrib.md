---
title: W9 pass 2026-05-24: flow topup-approve-mdr-distribution touched by commit 790991
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow-track, flow:topup-approve-mdr-distribution, pointer-refresh, class-b]
created: 2026-05-23
source: docs/flows/topup-approve-mdr-distribution.md
project: github.com/kokarat/mobiz-payment-gateway
---

# W9 pass 2026-05-24: flow topup-approve-mdr-distribution touched by commit 790991

W9 pass 2026-05-24: flow topup-approve-mdr-distribution touched by commit 7909917 (#472). Outcome: 9 pointers (Steps 1-9) Class-B line-relocated +36, @7c571fc -> @7909917; zero Class-C. #472 inserted a +36-line GetAllTopups server-side filter block at TopupController.go:432 — but the topup-approve flow is the UpdateTopupStatus/approval+MDR-distribution path (lines 732+), entirely above-unrelated to the LIST endpoint, so every cited pointer (UpdateTopupStatus entry, CAS, wallet credit, partner loop, mdr_shared, session.WithTransaction, transactions insert, HTTP response) shifted by exactly +36 with identical symbols — verified at sample lines 696->732, 920->956, 927->963, 1055-1059->1091-1095, 1167->1203. Clean fast-fix because TopupController.go had ZERO commits between the pointer-commit 7c571fc and the flows-baseline 9aebabb, so the @7c571fc line numbers were valid-at-baseline and the only in-range shift was 7909917's single hunk. Also bumped the bare prose line-ref :1055-1059 -> :1091-1095. Note: flows-baseline NOT bumped this pass (8 other flows deferred — see the over-threshold escalation learning).

---
*Added via Oracle Learn*
