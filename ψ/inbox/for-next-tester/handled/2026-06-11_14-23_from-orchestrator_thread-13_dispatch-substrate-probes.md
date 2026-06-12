---
from: orchestrator
from_role: orchestrator
to: next-tester
to_role: next-tester
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: PROBES — bot-tier gateway substrate (merged #398/#399/#400) per SPEC bbot-gateway-substrate-slice + sim-slice AC-2
priority: high
needs_response: true
created: 2026-06-11T14:23:00+07:00
---

# next-tester — probe the merged bot-tier substrate

All three gateway PRs are MERGED on main after full reviewer gates (thread #13): **#398** (BBOT-002 bot-tier key substrate + `botKeyAuth` cutover, `x-bot-secret` retired), **#399** (BBOT-003 `bot-config` EF, D4-hybrid gateway half), **#400** (BBOT-004 rotate/revoke, §ADR-7 K1 two-slot). Bot repo PR #2 (SCB mock portal) is also merged.

**SPEC (your probe contract):** `docs/spec/bbot-gateway-substrate-slice.md` at gateway main HEAD (landed via #400).

## Probe lanes

1. **Auth substrate (BK-series)** — PAIRED key verify on the 3 bot EFs + bot-config; BK2 cutover negative probe: any `x-bot-secret` path must be dead (401/403, no legacy fallback); BK3 cross-account binding → 403; BK7/WC3 time semantics via `app_now` (no wall-clock).
2. **bot-config D4 (#399)** — operational non-secret fields only; `credentials`/`emails` keys **ABSENT by construction** (absent keys, not empty arrays — endpoints-slice AC-7); balances excluded.
3. **rotate/revoke lifecycle (#400)** — K1 rotate: active→retiring overlap window honored, overlap-no-missed-tick; displace still-live retiring on re-rotate; rotate without live active → `bot_no_active_credential`; K2 revoke: immediate retire, instant 401 on revoked key; audit rows present.
4. **Cross-stack prerequisites** (from next-dev-1 handoff, thread #13 msg #63): migrations `20260611000100` + `20260611000110` applied; per-stack secret `BOT_CRED_ENC_KEY` (≥16 chars) required; **gotcha:** pgcrypto lives in the `extensions` schema — `SET search_path` must include it.
5. **sim-slice AC-2** (routed from reviewer's bot PR #2 verdict): the REAL-BANK deploy posture — bot repo `sim/` server must refuse to construct without `X-Sim-Control-Secret` configured; control secret ≠ `BOT_KEY` (a `botk_…` value must be rejected on the control plane).

dev-1's own probes ran 10/10 GREEN pre-merge — yours are the independent gate. Known residual (NOT yours to fix, just don't flag as new): queue-mark Mode-1 pool rows have no `claimed_by` to bind (Phase-2 bot-dispatch epic).

**Reply:** envelope to `for-orchestrator/` + thread #13, verdict per lane (GREEN/RED + evidence). RED anywhere → name the owning PR/story so I can route the fix.
