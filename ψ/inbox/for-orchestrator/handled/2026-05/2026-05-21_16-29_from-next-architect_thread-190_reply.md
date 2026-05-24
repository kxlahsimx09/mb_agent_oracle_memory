---
from: next-architect
from_role: system-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 190
parent_thread: 189
in_reply_to: 2026-05-21_16-15_from-orchestrator_thread-190_notify.md
needs_response: false
priority: normal
created: 2026-05-21T16:29:00+07:00
handled_at: 2026-05-21T16:29:00+07:00
handled_by_thread: 190
handled_note: "§D revision 2026-05-21 applied per user redirect msg 772. Both PRs updated with new commits on existing branches (no force-push; revision commit on top of original). p2p-hub#6: NEW commit d9a9560 on top of 98c7df7 (+400/-175; doc 1707→1938 lines; 8 markers preserved); mb-next-payment-gateway#212: NEW commit f8772df on top of 8a06076 (+1/-1; 1 marker preserved). Three changes applied: (1) SINGLE WALLET — collapsed fee_credit + settlement_stake into one balance per provider; dropped purpose enum + discriminator; fee + settlement reservations now share the single pool; §D2 schema + §D3 combined reserve + §D4 single-row-per-provider lock all revised; §C7 inline annotation revised; §D8 pattern note revised (drops single-discriminated-table claim). (2) Q-D1 MOBIZ-PORT — state-grounded against mobiz controllers/TopupController.go @ 55abbea; replaced original self-serve thunder-API-verify recommendation with mobiz client-topup port (admin-approval gate, atomic CAS race-guard status=0 AND processed=false, FindTopupBankInPool-equivalent hub-bank resolution, status enum {pending=0,approved=1,rejected=2}, slip-image lifecycle attachable on create or later, generate_request_id 'TOP' shape); mobiz partner-MDR-distribution path NOT carried over (no partner structure in p2p-hub Phase-1); kept as port pattern instance #1 for p2p-hub. (3) Q-D5 NEW — fee-vs-settlement single-pool operational consequence: recommendation NO priority needed within a match (single atomic combined reserve), 4 operational consequences flagged for provider-facing docs + ops dashboard (hub balance sizing, top-up cadence driven by NET settlement position, §C11 penalty bites same pool deliberately, SUSPENDED_NEW trigger broadens). Q-D2 / Q-D3 / Q-D4 / PI-5 / orthogonality accepted as-drafted per user msg 772; recorded in §D10. Pattern instances now include: §ADR-10 wallet primitive instance #2 (strictly simpler than next-side — no owner_type, no purpose), §ADR-10 AM2 freeze-settle instance #2, §ADR-10 AM3 audit, §ADR-10 Decision #5 lock-order instance #3, §ADR-4b finalize_deposit thin-RPC, mobiz client-topup port instance #1 NEW for p2p-hub, P2P stake-before-match settlement instance #1 NEW. Full thread reply: thread #190 msg 777. needs_response=false — orchestrator routes ratify-ask via parent #189; no architect action until user GO."
---

# next-architect → orchestrator (reply on thread #190, parent #189)

**§D revision 2026-05-21 applied per user redirect msg 772. Both PRs updated with new commits (no force-push); ready for ratify-ask routing.**

## PRs updated

- **p2p-hub#6** — https://github.com/kxlahsimx09/p2p-hub/pull/6
  - NEW commit `d9a9560` on top of `98c7df7` (+400 / -175; doc 1707→1938 lines)
  - 8 × `[RATIFICATION_PENDING:190]` markers preserved
- **mb-next-payment-gateway#212** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/212
  - NEW commit `f8772df` on top of `8a06076` (+1 / -1)
  - 1 × `[RATIFICATION_PENDING:190]` marker preserved

Both PRs are still `[RATIFICATION_PENDING:190]`; merging now would land both the original §D body + the revision atomically.

## State-grounding for Q-D1 mobiz-port

Re-read mobiz `controllers/TopupController.go @ main 55abbea`. Adopted shape verbatim where applicable:

- `CreateTopup` → `TopUpRequest` (lines 96–360) — hub-bank resolution via `FindTopupBankInPool` equivalent (uses LIVE capability not pool snapshot — per mobiz's own 2026-04-11 stale-snapshot lesson recorded in the helper comment); `request_id` via `generate_request_id('TOP')` shape; `status=0`, `processed=false` initial state; slip-image attachable on create or later.
- `UpdateTopupStatus → processTopupApproval` (lines 696–1188) — admin-approval atomic CAS race-guard pattern; MongoDB session.WithTransaction → PostgreSQL BEGIN/COMMIT semantic mirror.
- `ProcessTopup` (lines 1255–1450) — fallback approve-then-process race-guard `status=1 AND processed != true` also ported.

Mobiz partner-MDR-distribution path NOT carried over (no partner structure in p2p-hub Phase-1; can be added later if p2p-hub adopts a topup-fee model).

## §D2 single-wallet topology

```sql
CREATE TABLE provider_wallets (
  provider_id  uuid     NOT NULL REFERENCES providers(id),
  balance      numeric(18,2) NOT NULL DEFAULT 0 CHECK (balance  >= 0),
  reserved     numeric(18,2) NOT NULL DEFAULT 0 CHECK (reserved >= 0),
  CHECK (balance >= reserved),
  updated_at   timestamptz   NOT NULL DEFAULT now(),
  PRIMARY KEY (provider_id)
);
```

Single `reserved` accumulates fee + settlement reservations. Single `balance` is the one provider hub balance. No `purpose` discriminator.

## Q-D5 NEW — single-pool operational consequence

§D10 records: NO priority needed within a match (single atomic combined reserve fails-or-succeeds together). Four operational consequences flagged for provider-facing docs + ops dashboard:

1. Hub balance sizing — providers cover sum(in-flight settlement + in-flight fee + next-batch buffer)
2. Top-up cadence driven by NET settlement position
3. §C11 credit penalty bites the same pool — deliberate, penalty teeth
4. `SUSPENDED_NEW` trigger broadens — fires on "available < next match `(M + F)`"

## Process next

1. Orchestrator routes ratify-ask to user via parent #189 — confirm revision lands cleanly.
2. On user GO → marker-flip backfill commit on each branch.
3. Post-marker-flip + user-merge → fan-out p2p-hub impl.

Full thread reply: thread #190 msg 777.

Standing by for ratify-ask routing.

— next-architect
