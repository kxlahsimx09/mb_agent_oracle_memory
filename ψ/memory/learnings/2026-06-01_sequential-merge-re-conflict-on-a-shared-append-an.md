---
title: Sequential-merge re-conflict on a shared append anchor (docs revision-log). [Act
tags: [git, merge-conflict, append-only-docs, shared-anchor, merge-order, no-force-push]
created: 2026-06-01
source: next-writer ng2sync conflict resolution
project: github.com/kokarat/mobiz-payment-gateway
---

# Sequential-merge re-conflict on a shared append anchor (docs revision-log). [Act

Sequential-merge re-conflict on a shared append anchor (docs revision-log). [Actual repo: kxlahsimx09/mb-next-payment-gateway — the next-system docs port; filed here as it is unregistered in Oracle.]

When N branches each ADD entries at the SAME anchor in a shared file (e.g. all insert new `#### date — §ADR-NN` lines immediately after the "Ordered newest-first" header of docs/adr.md, above a common block), merging them into main one at a time RE-CONFLICTS on that file for every merge after the first. Reason: once branch A merges, main's anchor gains lines; branches B/C/D each added lines at that identical anchor relative to the same base, so git's 3-way merge sees both sides inserting at the same position → conflict.

Key properties:
- The re-conflict is a trivial CLEAN APPEND-BOTH each time (keep both sides' new entries above the common block). No semantic risk, no re-authoring.
- Merge ORDER does NOT avoid it — it recurs regardless of sequence. Order only changes the final top-to-bottom ordering of entries (cosmetic).
- Files where the branches touch DISJOINT regions (different sections of INDEX.md, different epic files) do NOT re-conflict. Only the shared-anchor file does.

Resolution method that avoids force-push (per safety rules): git fetch; git checkout <branch>; git merge origin/main; resolve append-both; git commit; git push (normal). A merge commit on the PR branch is fine.

Also: a same-LINE edit on both sides is still a clean append-both (NOT semantic overlap requiring escalation) when each side appends an independent ;- or middot-delimited clause/list-item to the end of the line — concatenate both, byte-preserving each. Only escalate when the two sides genuinely rewrite the same content.

Context: campaign ng2sync, PRs #292/#294/#295/#296 (4 §ADR amendment branches off old main; #290/#291 moved main e35a6e1→0586963).

---
*Added via Oracle Learn*
