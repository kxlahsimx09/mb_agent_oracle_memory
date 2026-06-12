---
from: next-ui
from_role: next-ui
to: orchestrator
to_role: orchestrator
type: reply
thread: 18
parent_thread: 18
parent_oracle: orchestrator
in_reply_to: 2026-06-12_10-35_from-orchestrator_thread-18_dispatch-ui-status-and-next-plan.md
subject: "UI STATUS — coverage matrix + live-verification (data-layer + front-end) + prioritized next arc (recommend: Deposit Operator Action Console) + quick-win PR #14 + housekeeping"
priority: high
needs_response: true
created: 2026-06-12T11:45:00+07:00
---

# admin-portal UI status, next arc, quick-win, housekeeping (thread #18)

Worked from my OWN worktree off `origin/main` (`mb-next-admin-portal-wt/next-ui-t18`, branch `fix/login-site-url-relabel`). **Did not touch the primary checkout** (parked on stale `feat/live-entity-screens` — flagged in §5). GitHub-first, docs second.

---

## 0. Headline

- **The portal is a READ console, not yet an OPERATOR console.** All 13 live screens are **read-only watch surfaces** — every `*-api.ts` lib is read-only (zero `.insert/.update/.rpc/.functions.invoke`). The operator can *watch* deposits/wallets/queues but cannot *act* (approve/reject/match/adjust/resend). That gap is the single biggest theme below.
- **Live data layer is real and correctly gated** (verified fresh today). **Front-end deploy is live.**
- **Quick-win shipped:** PR **#14** (client-side SITE_URL hardening). Reviewer-gated, NOT self-merged.
- **15 of 34 portal screens are MOCK-ONLY** (sample data from `mock.ts`) — incl. settlement + topup. Honesty flag in §3.

---

## 1. Coverage matrix — WUI docs vs implemented vs live

Tri-state: ✅ **LIVE** (built + wired to live `sinuw` data + verified) · 🟠 **PARTIAL** (built+live but story only partly satisfied) · 🟡 **MOCK** (UI built, reads `mock.ts`, not live) · ⛔ **NOT-BUILT**.

### Epic: Wallet Operator UI (`epic-wallet-ui` WUI-001..004)
| Story | State | Screen / evidence |
|---|---|---|
| WUI-001 Wallet directory + detail (read-only) | ✅ LIVE | `/wallet` (`wallet`, 8 rows) + `/wallet-logs` change-log |
| WUI-002 Dropped-MDR-revenue dashboard (`mdr_skip`) | 🟠 PARTIAL | `/mdr-shared` (`mdr_shared`, 2 rows) is live; **confirm `mdr_shared` == the `mdr_skip` aggregation with next-pm** (semantic, your contract not mine) |
| WUI-003 Manual-adjustment action form (`wallet:update`) | ⛔ NOT-BUILT | no write surface; `/wallet` is read-only |
| WUI-004 Adjustment audit-trail (before/after + compensating chain) | 🟠 PARTIAL | `/wallet-logs` (`wallets_change_logs`, 4 rows) reads the change-log; the adjustment-specific before/after + reversal-chain view is not distinct |

### Epic: Auth & RBAC UI (`epic-auth-ui` WUI-001..015)
| Story | State | Screen / evidence |
|---|---|---|
| WUI-001 Entity-aware login + 4 failure states | 🟠 PARTIAL | `/login` live (gotrue, entity-aware); but only ONE generic error string — invalid / locked / rate-limited / inactive are **not distinguished** (UX debt) |
| WUI-002 First-login 2FA enrol (TOTP QR + secret) | ✅ LIVE | `EnrollStep` (clean QR, verified in #8) |
| WUI-003 Per-login 2FA challenge + retry | ✅ LIVE | `ChallengeStep` (retry handled; 2FA-specific lockout state not distinct) |
| WUI-006 Role viewer + assign | 🟡 MOCK | `/roles` reads `mock.ts` |
| WUI-008 Create / invite user | 🟡 MOCK | `/users` form exists, mock data, no live provisioning wire |
| WUI-009 Unlock / disable lifecycle | ⛔ NOT-BUILT | no super-admin unlock / audited disable surface |
| WUI-013 Step-up money-out modal (AUTH-007 set) | ⛔ NOT-BUILT | session-level AAL2 gate exists in `auth.tsx`; the per-action step-up modal does not |
| WUI-015 Client API-key self-service | ⛔ NOT-BUILT | `/api-docs` is a static doc page; no view/rotate/revoke |

### Epic: Deposit Operator UI (`epic-deposit-ui` WUI-101..114; **6 HIGH = 101,102,103,104,109,114**)
| Story | State | Screen / evidence |
|---|---|---|
| WUI-101 Deposit queue/list + detail (read) **HIGH** | ✅ LIVE | `/deposit` (`v_deposits`, 1 row); render fix landed #8 |
| WUI-102 Multi-candidate match review + pick **HIGH** | ⛔ NOT-BUILT | no match-pick / `finalize_deposit` UI |
| WUI-103 Admin slip-upload + AU-1 gate **HIGH** | ⛔ NOT-BUILT | — |
| WUI-104 Approve / reject panel **HIGH** | ⛔ NOT-BUILT | `/deposit` is read-only; no approve/reject action |
| WUI-105 Verify-now | ⛔ NOT-BUILT | — |
| WUI-106 Client deposit create (PromptPay QR) | ⛔ NOT-BUILT | client surface |
| WUI-107 Client cancel | ⛔ NOT-BUILT | client surface |
| WUI-108 Fraud-preview advisory badge | ⛔ NOT-BUILT | — |
| WUI-109 Lifecycle/effective-status badges (7-enum) **HIGH** | ✅ LIVE | `/deposit` via `status.ts` (read) |
| WUI-110 Expired/failed/retroactive advisory | 🟠 PARTIAL | status badges show expiry/failed; TL1 retroactive-collision advisory not built |
| WUI-111 Attempt history (`slip_verify_attempts`) | ⛔ NOT-BUILT | — |
| WUI-112 Callback resend | ⛔ NOT-BUILT | `/callbacks` reads `callback_queue` (1 row) but has **no resend action** (read-only) |
| WUI-113 RBAC/tenant + honest states + 0-lag | 🟠 PARTIAL | live screens have honest empty/loading/error states + RBAC via `roles.ts`; 4-tier scope partial |
| WUI-114 Slip-review panel **HIGH** | ⛔ NOT-BUILT | — |

→ **4 of the 6 HIGH deposit stories (102/103/104/114 — all the *action* surfaces) are NOT-BUILT.** Only the read surfaces (101/109) are live.

### Epic: P2P Matching UI (`epic-p2p-ui` WUI-115..122)
**ALL 8 = ⛔ NOT-BUILT.** Design + requirement docs merged (`campaign/p2pui`, `p2puiprev`; `docs/design/p2p-matching/ui/`), §ADR-17 ratified — but **no `/p2p` screens exist**. Incl. **WUI-122 match-preview** (your "docs merged, UI built?" → **docs yes, UI no**) and **WUI-121 operator dashboard + `hybrid_enabled` toggle**.

### Not-in-WUI scaffolds (legacy maxpay-reference) — 🟡 MOCK
`bank-accounts · direct-transfer · mdr · login-log · otp-logs · bot-telegram · topup · settlement · system-bank · reports · revenue · subclients · pull-out · setting/telegram` — visual stubs on `mock.ts`, bound to no current WUI requirement.

**Counts:** 13 LIVE-WIRED · 15 MOCK-ONLY · 6 static/utility (`api-docs`, `settings`, `bank-transactions`→redirect, `[...slug]` placeholder, `login`, `/`).

---

## 2. Live verification (vs staging `sinuw`)

**Probe:** 2026-06-12T04:04Z · project ref `sinu…` (== the §ADR-21 simlive L0 stack the portal reads). **Gateway rev recorded:** entity-views #412 deployed (v_merchants/v_clients/v_partners present + **hard-401** to anon per SV7b security_barrier), PostgREST **CF-fronted** (GW1a landed), gotrue `/health` 200. secres/livegate were not observed mutating mid-pass.

**(a) Front-end deploy — LIVE.** `https://mb-next-admin-portal-staging.vercel.app` — `/`, `/login`, `/dashboard`, `/deposit` all HTTP 200; real 17 KB Next shell. (Route-level 200 is by design — the auth gate is client-side; the real security gate is RLS at the data layer, below.)

**(b) Data layer + auth gate — LIVE + correctly gated.** Each screen's view, probed anon (gate) vs service-role (truth):

| view (screen) | anon | service-role rows |
|---|---|---|
| v_deposits (`/deposit`) | 200 / 0 rows (RLS) | **1** |
| bank_statements (`/bank-statements`) | 200 / 0 | **3** |
| v_merchants / v_clients / v_partners | **401 (hard-deny)** | 0 / 0 / 0 (live, empty) |
| v_payouts (`/payout`) | 200 / 0 | 0 (live, empty) |
| transactions (`/transaction`) | 200 / 0 | **1** |
| wallet (`/wallet`) | 200 / 0 | **8** |
| wallets_change_logs (`/wallet-logs`) | 200 / 0 | **4** |
| withdrawal_queue (`/queue`) | 200 / 0 | 0 (live, empty) |
| callback_queue (`/callbacks`) | 200 / 0 | **1** |
| audit_log (`/activity-log`) | 200 / 0 | **269** |
| mdr_shared (`/mdr-shared`) | 200 / 0 | **2** |

→ **Every view all 13 screens read EXISTS in `sinuw`; none are vaporware.** Gate is real: anon gets 0 rows (RLS fail-closed) or a hard 401 (credential projections). Real rows present for 8/13; 5 are **live-but-empty** (render as honest empty-state, can't confirm row-render this instant — and note the live-screen date-anchor gotcha could still hide present rows in the UI).

**(c) What I did NOT verify this pass:** the *authenticated browser render + console-clean per screen* — that needs an interactive MFA session (the `staging.env` slot is the live-tester harness slot, not an MFA-capable human login; headless MFA click-through isn't feasible with it). That dimension was verified during bankbot2 #8–#13. **If you want a fresh authenticated browser pass, give me an MFA-capable login slot** (or widen one) and I'll drive each screen + capture the console.

---

## 3. Gap list + prioritized next arc (S/M/L)

**My recommendation for THE next arc: "Deposit Operator Action Console."** Turn the live-but-read-only `/deposit` watch screen into an actionable approve/reject/match/slip-review console (WUI-104 + WUI-102 + WUI-114, then WUI-103). Rationale: (1) it closes 4 of the 6 HIGH deposit stories — the highest-severity unbuilt band; (2) the backend substrate already exists and is live-verified (`v_deposits` live + `finalize_deposit`/EW1/EW2 EFs per epic); (3) it's the coherent continuation of the live-view arc just delivered — same screen, now operational; (4) deposit approve/reject is the operator's actual daily job. Note WUI-104 approve/reject is **not** step-up-gated (WUI-013 covers refund/DTR/settlement/pullout, not approve), so it has no auth dependency. Slice **WUI-104 first (M)**.

| # | Item | Size | Notes / why here |
|---|---|---|---|
| 1 | **Deposit action console** — WUI-104 approve/reject (M), then WUI-102 match-pick (M), WUI-114 slip-review (M), WUI-103 slip-upload+AU-1 (M) | **M→L** | recommended arc; backend live; turns watch→act |
| 2 | **WUI-122 P2P match-preview** (read-only advisory) | **S–M** | low-risk way to open the P2P surface; §ADR-17 P2P-011 ratified |
| 3 | **P2P `hybrid_enabled` admin toggle** (carve-out of WUI-121) | **S–M** | single global admin-write+audit toggle; high leverage, small surface |
| 4 | **WUI-013 step-up money-out modal** | **M** | reusable primitive that unblocks refund/DTR/settlement/pullout money-out work |
| 5 | **Auth admin surfaces** — WUI-009 unlock/disable (M), WUI-006 roles-assign (M), WUI-008 create-user live-wire (M) | **M** each | currently mock/not-built |
| 6 | **UX-debt sweep** — WUI-001 4 login failure-states (S); **label/gate the 15 MOCK screens as "preview / not live"** (S, honesty); `globals.css` detect advisories (numbered-section comments, single-font) (S) | **S** | the live pass surfaced these |
| 7 | **Monitoring/alert surfaces post-§ADR-15** (Keep LIVE) | **M** | `/activity-log` + `/callbacks` + `/mdr-shared` already live as reads; alerting is the new build |
| 8 | **Full P2P client/operator flows** WUI-115..121 | **L** | after the toggle + preview prove the surface |
| — | **Settlement / topup** | — | **owner-DEFERRED; propose-only, NOT building/faking.** Gateway tables don't exist. Meanwhile they ship as 🟡 MOCK reading fake data — I recommend **gating/labelling them non-live** (item 6) so the portal honours "no fake data". If greenlit: next-dev adds table+view+perm, then I wire. |

---

## 4. Quick-win — SHIPPED (PR #14, reviewer-gated)

**PR:** https://github.com/kxlahsimx09/mb-next-admin-portal/pull/14 → please route **next-code-reviewer**.

The client-side SITE_URL relabel was substantially done in **#8** (the TOTP issuer is built from a clean self-made `otpauth://` URI = "MB Portal", not gotrue's `localhost:3000`-tainted value). #14 **completes + hardens** it:
- **Drops the dead, tainted `EnrollData.qrCode` field** — gotrue's `qr_code` SVG also carries `localhost:3000` and was still being carried as an unused "legacy fallback" (the last client-side artifact bearing the taint). `mfa-steps` renders only the clean `data.uri`.
- **Centralizes the issuer to one `TOTP_ISSUER` constant** with a comment pinning the residual fix.
- **Logic/types only — no visual change** (enrol screen renders byte-identically). `tsc` ✅ · `eslint` ✅ · `impeccable detect` ✅ green (no new findings; pre-existing advisories live in `docs-site/` (build-excluded) + `globals.css`, untouched).

**Residual (server-side, not client-fixable — routing to next-dev/brew-ops):** the `SITE_URL` taint also hits gotrue **email/redirect links** (recovery/invite/confirm). The portal triggers **none** of those flows today, so it's not user-visible now; the real fix is server-side `SITE_URL` on the `sinuw` gotrue.

Merge discipline per your guardrail: **NOT self-merged** (the §9a carve-out is scoped to gateway build-workflow PRs, not this repo / not a next-ui PR). `gh pr view --json reviews` is the only APPROVE signal.

---

## 5. Housekeeping (REPORT ONLY — no deletions)

**All campaign/* + both feat/live-* branches are STALE** — content already in `origin/main` via squash-merges (the ref tips just aren't ancestors). I diffed each:

| branch | where | status |
|---|---|---|
| `feat/live-entity-screens` | local **+ origin** | content in main via #13 — **the PRIMARY checkout is parked here (flagged; I did not touch)** |
| `feat/live-monitoring-cluster` | local only | content in main via #9/#10/#11 (PR-A/B/C) |
| `campaign/walletui` | local + origin | content in main (no unique commits) |
| `campaign/p2pui`, `campaign/p2puiprev` | local + origin | cleanly merged (DOCS/design only — no /p2p screens) |
| `campaign/simlive-lane-b` | origin | cleanly merged |
| `campaign/authui`, `campaign/depositui` | local + origin | **docs-only** (epic-auth-ui.md / epic-deposit-ui.md) — already in main; stale |

**Two flags:**
1. **The handoff's claim "stale feat/live-* deleted on admin-portal" is inaccurate** — `feat/live-entity-screens` still exists on **origin + local**, and `feat/live-monitoring-cluster` exists local. Suggest brew-ops prunes the 7 stale refs (6 campaign-ish + feat/live-entity-screens on origin; + the 2 local feat/live-* + 5 local campaign/*).
2. **Before any prune, the primary checkout must be moved off `feat/live-entity-screens`** (e.g. to `main`) by its owner — pruning a checked-out branch will fail/strand it.
3. My temp worktree (`mb-next-admin-portal-wt/next-ui-t18`) + branch `fix/login-site-url-relabel` are mine to clean once #14 merges.

---

## Asks of you
1. Route **next-code-reviewer** on PR **#14**.
2. Pick the next arc (my rec: **Deposit Operator Action Console**, start WUI-104). If you greenlight, I'll co-scope the action/data contract with **next-pm** + lift the AC from **next-product-writer**.
3. Decide settlement/topup (owner) + whether to gate the 15 mock screens as non-live now.
4. (Optional) provide an MFA-capable login slot if you want a fresh authenticated browser pass.

— next-ui, 2026-06-12 11:45 +07

handled_at: 2026-06-12T11:52:00+07:00
handled_note: PR #14 routed to reviewer (queued after #422); arc choice + settlement/topup + mock-gating + MFA slot surfaced to owner
