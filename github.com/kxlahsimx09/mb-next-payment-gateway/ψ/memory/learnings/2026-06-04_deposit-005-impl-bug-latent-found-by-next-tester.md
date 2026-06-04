---
title: DEPOSIT-005 IMPL BUG (latent, found by next-tester during the DEPOSIT-001→004 co
tags: []
created: 2026-06-04
source: next-tester campaign d2fifo (DEPOSIT-001→004 completeness-audit follow-up), 2026-06-04; 6-run substrate observation on yupsevcrubgprsbujbpu
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DEPOSIT-005 IMPL BUG (latent, found by next-tester during the DEPOSIT-001→004 co

DEPOSIT-005 IMPL BUG (latent, found by next-tester during the DEPOSIT-001→004 completeness audit, 2026-06-04): the degenerate full-key-collision auto-pick is LIFO (newest-created), the OPPOSITE of the ratified DEPOSIT-005 AC which mandates FIFO (oldest-created-first).

CONTEXT: a >=2 full-key collision = two pending deposits sharing the same client + payer source-account + source-bank + amount + dest bank (one customer's repeat transfers — the degenerate carve-out). DEPOSIT-002/D2-03 owns only the money-safety consequence (<=1 credited, never both); the SELECTION of which colliding deposit wins is DEPOSIT-005's AC (epic-deposit.md DEPOSIT-005 L360 + worked example L375: DEP1@10:00 + DEP2@10:05 -> FIFO picks DEP1, the older one).

OBSERVED on the tester stack yupsevcrubgprsbujbpu (next-tester, 6 runs incl 2 with request_id order reversed, 100% consistent, §ADR-20 frozen clock, ground-truth reads): the deployed match_deposits_cascade / eager bot-statement intake cascade AUTO-PICKS (does not park to review) and credits the NEWEST-created deposit; the FIFO-oldest stays pending. Selection key disambiguated = created_at-newest / last-inserted (NOT request_id order — reversed runs created lexically-larger request_id first and the pick still went to the second/newer-created). Money-safety holds (exactly 1 credited, wallet delta +245.5 net, the other stays pending; NT-9 single-consumption guard means the eager intake cascade makes the pick and re-cascade no-ops as already_consumed).

IMPACT: real impl-vs-AC divergence for DEPOSIT-005 — the WRONG deposit is credited (newest instead of the AC-mandated oldest). Low real-world severity (both are the same customer's economically-identical repeat transfers, so money-safe), but a determinism/correctness bug vs the ratified AC. DEFERRED, NOT fixed: DEPOSIT-005 is not built yet; the degenerate-pick ordering must be corrected to FIFO-oldest (ORDER BY created_at ASC) WHEN DEPOSIT-005 is built/verified. The D2-03 probe is correctly scoped (money-safety only) and stays green — do NOT add a credited==oldest assertion to D2-03 (it would go red against the current LIFO substrate + is out of D2-03's scope).

WHY THIS MATTERS METHODOLOGICALLY: blindly executing the pre-framed task action (add 'assert credited == oldest' to close the audit's PARTIAL) would have turned D2-03 RED — the verify-first / observe-the-substrate step is exactly what caught that the deployed behavior is a third reality (auto-pick LIFO) neither of the two pre-framed outcomes assumed. Also: the same completeness audit's channel-field PARTIAL (#3) was a STALE/misread premise (channel IS coherent at HEAD per next-architect) — two of the audit's three flagged items dissolved under verify-first. Lesson: treat a completeness-audit PARTIAL as a hypothesis to verify against live substrate + HEAD, not a confirmed gap.

tags: [next-tester, next-dev, deposit-005, deposit-002, d2-03, fullkey-collision, degenerate-collision, fifo-vs-lifo, impl-vs-ac-divergence, drift, latent-bug, deferred, completeness-audit, verify-first, match-deposits-cascade, repo:mb-next-payment-gateway, next, gotcha]

---
*Added via Oracle Learn*
