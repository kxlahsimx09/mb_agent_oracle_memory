## next-live-tester (campaign olive) → orchestrator: TRI-EPIC LIVE harness BUILT + DRY-VALIDATED → HOLDING for owner-GO

**Date:** 2026-06-13. **Stack:** LIVE-mode staging sinuw (main HEAD, mig 158/158, EF 33/33). **Design:** docs/requirements/live-test-journey.md (PR #491). **Harness PR:** #492 (campaign/olive → main, NOT self-merged).

### Done this pass (BUILD + dry-validate, no owner-GO needed)
- Built the runnable tri-epic harness: `poc/integration/src/live/journey-tri-epic.ts` + launcher `run-live-tri-epic.sh`, reusing the existing live modules (journey-context/capture/db/readiness-gate/receiver/entry-auth/entry-client/admin-actions/faults) verbatim. 20 new modules, **every file ≤250 lines** (max 146).
- ONE multi-tenant cast → THREE trace ids (REQ-AUTH/REQ-DEP/REQ-PAY) → three evidence sets under evidence/live/{auth,deposit,payout}/<reqid>/.
- Coverage: PROLOGUE cast (2 merchants, 4 clients incl sub-client, 3 partners incl inactive PT3, 2 MDR profiles, banks incl maintenance, 8 users × 7 roles + TOTP); ACT I (AUTH I.1–I.8), ACT II (DEPOSIT II.1–II.9 + F-DEP-i/ii/iii), ACT III (PAYOUT III.1–III.11 + F-PAY-i/ii/iii) per the §10 matrix.

### Dry-validate result (sinuw)
1. **Compiles** — tsc zero new errors in tri-epic files; first-party graph bundles clean; loads under Bun.
2. **L0 readiness GREEN** — verdict READY, **zero blockers** (auth/deposit/payout EFs + CF worker + tenant-read + bot EFs + deployed mock-merchant receiver). [trycloudflare quick-tunnel is flaky on the fleet host → launcher defaults RECEIVER_BASE_URL to the slot's deployed mock-merchant EF, the stable receiver.]
3. **Fixtures provision** — confirmed by direct read on sinuw (C1 client+wallet, PT3 wallet inactive, maint bank window, PROFILE-B = PT1 70%/PT3 30%, 8 users w/ verified TOTP). Synthetic users banned at teardown; namespaced cast (0117e000-…) persists idempotently for the gated run.
- Harness STOPPED before any money act. No money moved.

### Design→deployed gaps (route to architect; harness handles honestly, never false-greens)
- `cs` & `merchant` roles NOT in Phase-1 RBAC catalogue (super_admin/client_admin/client_viewer/partner_user; user_type ∈ admin|client|sub-client|partner). cs=RBAC-deny actor (intended, I.4); **merchant roster-scope AUTH-004 leg NOT live-provable** — surfaced honestly in I.3.
- **AUTH-007 step-up has zero deployed call-sites** (per AUTH seal) — I.8 drives the step-up EFs but does NOT pretend a gated action exists (AMBER/honest-limit).
- MDR profile selection may be global-oldest (create_deposit ORDER BY created_at LIMIT 1) → confirm both profiles get exercised on a shared stack.

### HOLDING for owner-GO
Money acts run only under OWNER_GO_LIVE_ALL=1 (or per-epic _AUTH/_DEPOSIT/_PAYOUT=1) ./run-live-tri-epic.sh. **Relay the owner GO (all-three or per-epic)** and I'll run it. On GO: produces evidence/live/{auth,deposit,payout}/<reqid>/ with legs.json + stamped frames, then **I hand evidence to next-investigator for the L3 §9 recount** — I do NOT declare PASS/FAIL (ADR-21). Out-of-scope respected: no supabase/ or src/ product-code edits, no deploy, nothing marked done, no self-merge. Full detail: next-live-tester_olive_findings.md (worktree root).