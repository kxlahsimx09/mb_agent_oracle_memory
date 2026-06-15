ψ ENVELOPE — TO: orchestrator (LIVE-gate dispatch) + next-pm · CC: next-investigator (A-1) · FROM: next-live-tester · 2026-06-13 (GMT+7)

SUBJECT: D-1 + A-3 deployed-stack reruns DONE on staging — D-1 🟢 · A6 strict 🟢 (P8/SV7a closed) · X7 4/5 substantive-🟢 (x7_iii env-inconclusive, NOT code) · feeds AUTH seal + DEPOSIT L5; A-3→next-investigator A-1

=== STACK / LIVE-STATE (re-confirmed first, per dispatch) ===
Target = LIVE staging `sinuwgsqqyqzlpaavimf` @ git `0e43a5c` (= main HEAD; Phase-B #482 + the #483/#484 no-change re-stamps). mig **158=158**, EF **33/33** (per #484 deploy evidence). Read-only confirm before any run: gotrue/ts_deposits 200 · role_permissions=**48** (A4 LIVE → A6 runs STRICT) · admin_approve_paid present (≠404) · mdr_owner wallet count=1 · auth_lockout_config 200.
FOOTPRINT of this run = **0** — all probes self-clean (cleanupDeposits / gotrue user delete / role_permissions DELETE); soft_window restored 00:15:00 (verified). 7 stale `authtest.local` users exist but predate me (2026-06-09→11; `probe-*`/`simlive10-*`/`p2probe-*` — look like intentional fixtures) — non-blocking observation, left untouched (not mine).

=== D-1 — deposit admin-approve RM-conservation (standing probe #467) → 🟢 GREEN 2/2 ===
- rm_admin_approve_conservation: gross 1000 = clientΔ982 + ΣpartnerΔ10 + mdr_ownerΔ8, **Δ=0.00**; exactly 1 mdr_residual to mdr_owner (the #438 fix surface).
- rm_admin_approve_overalloc_rejected: partner pcts>fee → P0001 reject + whole rollback, money unmoved.
- evidence: evidence/integration-deposit-rm-1781354206155-0e43a5c5.json
- FEEDS DEPOSIT L5.

=== A-3a — A6 exposure (STRICT, A4 deployed) → 🟢 GREEN (9 PASS / 0 FAIL / 1 PENDING) ===
- DISPATCH EMPHASIS — P8 anon-wire CLOSED both semantics: sv7a soft-zero category EMPTY post-SV9 #425 (asserted explicitly, not vacuous green); sv7b 5 tables {client, merchant_config, bank_statements, callback_queue, callback_attempts} → 401/42501 hard-deny.
- m2 AAL1→0 / AAL2→7 · m3 no-:view→0 · W1 perm-change immediate (0→7→0, SAME token) · m3-write direct 403/42501 · m5 re-parent DB-fresh boundary (A's rows absent) · m3-realtime AAL1→0.
- p1_m1 = PENDING (strict m1-block needs A3 + a CF custom-domain front; raw-origin staging has neither — witness PASS today, strict recorded PENDING; PENDING never fails). This is the documented expected state for a non-CF stack, NOT a gap in A4.
- evidence: evidence/integration-auth-exposure-1781354336179-0e43a5c5.json

=== A-3b — X7 negatives → 4/5 substantive de-biased negatives 🟢 GREEN ===
- x7_i aal-less token parity (adminAuth + gotrueAuth BOTH 401) · x7_ii X1 wrong-TOTP×6 → account locked + counter bumped · x7_iv X3b spoofed XFF/CF-IP → ALL 403 ip_blocked (no allowlist bypass) · x7_v LK2 soft-window auto-expiry (external 401→200 within window, admin hard-lock 401→401 persists).
- DELTA: advanced **3/5 → 4/5** vs the prior qnccph run (git 56f5270b) — x7_v now PASSES on Phase-B (the F3 soft-window calibration de-flake landed). Improvement attributable to the deployed code.
- ⚠️ x7_iii (X2 gotrue-429 counter-integrity) = **INCONCLUSIVE(env)**, scored binary-RED by the runner (X7 has no tri-state, unlike A6's PENDING). Hosted gotrue does NOT emit 429 for the EF's internal sign-in at achievable volume (35 sequential bursts → no 429; parallel → 500 not 429). Non-green on **EVERY** run across BOTH qnccph and staging → this is a STRUCTURAL property of hosted gotrue, NOT a deployed-code regression. The 4 wire-exercisable de-biased negatives prove the X1/X3b/LK2 fixes; the X2 429-branch is simply unreachable to exercise live.
- evidence: evidence/integration-auth-x7-1781354238576-0e43a5c5.json

=== ROUTED (non-blocking) ===
1. [→ brew-ops / orchestrator] x7_iii closure path: lower the gotrue sign-in rate limit on a stack so the 429 branch is reachable over the wire, OR accept an EF-level unit test of isRateLimited() as the X2 429 witness. Until then x7_iii stays INCONCLUSIVE(env) and the X7 runner exits 1 on it — recommend the gate treat x7_iii as a known env-coverage carve-out (like A6's PENDING discipline), not a code RED. Consider giving run-auth-x7 a tri-state so an env-inconclusive leg doesn't paint the whole run RED.
2. [observation] 7 stale authtest.local users on staging (pre-2026-06-13) — sweep if undesired; some appear to be intentional fixtures (simlive10-*).

=== VERDICT ===
D-1 🟢 GREEN · A6 strict 🟢 GREEN (SV7a/SV7b anon-wire CLOSED — dispatch ask satisfied) · X7 substantive negatives 🟢 GREEN with one documented env-coverage carve-out (x7_iii, not code). The deployed-code gates that ARE exercisable over the wire are all green. Final gate verdict is the orchestrator's to weigh with this evidence.

Evidence committed + reviewable: **PR #487** (test/livegate-d1-a3-rerun-20260613, off main @ 0e43a5c; 3 evidence JSONs). Not self-merged — for reviewer/owner.
