---
title: poc-drift-closed: §ADR-2 G1–G6 W2 round 1 — single-round closure via thread #85,
tags: [implementation-architect, repo:mb-next-payment-gateway, next, auth, adr-2, poc-drift-closed, handoff, drift-closed, single-round-w2-closure, tier-3-deferred, supabase-auth, 2fa, rbac, audit-log, ip-allowlist, drift-closure-instance-5, pattern-observation]
created: 2026-05-07
source: poc/2/README.md (W2 Step 5 close); thread #85 (ratified #decision 2026-05-07); commit e0a5698
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-drift-closed: §ADR-2 G1–G6 W2 round 1 — single-round closure via thread #85,

poc-drift-closed: §ADR-2 G1–G6 W2 round 1 — single-round closure via thread #85, scaffold unblocked

W2 round 1 on §ADR-2 (Auth Surface Completion) closed in single round. Architect ratified all 6 sub-decisions (G1-D..G6-D) without re-drift; G2 reframed within-pass via greenfield premise correction (mobiz data migration → strict 1:1 fresh design). Commit `e0a5698 next-architect: §ADR-2 amendment — Auth Surface Completion (G1–G6)` patches docs/adr.md after RBAC subsection. Rounds 2/3 unused.

## Resolution shape (per gap)

- G1-D — port mobiz first-login QR-in-response shape verbatim into custom login EF; Supabase `auth.mfa` substrate. Two-endpoint preserved (`/auth/login` → `/auth/2fa/verify`). `AdminReset2FA` → `/admin/users/:id/reset-2fa` (super_admin RBAC) → `auth.mfa.admin.unenroll`. Secret persists in `auth.mfa_factors` (matches mobiz invariant).
- G2-D (revised) — strict 1:1 email = entity_type; greenfield premise (no migration); duplicate email → `user_already_registered` 409. Multi-entity model deferred to future §ADR-2a (no driver at launch).
- G3-D — single-RT EF wrap; P95 ≤ 800ms warm / ≤ 3s cold; always-warm keepalive via §ADR-1 cross-ref.
- G4-D — login audit lands `audit_log` (canonical per §ADR-13 D2) inside EF transaction; gotrue's `auth.audit_log_entries` non-canonical (forensic only).
- G5-D — IP allowlist in EF middleware (Layer 0, pre-auth); per-user `allowed_ips inet[] NULL` on entity profile rows. Mismatch → 403 + audit row.
- G6-D — bot auth + non-bot M2M OUT-OF-SCOPE → §ADR-4a §Security boundary + §ADR-6 + §ADR-7.

## Updated falsifiable claim list (C1–C13)

C1–C7 unchanged. C8–C13 added per amendment (see poc/2/README.md). PoC scaffold queued Tier-3 week 2-3 per SKILL.md "Cheap PoC criterion" (Supabase project required).

## Pattern observations

- **Single-round W2 closure** — first instance in repo (per architect note "round 1 of 3 closed; rounds 2/3 unused"). Pattern: when drift report carries (a) clear lean alternative + (b) per-gap mechanism diagnosis + (c) Precedent field with #current incident analogue, architect can ratify without re-drift cycle. Worth elevating as W2 efficiency heuristic.
- **Within-pass premise correction (G2)** — architect self-corrected G2 from migration-cutover framing to greenfield 1:1 within-thread without filing a new drift. Pattern: not all "wrong premise" findings need a drift-report cycle; architect-side correction is permitted within an open thread. Mirrors §ADR-4b B2 within-pass refinement pattern (architect-driven, not drift-driven).
- **Drift-closure-as-decision instance #5** (after §ADR-10 D4 / §ADR-9 D2 / §ADR-11 D1+D5 / §ADR-12 / §ADR-2 G1–G6). When 5 instances accumulate it's a durable architectural rule: drift reports surface gaps that become amendments; the amendment substrate is uniform regardless of which gap surfaced it.
- **Tier-3 ADR with cheap pre-PoC drift** — confirms SKILL.md §"Cheap PoC criterion" Tier-3 defer is correct discipline. Pre-PoC W1 Step 2+3 extraction surfaced 6 architecture gaps without scaffolding a runnable PoC. Cheaper than scaffolding-then-discovering. Worth elevating as Tier-3 default discipline.

## Cross-refs

- thread #85 — full discussion; messages #199 (drift report) + #200/201 (architect baseline) + #202 (G2 within-pass correction) + #203 (ratification).
- learning `2026-05-07_poc-drift-adr-2-six-silent-on-load-bearing-cas` — the original drift report (this learning closes the chain).
- precedent `2026-04-27_incident-2fa-enforcement-on-login-1d746ee-pr` — G1 #current analogue.
- §ADR-13 D2 — G4 cross-ref target.
- §ADR-4a §Security boundary + §ADR-6 + §ADR-7 — G6 cross-ref targets.
- §ADR-1 — G3 EF cold-start consequence cross-ref.
- commit `e0a5698` — amendment patch commit (architect worktree).

## Next

Tier-3 PoC scaffold queued week 2-3 per SKILL.md. Spec tests target C1–C13 wording. Re-drift if any claim cannot hold under execution (W2 round 2).

---
*Added via Oracle Learn*
