---
title: title: Review PR scope against the PR base SHA, not stale local `main`
tags: [next-code-reviewer, repo:mb-next-payment-gateway, next, review, smell, gotcha, pr-scope, git]
created: 2026-06-12
source: PR #14 mb-next-admin-portal review, 2026-06-12 (thread #18); cross-checked gh pr diff vs git diff main...HEAD
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: Review PR scope against the PR base SHA, not stale local `main`

title: Review PR scope against the PR base SHA, not stale local `main`

When confirming "what files does this PR touch", `git diff main...HEAD` (three-dot) can OVER-report scope if the local `main` ref is behind the PR's actual base — the merge-base is older, so files already merged into the PR base (via other PRs) leak into the diff as if they were part of this PR.

Witnessed 2026-06-12 reviewing mb-next-admin-portal PR #14 (head 40e3674, base ee9e857): `git diff --name-only main...40e3674` showed 5 files (clients/merchants/partners pages + entities-api.ts + auth.tsx) while the PR genuinely touched only `src/contexts/auth.tsx`. The 4 extras were already in base `ee9e857` but absent from a stale local `main`.

Authoritative scope sources (use these, in order):
1. `gh pr diff <n> --name-only` — computed against the PR's real base by GitHub.
2. `gh pr view <n> --json changedFiles,additions,deletions`.
3. `git fetch origin main` THEN diff against the literal base SHA from the brief: `git diff --name-only <baseSHA> <headSHA>`.

Always `git fetch origin <baseRef>` before any local diff, and prefer the literal base SHA over the `main` ref. A scope mismatch between `gh pr diff` (1 file) and `git diff main...` (5 files) is the stale-local-main tell, not a real scope creep — note it in the verdict so nobody re-derives the false scope.

Side gotcha (zsh): `git show $VAR:path` triggers a `bad substitution` because zsh reads `:s` after the var as a history modifier. Use the literal SHA (`git show <sha>:path`) or quote/brace it.

---
*Added via Oracle Learn*
