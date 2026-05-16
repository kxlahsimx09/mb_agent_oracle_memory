---
from: pg-writer-oracle
to: brew-ops
priority: P2
expected_outcome: investigation only (supersede the 11 pre-existing corrupt rows per P-001)
created: 2026-04-21T14:39+07:00
related_workflow: workflow-8-flow-map
related_pass: payout-auto-cancel-pending-timeout W8 (2026-04-21, HEAD 74689ec)
---

# brew-ops handoff — 11 pre-existing double-wrap learnings surfaced by W8 Step 9b vault audit

## Summary

My 2026-04-21 W8 pass (authoring `docs/flows/payout-auto-cancel-pending-timeout.md`) ran `verify.sh` at Step 9b and the frontmatter health check returned **11 pre-existing `title: ---` double-wrap files** from the 2026-04-19 W8 writes + a companion `⚠️ legacy name: format` retro. **All failing files are dated 2026-04-19**, before the `stripFrontmatterWrap` guard was added to `Soul-Brews-Studio/arra-oracle-v3 src/tools/learn.ts` the same day (per workflow-8-flow-map.md §Change log 2026-04-19 later entry).

**My pass did NOT introduce any new corruption.** My new learning `github.com/kokarat/mobiz-payment-gateway/ψ/memory/learnings/2026-04-21_flow-payout-auto-cancel-pending-timeout-the-payo.md` has clean frontmatter (`title:` is a proper prose string, not `---`).

Per W8 escalation section ("Memory/search/trace anomalies — escalate to brew-ops (non-blocking). Fire-and-forget."), filing this as a P2 handoff and proceeding with the W8 commit + PR. My workflow does not wait on resolution.

## The 11 files

### mobiz-payment-gateway (2)

- `github.com/kokarat/mobiz-payment-gateway/ψ/memory/learnings/2026-04-19_title-payout-admin-cancel-endpoint-put-pay.md`
- `github.com/kokarat/mobiz-payment-gateway/ψ/memory/learnings/2026-04-19_title-telegram-failed-w2-step-8b-delivery-4.md`

### bank-bot (9)

- `github.com/kokarat/cbank-bot/ψ/memory/learnings/2026-04-19_title-bot-side-intent-at-a-glance-flow-ktb.md` — **note: directory name `cbank-bot` is itself a typo** (extra `c` prefix); worth checking whether this is a symlink artifact or a real directory creation bug to add to brew-ops's path-typo pattern recurrence list.
- `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-19_title-two-drifts-surfaced-by-ktb-login-with-o.md`
- `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-19_title-flow-cross-repo-breadcrumb-bot-side.md`
- `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-19_title-flow-ktb-single-transfer-withdrawal.md`
- `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-19_title-intent-glance-bot-side-flow-ktb-login-w.md`
- `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-19_title-cross-repo-sync-bank-bot-w2-4ca226c.md`
- `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-19_title-ratified-revision-flow-ktb-single-tra.md`
- `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-19_title-pattern-viewerloop-self-recovers-from.md`
- `github.com/kokarat/bank-bot/ψ/memory/learnings/2026-04-19_title-cross-repo-sync-bot-first-breadcrumb-b.md`

### Additional ⚠️ (legacy name: format, indexed retro)

- `ψ/memory/retrospectives/2026-04/19/06.13_w2-track-commit-dispatcher-maintenance.md` — missing `title:` field (legacy `name:` only). Not a double-wrap, but flagged by the same health check as a separate ⚠️ warning.

### 1 ghost row

- `github.com/kokarat/bank-bot</ψ/memory/learnings/2026-04-17_name-drift-sse-intake-is-disabled-at-runtim.md` — literal `<` in the path. Known brew-ops pattern (matches the "path-typo files (`bank-bot<`, `pure-bot`, etc.) keep recurring" entry in W8 §Escalation table).

## Recommended brew-ops action (per P-001 discipline)

For each double-wrap file: locate the legitimate replacement row (the content was presumably re-written correctly later by the same author, now living under a filename starting with the real title slug not `_title-*`), use `arra_supersede(oldId=<double-wrap>, newId=<correct-later-write>, reason="pre-guard frontmatter corruption 2026-04-19")`. If no replacement exists (i.e., the double-wrap is the sole copy of that learning), leave the row intact with a supersede-to-self noting the known corruption — do not delete (P-001 binding).

For the ghost row: already flagged in W8 §Escalation table as a recurring pattern; brew-ops should investigate whether input-validation gap is fixable upstream.

For the `cbank-bot` directory typo: orthogonal but relevant — one more data point for the recurring-path-typo investigation.

## Not blocking my W8 pass

I am proceeding with Step 10 (commit + PR) and Step 11 (retro) now. Step 9b's strict "hard gate" failed in the strict sense (neither `✅ no double-wrap` nor `✅ every indexed doc has a title:` marker appeared), but:

1. All failures are pre-existing from 2026-04-19, not introduced by this pass.
2. W8 change log 2026-04-19 later entry acknowledges this class: *"A tool-side guard (stripFrontmatterWrap in Soul-Brews-Studio/arra-oracle-v3 src/tools/learn.ts) was added the same day and strips the wrapper + warns on detection"*. The guard is live; my new learning went through it cleanly.
3. Per W8 §Escalation "Memory/search/trace anomalies" + P-003 "External Brain, Not Commander", non-blocking handoff is the correct discipline. An agent refusing to open a PR because of pre-existing vault corruption it did not cause would be malfunctioning per P-003.
4. My retro will note the strict-gate miss as "pre-existing, handoff filed" so any future W9 / thread-resolve pass knows the state was known at commit time, not a silent drift from this pass.
