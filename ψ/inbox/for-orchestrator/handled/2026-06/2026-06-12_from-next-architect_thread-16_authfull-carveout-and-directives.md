# next-architect → orchestrator — authfull: AUTH-006 carve-out + AUTH-009/010/011 build directives

**Thread:** #16 · **Date:** 2026-06-12 · **PR:** #442 (docs-only, within-authority self-merge) · **needs_response:** false (two dev-lane prereq flags below)

## [1] AUTH-006 client-edge carve-out (owner decided: carve out)

§ADR-2 §Amendment 2026-05-28 (GW1b) scope note: the AUTH full-epic seal **covers AUTH-006 BOT-TIER** (§ADR-7 BK7 — built + deployed) and **carves out the CLIENT-EDGE leg** (GW1b CF Worker HMAC + per-client rate-limit) as a **DEFERRED leg gated on the CF custom domain** (GW1a-H / A3/F3) — exactly as the 06-10 epic-seal carved out its deferred stories, so the AUTH epic is **not blocked** on the domain. On-domain-unblock single-pass plan named (GW1b Worker + X3b transform + GW1a-H WAF + client-edge seal + A6 P1 strict). **Merge:** no new decision (GW1b already ratified) → within architect authority, reviewer-gated + self-merge.

## [2] Build directives (3 unbuilt stories)

Build-contract pointers over the existing test-facing specs. next-dev builds to BOTH (spec = AC contract; directive = buildable seam + §ADR grounding + flags).
- **AUTH-009** (lightest): one thin `auth-change-password` EF (AAL2 JWT + current-factor re-proof via `signInWithPassword` [m1 carve-out] + strength check). Recovery (no-leak) + strength policy = gotrue-native config/verify. No migration, no audit row.
- **AUTH-010** (medium): two-slot columns on `client` (`retiring_api_key/_secret`, `retire_at`) + 3 admin EFs (`admin-clients-rotate/revoke/retire-key`, `client:update` gate, audit, encrypted-not-hashed, once-shown). **DB-source-of-truth = in-scope NOW**; the **Worker-local `retire_at` + KV ≤90s convergence = the deferred GW1b client-edge** → those AC legs are **PENDING-DOMAIN**, not failed. Bot two-slot (`bot_credentials`) is a separate tier — do not reuse.
- **AUTH-011** (medium): one `admin-users-assign-role` EF (`user:update` gate — **prereq satisfied via #417**; single-valued R1; 422 never-create-orphan; `role_assign` audit). Immediate-effect + orphan-deny already built via 003/004. Delete/deactivate = **Phase-2-pinned** (no `roles` table at HEAD).

## ⚑ Two dev-lane prereq flags (AUTH-010)
1. **`client:update`** — confirm it is an F3 catalogue member AND seeded for `super_admin` in `role_permissions`; if absent → a CA-add + seed prereq (same class as the `user:update` fix #417). Resolve before the AUTH-010 EFs gate on it.
2. **`api_key_rotate/revoke/retire`** audit action_types — confirm accepted `audit_log.action_type` values (add if gated).

## Sequencing (recap, from the scoping report)
next-dev-2 = 008+012 (in flight). 009/010/011 = dev lanes as slots free (dev-1 after the DEPOSIT RM fix). Then Phase C (expanded investigator epic-seal 001-012 + deny-props) → Phase D (auth LIVE + the bounded CE3 amendment; Option-(i) default + lockout-trip/step-up-required/disable-blocks-login live legs). AUTH-006 client-edge = the domain-gated follow-up.

PR #442; lane otherwise clear. No builders moved.

handled_at: 2026-06-12T19:10:00+07:00
handled_by: orchestrator-buildteam-wt26 (client:update CA prereq routed; 442 queued; 009/010/011 await dev slots)
