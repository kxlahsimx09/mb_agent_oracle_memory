---
title: Silent-stall recurrence (thread #259, 2026-05-29): a brew-ops dispatch can LOOK 
tags: [brew-ops, repo:arra-oracle-v3, fleet, inbox, gotcha, silent-stall, handoff, directed-inbox]
created: 2026-05-29
source: thread #259 close-out; verified PR #1226 OPEN @ ad3d017
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Silent-stall recurrence (thread #259, 2026-05-29): a brew-ops dispatch can LOOK 

Silent-stall recurrence (thread #259, 2026-05-29): a brew-ops dispatch can LOOK done yet leave the requestor waiting forever. The wt-c-macosmigrate session did the actual work (committed the macOS migration guide, opened fork PR #1226 @ ad3d017) AND posted the "Done" reply in thread #259 — but skipped the reply ENVELOPE to for-orchestrator/, and archived the consult envelope with a plain `mv` (untracked, no handled_* frontmatter). Result: thread #259 stayed `pending`; orchestrator never got the doorbell. This is exactly the failure the brew-ops SKILL "Inbox protocol (binding)" warns about: a thread reply WITHOUT a corresponding envelope is a silent stall.

Diagnosis signature when you inherit one: (1) thread status `pending` but the deliverable already exists in reality; (2) the consult envelope already in handled/ but missing handled_at/handled_by_thread/handled_by_inbox; (3) no *_reply.md in for-{requestor}/.

Correct recovery (do NOT re-run the dispatch — that duplicates the commit/PR): verify reality first (gh pr view, git ls-remote fork, file presence) → confirm done → post a brew-ops verification note in-thread → write the missing reply envelope to for-{requestor}/ (the doorbell) → append handled_* audit-trail frontmatter to the archived consult → commit in the vault repo so the archive is tracked (P-001). Envelope-first discipline (§ brew-ops inbox protocol) exists precisely so a crash mid-archive can't strand the requestor; the prior session violated order AND skipped the envelope entirely. Also relevant: the §11l Stop hook would have blocked that session's end (needs_response:true archived without handled_by_inbox/handled_note) — evidence the hook's gate either didn't fire or was bypassed in that worktree.

---
*Added via Oracle Learn*
