---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: mb-next-bank-bot ingestion — §ADR-21 reconcile + Phase-1 scope pin + bot-auth PROPOSAL for owner + credentials bootstrap design
priority: high
needs_response: true
created: 2026-06-11T08:03:34+07:00
---

# bank-bot↔gateway ingestion — design pass (Lane A of the bank-bot campaign)

Owner GO 2026-06-11 on handoff `2026-06-10_06-46_mb-next-bank-bot-plan-statement-automatch-golden-journey`. Campaign anchor: thread #13 (arra-oracle-v3). Repo `kxlahsimx09/mb-next-bank-bot` already seeded from `kokarat/bank-bot@5cb612f` (seed commit `9405272`, no history).

**Owner decisions already locked — take as given, do not re-open:**
- Phase-1 scope = **statements-only** (deposit auto-match lane). Payout/queue lane deferred to Phase-2.
- Bot↔gateway auth: you **design and RECOMMEND**; the owner ratifies. Deliverable is a proposal doc, NOT a self-ratified amendment.

## Orchestrator grounding (verified vs code 2026-06-11 — start here, don't re-derive)

1. **§ADR-21 already pins auto-match as THE golden journey** (adr.md:4569 — M1 Mode SIM fixture-posts a statement to the intake EF; slip-upload explicitly not exercised in SIM). BUT the live-tester's journey script (branch `campaign/livetester-adr21`, `poc/integration/src/live/*`) implements **slip-upload → admin-approve**. The handoff's "re-scope question" is thus already answered in the ADR — what's needed is a **reconcile ruling**, not a re-scope.
2. **The push contract is largely documented**: §ADR-4b §Bot↔Gateway Statement Push Contract (adr.md:669–725, ratified: I-derived / I-no-retry / I-dedup, 3 endpoints, B3/B4/B5/B7) + `docs/design/deposit-lane/bot-gateway-contract.md` + `docs/requirements/epic-statement-matching.md` MATCH-001.
3. **REAL auth gap**: EF code (`supabase/functions/_shared/auth.ts:145-151` botAuth) = flat `x-bot-secret` shared secret, NO `bank_account_id` binding. ADR target = service-role JWT bound to `bank_account_id` (§ADR-2:57 G6-D); §ADR-4b B4 says unify to §ADR-7 API-key middleware; issuance/rotation lifecycle explicitly deferred (§ADR-6 / §ADR-14 "future scope", adr.md:66). **No doc ratifies the interim posture.** §ADR-6 substrate amendment (Fargate) still `#provisional`.
4. **Handoff fault-(i) framing is wrong**: `bank_transaction_id` is NOT a statement-ingest field (it lives on ts_payouts/withdrawal_queue). The dup-credit=0 invariant on statements = `uq_bank_statements_dedup_in` + count-based dedup in `submit_statements_batch`. Correct this wherever the golden-journey fault catalogue references it.
5. **Credentials bootstrap gap**: production bank-bot pulls bank-portal credentials from gateway `GET /api/v1/bot/config/:bankAccount` at boot (core/api.js getConfig). mb-next has NO such EF.
6. **bank-bot seam is tiny**: `core/api.js` (BotAPI, 183 lines, 15 mobiz endpoints) + env wiring in app.js. Portal side keeps AS-IS.

## Your 4 deliverables

**D1 — §ADR-21 reconcile ruling.** Pin formally: auto-match = THE ONE golden journey (majority money flow); classify the existing slip-path journey script (slip lane = §ADR-4d) — secondary journey, or rework target for next-live-tester? Name the artifact change required on `campaign/livetester-adr21`. Include the fault-(i) dedup-field correction (grounding #4).

**D2 — Phase-1 ingestion-scope pin.** ADR-level note: which of the 15 mobiz bot endpoints exist in Phase-1 mb-next (bot-statements + bot-bank-statements-last), which are explicitly OUT (queue/claim/mark, OTP relay, balance, status-report) and where they land later (Phase-2; cross-ref epic-bot-dispatch BOT-001..004 for the withdrawal lane).

**D3 — Bot-auth posture PROPOSAL (owner decides).** The decision memo: interim `x-bot-secret` (works today, zero gateway change) vs implement service-role JWT per `bank_account_id` now vs §ADR-7 API-key unification (B4). Cover: per-bot identity/blast radius, issuance + rotation + revocation lifecycle (the §ADR-6/§ADR-14 deferred part), migration/cutover, and what Phase-1 mb-next-bank-bot should build against TODAY so it isn't blocked. Give ONE recommendation + runner-up. Format like `next-architect_authexposure_proposal.md` (repo root, untracked) → owner review.

**D4 — Credentials bootstrap design.** Where do bank-portal credentials come from for mb-next bots: local secret slot per instance (fleet-secrets) vs a new bot-config EF vs other. Recommend, with the per-`bank_account_id` provisioning flow (ties into next-pm's epic — they're authoring in parallel on this thread).

Small reconciliation items to note for next-writer's SPEC (don't fix yourself): batch-cap 200 (`BS-5`) is code-only; 500 `submit_statements_failed` leaks raw error detail; `balance_after`/`bank_extras` schema-vs-ADR drift.

`needs_response: true` — reply on thread #13 with D1–D4 + proposal doc path, then archive this envelope (§11d). next-writer (SPEC) dispatches after your D3 lands.

— orchestrator, 2026-06-11 08:03 GMT+7
