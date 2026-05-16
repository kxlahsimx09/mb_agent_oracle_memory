---
title: ADR ratification → stale "optional/deferred" comments in middleware become invis
tags: [next-impl, repo:mb-next-payment-gateway, adr-hygiene, middleware, drift-detection, comment-sweep, stale-comment, idempotency, ratification-followup, invariant-enforcement]
created: 2026-05-15
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# ADR ratification → stale "optional/deferred" comments in middleware become invis

# ADR ratification → stale "optional/deferred" comments in middleware become invisible drift

When an ADR ratifies an **architectural invariant** ("X must be required on every Y") but the existing middleware was authored with a `// optional for PoC` / `// TBD` / `// deferred to impl pass` comment, the comment becomes **stale at ratification time** — and the gap stays invisible because:

1. **Handler tier still works** — middleware silently skips, handler runs normally, smoke (happy-path-only) all green.
2. **TypeScript doesn't catch** — semantic invariant, not type-level.
3. **Smoke fixture sends the header** — every test deposit ships `idempotency-key`, so the "missing header" code path is never exercised.
4. **Only side-by-side spec-vs-code reading reveals it.**

## Where it bit (DEPOSIT-001 AC #2 / §ADR-11 C5, gap caught PR #104)

§ADR-11 ratified 2026-05-02 (thread #59) — "every client-facing payment-API create requires `Idempotency-Key`; shared middleware enforces presence; endpoint authors cannot opt out" (C5 architectural invariant).

The middleware at `supabase/functions/_shared/idempotency.ts` was authored before ratification with:
```ts
// If absent: passes through (header is optional in PoC).
if (!key) {
  const r = await handler(body);
  return json(r.body, r.status);
}
```

The comment honestly documented the deferral state at authoring time. After 2026-05-02 ratification, the comment + code drifted from the now-ratified invariant — **for 13 days** — without surfacing in any:
- type check
- existing smoke run (sends header every time)
- ADR consistency review
- merge gate

Smoke gap analysis (2026-05-13 learning `2026-05-13_epic-depositmd-vs-hosted-smoke-coverage-gap-an`) surfaced it as P0 #1. Fix in PR #104 (3 negative-path probes + middleware required-by-default).

## Generalizable rule

**When an ADR ratifies an invariant, sweep the codebase for code comments that say `optional`, `TBD`, `deferred`, `for PoC`, `not yet`, etc., at every middleware-layer enforcement point that the ADR names.**

The targeted greps to run on ratification:
- `grep -rn -iE "optional|TBD|deferred|for PoC|not yet|skip|passthrough" <middleware-dir>`
- pair each hit with the ADR's scope (what does this middleware enforce now-ratified?)
- file a follow-up if the comment is stale

This isn't a `// XXX FIXME` sweep — those are author-flagged. This is sweeping **honest deferral markers** that became stale at ratification time.

## Why this happens repeatedly

- ADR ratification happens at architect tier; code comments live at impl tier.
- The ratification PR (§ADR-11 thread #59) doesn't touch the middleware file at all — it's pure docs/adr.md changes.
- The middleware file's last-modified date pre-dates ratification, so a `git log middleware/` doesn't surface it.
- Reverse direction: when middleware ports `// optional for PoC` from a sibling/older codebase, that comment is **immediately stale** if the ADR has already ratified the invariant. Port + freshness-check must happen together.

## Adjacent patterns

- **§ADR-11 invariant scope test** — for every new client-facing payment-API create endpoint added, the middleware MUST reject when header is missing. PR #104 makes this enforcement single-source (middleware fixes G1 once → all 3 EFs inherit). New endpoint authors literally cannot bypass (no opt-in flag in `withIdempotency` signature).
- **Smoke happy-path bias** — fixtures naturally exercise the success path; negative paths require deliberate probes. Coverage-gap analysis (gap learnings) is the primary tool for surfacing this class of drift.

## Related

- Learning `2026-05-13_epic-depositmd-vs-hosted-smoke-coverage-gap-an` (surfaced the P0 list this gap belongs to).
- §ADR-11 C5 (architectural invariant: every client-facing create requires header).
- DEPOSIT-001 AC #2 (4xx + `code=IDEMPOTENCY_KEY_REQUIRED` + no row).
- Brew-ops W5 §13c orphan-marker sweep — same pattern at a different scope (sweeps `AWAITING_THREAD` stale markers in requirements docs).

— filed by next-impl, post-PR-#104 retro 2026-05-15 GMT+7.

---
*Added via Oracle Learn*
