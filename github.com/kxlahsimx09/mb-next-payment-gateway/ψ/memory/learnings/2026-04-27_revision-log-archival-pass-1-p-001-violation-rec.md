---
title: Revision-log archival pass 1 + P-001 violation recovery (silent Edit-tool overwr
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, revision-log, archival, p-001-violation, p-001-recovery, edit-tool-discipline, silent-overwrite, docs-organization, monthly-rotation, process-improvement, durable-lesson, user-surfaced]
created: 2026-04-27
source: docs/adr.md@33189b5 + docs/adr/revision-log-archive-2026-04.md@33189b5 + git history of commit 1d66c83 (silent-overwrite trace)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Revision-log archival pass 1 + P-001 violation recovery (silent Edit-tool overwr

Revision-log archival pass 1 + P-001 violation recovery (silent Edit-tool overwrite caught + restored).

User-surfaced concern (2026-04-27): docs/adr.md hit 954 lines; user worried about "splitting these many sub-items will bloat the document". Profile measurement showed: decisions section = 414 lines (43%); revision log = 542 lines (57%). The "bloat" wasn't children proliferation (§ADR-4a, 4b, 4c-future, 4d-future) — those average 50-65 lines each and the extract-to-design-doc convention handles growth past ~150 lines (already applied to §ADR-4a + §ADR-8). Bloat lived ENTIRELY in revision log accumulation.

Established archival pattern:
- Archive criteria: §ADR sections at #decision stable ≥3 days, OR multi-pass narratives whose final pass already ratified
- Keep inline: last ~3 days, entries anchoring active [AWAITING_THREAD] / #provisional ADRs
- Path: docs/adr/revision-log-archive-YYYY-MM.md (monthly rotation)
- Format: header (frontmatter + index table + criteria) + entries verbatim newest-first
- Pointer in inline log: "12 earlier entries (date range) — see archive header"

First archive: docs/adr/revision-log-archive-2026-04.md (476 lines; 12 entries from §ADR-4a passes 1-6, ADR-6 pass 1, ADR-8 passes 1-4, Design-lane sync). docs/adr.md trimmed to 532 lines (44% reduction from 954).

P-001 violation surfaced + recovered (durable architect-process lesson):
The 2026-04-24 Design-lane sync revision-log entry was inadvertently overwritten in commit 1d66c83 (2026-04-27 surfacing pass). Mechanism: my Edit tool call had old_string ending with the heading line "#### 2026-04-24 — Design-lane sync...", and new_string had a different heading ("#### 2026-04-27 — Surfaced..."). Edit replaced the heading but the BODY of the sync entry (32 lines) survived AS-IS in the file — orphaned under the wrong heading, silently merged with the new entry.

This pass:
1. Recovered entry verbatim from git commit b23a20d (post-backfill canonical state)
2. Restored to archive with full body + index entry
3. Removed orphan body from inline (canonical copy in archive; no duplication)
4. Added P-001 recovery note in archive header documenting the silent overwrite

Durable lesson (added to internal pass-cadence checklist):
"When an Edit's old_string ends with a heading line that delimits two entries, validate which entry's body is being replaced before commit. When adding a newest-first revision-log entry, prefer Edit that anchors on the `---` separator + heading-immediately-after pattern, not on the previous-entry's heading."

This is the FIRST CONFIRMED P-001 violation in this repo's W1 history. Caught only because user asked an unrelated question about bloat and archival happened to read git history. Without that prompt, the silent overwrite would have stayed undetected indefinitely. This is a strong argument for periodic git-vs-current-doc audit passes — even though git preserves history, doc-tree discoverability is a separate guarantee that needs its own preservation discipline.

Pattern for future archival passes:
- Trigger: docs/adr.md > ~800 lines OR revision-log section > ~400 lines OR end of calendar month
- Output: monthly archive file + slimmed inline + pointer
- Side benefit: each archival pass becomes an opportunity to audit for accumulated drift (overlooked entries, broken refs, P-001 violations)

Threads opened: none. Threads closed: none. No design decisions changed. Both ADRs unchanged (#decision/#provisional preserved). Commit chain on PR #3: b801730 (archival) + 33189b5 (commit-sha backfill).

Pre-existing note carried forward: arra_trace_link still missing as habit (eighth retro flagging). The chain learning_2026-04-24_w1-design-lane-sync → this learning is a perfect trace candidate. Self-flagging at retro time has provably failed; treating as a process bug worth externalizing (wrapper script, hook, or brew-ops automation request).

---
*Added via Oracle Learn*
