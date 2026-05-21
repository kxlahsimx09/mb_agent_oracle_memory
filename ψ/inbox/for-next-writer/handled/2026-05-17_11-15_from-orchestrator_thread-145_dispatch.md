---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: dispatch
thread: 145
parent_thread: 145
parent_oracle: orchestrator
subject: epic-deposit DEPOSIT-001 — clarify the confusing `bank_code` / "destination bank code" wording
priority: normal
needs_response: true
created: 2026-05-17T11:15:44+07:00
---

# Clarify the `bank_code` wording in DEPOSIT-001

The user read `docs/requirements/epic-deposit.md` DEPOSIT-001 and found the `NO_BANK_AVAILABLE_AFTER_EXCLUSION` acceptance criterion confusing.

## The problem

**Line 66** (the AC) calls the request parameter a "**destination bank code** (e.g. `bank_code=KTB`)". That phrasing reads as *"the bank the client wants the deposit to go to."* But the actual semantics — spelled out in the **line 73** edge case — are the opposite: `bank_code` is an **exclusion key**. Pool rotation **drops** system banks of that same code, so the end-user's transfer is inter-bank, because an intra-bank transfer (e.g. KTB→KTB) yields a bank-statement shape the matcher cannot reconcile (the recipient-name field is stripped).

So "destination bank code" is misleading wording for what is really *the bank to avoid*. A reader cannot tell from line 66 alone that `bank_code` triggers an exclusion — they have to reach line 73 to find out, and the two even contradict in tone.

(The current system already had a same-class naming confusion — see §CB1, the `custom_bank_*` → `customer_bank_*` rename — so this is a known failure mode worth fixing cleanly.)

## Task

Reword the DEPOSIT-001 acceptance criterion (line 66) so the `bank_code` parameter is described **unambiguously as an exclusion** — and reconcile the line 73 edge case so both use consistent terminology.

- **Wording / clarity only — no behavior change.** The 503 / `NO_BANK_AVAILABLE_AFTER_EXCLUSION` / no-row / no-fallback semantics stay exactly as they are.
- Keep it at requirements-level — per-bank rotation mechanics stay in the design pass, as line 73 already notes.

**Before pushing — mandatory:** run the W1 Step 8 mermaid parser gate (`references/check-mermaid.mjs`) on `epic-deposit.md`.

Open a PR off `main`; do not merge — the user merges. `needs_response: true` — reply on **thread #145** with the PR number, then archive this envelope (§11d).

— orchestrator, 2026-05-17 11:15 GMT+7
