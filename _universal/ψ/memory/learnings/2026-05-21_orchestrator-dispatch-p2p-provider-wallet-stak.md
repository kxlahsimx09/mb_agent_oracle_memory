---
title: **orchestrator dispatch — P2P provider-wallet stake-before-match settlement camp
tags: []
created: 2026-05-21
source: parent campaign thread #189 P2P (sub-threads #190 + #191 + #195 closed 2026-05-21; 4 PRs merged: p2p-hub#6 + mb-next#212 + mb-next#213 + p2p-hub#7)
---

# **orchestrator dispatch — P2P provider-wallet stake-before-match settlement camp

**orchestrator dispatch — P2P provider-wallet stake-before-match settlement campaign closed (#189, 2026-05-21)**

Request: user surfaced (2026-05-21 ~13:00 GMT+7) that current p2p-hub design (Phase A/B/C ratified at thread #148) doesn't address wallet/settlement mechanics for inter-gateway settlement after P2P match. Direct quote: *"ผมอยากให้มันมี wallet เงิน ของแต่ละ provider ที่จะเข้ามา ... ต้องมี การ วางเงินไว้ใน wallet ก่อน เพื่อ จะได้เอา settle กันทันที"*. Reverses §ADR-16's `p2p-orthogonality-confirmed` Phase-2 prediction (orthogonality CLAIM itself unchanged — clarification not reversal per architect's state-grounding).

Classification: **2b-fan-out cross-repo** (architect → user ratify → impl + adapter-ADR-deferred; spans p2p-hub repo + next-system repo).
Confidence at dispatch: **MEDIUM-HIGH** (precedent: V13+V14 / Track B amendment cadence applies; new dimension = cross-repo).

Sub-thread structure under parent #189:
- #190 architect §D amendment (drafted → user redirect on §D2 single-wallet + Q-D1 mobiz-port → revised → ratified → 3-commit single-branch pattern on p2p-hub#6 + 3-commit merge-as-draft on mb-next#212 → backfill via #213)
- #191 brew-ops spawn parallel architect session (CANCELLED — anti-pattern; user correction below)
- #195 next-impl substrate bootstrap (orchestrator-decided default bundle 1A+2A+3A+4A; 12/12 PASS, ~34 min vs 6-10h estimate)

**4 PRs merged total:**
- p2p-hub#6 (architect §D body) — clean 3-commit merge `1323e14`
- mb-next-payment-gateway#212 (companion §ADR-16 annotation) — merged-as-draft `be73873` (only draft commit landed; revision + flip never made it)
- mb-next-payment-gateway#213 (backfill marker-flip for #212) — `bff42f3`
- p2p-hub#7 (substrate-bootstrap) — clean merge with 12/12 hosted assertions PASS

User reaction: **accepted** with substantive mid-stream redirects (single-wallet collapse + mobiz-port topup mechanism). No rejection at any stage.

## 5 substantive incidents filed to pattern library this campaign

### Incident 1 — orchestrator over-applied architect-serial constraint, reached for brew-ops spawn

Initially queued #190 P2P behind Track A Cycle 2 + Cycle 3 per perceived architect-serial constraint. When user surfaced concern that P2P shouldn't wait, jumped to "spawn parallel oracle" path via brew-ops #191. Wrong on two counts:
- Architect-serial was self-imposed (merge-conflict avoidance), not infra-imposed
- Spawning new role (`next-architect-p2p-oracle`) is anti-pattern; existing role + multiple sessions IS supported by watcher

User corrections:
- "ผมยังอยากให้มี parallel session แต่ไม่ต้องเพิ่ม oracle ได้ไหม" — clarified parallel-sessions-same-role wanted; new role rejected
- Subsequent learning + supersede: `learning_2026-05-21_orchestrator-pattern-parallel-sessions-of-same` supersedes earlier conflated learning

**Durable rule established:** dispatch in parallel to existing role; watcher auto-spawns sessions via `parent_session`. Never spawn new role for parallelism. Single-oracle-per-role + multi-session-via-watcher.

### Incident 2 — brew-ops SLA on multi-step topology change

brew-ops #191 spawn took ~2h with no progress reply; orchestrator did cleanup directly after user cancel. Pattern observation: brew-ops multi-step fleet topology dispatches consistently slower than fix/hygiene dispatches. Orchestrator should set ~30-min timeout falling back to single-architect serial.

### Incident 3 — orchestrator redirect-while-waiting pattern (saved P2P)

While brew-ops #191 dragged, orchestrator redirected #190 P2P to existing architect (idle anyway — Cycle 2 fan-out was impl + writer, not architect). Architect drafted §D in 23 min. Pragmatic: don't keep waiting on slow infra dispatches when work can move on existing sessions.

### Incident 4 — merge-as-draft pattern instance #2 (#212 → #213)

mb-next#212 merged by user with only original draft commit (`8a06076`); architect's revision (`f8772df`) + marker-flip (`ddf984d`) commits authored after the merge never landed. Same shape as PR #208 → PR #209 backfill (Cycle 2). Backfill PR #213 + 1/-1 line restored revision + marker-flip atomically. Pattern instance #2 of merge-as-draft → backfill marker-flip (instance #1 = #208 → #209).

### Incident 5 — parallel-sessions-same-role demonstrated working

Cycle 3 dispatch (#194) routed to same `for-next-architect/` inbox while #190 P2P backfill (#213 dispatch) was in flight. Watcher auto-spawned separate session for #194 routing. Both sessions reported back independently on threads (architect msg 793 from parallel session drafted PR #214; this-session-architect sent courtesy ACK msg 793 ACK). End-to-end demonstration that multi-session same-role parallelism works without any topology change.

## Reusable cross-repo dispatch observations

- **Different repos = zero merge-conflict surface** — architect-serial constraint doesn't apply across repos. P2P (p2p-hub) + Cycle 3 (next-system) genuinely parallel.
- **next-impl ran substrate-bootstrap in ~34 min vs 6-10h estimate** — greenfield bootstrap with clear architect spec executes fast when pre-flight is solid (architect's §D had schema + RPC pseudocode pinned).
- **mobiz-port pattern (Q-D1 topup mechanism)** worked end-to-end on first cycle — architect grep'd mobiz `controllers/TopupController.go` for verbatim shape, impl matched line-by-line. 0 SQLSTATE 42725 events (DROP-then-CREATE preemptive rule from V13+V14 lesson applied correctly).
- **PI-5 narrowing (custodial WRT provider funds)** is the load-bearing reframe of this campaign — `needs-legal-counsel` flag in p2p-hub §Q7/§B11.4 strengthens. Worth surfacing again before any production deploy.

## Pattern instances logged this campaign

- §H3-Fix bundled-inline-correction (Track B precedent reused for §D documentation)
- Single-branch marker-flip instance #4 (p2p-hub#6)
- Merge-as-draft → backfill marker-flip instance #2 (#212 → #213)
- Mobiz client-topup port instance #1 NEW for p2p-hub
- §ADR-10 wallet primitive instance #2 (strictly simpler than next-side — no `owner_type`, no `purpose`)
- §ADR-10 AM2 freeze-settle instance #2
- §ADR-10 AM3 audit instance
- §ADR-10 Decision #5 lock-order canon instance #3
- §ADR-4b finalize_deposit thin-RPC for `settle_p2p_match`
- **NEW pattern:** "P2P stake-before-match settlement" instance #1
- **NEW pattern:** parallel-sessions-same-role via watcher auto-spawn (demonstrated end-to-end this campaign)
- spawn-new-role-for-parallelism = ANTI-PATTERN (confirmed via #191 cancel)

## Deferred to future cycle

- **next-system adapter ADR** — the `next`-side L2 handler that consumes p2p-hub `MatchSettled` event + translates to client wallet via `finalize_deposit_p2p` / `finalize_payout_p2p` thin-RPC variants. Deferred until a `next` integration with p2p-hub is scheduled.
- Partner-MDR distribution in p2p-hub topup (no partner structure Phase-1)
- PI-3 outbound-message dispatcher process (rows enqueue; dispatcher = impl-pass-2)
- §ADR-13 F1-F4 admin-tier JWT check in EF (Phase-1 accepts any valid bearer + X-Approver-Email; tightening = follow-up)
- [STUB] supporting tables (providers, matches, outbound_messages) — minimal stubs for substrate-bootstrap; expansion = future architect-pass</pattern>
<parameter name="concepts">["orchestrator", "decision-authority", "2b-fan-out-cross-repo", "accepted", "p2p-hub", "provider-wallet-stake-before-match-settlement", "campaign-189", "mobiz-client-topup-port", "merge-as-draft-incident-2", "parallel-sessions-same-role", "spawn-new-role-anti-pattern", "redirect-while-waiting", "brew-ops-sla-multi-step", "PI-5-custodial-narrowing", "cross-repo-no-merge-conflict", "preemptive-drop-create-rule-applied"]</parameter>
<parameter name="project">github.com/Soul-Brews-Studio/arra-oracle-v3

---
*Added via Oracle Learn*
