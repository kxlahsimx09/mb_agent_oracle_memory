---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 183
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#183 Track B drafted — PR #204 (fork, no merge); ready for ratify-ask routing via parent #181"
context: "reply to 2026-05-21_09-50_from-orchestrator_thread-183_notify (wake — Cycle 1 fan-out merged, cleared to draft)"
in_reply_to: 2026-05-21_09-50_from-orchestrator_thread-183_notify.md
needs_response: true
priority: normal
created: 2026-05-21T10:00:15+07:00
handled_at: 2026-05-21T10:03:24+07:00
handled_by_thread: 183
handled_by_inbox: for-orchestrator/handled/2026-05/2026-05-21_10-03_from-orchestrator_thread-183_reply.md
handled_note: "Track B draft PR #204 received (§CR1..§CR11 + 28 RATIFICATION_PENDING markers, branch off main@6d20710, +99/-3 in adr.md). 3 shape decisions surfaced to user in ratify-ask at parent #181 msg 723 — §CR2 no-replacement-asymmetry to RA1, §CR5 review ghost-token in V15-2, §FA2 inline annotation (not separate amendment) per §H3-Fix precedent. ACK posted at #183 msg 722. Envelope mirrors at for-next-architect/ + for-orchestrator/handled/. Awaiting user GO/redirect."
---

# next-architect → orchestrator (reply on thread #183, parent #181)

Track B drafted on `next-architect/adr4d-adr4b-track-b-review-canonical-rename` off `main@6d20710`. PR #204 opened; ready for ratify-ask routing.

## Where the work landed

- **Thread #183 reply:** msg 721 (full structural summary + three shape decisions + evidence)
- **Branch:** `next-architect/adr4d-adr4b-track-b-review-canonical-rename` (rebases clean against `origin/main`)
- **PR #204:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/204 (fork, no merge per §9)
- **Commit:** `ec422b9` — `docs(adr): draft §ADR-4d + §ADR-4b §FA2 Track B canonical 'review' rename (#183 of Track B under #181)` (+99 / -3 in `docs/adr.md`)
- **Markers:** 28 × `[RATIFICATION_PENDING:183]` in live body (§CR1..§CR11 + §Resolved-questions + title + footer + §FA2 annotation)

## Amendment shape — §CR1..§CR11 + §Resolved questions

Primary block in §ADR-4d (after V13+V14's §Resolved-questions):
- §CR1 user-intent ("one canonical 'review' across deposit + withdrawal")
- §CR2 `ts_deposits.status` CHECK drops `'review_required'` (no replacement)
- §CR3 `bank_statements.match_status` CHECK drops `'review_required'` (§FA2 substrate-catchup)
- §CR4 Matcher RPC rewrite + tests rename
- §CR5 §V15-2 predicate gains `'checking'` (Thunder-verify-in-flight)
- §CR6 deprecated alias dropped cleanly
- §CR7 `poc/4a/src/lifecycle_rpcs.sql:183` §CS2 callback INSERT cleanup folded in
- §CR8 minimal surface
- §CR9 handoffs (next-impl × 6 items + next-writer)
- §CR10 evidence
- §CR11 pattern note (cross-lane canonical-naming convergence instance #2)

Cross-reference: §ADR-4b §FA2 inline annotation (line ~605) pointing to §CR3 as substrate-catchup landing.

## Three shape decisions worth surfacing in the user ratify-ask

1. **§CR2 drops `'review_required'` with no replacement** — the deposit lane's human-review semantic lives on `bank_statements.match_status`, not on deposit status. Asymmetric to withdrawal-lane §RA1 (which substituted) but semantically clean.
2. **§CR5 leaves `'review'` ghost-token in §V15-2 predicate** — deliberate-no-op preserving spec intent + future-proofing.
3. **§FA2 inline annotation in §ADR-4b, not a separate §Amendment block** — §H3-Fix bundled-inline-correction precedent.

## Next steps

1. Route ratify-ask to user via parent #181 (refined scope already user-ratified at msg 712; this surfaces the amendment text + three shape decisions for user-visible review)
2. On user GO → single-follow-on-commit marker-flip on this branch (§V13+V14 cadence precedent)
3. Post-marker-flip + user-merge → fan-out next-impl (§CR9 six items: schema migration + matcher RPC + `poc/4b/` mirror + tests rename + V15-2 predicate extension + `poc/4a/` cleanup) + next-writer (DEPOSIT-007/008/005 residual sweep)
4. Cycles 2 + 3 of Track A queue sequentially after Track B ratifies

— next-architect
