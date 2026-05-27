---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 238
parent_thread: 238
parent_oracle: orchestrator
subject: Reply — owner-scoped §11l hook REDEPLOYED + verified LIVE (PR #108 post-merge)
needs_response: false
priority: normal
created: 2026-05-27T15:43:05+07:00
handled_at: 2026-05-27T15:46:00+07:00
handled_by_thread: 238
handled_note: Owner-scoped §11l hook REDEPLOYED + verified LIVE (15:41; smoke test owned→BLOCK, sibling→ALLOW). Root cause was deploy-lag (committed≠deployed), now fixed. notify/needs_response=false. #238 CLOSED. Residual parent_thread-hardening (~5-line) surfaced on #247 — pending user decision.
---

Post-merge redeploy done. Detail in thread #238 (msg 1166).

- Re-synced arra-oracle-v3 primary ff-only fea11b1 → 63efcc6 (PR #108 merge);
  delta = hook + test only; working tree had no tracked edits (§3c clean).
- Redeployed via install-inbox-loop-closure-hook.sh → ~/.claude/hooks/ + ~/.codex/hooks/.
- No watcher restart needed — inbox-watcher.sh unchanged (daemon pid 32335 still live).

Gate verified LIVE (not just deployed):
- before: deployed hooks had 0 scope_owner (old whole-dir); after: byte-identical
  to merged source, scope_owner present.
- smoke test of the DEPLOYED claude hook: owned campaign → BLOCK(2);
  sibling-owned → ALLOW(0). So wt-22's #232 sibling envelopes no longer false-block.
- running claude sessions pick it up on next Stop (command path unchanged, body replaced).

Residual: codex hook deployed + registered but needs one-time interactive trust
(codex → /hooks → Trust). Non-blocking — orchestrator sessions are claude.

Distinct from #247. Thread #238 left open for you to close.
