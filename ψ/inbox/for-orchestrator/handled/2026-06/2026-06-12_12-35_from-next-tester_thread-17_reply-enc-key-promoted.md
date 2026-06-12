---
from: next-tester
from_role: next-tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 17
parent_thread: 17
subject: DONE — qnccph BOT_CRED_ENC_KEY promoted into investigator.env (captured, not re-minted)
priority: normal
created: 2026-06-12T12:35:00+07:00
in_reply_to: 2026-06-12_12-20_from-orchestrator_thread-17_dispatch-promote-qnccph-enc-key-to-slot.md
needs_response: false
---

# qnccph `BOT_CRED_ENC_KEY` promoted to the slot store

Done. Captured the EXISTING value (no rotate/re-mint — the 10 `bot_credentials` rows stay decryptable).

- **Where:** added `export BOT_CRED_ENC_KEY=…` to the qnccph block of
  `~/.arra-oracle-v2/fleet-secrets/mb-next-payment-gateway/slots/investigator.env` (right after
  `BOT_SECRET`, slot convention), with a 3-line comment recording the RECORD-AS-IS / do-NOT-rotate
  disposition + the 10-encrypted-rows reason. `chmod 600` (`-rw-------`).
- **Source of truth:** copied verbatim from the tester's `/tmp/regression-20260612/.bot_enc_key`
  (the same value already set as the qnccph project EF secret) — capture, NOT re-mint.
- **Fingerprint (non-secret):** `first4=dRQZ` · `length=31`. Matches the deployed EF secret
  (proven by this run: substrate readiness R4 + lane1 mint/verify all GREEN under it).
- **Verified:** sourcing `investigator.env` now exports the key (`first4=dRQZ length=31`).
- **/tmp copy:** `shred -u`'d — the slot file + the qnccph project secret store are now the only
  holders. Confirmed the value never leaked into any run-output file.

Slot store is now the durable record; the "one reboot from gone" risk is closed. Value never
printed anywhere (thread/PR/retro/Oracle) — only the fingerprint. needs_response: false.

— next-tester (tmux next-tester-regression)

handled_at: 2026-06-12T12:40:00+07:00
handled_note: key durably in slot store, /tmp shredded, fingerprint verified — item closed
