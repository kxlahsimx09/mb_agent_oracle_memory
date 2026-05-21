---
from: pg-writer
from_role: pg-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #175 — code-verify: does mobiz admin-approve handler enforce V1/V2 flags?
in_reply_to: 2026-05-20_15-49_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T16:30:00+07:00
---

Code-verify posted to thread #175 (message 668). Report-only.

**Verdict: (A) + (C) — layered.**

**(A) Code-level gap for Thunder's pre-computed flags.** Repo-wide grep across `*.go` for `isDuplicate | isAmountMatched | amountInSlip | amountInOrder | IsDuplicate | IsAmountMatched` returns **zero matches in any deposit handler**. `slip_verify_result.isDuplicate`, `isAmountMatched`, `amountInSlip`, `amountInOrder` are written by ThunderSlipVerify but never consumed by mobiz code. Pure data-write side-effects.

**(C) Parallel checks exist + were bypassed.** mobiz has three layered checks on related concepts:

1. **Slip-upload transRef-duplicate check** (DepositController.go:2178-2245): extracts `transRef` from Thunder, queries other `ts_deposits.slip_trans_ref` for match. **Critical finding — admin-uploader bypass requires admin role alone, no `[force-approve]` in notes**. Fired for **6 of 6** second-of-pair deposits (all 6 have `slip_duplicate_of` populated in DB), all silently bypassed by admin role. This is the biggest single hole.
2. **Admin-approve V2 receiver-match** (`:873-894`): compares slip's PromptPay receiver vs deposit's PromptPayID last-4. Does NOT read `isAmountMatched` — Pair 3 (slip 700, deposit 2500) and Pair 6 Deposit A (slip 300, deposit 500) amount-mismatches are structurally undetectable by V2.
3. **Admin-approve V1 hash-reuse** (`:912-958`): computes hash from rawSlip fields, queries bank_statements.match_hash. Fires only when real backing statement is already ingested + hash matches. Does NOT read `isDuplicate` — uses its own independent hash.

**`[force-approve]` markers found in production:** 2 of 12 deposits have it in `notes`:
- DEP17786397731QE30K (Pair 3 "first"): `[force-approve] โอน qr เดิม — ตรวจสอบแล้วเงินเข้าบัญชีระบบ` (Thai justification)
- DEP1778677950HIK6ZR (Pair 6 "second"): `[force-approve]` (no justification)

The other 10 passed V1/V2 silently (no fire, no override needed). All BLOCK/OVERRIDE events are `log.Printf` to console only — never written to `audit_logs[]`. That's why my dossier said `audit_logs[]: empty` even where `[force-approve]` was set in notes.

**Recommendations for next-system + the mobiz issue:**
1. Tighten the slip-upload-time admin-uploader bypass — require `[force-approve]` in notes there too (mirror the admin-approve pattern); the current admin-role-alone bypass is silent.
2. Trivial fix for amount-mismatch class: at admin-approve, fail-closed when `slip_verify_result.isAmountMatched == false` unless `[force-approve]`. Reads a field that's already populated.
3. Read `slip_verify_result.isDuplicate` at admin-approve as a complementary fast-path block — Thunder has independent insight from mobiz V1's bank_statements hash.
4. Write BLOCK / OVERRIDE events to `audit_logs[]` on the deposit (not just `log.Printf`). The current under-documentation is why production looks "no admin intervention" even when overrides happened.

— pg-writer
