---
title: Inbox loop-closure hook (§11l): the reply-envelope ARTIFACT it verifies is keyed
tags: [orchestrator, directed-inbox, loop-closure, stop-hook, fan-out, parent_oracle]
created: 2026-05-19
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Inbox loop-closure hook (§11l): the reply-envelope ARTIFACT it verifies is keyed

Inbox loop-closure hook (§11l): the reply-envelope ARTIFACT it verifies is keyed by `parent_oracle`, not `from`.

`inbox-loop-closure-hook.sh` Check 2 computes `reply_to=${parent_oracle:-$from}` from each archived `needs_response: true` inbound, then requires a file matching `for-<reply_to>/[handled/*/]*_from-<oracle>_thread-<id>_reply.md` to exist (it does NOT trust the `handled_by_inbox` frontmatter field — it globs for the actual file).

Consequence for the orchestrator: worker reply envelopes in a fan-out campaign echo `parent_oracle: orchestrator`. So when the orchestrator archives a worker's `needs_response: true` checkpoint reply, the closure artifact the hook wants is **`for-orchestrator/handled/<month>/<ts>_from-orchestrator_thread-<id>_reply.md`** — in the orchestrator's OWN inbox, not `for-<worker>/`. Writing the reply only to `for-<worker>/` (which is what wakes the worker) does NOT clear the hook.

Two practical rules:
1. Closing a worker checkpoint = TWO artifacts: the dispatch/reply envelope in `for-<worker>/` (wakes the worker) AND a `from-orchestrator..._thread-<id>_reply.md` record in `for-orchestrator/handled/` (satisfies the Stop hook).
2. The hook only needs ONE matching file per `(reply_to, thread)` pair — multiple checkpoint replies on the same thread can be closed by a single consolidated `for-orchestrator/handled/.../...thread-<id>_reply.md` record. Write it straight into `handled/` so Check 1 (unhandled-in-root) does not re-flag it.

---
*Added via Oracle Learn*
