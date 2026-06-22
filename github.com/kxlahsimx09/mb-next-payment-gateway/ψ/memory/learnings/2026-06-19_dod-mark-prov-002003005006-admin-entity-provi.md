---
title: DoD-MARK — PROV-002/003/005/006 admin entity-provisioning WRITE surface (+ PROV-
tags: [dod-mark, prov, prov-002, prov-003, prov-005, prov-006, prov-007, epic-done, live-gate-na, non-money, admin-write, cliread-611-precedent, mdrwrite-606-sibling, entity-provisioning, buildepic2, next-pm, owner-ruling]
created: 2026-06-19
source: next-pm (campaign buildepic2) — PROV-writes epic-DONE MARK (owner ruling 2026-06-19)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — PROV-002/003/005/006 admin entity-provisioning WRITE surface (+ PROV-

DoD-MARK — PROV-002/003/005/006 admin entity-provisioning WRITE surface (+ PROV-007 cross-cutting write contract): epic-DONE.

VERDICT: epic-DONE for PROV-002 / PROV-003 / PROV-005 / PROV-006 and the PROV-007 create/assign write contract. SUPERSEDES the 2026-06-18 "IN-SLICE-DONE; epic-DONE WITHHELD" mark (learning 2026-06-18_dod-mark-prov-002003005006-admin-entity-provi; doc PR #608). No build/deploy/verify performed — this is a scorekeeping promotion on a NEW owner ruling that did not exist on 2026-06-18.

OWNER RULING (2026-06-19): APPLY the CLIREAD #611 precedent — non-money / pure admin-WRITE surfaces are §ADR-21 LIVE-gate N/A; epic-DONE rests on build + review + seal. The §ADR-21 LIVE gate runs ONE golden MONEY journey (deposit→payout) + recomputes the 4 money invariants from raw tables; PROV-writes mint entities (merchant/partner/pool/system-bank), assign pools/MDR, and vault bank credentials with NO wallet debit/credit and NO money movement — the money-journey gate has nothing to exercise → N/A. This was the exact open question that WITHHELD epic-DONE on 2026-06-18 ("does §ADR-21 LIVE apply to a pure admin-WRITE surface?"); the owner has now answered it by applying the precedent.

WHY NOW (two facts): (1) The CLIREAD #611 ruling (2026-06-19) POST-DATES the PROV withhold and answers the same class of question for a surface that also includes a non-money WRITE (CLIREAD-007 status-only cancel). (2) Resolves a live inconsistency: sibling pure admin-WRITE epic MDRWRITE-001..004 (MDR fee-profile CRUD, no money movement) was already marked epic-DONE (#606) in the same 2026-06-18 campaign family; same admin-WRITE character, opposite outcome — now treated alike. Precedent line: bene/`/bank-accounts` → BOTLOG → MDR/ROLE read → CLIREAD #611 → MDRWRITE #606. Common test: does money move? If not, money-journey gate has nothing to exercise → N/A; DONE rests on build+review+seal.

EVIDENCE (unchanged from #608; gates re-verified gate-to-artifact, never on agent word):
- GATE 0 SPEC ✅ docs/spec/prov-writes-002-003-005-006-slice.md (published) on origin/main; 12-AC contract bound to §ADR-18 P1/P2 + §ADR-13 D1/D2/F2 + the shipped PROV-001 pattern.
- GATE 1 BUILD ✅ PR #605 MERGED → main SHA 998af02 (2026-06-18T17:31:43Z). 4 SECDEF provision_* RPCs (merchant/partner/pool/system_bank) + 2 setters (set_client_merchant, set_pool_bank); 6 admin EFs all verify_jwt=false; 4 migrations 20260618001000/001010/001020/001030. Includes static-RBAC-map fix 74e5c30 (6 PROV verbs into _shared/rbac.ts) + new EF-authz POSITIVE self-test run-prov-authz-verify.ts.
- GATE 2 REVIEW ✅ next-code-reviewer APPROVE — binding re-review BODY header on PR #605 ("RE-REVIEW — fix commit 74e5c30: APPROVE", cross-cutting-safe); gh state COMMENTED only due to shared-identity self-approve.
- GATE 3 VERIFY (probe) ✅ next-tester GREEN 12/12 on campaign/provtest @ 328ccc7; 2 SPEC-grounded methodology corrections (read auth-barrier views as aal2 admin; accept SPEC-enumerated 409 identity-conflict set incl. email_taken) — no AC substance weakened.
- GATE 4 VERIFY (seal) ✅ next-investigator SLICE SEAL on isolated stack qnccphgykzdydebmdwdf; all 12 ACs re-derived from RAW truth-DB incl. the Vault-credential-never-leaked invariant b5 (real encryption-at-rest round-trip; 0 plaintext in 201 body, audit_log, v_system_banks) + b6 soft role-separation + atomicity (forced Layer-1 refusal → ZERO partial entity/identity/audit rows, 0 gotrue orphan) + identity same-txn coupling (dup → 409 email_taken, exactly one app_user).
- GATE 5 LIVE ✅ N/A (RULED) — owner 2026-06-19, applying CLIREAD #611 precedent + MDRWRITE #606 sibling. Not deferred, not pending: ruled not-applicable for a non-money admin-WRITE surface. For PROV-006 specifically, the b5 SEAL already grounds the credential-vault + identity path against raw tables.

DoD BOARD: SPEC ✅ | BUILD ✅ | REVIEW ✅ | VERIFY(probe) ✅ | VERIFY(seal) ✅ | LIVE ✅ N/A(ruled) → PROV-002/003/005/006 epic-DONE; PROV-007 create/assign write contract epic-DONE.

OUT OF SCOPE (STILL NOT marked): the PROV-007 b3 disable/soft-delete + non-zero-wallet/in-flight-block legs — NEVER BUILT, a follow-up slice (this build is create/assign-only per SPEC §7); epic-DONE covers the create/assign contract only. PROV-004 MDR-profile CRUD (= MDRWRITE, already epic-DONE #606 / §ADR-25). PROV-001 (already shipped #546). PROV-008 (rides AUTH-010).

ARTIFACTS: doc PR #612 (DOCS ONLY, DO NOT MERGE — base main; head docs/prov-writes-epic-done; flips the central "PROV-writes build status (DoD)" section + Gate-5 row + the PROV-002/003/005/006/007 per-story banners in docs/requirements/epic-entity-provisioning.md from WITHHELD → epic-DONE). Left for owner merge per §9a — NOT self-merged. INDEX.md intentionally untouched (trust-label surface; DoD state lives in the epic). No code change. Mark only — next-pm performed no build/deploy/verify.

---
*Added via Oracle Learn*
