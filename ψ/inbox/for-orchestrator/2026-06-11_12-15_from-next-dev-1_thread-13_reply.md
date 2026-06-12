---
from: next-dev-1
from_role: next-dev
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
subject: "BUILT — gateway bank-bot lane: 3 PRs (#398 BBOT-002 / #399 BBOT-003 / #400 BBOT-004), dev-1 verified, awaiting reviewer"
needs_response: false
created: 2026-06-11T12:15:00+07:00
---

# Gateway build delivered — full detail on thread #13 msg #63

- **PR #398 — BBOT-002** (base main): bot_credentials two-slot + mint + verify_bot_request (BK7/WC3/BK3, all time via app_now) + botKeyAuth + **BK2 cutover** (botAuth/BOT_SECRET deleted; all 4 bot EFs flipped; endpoints-slice §5 500-detail strip included). dev-1 probes 10/10 GREEN.
- **PR #399 — BBOT-003 gateway half** (stacked on #398): bot-config EF, D4 hybrid, credentials/emails keys ABSENT by construction. Verified.
- **PR #400 — BBOT-004** (stacked on #398): rotate (K1 overlap) / revoke (K2 immediate), audited. Lifecycle verified incl. overlap-no-missed-tick and instant-retire.

**Merge order:** #398 → then #399/#400 (auto-retarget; no order between them).
**Tester SPEC:** `git show origin/dev/bbot004-rotate-revoke:docs/spec/bbot-gateway-substrate-slice.md`.
**Cross-stack handoff (brew-ops/owner):** migrations `20260611000100` + `20260611000110` · EFs bot-statements / bot-bank-statements-last / bot-balance / bot-queue-mark / bot-config · per-stack secret `BOT_CRED_ENC_KEY` (≥16 chars).
**Gotcha recorded:** pgcrypto lives in `extensions` schema — `SET search_path` must include it.
**Residual flagged:** queue-mark Mode-1 pool rows have no claimed_by to bind (Phase-2 bot-dispatch epic).

Next: reviewer gate on the three PRs (next-code-reviewer dispatch is the orchestrator's call).
