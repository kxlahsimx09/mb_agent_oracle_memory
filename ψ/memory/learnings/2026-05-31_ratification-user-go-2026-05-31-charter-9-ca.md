---
title: RATIFICATION (user GO 2026-05-31, charter §9) — campaign ng2arch §ADR-19 + §ADR-
tags: [ratification, adr-19, adr-12, adr-2-s2, step-up, auth-007, gross-vs-net, mdr, pullout-tasks, soft-delete, ng2arch, money-decision]
created: 2026-05-31
source: next-architect (ng2arch campaign — user ratification)
---

# RATIFICATION (user GO 2026-05-31, charter §9) — campaign ng2arch §ADR-19 + §ADR-

RATIFICATION (user GO 2026-05-31, charter §9) — campaign ng2arch §ADR-19 + §ADR-12 §Amendment finalized; both PRs (#291, #292) ready-for-review, NOT merged (user merges). Updates the two prior ng2arch learnings (which were "pending user GO").

§ADR-19 (PR #291) — all 3 sub-decisions RATIFIED, each matched the architect lean → promoted #decision:
- m1 MDR-base = GROSS (deposit fee + partner MDR shares compute on gross deposited amount; client wallet credited net = gross − fee). One GROSS base across both inflow lanes (deposit + topup §ADR-16 D5).
- m2 = per-client (per-MDR-profile) fee policy; NO per-method/per-bank/per-channel differentiation; the §ADR-18 MDR profile is the single fee-config home.
- m3 = fee-rate snapshot at deposit-CREATE.
DEPOSIT-002 AC #1 now asserts the GROSS net-credit base.

§ADR-12 §Amendment 2026-05-31 (PR #292) — both sub-decisions RATIFIED:
- p1 = soft-delete + BLOCK delete/disable while a pullout-task has an enqueued/in-flight drain in withdrawal_queue (matched lean; composes §ADR-18 b3; preserves config + pullout_logs lineage).
- p2 = SPLIT (user override of the all-or-nothing framing). NOTABLE DURABLE PATTERN — step-up gated by MONEY-RISK SHAPE, not by action category: the manual `execute-now` trigger (running an ALREADY-VETTED drain config) carries NO step-up; but pullout-task CONFIG create + update of the DESTINATION account + SCHEDULE/TIMING (defining WHERE/WHEN funds drain) REQUIRES step-up (AUTH-007). User rationale: "the money-risk is defining where/when the money goes, not pressing go on a vetted config."
  → This is the FIRST EXTENSION of the §ADR-2 §Amendment 2026-05-26 S2 step-up scope beyond the original thread #236 set {refund · admin DTR · admin settlement create+approve · admin payout override/confirm/cancel}. Cross-ref recorded at the §ADR-2 S2 amendment entry. Asymmetry vs the rest of S2: pullout moves the operator's OWN funds bank-to-bank (no client/partner wallet), and the gate is on CONFIG-WRITE, not on execution.
  → PULLOUT-003 carries the config-write step-up AC (create + dest/timing edits); PULLOUT-004 carries in-flight BLOCK + soft-delete + no-step-up execute-now. INDEX + story-shape table updated; PULLOUT-004 → [S2].

GENERALIZABLE: when an operator surface separates "define a money-movement config" from "execute a vetted config," the step-up/privilege gate belongs on the define step (where/when/destination), not the execute step. Consider this split whenever extending step-up scope to a new operator surface.

---
*Added via Oracle Learn*
