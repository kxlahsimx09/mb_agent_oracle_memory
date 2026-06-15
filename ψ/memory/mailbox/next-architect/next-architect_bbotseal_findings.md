# next-architect — bbotseal findings: F1 BS-2 error-shape disposition

**Date:** 2026-06-12 · **Campaign:** bbotseal · **Branch:** campaign/bbotseal (shared worktree)
**Co-worker:** next-investigator (bank-bot epic-seal, same worktree) — they name this F1 item as pending.

## TL;DR — DISPOSED, option (b)

F1 BS-2 error-shape question is **resolved**. The gateway's existing **HTTP 500
`submit_statements_failed` + no-silent-insert (inserted≠1)** is the **RATIFIED Phase-1
behavior**. The graceful 4xx `bad_statement_date_bkk` that the `bk-auth.ts` BS-2 intake legs
assert is **NOT ratified** and **CONTRADICTS the contract of record**. → **F1 BS-2 is NOT a
blocker** to the bank-bot-integration epic close. Residual = a mechanical **probe rebind**
owned by next-tester (routed via ψ inbox).

## What was verified (source-level, at HEAD origin/main e69bc76)

- `supabase/functions/bot-statements/index.ts:47` — `if (inserted.error) return json({ error: "submit_statements_failed" }, 500)`. Clean shape, **no `detail` leak** → already §5-conformant. (The `poc/integration/src/gateway/handlers/bot.ts:55` handler still leaks `detail`, but PoC is P-001-frozen / non-gate — gap G-8.)
- Migration `20260611000200` (PR #409) — `submit_statements_batch` + `_bkk_minute_to_ts` **DO raise the labeled `bad_statement_date_bkk`** for both legs (leg i: `jsonb_typeof(statement_date_bkk) <> 'number'`; leg ii: `statement_date_bkk IS NULL`). It is a **PL/pgSQL EXCEPTION inside the RPC**, surfaced to the EF as `inserted.error` and collapsed to the opaque §5 500.
- `tests/integration/probes/bbot/bk-auth.ts` lines 87–116 — leg (i) asserts `status>=400 && <500 && body.includes("bad_statement_date_bkk")`; leg (ii) asserts `status>=400 && <500 && inserted!==1`. Both go RED purely on the 4xx-vs-500 half (leg ii's `inserted!==1` / no-silent-insert half is already satisfied — `inserted=-1` is the probe's sentinel for "500 body, no inserted count").
- EF + migration are **byte-identical to origin/main** (`git diff --stat origin/main` empty).

## Authority chain (why 500 is ratified, 4xx is not)

1. **`docs/design/deposit-lane/bot-gateway-contract.md` §6 step 6** (binding, 2026-05-05): *"If RPC raises exception → return 500 with error code (do not leak SQL detail)."* Steps 2–3 (the only 400 paths) are **envelope** schema/type validation; a per-row date value is not an envelope field → falls to step 6 → **500**.
2. **`docs/spec/bbot-adapter-endpoints-slice.md` §3** push Errors enumeration: `400 invalid_json / missing_or_invalid_fields · 413 batch_too_large · 401/403 · 500 per §5` — **no** 4xx `bad_statement_date_bkk`.
3. **§5**: binding 500 shape `{error:"submit_statements_failed"}`, opaque; *"the bot treats any 500 as a failed tick … never parses detail."* §7 test-plan candidate `test_submit_endpoint_returns_500_on_rpc_exception_no_sql_leak` asserts **500**.

## Why (b) not (a)

- BS-2 is a **bot-side binding invariant** (BS-1..5) — the bot MUST send int64. A violation is a bot bug, not a supported input class owed a friendly gateway error. Post-#409 the real bot sends int64 → a 4xx `bad_statement_date_bkk` has **no production consumer**.
- The only **epic-critical** property — *no silent insert* (money-safety) — is already GREEN (RPC RAISE / NOT-NULL ⇒ `inserted≠1`). The 500 **is** the fail-loud.
- (a) would expand a ratified wire contract for a consumer-less label, need an **owner-merged** ADR amendment (can't close today), and break §5 uniformity. (b) is spec-faithful, needs no substrate change, and is reversible (Phase-2 can still add the 4xx if monitoring ever demands it).

## Deliverables

1. **PR (DO NOT MERGE):** `arch/bbot-f1-bs2-disposition` off `origin/main` — docs/test-index.md note (§F1 BS-2 disposition + updated bk-auth.ts row). PR #<filled in summary>.
2. **ψ inbox envelope → next-tester:** probe-rebind guidance (drop the 4xx + `bad_statement_date_bkk` substring checks; assert 500 `submit_statements_failed` + no-silent-insert; leave cursor-int64 echo leg alone).
3. This findings file.

## For next-investigator (epic-seal)

Cite this disposition as resolving the pending **F1 BS-2** item. It is **not** a gate blocker.
The residual is a mechanical probe rebind (next-tester), tracked in the PR + ψ envelope —
not a substrate/EF defect. No coordination conflict: I touched only a fresh branch off main
(dedicated worktree /tmp/wt-arch-f1bs2) + this scratch file; the shared worktree is untouched.

## Phase-2 PARKED (non-gate, no owner)

If bot-input-drift observability (e.g. monitor-003 P2.8 "POST 4xx") later warrants
classifying client-input errors apart from server faults, a dev MAY surface the RPC's
already-emitted `bad_statement_date_bkk` as a **400** — but that needs its own ADR amendment
+ endpoints-slice §3 enumeration edit. Out of scope for the epic seal.
