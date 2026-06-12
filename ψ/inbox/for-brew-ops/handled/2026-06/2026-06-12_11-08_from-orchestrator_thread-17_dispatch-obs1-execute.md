---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops (GATEWAY stacks — window brew-ops-obs1; oracle-repo instance please ignore)
type: dispatch
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: OWNER GO — execute OBS-1 now: sinuw bot-EF staleness audit + deploy-ledger fix (supersedes the 11:01 FYI)
priority: high
created: 2026-06-12T11:08:00+07:00
needs_response: true
handled_at: 2026-06-12T11:24:00+07:00
handled_by_thread: 17
handled_by_inbox: for-orchestrator/2026-06-12_11-24_from-brew-ops_thread-17_reply-obs1-complete.md
handled_note: sinuw not stale (no deploy); ledger fix PR #424 + vault W7 1e5fff3; qnccph key = record-as-is
---

# OBS-1 — execute now (owner GO 2026-06-12; supersedes the low-priority FYI `..._11-01_..._fyi-obs1-...`)

Background (regression run, thread #17): the "all-26-EF at HEAD" deploy sweeps never included the bbot adapter EFs (`bot-config`, `bot-statements`, `bot-bank-statements-last`, `bot-balance`, `bot-queue-mark`). On qnccph they sat pre-BK2-cutover stale until next-tester redeployed them at HEAD today (qnccph now true HEAD, migs `000300`/136, tester-provisioned probe `BOT_CRED_ENC_KEY`). sinuw is UNVERIFIED (tester is RO-only there).

## Task

1. **Audit sinuw**: deployed versions of the 5 bbot EFs vs HEAD + `BOT_CRED_ENC_KEY` presence + migs rev. Report what you find BEFORE changing anything.
2. **If stale → deploy the bbot EF set at HEAD on sinuw.** Guardrails:
   - sinuw is the staging/LIVE-mode stack and the **livegate + secres teams are active today** — check for in-flight runs (their lanes in session 03) and announce on thread #17 before bouncing anything; additive only; record rev before/after.
   - If you find an in-flight run, coordinate through me rather than racing it.
3. **Fix the ledger**: wherever "all EFs at HEAD" is defined (deploy checklist/ledger), make the EF list GENERATED from `supabase/functions/` at HEAD rather than a frozen count, or at minimum add the bbot set explicitly — the goal is that future sweeps cannot silently exclude a family again.
4. **qnccph key (your call):** the probe `BOT_CRED_ENC_KEY` tester provisioned is 31-char /tmp-only. Rotate to a canonical slot-managed key if conventions require; otherwise record it in the slot ledger as-is.

## Reply

→ `for-orchestrator/` + thread #17: sinuw audit result + actions taken (with before/after revs) + where the ledger fix landed + key decision.
