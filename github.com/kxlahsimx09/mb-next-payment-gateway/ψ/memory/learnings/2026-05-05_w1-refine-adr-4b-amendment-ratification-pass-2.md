---
title: W1 refine — §ADR-4b amendment ratification (pass 2) — thread #76 closed; B1-B7 r
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4b, amendment, bot-gateway-contract, ratification, pass-2, decision, thread-76-closed, b3-b5-monitoring-reframe, adr-11-exemption, single-pass-multi-pivot, user-pushback-instances-10-11-12, pre-input-5-instance-12-13, pattern-instance-3-revised, bot-adapter-responsibility-narrowing, matcher-cascade-dependency, linkcheckingdeposit-pr-384, future-adr-15-monitoring-placeholder, scope-preservation-adr-9]
created: 2026-05-05
source: docs/adr.md@e69617a + docs/design/deposit-lane/bot-gateway-contract.md@e69617a + thread #76 closed messages 182-184
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine — §ADR-4b amendment ratification (pass 2) — thread #76 closed; B1-B7 r

W1 refine — §ADR-4b amendment ratification (pass 2) — thread #76 closed; B1-B7 resolved → `#decision` 2026-05-05 GMT+7.

**Single-pass dialogue compressed lifecycle.** Pass-1 baseline → B2 within-pass refinement (raw_text_hash → count-based RPC + lock) → §ADR-11 exemption surfaced → B3+B5 monitoring reframe → B7 detailed walkthrough → ratify. **4 architectural pivots in single arc** — fastest pass-1-to-ratify lifecycle in repo history. Compare §ADR-12 (3 pre-ratification revises across 2 days), §ADR-13 (pass 1.5 + 1.6 across 2 days). Velocity attributable to user-pushback applied proactively + Pre-Input-5 discipline + architect-rec pre-positioned on all 7 questions.

**Verdict summary (all ratified):**
- B1 = (a) source-derived cursor lock-in
- B2 = β-refined within-pass (count-based RPC + pg_advisory_xact_lock; not unique constraint)
- B3 = intent ratified, mechanism deferred to future monitoring/alerting ADR (placeholder §ADR-15)
- B4 = (b) unify §ADR-7 API key middleware
- B5 = deferred to same future monitoring ADR (reframed from §ADR-9 amendment proposal)
- B6 = (c) hybrid Option 3 (sparse cols + JSONB overflow + promotion path)
- B7 = (a) port match_hash V1 fraud detection (sparse compute pattern)

**Architectural reframe pattern (B3 + B5 unified):** First instance in repo where 2 independently-deferred items collapsed under single future ADR based on user observation that they share monitoring substrate. User direction: "ตั้งใจจะแก้ทั้งหมดบน next — ผ่านระบบที่คอย monitor alarm" + "B5 น่าจะเป็นระบบ monitor". Pattern: when 2 deferred items name "alert" + share observation surface, ask whether they belong to same future ADR before fragmenting ownership. Reframe avoided: §ADR-9 callback dispatcher scope creep + bot adapter circuit-break per-class logic + retention checks ad-hoc.

**Bot adapter responsibility narrowing as side-effect of B3+B5 reframe.** Initial proposal: bot implements fail-loud / circuit-break / classify ~30-50 LOC. Final: bot emits telemetry signals only; detection + alarm centralized at future monitoring layer. Reduces bank-bot adapter complexity + future-proofs against new drift classes.

**§ADR-11 scope exemption pattern (new).** Bot statement-push endpoints carved out of §ADR-11 Idempotency-Key Required (which targets client-facing payment APIs). Rationale: when endpoint relies on I-no-retry + row-level dedup, request-level idempotency middleware adds zero safety AND adds caller state burden. Pattern: when scoping cross-cutting policy, declare carve-outs upfront for endpoint classes that don't fit the policy's safety model.

**Pattern instance tally update:**
- User-pushback-as-design-force: 9 → 12 (3 new in this pass: cursor-derived insight, match_hash separation, B3+B5 reframe)
- Pre-Input-5: 11 → 13 (2 new code-reads: BotConfigController GET + slipMatchHash full body)
- Deliberate-divergence-via-Postgres-feature: 4 cumulative (B2 retains instance #3; divergence shape revised from uniqueness mechanism to serialization mechanism)

**Critical dependency surfaced (matcher cascade).** B7 walkthrough revealed `linkCheckingDeposit` (mobiz PR #384, 2026-05-03) as load-bearing for V1 fraud check correctness. Pre-#384 production incident DEP17777364940AC8L3 + DEP1777733674IBGAQO blocked legitimate slip approvals. 3-step cascade ordering (matchDepositKTB/SCB pending → linkCheckingDeposit → linkPaidDeposit) MUST be implemented in next-system. Documented in design doc §8a; specification deferred to future §ADR-4b D2 amendment to avoid scope creep on this amendment.

**Single-straight-ratification heuristic test result.** Predicted high straight-rate; reality 4/7 straight (B1+B4+B6+B7) + 3/7 within-pass refined (B2 refined; B3+B5 reframed). Update candidate: prediction score should weight question-shape — binding-decision questions (B1+B4+B6+B7) high straight-rate; scope-naming questions (B3+B5) higher revision likelihood; refinement-vs-rejection ratio favorable (no question fully rejected; all reach #decision in single pass).

**Single-pass dialogue with multiple pivots — heuristic update candidate.** When dialogue surface allows fast iteration (Pre-Input-5 proactive + architect-rec pre-positioned + user fluent in architectural language), 4-pivot single-arc is achievable. Compare to multi-day §ADR-12/13 with similar pivot count but day-boundary delays. Process improvement: front-load architect Q&A prep with code-reads + cross-references before opening thread = compressed dialogue cycle.

**§ADR-9 scope preserved.** Callback dispatcher remains scoped to outbound delivery; ingest-staleness moved out per B5 reframe. Cleaner per-ADR scope.

**Artifacts:**
- PR #15 — 5 commits (baseline / baseline-backfill / B2-refinement / lock-posture-reframe / ratify-pass)
- docs/adr.md §ADR-4b amendment body — #decision
- docs/design/deposit-lane/bot-gateway-contract.md (~480 lines) — implementation notes + §8a matcher cascade dependency
- thread #76 closed

Trace e4ab88ed (pass-1 + B2 refinement + lock reframe) + this trace (ratify) = same arc. Chains forward from `e4ab88ed`. 16-link cumulative chain since §ADR-4c origin.

Threads opened: none. Threads closed: #76. Future ADR placeholder: §ADR-15 monitoring/alerting (B3+B5 deferral target). Next pass candidate: §ADR-4d slip-side amendment OR §ADR-4b D2 matcher cascade amendment OR revision-log archival pass 2.

Commit: e69617a (pass-2 ratify body) + backfill commit (this learn + trace).

---
*Added via Oracle Learn*
