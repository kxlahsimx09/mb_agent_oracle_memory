---
title: actor terminology fix — Client = API integrator (G1 quick-fix → G3 retroactive r
tags: [system-architect, repo:mb-next-payment-gateway, next, actor-terminology, drift-detection, client-api-integrator, merchant-tenant-admin, verify-divergence-via-production-mcp-instance-2, actor-terminology-drift-detection-via-schema-vs-prose-cross-check-new-sub-pattern, thread-90-opened, g1-quick-fix-path, pr-44, phase-1-surface-correction, glossary-canonical-additions, drift-closure-as-decision-instance-4]
created: 2026-05-10
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# actor terminology fix — Client = API integrator (G1 quick-fix → G3 retroactive r

# Actor terminology fix — Client = API integrator across §ADR-2/4/9/11/12 + glossary + epic-deposit

## Drift discovered

User flagged a single doc claim during epic-deposit review (*"notify the merchant via callback"*) — investigation revealed next-system docs had **inverted Merchant ↔ Client** vs current mobiz code. Affected `docs/requirements/glossary.md`, `docs/requirements/epic-deposit.md`, and 5 hard-contradiction sites + 8 cascade sites in `docs/adr.md`.

## Ground truth (verified via dpay MCP, 2026-05-09/10 GMT+7)

**Client = API integrator** — `clients.api_key` + `api_key_secret`; auth at `mobiz/middlewares/apiKeyCheck.go:33-36` (FindOne on `clients` by `api_key`); owns wallet (verified counts: `wallets.{owner_type=client}` = 87, `partner` = 10, `merchant` = 0); supplies per-deposit `callback_url`; receives HMAC-signed callback; has dashboard login too (multi-role).

**Merchant = multi-tenant parent / dashboard admin** — `username`/`password` dashboard login; `roles: ["merchant"]`; references shared pool (`pool_id`; pool "Main" referenced by 16 merchants per `mcp__dpay__aggregate`); default `mdr_profile_id`; `clients[]` roster; `group` field. **No** `api_key`, **no** wallet, **no** callback receipt. Pools are shared system resources — `pools` schema has no `owner_id` field.

## 5 hard contradictions (fixed in PR #44)

1. §ADR-9 D2 L774: callback dedup actor
2. §ADR-9 D3 L778: HMAC sign-time secret owner (`merchant's secret` → `client's api_key_secret`)
3. §ADR-11 Context L919: API caller identity
4. §ADR-12 D1 taxonomy L1012: Payout caller
5. §ADR-12 D1 taxonomy L1013 + label: Settlement (merchant API) → Settlement (client API)

## Pattern instance — `verify-divergence-via-production-mcp-before-propose` (instance #2)

Established pattern from thread #82 §ADR-13 amendment baseline (instance #1). This instance adds:
- **Cross-check artifacts**: prose claims (e.g. "API-key-authenticated merchants") **against** production collection schema (e.g. `clients.api_key` field exists; `merchants.api_key` does not)
- **Quantitative verification**: count queries (`wallets.{owner_type=merchant}` = 0) reject the prose claim that merchant holds wallets
- **Multi-source convergence**: dpay MCP schema + arra ratified prior learning (W8 thread #4 mobiz Merchant→Client rename) + raw text reads (line numbers L774, L919, L1012-1013)

## New sub-pattern — `actor-terminology-drift-detection-via-schema-vs-prose-cross-check`

When auditing architecture docs for actor identity claims:
1. Identify all actors mentioned in prose ("merchant calls", "client supplies", etc.)
2. For each actor + verb pair, identify the corresponding schema field that would back the claim (e.g. "merchant calls" → would need `merchants.api_key` to exist)
3. Verify field existence + cardinality via production MCP (`describe_collection` + `count` + `aggregate` for relationship cardinality)
4. Flag contradictions where prose claim has no schema backing
5. **Trust schema over prose** — if `merchants.api_key` doesn't exist, "API-key-authenticated merchants" is wrong regardless of doc tenure or ratification status

## Audit reliability lesson — sub-agents are biased by stated ground truth

F1 audit (first Explore agent pass) used the **inverted next-system glossary** as oracle — caught some contradictions but reinforced others as "correct." F2 audit (second Explore pass) was given **corrected ground truth** and caught different contradictions but missed §ADR-11 L919 + §ADR-12 D1 taxonomy that F1 had caught. **Reconciliation by manual raw-text reads** (`Read` with offset/limit on adr.md) was load-bearing for full coverage. Lesson: **never trust a single audit pass; reconcile across passes + verify against raw source**.

## G1 quick-fix path chosen (over G3 formal amendment)

User explicitly chose G1 (*"G1 ก่อนเลยครับ"*) — quick fix first, formal ratify after. Trade-off:
- ✅ Fix lands fast (1 commit, 3 files, +67/-57 lines)
- ✅ Doc coherence restored before next-impl Step 5c reads it
- ⚠️ Modifies 4 ratified `#decision` ADRs without prior arra thread (formal practice violation)
- ⚠️ Mitigated by retroactive thread #90 + this learning + revision-log entry

## Drift-closure-as-decision pattern (instance #4)

Per established pattern in repo (instances 1-3 in retro `19.35_w1-refine-adr-11-idempotency-contract-baseline`), this fix closes a known drift via architectural ratification rather than letting it accumulate. Drift origin: glossary copy-write moment introduced inversion despite mobiz precedent. Closure: glossary canonical `merchant` + `end-user (payer)` entries + 5 hard ADR fixes + cascade.

## Open follow-ups

- Soft items deferred: §ADR-9 L781 *"per-merchant retry config"* + L781 *"merchant SLA negotiation"* + §ADR-12 L1038 *"per-merchant config"* — tenant-scope items; merchant-as-tenant may be legitimate; defer to Phase-2 trigger.
- Thread #90 ratification status `pending` → `#decision` upon user ratify.

---
*Added via Oracle Learn — captures terminology-drift detection methodology + audit-reliability lesson + G1/G3 trade-off rationale*

---
*Added via Oracle Learn*
