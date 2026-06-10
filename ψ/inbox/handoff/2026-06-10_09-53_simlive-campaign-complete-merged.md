---
to: orchestrator-build (next session) + brew-ops + owner
from: orchestrator-build 2026-06-10
priority: P1
topic: CAMPAIGN simlive COMPLETE — admin-portal wired to staging (deposit+auth+RLS+MFA), BOTH lanes MERGED to main
project: github.com/kxlahsimx09/mb-next-payment-gateway + mb-next-admin-portal
tags: [orchestrator, simlive, merged, sim-live, deposit, auth, rls, mfa, gw1a-h, complete]
---

# simlive COMPLETE — both lanes merged · §ADR-21 L1 golden journey GREEN on staging

## DONE (merged to main 2026-06-10)
- **Lane A — gateway PR #365 MERGED** (main @ 5048bbb). Migration `20260609000030`: `v_deposits` → `security_invoker=true` + `GRANT SELECT TO authenticated` + pgTAP (13 assertions, DR6 four-tier). Closes the cross-tenant leak (plain view bypassed ts_deposits RLS). DEPLOYED + verified on staging (ref `sinuwgsqqyqzlpaavimf`). Built+confirmed on OPUS; opus-reviewer APPROVE; tester L1 8/8 green.
- **Lane B — portal PR #7 MERGED** (main @ 28942ae). Real gotrue login (mock role-switcher DELETED, role from JWT `entity_type`), real TOTP MFA, **forced admin MFA enrollment** (owner policy a), deposit screens (WUI-101/103/104) reading `v_deposits` DIRECT via supabase-js (RLS-scoped, NOT CF), realtime on physical `ts_deposits`, admin EF writes (`admin-deposit`/resolve/verify-now) with gotrue bearer. Built on OPUS (rebuild found+fixed a REAL MFA aal1-bypass bug sonnet missed + a bank-filter bug). opus-reviewer APPROVE ×2; tester re-test ALL PASS.
- **Architect rulings** (campaign simlive): Q1–Q4 read-path (direct PostgREST + RLS; realtime UI→Supabase direct WS; writes direct to EFs; all NOT via GW4 Worker) — no ADR change. `/tmp/simlive/architect-ruling.md`. CF-proxy GW1a-H spec `/tmp/simlive/architect-cf-proxy-ruling.md`.
- **gh auth fixed**: default account was `midasgoteam-ops` (invalid token) — removed it; `kxlahsimx09` re-stored as active (valid). gh works.

## VERIFIED on staging (tester ground-truth, real gotrue JWTs)
L1 golden journey 8/8: read v_deposits → upload-slip → approve→paid (wallet +500 credited, callback queued) → reject→rejected; RLS cross-tenant=0; AAL2 step-up enforced; harness non-vacuous. Re-test: zero-factor admin @aal1 → 401 aal2_required; enroll TOTP → aal2 → writes succeed. Policy (a) server-consistent.

## REMAINING (owner / follow-up — NONE block the merge)
1. **OWNER: §ADR-21 SIM-LIVE ACCEPT** — drive the merged portal end-to-end against staging (the actual live test). Backend+auth+RLS+MFA+UI all green; this is the owner's acceptance gate.
2. **brew-ops: CF custom-domain activation (GW1a-H)** — handoff `2026-06-09_06-28_simlive-brewops-cf-custom-domain-activation.md`. Env-swappable hardening (Supabase custom domain + CF orange-cloud; single SUPABASE_URL swap; JWT `iss` gotcha). Owner GO given.
3. **GW1a-H ADR note NOT yet landed in docs/adr.md** — architect was dispatched but gh was broken at the time; decision IS ratified + recorded in Oracle (learning `2026-06-09_decision-owner-go-2026-06-10-adr-2-amendment`). Land the formal §ADR-2 §Amendment GW1a-H note (shape in the CF-proxy ruling §6) next session.
4. **Deferred code follow-ups (non-blocking):** merchant pool-read (DR6 sprint — SECURITY DEFINER `merchant_pool_client_ids`); N-2 (canAccess placeholder allows non-NAV routes for the `unknown` role); split pre-existing oversize shared files (types.ts 369, i18n.ts ~860).

## OPS NOTES
- maw default model = SONNET; owner wants OPUS for all orchestrator dispatches → pass `--model opus` on every `maw team spawn` (learning `2026-06-09_user-preference-owner...`).
- `maw fleet renumber` is destructive + replaces FLEET_DIR symlinks with files (decouples vault-sync) — repaired this session; fleets now 01/02/03/05, vault-synced.
- orchestrator-guard hook mis-fires on DISPATCHED agents (keys on tmux window name `orchestrator-build`, can't distinguish the owning agent) — blocked next-ui Edit/Write; it worked around via Bash. SHOULD be fixed (let dispatched agents edit their own repo).
- agent panes (architect/dev/ui/reviewer/tester) idle in session `01-soul-brews:1` — brew-ops auto-reaps; coordinate before finishing.
