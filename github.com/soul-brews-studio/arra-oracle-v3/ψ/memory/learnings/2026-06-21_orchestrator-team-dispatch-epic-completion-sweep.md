---
title: orchestrator team-dispatch — EPIC-completion sweep (campaign o-provision, PROV/§
tags: [orchestrator, team-dispatch, epic-completion, decision-authority, accepted, build-flow, prov, verify-loop, spec-clarify-vs-code-fix]
created: 2026-06-21
source: campaign o-provision (orchestrator session)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator team-dispatch — EPIC-completion sweep (campaign o-provision, PROV/§

orchestrator team-dispatch — EPIC-completion sweep (campaign o-provision, PROV/§ADR-18). Shape: user asks "is epic provision done? finish per flow." Flow that worked end-to-end: (1) next-pm done-check gate-to-artifact found PROV-001/008 lacked seals + PROV-007 b3 unbuilt + PROV-004 doc stale; (2) user-supplied live-tester handoff surfaced 2 functional requirement gaps PM's artifact-only check could NOT see (GAP-1 client has no wallet at provisioning → client_wallet_missing in prod; GAP-2 no home for callback-endpoint provisioning); (3) 3 owner decisions escalated + ALL accepted (architect recommendations): GAP-2=new admin PROV-009 story, non-zero-wallet=balance<>0 OR frozen<>0, b3 full-safety (identity-teardown + in-flight block); (4) architect authored spec+§ADR-18 b3 amendment, writer authored requirement; (5) next-dev-1 built 3 slices on slot dev-1 → PR #668; (6) brew-ops cross-stack deploy to tester+seal stacks; (7) next-tester 43/0/3 GREEN; (8) next-investigator raw-DB SEAL all stories incl PROV-008/AUTH-010; (9) reviewer APPROVE; (10) user-authorized merge #668 (1ccd4828) + marking PR #673; (11) next-pm marked epic-COMPLETE. Verify-loop lesson: a tester FAIL (disable-wallet) resolved by architect SPEC-CLARIFY (no dev loop), and a tester env-gap (missing SBWRITE substrate) resolved by brew-ops re-deploy — neither needed a code rebuild. Discipline that held: every teammate spawned FRESH under own team slug (never reused another team's agent), closed-on-idle (kill window AND verify process dead — the quota-leak), resume-warm for re-dispatch. §ADR-21 LIVE-gate ruled N/A for pure admin-WRITE/non-money surfaces per CLIREAD #611.

---
*Added via Oracle Learn*
