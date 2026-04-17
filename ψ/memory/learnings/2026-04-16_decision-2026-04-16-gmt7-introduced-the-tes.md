---
title: Decision (2026-04-16, GMT+7) — Introduced the `tester` role for `mobiz-payment-g
tags: [tester, repo:mobiz-payment-gateway, current, decision, agent-design, integration-testing, mock-bank, supersede, handoff]
created: 2026-04-16
source: Conversation with Mobiz, 2026-04-16 GMT+7, brew-ops-oracle session
project: github.com/kokarat/mobiz-payment-gateway
---

# Decision (2026-04-16, GMT+7) — Introduced the `tester` role for `mobiz-payment-g

Decision (2026-04-16, GMT+7) — Introduced the `tester` role for `mobiz-payment-gateway` and superseded the `integration-test-writer` skill.

## Context
Human (Mobiz) asked for an agent analogous to `technical_writer` but for software-quality/test-suite health. Existing `.agent/skills/` already held three skills: `technical-writer`, `integration-test-writer`, `requirement-writer`. AGENTS.md §5 already named `tester` as a *planned* role — this activates it.

## What was decided
1. **New role `tester`** (tmux window `pg-tester-oracle`) added to `.agent/skills/tester/SKILL.md`. Responsibility: static-analysis auditor of the integration suite. Reads production Go/Node code but never modifies it. Owns `integration-tests/**`, `integration-tests/mock-bank/**`, `docs/test-index.md`, `docs/mock-bank-contract.md`, `docs/test-coverage-gaps.md`.
2. **Autonomy = static-analysis only.** User explicitly rejected the earlier "Wake → validate → run tests → report" option because running the suite is too slow. Final shape: "Wake → read code + tests → report" — runtime execution is a separate, user-initiated workflow. Keeps validate cycles fast.
3. **Superseded `integration-test-writer`** on *process* but preserved *intact* per P-001 — its pattern library (template, helpers, Patterns 1–11, pitfalls) remains the canonical reference for writing test code. Frontmatter amended with `superseded_by: .agent/skills/tester/SKILL.md` + dated banner. No content deleted.
4. **Three workflows created:**
   - `validate-integration-tests.md` — the primary "is each test still valid" pass; produces `docs/test-index.md` with taxonomy VALID/STALE/WRONG-SETUP/FLAKY/SUPERSEDED/UNKNOWN.
   - `add-new-test-case.md` — closes coverage gaps; requires user sign-off; registers the test in the 3 mandatory places (workflows doc, run-integration-test.sh, test-runner.html).
   - `mock-bank-sync-check.md` — detects drift between `mock-bank/server.js` and its consumers (backend, bank-bot, tests); proposes remediations but never silently patches.
5. **Future workflow `smoke-test.md` planned** (not yet written) — ≤5-min CI-friendly subset selected by `# @smoke` header tags.
6. **Fleet config** `.agent/fleet/20-payment-gateway.json` updated to declare the `pg-tester` window.
7. **AGENTS.md §5 + §11 updated** — tester promoted from *(planned)* to active with ownership details; §11 directory listing now reflects all four skills and the four workflows.

## Why static-only and not runtime
User feedback verbatim: "ตัดรันออกเพราะช้าเกินไป" (drop runtime execution — too slow). A static pass reads every `test-*.sh`, cross-references its curl/`api` calls against `routes/**`, its MongoDB reads against `models/**` bson tags, and its mock-bank calls against `server.js` endpoints. The five WRONG-SETUP hazards (missing `working_status: 'ready'`, missing `method` entries, unregistered mock destinations, REST-poll race on async MDR, timeout-treated-as-pass) are all detectable without executing anything.

## Why patterns stay in the superseded file
The `integration-test-writer` SKILL.md is 700+ lines of concrete test-writing patterns. Duplicating it into `tester/SKILL.md` would produce drift. Pointer + supersession banner is the P-001-compliant way to say "this is the process you should not follow; here are the patterns you still should follow."

## Deployment shape
`.agent/` is `.gitignore`d in `mobiz-payment-gateway` (confirmed: `.gitignore:100 /.agent`). Files land on disk locally. User has signalled the intent to extract `.agent/` into its own tracked repo and symlink it into each project repo — these files stage for that future migration.

## Files touched (all under /Users/dev01/Code/github.com/kokarat/mobiz-payment-gateway/.agent/)
- skills/tester/SKILL.md (new, 17 KB)
- workflows/validate-integration-tests.md (new, 15 KB)
- workflows/add-new-test-case.md (new, 11 KB)
- workflows/mock-bank-sync-check.md (new, 10 KB)
- skills/integration-test-writer/SKILL.md (modified — superseded_by frontmatter + dated banner; body preserved)
- fleet/20-payment-gateway.json (added pg-tester window)
- AGENTS.md (§5 roster + §11 directory listing)

## Rules the tester must honour (non-negotiable)
- Never modify production code (`controllers/`, `services/`, `models/`, `routes/`, `middlewares/`, `scheduler/`, `helpers/`, `db/`, `main.go`, `bank-bot/`).
- Never run the integration suite as part of validate.
- Never silently patch `mock-bank/server.js` — proposals only, user sign-off required.
- Never delete test scripts (P-001) — mark SUPERSEDED with a pointer.
- 3-layer tag convention: `#tester` + `#repo:mobiz-payment-gateway` + `#current` on every memory write.

## Open follow-ups (for a future session)
- Extract `.agent/` into its own repo so the roster is versioned.
- First real `tester` session: execute `validate-integration-tests` workflow to produce the initial `docs/test-index.md` baseline.
- Eventually write `smoke-test.md` workflow.
- Consider a similar supersession/pointer pattern for `.agent/workflows/create-test-case.md` (older workflow, now eclipsed by `add-new-test-case.md`).

---
*Added via Oracle Learn*
