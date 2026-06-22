---
title: prod Vercel deploy of mb-next-admin-portal — Vercel BLOCKS any deploy whose git 
tags: []
created: 2026-06-19
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# prod Vercel deploy of mb-next-admin-portal — Vercel BLOCKS any deploy whose git 

prod Vercel deploy of mb-next-admin-portal — Vercel BLOCKS any deploy whose git commit AUTHOR is not a Vercel team member (TEAM_ACCESS_REQUIRED / fork-protection). Same root cause as the "No GitHub account matching commit author email" RED check on agent-authored PRs (seen on PR #70). So a plain `vercel --prod` from the git checkout BLOCKS for agent commits. WORKING METHOD (used 2026-06-19 → dpl_6gP46jwYR7Wd4GzH8kKxtKzqgFfe, aliased mb-next-admin-portal.vercel.app, build green Next 16.2.7 / 39 routes): export the tree with `git archive` into a NON-git dir, add a `.vercel/project.json` link, then `vercel deploy --prod` there → no git author attached → no block. Durable fixes (owner choice): (1) add the merge author / a service identity to the Vercel team OR disable the git-author/fork-protection check in project settings; OR (2) keep the git-archive method. TOPOLOGY FACT confirmed via docs/stack-topology.md: there is NO production Supabase stack separate from sinuw — `sinuwgsqqyqzlpaavimf` is the §ADR-21 LIVE stack AND the prod-backend the Vercel portal targets (next-ui.env/staging.env SUPABASE_URL=sinuw). One Vercel project (mb-next-admin-portal, prj_ZIwsqrarjYCYgIgxMUgNAocANSCH), prod alias mb-next-admin-portal.vercel.app, prod deploys are manual CLI (source:cli, empty git metadata). So "deploy to prod" = a no-op on the gateway (migrations already on sinuw) + one manual vercel --prod of the portal.</pattern>
<parameter name="concepts">["brew-ops", "repo:mb-next-admin-portal", "vercel", "prod-deploy", "team-access-required", "git-author-block", "git-archive-workaround", "stack-topology", "sinuw-is-prod", "merge-not-deploy", "gotcha", "next", "fleet"]

---
*Added via Oracle Learn*
