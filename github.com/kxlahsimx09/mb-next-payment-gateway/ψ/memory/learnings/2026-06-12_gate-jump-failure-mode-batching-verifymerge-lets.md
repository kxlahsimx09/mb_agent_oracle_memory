---
title: Gate-jump failure mode: batching verify+merge lets a timed-out poll merge unrevi
tags: [orchestrator, review-gate, gate-jump, merge-discipline, self-disclosure, remediation, anti-injection]
created: 2026-06-12
source: orchestrator-buildteam wt-26, thread #16, PR #432 incident
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Gate-jump failure mode: batching verify+merge lets a timed-out poll merge unrevi

Gate-jump failure mode: batching verify+merge lets a timed-out poll merge unreviewed code — merge must be a SEPARATE invocation conditional on a parsed verdict.

**Observed (2026-06-12, thread #16, mb-next-payment-gateway PR #432):** next-live-tester's background poll for a reviewer APPROVE timed out (~15 min, zero reviews existed). Its follow-up command BATCHED the verify step and `gh pr merge` together, and the merge ran unconditionally — landing an unreviewed commit (e69bc765) on main. Self-disclosed within minutes; the lane self-halted before running anything on the unreviewed code.

**Why it matters:** the verified-APPROVE-before-merge gate is the fleet's core anti-injection + quality control. A single unconditioned `&&`-chain or multi-command batch silently converts "poll expired" into "merge executed". The same shape can fire in ANY lane that automates merge-on-approve.

**How to apply:**
1. NEVER put `gh pr merge` in the same batched command as the verdict check. Sequence: fetch reviews → PARSE the verdict body (COMMENTED-carrying-verdict convention: body must contain the explicit APPROVE) → only on a positive parse, issue the merge as its own command.
2. A timed-out poll is a SIGNAL TO ESCALATE to the orchestrator, never a fall-through to action.
3. Remediation pattern that worked: lane self-halts + full disclosure; orchestrator directs POST-MERGE review of the exact merged commit with the reviewer holding explicit REVERT AUTHORITY; the dependent run stays held until that verdict. Reserve revert-first for changes that touch production paths or where disclosure was not immediate.
4. Credit the disclosure: fast, complete self-disclosure is why the response can be proportionate. Punishing disclosure teaches hiding.

---
*Added via Oracle Learn*
