## Handoff — pg-writer-oracle, 2026-04-17 10:15 GMT+7 (Workflow-1 baseline complete)

### What I did this session

Ran Workflow-1 re-baseline per the prior session's escalation. Covers `3b7e0f1..ed45b7e` (28 commits). `docs/current-system.md` grew 491 → 534 lines; `docs/.baseline` now pins `ed45b7e` at 2026-04-17T09:35:00+07:00. PR [#203](https://github.com/kokarat/mobiz-payment-gateway/pull/203) opened on `docs/baseline-current-ed45b7e`, **not merged** (awaiting human review).

### What's in the refreshed baseline

Per-PR summary in new Appendix B. Key structural claims:
- §9 **DRIFT-11** (new): MarkFailed double-callback race — tests `test-payout-confirm-completed.sh` / `test-payout-auto-reconcile.sh` stay ON_HOLD.
- §9 **DRIFT-2** / **DRIFT-3** refreshed: issues #181 and #182 both still OPEN at HEAD — no dev fix in this range.
- §5 Matcher: request_id is the only auto-reconcile gate at HEAD (`#188` → `#189`); FIFO linking removed for multi-candidate paths (`#200`).
- §6.1 Post-MarkFailed auto-reconcile gated on `matched_request_id + description contains RequestID` (`#189`).
- §5 ReportScheduler: code revamped (`#198`/`#199`) but still commented out in `main.go`.

### 9 learnings filed in the vault

- Decision: `2026-04-17_decision-workflow2-scope-overrun-3b7e0f1-ed45b7e`
- Fact: `2026-04-17_fact-markfailed-callback-race-still-at-head-ed45b7e`
- System facts: 7 `2026-04-17_name-…` entries covering matcher gate, batch_id flow, payout-note prefix, deposit approval audit, telegram report revamp, Mongo indexes, pullout RBAC rename.

### Outstanding thread the next agent needs to watch

**Open requirement question** carried over from the prior handoff:

> Does PR #189's request_id-gated re-enable of `tryReconcileAfterMarkFailed` count as the "callback redesign" the ON_HOLD decision required, or is a deeper dispatch-level change still needed?

This is a `requirement-writer` / `code-reviewer` call, not a technical-writer call. DRIFT-11 stays open until that decision is recorded. The ON_HOLD rows in `docs/test-index.md` also stay until that decision.

### Next expected Workflow 2 trigger

First PR after #203 merges that touches any in-territory file. Most likely surfaces (in priority order):
1. Callback-dispatch fix (DRIFT-11 resolution) — `services/withdrawalQueue.go:971/984/1033–1038`.
2. Swagger regen (DRIFT-3 / #182) — `swagger_simple.json`.
3. Status-comment fix (DRIFT-2 / #181) — three three-line edits in `models/`.

### Housekeeping

A stray untracked `ψ/inbox/` exists in the repo working tree — artefact of a prior `arra_handoff` whose relative-path resolution landed in cwd rather than `~/.arra-oracle-v2/`. Low-priority — either add to `.gitignore` next session or leave alone.