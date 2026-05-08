---
title: poc-ready: §ADR-2 Tier-3 PoC falsified — 6 of 13 claims green via Supabase local
tags: [implementation-architect, repo:mb-next-payment-gateway, next, auth, adr-2, poc-ready, supabase-auth, rls, audit-log, bun-test, tier-3, tier-3-override, mutation-test, edge-function, rls-policy, gotrue, vitest-style, pattern-observation]
created: 2026-05-07
source: poc/2/ (commit pending); tests pass: 17/17 / 45 expect / 1.2s; mutations Mut-A + Mut-B both red as expected
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# poc-ready: §ADR-2 Tier-3 PoC falsified — 6 of 13 claims green via Supabase local

poc-ready: §ADR-2 Tier-3 PoC falsified — 6 of 13 claims green via Supabase local stack; 2 mutations confirm pin-to-claim

Tier-3 §ADR-2 PoC executed end-to-end via local Supabase stack (CLI 2.54.11 + Docker/orbstack + bun 1.3.12). Override of SKILL.md §"Cheap PoC criterion" Tier-3 day-1 defer was justified — toolchain + auth substrate cheaper than expected; cost-benefit favored running over deferring.

## Falsified claims (6/13)

- C1 unified login endpoint × 4 entities (admin/merchant/client/partner via single signInWithPassword)
- C2 entity_type via raw_app_meta_data → JWT app_metadata × 4 entities (decoded JWT verified)
- C3 RLS Layer-1 isolation × 3 (merchant own / client own / admin all-cross-entity)
- C7 custom login EF wraps profile × 3 (merchant/client/partner)
- C9 strict 1:1 email / duplicate-signup safety × 1
- C11 audit_log row per login × 2 (success + failure both write 1 row)

Total: 17 sub-tests / 17 pass / 45 expect calls / 1.2s wall.

## Mutation rigor (W1 Step 5e)

- Mut-A: `if (false) await service.from("audit_log").insert(...)` in EF → C11 × 2 red as expected; restore → green.
- Mut-B: `DROP POLICY; CREATE POLICY ... USING (true)` on transactions → C3 merchant + client red as expected (admin still green per CASE shape); restore → green.

Both mutations correctly fail tests → tests pin claim, not implementation. No 5d (implementation-grounded) or 5e (mutation-passes-test) failures.

## POC_GAPs (deferred, marked in poc/2/README.md)

- C4 DB-fresh RBAC — needs roles + EF middleware + per-request DB lookup; defer to Phase-2 RBAC PoC
- C5 gotrue rate-limit — threshold assertion needs perf harness or config tuning
- C6 refresh-token — gotrue native; tests would test gotrue not ADR
- C8 MFA TOTP — first-login enroll + RFC-6238 code gen + super_admin reset RPC; substantial
- C10 P95 latency budget (≤800ms warm / ≤3s cold) — needs harness
- C12 IP allowlist — middleware + allowed_ips inet[] + spoofing tests
- C13 OUT-OF-SCOPE per G6-D — no test owned by §ADR-2

## Stack shape

- supabase init under poc/2/supabase/ (separate from production root supabase/)
- Migration: 5 profile tables (admin/merchant/client/partner_profiles + transactions test surface) + audit_log + RLS policy
- EF: poc/2/supabase/functions/auth-login/index.ts — gotrue.signInWithPassword + auth.mfa.list_factors omitted (out of scope this pass) + entity-profile SELECT + audit_log row write, single-RT shape
- Seed: bun src/seed.ts via service-role admin API, sets app_metadata.entity_type at create time
- Tests: bun test tests/adr2.spec.ts — Supabase JS client + raw fetch for EF calls
- Ports: 64321/64322/64323 (avoided 54xxx collision with sibling project on same host)

## Pattern observations

- **Tier-3 override cheap when toolchain present.** SKILL.md "Cheap PoC criterion" defers Tier-3 to week 2-3 by default — but when host has supabase CLI + Docker + JS runtime, the marginal cost of `supabase start + seed + bun test` is ~30s warm spin-up + ~200ms per test. Cheaper than expected. **Heuristic candidate:** check toolchain first; if all three present, override Tier-3 defer for foundational claims (C1/C2/C3 class). MFA/RBAC-rich claims (C4/C8) still warrant defer.
- **Mutation rigor at the substrate boundary.** Mut-A (TS code mutation) + Mut-B (SQL policy mutation) cover both layers ADR-2 spans. Pattern: when ADR straddles substrate layers (TS EF + Postgres RLS), one mutation per layer is the minimum rigor target.
- **EF runtime hot-reload not always reliable.** First C11 mutation appeared to silently pass — required full `pkill + supabase functions serve` restart. Per_worker policy claims hot reload but worker may cache compiled bundle. **Heuristic:** when mutation result is suspiciously green, force full EF restart before classifying as 5e.
- **Dual-key support (legacy anon/service_role + new publishable/secret).** CLI 2.54.11 emits both formats; legacy keys still work for JS SDK. Worth noting for impl pass: production project may want to standardize on new format only.

## Cross-refs

- ADR baseline: docs/adr.md §ADR-2 + Auth Surface Completion subsection (commit e0a5698 on architect's worktree)
- Predecessor learnings: 2026-05-07_poc-drift-adr-2-six-silent-on-load-bearing-cas (W2 round 1 drift); 2026-05-07_poc-drift-closed-adr-2-g1g6-w2-round-1-single (W2 close); 2026-04-27_incident-2fa-enforcement-on-login-1d746ee-pr (G1 #current precedent — still load-bearing for C8 POC_GAP closure)
- Promote-to-dev trigger (Workflow 3, TBD): when next-dev forks poc/2/supabase/ contents into production root supabase/, anchor [POC_PROMOTED:<commit-hash>] per SKILL.md P-001.

---
*Added via Oracle Learn*
