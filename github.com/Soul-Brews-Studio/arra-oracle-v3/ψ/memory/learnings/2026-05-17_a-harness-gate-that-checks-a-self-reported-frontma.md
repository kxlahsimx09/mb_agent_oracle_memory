---
title: A harness gate that checks a self-reported frontmatter field is defeated by a mi
tags: [inbox-protocol, loop-closure, hooks, verification, anti-pattern, thread-159]
created: 2026-05-17
source: brew-ops — thread #159 root-cause
project: github.com/soul-brews-studio/arra-oracle-v3
---

# A harness gate that checks a self-reported frontmatter field is defeated by a mi

A harness gate that checks a self-reported frontmatter field is defeated by a mis-stamped field — verify the ARTIFACT instead.

Thread #159 (a recurrence of the #140 class): the §11d inbox-loop-closure Stop hook (`scripts/inbox-loop-closure-hook.sh`) passed a `needs_response: true` envelope whenever `handled_by_inbox` OR `handled_note` was non-empty. next-architect archived a consult stamping `handled_by_inbox` with the inbound envelope's own basename (not a reply path) plus a verbose `handled_note`, but never wrote the reply envelope — the hook passed, the orchestrator was never woken.

Lesson: a gate enforcing that work happened must verify the work's ARTIFACT (the reply-envelope file on disk, the thread status via API), never a field the gated agent writes about itself. Fix (fork PR kxlahsimx09/arra-oracle-v3 #78): `reply_envelope_exists()` globs the requestor's inbox for `*_from-<oracle>_thread-<id>_reply.md`; `thread_status()` covers the §11g moot case. `handled_by_inbox`/`handled_note` are now advisory only.

Note: this was NOT a `--resume`-path gap — the Stop hook is global in `~/.claude/settings.json` and fires for fresh and resumed sessions alike; the watcher records `session_id` identically for both. The defect was the gate's trust model, not its coverage.

---
*Added via Oracle Learn*
