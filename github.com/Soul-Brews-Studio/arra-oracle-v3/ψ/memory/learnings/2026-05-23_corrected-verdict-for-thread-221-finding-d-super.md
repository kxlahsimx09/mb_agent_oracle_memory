---
title: CORRECTED verdict for thread #221 finding D (supersedes my earlier "stale-server
tags: [brew-ops, repo:arra-oracle-v3, indexer, vault, drift, decision, gotcha, arra_learn, thread-221]
created: 2026-05-23
source: arra_learn from github.com/Soul-Brews-Studio/arra-oracle-v3 thread-221 brew-ops
project: github.com/soul-brews-studio/arra-oracle-v3
---

# CORRECTED verdict for thread #221 finding D (supersedes my earlier "stale-server

CORRECTED verdict for thread #221 finding D (supersedes my earlier "stale-server-only" framing — that was an over-claim).

C (data-loss-on-rebuild) — FIXED, unchanged: discoverProjectPsiDirs (src/indexer/discovery.ts) now also scans `<repoRoot>/_universal/ψ`. arra_learn writes project-less learnings to `_universal/ψ` (`projectDir = project || '_universal'`); the batch reindexer skipped that dir, so those files were index-only and a from-scratch rebuild dropped them (incl. 5 orchestrator-pattern 2026-05-21 learnings). Vault-verified: 12 now discovered. PR kxlahsimx09/arra-oracle-v3#89.

D — was NOT a stale server and NOT a code bug. It was a CLIENT-SIDE MALFORMED TOOL CALL. Evidence:
1. Current source (391420e) resolves explicit project= correctly (normalizeProject + KNOWN_PROJECTS whitelists arra-oracle-v3) → regression test in PR #89.
2. The live server PID 5859 — confirmed still up since May 17, never restarted — ALSO resolves it: a fresh arra_learn(project=github.com/Soul-Brews-Studio/arra-oracle-v3) at 2026-05-23 15:40 GMT+7 landed project-first, not _universal/.
3. Smoking gun on disk: wt-17's file _universal/ψ/.../2026-05-23_arralearn-with-a-project-writes-the-learning.md ends with literal `</pattern><parameter name="project">github.com/Soul-Brews-Studio/arra-oracle-v3` INSIDE the pattern body. The project arg leaked into `pattern` as XML markup, so no project reached handleLearn → correct _universal fallback, no project: frontmatter.

GOTCHA (the durable, reusable lesson): when arra_learn output lands in _universal/ with no `project:` frontmatter despite intending a project, suspect the tool call serialized the `project` argument into the `pattern` string (literal `<parameter name="project">…` / `</pattern>` markup in the body) — NOT a server/index bug. Verify by reading the on-disk file's tail. The handler resolves explicit project= correctly on both current source and the live server.

The post-merge restart is still worthwhile to (a) deploy C via the reindex CLI picking up merged code after the primary ff, and (b) clear the stale LanceDB fragment handle wt-17 saw — but NOT as a "D fix." D needs neither code change nor restart.

---
*Added via Oracle Learn*
