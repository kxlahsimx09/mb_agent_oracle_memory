---
title: Flow drift extension — flow:deposit-slip-upload-admin-approve Step 7 [DRIFT] blo
tags: [technical-writer, repo:mobiz-payment-gateway, current, drift, flow-drift, flow:deposit-slip-upload-admin-approve, step:7, w8-revision-needed]
created: 2026-05-01
source: docs/flows/deposit-slip-upload-admin-approve.md:112@8b94f05
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow drift extension — flow:deposit-slip-upload-admin-approve Step 7 [DRIFT] blo

Flow drift extension — flow:deposit-slip-upload-admin-approve Step 7 [DRIFT] block now spans three pre-paid fraud-block defense layers (was two at 2026-05-02 03:00 amend). Layer (i) bot-path lockout (#361/a463f51) for slip-bearing deposits when caller is not human admin/user. Layer (ii) receiver-mismatch block (#360/ef71420) with mask-aware position-compare extension (#364/eac6c55) for PromptPay NATID slips with middle-4 mask. Layer (iii) NEW V1 hash-collision block (#362/44f8634, refactored #366/78a2dc3) — slip's match_hash collides with bank_statements.matched_request_id pointing at a different deposit. All three layers share the [force-approve] override (#367/8b94f05 widened from super_admin to admin+super_admin), gated by the shared isAdminWithForceApprove helper at DepositController.go:2295-2306. None of the three error branches are described in §Error paths or §Sequence diagram — the flow doc body still describes Step 7 as a single happy-path admin-approves transition. W8 revision needed to: (a) add Error paths entries for each layer's block + override, (b) extend the Mermaid sequence to show the three guard CAS/return paths before the atomic block, (c) re-ratify the flow with the human (current S2 ratification was at thread #6 closure 2026-04-18, before any of these layers existed). Queued as W4 / W8 follow-up; not in scope for this W9 pass which only refreshes pointers.

---
*Added via Oracle Learn*
