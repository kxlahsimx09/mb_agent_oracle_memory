---
title: title: next-tester DEPOSIT V1 bijection — 5 AC clauses → 5 probes (positive+nega
tags: [next-tester, v1-bijection, deposit, probe, anti-bias, spec-decoupled]
created: 2026-06-03
source: tests/integration/probes/index.ts
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# title: next-tester DEPOSIT V1 bijection — 5 AC clauses → 5 probes (positive+nega

title: next-tester DEPOSIT V1 bijection — 5 AC clauses → 5 probes (positive+negative off ground-truth, SPEC-decoupled)

Campaign nextteam, 2026-06-03. Built the DEPOSIT vertical-slice probes IN PARALLEL with next-dev off the AC (next-writer_nextteam_deposit-ac.md) — never reading next-dev's code (de-bias layer 1). V1 bijection: exactly one probe per AC clause, each QUOTES the clause and asserts positive+negative off restSelect/restCount + API responses ONLY, under §ADR-20 frozen-step clock. Files in tests/integration/probes/ (poc/integration left frozen, P-001).

- AC-1 deposit-001-ac1-create-qr.ts: POS 200+field set+fee=round_satang(gross×pct/100)+net=amount−fee+callback snapshot persisted; NEG request body cannot override server-derived deadline.
- AC-2 deposit-001-ac2-qr-payload.ts: POS channel==QR + payload w/ exact amount embedded + proxy type; NEG payload server-built+persisted, re-served byte-identical.
- AC-3 deposit-002-ac3-stepkey-credit-mdr.ts: POS Step-1 full-key → paid + client +net + 1 wallets_change_logs row/partner (credited-on-gross OR mdr_skip note) + ledger conserved gross=net+Σpartner+residual; NEG source-identity mismatch → no credit, stays pending, 0 wcl rows.
- AC-4 deposit-002-ac4-statement-dedup.ts: POS same row 3× → exactly 1 bank_statements row + 1 credit; NEG 2 distinct payments identical-composition one batch → both kept (not collapsed). Row count off table is load-bearing; EF inserted is secondary only.
- AC-5 deposit-002-ac5-success-callback.ts: POS 2xx → 1 callback_queue row to snapshot endpoint, attempt_count≥1, sent=true, dup-egress 0 off the TABLE; NEG non-2xx → sent stays false, attempt++, still 1 row.

Contract names centralized in probes/_spec.ts with [SPEC-PENDING] markers + SPEC_UNBOUND guard (runner exits non-zero while unbound) — bound only from next-dev's broadcast SPEC docs/spec/deposit-slice.md, never from code. All bundle clean (bun build). Runnable once SPEC published + stack deployed. Out-of-slice guardrails (all-or-nothing finalize, concurrent-finalize, wallet-lookup rollback, late-statement, idempotency replay) are the negative/race suite, follow-up pass.

source: tests/integration/probes/index.ts
tags: next-tester, repo:mb-next-payment-gateway, next, probe, deposit-001, deposit-002, evidence, fixture-source:repo-flow-doc
project: github.com/kxlahsimx09/mb-next-payment-gateway

---
*Added via Oracle Learn*
