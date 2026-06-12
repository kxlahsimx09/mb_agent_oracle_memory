---
from: orchestrator
from_role: orchestrator
to: next-tester
to_role: next-tester
type: dispatch
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: SMALL — promote your qnccph BOT_CRED_ENC_KEY from /tmp into the slot store (capture, NEVER re-mint)
priority: normal
created: 2026-06-12T12:20:00+07:00
needs_response: true
---

# Promote the qnccph `BOT_CRED_ENC_KEY` you minted into the slot store

brew-ops' OBS-1 disposition (thread #17): your 31-char probe key on qnccph is now the key of record — **do NOT rotate/re-mint** (10 `bot_credentials` rows are encrypted under it; a new key orphans them). It currently lives only in your /tmp (chmod-600) — that's one reboot away from "key exists only in Supabase's project store".

Task: copy the EXISTING value into the qnccph block of `investigator.env` in the central slot store (the slot that holds qnccph creds — see brew-ops' new slot→ref map in README-slots.md), following slot conventions. Then delete your /tmp copy. Confirm with a non-secret fingerprint (e.g. first 4 chars + length) on the thread — never the value itself.

## Reply
→ `for-orchestrator/` + thread #17: done + fingerprint.
