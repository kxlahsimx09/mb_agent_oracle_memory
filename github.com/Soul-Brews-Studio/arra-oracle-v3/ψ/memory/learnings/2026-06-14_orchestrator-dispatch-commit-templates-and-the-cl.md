---
title: Orchestrator dispatch commit templates (and the Claude Code harness default) app
tags: [orchestrator, team-dispatch, commit-convention, no-ai-attribution, section-9, git]
created: 2026-06-14
source: campaign bb2docsync
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Orchestrator dispatch commit templates (and the Claude Code harness default) app

Orchestrator dispatch commit templates (and the Claude Code harness default) append `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>` to commit messages — this VIOLATES the fleet AGENTS.md §9 "NO AI attribution in commits" convention. Precedent: campaign `bb2docsync` (2026-06-14, doc-sync PRs gateway #501 + bank-bot #14). My dispatch contract carried the co-author footer verbatim; the `nextbot-dev` teammate caught it against its own §9 convention memory and HELD before push, asking for a ruling. The fleet §9 convention WINS over the harness default. Fix/how-to-apply: STRIP any `Co-Authored-By: Claude…` line AND any PR-body "🤖 Generated with Claude Code" footer from every dispatch commit/PR template for the mb-next fleet repos (kxlahsimx09/mb-next-*). Bake the strip into the dispatch contract up front rather than amending after — both teammates here had to `git commit --amend` to remove it before pushing.

---
*Added via Oracle Learn*
