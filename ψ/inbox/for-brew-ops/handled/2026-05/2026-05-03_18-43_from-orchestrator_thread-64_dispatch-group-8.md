---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: dispatch
thread: 64
parent_thread: 63
parent_oracle: orchestrator
subject: Execute Group 8 (user ratified "approve 8" on Telegram 2026-05-03 18:39 GMT+7) — use corrected cwd-from-JSONL classifier
needs_response: true
priority: normal
created: 2026-05-03T18:43:00+07:00
handled_at: 2026-05-03T18:55:00+07:00
handled_by_thread: 64
handled_note: Group 8 executed clean; 118/118 orphan JSONL dirs retired, 0 failed, 0 skipped. cwd-from-JSONL classifier verified (drift 145/26/118/1 → post 27/26/0/1). vigilant-almeida-1f523b + naughty-yalow + self-preservation set all preserved. Transcript on thread #64 msg 139.
---

# orchestrator → brew-ops (dispatch on thread #64)

User approved on Telegram chat 2002026175 at 2026-05-03 18:39 GMT+7:

> approve 8

This clears Group 8 (orphan `~/.claude/projects/<encoded>/` JSONL dirs) for execution. Full dispatch with hard constraints + corrected classifier + bucket order is in thread #64 msg 137 — read that first; this envelope is the wake.

**TL;DR:**
- Use the **cwd-from-JSONL classifier** (msg 137 §"corrected classifier"), NOT msg 131's broken sed loop.
- Re-run classifier as a fresh sanity check; halt if counts diverge >±5 from msg 136's 25 alive / 118 orphan / 1 unclassified.
- Process orphans in **per-bucket batches** (A→B→C→D→E), not as one flat sweep.
- **DO NOT** delete the UNCLASSIFIED entry (`naughty-yalow`).
- **DO NOT** delete vigilant-almeida-1f523b's JSONL (Group 6 LOST-WORK; near-miss under the broken classifier — explicit verify it lands in ALIVE before Bucket B).
- Self-preservation: protect the JSONLs of `wt-8-inbox-1777799010` (orchestrator parent #63), `wt-9-inbox-1777799495` (audit thread origin), `wt-14-inbox-1777808377` (this orchestrator dispatch session) — they should all classify ALIVE.

Pre-flight: `cat ~/.cache/w2-watcher/*.state` (no `pending_wake_ts` ≥ now). Per-bucket halt-on-failure policy in msg 137.

Deliverable on thread #64 (single reply): re-run classifier counts, per-bucket attempted/succeeded/skipped, final `~/.claude/projects/` count, confirmation vigilant-almeida-1f523b's JSONL still exists, any skipped items with reasons.

Reply on this thread when done. Orchestrator will re-wake, aggregate to parent #63, and final-report to user via Telegram.

— orchestrator (wt-14-inbox-1777808377)
