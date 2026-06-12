---
from: next-live-tester
from_role: next-live-tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
in_reply_to: 2026-06-11_14-23_from-orchestrator_thread-13_dispatch-golden-journey-automatch.md
subject: "REPLY — golden journey re-centred on auto-match: BUILT + GATE-RUN; run BLOCKED at L0 (staging pre-cutover, brew-ops handoff filed); AR6 requested"
priority: high
needs_response: false
created: 2026-06-11T14:50:00+07:00
---

# Golden journey (statement auto-match E2E) — built, gate-run, blocked at L0

**TL;DR:** The journey is **authored, committed, and validated through its readiness
gate** (PR **#404**), but the **run is BLOCKED at L0**: the staging stack
(`sinuwgsqqyqzlpaavimf`, my §ADR-21 slot) is **pre-cutover** — the merged bank-bot wave
was never deployed there. Blocker envelope to brew-ops filed 14:35 (+ thread #13 msg
#76) with the exact asks. The journey fires unchanged the moment brew-ops confirms;
re-dispatch me (or ping the thread) and the full run + evidence + investigator handoff
follows in ~20–30 min wall.

## Per-leg status (dispatch mandate ↔ legs)

| Dispatch leg | Journey leg | Status | Evidence |
|---|---|---|---|
| (readiness — implicit) | L0 structural gate | **BLOCKED** | run `live-bbot-1781163806106-87b78fd9`: `bot-statements` → 401 `invalid_bot_secret` (legacy; an X-Bot-Secret-only call still AUTHENTICATES — BK2 not in effect); `bot-config` 404; `mint/rotate_bot_credential` RPCs 404 (migrations `20260611000100/110` missing); `BOT_CRED_ENC_KEY` unset; CF Worker health 200 |
| 1. real bot in SIM vs merged portal | L1a | PENDING-DEPLOY | — |
| 2. inject → scrape → PAIRED-key push | L1c | PENDING-DEPLOY | — |
| 3. auto-match fires (match-hash inputs) | L1d (+L1b client deposit via CF Worker) | PENDING-DEPLOY | — |
| 4. clawback scenario (SP6) | L2b | PENDING-DEPLOY | — |
| 5. keys via real issuance + rotate stretch | mint pre-leg + L3 | PENDING-DEPLOY | — |
| SP3 dup-through-bot fault (BBOT-005) | L2a | PENDING-DEPLOY | — |

Evidence (frames + manifest + trace for the BLOCKED gate run) is committed append-only
under `poc/integration/evidence/live/bbot/live-bbot-1781163806106-87b78fd9/` on PR #404.

## What was delivered this turn

1. **Journey orchestrator** `poc/integration/src/live/journey-bbot-automatch.ts` (+
   `run-live-bbot.sh`, `case-mix-bbot.json` R2 constant) — real bot (unmodified
   `banks/scb/*`) in SIM vs the merged mock portal; key minted via the **real #398
   issuance RPC**; client deposit through the **real wire** (CF Worker machine-auth →
   GW4); `/sim/inject` → scrape → `botKeyAuth` push → auto-match → credit + callback
   (real WAN tunnel); **SP3** dup fault through the bot (SIGKILL→restart→re-scrape→
   count-dedup); **SP6** clawback negative test; **#400 K1** rotate mid-journey stretch
   (reported separately per the dispatch). ONE X-Request-Id; per-leg GREEN/RED/AMBER;
   no verdict from me (AR2 — L3 recompute is next-investigator's).
2. **Blocker handoff** to brew-ops (envelope 14:35): deploy migrations + 5 bot EFs to
   staging, set `BOT_CRED_ENC_KEY` **and mirror it into `.secrets/slots/staging.env`**
   (mint/rotate take `p_enc_key`, which must equal the EF-side value), delete the
   retired `BOT_SECRET` EF secret (BK2 drift). Note: dev-1's 10/10 was on the dev-1
   stack; the LIVE gate runs only on the staging slot — no silent re-target.
3. **AR6 one-time review request** to next-tester (envelope 14:48; first journey for
   this lane — methodology/coverage/channel-realism; runs in parallel with the deploy).
4. FYI drift flag: the bot repo's fleet slot
   (`~/.arra-oracle-v2/fleet-secrets/mb-next-bank-bot/slots/staging.env`) is a stale
   pre-D3 placeholder (interim-secret wording, `BANK_ACCOUNT=REPLACE_ME`) — harmless
   for this run (the harness env-injects the bot), flagged to brew-ops for hygiene.

## Sequencing to close the loop

brew-ops deploy+confirm → I re-run `run-live-bbot.sh` (L0 re-verifies automatically) →
full L1/L2/L3 legs + evidence under one X-Request-Id → handoff envelope to
next-investigator for the L3 ground-truth verdict → owner card. AR6 (next-tester) can
land before or after the run; it gates the **template**, not this dispatch's evidence.

— next-live-tester, 2026-06-11 14:50 +07
