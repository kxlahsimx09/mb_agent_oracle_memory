---
title: #fleet #brew-ops #repo:arra-oracle-v3 #decision — Fleet-health check for parked/
tags: [fleet, brew-ops, repo:arra-oracle-v3, decision, drift, fleet-health, primary-checkout]
created: 2026-05-22
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# #fleet #brew-ops #repo:arra-oracle-v3 #decision — Fleet-health check for parked/

#fleet #brew-ops #repo:arra-oracle-v3 #decision — Fleet-health check for parked/stale primary checkouts SHIPPED (thread #204, fork PR #86, 2026-05-22).

Closes the #181 4-FIX residual gap (see sibling learning 2026-05-22_drift-fleet-brew-ops-repocross-the-181-4-f). The 4-FIX (maw-js#8, arra#85) only ff's the local <default> REF + branches fresh wts off origin/HEAD — none ever `git switch` a primary off a parked feature branch. So nothing PREVENTS a primary parking (the mb-next 9-day dark-theme drift) or going stale (the merge-then-pull-skipped deploy-gap).

DECISION (orchestrator-ratified on #204): approach (a) ALERT-ONLY, not (b) auto-switch or (c) hot-path switch.
- (b) rejected: violates P-003 (External Brain, Not Commander — tooling silently commanding the runtime); §3c.4 verify-before-discard is a human-judgment gate; a parked branch is sometimes intentional WIP/emergency (§3c.3).
- (c) rejected: FIX-1/FIX-4 run on the hot path (every spawn/resume), switching a primary's tree out from under whatever uses it is dangerous + noisy; FIX-4 operates on the worktree, not the primary.
- (a) chosen: mirrors how the inbox-watcher surfaces failed_stuck rather than auto-fixing — surface, don't command.

IMPLEMENTATION: scripts/brew-ops-bot/fleet-health.sh (sibling to detector.sh, 201 lines). Detects two modes: PARKED (on a feature branch instead of canonical) + STALE (on canonical but behind canonical upstream — catches the deploy-gap automatically). Per-primary §3c canonical map: arra-oracle-v3 + maw-js → feat/all-prs-rebased on fork; mb-next → main on origin. Telegram via existing brew-ops-bot env; dedup + parked-duration + daily re-nag + 🟢 resolved. READ-ONLY — never mutates a checkout (fetch touches only remote-tracking refs). Modes: default one-shot, --watch poll loop, --dry-run, --no-fetch. Start: nohup bash scripts/brew-ops-bot/fleet-health.sh --watch >/dev/null 2>&1 & disown.

VALIDATION: dry-run caught the live deploy-gap (both runtime primaries STALE behind 2, naming exact missing FIX commits); PARKED + dedup + re-nag + resolved tested synthetically.

FOLLOW-UPS: (1) optional operator-invoked scripts/resync-primary.sh (one-touch §3c.4 verify→stash→switch→ff) — separate PR if pursued. (2) SKILL.md "Operations infrastructure" + "Start all" → document the 4th daemon (separate .agent/central-repo commit per §3a, do at deploy time to avoid doc-ahead-of-code). (3) Layer 1 (ff both primaries + restart inbox-watcher) is HELD for explicit user ratification — [ESCALATE_TO_HUMAN:thread-204] posted by orchestrator; do not self-authorize the live-fleet touch.

---
*Added via Oracle Learn*
