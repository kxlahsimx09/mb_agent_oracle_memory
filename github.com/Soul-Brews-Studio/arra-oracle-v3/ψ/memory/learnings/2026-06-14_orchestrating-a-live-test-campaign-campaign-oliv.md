---
title: Orchestrating a LIVE-test campaign (campaign `olive`, tri-epic AUTH+DEPOSIT+PAYO
tags: [orchestrator, live-test, adr-21, team-dispatch, send-keys, bank-bot, mock-portal, decision-authority, tri-epic, mb-next-payment-gateway]
created: 2026-06-14
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Orchestrating a LIVE-test campaign (campaign `olive`, tri-epic AUTH+DEPOSIT+PAYO

Orchestrating a LIVE-test campaign (campaign `olive`, tri-epic AUTH+DEPOSIT+PAYOUT, 2026-06-13/14) — durable lessons:

1. **`maw team send` does NOT wake an IDLE TUI agent.** Messages sent via `maw team send` to an idle teammate do not become an actionable turn — the agent sat at a HOLD banner for 39 min. The reliable wake is `tmux send-keys -t <pane> -l "<text>"` then a SEPARATE `tmux send-keys -t <pane> Enter` (the team-dispatch-helper's kickoff method). Always capture-pane AFTER to confirm it submitted (transitioned to "esc to interrupt"). Auto-suggest GHOST TEXT can appear at the `❯` prompt (e.g. a prior command) — it is NOT real unsubmitted input; do not try to "submit" it.

2. **`errors:0` in a run log is NOT semantic GREEN.** A leg can complete without throwing yet be wrong (payout settle=0, claim_withdrawal_items claimed:0). Only the investigator's L3 raw-table recount is the authoritative verdict (ADR-21). Read run-log CONTENT + verify business outcomes, not error counts or legs.json flags.

3. **A gateway-wire tri-epic LIVE run does NOT prove the bank-bot↔mock-portal intake seam.** The tri-epic harness `bot-driver.ts` mints a bot credential + POSTs fabricated statements straight to `bot-statements` ("without needing the AWS portal stack") and claims payouts via service_role RPC — it bypasses the real `mb-next-bank-bot` (ECS Fargate) scraping the mock portal (`/sim/inject` → bot scrapes BANK_URL→mock → bot POSTs). For a full-topology LIVE sign-off, route deposits through the bbot-journey path (PORTAL_BASE_URL + SIM_CONTROL_SECRET + a current ECS bot), not the harness-as-bot shortcut. Owner (2026-06-14) requires real-bot+portal fidelity and wants the live sign-off COMBINED with the bank-bot epic.

4. **Triage rule that kept the build-workflow clean:** RED legs from HARNESS/FIXTURE gaps are the live-tester's to fix in its own harness + re-run; ONLY a genuine DEPLOYED-code defect bounces to next-dev. Pre-sending this rule prevented spawning next-dev for the 6 runs of harness gaps; the one real product defect (D-1: admin_approve_paid omits partner mdr_distribute WCL rows) surfaced cleanly from the L3 recount.

5. **Decision-authority:** this owner pre-grants owner-GO for SIM money runs once the harness is built + readiness green (do not make them a per-run bottleneck), but a REAL-BANK / full-topology run still needs explicit scope confirmation. Owner prefers a FRESH team per task (do not reuse idle agents from a prior campaign).

6. **Session-close safety:** `team-dispatch-finish.sh` uses `git worktree remove --force` which DELETES uncommitted run evidence — violates "never --force" + "Nothing is Deleted". To pause-and-resume, use `maw team shutdown <slug> --merge` (closes agents + copies findings to mailbox) and LEAVE the worktree intact.

---
*Added via Oracle Learn*
