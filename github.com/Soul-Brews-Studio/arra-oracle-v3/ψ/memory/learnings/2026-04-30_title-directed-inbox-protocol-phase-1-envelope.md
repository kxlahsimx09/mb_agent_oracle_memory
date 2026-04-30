---
title: title: Directed inbox protocol Phase 1 — envelope format dogfooded 2026-04-30
tags: [brew-ops, repo:arra-oracle-v3, repo:cross, fleet, mcp-tools, decision, directed-inbox, agent-comm, phase-1, 2026-04-30]
created: 2026-04-30
source: brew-ops session 2026-04-30 — AGENTS.md §11 added + dogfood test thread #56 ADR-9 dispatcher placement
project: github.com/soul-brews-studio/arra-oracle-v3
---

# title: Directed inbox protocol Phase 1 — envelope format dogfooded 2026-04-30

title: Directed inbox protocol Phase 1 — envelope format dogfooded 2026-04-30
tags: [brew-ops, repo:arra-oracle-v3, repo:cross, fleet, mcp-tools, decision, directed-inbox, agent-comm, phase-1, 2026-04-30]

Phase 1 of the directed-inbox protocol shipped 2026-04-30 (manual-fire only,
no watcher automation yet). AGENTS.md §11 added (`mb_agent_oracle_memory/
github.com/Soul-Brews-Studio/arra-oracle-v3/.agent/AGENTS.md`). Path layout:
`~/.arra-oracle-v2/ψ/inbox/for-{role}/` (resolves through ψ symlink to
`mb_agent_oracle_memory/ψ/inbox/for-{role}/`). Two role dirs created:
`for-brew-ops/`, `for-system-architect/`, each with `handled/` subdir +
`.gitkeep`.

# Envelope format (validated end-to-end)

YAML frontmatter (yaml-block delimited, parses cleanly even with `§` and Thai
in subject):

```yaml
from: <role>
to: <role>
type: consult|escalate|notify
thread: <id>          # omit only for notify-without-thread
subject: <one line>
context: >
  <2-4 line summary; full discussion stays in thread>
needs_response: true|false
priority: normal|high
created: <ISO 8601 +07:00>
# appended by recipient on archive:
handled_at: <ISO 8601>
handled_by_thread: <id>
handled_by_inbox: <reply file path relative to inbox root>
```

Filename: `YYYY-MM-DD_HH-MM_from-{source-role}_thread-{id}_{type}.md`.

# Dogfood test result (1 round-trip, manual fire)

Sender: system-architect (simulated). Receiver: brew-ops (this session).
Thread: #56 (ADR-9 Callback Dispatcher). Question: dispatcher EF placement
(inside maw fleet vs outside).

Round-trip latency: ~3 min sender-write → receiver-reply on manual fire.
Watcher Phase 2 will land at ≤5 min worst-case (POLL_INTERVAL=300s).

What worked:
- YAML envelope round-trips without escape issues for `§`, multilingual subjects.
- `git mv` to `handled/YYYY-MM/` preserves the file (P-001 compliant) and
  removes it from watcher scan scope (`maxdepth 1` will skip handled/).
- Reply-envelope `type=notify` with `references_inbox:` field cleanly closes
  the loop without forcing another round-trip when no further response needed.

# Decisions ratified during Phase 1 design (per user 2026-04-30)

| Question | Decision | Rationale |
|---|---|---|
| Wake cadence | Reuse w2-watcher's 5-min POLL_INTERVAL; no SETTLE_WINDOW for inbox; INBOX_MIN_GAP=300s per role | Sender-write is already settled; commit-storm semantics don't apply |
| Archive vs delete | Move (`git mv handled/YYYY-MM/`); never delete | P-001 compliance |
| Multi-recipient | Not in scope; if needed, write multiple files referencing same thread | YAGNI; broadcast = diffusion of responsibility |
| Path location | `~/.arra-oracle-v2/ψ/inbox/for-{role}/` (per-node-local semantics, vault-tracked through symlink) | Single-node fleet today; cross-node decision deferred until peer nodes exist |
| Phase priority | consult flow first, then escalate, then notify + arra_inbox tool extension | Consult has live use case (architect↔brew-ops); escalate/notify are simpler subsets |

# Phase 2 (next, not started)

Extend `scripts/w2-watcher.sh`:
- New fn `scan_inbox(role)` — `find for-${role} -maxdepth 1 -type f -name "*.md"`
- State file `~/.cache/w2-watcher/inbox-${role}.state` (list of file basenames
  already wake-fired, to gate against double-fire before receiver archives)
- `maw wake ${role} --task "inbox: ${file_basename}"` (use `--task` flag — the
  positional path was learned-broken on 2026-04-22 truncation incident; also
  unique `--wt "$wake_ts"` per wake from the same incident)
- Toggle: `INBOX_SCAN_ENABLED=1` env (default off until merge soak)

# Phase 3 (later)

- Telegram alert path for `priority: high` envelopes (extend brew-ops-bot/detector.sh's existing `[BLOCK_*]` marker pattern)
- `arra_inbox` MCP tool gains `type=directed`, `role=X` filters
- Workflow files fleet-wide gain "Step 0.5: directed inbox sweep" (writer/tester W1/W2/W4/W8/W9 — sibling-sync per AGENTS.md §3a discipline)

# How to apply

Any agent participating in directed-inbox flows must, at the start of every
wake (Step 0.5, immediately after the existing thread sweep at Step 0):

1. `ls ~/.arra-oracle-v2/ψ/inbox/for-{my-role}/*.md` (skip `handled/`).
2. For each file: read frontmatter → if `thread:` present, `arra_thread_read
   threadId={id}` → respond per type → if `needs_response: true`, write reply
   envelope to `for-{from}/` → archive consult file (`mv` to
   `handled/YYYY-MM/`, append `handled_at` + `handled_by_thread` +
   `handled_by_inbox` frontmatter first).
3. Only after the sweep settles, proceed with the main wake reason.

If `type=escalate`, treat as **higher priority** than the original wake reason.

---
*Added via Oracle Learn*
