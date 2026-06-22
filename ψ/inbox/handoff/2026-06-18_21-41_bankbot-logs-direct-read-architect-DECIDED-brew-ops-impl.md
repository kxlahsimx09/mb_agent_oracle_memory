# Handoff → brew-ops (impl) + orchestrator: `/bankbot-logs` direct-read — ARCHITECT DECIDED ✅

**From:** next-architect · **Date:** 2026-06-18 GMT+7 · **Campaign:** botlogdirectread · **Status:** DECISION MADE — APPROVED; ADR PR open (owner-gated, DO NOT MERGE); brew-ops impl contract below (dispatch only AFTER owner ratifies the ADR PR).
**Upstream:** decision packet `ψ/inbox/handoff/2026-06-18_21-22_bankbot-logs-direct-read-architect-decision.md` (brew-ops) + next-ui ask `ψ/inbox/handoff/2026-06-18_20-46_bankbot-logs-direct-read-brew-ops.md`.

## THE CALL
**APPROVED — reverse §ADR-15 BL6-D (EF-sole-read) → gated direct-read views on the `v_users` projection class; EF RETAINED for `resolve_proof` only.** Owner steer ("lock ด้วย RBAC, ให้ super_admin view ได้คนเดียว") = the gated-projection mechanism; honoured — scope stays super_admin-only. All 4 open decisions resolved; both rollout findings dispositioned.

- **D1 APPROVE** — both BL6-D lock rationales hold without the EF read path (cited *v_payouts leak* = the UN-gated class; the ratified gated-projection fix SV7c-P1/#412 addresses it; proof-signing kept via D3). Recorded as append-only §ADR-15 amendment **DR1–DR6** + revision-log entry + BL6-D forward-pointer.
- **D2 sequencing** — STAGING = **1a** coordinated cut-over (brief empty window OK, non-money read); PROD = **1b** expand→contract (temporary `service_role` OR-branch in the gate — confirmed: service_role fails the in-body gate so the un-amended EF read returns 0 rows mid-cut).
- **D3 realtime** — **2a** drop realtime / keep polling (Postgres-Changes enforces base-table RLS per subscriber → locked base yields no events); **2b REJECTED** (re-opens base-table read); **2c (Broadcast) DEFERRED** to a future slice.
- **D4 RBAC** — `bot-activity-log:view` stays **super_admin-only** (BL8-D reaffirmed; no widening).

## ADR PR (owner-gated — DO NOT MERGE)
- **PR #602** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/602 · branch `campaign/botlogdirectread` off main @ `66d6cdd` · commit `cfef5fa` · `docs/adr.md` ONLY (append-only amendment + revision-log + BL6-D supersede pointer). `#provisional`, ratification = owner-merge (same gate as BL6-D / PR #506).

## brew-ops IMPLEMENTATION CONTRACT (after ratification)
**Migration `20260618xxxxxx_botlog_gated_read_views.sql` (additive, idempotent):**
- `CREATE OR REPLACE VIEW` both `v_bankbot_activity_stream` + `v_bankbot_fleet_now` `WITH (security_invoker=false, security_barrier=true)`, SAME SELECT/join/projection as `20260616000060` (incl. `detail_text`, fleet_now's `DISTINCT ON` + BBOT-013 telemetry cols), add in-body gate `WHERE (SELECT public.auth_aal2()) AND (SELECT public.has_read_perm('bot-activity-log')) AND (SELECT public.auth_db_is_admin())`.
- `GRANT SELECT … TO authenticated`. **Base `bankbot_activity_log` UNTOUCHED** (zero-grant/RLS-locked/append-only). **No RBAC re-seed** (`bot-activity-log:view` already super_admin-only via `20260616000070`).
- Preserve the EXACT column/keyset/filter contract `admin-bankbot-log/reads.ts:62-124` depends on (so the EF keeps working until next-ui repoints).
- **Realtime EXCLUDED** (do NOT touch `supabase_realtime`).
- **PROD (1b):** add a temporary `OR ((SELECT auth.jwt()->>'role') = 'service_role')` to the gate for the cut-over window; remove in a follow-up contract migration. STAGING (1a) ships the pure gate.

**pgTAP `botlog_gated_read_views_test.sql` (mirror `v_users_read_surface_test.sql`):** structural (owner-context, security_barrier set); grants (authenticated SELECT on views, anon none, base zero-grant); behavioral gate (aal2 super_admin+perm → rows; aal1 / non-admin / no-claim → 0 rows; anon → denied). **MUST flip the existing `botlog_bankbot_activity_log_test.sql:82-85`** (views NOT readable by authenticated) to the gated contract in the SAME PR; `:60-63` (base locked) stay green.

**next-ui (separate PR, after grants):** `monitoring-api.ts` `efPost(stream/fleet_now)` → `supabase.from(view)`; `resolveBankbotProof` stays on the EF; `bankbot-logs/page.tsx` keep polling (no realtime). Coordinated cut-over with the migration (1a on staging).

**Premise verification (HEAD `66d6cdd`):** BL6-D `docs/adr.md:4469`; views service_role-only `20260616000060:99-102`; `v_users` mirror `20260617000020:69-101`; `resolve_proof` client-pointer/no-view-read `admin-bankbot-log/index.ts:115-159`; gate helpers `20260611000010:159-222`. Full findings: `next-architect_botlogdirectread_findings.md` (worktree root).
