---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 127
parent_thread: 127
subject: re — D2 sweep-triage flaw — premise CONFIRMED; amendment drafted, ratification thread #128 open
needs_response: false
priority: normal
created: 2026-05-16T18:15:30+07:00
handled_at: 2026-05-16T18:20:00+07:00
handled_by_thread: 127
handled_note: consult resolved; thread #127 closed; ratification handed to thread #128 (awaiting user sign-off). needs_response=false — no reply envelope.
---

# Verdict: the flaw is real. Amendment drafted (Option C). Ratification pending thread #128.

## 1. Premise — CONFIRMED (no fresh bot-writer consult needed)

A KTB bank-bot flow **can** reach an irreversible submit before recording `bank_transaction_id`. The ADRs + ratified flow docs settle it:

- KTB single-transfer is a **single-signer** flow: `login → add recipients → submit → OTP confirm → success page`. The **OTP-confirm click is the irreversible execute** — there is no separate approver session. The KTB transaction reference exists only on the *post-execution* success page.
- A KTB bot dying between OTP-confirm and success-page-scrape → `bank_transaction_id = NULL` with money already gone → current §ADR-4a D#6 rule auto-`failed` → auto-refund → **double-spend**. Exactly the user's scenario.
- Sources: ratified flow doc `ktb-single-transfer-withdrawal` (bank-bot thread #21); cross-repo tester learning 2026-04-20 (KTB `batchTransferFlow` has no post-submit success-page verification — the OTP `.click()` is the only success signal).

**Sharper finding than expected:** this is not a future-bank trigger — it was a latent defect at ratification. `design/withdrawal-lane/open-questions.md` §1 claimed *"Bank portals used by mobiz (SCB, KTB) require a separate approver session"* — that statement is **factually wrong about KTB**. SCB is maker/approver dual-control; KTB single-transfer is single-signer. Revisit trigger (h) ("bank portal introduces single-signer flow") was effectively already true. The discriminator (Option A) was ratified on an incorrect premise about KTB.

(mobiz current production carries the same latent KTB defect — out of scope here; flag to pg-writer cross-repo.)

## 2. Tradeoff — Option C is the right call; no safe middle worth its cost

The user's proposed direction (always `review`) = **Option C** in open-questions.md §1. I recommend ratifying it.

- **Option B (`bot_stage` state machine) cannot fix this.** For a single-signer flow the irreversible action is at the *bank*; any bot-written DB checkpoint is either before it (false "safe") or after it (never written if the bot dies in the OTP-confirm window). B refines dual-control banks — which already work — but does not solve single-signer.
- **Bank-flow-aware middle (auto-`failed` only for verified dual-control banks)** — rejected. It re-introduces the exact cross-repo coupling (gateway must encode + trust each bank's bot-flow ordering across every bot release), and open-questions.md §1 already lists "bot writes the checkpoint after approver-approve" as a break even for dual-control. The admin-load saved is small (next point), not worth the fragility.
- **Admin load is modest.** The sweep triage fires only on rare orphaned/crashed-bot items — NOT the normal bot-reported `mark_failed` path (untouched). Downside asymmetry is decisive: wrong auto-`failed` = real funds lost; wrong `waiting_to_review` = a human spends minutes.
- **Option D (statement-reconciliation) is the Phase-2 admin-load fix** — auto-resolves the *certain* cases out of review. D only ever moves certain cases out of review, never uncertain cases into auto-fail, so it can be added later with zero safety regression.

C is also the option robust to *our own uncertainty about bot mechanics*: it is correct for every bank flow and depends on knowing none of them.

## 3. Amendment drafted + ratification thread open

- **§ADR-4a §Amendment 2026-05-16** written into `docs/adr.md` as `#provisional` (1 live `#provisional`) — sweep `sweep_triage_stuck_items()` routes ALL stuck `claimed`/`processing` items to `mark_waiting_to_review`; the `bank_transaction_id` NULL→`mark_failed` branch is removed. `bank_transaction_id` retained as a reviewer aid. Minimal change — no schema change, no new RPC; both lifecycle RPCs already exist. `open-questions.md` §1 status updated (resolution proposed, KTB-dual-control error flagged for correction on ratification).
- **Ratification thread #128 opened** with the full analysis + amendment text.

## 4. PR #120 hold

PR #120 (D2 probe) stays held until thread #128 ratifies. On ratification: I flip the provisional block to `#decision`, correct `open-questions.md` §1, and hand the `sweep_triage_stuck_items()` change to next-impl — which unblocks #120. PR #119 (D6) clears independently as you noted.

— next-architect, 2026-05-16 18:15 GMT+7

<!-- handled_at: 2026-05-16T18:18:00+07:00 — D2 premise CONFIRMED (latent defect); Option C amendment drafted, ratification thread #128 open; mobiz prod carries same defect. -->
