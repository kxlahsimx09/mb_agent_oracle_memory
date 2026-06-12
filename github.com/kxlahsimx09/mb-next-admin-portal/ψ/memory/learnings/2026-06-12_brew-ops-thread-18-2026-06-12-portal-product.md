---
title: brew-ops (thread #18, 2026-06-12) — portal production promote: the stale canonic
tags: [brew-ops, repo:mb-next-admin-portal, next, vercel, deploy, env-vars, gotcha, production, next-ui, supabase]
created: 2026-06-12
source: thread #18 2026-06-12; promoted bcbeaca to production after mirroring 2 prod Supabase env vars; vercel CLI
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# brew-ops (thread #18, 2026-06-12) — portal production promote: the stale canonic

brew-ops (thread #18, 2026-06-12) — portal production promote: the stale canonical was a MISSING-PROD-ENV build failure, not a stale promote.

## Symptom → root cause
`mb-next-admin-portal.vercel.app` (canonical/production) served a 2-day-old build despite #9–#17 merging to main. Cause was NOT "forgot to promote": the Vercel **Production** target had **NO** `NEXT_PUBLIC_SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_ANON_KEY` (only the **Preview** + **Development** targets did, added 18h/2d prior). So any production build fails at prerender with **`Error: supabaseUrl is required`** (a NEXT_PUBLIC var is needed at BUILD time because a Supabase client instantiates during static prerender of e.g. `/_not-found`). Preview builds were green (preview env had the vars), which masked it. The last successful production build predated that prerender-time Supabase usage.

## Diagnosis sequence (reusable)
1. `vercel list <project>` — note that recent deploys are all **Preview**, last **Production** is old.
2. `vercel inspect <canonical-alias>` — `url` = the deployment, `created` = its age, `target`.
3. `vercel deploy --prod --yes` from a clean checkout of the target commit → if it fails, the error names the cause.
4. Reproduce locally: `npm ci && npx next build --turbopack` → exact prerender error.
5. `vercel env ls` — compare env var **environments** column across targets; a var present for Preview but absent for Production is the smoking gun.

## Fix (mechanical, brew-ops env/deploy domain)
Mirror the working Preview values onto Production: `vercel env pull --environment=preview /tmp/x.env --yes`, extract the values, `printf '%s' "$VAL" | vercel env add <NAME> production` (pipe — never echo a secret), `rm` the pulled file. Confirm the URL is the intended backend (sinuw) before mirroring. Then `vercel deploy --prod --yes` → READY. Verify: `vercel inspect <canonical>` shows the new deployment id + fresh `created`; runtime `curl -sI` shows `age` reset to ~0 and 200s.

## Gotchas
- **Build command override:** the Vercel project builds with `next build --turbopack` even though `package.json` build is `next build --webpack`. Not the failure cause here (env was), but be aware the project setting overrides package.json.
- **Production deploys are MANUAL on this project** — git push to main does NOT auto-deploy production (it deploys Preview). So canonical does not auto-freshen on merges; a `vercel deploy --prod` (brew-ops) is required after each main advance, or wire prod auto-deploy (owner config).
- **Auth-gated content can't be curl-verified:** the #15 PreviewNotice renders inside the AAL2 `(portal)` layout, so a banner probe needs an authed browser, not curl. Verify freshness by deployment-id + cache `age` instead.
- **SITE_URL:** I set only the 2 public Supabase vars; did NOT set a production `SITE_URL` (portal #14 hardened MFA against staging-SITE_URL taint, so it should derive correctly). MFA-redirect correctness on a freshly-provisioned prod env is an app/owner confirm, not a blind brew-ops env-set.

next-ui PORTAL_URL pointed at canonical (freshest + has #14 hardening) once green; -staging (preview alias) is pre-#14 and now the worse MFA target.

---
*Added via Oracle Learn*
