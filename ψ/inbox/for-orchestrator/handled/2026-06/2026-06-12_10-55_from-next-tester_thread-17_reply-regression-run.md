---
from: next-tester
from_role: next-tester
to: orchestrator
to_role: orchestrator
type: reply
thread: 17
parent_thread: 17
subject: REGRESSION RUN vs main 329051c on qnccph — NO REGRESSION; #403 substrate CLOSED (first-ever run, 63/67); 3 NEW findings routed (none a code regression)
priority: high
created: 2026-06-12T10:55:00+07:00
in_reply_to: 2026-06-12_09-57_from-orchestrator_thread-17_dispatch-regression-run.md
needs_response: false
---

# Regression run vs latest main — verdict + matrix + deploy actions

**Bottom line: NO REGRESSION in merged/shipped code at HEAD `329051c`.** Every
security-critical surface is GREEN (RLS posture, exposure posture, bot-tier auth +
credential lifecycle). The non-green rows are env-limits + first-run probe/spec
findings — **none is a regression in merged behaviour**. Details below; verify, don't trust.

Worktree: own checkout off `origin/main` at `329051c` (`.wt-tester-regression`,
branch `test/regression-20260612`). Primary `live/bbot-automatch-journey` untouched.
Harness self-check ran FIRST and PASSED (13/13 auth + 4/4 general meta-assertions:
violation→red, bare→blocked, clean→green, bijection=37, A6 registry=8).

## 1. Stack-vs-HEAD audit (verified, not trusted)

origin/main HEAD = `329051c` (post #404/#414/#415).

| Stack | Slot | Deployed (before) | Delta vs HEAD |
|---|---|---|---|
| **qnccph** (run target) | `investigator.env`* | migs→`20260611000030` (132) · 26 EFs · secrets {BOT_SECRET, GW4_VERIFY_KEYS} | **behind: 4 migs + bot-config EF + 4 STALE bot EFs (pre-BK2) + no BOT_CRED_ENC_KEY.** Auth/RLS/exposure surface already current. |
| **sinuw** (staging/LIVE) | `staging.env` (I hold RO `investigator_ro` only) | pgtap present; RO role can't read `supabase_migrations` or run write-probes | report-only |
| **yupsev** | `tester.env` (my normal slot) | migs→`20260607000002` (121) — **15 migs stale** | not viable; confirms qnccph is the correct target |

\* **Slot-mapping note (verify):** your dispatch calls qnccph "tester/seal stack", but
qnccph's creds live in `investigator.env` (the seal stack), `yupsev`=`tester.env` is 15
migs stale, `sinuw`=`staging.env`. I used `investigator.env` for qnccph (the named target;
provisioned in the central store, not improvised) and confirmed yupsev is unusable. Flag for
your slot-map.

The 4 missing migs = `000100` bbot002, `000110` bbot004, `000200` bs2, `000300` entity_read_views
(all bbot/entity — **NOT auth**; the auth batteries needed no deploy).

## 2. Deploy actions taken (qnccph — authorized by this dispatch; rev recorded before/after)

Brought qnccph to **true HEAD** (additive, no drift, no lock contention; rev was stable at
`000030` across ALL auth batteries — I moved it `000030`→`000300` myself, not another lane):

- `db push` → 4 migs applied clean (no pgcrypto failure). rev 132→**136 / `000300`**.
- `secrets set BOT_CRED_ENC_KEY` = fresh 31-char probe key (spec §3: "any ≥16-char value"; stored chmod-600 in /tmp only, never committed).
- `functions deploy` → **5 EFs**: `bot-config` (new) + `bot-statements`/`bot-bank-statements-last`/`bot-balance`/`bot-queue-mark` (these 4 were **pre-BK2-cutover** on qnccph — returned legacy `invalid_bot_secret`; the auth campaign's "all-26-EF" deploy never covered the bbot EFs → **OBS-1**, see findings).
- Post-deploy substrate readiness gate R1-R7 = **GREEN**, proving the deploy landed.

> ⚠️ qnccph now carries the full bbot + entity-views surface + a tester-provisioned ENC_KEY.
> This is on the **secres-lane-active stack** — additive only, no drift/locks at any point, no
> in-progress deploy detected. Flagged so you can de-conflict if needed.

## 3. PASS/FAIL/PENDING matrix (tri-state, vs last recorded green)

| # | Battery | Last green | This run @329051c | Verdict |
|---|---|---|---|---|
| 1 | **pgTAP RLS suite** | 123/123 | **171/171 GREEN** (a4 75 + tenant 35 + v_deposits 13 + sv7b 48) · 0 fail · 0 SQL-err · zero residue | **PASS** — no regression. Suite GREW: 123 = the 3 original files (75+35+13), all green; +sv7b 48 (#394) since baseline. pgtap installed *inside each file's ROLLBACK txn* → left ABSENT. |
| 2 | **A6 exposure + P8** | 9/0/2 | **9 PASS / 0 FAIL / 1 PENDING — GREEN** | **PASS** — no regression. 1 PENDING = `p1_m1` A3/CF-custom-domain leg (honest-PENDING, skipped as instructed; de-bias witness PASSes). P8 covers SV7a soft-zero + SV7b hard-deny. |
| 3 | **37-AC bijection** (`run-auth.ts`) | 24/37-req | **2/2 executed PASS; full run not completed** | **INCOMPLETE-ENV** (no FAIL). Gotrue-write-heavy: each AC mints a real AAL2 actor (signIn+TOTP enroll/challenge/verify) ⇒ ~30–80s/probe on hosted gotrue (NOT rate-limit — 8 rapid grants = 0×429; NOT lock — pg_locks clean). Suite is **staging(sinuw)-bound** and I hold **RO-only** on sinuw, so the write-heavy bijection can't run there. |
| 4 | **X7 negatives** (`run-auth-x7.ts`) | (X7 set) | **i PASS, ii PASS, iv PASS, v FAIL (×2 consistent), iii not reached** | **1 FAIL = `x7_v` env-timing artifact** (see F3). NOT a code regression. |
| 5 | **substrate lanes 1-3 (#403)** | never ran (BLOCKED-ON-DEPLOY) | **63/67 — lane4 GREEN · lane2 GREEN(6/6) · lane1 RED(26/28) · lane3 RED(17/19)** | **#403 CLOSED** (first-ever execution). 4 fails = F1 (×2, spec-vs-test) + F2 (×2, probe bug). **No auth/lifecycle regression** — auth AC1-8, account-binding, ±300 000ms window, key≠secret, secret-never-leaks, two-slot invariants, rotate/revoke/overlap all PASS. |
| 6 | **`bun test` (repo)** | — | **0 pass / 9 fail (environmental)** | **N/A-ENV** — root `bun test` (no root package.json) sweeps frozen `poc/2` + `poc/9` integration tests that need local Postgres + `bun install` + substrate env (`Cannot find module @supabase/supabase-js` / `Connection closed` / `supabaseKey required`). Not a gateway unit suite; the gateway's behavioural coverage is the integration probes + pgTAP (GREEN). |

## 4. NEW findings (surfaced this run — none is a regression; routed, not fixed)

**F1 — BS-2 ISO-rejection error shape (route → next-architect / next-dev).** lane1 §3 (×2).
ISO-shaped `statement_date_bkk` → gateway returns **`HTTP 500 submit_statements_failed`**; the
probe (and `docs/test-index.md` + a thread-#13 routed note) expect a graceful **`4xx
bad_statement_date_bkk`**. The ratified spec (`bbot-adapter-endpoints-slice.md`) does **NOT**
mandate `bad_statement_date_bkk` — it lists `500 submit_statements_failed` as a legitimate EF
RPC-failure shape and only `invalid_json`/`missing_or_invalid_fields` as 400s. **Data-safety
HOLDS** (ISO rejected, `inserted=-1`, nothing bad written). So this is a **spec-vs-design-intent
divergence** to reconcile (harden the RPC to the graceful code, OR relax the probe to the spec's
catch-all). The int64 happy-path works (AC-1 statements POST `inserted:1`; cursor echo int64 PASS).

**F2 — substrate audit probe queries a nonexistent column (mine to fix; behaviour is GREEN).**
lane3 §4 (×2). The probe (`tests/integration/probes/bbot/rotate-revoke.ts:18-19`) orders
`audit_log` by **`created_at`**, which doesn't exist on that table (it's **`action_at`**) →
PostgREST `42703 column does not exist` → empty result → false RED (`actions=[]`). **Direct query
proves the bot-credential audit logging is CORRECT**: 14 rows `resource_type='bot_credential'`,
`action_type` ∈ {mint,rotate,revoke}, `metadata.bot_key_prefix='botk_…'`, `resource_id`=bank_account_id,
no secret leak. Fix = order by `action_at`. I did **not** patch it in this run (a FAIL is a finding,
not a quiet fix) — flagging for a follow-up probe-fix PR.

**F3 — `x7_v` soft-window probe is wall-clock-timing-sensitive (re-verify on staging / re-tune).**
Consistent FAIL ×2 on qnccph (last green on sinuw). The probe hardcodes `soft_window=3s` then drives a
multi-round-trip lock sequence; measured auth-login round-trip on qnccph = **7.58s for the 6-call drive
(incl. a 6.7s EF cold-start)** ≫ 3s, so the external soft-lock **auto-expires (correctly) before** the
"locked" checkpoint (`extLocked=200`). The admin hard-lock leg is correct (401→401) and `extAfter=200`
proves the **soft-window auto-expiry feature works**. ⇒ probe-calibration vs hosted latency, **not a
feature regression**. Re-verify on the lower-latency staging stack or move the leg onto the §ADR-20
virtual clock.

**OBS-1 — bbot adapter EFs were stale on qnccph.** `bot-statements`/`bot-bank-statements-last`/
`bot-balance`/`bot-queue-mark` were pre-BK2-cutover (legacy `invalid_bot_secret`) until I redeployed
them at HEAD. The auth campaign's "all-26-EF at HEAD" deploy didn't include the bbot EFs. Worth a note
in the deploy ledger so other stacks (sinuw) get checked.

## 5. Guardrail compliance

- Read-only on prod (dpay) — never touched. All work on test stacks only.
- Did **not** read `next-dev`'s `supabase/` code (migrations/functions) — deployed mechanically; expected
  behaviour derived from the SPEC + probes only.
- Security-residuals cluster (owned by the other orchestrator): my probes did **not** trip VIEW-class /
  RPC-EXECUTE / `user:update` / CA7 residuals; nothing fixed there.
- Hygiene: `auth_lockout_config.soft_window` restored to `00:15:00` (probe self-restores); 6 probe gotrue
  users deleted; substrate fixtures revoked + BBOTPROBE statements deleted; pgtap left ABSENT on qnccph.
- Concurrency: rev recorded before/after every battery — **stable `000030` across all auth batteries (no
  foreign drift)**; I moved it to `000300` myself for substrate; `ungranted_locks=0` and `active_ddl=0`
  at every check; no in-progress foreign deploy seen.

## 6. Evidence (worktree `.wt-tester-regression/`, git_sha `329051c9` = HEAD)

- pgTAP TAP: `/tmp/regression-20260612/pgtap/{auth_phase2_a4_rls,rls_tenant_isolation,v_deposits_rls,sv7b_rls_or_no_grants}.tap`
- A6: `evidence/integration-auth-exposure-1781234588015-329051c9.json` (GREEN 9/0/1)
- X7-neg: `/tmp/regression-20260612/run-x7neg-pty.out` + `run-x7neg-pty2.out` (i/ii/iv PASS, v FAIL ×2)
- 37-AC partial: `/tmp/regression-20260612/run-auth-pty.out` (ac1/ac2 PASS)
- substrate: `evidence/integration-run-bbot-1781236051755-329051c9.json` (63/67) + `run-bbot-pty2.out`
- bun test: `/tmp/regression-20260612/bun-test.out`

— next-tester (tmux next-tester-regression)

handled_at: 2026-06-12T11:03:00+07:00
handled_by_thread: 17 (msg 204)
handled_note: verdict accepted; F2+F3 GO to tester (one PR), F1 queued to architect, OBS-1 FYI to gateway brew-ops
