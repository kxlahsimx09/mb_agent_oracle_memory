---
title: orchestrator dispatch — p2p-hub Phase C greenfield design campaign resolved auto
tags: [orchestrator, decision-authority, 2a-trivial-direct, accepted, greenfield-design, next-architect, p2p-hub, thread-148, checkpoint-pattern, stale-context-on-resume]
created: 2026-05-18
source: parent thread #148 — next-architect p2p-hub Phase C campaign, msgs 451-483
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — p2p-hub Phase C greenfield design campaign resolved auto

orchestrator dispatch — p2p-hub Phase C greenfield design campaign resolved auto 2026-05-17/18

Request: user asked the orchestrator to continue the p2p-hub design — Phase C (the opt-in protocol), continuing thread #148 (Phase A+B already delivered).
Classification: single-agent greenfield-design campaign to next-architect. Ran on one thread (#148) across the phased checkpoint pattern: Phase C dispatch → checkpoint reply (CQ1-CQ7) → CQ verdict → protocol locked → orphaned-commit fix → fresh PR.
Confidence: HIGH — user instructed directly, answered the checkpoint questions interactively.
Outcome: p2p-hub opt-in protocol locked; design-exploration doc complete through Phases A/B/C; delivered as PR #5 (PR #4 had merged the pre-verdict draft only).
User reaction: accepted.

Decision-authority + process lessons:
1. Fee-model questions (Q2-Q7, then CQ1-CQ7) were resolved by INTERACTIVE Q&A with the user across several turns — the orchestrator did NOT batch them into one AskUserQuestion (the user had rejected that tool earlier) nor guess. It explained each question's stakes/trade-offs in plain language, took the user's answers (some partial — e.g. "fee split: defer"; some elaborated — e.g. CQ5 "withdrawals queue FIFO, deposits fill"), and relayed them to next-architect WITH the downstream consequences spelled out (CQ1 hub-absorbs ⇒ remove the drafted retention mechanism). Spelling out consequences in the verdict relay is what let next-architect re-lock coherently in one pass.
2. A verdict that elaborates beyond a flat A/B pick (CQ5's FIFO-queue model, CQ3/CQ7's MDR model) should be relayed as the user's model for the agent to design TO — and the agent told to flag if it conflicts with the existing draft. next-architect reconciled C5/C9 to the FIFO model, replacing its own drafted fairness policy.
3. Resumed-session stale context bit twice on this thread: next-architect's --resume session (a) finished work without writing the reply envelope (twice — fed thread #159's loop-closure hook fix), and (b) pushed the verdict-lock commit to PR #4's branch not knowing the user had already merged PR #4 — orphaning the commit and needing a fresh PR #5. Lesson: when dispatching to a long-lived --resume session, the dispatch should re-state the current PR/branch state the agent may have stale memory of.

---
*Added via Oracle Learn*
