---
title: Supabase free-tier project limit is PER-MEMBER (2 active free projects total acr
tags: [brew-ops, repo:cross, fleet, supabase, free-tier, provisioning, loadtest, gotcha, drift]
created: 2026-05-26
source: thread #216 msg 1065 — free-tier loadtest provisioning attempt 2026-05-26 (brew-ops)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Supabase free-tier project limit is PER-MEMBER (2 active free projects total acr

Supabase free-tier project limit is PER-MEMBER (2 active free projects total across ALL orgs the member owns/admins), NOT 2-per-org. Confirmed 2026-05-26 (thread #216, free-tier loadtest reframe): `supabase projects create --org-id <mb-payment-dev>` FAILED with "organization members have reached their maximum limits for the number of active free projects ... : mobiztool (2 project limit)" — even though the TARGET org (mb-payment-dev) had only 1 project. The member's 2 free projects in a DIFFERENT org (mobiztool: tarot-app + ai-marketing-platform) consumed the whole quota, blocking creation everywhere.

Implications for fleet provisioning:
- A dispatch/plan that assumes "free orgs allow 2 projects (per-org)" is WRONG — the cap is the member's global 2.
- Spinning up a NEW free org does NOT grant a fresh slot (per-member cap unchanged).
- Corollary deduction: if a member is "at 2 free" via org X while org Y has an ACTIVE project, org Y's project is almost certainly PAID (a 3rd active project can't be free under the global-2 cap). So an org hosting a long-lived active POC alongside the member's 2 free projects is effectively a paid org.

Unblock options when a $0 free run is wanted but the member is at 2: (A) user pauses/deletes one existing free project to free the member slot (touches their other apps — user's call, never auto-pause); (B) accept a cheap paid run on an existing PAID org (smallest compute ~$1 same-day, no new $25/mo org) — but a paid Micro/Nano is NOT the free shared-CPU/500MB-RAM substrate, so it does not answer a "does free tier hold?" feasibility question.

Step-0 discipline (AGENTS.md): check the slot via `supabase projects list` + attempt-or-API BEFORE provisioning; on this kind of fork, flag to the orchestrator/user and do NOT guess past it. Don't pause/delete the user's unrelated apps or spend money unprompted.

---
*Added via Oracle Learn*
