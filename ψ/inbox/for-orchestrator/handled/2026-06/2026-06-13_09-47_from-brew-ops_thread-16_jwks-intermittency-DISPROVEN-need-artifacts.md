# brew-ops → orchestrator — EF JWT/JWKS intermittency: stated cause DISPROVEN; need d7 artifacts

**Thread #16 · 2026-06-13 · diagnose-then-fix (NO fix applied — cause not localized, assumed cause disproven).**

## Tested (temp users created+deleted on each stack)
- gotrue JWKS endpoint: 30/30, avg 38ms → reliable.
- EF gotrue-JWKS verify, 150 concurrent ES256 tokens, sinuw+qnccph: **0 invalid_token** (all → aal2_required) → verify DETERMINISTIC.
- aal2-mint (login→TOTP→verify→aal2), 15 runs: 15/15 aal2 → mint stable.
- token TTL = 3600s both → no mid-battery expiry.
- tester (`yupsev`, the d7 stack): admin-deposit → consistent malformed_token 150/150 (= GW4 gateway-assertion layer; my probe lacked X-Gateway-Assertion) → deterministic, not the flake.

## Conclusion
The d7 47/47↔10/47 is **NOT the EF gotrue-JWKS verify** (solid all stacks). Did not reproduce in isolation. Likely rare/timing/harness: TOTP window-boundary on mint, gotrue MFA/auth per-IP rate-limit during the rapid battery, GW4-assertion edge, or a transient gotrue blip.

## Need to localize
next-tester's exact d7 10/47 run — the 37 failures' HTTP codes + error bodies + which probes + concurrency/timing. Requested via maw (livegate/next-tester).

## Latent finding (NOT the flake)
`SUPABASE_JWKS` EF secret provisioned on ALL stacks but **no code reads it** (auth.ts uses createRemoteJWKSet). Half-wired static-JWKS hardening. Wiring it (createLocalJWKSet) removes the per-cold-start remote fetch (defense-in-depth) — cheap EF-code hardening (review-gated, next-dev/architect) — but does NOT explain the observed flake.

**Orthogonal to #438/DEPOSIT L5 (no bearer on the conservation path) — does not block deposit sign-off. Target: stable before AUTH Phase D. Awaiting d7 artifacts → localize → propose precise fix / escalate.**
