---
title: Orchestrator session-grounding: why round-1 grounding missed the predecessor ses
tags: [orchestrator, grounding, handoff, session-resume, oracle, index-lag, stale-state]
created: 2026-06-12
source: orchestrator session 2026-06-12 (wt-25-build) — grounding post-mortem requested by owner
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Orchestrator session-grounding: why round-1 grounding missed the predecessor ses

Orchestrator session-grounding: why round-1 grounding missed the predecessor sessions (build2 + bankbot2, 2026-06-12) — and the correct grounding order.

What went wrong (4 layers):
1. **Close-handoffs were retros, not inbox files.** build2 and bankbot2 both ended by writing `ψ/memory/retrospectives/YYYY-MM/DD/*.md` only — nothing in `ψ/inbox/handoff/`. arra_inbox therefore showed the PREDECESSOR's handoff as "newest" and looked complete. Check retros by date (`find ψ/memory/retrospectives -newermt <date>`) before concluding "no handoff".
2. **arra_search index lag.** Both retros were committed AND pushed to the vault repo, but FTS returned 0 hits for "bankbot2" a full day later — fresh files are invisible until reindex. Worse, hybrid mode papers over the gap with old-but-similar vector matches, which LOOKS like an answer. Treat zero ftsMatches on a literal token as "index is stale", not "doesn't exist".
3. **Vault path indirection.** The real ψ vault for the mb-next fleet is `kxlahsimx09/mb_agent_oracle_memory` (resolved server-side by the MCP) — NOT the arra-oracle-v3 checkout (its ψ/ has only memory/). Locating it required mdfind on a known handoff filename.
4. **Stale-state-on-resume (again).** Even after finding the retros, narrative docs (STATUS.md, handoffs) were read as current state: "#415 landing" was already MERGED, "L3 re-cert pending" already had a CloudWatch proof on main, the deposit-journey LIVE-gate prereqs were already superseded by the §ADR-21 SP1 re-scope. The owner had to correct the picture twice.

Correct grounding order for a resuming orchestrator:
(1) GitHub ground truth FIRST: `gh pr list` (open + recently-merged) and origin/main log on every work repo;
(2) filesystem `find` on mb_agent_oracle_memory retros + inbox by date;
(3) arra_search LAST, as a supplement — never as the primary source for "what just happened".

---
*Added via Oracle Learn*
