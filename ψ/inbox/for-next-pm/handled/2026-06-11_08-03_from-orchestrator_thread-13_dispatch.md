---
from: orchestrator
from_role: orchestrator
to: next-pm
to_role: next-pm
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: author epic — mb-next-bank-bot integration + per-bank_account_id bot provisioning (Phase-1 statements-only)
priority: high
needs_response: true
created: 2026-06-11T08:03:34+07:00
---

# Epic: mb-next-bank-bot integration (Lane B of the bank-bot campaign)

Owner GO 2026-06-11 on handoff `2026-06-10_06-46_mb-next-bank-bot-plan-statement-automatch-golden-journey` item 2. Campaign anchor: thread #13 (arra-oracle-v3). Runs in PARALLEL with next-architect's design pass (same thread) — mark auth-dependent stories `[PENDING-ARCHITECT thread-13 D3]` rather than blocking.

## Context (orchestrator-verified 2026-06-11)

- Repo `kxlahsimx09/mb-next-bank-bot` exists (seeded from `kokarat/bank-bot@5cb612f`, no history, seed commit `9405272`). Fleet role `nextbot-dev` being registered by brew-ops.
- **Owner-locked scope: Phase-1 = statements-only** (deposit auto-match lane — the MAJORITY money flow per owner insight). Payout/queue lane deferred to Phase-2.
- Gateway side ALREADY covered by `docs/requirements/epic-statement-matching.md` (MATCH-001 intake/dedup, MATCH-002 IN-cascade, MATCH-003 OUT-reconcile) — do NOT duplicate the intake contract.
- What has NO epic/story coverage today (the gap you close):
  1. **The bot itself**: adapter port (gateway client `core/api.js` swap to `bot-statements` + `bot-bank-statements-last` EFs), Phase-2 stubs, mock-portal/test story.
  2. **Per-`bank_account_id` bot provisioning**: admin issues the bot credential bound to a `bank_account_id`, registers the account, deploys the bot instance (one container per account, per production pattern); credential rotation/revocation ops. Auth mechanism + credentials-bootstrap = `[PENDING-ARCHITECT thread-13 D3/D4]`.
  3. **SIM statement source**: realising `MOCK_BANK_URL` for §ADR-21 — thin mock of bot-statements ingestion OR mb-next-bank-bot against a mock portal; includes the dup-credit fault flag (NOTE: the dedup invariant is `uq_bank_statements_dedup_in` + count-based dedup, NOT `bank_transaction_id` — that field is payout-side only). This unblocks LIVE-gate fault (i).
- REAL-BANK mode (M2, §ADR-21) = Phase-2 horizon; mb-next-bank-bot is its real scraper.

## Deliverable

`docs/requirements/epic-bank-bot-integration.md` (or per your epic layout conventions) in mb-next-payment-gateway, branch + PR per GitHub flow — stories with Given/When/Then AC, S-numbered, Phase-1/Phase-2 partitioned, cross-refs to epic-statement-matching + epic-bot-dispatch (BOT-001..004, withdrawal lane — Phase-2 anchor) + §ADR-4b/§ADR-6/§ADR-21.

`needs_response: true` — reply on thread #13 with the epic PR link, then archive this envelope (§11d).

— orchestrator, 2026-06-11 08:03 GMT+7
