---
from: bot-writer
from_role: bot-writer
to: orchestrator
to_role: orchestrator
type: report
thread: 88
parent_thread: 108
parent_oracle: orchestrator
subject: bank-bot orphan-marker pass complete — 0 live orphans, 13 narration mentions de-bracketed, PR #114
needs_response: false
priority: normal
created: 2026-05-16T12:28:00+07:00
---

# Campaign #108 / thread #88 — bank-bot orphan-marker pass: outcome

## Genuine result

**0 live orphans.** Confirmed the corrected brief (msg 275) — bank-bot matches
the #86/#87 pattern. Classified every hit in context (`grep -rnE`, file:line):

- **13 flagged markers = historical narration**, all inside `## Change log`
  bullets. The live markers were stripped from doc headers/bodies in prior
  ratification passes; PR #90 (Apr) converted the KTB `AWAITING_THREAD` body
  markers to `DRIFT-N RESOLVED`. The change logs only *narrate* that history.
- **2 VALID** `[UNDOCUMENTED-STEP:50]` in `scb-login.md` — thread #50 still
  `pending`. Retained, untouched.
- **0** prematurely-closed threads with open claims (no reopen needed).

## Action taken

De-bracketed the 13 change-log mentions (`[TOKEN:N]` → `TOKEN:N`) across 6 flow
docs so the workflow-5 §13c audit grep stops false-flagging them, + a dated
reconciliation entry per change log. No prose deleted (P-001) — only the
`[...]` live-annotation syntax removed from past-tense narration.

| File | De-bracketed |
|---|---|
| bot-otp-relay.md | `RATIFICATION_PENDING:39` ×2 |
| bot-maintenance-mode-window.md | `:35` ×1 |
| bot-otp-imap-fallback.md | `:40` ×2 |
| bot-bootstrap-and-status-reporting.md | `:30` ×2 |
| ktb-login-with-otp.md | `:23` ×2 |
| ktb-single-transfer-withdrawal.md | `:21` ×2 + `AWAITING_THREAD:15` + `:16` |

Audit grep now returns only the 2 VALID `UNDOCUMENTED-STEP:50`.

**PR: kokarat/bank-bot#114** — https://github.com/kokarat/bank-bot/pull/114
Branch `docs/strip-orphan-thread-markers-2026-05-16`. Thread #88 closed.

> Note on PR target: the finishing brief said "push to the fork." bank-bot has
> no fork remote — single `origin` = `kokarat/bank-bot`. Its established
> convention (PR #90 / #112 / #113) is feature-branch on origin → PR to `main`,
> so #114 follows that. The `feedback_fork_prs_not_upstream` learning is
> Soul-Brews-Studio-scoped (maw-js / arra-oracle-v3) and is itself superseded
> by the long-lived-branch / fork-as-backup-only learning — it does not govern
> bank-bot. Flagging in case the brief's wording reflects a stale assumption.

## Grep-scoping suggestion (audit-method fix — already tracked as #112)

The workflow-5 §13c `grep -rohE` over-counts because it matches every literal
marker string, including past-tense narration of completed strips. Recommend
scoping it to **exclude `## Change log` sections** (and `revision-log-*` files,
per #87) before counting — e.g. strip everything from a `^## Change log` line
to EOF, or `grep -v` lines beginning with a dated change-log bullet. Without
that, any flow doc that *narrates* a marker lifecycle will be re-flagged on
every audit cycle. Noted that #112 already owns this fix.

## Step 0.5 sweep — 4 un-misfiled bot-writer handoffs in `ψ/inbox/handoff/`

Triaged per W9 Step 0.5 (consume + build affected-flows list). Dispositions:

1. **`...mobiz-5ce4596-botconfig-pullout-trigger.md`** — NO ACTION. Handoff
   itself states no bot flow doc needs revision; the 3 docs citing
   `BotConfigController.go` cite functions unmodified by `5ce4596`. Informational.

2. **`...transactionmatcher-transaction-date.md`** (mobiz `b31866f`, P2) —
   **GENUINE DRIFT.** `docs/flows/deposit-auto-match-from-statement.md`
   §Postconditions needs a `payment_details.transaction_date` annotation (now
   the bank's reported transfer time, not scrape time; fallback to ScrapedAt
   when `transaction_date_bkk = 0`). Exact text supplied in the handoff. Added
   to affected-flows list — **not applied here** (independent of #88; deposit
   doc untouched by this pass). Dispatch to next bank-bot W9.

3. **`...w8-revision-ktb-login-with-otp-q4...`** — **LIVE, W8 task.** Thread #23
   Q4 verdict (promote `ensureLoggedIn`/`checkSession` to first-class numbered
   steps in the `ktb-login-with-otp.md` sequence diagram) is still un-applied —
   header carries the verdict, the mermaid/step-numbering does not. This is a
   **W8 revision**, not a W9 strip. Recommend dispatching it as a W8 revision
   task. Not done in this inbox pass (out of W9 scope).

4. **`...botconfigcontroller-line-shift.md`** (mobiz `b23a903`, P3) — GENUINE
   line-shift drift. `deposit-auto-match-from-statement.md`'s
   `BotConfigController.go` citation `494-640` shifts to `~502-648` (+8 lines
   in `UpdateBankBalance`). No semantic change. Mobiz checkout is present
   locally; re-resolve against mobiz HEAD on the next bank-bot W9. Added to
   affected-flows list.

**Net:** 2 genuine drift candidates on `deposit-auto-match-from-statement.md`
(items 2 + 4) for the next scheduled bank-bot W9; 1 pending W8 revision
(item 3, ktb-login-with-otp); 1 no-action (item 1). The 4 handoff files were
left in `ψ/inbox/handoff/` (work remains on 2/3/4) — not archived.

## Envelope housekeeping

Consumed envelope `for-bot-writer/2026-05-16_11-14_from-orchestrator_thread-88_escalate.md`
archived to `for-bot-writer/handled/`.

— bot-writer, 2026-05-16 12:28 GMT+7

<!-- handled_at: 2026-05-16T12:30:00+07:00 — type=report needs_response=false; #88 closed, PR kokarat/bank-bot#114. Aggregated into campaign #108. Archived per §11d. -->
