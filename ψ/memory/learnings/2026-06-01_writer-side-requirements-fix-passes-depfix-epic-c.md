---
title: Writer-side requirements fix passes (depfix-epic campaign on mb-next-payment-gat
tags: [requirements-writing, multi-agent-coordination, depfix, state-grounding, deposit-lane]
created: 2026-06-01
source: next-writer (depfix-epic campaign, PR #300)
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# Writer-side requirements fix passes (depfix-epic campaign on mb-next-payment-gat

Writer-side requirements fix passes (depfix-epic campaign on mb-next-payment-gateway, 2026-06-01): when a separate architect agent owns adr.md on a parallel branch and the writer owns the epic requirements doc, the writer can safely APPLY epic ACs that depend on not-yet-merged ADR amendments by **citing the ADR-side change as pending in the architect's branch/PR** rather than blocking. Concrete example: D2 escalate-to-checking needed a §ADR-4c expire-sweep "escalation arm" that the architect was adding on arch/depfix-adr — the writer worded the DEPOSIT-003/004 ACs to attribute the deterministic `checking` flip to that escalation arm (a producer independent of any Thunder verdict, closing the no-verdict-path gap) and annotated it "cited as pending in arch/depfix-adr". Same shape for D5 §ADR-9 AM5 resend set and the A1/A2 wire-name/column renames. Durable rule: writer + architect can fan out on the SAME campaign by partitioning files (epic-*.md vs adr.md), each citing the other's pending work by branch — no merge coupling, no blocked items.

Second durable point from the same pass: ground every "fix" against deployed substrate, not the doc's own prose. The architect fix-spec pinned each item to a migration/controller line (whole-baht floor = DepositRequestController.go:223-229 FLOOR not round; expiry default 10min/sample 5-15/override 1-60, NOT the doc's bogus "5-45"; deposit status = the deployed 7-value enum where `processing` is payout-only and the deposit holding state is `checking`). The doc had drifted from substrate on several of these — the fix is to the doc, toward the deployed truth. Delivered as PR #300 (writer/depfix-epic vs main, NOT merged).

---
*Added via Oracle Learn*
