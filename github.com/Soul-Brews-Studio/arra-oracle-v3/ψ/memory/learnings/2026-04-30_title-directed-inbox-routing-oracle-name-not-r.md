---
title: title: Directed inbox routing — oracle name (not role label) + Phase 1 corrected
tags: [brew-ops, repo:arra-oracle-v3, repo:cross, fleet, mcp-tools, decision, gotcha, directed-inbox, agent-comm, phase-1, routing, 2026-04-30]
created: 2026-04-30
source: brew-ops session 2026-04-30 — caught during pre-test reconnaissance via `maw oracle ls` before firing first cross-oracle wake; supersedes prior Phase 1 learning
project: github.com/soul-brews-studio/arra-oracle-v3
---

# title: Directed inbox routing — oracle name (not role label) + Phase 1 corrected

title: Directed inbox routing — oracle name (not role label) + Phase 1 corrected 2026-04-30
tags: [brew-ops, repo:arra-oracle-v3, repo:cross, fleet, mcp-tools, decision, gotcha, directed-inbox, agent-comm, phase-1, routing, 2026-04-30]

Supersedes the original Phase 1 learning that used role label as inbox path.
Issue caught before any cross-oracle wake fired (during pre-test reconnaissance
of `maw oracle ls` / `maw about <name>`).

# The bug (caught fast, fix is simple)

The first cut of the directed-inbox protocol used **role labels** as inbox path
keys (`for-system-architect/`, envelope `to: system-architect`). That breaks
because:

| Role label | Oracle name(s) — what `maw wake` resolves |
|---|---|
| `brew-ops` | `brew-ops` (1:1, hides the bug) |
| `system-architect` | `next-architect` (1:1 but mismatched) |
| `technical-writer` | `pg-writer`, `bot-writer` (1:N — ambiguous) |
| `tester` | `pg-tester` (1:1 but mismatched) |

A Phase 2 watcher reading `for-system-architect/<file>` would have nothing to
wake — `maw wake system-architect` returns "no oracle named 'system-architect'"
because the maw fleet entity is `next-architect`. And `for-technical-writer/`
would be ambiguous between two oracles regardless.

`brew-ops` (the only role I tested) hid this because oracle name == role label.

# The fix

**Path = oracle name** (the address `maw wake` resolves). Use `maw oracle ls` to
discover the current set; oracle name is also what `maw whoami` returns inside a
session.

```
~/.arra-oracle-v2/ψ/inbox/
├── for-brew-ops/
├── for-next-architect/         (was: for-system-architect/)
├── for-pg-writer/              (Phase 3+, when writer joins protocol)
├── for-bot-writer/
└── for-pg-tester/
```

**Envelope:**

```yaml
from: next-architect           # oracle name — routing key
from_role: system-architect    # role label — semantic context (optional, doc-only)
to: brew-ops                   # oracle name — must match `maw oracle ls`
to_role: brew-ops              # role label (optional)
```

`from`/`to` route. `from_role`/`to_role` document. Watcher and Step 0.5 sweep
parse only the routing keys. Role labels exist so the receiver immediately knows
what the sender does in fleet terms without an extra `maw oracle ls` call.

**Filename:** `YYYY-MM-DD_HH-MM_from-{source-oracle}_thread-{id}_{type}.md`
(uses oracle name to match dir convention).

# Phase 1 commit history (vault repo `mb_agent_oracle_memory` main)

- `04c859e` — Phase 1 initial (used role labels — buggy)
- (next commit) — Phase 1 routing fix (rename + envelope frontmatter + AGENTS.md
  §11 wording). Both commits together = correct Phase 1 baseline.

`git mv` was used for the directory rename so vault history shows continuity
(consult + reply files preserved via rename; P-001 OK).

# Why catching this before the wake fired matters

The intended cold test was: `maw wake next-architect --task "inbox: <file>"`.
With the buggy spec, that wake would have happened (next-architect is the right
target!) but the architect would have had no §11 awareness of where to look,
AND the inbox would have been at `for-system-architect/` which is non-canonical.
Now the routing is canonical before the first cross-oracle wake, so the cold
test (deferred, separate session) measures envelope self-explanatory-ness, not
spec drift.

# How to apply (going forward)

1. When designing fleet-wide protocols, always check `maw oracle ls` first to see
   the actual addressing space. Role labels are documentation; oracle names are
   addresses.
2. Distinguish "role" (semantic, in `.agent/AGENTS.md` rosters) from "oracle"
   (operational, in `~/.config/maw/fleet/*.json` and `maw oracle ls`). They are
   often the same string but not always — and only oracle names route.
3. Reserve `_role` suffixed fields for documentation; reserve unsuffixed
   fields (`from`, `to`, `for-{x}`) for routing. This convention should hold for
   future protocols (e.g., a future `arra_inbox` MCP tool should accept
   `oracle=X` parameter, not `role=X`).

---
*Added via Oracle Learn*
