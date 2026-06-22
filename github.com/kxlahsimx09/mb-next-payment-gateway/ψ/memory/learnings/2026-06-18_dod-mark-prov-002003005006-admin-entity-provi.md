---
title: DoD-MARK — PROV-002/003/005/006 admin entity-provisioning WRITE surface (+ PROV-
tags: [dod-mark, prov, prov-002, prov-003, prov-005, prov-006, prov-007, in-slice-done, not-epic-done, epic-done-withheld, adr-21-live-applicability-undecided, entity-provisioning, buildepic, next-pm]
created: 2026-06-18
source: next-pm (campaign buildepic) — PROV-writes MARK
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — PROV-002/003/005/006 admin entity-provisioning WRITE surface (+ PROV-

DoD-MARK — PROV-002/003/005/006 admin entity-provisioning WRITE surface (+ PROV-007 cross-cutting write contract): IN-SLICE-DONE (gates 1–4 GREEN, merged). NOT epic-done — epic-DONE WITHHELD pending the §ADR-21 LIVE-applicability owner decision (UNDECIDED whether the LIVE gate even applies to a pure admin-WRITE surface; owner, 2026-06-18). This is NOT not-applicable and NOT done — explicitly withheld.

Marked by next-pm (campaign buildepic) 2026-06-18 from ARTIFACTS ONLY; each gate independently re-verified gate-to-artifact (go-look), never on agent word. Doc PR #608 (DOCS ONLY, DO NOT MERGE) carries the per-story marks in docs/requirements/epic-entity-provisioning.md; INDEX.md intentionally untouched (trust-label surface; build/DoD state lives in the epic, per deposit/payout/settle precedent).

GATE 0 — SPEC ✅ docs/spec/prov-writes-002-003-005-006-slice.md present on origin/main (status: published). 12-AC test-facing contract bound to §ADR-18 P1/P2 + §ADR-13 D1/D2/F2 + the shipped PROV-001 pattern.

GATE 1 — BUILD ✅ PR #605 MERGED → main SHA 998af02 (mergedAt 2026-06-18T17:31:43Z); git merge-base --is-ancestor 998af02 origin/main = TRUE. Delta byte-verified on origin/main: 4 SECURITY DEFINER provision_* RPCs (provision_merchant/provision_partner/provision_pool/provision_system_bank) + 2 setters (set_client_merchant, set_pool_bank); 6 admin EFs (admin-merchants-create, admin-merchants-set-client, admin-partners-create, admin-pools-create, admin-pools-set-bank, admin-system-banks-create) all registered verify_jwt=false in config.toml; 4 migrations 20260618001000/001010/001020/001030. Includes the static-RBAC-map fix (commit 74e5c30, squash-merged into 998af02; NOT an ancestor as an individual commit because PR was squash-merged, but its content is present): 6 PROV verbs (merchant:create/update, partner:create, pool:create/update, system-bank:create) added to _shared/rbac.ts ROLE_PERMISSIONS.super_admin (system-bank:create at rbac.ts L111). New EF-authz POSITIVE self-test tests/integration/run-prov-authz-verify.ts closes the BUILD blind spot (the original 403-on-valid-super_admin shipped because no EF-authz-positive self-test existed: EF authz reads the in-code rbac.ts map, NOT the role_permissions DB table; migrations seeded the DB but not the map).

GATE 2 — REVIEW ✅ next-code-reviewer APPROVE — the binding verdict is the re-review BODY header on PR #605: "RE-REVIEW — fix commit 74e5c30 (403-on-valid-super_admin): APPROVE ✅" (cross-cutting-safe; first-pass review also APPROVE). gh review-state reads COMMENTED only because reviewer==author under the shared kxlahsimx09 identity (self-approve degrade) — body header is authoritative per build-workflow Step 3.

GATE 3 — VERIFY (probe) ✅ next-tester GREEN 12/12 on campaign/provtest @ 328ccc7 (next-tester_provtest_findings.md §8). Suite ran RED twice then v3 after the 74e5c30 auth fix → all 12 ACs GREEN against live DB ground-truth. Two methodology corrections, both SPEC-grounded (no AC substance weakened): (1) viewOneAs — read the 4 auth-barrier read-views (v_merchants/v_partners/v_system_banks/v_clients) as the aal2 admin the SPEC intends, not service-role (the views carry an in-body WHERE auth_aal2() AND auth_db_is_admin() AND has_read_perm() barrier — a positive defense-in-depth property); (2) isIdentityConflictCode — accept the SPEC §125/183-enumerated 409 identity-conflict set {username_taken, email_taken, identity_mint_failed} instead of only username_taken (EF mints gotrue first → dup collides at email layer → email_taken).

GATE 4 — VERIFY (seal) ✅ next-investigator SLICE SEAL on isolated seal stack qnccphgykzdydebmdwdf (next-investigator_provseal_findings.md). Connected directly as postgres superuser + drove ops with an independent (no-cleanup) driver; all 12 ACs CONFIRMED from RAW truth-DB — incl. the Vault-credential-never-leaked invariant b5 (real encryption-at-rest round-trip in vault.decrypted_secrets; plaintext maker/approver password = 0 hits in 201 body, audit_log whole-row scan, and v_system_banks; vault.secrets 406 via PostgREST) + b6 soft role-separation + atomicity (forced Layer-1 refusal → ZERO partial entity/identity/audit rows + 0 gotrue auth.users orphan = EF-side identity compensation) + identity same-txn IFF coupling (dup → 409 email_taken, exactly one app_user, no orphan). Both tester probe corrections independently confirmed LEGIT (not goalpost-moving). Two non-blocking test-teardown hygiene notes (orphan vault secret + orphan pool left by probe cleanup) — routed to next-tester, not slice defects.

GATE 5 — LIVE ⏸️ DEFERRED. No live_signoff ACCEPT row exists. The §ADR-21 LIVE-gate applicability to pure admin-WRITE surfaces is an UNDECIDED owner question (2026-06-18). → epic-DONE WITHHELD pending that owner decision.

DoD BOARD: SPEC ✅ | BUILD ✅ | REVIEW ✅ | VERIFY(probe) ✅ | VERIFY(seal) ✅ | LIVE ⏸️ → PROV-002/003/005/006 IN-SLICE-DONE (all 12 ACs in-slice); PROV-007 cross-cutting write contract SATISFIED in-slice across them. epic-DONE WITHHELD pending §ADR-21 LIVE-applicability owner decision.

OUT OF SCOPE (not marked): epic-done (LIVE deferred); PROV-004 MDR-profile CRUD (in-flight, campaign mdrwrite / PR #600 / §ADR-25); the PROV-007 disable/soft-delete + non-zero-wallet/in-flight-block legs (b3 — a follow-up slice, this build is create/assign-only per SPEC §7); PROV-001 (already shipped #546); PROV-008 (rides AUTH-010). The shipped read-views pre-exist this WRITE slice. No build/deploy/verify work done by next-pm (mark only). Doc PR #608 left for owner merge (not self-merged, §9a).

---
*Added via Oracle Learn*
