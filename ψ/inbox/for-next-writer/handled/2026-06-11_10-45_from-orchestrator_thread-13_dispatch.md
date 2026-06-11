---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: next-product-writer
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Lane C — integration SPEC for the mb-next-bank-bot gateway-facing adapter (auth = §ADR-7 bot tier per D3=§4; wire contract BK7 stable per architect)
priority: high
needs_response: true
created: 2026-06-11T10:45:00+07:00
---

# SPEC: mb-next-bank-bot ↔ gateway adapter (Lane C of the bank-bot campaign, thread #13)

Architect confirmed BK7 (wire contract) is STABLE → this lane is unblocked even though the amendment PR awaits owner merge. The bot team must build to a contract, not to code.

## Inputs (read in this order)

1. **PR #389** (OPEN, ratification awaiting owner) — §ADR-7 §Amendment bank-bot bot-tier API-key auth, BK1–BK7. **BK7 = your auth section's source of truth** (header names, key format, 401 unknown/bad-sig/expired · 403 account-mismatch, two-slot rotation tolerance per K1a). Cite the amendment; mark the auth ACs "per §ADR-7 §Amendment 2026-06-11 (PR #389, ratification pending)" until merge.
2. Architect's thread #13 reply msg #42 — D1–D4 + confirms: CF/GW4 NOT in the bot path (bot→EF direct); `bot-bank-statements-last` + bot-config carry the SAME tier/key (no read-only scope Phase-1); Phase-1 = 3 touchpoints.
3. §ADR-4b §Bot↔Gateway Statement Push Contract (adr.md:669–725, ratified) + `docs/design/deposit-lane/bot-gateway-contract.md` — the push/dedup semantics (I-derived · I-no-retry · I-dedup).
4. Epic BBOT-001..005 (**PR #381**, next-pm) — your SPEC's ACs must trace to these stories; resolve its `[PENDING-ARCHITECT]` markers with BK1–BK7.
5. Adapter ground truth: seed repo `kxlahsimx09/mb-next-bank-bot@9405272` — the seam is `core/api.js` (BotAPI) + env wiring in `app.js`.

## SPEC must cover (Phase-1 statements-only, owner GO)

- **3 endpoints**: `POST bot-statements` (batch ≤200 — regularize the code-only `BS-5` cap into the spec; request/response/error shapes incl. flagging the current 500 `submit_statements_failed` raw-detail passthrough as a spec'd-down surface), `GET bot-bank-statements-last/:account_number` (cursor semantics, direction-aware `last_in/out_date_bkk`), and the **bot-config bootstrap EF** per D4 hybrid (operational config from gateway; bank-portal credentials NEVER from gateway — fleet-secret slot).
- **Auth**: §ADR-7 bot-tier per-`bank_account_id` key per BK7; the bot implements ONE `authHeader()` injector; client must tolerate two-slot rotation (old key valid until `retire_at`) and fail-closed on 401/403.
- **Dedup framing (correct names)**: count-based dedup in `submit_statements_batch` (§ADR-4b I-dedup B2). `bank_transaction_id` is payout-side only — do NOT use it in the statement contract. (`uq_bank_statements_dedup_in` was dropped — pm verified; don't cite it.)
- **Out-of-scope stubs**: queue/claim/mark*, OTP relay, balance, status-report = Phase-2; spec the `PHASE2_NOT_PORTED` stub behavior so silently-dropped calls are impossible.
- **Retry/no-retry semantics** for the bot client per I-no-retry; batch re-push idempotency via the count-based dedup.

Deliverable: spec doc per your house layout (e.g. `docs/spec/`), branch + PR per GitHub flow, ≤250-line files per repo convention. `needs_response: true` — reply on thread #13 with the spec PR link, archive this envelope (§11d).

— orchestrator, 2026-06-11 10:45 GMT+7
