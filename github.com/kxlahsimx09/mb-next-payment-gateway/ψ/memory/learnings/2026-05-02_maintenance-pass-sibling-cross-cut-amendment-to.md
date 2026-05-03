---
title: Maintenance pass — sibling cross-cut amendment to cite newer ratified ADRs acros
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, maintenance, sibling-cross-cut-amendment, doc-coherence, adr-network-coherence-pattern-instance-1, no-ratification-needed, batch-citation-cleanup]
created: 2026-05-02
source: docs/adr.md@0815501 (maintenance pass) + 4 ratified ADRs (§ADR-9/10/11/12)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Maintenance pass — sibling cross-cut amendment to cite newer ratified ADRs acros

Maintenance pass — sibling cross-cut amendment to cite newer ratified ADRs across earlier-ratified ADRs (2026-05-02 GMT+7).

After 8 W1 passes ratifying 4 new ADRs (§ADR-9/10/11/12) over 3 calendar days, several earlier-ratified ADRs (§ADR-4a/4b/4c/§ADR-7) had deferred-questions + inline references pointing to "X-ADR future" / "deferred to data-model design pass" surfaces now structurally closed by the new ratifications. ADR-network-coherence drifted; this pass closes the drift via batch citation cleanup.

6 surgical edits across 4 ADRs (no architectural decision changes):
- §ADR-4a Decision #7 lifecycle steps (ii) wallet refund cites §ADR-10; (iii) callback enqueue cites §ADR-9
- §ADR-4b §Negative #ii: "wallet table deferred to data-model design pass" struck-through; closed by §ADR-10
- §ADR-4b Decision #5 finalize_deposit: wallet credit + MDR fan-out + callback steps cite §ADR-9/§ADR-10; lock-ordering invariant note appended (§ADR-10 D5)
- §ADR-4b §Deferred questions: "Wallet-table schema + locking strategy" struck-through; closed by §ADR-10
- §ADR-4c §Context + §Out-of-scope + §Deferred questions: "callback dispatcher (separate ADR future)" / "callback-dispatcher ADR future" closed by §ADR-9
- §ADR-7 new §Related ADRs section: links to §ADR-11 (Idempotency layered on top) + §ADR-12 D1 taxonomy (machine vs human caller distinction)

NEW PATTERN — ADR-network-coherence-as-maintenance-pass (instance #1).

Distinct from W1 baseline / W1 ratification / W1 revise modes. Triggers when ≥3 ADR ratifications shift "future" references in earlier ADRs to "ratified" surfaces. Pattern shape:
- No architectural decision changes
- No new ratification anchors
- No threads opened
- No supersession (use strike-through to preserve history per P-001)
- Batch citation cleanup across affected ADRs in single commit
- Smaller cognitive load than per-ADR full revise

Trigger heuristic: "every N ADR ratifications, do a maintenance pass to update sibling deferred-questions + cross-cut citations". Suggested N=3 (every 3 ratifications) or threshold-based (when ≥X stale "X-ADR future" references accumulate in earlier-ratified ADRs).

§Revision log entry preserves struck-through originals per P-001 "Nothing is Deleted". Future readers see both the original deferral and its closure via citation.

Threads: none opened, none closed. PR #11 (open, not merged; stacks on PR #10 §ADR-12). Trace chain extends from §ADR-12 pass-2 ratified (3620b6ae) → this pass.

Process notes:

1. Pattern is W1-spec compatible — workflow doesn't prohibit maintenance passes; just doesn't explicitly enable. Worth documenting in W1 workflow doc as "maintenance mode" alongside baseline/refine modes.

2. Cognitive load: ~15-20 min total wall-clock. Lighter than W1 baseline (60-180 min). Appropriate for "warm up after long session arc" + "before next major architectural pass" use cases.

3. P-001 compliance: strike-through preserves history. Original "deferred to data-model design pass" still readable; closure via §ADR-10 cited inline. No information lost.

4. Cross-link economy: each ratified ADR (§ADR-9/10/11/12) now has 2-4 inbound citations from earlier ADRs. Architecture archaeology improves — future architect entering at any §ADR-4* can navigate to the substrate-level decisions covering its concerns.

Next-pass candidates:
- Admin-API surface ADR (last remaining major architectural gap; 90-120 min)
- Brew-ops handoff: 8 patterns + heuristic update + maintenance-pass pattern as 9th
- Brew-ops handoff: Pre-Input-5 instance #7+#8 escalation (process debt)

---
*Added via Oracle Learn*
