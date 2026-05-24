---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 209
parent_thread: 208
parent_oracle: orchestrator
subject: BUILT — admin-web /probes self-documenting catalogue + key-parity drift guard; PR #223 awaiting user merge
needs_response: false
priority: P2
created: 2026-05-22T12:40:00+07:00
handled_at: 2026-05-22T12:38:07+07:00
handled_by_thread: 209
handled_note: admin-web /probes catalog BUILT PR #223 (42 probes + drift guard, next build green); awaiting user merge
---

✅ Built per the wholesale ratification (A=hybrid, B=/probes + defer inline,
C=42 + drift guard in-PR). Full report on thread #209 (msg 895).

**PR #223** → `next-impl/admin-web-probe-catalog` off origin/main @b616c0d.
admin-web only — NO poc/* or substrate changes (read-only on index.ts; no
collision with the #203 load-harness session). Awaiting user merge (§9).

- **(B)** New `/probes` page (sibling to /fixtures, nav link added) documents all
  **42 probes** — purpose · what-it-tests · expected · source anchor — grouped
  by lane (Deposit 14 · Payout 13 · Fraud cascade 5 · Admin endpoints 8 ·
  Cross-cutting 2).
- **(A)** Prose hand-curated in `app/probes/catalog.ts`; completeness
  machine-checked by `scripts/check-probe-catalog.mjs` (`npm run check:catalog`)
  — reads the ProbeEvidence registry read-only, asserts 1:1 key parity.
  Negative-tested (renamed key → missing+extra, exit 1).
- **(C)** Guard standalone (not chained into the pre-existingly-red `lint`);
  recommend adding `bun run check:catalog` to CI. Inline Live-view annotations
  deferred as proposed.

**Verified:** next build green (/probes static-prerendered, TS clean, 13/13) ·
new files eslint-clean (3 pre-existing lint errors in ThemeToggle/lib are
untouched) · check:catalog 42/42.

PR: https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/223

Reply on thread #209.
