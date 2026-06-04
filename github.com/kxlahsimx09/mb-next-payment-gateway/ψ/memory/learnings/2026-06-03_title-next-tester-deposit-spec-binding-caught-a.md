---
title: title: next-tester DEPOSIT — SPEC binding caught AC-prose↔contract divergences (
tags: [next-tester, spec-binding, drift, anti-bias, deposit]
created: 2026-06-03
source: tests/integration/probes/_spec.ts + docs/spec/deposit-slice.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: next-tester DEPOSIT — SPEC binding caught AC-prose↔contract divergences (

title: next-tester DEPOSIT — SPEC binding caught AC-prose↔contract divergences (de-bias working)

Campaign nextteam, 2026-06-03. next-dev published docs/spec/deposit-slice.md (Step-0 contract). Because next-tester built probes off the AC FIRST (de-bias layer 1), binding the SPEC SURFACED material divergences between AC prose and the deployed contract — caught + recorded, not silently inherited. SPEC wins (per SPEC §1 contract note). Divergences bound into tests/integration/probes/_spec.ts (SPEC_UNBOUND flipped false):
- create endpoint POST /functions/v1/deposits-create returns 201 (not AC-prose 200); body nested under `deposit`.
- request body: method/request_id/callback_url/customer_bank_* (NOT currency/client_reference_id/metadata); amount floored to whole baht.
- supplying expires_in_seconds → 400 client_supplied_expires_in_seconds (AC-1 negative asserts that code).
- QR surfaced as deposit.qrcode (EMVCo amount in tag 54) + deposit.qr_type {mobile|national_id|tax_id|ewallet} + promptpay_number; NO `channel` field; persisted ts_deposits.qr_payload/.qr_type.
- residual wallet owner_type='mdr_owner'; wallets_change_logs rows typed by `operation` (deposit_credit|mdr_distribute|mdr_skip|mdr_residual); AC-4 credit observable = exactly one operation='deposit_credit' row.
- callback delivery = callback_queue.status='delivered' + delivered_at + last_response_code 2xx (NO boolean `sent`); dedup_key='deposit:<id>:deposit.paid'.
- DEPOSIT-002 has no client endpoint: submit_statements_batch/bot-statements intake then match_deposits_cascade(p_statement_id) RPC fires finalize_deposit.

Still-open [SPEC-PENDING] flagged to next-dev (NOT guessed): ts_deposits→destination-bank FK col not in SPEC §2.1 (probe resolves bank from create response instead); bank_account code column name; AC-5 mock-merchant 2xx/timeout behavior knob.

LESSON: building off the AC before the SPEC is what makes the divergences VISIBLE. A tester who read the code would have inherited 201/nested-deposit/mdr_owner/operation-typed-rows silently and the AC-prose gaps would never surface for next-writer/next-dev to reconcile.

source: tests/integration/probes/_spec.ts + docs/spec/deposit-slice.md
tags: next-tester, repo:mb-next-payment-gateway, next, spec, drift, deposit-001, deposit-002, handoff
project: github.com/kxlahsimx09/mb-next-payment-gateway

---
*Added via Oracle Learn*
