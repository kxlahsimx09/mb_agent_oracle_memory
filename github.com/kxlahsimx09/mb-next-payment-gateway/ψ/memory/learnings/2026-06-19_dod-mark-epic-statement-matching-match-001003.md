---
title: DoD-MARK — epic-statement-matching (MATCH-001..003) = 🟢 epic-DONE (2026-06-19, 
tags: [dod-mark, epic-done, statement-matching, matcher-engine, adr-4a, adr-4b, live-n-a, seal-collapse, pmmark, docs-flip]
created: 2026-06-19
source: next-pm campaign pmmark (DoD-MARK)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — epic-statement-matching (MATCH-001..003) = 🟢 epic-DONE (2026-06-19, 

DoD-MARK — epic-statement-matching (MATCH-001..003) = 🟢 epic-DONE (2026-06-19, next-pm campaign `pmmark`)

The matcher engine epic is flipped to epic-DONE on concrete gate-to-artifact evidence (gone-and-looked at each artifact — never agent word). The flip is a DOCS-ONLY PR #644 (base `main`, head `docs/statement-matching-epic-done-pmmark`), LEFT FOR OWNER MERGE per §9a (no self-merge).

GATE → ARTIFACT (each verified directly):
- BUILD ✅ MERGED — PR #641 MERGED → `main`, squash `060017a` = `origin/main` HEAD (confirmed `git merge-base --is-ancestor`; `mergedAt` 2026-06-19T16:12:52Z). `supabase/functions/_shared/statement-matching-conformance.test.ts` present on `main`. Static §ADR-4a/4b CI-teeth conformance test: 19 pass / 0 fail / 54 expect().
- REVIEW ✅ APPROVE — next-code-reviewer (campaign `teethclose-matching`) PR #641 review BODY-HEADER "✅ REVIEW VERDICT: APPROVE". gh `state = COMMENTED` (expected self-authored build-PR degrade under the shared `kxlahsimx09` identity; §9a build-CODE carve-out + #618 precedent — verdict lives in the body). Pins the architect's FOUR money-safety invariants: (1) count-based dedup the SOLE gate (`ON CONFLICT` absent; non-unique accelerator); (2) Step-1 full three-predicate key, NO amount-only fallback (the `PAY1776286617S2B53L` lesson); (3) OUT auto-fire ONLY on the server-derived request-reference; (4) fee-row skip (code-first then description-gated). Reviewer independently verified all six pinned functions are AUTHORITATIVE-LATEST at HEAD + re-proved fail-on-violation (injected `ON CONFLICT DO NOTHING` → RED 18/1; reverted clean).
- VERIFY/SEAL ✅ COLLAPSE — next-investigator §8 ruling (`next-investigator_pmcloseepic_findings.md` §8): epic-statement-matching needs NO dedicated investigator money-seal; it COLLAPSES to reviewer-APPROVE + #641 CI-teeth GREEN, conditional on #641 pinning the four invariants. CAVEAT SATISFIED — the reviewer's APPROVE body confirms all four per-invariant. Detection-only; money consequences already re-derived from raw rows under PAYOUT-009 seal (§3 s7: review→success, exactly-one callback, satang-exact conservation, >50 amount-mismatch park) + DEPOSIT-002 (IN-match); deployed `match_payout_statement` body md5 byte-identical to the slice-5 sealed citation.
- LIVE (§ADR-21) ✅ N/A (ruled) — OWNER P1 ruling (`next-architect_pmcloseepic_findings.md` §3 + close-out matrix row 3): detection-only / non-money → the golden MONEY journey + 4-money-invariant recompute has nothing unique to exercise; wrong-link/missed-link money-safety rides DEPOSIT/PAYOUT invariants #1/#4. Precedent: CLIREAD #611 + FLEET #496 (non-money-engine sibling).

DOCS TOUCHED: `docs/requirements/epic-statement-matching.md` (new "Build status (DoD) — matcher engine" section: banner + owner ruling + gate table) + `docs/requirements/INDEX.md` (epic-DONE summary blockquote + MATCH-001..003 tagged `✅ epic-DONE 2026-06-19`). Mark PR: #644.

RULE REINFORCED: a detection-only non-money ENGINE closes on gates 1–4 with the VERIFY/SEAL gate allowed to COLLAPSE to reviewer-APPROVE + a CI-teeth conformance test GREEN when the money consequences are already independently sealed under the lane epics it feeds (here DEPOSIT-002 / PAYOUT-009) — but ONLY when the test provably pins every load-bearing invariant (the reviewer is the gate that confirms that coverage).

---
*Added via Oracle Learn*
