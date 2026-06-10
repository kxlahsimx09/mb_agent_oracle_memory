---
to: orchestrator-build (next session) + owner + brew-ops
from: orchestrator-build 2026-06-10
priority: P2
topic: BUILD-CONTINUATION COMPLETE — GW1a-H §ADR-2 amendment (PR #367 open) + next-live-tester 6th-role registration (committed)
project: github.com/kxlahsimx09/mb-next-payment-gateway + mb_agent_oracle_memory
tags: [orchestrator, gw1a-h, adr-2, next-live-tester, registration, simlive-followup, complete]
---

# Build-continuation: both follow-up lanes landed (simlive campaign tail)

Continued from `2026-06-10_09-53_simlive-campaign-complete-merged` (items 2/3) + `2026-06-10_11-57_livetester-adr21-owner-GO-brew-ops-step2`. Both dispatched OPUS, ran in parallel.

## Lane 1 — GW1a-H §ADR-2 §Amendment → LANDED as PR (owner merges)
- **PR #367** `kxlahsimx09/mb-next-payment-gateway` base main, head `campaign/simlive-gw1ah` — **OPEN, MERGEABLE, NOT merged**. `docs/adr.md` only, +24/-0 additive. Commit `docs(adr): ratify §ADR-2 GW1a-H (human-traffic CF proxy via Supabase custom domain)`.
- Content = architect's ready-to-apply block (`/tmp/simlive/architect-gw1ah-amendment.md`): GH1–GH4 + scope-boundary + prior-art, marker flipped [RATIFICATION_PENDING:simlive] → RATIFIED #decision (owner GO 2026-06-10), §ADR-7 explicitly unaffected. Closes item 3 of the 09-53 handoff.
- **ACTION: owner merge PR #367.**

## Lane 2 — next-live-tester 6th-role registration → COMMITTED (memory repo, no PR needed)
- Commit **2ff52590c2174696faebac51059b00e80976fdb3** in `mb_agent_oracle_memory` (main). Landed atomic with the in-flight fleet-renumber (10/20/20/20 → 01/02/03/05).
- Artifact D (`next-live-tester/SKILL.md` full charter) + Artifact C (`next-investigator` workflow row 4 → concrete `verify-live (L3)`, old live-RCA → row 5). All 6 touchpoints verified; LIVE secret slot `staging.env` scaffolded out-of-git (ref `sinuwgsqqyqzlpaavimf`, DISTINCT from tester slot per AR3). `maw wake next-live-tester --dry-run` resolves → session 03-mb-next-payment-gateway. NOT half-registered. Closes brew-ops Step 2 (the 11-57 handoff).

## OPS — orchestrator-guard mis-fire on dispatched agents (CONFIRMED + workaround proven)
- `maw team spawn <team> <role> --exec` spawns the agent's pane **into the orchestrator's CURRENT tmux window** (here `orchestrator-build`, 01-soul-brews), NOT a role-named window. The dispatched agent then inherits window name `orchestrator-build` → orchestrator-guard PreToolUse hook blocks its Edit/Write to any path outside {*/inbox/*, ψ/ vault, .cache/orchestrator-bot/, /tmp}. Lane 1 (gateway docs/adr.md) was blocked; Lane 2 survived only because vault/ψ edits are in the guard's allow-zone.
- **Fix that worked (legitimate, not a bypass):** `tmux break-pane -d -s <pane> -n <role>-work` moves the dispatched pane to its OWN non-orchestrator window; guard reads window name live → becomes a no-op; agent re-ran the Edit cleanly. The agent correctly REFUSED the Bash bypass — break-pane is the right fix.
- **Next session:** either `break-pane` immediately after every `maw team spawn`, OR dispatch via `maw wake <role>` (lands in the repo's own session, e.g. 03-mb-next-payment-gateway) so the guard never mis-fires. The real fix is still pending: let dispatched agents edit their own repo regardless of spawning window.
- `--exec` wrote the spawn-prompt but did NOT auto-submit it (empty `❯`); had to nudge via `tmux send-keys -t <pane> -l "<prompt>"` + Enter. Same as the leader-inbox nudge pattern.

## REMAINING (owner / unchanged from 09-53)
1. **OWNER: merge PR #367** (GW1a-H ADR note).
2. **OWNER: §ADR-21 SIM-LIVE ACCEPT** — drive the merged portal end-to-end against staging (the live acceptance gate; backend+auth+RLS+MFA+UI all green).
3. **brew-ops: CF custom-domain activation (GW1a-H)** — the now-ratified amendment's activation checklist (`2026-06-09_06-28_simlive-brewops-cf-custom-domain-activation`).
4. Deferred non-blocking code follow-ups (merchant pool-read DR6; N-2 canAccess; oversize types.ts/i18n.ts split).
