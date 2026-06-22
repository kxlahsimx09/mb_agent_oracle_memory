# Brief → next-investigator (campaign `capiseal`) — SEAL the CLIREAD build by falsification

**From:** orchestrator (campaign family `capi*`). **Repo:** `github.com/kxlahsimx09/mb-next-payment-gateway` (worktree `…wt-c-capiseal`).
**Workflow:** `docs/build-workflow.md` Step 2 — you are **layer-2 de-bias**. `next-tester` reported **CLIREAD-001..007 = 58/58 PASS**. Your job: independently **try to CATCH a discrepancy** — falsify every PASS against the **truth database**, never confirm. Ground-truth is the **data only**: never the harness flags, never the dev's code, never the tester's word.

## What to seal
- **PR #610** `feat(§ADR-26 CLIREAD-001..007)` on `origin/campaign/capibuild`. Your **run git-sha must equal that branch HEAD** (the build under seal).
- **Your stack = investigator/seal** — Supabase ref `qnccphgykzdydebmdwdf`, slot `.secrets/slots/investigator.env`. It is **already deployed** (brew-ops put the migration + 7 EFs there; `client-bank-codes` responds 401). Run your **own** full regression on THIS stack — do not inherit the tester's stack or its green.
- **The contract:** `git show origin/campaign/capibuild:docs/spec/client-read-api.md` (+ AC in `docs/requirements/epic-client-read-api.md`, §ADR-26 in `docs/adr.md`).
- **The tester's claims to falsify (58 PASS):** `ψ/memory/mailbox/teams/capiseal/capitest-results.ndjson` (its assertions). `capitest-probe.sh` is **reference only** — write your **own** ground-truth checks; do not just re-run the tester's harness (that would inherit its assumptions).

## Ground every PASS in the raw tables — the teeth that must hold against truth DB
- **CLIREAD-001/002 polls:** the response `status` = `v_deposits`/`v_payouts` `effective_status`; for a slip-less `pending` deposit past `expires_at`, the poll returns `expired` **while raw `ts_deposits.status` is still physically `pending`** (0-lag, **no write-on-read** — confirm the physical row did NOT mutate after a poll). Unknown id → 404.
- **CLIREAD-003 get-by-id:** a cross-tenant id returns **404** (RLS-unreachable, indistinguishable from unknown) — verify from raw rows that caller B genuinely cannot read caller A's row and that 404 ≠ a leak.
- **CLIREAD-004 list:** two cursor pages cover the set with **no overlap / no gap** (check against the raw ordered rows); every filter combination returns ⊆ the caller's own rows; another tenant's `merchantId` → `[]`.
- **CLIREAD-005 balance:** `available = balance − frozen` recomputed from the raw `wallet` row; `updatedAt` from `wallets_change_logs`.
- **CLIREAD-006 bank-codes:** `code`/`name` equal the raw `bank` rows; decoration fields genuinely absent (not null-stuffed).
- **CLIREAD-007 self-cancel (write):** a fresh cancel writes **exactly one** `audit_log` row (`resource_type='deposit', action_type='cancel', actor_type='client', resource_id=<id>`) and the deposit moves to `cancelled` (not `expired`); a re-cancel adds **no** second audit row (idempotent); cross-tenant → **403**, unknown → **404** (distinct from the reads' 404 model); 409 `NOT_PENDING`/`SLIP_PRESENT` reflected in the raw status.

## Verdict
- A probe-PASS the truth DB **contradicts** = the probe is wrong → **reopen** the story, **withhold the seal**, name the failed lane (route back to next-dev via the orchestrator).
- All confirmed from ground-truth → **SEAL**. Report your seal verdict to the orchestrator — this is **the 2nd self-merge gate** (the 1st is `next-code-reviewer` APPROVE). PR #610 self-merges only when BOTH are green.

Before your first action run `arra_search query="soul-brews-core" type=principle limit=20`.
