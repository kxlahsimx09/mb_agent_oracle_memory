# Live-suite option flags (A · B · C · D · DEP)

> The per-suite env-var controls for [[run-live-suites]]. **toggle** → `VAR=1` when on (omit when off) ·
> **number/text/select** → `VAR=<value>`. Untouched ⇒ the **Default** column (an untouched form = the
> canonical run). Exhaustive semantics: `poc/integration/src/live/README-*-journey.md`.

## Suite A — Tri-Epic (`run-live-tri-epic.sh`)

**Epic GO toggles** — tick = run that epic's money acts; **none ticked = DRY-VALIDATE only** (provision + stop, no money):

| Env | Default | Epic |
|---|---|---|
| `OWNER_GO_LIVE_ALL` | off | AUTH+BBOT+DEPOSIT+PAYOUT+MT+KTB + enforce |
| `OWNER_GO_LIVE_AUTH` | off | ACT I — login/2FA/AAL2/RBAC/lockout/lifecycle |
| `OWNER_GO_LIVE_BBOT` | off | ACT B — bot seam: binding/dedup/OTP/telemetry/rotate |
| `OWNER_GO_LIVE_DEPOSIT` | off | ACT II — create→match→credit→MDR + faults |
| `OWNER_GO_LIVE_PAYOUT` | off | ACT III — freeze→claim→settle + reconcile/cancel/reverse |
| `OWNER_GO_LIVE_MT` | off | ACT MT — sub-client + 2nd-client + concurrency |
| `OWNER_GO_LIVE_KTB` | off | ACT KTB — second-bank dialect |
| `OWNER_GO_LIVE_ENFORCE` | off | LIGHT system-bank enforce legs (II.E/III.E/III.E3) — **NO money**, safe anytime |

**A — common:**

| Env | Type | Default | Meaning |
|---|---|---|---|
| `LIVE_DEDICATED_STACK` | toggle | off | ⚠ wipe txns at START (clean slate, keeps config). OFF = append. **Destructive — confirm with owner** |
| `RECEIVER_BASE_URL` | select | deployed `mock-merchant` | `deployed` (default) or `local` (local mock-merchant + cloudflared tunnel) |
| `KEEP_ALERTS_API` (+`KEEP_API_KEY`) | text | unset | set ⇒ confirm P2.12/P2.16/P2.17 alerts in-harness; else those faults are AMBER (page is the surface) |

> A's enforce legs (II.E/III.E/III.E3) also run *inside* a DEPOSIT/PAYOUT money run; `OWNER_GO_LIVE_ENFORCE` runs JUST them, no money.

## Suite B — Automatch (`run-live-bbot.sh`)

**Leg skips** — set `VAR=1` to SKIP that leg (default = leg RUNS):

| Env | Leg | Tests |
|---|---|---|
| `SKIP_PARK` | L1g | DEPOSIT-005 cross-client → review |
| `SKIP_DEGEN` | L1g2 | DEPOSIT-005 AC-2 same-client auto-pick-oldest |
| `SKIP_EXPIRE` | L1h | DEPOSIT-003 slip-less sweep |
| `SKIP_DEP_IDEM` | L1m | CLIENT-001 / §ADR-11 |
| `SKIP_DEP_CANCEL` | L1j | DEPOSIT-010 (AAL2 gotrue + tenant scope) |
| `SKIP_MDR` | L1n | WALLET-003/007 satang-exact |
| `SKIP_CBSIG` | L1i | CALLBACK-002 WC1/WC8/WC10 |
| `SKIP_WITHDRAW` | L4/L4b | outbound real-bot payout |
| `SKIP_STALE` | L4f | PAYOUT-008 sweep |
| `SKIP_MAINT` | L4m | PAYOUT-010 bank-maintenance sweep |
| `SKIP_PAY_IDEM` | L4k | CLIENT-001 / §ADR-11 |
| `SKIP_DEADLETTER` | L2c | P2.12 must-page (~2 min; needs failing-callback) |

**B — tunables:**

| Env | Type | Default | Meaning |
|---|---|---|---|
| `DEPOSIT_COUNT` | number | `3` | total deposits (anchor + batch). `1` ⇒ L1f batch SKIPPED |
| `WITHDRAW_COUNT` | number | `3` | payouts in the SCB batch. `1` ⇒ single L4 lane (not L4b batch) |
| `WITHDRAW_AMOUNT` | number | random `1200–1799` | pin payout amount (else auto, avoiding stale-collision set) |
| `ROTATE_STRETCH` | toggle | off | L3 mid-journey bot-credential rotate (opt-in; leaves bot on retiring key — coordinate) |
| `BBOT_MINIMIZE_CAST` | toggle | off | prune staging admin view to the bbot cast (deletes olive/tri-epic cast — **DO NOT run concurrent with Suite A**) |
| `CALLBACK_FAIL_PATH` | text | `/fail` | the always-500 route the dead-letter leg binds to |

## Suite C — Restart (`run-live-bbot-restart.sh`)

| Env | Leg | Tests |
|---|---|---|
| `SKIP_DUPFAULT` | L2a-dup-fault | SP3 restart → dup-credit = 0 |
| `SKIP_RECONCILE` | P1+P2 | III.5 stuck-reconcile + amount-mismatch |

> Needs `BOT_RESTART_CMD` preset (a brew-ops runbook cmd, e.g. `aws ecs stop-task …`) + `remote` bot
> mode; absent ⇒ the restart legs honest-SKIP. `BOT_RESTART_CMD`/`BBOT_SERVICE`/`BBOT_PAYOUT_SERVICE`
> are **environment presets** (run-live-suites §5), not per-run toggles.

## Suite D — Fair-router (`run-live-bbot-fairrouter.sh`)

| Env | Type | Default | Meaning |
|---|---|---|---|
| `FAIRROUTER_N` | number | `9` | tx per lane (≥3; 9 = 3/account) |
| `FAIRROUTER_CLAIM` | select | `drive` | `drive` = harness claims (fast; rows sit 'claimed') · `observe` = wait for real bots' ~6-min metronome (full E2E, up to ~20 min) |
| `FAIRROUTER_FORCE_SETTLE` | toggle | off | drive `mark_success` so the FRP3 payout.success-callback leg asserts in ~80s (vs `observe`) |
| `FAIRROUTER_CROSSBANK` | toggle | off | mixed pool = 3 SCB + 1 KTB (payout-only) → method-aware routing + FRX gate (needs `crossBank.ktbAccounts[]`) |
| `FAIRROUTER_FUND_FLOOR` | number | `0` | raise each fleet bank balance to ≥ floor (claim-budget gate); 0 = leave brew-ops funded |
| `FAIRROUTER_NO_EQUALIZE` | toggle | off | skip zeroing LRU counters (default zeroes them so spread is crisp) |
| `SKIP_DEPOSIT` | toggle | off | run payout lane only |
| `SKIP_PAYOUT` | toggle | off | run deposit lane only |

> Needs the 3-account fleet (`scb-fleet.json`) up; absent/<3 ⇒ legs honest-SKIP (BLOCKED).

## Suite DEP — Deposit golden (`run-live-deposit.sh`)

| Env | Type | Default | Meaning |
|---|---|---|---|
| `OWNER_GO_LIVE_DEPOSIT` | toggle | off | **required** to do anything (else DRY-VALIDATE) |
| `KEEP_ALERTS_API` (+`KEEP_API_KEY`) | text | unset | confirm the F-iii P2.12 alert in-harness |
