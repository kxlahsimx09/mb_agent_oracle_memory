# Builder Fix-Spec — auth lane security-material gaps (campaign authsec)

**From:** next-architect · **To:** next-dev (X1–X6) + next-tester / next-investigator (X7) · **Date:** 2026-06-10
**Authority:** NO new ratification needed — every item reconciles deployed code to an **already-ratified AC/decision** (epic-auth-rbac.md + §ADR-2 G1-D/G4-D/G5-D + §Amendment 2026-06-07 LK + §Amendment 2026-05-26 S3/S4). Items marked ⚑ carry a pinned lean where the ratified text under-specifies; flag-to-architect if you disagree, do not silently choose otherwise.
**Context:** post-seal review found the keystone seal (`2e8c0ad`) sound within its claims but several ratified auth controls are **phantom or bypassable** in the deployed substrate. These are the code-side closures. Companion docs: `next-architect_authexposure_proposal.md` (owner decision — exposure posture; do NOT start m-items before GO) + `next-architect_authdocs_spec.md` (doc pass).

> **Scope:** code + the two spec files named in X6. Line refs are a snapshot at main `4690345` — re-verify anchors at HEAD. Do not re-do what `ccd7608` already fixed (listFactors via `GET /auth/v1/user`, strict-aal in admin-auth, MFA TOTP config.toml).

---

## X1 — Count 2FA failures into the account lockout (unbounded-TOTP-guessing closure)

**What:** `supabase/functions/auth-2fa-verify/index.ts` — on a wrong TOTP code: increment the same per-account failed-attempt path `auth-login` uses (`registerFailedAttempt`, `_shared/login-support.ts:144-192` — export/share it; same two-regime trip: admin → hard ban, external → soft window), write exactly one failure audit row for the attempt, and **reset the counter on successful verify** (mirror the login-success reset). The counter lives on `app_user` (`20260609000001:74-83`).

**Why:** ratified AUTH-002 AC (`epic-auth-rbac.md:134`): *"the account's failed-attempt counter increments… **the same is true for a wrong second-factor code**."* Today `auth-2fa-verify` never touches the counter → an attacker holding a valid AAL1 `temp_token` (password already known) can guess TOTP **unbounded**; the account never locks. This was probe-visible but unprobed (no 2FA-failure-lockout AC probe exists — X7 adds it).

**⚑ Pinned lean:** no separate per-`temp_token` retry budget in Phase-1 — the account counter IS the bound (5 → lock per LK). A future per-token bound is optional hardening, not required by any ratified text.

## X2 — gotrue 429 must not corrupt the lockout counter + implement the audited rate-limit tier

**What:** `supabase/functions/auth-login/index.ts:64-68` — the generic `authErr` branch swallows gotrue rate-limit errors. Branch explicitly on gotrue's rate-limit signal (HTTP 429 / `over_request_rate_limit`): return **429** with one **`login_rate_limited`** audit row written **before** the response, and **do NOT increment `failed_login_attempts`** and do NOT write `login_failure_wrong_password`. All other auth errors keep current behavior.

**Why:** two ratified texts at once. (a) AUTH-005 AC3 (`epic:284`): rate-limited attempt → *"an audit record is still written before the rejection"* — G4-D's one-row-before-429 invariant (`adr.md:53`); the string `login_rate_limited` is named by G4-D and even by the migration's own comment (`20260609000001:14-17`) yet **zero code writes it** — a phantom control, misfiled as ENV in the 26/37 run. (b) Counter integrity: today a rate-limited burst **with the correct password** increments the counter (gotrue limit `sign_in_sign_ups = 30`/5min/IP, `config.toml:156`) → griefing path: anyone can lock any account through the 429 window, and the audit trail records the wrong outcome class.

## X3 — IP-allowlist: enforce on authed EFs, harden the header, support CIDR

**What:**
1. **(a) Authed-EF enforcement:** add the per-account IP-allowlist gate to `adminAuth` (`_shared/admin-auth.ts:95-126`) per the ratified G5-D chain *"gotrue JWT verify → IP allowlist → RBAC → handler"* (`adr.md:55`); `auth-2fa-verify` gets it too. Read the same `*_profiles.allowed_ips` the login gate reads.
2. **(b) Header trust:** `extractClientIp` (`login-support.ts:41-47`) currently trusts `CF-Connecting-IP`/`X-Forwarded-For` from ANY caller while the raw `*.supabase.co` origin remains reachable → the allowlist is spoofable end-to-end. Trust `CF-Connecting-IP` only when the request provably traversed our CF zone (CF-injected secret header validated EF-side; coordinate the header secret with brew-ops). When the CF marker is absent, fall back to the platform-provided peer-IP header, never to a client-suppliable one. *(The broader "should the raw origin stay reachable at all" question is the exposure memo's m4 — do not block on it; this item makes the allowlist non-spoofable regardless.)*
3. **(c) CIDR:** `ipAllowed` (`login-support.ts:51-58`) is exact-string match; a CIDR entry in `allowed_ips inet[]` (`20260609000001:31`) silently never matches. Match via inet containment (`ip <<= any(allowed_ips)` semantics — small RPC or SQL-side check), and document that single IPs and CIDRs both work.

**Why:** AUTH-005 AC2 (`epic:283`) + AC9 (`epic:290` — *"the IP allowlist and role both reflect current state"* on every request) are ratified; today the allowlist runs **only at login**, off a spoofable header, with a dead-letter CIDR shape the migration itself advertises.

## X4 — Ordering: IP gate before counter reset

**What:** `auth-login/index.ts` — today a correct password **resets the failed counter** (`:75-78`) **before** the IP-allowlist gate (`:87-96`). Reorder: lock pre-check → password verify → **IP gate (refuse + `ip_blocked` audit, no counter mutation)** → counter reset → 2FA branch.

**Why:** an off-allowlist attacker who knows the password can today silently reset the victim's lockout counter forever (defeating LK on exactly the stolen-credential scenario the allowlist exists for). No ratified text permits a counter mutation on a refused attempt; AUTH-005 AC1 (`epic:282`) requires the refused attempt audited with the `ip_blocked`-class outcome.

## X5 — Retried first-login enrollment returns a malformed payload (G1-D factor-reuse)

**What:** `auth-login/index.ts:105-112` unconditionally calls `mfa.enroll` on the enroll branch. On a **retried** first login (unverified TOTP factor already exists), gotrue either errors (→ EF returns old `factor_id` with `qr_code_url`/`secret` **undefined** — malformed contract payload) or mints a stray second factor. Fix: when an **unverified** factor exists for the user, **delete it and enroll fresh** in one pass, returning a complete `{requires_2fa_setup, temp_token, factor_id, qr_code_url, secret}` payload every time. Never touch a **verified** factor on this path.

**Why:** the two-step response shape is a ratified contract (epic AUTH-002 edge `:141` — the mobiz "silent shape flip broke 35 tests" lesson). **⚑ Pinned lean (deviation from design doc):** `01-login-ef.md:71-73` says "do not mint a fresh secret on a retried first-login" — unimplementable as written (gotrue cannot re-read an existing factor's secret). Delete-unverified-and-re-enroll is the safe equivalent (the factor was never verified; no security downgrade). The doc pass (authdocs W7) updates the design text; this spec pins the behavior.

## X6 — AUTH-007 step-up: stop presenting an unwired gate as live; wire what exists; audit the lockout trip

**What:**
1. **Spec re-scope** (`docs/spec/auth-007-step-up-slice.md`): mark AC1 / S4-a / S2-c **BLOCKED-on-consumer** — `requireStepUp` (`_shared/step-up.ts:91-102`) has **zero call sites**; the anchor consumer (deposit refund) is DEPOSIT-011 Phase-2-deferred. Add the binding rule: *every consuming slice's Step-0 spec MUST carry a named `requireStepUp`-wiring AC* (so wiring can't be silently skipped), and name the first real Phase-1 consumers when they land (pullout drain-config write per §S2 extension `adr.md:87`; settlement EFs).
2. **Audit the 423 lockout trip:** `auth-step-up-verify/index.ts:38-40` returns 423 writing nothing; `registerStepUpFailure` (`step-up.ts:35-44`) writes nothing at the threshold crossing. Ratified AUTH-007 spec line (`auth-007:92`) requires audit rows on the trip — write one `step_up_lockout_tripped` row at the crossing (one, not per-attempt).
3. **⚑ Config constants:** `step-up.ts:18-20` hardcodes threshold/window/grant-TTL; ratified text says baseline-but-configurable (`auth-007:78`, S3 `adr.md:88`). Move to a config row (the `step_up_posture_config` table pattern). Small; do it while in the file.

**Why:** "fail-closed by default" currently protects nothing — the posture engine is sealed but no gate consumes it. The spec presenting AC1 as live behavior is exactly how the 26/37 red got misread.

## X7 — Tester / investigator gate (re-run + de-bias + re-seal criteria)

**What (next-tester):**
1. **Full 37-AC re-run** vs staging at main HEAD (post-`ccd7608`, post-RLS `20260609000010`, post X1–X6): required green = auth002 AC2 (returning-user challenge) + auth004 AC1/3/4/5 (RLS) + the X1/X2 behaviors. Commit evidence.
2. **New negative probes:** (i) validly-signed **aal-less** token vs `adminAuth` AND `gotrueAuth` (parity — the `ccd7608` hardening has no regression net); (ii) 2FA-failure-lockout (wrong TOTP ×5 → account locked per regime); (iii) gotrue-429 leg (burst to 429 → assert 429 + `login_rate_limited` row + counter UNCHANGED); (iv) spoofed `CF-Connecting-IP` against the allowlist via the raw origin (must NOT bypass post-X3); (v) LK2 soft-lock auto-expiry via a shrunken `auth_lockout_config.soft_window` — **pin this as the sanctioned mechanism** and fix the spec text that says "virtual clock" (`auth-005:74` — no virtual-clock indirection exists in auth EFs; wall-clock + shrunken window is the testable form).
3. **De-bias:** each new probe must demonstrably FAIL against the pre-fix behavior (point at old code path or assert strictly).

**What (next-investigator, re-seal):** re-adjudication rule — **no red AC may be classed ENV/SEAM without code-level proof** (auth002 AC2 + auth005 AC3 were both real bugs misfiled under the old rule); add a **config-drift precondition** to any future seal: deployed gotrue config == committed `config.toml` (MFA TOTP on, verify_jwt map), wired into the §ADR-21 L4 evidence capture.

**Why:** the fix chain (`ccd7608` → X1–X6) currently ends in *predictions* of green; the seal record's epistemic gap was scope-overread + red-misclassification — these two rules close both.

---

## Done-when

1. Wrong-TOTP ×5 locks the account (regime-correct); successful verify resets the counter.
2. gotrue 429 → HTTP 429 + one `login_rate_limited` row + counter unchanged; `grep -rn "login_rate_limited" supabase/functions` ≥ 1 write site.
3. `adminAuth` chain = JWT → IP-allowlist → RBAC; spoofed `CF-Connecting-IP` from a non-CF path does not pass; CIDR entries match.
4. Off-allowlist + correct password: refused, `ip_blocked`-class audit, counter NOT reset.
5. Retried first-login returns a complete enroll payload every time; no stray verified-factor mutation.
6. `auth-007` spec carries BLOCKED-on-consumer markers + the wiring-AC rule; 423 trip writes one audit row; step-up numbers read from config.
7. 37-AC re-run committed green (or red with code-level adjudication), new probes in `tests/integration/probes/auth/`, de-bias section updated.
