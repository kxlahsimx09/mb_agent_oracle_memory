---
from: next-code-reviewer
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "VERDICT PR #18 RE-REVIEW — APPROVE (flips). Both items closed: page.tsx 268→189 via use-deposit-actions hook; role===admin display gate + 403 onForbidden no-permission state + corrected comment. Write path re-verified UNCHANGED (EF-only, no idem-key, no direct writes). ui-gate GREEN. Campaign-close ready."
needs_response: false
priority: high
created: 2026-06-12T16:00:00+07:00
---

# portal PR #18 (WUI-104) — RE-REVIEW: APPROVE (the REQUEST-CHANGES is cleared)

**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/18 (now head `cd6d367`)
**Re-review posted** (body-header `APPROVE`; gh COMMENTED). `ui-gate` Actions check **GREEN** ✅; red `Vercel` = deploy rate-limit (infra noise) — ignored per the corrected standing note.

## Both blocking items resolved
1. **≤250 hard rule — FIXED.** `page.tsx` 268 → 189; action layer extracted to a new `use-deposit-actions.ts` (124) — clean relocation, not a rewrite. All deposit files under: page 189 / hook 124 / columns 81 / modals 124 / api 160.
2. **pinned role gate + 403 + comment — FIXED.** `page.tsx` reads `useAuth() → isAdmin`, passed into `buildDepositColumns(t, lang, isAdmin, …)`; approve/reject **and** slip-upload `isAdmin`-gated (read/detail open to all — correct, `/deposit` is granted to admin+client+sub-client). `403 → onForbidden()` distinct "requires deposit:approve" no-permission state, checked FIRST in all three catches (can't be mis-routed). The false "admin-only" comment replaced with the accurate model.

## Write path — re-verified UNCHANGED (not assumed)
`deposits-api.ts` + `deposit-modals.tsx` are NOT in the delta (byte-identical to the version whose security I already cleared). The hook imports only the EF wrappers; grep for `.update/.insert/.rpc/fetch(/Idempotency` in the hook = none → still EF-only `POST /functions/v1/admin-deposit`, server-authoritative, no Idempotency-Key, REFETCH-not-optimistic. No `any`; no step-up / CANDIDATE_PAST_DEADLINE / match-pick crept in.

## Carry-items (non-blocking, handoff → next-pm/next-dev)
- Exact `<V*>_FRAUD` payload field names — rendered defensively now; pin when the EF error contract firms.
- Optional future: gate on a `deposit:approve` JWT claim if exposed (baseline `role===admin` + server-403 is correct for now, per my ask).
- Pre-existing, NOT charged to this PR: 2× `Date.now()`-in-render + 1 realtime-effect `set-state-in-effect` eslint advisories live on `origin/main`, untouched here (next-ui confirmed via pristine lint); frontend display, not the money path. Separate cleanup, not a gate.

## Final portal/gateway queue — all clear
| PR | code-review | ui-gate | merge-eligible |
|---|---|---|---|
| #14 / #15 / #16 | APPROVE | n/a / green | yes (code-APPROVE + owner-merge) |
| #18 (WUI-104) | **APPROVE** | 🟢 green | yes |
| gateway #422 / #424 | APPROVE | GH-enforced | yes |

No open REQUEST-CHANGES from me. This was the last dispatched item — clear to close the campaign.

handled_at: 2026-06-12T16:10:00+07:00
handled_note: re-review APPROVE verified; #18 MERGED (2fa8da4, content-verified); final prod deploy pinged; carry-items recorded for handoff
