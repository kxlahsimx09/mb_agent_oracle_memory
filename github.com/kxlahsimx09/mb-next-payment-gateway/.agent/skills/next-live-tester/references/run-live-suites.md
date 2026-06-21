# Running the live suites (A · B · C · D · DEP)

> The actionable playbook for driving any of the 5 live-tester journeys on the shared
> **staging** stack. Codifies the `next-live-tester` run contract (handoff
> `ψ/inbox/handoff/2026-06-20_09-38_live-tester-run-ui-spec-for-fleet-town.md`,
> reconciled with payment-gateway PR #649). Flag tables: [[run-live-suite-flags]].
> **Exhaustive source of truth** = `poc/integration/src/live/README-{bbot,restart,fairrouter,tri-epic,deposit}-journey.md` — read the suite's README before a first run.

All launchers live in `poc/integration/` (cwd) and source the staging slot
`../../.secrets/slots/staging.env`. I am **CODE-BLIND** (SKILL §0) — I run the launcher
and read its evidence; I never read gateway/EF/migration code.

## 0. Lock the env FIRST — one run at a time (reuse `staging-lock.sh`, brew-ops #137)

The shared staging env (sinuw) is **single-writer**: two suites at once corrupt results.
The launchers already self-acquire the lock (PR #637: `acquire --agent next-live-tester … ; trap release EXIT`), so **I do not take the lock by hand** — launching does it. My job is to **respect it**:

```bash
LOCK="$HOME/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/scripts/staging-lock.sh"
"$LOCK" status            # before launching — is the env free?
```
- **FREE** → launch (the launcher acquires + holds it for the run; Fleet Town shows the 🪙 chest trailing my sprite).
- **HELD by another agent** (or a launch exits **3**) → **STOP, surface the holder to the owner, and ask: seize or wait?**
  - owner says **seize** → `"$LOCK" steal --agent next-live-tester --campaign "$CAMPAIGN" --reason "<suite>"` then relaunch.
  - owner says **wait** → wait / retry later. **Never auto-steal.**
- `CAMPAIGN` (free-text, default `livetest`) flows to `--campaign` for the holder card.
- The owner can force-release / toggle disable from the Fleet Town 🔒 panel; a stale lock from a crashed run is recoverable there.

## 1. The 5 suites (pick one)

| Suite | Launcher | Exercises | ~Runtime | Gate |
|---|---|---|---|---|
| **A — Tri-Epic** | `run-live-tri-epic.sh` | full multi-tenant: AUTH+BANK-BOT+DEPOSIT+PAYOUT+MT+KTB + system-bank ENFORCE | 5–20 min | **OWNER-GATED money** (per-epic `OWNER_GO_*`); none set ⇒ DRY-VALIDATE |
| **B — Automatch** | `run-live-bbot.sh` | statement auto-match golden + deposit/payout coverage via the real deployed bot | ~15 min | SIM money, synthetic accts — runs legs directly |
| **C — Restart** | `run-live-bbot-restart.sh` | bank-bot crash-restart dedup + orphaned-claim reconcile (only suite that restarts the bot) | ~10–15 min | needs `BOT_RESTART_CMD` preset + `remote` bot mode, else legs honest-SKIP |
| **D — Fair-router** | `run-live-bbot-fairrouter.sh` | multi-bank LRU distribution + per-login isolation (+ cross-bank, callback-delivery) | ~10–25 min | needs the 3-account fleet (`scb-fleet.json`); <3 ⇒ honest-SKIP |
| **DEP — Deposit golden** | `run-live-deposit.sh` | standalone DEPOSIT+AUTH slip→finalize | ~5 min | **OWNER-GATED** (`OWNER_GO_LIVE_DEPOSIT`); unset ⇒ DRY-VALIDATE |

**Visibility gate:** A and DEP move real (SIM) money on the shared stack — they stay behind
my live-tester-only scope + the lock. B/C/D are SIM/idempotent on synthetic accounts (gate
them by who runs them, not a flag).

## 2. Run recipe (the launch contract)

1. Resolve suite → its `run-live-*.sh` (cwd `poc/integration`).
2. Build the env from the chosen options ([[run-live-suite-flags]]): toggles → `VAR=1` (omit when off);
   numbers/text/selects → `VAR=<value>`. Leave a control untouched ⇒ its default (an **untouched form = the canonical run**).
3. `"$LOCK" status` → if free, exec the launcher **as next-live-tester** with that env (it self-acquires/-releases the lock):
   ```bash
   cd poc/integration
   OWNER_GO_LIVE_DEPOSIT=1 ./run-live-tri-epic.sh      # example: A, DEPOSIT epic only
   DEPOSIT_COUNT=5 SKIP_WITHDRAW=1 ./run-live-bbot.sh   # example: B, 5 deposits, no withdraw lane
   ```
4. Stream the launcher's structured-JSON beats; on exit read the per-leg `legs.json`
   (GREEN/AMBER/RED/SKIPPED) + the evidence dir link.
5. **Exit codes:** `0` = ran (read legs for colours) · `2` = bad config/slot · `3` = lock held by
   another (surface holder → seize/wait) · other = harness error.

## 3. Verdict model — I RUN, I never PASS/FAIL (§ADR-21)

The harness **records evidence; it never declares PASS/FAIL.** Each leg emits a colour into
`legs.json`; the **verdict is `next-investigator`'s L3 raw-table recount** (independence rule AR2,
SKILL §5). I present results as **"ran + per-leg colour"**, never "passed". I hand the stamped
`X-Request-Id` + artifacts to the investigator (envelope-first; a thread reply with no envelope is a
silent stall). Evidence is append-only under
`poc/integration/evidence/live/<epic>/<X-Request-Id>/` (manifest.json + per-beat json + png + trace/video).

## 4. Guardrails (bake into every run)

- **`OWNER_GO_*` (A) and DEP move SIM money on the shared stack** — keep behind live-tester scope + the lock.
- **`LIVE_DEDICATED_STACK=1` wipes staging transactions** at START — destructive; **confirm with the owner** before setting, gate to dedicated runs only. OFF = append mode.
- **One run at a time** — the lock enforces it; reflect HELD, do not queue a 2nd launch.
- **`BBOT_MINIMIZE_CAST` (B) ⨯ Suite A are mutually exclusive** — B's minimize prunes A's cast; never run them concurrently / warn if A ran recently.
- **C/D may honest-SKIP** when their preset/fleet prerequisites are absent — a SKIP is honest, not a failure; surface it, don't fake-green it.

## 5. Environment — PRESET by brew-ops, NOT user toggles

Read from the staging slot / fleet config / runbook; fixed per environment, never typed per run:
slot secrets/URLs (`SLOT`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `CF_WORKER_URL`,
`PORTAL_BASE_URL`, `SIM_CONTROL_SECRET`, `SCB_FLEET_FILE`, `KTB_PORTAL_BASE_URL`, …), levers
(`BOT_RESTART_CMD`, `BOT_LOG_CMD`, `PORTAL_DESCRIBE_CMD`, `BBOT_SERVICE`, `BBOT_PAYOUT_SERVICE`),
and mode (`BOT_MODE` = `spawn`|`remote`, auto-`remote` when `PORTAL_BASE_URL` set; `BOT_POLL_MS`).
`LIVE_SMOKE=portal` = local-only smoke, **not** a gate run — don't expose it as a normal option.

Questions on a flag's exact semantics → `arra_thread` to `next-live-tester` (the suite owner).
