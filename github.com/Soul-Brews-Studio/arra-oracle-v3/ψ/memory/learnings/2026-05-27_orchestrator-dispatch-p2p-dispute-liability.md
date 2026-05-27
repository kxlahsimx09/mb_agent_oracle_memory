---
title: **orchestrator dispatch — P2P dispute & liability design (campaign #231) closed;
tags: [orchestrator, decision-authority, 2a-single-agent-design, accepted, p2p-hub, dispute-centric, liability-matrix, campaign-231, section-F, ratified, phase-1-simplification, user-hands-on-design, defer-to-phase-2, needs-legal-G1, 214-reply-routing-bug, p2p-hub-not-registered-project, repo:cross, fleet]
created: 2026-05-27
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# **orchestrator dispatch — P2P dispute & liability design (campaign #231) closed;

**orchestrator dispatch — P2P dispute & liability design (campaign #231) closed; §F merged (2026-05-27)**

Request (user, direct CLI orchestrator session wt-22): continue the P2P (p2p-hub) project. Resolved into a single-agent design-analysis campaign to next-architect: Phase B edge-case audit (72 cases) → B7/B8 deep-dive → liability matrix (13 rows) → re-cast dispute-centric → ⟦S5⟧ close_outcome contract → **§F Dispute & Liability (Phase 1)** authored into docs/design/p2p-hub-design-exploration.md. Outcome: **p2p-hub PR #10 MERGED**, §F marked #decision (ratified), §C11 enforcement framing superseded with a P-001-retained cross-ref.

Classification: 2a single-agent design-analysis, propose-then-discuss (NO build until the final §F PR). Confidence: HIGH (user drove every decision interactively). User reaction: **accepted** with heavy hands-on ruling.

Decision-authority signals (P2P, this user):
- User makes the design calls himself; the orchestrator RELAYS questions to the architect and ratifies row-by-row (never auto-decides design content). Architect proposes; user disposes.
- Strong preference: **dispute-centric, human-mediated resolution** (p2p-support ↔ DSP ↔ PSP, both-agree-to-close) OVER automatic fault-penalty. The liability matrix is "guidance for the mediator," not an auto-debit engine. (This reframed the architect's first matrix draft.)
- **Simplifies aggressively + defers complexity to Phase 2.** B1.4: rejected the whole double-pay machinery (EXPIRED→DISPUTE reopen, double-detection, D-tree, duplicate-suspected-hold) in favor of a hard slip-deadline cliff (miss the slip-upload deadline = EXPIRED = DSP-fault, no inter-provider settle, late funds = PSP-customer benefit). Reserved double_pay_handled + split_settled outcomes → Phase 2.
- Wants per-case detail + plain-language stakes before deciding; asked for opaque labels (D-1..D-4) to be spelled out + renamed.
- Legal-gated items (B8.3/B11.4 regulatory, clawback B1.7) flagged NEEDS-LEGAL (G1, launch-blocking) — user has not yet escalated to counsel.

Follow-on (new campaign #250, dispatched same session): author a p2p-hub product-requirement doc FROM the design doc, in mb-next-payment-gateway docs/requirements/ style → next-writer.

Fleet-mechanics incident (recurring, flagged for brew-ops, user not yet authorized fix): the §214/§11f reply-routing bug tripped the §11l circuit-breaker on EVERY next-architect reply on sub-thread #232 — the reply (thread:232, parent_thread:231) keyed on thread:232 → spurious sibling orchestrator session (wt-29, recorded as thread-232.owner) instead of the campaign owner thread-231.owner=wt-22. Work was UNAFFECTED (the real owner handled every reply via user-driven bootstrap wakes; the breaker notifies were moot). Mitigation idea: a single-thread campaign (thread==parent_thread) likely sidesteps the mismatch; the real fix is brew-ops (orchestrator-bound replies must key on parent_thread, not thread).

Side-finding: **p2p-hub is NOT a registered Oracle project** (arra_learn rejects project=github.com/kxlahsimx09/p2p-hub; not in KNOWN_PROJECTS / no fleet JSON). P2P learnings file under arra-oracle-v3 or _universal. Worth registering if p2p-hub work continues.

P2P project state after #231: design doc carries Phases A–F; §F dispute/liability Phase-1 ratified+merged; substrate ⟦S1⟧–⟦S6⟧ all UNBUILT. Open menu: (1) G1 legal, (2) thunder-API commit (gates ⟦S4⟧), (3) B8.7 vetting policy, (4) ⟦S1⟧–⟦S6⟧ build, (5) parked §E impl (PR #8 spec, migrations 006–009 unbuilt, RATIFICATION_PENDING:206 + thread #206 open), (6) Phase-2 reserved.

---
*Added via Oracle Learn*
