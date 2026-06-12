# Auth/Deposit hardening — preserved architect docs + STATUS index

Preserved 2026-06-11 from gateway-repo-root untracked docs + /tmp team reports (both ephemeral) so the full change-lists survive. Gateway @ main `530f5c0` at preservation; **campaign CLOSED 2026-06-11 @ main `3ab1c7f`** (see session-2 + wave-3 sections below). Cross-ref handoffs `2026-06-10_06-30_...live-prep-session` + `2026-06-10_06-46_mb-next-bank-bot-plan...` + `2026-06-11_02-50_orchestrator-build-auth-phase2-executed`.

## Files here
- `next-architect_authexposure_proposal.md` — exposure decision (A1-A6). DECIDED, owner GO; **propagation EXECUTED 2026-06-11** (A3 residual only).
- `next-architect_authsec_spec.md` — code fix-spec X1-X7 + Done-when.
- `next-architect_authdocs_spec.md` — doc reconciliation W1-W10.
- `next-architect_dep10fix_spec.md` — DEPOSIT-010 F1-F7 (acted on; kept for trace).
- `next-architect_depmatch_proposal.md` — depmatch Option B (acted on; kept for trace).
- `team-reports/` — X7 report (F1-F4 detail), authsec dev/reviewer/F1 reports, x7-v re-verify.

---

## ✅ DONE this session (merged + verified, gateway main 530f5c0)

### authsec — Phase 1 code closures
- [x] **X1** count 2FA failures into lockout — PR #377
- [x] **X2** gotrue-429 → `login_rate_limited` audit, no counter corrupt — PR #377
- [x] **X3** IP-allowlist on authed EFs + CF-provenance header + CIDR RPC — PR #377 (X3b spoof-CLOSED; positive leg = F3 below)
- [x] **X4** IP-gate before counter reset — PR #377
- [x] **X5** retried first-login enroll payload (delete-unverified-re-enroll) — PR #377
- [x] **X6** AUTH-007 step-up: BLOCKED-on-consumer + audit 423 + config row — PR #377
- [x] **X7** 37-AC re-run + 5 negative probes + fixture fix — PR #378 (24/37 required-green ALL pass; reds env-proven)
- [x] **F1** soft-window auto-expiry: soft-regime gotrue ban = `soft_window` seconds (was ceil-minutes) — PR #379, re-verified GREEN

### DEPOSIT-010 (dep10fix F1-F7)
- [x] **F1-F7** spec + M4 idempotent re-cancel (200 echo not 409) forward migration `20260610000001` + EF — PR #371; F4/F5 probes GREEN; F6 epic-AC clarify PR #376
- [x] (also: the auth-login returning-user 2FA bug found during the seal — PR #369 `ccd7608`)

### depmatch (Option B)
- [x] **B1** §ADR-4c §Amendment + **B4** §ADR-15 sizing — PR #374
- [x] **B2/B5** epic-deposit edges + new AC + design annotations — PR #375
- [x] **B3** DEPOSIT-005 resolve → 409 `CANDIDATE_PAST_DEADLINE` + migration `20260610000002` — PR #373; probe GREEN

---

## ⬜ PENDING ledger from session 1 — RECONCILED 2026-06-11 after session 2 + wave-3 (details in the sections below)

### authsec residuals (env/coverage, proven in X7 — code is sound)
- [x] **F2** CLOSED test-side — X2 contract-model unit test (4 invariants incl. one-row-before-429 + counter unchanged), network-independent — PR #384. (The gotrue rate-limit lever leg remains unnecessary.)
- [ ] **F3** STILL BLOCKED on the CF custom domain (owner getting a domain). Spoof-CLOSED leg GREEN; positive AC1/AC2/AC9 legs re-run once the CF transform injects `cf-zone-secret` + real `CF-Connecting-IP`. Same blocker as A3's CF leg.
- [x] **F4** CLOSED — `admin-users-unlock` deployed on BOTH stacks (first-ever on qnccph; 401 not 404; canonical `user:unlock`) — wave-3 brew-ops deploy @ 47be8d6. `admin-deposit-refund` Phase-2-deferred as acknowledged (verified structurally absent).

### authexposure — Phase 2 (DECIDED, owner GO) — EXECUTED except A3
- [x] **A1** §ADR-2 amendment — PR #380
- [x] **A2** §ADR-13 amendment (split-by-verb + SV6a matrix + SV7a/SV7b closures) — PRs #380/#387
- [ ] **A3** CF zone + gotrue config (m1 block password-grant, m4 origin restriction) + X3b `CF_ZONE_SECRET` transform + staging verify — brew-ops + next-dev. CF-rule leg + transform BLOCKED on the custom domain (= F3); the gotrue-config-only leg is the investigable remainder.
- [x] **A4** RLS migration `20260611000010` + pgTAP 123/123 — PR #385; deployed both stacks (wave-2)
- [x] **A5** epic/spec touches — PR #383
- [x] **A6** probes authored (PR #384) + strict re-run 9/0/2 + P8 (PR #390)

### authdocs — W1-W10 — ALL DONE
- [x] **W1** F3 catalogue-add CA1-CA7 — PR #386 (OWNER-RATIFIED `39c64d7`)
- [x] **W2-W6** adr.md doc pass — PR #380
- [x] **W7** + **W8** — PR #383
- [x] **W9** K1 two-slot rotation — PR #386 (OWNER-RATIFIED)
- [x] **W10** AUTH-008 spec (PR #383) + AUTH-010 spec (PR #393). Remaining queue: **011/012/009/006 specs — the only W10 leftover** — next-writer, next session.

### Cross-cutting
- [ ] **mb-next-bank-bot** + statement-auto-match golden journey (handoff `..._06-46`) — in progress 2026-06-11 by the bankbot orchestrator (PR #381 epic open)
- [ ] **LIVE gate RUN** 5 prereqs (handoff `..._06-30`)
- [ ] **CF custom domain** (blocks F3 + GW1a-H WAF) — owner getting a domain

---

## ✅ 2026-06-11 session 2 — auth Phase-2 EXECUTED (orchestrator-build, 4 lanes + reviewer)

Gateway main now `88e9759`. Every PR reviewer-gated (next-code-reviewer, separate agent); REQUEST-CHANGES rounds on #380/#382/#385 all caught real defects.

### MERGED
- [x] **A1+A2** §ADR-2 + §ADR-13 exposure amendments + **W2-W6** — PR #380 (2 fix rounds: **SV7a** anon-read-policy closure — `adminweb_anon_select` survived on `bank_statements`/`callback_queue`/`callback_attempts`; **SV6a** Phase-1 role→`:view` grant matrix — was ratified NOWHERE, now pinned with binding composition `aal2 ∧ has_read_perm ∧ (admin OR tenant)`; G3-D `list_factors` strike)
- [x] **A5 + W2-mirror + W7 + W8 + W10/AUTH-008 spec** — PR #383 (AUTH-010 NOT authored — blocked on W9 ratification)
- [x] **F2** X2 gotrue-429 contract-model test (7/7 GREEN, network-independent) + **A6** 7 exposure probes w/ de-bias witnesses — PR #384
- [x] **A4** split-by-verb RLS migration `20260611000010` + pgTAP 123/123 (EXPLAIN once-per-query proof real; seed canonical-only after review fix) — PR #385
- [x] **SV7b** default-grant closure enumeration (27 RLS-less tables, zero grants off the SV6 list; reviewer-verified complete vs migration census; judged NOT ratification-bearing) — PR #387
- [x] **SV7b stopgap** revoke anon+authenticated SELECT on `client` + `merchant_config` (credential-bearing) — migration `20260611000020`, PR #388

### OPEN for OWNER
- [x] **PR #386 — OWNER MERGED 2026-06-11** (`39c64d7`) — W1 F3 catalogue-add CA1-CA7 + `admin-users-unlock`→`user:unlock` flip + §ADR-16 `topup:*` correction + W9 K1 two-slot rotation are RATIFIED. Unblocks: CA2/CA4 EF flips, AUTH-010 spec, F4 deploy (wave-3, dispatched).

### WAVE-3 (post-#386 ratification, 2026-06-11) — DONE
- [x] **CA2/CA4 EF flips** — PR #392 MERGED (`47be8d6`): `user:reset-2fa` + `security-config:update` canonical, 2 DEPRECATED map exceptions dropped, zero old-string enforcement sites
- [x] **AUTH-010 spec** — PR #393 MERGED: `docs/spec/auth-010-api-key-lifecycle-slice.md`, 5/5 AC bijection, K1a-K1c faithful, Phase-1 admin-only pin ⚑-flagged
- [x] **F4 CLOSED** — brew-ops deployed ALL 26 EFs at HEAD (47be8d6) to qnccph + sinuw: `admin-users-unlock` first-ever deploy on qnccph (401 not 404 — AC7 coverage live), CA1/CA2/CA4 canonical strings + canonical-only ROLE_PERMISSIONS active everywhere; `admin-deposit-refund` structurally absent (Phase-2-deferred, verified)

### Wave-2 results (same day, for trace)
- [x] **Wave-2 deploy** DONE: A4 + stopgap migrations applied + spot-checked GREEN on qnccph + sinuw (brew-ops report `/tmp/authphase2/brewops.done`; role_permissions=44, client/merchant_config 42501, A4 tables anon→zero)
- [x] **A6 strict re-run + P8** DONE: PR #390 MERGED (main `61028c2`) — **9 PASS / 0 FAIL / 2 honest-PENDING** (P1/m1 env-gated on A3; P7 live-WS = observation, SELECT-equivalence is the proof). P8 covers both denial semantics (A4 soft-zero vs SV7b hard-deny). Reviewer-commended phantom-string catch (`ts_deposits:view`→`deposit:view`) pre-run.

---

## 🏁 CAMPAIGN CLOSED 2026-06-11 — gateway @ main `3ab1c7f`

**10 PRs merged** (#380 #383 #384 #385 #386[owner] #387 #388 #390 #392 #393), all reviewer-gated; **wave-2 migrations + wave-3 all-26-EF deploy live on qnccph + sinuw**; strict probes 9 PASS / 0 FAIL / 2 honest-PENDING. The split-by-verb posture (aal2 ∧ has_read_perm ∧ tenant; writes EF-only; anon closed on business tables) is ratified, coded, deployed, and probe-verified.

### Carry-forward (everything still open, one list)
> **COORDINATION NOTE (orchestrator, 2026-06-12):** the security-residuals cluster below (function-EXECUTE posture · VIEW-class exposure · on-list residue · `user:update` seed-vs-map · CA7 assertion · PoC twin) is **owner-assigned to ANOTHER orchestrator/session** as of 2026-06-12 — do not double-dispatch from other sessions; check with the owner before picking these up.
- [x] **SV7b full-set migration — DONE + DEPLOYED 2026-06-11**: PR #394 MERGED (`20260611000030` — REVOKE ALL 8 PG17 verbs on 27+2 tables + pg_tables-based `rls_or_no_grants` sweep, 48/48); brew-ops pushed to qnccph + sinuw and verified live: residual anon/auth grants = 0 across all 29, supabase_auth_admin carve-out survives, postgres-grantor table default-ACL = 0, revoked tables 42501 / SV6 soft-zero intact / auth-login EF healthy / `investigator_ro` unaffected. Documented residual: supabase_admin-grantor default ACL (dashboard-created objects) — sweep is the recurrence-catch.
- [x] **W10 — FULLY CLOSED**: #395 MERGED — AUTH-011/012/009/006 specs (GO all four). Every S2 auth story now has a spec slice.
- [ ] **A3 / F3** — **gotrue-config leg EXHAUSTED 2026-06-11 (brew-ops investigation, nothing applied, both stacks healthy)**: NO selective lever exists on hosted gotrue — every hook/toggle/limit is non-selective and would 401 the EF too (`password_verification_attempt` carries no IP/origin; provider toggle kills the EF path; CAPTCHA non-selective). m4: only DB-level CIDR exists (does NOT cover the API origin; narrowing breaks Hyperdrive+pooler) → left open by design. **m1 reduces ENTIRELY to the CF-rule leg = blocked on the CF custom domain (owner)** — and even that rule covers only the custom-domain path; raw-origin external callers remain the recorded §ADR-2 m4 residual. A6 **P1 strict leg must NOT be dispatched** until the CF rule lands. On domain unblock: CF rule + X3b transform + GW1a-H WAF + P1 strict + X3b positive AC1/AC2/AC9 re-run, in one pass.
- [ ] **W10 leftover** — AUTH-011/012/009/006 specs — next-writer
- [ ] **PoC twin re-align** `admin-auth-core.ts` vs prod map — next-impl
- [ ] **LIVE gate RUN** 5 prereqs (handoff `..._06-30`) — 2026-06-11 update from the brew-ops livegate pass:
  - [x] **L3 creds CLOSED** — `investigator_ro` on sinuw (read-only + BYPASSRLS — plain role would read A4-RLS silent zeros; probes verified counts match ground truth; slot `investigator.env` sinuw block added, revert documented)
  - [x] **fault(iii) cadence leg MOOT** — premise stale: impl locked MAX_ATTEMPTS=3 with NO backoff timer → retry exhaustion ≈2 min real-time, verified live on sinuw (121 dead_letter rows, 1:00-1:56 elapsed). No knob needed.
  - [ ] **fault(iii) ALERT half** — gap narrowing: **host DECIDED + RATIFIED 2026-06-11**: owner direction "AWS Fargate, Hetzner dropped" → §ADR-15 §Amendment merged **PR #397** (`a04f9a0`; D1 flip + 2 Consequences strikes, reviewer APPROVE). AWS substrate check: `one-time-grant` + `mb-next-egress-setup` keys alive but policy-stripped (STS ok, zero ECS/IAM perms) — owner attaching `mb-next-keep-setup` policy (JSON handed over in-session). Remaining: (i) P2.12 YAML+runbook per P2.16 exemplar — next-dev, dispatchable NOW; (ii) Keep stand-up on Fargate — brew-ops, fires on policy attach; (iii) interim "alert fired" surface pre-Keep — likely MOOT once Keep stands, else §ADR-15/§ADR-21 amendment — OWNER. Also: §ADR-21 "which alert is the must-page fault" still OPEN (adr.md:4806) — P2.12 natural pick, unpinned.
  - [ ] remaining: MOCK_BANK_URL (bank-bot track) · AR6 review (pending golden-journey re-scope) · owner GO
- [ ] **NEW residual (brew-ops Task-B finding)** — **function EXECUTE posture**: PUBLIC EXECUTE on ~1184 public RPCs incl. SECURITY DEFINER writers; same surface PostgREST exposes. Needs an exposure-lane disposition (revoke PUBLIC EXECUTE / per-fn grants) — next-architect, A3-adjacent.
- [ ] **NEW residual (#394 review finding)** — **VIEW-class exposure**: `v_bank_balance` / `v_payouts` / `v_success_payout_audit` are owner-context views with LIVE anon+authenticated SELECT; views are structurally invisible to the pg_tables sweep (reviewer-confirmed real). Needs an SV-class disposition (revoke / security_invoker / sweep extension over pg_views) — next-architect.
- [ ] **NEW residual (#394 review §5, non-blocking)** — **on-list residue**: the 12 SV6 tables still carry init-default REFERENCES/TRIGGER/MAINTAIN for anon+authenticated (A4 revoked write verbs only; SV7b zero-rule is off-list only). "Zero means zero" on-list for non-SELECT verbs = SV7b scope extension — architect disposition.
- [ ] **NEW follow-up (#395 AUTH-011 flag #3)** — **seed-vs-compiled-map divergence on `user:update`**: A4 seed carries `('super_admin','user:update')` but the compiled `ROLE_PERMISSIONS` map LACKS the string — when the role-assign EF lands (AUTH-011), EF write-RBAC would 403 super_admin. Add `user:update` to the map (or pin the divergence) — next-dev. (Flags #1-#5 full text = PR #395 body; durable record = here.)
- [ ] **mb-next-bank-bot** — other orchestrator's track (PRs #381/#391 open, #389 merged)
- [ ] **finance-audit PR #372** — unowned, still open
