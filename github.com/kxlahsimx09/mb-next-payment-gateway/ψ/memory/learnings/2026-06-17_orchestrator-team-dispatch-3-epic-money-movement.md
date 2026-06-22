---
title: orchestrator team-dispatch — 3-epic money-movement build (TOPUP/SETTLEMENT/PULLO
tags: [orchestrator, team-dispatch, 2b, accepted, build-workflow, mb-next-payment-gateway, bias-minimization, next-dev, next-tester, next-investigator, next-pm, brew-ops, decision-authority, migration-version-collision, stack-drift]
created: 2026-06-17
source: orchestrator campaign indigo (3-epic money-movement build, 2026-06-16/17)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# orchestrator team-dispatch — 3-epic money-movement build (TOPUP/SETTLEMENT/PULLO

orchestrator team-dispatch — 3-epic money-movement build (TOPUP/SETTLEMENT/PULLOUT) on mb-next-payment-gateway, owner-driven, ACCEPTED. Pattern that worked end-to-end (campaign `indigo`→per-epic→consol, 2026-06-16/17):

PLANNING-FIRST: PM ground-truth consult (GitHub-first) → pg-writer deep gap-audit → per-epic next-architect rulings (relay every genuine SCOPE call to the owner: topup-cancel Phase-1/2, settlement batch_id defer, the PULLOUT-002 safety guard numbers) → next-writer hardening + design pass → owner-merge doc PR → THEN buildflow. Never start a buildflow before the requirements/ADR/design are hardened + merged.

BUILDFLOW per docs/build-workflow.md: next-dev SPEC-first ∥ next-tester (code-blind, separate worktree) → brew-ops CROSS-STACK deploy → stack-readiness gate → VERIFY → next-investigator RAW-TABLE seal → next-code-reviewer APPROVE → merge → next-pm marks. The de-bias earns its keep: the code-blind TOPUP tester caught a real 404-vs-409 contract bug (t002.h) from ground truth alone; the loop self-healed (dev fix → redeploy → 51/51).

DECISION-AUTHORITY: owner granted a STANDING auto-merge GO for build-CODE PRs once reviewer-APPROVE + investigator-SEAL are both green (body-header verdict, not gh state); doc/ADR PRs stay owner-merge. Relay safety-critical numbers (PULLOUT-002 guard params) to the owner with PROD grounding, not just the architect's word.

OPERATIONAL: watch the ARTIFACT not the pane vibe (SPEC-on-branch / PR-head / migration-on-stack / findings-file). brew-ops backgrounds `functions deploy` → watch the findings file, never pane-idle. Transient API-500 mid-deploy → NUDGE to resume, don't re-dispatch (nothing applied until db push). Free every teammate the moment it idles (chat-watcher keepalive flag = quota burn). Surgical per-slice deploys (drift-aside + dry-run-confirm) let builds proceed despite chronic tester/seal stack drift — but reconcile the drift eventually (it blocked the bot-queue-mark e2e until a full main@HEAD remediation).

LATENT DEFECTS surfaced only at consolidation: (1) main migration VERSION COLLISION 20260616000040 (topup_apply_not_found_404 vs v_users_read_surface — same version; fresh db push aborts; rename needed); (2) tester+seal stacks chronically behind main (9 / 17 migs). Add periodic stack-freshness + migration-version-uniqueness checks.

---
*Added via Oracle Learn*
