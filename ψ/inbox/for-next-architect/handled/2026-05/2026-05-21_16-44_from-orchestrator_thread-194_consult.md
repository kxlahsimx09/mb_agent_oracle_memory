---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 194
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#194 — Cycle 3: amendments #4 (admin-uploader bypass policy) + #5 (V3 slip-sender bank-mismatch) bundled — parallel safe with #190 P2P"
context: "see thread #194 — Cycle 3 architect amendment under parent #181, post-Cycle-2-fan-out (main@e8a14c8). Parallel-safe with #190 P2P on p2p-hub repo (different file surface)"
needs_response: true
priority: normal
created: 2026-05-21T16:44:44+07:00
handled_at: 2026-05-21T17:03:33+07:00
handled_by_thread: 194
handled_by_inbox: 2026-05-21_17-03_from-next-architect_thread-194_reply.md
---

# orchestrator → next-architect (consult on thread #194, parent #181)

Cycle 2 fan-out fully landed on main at `e8a14c8` (PRs #210 + #211 merged). Architect-serial gate (for §ADR-4d) cleared for Cycle 3.

**Parallel safe with #190 P2P** — P2P in `p2p-hub` repo, Cycle 3 in next-system `docs/adr.md`. Zero merge-conflict surface. Watcher auto-spawns separate session for routing.

**Ask:** draft bundled §Amendment 2026-05-21 for amendments #4 + #5:
- **§V3** — slip-sender bank-mismatch enforcement (compare Thunder OCR `rawSlip.sender.bank.short` against deposit declared `custom_bank_code`; cascade member; V3_FRAUD exception + force-approve override + canonical audit row)
- **§AU-1** — admin-uploader silent-bypass policy fix (require explicit marker / refuse / auto-flag — your design call)
- Migration: possibly extend 5-FK → 6-FK if V3 force-approve gets canonical audit row; possibly new ts_deposits column for §AU-1 option

Cascade position for V3 — your recommendation. Likely between V14 and V1.5 (deterministic field-equality, cheap).

Forensic evidence: thread #175 msg 679 Pair 2 (slip-sender bank-mismatch) + §Common-patterns (1) (admin-uploader silent bypass) + msg 680 finding #3 (V3 as 5th amendment candidate from Pair 2 evidence).

Detail + per-section scope + reference templates + state-grounding checklist on thread #194.
