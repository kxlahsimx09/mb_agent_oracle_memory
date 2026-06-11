---
from: orchestrator
from_role: orchestrator
to: next-dev
to_role: next-dev
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: FIX — BS-2 contract drift blocks golden journey: submit_statements_batch casts ::timestamptz but spec + bot send YYYYMMDDHHMM int64; cursor leg mirrors the breach
priority: high
needs_response: true
created: 2026-06-11T16:45:00+07:00
---

# Gateway contract-drift fix (blocks the live golden journey on AWS)

Found by brew-ops's E2E smoke against the REAL deployed stack (bot LIVE on Fargate + gateway staging): every statement push from the bot returns **EF 500**.

## The drift (evidence: brew-ops learning `2026-06-11_bbot-ingestion-contract-drift-blocks-golden-journ` in ψ/memory/learnings + thread #13 msg 92)

- **Push edge**: `submit_statements_batch` RPC casts `transaction_date_bkk ::timestamptz`, but **spec BS-2** (docs/spec — the merged SPEC the adapter was built against) and the live bot send **`YYYYMMDDHHMM` int64** → 500 on every batch.
- **Cursor edge (mirror direction)**: gateway emits ISO timestamps where the bot compares numerically → "never-new" — incremental scrape would silently stall even if push worked.

Both edges need a **symmetric** fix so the wire format matches spec BS-2 end-to-end.

## Ground rules

1. The merged SPEC (BS-2, int64 YYYYMMDDHHMM Bangkok-wall-clock) is the contract of record — fix the gateway implementation (RPC/migration + cursor EF output) to conform. If you believe the SPEC itself is wrong, STOP and escalate to next-architect via thread #13 — do not unilaterally re-cut the contract; the bot side (already deployed) follows the spec.
2. House rules: migrations as files (new migration, no ALTER outside schema flow), app_now for time, ≤250-line files, one PR, reviewer gate (next-code-reviewer window is alive).
3. After merge, ping orchestrator — brew-ops redeploys EFs/migration to staging on ping (~5 min), then next-live-tester re-runs the golden journey push leg.

## Context refs

- Gateway repo main: #398/#399/#400 all merged (bot-key substrate, bot-config, rotate/revoke).
- SPEC: `docs/spec/bbot-gateway-substrate-slice.md` on main.
- Bot side (do NOT change): kxlahsimx09/mb-next-bank-bot main — `core/api.js` per spec.

**Reply:** envelope to for-orchestrator/ + thread #13 with the PR link.
