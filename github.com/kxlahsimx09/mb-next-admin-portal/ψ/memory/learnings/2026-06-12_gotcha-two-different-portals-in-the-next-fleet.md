---
title: GOTCHA — two different "portals" in the next fleet; do not conflate (cost me a v
tags: []
created: 2026-06-12
source: thread #18 live-verification 2026-06-12; brew-ops notify thread-13; bankbot2 campaign-close handoff
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# GOTCHA — two different "portals" in the next fleet; do not conflate (cost me a v

GOTCHA — two different "portals" in the next fleet; do not conflate (cost me a verification detour, and the bankbot2 campaign-close handoff conflated them):

1. ADMIN PORTAL (this repo, mb-next-admin-portal) — the Next.js operator console for backend users. Staging deploy = Vercel: https://mb-next-admin-portal-staging.vercel.app (per next-ui thread-13 reply; deployed via the git-less CLI workaround, Vercel seat-block). Reads live staging data from the sinuw Supabase project.

2. SCB MOCK-BANK SIM PORTAL (bank-bot's scrape target) — https://18-136-227-108.sslip.io, EC2+Caddy+sslip.io, login simviewer/simviewer-pass, /sim/* IP-gated to owner. This is the portal the SP3 dedup-fidelity service-split moved to its own EC2 ("portal now its own EC2+Caddy at a stable HTTPS URL"). It is NOT the admin portal — /login 404s there because it's a different app (21-byte body).

The handoff said "portal now at stable HTTPS https://18-136-227-108.sslip.io" referring to the BANK-SIM portal; an unwary reader assumes it's the admin portal and wastes a curl pass. Admin-portal live verification = (a) Vercel front-end + (b) sinuw Supabase data layer via PostgREST.

Also: staging.env slot (fleet-secrets/mb-next-payment-gateway/slots/staging.env, project ref sinu…) is the §ADR-21 simlive L0 stack the admin portal reads — has SUPABASE_URL/ANON/SERVICE_ROLE, but it is the next-live-tester HARNESS slot, NOT an MFA-capable human login. So headless authenticated browser verification of the admin portal isn't feasible with it; you need an MFA-capable login slot for a click-through pass.</parameter>
<parameter name="concepts">["next-ui","repo:mb-next-admin-portal","next","gotcha","staging","live-verification","portal-url","sinuw","decision"]

---
*Added via Oracle Learn*
