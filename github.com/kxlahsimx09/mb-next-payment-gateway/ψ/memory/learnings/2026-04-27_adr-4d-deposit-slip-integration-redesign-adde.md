---
title: §ADR-4d (deposit slip-integration redesign) — added + ratified `#decision` via t
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4, adr-4d, deposit, slip-integration, thunder, atomic-finalize, ratification, decision, thread-53, match-current, admin-always-in-loop, code-duplication-drift-closed, user-surfaced, input-5-during-ratification, skip-provisional-pattern]
created: 2026-04-27
source: docs/adr.md@c1a2d02 §ADR-4d + thread:#53 messages 104-107 + current-system code reads cited inline
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-4d (deposit slip-integration redesign) — added + ratified `#decision` via t

§ADR-4d (deposit slip-integration redesign) — added + ratified `#decision` via thread #53.

User ratified all 5 sub-questions C1-C5 on 2026-04-27 GMT+7 same session as opening. §ADR-4d authored directly as `#decision` (skipped `#provisional` intermediate state — first time in this repo's W1 history that an ADR was authored at ratified state because all sub-questions were pre-confirmed before authoring).

Ratification:
- C1 (TTL trigger) → Option a: hard 15-min
- C2 (status model) → Option a: status keep `pending` + slip fields on `ts_deposits`
- C3 (race resolution) → Option a: auto-match wins; sweep `WHERE status='pending'` filter naturally skips already-paid deposits
- C4 (Thunder evidence) → **Option D**: match current admin-always-in-loop invariant
- C5 (admin path semantics) → Option a: uniform with client

C4 had user-driven re-framing — important pattern captured:
1. Initial architect recommendation: Option B (Thunder + statement cross-check) based on Q1 atomic-finalize spirit + assumption current does similar
2. User challenged: "Option B ลองเช็คดู current ก็น่าจะเป็นงี้"
3. Code read `UpdateDepositStatus@2248499` revealed current = admin-always-in-loop, NOT auto cross-check
4. Revised to Option D (parity with current)
5. User confirmed: "งั้น D แหละ เอาแบบ current. ที่ไม่เหมือน คือ slip ยังไม่มี verify ทันทีที่ upload"

This is the 5th user-surfaced clarification in 2 weeks (cross-direction-metric, body-size drift, tier-cap redundancy, §ADR-4b Q3, today's C4). Pattern reinforced: read current-system code FIRST when claiming "current does X". Abstractions in retro/learning summaries often diverge from actual code semantics. Cost ~5-10min Input-5 read; benefit avoids substantial recommendation reversal mid-ratification.

§ADR-4d shape (7 numbered decisions):
1. Slip upload endpoints preserved (both client API-Key + admin JWT) — both call shared internal `save-slip-metadata` helper
2. Slip upload saves metadata only — NO Thunder verify, NO status flip; status stays `pending`
3. T+15min TTL pg_cron sweep — separate from §ADR-4b statement sweep
4. Thunder verify at sweep time — single helper, single hardening point (`verify-slip` EF)
5. Wallet credit requires admin approve — existing `PUT /deposits/:id/status=paid` triggers `finalize_deposit` RPC (reused from §ADR-4b Decision #5)
6. Mutual-exclusivity invariant preserved post-flip — once status='checking', matcher `WHERE status='pending'` excludes deposit
7. Edge case — deposit expires before T+15min handled by §ADR-4c future auto-expire sweep + admin manual recovery

Side benefit captured (closes current code-duplication drift):
- Current asymmetric hardening: `UploadSlipAdmin` has `defer recover()` + 2 retries (PR #219 hardening 2026-04-18); `UploadSlip` (client path) has neither — same logic ported to two places asymmetrically
- Under §ADR-4d: only ONE Thunder call site exists (sweep-time `verify-slip` EF). Both upload paths save metadata only at upload; converge through one Thunder helper at T+15min sweep
- Asymmetric-hardening drift class cannot recur structurally

Code reads during ratification (Input 5, 2026-04-27):
- `controllers/DepositRequestController.go:794-963 UploadSlip` — client API-Key endpoint (1 retry, no recover)
- `controllers/DepositController.go:1936-2153 UploadSlipAdmin` — admin JWT endpoint (defer recover + 2 retries, PR #219 hardened)
- `controllers/DepositController.go:744-870 UpdateDepositStatus` — admin approve handler (verified current = admin-always-in-loop; NO auto statement cross-check; the C4 verification anchor)

Threads opened: none. Threads closed: #53 (with full ratification citation + commit reference). Commit: c1a2d02 on PR #3.

Cross-references:
- §ADR-4b "§ADR-4d future — thread #53 active" updated to "§ADR-4d ratified #decision 2026-04-27 via thread #53"
- §ADR-4b implementation footer updated similarly
- §ADR-4d cites §ADR-4b Decision #5 (`finalize_deposit` RPC reused as wallet-credit trigger)
- §ADR-4d cites §ADR-4c future for auto-expire edge case handling
- §ADR-4d cites §ADR-2 for admin JWT, §ADR-7 for client API-Key, §ADR-5 for SSE event

Pattern observation — first ADR ratified directly at #decision without #provisional intermediate:
Previous baseline passes (§ADR-4a pass-1, §ADR-8 pass-1, §ADR-4b pass-1) all opened with `#provisional` + ratification thread, then promoted to `#decision` after user confirms. §ADR-4d skipped this — author after ratification because thread #53 was opened mid-discussion (during §ADR-4b ratification in the same session) with C1-C5 architect-recommendations pre-staged. User answered C1-C5 before §ADR-4d body was authored. Authoring at #decision directly is more efficient when this sequence is achievable.

Caveat: this works because thread #53 was opened with concrete architect-recommendations on every sub-question (C1-C5 each had 2-3 options + architect rec); user could ratify with one-line answers. If sub-questions had been more open-ended ("how should we handle X"), #provisional intermediate would still be required. Pattern: **frame ratification with options + architect-rec → enable one-line user answers → may skip #provisional**.

Next-pass candidates surfaced during this session:
- §ADR-4c (auto-expire) baseline — sibling completes deposit-lane trio; estimated 50-60 min
- Wallet-table cross-cutting ADR — used by §ADR-4a + §ADR-4b atomic boundaries
- Deposit-create API + bank-assignment ADR — entry point of deposit flow, currently mentioned as precondition only
- Callback dispatcher ADR — webhook delivery semantics, retry, idempotency
- Retro for today's session (DoD requires)
- arra_trace_link automation (recurring miss, 8 retros flagging)

---
*Added via Oracle Learn*
