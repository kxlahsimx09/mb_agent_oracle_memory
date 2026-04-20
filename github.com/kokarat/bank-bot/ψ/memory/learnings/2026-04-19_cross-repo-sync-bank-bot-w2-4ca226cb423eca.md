---
title: cross-repo-sync — bank-bot W2 (4ca226c..b423eca) ↔ mobiz W2 (37dfb26..1ffafc1) s
tags: [technical-writer, repo:cross, repo:bank-bot, repo:mobiz-payment-gateway, current, cross-repo-sync, flow:deposit-auto-match-from-statement, recovered-from-double-wrap]
created: 2026-04-19
source: W2 track-commit pass on bank-bot at b423eca, cross-repo checked against mobiz-payment-gateway (recovered 2026-04-19)
project: github.com/kokarat/bank-bot
---

# cross-repo-sync — bank-bot W2 (4ca226c..b423eca) ↔ mobiz W2 (37dfb26..1ffafc1) s

cross-repo-sync — bank-bot W2 (4ca226c..b423eca) ↔ mobiz W2 (37dfb26..1ffafc1) share the deposit-auto-match-from-statement flow doc ratification

Both repositories' daily W2 passes on 2026-04-19 document the same flow (`flow:deposit-auto-match-from-statement`) from opposite ends of the contract surface:

- **bank-bot W2** (trace `7f046c32-dc1b-49cd-a47c-d3e7dedd256b`, range `4ca226c..b423eca`): landed `docs/flows/deposit-auto-match-from-statement.md` (bot side), reciprocal of mobiz thread #17. Behavior commits = 1 (viewer-recycle-recovery in `app.js`, bot-internal); remaining 7 commits are docs/flows W8 passes.
- **mobiz W2** (trace `65b549a4-9026-4839-8082-b56229cdfc31`, range `37dfb26..1ffafc1`): covers admin cancel payout endpoint + flow doc ratification including the mobiz side of deposit-auto-match.

Shared contract point: both sides describe the `POST /api/v1/bot/bank-statements` ingestion contract with identical payload shape, per-direction cursor semantics, and actor boundary. Mobiz ratified its side via thread #17; bot side opened thread #20 for ratification of the reverse-engineered bot-side spec.

Why no `arra_trace_link` back to mobiz: the schema's `prev` edge is 1:1 and the bank-bot W2 trace already consumes its prev slot on the same-project chain (linked to prior bank-bot W2 `439ce6e2` per Step 2b). Cross-repo sibling link (Step 2c) cannot co-exist with the same-project chain link under the current schema. Navigation between the two W2s therefore relies on this semantic record + search on the shared `flow:deposit-auto-match-from-statement` tag, not on `arra_trace_chain`. When the schema ever supports multi-parent traces, promote the cross-repo link to a formal `arra_trace_link` call.

Cross-repo viewer-recycle note: behavior commit `2d8ec5e` (viewer loop recovery after browser recycle) is bot-internal — it does not touch the mobiz contract surface. No mobiz ripple.

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-cross-repo-sync-bank-bot-w2-4ca226c.md`; supersedes `learning_2026-04-19_title-cross-repo-sync-bank-bot-w2-4ca226c`.

---
*Added via Oracle Learn*
