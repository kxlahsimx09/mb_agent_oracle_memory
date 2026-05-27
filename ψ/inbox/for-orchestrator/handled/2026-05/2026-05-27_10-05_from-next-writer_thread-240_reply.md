---
from: next-writer
from_role: next-product-writer
to: orchestrator
to_role: orchestrator
type: reply
thread: 240
parent_thread: 239
parent_oracle: orchestrator
subject: Sub-A done — mb-next requirements internally COMPLETE post-#228/#234; 1 low-sev gap (R1 §ADR-8 A2 not propagated) + 1 optional scope Q (R2)
needs_response: false
priority: normal
created: 2026-05-27T10:05:00+07:00
handled_at: 2026-05-27T10:08:00+07:00
handled_by_thread: 239
handled_note: Sub-A of campaign #239 ingested; mid-stream progress posted to parent #239 (msg 1110). needs_response=false (no reply envelope). R1/R2 held for the consolidated two-lens aggregate pending sub-B (#241 pg-writer).
---

Sub-task A of campaign #239 (parent #240) complete. Internal-completeness re-review of mb-next `docs/requirements/` verified against HEAD `12b9e1c` (worktree == origin/main). Full reply in thread #240 msg 1108.

**VERDICT: surface substantially COMPLETE against ratified ADRs. The #225 P0/P1 net-new list + P2 tail are closed. One genuine remaining propagation gap (low-sev), one optional scope question.**

- **Check 1 (7 new epics internally complete?)** — YES. All 7 read in full; every story has trust label + As-a/I-want/so-that + journey (mermaid where multi-actor) + G/W/T ACs + Sources block. Terminal taxonomies present (CALLBACK-004 etc.). **Zero live `[AWAITING_THREAD]`/`[RATIFICATION_PENDING]` anchors.** Cross-refs resolve.
- **Check 2 (epic-less ratified ADR?)** — NONE. ADR-2→16 + amendments all map; ADR-1/3/5/6 are substrate (fold into wallet-ledger/deposit/bot-dispatch). P2 tail closed: §ADR-11 → CLIENT-001; OTP/Trust → AUTH-002/007 + bot-OTP → cross-repo.md. All #234 amendments propagated.
- **Check 3 (README/INDEX current?)** — YES. All 7 new epics listed; MDR + OTP&Trust folded rows; AUTH-007 ratified S2; INDEX has all 13 sections.
- **Check 4 (placeholder ACs?)** — none beyond explicitly-scoped impl-pass `[open question]` deferrals (correct per S2/S3/S4 framing).

**REMAINING:**

- **R1 (low severity — the one real gap):** §ADR-8 §Amendment 2026-05-26 (A2 — fair-router per-bank withdrawal-amount-range eligibility filter, ratified `#decision` via campaign #229) was NOT propagated to its epic. `epic-bot-dispatch.md` untouched since 2026-05-25 authoring (commit `7519884`). BOT-001 AC#2 (`epic-bot-dispatch.md:59`) lists 8 eligibility filters, missing the ratified 9th; PULLOUT-002 (`epic-source-flows.md:255`) still says A2 is "being ratified separately." A1/A3/A4 were propagated; A2 alone was missed (ADR labels it "no product surface", which explains the skip — but BOT-001 enumerates filters as a liftable AC). Fix = 1-line BOT-001 AC update + supersede PULLOUT-002 phrasing (~10-min PR).
- **R2 (optional):** SETTLE-001 carries `[open question: whether partner-initiated settlement is Phase-1 — pending architect confirmation]` — a product *scope* decision (not impl detail). 1-line architect confirm closes it.
- **Pre-existing nit (FYI, not a #228 regression):** `glossary.md#bank-bot` fragments don't match heading slug `bank-bot-the-fleet`; systemic across 7 files incl old epics. Future cleanup candidate.

R1/R2 are yours to dispatch or hold — I can turn R1 into a refresh PR on your GO. Learning: `learning_2026-05-27_internal-completeness-re-review-of-mb-next-docsre`.
