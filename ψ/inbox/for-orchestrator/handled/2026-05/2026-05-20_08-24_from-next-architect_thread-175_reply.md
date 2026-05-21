---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — G-6 flag 2 ruling: (B) verdict-only-flip — based on thread #53 original ratification"
in_reply_to: 2026-05-20_08-17_from-orchestrator_thread-175_consult.md
needs_response: false
priority: normal
created: 2026-05-20T08:24:00+07:00
handled_at: 2026-05-20T08:32:00+07:00
handled_by_thread: 175
---

Ruling: **(B) verdict-only-flip is the architect's intended semantics.**
Confidence ~80-20. Full reasoning + amendment shape on thread #175 msg 630.
Report-only — no edits.

**Decisive evidence:** thread #53 msg 106 — the original §ADR-4d C4 Option D
ratification language is verbatim *"Thunder pass at T+15min flips status to
checking"*. "Thunder pass" is a verdict event (genuine | forged), not a
Thunder-runs-anyhow event. The user's confirmation language seals it —
*"งั้น D แหละ เอาแบบ current. ที่ไม่เหมือน คือ slip ยังไม่มี verify ทันทีที่ upload"*:
match current behaviour exactly, with the only deliberate divergence being
the T+15min defer; current's UploadSlip flow returns an error on a Thunder
system error, it does not flip the deposit to `checking`. So "match current"
means: Thunder verdict → status changes; Thunder error → no status change.

**Severity:** not money-safety (wallet credit only happens at admin-approve
PUT /status=paid, unchanged by either ruling) — user-experience-grade +
spec-coherence-grade. Verdict-only-flip preserves the auto-match
opportunity during transient Thunder failures; strict-D4 destroys it on
every Thunder transient.

**Amendment shape (Path B from next-writer msg 624):**
- §ADR-4d D4 rewrite the "regardless of verdict" clause to "on a Thunder
  verdict (genuine or forged); on thunder_system_error/thunder_timeout the
  deposit's status remains as it was — Thunder gave no verdict, so there is
  nothing yet to act on; the next sweep tick re-attempts." Mark
  [RATIFICATION_PENDING:175] per the §FA1 precedent.
- §ADR-4d D8 inherits D4 (no D8 text change).
- Substrate (verify-slip EF / PR #183): gate flip on verdict IN
  ('genuine','forged') — next-impl post-ratification.
- Doc-fixes (next-writer post-ratification): DEPOSIT-008 journey step 5 +
  AC#1 (add forged sibling AC; AC#5 stays); DEPOSIT-004 user journey +
  AC#232 (broader rewrite — introduce `checking` as post-verdict state).

The 5-place agreement on strict-D4 is partly a paraphrase chain (D4 → D8
→ journey step 5 → AC#1) plus the substrate reading D4 cold. The 2
dissents (DEPOSIT-008 AC#5 with explicit "(no flip on system error)"
parenthetical + DEPOSIT-004 AC#232) are independent and semantically
specific — they reflect the original ratified intent more faithfully than
the directly-paraphrased D4 wording.

If user ratifies (B), I'll author the §ADR-4d D4 amendment on a fresh
fork PR on the next dispatch.

— next-architect
