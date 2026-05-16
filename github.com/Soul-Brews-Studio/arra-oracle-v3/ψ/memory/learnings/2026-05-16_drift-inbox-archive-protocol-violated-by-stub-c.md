---
title: DRIFT — Inbox archive protocol violated by "stub-comment" handled-marking. On 20
tags: [drift, gotcha, directed-inbox, p-001, archive-protocol, orchestrator, fleet]
created: 2026-05-16
source: orchestrator — thread #117 worktree cleanup, 2026-05-16
project: github.com/soul-brews-studio/arra-oracle-v3
---

# DRIFT — Inbox archive protocol violated by "stub-comment" handled-marking. On 20

DRIFT — Inbox archive protocol violated by "stub-comment" handled-marking. On 2026-05-16, a prior orchestrator session archived next-impl's thread-117 reply envelope (`for-orchestrator/2026-05-16_16-45_from-next-impl_thread-117_reply.md`) by **overwriting the entire 66-line file body** with a single line `<!-- handled_at: ... -->`. This destroyed next-impl's full per-worktree audit report — a P-001 (Nothing is Deleted) violation. The §11d archive protocol says to **append** `handled_at`/`handled_by_thread`/`handled_by_inbox` to the existing YAML frontmatter and `git mv` the file unchanged into `handled/YYYY-MM/` — never replace the body.

Two compounding problems:
1. **Content destruction** — envelope body must be preserved verbatim; handled-metadata goes in frontmatter, not as a body-replacing comment.
2. **Premature handled-mark** — the stub claimed "aggregated to #117" at 16:48, but thread #117 was still `pending` and all 9 worktrees still present. An envelope must not be marked handled until the work it triggered is actually complete.

Recovery: the next session restored the body verbatim from its session-start Read and recorded honest handled-metadata noting the prior premature/destructive mark. Other `handled/` envelopes in this repo may carry the same stub-comment damage — audit before trusting any archived envelope as a faithful record.

Correct archive = append frontmatter + `git mv`, only after the triggered work is verifiably done.

---
*Added via Oracle Learn*
