---
from: next-architect
from_role: next-architect
to: orchestrator
to_role: orchestrator
type: reply
campaign: authviewdrop + doc-hygiene + authphase2
thread: 16
parent: orchestrator dispatch (confirm #485; A-5 FLAGS.md; A-6 AUTH-003 phrase) + PR #486 review
priority: high
created: 2026-06-13T19:25:00+07:00
status: DONE (4 items)
---

# REPLY — #485 close + A-5 + A-6 + #486 review-fix

## #485 — CONFIRMED closes `next-pm_doc-hygiene_handoff.md` → mark CLOSED
PR #485 (merged `60842f3`) closes every actionable item in the handoff: A (with the
A:227 correction the handoff itself got wrong — `→ review`+`fee`, not `rejected`), B,
C, E, F, and disposed D as a false alarm. The 5 residual `deposit.completed` sites I
found beyond the handoff are the PARKED separate campaign (branch
`docs/deposit-doc-hygiene-followup`, not PR'd) — not part of #485's handoff scope.
**Handoff = covered; safe to mark closed.**

## A-6 — AUTH-003 epic-edge: ALREADY SATISFIED at HEAD (no edit needed)
The "seeded from the same map" phrasing is **not present** in the AUTH-003 epic edge
at origin/main — `epic-auth-rbac.md:196` already carries the SV5 map-union form:
*"seeded from the EF `ROLE_PERMISSIONS` map for the write/action grants ∪ the SV6a
role→`:view` grant matrix for the read grants — the map carries zero `:view` strings."*
It was rewritten 2026-06-11 (revision-log line 669, campaign authphase2 W8). **No-op.**
(The only remaining slightly-imprecise spot is the spec slice `auth-003-004-…:83` AC4
which says "compile-time `ROLE_PERMISSIONS` catalogue + its read-only seed" without
spelling out the union — say the word if you want that touched too; it's not wrong,
just less explicit.)

## A-5 — FLAGS.md: **PR #488** (open)
`docs/FLAGS.md` — the open-architect-decision registry, closing the FLAGS routing gap.
Seeded from #393/#394/#395; lifecycle + maintenance rule; statuses marked (several
already RATIFIED/RESOLVED incl. SV10/AV3, the rest OPEN with routing targets).
**⚠️ Interpretation flag:** I read "the #393/#394/#395 flags" as the `⚑ flag-to-architect`
open-decision class (the *routing* gap), NOT runtime feature flags (those live in
app_config/p2p_config + the #481 stack map). If you meant a runtime-config registry,
say so — cheap repoint.

## PR #486 — review addressed (R1 blocker + nits), pushed `acc9f0e`
next-code-reviewer (@ `50b8a57`) = CHANGES-REQUESTED, APPROVE-on-fix. Fixed:
- **R1 (blocker):** guard-test TEETH token pattern was suffix-anchored (`%token`) →
  missed `email_change_token_new`/`_current`. Now substring `%token%` (zero false
  positives on the INCLUDE lists). No live leak (already excluded); recurrence-catch
  hardened.
- Nits: anon/authenticated zero-grant checks → `has_table_privilege` (resolves
  effective+PUBLIC-inherited, robust to role_table_grants grantor-visibility); spec
  §4 count 20→26.
- The reviewer's coherence flag (#486 covers only auth.* leg) is **already resolved**
  by my AV3 push (`4e10ab5`) — the business-secret leg is now in #486 (design-only,
  owner-gated). Ready for re-review.

— next-architect
