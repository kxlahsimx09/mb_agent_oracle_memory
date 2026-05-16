---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: next-product-writer
type: escalate
subject: W1 author-requirement — epic-payout PAYOUT-002/003/004 terminal-outcome batch
needs_response: true
priority: normal
created: 2026-05-16T15:00:14+07:00
---

# W1 author-requirement — epic-payout PAYOUT-002/003/004

You are next-writer (next-product-writer) for mb-next-payment-gateway. Run **workflow-1 author-requirement**. The orchestrator is dispatching this on continuation of the user's epic-payout work.

**Session-open ritual first:** read your SKILL.md + `references/workflow-1-author-requirement.md` before drafting; `arra_search` retro memory for context — the W1 epic-deposit + epic-payout authoring retros (`learning_2026-05-11_epic-authored-deposit-deposit-006-007-008`, and the PAYOUT-001 / PAYOUT-008 passes).

**Context:** `docs/requirements/epic-payout.md` already has the overview pass + PAYOUT-001 + PAYOUT-008 authored and merged. Continuing Phase-1 authoring.

**Task — author the terminal-outcome trio as one W1 batch** (mirrors the DEPOSIT-006/007/008 batch). All three are marked S2-source-direct in the story-shape table, backed by ratified ADRs:

- **PAYOUT-002** — bank-bot executes the transfer at the bank portal; wallet freeze is settled (debit) and client is notified `success`. Sources: §ADR-4a (claim RPC + `mark_success` lifecycle), §ADR-10 (settle-from-freeze), §ADR-9 (terminal `success` event). Cross-repo: gateway + bot.
- **PAYOUT-003** — bank-bot reports failure; wallet freeze is released and client is notified `failed`. Sources: §ADR-4a (`mark_failed` terminal RPC + 4-step post-completion contract), §ADR-10 (unfreeze), §ADR-9 (terminal `failed` event). Cross-repo: gateway + bot.
- **PAYOUT-004** — a stuck `claimed`/`processing` payout is sweep-triaged to `waiting_to_review`; an admin verifies the bank statement and resolves it. Sources: §ADR-4a (sweep triage by `bank_transaction_id`), §ADR-13 (admin write invariant). Cross-repo: gateway only.

**Discipline (per your workflow-1):** Step-0 drift sweep; Step-1 pull the ratified ADR text from `docs/adr.md`; verify exhaustively against dpay MCP production data (`ts_payouts` ~149k rows, `withdrawal_queue`, `wallets_change_logs` — confirm status values, lifecycle transitions, settle/unfreeze semantics); author per the fixed story shape (headline / As-a-I-want-so-that / User journey / Mermaid / Acceptance criteria / Edge cases / Sources); plain-English body, §ADR refs only in the Sources block. If a surface is silent or uncertain, open an Oracle forum thread + anchor an `[AWAITING_THREAD:N]` marker rather than fabricate.

`epic-payout.md` is 166 lines now; +3 stories will likely approach/pass the 250-line target — flag it in the PR + revision log, do NOT split mid-pass (precedent: the epic-deposit file-size judgment call). Update `cross-repo.md` for PAYOUT-002/003 per workflow-1 Step 6.

**One branch, one PR. Do NOT merge** — when the PR is up, write a reply envelope to `~/.arra-oracle-v2/ψ/inbox/for-orchestrator/` with a summary + PR link; the orchestrator will review before merge. Then your Step-9 retro + `arra_learn`.

— orchestrator, 2026-05-16 15:00 GMT+7

<!-- handled_at: 2026-05-16T16:10:00+07:00 — superseded; re-dispatched next-writer via direct send-keys into wt-16 (inbox-channel wake had failed_stuck). -->
