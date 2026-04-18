# W8 first-pass handoff — deposit-qr-request

**PR:** https://github.com/kokarat/mobiz-payment-gateway/pull/204 (open, not merged)

**Doc:** `docs/flows/deposit-qr-request.md` @ed45b7e

**Claim strength:** S4 reverse-engineered. Doc header carries `[RATIFICATION_PENDING:4]`.

**W8 root trace:** `64ef2dc5-7a6b-45f4-8ab6-3fe49e9202a0`

## Open threads (BLOCKING before merge)

- Oracle thread **#4** — ratification thread (required). Confirm intent matches system design.
- Oracle thread **#5** — `pending_review` no-callback semantics. Intent vs missing-feature.

## Done this session

- 8-step actor-crossing mermaid (Merchant · Payer · Gateway · BankBot · Bank).
- 6 `// impl:` pointers, 2 `// ext:` (external-only hops). 0 `[UNIMPLEMENTED]`, 0 `[DRIFT]`.
- Cross-link in `docs/current-system.md` §3.3.
- Two learnings filed:
  - `2026-04-17_flow-deposit-qr-request-merchant-integrator-in.md`
  - `2026-04-17_flow-cross-repo-breadcrumb-deposit-qr-request-cr.md`
- Retro: `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/17/19.49_flow-deposit-qr-request.md`

## Pickup for next agent

1. **Don't merge PR #204** without resolving thread #4 (and acknowledging thread #5 either way).
2. **When thread #4 answers:** edit the doc header — drop `[RATIFICATION_PENDING:4]`, bump claim strength to `S2 (ratified via thread #4)`, log the state change in §Change log.
3. **When thread #5 answers reading B (missing feature):** file `#missing-feature` learning + open a feature PR; then supersede the current flow learning with a revised one documenting the new callback behaviour.
4. **Next W8 candidates (ranked):**
   1. `deposit-slip-upload-admin-approve` — already breadcrumbed in §Related flows; different actors (admin) + auth (JWT).
   2. `deposit-expiry` — smallest scope, single scheduler + one callback. Good W8 ergonomics practice.
   3. `withdrawal-dispatch` — cross-repo, deferred until `bot-writer` can run W8 on its side so both flows land together with `arra_trace_link`.
5. **For bot-writer (future):** when it runs W8 on the deposit-qr-request counterpart, chain with `arra_trace_link(prevTraceId=64ef2dc5-7a6b-45f4-8ab6-3fe49e9202a0, nextTraceId=<bot trace>)`. Contract points the bot depends on are listed in the cross-repo-sync learning.

## Workflow candidates for clarification (raised in retro)

- `// ext:` vs `[UNIMPLEMENTED]` semantics — I invented `// ext:` to mark "external actor hop, no code on our side expected". Workflow's example uses `[UNIMPLEMENTED]` ambiguously for this. One of us should pick a standard.
- `// impl-level` marker on the cross-link reads oddly; worth one sentence in the workflow.
- `[RATIFICATION_PENDING]` has no decay rule — what if the thread is never answered?

These three go into a future PR against `.agent/skills/technical-writer/references/workflow-8-flow-map.md`, not this PR.