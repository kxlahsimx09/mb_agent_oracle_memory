---
title: orchestrator — /system-bank end-to-end buildout (campaign family ui-team-bank → 
tags: [orchestrator, team-dispatch, system-bank, mb-next-admin-portal, mb-next-payment-gateway, adr-29, money-material-verify, mint-aal2-jwt-roundtrip, migration-timestamp-collision-stale-base, merge-not-rebase-no-forcepush, next-dev-1-oracle-name-validation, static-rbac-map-gotcha, write-surface, soft-delete, sv7b, accepted]
created: 2026-06-20
source: campaign ui-team-bank → sysbankc family (orchestrator session 2026-06-19/20)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# orchestrator — /system-bank end-to-end buildout (campaign family ui-team-bank → 

orchestrator — /system-bank end-to-end buildout (campaign family ui-team-bank → sysbankbe/ab/c). Drove the admin-portal /system-bank page from "live-but-static read" all the way to a full read+realtime+parity+WRITE surface, deployed to staging + production, across ~14 dispatched teammates under own slugs. Phase shape that worked: investigate (brew-ops readiness ∥ next-architect spec) → build (next-dev) → independent verify (next-tester for money-material / next-pm for done-check) → owner-merge → deploy (brew-ops) → repeat per phase. Phases: A+B portal realtime+parity (#71), ADR-29 plan (#630, 5 docs, D1-D8 open decisions), A+B backend aggregates+detail (#631), A+B portal surface (#72), Phase C write spec (#635), Phase C build 7 verbs (#638), Phase C portal write-UI (#73).

REUSABLE GOTCHAS this run surfaced: (1) team-dispatch-helper.sh now VALIDATES the oracle name against the fleet registry (alias+registry-validate landed mid-session) — bare `next-dev` is REJECTED; the builder oracle is `next-dev-1`/`next-dev-2` (next-dev-1 holds the dev-1 stack slot). (2) MIGRATION-TIMESTAMP COLLISION on a stale branch base — a build branch cut from origin/main at time T, then another campaign merges a migration at the SAME yyyymmddHHMMSS prefix before this PR; the ledger keys on the version prefix so one silently skips. FIX (no force-push): `git merge origin/main` into the branch + rebump your migration files to timestamps ABOVE the current max on main, re-apply + re-verify. The dirty-2-dot `git diff origin/main..HEAD` shows phantom deletions of the newer commits' files — a stale-base artifact, NOT real deletions (a PR uses the 3-dot merge-base diff which is clean). (3) MONEY-MATERIAL write-surface verification: spawn an independent next-tester that MINTS A REAL gotrue aal2 super_admin JWT end-to-end (admin-create → app_user → sign-in → TOTP enroll → challenge → verify) and drives every write EF → 200 + real DB effect + negative sentinels (409/429), then adversarially proves soft-delete-not-hard, SV7b zero-grant (42501 on direct write), no-credential-leak, rate-limit, one-audit-per-write, and (for a reorder) that the order column is NOT consumed by the router. This closed the gap the dev couldn't (the full authenticated round-trip). (4) the static `_shared/rbac.ts` map gotcha for admin EFs (DB seed alone 403s) must be in EVERY write-EF spec.

Owner decisions resolved this run: D1=YES portal write wanted; D4=#22 per-bank MDR NO-BUILD (mobiz confirms MDR is client/txn-scoped, SystemBank struct has no fee field); D5=sync-status a DISTINCT verb; D7=reorder COSMETIC (mobiz confirms bank order is non-routing — sort_order is a dead/write-only field there); D2/D6/D8 took the ADR-recommended conservative defaults.

---
*Added via Oracle Learn*
