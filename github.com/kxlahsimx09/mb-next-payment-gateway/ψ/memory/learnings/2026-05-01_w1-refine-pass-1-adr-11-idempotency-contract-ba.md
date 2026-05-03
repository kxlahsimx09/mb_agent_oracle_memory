---
title: W1 refine pass 1 — §ADR-11 Idempotency Contract baseline (`#provisional` `[RATIF
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-11, idempotency, idempotency-key, client-api, deposit-create, payout-create, slip-upload, stripe-pattern, baseline, pass-1, provisional, ratification-pending, drift-closure-instance-3, coordination-rule-instance-2, substrate-convergence-7-instances, thread-59-opened]
created: 2026-05-01
source: docs/adr.md@9d2d748 §ADR-11 + thread #59 messages + 3 mobiz learnings cited in §Revision log
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 refine pass 1 — §ADR-11 Idempotency Contract baseline (`#provisional` `[RATIF

W1 refine pass 1 — §ADR-11 Idempotency Contract baseline (`#provisional` `[RATIFICATION_PENDING:59]`).

Closes the structural gap where current mobiz allows HTTP retry from client → duplicate ts_deposits / ts_payouts row by construction. §ADR-7 ratifies API-Key auth + HMAC integrity but does not specify replay-handling contract. PR #200 server-derived request_id (matcher-disambiguator fix for production incident PAY1776286617S2B53L 2026-04-16) is matcher-internal; client-side replay surface is structurally separate.

Body 78 lines (well under 150-line extract threshold; close to §ADR-9 ratified 78 + §ADR-10 73 baseline). Architecture-vs-design discipline carried forward — body names the surface + invariant + staging; defers seconds + columns + SQL + body-shape to design/impl pass.

Five decisions, each [RATIFICATION_PENDING:59]:
- C1 Idempotency-Key surface = required client-supplied header (Stripe pattern); body-hash fallback rejected (fragile under encoding changes); server-only rejected (server cannot distinguish retry from new request with same fields)
- C2 dedup-index location    = separate idempotency_keys table + UNIQUE (client_id, key) + response_snapshot for replay-safe; column shape deferred
- C3 TTL                     = Phase-1 fixed 24h; Phase-2 merchant-configurable trigger-driven (mirrors §ADR-9 retry-budget + §ADR-2 RBAC + §ADR-10 audit-topology Phase-1/2 staging)
- C4 conflict semantics      = replay-safe + body-hash conflict; same-key+same-body=replay 200 / same-key+diff-body=409 Conflict / outside-TTL=new request; Stripe-style
- C5 architectural invariant = every client-facing payment-API create requires Idempotency-Key; shared middleware enforces; coordination-rule-as-architectural-invariant pattern instance #2 (per §ADR-10 D5 precedent)

Ten trade-off alternatives evaluated and rejected (A no-idempotency / B optional / C body-hash-only / D server-derived extension / E unique-on-business-tables / F forever-TTL / G Phase-1-configurable / H silent-mismatched-retry / I always-409 / J per-endpoint opt-in). 6 revisit triggers documented.

Three patterns confirmed durable from prior passes:

1. **Coordination-rule-as-architectural-invariant — instance #2** (after §ADR-10 D5 canonical lock-order). §ADR-11 D5 sets "every client-facing payment-API create requires Idempotency-Key" as architectural invariant. Pattern: cross-endpoint rule + missing-it = drift-class → architecture is the right place. Every future client-facing create endpoint inherits requirement from §ADR-11.

2. **Drift-closure-as-decision — instance #3** (after §ADR-10 D4 thread-#6 silent-skip + §ADR-9 D2 callback-resend idempotency). §ADR-11 closes "HTTP retry → duplicate row" structural gap by Decision #1+#5. Pattern: known structural gap + has known fix (Stripe Idempotency-Key) + fix changes data semantics (new dedup primitive) → architecture closes structurally.

3. **Phase-1/Phase-2 staging — instance #4** (after §ADR-2 RBAC + §ADR-9 retry + §ADR-10 audit/balance). §ADR-11 D3 names Phase-2 trigger explicitly (first merchant SLA negotiation requiring custom TTL). Pattern: hedged decision with clear evolution path; avoids premature abstraction while keeping Phase-2 visible.

Three client-facing payment-API creates affected: deposit-create + payout-create + slip-upload. Architectural invariant via shared middleware ensures uniform contract across endpoints + future expansion.

Substrate convergence count → 7 — §ADR-11 ports Stripe Idempotency-Key pattern (industry standard) + reuses §ADR-9 D2 dedup-key shape from merchant-side (symmetric: §ADR-9 was outbox→merchant; §ADR-11 is client→gateway) + reuses §ADR-10 D5 coordination-rule-as-architectural-invariant pattern.

Prior-art bundle: 3 mobiz learnings (request_id gate / payout-request flow ratification / Opt D Idempotency-Key from threads #19+#31) + §ADR-7 auth parent + §ADR-9 D2 merchant-side precedent + §ADR-10 D5 pattern precedent + §ADR-4a/4b/4c downstream consumers + W10 baseline (no inheritance constraint applies). Input 5 not needed (mobiz code lines cited line-precise via prior learnings).

Threads opened: #59 (5 sub-questions C1-C5). Threads closed: none. Commit: 9d2d748. PR #9 (open, not merged; baseline pass after §ADR-9 PR #7 + §ADR-10 PR #8 merged to main). Trace chain candidate: §ADR-10 pass-2 ratified (b304445f) — §ADR-11 closes the upstream client-API surface that §ADR-10 wallet-substrate atomic-RPCs consume.

Pre-Input-5 checkpoint NOT triggered this pass — no "current does X" claim made without prior-learning citation.

Single-straight-ratification heuristic from §ADR-10 retro suggests §ADR-11 may ratify in single response if all 5 enabling conditions present (Phase-1/2 staging on hedged decisions ✓ / architect-rec on every sub-question ✓ / trade-offs rejected inline ✓ / drift-closure-as-decision ✓ / coordination-rule-as-invariant ✓). All 5 satisfied; single-straight-ratification likely.

Next-pass candidate: §ADR-11 ratification (pass 2) when user answers C1-C5 — same shape as §ADR-10 ratification velocity (~10 min if straight-ratification). After §ADR-11 ratifies: Payment Source-Flow ADR (Settlement scheduling + Pullout + Direct-Transfer + Payout creation; 120-180 min, may need 2 passes); then Admin-API surface ADR (90-120 min) — both surface-shaped, not substrate-shaped.

---
*Added via Oracle Learn*
