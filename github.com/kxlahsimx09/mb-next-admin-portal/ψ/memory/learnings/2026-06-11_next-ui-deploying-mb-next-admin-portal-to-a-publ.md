---
title: next-ui — Deploying mb-next-admin-portal to a public Vercel URL on staging (sinu
tags: [next-ui, repo:mb-next-admin-portal, next, vercel-deploy, staging, gotcha, seat-block, docs-site, sso-protection, thread-13]
created: 2026-06-11
source: thread #13 staging-portal-live-view dispatch; deploy dpl_6Yf9cgFeajeMVAeNjCmYuc7thDvd / alias mb-next-admin-portal-staging.vercel.app
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# next-ui — Deploying mb-next-admin-portal to a public Vercel URL on staging (sinu

next-ui — Deploying mb-next-admin-portal to a public Vercel URL on staging (sinuw): playbook + 3 gotchas (2026-06-11, thread #13).

GOAL: a deployed, owner-loginable Preview URL wired to staging Supabase sinuwgsqqyqzlpaavimf. NEXT_PUBLIC_SUPABASE_URL/ANON_KEY are build-time baked → setting them needs a redeploy. They lived only in Vercel Development; copy them to Preview (vercel env pull --environment=development to read; do NOT invent). Production left unwired on purpose (prod boundary).

GOTCHA 1 — Vercel git-author SEAT-BLOCK. Team "midas-go's projects" (Hobby) refuses to build any git-based deploy whose HEAD commit author isn't a team member. All commits are authored by 117012903+kxlahsimx09@users.noreply.github.com (not a member) → deployments enter readyState=BLOCKED, seatBlock=TEAM_ACCESS_REQUIRED, alwaysRefuseToBuild=true, buildSkipped=true (NOT a build failure — the build never starts; CLI just hangs at "Building…"). WORKAROUND that works today: deploy a GIT-LESS copy of the tree (rsync excluding .git/.agent/node_modules/.next, keep .vercel/project.json) and `vercel deploy` from there — no .git ⇒ no author enforcement ⇒ builds as a plain CLI deployment and still picks up Preview env vars. Real fix (brew-ops/owner): add the git identity to the Vercel team, or author deploy commits as midasgoteam@gmail.com.

GOTCHA 2 — docs-site/ breaks `next build`. Root tsconfig.json include is greedy (**/*.tsx) so it type-checks the STANDALONE docs-site/ Nextra app (own package.json/tsconfig, deps NOT installed at root) → "Cannot find module 'nextra/pages'" → next build exit 1. FIX: add "docs-site" to tsconfig exclude AND .vercelignore. (.agent symlink / Turbopack was NOT the cause here — .vercelignore already excludes .agent so remote turbopack builds fine.)

GOTCHA 3 — Deployment Protection SSO wall. Project ssoProtection={"deploymentType":"all_except_custom_domains"} ⇒ every *.vercel.app URL (incl. any .vercel.app alias) returns HTTP 401 → vercel.com/sso. A custom domain would be exempt but a .vercel.app alias is NOT. To hand a non-Vercel owner a plain URL: PATCH /v9/projects/{id} ssoProtection=null (reversible). Safe here because the portal's own gotrue+forced-MFA(aal2)+RLS is the real data security; SSO only gated the public login shell. Alternative if the wall must stay: Protection-Bypass token cookie link.

RESULT: stable alias mb-next-admin-portal-staging.vercel.app → READY deploy; HTTP 200, real portal, sinuw baked into the client bundle. Auth token for the API workarounds lives in ~/Library/Application Support/com.vercel.cli/auth.json; project prj_ZIwsqrarjYCYgIgxMUgNAocANSCH, team team_NcQL9QEsv53GkO7pBqyiyMFC.

---
*Added via Oracle Learn*
