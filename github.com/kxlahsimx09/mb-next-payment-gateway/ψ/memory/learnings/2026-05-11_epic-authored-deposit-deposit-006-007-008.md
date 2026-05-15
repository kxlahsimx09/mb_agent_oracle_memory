---
title: epic authored — deposit (DEPOSIT-006 / 007 / 008) — 3 stories, trust mix S2/S3/S
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, epic-deposit, deposit-006, deposit-007, deposit-008, deposit-auto-match, deposit-slip-integration, admin-recovery, admin-manual-re-match, slip-fraud-detection, v1-hash-lookup, v2-receiver-mismatch, force-approve-override, verify-slip-now, thunder-on-demand, append-only-history, s2-ratified, phase-1-epic-deposit-closed, workflow-1]
created: 2026-05-11
source: docs/requirements/epic-deposit.md (DEPOSIT-006/007/008 authoring pass)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — deposit (DEPOSIT-006 / 007 / 008) — 3 stories, trust mix S2/S3/S

epic authored — deposit (DEPOSIT-006 / 007 / 008) — 3 stories, trust mix S2/S3/S4 = 3/0/0.

Subsystem: deposit-auto-match + deposit-slip-integration + admin-recovery-paths
Pass scope: closes Phase-1 of epic-deposit (all ratified DEPOSIT stories now authored). 3 stories share epic-deposit.md with DEPOSIT-001..005; one PR; no cross-repo touch (gateway-only admin paths).

DEPOSIT-006 — Admin manual statement re-match
- Source: §ADR-4b Decision #6 (ratified `#decision` 2026-04-27 via thread #52)
- Recovery branch of DEPOSIT-002 for statements beyond the 1-hour auto-retry window
- Same matcher cascade body + same atomic `finalize_deposit` as automatic path (code-reuse structural per §ADR-4b D6)
- 3 use cases: bot-down recovery / post-parser-fix re-run / DBA force-rematch
- AC matrix covers 6 cascade outcomes + JWT 403 + double-call race-guard + outside-window recovery
- Cross-refs §ADR-13 (admin JWT + RBAC + audit-log D2 trigger-denorm) and §ADR-9 (callback dispatcher emits `deposit.completed` indistinguishably from auto-path)

DEPOSIT-007 — Slip-fraud auto-checks (V1 + V2) at admin approve
- Source: §ADR-4d V1+V2 amendment (ratified `#decision` 2026-05-05 via thread #77)
- V2 receiver-mismatch (3-layer mask-aware comparator; Layer-1 fail-closed = deliberate divergence #5 from mobiz current)
- V1 slip-reuse hash-lookup (single-path day-bound; M4 sort tiebreaker; no fallback path per §ADR-4b B7 enforcement)
- Cascade V2 → V1 cheapest-first; V3 caller-guard dropped (replaced by §ADR-13 D1 endpoint separation — bot path cannot route here structurally)
- Force-approve override: super_admin includes `[force-approve]` literal in admin notes + JWT user_type=admin gate (per 2026-05-02 audit fix)
- Race-case admin flip-back to pending preserved per §ADR-4d C6 (admin clicks "delegate to auto-match"; deposit checking → pending + statement released)
- Production tuning ports verbatim: V2 caught 905/8736 slip-deposits / 90d / ~1.07M THB direct loss prevented (mobiz #360); V1 caught DEP17777364940AC8L3 + DEP1777733661IBGAQO (mobiz #362)
- Terminal-state taxonomy: fraud BLOCK refused approve → admin chooses reject → terminal `rejected` (not `failed` — per DEPOSIT-004 taxonomy)

DEPOSIT-008 — Admin verify-slip-now (on-demand Thunder verify)
- Source: §ADR-4d Decision #8 (ratified `#decision` 2026-04-28 as in-scope amendment to thread #53)
- On-demand sibling of DEPOSIT-004 step 4 (the 15-min sweep) — same verify-slip body, scoped to one deposit
- Pre-condition `slip_uploaded_at IS NOT NULL AND status IN ('pending','checking')`; terminal-status → 409 Conflict
- One deposit per call (no batch — user ratified "เลือกทำได้ทีละอัน")
- Every call appends one row to `slip_verify_attempts` per §ADR-4d Decision #9 (append-only — never overwrites)
- `triggered_by='admin_verify_now'` distinguishes from sweep `'sweep_auto'` and system retry `'system_retry'`
- Re-verify on `status='checking'` intentional (post-thunder_system_error retry; post-genuine second-opinion confirm)
- No current-system equivalent (mobiz calls Thunder inline at upload; verify-now is new construction enabled by §ADR-4d D1+D2 decoupling)

Sources cited (across 3 stories):
- new:adr — §ADR-4b D6 / D5 / D4 / D2-amendment / B7-amendment; §ADR-4d D1 / D3 / D4 / D5 / D8 / D9 / V1+V2-amendment; §ADR-13 D1 / D2; §ADR-9
- new:design — `docs/design/deposit-lane/matcher-cascade.md` + `docs/design/deposit-lane/slip-fraud-detection.md`
- new:learning — `2026-04-28_adr-4d-post-ratification-amendment-4-user-drive`, `2026-04-27_adr-4d-deposit-slip-integration-redesign-adde` (superseded — original ratify record), `2026-05-05_w1-refine-adr-4d-amendment-ratification-pass-2`
- old:flow — `mobiz/docs/flows/deposit-auto-match-from-statement.md`, `mobiz/docs/flows/deposit-slip-upload-admin-approve.md`
- old:incident — V2: DEP17775523528PE8D7 + DEP1777551533U75UBL + DEP1777664433X6DFUK (NATID mask false-positive class); V1: DEP17777364940AC8L3 + DEP1777733674IBGAQO + DEP17776655127CL4Q0 (false-positive class structurally closed by B7)
- old:code — mobiz services/slipFraudCheck.go, services/slipMatchHash.go, controllers/DepositController.go (admin approve), services/transactionMatcher.go, controllers/AdminController.go (admin re-match), controllers/DepositController.go UploadSlipAdmin + DepositRequestController UploadSlip
- old:data — mongo audit_log, ts_deposits, bank_statements, system_banks, slip_verify_attempts (next-system table)

Open threads: 0 new AWAITING_THREAD flags introduced (the 9 from prior session pass remain — separate ratification sweep)

File: docs/requirements/epic-deposit.md @ writer/deposit-006-007-008-2026-05-11 branch (commit pending PR open)

Process notes:
- File size now ~497 lines (well past SKILL.md §5 250-line target). Flagged in revision-log entry as housekeeping debt — recommend archiving the revision log to `docs/requirements/epic-deposit-revision-log-archive-2026-05.md` before the next epic-deposit refinement pass (precedent: §ADR-15 ratification pass archived `docs/adr.md` revision log).
- MDX bare-brace check via `rg -nP '(?<![\`\\])\{[^}\`]+\}'` on new content surfaced 0 hits in the 3 new stories; the 4 pre-existing hits (mermaid block + Sources-line inside multi-char backtick span) are safe.
- No new glossary terms introduced — admin / Thunder / verify-now were already concept-introduced in DEPOSIT-004; pattern preserved (avoid premature glossary churn).
- No cross-repo coordination needed — all 3 stories are admin paths gateway-side; bot side is untouched.
- Phase-1 of epic-deposit now closed: all 8 ratified DEPOSIT stories authored at S2. Next moves per retro recommend either (a) housekeeping pass (archive revision log + glossary refinement), (b) Phase-3 AWAITING_THREAD ratification sweep (9 pending flags), or (c) Phase-4 next epic (Payout / Client Self-Topup / Wallet & Ledger).

---
*Added via Oracle Learn*
