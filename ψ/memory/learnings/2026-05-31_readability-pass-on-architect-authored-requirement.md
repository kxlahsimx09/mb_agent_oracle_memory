---
title: Readability pass on architect-authored requirement-story acceptance criteria (ca
tags: [requirements-writing, acceptance-criteria, readability, prose-only, adr-citation, ng2fix2]
created: 2026-05-31
source: next-writer ng2fix2 readability pass
---

# Readability pass on architect-authored requirement-story acceptance criteria (ca

Readability pass on architect-authored requirement-story acceptance criteria (campaign ng2fix2, team next-writer, repo mb-next-payment-gateway). Prose-only treatment, ratified meaning locked, modeled on DEPOSIT-002 commit 60cf6ba:
- Break a run-on AC into *Given*/*when*/*then* with a bulleted Then (one fact per bullet).
- Remove statements duplicated across ACs (e.g. change-gating wording repeated in both the alert AC and the severity AC; an inline parenthetical that re-states a sibling story).
- Collapse per-AC inline §ADR/`#decision`/ratified citations into ONE compact ratification-note blockquote (`> Ratified §ADR-NN §Amendment YYYY-MM-DD (user GO …): …`) right after the AC, OR rely on the existing Sources block.
- Keep load-bearing tokens VERBATIM: ledger equations (gross = client-net + Σ credited-partner-shares + Σ residual), error_code string literals (error_code='callback_redirect_blocked'), numeric thresholds, AUTH-007/step-up scope wording.
SCOPE GUARD: only edit story ACs in epic-*.md; never edit docs/adr.md decision text (architect's spec). Commit message asserts "prose only, meaning unchanged" + lists the ratified decision preserved + "No #decision altered; adr.md untouched." One file per commit. Do NOT merge.
Applied to 4 PRs: #292 PULLOUT-003/004 step-up+guard (epic-source-flows), #294 MONITOR-005 P2/hourly (epic-monitoring), #295 TOPUP-002 residual-MDR (epic-topup), #296 CALLBACK-003 3xx-do-not-follow (epic-callback-delivery).

---
*Added via Oracle Learn*
