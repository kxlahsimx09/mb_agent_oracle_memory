# Doc Fix-Spec — auth-rbac documentation reconciliation (campaign authdocs)

**From:** next-architect · **To:** next-writer (epic/spec/design items) + next-architect doc pass (adr.md items W1–W6) · **Date:** 2026-06-10
**Authority:** doc reconciliation of already-ratified decisions — **except W1 and W9, which are small ratification-bearing amendments** (catalogue additions + K1 schema fix) flagged as such. Nothing here changes money/auth behavior; the behavior changes live in `next-architect_authsec_spec.md` (code) and `next-architect_authexposure_proposal.md` (owner decision).
**Snapshot:** refs at main `4690345` — re-verify anchors at HEAD; adr.md line numbers drift with every merge.

---

## W1 — Catalogue-add amendment (ratification-bearing; AM7 "NEW action" style) — the F3 list cannot gate the epic's own actions

**Target:** `docs/adr.md` §ADR-13 F3 (catalogue at `:3526-3569`) — one amendment block adding, each tagged NEW-not-port:
- **`user:unlock`** — the LK1 unlock action (`adr.md:210` says "Phase-2 RBAC permission" without naming one). **Canonicalization decision bundled:** the deployed EF enforces **`auth:unlock`** (`admin-users-unlock/index.ts:22`) while ADR/design/spec say the **role** `admin:super` — neither string is in the catalogue, and `auth` is not an F3 resource. ⚑ Lean: follow F3 grammar → mint **`user:unlock`**, change the EF string + `ROLE_PERMISSIONS` in the same PR, and state explicitly that `admin:super` is a **role name** that merely *holds* the permission (the colon-format collision between role names and permission strings deserves its own one-line warning in F3).
- **`user:reset-2fa`** — the G1-D admin reset (`adr.md:47` "super_admin RBAC", unnamed).
- **Role-assignment verb** — ⚑ lean: pin assignment to **`user:update`** (assignment mutates the user row, not the role) rather than minting `role:assign`; state it explicitly so R1 (`adr.md:230`) stops dangling. Phase-tag `role:create/update/delete` as Phase-2-meaningful (roles are hardcoded Phase-1 per `adr.md:40-41`).
- **`security-config:update`** — the S4 step-up posture toggle (`adr.md:89` "Phase-2 RBAC permission", unnamed; no config-class resource exists at all).
- **Regularize `deposit-log:view`** — referenced as "existing" by DR1/DR8 (`adr.md:3682,3689`) but absent from the list; add it as the precedent instance and close the `:2237` drift-audit flag.

**Why:** four ratified auth actions reference permissions that do not exist; the catalogue is treated as closed ("port verbatim") while amendments cite phantom members. Probes and seed migrations built from F3 will 403 (or worse, skip the gate). The L3580 cross-check duty should become a CI-checkable seed-vs-catalogue assertion, not prose — name that in the amendment.

## W2 — Merchant lockout classification (ADR one-word fix; epic already correct)

**Target:** `docs/adr.md` LK2 (`:211`) — "client / sub-client / partner web" → add **merchant**. The epic already classifies merchant as external/soft-lock (`epic-auth-rbac.md:287`) and the substrate hard-locks only `admin` (`login-support.ts:120-122`) — the ADR is the odd one out. Fix the spec mirror too: `docs/spec/auth-005-login-security-slice.md` §1 regime table (the spec's own AC6 at `:74` already includes merchant; its §1 table contradicts its own AC).

**Why:** the only place merchant's lockout regime is *missing* is the ratified ADR line everyone will cite. One word closes a tier-classification hole for a real tier (29 merchant accounts in prod).

## W3 — Lock-substrate reconciliation paragraph (EA3 vs LK1)

**Target:** `docs/adr.md` — EA3 (`:166`) asserts the lock rides "gotrue's `banned_until`"; LK1 (`:210`) ports `is_locked = true` with "NO TTL" and defers the substrate (`:217`). The deployed code reconciles them (far-future ban `FAR_FUTURE_BAN = "876000h"` + `is_locked` projection — `auth-login/index.ts:32,144-192`). Write one reconciliation note on LK: *substrate = gotrue `banned_until` (far-future sentinel ⇒ LK1 "no TTL"; window-length ban ⇒ LK2), with `app_user.is_locked/locked_at` as the operator-visible projection* — and mark EA3's parenthetical as consistent-with rather than competing.

**Why:** two ratified texts name two substrates; the implementation quietly picked the right synthesis — record it before someone "fixes" one side to match the other.

## W4 — Dangling "§ADR-2 base C4/C5" referents

**Target:** `docs/adr.md` ADR-2 base (`:14-41`). Amendments and the epic cite "base C4" (DB-fresh) ~6× (`:55,:124,:154,:176,:198,:200`) and "base C5" (platform rate-limit) ~5× (`:51,:166,:176,:207,:221`); the epic Sources cite them too (`epic-auth-rbac.md:305`). **No C-labels exist in the base text.** ⚑ Lean: add a small labeled-clauses block to the base (C1 identity store · C2 entity_type/claims · C3 RLS-isolation-not-RBAC · **C4 DB-fresh authorization** (`:39`) · **C5 platform sign-in rate-limit** (`:21`)) rather than rewriting ~11 call sites.

**Why:** the single most-cited auth principle (C4) is currently unquotable; every new amendment keeps citing a ghost.

## W5 — F4 supersession + layer-vocabulary cleanup

**Target:** `docs/adr.md` F4 (`:3595-3598`) — the "Phase-1 = Layer 1 + 2; Layer 3 RLS deferred Phase-2" enforcement list is superseded by the 2026-06-07 RLS amendment (`:3725,:3729`) but carries **no inline marker**: edit in place per the §H3-Fix precedent. Add a one-line note on DR6 (`:3687`) that the `WHERE client_id=` filter is the defense-in-depth layer, RLS authoritative. Adopt the epic's disambiguation (`epic-auth-rbac.md:194`) as the canonical vocabulary — *"app-scope check (defense-in-depth)" vs "RLS (authoritative)"* — and state which layer owns the contract-visible failure mode (403 = app layer; RLS alone yields empty sets — F4's "403 + structured error" promise at `:3586` is only deliverable app-side; say so).

**Why:** a reader implementing from F4 alone ships the withdrawn Phase-1; three colliding "Layer 1" numbering schemes already forced the epic to carry a disambiguation note — promote it to the ADR.

## W6 — ADR-2/7 stale-text strikes (mechanical)

**Target:** `docs/adr.md`:
- ADR-7 base (`:1993-2001`): title still "via Edge Function Middleware"; "Rate limiting … via Postgres counter" superseded by GW5/§ADR-11-A3 (`:131,:122`) — extend the `:2003` relocation pointer to cover rate-limiting; strike-mark the Postgres-counter line.
- GW4 (`:130`): shared-secret prose vs the same bullet's Ed25519 sub-refinement — strike the shared-secret/rotation text; also fix the Deferred list (`:152`) still naming "token format" + "request_hash" as open (both resolved inside `:130`).
- S2 set (`:86` "exactly {refund · DTR · settlement}") vs the 05-31 pullout extension (`:87`) — reconcile to the five-member set; fix K3's "S2 is money-out only" (`:2012`) to acknowledge the config-write member.
- GW1a-H heading (`:180`) carries date 2026-05-28 with ratification 2026-06-10 — add the ratified-date to the heading so chronological scans don't mis-order the topology history; define "GW1a/GW1b" labels at their source (`:127`).
- F1 (`:3480`) "JWT signed by mobiz" → gotrue-signed.
- `:2088` "§ADR-7 session-token revocation primitive" → re-point at AUTH-008/gotrue sessions (ADR-7 has no such primitive).
- Base `:21` "Eliminates … brute force protection" — annotate with a pointer to the LK amendment (custom lockout exists by design).

## W7 — Spec/design post-cutover reconciliation

**Targets:**
- `docs/spec/auth-login-build-slice.md:251-252` — **strip the committed `</content>` / `</invoke>` tool-call artifacts** from the authoritative build contract; also fix ":222 four new EFs" → six (its own §1 lists six), and the stale ":207 d8/d9/d10 probes NOT in this tree".
- `docs/design/auth-login/02-jwt-flip.md:3-5` "Today … stub decode" + `:33-34` shim rationale — mark superseded by the NO-SHIM GO the same file records at `:94-95`.
- `docs/design/auth-login/README.md:32` `auth.mfa.list_factors` → the `ccd7608` reality (`GET /auth/v1/user` factors; there is no GET list-factors route).
- `docs/design/auth-login/01-login-ef.md:54-56` admin-path enroll guidance vs deployed user-scoped enroll — update per authsec X5's pinned delete-unverified-and-re-enroll behavior; `:71-73` "don't mint fresh secret" reworded to the X5 form.
- `docs/spec/auth-001-002-login-2fa-slice.md`: drop the impossible 409 `user_already_registered` login-response row (`:77`); fix `users.*` → `app_user.*` observables (`:93`); define "attempt" across the two-step so AC1's one-row-per-attempt is probe-able (challenge leg unaudited per design `01:141-143`; verify leg = `mfa_verify`+`login_success` two-row success shape — pick and pin).
- `docs/spec/auth-005-login-security-slice.md`: IP-header "deferred" (`:32-33`) → pinned `CF-Connecting-IP` (build-slice `:147`); AC6 "virtual clock" → shrunken `soft_window` mechanism (per authsec X7); unlock permission string per W1.
- GH3 `iss`-flip activation ordering (`adr.md:192`) → add to the build-slice §6 deploy notes + `docs/runbooks/edge-function-deploy.md` (today it lives only inside the ADR amendment; a mis-sequenced cutover 401s every human request).

## W8 — AUTH-003 "roles are data" phase-tag (epic)

**Target:** `docs/requirements/epic-auth-rbac.md` AUTH-003 AC (`:188`) — "*admin changes a role's permissions → applies immediately*" is **Phase-2** behavior (Phase-1 = hardcoded set, the epic's own edge `:196`; substrate = compile-time `ROLE_PERMISSIONS`, `admin-auth.ts:43-61`). Tag the AC `[Phase-2 — role-content editing]` and add the Phase-1-testable sibling: *role re-assignment* (AUTH-011 R1) takes effect next request. Mirror in `docs/spec/auth-003-004-rbac-tenant-scope-slice.md` (`:76` probe edits a role in the DB — unexecutable; `:77` example strings `tasks:*`/`logs:view` don't exist — swap for real catalogue members).

## W9 — K1 API-key rotation made implementable (ratification-bearing, small)

**Target:** `docs/adr.md` §ADR-7 K1 (`:2010-2015`) — as written, rotate-with-overlap is structurally impossible: single `api_key/api_key_secret` pair (`:2013`) + GW6 lazy-reload-from-Postgres (`:132`) kills the old key instantly, and "store **hashed**/encrypted" is half-broken (hashing is incompatible with HMAC verify + KV secret caching). Amend: **two-slot schema** (`active` + `retiring`, `retire_at`), **encrypted not hashed**, and the KV/`/internal/invalidate` handling for the pair. Then AUTH-010's spec can be authored (it is currently spec-less and blocked on this).

## W10 — Spec authoring queue (gap closure, post-W9)

Six S2 stories have **no spec slice**: AUTH-006 / **008** / 009 / **010** / 011 / 012. Priority order: **AUTH-008** first (the per-token blacklist carry-over `jwt.go:301` is ratified-must-not-drop (`epic:299,:447`) and currently exists nowhere — also a dependency of AUTH-012's session-cut), then **AUTH-010** (post-W9), then 011/012/009/006. Reuse the auth-001-002 §0 substrate verbatim.

---

## Done-when

1. `grep -c "C4\|C5" docs/adr.md` resolves against defined labels; no dangling base refs.
2. F3 catalogue + seed/`ROLE_PERMISSIONS` agree (CI assertion named in W1); `admin-users-unlock` enforces the canonical string.
3. LK2 names merchant; LK carries the substrate note; F4 carries the supersession marker.
4. No `</content>`/`</invoke>` in any spec; design docs carry no "Today = stub" framing.
5. AUTH-003 AC phase-tagged; auth-001-002/005 spec observables match `app_user` + pinned mechanisms.
6. K1 amendment ratified; AUTH-008 + AUTH-010 specs authored.
