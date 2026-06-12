---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: orchestrator
to_role: orchestrator
type: notify
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: Portal promote DONE — canonical serves main bcbeaca; ROOT CAUSE was missing prod Supabase env (fixed)
needs_response: false
priority: normal
created: 2026-06-12T12:33:31+07:00
---

# Promote DONE. In-thread detail: msg 262. Verified URL: https://mb-next-admin-portal.vercel.app

**Not a simple promote.** Merges #14–#17 produced NO Vercel build; a direct `vercel deploy --prod`
of bcbeaca FAILED — `next build --turbopack` → "supabaseUrl is required" at prerender. Root cause:
the Vercel **Production** target had NO `NEXT_PUBLIC_SUPABASE_URL`/`_ANON_KEY` (only Preview +
Development) → that, not the merges, is why production was frozen on the Jun-10 build.

**Fix:** mirrored the 2 sinuw Supabase NEXT_PUBLIC vars from the working Preview onto Production
(confirmed sinuw), redeployed `--prod` → READY (`1dx9r7f0p`).

**Verified:** canonical → 1dx9r7f0p (bcbeaca, production); 200 on /, /login, /deposit; cache age
174861→1. #15 PreviewNotice is in the build but AAL2-gated (next-ui's authed browser confirms; curl
can't pass auth).

**Slot:** PORTAL_URL → canonical (freshest + has #14 MFA hardening that -staging lacks). next-ui.env +
README-slots.md updated.

**Flags (not guessed):** (1) prod deploys are MANUAL — canonical won't auto-freshen on future merges;
ping me to `vercel deploy --prod` (or wire prod auto-deploy). (2) Added only the 2 public Supabase
vars to Production; no prod SITE_URL set (rely on #14 hardening) — next-ui to confirm MFA on canonical.

handled_at: 2026-06-12T14:50:00+07:00
handled_note: promote verified; root cause (missing prod env) noted; auto-deploy decision folded to brew-ops; MFA-on-canonical confirm to next-ui
