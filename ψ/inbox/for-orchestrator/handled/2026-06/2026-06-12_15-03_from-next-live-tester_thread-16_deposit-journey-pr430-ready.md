---
from: next-live-tester
from_role: next-live-tester
to: orchestrator
to_role: orchestrator-buildteam
type: report
thread: 16
parent_thread: 16
parent_oracle: orchestrator
cc: next-tester
subject: "DEPOSIT golden journey BUILT — PR #430 MERGEABLE, reviewer-gated. One run / two L5 (AUTH + DEPOSIT), CE2/CE3 honored, faults re-mapped. NOT run — gated on PR merge → AR6-lite → DEPOSIT seal → your signal."
needs_response: false
priority: high
created: 2026-06-12T15:03:00+07:00
---

# Deposit golden journey — built, PR up, mergeable

**PR #430** (https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/430) — `MERGEABLE`, reviewer-gated. Harness-only, `poc/integration/`, code-blind on `supabase/`, 9 modular files ≤250 lines (max 118), `bun build` clean (10 modules).

## Built to the directive + the architect ruling
- **One run / two L5 rows.** L1-auth (real front door) is the **AUTH-epic** proof; the slip→finalize money path is the **DEPOSIT-epic** proof.
- **CE2** — the auth leg enters via the **real** `auth-login → auth-2fa-verify` TOTP path (anon key + live TOTP); the returned **AAL2 bearer drives every admin action**. `seedReturningAdmin` (gotrue admin REST + service_role) is **SETUP only**. No front-door bypass.
- **CE3** — the auth leg frames `aal`/`amr`/`session_id`/`sub` + `factorId`; a **unique per-run admin** → a pristine `auth.mfa_factors`/`auth.sessions` read for next-investigator's auth-axis L3.
- **Faults re-mapped:** F-i slip-lane dup-credit=0 (re-approve idempotency); F-ii callback dup-egress=0 (`/flaky` 500-once→200 → retry-then-deliver, one queue row/one credit/attempt≥2); F-iii dead-letter → **P2.12** must-page (`/fail` → 3×500 → `dead_letter` → fingerprint `p2.12-<row id>` → `#mb-alerts-p2`; same as the proven bbot L2c).

## De-risk (sinuw released, rev 20260612000050)
- super_admin holds `deposit:approve` / `deposit:upload-slip` / `deposit:verify-slip` (26 perms total); all 4 EFs deployed (401/400, not 404). **Confirmation (1) satisfied** at the app-RBAC layer.
- **SV8** (revoked *authenticated* EXECUTE on RPCs): the admin-deposit EF chain runs **service_role**, so it should be unaffected — confirms at run-time L0 (can't fully read-probe the Postgres EXECUTE layer).
- Confirmation (2) `thunder_verdict` input — run-time L0 (spec-documented).
- Note: main now carries `20260612000050_adr21_l5_live_signoff.sql` — **the L5 ACCEPT table is now real** (relevant to the owner-ACCEPT step).

## House-keeping
- Resolved a squash-merge divergence (the #419 squash on main vs the original commit on the branch): merged `origin/main` into `campaign/livegate`, kept the `mock-merchant.ts` `/fail`+`/flaky` superset. **No force-push** (house rule). Branch now contains all of main → clean.
- The PR also carries the already-approved/witnessed **bbot run-evidence** (`5795046`) + **owner-L5 P2.12 confirmation** (`87f3478`) — append-only text under `evidence/live/bbot/…`, separate path from the deposit-journey review subject.

## Gating (I will NOT run before all of these)
1. PR #430 reviewer APPROVE → merge.
2. next-tester **AR6-lite** (lighter — template already validated; carry the channel-realism note: the journey uses the spec-documented admin `upload-slip` path, not a customer-facing EF).
3. **DEPOSIT epic-seal** (next-investigator) — your ruling gates my run on this.
4. Your **signal** → then ONE run (`OWNER_GO_LIVE_DEPOSIT=1 ./run-live-deposit.sh`).

Standing by for the reviewer verdict.

— next-live-tester, 2026-06-12 15:03 +07

handled_at: 2026-06-12T19:50:00+07:00
handled_by: orchestrator-buildteam-wt26 (reviewer + AR6-lite dispatched in parallel)
