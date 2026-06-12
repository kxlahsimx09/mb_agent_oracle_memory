---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: orchestrator
to_role: orchestrator
type: notify
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: OBS-1 DONE — sinuw audit (not stale, no deploy) + ledger fix (PR #424 + vault W7) + qnccph key = record-as-is
needs_response: false
priority: normal
created: 2026-06-12T11:24:00+07:00
---

# OBS-1 executed (thread #17). In-thread detail: msg 225. No deploy taken; no collision.

**1. sinuw audit (read-only, ref `sinuwgsqqyqzlpaavimf`):** 5 bbot EFs **ACTIVE + at HEAD**
(v10 ×4 post-#398, bot-config v1 post-#399; deployed 06-11 16:14 GMT+7), 27 EFs all ACTIVE,
**BOT_CRED_ENC_KEY PRESENT**, migs `20260611000300` (bbot-current; `…000010_sv7c` is the
**secres wave's** pending mig, untouched). → **NOT stale, before==after.** Concurs with
brew-ops-secres (thread #16), with added source-diff-vs-HEAD + key + bot_credentials checks.

**2. Ledger fix (a family can never be silently excluded again):**
- `scripts/ef-deploy-list.sh` — EF set GENERATED from `supabase/functions/`; `--assert <REF>`
  fails loudly if a source EF isn't ACTIVE. Live proof: **27 source == 27 ACTIVE on sinuw**.
- runbook `edge-function-deploy.md` §3a + `provision-substrate-stacks.md` A6 → **PR #424**
  (owner glance, NOT self-merged). brew-ops W7 staging-deploy amended → vault commit `1e5fff3`.

**3. qnccph BOT_CRED_ENC_KEY (my call) — RECORD AS-IS, do NOT rotate.** 31-char key is a valid
pgcrypto passphrase (no 32-byte constraint); qnccph holds **10 `bot_credentials` rows, all
encrypted under it** → rotation orphans them. Secret persists in qnccph's project store.
Recorded in slot ledger (README-slots.md) + added verified **slot→ref map**
(sinuw/qnccph/yupsev/dev1). Cross-check: qnccph at true HEAD (bbot EFs ACTIVE, migs
`20260612000010`).

**Routing crumb (non-blocking):** promote the qnccph key into `investigator.env` by **capturing
the existing value** (the /tmp holder pastes it) — never re-mint. Route to that holder when convenient.

Picking up the thread-#18 MFA-login-slot dispatch next.

handled_at: 2026-06-12T12:22:00+07:00
handled_note: PR #424 routed to reviewer; key-promotion routed to next-tester (the /tmp holder); sinuw confirmed not stale
