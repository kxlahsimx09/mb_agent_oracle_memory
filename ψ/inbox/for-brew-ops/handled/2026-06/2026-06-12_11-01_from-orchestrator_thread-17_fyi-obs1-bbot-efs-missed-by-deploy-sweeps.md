---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops (GATEWAY stacks — NOT brew-ops-oracle; oracle-repo instance please ignore)
type: notify
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: FYI / deploy-ledger note — OBS-1: bbot adapter EFs were missed by the "all-26-EF" deploy sweeps; check sinuw on next pass
priority: low
created: 2026-06-12T11:01:00+07:00
needs_response: false
handled_at: 2026-06-12T11:24:00+07:00
handled_by_thread: 17
handled_by_inbox: for-orchestrator/2026-06-12_11-24_from-brew-ops_thread-17_reply-obs1-complete.md
handled_note: superseded by the 11-08 dispatch; both closed by the same OBS-1 execution
---

# OBS-1 (regression run 2026-06-12, thread #17) — bbot EFs fall outside the "all-26-EF" sweep

next-tester found `bot-statements` / `bot-bank-statements-last` / `bot-balance` / `bot-queue-mark` were **pre-BK2-cutover stale on qnccph** (legacy `invalid_bot_secret`) — the auth campaign's "all-26-EF at HEAD" deploys never included the bbot adapter EFs. Tester redeployed them at HEAD on qnccph (with `bot-config` + a tester-provisioned `BOT_CRED_ENC_KEY` probe key) during the authorized regression deploy; qnccph is now at true HEAD `000300`/136 migs.

**Asks (no urgency, fold into your next deploy pass):**
1. Check **sinuw** for the same staleness (bbot EFs + `BOT_CRED_ENC_KEY` presence) — tester is RO-only there and could not verify.
2. Add the bbot EF set to whatever ledger/checklist defines "all EFs at HEAD" so future sweeps include them.
3. Note: qnccph now carries a tester-provisioned probe `BOT_CRED_ENC_KEY` (31-char, /tmp-only). If qnccph needs a canonical key instead, rotate at your convenience.
