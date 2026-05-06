---
title: W1 refine — §ADR-4d amendment baseline pass — Slip-Bearing Deposit Fraud Detecti
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4d, amendment, slip-fraud-detection, v1-hash-lookup, v2-receiver-mismatch, force-approve-override, race-case-admin-flip-back, m4-sort-tiebreaker, architectural-separation-v3-dropped, bot-admin-endpoint-separation, user-pushback-instances-13-19, pre-input-5-instance-14, fastest-pivot-rate, pattern-architectural-separation-replaces-runtime-check, baseline, pass-1, provisional, ratification-pending, drop-fallback-path, single-pass-7-pivots]
created: 2026-05-05
source: docs/adr.md@5ce5dfd + docs/design/deposit-lane/slip-fraud-detection.md@5ce5dfd + thread #77 + code-reads in mobiz DepositController + slipFraudCheck
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine — §ADR-4d amendment baseline pass — Slip-Bearing Deposit Fraud Detecti

W1 refine — §ADR-4d amendment baseline pass — Slip-Bearing Deposit Fraud Detection (V1 + V2) — `#provisional`, thread #77 opened 2026-05-05 GMT+7.

**First amendment with 7 user-pushback instances within single dialogue arc — fastest pivot rate in repo history.** Continuing fast iteration pattern from §ADR-4b amendment (4 pivots in single arc); §ADR-4d amendment had 7 pivots. Velocity attributable to: user fluency in architectural language + Pre-Input-5 proactive use + architect-rec pre-positioned + design doc extraction discipline + willingness to drop own proposals fast.

**User-pushback-as-design-force pattern instances #13-#19 within this pass:**
- #13: "linkCheckingDeposit ทำไมไม่ flip เป็น paid?" → surfaced trust-model boundary (slip = admin-review path; statement match alone insufficient)
- #14: "current verify slip ทันทีหรอ?" → corrected my CURRENT vs §ADR-4d conflation (Thunder timing)
- #15: Hash collision realism → M4 sort tiebreaker added (1/130k → 1/430k false-positive)
- #16: Fallback path necessity → dropped per §ADR-4b amendment B7 enforcement; production false-positive class DEP17776655127CL4Q0 structurally eliminated
- #17: "statement = trusted, why wait?" → clarified §ADR-4d D2 already supports auto-match-first via status-stays-pending
- #18: Race-case via admin flip-back (vs auto-promote in linkCheckingDeposit) → §ADR-4d D5 invariant preserved + matcher cascade reuse
- #19: Drop V3 → endpoint separation per §ADR-13 D1 → runtime check redundant when bot can't structurally reach slip-bearing path

Cumulative pattern instance count: 12 → 19 (7 new in this pass). Trend continues durable.

**4 sub-questions in thread #77 (down from initial 5+; simplified):**
- C1 — V1 hash-lookup port + drop fallback + M4 sort tiebreaker → architect-rec (a) Yes
- C2 — V2 receiver-mismatch port → (a) Yes (highest ROI; production-validated)
- C5 — Force-approve override port → (a) Yes (post-2026-05-02 fix mechanism)
- C6 — Race-case admin flip-back NEW → (a) Yes (admin button "delegate to auto-match")

Dropped: C3 (V3 caller-guard) → architectural separation per §ADR-13 D1; C4 (cascade order V3→V2→V1) → simplified to V2→V1 since V3 dropped.

**Architectural pattern candidate: "architectural separation replaces runtime check" (instance #1).** When runtime check inside shared handler addresses cross-cutting concern that would naturally belong to endpoint-level separation (§ADR-13 D1 framework), prefer architectural fix to runtime fix. Bot endpoint + admin endpoint = separate routes = bot can't reach slip-bearing approve path = no V3 runtime check needed. Brew-ops handoff candidate when 2-3 instances accumulate.

**Pattern: race-case admin flip-back vs auto-promote.** When statement arrives mid-admin-review on checking-status deposit, admin clicks "delegate to auto-match" button (UPDATE deposit pending + release statement) → matcher Step 1 picks up via existing path → finalize_deposit credits. Cleaner than auto-promote in linkCheckingDeposit (no §ADR-4d D5 amendment needed; admin retains action ownership; reuses ratified matcher cascade). Audit trail explicit (admin reason note).

**Pre-Input-5 instance count: 13 → 14** (1 new code-read for slipFraudCheck.go V2 helper + DepositController admin approve flow tracing).

**M4 sort tiebreaker — new addition not in mobiz current.** Production false-positive class DEP17776655127CL4Q0 fix in mobiz was "score >= 2" requirement on fallback path. Next-system drops fallback entirely (per §ADR-4b amendment B7 enforcement); needs new mechanism for collision-class. M4 = "matched-to-current-deposit FIRST" sort priority. Cleaner structurally than score threshold.

**Implementation extracted to design doc** `docs/design/deposit-lane/slip-fraud-detection.md` (~600 lines): full V1+V2 algorithms + helpers + scoring + M4 sort + force-approve mechanics + race-case flip-back + 6 edge cases (A V2 fail-open / B V1 collision M4 / C force-approve user_type / D admin flip-back race / E partial Thunder / F flip-back-without-link) + bot/admin endpoint separation table + Layer 1 filter pseudo-code + test plan candidates + 5 deferred implementation questions.

**§ADR-4d D5 invariant preserved** — race-case admin flip-back is admin-owned action (button click + reason note); auto-credit happens at matcher layer (separate code path). D5 ratification ("admin owns both terminals") strictly satisfied. Lesson: simplifications don't always require ratified-decision revisions; sometimes they enable cleaner designs that preserve intent.

**Single-straight-ratification heuristic prediction:** scope contained (1 sub-section in §ADR-4d) + cross-cutting cited (§ADR-13 D1, §ADR-4b amendment B7) + architecturally-clean-by-construction + pre-positioned architect-rec on all 4 questions + 2 architectural simplifications already validated by user during dialogue. **Predict: high probability of straight ratification.**

PR #16 opened (depends on PR #15 §ADR-4b amendment for B7 reference + design doc directory). Threads opened: #77. Threads closed: none. Future flagged: §ADR-4b D2 amendment (matcher cascade incl. linkCheckingDeposit specification).

§ADR-4d body 100 → ~190 lines (over 150 threshold; design doc absorbed implementation detail preemptively). Commit: 5ce5dfd. Branch: architect/w1-refine-adr-4d-amendment-slip-fraud-detection-2026-05-05.

---
*Added via Oracle Learn*
