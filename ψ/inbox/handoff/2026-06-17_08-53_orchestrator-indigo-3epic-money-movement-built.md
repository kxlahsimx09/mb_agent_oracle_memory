# Handoff — orchestrator `indigo`: TOPUP + SETTLEMENT + PULLOUT forward slices BUILT + SEALED + MERGED

**State (2026-06-17):** All three money-movement epics built via the full bias-minimized workflow + merged to main:
- **TOPUP** 001–004 → PR #537 (hardening #535); VERIFY 51/51; investigator-SEALED; DoD-marked.
- **SETTLEMENT** 001/002/003 → PR #542 (#539); 44/46 (2 honest SKIP); SEALED (client+partner); marked.
- **PULLOUT** 001/002/003/004 → PR #547 (#544); 126/126; SEALED (no-wallet held); marked.
Tester `yupsev` + seal `qnccph` now at **main@HEAD** (drift remediated; bot-queue-mark e2e satisfiable). All ~19 campaign worktrees cleaned.

**Retro:** `ψ/memory/retrospectives/2026-06/17/08.52_orchestrator-indigo-3epic-money-movement-build.md`

**OUTSTANDING:**
1. **Owner-merge PRs #548** (DoD marks + settlement 40001→P0001 doc-fix) + **#549** (regression probe suites) — open.
2. **§ADR-21 LIVE gates** — TOPUP + source-flows each need a LIVE journey authored/run + **owner `live_signoff` ACCEPT** for epic-DONE (no journey defined for the 3 new epics; joins the 4-core-epic L5 backlog).
3. **🔴 main migration version COLLISION `20260616000040`** — `topup_apply_not_found_404.sql` (applied) vs `v_users_read_surface.sql` (can never apply; fresh `db push` from main aborts there). Rename v_users to a unique version + re-apply. Blocks fresh provisioning.
4. bot-queue-mark e2e leg can now be run on the current stacks to close the settlement+pullout honest-SKIP.

**Awaiting owner:** merge #548/#549; the 3 `live_signoff` ACCEPTs; decision on the #20260616000040 rename owner.
