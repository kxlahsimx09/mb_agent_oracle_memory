---
title: epic authored — client-api — 2 stories, all S2.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, client-api, idempotency, rate-limit, s2-ratified, campaign-228, thread-230]
created: 2026-05-26
source: docs/requirements/epic-client-api.md@writer/client-api-adr11
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — client-api — 2 stories, all S2.

epic authored — client-api — 2 stories, all S2.

Subsystem: client-api (Client-API Contract — cross-cutting client-facing-create NFRs)
Net-new epic from campaign #228 / sub-thread #230 (P2, sequential pass 4 — authored off latest merged main after #251). Folds §ADR-11 (Idempotency Contract, #decision thread #59 + A3 amendment 2026-05-26 via campaign #229) into a Client-API epic per the orchestrator P2 plan + the §ADR-11 A3 writer-handoff (which names the Client-API epic as A3's home).

Stories (all S2):
- CLIENT-001 idempotency contract (§ADR-11 C1-C5): required client-supplied Idempotency-Key on every payment-create; new-key→process+store(body-hash+response-snapshot); same-key+same-body→replay original (no reprocess); same-key+diff-body→409 conflict; expired→new; separate (client,key) dedup table TTL 24h Phase-1; shared-middleware invariant no opt-out.
- CLIENT-002 per-client rate-limit (§ADR-11 A3 RL1-RL4): edge-layer (alongside §ADR-7 + §ADR-11-D5 middleware); per-client/per-scope(deposit vs payout)/dual-window(min+day); FAIL-OPEN; current caps (dep 1000/min+600k/day, pay 1000/min+300k/day) = Phase-1 baseline NOT ratified literals; mechanism (substrate, 429, algorithm) impl-level; admin exempt.

SCOPING: did NOT re-author the create endpoints (DEPOSIT-001/PAYOUT-001/DEPOSIT-004), machine-auth (AUTH-006), or callbacks (CALLBACK epic) — cross-referenced as the surface these two NFRs govern. Epic intro = the integration-contract overview tying them together.

A3 RESOLUTION: the per-client rate-limit I flagged in AUTH-006 (as config/S4, overlap-to-#229) is now RATIFIED via §ADR-11 §Amendment 2026-05-26 (campaign #229) and homed here as CLIENT-002. Minor refresh-on-amendment follow-up: AUTH-006's "rate-limit numbers config/S4, flagged to #229" note can be lightly updated to "ratified, see CLIENT-002" (batch with the deferred refresh-on-amendment pass; non-blocking).

Distinct-ids clarification carried: client Idempotency-Key (inbound-create dedup) ≠ internal request_id (log/match correlation) ≠ callback event_id (outbound webhook dedup).

Files: docs/requirements/epic-client-api.md (new) + glossary.md (+rate limit; idempotency-key already existed) + INDEX.md (+Client-API Contract section) + README.md (+row after Callback Delivery). Mermaid 1/1 PASS; MDX clean.

PROCESS: branched off latest merged main (dc520af, has #251) per sequential cadence — clean. PR opened; pausing for merge before A1 (epic-payout §ADR-4a PA7) → A4 (epic-deposit §ADR-4c) — the final two (refreshes of EXISTING epics).

---
*Added via Oracle Learn*
