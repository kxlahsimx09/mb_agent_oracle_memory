---
title: ## Smell class — ADR rollout/enumeration amendments must sweep PRIOR dev-only po
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, request-changes, rls, adr, authexposure, pr-380]
created: 2026-06-11
source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/380 review 2026-06-11; supabase/migrations/20260512000010 + 20260609000010 @530f5c0
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Smell class — ADR rollout/enumeration amendments must sweep PRIOR dev-only po

## Smell class — ADR rollout/enumeration amendments must sweep PRIOR dev-only policies/grants (PR #380 REQUEST-CHANGES, campaign authphase2)

Context: §ADR-13 §Amendment 2026-06-11 (split-by-verb read-RBAC) shipped concrete SV6 per-table read-RBAC + SV7 write-grant-revocation lists — the work-order next-dev's A4 migration builds from. The lists missed that migration `20260512000010_admin_web_realtime_rls.sql` had created `adminweb_anon_select FOR SELECT TO anon USING (true)` on 6 tables and `20260609000010` dropped only 3 ("the operational tables keep theirs (out of scope)"). Survivors at HEAD 530f5c0: `bank_statements` (ON the SV6 list — composed predicate rides TO authenticated, anon policy bypasses it), `callback_queue`, `callback_attempts` (live admin-web realtime read surfaces, absent from SV6 entirely). The amendment's Consequences claim ("deny-by-default now holds at the DB for reads") was false at the substrate.

**The smell:** an enumeration-bearing amendment (per-table rollout list, grant-revocation list) that doesn't grep prior migrations for policies/grants on the SAME surfaces. Write-grant revocation does NOT remove SELECT *policies*; `TO anon` policies are invisible to a `TO authenticated` predicate review. Dev-only `USING (true)` policies marked "DEVELOPMENT-ONLY … replace later" are prime survivors.

**Review check (reusable):** for any RLS/grant amendment, run `grep -rn "TO anon\|USING (true)\|GRANT SELECT" supabase/migrations/` and reconcile every hit against the amendment's lists — each surface must be either listed, excluded-with-reason, or have its stale policy explicitly dropped. Also verify each "consequence" sentence is true AT the substrate, not just at the design.

---
*Added via Oracle Learn*
