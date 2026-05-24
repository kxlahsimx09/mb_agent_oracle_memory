---
title: OBSERVED (P-002, not a fix): orchestrator campaign fragmented across TWO session
tags: [orchestrator, fleet, drift, inbox-watcher, session-fragmentation, sticky-ownership, section-151, section-11k, handoff, repo:cross, brew-ops]
created: 2026-05-22
source: orchestrator — observed live during campaign #211/thread #213 (2026-05-22)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# OBSERVED (P-002, not a fix): orchestrator campaign fragmented across TWO session

OBSERVED (P-002, not a fix): orchestrator campaign fragmented across TWO sessions despite §151 sticky-ownership — recurrence of the §11k/§151 "campaign opened inside an already-running session" edge case.

**What happened (2026-05-22, campaign #211 — bank-selection substrate):**
- Parent thread #211 was OPENED by session `arra-oracle-v3.wt-5-20260522-084335` (msg 893) — i.e. an already-running/human-driven orchestrator session that called `arra_thread` directly, NOT a watcher-spawned session. Per §11k/§151 this is exactly the case with no watcher-spawn event to anchor `owner[orchestrator][parent-211]`.
- The inbox-watcher then woke a SECOND orchestrator session `arra-oracle-v3.wt-10-inbox-1779429895` for the reply envelopes on sub-thread #213 (msgs 910, 911, 917, 918, 921, 922).
- Meanwhile wt-5 stayed the user-relay channel (msgs 912, 914, 915, 919 — "User chose FULL hosted", then "User chose (B)").
- Concrete harm risk realized: wt-10's escalation-to-user (msg 917, 07:03:09Z, [ESCALATE_TO_HUMAN]) CROSSED wt-5's relay of the user's actual (B) answer (msg 919, 07:03:59Z) — ~50s apart. They converged on the same answer this time (both → user's (B)), so no divergent dispatch occurred, but the two sessions were independently driving the same campaign.

**Likely root cause (hypothesis for brew-ops):** §151 records the campaign owner from the `parent_session` stamp on the *dispatcher's outbound dispatch envelope*. If the campaign parent (#211) was opened directly in a running session without that session writing dispatch envelopes carrying `parent_session` (or the owner record was never written / pointed at wt-5 while the watcher routed #213 sub-thread replies to wt-10), reply routing falls back to fresh/secondary sessions — the #140/#141 fragmentation §151 was meant to close. Worth verifying: did the #211→#213 dispatch envelopes carry `parent_session`, and what does `sessions/orchestrator/thread-211.owner` actually hold?

**Mitigation that held this time:** the thread (P-001 durable content layer) is the single source of truth — wt-10 read the full thread each wake and saw wt-5's posts, so both sessions stayed coherent. Fragmentation degraded gracefully because no session trusted only its own JSONL.

---
*Added via Oracle Learn*
