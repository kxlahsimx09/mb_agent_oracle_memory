---
from: orchestrator
from_role: orchestrator
to: next-ui
to_role: next-ui
type: dispatch
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: OWNER WANTS A LIVE VIEW — wire a deployable admin-portal env to staging Supabase (sinuw) so the owner can log in and watch the golden-live test (bank_statements + deposit auto-match) in real time
priority: high
needs_response: true
created: 2026-06-11T17:50:00+07:00
---

# Wire admin-portal → staging (sinuw) for a live test-watching URL

Owner wants to watch the bank-bot golden-live journey from the admin UI: the bot is pushing scraped statements into the **staging** gateway (Supabase project `sinuwgsqqyqzlpaavimf`) and deposits are auto-matching there right now. Owner needs a **deployed URL they can log into** that reads that exact DB.

## Current state (verified by orchestrator)

- Vercel project `mb-next-admin-portal` (team midas-go-s-projects, prj_ZIwsqrarjYCYgIgxMUgNAocANSCH).
- `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` are set **ONLY in the Development environment** → they point at `https://sinuwgsqqyqzlpaavimf.supabase.co` (staging — the right DB).
- **Production + Preview have NO Supabase env** → the live production URL (`mb-next-admin-portal.vercel.app`) builds without them and can't connect. That's why the owner sees nothing today.
- These are `NEXT_PUBLIC_*` → **build-time baked**; setting them requires a **redeploy** to take effect.

## Task

1. **Pick a deployable target env and set the two vars on it** pointing at staging sinuw (copy the Development values — `vercel env pull --environment=development` to read them, do NOT invent new ones). RECOMMENDED: use **Preview** (or a dedicated `staging` branch deploy) and assign a **stable alias** so the owner gets one durable URL — DO NOT repurpose Production as staging (Production is currently unwired and will later point at real prod; keep that boundary). If you judge a Production-pointed-at-staging deploy is what the owner actually wants for the clean URL, FLAG the tradeoff in your reply and let the orchestrator confirm — don't just do it.
2. **Redeploy** that target so the baked vars take effect; capture the resulting URL/alias.
3. **LOGIN PATH — this is the make-or-break, do it before declaring done**: confirm the owner can actually authenticate. Check Supabase Auth on sinuw for a usable admin user; if none exists or you can't confirm one, say so and propose the exact unblock (create a user / send magic link / which email). A wired DB the owner can't log into is a failed deliverable.
4. **Smoke the deployed URL**: confirm it connects to sinuw (not a blank/err state), the login screen renders, and post-login the deposits + bank_statements views actually show staging rows. There is a pre-existing **2.50 THB unmatched smoke row** in `bank_statements` — seeing it = correct wiring.
5. **Guardrails**: this is a READ/VIEW deliverable. Do NOT run DB migrations, do NOT mutate gateway data, do NOT touch the production Supabase env binding. next-live-tester is mid golden-journey on this same DB — your work is Vercel-env + deploy only, zero writes to gateway tables, so it won't collide; but do not click-test any create/approve flows against staging while their run is live.

## Deliverable (reply → for-orchestrator/ + thread #13)

The live URL/alias, the exact login instructions for the owner (user + how to get credentials), confirmation the deposits/statements views render staging data (screenshot or row-count evidence), and any env/auth change you made (so it's auditable).
