---
title: W1 refine-adr workflow authored for system-architect (2026-04-22, GMT+7). Target
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, next, adr, refinement, workflow-authoring, w1, decision, five-input-priority, baseline-vs-refine, thread-first, handoff, known-projects-gap, brew-ops-followup]
created: 2026-04-22
source: Conversation with user 2026-04-22 GMT+7, session continuing from system-architect activation earlier same day. Workflow spec at .agent/skills/system-architect/references/workflow-1-refine-adr.md@a1729e2 (central memory main). User added baseline docs/adr.md (14KB) in mb-next mid-session. .claude/ preamble + settings.json added to mb-next matching fleet convention.
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# W1 refine-adr workflow authored for system-architect (2026-04-22, GMT+7). Target

W1 refine-adr workflow authored for system-architect (2026-04-22, GMT+7). Target repo: `kxlahsimx09/mb-next-payment-gateway` (note: not yet registered in KNOWN_PROJECTS; this learning is filed under the central memory repo because the workflow file physically lives there and KNOWN_PROJECTS rejects the new repo slug — see §Follow-up at bottom).

system-architect had no numbered workflows at activation (2026-04-22 earlier this session). Human requested W1 as iterative ADR refinement grounded in five canonical inputs. Workflow file lives at `kxlahsimx09/mb_agent_oracle_memory/github.com/kxlahsimx09/mb-next-payment-gateway/.agent/skills/system-architect/references/workflow-1-refine-adr.md` (548 lines). Central commit `a1729e2`.

Shape of W1 — key design decisions:

Five-input priority order (cheapest to most expensive):
1. Oracle memory — `arra_search` on learning/retro/thread/trace across all repos.
2. Current-system `docs/current-system.md` — accessed preferentially via the learnings pg-writer + bot-writer published, not direct file read.
3. Current-system `docs/flows/*.md` — W8 output from both writers; highest-signal source for end-to-end behavior.
4. Current-system `docs/constraints.md` — pg-writer W10 output; externally-imposed inheritance surface.
5. Current-system code direct read — last resort, must emit a summarizing `arra_learn` so the next W1 pass gets the fact at Input 1 cost.

Baseline vs refine modes: run 1 creates `docs/adr.md` from an embedded skeleton template (goals, non-goals, inheritance surface, subsystems, cross-cutting, migration map, scale targets, revisit triggers); run 2+ picks one focus theme per pass. Same step sequence (0-9) covers both; only Step 2's scope varies.

**Update mid-session:** the human placed a 14KB baseline `docs/adr.md` at `kxlahsimx09/mb-next-payment-gateway/docs/adr.md` (not read yet by system-architect). The first W1 run will therefore be a **refine**, not a baseline — start by reading the existing file end-to-end in Step 1, then pick the first focus theme in Step 2.

Iteration model: W1 is explicitly repeatable indefinitely. The `docs/adr.md` carries its own `## Revision log` tracking every pass (date, theme, delta, sources cited, threads opened/closed, learning id, commit). Prevents thrash (don't re-refine same section without new evidence) and gives future architects a running audit trail.

Thread-first for architect-level confirmation: un-ratified claims anchored via `[AWAITING_THREAD:<id>]` at the specific section. Three thread classes — Ratification, Disambiguation, Scope/strategy. Security-sensitive themes (auth, OTP, PII, RBAC, credentials) bypass async-thread convention — halt and ping the human directly.

Definition of Done per pass: `docs/adr.md` modified surgically (not full rewrite), revision log entry appended, every new `[AWAITING_THREAD:<id>]` has matching `arra_thread` call, every resolved thread has marker-strip + closing-message citation, one `arra_learn` with 3-layer tags + focus-theme tag, `arra_supersede` called for wholesale-replaced prior learnings, PR opened (not merged — human approval per AGENTS.md §9), retrospective written with AI Diary + Honest Feedback.

Inventory impact for brew-ops workflow-5 (memory audit):
- Main workflow-inventory table now carries a system-architect W1 row (central commit `56b5484`).
- Transitional section "Active roles without numbered workflows yet" removed.
- W1 passes will produce learnings tagged `#system-architect #repo:mb-next-payment-gateway #next #adr #refinement + <theme>`. Audit can now flag drift if these tags are missing.

Placeholder future workflows (named, not authored):
- W2 revise-design — wider-than-one-section revision with supersede chains.
- W3 migration-map-entry — one current↔next mapping per pass.
- W4 write-adr — standalone MADR file when a decision grows too large for docs/adr.md.
- W5 handoff-to-implementor — `arra_learn #handoff` naming the receiving role (once implementation agents exist).

Also in this session (unrelated but concurrent):
- `.claude/settings.json` + `.claude/oracle-preamble.md` created locally in `kxlahsimx09/mb-next-payment-gateway/.claude/`. Matches fleet convention: SessionStart hook loads the preamble, which points to `.agent/AGENTS.md` + `.agent/skills/<role>/SKILL.md`. `/.claude` added to the product repo's `.gitignore` per fleet convention (local-only setup).
- Commits: mb-next product repo `e3b4887` (initial `.gitignore /.agent`), `6578d42` (add `/.claude` to `.gitignore`).

Commits (central memory main):
- `a1729e2` feat(system-architect): add W1 refine-adr workflow.
- `56b5484` docs(arra-oracle-v3): promote system-architect W1 into brew-ops inventory.
- (this learning + its commit).

## Follow-up — KNOWN_PROJECTS gap (brew-ops territory)

`arra_learn(project="github.com/kxlahsimx09/mb-next-payment-gateway")` rejects the slug with `Unknown project` because `src/tools/learn.ts:68-77` (KNOWN_PROJECTS) doesn't list it. This learning is filed under `github.com/kxlahsimx09/mb_agent_oracle_memory` as a workaround. Needed fix: one-line PR to `Soul-Brews-Studio/arra-oracle-v3` adding `'github.com/kxlahsimx09/mb-next-payment-gateway'` to the Set. Low risk, brew-ops-scoped. Tag when filed: `#brew-ops #repo:arra-oracle-v3 #mcp-tools #decision`.

---
*Added via Oracle Learn*
