---
title: flow — queue-claim-to-processing-state-machine — ratified revision (S4 → S2 via 
tags: [technical-writer, repo:bank-bot, current, flow, flow:queue-claim-to-processing-state-machine, ratified, revision, queue-claim, recycle-sentinel, state-machine, cross-cutting, s2]
created: 2026-04-22
source: Oracle Learn
project: github.com/kokarat/bank-bot
---

# flow — queue-claim-to-processing-state-machine — ratified revision (S4 → S2 via 

flow — queue-claim-to-processing-state-machine — ratified revision (S4 → S2 via Oracle thread #36, 2026-04-22). Supersedes the first-pass S4 learning filed earlier the same day.

**Doc:** `docs/flows/queue-claim-to-processing-state-machine.md@<follow-up-commit>` (was `098a400` on first pass, header updated on ratification commit).
**Thread:** #36 — closed 2026-04-22, skipping `answered` intermediate per ratification-thread-closure discipline.
**PR:** kokarat/bank-bot#99.
**Cross-repo counterpart:** `mobiz-payment-gateway/docs/flows/withdrawal-queue-dispatch-and-claim.md` step 4 (unchanged — ratification did not alter the cross-repo mapping).

**Five judgment calls, ratification verdict = all acked as-is:**
1. **Scope boundary** — claim decision + recycle sentinels only. Per-item terminal-call mechanics stay delegated to `scb-dual-control-withdrawal.md` / `ktb-single-transfer-withdrawal.md`. Avoids ~40% duplication.
2. **Actor granularity** — 4 actors (PollLoop, Maker, TransferSession, Gateway). Surfaces the outer-claim-runs-all-guards vs continuation-claim-skips-guards asymmetry. Diverges from `deposit-auto-match-from-statement.md` single-actor house style because the asymmetry IS the flow's content.
3. **Loop-wrapped mermaid** — kept. Cadence (30s) + recycle branches (`alt sentinel tripped / else continue`) + two distinct loop bodies (outer poll vs in-session continuation) are correctness-relevant.
4. **Claim strength** — S4 first pass, S2 post-ratification. Matches the `scb-dual-control-withdrawal` sibling trajectory (S4 → S2 via thread #18).
5. **Error codes inline vs registry** — inline for now. Revisit when a fifth bank-specific code lands (e.g. KBANK module adds its own sentinel) — spin out `bank-error-code-registry.md` at that point, backlink from flow docs.

**Five spot-check values, all verified against `app.js@098a400`:**
- `MAX_FAILED_BATCHES_BEFORE_RECYCLE = 2` still active at both `processSingleTransfer` sites (`app.js:1663-1669` batch + `app.js:1731-1737` single-item).
- `approverRecycleRequested` flag-passing mechanism confirmed: flipped in `approverLoop` at `app.js:981,1012`, honoured by `makerLoop` at `app.js:594-599`. Rationale: `approver` can't call `resetBrowser()` directly while `maker` holds a live context on the same Chromium process.
- `KTB_NEED_RELOGIN` one-shot retry hard-cap confirmed at `app.js:1601-1615`. Zero-items-touched contract is the load-bearing safety guarantee (enforced by the throw site at `banks/ktb/transfer.js:204` being the FIRST action of `navigateToTransfer`).
- `MAX_ITEMS_BEFORE_RECYCLE = 20`, `MAX_LOGIN_FAILURES_BEFORE_RESET = 3` — both confirmed live.

**What changed on ratification (doc-side):**
- Header `Claim strength` line: `S4 — reverse-engineered ... pending` → `S2 — ... ratified 2026-04-22 via Oracle thread #36 ...`
- Added `// ratified-via-thread:36` marker line.
- Change log entry added for the S4 → S2 transition + future-follow-up note (registry extraction when fifth code lands).
- No content changes to §Purpose / §Actors / §Preconditions / §Sequence / §Success criteria / §Error paths / §Postconditions / §Implementation pointers — ratification did not surface any errors.

**Follow-up learnings implicit in ratification:**
- `bank-error-code-registry.md` extraction is deferred, NOT cancelled — re-raise when a fifth bank-specific sentinel code is added.
- Two gap-list flows from the 2026-04-22 W8 gap analysis remain open: `statement-push-error-handling-and-retry` and `scb-session-dead-recovery-re-login`. Not in PR #99 scope.

---
*Added via Oracle Learn*
