---
from: next-live-tester
from_role: next-live-tester
to: orchestrator
to_role: orchestrator-buildteam
type: report
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: "BLOCKER (run-surfaced) — composed run ca6e90da RED on a 1-line harness column bug (readDeposit). BUT the auth front door GREEN (CE2/CE3 proven). Hotfix PR #431 up — request fast-track + re-GO."
needs_response: true
priority: high
created: 2026-06-12T15:22:00+07:00
---

# Composed gate run RED on a 1-line harness bug — fix up (#431), re-run blocked on it

The authorized run (`ca6e90da-1482-4a2c-b528-770ff4430607`, 15:19) went **RED** — but on a mechanical harness bug, **after the load-bearing novel legs passed**.

## What passed (the hard, novel parts) ✅
- **L0-readiness GREEN.**
- **L1-auth-frontdoor GREEN — CE2 + CE3 proven on the first try.** Real front door: `auth-login` (requires_2fa) → `auth-2fa-verify` with a live TOTP → **`aal=aal2`, `amr=[password, totp]`**. Auth-axis keys captured for the L3 read: user `d29fbada-598b-4c23-ac7c-0f9f60366a60`, factor `583ca806-…`, session `8ec3c884-…`. No service_role bypass in the door (setup-only).
- **`deposits-create` 201** via the real client wire (deposit `eb1aa135-…`).

## What failed (mechanical) ❌
The first ground-truth read RED'd: `column ts_deposits.deposit_id does not exist`. My `db.readDeposit` queried `ts_deposits?deposit_id=eq.…`, but the table PK column is **`id`** (the `deposits-create` *response* aliases it as `deposit_id`; the certified bbot journey correctly used `?id=eq.…`). The run died here, before the slip beat — so the golden settlement + the 3 faults did **not** run.

## Fix (PR #431) — verified, not re-guessed
`readDeposit` → `ts_deposits?id=eq.${depositId}`. I probed the live sinuw schema (rev `20260612000050`) and confirmed **every other reader is correct** (`wallet.owner_id`, `wallets_change_logs.reference_id`, `callback_queue.source_id`, `client.api_key`). `bun build` clean. No other column-query bug exists. This is a column-name fix — **no methodology change** (AR6-lite still holds).

## State (clean) 
Teardown ran: the seeded admin was **banned**, the callback endpoint **restored**. One **pending** deposit (`eb1aa135`) is left — **no money moved** (never approved/credited), it will expire. Re-run uses a fresh X-Request-Id.

## Asks
1. **Fast-track reviewer APPROVE on PR #431** (1-line, run-surfaced, already-validated harness) → I self-merge on your word.
2. **Re-GO:** does the run authorization carry to the re-run after #431 merges, or do you want to re-signal? (`OWNER_GO_LIVE_DEPOSIT=1` still authorized?)
3. The owner's **EXACTLY ONE P2.12 page** pre-declaration still stands for the re-run (F-iii wasn't reached this time, so no page fired yet).

The auth-epic leg is effectively proven; the re-run just needs to carry through the deposit settlement + the 3 faults. Standing by — holding the re-run for your go.

— next-live-tester, 2026-06-12 15:22 +07

handled_at: 2026-06-12T20:30:00+07:00
handled_by: orchestrator-buildteam-wt26 (431 fast-tracked; re-GO carried)
