---
title: **orchestrator pattern — user prefers manual filing for pre-delivered escalation
tags: []
created: 2026-05-21
source: parent campaign thread #181 Track C — user closed 2026-05-21 ~10:40 GMT+7 ('learning ก็ปิดได้เลยครับ')
---

# **orchestrator pattern — user prefers manual filing for pre-delivered escalation

**orchestrator pattern — user prefers manual filing for pre-delivered escalation packs (2026-05-21)**

Track C of parent campaign #181 (resume from 2026-05-20 18:08 wrap retro): mobiz issue filing decision deferred from prior session. Question was — who files the GitHub issue on `kokarat/mobiz-payment-gateway` for the 7,749.30 THB slip-reuse fraud escalation (6-pair dossier + 8 patterns + 3 enforcement gaps)?

Two options offered:
- (a) **pg-writer drafts directly** via `gh issue create` — orchestrator dispatches; pg-writer regenerates body from vault learnings + threads
- (b) **User files manually** — uses the escalation pack already delivered to Telegram chat last session (verbatim, no regeneration)

Orchestrator recommendation: (b). Pack was pre-delivered to Telegram chat in prior session (#175 ~17:55 GMT+7 2026-05-20). Regenerating via pg-writer = dispatch overhead + drift risk between pre-delivered chat pack and re-derived draft. No round-trip benefit since user has copy-paste-ready material.

**User decision: close as user-handled + file learning.** Implicit accept of (b)-path (user did not dispatch pg-writer; closed the track without queuing impl work).

## Reusable pattern

When the escalation/dossier/draft material has already been delivered to the user in chat (verbatim, copy-paste ready), default to (b) user-files-manually rather than (a) orchestrator-dispatches-pg-writer-to-regenerate:

1. **Avoid dispatch overhead** for content the user already has in usable form. pg-writer regenerating a chat-delivered pack is duplicative work.
2. **Avoid drift risk** between the chat-delivered version (which user trusts and reads) and a regenerated draft (which may rephrase, reorder, or summarize differently).
3. **Avoid sub-thread sprawl** — opening a new sub-thread for "regenerate what's already in chat" violates Thread Discipline §1 (batch related, don't multiply).
4. **Reserve agent dispatch for follow-ups** — if the recipient triages the user-filed issue and asks for clarifications, dispatch pg-writer to draft the response then. First-filing rarely needs the round-trip.

**How to apply:** when a track involves "who files the issue / sends the email / posts the message" and the underlying content has already landed in user-facing chat verbatim:
- Default route: user files manually; orchestrator closes the track as user-handled
- Dispatch route reserved for: content requiring re-derivation, multi-recipient broadcast, async follow-ups where user is offline
- File the close-out learning even when no impl work happens — captures user preference for future similar decision points

## What I do NOT do at close

- No `arra_thread_update` for Track C (no sub-thread was ever opened for it — it was an inline deferral in parent #181)
- No envelope to pg-writer (the dispatch never fired)
- No PR or merge expected — user-handled track has no fleet artifact

## Decision-authority tag

This adds a `2c-trivial-direct-no-dispatch` instance to the decision-authority pattern library: shape = "track decision = pick between user-handles vs orchestrator-dispatches; user picks user-handles". On future similar tracks (escalation/dossier/draft already in chat), confidence MEDIUM-HIGH for proposing user-handles as default with orchestrator-dispatches as escalable alternative.</pattern>
<parameter name="concepts">["orchestrator", "decision-authority", "track-closure", "user-handled-default", "pre-delivered-pack-pattern", "no-dispatch-pattern", "thread-201", "campaign-181-track-c", "mobiz-escalation-filing", "regeneration-drift-avoidance"]</parameter>
<parameter name="project">github.com/Soul-Brews-Studio/arra-oracle-v3

---
*Added via Oracle Learn*
