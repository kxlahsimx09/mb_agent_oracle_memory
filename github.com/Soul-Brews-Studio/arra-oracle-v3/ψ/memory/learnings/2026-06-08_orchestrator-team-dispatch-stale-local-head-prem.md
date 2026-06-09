---
title: orchestrator team-dispatch — STALE-LOCAL-HEAD premise failure (campaign p2pdoc -
tags: [orchestrator, team-dispatch, procedure-violation, verify-against-live-HEAD, stale-local-main, origin-main-not-local, duplicate-adr, pr-346-closed, pr-333, adr-17, p2p-matching, p2pdesign, campaign-correction, maw-wake-fanout-antipattern, team-dispatch-helper, mb-next-payment-gateway, repo:arra-oracle-v3, fleet]
created: 2026-06-08
source: orchestrator session 2026-06-08 — campaign p2pdoc->p2pdesign correction
project: github.com/soul-brews-studio/arra-oracle-v3
---

# orchestrator team-dispatch — STALE-LOCAL-HEAD premise failure (campaign p2pdoc -

orchestrator team-dispatch — STALE-LOCAL-HEAD premise failure (campaign p2pdoc -> corrected as p2pdesign, 2026-06-08). MISTAKE: dispatched a 5-agent campaign to AUTHOR §ADR-17 (P2P matching) + requirement epic, after "verifying" ADR-17 was unwritten by grepping the LOCAL main checkout (407b2fc) — which was STALE. §ADR-17 was in fact ALREADY MERGED on origin/main via PR #333 ("P2P Matching + Wallet-Settlement Subsystem", #provisional, PM1-PM13 + DP0-DP11, owner GO 2026-06-05), and docs/design/p2p-matching/sim/match_sim.py already existed. The team got far enough to push branch campaign/p2pdoc and open PR #346 — a DUPLICATE ADR-17 PR (also a substantively WRONG design: it re-derived the old 2026-05-09 POC bank-rail-offload model, whereas the merged ADR-17 is the THIRD, different model = intra-gateway closed-loop p2p-wallet settlement).

ROOT CAUSE: Step 2.5 "verify premise against live HEAD" was run against LOCAL HEAD, not `git fetch origin && git show origin/main:<path>`. Local fleet checkouts drift hours behind a fast-moving origin/main (multiple campaigns merging PRs continuously). The verify-against-HEAD entries already IN docs/adr.md ("ADR-17 reserved") were themselves stale (written at old HEADs b92f9a1/e35a6e1/1fc5f2f) and reinforced the wrong conclusion.

FIX APPLIED: closed PR #346 (duplicate of #333, comment cross-refs), deleted branch campaign/p2pdoc (local+remote), stood down the p2pdoc team (finish.sh), re-created branch campaign/p2pdesign off origin/main (NOT local main — local main had an un-pushed [NOT FOR MERGE] commit 407b2fc that blocked ff), re-dispatched the CORRECT task: the design pass under docs/design/p2p-matching/ that ADR-17 explicitly DEFERS (schema, RPC bodies, EF wiring, expiry windows, failure-policy, §Data-validation grounded in match_sim.py) — next-writer (core design) + next-ui (UI design) + next-pm (track). No architect needed (ADR-17 done).

RULE (binding for future dispatch): ALWAYS `git fetch origin <default-branch>` THEN verify the premise against `origin/<default>` (git show origin/main:path / git ls-tree origin/main), NEVER the local checkout, before writing a dispatch contract — local is stale by default on an active fleet. And when an ADR/epic is the subject, check `gh pr list --search "<topic>" --state all` + the merged history, not just the working tree: the artifact may already exist in a merged PR. Also: helper team-dispatch-helper.sh branches the campaign worktree off the repo's CURRENT local HEAD — pre-create the campaign branch off origin/main (git branch campaign/<slug> origin/main) so the worktree starts current.

SECONDARY: first dispatch attempt used `maw wake -p` with a multi-line/unicode prompt — it fanned out to all of next-architect's worktrees and the prompt leaked into the shell (zsh quote> continuation); aborted with Ctrl-C (nothing ran). Lesson reinforced: use scripts/team-dispatch-helper.sh (workflow-2), never maw wake -p, for orchestrator dispatch — the helper delivers the kickoff bracketed-paste-safe and targets one window.

---
*Added via Oracle Learn*
