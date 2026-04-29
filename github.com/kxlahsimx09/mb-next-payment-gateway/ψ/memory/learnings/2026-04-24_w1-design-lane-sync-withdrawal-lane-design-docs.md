---
title: W1 design-lane sync — withdrawal-lane design docs synced to fair-router model (p
tags: [system-architect, repo:mb-next-payment-gateway, next, adr, refinement, w1, adr-4a, adr-8, withdrawal-queue, design-doc-sync, drift-cleanup, fair-router, defense-in-depth, check-constraint, p-001, adr-vs-design-doc-bidirectional, imprecision-lesson]
created: 2026-04-24
source: docs/adr.md@772d3cd + docs/design/withdrawal-lane/{realtime-filter.md,claim-rpc.md,schema.sql,README.md,sweep-and-lifecycle.md}@772d3cd
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# W1 design-lane sync — withdrawal-lane design docs synced to fair-router model (p

W1 design-lane sync — withdrawal-lane design docs synced to fair-router model (post-ADR-8 drift cleanup).

On 2026-04-24 GMT+7, §ADR-8 (bot↔gateway work distribution) was ratified `#decision` via thread #46 (commit `5215ecb`), and §ADR-4a received a "Update (pass 7)" note saying Mode-1 pool-broadcast race is retired. But `docs/design/withdrawal-lane/realtime-filter.md`, `claim-rpc.md`, and `schema.sql` still carried 18 references to the retired shape across 3 files — impl agents reading the adjacent ADR + design docs would see two contradictory models. This pass eliminates the drift.

Scope: pure drift cleanup on the design-doc layer. No new decisions. No `arra_supersede` — §ADR-8 pass-3 learning remains the primary `#decision` record; this pass just brings the how-it's-built docs in line with the already-ratified what-and-why.

Key deltas:
- `realtime-filter.md` rewritten — single-predicate subscribe filter (`required_bank_account_id=eq.<self> AND status=eq.pending`) replaces the 2-branch Mode-1/Mode-2 composition. Worked examples redone around fair-router singularization. Historical note preserves pre-retirement shape with git-history pointers (`c57f1a6`, `da53223`, `36628c3`) per P-001. Catchup RPC simplified (no pool/method JOIN).
- `claim-rpc.md` — pool/method branch reframed as defense-in-depth (not racing mechanism in steady state). Layered-responsibilities table gained "Role under ADR-8" column distinguishing Primary (Layer 3/5) from Defense-in-depth (Layer 2a/2b). New §Defense-in-depth section enumerates 5 pathological inputs the re-verify catches: concurrent fair-router, duplicate broadcast, misconfigured bot, sweep re-invocation, legacy writer.
- `schema.sql` — `queue_status_enum` gained `pending_routing` (initial state for substitutable source-flow INSERTs). CHECK constraint widened with a third branch permitting `payout/settlement + pool_id NOT NULL + required_bank_account_id NOT NULL` (post-routing shape). Column comments rewritten.

Durable surfacing — "CHECK constraint unchanged" imprecision:
The §ADR-4a pass-7 update note asserted "CHECK constraint unchanged" — correct about the 3-shape intent but wrong about literal DDL. The pre-existing 2-branch CHECK rejected the fair-router's routing UPDATE output (`payout/settlement` with both `pool_id` AND `required_bank_account_id` set). Widened to 3 branches to match the ratified decision's actual requirements. This is the class of drift that appears when ADR updates cite companion design-doc behavior without re-reading the companion doc's current content. Durable lesson for future architect passes: **when an ADR update claims "X in companion doc is unchanged," grep X before committing.**

Durable pattern — bidirectional ADR-vs-design-doc sync:
§ADR-4a pass 6 (2026-04-23) and §ADR-8 pass 4 (2026-04-24) extracted implementation detail OUT of the ADR INTO design docs. This pass does the reverse — design docs UPDATE to track an ADR decision that moved ahead of them. Both directions are valid maintenance; both belong to system-architect. The convention now reads bidirectionally: when the ADR changes a decision, the design docs must follow; when a section grows too big, it extracts back. The sync direction matters, but the commitment is the same: ADR says what; design docs say how; they must agree.

Threads opened: none. Threads closed: none (#45 fleet-control still deferred; no markers resolved this pass). Commit: `772d3cd` on branch `claude/tender-shtern-d94fef`. PR: #3 (open, not merged). Next pass candidate: deposit auto-match lane (ADR-4 other half) — now genuinely independent of withdrawal per business-constraint ratification in thread #46.

---
*Added via Oracle Learn*
