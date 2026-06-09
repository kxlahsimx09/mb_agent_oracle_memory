---
to: orchestrator (next session)
from: orchestrator 2026-06-07
priority: P1
topic: epic-wallet-ledger 4-lens review COMPLETE → 2 PRs PENDING USER MERGE; continue 4-lens on the next epic
---

# epic-wallet-ledger 4-lens pre-dev review — COMPLETE (2026-06-07)

First round with the NEW 4th lens (next-ui) added to the established 3. The full arc ran end-to-end: review → dpay-verify → user-ratify → staged fix → 2 PRs.

## OUTPUT — 2 PRs OPEN, PENDING USER MERGE (do not merge without user GO)
- **PR #338** (campaign/walletfix) — `docs/adr.md` only — §ADR-10 §Amd 2026-06-07 (WO1 owner-model / CB1–CB5 mdr_clawback substrate / SA1 signed-add-only / RX1 Phase-1 read) + §ADR-13 §Amd 2026-06-07 (WR1–WR3 read-surface existence).
- **PR #339** (campaign/walletfix-epic) — `epic-wallet-ledger.md` + `INDEX.md` + `glossary.md` — WALLET-007..012 added + A–G reconciliations.
- **MERGE ORDER: #338 (adr) FIRST**, then #339 (epic cites the §Amd 2026-06-07 anchors). DISJOINT files → no conflict; the order is logical (cross-ref resolution), not a cascade.

## What was ratified (user GO 2026-06-07) — detail in the 2026-06-07 learning + /tmp/walletreview/RATIFIED-decisions.md
A residual-routing doc-faithfulness (RM1/RM2/R1) · B owner-model=owner_type=partner+is_owner (drop `system`) · **C port-full mdr_clawback** (payout+topup+deposit-refund; INPUT=reconstruct-from-change-log) · **D signed-add-only** (cut set/subtract/freeze/unfreeze) · E read-surface existence + WALLET-001 Phase-1 · **F HIGH-5 UI stories** WALLET-007..011 (MED/LOW deferred) · G quality fixes. Plus WALLET-012 = clawback substrate (Theme-C epic home).

## KEY dpay PROD findings (grounded the C/D decisions, as-of 2026-06-07)
Live collection = `wallets_change_logs` (4.67M docs; a decoy `wallet_change_logs` singular has 4 test docs — verify-don't-assume). Reverse-MDR clawback LIVE: mdr_distribution_reversed 309× (last 2026-06-06), mdr_distribution_cancelled 10×, deposit_refund_debit 7×. Admin: add 5,353× (always-positive), subtract/set 0×.

## PATTERN PROVEN (carry to next epics)
- 4 lenses parallel read-only (architect=ADR-consistency · pg-writer=current-mobiz-parity · next-writer=internal-quality · next-ui=operator/client UI buildability). next-ui adds real value — found 5 HIGH UI-story gaps the backend lenses missed.
- dpay verify via FRESH teammate (brew-ops, mcp__dpay__* direct; NOT the dpay-finder subagent; ground op-strings in Go first). Saved the C/D decisions from guessing.
- Staged fix: architect adr.md PR + writer-spec → ORCHESTRATION-CATCH (orchestrator reads adr+spec before writer applies) → writer epic+INDEX+glossary PR on a SEPARATE campaign (disjoint files). team-dispatch-finish.sh --merge preserves *_findings.md to ψ/memory/mailbox/ then removes worktrees; finish leaves ORPHAN windows → kill by name (next-<role>-<campaign>), never by index, never touch nextteam/dep8.
- team-dispatch-helper TUI-readiness almost always hits the 45s timeout-fallback for these spawns; ALWAYS peek the pane to confirm the kickoff landed (next-writer once needed a re-send: it summarized in-pane + "notified team-lead" instead of writing its findings file — re-send "write the FILE, I collect the file not the chat").

## NEXT ROUND — 10 epics still un-deep-reviewed
callback-delivery · topup · monitoring · statement-matching · admin-audit · bot-dispatch · fleet-control · entity-provisioning · source-flows · client-api. Recommend callback-delivery or topup next (topup now has open ties: WALLET-012 references a topup-cancel trigger story the topup epic must own; the topup MDR fan-out feeds WALLET-003). CONFIRM target with user before dispatching. Reuse the 4-lens+dpay+staged-fix pattern above.
