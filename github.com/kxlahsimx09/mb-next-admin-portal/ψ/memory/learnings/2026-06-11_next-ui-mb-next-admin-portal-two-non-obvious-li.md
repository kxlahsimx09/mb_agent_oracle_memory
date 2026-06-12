---
title: next-ui — mb-next-admin-portal: two non-obvious live-screen bugs fixed 2026-06-1
tags: [next-ui, repo:mb-next-admin-portal, next, deposit, bank-statements, mfa, qr, gotcha, live-data, realtime, thread-13]
created: 2026-06-11
source: PR #8 (feat/live-bank-statements-and-deposit-render-fix); verified on staging alias mb-next-admin-portal-staging.vercel.app
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# next-ui — mb-next-admin-portal: two non-obvious live-screen bugs fixed 2026-06-1

next-ui — mb-next-admin-portal: two non-obvious live-screen bugs fixed 2026-06-11 (thread #13, PR #8).

BUG 1 — live data + mock date-anchor = rows silently filtered out. The shared date-range filter (src/components/ui/date-range.tsx) anchored its window to the FIXED mock NOW (`BASE = 2026-06-04T16:30+07`, exported as NOW from src/lib/mock.ts). The default preset is "30d", so rangeBounds = [NOW-30d, NOW] with endMs=NOW (June 4). Any LIVE row (real timestamp > June 4) failed inRange and was dropped from `filtered` — but the segmented "All" count uses `rows.length` (unfiltered), so the UI showed "count 1, no row." This bites EVERY live screen that reuses DateRange/inRange. FIX: rangeBounds(v, nowMs=NOW) + inRange(iso, v, nowMs=NOW) + DateRange nowMs?: prop (all default to mock NOW for backward-compat with mock screens); LIVE screens (/deposit, /bank-statements) pass real Date.now(), recomputed inside the filtered useMemo so realtime-pushed rows stay in view. RULE: any screen wired to real Supabase data MUST anchor date filters to real now, never the mock NOW.

BUG 2 — GoTrue MFA enroll QR renders but won't scan. supabase.auth.mfa.enroll() returns data.totp.qr_code as a raw SVG with `width/height=231` and **NO viewBox**; the enroll screen force-sized it to 160px via CSS (`[&_svg]:size-40`). Without a viewBox, CSS sizing does NOT scale the 231-unit content — it CLIPS it to the top-left 160px → a cropped, undecodable QR (looks like a QR, won't scan). Also data.totp.uri's issuer/label was `localhost:3000` (the sinuw GoTrue SITE_URL leaking the dev origin). FIX: generate the QR client-side with `qrcode.react` <QRCodeSVG> (proper viewBox + quiet zone marginSize=2 + pure #000/#fff + ECC level "M") from a CLEAN otpauth URI we build ourselves — `otpauth://totp/MB%20Portal:<email>?secret=<same gotrue secret>&issuer=MB%20Portal&algorithm=SHA1&digits=6&period=30`. Relabelling is safe: only the secret (+SHA1/6/30) drives codes, so they still verify. Keep the manual-secret fallback visible. NOTE: sinuw GoTrue SITE_URL=localhost:3000 is a server-side staging smell (also taints email/redirect links) — next-dev/brew-ops, non-blocking since we relabel.

Both are admin-only live screens; reads need aal2 ∧ has_read_perm(resource) ∧ admin (deposit→'deposit', bank_statements→'bank-transactions'); v_deposits & bank_statements are both in the supabase_realtime publication so postgres_changes works without a migration.

---
*Added via Oracle Learn*
