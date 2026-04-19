---
title: flow — deposit-auto-match-from-statement — ratified revision (S4 → S2 via Oracle
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, deposit-auto-match-from-statement, ratified, revision, deposit, bank-statement, matcher, mdr, callback, bank-bot, thread:17]
created: 2026-04-19
source: docs/flows/deposit-auto-match-from-statement.md@post-ratification + thread #17 + trace 906553f0-373d-4920-bc99-ebe971be82c1
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — deposit-auto-match-from-statement — ratified revision (S4 → S2 via Oracle

flow — deposit-auto-match-from-statement — ratified revision (S4 → S2 via Oracle thread #17).

Actor-visible contract (Q1 ratified): one client API call (`POST /api/v1/deposit-request`) eventually produces one client callback (`status="completed"`) with zero additional client API calls in between. Gateway's job in the gap: ingest + dedup of BankBot-scraped statement rows, bank-specific description parsing (KTB full-account or SCB last4 + source bank code), atomic commit of `ts_deposits → paid` + client wallet credit + partner MDR fan-out + `wallets_change_logs` audit + `transactions` row + `mdr_shared` snapshot + completion callback. Mutually exclusive with the `deposit-slip-upload-admin-approve` sibling flow on any single deposit.

Scope boundary (Q2 ratified): this flow picks up from a `ts_deposits` row already in `status=pending, is_matched=false` (precondition owned by `deposit-qr-request`) and terminates at either `status=paid` + callback fired, OR a §Error paths branch (review / unmatched / expired-linkage). The "payer uploads slip before statement arrives" case is **not** this flow — it belongs to `deposit-slip-upload-admin-approve`.

Trigger documentation (Q3 ratified): three matcher entry points converge on the same `matchDeposit → finalizeDeposit` pipeline. The BankBot-ingest-initiated path is drawn in the sequence diagram; the 30-second retry ticker and the admin manual re-match path are explicitly enumerated in §Purpose (§single-diagram kept; operator-visible non-ingest triggers must stay called out).

Ratification classifications for the four code-level questions:
- Q4a (wallet-update failure does not abort match) = **DRIFT, PR needed** — human confirmed as a bug. A `status=paid` deposit with uncredited client wallet but distributed partner MDR is backwards; wallet credit is load-bearing for "completed" callback semantics. Drift learning filed at `ψ/memory/learnings/2026-04-19_drift-deposit-auto-match-finalizedeposit-does-no.md`; W8 child trace `906553f0-373d-4920-bc99-ebe971be82c1`; W4 queue item.
- Q4b (retry ticker 1-hour look-back) = **intentional** — the 1-hour window is deliberate; admin manual re-match (`POST /api/v1/bank-statements/match`) is the documented recovery for older statements.
- Q4c (SCB multi-candidate review parking has no admin consumer) = **intentional** — the "mark for review, do not auto-match" branch is correct safety. Auto-picking from multiple candidates on `amount + last4` alone is too risky; `match_candidates[]` is a human-facing audit trail, not a workflow input. Resolution in production is manual (DBA or slip-upload-admin-approve).
- Q4d (amount-only fallback removal leaves some banks unsupported) = **intentional** — `resolveBankCodeFromPrefix` is effectively the allowlist of "banks whose description format the matcher can parse"; banks outside this list are unsupported by design until parser code is added. Keeping amount-only fallback was deemed higher-false-rate than leaving statements unmatched.

Human engagement: thread #17 message id 30 on 2026-04-19 GMT+7 explicitly classified each question ("Q1/Q2 ok", "Q3 ไม่ต้องวาด path อื่น แต่ต้องมีระบุไว้ซักทีว่ามี path อื่น", "Q4a = บั๊ก", "Q4b = intention", "Q4c = ไม่ควรจะ match ได้เลย กรณีที่ตรงแค่ amount อย่างเดียว เพราะค่อนข้างอันตรายที่จะ auto match" — applied to both Q4c and Q4d by unified reasoning).

W8 root trace: b9e04355-1599-4bfb-b001-ac7697e9586b.
Thread-resolved child trace: 906553f0-373d-4920-bc99-ebe971be82c1 (Q4a drift).
Thread status: closed (2026-04-19).

Supersedes: `learning_2026-04-19_flow-deposit-auto-match-from-statement-intent` — that entry was the pre-ratification summary carrying "ratification-pending" tag; this learning is the post-ratification authoritative summary.

---
*Added via Oracle Learn*
