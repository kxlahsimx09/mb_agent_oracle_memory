---
from: next-writer
from_role: technical-writer
to: orchestrator
to_role: orchestrator
type: consult-reply
thread: 250
parent_thread: 250
parent_oracle: orchestrator
subject: p2p-hub PRD — PROPOSE step delivered in #250 (epic decomposition + ID scheme + sample epic) — needs user style-confirm before full write
needs_response: true
priority: normal
created: 2026-05-27T16:46:00+07:00
handled_at: 2026-05-27T16:48:00+07:00
handled_by_thread: 250
handled_note: next-writer PRD propose step (msg 1181 — 9-epic decomposition + ID scheme + provenance model + full sample epic-provider-topup + 5 decisions) read + relayed to user for the style-confirm. Campaign #250 stays OPEN — awaiting user (a) style-match confirm + (b)–(e) the 4 structural decisions; on GO, writer authors all 9 epics + scaffolding as ONE docs PR (no merge). Reply = doorbell, handled.
---

Campaign #250 — propose-then-proceed, **propose step complete**. Full reply in thread #250 (msg 1181) — read via `arra_thread_read 250`.

**Routing note:** this resolves the earlier `2026-05-27_16-36_from-next-writer_thread-250_routing-flag.md` — the #249-dispatched session correctly flagged-and-deferred #250; you routed it to THIS session (my bootstrap named thread-250 explicitly), so #250 is now owned and the propose step is delivered. No collision.

**What I delivered in #250 (for the user's style-confirm):**
1. **Epic decomposition** — 9 epics + 4 scaffolding files mirroring mb-next `docs/requirements/`: protocol-foundations · provider-lifecycle · matching · verification · provider-wallet(+settlement) · billing-fees · provider-topup · reconciliation · dispute-liability. Maps §A–F.
2. **Requirement-ID scheme** — mb-next `EPIC-NNN`: PROTO-/PROV-/MATCH-/VERIFY-/WALLET-/BILL-/TOPUP-/RECON-/DISPUTE-.
3. **Provenance model** — S2 = §A–D+§F ratified `#decision`; S3 `[RATIFICATION_PENDING:206]` = §E-only behaviors; per-epic Build-status line; Phase-2 items in "Deferred Surfaces" sub-sections; `⚖️ NEEDS-LEGAL` (Q7 / §F source_funds_clawback) flagged not settled. (p2p-hub has no `docs/adr.md` — the phased design doc IS the decision source, cited `new:design §X`.)
4. **One full sample epic** — `epic-provider-topup.md` (closest 1:1 analog to mb-next `epic-topup.md`), drafted complete with Sources + trust labels + G/W/T.

**5 decisions surfaced for the user** (in #250 §5): (a) style-match confirm; (b) un-prefixed ids vs `HUB-` namespace [rec: un-prefixed]; (c) billing separate vs folded into wallet [rec: separate]; (d) reconciliation separate vs folded into protocol-foundations [rec: separate]; (e) extend `docs-site/sync-content.sh` to render requirements vs keep doc-site design-only.

Grounded on fresh `origin/main @52ab1d2` (§F merged PR #10; local clone was 3 behind). **NO code, NO PR.** On the user's style-confirm + your GO I author all 9 epics + scaffolding and open ONE docs PR off fresh origin/main (no merge).

Please relay the sample + decomposition to the user for the style-confirm.
