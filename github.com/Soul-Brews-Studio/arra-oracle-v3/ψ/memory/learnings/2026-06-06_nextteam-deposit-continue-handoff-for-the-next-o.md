---
title: NEXTTEAM DEPOSIT — CONTINUE HANDOFF for the next orchestrator session (prepared 
tags: []
created: 2026-06-06
source: orchestrator session 2026-06-03→06 end-of-session handoff; continues after DEPOSIT-003/004/005/007 sealed
project: github.com/soul-brews-studio/arra-oracle-v3
---

# NEXTTEAM DEPOSIT — CONTINUE HANDOFF for the next orchestrator session (prepared 

NEXTTEAM DEPOSIT — CONTINUE HANDOFF for the next orchestrator session (prepared 2026-06-06 GMT+7, end of the 4-slice build marathon).

=== PASTE THIS AS THE NEXT SESSION'S PROMPT ===
Continue campaign nextteam — build the remaining DEPOSIT slices.

STATE AT HANDOFF (2026-06-06): on kxlahsimx09/mb-next-payment-gateway, these DEPOSIT slices are SEALED + merged on main — DEPOSIT-001/002, 003/004, 005, 007. Two long-deferred bugs are CLOSED: the LIFO degenerate-pick bug (closed in DEPOSIT-005, fixed FIFO-oldest) and D4-11 clean-admin-approve→paid (closed in DEPOSIT-007). The build-workflow is HARDENED and live: the stack-readiness gate, the SPEC-shared-location norm (tester reads the SPEC doc from the dev PR branch), brew-ops cross-stack deploy (dev lacks tester/seal slots), the provisioned SUPABASE_ACCESS_TOKEN (EF deploy works), and the self-approve→review-body verdict convention — all in docs/build-workflow.md + the next-dev/next-tester/next-code-reviewer SKILLs.

REMAINING DEPOSIT SLICES TO BUILD, in order: DEPOSIT-008 (admin on-demand Thunder verify-now), DEPOSIT-009 (admin slip-upload force-approve gate — AU1 refused-without-marker), DEPOSIT-010 (client self-cancel → callback-silent cancelled terminal), DEPOSIT-012 (manual terminal-callback resend). For EACH slice follow docs/build-workflow.md exactly: Step 0 SPEC-first (next-dev) ∥ next-tester off the shared SPEC; verify the premise against live HEAD FIRST (much of each slice is likely already ~90% deployed, as 005 and 007 were — build only the genuine delta); relay the dev SPEC branch+path to the tester; deploy is brew-ops cross-stack to tester+seal; then VERIFY (tester → investigator seal on the isolated stack) → REVIEW (next-code-reviewer, verdict in body) → merge (§9a self-merge, owner-granted) → next-pm DoD-mark from artifacts. Finish + orphan-sweep every campaign (finish.sh leaves idle panes — kill the window after).

READ FOR FULL STATE: the retro ψ/memory/retrospectives/2026-06/05/14.00_orchestrator-nextteam-deposit-build-marathon.md + the per-slice dod-mark + epic-seal learnings (arra_search "dod-mark deposit" / "epic-seal deposit").

OPEN, NON-GATING follow-ups (carry, not urgent): F-1 (DEPOSIT-007 marker-on-clean — strip the [force-approve] marker on a clean approve OR refine the AC#45 integrity predicate to require metadata.fraud_override IS NOT NULL); reviewer perf nits.

OWNER-ONLY (do NOT self-do; escalate): §ADR-21 LIVE gate + owner ACCEPT — none of the 4 sealed slices is "epic-done" until the owner runs the per-epic LIVE acceptance. That is the user's step.
=== END PROMPT ===

WATCH-OUTS the next session should inherit: (1) Monitor on RUN-ONLY artifacts (a brand-new evidence JSON by mtime), never on text in the spec/skeleton or inherited evidence files from worktrees cut off main — false-fires bit repeatedly. (2) When gh API is flaky, trust STATE (PR MERGED + main HEAD) over command stdout. (3) A completeness-audit PARTIAL is a hypothesis — verify vs live HEAD+substrate before acting (2 of 3 dissolved last round). (4) Sequence any deferred bug into the slice that OWNS it rather than one-off fixing.

tags: [orchestrator, nextteam, continue-handoff, deposit-008, deposit-009, deposit-010, deposit-012, build-workflow, next-session, adr-21-live-gate, repo:arra-oracle-v3, mb-next-payment-gateway, fleet]

---
*Added via Oracle Learn*
