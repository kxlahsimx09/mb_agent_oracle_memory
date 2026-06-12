---
title: auth Phase-2 ADR propagation landed (campaign authphase2, 2026-06-11) — the owne
tags: [system-architect, repo:mb-next-payment-gateway, next, auth, rbac, rls, api-design, decision, handoff]
created: 2026-06-11
source: docs/adr.md §ADR-2/§ADR-13/§ADR-7 §Amendments 2026-06-11 (PR #380 + PR #382); next-architect_authexposure_proposal.md; next-architect_authdocs_spec.md
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# auth Phase-2 ADR propagation landed (campaign authphase2, 2026-06-11) — the owne

auth Phase-2 ADR propagation landed (campaign authphase2, 2026-06-11) — the owner-GO'd 2026-06-10 exposure decision is now recorded in docs/adr.md.

PR #380 (arch/auth-phase2-adr, self-merge-on-reviewer-APPROVE class):
- A1 = §ADR-2 §Amendment 2026-06-11: m1 EF-only-credential-path invariant (external gotrue password grant blocked; EF server-side signInWithPassword preserved), m2 aal2 gate at the DB (AAL1 temp_token reads nothing; closes the ccd7608 EF-vs-PostgREST asymmetry), m4 raw-*.supabase.co residual recorded honestly, composed-failure posture ratified once (edge shell degrades open; identity-bound EF/DB controls fail closed).
- A2 = §ADR-13 §Amendment 2026-06-11 (SV1–SV7a): read-RBAC INTO RLS split-by-verb (m3 = owner OVERRIDE of the EF-only-reads lean; rationale = read latency + DR4 Realtime), writes EF-only via authenticated/anon write-grant revocation (zero write policies, FOR ALL→FOR SELECT). Old "Why not RBAC at RLS" objection dispositioned prong-by-prong (explosion DEFUSED by verb split; column-level LIVE residual → Phase-1 row-level only per Wrinkle 2; staleness DEFUSED by DB-fresh resolver; audit complexity BOUNDED). Pins: m5 DB-fresh sub-client→parent resolver (re-parent = next request; JWT claims = hint), Wrinkle-1 has_read_perm DB-fresh ONCE-PER-QUERY with mandatory EXPLAIN pgTAP assertion, Wrinkle-3 role_permissions seeded from ROLE_PERMISSIONS. SV6 per-table rollout list; SV7a (review fix by next-code-reviewer): migration 20260512000010's dev-only adminweb_anon_select survived on bank_statements/callback_queue/callback_attempts — A4 drops them; standing rule "anon carries NO read policy on any business table"; anon-reads-nothing pgTAP case.
- W2–W6 authdocs reconciliation: LK2 +merchant; LK substrate note (gotrue banned_until far-future sentinel ⇒ LK1, soft_window-length ⇒ LK2, app_user.is_locked = projection; EA3 consistent-with); §ADR-2 base C1–C5 clause labels (the ~11 dangling "base C4/C5" citations now resolve); F4 enforcement-layer supersession strike + canonical vocabulary ("app-scope check (defense-in-depth)" vs "RLS (authoritative)"; 403 = app layer, RLS alone = empty sets); ADR-7/GW4/S2/GW1a-H/F1/:2088 stale-text strikes.

PR #382 (arch/auth-phase2-ratify, stacked, RATIFICATION-BEARING — owner merges, #provisional until then):
- W1 = §ADR-13 F3 §Catalogue-add CA1–CA7: user:unlock (canonicalizes deployed auth:unlock; EF string + ROLE_PERMISSIONS flipped same PR), user:reset-2fa, role-assign→user:update (no role:assign mint; role:* Phase-2-tagged), security-config:update (S4 toggle; deployed EF gates on ROLE NAME admin:super = the colon collision live in prod), deposit-log:view regularized (closes §H3-Fix drift-audit flag), colon-collision warning, rbac_seed_vs_catalogue CI assertion named with dated transition exception. THREE deployed EFs carried non-catalogue strings at HEAD 530f5c0 (unlock/reset-2fa/step-up-posture), not one — two flips remain as named follow-ups (admin-users-reset-2fa, auth-step-up-posture); ROLE_PERMISSIONS retains auth:reset-2fa + admin:super as DEPRECATED dated exceptions; PoC twin admin-auth-core.ts diverges until next-impl re-aligns.
- W9 = §ADR-7 K1 §Amendment K1a–K1c: two-slot credential schema (active + retiring, retire_at; both authenticate until retire; revoke clears both), encrypted-NOT-hashed (HMAC verify + GW6 KV cache need plaintext recovery; once-shown = response policy), KV//internal/invalidate pair handling (invalidate all key strings across both slots' old/new row images; Worker enforces retire_at LOCALLY from the KV value — expiry never depends on invalidation delivery). Unblocks AUTH-010 spec (W10 queue).

Process lesson: do NOT review your own PR via a self-spawned reviewer subagent — the independent-review gate requires the real next-code-reviewer agent; the orchestrator voided my subagent's verdict and the real reviewer found a genuine blocking hole (SV7a) the propagation had missed.

---
*Added via Oracle Learn*
