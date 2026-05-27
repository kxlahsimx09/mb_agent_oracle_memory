---
title: Registering a new project for `arra_learn(project=...)`: choose KNOWN_PROJECTS b
tags: [brew-ops, repo:arra-oracle-v3, mcp-tools, memory, arra-learn, known-projects, decision, gotcha]
created: 2026-05-27
source: brew-ops thread #251, PR kxlahsimx09/arra-oracle-v3#110, 2026-05-27
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Registering a new project for `arra_learn(project=...)`: choose KNOWN_PROJECTS b

Registering a new project for `arra_learn(project=...)`: choose KNOWN_PROJECTS baseline vs fleet JSON by whether the repo hosts a maw agent.

`handleLearn` (src/tools/learn.ts on `feat/all-prs-rebased`) validates an explicit `project` arg via `validateProjectInput` → `getKnownProjects()` = the hard-coded `KNOWN_PROJECTS` baseline Set ∪ fleet-derived slugs (scanned from `<central-vault>/github.com/<owner>/<repo>/.agent/fleet/*.json` `project_repos` arrays). An unknown project throws "Unknown project … (register a genuinely new project, add a fleet JSON …)" and the learning falls back to `_universal/` or a wrong repo.

Two registration paths, and which to use:
- **Fleet JSON** (`.agent/fleet/*.json` with `project_repos`): correct ONLY when the repo hosts its own maw agent(s). A fleet JSON is fundamentally a maw tmux-window config — every real one declares agent windows (e.g. mb-next-payment-gateway → next-architect/impl/writer-oracle). Adding one for an agent-less repo declares phantom windows maw would try to manage.
- **KNOWN_PROJECTS baseline** (one-line code add): correct for repos with NO `.agent/` dir / no agent of their own — learnings about them are filed by agents based elsewhere. This is the case the rejection message itself names ("For legacy repos without an .agent/ directory, add the slug to KNOWN_PROJECTS").

Worked example: `github.com/kxlahsimx09/p2p-hub` (greenfield P2P matching-hub, no agent, learnings filed by mb-next-payment-gateway agents in campaigns #231/#250) → baseline, via PR #110.

Two operational gotchas:
1. **The live MCP server runs the PRIMARY checkout, not `main`.** `~/.claude.json` registers the `arra-oracle-v2` MCP as `bun /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3/src/index.ts` — the primary checkout, which sits on `feat/all-prs-rebased` (§3c). That branch has the KNOWN_PROJECTS validation; `main` has NO project validation at all (branches diverged). Any fix to the running server must branch from / PR into `feat/all-prs-rebased`, never `main`.
2. **`getKnownProjects()` caches for the process lifetime.** Registration (either path) does NOT take effect on the live server until: merge → re-sync the primary checkout (`git merge --ff-only`) → restart the MCP server. The restart is user-owned (§3c deploy discipline). Until then the new project stays rejected even though the PR is merged.

---
*Added via Oracle Learn*
