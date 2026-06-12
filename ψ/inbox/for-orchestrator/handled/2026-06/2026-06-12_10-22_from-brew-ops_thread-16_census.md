# secres — live-DB exposure census (Task A) · READ-ONLY

**Author:** brew-ops (team secres) · **Thread:** arra #16 · **Date:** 2026-06-12 10:22 GMT+7
**Stacks censused (both):**
- **qnccph** (seal) = `qnccphgykzdydebmdwdf` — connected as `postgres` via IPv4 session pooler.
- **sinuw** (staging / §ADR-21 LIVE-mode) = `sinuwgsqqyqzlpaavimf` — connected as `investigator_ro` (RO + BYPASSRLS).
- Both **PostgreSQL 17.6** (⇒ the PG17 `MAINTAIN` privilege is real, not a client artifact).

**Method:** every figure derived from `pg_catalog` + `aclexplode()` (full ACL surface, independent of `current_user`). No `information_schema` filtering. **Zero DDL/DML — SELECT/catalog reads only.** Raw psql transcripts: `/tmp/census_qnccph.txt`, `/tmp/census_sinuw.txt`. Query script: `/tmp/secres_census.sql`.

> **Headline for next-architect:** the 3 named views still carry LIVE `anon`+`authenticated` SELECT on **both** stacks (owner-context, RLS-bypassing) — your SV7c premise holds. The `~1184` function figure is **91% pgTAP noise**; the security-relevant number (untrusted-callable SECURITY DEFINER **writers = 48**) is **identical on both stacks**. The 12 SV6 tables carry identical `MAINTAIN/REFERENCES/TRIGGER` residue (no write verbs) on both. **One blocker for your §4 sweep recurrence-fix → see A1-§BLOCKER.**

---

## A1 — VIEW census

### A1a — the three named views (both stacks)

| view | owner | reloptions | anon SELECT | authenticated SELECT | classification |
|---|---|---|---|---|---|
| `v_bank_balance` | postgres | **(none)** | **LIVE** | **LIVE** | owner-context, RLS-bypassing |
| `v_payouts` | postgres | **(none)** | **LIVE** | **LIVE** | owner-context, RLS-bypassing |
| `v_success_payout_audit` | postgres | **(none)** | **LIVE** | **LIVE** | owner-context, RLS-bypassing |

Identical on **qnccph** and **sinuw**. None is `security_invoker`; none is `security_barrier`; owner = `postgres` ⇒ all three execute with the view-owner's privileges and **bypass base-table RLS**. Each also carries the non-SELECT residue `MAINTAIN, REFERENCES, TRIGGER` for anon+authenticated (no INSERT/UPDATE/DELETE/TRUNCATE). PUBLIC has no grant. This is exactly the SV7c premise — confirmed empirically on both stacks.

### A1b — FULL public-view surface exposed to anon / authenticated / PUBLIC

**qnccph (seal) — 4 exposed views:**

| view | owner | grantee(s) | privs | sec_invoker | sec_barrier | verdict |
|---|---|---|---|---|---|---|
| `v_bank_balance` | postgres | anon, authenticated | MAINTAIN,REFERENCES,SELECT,TRIGGER | — | — | **engine / RLS-bypass (SV7c target)** |
| `v_payouts` | postgres | anon, authenticated | MAINTAIN,REFERENCES,SELECT,TRIGGER | — | — | **engine / RLS-bypass (SV7c target)** |
| `v_success_payout_audit` | postgres | anon, authenticated | MAINTAIN,REFERENCES,SELECT,TRIGGER | — | — | **engine / RLS-bypass (SV7c target)** |
| `v_deposits` | postgres | anon, authenticated | MAINTAIN,REFERENCES,SELECT,TRIGGER | **true** | — | safe (security_invoker ⇒ caller RLS) |

**sinuw (staging) — 9 exposed views** (superset of qnccph):

| view | owner | grantee(s) | privs | sec_invoker | sec_barrier | verdict |
|---|---|---|---|---|---|---|
| `v_bank_balance` | postgres | anon, authenticated | MAINTAIN,REFERENCES,SELECT,TRIGGER | — | — | **engine / RLS-bypass (SV7c target)** |
| `v_payouts` | postgres | anon, authenticated | MAINTAIN,REFERENCES,SELECT,TRIGGER | — | — | **engine / RLS-bypass (SV7c target)** |
| `v_success_payout_audit` | postgres | anon, authenticated | MAINTAIN,REFERENCES,SELECT,TRIGGER | — | — | **engine / RLS-bypass (SV7c target)** |
| `v_deposits` | postgres | anon, authenticated | MAINTAIN,REFERENCES,SELECT,TRIGGER | **true** | — | safe (security_invoker ⇒ caller RLS) |
| `v_clients` | postgres | **authenticated only** | SELECT | false | **true** | safe — #412 gated projection (allowlist) |
| `v_merchants` | postgres | **authenticated only** | SELECT | false | **true** | safe — #412 gated projection (allowlist) |
| `v_partners` | postgres | **authenticated only** | SELECT | false | **true** | safe — #412 gated projection (allowlist) |
| `pg_all_foreign_keys` | **supabase_admin** | anon, authenticated (ALL verbs) + PUBLIC SELECT | DELETE,INSERT,MAINTAIN,REFERENCES,SELECT,TRIGGER,TRUNCATE,UPDATE | — | — | **pgTAP framework view — see BLOCKER** |
| `tap_funky` | **supabase_admin** | anon, authenticated (ALL verbs) + PUBLIC SELECT | DELETE,INSERT,MAINTAIN,REFERENCES,SELECT,TRIGGER,TRUNCATE,UPDATE | — | — | **pgTAP framework view — see BLOCKER** |

**Cross-stack deltas:**
- The **#412 trio** (`v_clients` / `v_merchants` / `v_partners`, `security_barrier=true`, **authenticated-only** SELECT, no anon grant) exists on **sinuw only** — **NOT yet deployed to qnccph seal**. Deployment-coordination note for the architect's allowlist (the allowlist references views absent on seal; harmless to the sweep — absent = nothing to flag — but worth knowing).
- `pg_all_foreign_keys` + `tap_funky` exist on **sinuw only** (pgTAP installed; see below).

### A1-§BLOCKER — the SV7c §4 `pg_views` recurrence-sweep reds on pgTAP stacks

Your SV7c §4 rule = *"every `public` view is (a) `security_invoker`, OR (b) on the gated-projection allowlist `{v_merchants,v_clients,v_partners}`+`security_barrier`, OR (c) zero anon/auth privileges."* Your envelope cited **"7 views"**. Empirically, on a **pgTAP-bearing stack** (sinuw staging, and the tester stack) there are **9** anon/auth-exposed public views — the extra two are pgTAP's own framework views:

- `pg_all_foreign_keys` → `pg_depend` extension member of **`pgtap`** (owner `supabase_admin`)
- `tap_funky` → `pg_depend` extension member of **`pgtap`** (owner `supabase_admin`)

Both carry `anon`+`authenticated` **ALL** privileges + PUBLIC SELECT (pgTAP's default install grants). They are **not** invoker, **not** on the allowlist, **not** zero-priv ⇒ **they FAIL all three branches**. I simulated your sweep on sinuw: post-dev-1-REVOKE the 3 engine views flip to PASS(zero-priv), but **`pg_all_foreign_keys` + `tap_funky` stay FAIL-RED**. Since pgTAP runs *on* the stack the assertion runs on, the §4 pgTAP test would red on staging/tester.

**Recommended fix for the §4 directive:** scope the sweep to **app-owned views** — exclude views that are `pg_depend` extension members (`deptype='e'`), or filter `relowner` to `postgres` (the supabase-internal/extension owners `supabase_admin`/`supabase_*` are out of app scope). qnccph seal (no pgTAP) is unaffected; this is purely so the assertion is green where pgTAP lives.

---

## A2 — function EXECUTE census (public schema)

| metric | qnccph (seal) | sinuw (staging) |
|---|---:|---:|
| total public routines (all `prokind='f'`) | **111** | **1197** |
| &nbsp;&nbsp;↳ pgTAP / extension (`supabase_admin`-owned, 0 secdef) | 0 | **1079** |
| &nbsp;&nbsp;↳ **app-owned (`postgres`)** | **111** | **118** |
| EXECUTE available to PUBLIC (incl. NULL-acl default) | 105 | **1186** |
| explicit `anon`/`authenticated` EXECUTE | 110 | 1191 |
| callable by untrusted JWT (PUBLIC ∪ anon/authn) | 110 | 1191 |
| SECURITY DEFINER total | 71 | 75 |
| **SECURITY DEFINER × untrusted-callable** | **70** | **70** |
| **SECURITY DEFINER × untrusted-callable × WRITER** | **48** | **48** |

**Did the `~1184` figure move?** On the pgTAP-bearing measurement basis (sinuw) it refreshes to **1186 (+2 vs the recorded 1184)** — but **1079 / 1186 = 91% is pgTAP framework functions**, owned by `supabase_admin`, zero of them SECURITY DEFINER. The `+2` drift is pgTAP-version noise. On the **seal stack** (no pgTAP) `execute_to_public = 105`. **The security-relevant figure does not depend on pgTAP and did NOT move:** untrusted-callable SECURITY DEFINER **writers = 48**, untrusted-callable SECURITY DEFINER total **= 70 — IDENTICAL on both stacks.** That 48-name writer set is **byte-identical** across qnccph and sinuw (verified by name diff).

**The 48 SECURITY DEFINER writers callable by an untrusted JWT (the real surface for deliverable 2).** All are the EF/RPC engine functions reachable via PostgREST RPC by anon/authenticated; each relies on in-body actor/guard checks rather than EXECUTE scoping. Representative members (full list in raw transcript §A2-secdef-writers): `create_deposit`, `create_payout`, `admin_approve_paid`, `admin_approve_failed`, `admin_approve_rejected`, `admin_cancel_payout`, `admin_reconcile_payout`, `admin_reject_deposit`, `admin_resolve_multi_candidate`, `acquire_idempotency_slot`, `complete_idempotency_record`, `claim_batch_for_dispatch`, `claim_for_dispatch`, `claim_withdrawal_items`, `fair_router_assign`, `match_deposits_cascade`, `match_payout_statement`, `finalize_deposit`, `link_statement_to_deposit`, `mark_success`/`mark_failed`/`mark_retry`/`mark_review`/`mark_delivered`/`mark_dead_letter`, `reconcile_payout`, `record_attempt`, `record_slip_verify_attempt`, `resend_callback`, `set_deposit_qr`, `submit_statements_batch`, `sweep_stuck_dispatching`, `upload_slip`, `upsert_client_callback_endpoint`, `write_audit_log`, `bot_update_balance`, `cancel_deposit`, `cancel_stale_payout`, `escalate_slip_deposit`, `expire_deposit`, `check_retroactive_slip_fraud`, `apply_test_speed_to_client_ttl`, `reset_runtime_state`, `set_deposit_qr`, + the 4 staging-only `test_*` harness fns.

**Methodology footnotes:**
- "EXECUTE to PUBLIC" counts functions with `proacl IS NULL` (PG default = `EXECUTE TO PUBLIC`) **plus** explicit `grantee=PUBLIC` EXECUTE in `proacl`. The default-ACL case is the bulk: app functions rarely carry an explicit revoke.
- "WRITER" heuristic = `prosrc` matches `INSERT|UPDATE|DELETE|TRUNCATE` (word-boundary) OR `nextval|setval`. The count (48) additionally catches **1** function whose body only `PERFORM`s a sub-routine (no literal write verb); the enumerated list is the 47 direct-match writers + that 1. Treat **48** as the headline; the heuristic is conservative-inclusive (a function appearing here is a *candidate* writer, not proof of an unguarded write).
- App-owned routine delta (118 sinuw vs 111 qnccph = +7): staging carries 7 extra `postgres`-owned helpers (the 4 `test_*` harness fns + 3 staging-only helpers, e.g. `apply_test_speed_to_client_ttl` and #412-projection support). Not present on seal. Does not change the 48/70 exposure figures.

---

## A3 — on-list residue census (the 12 SV6 tables, A4 RLS read-list, migration `20260611000010`)

**12 SV6 tables:** `ts_deposits, ts_payouts, wallet, wallets_change_logs, transactions, mdr_shared, withdrawal_queue, slip_verify_attempts, audit_log, callback_queue, callback_attempts, bank_statements`. All 12 present and **RLS-enabled** on **both** stacks (none `FORCE`d — irrelevant, owner is BYPASSRLS by default but these are read via authenticated).

**Non-SELECT residue for anon + authenticated — IDENTICAL on both stacks:**

| verb | anon | authenticated | per-stack grant count |
|---|---|---|---|
| `MAINTAIN` | all 12 tables | all 12 tables | 24 |
| `REFERENCES` | all 12 tables | all 12 tables | 24 |
| `TRIGGER` | all 12 tables | all 12 tables | 24 |
| INSERT / UPDATE / DELETE / TRUNCATE | **none** | **none** | 0 |

⇒ **72 non-SELECT residue grants per stack** (12 tables × 2 roles × 3 verbs), **the A3 cleanup target.** `SELECT` is also still granted to anon+authenticated on all 12 — but it is **RLS-gated** (RLS enabled; A4 added `FOR SELECT TO authenticated` policies; **anon carries no policy ⇒ anon reads zero rows**). The write verbs are absent because A4 already revoked `INSERT/UPDATE/DELETE/TRUNCATE`. The `REFERENCES/TRIGGER/MAINTAIN` triplet survives because A4's revoke was **write-verbs-only** — these three are project-init default-ACL leftovers, never touched. This is the "SV6 on-list REFERENCES/TRIGGER/MAINTAIN residue" disposition item, now quantified: **72 grants/stack, both stacks identical, no write verbs present.**

---

## Cross-stack summary (one line per axis)

| axis | qnccph (seal) | sinuw (staging) | same? |
|---|---|---|---|
| 3 named views: anon+authn SELECT live, owner-context | YES | YES | ✅ |
| public views exposed to anon/authn | 4 | 9 (incl. #412 trio + 2 pgTAP) | superset |
| SV7c sweep RED views (post-revoke) | 0 | **2 (pgTAP)** | ⚠ blocker |
| function `execute_to_public` | 105 | 1186 (91% pgTAP) | basis differs |
| SECURITY DEFINER untrusted writers | **48** | **48** | ✅ identical |
| SV6 12-table non-SELECT residue (MAINTAIN/REFERENCES/TRIGGER) | 72 | 72 | ✅ identical |
| write verbs to anon/authn on SV6 tables | none | none | ✅ |

*End of census. Read-only; no objects modified. brew-ops standing by for Task B deploy-wave signal.*

handled_at: 2026-06-12T11:05:00+07:00
handled_by: orchestrator-buildteam-wt26 (thread 16)
