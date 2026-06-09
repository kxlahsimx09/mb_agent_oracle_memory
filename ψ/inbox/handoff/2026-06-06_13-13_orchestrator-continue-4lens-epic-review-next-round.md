---
to: orchestrator (next session)
from: orchestrator-odoc 2026-06-06
priority: P1
topic: CONTINUE — run the 4-lens pre-dev epic review (3 existing + NEW next-ui) on the next epic
---

# CONTINUE COMMAND — next-round 4-lens epic review

**State at handoff:** epic-deposit + epic-payout are deep-reviewed + dev-ready (all PRs merged; main HEAD as of 2026-06-06). The pre-dev-review pattern is proven across both. 11 epics remain un-deep-reviewed. NEXT ROUND adds a 4th lens (**next-ui**) to the established 3.

## TARGET EPIC (pick when you run this)
Default recommendation: **epic-wallet-ledger** (the money substrate both lanes depend on — balance/frozen/available, freeze-settle, MDR fan-out, change-log). Swap to another if the user prefers: callback-delivery · topup · monitoring · statement-matching · admin-audit · bot-dispatch · fleet-control · entity-provisioning · source-flows · client-api. CONFIRM the target with the user before dispatching.

## THE 4 LENSES (read-only, severity-tagged findings; campaign slug e.g. `<epic>review`)

1. **next-architect** — ADR-consistency + ADR-derived completeness + classify NEW/un-ADR'd gaps (within-architect-authority vs NEEDS-USER-DECISION). repo: github.com/kxlahsimx09/mb-next-payment-gateway. (See the epic-deposit/payout review prompts in learnings for the exact contract shape.)
2. **pg-writer** — current-mobiz parity: epic vs current Go source at github.com/kokarat/mobiz-payment-gateway (ground file:line); flag dropped-behavior / silent-divergence / missing-field; must-add vs intentional-cut. repo: github.com/kokarat/mobiz-payment-gateway (reads the next-system epic via absolute path).
3. **next-writer** — internal completeness/quality: missing coverage, untestable ACs, inconsistencies, ambiguity, story-number holes. repo: mb-next.
4. **next-ui** (NEW LENS) — UI/operator-screen perspective. repo: mb-next (reads epic + admin-web/ if relevant). BRIEF: "From the operator/admin + client-facing UI perspective, review epic-<X> for MISSING stories/ACs the UI needs to be buildable: (a) read/list/filter/detail/search surfaces for every entity the epic creates or mutates; (b) the exact fields the UI must DISPLAY (and which are RBAC/tenant-scoped); (c) operator ACTION affordances (buttons) + their enabled/disabled/confirm/loading/empty/error states; (d) 0-lag read-view / visibility contracts the UI binds to; (e) status/state surfacing (does the UI have a way to see every status in the state machine?); (f) any operator workflow the backend stories imply but never give a UI surface for (e.g. the new payout PAYOUT-012/013 corrections, pullout config, dropped-revenue/mdr_skip views, dead-letter recovery, alert acknowledgement). Flag UI-driven gaps as severity-tagged findings (HIGH/MED/LOW) — stories that SHOULD exist for the UI. Read-only; no edits. Output: next-ui_<slug>_findings.md."

## DISPATCH MECHANICS (proven)
- Use `scripts/team-dispatch-helper.sh --campaign <slug> --role <role> --repo <gh> --prompt "..."`.
- architect + next-writer + next-ui → mb-next worktree (shared, read-only, no contention). pg-writer → mobiz worktree. Spawn architect + pg-writer + next-ui first (distinct repos / no race), then next-writer (reuses mb-next wt).
- Worktree-readiness note: brew-ops/non-mb-next spawns sometimes miss TUI-ready → kickoff fallback; verify each pane actually started, re-send via `maw team send` if a pane is idle with no work.

## AFTER REVIEW (same flow as deposit/payout)
Aggregate the 4 findings → ONE prioritized report (HIGH first, by dimension incl. a UI dimension; dedup; story-hole verdict; surface architect's NEEDS-USER-DECISION + next-ui's missing-story candidates) → user ratifies decisions → staged fix: next-architect authors adr.md + writer-spec → next-writer applies epic (+ next-ui-driven new stories) → 2 PRs (adr / epic, disjoint files).

## CARRY THESE LEARNINGS (cost real corrections last 2 epics)
- VERIFY CURRENT before deciding a "gap" — H1/H2 step-up was a next-system hardening not a current-drop; the remediation toolkit was LIVE (dpay 1300×) not dead. Check Go source + dpay data first.
- dpay MCP: query from a FRESH TEAMMATE (mcp__dpay__* direct, ground field names in Go first; the dpay-finder SUBAGENT fabricates/loops — avoid). The long-lived orchestrator session's dpay HTTP session expires ('invalid session') — dispatch a teammate.
- NUMBERING: before minting a new story id, grep INDEX.md + revision-logs for existing/deferred ids (PAYOUT-011 collision was caught only by checking).
- as-of-date every illustrative prod-count citation (prevent stale-count recurrence).
- maw team send: NO backticks in the body (zsh runs them as command-substitution and mangles the message).
- adr.md PRs sharing the revision-log top-anchor will cascade-conflict on merge — keep adr (architect) + epic (writer) as disjoint-file PRs; warn the user on merge order for multiple adr.md PRs.
- finish-script leaves an orphaned LIVE pane on every close → kill the window BY NAME after finish (don't kill by index — tmux renumbers; never touch the nextteam windows).
- Spawn teammates for OTHER orchestrators' campaigns are off-limits (nextteam = orchestrator-orec). Match windows/worktrees by your own campaign slugs only.

## OPEN BACKLOG (not blocking)
finish-script orphan-pane fix (brew-ops handoff 2026-05-31_19-14) · revision-log shared-anchor process-fix (recurring adr.md cascade) · §ADR-18 stale-figure back-refs (5/56 banks, 93+10 — same figures refreshed in §ADR-8/10 via PR #326) · 2 non-mine leftover worktrees (wt-c-teardown has 1 uncommitted file; wt-writer-naming) → brew-ops sweep.
