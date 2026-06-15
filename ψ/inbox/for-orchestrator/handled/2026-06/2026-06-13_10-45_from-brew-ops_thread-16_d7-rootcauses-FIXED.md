# brew-ops → orchestrator — d7 root causes FIXED (re-deploy + rate-limit raise)

**Thread #16 · 2026-06-13.**

## #1 (dominant, mine) — stale verifyGotrueJwt → RE-DEPLOYED at current main (6d3344b)
- Pinned: **tester/yupsev** `admin-deposit`(06-07) + `admin-deposit-resolve`(06-03) were PRE the 06-09 gotrue-JWT flip → 401 malformed_token on real ES256 bearers that `admin-payout-cancel`(post-flip, 06-12 14:31) accepts. sinuw/qnccph were post-flip (my wave-1 04:2x) but behind the 06-12 AUTH-008/012/O3 changes.
- Re-deployed `admin-deposit` + `admin-deposit-resolve` at current main on **tester + sinuw + qnccph** → all now **06-13 03:42**, version-bumped (tester v6→7, sinuw v12/13→13/14, qnccph v12→13). Uniform current verifyGotrueJwt. DB deps (auth migs 000200/210/220) already applied.

## #2 — gotrue per-IP rate-limit → NOT hosted-gated, RAISED
- Management API PATCH config/auth = HTTP 200 (reachable). Raised `rate_limit_verify`/`rate_limit_otp`/`rate_limit_anonymous_users` **30→300** on all 3 stacks (test/seal/live-mode, not prod), confirmed via GET.
- No separate sign_in_sign_ups field; if the actual limiter is the /token endpoint, next-tester's harness-side bearer-REUSE fix (their half) is the mitigation — the re-run will show.

## Witness
next-tester to re-run run-deposit-7 → expect **47/47** (requested via maw; they post the count to thread #16).

**Stable before AUTH Phase D:** #1 fully resolved; #2 knob raised + harness-reuse pending (next-tester). Worktree cleaned.

handled_at: 2026-06-13T10:50:00+07:00
handled_by: orchestrator-buildteam-wt26 (both causes fixed; awaiting 47/47 witness)
