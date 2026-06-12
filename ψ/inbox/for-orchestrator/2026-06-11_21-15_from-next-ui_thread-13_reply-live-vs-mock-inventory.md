---
from: next-ui
from_role: next-ui
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
in_reply_to: 2026-06-11_21-00_from-orchestrator_thread-13_dispatch-wire-all-core-data-screens.md
subject: "STEP 1 — LIVE-vs-MOCK inventory of every screen + sinuw backing. 10 screens WIREABLE now (incl. the owner's wallet ledger); settlements + merchants/clients/partners + topup are BLOCKED (no admin-readable view in sinuw → next-dev). Proposed 3 PR clusters inside."
priority: high
needs_response: true
created: 2026-06-11T21:15:00+07:00
---

# Inventory map: every portal screen → sinuw backing → LIVE / WIREABLE / BLOCKED

Method: matched each `(portal)` route to its entity, then checked sinuw for (a) the table/view, (b) an admin-readable A4 SELECT policy (`aal2 ∧ has_read_perm(<perm>) ∧ admin`), (c) whether super_admin holds `<perm>:view`, and (d) live row count (is there data to watch). Read-only via the staging service-role + Management API.

## ✅ LIVE already
| Screen | sinuw backing | perm | rows |
|---|---|---|---|
| `/deposit` | `v_deposits` / `ts_deposits` | deposit:view | 1 |
| `/bank-statements` | `bank_statements` | bank-transactions:view | 2 | (PR #8, in review)

## 🟢 WIREABLE NOW — backing exists, super_admin has the perm, same /deposit pattern
| Screen | sinuw backing | perm (super_admin ✓) | live rows |
|---|---|---|---|
| `/dashboard` | compose from `v_deposits`+`v_payouts`+`wallet`+`transactions` | (those perms) | n/a |
| `/payout` | `v_payouts` / `ts_payouts` | payout:view | 0 (empty now) |
| `/wallet` | `wallet` (+ `v_bank_balance`) | wallet:view | **8** |
| `/wallet-logs` | `wallets_change_logs` | wallet-log:view | **4** ← the credit ledger you saw |
| `/transaction` | `transactions` | transaction:view | 1 |
| `/queue` (withdrawal) | `withdrawal_queue` | withdrawal-queue:view | 0 |
| `/mdr-shared` | `mdr_shared` | mdr-shared:view | 2 |
| `/activity-log` | `audit_log` | activity-log:view | **269** |
| `/callbacks` (NEW route) | `callback_queue` + `callback_attempts` | activity-log:view | 1 + 1 |

(`/bank-transactions` mock is **superseded** by the live `/bank-statements` — recommend retiring/redirecting it.)

## 🔴 BLOCKED — no admin-readable backing in sinuw → route next-dev (don't want me to invent a shape)
| Screen | Gap (exact ask for next-dev) |
|---|---|
| `/settlement` | **No settlement table/view exists in sinuw at all** (`settl%` → 0). Needs the gateway settlements table/view + RLS + `settlement:view` perm. |
| `/merchants` | `merchant_config`/`merchant_profiles` exist but SELECT was revoked (SV7b) and there's no `has_read_perm` policy. Needs a `v_merchants` read view + `merchant:view` perm + A4 RLS. |
| `/clients` | `client`/`client_profiles` exist but SELECT revoked, no policy. Needs `v_clients` + `client:view` + RLS. |
| `/partners` | `partner_profiles` exists, no read policy/perm. Needs `v_partners` + `partner:view` + RLS. |
| `/topup` | No topup table exists (`topup%` → 0). Needs the gateway topups table/view + RLS + perm. |
| `/users`, `/roles` | `app_user`/`role_permissions` are read only via SECURITY DEFINER fns; no direct admin SELECT policy. Needs a `user:view`/`role:view` read path. |
| `/system-bank`, `/bank-accounts`, `/direct-transfer`, `/pull-out`, `/subclients`, `/mdr`(profiles), `/login-log`, `/otp-logs` | No admin-readable backing view in sinuw. Need next-dev views/RLS, or confirm they're out of the live-watch scope. |
| `/revenue` | Partially possible via `v_payouts`/`v_success_payout_audit` (partner-context; the latter is anon-readable, already flagged). Low priority — confirm if wanted. |

## ⚙️ CONFIG / STATIC (not live-data watch screens — leave as-is)
`/settings`, `/setting/telegram`, `/bot-telegram`, `/api-docs`.

## Proposed PR clusters (one reviewer-gated PR each, deployed to the alias as it lands)
- **PR-A — Money flow:** `/dashboard` + `/payout` + `/transaction`
- **PR-B — Wallet ledger:** `/wallet` + `/wallet-logs` + `/queue`  (the owner's 4-row credit ledger is here)
- **PR-C — Monitoring:** `/callbacks` (new) + `/activity-log` + `/mdr-shared`

All reuse the existing components/tokens + the proven aal2+RLS+realtime+real-`Date.now()` pattern; `impeccable detect` clean + critique/audit per surface; read-only.

## Ask
1. **Confirm the cluster plan / order** (or re-prioritize — e.g. ledger first since it has the data the owner watched). On your nod I start **PR-B (wallet ledger)** or **PR-A** immediately.
2. **Route next-dev** for the BLOCKED set — the highest-value gap is **settlements** (named core, but the view doesn't exist) and the **merchant/client/partner** entity views. I can wire those the moment next-dev lands `v_*` + RLS + perms.

— next-ui, 2026-06-11 21:15 +07
