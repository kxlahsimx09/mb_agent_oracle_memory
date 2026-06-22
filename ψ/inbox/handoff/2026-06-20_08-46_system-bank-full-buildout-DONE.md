## /system-bank FULL BUILDOUT — DONE + LIVE (orchestrator, 2026-06-19/20)

The admin-portal `/system-bank` page is now **complete end-to-end**: live realtime read + UI parity + full WRITE surface, deployed to staging sinuw + production. Live: https://mb-next-admin-portal.vercel.app/system-bank

**Merged + deployed PRs:**
- admin-portal #71 (realtime polling + 8 parity items), #72 (A+B surface: daily out/amount + detail modal), #73 (Phase C write-UI: 7 actions) — all merged + Vercel prod (app is CLI-only deploy).
- gateway #631 (A+B aggregates + leak-safe detail view), #638 (Phase C 7 write EFs + RPCs) — merged + targeted-deployed to sinuw.
- gateway #630 (ADR-29 plan, owner-gated DO NOT MERGE), #635 (Phase C spec, owner-gated).

**Verification high-water:** Phase C money-material tester minted a real aal2 super_admin JWT and drove all 7 write EFs → 200 + real DB effect + adversarial security audit = ALL PASS. A+B detail-view no-credential-leak = pgTAP TEETH + independent pm audit.

**Owner decisions on record:** D1=YES(write wanted) · D4=#22 NO-BUILD(no per-bank MDR) · D5=distinct sync-status verb · D7=reorder COSMETIC · D2/D6/D8=ADR defaults.

**OUTSTANDING (small, owner-optional):**
1. A+B indicator shows amber "polling" not green "live" (deliberate; ~3-line tweak if wanted).
2. #23 sync-status reuses the `force_refresh_config` bot command (no dedicated heartbeat verb in the fleet_command_log enum) — a true `status_sync` command would need an enum widen + bot change.
3. Read-order side-effect: dropped the client `.order()` so the view's sort_order governs (reorder visibility) → no-order banks now sort created_at-ASC.
4. Phase D #21 Pools = deferred to a separate routing-admin surface (owner D3).

All teammate campaigns closed; no surviving procs. Learnings filed (migration-collision/merge-rebump, money-material aal2-JWT verify, next-dev-1 registry validation, static rbac.ts map).