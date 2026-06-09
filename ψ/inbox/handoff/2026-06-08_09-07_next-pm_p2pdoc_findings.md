---
title: next-pm campaign p2pdoc findings — §ADR-17 P2P matching 4-lens authoring tracker
from: next-pm (campaign p2pdoc)
created: 2026-06-08
status: BLOCKED on ADR-17 authoring (not yet at owner-ratification readiness)
tracker: arra thread #10
tags: [next-pm, campaign-p2pdoc, adr-17, p2p-matching, 4-lens, ratification-gate, tracker]
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# campaign p2pdoc — next-pm findings (campaign open, 2026-06-08)

## Charter
Own the campaign thread + ratification gate for authoring the P2P withdraw/deposit matching artifact set:
§ADR-17 (design, next-architect) → epic-p2p-matching.md (requirement, next-writer) → epic-p2p-matching-ui.md (UI, next-ui); pg-writer grounds (current-production lens). ADR-17 is the origin. Serialized on branch `campaign/p2pdoc`. Owner merges; next-pm does NOT merge / does NOT mark done without evidence.

## Ground truth at open
- Branch `campaign/p2pdoc` HEAD = 407b2fc — ZERO campaign commits.
- §ADR-17 is RESERVED ONLY in docs/adr.md — NOT yet authored on the branch. next-architect authoring (task #1, in_progress).
- No docs/requirements/epic-p2p-matching.md or epic-p2p-matching-ui.md yet.
- Prior design exists uncommitted: §ADR-17 draft PM1–PM13 + design-pass DP0–DP11 (owner-GO'd 2026-06-05) in a separate worktree (agents/2-adr). THIS campaign formalizes it onto campaign/p2pdoc.
- Ground sources: arra learning `2026-05-09_poc-feasibility-p2p-withdrawdeposit-matching-p` (PR #41); architect handoff slug `next-architect_p2pdoc_adr17_findings`; project memory `adr17-p2p-matching.md` (DP0–DP11).
- Model note: design EVOLVED from the 2026-05-09 POC (1:1 bank-rail offload) to owner-ratified 2026-06-05 (1 withdrawal : N deposits, closed-loop pre-funded p2p-wallets via §ADR-10 `wallet_kind`, Thunder = verification heart, two ports FeeDistributor + TransferVerifier for extractability).

## ⚠ STAFFING GAP (raised to team-lead)
Team config (p2pdoc) = next-architect, next-writer, next-pm ONLY. next-ui + pg-writer named in brief but NOT members. Tasks #5 (ui) + #3 (pg-writer) owned-by-name but unstaffed. Awaiting team-lead to spawn/add or rescope.

## 5 POC open questions — coverage checklist (each: resolved in ADR-17 + writer story + any UI implication in ui story)
1. FAIRNESS (popular amounts) → maps to DP1/DP2 (FIFO head-first; priority earned by progress; weighted-closeability+age-force DROPPED). [ADR ☐ writer ☐ ui ☐]
2. FALLBACK-TIMEOUT → DP6 (P1 expire→unfreeze) + DP4 (timeout→retry→dead-letter→CS) + DP11b (T_large→truncate-to-locked+re-submit). [ADR ☐ writer ☐ ui ☐]
3. SLIP-VERIFY-FAILURE → DP3 (overpay→credit-only / underpay→leg-cancel+log) + DP4 (forged→hard-fail+notify+re-pool w/ queue-jump). [ADR ☐ writer ☐ ui ☐]
4. BIG-AMOUNT-STRATEGY → DP10 (overflow seam amount>X: gateway→normal payout; pure-P2P→secondary large-only queue) + DP11 (secondary-queue exit/migrate/truncate). [ADR ☐ writer ☐ ui ☐]
5. PROMO-FRAUD → ⚠ NOT visibly covered in DP0–DP11. Original POC prescribed KYC binding + per-customer rate limit. ASKED next-architect to confirm ADR-17 resolves it. [ADR ☐ writer ☐ ui ☐]

## Ratification gate (next-pm enforces)
ALL writer + ui stories stay S3 PROVISIONAL until owner GO ratifies §ADR-17, then flip S2. No lens claims S2 prematurely. next-pm surfaces readiness; owner ratifies + merges.

## DoD
☐ ADR-17 section (5 questions resolved) · ☐ epic-p2p-matching.md (each Q → ≥1 story) · ☐ epic-p2p-matching-ui.md (UI implications) · ☐ INDEX/glossary updated · ☐ all 5 Qs closed · ☐ Phase-2 (deposit-splitting / N:1 / M:N / dispute engine) recorded DEFERRED · ☐ UI stories present · ☐ pg-writer grounding folded in · ☐ PR(s) open NOT merged.

## Task map (team p2pdoc)
#1 next-architect ADR-17 (in_progress) · #3 pg-writer grounding (UNSTAFFED) · #4 next-writer epic (blockedBy #1) · #5 next-ui epic (blockedBy #4, UNSTAFFED) · #6 next-pm RATIFICATION GATE (blockedBy #1,#3,#4,#5).

## Next actions
- Await next-architect: ADR-17 PR # + section anchor + promo-fraud resolution.
- Await team-lead: staff next-ui + pg-writer (or rescope).
- On ADR-17 authored: tick ADR column per question; unblock writer; then ui.
- Hold S2 until owner GO. Surface readiness-for-ratification when chain completes.
