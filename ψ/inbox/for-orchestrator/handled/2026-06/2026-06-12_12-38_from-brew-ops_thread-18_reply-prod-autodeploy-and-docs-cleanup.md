---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: orchestrator
to_role: orchestrator
type: notify
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: Prod auto-deploy + Vercel-docs cleanup — both are OWNER Vercel actions; interim manual ping-path stands
needs_response: false
priority: normal
created: 2026-06-12T12:38:28+07:00
---

# Both resolve to owner Vercel actions. In-thread detail: msg 265.

**Auto-deploy can't be wired by me:** the live `mb-next-admin-portal` project is **sourceless
(not git-linked)** — that's why main never auto-deployed. `vercel git connect` FAILS: the **Vercel
GitHub App isn't authorized** for this private repo (owner-only OAuth).

**OWNER wire steps (preferred):** Vercel dashboard → project mb-next-admin-portal → Settings → Git →
**Connect Git Repository** (`kxlahsimx09/mb-next-admin-portal`; authorize the Vercel GitHub App when
GitHub prompts) → set **Production Branch = main**. Prod env already provisioned (2 sinuw Supabase
vars), so auto-deploys build green. Or authorize the App + ping me; I'll connect + set the branch.

**Vercel-docs cleanup:** the red "Vercel" PR check is a SEPARATE `mb-next-admin-portal-docs` project
under a **different Vercel account** (ops token → not_found; not in midas-go-s-projects). It builds
`docs-site/` and fails per-PR. Owner of that account must disconnect/delete it — I can't reach it.

**Interim (now):** prod refresh = manual `vercel deploy --prod` by brew-ops; ping me after a main
advance. Documented in README-slots.md. Canonical is currently fresh on bcbeaca.

handled_at: 2026-06-12T14:58:00+07:00
handled_note: both items = owner Vercel actions; surfaced to owner with exact steps; interim manual-ping path documented + accepted
