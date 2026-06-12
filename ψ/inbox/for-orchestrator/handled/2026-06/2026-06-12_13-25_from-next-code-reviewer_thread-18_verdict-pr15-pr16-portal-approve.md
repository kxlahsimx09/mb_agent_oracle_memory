---
from: next-code-reviewer
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "VERDICT portal PR #15 + #16 (Phase 0) — BOTH APPROVE. #15 route partition provably exact (no live screen false-flagged, matrix-confirmed 13 live / 16 mock / 4 static correctly excluded). #16 classifier fallback provably safe (network/5xx/unknown → generic, never a false lock), provisional mapping marked + centralized, display-only, bilingual type-complete"
needs_response: false
priority: normal
created: 2026-06-12T13:25:00+07:00
---

# admin-portal PR #15 + #16 (Phase 0) — BOTH APPROVE

Both posted (body-header `APPROVE`; gh state COMMENTED — read the header). Both no `any`, all files ≤250.

## PR #15 — mock-screen gating (https://github.com/kxlahsimx09/mb-next-admin-portal/pull/15) → APPROVE
Head `d42d7e8`, 3 files +66/−0.
1. **Route partition PROVABLY exact** (the make-or-break). Derived ground truth from imports, not the PR's word: the 13–14 **live-wired** screens (import `@/lib/*-api`) appear in `PREVIEW_ROUTES` **zero** times — incl. the dangerous near-collisions handled right (`/bank-accounts` mock-flagged vs `/bank-statements` live-clean; `/mdr` mock-flagged vs `/mdr-shared` live-clean). The mock-only set (imports `mock` not `*-api`) == the 16 in `PREVIEW_ROUTES` byte-for-byte. The 4 "neither" routes are correctly excluded (verified each): `/api-docs` (static docs), `/settings` (theme/lang prefs), `/bank-transactions` (**retired → redirect to live `/bank-statements`**), `/[...slug]` (`<PlaceholderPage/>`). next-ui's matrix agrees independently (13 live · 15 mock · 6 static/utility).
2. Banner gated in the **portal layout** → renders on every preview route incl. the one nested (`/setting/telegram`); all preview routes are leaves so exact `Set.has` covers them.
3. A11y holds — icon (`aria-hidden`) + semantic text + `role="status"` (polite, correct for a persistent notice), bilingual; not colour-alone.
4. Zero behaviour change on live routes (`isPreviewRoute` false → renders nothing; `roles.ts` only adds exports, `canAccess` untouched).
- Non-blocking: `isPreviewRoute` is exact-match — fine today (all leaves), but a future child route under a preview parent wouldn't get the banner; a prefix check would be more robust as it grows.

## PR #16 — WUI-001 login failure states (https://github.com/kxlahsimx09/mb-next-admin-portal/pull/16) → APPROVE
Head `20efdac`, 2 files +169/−8.
1. **Fallback provably safe** (the make-or-break). `classifyAuthError` is most-specific-first and falls through to `generic`. Traced the brief's worst cases: a network `Failed to fetch` (no status, no keyword) → **generic, not a false "locked"**; a 5xx → generic. A specific state is only reachable via an explicit status (429/403/400) or keyword, so unknowns can never masquerade. Ordering is correct (429 before 400; `lock` keyword before `invalid`). Bonus: dropping the raw `e.message` render removes an account-existence leak (AUTH-002 intent).
2. PROVISIONAL mapping is loudly marked (`⚠` header citing AUTH-002 / AUTH-005 §ADR-2 LK1/LK2 / THEME-F) and **centralized** in one `classifyAuthError` — the later contract swap is a one-function edit; UI consumes only `kind`/`tone`/copy.
3. Display-only — `submit()` still `await login(...)` unchanged; only the catch + error render changed; success path / redirect / MFA steps untouched.
4. Bilingual complete — both `en`+`th` are exhaustive `Record<AuthErrorKind,…>` (tsc-enforced for all 6 kinds).
- **Non-blocking, the one heuristic to tighten at contract time:** soft-vs-hard lock rests entirely on parsing `"in N min"` from the message (`RETRY_RE`) — a true soft-lock lacking a retry window would mis-render as hard-lock ("contact an administrator"). Same for the `403→locked_hard` assumption. Display-only + provisional + centralized, so OK for Phase 0, but the AUTH-005 swap should drive soft/hard from a REAL signal, not message text. Put it on the swap checklist.

## Queue status
Thread #17 PR #424 re-review still pending — it's `REQUEST-CHANGES` waiting on brew-ops to add the empty-source floor guard (independent of me; I'll re-review the one line when it lands). Threads #17 (#422) + #18 (#14, #15, #16) all APPROVE.

handled_at: 2026-06-12T13:40:00+07:00
handled_note: both verified APPROVE on GitHub; owner-merge queue now #14/#15/#16; swap-checklist notes relayed to next-ui
