---
from: next-ui
from_role: next-ui
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "/merchants /clients /partners LIVE — PR #13 (base=main, MERGEABLE). All-core-data wiring COMPLETE. settlement/topup remain owner-deferred."
priority: high
created: 2026-06-11T23:45:00+07:00
needs_response: true
---

# Entity screens live — the last 3 → all-core-data wiring complete

**PR #13** → https://github.com/kxlahsimx09/mb-next-admin-portal/pull/13 — **base=main, standalone (not stacked), `mergeable=MERGEABLE`, 4 files.** Route next-code-reviewer.

Unblocked by gateway PR #412. The `v_*` views embed the gate + exclude secrets, so it was a plain `GET /rest/v1/v_<entity>` with the aal2 JWT, same pattern as /deposit.

| Route | view | verified rows (real aal2 admin) |
|---|---|---|
| `/merchants` | `v_merchants` | **1** (mock-merchant) |
| `/clients` | `v_clients` | **5** (Client A…) |
| `/partners` | `v_partners` | **0** (fills live) |

- Read-only; dropped the mock write-features the views don't expose (client API-key mgmt, bulk-edit, merchant create/edit/delete). No secrets in the payload (confirmed).
- Service-role sees 0 rows (the gate lives in the view body, by design) — only an **aal2 admin** sees data, which I verified end-to-end.
- detect clean; build green (38/38); deployed to https://mb-next-admin-portal-staging.vercel.app (all 3 + dashboard → 200). New `src/lib/entities-api.ts`; nav/i18n already existed.

## All-core-data wiring — COMPLETE
Every core money-flow + entity screen now reads live sinuw under aal2+RLS+realtime:
deposit · bank-statements · payout · wallet · wallet-logs · queue · transaction · dashboard · callbacks · activity-log · mdr-shared · **merchants · clients · partners**.

**Owner-deferred (no gateway table exists — not faked):** `/settlement`, `/topup`. If/when the owner decides those are in-scope, next-dev would add the table+view+perm and I'll wire them.

**Ask:** merge #13 (base=main) and the wiring epic is done. Ping me if settlement/topup get greenlit, or for any review findings.

— next-ui, 2026-06-11 23:45 +07
