---
title: ## Smell-class RECURRENCE (same day) — "(PR #N merge pending)" markers in bindin
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, request-changes, stale-marker, recurrence, bank-bot, sim-portal, adr-21, gotcha]
created: 2026-06-11
source: PR #391 f80caa3 + PR #381 da6d783 re-reviews 2026-06-11; thread #13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ## Smell-class RECURRENCE (same day) — "(PR #N merge pending)" markers in bindin

## Smell-class RECURRENCE (same day) — "(PR #N merge pending)" markers in binding docs: the class re-fired against a DIFFERENT gating PR within hours; root cause is authoring-time state written into merge-time artifacts

Follow-up to the 2026-06-11 "parallel-lane doc PRs go stale" learning (PRs #391/#381, bankbot campaign). After the writer correctly stripped the stale #389 markers on re-push (f80caa3), the SAME class re-appeared in the SAME PR against #396 (§ADR-21 SP1–SP6): the new sim slice cited its PRIMARY binding source as "PR #396 … merge pending" while #396 had merged at 04:13:00Z — six minutes BEFORE the writer's own thread note asserting it was "genuinely open" (thread #13 msg 56). A literal race: the gating PR merged between authoring and push.

Generalizations for the reviewer:
1. **Merge-state text in a doc is a liveness bug by construction.** Any "(PR #N pending)" phrase is a snapshot of a moving fact. In an active campaign where the owner merges ratification PRs within hours, the snapshot's half-life is shorter than a doc PR's review cycle. The durable citation form is "§X §Amendment YYYY-MM-DD (ratified #decision via owner GO)" + the ADR revision log as the merge ledger — no PR state at all.
2. **Reviewer check is mechanical:** `grep -c "pending" <diff>` then `gh pr view <N> --json state,mergedAt` for every PR number named in a marker. Cheap, catches the race every time.
3. **The epic-side analogue:** v1-framing leftovers in at-a-glance tables (PR #381 round 2: BBOT-007/008/009 "Cross-repo: gateway only" rows surviving from the superseded fixture-post model while the reworked BBOT-005 row was updated and SP5 pinned the component bot-repo-side). When a rework supersedes a framing, sweep the TABLES, not just the story bodies — tables are where stale framing hides because each cell reads plausible in isolation.
4. Recommended to the fleet on thread #13: re-verify merge state of every PR named in binding_sources AT PUSH TIME, or stop writing merge-state into specs entirely.

Both round-2 re-reviews: REQUEST-CHANGES with exactly ONE item each (4 phrases / 3 table cells), everything else verified pin-for-pin vs merged SP1–SP6 + BK1–BK7 at HEAD.

Source: PR https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/391 (f80caa3) + /pull/381 (da6d783) re-reviews 2026-06-11; docs/adr.md@1c3d283; thread #13 msgs 50-56.

---
*Added via Oracle Learn*
