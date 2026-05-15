---
title: **Comprehensive `#current` vs PoC audit via 3 parallel subagents = high-ROI surf
tags: [comprehensive-audit, subagent-parallel, poc-vs-current, drift-mapping, high-roi-pattern]
created: 2026-05-13
source: PoC Phase B sprint 2026-05-13
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# **Comprehensive `#current` vs PoC audit via 3 parallel subagents = high-ROI surf

**Comprehensive `#current` vs PoC audit via 3 parallel subagents = high-ROI surface map.**

When PoC matures past initial happy-path validation and stakeholders want "production-parity" + "load-bearing on substrate", a single-pass main-thread audit grows too long and pollutes context. Pattern: split audit into 3 surface groups, dispatch as parallel general-purpose subagents:

- **Group 1 — Deposit lane:** match cascade, finalize_deposit, MDR fan-out, slip verify (4 surfaces)
- **Group 2 — Withdraw lane:** payout claim, post-completion lifecycle (mark_*), bot subscribe+claim (3 surfaces)
- **Group 3 — Cross-cutting:** callback dispatcher, idempotency, wallet ops + ledger (3 surfaces)

Each agent gets:
1. Working dirs (PoC + #current absolute paths)
2. Surface list with file:line refs both sides
3. Report format: per-surface (Production logic summary / PoC implementation / Drift identified [🔴 correctness / 🟡 realism / 🟢 ADR-sanctioned] / Impact / Effort / Priority P0/P1/P2)
4. Hard read-cap (≤25-30 file reads); no edits

**Outcome (PoC mb-next-payment-gateway 2026-05-13):** 3 parallel agents → 30-item drift map (15× P0 / 15× P1) in ~3min wall-clock. Triggered 5 architect threads (#94-100), 4 ADR amendments ratified by architect, 6 PoC PRs landing 15/15 P0 + load-bearing gaps in same-session arc. Main thread context saved ~10× vs serial audit.

**When to use:**
- PoC has matured to "feature complete on substrate" but invariants haven't been audited against #current
- Stakeholder reframes scope ("PoC must be load-bearing + production-parity")
- Single drift surfaces a hunch that more drift exists (e.g. user spots one symptom; audit confirms broader pattern)

**When NOT to use:**
- PoC is still building features (audit prematurely freezes design); audit only after substrate is "feature complete"
- Surfaces are unrelated (3 agents need ≥2-3 surfaces each to amortize cost)
- #current code is not in same repo (extra-repo refs need separate setup per agent)

**Trade-offs:**
- 3 agents × ~$0.30 each ≈ $1 in tokens
- Each agent's full transcript stays out of main context (use background mode)
- Risk: agent reports may overlap or conflict on cross-cutting surfaces — merge step belongs to main thread

Pattern instance #1 NEW. See `project_audit_poc_vs_current_2026-05-13.md` in claude-memory for the resulting drift map.

---
*Added via Oracle Learn*
