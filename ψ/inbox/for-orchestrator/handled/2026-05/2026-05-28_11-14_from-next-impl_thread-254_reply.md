---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: LIMIT 500 grounded — PR #276 commit d8d42d4; recommendation = keep 500
needs_response: false
priority: normal
created: 2026-05-28T11:14:00+07:00
handled_at: 2026-05-28T18:17:00+07:00
handled_by_thread: 254
handled_note: >
  next-impl LIMIT 500 grounding reply (msg 1237) relayed to user. Closes the second
  parallel user-correction loop on PR #276 (the first was R1.C cadence; this was
  LIMIT 500 grounding via wt-21 msg 1234 consult). Grounding delivered: (a) original
  had NO LIMIT (unbounded); 500 is a new knob, not preserved literal — (b) no ratified
  literal in adr.md/epics, sibling precedent sweep_expired_deposits DEFAULT 100 —
  (c) dpay 7d evidence: avg ~102/hr, hard peak 239 Tue 2026-05-27 19:00 BKK,
  7d total 15,974 unmatched-in, daily ~45k baseline (61-64k last 3d) — (d) keep 500
  (2× hard peak, ~4× avg, 5× precedent, parametrized via DEFAULT for ops tunability).
  Folded into PR #276 as commit d8d42d4 (inline migration rationale block; code value
  unchanged). PR #276 verified live gh: OPEN/MERGEABLE/non-draft. Commit chain
  cba7023 → 4a6f2ac → d8d42d4. Relayed grounding + 2 final user calls (merge +
  brew-ops dispatch) to user via Telegram (chat 2002026175, msg id 45) at
  2026-05-28T18:17+07:00. Trace marker posted to thread #254 (msg 1239 — note minor
  gap: msg 1238 posted by another session between my thread-read and post, content
  not material to this relay). Thread left pending; envelope needs_response=false →
  no reply to next-impl. §151 owner remains wt-21. Notable durable pattern:
  next-impl's grounding template (original-vs-new diff + requirements check +
  current-system dpay evidence + ranked alternatives) converted a fuzzy magic-number
  question into a numerically-defended choice in ~10 min — worth capturing when
  campaign closes.
---

Grounding done. Folded into PR #276 alongside the cadence revert. Code value unchanged (LIMIT 500 stays); migration carries an inline rationale block. Thread #254 msg 1237 has the full table.

**(a) Original vs PR #276:** original had NO LIMIT (unbounded scan); PR #276 adds `LIMIT p_batch_limit DEFAULT 500`. msg-1231's "+LIMIT 500" was therefore correct.

**(b) Requirements:** adr.md L235 + L1920 explicitly punt "batch-size semantics" to impl-pass. epic-deposit / epic-statement-matching defer the numeric value to design docs. No ratified literal — impl discretion. Sibling precedent: `sweep_expired_deposits(p_batch_size int DEFAULT 100)`.

**(c) Current system (dpay last 7d; direction='in' + pending|unmatched per 1-hr bucket):**
- avg ~102/hr, sustained peaks 157–184 (afternoon/evening), **hard peak 239** (Tue 2026-05-27 19:00 BKK), min 2 (off-hours).
- 7-day total unmatched-in: 15,974 rows.
- Daily totals confirm ~45k baseline (running hotter last 3d at 61–64k); direction split 62–68% in / 32–38% out.

**(d) Recommendation: keep LIMIT 500.** 2× the hard spike (239) + ~4× the avg (~102). 5× the sweep_expired_deposits precedent (100) because hourly volume is materially larger. Tunable via DEFAULT param — ops can bump to 1000 via cron command without redeploying.
- 100 (match precedent): would leak rows on a normal afternoon hour → regression vs unbounded original.
- 500 (chosen): comfortable headroom, parametrized.
- 1000: panic-proof; defensible if extra margin wanted; cost negligible.
- dynamic: complexity for no real win at this volume.

PR #276 commits: cba7023 (initial) → 4a6f2ac (R1.C revert) → **d8d42d4 (LIMIT 500 grounding)**. `gh pr view 276` → MERGEABLE. Local re-apply clean (single overload, partial sweep idx present, 6 DROPs gone, 15 ADDs present, simulate_admin unscheduled, all sweeps at 1/min). Ready for brew-ops db push + §D re-run.
