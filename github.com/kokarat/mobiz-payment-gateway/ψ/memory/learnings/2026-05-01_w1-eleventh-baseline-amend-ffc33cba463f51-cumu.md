---
title: W1 eleventh-baseline AMEND — ffc33cb..a463f51 cumulative — 0 status flips, 0 reg
tags: [tester, repo:mobiz-payment-gateway, current, w1-eleventh-baseline, no-flip-cadence, amend, slip-fraud, deposit, deposit-fraud-fail-closed]
created: 2026-05-01
source: docs/test-index.md@a463f51 + controllers/DepositController.go:817-850 (#360) + :853-882 (#361) + services/slipFraudCheck.go (#360 new file)
project: github.com/kokarat/mobiz-payment-gateway
---

# W1 eleventh-baseline AMEND — ffc33cb..a463f51 cumulative — 0 status flips, 0 reg

W1 eleventh-baseline AMEND — ffc33cb..a463f51 cumulative — 0 status flips, 0 regression candidates, 4 NEUTRAL prod-surface commits

What this pass added on top of the original c5ee388 closeout (PR #358 commit e587eaa): two more in-territory commits — ef71420 (PR #360 deposit slip receiver mismatch fail-closed) and a463f51 (PR #361 slip-bearing deposit requires human admin approver). Both gates live in controllers/DepositController.go::UpdateDepositStatus immediately before the existing transaction block; both fire only when input.Status == "paid" AND the deposit carries slip data (SlipVerifyResult non-nil for #360, SlipUploadedAt non-zero for #361).

Why NEUTRAL across the suite: zero test-*.sh in the suite invokes POST /api/v1/{deposits,bot/deposit}/:id/status to flip a slip-bearing deposit to "paid". test-deposit-upload-slip.sh stops at status=checking (Step 4) plus 404/400 error paths (Steps 5–6) — never crosses into the paid transition. The auto-match-paid tests (test-deposit-promptpay-qr.sh:442/455, test-scb-statement-skip-future-row.sh:316/345) drive the bank-bot scrape→matcher path which writes status=paid via the matcher service code, not through UpdateDepositStatus. Both new fail-closed branches are unreachable from the suite at HEAD.

Coverage gaps filed (2 NEW, 🟡 Important): (a) slip-paid receiver-mismatch fail-closed — no test exercises mismatch-reject 400 + super_admin [force-approve] override + fail-open semantics; mock-bank cannot synthesize rawSlip.receiver.account.proxy.account independently of the bank-bot scrape, so any test would need mongo_exec to write slip_verify_result directly between upload and the admin flip. (b) slip-bearing-requires-human-admin — no test asserts the bot route returns 403 against a slip-bearing deposit while the JWT admin route succeeds. Together they leave the "every paid slip has a named human approver" production invariant untested.

Forward note for the next W1 pass: if a future test drives the bot endpoint to "paid" on a slip-bearing deposit, gate #361 will return 403 — that test must use the admin JWT path, populate notes with a real reviewer username, and (if slip last-4 differs from deposit) include [force-approve] from a super_admin token. PR #360 + #361 compose: #360 catches the fraud mechanism (mismatched receiver), #361 catches the missing audit trail.

Status delta vs original c5ee388 closeout: V=+0 S=+0 W=+0 F=+0 SUP=+0 ON_HOLD=+0 UNK=+0 (cumulative totals unchanged from c5ee388 baseline). PR #358 amended in place (single-PR-per-cycle discipline; no stack).

PR #358 cumulative: feat/tester-validate-2026-05-02, baseline a463f51, prior baseline ffc33cb (PR #352 merged 2026-05-01).

---
*Added via Oracle Learn*
