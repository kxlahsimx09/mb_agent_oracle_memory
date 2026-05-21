---
title: Gotcha — inbox-watcher: an envelope fired+archived within one poll interval orph
tags: [gotcha, inbox-watcher, fleet, campaign-inflight, fired-state, 11f, brew-ops, thread-170]
created: 2026-05-18
source: thread #170 — brew-ops root-cause + fix PR #81
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Gotcha — inbox-watcher: an envelope fired+archived within one poll interval orph

Gotcha — inbox-watcher: an envelope fired+archived within one poll interval orphans at state=`fired`, blocking its whole campaign (fixed PR #81) 2026-05-18

The inbox-watcher froze a campaign for ~2.3 hours. Root cause — a state-reconciliation gap in `inbox-watcher.sh`, NOT session-death or a campaign-inflight lock bug:

- A consult/reply envelope fired (`status=fired`), the woken agent processed it AND §11d-archived the `.md` to `handled/`, all within one 60s watcher poll interval.
- Watcher Pass 1 only iterates `.md` files still present in `for-<oracle>/` — by the next scan the file was already in `handled/`, so the T1 `verify_delivery` probe never ran for it.
- Watcher Pass 2 (the archived-envelope reconciliation sweep) had cases for `verified` / `delivered_to_owner` / `deferred` — but NO `fired` case. So the envelope's state file stayed `fired` forever.
- `campaign_inflight()` counts any sibling envelope in `fired|verified|delivered_to_owner` as in-flight. The orphaned `fired` record made it return true on every scan → every other envelope in that campaign deferred indefinitely, ALERTing "DEFERRED past T2" every ~60s with no auto-resolve.

Symptom: a dispatch envelope stuck DEFERRED for hours, watcher ALERTing "campaign N sibling still in flight past T2", but no live worker session exists (the supposed in-flight sibling exited cleanly long ago).

Immediate unstick: reconcile the orphaned state file (`~/.cache/inbox-watcher/...` — operational state, eviction-allowed, not vault) — set the stale `fired` to `completed`; next scan un-defers the blocked envelope.

Fix: fork PR kxlahsimx09/arra-oracle-v3 #81 (base feat/all-prs-rebased, pending review/merge) — Pass 2 gains a `fired)` case: a `fired` envelope whose `.md` is gone from the inbox is finalized to `completed` (file-gone proves §11d archival). + regression test. Post-merge: §3c deploy (ff primary + restart inbox-watcher.sh).

Related orchestrator correction (§11f): for a follow-up consult on an in-flight campaign, the watcher firing `--resume <sid>` is CORRECT even when the prior worker process has exited — `--resume` resumes the conversation/JSONL and spawns a fresh process; it is the right mechanism for a cleanly-exited session, and gives the agent warm campaign context. Only avoid `--resume` if the prior session crashed mid-turn (unclean JSONL) or cold context is specifically wanted. Do not conflate process-death with conversation-resumability. Tags: #gotcha #inbox-watcher #fleet #campaign-inflight #11f

---
*Added via Oracle Learn*
