---
title: #decision: P1#4 callback safety contract revised and ratified as preconfigured c
tags: [system-architect, repo:mb-next-payment-gateway, next, adr-9, callback-endpoint, callback-url, ssrf, security, decision, thread-223, preconfigured-endpoint]
created: 2026-05-25
source: thread #223 follow-up human ratification + dpay MCP verification + PR #240 update
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #decision: P1#4 callback safety contract revised and ratified as preconfigured c

#decision: P1#4 callback safety contract revised and ratified as preconfigured callback endpoints for mb-next-payment-gateway on 2026-05-25 via Oracle thread #223 follow-up.

Human ratification phrase: "งั้น ok เอาตามนี้" after reviewing current production data and the preconfigured endpoint recommendation.

Supersedes the earlier same-day per-request callback_url validation decision. Final ratified contract:
- Deposit/payout create APIs MUST NOT accept raw callback URLs (`callback_url` or any destination URL). Raw URL input rejects before business-state writes with HTTP 400 `code=CALLBACK_URL_NOT_ALLOWED`.
- Callback destinations are configured per client/per flow (`deposit_callback_url`, `payout_callback_url`), with optional admin-configured named endpoint keys. Create APIs may select only a preverified `callback_endpoint_key`, never a URL. Unknown/disabled key rejects with `INVALID_CALLBACK_ENDPOINT_KEY`.
- Callback endpoint create/update config validates the full URL synchronously before save: absolute HTTPS only; reject http, relative, non-HTTP schemes, fragments, embedded credentials, localhost, loopback/link-local/private/reserved IP literals, unsafe DNS answers, and non-default ports unless admin-owned audited allowlist permits the controlled environment. Invalid config writes fail with `INVALID_CALLBACK_ENDPOINT` and leave old config unchanged.
- Payment create requires a verified endpoint snapshot. Missing required endpoint config rejects before business-state write with HTTP 409 `CALLBACK_ENDPOINT_NOT_CONFIGURED`.
- The gateway snapshots the selected endpoint URL/key/version onto the source row or callback event; retries/manual resend use that snapshot and client config changes do not rewrite in-flight destinations.
- Per-transaction dynamic callback context moves to signed payload fields (`client_reference_id` -> `clientReferenceId`, bounded `metadata`, event/status fields), not URL path/query.
- Dispatch still re-checks endpoint DNS safety before each attempt; unsafe rebinding produces `callback_endpoint_unsafe` attempt/dead-letter behavior without mutating source lifecycle state.

Production-data grounding checked 2026-05-25 via dpay MCP:
- 0/108 `clients` rows had a `callback_url` config field; current system stores callback URLs on transaction rows.
- Transaction callback URLs vary in exact path/query for some clients, but origin is stable for most traffic: deposit primary origin ~99.988%, payout primary origin ~99.885%.
- Query keys observed were limited to `resource_type` and `action`/`on_success`/`order_id`; `order_id` overwhelmingly matched `ref_code` (deposit 90,689/90,826; payout 54,926/54,933), so current dynamic query intent maps to signed callback payload fields.
- Current HTTP endpoints exist (deposit 90,828 rows, payout 54,931 rows), but Phase-1 is greenfield/no migration; HTTPS-only preconfigured onboarding is the ratified divergence.

Local docs updated and verified with `git diff --check`:
- `docs/adr.md`: §ADR-9 amendment renamed to Preconfigured Callback Endpoint Safety Contract; WC7 now includes optional bounded `metadata`; CU1-CU8 lock the final contract.
- `docs/requirements/epic-deposit.md`: DEPOSIT-001 removes `callback_url` from create examples/ACs; adds endpoint snapshot, raw URL rejection, missing config rejection, endpoint key rejection, and client_reference_id/metadata fields.
- `docs/requirements/epic-payout.md`: PAYOUT-001 mirrors the same endpoint contract and manual resend precondition now references endpoint snapshot.
- `docs/requirements/epic-deposit-revision-log.md`: P1#4 entry updated from per-request validation to preconfigured endpoint contract.

UX/API implication: greenfield clients configure callback endpoints during onboarding/config updates, then payment-create calls carry business references/metadata rather than callback URLs. Existing mobiz-style clients that routed by dynamic URL path/query would need adapter changes, but Phase-1 has no migration population.

---
*Added via Oracle Learn*
