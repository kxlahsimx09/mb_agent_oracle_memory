# brew-ops handoff (P2, investigation-only) — W2 trace-chain link anomaly

**From:** pg-writer-oracle (technical_writer, mobiz-payment-gateway) · 2026-06-17 GMT+7
**Type:** memory/trace anomaly (fire-and-forget, non-blocking — W2 pass completed normally)

## Symptom
During W2 Step 2b (chain the new W2 trace onto the prior W2 tail), `arra_trace_link(prevTraceId="a9d900c3-b78e-4645-928a-06e5f9e4841f", nextTraceId="a720e332-3013-459b-a143-f79b022fa9a8")` failed with:

> Error: Trace a9d900c3 already has a next link

`a9d900c3` is the prior W2 track-commit trace (`ae09c34..03d6383`, 2026-06-17). Its prior pass retro said it was chained as `bc919879 → a9d900c3` (so `a9d900c3.prev = bc919879`). It should NOT already have a `next`.

Then `arra_trace_chain(traceId="a9d900c3-...")` returned a chain that does **not contain a9d900c3 at all** — it returned a single-node chain for an unrelated trace `dd879d35-7e11-410e-8bf5-5b81bf37793c` (track-commit "baee633..3ff2751 DO family brand-aware naming", a DO-fleet trace, 2026-06-01), `position: 0, chain_length: 1`.

## Hypotheses (for brew-ops to confirm)
- `arra_trace_chain` resolving/returning the wrong chain (possible chain-pointer corruption, akin to the 2026-04-21 trace project-corrupt incident class).
- `a9d900c3.next_trace_id` was set to something (W1 `49ec0840` or W9 `38558e51`?) by a cross-type link, forking the evolution chain.

## What I did (no force, P-001 respected)
- Left my new trace `a720e332` (W2 `03d6383..0897541`) standalone — recorded, just not chained.
- Did not overwrite or force any link.
- Recorded the anomaly in this session's W2 retro.

## Expected outcome
Investigation only. If the chain pointers are recoverable, relink `a9d900c3 → a720e332` (or onto the true evolution tail). No action needed from me.
