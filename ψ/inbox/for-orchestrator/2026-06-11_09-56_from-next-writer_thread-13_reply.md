---
from: next-writer
from_role: next-product-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: Lane C DONE — integration SPEC PR #391 (mb-next-bank-bot ↔ gateway adapter, Phase-1 statements-only; auth ACs bound to BK7 per PR #389 ratification-pending)
priority: high
needs_response: false
created: 2026-06-11T09:56:00+07:00
in_reply_to: 2026-06-11_10-45_from-orchestrator_thread-13_dispatch.md
---

# Lane C delivered — SPEC PR #391

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/391 (branch `spec/bbot-adapter-phase1`, docs-only, base `main`). Full content narrative on **thread #13 msg #44**.

Deliverable = two house-layout spec slices (≤250 lines each) + word-level `cross-repo.md` refresh:

- `docs/spec/bbot-adapter-auth-slice.md` — BK7 wire contract bot-side: headers + both signing canonicals, 401×4/403 taxonomy + fail-closed, K1a two-slot rotation tolerance, ONE `authHeader()` injector, env wiring (`BOT_SECRET` retired → `BOT_KEY`/`BOT_KEY_SECRET` from the fleet-secret slot). Auth ACs marked **"per §ADR-7 §Amendment 2026-06-11 (PR #389, ratification pending)"** per the dispatch; epic BBOT-002/004 `[PENDING-ARCHITECT D3]` markers resolved to BK1/BK3/BK4/BK5 (traceability table §7).
- `docs/spec/bbot-adapter-endpoints-slice.md` — the 3 Phase-1 touchpoints (cursor direction-aware I-derived · `POST bot-statements` with **BS-5 ≤200 cap regularized into a binding AC** + **500 raw-detail passthrough spec'd down** · `bot-config` per **D4 hybrid**, creds-keys-absent invariant). Dedup framing with correct names (count-based SOLE gate; `bank_transaction_id` payout-only; dropped `uq_` index not cited). I-no-retry. `PHASE2_NOT_PORTED` fail-loud stubs for all 11 legacy methods. §8 reconciliation ledger dispositions every architect flag.
- `docs/requirements/cross-repo.md` — stale service-role-JWT identity rows realized as the §ADR-7 bot-tier key (BK1/BK5/BK6); spec pair back-linked.

**One open pin (non-blocking, flagged in-spec):** BK7 leaves "key string doubles as HMAC secret vs paired secret" unresolved; the SPEC absorbs either behind the injector + two slot fields. One architect line on thread #13 hard-pins it if wanted.

**Downstream:** Lane 5 (nextbot-dev) + Lanes 1–3 (next-dev) + next-tester consume the slices; next-pm patches the epic markers post-#389-merge. Dispatch envelope archived to `for-next-writer/handled/` (§11d).

— next-writer, 2026-06-11 09:56 GMT+7
