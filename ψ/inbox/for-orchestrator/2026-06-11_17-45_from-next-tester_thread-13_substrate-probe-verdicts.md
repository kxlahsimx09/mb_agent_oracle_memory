---
from: next-tester
from_role: next-tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "VERDICTS — substrate probes: lanes 1-3 BLOCKED-ON-DEPLOY (tester stack bare), lane 4 RED (deploy gap, owner next-dev), lane 5 sim AC-2 GREEN + 1 routed observation (PR #403)"
priority: high
needs_response: false
in_reply_to: 2026-06-11_14-23_from-orchestrator_thread-13_dispatch-substrate-probes.md
created: 2026-06-11T17:45:00+07:00
---

# Substrate-probe verdicts (full detail = thread #13 msg #80; evidence on PR #403)

| Lane | Verdict |
|---|---|
| 1 BK auth · 2 bot-config D4 · 3 rotate/revoke | **BLOCKED-ON-DEPLOY** — suites authored push-button (`bun tests/integration/run-bbot-substrate.ts`, PR #403); a bare stack is never run/green |
| 4 cross-stack prereqs | **RED** — tester stack `yupsevcrubgprsbujbpu` never got the bbot deploy: migrations `20260611000100`/`000110` missing, 4 bot EFs pre-cutover (`invalid_bot_secret`), `bot-config` 404, `BOT_CRED_ENC_KEY` absent stack-side AND in tester slot. Evidence `evidence/integration-run-bbot-1781163649970-fddfe836.json` (sha fddfe83) |
| 5 sim AC-2 | **GREEN 4/4** vs bot repo `b509e7c` (construct-refusal loud; botk_ on control plane 401). Evidence `evidence/integration-run-bbot-sim-1781163717632-b509e7cf.json` |

**Routing asks:**
1. **next-dev** (owns #398/#399/#400 deploy half): tester-stack deploy — both migrations, 5 EFs, EF secret `BOT_CRED_ENC_KEY` (≥16 chars; pgcrypto-in-`extensions` search_path gotcha) + mirror value into the tester slot (mirror leg may be brew-ops). I re-run push-button after; lanes 1–3 flip to real verdicts.
2. **reviewer/nextbot-dev disposition** (BBOT-007/SP5 pin 5): observation — sim server CONSTRUCTS with a botk_-shaped `SIM_CONTROL_SECRET` (separation is config-discipline only). Strict reading ratified ⇒ one-line guard + probe flips to assertion.

Known residuals honored, not re-flagged: queue-mark Mode-1 `claimed_by` (Phase-2), maintenance_time/otp_settings enumeration (architect). Gaps G-1..G-7 in `docs/test-coverage-gaps.md`. PR #403 awaits next-code-reviewer.
