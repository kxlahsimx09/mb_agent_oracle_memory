# [for orchestrator/owner] UI-data wiring — `/system-bank` wired; `/bank-accounts` BLOCKED on a requirement (spec-first)

**From:** orchestrator (bui session) · **2026-06-17 15:44 (GMT+7)** · **Re:** owner ask "wire `/system-bank` + `/bank-accounts` to real data"

## TL;DR
- **`/system-bank` → WIRED** to the live `v_system_banks` read view. Portal **PR #42**, gateway view **PR #553** (deployed + verified on sinuw). Remaining: live browser-smoke + two-gate/merge.
- **`/bank-accounts` → DO NOT BUILD YET.** No backend table, no read/write surface, **and no requirement/spec/ADR exists**. It is a scaffolded mock. Building it = *defining new product behaviour*, which needs owner decisions + an authored requirement FIRST. (An agent was mid-authoring a requirement PR; the owner halted it — capture here instead, decide before any build.)

## `/system-bank` — DONE (pending validate + merge)
- **Gateway:** `v_system_banks` (leak-safe, mirrors `v_users`: `security_barrier`, admin-tier gate in WHERE, base `bank_account` stays SV7b zero-grant). PR **#553**, migration `20260617000030`. Deployed + verified on **sinuw**: pgTAP 22/22, rbac 55/55, anon→401, aal2-admin→rows, no secret columns, `account_number` admin-gated (per `v_deposits` precedent).
- **Portal:** `readSystemBanks()` (`src/lib/system-bank-api.ts`) + `/system-bank` page wired, mock removed, read-only (`bank-modal.tsx` is detail-only — no write EF exists). PR **#42**.
- **BACKED fields:** id, bankCode, accountName, accountNo, balance, status, bot/working (from `availability`), pool, methods.deposit/payout, dailyInCount.
- **UNBACKED (degrade, NOT fabricated; need gateway aggregates later):** mdrProfile, priority, methods.topup/settlement, dailyOutCount, dailyCount, dailyAmount.
- **Follow-ups:** (1) live browser-smoke using the `portal-test-cast.env` U_SA slot; (2) two-gate → merge #553 then #42; (3) PR #553 test nits (`plan(20)`→22, FK fixture-order).

## `/bank-accounts` — BLOCKED: needs a requirement first
- It is the **client/partner BENEFICIARY bank-account registry** with an approval workflow (mock subtitle: "Destination bank accounts"). Mock `BankAccount`: `owner, ownerType(client|partner), bankCode, accountName, accountNo, purpose(deposit|payout), status(pending|approved|rejected), isDefault`.
- **Verified absent:** no table (47 migrations / 53 tables, no `is_default` column), no read/write surface, **no requirement / epic / spec / ADR**. Only `mb-next-admin-portal/docs/maxpay-ui-reference/pages/06-system-bank-accounts.md` (legacy screen ref) + the mock type.
- **Build cost (if pursued):** a full subsystem ≈ BOTLOG + PROV-001 combined — new table + RLS + approval state-machine + write EFs (submit/approve/reject/set-default) + leak-safe read view + RBAC + UI. Multi-pass (dev → brew-ops → next-ui).
- **OPEN OWNER DECISIONS (resolve before any build):**
  1. Does the client/partner **submit** side belong in THIS admin portal, or a separate client app? (same scope question as the P2P client surface)
  2. **Client-self** submission vs **admin-on-behalf**?
  3. Does an **approved beneficiary become a payout destination** (relationship to settlement/payout target selection)?
  4. `account_number` masking policy (full-to-admin like v_system_banks, or last-4?).
- **Next step:** author `epic-bank-account-ui.md` ONLY after the owner answers the above — then dispatch the build chain. Until then: leave the mock, do not point it at any view.

## Broader buildable-now roadmap (from the 4-cluster gap refresh, code-grounded — the stale `gap-analysis-wui.md` mislabels several as blocked)
**Pure-portal, substrate already live (no gateway dep) — highest value:**
1. Deposit **DR7 fraud-preview (WUI-108 + 114)** — `fraud_preview` computed column on `ts_deposits` (already granted). Doc wrongly says blocked.
2. **Wallet-002 degraded MDR-skip dashboard** — read `mdr_skip` from `wallets_change_logs` via `wallet-log:view`.
3. **Auth reset-2FA row action (completes WUI-009)** — `resetUser2fa` lib + `admin-users-reset-2fa` EF already exist; just add the UI control (smallest win).
4. **Deposit callback-resend (WUI-112)** — `deposit-resend-callback` EF live + withCors.
5. **Deposit TL1 retroactive advisory (WUI-110 → DONE)** — `bank_statements` already portal-readable.
6. **WUI-004 wallet-scoped audit read** (joinable portion; reversal-chain waits on WUI-003).
**+ tiny gateway one-liner:** add `withCors` to `deposits-cancel` → unblocks operator-cancel (WUI-107 admin variant).

**Backend-blocked (need a gateway build first):** WUI-003 wallet-adjustment (no `wallet:update` perm + no EF), WUI-002 spec-faithful (typed `reason_code` + `partner-revenue:view` seed + aggregate view), WUI-006 viewer matrix (no role/permission read view), WUI-008 admin/merchant/partner tiers (no provisioning EFs — only client/sub-client built), WUI-015 self-service (`client-self-*` EFs).

**Big/blocked:** P2P (WUI-115..122) — entire epic, gateway §ADR-17 is 0% built; mostly client-facing (scope question); only WUI-121 operator dashboard is clearly this portal's.

## Session notes / gotchas (carry forward)
- **335 `@probe.local` test users were purged** earlier this session → the `next-ui.env` admin no longer exists in gotrue. Use slot **`portal-test-cast.env`** (U_SA super-admin + TOTP secret) for any aal2 admin flow.
- **API instability (500/529)** killed several agents mid-run; work was recoverable each time (committed-but-unpushed → pushed by the orchestrator). Orphaned chromium procs (~960 MB) from a killed agent linger (harness-namespace; will be reaped).
- **`gap-analysis-wui.md` is materially STALE** (all 4 cluster analysts found errors — WUI-008/006/009 caveats, payout-actions unrecorded, deposit "blocked" verdicts wrong). Worth a refresh PR before relying on it.

## Open PRs (owner-gated, NOT merged)
- portal **#42** (`/system-bank` wiring) · gateway **#553** (`v_system_banks` read view)
