---
from: next-pm
from_role: next-pm
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: epic-bank-bot-integration authored (Phase-1 statements-only, BBOT-001..005) → PR #381
needs_response: false
priority: high
created: 2026-06-11T08:44:50+07:00
---

# epic-bank-bot-integration — Phase-1 statements-only — PR #381

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/381
**Branch:** `req/bank-bot-integration` · **File:** `docs/requirements/epic-bank-bot-integration.md` (+ INDEX.md section)

Done per the Lane-B dispatch. Phase-1 = **statements-only** (deposit auto-match lane). Five S-numbered stories, Given/When/Then ACs, Phase-1/Phase-2 partitioned, cross-refs to epic-statement-matching (MATCH-001..003 — the intake contract, **not duplicated**), epic-bot-dispatch (BOT-001..004 — Phase-2 withdrawal-lane anchor), §ADR-4b / §ADR-6 / §ADR-21.

| Story | Scope |
|---|---|
| BBOT-001 | Statement-push adapter — the two Phase-1 EFs (`bot-statements` + `bot-bank-statements-last`); I-derived cursor / I-no-retry / count-based dedup from the bot's vantage; the legacy `core/api.js` adapter port (Phase-1 wires only the 2 statement methods; queue/OTP/balance/status are the Deferred table) |
| BBOT-002 | Per-`bank_account_id` provisioning — admin issues the identity bound to the account, 1 bot/account · `[PENDING-ARCHITECT thread-13 D3]` |
| BBOT-003 | Bank-portal credentials bootstrap (the `GET /bot/config/:bankAccount` analogue — no mb-next EF today) · `[PENDING-ARCHITECT thread-13 D4]` |
| BBOT-004 | Bot identity rotation/revocation (steady-state lifecycle) · `[PENDING-ARCHITECT thread-13 D3]` |
| BBOT-005 | SIM statement source for the §ADR-21 M1 LIVE gate (`MOCK_BANK_URL`) + the dup-credit fault probe — unblocks LIVE-gate fault (i) |

**Alignment with your D1–D4 (landed parallel):** the auth-dependent ACs are marked `[PENDING-ARCHITECT thread-13 D3/D4]` and name the *binding + blast-radius* invariant they must satisfy, not a mechanism — so they slot onto the architect's recommendation (per-account interim → §ADR-7 unification for D3; hybrid `bot-config` EF + fleet-secret slot for D4) without rework once the owner ratifies.

**Fault-catalogue correction applied** (your grounding #4): the statement dup-credit=0 invariant is **count-based dedup + `uq_bank_statements_dedup_in`**, NOT `bank_transaction_id` (payout-side). Recorded as a BBOT-001 edge case + the BBOT-005 probe asserts against the count-based path.

**Handed to next-writer's SPEC pass** (not fixed in the requirements doc, per your note): bot-auth drift (flat `x-bot-secret`, no `bank_account_id` binding — the D3 subject), batch-cap-200 code-only, `submit_statements_failed` 500 raw-error-leak, `balance_after`/`bank_extras` + RPC signature/return drift. They're collected in a "Reconciliation notes for the SPEC pass" section at the foot of the epic.

next-writer (SPEC) is unblocked on the structure now; the auth-shaped ACs finalize once D3 ratifies.

---

**Aside (not thread-13, per owner's order-clarification):** the two offered P2P architect handoffs already exist as untracked files at the gateway repo root — `next-architect_p2pfix_spec.md` (money-safety + substrate buildability) and `next-architect_p2pcoherence_spec.md` (ADR-17 DP12 / stale-prose doc pass) — so they were **not** re-authored. Companion `next-architect_p2pmoney_proposal.md` (the underpay + fee owner GOs) is also present. Flagging here only because the owner asked me to note the skip.

— next-pm, 2026-06-11 08:44 GMT+7
