---
title: brew-ops OBS-1 (thread #17, 2026-06-12) — "all EFs at HEAD" deploy sweeps must b
tags: [brew-ops, repo:mb-next-payment-gateway, next, deploy, edge-functions, bbot, bot-credentials, gotcha, decision, staging-deploy, slot-map]
created: 2026-06-12
source: OBS-1 thread #17 2026-06-12; PR #424 + vault W7 1e5fff3; sinuw+qnccph Management-API audit
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# brew-ops OBS-1 (thread #17, 2026-06-12) — "all EFs at HEAD" deploy sweeps must b

brew-ops OBS-1 (thread #17, 2026-06-12) — "all EFs at HEAD" deploy sweeps must be GENERATED, never a frozen list; + bbot BOT_CRED_ENC_KEY is a pgcrypto passphrase (rotation orphans encrypted rows).

## Root cause
The auth campaign's "all-26-EF at HEAD" Edge-Function deploy sweeps were run from a hand-enumerated EF list that PREDATED the bank-bot adapter family. So the 5 bbot EFs (bot-config / bot-statements / bot-bank-statements-last / bot-balance / bot-queue-mark) were SILENTLY EXCLUDED from every sweep and sat pre-BK2-cutover stale on the tester/seal stack (qnccph) until next-tester redeployed them by hand. A frozen list cannot see a new family. (Real EF count at HEAD = 27, not 26; the "26" was already stale at coinage.)

## Fix (PR #424 + vault W7 commit 1e5fff3)
- `scripts/ef-deploy-list.sh`: single source of truth. `--list` (generated from `supabase/functions/`, excludes `_*` helper dirs), `--count`, `--assert <REF>` (diffs source-set vs the stack's ACTIVE-deployed slugs via Management API `GET /v1/projects/<ref>/functions`; exits non-zero if a family is missing).
- The no-arg `supabase functions deploy --project-ref <REF>` form IS the authoritative sweep — the CLI derives the set from `supabase/functions/`, so it cannot omit a family. The single-fn form is targeted-redeploy only. NEVER substitute a hand-typed list.
- Runbook `edge-function-deploy.md` §3a + `provision-substrate-stacks.md` A6 + brew-ops W7 staging-deploy Step-3 all carry the generated-list rule + `--assert` completeness gate.

## sinuw audit result (read-only Management API)
sinuw (`sinuwgsqqyqzlpaavimf` = mb-next-staging, LIVE-mode stack) was NOT stale: 5 bbot EFs ACTIVE + at HEAD (v10×4 post-#398, bot-config v1 post-#399), 27 EFs all ACTIVE, BOT_CRED_ENC_KEY present, migs `20260611000300`. No deploy taken. (EF `updated_at` from the API is epoch MILLISECONDS — divide by 1000 before `todate`.)

## Verified slot → Supabase project-ref map (closes the recurring "slot-map gotcha")
dev-1.env→`qvmjywljrgqzyxshexhx` (mb-next-dev1) · tester.env→`yupsevcrubgprsbujbpu` (yupsev/mb-next-tester) · investigator.env→`qnccphgykzdydebmdwdf` (qnccph/mb-next-investigator) · staging.env→`sinuwgsqqyqzlpaavimf` (sinuw/mb-next-staging). A PAT from any one slot is account-scoped → reaches all of them read-only.

## qnccph BOT_CRED_ENC_KEY decision — RECORD AS-IS, do NOT rotate
`BOT_CRED_ENC_KEY` is consumed as a pgcrypto passphrase: `_shared/bot-auth.ts:27` only checks it non-empty and passes it to `verify_bot_request` → `pgp_sym_decrypt`. So ANY length is valid (no 32-byte AES-256 raw-key constraint) — the tester's 31-char probe key is functionally correct. Rotation is contraindicated: qnccph holds 10 `bot_credentials` rows ALL encrypted under the current key; re-minting orphans every one (decrypt failure → bot auth breaks). The deployed EF secret persists in the project's secret store (the "/tmp-only" risk is only the operator's local copy). Convention: BOT_CRED_ENC_KEY is slot-managed (sinuw reference = staging.env). Promote into a stack's slot by CAPTURING the existing value, never by rotating. Recorded in README-slots.md (the slot ledger).

---
*Added via Oracle Learn*
