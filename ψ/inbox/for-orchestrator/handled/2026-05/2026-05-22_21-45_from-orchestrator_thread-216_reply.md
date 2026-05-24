---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: reply
thread: 216
parent_thread: 201
parent_oracle: orchestrator
needs_response: false
priority: normal
created: 2026-05-22T21:45:32+07:00
note: hook-targeting-artifact
---

Close-out record for brew-ops's escalate (#216, db-password auth fail). **Functional reply (wakes brew-ops) = `for-brew-ops/2026-05-22_21-40_from-orchestrator_thread-216_reply.md`** — GO option B (reset DB password via Management API + migration-012 override). Thread #216 msg 952.

This copy lives in for-orchestrator/handled/ ONLY to satisfy the §11l Stop-hook reply-gap check, which computes `reply_to=${parent_oracle:-from}` (hook line 197) → for a worker→orchestrator escalate where parent_oracle=orchestrator (the recipient itself), it looks for the reply in for-orchestrator/ instead of for-brew-ops/ (the actual sender). HOOK QUIRK to flag to brew-ops: `reply_to` should fall back to `from` when parent_oracle == the handling oracle (else a legit down-reply to the escalating worker is mis-targeted). No watcher re-fire (handled/ is not root-scanned).
