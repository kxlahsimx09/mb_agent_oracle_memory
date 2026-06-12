---
title: CORRECTION (supersedes the "admin-portal-ui-state ... read console not operator 
tags: []
created: 2026-06-12
source: thread #18 2026-06-12 (PR #18 reconcile); deposit/ sub-file read revealed the built+wired action console
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# CORRECTION (supersedes the "admin-portal-ui-state ... read console not operator 

CORRECTION (supersedes the "admin-portal-ui-state ... read console not operator console / WUI-104 NOT-BUILT" claim from earlier the same day, 2026-06-12 thread #18).

The /deposit ACTION console IS built + wired on main: deposit/page.tsx + deposit-modals.tsx + deposit-columns.tsx call approveDeposit/rejectDeposit/uploadSlip in src/lib/deposits-api.ts, which POST to the admin-deposit Edge Function via raw fetch(`${NEXT_PUBLIC_SUPABASE_URL}/functions/v1/admin-deposit`). So WUI-104 (approve/reject + force-approve) and WUI-103 (slip-upload) are BUILT (reconciled to the pinned contract in PR #18), NOT not-built.

ROOT CAUSE of the wrong assessment: (1) my read-only audit grepped src/lib/*-api.ts for `.insert/.update/.delete/.upsert/.rpc/functions.invoke` — but portal writes go through raw `fetch` to EFs, so the grep returned empty and I wrongly concluded "read-only console." (2) the route-classification sub-agent read deposit/page.tsx but not the deposit/ sub-files (deposit-columns.tsx row-action buttons, deposit-modals.tsx confirm/reject/force modals).

LESSON for future portal write/coverage audits: to find writes, grep for `fetch(.+/functions/v1/` and the action-fn names (approveDeposit etc.), not just supabase mutation methods; and open route SUB-files (columns/modals/detail), not just page.tsx. Still genuinely unwired in deposit: WUI-102 match-pick (resolveDeposit), WUI-105 verify-now (verifyNow) — EF lib wrappers exist but no UI calls them. See [[wui-104-deposit-approvereject-pinned-build-cont]].</parameter>
<parameter name="concepts">["next-ui","repo:mb-next-admin-portal","next","correction","coverage-matrix","WUI-104","deposit-action-console","gotcha","thread-18"]

---
*Added via Oracle Learn*
