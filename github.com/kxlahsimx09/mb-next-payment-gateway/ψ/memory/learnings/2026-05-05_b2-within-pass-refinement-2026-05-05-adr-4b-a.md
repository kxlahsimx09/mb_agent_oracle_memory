---
title: B2 within-pass refinement (2026-05-05) — §ADR-4b amendment dedup mechanism final
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4b, amendment, bot-gateway-contract, b2-refinement, count-based-dedup, advisory-lock, rpc-vs-ef, adr-11-exemption, user-pushback-instance-10, pattern-instance-3-revised, deliberate-divergence-serialization-mechanism, design-doc-extraction, edge-cases-test-plan, next-implement-handoff, within-pass-revise]
created: 2026-05-05
source: docs/adr.md@e03b1e5 + docs/design/deposit-lane/bot-gateway-contract.md@e03b1e5 + thread #76 messages 182-183
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# B2 within-pass refinement (2026-05-05) — §ADR-4b amendment dedup mechanism final

B2 within-pass refinement (2026-05-05) — §ADR-4b amendment dedup mechanism final shape: port mobiz count-based + RPC + pg_advisory_xact_lock per account; no hash/no unique constraint; design doc edge-cases extracted for next-implement.

**User-pushback-as-design-force pattern instance #10** (within single pass; 2nd in §ADR-4b amendment after the cursor-derived insight at instance #9):

Initial architect proposal "Postgres unique constraint + bank-specific dedup_key composition via bank_dedup_strategy config table" was theoretically clean (race-free + simple) but had hidden weakness on SCB edge case: 2 real deposits from same source in same minute, identical structured fields → no uniqueness primitive within bank-exposed data. Architect proposed `raw_text_hash` tie-breaker; user rejected: "เราควบคุมไม่ได้ว่า html ในนั้นจะเป็นยังไงบ้าง และจะเปลี่ยนเมื่อไหร่" — bank UI is volatile (redesigns, A/B tests, dynamic timestamps in HTML attributes).

Final shape: port mobiz BotConfigController.go:759-803 count-based logic verbatim + pg_advisory_xact_lock(hashtext('stmt:' || account)) for race safety. Pattern instance #3 of "deliberate divergence via Postgres feature" still applies but divergence is *serialization mechanism* (advisory lock + transaction wrap) NOT *uniqueness mechanism*.

Architectural lesson — **prefer current-system-pattern verbatim over architect-invented improvement when current pattern is correct under stated assumptions and architect-invented depends on bank-controlled artifacts**. Bank-exposed fields are external; can change without notice. Logic that depends on stable bank rendering (raw_text, HTML structure, formatting) inherits external fragility. mobiz's count-based logic is correct under "1 actor at a time per account" assumption; advisory lock makes that assumption true regardless of concurrent actors.

**§ADR-11 exemption pattern (new)** — per user "การ implement idempotency ที่ bankbot อาจะไม่คุ้มหรือเปล่า": when an endpoint relies on I-no-retry semantics (cursor-reload IS retry) + row-level dedup, request-level idempotency middleware adds zero safety (HTTP retry doesn't happen on bot side; row dedup catches re-delivered same-content) AND adds state burden to caller (key generation, storage, replay handling). Bot endpoints explicitly carved out of §ADR-11 scope. Pattern: when scoping cross-cutting policy (auth, idempotency, etc.) to a new ADR, declare carve-outs upfront for endpoint classes that don't fit the policy's safety model.

**Implementation extraction to design doc (per user "เผื่อจะใช้ test ในอนาคต ให้ next-implement ทำต่อได้")**:
- docs/design/deposit-lane/bot-gateway-contract.md (~450 lines)
- 10 edge cases A-J with mitigation per case
- 5 bot-side invariants (BS-1..5: intra-batch dedup / time precision / TZ / numeric types / batch size limit)
- 6 gateway-side invariants (GS-1..6: transaction wrap / advisory lock / NULL-safe comparison / type strictness / batch size validation / date range sanity)
- 8-step EF responsibilities (auth + orchestration only; no business logic)
- Test plan candidates grouped by edge case (unit / integration / concurrency / TZ-precision / load)
- 5 deferred implementation questions

Pattern: ADR body = binding contract; design doc = implementation checklist + test plan. Keeps architect role focused on decisions; gives next-implement role concrete starting point. Same shape as §ADR-4a/4c precedent extractions but pre-emptive (not triggered by ~150-line threshold).

**B3-B7 still pending ratification** in thread #76. Architect-rec unchanged. Wait state: user verdict on auth unification (B4), drift closure (B3), retention alert ownership (B5), schema shape (B6), match_hash port (B7).

Trace e4ab88ed (baseline) + this refinement = same arc. Net commits: e0b0ac8 (baseline) + 1be9581 (backfill) + e03b1e5 (B2 refinement + design doc). PR #15.

---
*Added via Oracle Learn*
