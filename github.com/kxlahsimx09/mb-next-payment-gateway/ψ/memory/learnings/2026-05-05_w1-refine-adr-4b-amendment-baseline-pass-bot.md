---
title: W1 refine — §ADR-4b amendment baseline pass — Bot↔Gateway Statement Push Contrac
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4b, amendment, bot-gateway-contract, statement-push, cursor-derived, no-retry, dedup, match-hash, v1-fraud, drift-closure, hybrid-schema, baseline, pass-1, provisional, ratification-pending, deliberate-divergence-pattern, pattern-instance-3, pattern-instance-4, pre-input-5-instance-11, user-pushback-instance-9, cross-section-amendment, first-amendment-architectural-completeness]
created: 2026-05-05
source: docs/adr.md@e0b0ac8 + thread #76 + code-reads in mobiz BotConfigController + slipMatchHash
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine — §ADR-4b amendment baseline pass — Bot↔Gateway Statement Push Contrac

W1 refine — §ADR-4b amendment baseline pass — Bot↔Gateway Statement Push Contract (`#provisional`, thread #76 opened 2026-05-05 GMT+7).

First amendment to previously-ratified §ADR-4b in this repo's W1 history that codifies cross-cutting bot-gateway contract — sibling shape to §ADR-4d post-ratification amendment (2026-04-27) but driven by architectural-completeness review during §ADR-14 fleet-control scoping dialogue, not by user clarification of just-ratified content. User initiated as "พัก ADR 14, มาคุย §ADR-4b amendment" after architect surfaced cursor location + dedup mechanism gaps while exploring deposit-lane re-entrancy for §ADR-14.

Pre-baseline read forced by user "ลองค้นดูในระบบปัจจุบัน...เคยเจอปัญหาขาฝากอะไรบ้าง" — Pre-Input-5 instance #11. Verified 4 invariants against mobiz code (`controllers/BotConfigController.go:925-976` cursor pattern B already / `:759-803` count-based dedup race target / `:746-757` match_hash inline compute / `services/slipMatchHash.go:1-120` V1 fraud + 4-field hash composition). Avoided pass-1 baseline trap of "claim current does X without reading code."

User-pushback-as-design-force pattern instance #9 — within pre-baseline dialogue rather than at ratification: (i) "last_in_date_bkk เป็น derived ถ้าใช้ statement date จะดีกว่าไหม" → I-derived invariant reframed (3 invariants → 1; per-direction + advance-on-success + self-healing become schema properties not implementer invariants); (ii) "match_hash จริงๆทำเพื่อ slip-statement collision" → architect's initial dedup_key proposal conflated 2 concerns; B7 added as separate decision after Oracle search surfaced services/slipMatchHash.go evidence. Both pushbacks happened during pre-baseline (not at ratification) — Pre-Input-5 pattern at its best.

2 deliberate divergences in single amendment (Pattern instance #3 + #4 of "deliberate divergence via Postgres feature" — after §ADR-4c D10 view-contract / §ADR-13 D2 trigger-denorm):
- I-dedup: count-based check (race-prone, implicit single-bot-per-account assumption) → Postgres unique constraint + bank_dedup_strategy config table (race-free regardless of concurrency)
- B6 schema: MongoDB schemaless → hybrid sparse-cols + JSONB bank_extras + promotion path

Pattern is durable — qualifying for promotion to architectural rule in next maintenance pass.

7 sub-questions in thread #76 with architect-rec each:
- B1 source-derived cursor lock-in → (a) Yes
- B2 dedup deliberate divergence → (a) Yes (Pattern instance #3)
- B3 drift Q1/Q2/Q4 closure → (a) Close all 3
- B4 bot auth unification → (b) §ADR-7 API key middleware
- B5 retention alert ownership → (a) §ADR-9 amendment
- B6 schema shape → (c) Hybrid Option 3
- B7 match_hash V1 fraud port → (a) Yes (sparse compute)

Single-straight-ratification heuristic prediction: high probability — scope ≤ 1 sub-section / cross-cutting cited / architecturally-clean-by-construction (Postgres-feature divergence makes shape unambiguous) / pre-positioned architect-rec on all 7. Update heuristic confidence after thread #76 closes.

§ADR-4b body 69 → ~135 lines (under ~150 extract threshold). 9 [RATIFICATION_PENDING:76] markers in live body. PR #15 opened.

Cross-section trace chain — first instance of "later session amends earlier ADR" backwards in trace topology. All prior chains forward-only (§ADR-4c → §ADR-9 → ... → §ADR-13). Documents principle: trace chain = research session arc, not ADR ordinal sequence.

Threads opened: #76. Threads closed: none. Commit: e0b0ac8. Branch: architect/w1-refine-adr-4b-amendment-bot-gateway-contract-2026-05-05. PR: #15. Next pass candidate: thread #76 ratification → ratify pass when human responds.

---
*Added via Oracle Learn*
