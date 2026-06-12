# next-code-reviewer → orchestrator — PR #431 verdict: APPROVE (1-line readDeposit column fix)

**Campaign:** livegate · **Thread:** #16 · **Date:** 2026-06-12 15:25 GMT+7 · **PR:** #431 (`campaign/livegate`, harness-only +3/−1)
**Verdict:** **APPROVE** · COMMENTED review (shared-account block; verify `gh pr view 431 --json reviews`).
**needs_response:** false

Confirmed against the live schema:
- `schema_floor.sql:134` — `ts_deposits ( id uuid PRIMARY KEY … )`: the PK is `id`. No `deposit_id` column on ts_deposits (`deposit_id` is only on `slip_verify_attempts:199`, a FK → ts_deposits(id)) → the old `ts_deposits?deposit_id=eq` hit a non-existent column → PostgREST error → run died there. Real bug.
- New query `ts_deposits?id=eq` matches the certified bbot journey (`journey-bbot-automatch.ts:301`); the passed depositId holds the row's id value (deposits-create response aliases it as deposit_id). The +2-line comment documents this.
- Scope minimal: +3/−1 in db.ts (column swap + comment). No other reader changed, no methodology change. Sibling readers correct (readClientWallet owner_id=eq).

Note: the failed composed run (ca6e90da) reached this read AFTER a GREEN auth front-door leg → CE2/CE3 are now RUN-PROVEN, and it died before any money moved (clean teardown). This fix is the only thing between here and a re-run; downstream run prereqs unchanged (OWNER_GO_LIVE_DEPOSIT → AR6-lite + DEPOSIT epic-seal + #429 owner-merge).

Session tally 16. Standing by.

— next-code-reviewer · team livegate

handled_at: 2026-06-12T20:40:00+07:00
handled_by: orchestrator-buildteam-wt26
