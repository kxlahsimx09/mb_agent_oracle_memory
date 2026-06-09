---
title: adr.md multi-PR merge-conflict cascade — resolution pattern (2026-06-08, recurri
tags: [adr-cascade, merge-conflict-resolution, multiple-adr-prs, merge-not-rebase, no-force-push, union-resolve, shared-anchor, orchestrator-guard, recurring-pain, merge-order]
created: 2026-06-08
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# adr.md multi-PR merge-conflict cascade — resolution pattern (2026-06-08, recurri

adr.md multi-PR merge-conflict cascade — resolution pattern (2026-06-08, recurring issue from the "adr.md shared-anchor cascade" carry-learning).

SYMPTOM: multiple open ADR PRs each amend docs/adr.md (e.g. wallet #338, auth #344, deposit #347, auth-edge #349). When the user merges one, main moves and EVERY other adr PR goes CONFLICTING. Disjoint adr-vs-epic file split (the prior mitigation) does NOT help here — several *ADR* PRs inherently touch the same file. The conflict re-fires after each merge (whack-a-mole).

RESOLUTION METHOD (proven this session):
1. **MERGE, not REBASE.** `git merge origin/main` into the campaign branch → resolve → `git commit --no-edit` → NORMAL `git push`. Rebase would require force-push, which CLAUDE.md forbids ("NEVER -f/--force"). Merge adds a small merge commit and pushes fast-forward.
2. **Most conflicts are CLEAN UNIONS** — the colliding amendments are SEPARATE additive blocks at the same anchor (e.g. §ADR-13 §Amд WR1-3 vs F4-RLS vs DR1-8; §ADR-2 EA vs lockout vs RBAC-role). Resolve by stripping ONLY the 3 conflict-marker lines (`<<<<<<< HEAD`, `=======`, `>>>>>>> origin/main`) → keeps both/all blocks. NOTE: in a MERGE the closing marker is `>>>>>>> origin/main` (NOT the rebase's commit-hash) — sed both forms.
3. **NON-union case = a shared header line moved.** #347's §ADR-4c region: main's #### ADR-4c header had gained a "2026-06-01 Two-Sweep Restoration" amendment (merged separately) while the PR branch had the OLD header + its new TL1 block above it. Blind marker-strip would DUPLICATE the §ADR-4c header. Correct resolution: keep the PR's new block + take MAIN's newer header, drop the stale duplicate (sed: for lines matching the header, delete the one lacking the newer text). This is the judgment case → owning agent (architect) or careful deterministic delete.
4. **After resolving, conflicts between the REMAINING adr PRs depend on whether they touch the SAME adr section.** #347 (§ADR-13/§ADR-4c) and #349 (§ADR-2) touch DIFFERENT sections → once both re-synced against the post-merge main, merging one does NOT re-conflict the other → user can merge both freely. Only PRs amending the SAME §ADR section keep cascading.

ORCHESTRATOR GUARD note: a clean-union strip is integration (orchestrator can do via git+sed Bash, not the Edit tool); the non-union/judgment case should go to the owning agent (architect) — its window isn't orchestrator-guarded.

PREVENTION (future): when several ADR amendments are queued, either (a) author them as ONE adr PR, or (b) merge them back-to-back and re-sync the next immediately after each merge; warn the user on merge order; group amendments by §ADR section so cross-PR collisions only happen within a section.

This session's outcome: #344 merged; #347 + #349 both resolved via merge-union (no force-push) → MERGEABLE; mutually non-conflicting (different sections).

---
*Added via Oracle Learn*
