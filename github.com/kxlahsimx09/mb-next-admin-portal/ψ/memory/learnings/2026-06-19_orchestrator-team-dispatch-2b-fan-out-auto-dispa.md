---
title: orchestrator team-dispatch (2b fan-out, AUTO-dispatched, accepted) — UI-wiring c
tags: [orchestrator, team-dispatch, 2b-fanout, accepted, ui-team-bank, mb-next-admin-portal, system-bank, realtime, polling, supabase-realtime-base-table-leak, v_system_banks, architect-self-ping-idle-loop, kill-respawn, next-architect, brew-ops, next-dev, next-pm]
created: 2026-06-19
source: campaign ui-team-bank (orchestrator session 2026-06-19)
project: github.com/kxlahsimx09/mb-next-admin-portal
---

# orchestrator team-dispatch (2b fan-out, AUTO-dispatched, accepted) — UI-wiring c

orchestrator team-dispatch (2b fan-out, AUTO-dispatched, accepted) — UI-wiring campaign `ui-team-bank`: wire the admin-portal `/system-bank` page to realtime + bring UI to parity with the `kokarat/clone_maxpay_frontend` reference. Flow that worked: brew-ops (backend realtime readiness) ∥ next-architect (realtime ADR + UI-parity gap spec) → next-dev (build) → next-pm (independent done-check). Result: PR #71 (poll-realtime + 8 in-scope parity items), pm verdict PASS, mergeable.

KEY TECHNICAL FINDING (brew-ops, reusable for ALL portal pages reading masked views): Supabase Realtime `postgres_changes` on a SENSITIVE base table (`bank_account`) is INCOMPATIBLE with the leak-safe view design — Realtime streams the BASE-table row (no column filtering), so it leaks columns the `v_system_banks` view deliberately withholds (e.g. `bank_credentials_secret_id` vault pointer), and enabling it requires re-opening the SV7b zero-grant (which also exposes the base table over REST). ⇒ For a page that reads a masked/projection view, the leak-safe realtime path is CLIENT-SIDE POLLING of the existing read (~12s, paused on tab-hidden), NOT postgres_changes. True server-push would need a broadcast-from-trigger emitting only projected columns (separate ADR + owner gate).

ORCHESTRATION GOTCHA (reusable): the FIRST next-architect spawn wedged in a self-ping idle loop — it used an Explore SUB-AGENT on a 4810-line reference and then cycled `Teammate @next-architect came to rest / Idle / 2s-churn` forever, writing NOTHING to disk. Fix: `tmux kill-pane` the wedged teammate + re-spawn fresh with a directive to (a) read the files DIRECTLY with Read (no Explore/sub-agents), (b) WRITE the deliverable files FIRST, (c) all decision inputs pre-loaded in the prompt so it does not re-investigate. Fresh re-spawn reads mailbox standing-orders, not the wedged in-memory session, so context is clean. Also: a 97% weekly shared-quota warning surfaced mid-campaign in a teammate pane — flagged to owner, owner cleared it; close idle teammates immediately (kill-pane) to stop quota burn.

---
*Added via Oracle Learn*
