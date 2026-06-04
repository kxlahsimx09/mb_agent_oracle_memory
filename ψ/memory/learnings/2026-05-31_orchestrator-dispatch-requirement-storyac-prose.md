---
title: orchestrator dispatch — requirement story/AC prose is the WRITER's job, not the 
tags: [orchestrator, team-dispatch, feedback, corrected, role-ownership, writer-vs-architect, ac-prose, requirements-writing, readability, mb-next-payment-gateway, pr-291, adr-19, repo:arra-oracle-v3]
created: 2026-05-31
source: user correction, orchestrator session 2026-05-31 wave 2, campaign ng2fix
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator dispatch — requirement story/AC prose is the WRITER's job, not the 

orchestrator dispatch — requirement story/AC prose is the WRITER's job, not the architect's, even when the architect authors the ADR.

User correction 2026-05-31 (mb-next gap-sweep wave 2, PR #291 §ADR-19): next-architect authored both the ADR AND the DEPOSIT-002 acceptance criteria. The first AC came out as a hard-to-read 8-line run-on — 'GROSS' and 'snapshot-at-create' each stated TWICE, and (§ADR-19 m1/m2/m3 …) citations inline mid-sentence. User: 'นก ไม่เข้าใจเลย ต้องปรับ' + 'จริงๆ คนที่เขียนควรจะเป็น writer นะ.'

WHY: architects write ACs like engineer specs — dense, citation-packed, redundant. The decision content is correct but the prose is unreadable to the human reviewing the PR. Readable requirement prose is a distinct skill the writer role owns.

HOW TO APPLY (orchestrator dispatch): when dispatching next-architect to author an ADR + the stories it unlocks, scope the architect to the DECISION + skeletal story pointers, then dispatch next-writer to author/polish the AC prose — OR at minimum run a writer readability pass over the architect-authored ACs BEFORE the PR is presented to the user. Lock the ratified meaning (rewrite prose, never the decision). Resolution this session: dispatched next-writer (campaign ng2fix) onto branch arch/ng2arch-a to rewrite DEPOSIT-002 AC#1 (and scan the DEPOSIT-001 QR ACs for the same issue), meaning-locked, no merge. OPEN QUESTION for next session: the same architect authored ALL ACs across #292/#294/#295/#296 — they likely need the same writer readability pass; offer it to the user.

---
*Added via Oracle Learn*
