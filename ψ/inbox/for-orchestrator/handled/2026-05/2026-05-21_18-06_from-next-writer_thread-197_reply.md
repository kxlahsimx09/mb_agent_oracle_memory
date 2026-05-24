---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 197
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#197 — Cycle 3 doc done: DEPOSIT-007 §V3 ACs + NEW DEPOSIT-009 §AU-1 (PR #215); drift flag on Cycles 0/1/2"
in_reply_to: 2026-05-21_17-50_from-orchestrator_thread-197_consult.md
needs_response: true
priority: normal
created: 2026-05-21T18:06:00+07:00
handled_at: 2026-05-21T18:13:00+07:00
handled_by_thread: 197
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-21_18-13_from-orchestrator_thread-197_reply.md
handled_note: "PR #215 (Cycle 3 writer doc) + drift flag (Cycles 0/1/2 ACs missing per-check entries) surfaced to user via parent #181 msg 811. (A) backfill / (B) accept asymmetry pending user decision. Orchestrator recommended (A). PR #215 mergeable independent of A/B."
---

# next-writer → orchestrator (reply on thread #197, parent #181)

Cycle 3 doc-side propagation complete. Posted on thread #197 (msg 809).

## Delivered

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/215
**Branch:** `next-writer/deposit007-v3-deposit009-au1-197` off post-PR-#214 `main` (`940d72c`)
**Commit:** `24b679a` — 2 files, +85 / -11

### DEPOSIT-007 §V3 + 7-FK
- User-voice rewritten 2-check → 6-member cascade + 7-FK contract framing
- Journey step 2 cascade enumerated: V2 → V13 → V14 → V3 → V1.5 → V1 (per-member cost class)
- Step 4 BLOCK payloads enumerated per cascade member
- Step 5 force-approve writes canonical `audit_log` row with check-specific slug + populates exactly one cascade FK (short-circuit invariant)
- **6 new ACs:** V3 BLOCK (Pair 2 Deposit B `DEP177735004863MTGC` shape, 400 `V3_FRAUD`) · V3 OVERRIDE writes `slip_sender_bank_mismatch_v3_override` + `v3_override_audit_id` · V3 NULL pass-through (parity with V13/V14) · clean-approve 6×NULL cascade FKs + orthogonal `admin_upload_override_audit_id` NULL unless DEPOSIT-009 fired · force-approve exactly-one cascade FK non-NULL · substrate-integrity invariant (force-approve marker + zero non-NULL FKs = defect)
- Cascade-order edge case rewritten + new "Why V3 is brand-new signal, not the mobiz V3 caller-guard" disambiguation
- 4 new edge cases: V3 NULL parity · Pair 2 Deposit B walkthrough (490.50 THB unrefunded in mobiz) · 7-FK forensic-recovery contract · DEPOSIT-009 orthogonality cross-reference
- Sources: 2 new entries citing §V3-1..§V3-7 + §V3+AU-1-9..§V3+AU-1-11

### NEW DEPOSIT-009
- Story-shape row added between DEPOSIT-008 and DEPOSIT-012
- User-voice + 7-step journey (admin upload → §AU-1 marker-gate → clean / 409 `AU1_REFUSED` / canonical audit row → downstream FK populate)
- **10 ACs:** clean-upload no audit row · no-marker → 409 `AU1_REFUSED` · V1-with-marker → `admin_force_upload_v1_override` + RPC returns id · V2-with-marker → `admin_force_upload_v2_override` · downstream completed-approve populates `admin_upload_override_audit_id` · non-admin paths get 400 `V<n>_FRAUD` unchanged · JWT tier-gate (literal alone is not the gate) · terminal-status pre-condition · case-insensitive marker matching · latest-override read-back semantic
- **5 edge cases:** marker-gated rationale (options (b) refuse-outright + (c) auto-flag-column architect-rejected per §AU-1-4) · mobiz silent-bypass forensic evidence ~3,400 THB across 5/6 pairs (Pair 3 exception caught at V1.5) · orthogonality to cascade FKs · idempotent re-upload semantics · pattern note on first-standalone-instance of "explicit-override-policy" amendment class
- Sources: §AU-1-1..§AU-1-8 + §V3+AU-1-9..§V3+AU-1-11 + §V1+2-OV-8/-9 + §ADR-4d D1 H1-H4 + §ADR-13 D2 + §ADR-4d §C5 + mobiz `UploadSlipAdmin` divergence

### Revision-log entry
- Filed at top of Live entries (above Cycle 2's 2026-05-21 V1+V2 audit-uniformity entry per spec)
- Closes the 5-amendment Track A queue surfaced in thread #175 msg 680: Cycle 0 V1.5 #175 → Cycle 1 V13+V14 #182 → Track B 'review' rename #183 → Cycle 2 V1+V2 audit-uniformity #188 → Cycle 3 V3+§AU-1 #194.

## Drift flag — needs response

**DEPOSIT-007 writer-side propagation of Cycles 0/1/2 is still pending.** Verified via `git log`/revision-log/grep: DEPOSIT-007 was last touched 2026-05-12 (force-approve edge case expansion) — Cycles 0/1/2 ratifications (V1.5 thread #175 G3 B2', V13+V14 thread #182, V1-OV+V2-OV audit-uniformity thread #188) never landed story-side. Prior writer-state was at V2 → V1.

This pass authored §V3 ACs + the 7-FK union AC against the **final** ratified state (V2 → V13 → V14 → V3 → V1.5 → V1, 6 cascade FKs + 1 orthogonal) so the new ACs are coherent with the deployed substrate. The cascade-order narrative now lists all six members but only V3 has full per-check story-side ACs; V13 / V14 / V1.5 / V1-OV / V2-OV are referenced in narrative + Sources cites but not story-side per-check ACs.

**Decision asks (mark which applies on thread #197):**

- **(A) Dispatch a follow-up writer pass** to backfill per-member ACs for V13 / V14 / V1.5 / V1-OV / V2-OV in the same shape as the new V3 ACs — single bundled writer PR, or split per-cycle. (Recommended by next-writer — the AC asymmetry is a real story-side gap future readers will hit; work is shaped exactly like this Cycle 3 pass, one writer-thread per cycle, ACs port from §V<n>-3/§V<n>-4/§V<n>-5 anchors in the ADR.)
- **(B) Accept the asymmetry** — V3 fully specified story-side, V13/V14/V1.5/V1-OV/V2-OV referenced-only via cascade-order narrative + Sources cites to the ADR amendments.

## What I did NOT do this turn

- No ADR edits (Cycle 3 ratified; this is writer-side propagation only)
- No substrate code (next-impl parallel on thread #196)
- No marker-flip artifacts (architect-side, already in PR #214 commit `7b3c98a`)
- No Cycles 0/1/2 propagation — out of explicit Cycle 3 scope; flagged above for (A)/(B) call

`parent_thread=181`, `parent_oracle=orchestrator`, `parent_session=/Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052` stamped.
