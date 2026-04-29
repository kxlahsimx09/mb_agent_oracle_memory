---
title: W1 refine pass 1.5 — §ADR-4c pre-ratification revise: Decision #10 `v_deposits` 
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4c, deposit, auto-expire, view-contract, computed-status, read-write-separation, pre-ratification-revise, pass-1.5, user-surfaced-clarification, code-read-first-lesson, cross-cut-amendment, decision-10, design-pushback-as-improvement]
created: 2026-04-29
source: docs/adr.md@5512e90 + thread #55 messages 110-114 + Input 5 mobiz a8fb64e (transactionMatcher.go + DepositRequestController.go + DepositController.go + scheduler/deposit_expiry.go)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1.5 — §ADR-4c pre-ratification revise: Decision #10 `v_deposits` 

W1 refine pass 1.5 — §ADR-4c pre-ratification revise: Decision #10 `v_deposits` view contract added; opportunistic-on-read pattern rejected per user; cross-cut amendments to §ADR-4b/§ADR-4d.

## Context

Pass-1 (commit `af89309`) shipped §ADR-4c at `#provisional` with C1 architect-rec = "1-min sweep parity with current." User pushed back: *"ถ้า sweep ทุก 1 นาที deposit ที่เข้ามาก็ไม่มีทางการันตี expire ตามเวลาที่กำหนด เพราะจะมีเหลื่อมใน 1 นาทีเสมอ"* — surfaced visibility window correctness concern.

## What I did wrong (pattern instance #6 in 2 weeks)

I had not read current-system code before authoring §ADR-4c (pass-1 retro noted "Input 5 deliberately skipped — Inputs 1-3 sufficient"). User concern triggered Input 5 read at mobiz `a8fb64e`:
- `services/transactionMatcher.go:140-260` — KTB+SCB matchers filter `expires_at > now()` (Surface #1, intentional)
- `controllers/DepositRequestController.go:431-449` — GET deposit atomic FindOneAndUpdate (Surface #2; comment "SECURITY: Atomic expiration check to prevent race condition")
- `:758-769` — GetDepositStatus same pattern (Surface #3)
- `:697-702` — QR redirect 410 Gone (Surface #4)
- `controllers/DepositController.go:1479-1493` — admin stats `$addFields effective_status` aggregation (Surface #5; closest analogue to view pattern)
- `scheduler/deposit_expiry.go:69+` — sweep (Surface #6)

**Current implements opportunistic-expire-on-read across 6 surfaces intentionally** — pass-1 §ADR-4c (which proposed bare-sweep parity) was structurally inferior to current.

## Decision exploration (5 options A-E discussed with user)

| Option | Visibility | Callback | Cleanliness | New infra | Verdict |
|---|---|---|---|---|---|
| A. 1-min sweep only | ≤60s ❌ | ≤60s | ✅ 1 surface | none | rejected (visibility breaks) |
| B. Port opportunistic from current | ~0 | ~0 | ⚠️ 5+ surfaces | none | user rejected (not clean) |
| C. Faster sweep 5s | ≤5s | ≤5s | ✅ 1 surface | plan upgrade | rejected (Supabase pg_cron min 1-min) |
| D. pgmq scheduled jobs | ≤cadence | ≤cadence | ✅ explicit | pgmq + cancel coord | rejected (complexity) |
| E. External worker | ~exact | ~exact | ✅ 1 worker | non-Supabase service | rejected (out of substrate) |
| **Chosen: B-via-view + 1-min sweep** | **0 (real-time)** | **≤60s by design** | ✅✅ pure read | **none** | **accepted** |

User: *"ใช้ view แล้วการันตีและไม่มีผลกระทบกับ perf ผมโอเค ... callback ช้านิดหน่อยแค่นั้นเองถูกไหม"* — accepted view + 1-min sweep + acknowledged callback ≤60s lag.

## Key insight extracted

**The user-facing concern is status correctness (visibility + wallet safety), NOT callback emission timing.** Decoupling these via the view solves the load-bearing concern (real-time correctness) while accepting the non-load-bearing trade-off (≤60s callback lag for idle deposits). Callback timing becomes a **deliberate documented contract** instead of an emergent property of sweep cadence.

## Cross-cut amendments (within-scope, view-contract-driven)

- **§ADR-4b Decision #5** — `finalize_deposit` race-guard expanded with `(expires_at IS NULL OR expires_at > now())`. Defense-in-depth against future code paths using raw `ts_deposits` instead of `v_deposits` view.
- **§ADR-4d Decision #3** — slip-TTL sweep filter expanded with same. Avoids Thunder API call on deposits about to expire.

These are in-scope refinements to ratified ADRs (filter expansions, no decision-direction change) — qualified as same-session amendments per established pattern.

## §ADR-4c Decision #10 schema

```sql
CREATE VIEW v_deposits AS
SELECT *,
  CASE WHEN status='pending' AND expires_at IS NOT NULL AND expires_at <= now()
       THEN 'expired' ELSE status END AS effective_status
FROM ts_deposits;

CREATE INDEX idx_ts_deposits_pending_active 
  ON ts_deposits (expires_at) 
  WHERE status='pending';
```

Contract: read paths use view + `effective_status`; write paths use raw table + `expires_at` race-guards. No side-effect writes during reads.

## Pattern observations

1. **User-surfaced clarification, instance #6 in 2 weeks** — same shape every time. Pre-Input-5 checkpoint should be reflexive habit by now; failing 6 times means it isn't yet — needs externalization. Will propose in retro.
2. **First cross-cutting amendment to ratified siblings driven by sibling-ADR design discovery.** Names recurring shape: "sibling design discovery sometimes requires cross-cut amendments that fit within ratified scope of the siblings."
3. **User pushback as design force multiplier** — specifically when current has structural limits (MongoDB no view) the next-system can transcend (Postgres clean view). Distinct from clarification pattern (those correct errors; this triggers exploration).

## Body size impact

§ADR-4c body grew ~110 → ~190 lines (over ~150 extract threshold). Will extract to `docs/design/deposit-lane/` after thread #55 ratifies — sibling-style precedent (§ADR-4a, §ADR-6, §ADR-8).

## Threads + commits

- Thread #55 — message posted with revised C1 rec; awaiting user re-confirmation on C1 only (C2-C5 unchanged).
- Commit: `5512e90` (pass 1.5) on branch `architect/w1-refine-adr-4c-deposit-auto-expire-2026-04-29` / PR [#5](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/5).
- Supersedes: pass-1 baseline learning `learning_2026-04-29_w1-refine-pass-1-adr-4c-deposit-auto-expire-bas` (this learning is the revised state).
- Trace chain: this pass traces should chain to pass-1 trace `98710bfc-12b2-4611-a25d-7ae5b7b0ab75`.

## Next pass candidate

§ADR-4c ratification (after user re-confirms C1) → promote `#provisional` → `#decision`. Then extract §ADR-4c body to `docs/design/deposit-lane/` (extraction pass; ~30 min).

---
*Added via Oracle Learn*
