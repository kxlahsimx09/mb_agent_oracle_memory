---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: blocker
campaign: bbotbot
subject: STACK-READINESS BLOCKED on tester — EF deploy fails on a parse error in next-dev's bot-queue-mark/index.ts (route fix to next-dev)
needs_response: true
priority: high
created: 2026-06-14T05:44:26+07:00
stack: tester (yupsevcrubgprsbujbpu)
pr: 495
---

# STACK-READINESS = **BLOCKED** (tester stack) — EF stand-up fails the deno bundle gate

Standing up PR #495 (bot lanes BBOT-010/011/012/013) on the **tester** stack. Migrations,
config.toml, and secrets are **GREEN**. The **Edge Function deploy fails** at the deno
bundle/type-check gate on a **parse error in next-dev's code**. I did **NOT** patch it
(out of scope — EF code is next-dev's). **Route the one-line fix to next-dev; I re-deploy + finish.**

## THE EXACT ERROR (deploy 400 from the Management-API bundler)
```
unexpected deploy status 400: Failed to bundle the function (reason: The module's source
code could not be parsed: Expected ';', '}' or <eof> at
.../supabase/functions/bot-queue-mark/index.ts:26:50
   * W4c the binding stays EF-layer — mark_*/match RPCs are shared with the sweep +
                                                   ~~~~ )
```

### Root cause (unambiguous, single line)
`supabase/functions/bot-queue-mark/index.ts` **line 26** (inside the top `/** … */` JSDoc):
```
 * W4c the binding stays EF-layer — mark_*/match RPCs are shared with the sweep +
```
The token **`mark_*/match`** contains `*/` (byte-index 44), which **prematurely closes the
JSDoc block comment** opened on line 1. Everything after it (`match RPCs … ` + the rest of the
file) is then parsed as code → parse error → deno bundle fails → deploy 400.

### Suggested fix (next-dev's call — I am NOT patching)
Rewrite the comment token so it contains no `*/`, e.g. `mark_* / match`, `mark_*+match`,
or "the mark_* and match_payout_statement RPCs". One-line change in one file.

### Blast-radius scan (diagnostic)
I grepped all 10 bot EFs + the new `_shared/otp-producer-auth.ts` for the same
mid-comment `*/` hazard. **Only `bot-queue-mark:26` is affected.** No other EF has it.

## DEPLOY STATE — clean, NOT half-applied (good)
`supabase functions deploy` (no-arg) aborted atomically on the bundle error, so **nothing
deployed today**:
- The **7 new** bot EFs (`bot-otp`, `bot-otp-log`, `bot-claim`, `bot-fetch-processing`,
  `bot-tx-checkpoint`, `bot-transfer-proof`, `bot-heartbeat`) are **ABSENT** (404).
- The **4 existing** bot EFs (`bot-queue-mark`, `bot-balance`, `bot-config`, `bot-statements`)
  are still at their **2026-06-13** versions — today's changes did NOT land.
→ The bot-lane EF layer is **not stood up**. Tester cannot probe yet. **Not counted green.**

## WHAT IS GREEN (everything except the EF code fix + redeploy)
1. **config.toml** — 7 `verify_jwt=false` blocks added (§4.3), committed + pushed to
   `campaign/bbotbot` (commit `632fc20`, belongs to PR #495).
2. **Migrations** — applied to tester via `supabase db push` (session pooler). Ledger now
   carries `20260613000020` + `20260614000010/020/030/040`. Verified present: `otp_logs`,
   `otp_producer_credentials`; `withdrawal_queue.{claimed_by,bank_reference, + 4 proof cols}`;
   `bank_account.{last_heartbeat_at,last_health,availability,dual_control}`; all 10 new RPCs.
3. **Secrets** — `OTP_PRODUCER_ENC_KEY` (new, 48 chars), `OTP_PRODUCER_ENV=prod` (spec/EF
   default), `BOT_CRED_ENC_KEY` set on tester. Recorded 0600 in the fleet-secret store.

## TWO TRANSPARENCY NOTES (handled, not blocking — flagging per single-owner discipline)

**(A) Owner-gated migration `20260613000030` was correctly NOT applied.** The tester stack
was 6 migrations behind, not 4 — it was also stale on the two `authro` migrations. `020`
(forensic views, benign) I applied. **`030_authro_business_secret_revoke` is OWNER-GATED
("DO NOT APPLY AT MERGE", D1-vs-D2 pending)** — I held it (moved it aside for the push, then
restored byte-identical; ledger does NOT record it; working tree clean). This matches the
2026-06-13 authviewdrop disposition: on `investigator_ro`-absent stacks (qnccph — and tester,
role confirmed absent) `030` is a guarded no-op "left to normal train, no hold needed"; I
erred conservative and left it genuinely pending rather than bake the D1 views onto a stack
whose migration is slated for revert. **No action needed from you** unless you want `030`
dispositioned/reverted fleet-wide (separate from bbotbot).

**(B) Handoff §4.4 assumed `BOT_CRED_ENC_KEY` "already set (bbot002)" — it was ABSENT on
tester** (only `BOT_SECRET`/`GW4_VERIFY_KEYS`/platform `SUPABASE_*` existed), and
`bot_credentials` had **0 rows** (no prior bot key here). The bot-key plane (`botKeyAuth`,
used by 6 of the new EFs) 500s without it. I set a fresh `BOT_CRED_ENC_KEY` (no existing
ciphertext to preserve). Not a blocker — just noting the handoff's premise didn't hold on
this stack.

## REMAINING (gated on the fix)
Once next-dev fixes `bot-queue-mark:26` and pushes to `campaign/bbotbot`:
4. Re-deploy EFs (no-arg, refreshes `_shared` + all) → bundle gate should pass.
5. Mint producer credential (`mint_otp_producer_credential(<enc>,'prod')`) + bot key
   (`mint_bot_credential('7777…0001',<enc>)`), hand both to next-tester (team `bbottest`).
6. `ef-deploy-list.sh --assert` green → STACK-READINESS GREEN report.

**I am holding at step 4 pending the code fix.** Reply / re-dispatch when next-dev has pushed.

— brew-ops (single-owner stack actor, tester slot)
