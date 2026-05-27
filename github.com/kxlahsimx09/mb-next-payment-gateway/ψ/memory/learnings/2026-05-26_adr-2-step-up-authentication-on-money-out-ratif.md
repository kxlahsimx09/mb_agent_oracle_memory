---
title: §ADR-2 Step-Up Authentication on Money-Out — RATIFIED #decision (thread #236, ca
tags: [system-architect, repo:mb-next-payment-gateway, next, auth, totp, step-up, security, decision, adr-2, thread-236, money-out, fail-closed]
created: 2026-05-26
source: docs/adr.md §ADR-2 §Amendment 2026-05-26 + thread #236 user ratification + mobiz helpers/totp_step_up.go@815418e
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# §ADR-2 Step-Up Authentication on Money-Out — RATIFIED #decision (thread #236, ca

§ADR-2 Step-Up Authentication on Money-Out — RATIFIED #decision (thread #236, campaign #234), landed 2026-05-26.

AUTH-007 step-up control bound as a §ADR-2 amendment after user ratification (the Q3 escalation from consult #233). §ADR-2 G1-D ratifies LOGIN 2FA only; step-up is the distinct action-time control. Mobiz substrate = helpers/totp_step_up.go@815418e (purpose-scoped, replay-block, lockout, fail-open — was decision-required, never ratified for current).

DECISIONS:
- S1 — step-up is distinct from login 2FA (identity-at-login vs presence-at-action); same authenticator seed, different question.
- S2 — SCOPE = admin-initiated money-out actions ONLY: deposit refund · admin-created Direct-Transfer · admin-created Settlement + Settlement approve · admin payout override/confirm-completed/cancel (§ADR-4d money-state-forcing). NOT machine/client API (clients use API-Key + Idempotency-Key §ADR-7/§ADR-11; no human present to produce a fresh code). User: "CONFIRMED as recommended — admin money-out only … NOT machine/client API".
- S3 — replay + lockout invariant: code single-use PER PURPOSE; lockout after repeated failures; same code MAY be accepted for two distinct purposes within its window (matches mobiz). Substrate/TTL/threshold = impl pass.
- S4 — POSTURE = FAIL-CLOSED by default (deliberate divergence from mobiz fail-open) + a SUPER-ADMIN-only runtime toggle to FAIL-OPEN, effective IMMEDIATELY (no redeploy), as the operational escape hatch for an OTP/auth-substrate outage. Toggle change is super-admin-only + audited (audit_log §ADR-13 D2). User: "FAIL-CLOSED by default, BUT provide a config toggle to fail-open that takes effect IMMEDIATELY … The toggle itself must be SUPER-ADMIN-only".

DEFERRED (impl/design): replay/lockout substrate on Supabase (no Redis assumed); TTL/threshold; the toggle config-store + immediate-effect propagation (must be read live, not deploy-cached); per-action purpose-tag catalog; admin UI mechanics; step-up for non-money-out privileged actions.

PROCESS: security-sensitive → correctly halted for human ratification (charter §9). Architect filed a recommendation (prior pass), user ratified-with-refinement (added fail-closed + super-admin immediate-effect toggle), this pass binds the refined form with the verbatim quotes in §Resolved questions — no marker-flip needed.

next-writer handoff: promote AUTH-007 S4 → S2; drop [AWAITING_THREAD:233]; ACs already describe step-up shape; add the fail-closed-default + super-admin-toggle posture as a note.

Recorded in docs/adr.md §ADR-2 §Amendment 2026-05-26 + §Revision log (PR on branch architect/adr2-stepup-thread236).

---
*Added via Oracle Learn*
