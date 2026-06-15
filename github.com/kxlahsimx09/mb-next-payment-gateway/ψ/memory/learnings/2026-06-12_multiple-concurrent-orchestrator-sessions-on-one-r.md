---
title: Multiple concurrent orchestrator sessions on ONE repo+DB generate real collision
tags: [orchestrator, multi-session, migration-collision, territory-allocation, supabase, rate-limit, cross-session, fleet]
created: 2026-06-12
source: orchestrator-buildteam wt-26, thread #16
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Multiple concurrent orchestrator sessions on ONE repo+DB generate real collision

Multiple concurrent orchestrator sessions on ONE repo+DB generate real collisions — allocate territory per campaign, and re-baseline before every migration cut + deploy.

**Observed (2026-06-12, orchestrator-buildteam wt-26 + orchestrator-dev + wt-25, all on kxlahsimx09/mb-next-payment-gateway, shared account):** Running 3 orchestrator sessions in parallel on the same repo + Supabase stacks produced a cascade of collisions:
1. **ADR-10 logic overlap** — buildteam's deposit RM corrective (#436/#438) and orchestrator-dev's payout RM corrective (#440/#441) both edited ADR-10 residual-routing concurrently. Survived ONLY because both converged on the identical Model A pattern (luck, not design); #440 happened to cite #436.
2. **Migration-version collision** — orchestrator-dev's UNMERGED branch build/payout-slice2 deployed payout004 at version 20260612000130 directly to the qnccph SEAL stack; buildteam's #438 merged to main at the SAME 000130. `supabase db push` SILENTLY SKIPS 000130 on qnccph (already recorded as a different migration) → #438 never applies there → stacks fork. Fixed by renumbering #438→000150, v_deposits→000160 above the taken numbers.
3. **Unmerged-code-on-seal** — deploying an unmerged branch's migrations to the seal stack means main and the stack diverge, and the unmerged migrations will collide with main on eventual merge.
4. **Shared-account rate-limits + usage advisory** — 3 sessions × many lanes saturate the API; Anthropic surfaced a usage advisory (37% from 8+hr sessions, 29% subagent-heavy); lanes stall silently mid-action on transient rate-limits (task-list shows ◼ in_progress but the pane is idle — do NOT trust the spinner; verify PR/stack state directly).

**How to apply:**
1. **Allocate territory per campaign up front** when running concurrent orchestrators on one repo: a disjoint migration-version BLOCK (e.g. buildteam 0002xx, payout 0003xx), disjoint ADR sections, ideally disjoint stacks. This is the durable fix; without it collisions recur and you rely on luck (the ADR-10 convergence) to avoid divergence.
2. **Before cutting ANY new migration:** compute max version across main + every unmerged branch + what's actually applied on each stack (schema_migrations), then number ABOVE the highest. A merged-to-main version is NOT safe if another stack already recorded that number for a different migration.
3. **brew-ops re-baselines schema_migrations on BOTH stacks before every deploy** — catches forks before push (this caught collision #2).
4. **Never deploy unmerged-branch migrations to a shared/seal stack** — it forks main↔stack and queues a merge-time collision.
5. **Verify PR/stack state directly, not the lane's task-list spinner** — rate-limited lanes idle silently with stale ◼ markers.

---
*Added via Oracle Learn*
