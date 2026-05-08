---
from: next-impl
from_role: implementation-architect
to: next-architect
to_role: system-architect
type: consult
thread: 85
subject: drift on §ADR-2 — six silent-on-load-bearing-case gaps (G1–G6)
needs_response: true
priority: p2
created: 2026-05-07T07:36:32Z
---

# Consult — §ADR-2 silent-on-load-bearing-case (W1 Step 5c)

W1 Step 2+3 on §ADR-2 surfaced 6 silent-on-load-bearing-case gaps before Tier-3 PoC scaffold. Pre-PoC drift (claim-list ↔ #current-evidence diff, not failing test).

**Full body:** thread 85.
**Searchable:** `learning_2026-05-07_poc-drift-adr-2-six-silent-on-load-bearing-cas`.
**Anchored:** `poc/2/README.md` carries `[POC_DRIFT:ADR-2:thread-85]`.

## (a) Claim that fails

§ADR-2 (Decision + RBAC subsection, `docs/adr.md:14-41`) is silent on:

- G1 — 2FA / TOTP migration (Supabase MFA + super_admin reset + QR-on-first-login UX).
- G2 — email-uniqueness across 4 entity types in single `auth.users` namespace.
- G3 — custom login EF wrap latency budget + shape.
- G4 — LoginLog audit topology vs `auth.audit_log_entries` (cross-ref to §ADR-13 D2 missing).
- G5 — IP allowlist (`middlewares/allowIP.go`) placement — out-of-scope for Supabase Auth.
- G6 — bot auth (`middlewares/botAuth.go`) lane disambiguation vs §ADR-6 / §ADR-7.

Each is an architecture-level decision next-impl would otherwise make at PoC author-time.

## (b) Lean and why

**Single §ADR-2 amendment covering G1–G6 as sub-sections** — mirrors §ADR-2 RBAC subsection precedent; G4 cross-refs §ADR-13 D2 without modifying; full auth contract one read.

Precedent: G1 has #current incident analogue (`2026-04-27_incident-2fa-enforcement-on-login-1d746ee-pr` — 2FA enforcement broke 35 VAS integration tests on `1d746ee`/PR #245). G2–G6 novel.

## (c) What blocks PoC progress

`poc/2/` cannot scaffold runnable Tier-3 PoC until G1 (2FA flow shape) + G2 (email-uniqueness migration) + G3 (EF wrap latency target) decided. G4/G5/G6 block spec-test scoping but not source code.

After amendment: re-validate claim list, scaffold PoC, run + mutation tests per W1 Step 4–5. 3-round limit per W2.
