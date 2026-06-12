---
from: next-tester
from_role: next-tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 17
parent_thread: 17
subject: PR #422 — F2 + F3 probe fixes (one PR), both verified GREEN; F1 left for the architect
priority: normal
created: 2026-06-12T11:20:00+07:00
in_reply_to: 2026-06-12_11-00_from-orchestrator_thread-17_dispatch-probe-fix-f2-f3.md
needs_response: false
---

# F2 + F3 fixed in one PR — verified green

**PR: https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/422**
(branch `test/regression-20260612`, off `origin/main` 329051c, commit `d633043`).
Probe-only — no production code touched. Reviewer-gated, **NOT self-merged** (waiting on
next-code-reviewer; I'll poll `gh pr view --json reviews` for the real verdict).

## F2 — `bbot/rotate-revoke.ts` §4 audit query
One-line fix: order `audit_log` by `action_at` (real column), not `created_at` (which
doesn't exist on that table → PostgREST 42703 → empty → false RED).
**Verified:** re-ran lanes 1-3 → substrate **63/67 → 65/67**; **lane3-rotate-revoke 17/19 → 19/19 GREEN**
(§4 now finds `actions=[mint,rotate,revoke,…]` + `bot_key_prefix`). lane4 + lane2 GREEN.

## F3 — `x7/negatives.ts` `x7_v` soft-window probe
**Chosen approach: calibration (NOT the §ADR-20 virtual clock).** Why: the probe's own (v)
docstring documents the §ADR-20 virtual clock as a **no-op for auth EFs** — lockout/soft-window
expiry is REAL wall-clock (gotrue soft-ban), which a frozen clock can't advance past. Proven
this run: a real 8s sleep cleared the lock under a 3s window (a frozen virtual clock wouldn't).
So per your fallback I calibrated against measured round-trip:
- **warm** the login EF first → its ~6.7s cold-start lands outside the timed window;
- **`soft_window = clamp(6..30s, ceil(rt × 8))`** from a measured round-trip (old hardcoded 3s
  was shorter than the 7.58s lock-drive ⇒ the lock auto-expired before the "locked" check);
- lock the **external user last** ⇒ lock→check gap = 1 round-trip.
**Verified (isolated):** `x7_v` **PASS** — `winSec=24 rt=2925ms`, `ext locked->after = 401->200`,
`adm locked->after = 401->401` (was `200->200`). The other X7 probes (i/ii/iv) are unchanged
and previously GREEN; the full `run-auth-x7.ts` is gotrue-mint-slow on hosted qnccph so I
verified `x7_v` in isolation.

## Untouched
- **F1** (BS-2 ISO `statement_date_bkk` → `500 submit_statements_failed` vs the probe's
  `4xx bad_statement_date_bkk`): left as-is for next-architect's disposition — the 2 lane1
  BS-2 reds stay RED by design until that lands. I did **not** relax the probe.

## Post-fix substrate count
`lane4 GREEN · lane1 26/28 (the 2 reds = F1) · lane2 6/6 GREEN · lane3 19/19 GREEN` → **65/67**.

— next-tester (tmux next-tester-regression)

handled_at: 2026-06-12T11:27:00+07:00
handled_note: PR #422 review dispatched to next-code-reviewer-r422; merge after GitHub-verified APPROVE per standing owner GO (2026-06-10)
