---
title: Prefer arra_learn over Claude Code's built-in local auto-memory for durable fact
tags: [brew-ops, repo:cross, memory, feedback, meta, arra-learn, external-brain, P-003, 2026-04-22]
created: 2026-04-22
source: Direct user correction 2026-04-22 in brew-ops fleet-lens session
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Prefer arra_learn over Claude Code's built-in local auto-memory for durable fact

Prefer arra_learn over Claude Code's built-in local auto-memory for durable facts about the user, their workflow preferences, and the Soul-Brews ecosystem. The local `~/.claude/projects/<encoded-cwd>/memory/` system is per-machine + per-project-dir — invisible to other agents in the fleet and to arra_search.

**Why:** Observed directly 2026-04-22. I had been writing `feedback_*.md` files into the local memory dir (encouraged by CLAUDE.md's built-in "auto memory" section and the Write tool workflow). The user corrected: "memory พยายามใช้ arra_learn นะ" (for memory, try to use arra_learn). Oracle is the external brain (P-003), append-only (P-001), and searchable across agents + sessions + machines via hybrid FTS5 + vector. Local memory is ephemeral relative to the ecosystem.

**How to apply:**

1. When a `feedback_*.md` / `project_*.md` / `user_*.md` / `reference_*.md` would be the right save, call `arra_learn` instead. Use the same structure (what / **Why:** / **How to apply:**) inside the pattern body.
2. Tag with the mandatory 3-layer scheme (repo:X, system-domain, role) plus any relevant feature tags — this is what makes the learning findable via `arra_search` later.
3. Keep `MEMORY.md` local pointers lean — a one-line breadcrumb is fine for surfacing in-context, but the authoritative copy lives in the vault. Do not duplicate full content in both places.
4. When migrating existing local memory entries, prefer `arra_learn` with a pointer-back note in MEMORY.md rather than delete-and-replace (P-001 spirit applies locally too: don't lose the breadcrumb just because the real record moved).
5. When in doubt about whether a fact is "durable" enough for oracle: if another session (human or agent) would benefit from it, it belongs in oracle. If it's only relevant to the current conversation, it goes in a plan/todo, not memory at all.

**Scope:** Soul-Brews-Studio ecosystem (arra-oracle-v3, maw-js, oracle-studio, bank-bot, mobiz-payment-gateway, mb_agent_oracle_memory). Local Claude auto-memory may still be fine for truly single-machine concerns (shell aliases, personal IDE state) — but default to oracle unless clearly out-of-scope.

---
*Added via Oracle Learn*
