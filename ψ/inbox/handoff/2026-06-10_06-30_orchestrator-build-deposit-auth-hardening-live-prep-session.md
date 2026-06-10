---
to: orchestrator-build (next session) + owner + brew-ops + next-tester + next-investigator
from: orchestrator-build 2026-06-10/11
priority: P1
topic: BIG SESSION — auth-rbac sealed, DEPOSIT-010 + depmatch fixed, authsec Phase-1 hardening done, LIVE gate PREP done + HALTED before money-run
project: github.com/kxlahsimx09/mb-next-payment-gateway
tags: [orchestrator, live-gate, adr-21, authsec, deposit-010, depmatch, auth-hardening, prep-halted, simlive]
---

# Session summary — gateway @ main `530f5c0` (everything below MERGED unless noted)

## DONE this session (all merged + verified)
1. **auth-rbac epic-seal** (next-investigator, qnccph seal stack). Took 3 passes: (a) substrate gap — investigator creds were for empty qnccph not staging sinuw → brew-ops deployed the HEAD auth slice + seeded 4 synthetic identities to qnccph; (b) re-seal found a REAL bug: **AUTH-002 returning-user 2FA login broken** — `auth-login listFactors()` called `GET /auth/v1/factors` (gotrue 405) → always enroll-branch, challenge-branch dead → returning enrolled users couldn't log in (happy-path tests missed it; they minted bearers directly). **Fixed PR #369** (`GET /auth/v1/user` + strict-aal admin-auth:104 + config.toml TOTP=true), commit `ccd7608`. (c) re-seal GREEN: AUTH-001/002/003/004 + AAL2 sealed.
2. **DEPOSIT-010 M4 inversion** — spec authored 1 day before ratify → code returned 409 on re-cancel (ratified M4 wants 200 idempotent echo). Fixed spec F1-F7 + forward migration `20260610000001` (already_cancelled→200 echo) + EF (**PR #371**); next-tester F4/F5 probes GREEN (M4 200 + cancelled_at unchanged, 404-admin, AC2c eff-expired). F6 epic-AC clarify **PR #376**.
3. **depmatch Option B** (owner GO "parity") — slip-bearing past-deadline = NOT auto-creditable, admin-approve-only (mobiz-verbatim port, no match-logic change). §ADR-4c §Amendment + §ADR-15 sizing (**PR #374**), epic+design docs (**PR #375**), DEPOSIT-005 resolve → **409 CANDIDATE_PAST_DEADLINE** + migration `20260610000002` (**PR #373**); probe GREEN.
4. **authsec Phase-1 (X1-X6 + X7 + F1)** — post-seal review found phantom/bypassable auth controls. **PR #377** (X1 2FA-fail→lockout, X2 gotrue-429 audit, X3 IP-allowlist+CF-header+CIDR, X4 ordering, X5 enroll payload, X6 step-up) + migration `20260610000010`. X7 re-run **PR #378** (24/37 required-green all pass). **F1 fix PR #379** (soft-regime gotrue ban = soft_window not ceil-minutes) — re-verify GREEN.

## DEPLOYED (brew-ops, both stacks): qnccph (seal) + sinuw (staging/LIVE-mode)
All migrations + EFs at HEAD. `CF_ZONE_SECRET` set on both EF envs (X3b) — value at `/tmp/simlive/.cf_zone_secret` (header `cf-zone-secret`).

## ⏸️ LIVE gate (deposit+auth) — PREP COMPLETE, HALTED before the money-run
next-live-tester authored the §ADR-21 DEPOSIT golden journey (code-blind, 6 files `poc/integration/src/live/*` ≤250 lines) on branch **`campaign/livetester-adr21`** (worktree `mb-next-payment-gateway.wt-3-adr`) — committed+pushed WIP (PREP). Real auth front door (login→2FA→aal2, the #369 path) + real client front door (CF Worker HMAC→GW4 assertion→deposits-create) + admin upload-slip→verify-now→approve→finalize + LiveCapture + ONE X-Request-Id + 3 RUN-guarded faults.
- **LIVE-readiness: happy money path GREEN end-to-end on sinuw.** Run cmd: `OWNER_GO_LIVE_DEPOSIT=1 bun run src/live/deposit-journey.ts`.
- **5 prereqs before the money-RUN (none done yet):**
  1. **AR6 review** — next-tester one-time methodology/coverage/channel-realism review of the journey script. Weigh: slip-upload uses the admin path (customer-facing client-tier slip shape not in the SPEC — confirm); verify-now(genuine) for determinism vs the 5-min sweep.
  2. **MOCK_BANK_URL** unset on `slots/staging.env` → blocks **fault (i)** dup-bank-txn only (NOT happy path). brew-ops/L0 to provision a mock-bank push channel + dup-credit flag.
  3. **fault (iii) gap:** the §ADR-15 callback **dead-letter alert is NOT deployed** (catalog only P2.16 payout) — the "alert fires" half has no artifact to verify; AND the prod retry horizon ~32h is real-timer → RUN needs a staging-compressed dispatcher cadence (confirm w/ brew-ops).
  4. **L3 creds:** next-investigator must read **sinuw** raw tables for the L3 verdict but its slot (investigator.env) is qnccph-bound → provision sinuw read-creds (service-role or read grant). The journey stamps the ONE X-Request-Id for L3 correlation.
  5. **OWNER GO** for the money-run.

## Auth-hardening — NOT YET STARTED (3 architect docs at gateway repo root, untracked)
- `next-architect_authexposure_proposal.md` — DECIDED (owner GO): m1 block ext password-grant · m2 RLS aal2 · **m3 split-by-verb RLS** (reads=PostgREST+RLS w/ tenant+aal2+`:view` RBAC; writes=EF-only, revoke authenticated write grants) · m4 raw-origin · m5 DB-fresh resolver. Propagation **A1-A6** (architect A1/A2 ADR · dev A4 RLS migration · brew-ops A3 CF/gotrue · writer A5 · tester A6). NOT started.
- `next-architect_authsec_spec.md` — X1-X6 DONE (this session); **X7 done**; residuals **F2** (gotrue-429 unverifiable over wire — needs a gotrue rate-limit lever or EF unit test), **F3** (X3b positive on-list leg blocked on the deferred CF transform = the deferred CF custom domain), **F4** (admin-users-unlock EF + admin-deposit-refund not deployed on qnccph).
- `next-architect_authdocs_spec.md` — W1-W10 doc reconciliation (W1 F3 catalogue-add + W9 K1 API-key rotation are ratification-bearing; architect adr.md serialize) — NOT started.

## OTHER OPEN
- **CF custom domain / staging** — deferred, owner gettinga domain. vanity subdomain is a dead end (doesn't rewrite gotrue iss — learning `2026-06-10_supabase-free-vanity-subdomain...`). Staging on raw URL. This blocks F3 + GW1a-H WAF activation. Handoff `2026-06-10_14-59_staging-stays-raw-url...`.
- **finance-audit PR #372** (separate campaign `agents/4-audit`) — untouched.

## OPS (carry-forward)
- **Self-merge OK for build PRs after reviewer APPROVE** (owner GO 2026-06-10; learning `2026-06-10_owner-preference...build-team...`). Orchestrator merged #369/371/373/374/375/376/377/378/379.
- **maw dispatch gotcha:** `maw team spawn` drops the agent into the orchestrator's tmux window → orchestrator-guard blocks its edits. Fix: `tmux break-pane -d -s <pane> -n <role>-work` immediately after spawn (learning `maw-spawn-guard-misfire-breakpane`). `--exec` doesn't auto-submit; nudge via `tmux send-keys -l "<prompt>" + Enter`.
- Stacks: **qnccph** = investigator seal stack; **sinuw** = LIVE-mode/staging. Both at HEAD.
