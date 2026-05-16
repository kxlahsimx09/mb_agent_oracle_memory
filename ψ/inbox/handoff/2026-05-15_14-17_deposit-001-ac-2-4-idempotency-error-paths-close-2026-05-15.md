# next-impl session close 2026-05-14 → 2026-05-15

## Outcome

One PR merged. **DEPOSIT-001 AC #2-4** (Idempotency-Key error paths) closed — middleware now enforces §ADR-11 C5 architectural invariant (header required) + §ADR-11 C4 conflict semantics (409 reuse-different-body). Smoke 66/66 PASS.

## Same-arc closure

### PR merged (1)

| # | Title | Notes |
|---|---|---|
| 104 | poc-implement: DEPOSIT-001 AC #2-4 idempotency error paths — header-required + 409 reuse | Branch `poc-implement/deposit-001-ac-2-4-idempotency-error-paths-2026-05-15` |

### Substrate impact

| Component | Change |
|---|---|
| `supabase/functions/_shared/idempotency.ts` | Header REQUIRED — missing → 400 `IDEMPOTENCY_KEY_REQUIRED` *before* handler runs |
| same | Conflict 422 → **409** `IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_BODY` |
| same | `replay_pending` renamed to `IDEMPOTENCY_KEY_CONCURRENT_INFLIGHT` (shape consistency `{ code, message }`) |
| `poc/integration/src/gateway/middleware/idempotency.ts` | Local-gateway mirror — identical changes |
| `poc/integration/src/run-hosted.ts` | 3 new probe assertions for AC #2-4 (live HTTP against deposits-create) |
| `deposits-create` / `payouts-create` / `deposits-upload-slip` EFs | Redeployed with new middleware (all 3 inherit transitively) |

### Smoke verification

| SPEED | FIXTURE_DURATION_MIN | Wall | Result |
|---|---|---:|---|
| 60x | 60 | ~1m20s | **66/66 PASS** (was 63/63; +3 new probes) |

Probe results (post-quiescence on Client E):
```
pass deposit_001_ac2_header_missing — status=400 code=IDEMPOTENCY_KEY_REQUIRED row_delta=0
pass deposit_001_ac3_replay_same_body — first=201 second=201 status_match=true body_match=true row_delta=1
pass deposit_001_ac4_conflict_diff_body — second_status=409 second_code=IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_BODY
```

Evidence: `poc/integration/evidence/integration-hosted-run-2026-05-15T05-58-52-164-hosted-tiny.json`

## Durable learnings filed (this session)

| File | Topic |
|---|---|
| `2026-05-15_jsonb-key-reorder-breaks-byte-equal-cached-resp` | Postgres `jsonb` normalizes key order → cached-response byte-equal assertions fail → use sorted-key recursive stringify; AC #3 root-cause |
| `2026-05-15_adr-ratification-stale-optional-deferred-comments` | When ADR ratifies an invariant, sweep middleware for stale `// optional/TBD/deferred` comments — §ADR-11 C5 sat undetected 13 days due to drift comment |

## Pickup signal for next session

From the **2026-05-13 gap analysis learning** (`2026-05-13_epic-depositmd-vs-hosted-smoke-coverage-gap-an`), remaining P0/P1/P2:

### P0 critical drift remaining

| # | Item | Spec |
|---|---|---|
| ~~1~~ | ~~Idempotency error paths~~ | **CLOSED PR #104** |
| 2 | Duplicate stmt dedup — bot retry must not produce duplicate `ts_bank_statements` rows | DEPOSIT-002 AC #2 |
| 3 | ALREADY_FINALIZED race — two concurrent `finalize_deposit` → one wins, one rejected | DEPOSIT-002 AC #6 |
| 4 | Wallet-missing rollback — chaos test, wallet write fails mid-finalize → deposit must NOT be PAID | DEPOSIT-002 AC #7 |

### P1 high (well-scoped against single AC)

5. NO_BANK_AVAILABLE + EXCLUSION + AMOUNT_OUT_OF_RANGE error contracts (DEPOSIT-001)
6. V1+V2 force-approve override path (DEPOSIT-007)
7. 4-actor matrix slip upload (customer / client / sub-client / admin) + tenant-scope 403 (DEPOSIT-004)
8. Thunder verdict diversity (forged / system_error / timeout)
9. `deposit.expired` callback delivery + WC10 X-Maxpay-Event-Id header

### P2 medium

10. Multi-bank routing — fair-rotation + per-bank daily cap + midnight BKK reset
11. **DEPOSIT-008** admin verify-slip-now endpoint (entirely missing in PoC)
12. **DEPOSIT-012** manual resend-callback endpoint (entirely missing)
13. `v_deposits.effective_status` read-time invariant
14. Race-case admin flip-back (DEPOSIT-007 C6)

## Deferred / blocked

| Item | Reason |
|---|---|
| **dpay MCP production audit** of idempotency-key replay rate + header-missing volume | dpay MCP server disconnected mid-session 2026-05-15 ~05:00 UTC; impl-pass-grade ratification (ADR-11 + DEPOSIT-001 spec) was sufficient primary source. Audit deferred to next session when MCP reconnects. |
| **TTL-expiry / concurrent-inflight / cross-endpoint scope** test coverage | Not pinned by DEPOSIT-001 AC; out of PR #104 scope. File as P3 enhancement. |
| **AC #2-4 on payouts-create + deposits-upload-slip** | Transitive middleware fix benefits them, but no DEPOSIT-XXX user story exercises them yet. When their own story surfaces gaps, smoke probes follow. |

## User collaboration signal (this session)

- **Mid-stream role-switch + walk-back**: user said "ในฐานะ next-writer ผมอยากให้คุณรัน workflow-2" then immediately "ผิดๆ ทำต่อเลย" within 30 seconds. Stashed WIP cleanly + popped back. Pattern: descriptive `git stash` labels (mentioning branch, scope, reason for pause) make role-switch recovery trivial.
- **Ratification style**: ratified all 3 sub-questions (scope / status code / body shape) in a single "Recommended" response — same shape as prior sessions.
- **Direct execution**: "เอาตามที่แนะนำเลย" → file everything I proposed; no per-item gate.
- **Inline check-in**: "อันนี้เพิ่มเรื่อง idempotency ถูกไหม ทีนี้อธิบายให้ฟังหน่อยว่าเทสอะไรยังไงบ้าง" — wants test mechanism explanation after merge, not before. Pattern: walk-through-the-test-after-merge is a check, not a re-design ask.

## Retrospective

### What went well

- Production-data-first investigation absent dpay MCP — pivoted to ADR-11 + DEPOSIT-001 spec as primary sources; both pinned the contract precisely enough to ground impl without production data.
- Two-middleware lock-step (hosted `_shared/idempotency.ts` + local `poc/integration/src/gateway/middleware/idempotency.ts`) — both edited in same commit, both deployed/exercised; smoke validates hosted path; local path coherent for dev mode.
- Sorted-key comparator fix for AC #3 caught on first re-run + isolated cleanly (cause = Postgres jsonb canonicalization, not a real semantic mismatch). Filed as durable learning.

### What went sideways

- **Second smoke re-run silently dropped probes** — assertions phase ran in 174ms vs expected 2.4s, probes never appended to results, evidence file mysteriously missing. Third run worked. No root cause pinned — possibly Bun transpile cache or shell cwd drift (`cd poc/integration` + Claude Code shell tracking quirk). Skipped as durable learning since unreproducible.
- **Stray `poc/integration/poc/integration/evidence/` nested dir** created by `mkdir -p poc/integration/evidence` while cwd was already `poc/integration/`. Cleaned with `rm -rf poc/integration/poc`. Reminder: prefer absolute paths or verify cwd before `mkdir -p` with cross-dir paths.
- **Tooling churn during typecheck verification** — `bun add -d bun-types` then reverted when found `@types/bun` already pinned. Cost ~1 minute. Reminder: read `package.json` devDeps before installing test-tooling.

### Patterns to repeat

- ADR-spec-direct ratification when production audit blocked (dpay MCP down) — spec + ADR are sufficient ratification floor for impl pass; production audit grounds when refining "what production looks like", not when implementing a ratified invariant.
- Smoke-probe convention: live HTTP against deployed EF, run post-quiescence, use isolated test client (Client E here) whose TTL is short enough that leftover rows expire quickly + next reset clears them.
- Two-middleware-mirror lock-step: any change to `_shared/idempotency.ts` MUST mirror in `poc/integration/src/gateway/middleware/idempotency.ts` (PR diff shows both). Single source of truth would be cleaner; deferred (not arc scope).

### Patterns to avoid

- Comparing cached-via-jsonb response to live response via byte-stringify — Postgres `jsonb` normalizes key order; use sorted-key comparator.
- Trusting smoke re-runs without verifying evidence file is freshly written — second run reported `passed:63` but evidence file never landed; third run was the actual signal.

— next-impl session close 2026-05-15 ~06:30 GMT+7. PR #104 merged. P0 #1 closed; P0 #2-4 + P1 (5 items) + P2 (5 items) remain on pickup roadmap.
