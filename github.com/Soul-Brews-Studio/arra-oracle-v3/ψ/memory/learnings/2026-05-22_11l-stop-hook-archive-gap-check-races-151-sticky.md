---
title: §11l Stop-hook archive-gap check races §151 sticky ownership → a non-owner orche
tags: [drift, fleet, inbox-protocol, stop-hook, session-ownership, 11l, 151, dedup, orchestrator, brew-ops]
created: 2026-05-22
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# §11l Stop-hook archive-gap check races §151 sticky ownership → a non-owner orche

§11l Stop-hook archive-gap check races §151 sticky ownership → a non-owner orchestrator session duplicates the owner's campaign work.

**Observed 2026-05-22 ~09:43–09:51 GMT+7.** Session `wt-7` (`arra-oracle-v3.wt-7-inbox-1779417512`) was woken by the inbox-watcher to handle ONE envelope: `for-orchestrator/…thread-204` (a brew-ops consult, campaign-less). On stop, the §11l inbox-loop-closure Stop hook ALSO attributed three unrelated orchestrator envelopes to wt-7 and directed it to close them:
- thread-202 (next-writer, campaign #201)
- thread-203 (next-impl, campaign #201)
- thread-206 (next-architect, campaign #205)

All three carried `parent_session = …/arra-oracle-v3.wt-5-20260522-084335` — i.e. **wt-5 was the §151 recorded campaign owner**, and wt-5 was concurrently handling + archiving them (`handled_by_inbox: orchestrator@wt-5-…`, `handled_at` 09:47–09:49). Because the hook's archive-gap check (§11l point 2) is **per-oracle-root** ("any *.md in `for-{oracle}/` root → block"), NOT per-session-ownership, wt-7 — stopping while wt-5's archiving was mid-flight — was told to handle envelopes it did not own.

**Result:** wt-7 duplicated wt-5's work — thread posts (msgs 846/847/848 on 202/203/206; 849/850 on parents 201/205) and duplicate "hold" reply envelopes to `for-next-writer/` + `for-next-architect/`, causing extra worker wakes (next-writer/next-architect woke, stamped, held).

**Root cause:** §151 fixed reply ROUTING (watcher routes a reply to the recorded owner session) but the §11l Stop-hook stop-GATE still fires on *any* envelope in the oracle's inbox root regardless of recorded owner. This reopens the §140/§141-class session-fragmentation that §151 was meant to close, at the hook layer.

**Fix direction (brew-ops):** gate the §11l archive-gap + reply-gap checks on recorded ownership — a session should only be blocked-for / directed-to envelopes whose `sessions/<oracle>/thread-<wake-key>.owner` is THIS session (or genuinely unowned). Envelopes owned by a different *live* session should be invisible to a non-owner's stop gate. Harm here was bounded (duplicate posts were content-consistent; no decisions changed), but it is session-sprawl + thread noise that compounds whenever ≥2 orchestrator campaigns are in flight concurrently. #drift #fleet

---
*Added via Oracle Learn*
