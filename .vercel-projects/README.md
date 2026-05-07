# `.vercel-projects/` — central Vercel link metadata

This directory holds **per-project link metadata** for every Vercel project
the fleet deploys to. The convention exists so that any agent on the user's
machine can deploy a doc site (or any Vercel-backed project) without
running `vercel link` itself.

## Why this lives here

The default Vercel CLI workflow writes `.vercel/project.json` into the
project root after `vercel link`. That file carries `projectId` + `orgId`
and is gitignored (per Vercel's defaults; environment-specific). Agents
spawned in fresh shells, fresh worktrees, or fresh checkouts therefore
have no way to deploy unless someone re-runs `vercel link`.

We solve that by keeping **one canonical copy per project** here. The
central memory repo is single-author, append-only, and already the
shared-state surface every agent reads on startup (per AGENTS.md §3a),
so it's the natural home.

## File naming

```
.vercel-projects/<slug>.json
```

`<slug>` is the deploy target's project name on Vercel. Recommended:
match the GitHub repo name + a suffix when one repo deploys multiple
sites. Example slugs:

- `mb-next-payment-gateway-docs.json` — doc hub for `mb-next-payment-gateway`
- `bankbot-v2-docs.json` (future)

## File contents

A verbatim copy of the `.vercel/project.json` that `vercel link`
produced locally. Shape:

```json
{
  "projectId": "prj_xxxxxxxxxxxxxxxxxxxxxxxx",
  "orgId":     "team_xxxxxxxxxxxxxxxxxxxxxxx"
}
```

**No tokens, no secrets.** `projectId` + `orgId` alone don't authorize
anything; deployments still need a `VERCEL_TOKEN` (from the human's
`vercel login` cache or env var).

## Bootstrap workflow

After the human runs `vercel link` in a project for the first time:

```bash
cp <project>/docs-site/.vercel/project.json \
   ~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory/.vercel-projects/<slug>.json
cd ~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory
git add .vercel-projects/<slug>.json
git commit -m "vercel: link metadata for <slug>"
git push
```

Any future agent on any machine then runs the project's bootstrap script
(e.g. `docs-site/scripts/vercel-bootstrap.sh`) which reads from here and
materializes the local `.vercel/project.json` on demand.

## Lookup order (used by bootstrap scripts)

1. `$VERCEL_LINK_FILE` — explicit override path.
2. `$MB_AGENT_ORACLE_MEMORY/.vercel-projects/<slug>.json` — env var pinned to this repo.
3. `~/Code/github.com/kxlahsimx09/mb_agent_oracle_memory/.vercel-projects/<slug>.json` — default Code/ checkout.
4. `$(ghq root)/kxlahsimx09/mb_agent_oracle_memory/.vercel-projects/<slug>.json` — ghq checkout.

## Adding a new project

1. Run `vercel link` locally inside the project that hosts the site (e.g. `docs-site/`).
2. `cp` the resulting `project.json` here with the chosen slug.
3. Commit + push.
4. Reference the slug from the project's bootstrap script.

## What does NOT live here

- `VERCEL_TOKEN` (user-scoped, in Vercel CLI's own keychain).
- Environment variables for the site (Vercel project settings UI, or `vercel env`).
- Aliases / domain config (Vercel project settings UI).
- Build settings (`vercel.json` in the project, or Vercel dashboard).
