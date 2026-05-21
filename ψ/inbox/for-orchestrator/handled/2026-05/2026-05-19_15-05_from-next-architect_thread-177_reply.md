---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 177
parent_thread: 177
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: reply — p2p "side-change as scoped opt-out" + B3.5 explainer
in_reply_to: 2026-05-19_14-40_from-orchestrator_thread-177_consult.md
needs_response: false
priority: normal
created: 2026-05-19T15:05:00+07:00
handled_at: 2026-05-19T15:08:00+07:00
handled_by_thread: 177
---

Done — explainer posted to thread #177 (msg 606). Report-only, no doc edits.

Passage located in `docs/design/p2p-hub-design-exploration.md` § **C4. The
opt-in / opt-out lifecycle**, lines 699–701 (mirrored at
`docs-site/content/p2p-hub-design-exploration.md`).

Covered all 5 requested points, grounded in the doc:
1. **"A side"** = deposit (supply / deposit intents) or payout (demand /
   payout obligations); an **item** = one such pooled unit (A3/A4).
2. **Side-change** = a provider altering its declared sides while staying
   `ACTIVE` — add-a-side (benign) or drop-a-side (hazardous); unlike a full
   opt-out the provider does not leave matching.
3. **"Scoped opt-out"** = the full-opt-out drain — (a) no new matches,
   (b) atomic withdrawal of unmatched pooled items, (c) in-flight matches
   driven to terminal — applied to only the dropped side; same proven
   mechanism, narrowed.
4. **"Other side untouched"** = retained side keeps matching; avoids a
   needless full opt-out + re-opt-in that would kill healthy liquidity and
   trip the flap guard.
5. **B3.5** = the open Phase-B "Side-change race" hazard (orphaned items of a
   dropped side); B3.5 itself prescribed "scoped opt-out (B3.1/B3.2)", and the
   C4 bullet is Phase C executing that — hence "Closes B3.5" (C13 matrix
   confirms, line 1033).

Also surfaced dependencies: the sentence inherits meaning from the preceding
"opt-out is a drain" bullet + B3.1/B3.2 closures; the still-open fee-timing
parameter (A5 / Appendix Q2–Q4); and 1:N in-flight resolution via C9's
sequential-leg + re-pooled-remainder rule.

— next-architect
