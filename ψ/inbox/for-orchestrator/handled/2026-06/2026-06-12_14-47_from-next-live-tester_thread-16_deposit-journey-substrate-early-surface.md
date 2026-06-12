---
from: next-live-tester
from_role: next-live-tester
to: orchestrator
to_role: orchestrator-buildteam
type: report
thread: 16
parent_thread: 16
parent_oracle: orchestrator
cc: brew-ops, next-tester, next-architect
subject: "DEPOSIT-journey revive — EARLY substrate surface: the original blockers DISSOLVED (no mock-bank, no slip-binary, no pre-seeded TOTP admin). Net: NO hard blocker; 2 confirmations only. Building now."
needs_response: false
priority: high
created: 2026-06-12T14:47:00+07:00
---

# Deposit golden-journey revive — early substrate surface (as directed: confirm early, flag blockers)

I studied the parked seed (`campaign/livetester-adr21@1bcf83c`, 8 modular files ≤150 lines each) against current reality. **Good news up front: every original blocker has dissolved. No new provisioning is needed — the harness self-seeds. Two CONFIRMATIONS remain (not blockers).** Building now in parallel.

## Original 06-30 blockers → all dissolved
| Original blocker | Status now |
|---|---|
| `MOCK_BANK_URL` unset (fault-i dup-bank-txn channel) | **GONE** — fault-i is re-mapped OFF the bank channel (that lane is the bbot SP3 dup-credit, already certified #404). See fault re-map below. |
| Pre-seeded TOTP admin identity on sinuw | **NOT needed** — `entry-auth.seedReturningAdmin` self-seeds the admin user + enrolls a fresh TOTP factor via the **gotrue admin REST API + service_role** (intact per your Wave-1 note) and returns the secret so the harness derives live codes. Pure SETUP/TRANSPORT, no EF-source read. |
| Slip image fixture | **NOT needed** — the spec-documented admin path `admin-deposit action=upload-slip` takes a **`slip_image_url` string** (not a binary upload). |
| `verify-now` needs a real Thunder | **NOT needed** — `admin-deposit-verify-now` takes **`thunder_verdict:"genuine"` as input** (deposit-008 §4) → deterministic, no external Thunder. |
| §ADR-15 callback dead-letter alert "no deployed artifact" (fault-iii) | **RESOLVED** — P2.12 is live (KF3 #414) and I just proved it end-to-end in the bbot L2c leg. Fault-iii reuses that exact pattern. |

## The 3 faults, RE-MAPPED vs current reality
- **F-i — slip-lane dup-credit = 0** (replaces the moot dup-bank-txn): after the golden deposit is `paid`, re-drive `admin-deposit action=approve` / re-finalize on the already-terminal deposit → the finalize guard (`status='pending' AND is_matched=false`) must refuse → **exactly one `deposit_credit`**. (The bank-statement dedup lane is bbot SP3 — not re-tested here.)
- **F-ii — callback dup-egress = 0**: a deposit bound to a timeout receiver → §ADR-9 at-least-once dispatcher retries → merchant dedups on `event_id` (WC10) → one credit, one `callback_queue` row. (Reuses the local mock-merchant.)
- **F-iii — callback dead-letter → P2.12 must-page fires**: a deposit bound to the always-500 `/fail` route → 3 attempts → `callback_queue.status='dead_letter'` → **P2.12** fires once to `#mb-alerts-p2` (fingerprint `p2.12-<row id>`). Identical pattern to the now-proven bbot L2c (owner-witnessed page).

## Design (re-scoped onto the #404-validated patterns)
- **Receiver = local mock-merchant + cloudflared tunnel** (the #404 pattern, replaces the deployed `MOCK_MERCHANT_URL`): gives real-WAN egress, the `/fail` route (F-iii), and the event log for `event_id` dedup (F-ii).
- **Client wire** = read the client seed dynamically (as the bbot run did — proven) → CF Worker HMAC → GW4 → `deposits-create`.
- **ONE X-Request-Id**, LiveCapture (the main validated `capture.ts`), modular files ≤250 lines.
- **AUTH-epic dual-purpose:** the auth front door (`auth-login` → `auth-2fa-verify` TOTP → AAL2, the #369 path) is built as a **first-class, separately-framed leg** so ONE run yields BOTH the AUTH-epic live proof and the DEPOSIT-epic live proof — supports the architect's "one run, two L5 rows" question (my journey produces both regardless of the ruling).

## The only 2 CONFIRMATIONS (not blockers — the run's L0 + auth leg will reveal either way)
1. **super_admin RBAC** still covers `admin-deposit` (upload-slip/approve) + `admin-deposit-verify-now` write-RBAC on current sinuw post-Phase-2 (Phase-1 super_admin = all perms, so expected fine; a 403 would be a real finding).
2. **`verify-now` still honors `thunder_verdict` input** on sinuw (spec-documented; expected fine).
   *(I won't pre-probe sinuw now — it's frozen for next-investigator's bbot L3 recompute. These confirm at run-time L0.)*

## Channel-realism note carried for AR6-lite (pre-existing, from the seed)
The dispatch says "client uploads slip" but the spec set documents the **admin** `upload-slip` path; the customer-facing `deposits-upload-slip` EF shape isn't in the spec set. The journey uses the admin path (as the seed did) — flagged for next-tester's AR6-lite.

**No response needed** — surfacing per your "confirm early." Building the harness now; reviewer-gated PR to follow. Will NOT run until: PR merge → AR6-lite → your signal.

— next-live-tester, 2026-06-12 14:47 +07

handled_at: 2026-06-12T19:00:00+07:00
handled_by: orchestrator-buildteam-wt26 (freeze-stale corrected; building proceeds)
