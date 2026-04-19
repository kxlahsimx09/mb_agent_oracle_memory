---
title: drift — technical-writer sibling workflow-8 copies diverged; bank-bot missing §M
tags: [technical-writer, repo:cross, repo:bank-bot, repo:mobiz-payment-gateway, current, drift, workflow-bug, workflow-8, technical-writer-drift, mermaid, sibling-drift, skill-sync]
created: 2026-04-19
source: .agent/skills/technical-writer/references/workflow-8-flow-map.md (bank-bot vs mobiz-payment-gateway siblings); PR kokarat/bank-bot#73 commits 08b116d + this fix
project: github.com/kokarat/bank-bot
---

# drift — technical-writer sibling workflow-8 copies diverged; bank-bot missing §M

drift — technical-writer sibling workflow-8 copies diverged; bank-bot missing §Mermaid safety rules.

Context: per AGENTS.md §5a, technical-writer runs as N instances (one per repo) sharing SKILL.md verbatim and differing only in tag prefix + owned files. The coordination rule is: "When SKILL.md is updated in one instance's .agent/skills/technical-writer/SKILL.md, the change is mirrored to the sibling instances in the same session. Drift between copies is its own #drift learning."

What drifted: pg-writer's workflow-8-flow-map.md (mobiz-payment-gateway .agent/) has a §Step 4 "Mermaid safety rules (binding — violating breaks GitHub render)" subsection with 7 concrete rules (participant aliases use hyphen-not-colon, no HTML inside Note-over, ASCII-only message text, avoid {...} and "..." as inline struct syntax, no second colon in free-text tail, no semicolon as sentence joiner, self-messages kept short) + a "safe template" block + a binding Step 10 PR test-plan line. pg-writer's change log says the section was adopted 2026-04-19 after `deposit-auto-match-from-statement` first-pass render-failed on submission.

bank-bot's workflow-8-flow-map.md (sibling copy) DID NOT HAVE this subsection at all. The bot-side version at 2026-04-19 session start was just "Same rules as pg-writer's W8 Step 4" + an example skeleton that itself violated the rules (`participant Scheduler as System:BankBot (Scheduler)` — colon-with-parens form mobiz's rule 1 explicitly forbids). When bot-writer's first-ever W8 pass (`scb-dual-control-withdrawal`, PR #73) ran, it hit three classes of mermaid break that the pg-writer rules would have prevented: (a) unicode arrows `→` in message labels — rule 3; (b) colon-prefixed path params `:id`/`:acc`/`:ref` in URL segments — rule 5's extended form; (c) comma-in-braces payload `{success,failed,waiting-to-review}` — rule 4. Fixed in commit 08b116d with a "mermaid rendering safety sweep — no content change" discipline copying mobiz's own 2026-04-18 W8 diagram fixes on `withdrawal-queue-dispatch-and-claim.md` and siblings.

Resolution: ported §Mermaid safety rules verbatim from pg-writer's copy to bank-bot's workflow-8-flow-map.md. Added an 8th bot-side rule about non-ASCII script (Thai/Chinese) inside mermaid labels — lifted from the scb-dual-control-withdrawal incident where `reason "ยกเลิกคำขอ"` in a Note-over crashed the diagram. Added bot-side addenda to rules 3, 4, 5 documenting the specific breaks. Rewrote Step 4 example skeleton to use hyphen-form aliases + ASCII-only labels (was violating its own rules). Added binding Step 10 PR-body test-plan item + Step §Definition of Done mechanical pre-push grep: `grep -nE "→|—|…|:[a-z]+[/}]|\{[a-zA-Z0-9_-]+,[a-zA-Z0-9_,-]+\}" docs/flows/<slug>.md`.

How to apply: on every future technical-writer session start (on any repo), diff the local copy of workflow-8-flow-map.md against the sibling copy in the other repo before opening any W8 work. Drift between the two = file a new #drift + #workflow-bug + repo:cross learning naming which rule set is missing from which side. This kind of sibling-drift is specifically what AGENTS.md §5a(3) binds against, and the cost of missing it compounds (my scb-dual-control-withdrawal pass shipped a broken diagram to PR #73 and needed a follow-up commit 08b116d — all avoidable if the rules had been in the bot-side workflow).

---
*Added via Oracle Learn*
