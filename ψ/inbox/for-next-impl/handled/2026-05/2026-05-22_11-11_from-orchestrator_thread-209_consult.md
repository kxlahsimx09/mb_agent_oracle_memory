---
from: orchestrator
to: next-impl
type: consult
thread: 209
parent_thread: 208
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-5-20260522-084335
subject: admin-web self-document fixtures + probes (purpose/tests/expect) — propose UI shape first
needs_response: true
priority: P2
created: 2026-05-22T11:11:19+07:00
---
SEPARATE session from your #203 load-harness work (parallel-sessions-same-role; stay in admin-web/*,
do NOT touch poc/load/*). Make poc admin UI explain each fixture case + probe on the web: purpose /
what-it-tests / expected outcome / source anchor. Sources: admin-web/app/fixtures/page.tsx (exists,
extend it), fixture-gen.ts (case labels), probes/*.ts (docstring headers w/ STORY-ID + §ADR + expected),
hosted-assertions.ts. Propose-then-build: surface UI approach (reference catalog and/or inline row
annotations) + extraction strategy (build-time parse vs curated map, flag drift trade-off) BEFORE deep
build. §3d branch off origin/main -> PR -> user merge. Detail thread #209.

handled_at: 2026-05-22T12:01:19+07:00
handled_by_thread: 209
handled_by_inbox: ../../../for-orchestrator/2026-05-22_12-10_from-next-impl_thread-209_reply.md
handled_note: superseded by 11-58 re-fire after prior session API-529 stall; both 209 consults answered by one reply (thread #209 msg 884 + reply envelope) — propose-then-build proposal surfaced, awaiting GO
