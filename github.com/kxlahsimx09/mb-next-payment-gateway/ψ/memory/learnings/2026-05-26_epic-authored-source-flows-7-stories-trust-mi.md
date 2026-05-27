---
title: epic authored — source-flows — 7 stories, trust mix S2/S3/S4 = 4/1/2.
tags: [next-product-writer, repo:mb-next-payment-gateway, next, requirement, epic, source-flows, settlement, pullout, direct-transfer, mixed-trust, campaign-228, thread-230]
created: 2026-05-26
source: docs/requirements/epic-source-flows.md@writer/source-flows-adr12
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# epic authored — source-flows — 7 stories, trust mix S2/S3/S4 = 4/1/2.

epic authored — source-flows — 7 stories, trust mix S2/S3/S4 = 4/1/2.

Subsystem: payment source-flows (settlement + pullout + direct-transfer creator side)
Net-new epic from campaign #228 / sub-thread #230 (Pass 1, P0a). Translates §ADR-12 (Payment Source-Flow taxonomy, #decision 2026-05-02 thread #60) into human-readable stories, grounded against current production (dpay MCP 2026-05-26).

Stories:
- SRCFLOW-001 [S2] the 5-row caller×auth×trigger×idempotency taxonomy; duplicate-protection depends on caller mechanism not flow type (machine→Idempotency-Key, human→none, system→cooldown).
- SETTLE-001 [S2] client/sub-client API settlement create (machine caller, Idempotency-Key, wallet reserve).
- SETTLE-002 [S3] admin create + review lifecycle (approve→finalise, reject→refund, append-only, no UPDATE/DELETE DRIFT-7); shape preserved-by-intent (§ADR-12 C2) but detailed next-system lifecycle deferred.
- PULLOUT-001 [S2] single-dispatcher consolidation (§ADR-12 D3) — 4 triggers → 1 entry, one guard chain.
- PULLOUT-002 [S4] do-not-lose guard chain: DestCap random band, two-layer in-flight reservation (pending + settled-unsynced ~60min floor), source-side reservation, jitter/window timing, demand-refill. §ADR-12 defers specifics to impl pass.
- DTR-001 [S2] sync-validate-all-before-INSERT (§ADR-12 D4) — closes the DTR…RZE1H2 self-transfer+balance-insufficient async-fail incident.
- DTR-002 [S4 deferred] deposit-refund-via-direct-transfer (transfer_type=refund + refund_for_deposit_id) — maps to DEPOSIT-011 deferred Phase-2.

Production grounding corrections (dpay 2026-05-26): settlements status is INT (waiting_to_review=3, not the string; pending 0/24, approved 1/2784, processed 2/162, review 3/2); entity_type client/partner; wallet_before on 100% (signals reserve/debit at create — open Q). pullout_tasks is a recurring CONFIG (status bool enabled/disabled), per-run in pullout_logs; only jitter(154)/window(1) strategies live (weighted/burst are dead code paths); reservation logic surfaces in last_skip_reason text. direct_transfers status is STRING (completed/failed/waiting_to_review/cancelled); transfer_type refund on 7/597 with refund_for_deposit_id; approved_by_name on 575/597 (admin approve step).

Open threads: [AWAITING_THREAD:233] to next-architect — (Q1) settlement wallet-debit timing create-vs-approve; (Q2) does settlement approve distribute MDR (tester learning says confirm-review success branch SKIPS MDR; contradicts pg-writer Bucket B "approve→MDR distribute"). Non-blocking; SETTLE-001/002 shipped with anchors.

Cross-flags to architect sub-thread #229 ratification: PULLOUT-002 per-bank withdrawal amount band = A2 (fair-router eligibility, belongs to BOT epic). A3 per-client rate-limit deferred to Auth/Client-API epic (Pass 2). A1 per-bank maintenance-cancel = payout-epic scope, not source-flows.

Files: docs/requirements/epic-source-flows.md (new) + glossary.md (+settlement/pullout/direct-transfer) + INDEX.md (+Payment Source-Flows section) + README.md (3 _planned_ rows → epic-source-flows.md). Mermaid gate: 4/4 PASS. MDX brace check: clean.

---
*Added via Oracle Learn*
