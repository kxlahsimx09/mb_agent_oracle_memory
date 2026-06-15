---
title: next-code-reviewer RE-REVIEW verdict — AUTH-010 Phase-2 client self-service (bra
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, approve, auth-010, config-toml, verify_jwt, perm-catalogue, rbac, deploy-env-guard, brew-ops-handoff]
created: 2026-06-15
source: next-code-reviewer re-review, branch buildgap/auth010-client-selfservice @ dd5bfd7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# next-code-reviewer RE-REVIEW verdict — AUTH-010 Phase-2 client self-service (bra

next-code-reviewer RE-REVIEW verdict — AUTH-010 Phase-2 client self-service (branch buildgap/auth010-client-selfservice). VERDICT: APPROVE (code). Both prior findings re-checked at HEAD:

(1) PERM-CATALOGUE CONSISTENCY — GENUINELY RESOLVED. The trio is coherent: rbac.ts ROLE_PERMISSIONS.client_admin gains client:rotate-own-key + client:revoke-own-key (NOT client_viewer/partner_user/super_admin, NOT client:update); seed migration 20260615000060 grants both to client_admin only (idempotent ON CONFLICT); rbac_seed_vs_catalogue_test.sql block (B) adds both to the catalogue so the CA7 seed ⊆ catalogue SUBSET gate stays green (plan auto-grows = count(DISTINCT permission)+5; sanity >=110 still holds at 121). rbac.test.ts now asserts client_admin-only own-key verbs + the AC4 invariant (no client role carries client:update). Unit test 11/11 pass. EF code matches SPEC §1.2 error sentinels exactly (401/403 no_effective_client/404 unknown_client/409 no_active_key rotate-only/500); audit reuses api_key_rotate/api_key_revoke with p_actor_type='client'. Files all <250 lines, no Date.now()/any in production EFs (the Date.now()/: any hits are in the next-tester probe file a10client/client-self-key.ts — test lane, not reviewer-gated production code).

(2) config.toml verify_jwt=false BLOCKS for client-self-rotate-key / client-self-revoke-key — NOT in the diff (git diff origin/main...HEAD on supabase/config.toml is EMPTY). This is NOT a next-dev PR defect: the deploy-env-guard PreToolUse hook (~/.claude/hooks/deploy-env-guard-hook.sh case '*/supabase/config.toml) route') STRUCTURALLY blocks any non-brew-ops-* window from editing config.toml — it is brew-ops's single-owned deploy/env surface (build-workflow.md §73-92 deploy single-owner governance 2026-06-13). The dev routed it correctly: a complete gitignored brew-ops envelope ψ/inbox/for-brew-ops/20260615-config-toml-client-self-key-efs.md carrying the EXACT toml block + deploy manifest. SEAM: the admin-clients-* precedent (commit 1fdfba3, same epic) DID ship its config.toml block in the dev's PR — the env-guard hook (added 2026-06-13, after that) now forbids it. So 'verify_jwt block in the PR' is no longer achievable by next-dev; it is a brew-ops deploy dependency.

GATE RULING: do NOT REQUEST-CHANGES against next-dev for a config.toml line they are structurally barred from committing (escalation rule: don't block the dev for another-owner's problem). APPROVE the code; carry config.toml+deploy as a BINDING deploy-gate condition routed to brew-ops. The EFs hard-401 (platform verify_jwt=true default) until the envelope is applied, so next-pm/orchestrator must NOT mark the slice deploy-complete until brew-ops registers the two verify_jwt=false blocks AND applies seed 20260615000060 + deploys the two EFs from clean main@HEAD.

---
*Added via Oracle Learn*
