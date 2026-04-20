---
title: ratified revision — flow ktb-single-transfer-withdrawal (S4 to S2 via Oracle thr
tags: [technical-writer, repo:bank-bot, current, flow, flow:ktb-single-transfer-withdrawal, ratified, ratification, s2, thread-21, recovered-from-double-wrap]
created: 2026-04-19
source: docs/flows/ktb-single-transfer-withdrawal.md post-ratify (bank-bot PR 79); thread 21 closed 2026-04-19; mobiz sibling at 252849e — recovered 2026-04-19
project: github.com/kokarat/bank-bot
---

# ratified revision — flow ktb-single-transfer-withdrawal (S4 to S2 via Oracle thr

ratified revision — flow ktb-single-transfer-withdrawal (S4 to S2 via Oracle thread 21, Q5 scope REVISE)

The reverse-engineered bot-side flow doc `docs/flows/ktb-single-transfer-withdrawal.md` was ratified via Oracle thread #21 on 2026-04-19 (closed same day). Seven judgement calls were raised in the S4 draft; the ratification outcome per question:

1. **Slug name** (`ktb-single-transfer-withdrawal` vs alternatives) — AFFIRM. Current slug stays. Matches the `scb-dual-control-withdrawal` precedent for per-bank slugs paired with generic mobiz slugs.
2. **Loop-wrapped mermaid** (vs linear) — AFFIRM. Loop-wrap is the right form for the claim-batch-OTP cycle. Rendered dimensions fit the 10-crossing cap without flattening into linear form.
3. **Actor framing** (`MZ` gateway as a single actor vs decomposed) — AFFIRM. Gateway decomposition belongs in the mobiz-side sibling; bot-side keeps `MZ` compact.
4. **Drift carry-forward** from mobiz (`[AWAITING_THREAD:15]` and `:16`) — AFFIRM. Bot doc carries forward verbatim; no re-filing. Resolution happens at next W9 sweep.
5. **Scope boundary** (include ktb-login-with-otp internals inline vs split) — **REVISE**. Split the login-with-OTP scope into its own flow doc `ktb-login-with-otp.md`. Parent keeps Step 0a as a precondition pointer. Rationale: the phase-cascade OTP logic + two session-reuse short-circuits have their own lifecycle separate from the claim loop, and unpacking them inline would triple the parent's step count.
6. **Sentinel density** (four `KTB_*` sentinels as first-class §Error paths entries vs fewer) — AFFIRM. Each sentinel has distinct recovery behaviour; collapsing would erase meaningful differences.
7. **Naming disclaimer** ("reverse-engineered S4" banner at top) — AFFIRM. Keep banner until a human-ratified revision lands (this one).

Ratification outcome: S4 → S2. `[RATIFICATION_PENDING:21]` marker stripped; replaced with `// ratified-via-thread:21` pointer. `docs/flows/.baseline` bumped to `1cf5e14`. The S4 predecessor learning `learning_2026-04-19_title-flow-ktb-single-transfer-withdrawal` (double-wrap recovered) now superseded by this ratified variant.

Downstream effects: the Q5 REVISE triggered authoring of `docs/flows/ktb-login-with-otp.md` in the same session (separate W8 pass, trace `ff47aa94-…`). Bot-side flow portfolio after ratification: `scb-dual-control-withdrawal` (S2), `deposit-auto-match-from-statement` (S2 bot-side), `ktb-single-transfer-withdrawal` (S2 as of this ratification), `ktb-login-with-otp` (S4 pending thread #23) = 3 ratified + 1 pending → unblocks W9 on the 3 ratified.

Related: thread #21 closed 2026-04-19 with 7 human answers; PR #79 (bank-bot) carries the baseline bump + ratified-via-thread marker; mobiz sibling at `252849e` unchanged (ratification affects only bot-side prose, not the shared contract).

RECOVERED 2026-04-19 from double-wrap file `2026-04-19_title-ratified-revision-flow-ktb-single-tra.md`; supersedes `learning_2026-04-19_title-ratified-revision-flow-ktb-single-tra`.

---
*Added via Oracle Learn*
