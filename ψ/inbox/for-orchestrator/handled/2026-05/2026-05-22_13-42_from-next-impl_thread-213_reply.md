---
from: next-impl
from_role: next-impl
to: orchestrator
to_role: orchestrator
type: reply
thread: 213
subject: suite-regression scope — hosted fixture is hard-baked to BANK_IDS[0]; non-trivial reconciliation + needs shared-hosted deploy (decision needed)
needs_response: true
priority: P2
created: 2026-05-22T13:42:00+07:00
references_inbox: for-next-impl/2026-05-22_13-28_from-orchestrator_thread-213_consult.md
handled_at: 2026-05-22T13:45:51+07:00
handled_by_thread: 213
handled_note: hosted-suite-breakage investigation; user chose A (full hosted); GO Strategy 2 + shared deploy
handled_by_inbox: /Users/dev01/.arra-oracle-v2/ψ/inbox/for-orchestrator/handled/2026-05/2026-05-22_13-45_from-orchestrator_thread-213_reply.md
---

# Suite addendum — investigated before refactoring/deploying

Full detail at **thread #213, message 913**.

## Core finding
The hosted fixture **hard-bakes every deposit statement to `BANK_IDS[0]`** (`fixture-gen.ts:694`, builder `:714-752`), explicitly relying on the deterministic stub picker. The hosted bot (`main-hosted.ts`) is deposit-blind by design (scans `scan_bank_feed` per bank). Under LRU, deposits round-robin across 3 banks and the loader fires them **concurrently** (`fixture-loader.ts:345/369`) → assigned bank is non-deterministic → ~2/3 of happy-path statements land on the wrong bank → deposits expire instead of pay → **hosted suite RED comprehensively**.

**Point 1 is half-right:** the LOCAL bot (`main.ts:100/115`) reads `system_bank_account_id` off the deposit → local suite robust under LRU. But "190/190 + 42 probes" is the HOSTED path (pre-baked feed) → not robust.

## Your 5 reconciliation points
1. Happy-path — robust LOCAL only; hosted needs re-targeting. ❌ on hosted.
2. Cluster FA1/FA2 — can't pin to one bank via API (one exclude param, 3 banks); LRU's purpose is to spread. Need cluster-count bump or test-infra bank-deactivation. ⚠️ design choice.
3. test_deposit_daily_cap — already realigned in migration B, verified pass. ✅
4. A3-late crossbank (`fixture-gen.ts:733-739`) — must set the crossbank stmt bank relative to the deposit's ACTUAL assigned bank (else the deposit may land on the stmt's bank and wrongly match). ⚠️
5. 42 probes — sweep needed once the feed model is fixed.

## Recommended fix — Strategy 2 (production-faithful)
Loader stages each `mock_bank_feed` entry to the deposit's **actual assigned bank** (from the create response, already read at `:198`). Robust to LRU + concurrency; mirrors reality. Strategy 1 (fixture-gen round-robin mirror) NOT viable (concurrent firing → non-deterministic).

## Infra/risk
`run-hosted` requires A+B deployed to the **shared** hosted Supabase (`.secrets` shared across all 7 worktrees → forward-only `db push` changes `create_deposit` for every session) + cloudflared tunnel + ~5-10 min quiescence. Want a green-light + window before that deploy, not a unilateral push.

## Decision needed
- **(A) [rec]** I implement Strategy 2 (+ FA2 + A3-crossbank relative-bank) on #225's branch, then coordinate a hosted-deploy window and run `run-hosted` → 190/190 + 42 probes. Deposit/match CODE already proven (scratch-DB test_deposit_daily_cap 3/3 + SLO RED→GREEN).
- **(B)** local suite (`run.ts`, robust under LRU) + canonical-substrate proof as the regression gate; hosted-fixture re-targeting tracked separately (no shared-hosted coupling).
- **(C)** other.

Holding on refactor + deploy pending your call.
