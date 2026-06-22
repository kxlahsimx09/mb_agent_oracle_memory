---
title: Orchestrator team-dispatch — business-logic GAP review (ours #next vs current #c
tags: [orchestrator, team-dispatch, 2b, business-gap-review, bizgapgw, bizgapbot, mb-next-payment-gateway, mb-next-bank-bot, account-401-resume, resume-not-redo, next-code-reviewer, accepted]
created: 2026-06-20
source: orchestrator campaign 41-o-business-gap (bizgapgw + bizgapbot), 2026-06-20
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Orchestrator team-dispatch — business-logic GAP review (ours #next vs current #c

Orchestrator team-dispatch — business-logic GAP review (ours #next vs current #current), gateway + bankbot, campaigns bizgapgw + bizgapbot (2026-06-20).

SHAPE: 2b fan-out, 2 parallel next-code-reviewer teammates under the orchestrator's OWN slugs (not reusing kxlahsimx09 build-team reviewers). Each reviewer fanned out its own read-only Explore sub-agents (gateway: 12 in 2 waves; bankbot: 7) then mapped+classified itself. Baseline = current repo docs/current-system.md + docs/flows as the behavior checklist; intent record = new repo docs/adr.md + docs/spec for INTENTIONAL-vs-UNDOCUMENTED classification. Findings preserved at ψ/inbox/handoff/2026-06-20_bizgap-review/ + mailbox/next-code-reviewer/.

INCIDENT + RECOVERY (reusable): mid-run, a /login rotated the account (MaxpayPlus) → ALL teammates 401'd ("Invalid authentication credentials / Please run /login") account-wide — NOT 429 quota, and brew-ops dispatch can't fix it (same account → same 401) → genuine USER blocker (re-login). Bankbot findings were already written to disk (survived); gateway synthesis was in-context-only (lost on kill). Resume rule: re-spawn on the new account, but for the agent whose deliverable already exists on disk give a FINALIZE-don't-redo turn, and for the one whose work was lost re-deliver the FULL contract. The team-dispatch-helper reliably re-delivers the kickoff turn (a bare `maw team spawn --exec` does not). On resume the bankbot agent re-verified (caught/corrected 3 of its own sub-agents' precision errors); resume-not-redo saved a full re-audit.

HEADLINE RESULT: rewrite is faithful where documented (~24 gateway + 11 bankbot INTENTIONAL-DIVERGENT, incl 2 genuine CURRENT bug-fixes). Risk concentrates in UNDOCUMENTED-DIVERGENT + MISSING. Top cross-repo compound: bankbot stubbed updateBalance AND gateway over-draw guard reads bot-only bank_account.balance with no freshness/settle-decrement/in-flight accounting → real over-draw risk. Other HIGH: blacklist auto-detect+deposit gate MISSING; backend self-healing statement parser removed; payout MDR partner-split collapsed onto deposit percentage column; callback retry budget 7→3; deposit routing ignores availability; SCB payout browser-recycle self-heal MISSING; system-wide maintenance lockdown MISSING. Owner gated next step (user said discuss-before-fix).

---
*Added via Oracle Learn*
