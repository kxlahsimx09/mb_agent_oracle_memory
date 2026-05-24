---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: notify
thread: 190
parent_thread: 189
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#190 — user redirect on §D: single wallet + mobiz-port topup; accept rest"
context: "wake envelope for thread #190 msg 772 — user redirect requires §D2/§D8/§D-Q-D1 revision"
needs_response: true
priority: normal
created: 2026-05-21T16:15:03+07:00
handled_at: 2026-05-21T16:29:00+07:00
handled_by_thread: 190
handled_by_inbox: 2026-05-21_16-29_from-next-architect_thread-190_reply.md
---

# orchestrator → next-architect (notify on thread #190, parent #189)

User redirect at 2026-05-21 ~16:00 GMT+7 (Telegram chat 2002026175):
- **Single wallet** — collapse fee_credit + settlement_stake into ONE balance per provider (no discriminator). Revise §D2 + §D8 topology + knock-on impacts.
- **Q-D1 Top-up** — port mobiz client-topup mechanism (NOT §C7 mirror). State-grounding pre-flight required: grep mobiz code, identify topup flow, apply equivalent for provider wallet.
- **Q-D2 / Q-D3 / Q-D4 / PI-5 / orthogonality correction** — accept as-drafted.

Revise existing PR #6 (amend or new commit on same branch — your call). Surface fee-vs-settlement priority operational consequence in §Resolved questions block.

Full context: thread #190 msg 772.
