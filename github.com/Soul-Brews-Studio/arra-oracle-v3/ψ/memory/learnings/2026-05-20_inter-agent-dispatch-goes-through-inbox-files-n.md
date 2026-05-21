---
title: **Inter-agent dispatch goes through inbox files, not Telegram.**
tags: []
created: 2026-05-20
source: Session feedback 2026-05-20 — user corrected after I used Telegram instead of inbox
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **Inter-agent dispatch goes through inbox files, not Telegram.**

**Inter-agent dispatch goes through inbox files, not Telegram.**

When orchestrator (or any role) needs to instruct another fleet agent (brew-ops, pg-writer, next-architect, etc.) to do work, the channel is:

1. `arra_thread` → create/continue Oracle thread for the topic (gets thread ID + persistent KB record)
2. Write a markdown file at `mb_agent_oracle_memory/ψ/inbox/for-<target-role>/<YYYY-MM-DD>_<HH-MM>_from-<sender>_thread-<N>_<type>.md` with frontmatter:
   - `from`, `from_role`, `to`, `to_role`
   - `type`: dispatch | consult | escalate | notify | reply | cancel
   - `thread`, `parent_thread`, `parent_oracle`, `parent_session` (worktree path)
   - `subject`, `needs_response`, `priority`, `created` (ISO8601 with TZ)

The target bot watches its `for-<role>/` dir and processes the file (moves to `handled/YYYY-MM/` after).

**Telegram (`telegram_send`) is for human↔bot conversation only** — not agent↔agent dispatch. Sending a fix request to Telegram puts it in the human's chat, not the target bot's work queue.

**Why:** thread inbox = durable, traceable, routable via thread ID; replies land back at the right `parent_session`. Telegram = ephemeral chat surface for the human operator.

**How to apply:** any time the user asks "tell brew-ops to ..." / "dispatch X to pg-writer" / "ask next-architect about Y" → use inbox file pattern. Look at handled examples in `for-<role>/handled/YYYY-MM/` for type/format if unsure.</pattern>
<parameter name="concepts">["fleet", "inbox", "dispatch", "thread", "brew-ops", "orchestrator", "telegram", "routing"]

---
*Added via Oracle Learn*
