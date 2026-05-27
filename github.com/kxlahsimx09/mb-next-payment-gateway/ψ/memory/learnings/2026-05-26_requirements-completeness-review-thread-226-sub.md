---
title: Requirements completeness review (thread #226, sub-task A of campaign #225) — de
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, gap-analysis, completeness-review, thread-226, campaign-225, source-flow, callback-delivery, admin-api, audit, auth-rbac, fleet-control, monitoring, idempotency, adr-coverage-matrix, p-004]
created: 2026-05-26
source: thread #226 completeness review 2026-05-26 Asia/Bangkok, no file edits; verified against docs/adr.md @ HEAD b8facce
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Requirements completeness review (thread #226, sub-task A of campaign #225) — de

Requirements completeness review (thread #226, sub-task A of campaign #225) — deeper-than-W1 pass over docs/requirements/, verified against docs/adr.md per P-004.

16 ratified `#decision` ADRs vs authored epics. Authored: Deposit, Payout, Statement Matching, Bot Dispatch, Client Self-Topup, Wallet & Ledger (MDR folded as WALLET-003). README.md:59-67 marks Settlement/Pullout/Direct-Transfer/Auth-RBAC/OTP as `_planned_`.

MISSING ratified-ADR surfaces, prioritized:
- P0-1 Source-Flow trio Settlement/Pullout/Direct-Transfer — §ADR-12 (adr.md:2425); 5-row taxonomy + D2/D3/D4/D5; prod settlements ~2877 / direct_transfers ~589 / pullout_tasks ~155. Author as one epic-source-flows.md (file referenced by orchestrator task, doesn't exist).
- P0-2 Auth & RBAC — §ADR-2 (adr.md:14) + Amendment G1-G6 (adr.md:43) + §ADR-7 (adr.md:1652) + §ADR-13 F1/F3/F4 (adr.md:2612); 33-resource catalog adr.md:2670; users 685 / login_logs 36832 / otp_logs 39568 / roles 7.

NEW vs W1 2026-05-25 (W1 missed these three) — and they are NOT even listed in README epic index:
- P1-3 Callback Delivery core — §ADR-9 (adr.md:1732). Only manual-resend slice exists (DEPOSIT-012/PAYOUT-007); core contract (wire-sig WC1-11, at-least-once+event_id, retry/dead-letter, callback_attempts, preconfigured-endpoint safety thread #223) unwritten.
- P1-4 Admin-API + Audit substrate — §ADR-13 (adr.md:2519); 3-layer write invariant D1 + canonical audit_log D2 + RBAC resource-split D3 + created_by triple F2; referenced piecemeal, no owning epic.
- P2-7 Idempotency — §ADR-11 (adr.md:2346); has glossary entry, partial in DEPOSIT-001 AC, no dedicated story.

Also missing (W1 flagged, confirmed): P1-5 Fleet-Control §ADR-14 (only in cross-repo.md:57); P1-6 Monitoring §ADR-15 (32-alert catalog, SRE-facing).

WHERE NOT TO CHURN: authored epics are internally complete — deposit terminal taxonomy fully specified with producing paths (epic-deposit.md:260-267: paid/expired/rejected/failed, failed=system_error only); payout success/failed/cancelled; 0 live AWAITING_THREAD/RATIFICATION_PENDING anchors in active epics; the "Open questions" sections are all ADR-scoped deferrals (§Scope boundary / §Out of scope / closed-thread), not holes. So the add-work is net-new epics, not rework.

OTP & Trust (README `_planned_`) folds into Auth & RBAC (mostly §ADR-2 G1-D TOTP; bank-OTP is bankbot-v2). §ADR-6 bot-infra = bankbot-v2 territory, not a gateway gap. Do NOT revive PAYOUT-006 `rejected` (withdrawn §ADR-9 reconciliation thread #120, adr.md:3597). README epic index (README.md:54-67) is stale — add discoverability rows for Callback/Admin-Audit/Fleet/Monitoring/Idempotency even before epics land.

Durable method note: a README `_planned_` table is NOT the same as the ratified-ADR surface — cross-check every `#decision` ADR against the index, because ratified surfaces (Callback core, Admin/Audit, Idempotency) can be missing from the index entirely, not just unauthored. Recommended author order: source-flows → callback-delivery → auth-rbac → admin/audit → fleet+monitoring (lighter) → fold idempotency+OTP into parents.

---
*Added via Oracle Learn*
