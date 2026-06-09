# Campaign p2pmode — §ADR-17 RATIFIED (owner GO 2026-06-09)

**next-architect handoff.** Owner resolved ALL open questions and gave GO (2026-06-09). §ADR-17 in `docs/adr.md` is now fully RATIFIED on branch `campaign/p2pmode` (PR #355, commit `f9774e5`).

## What flipped (LIVE status tags only; historical narrative preserved verbatim)
1. **Single-flag §Amendment (TM1–TM7)** — `#provisional` `[RATIFICATION_PENDING:p2pmode]` → **RATIFIED `#decision` (owner GO 2026-06-09)** at the ADR-17 title line, the amendment header, and the Implementation line.
2. **Base §ADR-17 (PM1–PM13 + DP0–DP11)** — "pending ratification thread + design pass" condition SATISFIED (design pass = PR #351, requirement = PR #354). STATUS line + Implementation line `#provisional` → **RATIFIED `#decision` (owner GO 2026-06-09)**.
3. **OQ3 RESOLVED 2026-06-09 = port-now-bind-later** (was "sole remaining open question"): ship the `PayoutRail` port + the ability for the extracted product to bind it now; defer the actual extracted-product binding to the future extraction campaign. OQ1/OQ4/OQ5 dissolved + OQ2 resolved (gateway default `hybrid_enabled = ON`).

## Verification
- 3 `[RATIFICATION_PENDING:p2pmode]` markers removed; doc total 53 → 50. **No other ADR's markers changed** (diff confined to ADR-17 hunks @4087/4180/4200).
- 0 `#provisional` / 0 `[RATIFICATION_PENDING]` remain inside the ADR-17 section.
- PR #355: OPEN, MERGEABLE, NOT merged (owner merges per charter §9). Title updated to reflect ratification.
- Findings file `next-architect_p2pmode_findings.md` updated with a RATIFICATION 2026-06-09 block.

## Downstream (NOT this campaign — next-writer, post-ratification)
- PR #351 (design, `campaign/p2pdesign`) + PR #354 (requirement, `campaign/p2preq`) — both OPEN; the §Propagation set in the amendment governs their edits (single `hybrid_enabled` flag, `PayoutRail` 4th port, pure-floor in-gateway). Out of scope here.

The model: single global boolean `hybrid_enabled`; pure-P2P secondary queue (DP10b) is the always-on FLOOR for `> X`; hybrid override (`ON` → §ADR-8 `withdrawal_queue` bank rail) supersedes it. No both-on band-split, no both-off reject.