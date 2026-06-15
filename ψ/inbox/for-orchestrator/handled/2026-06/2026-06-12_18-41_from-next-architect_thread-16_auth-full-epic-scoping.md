# next-architect → orchestrator — SCOPING: AUTH epic L5 expansion to FULL (AUTH-001..012)

**Thread:** #16 · **Date:** 2026-06-12 · **needs_response:** owner go/no-go on the build wave (analysis-only; NO building started)
**Grounded against truth:** code-at-HEAD (supabase/ + functions/ + poc/, subagent-inventoried + spot-verified), the 2026-06-10 next-investigator auth-rbac epic-seal record, `ψ/memory/auth-hardening-2026-06/STATUS.md`, the 12 spec slices on main.

---

## 1. Per-story status map (verified)

Legend — Build: DONE / PARTIAL / NONE · Verify: probes/tests exist? · Seal: in the 2026-06-10 epic-seal?

| Story | Spec | Build | Verify | In 06-10 seal? |
|---|---|---|---|---|
| **AUTH-001/002** login + mandatory 2FA | ✓ | **DONE** | sealed (real gotrue/TOTP) | **YES — GREEN** |
| **AUTH-003/004** RBAC + tenant RLS | ✓ | **DONE** | sealed | **YES — GREEN** |
| **AAL2 EF enforcement** | ✓ | **DONE** | sealed | **YES — GREEN** |
| **AUTH-005** lockout · IP-allowlist · 2-tier rate-limit | ✓ | **DONE** (X1–X6,F1 — #377/#378/#379; `auth-login`+`admin-users-unlock` EFs, `lockout-support.ts`, `ip_in_allowlist` RPC) | **DONE-ish** (X7 37-AC + 5 neg probes #378; not in the std poc probes dir) | **NO** |
| **AUTH-006** machine HMAC @ edge + bot-tier | ✓ (#395) | **PARTIAL** — bot-tier DONE (`verify_bot_request`, `bot_credentials` two-slot, `bot-auth.ts`); **client-HMAC-at-CF-edge = substrate only** (`client.api_key_secret`), the CF Worker build/deploy/verify **BLOCKED on the CF custom domain (A3/F3, owner)** | bot-tier verify thin; client-edge blocked | **NO** |
| **AUTH-007** admin money-out step-up | ✓ | **DONE** (X6 #377; `auth-step-up-verify` + `auth-step-up-posture` EFs, `step-up.ts`, 4 tables) | **PARTIAL** (RBAC tested; no dedicated step-up-flow probe) | **NO — explicitly OUT of seal scope** (deposit money-out is AAL2+RBAC; step-up purposes = refund/transfer/settlement/pullout) |
| **AUTH-008** logout · session · refresh rotation · per-token blacklist | ✓ (#383) | **NONE** — gotrue covers base session only; the AUTH-008 build (logout EF, `revoked_tokens` blacklist + EF-side check, refresh-rotation) is **unbuilt** (no table, no EF — truth-confirmed) | **NONE** | **NO** |
| **AUTH-009** password recovery (no leak) · change-pw re-proof · strength | ✓ (#395) | **NONE** — gotrue email-link base exists; the AUTH-009 wrappers (no-existence-leak, current-factor re-proof gate, strength policy) **unbuilt** | **NONE** | **NO** |
| **AUTH-010** client API-key rotate (two-slot) · revoke · once-shown | ✓ (#393, K1a–c) | **PARTIAL→NONE** — `client.api_key_secret` column only; **client two-slot table + rotate/revoke RPC + EF unbuilt** (the `bot_credentials` two-slot is a different tier) | **NONE** | **NO** |
| **AUTH-011** role-assign (immediate) · deletion-teardown · orphan-deny | ✓ (#395) | **PARTIAL** — RBAC substrate + **orphan-deny + immediate-effect (C4) are built & SEALED via 003/004**; the **role-ASSIGN write EF + role-deletion-teardown are unbuilt** (STATUS.md flag #3: "when the role-assign EF lands") | RBAC sealed; assign-action NONE | **partial** (orphan-deny in seal; assign-action NOT) |
| **AUTH-012** account disable/enable/offboard · status login-gate · session-cut | ✓ (#395) | **NONE** — no `account_status`/`business_status` column, no disable EF; login gates only on `is_locked`/`banned_until` (AUTH-005) | **NONE** | **NO** |

**Headline:** all 12 have specs. Built+sealed: 001–004 + AAL2. Built-but-unsealed: **005, 007, 006(bot-tier)**. Unbuilt (spec-only): **008, 009, 010(client), 011(assign+teardown), 012**. External-blocked: **006(client-edge)** on the CF domain.

---

## 2. Gap-to-full-epic

### (a) Per-story: build vs verify vs seal-fold-only
- **Seal-fold-only (built, just needs sealing + light verify):** **AUTH-005** (lockout — built + X7-verified), **AUTH-007** (step-up — built), **AUTH-006 bot-tier**. → minimal/no new build; investigator re-derives on the live deploy + a couple probes.
- **VERIFY-needed (build done, probe thin):** AUTH-005 (fold X7 onto the seal stack), AUTH-007 (a step-up-flow probe: money-out requires fresh purpose-scoped TOTP, fail-closed), AUTH-006 bot-tier (mint→HMAC-verify→replay-reject probe).
- **BUILD-needed (spec-only today):** **AUTH-008** (logout EF + `revoked_tokens` blacklist + EF-check + refresh-rotation), **AUTH-009** (recovery-no-leak + change-pw re-proof + strength — lighter, gotrue-config-heavy), **AUTH-010** (client two-slot table + rotate/revoke RPC + EF), **AUTH-011** (role-assign EF + deletion-teardown — uses `user:update`, the seed-vs-map `user:update` fix is the prereq, STATUS flag #3), **AUTH-012** (`account_status` + disable/enable EF + login-gate + session-cut wiring into 008's blacklist).
- **External-blocked:** **AUTH-006 client-edge** — the CF Worker HMAC + per-client rate-limit can't be built/verified/sealed until the **CF custom domain** lands (owner). *Scoping decision needed* (see §4).

### (b) What an EXPANDED epic-seal must cover (001–012 + deny-properties)
The investigator re-derives, on the live deploy, **per story**: the positive (happy) path AND the deny/negative properties. The **deny-properties already sealed for 001–004+AAL2** (aal1→401, RBAC-deny, cross-tenant=0, gotrue alg-confusion-reject) STAY; the expansion adds, per story:
- 005: N-fails → locked → `banned_until` gate → super-admin unlock clears; soft-window auto-expiry; IP-allowlist CIDR deny.
- 006: valid HMAC accepts; bad-sig/expired-replay/account-mismatch reject (bot-tier; client-edge when unblocked).
- 007: money-out **requires** a fresh purpose-scoped grant; stale/replayed/wrong-purpose grant → 423; fail-closed when posture off.
- 008: logout → token blacklisted → protected EF 401; refresh rotation; idle timeout.
- 009: recovery returns identical response for existent/non-existent (no leak); change-pw requires current-factor re-proof; weak-pw rejected.
- 010: rotate → both slots valid during overlap → old slot revoked → 401; once-shown secret; tenant-scope.
- 011: assign role → next request reflects it (immediate); delete role → orphaned users deny-by-default; single-valued.
- 012: disable → login blocked + active sessions cut (008 blacklist); re-enable restores; status-gate distinct from lockout.

### (c) FULL-epic AUTH LIVE journey delta + the CE3-amendment question
Today's run (the deposit front door) proves the auth **HAPPY PATH** live (login→TOTP→aal2→RBAC), and CE3 ruled the auth **DENY** properties stay **seal-covered** (LIVE layers on top, Honest limit 6). **A FULL-epic auth L5 forces a choice:**
- **Option (i) — seal-does-coverage (recommended, §ADR-21-native):** keep the LIVE journey representative (deposit front door + a few auth legs); the **expanded SEAL** carries the 001–012 + deny coverage. The auth L5 = expanded-seal + ACCEPT. **CE3 holds essentially as-is** (the deposit run still feeds the auth-happy-path L5; the seal now covers more). Smallest LIVE surface.
- **Option (ii) — LIVE exercises the full surface:** add **live deny-legs + lifecycle legs** to an auth-specific LIVE journey (lockout-trip-live, step-up-required-live, disable-blocks-login-live, api-key-revoke-401-live, role-orphan-deny-live). This **DOES need a CE3 amendment** — the composed-epic gate's "deposit run feeds the auth L5" was scoped to the **sealed happy-path** AUTH-001..004+AAL2; a full-epic auth L5 with live deny/lifecycle legs is a NEW, auth-specific journey beyond the deposit front door.
- **My lean:** Option (i) for the gate (seal does coverage; §ADR-21 Honest limit 6), with a **small set of de-theatering live deny/lifecycle legs** (lockout-trip, step-up-required, disable-blocks-login) added to the auth journey for owner-confidence — which is a **bounded CE3 amendment** (the auth L5's representative journey gains a handful of named live legs; the rest stays seal-covered). Decide at go-time.

### (d) Phased plan + rough lane count + sequencing
- **Phase 0 — prereq (1 lane, fast):** land the `user:update` seed-vs-map fix (STATUS flag #3) — blocks AUTH-011's role-assign EF write-RBAC. *(May already be in flight — verify.)*
- **Phase A — fold the BUILT stories (≈1–2 lanes):** probes for AUTH-005 (lockout/IP/soft-window) + AUTH-007 (step-up flow) + AUTH-006 bot-tier → re-mint onto the seal stack. (next-tester; ~0 new dev build.)
- **Phase B — BUILD the unbuilt (≈4–5 lanes, the bulk):** **008**+**012** = the session/account axis (compose — 012's session-cut wires 008's blacklist; build together, ~1–2 lanes); **010** client two-slot rotate/revoke (~1 lane); **011** role-assign + deletion-teardown (~1 lane, after Phase 0); **009** password recovery/change/strength (~1 lane, lighter/gotrue-config-heavy). Each = next-dev build + next-tester verify (specs already exist → no spec lane).
- **Phase C — EXPANDED epic-seal (1 lane, the gate):** next-investigator re-derives 001–012 + all deny-properties on the live deploy → the expanded auth epic-seal GREEN. (G1 prereq for the auth LIVE.)
- **Phase D — FULL-epic auth LIVE + CE3 (≈1–2 lanes):** next-live-tester adds the chosen live legs (Option i/ii); next-architect lands the (bounded) CE3 amendment if live deny/lifecycle legs are added; owner signs the auth L5.

**Rough total: ~8–10 work-streams across Phases 0/A→B→C→D**, sequenced (0 before 011; A/B parallel; C after A+B; D after C). **Campaign-sized — matches the owner's framing.** External long-pole: AUTH-006 client-edge (CF domain).

---

## 3. Key facts for the owner's decision

- **Nothing is wasted:** today's AUTH-001..004 happy-path LIVE evidence folds into the expanded epic-LIVE (the seal grows; the run's auth front door remains valid).
- **The bulk of the work is Phase B (5 unbuilt stories)** — this is the campaign. 005/006-bot/007 are already built (just unsealed); 011 is half-built (orphan-deny sealed, assign-action unbuilt).
- **AUTH-006 client-edge is the long-pole external blocker** (CF custom domain). The owner must decide whether the FULL auth epic L5 (a) **requires** the client-edge leg (→ blocked until the domain lands) or (b) **carves it out** as a domain-gated follow-up (seal AUTH-006 bot-tier + name the client-edge as a deferred leg, the way the 06-10 seal already carved out deferred stories). **Recommend (b)** — don't let the CF-domain block the whole auth epic.
- **AUTH-008/009** are partly gotrue-delegated — confirm scope (how much is "build a wrapper/blacklist" vs "verify gotrue config") to size Phase B accurately; AUTH-008's per-token blacklist is the real build, AUTH-009 is lighter.

---

## 4. Recommendation (for the owner's go/no-go)
1. **GO** on the build wave — but **carve out AUTH-006 client-edge** (CF-domain-gated follow-up) so the epic isn't held by the domain.
2. **LIVE coverage = Option (i)** (seal does coverage) **+ a bounded set of de-theatering live legs** (lockout-trip, step-up-required, disable-blocks-login) → a **small CE3 amendment**, decided at go-time.
3. **Sequencing:** Phase 0 (`user:update` fix) → A (fold 005/006-bot/007) ∥ B (build 008/009/010/011/012) → C (expanded seal) → D (auth LIVE + CE3 + owner ACCEPT). ~8–10 lanes.
4. **Independent:** the DEPOSIT RM-fix + AXIS-1 re-run proceeds in parallel; the deposit L5 is not blocked on this auth expansion.

*Analysis/planning only — no building started, no ADR amendment authored (the CE3 amendment lands only on owner GO for Option ii/the live legs).*

handled_at: 2026-06-12T20:05:00+07:00
handled_by: orchestrator-buildteam-wt26 (stale — campaign already launched)
