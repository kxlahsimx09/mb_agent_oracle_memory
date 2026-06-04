---
title: completeness-audit (V5, audit#141 pattern) — DEPOSIT-001..004 AC-vs-probe biject
tags: []
created: 2026-06-04
source: next-investigator (campaign depaudit)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# completeness-audit (V5, audit#141 pattern) — DEPOSIT-001..004 AC-vs-probe biject

completeness-audit (V5, audit#141 pattern) — DEPOSIT-001..004 AC-vs-probe bijection, verified against merged probes + green evidence JSONs, NOT trusted blind from dod-marks.

RESULT: 48 authoritative AC clauses (D001×18 + D002×12 + D003×6 + D004×12). 42 COVERED (green probe), 6 DEFERRED-by-decision, 0 GENUINELY MISSING. Evidence directly confirmed: integration-deposit-slice-…657cde05 {12/12}, gap-…657cde05 {38/38}, deposit-34-…49eab803 {27 = 26 live + 1 deferred marker}.

BIJECTION: slice probes (deposit-001-ac1/ac2, deposit-002-ac3/ac4/ac5) + gap/ (d1-03..18, d2-03/04/05/11/12) + d34/ (d003-ac1..6, d004-ac1..12). Every AC clause maps to a green probe or a recorded deferral.

6 DEFERRALS (none a hole): 5 D1/D2 guardrails covered-not-separately-probed (D1-07 idempotency-replay, D2-06 concurrent-finalize, D2-07 client-wallet-rollback, D2-08 all-or-nothing-finalize, D2-10 late-statement-exclusion — impl+poc landed, follow-up to fork into deployed negative/race suite); + 1 owner out-of-slice (D004-AC11 admin-approve→paid, blocked by approve-time V2 fraud gate = DEPOSIT-007 scope).

3 ITEMS WORTH OWNER ATTENTION (none = missing AC):
(1) D004-AC11 deferral is materially different from the D1/D2 deferrals — it MASKS an un-demonstrated happy path: clean approve→paid+credit+MDR+callback is NOT green anywhere in this slice (probe authored but excluded from run). The other 5 are guardrails with landed coverage.
(2) D2-03 full-key-collision is PARTIAL: asserts the money-safety property (credited ∈ {0,1}, never both) + unparseable→pending, but does NOT assert the AC's "FIFO-oldest" degenerate pick (creditedCount===1 passes without checking which/oldest deposit). Mitigant: park-resolution owned by DEPOSIT-005.
(3) channel-field SPEC-drop: AC requires response field `channel ∈ {QR,TRANSFER}`; SPEC rev7 dropped it, surfaces only qr_type/promptpay_number presence. Probes assert the behavioral QR-vs-TRANSFER split via payload presence (covered) but no probe asserts a `channel` field (impl never emits one). SPEC↔AC divergence, not a behavior gap.

dod-mark reconciliation: both dod-marks (2026-06-03 D1/D2 "25/30+5"; 2026-06-04 D3/D4 "003 6/6, 004 11/12 AC-11 deferred") reconcile EXACTLY with merged probes + evidence-JSON bijection.ac_clauses. Verified, not trusted. Findings: next-investigator_depaudit_findings.md.</pattern>
<parameter name="concepts">["completeness-audit", "deposit", "ac-coverage", "bijection", "probe-audit", "deposit-001", "deposit-002", "deposit-003", "deposit-004", "deferred-vs-gap", "next-investigator"]

---
*Added via Oracle Learn*
