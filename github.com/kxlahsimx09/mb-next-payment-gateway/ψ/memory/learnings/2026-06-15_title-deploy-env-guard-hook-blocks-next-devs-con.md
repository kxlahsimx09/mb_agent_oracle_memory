---
title: title: deploy-env-guard hook blocks next-dev's config.toml source edit (verify_j
tags: [config-toml, deploy-env-guard, verify_jwt, edge-function, rbac, auth-010, brew-ops-handoff]
created: 2026-06-15
source: buildgap-fix-auth010 (branch buildgap/auth010-client-selfservice, PR fix-on-review)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: deploy-env-guard hook blocks next-dev's config.toml source edit (verify_j

title: deploy-env-guard hook blocks next-dev's config.toml source edit (verify_jwt blocks for new EFs) — must route to brew-ops, never bypass

AUTH-010 Phase-2 client self-service (branch buildgap/auth010-client-selfservice). The reviewer's blocker was: the two new EFs client-self-rotate-key / client-self-revoke-key lack `[functions.<name>] verify_jwt = false` blocks in supabase/config.toml, so on deploy the platform hard-401s every request BEFORE adminAuth/requirePermission runs. The reviewer finding said "next-dev must add the config.toml lines in this PR; brew-ops applies the deploy."

GOTCHA / SEAM: the deploy-env-guard PreToolUse hook (~/.claude/hooks/deploy-env-guard-hook.sh line 131) matches `*/supabase/config.toml` on Edit/Write/MultiEdit and BLOCKS it for ANY non-brew-ops-* window — it does NOT distinguish "edit config.toml source in a PR branch" (next-dev's legit job) from "deploy/mutate live env". So next-dev STRUCTURALLY CANNOT put the config.toml lines in the PR commit from a non-brew-ops window. The hook's own guidance + AGENTS.md §11a forbid working around it (no sed/echo, no dangerouslyDisableSandbox).

RESOLUTION (the sanctioned path): write a routing envelope to ψ/inbox/for-brew-ops/ (gitignored doorbell) carrying the EXACT toml block + the deploy manifest; brew-ops applies BOTH the config.toml edit and the deploy from clean main@HEAD. The envelope is the deliverable, not a PR commit. For this slice the envelope is ψ/inbox/for-brew-ops/20260615-config-toml-client-self-key-efs.md.

CODE-SIDE VERIFIED SOUND (no amend needed): rbac.ts ROLE_PERMISSIONS + seed 20260615000060 + rbac_seed_vs_catalogue_test.sql block B + rbac.test.ts are coherent for client:rotate-own-key / client:revoke-own-key (client_admin ONLY; NOT client_viewer/super_admin/partner). rbac unit test 11/11 pass. AC4 self-EF-403 (admin/super_admin token → 403 on the self EFs) is ALREADY enforced in code because those tokens carry client:update but NOT the own-key verbs, so requirePermission 403s them. The tester's AC4-coverage + AC1/AC2 gateway-USE-leg + harness-selfcheck 37→61 findings are PROBE-layer (next-tester's lane), not code fixes.

tags:
  - next-dev
  - repo:mb-next-payment-gateway
  - next
  - edge-function
  - config-toml
  - gotcha
  - handoff
  - auth-010

---
*Added via Oracle Learn*
