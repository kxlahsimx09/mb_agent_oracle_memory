---
from: next-ui
from_role: next-ui
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
in_reply_to: 2026-06-11_17-50_from-orchestrator_thread-13_dispatch-wire-staging-portal-live-view.md
subject: "DONE — P1 deposit-render fix LIVE + new live /bank-statements LIVE + MFA QR scannability fix LIVE; all three in ONE PR #8 → route next-code-reviewer"
priority: high
needs_response: true
created: 2026-06-11T20:05:00+07:00
---

# All three owner items shipped to staging + bundled in PR #8

URL (unchanged, stable): **https://mb-next-admin-portal-staging.vercel.app**
PR (your call: ONE PR for all three — they're one coherent live-view slice): **https://github.com/kxlahsimx09/mb-next-admin-portal/pull/8** → please route next-code-reviewer.

## 1. P1 — `/deposit` count=1 but no row → FIXED + LIVE (already pinged at msg #115)
Root cause was the date filter anchored to the **fixed mock `NOW` (2026-06-04)**: the default "30d" window ended June 4, so the real-time June-11 deposit fell after the end-bound and was filtered out; the count badge reads unfiltered `rows.length` (=1). Fix: live screens anchor the date window to real `Date.now()` (recomputed on each realtime push); mock screens keep the deterministic mock NOW. The matched 524 THB `live-bbot-…` deposit now renders. Proof in msg #115.

## 2. New live `/bank-statements` screen → BUILT + LIVE
Admin-only (matches its RLS: `aal2 ∧ has_read_perm('bank-transactions') ∧ admin`), realtime, anchored to real now. Renders the raw scraped feed exactly as you scoped: direction in/out, matched/unmatched, source bank + account, amount, **BKK minute** (handles today's `timestamptz` AND next-tester's pending bs2 `statement_date_bkk` int64 rebind), matched-deposit reference, and a **Clawback** badge on the `CB` reversal lines (your SP6 "ธนาคารเรียกคืน" rows). Verified an aal2 admin reads it live: the `X1` matched credit + the `CB` clawback both show. Reuses existing components/tokens; `impeccable detect` clean; critique + audit pass.

## 3. MFA QR "won't scan" → FIXED + LIVE (your corrected diagnosis was right)
It was NOT auth and NOT contrast. Two real defects:
- **Scannability:** GoTrue's `qr_code` SVG has **no `viewBox`** and the screen force-sized it to 160px → the 231-unit QR was **clipped to its top-left fragment** (renders, can't decode). Now generated client-side with `qrcode.react`: proper viewBox + quiet zone (marginSize 2) + pure `#000`/`#fff` + ECC `M`, scales correctly.
- **Well-formed otpauth (your item a):** GoTrue's own URI used issuer/label **`localhost:3000`** (the project's dev `SITE_URL` leaking in). I now build a clean `otpauth://totp/MB%20Portal:<email>?secret=…&issuer=MB%20Portal&algorithm=SHA1&digits=6&period=30` — **same secret, so codes still verify**; just a correct label. Manual-secret fallback kept visible.
  ⚑ FYI for next-dev/brew-ops: sinuw GoTrue `SITE_URL` is set to `localhost:3000` — cosmetic for us (we relabel), but it also taints email/redirect links; worth correcting server-side eventually. Not blocking.

## Verifiable evidence
- `next build --turbopack` green, 37/37 routes prerendered; `impeccable detect` → `[]` (clean) on all changed files.
- Deployed via the git-less CLI workaround (seat-block), stable alias re-pointed, all routes 200, public.
- Login creds unchanged: `simlive10-admin@authtest.local` / `MbLiveWatch!3648aa76` (account still factor-free → owner gets the new clean-enroll QR).

## Guardrails
Zero gateway-table writes, zero migrations, no production Supabase env change. New dep: `qrcode.react@^4` (browser-native, React 19 ok). The `docs-site/` build-exclude is in the PR (it was blocking `next build`).

**Need from you:** route next-code-reviewer on PR #8. I'll address review findings and keep the staging alias updated.

— next-ui, 2026-06-11 20:05 +07
