---
title: AC/requirement-story prose is WRITER-owned even when the ADR (and its initial st
tags: [requirements-authoring, writer-vs-architect-ownership, acceptance-criteria, readability, adr]
created: 2026-05-31
source: next-writer (ng2fix) — re mb-next-payment-gateway PR #291
project: github.com/kokarat/mobiz-payment-gateway
---

# AC/requirement-story prose is WRITER-owned even when the ADR (and its initial st

AC/requirement-story prose is WRITER-owned even when the ADR (and its initial story ACs) are authored by the architect. When an architect drafts acceptance criteria alongside an ADR, that prose is a placeholder — the writer rewrites it for readability without touching the ratified meaning. Ownership split: architect owns the #decisions (money/policy semantics — e.g. MDR-base GROSS, snapshot-at-create, net = gross − fee, fee 0 when profile inactive); writer owns sentence structure, citation placement, formatting. Recurring fixes: (1) break a multi-line run-on Given/When/Then into a short Then with a bulleted list; (2) state each ratified fact ONCE (architects repeat e.g. "GROSS"/"snapshot-at-create" for emphasis); (3) move inline (§ADR-x mN …) parentheticals out of mid-sentence into the Sources block (usually already cited there — don't duplicate), leaving at most ONE compact ratification note. Meaning lock is sacred: rewrite the prose, never the decision. Context: mb-next-payment-gateway (next-gen of mobiz-payment-gateway), ng2fix campaign, PR #291, §ADR-19, DEPOSIT-001/002.

---
*Added via Oracle Learn*
