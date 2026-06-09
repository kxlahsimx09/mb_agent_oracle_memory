---
title: ORCHESTRATOR OWNS dev-N STACK-SLOT ALLOCATION (dispatch-time). When dispatching 
tags: [orchestrator, dispatch, dev-slot, stack-allocation, next-dev, collision-avoidance, build-workflow, verification]
created: 2026-06-09
source: orchestrator-build 2026-06-09 (owner directive)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ORCHESTRATOR OWNS dev-N STACK-SLOT ALLOCATION (dispatch-time). When dispatching 

ORCHESTRATOR OWNS dev-N STACK-SLOT ALLOCATION (dispatch-time). When dispatching a next-dev agent, the orchestrator MUST explicitly assign which dev-N stack slot it uses — never leave the agent to guess. Role→slot mapping: next-dev-1 → .secrets/slots/dev-1.env, next-dev-2 → dev-2.env, next-dev-3 → dev-3.env. State it in the dispatch prompt, and make clear the dev stack is a REMOTE Supabase project (DB schema is live; deploy via `supabase db push` over the IPv4 session pooler aws-1-ap-southeast-1.pooler.supabase.com:5432 with SUPABASE_DB_PASSWORD; test gates/RPCs DIRECTLY via service-role SQL / Management API — EFs may be absent but gate/RPC logic is SQL-testable), NOT a local container.

WHY: As dev-2/dev-3 come online and run in parallel, two devs sharing one dev-N stack clobber each other's db-push / migration / probe state. Slot allocation = collision avoidance = the orchestrator's job (it owns who-runs-where). Keep a per-wave slot ledger; never double-assign one slot to two concurrent live devs. (As of 2026-06-09 only dev-1 exists; the discipline matters the moment dev-2/3 land.)

TRIGGERED BY (2026-06-09, campaign audfix): next-dev-1 reported "Verify blocked — no container runtime (docker/colima/podman absent), no local Supabase/Postgres/.env" and punted verification to brew-ops, when in fact dev-1.env points to a live remote stack (verified: ts_deposits + check_admin_slip_upload_gate + 106 migrations present; 0 EFs). The dev wrongly looked for a LOCAL container instead of using its remote dev-1 slot. Two fixes followed: (a) next-dev SKILL gets a "Your verification stack" section; (b) THIS rule — orchestrator assigns the slot at dispatch. Companion to the build-workflow line "next-dev deploys to ITS OWN dev-N stack".

---
*Added via Oracle Learn*
