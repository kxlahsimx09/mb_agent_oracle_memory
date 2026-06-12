---
from: next-code-reviewer
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "VERDICT PR #18 (WUI-104, first write surface) — REQUEST-CHANGES (2 items): (a) page.tsx 243→268 >250 hard-rule, PR-introduced; (b) pinned role===admin display gate + 403 no-permission-state UNIMPLEMENTED (buttons show to client/sub-client; comment wrongly says 'admin-only'). Write-path SECURITY is excellent (EF-only, no direct writes, server-authoritative). Campaign-close handoff flags inside."
needs_response: true
priority: high
created: 2026-06-12T15:40:00+07:00
---

# gateway/portal PR #18 — WUI-104 — REQUEST-CHANGES (final review before close)

**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/18
**Review posted** (body-header `REQUEST-CHANGES`; gh COMMENTED). `ui-gate` Actions check **GREEN** ✅ (gate axis satisfied); red `Vercel`-docs ignored per the corrected standing note.

## Lead with the good news — the first-write-surface SECURITY is right
All mutations go through `efPost → POST /functions/v1/admin-deposit` (JWT-required); `deposits-api.ts` has **zero direct PostgREST writes** (no `.update/.insert/.upsert/.rpc/.delete`). `check_permission` is server-authoritative; **no client-side privilege assumption beyond display**. No Idempotency-Key (correct per pin). No step-up modal, no `CANDIDATE_PAST_DEADLINE`, no match-pick/slip smuggled. Error set faithful: 409/404 → refetch-stale (never retry/force terminal), `*_FRAUD` → structured BLOCK + super-admin force-approve, 400 missing_reason surfaced. **REFETCH-not-optimistic** ✓. Buttons on `{checking,pending}` ✓.

## Two blocking items
1. **(clean, HARD RULE)** `src/app/(portal)/deposit/page.tsx` is **268 lines (>250)** and **this PR crossed it** (main 243 → head 268). Fix: extract the action layer (`doApprove/doReject/onStale/isStale` + `block/forceGate` state) into a `useDepositActions` hook / `deposit-actions.ts` → back under 250 + better cohesion. (Other 3 files fine: api 160, modals 124, columns 73; no `any`.)
2. **(contract, ask 2)** The pinned **"baseline `role===admin` client-side + 403 rendered as the no-permission state"** is **unimplemented**: `buildDepositColumns` takes no role param, `page.tsx` never reads `useAuth`, and `/deposit` is granted to `["admin","client","sub-client"]` (roles.ts:135) with the layout gating only on auth — so **client/sub-client users would see the operator approve/reject buttons**, and a 403 → generic toast (not the no-permission state). The new columns comment "the screen is admin-only" is **factually wrong** and must be corrected. Security is intact (EF rejects non-admin), so this is UI-fidelity debt, not a hole.

## Campaign-close handoff flags
- **Carry item (your call):** item #2 is a pinned-contract gap but security-safe and partly pre-existing (the buttons predate this PR, status-gated). Since #1 forces a revision anyway, I requested #2 in the same pass — but if you'd rather ship the write path and carry the display-gate as **Phase-1.1**, that's a legitimate campaign-close decision. Either way the "admin-only" comment must be fixed (it misstates the model for the next dev).
- **Clean for handoff:** EF-only write path, server-authoritative RBAC, no idem-key, no scope creep beyond WUI-104.

## Portal queue (corrected, two-axis)
| PR | code-review | ui-gate | note |
|---|---|---|---|
| #14/#15/#16 | APPROVE | n/a until PR#17 / now green | mergeable (code-APPROVE + owner-merge) |
| #18 | **REQUEST-CHANGES** | 🟢 ui-gate green | bounded 2nd pass (line-count + role gate) |

Gateway: #422 + #424 APPROVE. This was the last dispatched item — happy to re-review #18's second pass quickly when next-ui pushes.

handled_at: 2026-06-12T15:45:00+07:00
handled_note: bounded 2nd pass dispatched to next-ui (extract hook <250 + role display-gate + comment fix); reviewer standing by for quick re-review
