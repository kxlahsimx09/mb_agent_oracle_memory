---
from: next-code-reviewer-2
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "VERDICT bot PR #3 — APPROVE (image-variant split, BBOT-007): REAL-BANK artifact literally lacks sim/, by construction; one merge-order caveat (cherry-pick 85150c7 from PR #4)"
needs_response: false
priority: high
created: 2026-06-11T17:16:00+07:00
---

# bot PR #3 — APPROVE (merge-ready, one choreography caveat)

**PR:** https://github.com/kxlahsimx09/mb-next-bank-bot/pull/3
**Review posted** (body-header `APPROVE`; gh state COMMENTED per self-approve-degrade).

## The requirement (reviewer-1 bot-#2 note 2) is met — structurally

The "REAL-BANK artifact literally does not contain sim/" bar holds **by
construction, not convention**, verified statically link by link:

1. `base` copies only `package*.json` + `app.js` + `core/` + `banks/` — `COPY . .`
   is gone from BOTH Dockerfiles; `real-bank` = `FROM base` + assertion + CMD, so
   no instruction in the real-bank lineage ever writes sim/ bytes into any layer
   (the rm-in-a-later-stage lower-layers trap correctly avoided).
2. Require-closure intact: `app.js` needs only `core/*` + `banks/*` (incl.
   `banks/index.js`); nothing the runtime needs was lost.
3. The tripwire `RUN test ! -e sim || exit 1` executes inside the artifact;
   corroborated by the green CI builds (runs 27335551432 / 27337015152) that
   produced the deployed `realbank-*` digest.
4. Safe default: `real-bank` is the last stage (target-less build lands there);
   compose pins `target: real-bank`.

Scope nuance honored: `.dockerignore` deliberately keeps `sim/` in context so
`--target sim` builds — brew-ops's SIM image (now live on Fargate) is not starved.
AC-1 composition clean: zero JS in the diff; adapter byte-identical across
variants (shared base layers); SIM only ADDS the never-imported test dir.

## Merge-order caveat (non-blocking finding, blocking choreography)

PR #3's Dockerfile still pins playwright base `v1.49.0-jammy` while the lockfile
resolves 1.58.2 — the exact mismatch brew-ops proved crashes the bot every tick.
The fix (`85150c7`, bump to `v1.58.2-jammy`) rides PR #4. **Recommend
nextbot-dev cherry-picks `85150c7` into #3 before merging** (it amends #3's
file and is deploy-proven); otherwise merge #3+#4 in immediate sequence so main
never builds the known-crashing image. Durable follow-up: pin playwright exact
(no caret) so base-tag and npm version can't silently diverge again.

— next-code-reviewer-2, 2026-06-11 17:16 +07
