---
title: orchestrator team-dispatch — "run a never-run LIVE-test gate to green + independ
tags: [orchestrator, team-dispatch, accepted, live-test, adr-21, l3-verification, discrimination-before-dispatch, happy-path-masking, close-idle-teammates, quota, money-safety]
created: 2026-06-16
source: orchestrator session 2026-06-15→16; campaigns livepass/liveenv/livedev/livel3; §ADR-21 quad-epic LIVE 0 RED + L3 PASS; PRs #524/#525
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator team-dispatch — "run a never-run LIVE-test gate to green + independ

orchestrator team-dispatch — "run a never-run LIVE-test gate to green + independent-verify" request shape, AUTO-dispatched, user-ACCEPTED (with one quota correction). Reusable plays that worked:

1. DISCRIMINATION-BEFORE-DISPATCH: when the tester localized the payout failure as "gateway-side claim cooldown", do NOT dispatch next-dev to fix — dispatch it to ADJUDICATE (intended vs defect). It proved INTENDED (one-batch-per-bank lock GAP-7 + 5-min stale-sweep); 0 gateway bugs. Routing the symptom blind would have chased a non-bug. Verify premise (§2.5), let the owning expert render the verdict (principle 2a).
2. RUNNER ≠ GRADER / L3 catches happy-path-masking: the tester flagged that conservation snapshots were keyed on inert CAST partner wallets while real money moved through SEEDED recipients. next-investigator's independent raw-table recount on the REAL recipients CONSERVED to the satang — that is what makes the 37G/0R trustworthy. Always run L3 before calling a live gate "passed".
3. CLOSE IDLE TEAMMATES IMMEDIATELY: leaving brew-ops/next-dev/tester idle overnight burned shared account quota and is the suspected cause of next-investigator hitting the session limit mid-L3. Close on DONE-WHEN. CRITICAL: team-dispatch-finish.sh merges knowledge + removes the worktree but does NOT kill the helper-spawned claude process — must ALSO `tmux kill-pane` (verify with `pgrep -af "claude --agent-id"`). Keep the worktree (kill only the process) if a live consumer still needs its files (e.g. investigator reading the tester's evidence dir).
4. MONITORING: background Bash polling the findings-file mtime + pane-idle, re-invoking on completion, survived ~40-min live runs and an overnight session-limit gap. Do NOT grep the pane for "BLOCKER:" — the dispatch contract contains those tokens (false positives); the findings file is the signal.

---
*Added via Oracle Learn*
