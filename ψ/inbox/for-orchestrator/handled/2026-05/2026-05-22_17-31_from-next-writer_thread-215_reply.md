---
from: next-writer
from_role: next-product-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 215
parent_oracle: orchestrator
subject: W2 cleanup-requirements DONE — 3 PRs (#227 mdx · #228 epic-deposit hygiene · #229 epic-payout PE) + thread #102 cluster-split refreshed (proposal, both epics, awaiting human sign-off — NOT actioned)
needs_response: false
priority: normal
created: 2026-05-22T17:31:00+07:00
handled_at: 2026-05-22T17:39:17+07:00
handled_by_thread: 215
handled_note: needs_response=false worker-completion reply — no reply envelope. Aggregated to user on thread #215 msg 940 + Telegram (orchestrator chat 2002026175, msg 27). PRs #227/#228/#229 verified OPEN against kxlahsimx09/mb-next-payment-gateway (1 file each, base main). Cluster-split sign-off escalated to user on thread #102 (still pending). #215 held pending user (PR merges + split sign-off).
---

W2 `cleanup-requirements` pass complete — full report on **thread #215 msg 938**.

**TL;DR:** 3 PRs open, each touching one file (grouped to avoid inter-PR merge conflict; categories labelled in PR bodies):
- **#227** MDX-safety (epic-wallet-ledger brace)
- **#228** epic-deposit hygiene — Step 3c plain-English on DEPOSIT-007 (the epicenter of the "รก") + orphan-flip `:175` + brace fix. 89 ACs byte-verbatim.
- **#229** epic-payout plain-English — 4 body-prose lines. 61 ACs byte-verbatim.

**Cluster-split (Step 3b) = PROPOSAL ONLY** — refreshed on **thread #102 msg 937**, now spans both epics. Headline: the 2026-05-15 `auto/slip/admin` split no longer reaches ≤250 (DEPOSIT-007 grew 95→133 + new DEPOSIT-009). 6 decisions enumerated; recommended **D-1 (design-extraction) + P-4 (4-way payout)**. Awaiting user sign-off.

**Two flags for you:**
1. **Orphan-sweep refinement:** the four `[RATIFICATION_PENDING:167]` markers were LEFT untouched — thread #167 is closed but `adr.md:359/:402` still record §Amendment 2026-05-18 as "drafted … awaiting ratification". Thread-status alone would have wrongly stripped them. If the Success-Payout audit (§167) gets ratified, those markers + the §V15-style declarative flip become a follow-on sweep.
2. **epic-payout has no revision-log file** (W1-infra gap) — surfaced, not fixed. Revision-log entries for this pass deferred to post-merge per the 2026-05-15 precedent.

`arra_learn` filed; retro at `ψ/…/2026-05/22/17.30_w2-cleanup-deposit-payout.md`.

<!-- handled_at: 2026-05-22T17:40:09+07:00 | handled_by: orchestrator wt-13 | handled_note: MOOT for wt-13 — a sibling orchestrator (wt-15, watcher-spawned) already handled this #215 reply: posted aggregation msg 940 to thread #215, verified PRs #227/#228/#229, surfaced cluster-split #102 + 2 flags to user, asked for sign-off. wt-13 NOT re-aggregating (avoids the redundant round-trip §214 guards against). This is the 2nd sibling-orch spawn this session (watcher §151 owner-routing gap, adjacent to #88 per wt-12 #214 msg 927 — tracked-open). Relaying result to user via the live wt-13 channel. -->
