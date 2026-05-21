---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 167
parent_thread: 167
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-51-20260517-200810
subject: "#167 — P1#2 doc ACs (PR #168) + matcher epic authored (PR #169)"
needs_response: true
priority: normal
created: 2026-05-18T20:30:00+07:00
---

Two tasks done. Full reply posted to thread #167 (msg 552).

## (1) P1#2 doc — SC10 handoff — PR #168

`epic-payout.md` updated for §ADR-4a §Amendment 2026-05-18 (success-payout
statement-confirmation audit): PAYOUT-002 gains an edge case for the
after-the-fact statement-confirmation audit; PAYOUT-009 gains an AC for the
matcher's `success`-link branch + an edge case for the three-way
classification with intra-bank/memo-less successes `exempt`. Sources cite the
amendment. Doc-only.

**PR #168** — `next-writer/thread167-p1-2-success-audit-acs` → `main`, open,
**not merged** (§9).

## (2) Matcher epic — PR #169 (stacked on #168)

Created `epic-statement-matching.md` — canonical matcher-engine spec:
MATCH-001 (intake + count-based dedup), MATCH-002 (IN cascade), MATCH-003
(OUT reconcile + success audit). Wired into INDEX.md + README.md.
Consolidate-vs-reference: matcher epic owns the engine; DEPOSIT-002 /
PAYOUT-009 keep lane behaviour and reference it (Engine-reference blockquotes
added; DEPOSIT-002 dedup mechanics + pure-engine genuine-duplicate AC moved
to MATCH-001).

50/50 calls flagged in the PR body: the lane cascade/reconcile ACs were kept
in place (testable lane contracts — gutting them would be destructive); only
unambiguously pure-engine passages were moved to references. A deeper AC-level
de-dup is a structural follow-up left for the user. Matcher stories framed
around the engine (no single user actor) — flagged in case a different
framing is preferred.

**PR #169** — `next-writer/thread167-matcher-epic` → base
`next-writer/thread167-p1-2-success-audit-acs` (stacked), open, **not
merged** (§9). Review #168 first.

needs_response: the two flagged 50/50 calls (keep-vs-gut lane ACs;
engine-framing of matcher stories) are open for the user's structural call.

# handled_at: 2026-05-18T22:09:08+07:00
# handled_by_thread: 167
# handled_by_inbox: for-next-writer/2026-05-18_22-09_from-orchestrator_thread-167_reply.md
# handled_note: PR #168/#169 received; 2 structural 50/50 calls escalated to user
