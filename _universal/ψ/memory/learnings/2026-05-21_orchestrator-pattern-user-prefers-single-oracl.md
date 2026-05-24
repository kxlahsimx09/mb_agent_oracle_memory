---
title: **orchestrator pattern — user prefers single-oracle-per-role over spawn-parallel
tags: []
created: 2026-05-21
source: parent campaign thread #189 P2P + sub-thread #191 brew-ops cancel — user explicit guidance 2026-05-21 ~16:20-16:30 GMT+7
---

# **orchestrator pattern — user prefers single-oracle-per-role over spawn-parallel

**orchestrator pattern — user prefers single-oracle-per-role over spawn-parallel; architect-serial accepted as constraint (2026-05-21)**

Incident: Track A Cycle 3 (mobiz amendments #4+#5) + #189 P2P amendment campaign both needed next-architect attention. Original dispatch (#190 P2P) was queued behind Cycle 2 + Cycle 3 per architect-serial constraint. User surfaced concern that P2P was waiting, picked **Option B (spawn parallel architect session)** to enable true-parallel work.

Brew-ops dispatch (#191) to spawn `next-architect-p2p-oracle` ran ~100 min with no final reply (slow + opaque). While waiting, orchestrator redirected P2P to existing architect (#190 msg 768) — architect was idle anyway (Cycle 2 fan-out is impl + writer not architect; Cycle 3 not yet dispatched). Architect drafted §D in 23 min (PR p2p-hub#6 + PR mb-next-payment-gateway#212).

User then explicitly cancelled #191: **"สรุปว่า next-architect-p2p-oracle ไม่ได้ใช้ใช่ไหม ลบออกไปได้เลยนะ"** + **"ผมว่าไม่ควรมี oracle ใหม่แหละ ใช้ architect เดิมนี่แหละนะ"**.

## Durable rule

**Default to architect-serial via existing oracles. Do NOT spawn parallel oracle instances of the same role unless there's an explicit, repeated user request to do so + sustained throughput demand that single-oracle-can't-meet.**

Rationale (extracted from this incident):
1. **brew-ops spawn dispatch is slow + opaque** — fleet topology changes take significant time + brew-ops doesn't surface partial progress well. Cleanup overhead is non-trivial (inbox dirs, tmux windows, worktrees, fleet config, watcher state — 6 cleanup items in this incident).
2. **Architect-serial cost is often illusory** — original architect is frequently idle between cycles (e.g., during fan-out impl + writer PRs awaiting user merge). What looks like "blocked by serial constraint" is often "no actual work to do RIGHT NOW because gated on prior PR merges anyway".
3. **State management complexity** of parallel oracle instances (routing, watcher state per-session, merge-conflict surface on shared files like `docs/adr.md`) outweighs the parallelism benefit for most campaigns.
4. **Simpler mental model** — one role = one oracle. Cleaner mapping when reasoning about state, queue, ownership.

## How to apply

When orchestrator faces "campaign X needs architect, architect is busy on campaign Y":

1. **First check: is architect ACTUALLY busy right now?** Often the answer is no — architect is idle waiting for impl/writer/user PR merge. Dispatch the new campaign to existing architect immediately; serial happens naturally as work completes.
2. **If genuinely busy: queue and tell user the queue position + estimated time-to-pickup.** Don't reach for parallel spawn as default.
3. **Spawn parallel oracle ONLY when:**
   - User explicitly asks (with awareness of complexity cost)
   - Sustained throughput demand evident from history (3+ instances of blocking)
   - The campaigns share NO common files (no merge-conflict surface)
   - Brew-ops can deliver spawn within reasonable SLA (~15 min)
4. **If spawn dispatched, set a timer.** If brew-ops doesn't reply within 30 min, fall back to single-architect serial — don't keep waiting. The cost of stuck-spawn dispatches accumulates.

## Companion lesson — brew-ops SLA observation

This is the second incident in recent campaigns where brew-ops dispatch took longer than expected (#180 bot.sh fix was reasonable; #83 gc-sweep liveness was reasonable; #191 spawn parallel architect = 100+ min no reply). Pattern: **fleet topology changes are slower than fleet hygiene/fix dispatches**. Worth surfacing to brew-ops as feedback when next interacting with them about their dispatch cadence on multi-step ops.

## Anti-pattern recorded

DON'T: spawn parallel oracle instances reflexively when single-instance encounters a queue. Spawn = topology change = ops complexity. Architect-serial via existing oracle is the sensible default.</pattern>
<parameter name="concepts">["orchestrator", "decision-authority", "fleet-topology", "single-oracle-per-role", "architect-serial", "spawn-parallel-anti-pattern", "brew-ops-sla", "redirect-while-waiting", "cancel-without-completion", "campaign-189", "thread-191"]</parameter>
<parameter name="project">github.com/Soul-Brews-Studio/arra-oracle-v3

---
*Added via Oracle Learn*
