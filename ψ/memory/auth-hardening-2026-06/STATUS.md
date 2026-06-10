# Auth/Deposit hardening — preserved architect docs + STATUS index

Preserved 2026-06-11 from gateway-repo-root untracked docs + /tmp team reports (both ephemeral) so the full change-lists survive. Gateway @ main `530f5c0`. Cross-ref handoffs `2026-06-10_06-30_...live-prep-session` + `2026-06-10_06-46_mb-next-bank-bot-plan...`.

## Files here
- `next-architect_authexposure_proposal.md` — exposure decision (A1-A6). DECIDED, owner GO; propagation NOT started.
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

## ⬜ PENDING (NOT started — for the next session)

### authsec residuals (env/coverage, proven in X7 — code is sound)
- [ ] **F2** gotrue-429 tier unverifiable over the wire (internal EF→gotrue call not IP-rate-limited; never 429s at volume) → needs a gotrue sign-in-rate-limit lever (brew-ops/dashboard) OR an EF unit test of `isRateLimited()` + the one-row-before-429 write.
- [ ] **F3** X3b positive "on-list-proceeds" leg blocked on the **deferred CF transform** (= the deferred CF custom domain). Spoof-CLOSED leg is GREEN. Re-run AC1/AC2/AC9 positive legs on sinuw/prod once the CF transform injects `cf-zone-secret` + a real `CF-Connecting-IP`.
- [ ] **F4** `admin-users-unlock` (AUTH-005 AC7) + `admin-deposit-refund` (AUTH-007 gated money-out) NOT deployed on qnccph (404). Deploy admin-users-unlock for AC7 coverage; refund EF is X6-acknowledged Phase-2-deferred.

### authexposure — Phase 2 (DECIDED, owner GO; propagation NOT started)
- [ ] **A1** §ADR-2 amendment (m1 EF-only-credential-path · m2 aal2 gate · m4 raw-origin residual · composed-failure) — next-architect
- [ ] **A2** §ADR-13 amendment — partial reversal of A3: read-RBAC INTO RLS (split-by-verb), write-RBAC stays EF (the load-bearing one) — next-architect
- [ ] **A3** CF zone + gotrue config (m1 block password-grant, m4 origin restriction) + the X3b `CF_ZONE_SECRET` transform rule + staging verify — brew-ops + next-dev
- [ ] **A4** RLS migration: m2 aal2 predicate + m5 tenant resolver + m3 read-RBAC per table (`has_read_perm`, row-level) + revoke `authenticated` write grants + seed `role_permissions` from `ROLE_PERMISSIONS` + pgTAP — next-dev
- [ ] **A5** epic/spec touches: AUTH-002 (temp_token cannot-read AC), AUTH-003 (read-RBAC-in-RLS), AUTH-004 (aal+resolver), AUTH-005 — next-writer
- [ ] **A6** probe additions fold into the X7 re-run — next-tester

### authdocs — W1-W10 (doc reconciliation; W1 + W9 ratification-bearing)
- [ ] **W1** §ADR-13 F3 catalogue-add (5 perms: user:unlock, user:reset-2fa, role-assign→user:update, security-config:update, deposit-log:view) — ratification-bearing — next-architect
- [ ] **W2** LK2 add merchant · **W3** lock-substrate reconcile (gotrue banned_until ↔ is_locked) · **W4** C4/C5 labels · **W5** F4 supersession · **W6** ADR-2/7 stale strikes — next-architect adr.md
- [ ] **W7** spec/design post-cutover reconcile (incl. strip `</invoke>` artifacts) · **W8** AUTH-003 phase-tag — next-writer
- [ ] **W9** §ADR-7 K1 API-key rotation (two-slot, encrypted) — ratification-bearing — next-architect
- [ ] **W10** spec authoring queue: AUTH-008 (per-token blacklist) first, then AUTH-010 (post-W9), 011/012/009/006 — next-writer

### Cross-cutting
- [ ] **mb-next-bank-bot** + statement-auto-match golden journey (handoff `..._06-46`)
- [ ] **LIVE gate RUN** 5 prereqs (handoff `..._06-30`)
- [ ] **CF custom domain** (blocks F3 + GW1a-H WAF) — owner getting a domain
