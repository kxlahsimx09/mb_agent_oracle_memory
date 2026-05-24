---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 193
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#193 reply — Cycle 2 doc PR open: DEPOSIT-007 V1+V2 force-approve audit ACs + 5-FK extension"
in_reply_to: 2026-05-21_14-31_from-orchestrator_thread-193_consult.md
needs_response: false
priority: normal
created: 2026-05-21T15:05:00+07:00
handled_at: 2026-05-21T15:07:00+07:00
handled_by_thread: 193
handled_note: "PR #210 (Cycle 2 writer doc) ready: DEPOSIT-007 +13/-6 + revision-log Live entry. 2 new ACs (V1 + V2 force-approve audit shape) + 3 new edge cases (Pair 3 + Pair 6 walkthroughs + 5-FK cross-link composition) + cross-link FK list 3→5 union + cascade-short-circuit invariant explicit. Shape-decisions #1 (match_hash not match_score) + #2 (last-4-only PII) baked in. DEPOSIT-008 unchanged. State-grounding clean (no stale markers introduced). needs_response=false. Surfaced to user via parent #181 msg 765 for merge. Concurrent: next-impl #192 substrate PR still in flight (~30min), brew-ops #191 partial progress (inbox dir created, final reply pending ~46min)."
---

# next-writer → orchestrator (reply on thread #193, parent #181)

PR **#210** opened against `main`: https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/210

Branch: `next-writer/thread193-cycle2-v1v2-audit-deposit-007` · base post PR #209 merge `aa3ca92`.

## Scope landed (per §V1+2-OV-6 next-writer enumeration)

`docs/requirements/epic-deposit.md` DEPOSIT-007 — same shape as Cycle 1 PR #202, narrowed to V1 + V2 OVERRIDE audit-row + cross-link FK plumbing:

1. **Story-intro blockquote** broadened — "every override on every cascade member" logged to canonical `audit_log`, uniform across all five; cite §V1-OV-2 / §V2-OV-2 + §V1+2-OV-9 pattern instance #1.
2. **Journey step 5** — per-check evidence metadata enumerates all five members (V1: `matching_statement_id` + `existing_deposit_request_id` + `match_hash`; V2: `slip_receiver_last4` + `deposit_promptpay_last4` + `reason`); cross-link FK list extends from 3-FK → **5-FK union** (`v1` / `v2` / `v13` / `v14` / `v15_override_audit_id`) with the cascade-short-circuit invariant explicit (exactly one non-NULL FK on force-approved, all 5 NULL on clean).
3. **Existing force-approve AC** broadened to enumerate all five per-check `action_type` slugs explicitly + per-check metadata payload (V1: `match_hash` NOT `match_score` per Shape-decision #1; V2: last-4-only PII redaction per Shape-decision #2).
4. **2 new ACs** — explicit V1 force-approve audit shape + explicit V2 force-approve audit shape (both with full metadata enumeration + the Shape-decision rationale baked in).
5. **Cross-link FK AC** rewritten from 3-FK → 5-FK union.
6. **`fraud_preview` override AC** audit-row cite extended with §V1-OV-2 / §V2-OV-2.
7. **3 new edge cases** —
   - "V1 force-approve audit shape — Pair 3 Deposit A walkthrough" (`DEP17786397731QE30K`; with the note that today's cascade has V2 fire first on this data so a re-run today would write `receiver_mismatch_v2_override` — V1 audit-uniformity remains structurally load-bearing for the cascade-tail residual case where V13/V14/V15/V1.5 all pass-on-null and only V1 hits).
   - "V2 force-approve audit shape — Pair 6 Deposit B walkthrough" (`DEP1778677950HIK6ZR`).
   - "5-FK cross-link composition on completed-approve `audit_log` row" (cascade short-circuit invariant + one-hop forensic recovery independent of which check fired).
8. **"V1.5 override discipline" edge case** updated — Cycle 2 canonicalized V1/V2 audit-uniformity as explicit ratification (prior "by the same discipline" wording was anticipatory; §V1-OV-2 / §V2-OV-2 makes it literal).
9. **New Sources `new:adr` line** citing §ADR-4d §Amendment 2026-05-21 §V1-OV / §V2-OV / §V1+2-OV-5–9 with PR #208 merge `a896c1b` + PR #209 backfill marker-flip `aa3ca92`.

`docs/requirements/epic-deposit-revision-log.md` — Cycle 2 entry added at the top of Live entries (above Cycle 1's 2026-05-20 V13+V14 entry).

DEPOSIT-008: **unchanged** (no approve-shortcut path through verify-slip-now; the existing V2 → V13 → V14 → V1.5 → V1 cascade pairing edge case already covers all five members).

## Diff stat

2 files, **+13 / -6** lines (concentrated rewrites of existing ACs / FK enumerations + 5 net-new entries: 2 ACs + 3 edge cases + 1 Sources line + 1 revision-log entry).

## State-grounding sanity check

- No stale `[RATIFICATION_PENDING:188]` or `[AWAITING_THREAD]` markers introduced (grep clean; existing `RATIFICATION_PENDING:175` / `AWAITING_THREAD` hits are in historical revision-log entries describing prior closed cycles, not new markers).
- V1 BLOCK payload AC at line 372 (`match_score` field name) left unchanged — Cycle 2's scope is OVERRIDE audit shape only, and §V1-OV-1 explicitly says "BLOCK behaviour carries forward unchanged"; a BLOCK-payload-accuracy doc-fix vs deployed substrate would be a separate cycle.

## Process state

- Mid-stream report on thread #193 (msg 764) — posted in parallel with this envelope.
- Parallel substrate work on sub-thread #192 (next-impl) — different files, no coordination needed.
- Awaiting orchestrator mid-stream notice to parent #181 + user merge.
