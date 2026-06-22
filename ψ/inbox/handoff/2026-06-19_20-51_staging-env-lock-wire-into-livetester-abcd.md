---
from: brew-ops
to: next-live-tester
date: 2026-06-19T21:15:00+07:00
topic: Staging-env lock is LIVE — wire `acquire` into the A/B/C/D journey scripts
status: mechanism merged + deployed + verified; your job = make each journey take the lock before it drives staging
tags: [#repo:cross, #fleet, #brew-ops, #handoff, #live-tester, #staging, #lock]
---

# Handoff → next-live-tester: take the staging-env lock before each journey

**Why this exists:** the 4 live-tester journey scripts (A/B/C/D) all drive the **same** staging env (sinuw). Running two at once corrupts results. Owner asked for a single-writer lock: any agent must hold it before using the env, the holder is visualized in Fleet Town, and the owner can release/seize from the UI. The mechanism is built, **merged, and live on the arra primary** — your task is the wiring.

## The tool (LIVE now)

```
$HOME/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/scripts/staging-lock.sh
```
(arra-oracle-v3 PR #137, merged → primary fast-forwarded → executable + smoke-tested. `--help` prints the full contract.)

| command | does | exit codes |
|---|---|---|
| `acquire --agent <oracle> [--campaign <c>] [--reason <r>]` | atomic O_EXCL grab; same-pane re-acquire = idempotent refresh | **0** got it · **3** HELD BY ANOTHER · 2 usage |
| `release [--agent <o>] [--force]` | drop the lock if you hold it (pane/agent match) | **0** · **4** not-the-holder |
| `steal --agent <o> [--campaign --reason]` | seize (force-replace) — ONLY after the owner approves | 0 |
| `status [--json]` | FREE / HELD-by-whom / DISABLED | 0 |

It auto-captures your `$TMUX_PANE` into the holder record so Fleet Town can attach the 🔒 staging item to your sprite while you hold it.

## What to add to EACH of A/B/C/D (drop-in pattern)

```bash
LOCK="$HOME/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/scripts/staging-lock.sh"
JOURNEY="A"   # B / C / D per script

# 1) take the lock BEFORE touching staging
if "$LOCK" acquire --agent next-live-tester --campaign "${CAMPAIGN:-livetest}" --reason "bbot-live-journey $JOURNEY"; then
  :                                  # acquired (or lock disabled → no-op success)
else
  rc=$?
  if [ "$rc" -eq 3 ]; then
    echo "STOP: staging is locked by another agent (details above)."
    "$LOCK" status                   # surface the holder to the owner
    # ASK THE OWNER — do NOT auto-seize. Wait for the decision:
    #   • owner says SEIZE → run: $LOCK steal --agent next-live-tester --reason "bbot-live-journey $JOURNEY"  → then proceed
    #   • owner says WAIT  → stop here / retry later
    exit 3
  fi
  echo "lock error (rc=$rc)"; exit "$rc"
fi

# 2) ALWAYS release — even if the journey fails or the script is killed
trap '"$LOCK" release --agent next-live-tester' EXIT

# 3) run the journey as before
#    ... existing journey-$JOURNEY steps ...
```

## Rules / gotchas

1. **Never auto-`steal`.** Exit 3 means another agent holds it → STOP, show `status`, and let the **owner** decide seize-or-wait. `steal` is only after explicit owner approval.
2. **Always release** — use the `trap '... release' EXIT` so a crashed/killed journey doesn't leave the env locked forever. (If one ever does leak, the owner force-releases from the Fleet Town 🔒 panel, or `release --force`.)
3. **Idempotent**: re-running `acquire` from the SAME pane just refreshes — it won't deadlock you against yourself.
4. **Disable mode is transparent to you.** If the owner flips the lock to DISABLED (Town UI), `acquire` returns 0 immediately (no-op) and your scripts run exactly as they did before the lock existed. So this wiring is safe to land even while the team decides whether to enforce.
5. **Pass `--agent next-live-tester`** (the oracle name) consistently — that's what shows on your sprite + in the panel.

## What you DON'T need to touch

The lock state, the file format, and the Fleet Town visualization are done. You only add the acquire/release wrapper around each journey's staging work.

## Pointers

- Contract + design: `staging-lock.sh --help`; durable note in brew-ops memory `staging-env-lock-mechanism`.
- Town viz (FYI, already live at https://town.3-1-0-33.sslip.io): while you hold the lock, a 🔒 staging item trails your sprite; owner can click it → Release / Disable.
- PRs: arra-oracle-v3 #137 (the CLI, merged), ui-studio-oracle-studio #8 (the town viz, deployed).

Questions on the contract → ping brew-ops. Owner's standing ask: wire it, then the team decides enabled-vs-disabled for the real runs.
