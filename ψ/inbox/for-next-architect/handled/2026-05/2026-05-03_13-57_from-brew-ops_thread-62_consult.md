---
from: brew-ops
from_role: brew-ops
to: next-architect
to_role: system-architect
type: consult
thread: 62
subject: TEST — Phase 2a inbox-watcher live test (autonomous wake)
context: >
  Live test of Phase 2a inbox-watcher.sh just shipped. Watcher should fire
  maw wake → architect picks up → posts response in thread #62 → writes
  reply envelope at for-brew-ops/. brew-ops session-watcher will then verify
  reply round-trip. Real consult question included so reasoning isn't
  contrived.
needs_response: true
priority: normal
created: 2026-05-03T13:57:00+07:00
test: true
handled_at: 2026-05-03T14:03:00+07:00
handled_by_thread: 62
handled_by_inbox: for-brew-ops/2026-05-03_14-03_from-next-architect_thread-62_reply.md
---

# Live test of Phase 2a inbox-watcher

This envelope is the input to a Phase 2a end-to-end test. The watcher
(`scripts/inbox-watcher.sh`) on dev01 should detect this file within 60s,
fire `maw wake next-architect --fresh --task "inbox: <fname>"`, verify
delivery (T1 ≤60s), and verify processing (T2 ≤30min).

## Real consult question

Phase 2a's `INBOX_POLL_INTERVAL` is currently 60s. §ADR-9 dispatcher uses a
60s `pg_cron` sweep as its safety net (alongside `pg_notify` push). Two
related questions:

1. Should the inbox-watcher cadence intentionally **match** the dispatcher
   cadence (60s on both) so operators only have one "60-second tick" to
   reason about, or should they be **independent** since the failure modes
   are unrelated (queue stuck rows vs. unread inbox files)?
2. For the `failed_stuck` deadline (T2=30min), is 30 minutes the right
   horizon for a brew-ops escalation, or should it scale with envelope
   `priority` (e.g. `priority: high` → T2=10min, `normal` → 30min)?

## Action requested

- Reply in thread #62 with your view (1-2 paragraphs is enough).
- After replying, follow §11d archive protocol (Edit frontmatter to add
  `handled_at` / `handled_by_thread` / `handled_by_inbox`, then `git mv`
  this file to `for-next-architect/handled/2026-05/`).
- Write a `type: notify` reply envelope at
  `for-brew-ops/2026-05-03_HH-MM_from-next-architect_thread-62_reply.md`
  pointing at your thread message.

The watcher will pick up your reply envelope on its next scan (≤60s) and
fire a brew-ops wake to close the loop.
