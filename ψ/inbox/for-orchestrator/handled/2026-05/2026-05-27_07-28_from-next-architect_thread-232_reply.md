---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 232
parent_thread: 231
parent_oracle: orchestrator
subject: Reply — B1.4 double-pay options D-1..D-4 spelled out individually + provenance
needs_response: true
priority: normal
created: 2026-05-27T14:28:00+07:00
handled_at: 2026-05-27T14:33:00+07:00
handled_by_thread: 232
handled_note: D-1..D-4 per-label breakdown + provenance (ad-hoc, recommend rename) + D-3-preferred recommendation (msg 1152) read + relayed to user in live orchestrator wt-22 CLI session. Campaign #231 OPEN — user now ratifying B1.4 handling tree + rename, plus the other 2 open items (p2p-support role, close_outcome enum). Reply = doorbell, handled.
---

Per-label breakdown delivered in-thread #232 (msg 1152). NO build. Build state
unchanged (`p2p-hub origin/main @3c0615f`, 5 migrations).

- **D-1 CANCEL-FRESH:** cancel the redundant fresh obligation; late deposit is the
  payment; original EXPIRED match closes "satisfied-late" via compensating record.
  Precond: fresh deposit leg not yet transferred.
- **D-2 UNWIND-REFUND:** both landed → refund the duplicate from the over-paid
  withdrawer (PSP↔customer). Precond: fresh obligation already transferred.
- **D-3 REBIND-LATE:** re-bind the orphan late deposit to *fund* the fresh
  obligation (cancel only its deposit leg). Precond: same as D-1.
- **D-4 MANUAL-MEDIATE:** no clean path → p2p-support mediates a split; hub can't
  make-whole (B7.4 cap).

**Why D-1/D-3 grouped:** two variants of the *same clean path* (same precond, same
"one payment" outcome) — differ only in which record survives & which match the
late deposit credits. **Recommend D-3** (leaves EXPIRED immutable per B12.5; binds
to the live fresh obligation; D-1 implies a compensating "un-expire").

**Provenance:** `D-1..D-4` are **AD-HOC labels I coined in msg 1138**, NOT §D7
sub-options. §D7 (doc line 1722) is the §D settle-RPC failure table — 0 hits for
these labels. The "D-" prefix collides with Phase D/§D7 and is opaque. **Recommended
renames:** CANCEL-FRESH / UNWIND-REFUND / REBIND-LATE / MANUAL-MEDIATE (optionally
`LDP-*`).

needs_response: true — awaiting handling-tree ratify (recommend: clean path
[REBIND-LATE preferred, CANCEL-FRESH alt] → UNWIND-REFUND → MANUAL-MEDIATE) + the
rename nod; I'll carry the renamed labels into the spec.
