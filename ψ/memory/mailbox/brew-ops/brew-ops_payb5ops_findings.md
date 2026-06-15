# brew-ops — PAYOUT slice-5 (FINAL, correction toolkit) CROSS-STACK DEPLOY findings

**Campaign:** payb5ops · **Date:** 2026-06-13 · **Role:** brew-ops (sole deploy owner, AGENTS.md §11a / PR #470)
**Delta:** PR #477 · `build/payout-slice5` @ `ad3c43b` · **Targets:** TESTER (`yupsev`/`yupsevcrubgprsbujbpu`) + INVESTIGATOR-seal (`qnccph`/`qnccphgykzdydebmdwdf`)
**Deploy source:** fresh **detached** worktree at `origin/build/payout-slice5` (`ad3c43b`) → `mb-next-payment-gateway.wt-brewops-payb5src` (NOT the dev worktree, NOT dev-1).

## 0. TL;DR — **GREEN on BOTH stacks. Stack-ready for payb5t probes.**

The slice-5 delta (1 migration `…20260613000010` building 3 SECURITY DEFINER RPCs + 2 admin EFs) is deployed and **per-item verified GREEN on both `yupsev` and `qnccph`**. The sealed cross-boundary set (`mark_success` / forward MDR fan-out / `match_payout_statement`) is **byte-identical pre/post deploy** (md5 unchanged) — no slice-1/bbot seal re-opened. Cross-lane #463 (SV8 re-close) + #470 (deploy-policy) carry **no conflict**. **One NON-BLOCKING durability item:** the `config.toml` registration was made in the deploy source and used for this deploy, but is **not yet committed to `build/payout-slice5`** (only brew-ops can add it per the deploy-env-guard; the dev was blocked) — see §5.

## 1. Deploy method (per `docs/runbooks/edge-function-deploy.md`)

- **Migration** — `supabase db push --db-url <IPv4 session pooler> --yes` from the fresh checkout (`--workdir`). Pooler `aws-1-ap-southeast-1.pooler.supabase.com:5432`, user `postgres.<ref>`, URL-encoded DB password. Dry-run first confirmed **exactly one** pending migration per stack.
- **Edge Functions** — `supabase functions deploy <fn> --project-ref <ref> --no-verify-jwt` from the fresh checkout (PAT-authed via slot `SUPABASE_ACCESS_TOKEN`). config.toml `verify_jwt=false` present in the deploy source for both new EFs.
- **Verification** — read-only `psql` over the pooler + `curl` against the live EF endpoints + Supabase Mgmt-API status.

## 2. Pre-deploy state (confirmed before applying)

| Check | tester (yupsev) | investigator (qnccph) |
|---|---|---|
| Migration HEAD before | `20260612000260` | `20260612000260` |
| `…000010` present before | no (0) | no (0) |
| 3 new RPCs present before | **0 (greenfield confirmed)** | **0 (greenfield confirmed)** |
| `mark_success` md5 (baseline) | `65ed78f1eeeaad98d3b2563b1f809bb0` | `65ed78f1eeeaad98d3b2563b1f809bb0` |
| `match_payout_statement` md5 (baseline) | `d0abcef738561c5730f4804231a31649` | `d0abcef738561c5730f4804231a31649` |

Forward MDR fan-out: **no separate function** matches `mdr|distribute|fanout` at HEAD → the forward fan-out is **inline inside `mark_success`** ⇒ covered by the `mark_success` fingerprint above.

## 3. PER-STACK VERIFICATION CHECKLIST — all GREEN

Both stacks returned identical results for every item.

| # | Item | tester | investigator |
|---|---|---|---|
| **V1** | migration `20260613000010` in `schema_migrations` | ✅ GREEN | ✅ GREEN |
| **V2a** | `admin_correct_payout(uuid,uuid,text,text,text)` present, `SECURITY DEFINER`, plpgsql | ✅ GREEN | ✅ GREEN |
| **V2b** | `admin_reverse_settle_payout(uuid,uuid,text,text)` present, `SECURITY DEFINER` | ✅ GREEN | ✅ GREEN |
| **V2c** | `mdr_clawback_fanout(text,uuid,text)` present, `SECURITY DEFINER` | ✅ GREEN | ✅ GREEN |
| **V2-ACL** | SV8-tight: EXECUTE grantees = `{postgres(owner), service_role}` — **NO PUBLIC / anon / authenticated** (all 3 fns) | ✅ GREEN | ✅ GREEN |
| **V3a** | `admin_correct_payout` body **PERFORMs `mark_success`** (delegates, not reimplemented) | ✅ GREEN | ✅ GREEN |
| **V3b** | `admin_reverse_settle_payout` writes `payout_reverse_settle` **AND** calls `mdr_clawback_fanout(` | ✅ GREEN | ✅ GREEN |
| **V4a** | `mark_success` md5 == baseline (`65ed78f1…`) — **UNCHANGED / sealed** | ✅ GREEN | ✅ GREEN |
| **V4b** | `match_payout_statement` md5 == baseline (`d0abcef7…`) — **UNCHANGED / sealed** | ✅ GREEN | ✅ GREEN |
| **V5a** | EF `admin-payout-correct` reachable (NOT 404): `GET→405`, `POST no-bearer→401`, `POST garbage→401 {"error":"invalid_token"}` | ✅ GREEN | ✅ GREEN |
| **V5b** | EF `admin-payout-reverse-settle` reachable (NOT 404): `GET→405`, `POST no-bearer→401`, `POST garbage→401 {"error":"invalid_token"}` | ✅ GREEN | ✅ GREEN |
| **V5-API** | Mgmt-API: both EFs `status=ACTIVE`, `verify_jwt=false`, `version=1` | ✅ GREEN | ✅ GREEN |
| **V6** | `mdr_owner` residual wallet exists (`owner_type='mdr_owner'`, id `33333333-…-0000000001ff`, 1 row) | ✅ GREEN | ✅ GREEN |

**No failed item on either stack → no BLOCKER.**

The `401 {"error":"invalid_token"}` body on a forged bearer is the **EF's own gotrue gate** (`adminAuth`→`verifyGotrueJwt`) responding — not a platform 404 or missing-apikey — proving the EF owns its verification with `verify_jwt=false`, exactly as designed.

## 4. Cross-lane re-verification (#463 / #470)

- **#463 — `arch(SV8): re-close — REVOKE EXECUTE on 6 payout fns` (MERGED, migration `…000240`, already at HEAD on both stacks).** The blanket DO-block targets **6 named legacy fns** (`create_payout`, `_payout_stuck_review_minutes`, `mark_failed_from_review`, `sweep_payouts_bank_maintenance`, `sweep_stale_claims`, `sweep_stale_payouts`) — it does **NOT** touch the slice-5 RPCs (which post-date it). The #463 **standing SV8 recurrence-rule** ("any campaign that adds public functions must carry the SV8 revoke in its own migration, or `execute_or_no_grants` reds") is **SATISFIED**: `…000010` itself does `REVOKE ALL … FROM PUBLIC` + `GRANT EXECUTE … TO service_role` for all 3 new fns. **V2-ACL above is the direct evidence** that the SV8 sweep would stay green — no conflict.
- **#470 — `docs(build-workflow): BINDING deploy/env single-owner policy — brew-ops sole deploy actor` (OPEN, owner-gated).** Docs/policy only; it **codifies** the role I executed here. No code/migration/EF surface — no conflict.

## 5. config.toml registration — DONE for the deploy; **durability follow-up (NON-BLOCKING)**

I added (single-owner edit; the dev was deploy-guard-blocked) to the deploy source's `supabase/config.toml`, alongside the admin-payout family:
```toml
[functions.admin-payout-correct]
verify_jwt = false

[functions.admin-payout-reverse-settle]
verify_jwt = false
```
This block was present in the deploy source and **used for this deploy** (and both EFs were also deployed with the explicit `--no-verify-jwt` flag → Mgmt-API confirms `verify_jwt=false`). **Both stacks are correct now.**

**Durability gap (surfaced, NOT auto-resolved — OUT-OF-SCOPE excludes branch/code commits):** the edit lives only in the ephemeral deploy-source worktree; it is **not committed to `build/payout-slice5`**. If `#477` merges to main **without** this block, a future no-arg `supabase functions deploy` sweep would redeploy these two EFs at the **default `verify_jwt=true`**, double-gating them (platform JWT required in front of the EF's own gotrue gate). **Only brew-ops can add this block** (the deploy-env-guard blocks every non-brew-ops window from editing `config.toml`). **DURABILITY FIX DONE (orchestrator directive, 2026-06-13):** brew-ops committed **only** these two `config.toml [functions.*]` blocks onto `build/payout-slice5` and pushed — **commit `52e0a01`** (`ad3c43b..52e0a01`, fast-forward; 1 file, +6). PR **#477** head now `52e0a01b8f070f9102589027b0c8f1d9a3417b6b`, state **OPEN / MERGEABLE**. The branch is now reproducible: a fresh no-arg `supabase functions deploy` from the merged PR keeps `verify_jwt=false`. (Migration + 3 RPCs + both EF bodies were already on the branch from the dev; this commit adds the registration only.)

## 6. TESTER (yupsev) fixture readiness — for payb5t (do NOT invent creds)

The EF money legs need a **real gotrue aal2 admin bearer** + per-partner clawback fixtures. What the tester stack carries today:

| Prereq | Status on yupsev | Action for payb5t |
|---|---|---|
| RBAC: `payout:approve` → role | **present** → `super_admin` (sibling `admin-payout-reconcile`'s perm; zero catalogue churn) | none |
| `app_user` super_admin rows | **3 present** | none |
| `auth.users` / mintable aal2 | **auth.users = 0, verified factors = 0** → **no pre-minted bearer** | **MINT** a `super_admin` aal2 bearer at probe time via the canonical `mintGotrueBearer` seal pattern (creates the auth user + verified TOTP factor mapped to a `super_admin` `app_user`; `adminAuth` does a DB-fresh `app_user` lookup, so the minted gotrue id MUST resolve to a real super_admin row). Also cover the **IP-allowlist** leg in the chain (JWT→aal2→**IP**→RBAC). This is the standard tester mint — not a blocker. |
| `mdr_owner` residual wallet | **present** (1 row, `…0000000001ff`) | none |
| partner wallets (full-vs-shortfall branches) | **2 present**: P1 `…0101` (owner `5555…0001`, bal **18.00**), P2 `…0102` (owner `5555…0002`, bal **12.00**); both frozen 0 | The full-cover vs partner-shortfall branch is driven by **per-partner net forward credit vs wallet balance** — the tester **sizes the forward fan-out in its own `BEGIN…ROLLBACK` fixture** (as dev smoke S4 all-coverable / S5 shortfall did). The 2 seeded partner wallets are usable; payb5t may also seed dedicated full/shortfall partner+profile rows. No pre-seed required from brew-ops. |
| client wallets | 5 present | tester sizes its own |

**Net:** the **schema/RBAC substrate is ready**; the only per-run provisioning is the tester's own bearer mint + the fixture payout/fan-out sizing inside its rollback transaction — both standard for the seal/tester lane. No creds invented; nothing for brew-ops to seed.

## 7. Status / next

- **Deploy: COMPLETE + GREEN on both target stacks** (tester + investigator-seal). Out-of-scope `sinuw`/`dev-1`/`dev-2` untouched.
- **Stack-ready signal:** ✅ for **next-tester (payb5t)** to author/run EF probes off `docs/spec/payout-correction-toolkit-slice.md` against `yupsev`. **next-investigator** seal stack `qnccph` likewise ready for RPC-level falsification.
- **config.toml durability: CLOSED** — §5 block committed to `build/payout-slice5` (`52e0a01`) + pushed; PR #477 MERGEABLE. The clean-merge gate is resolved.
- **Sealed-set lock HELD:** `mark_success` / forward fan-out / `match_payout_statement` md5-unchanged on both stacks — verified, not modified (per OUT-OF-SCOPE).
- **Deploy-source worktree** `…wt-brewops-payb5src` (now at `52e0a01`) removed post-push — change is committed to the branch, nothing left uncommitted.
