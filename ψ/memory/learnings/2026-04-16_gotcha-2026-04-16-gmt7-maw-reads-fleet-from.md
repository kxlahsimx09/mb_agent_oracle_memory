---
title: Gotcha (2026-04-16, GMT+7) — maw reads fleet from `~/.config/maw/fleet/`, NOT fr
tags: [brew-ops, tester, repo:maw-js, repo:cross, current, fleet, gotcha, mock-bank-n-a]
created: 2026-04-16
source: Live debug session 2026-04-16 GMT+7; maw-js src/commands/shared/wake-resolve.ts:148-156; audit log ~/.config/maw/audit.jsonl; diff of fleet files
project: github.com/soul-brews-studio/maw-js
---

# Gotcha (2026-04-16, GMT+7) — maw reads fleet from `~/.config/maw/fleet/`, NOT fr

Gotcha (2026-04-16, GMT+7) — maw reads fleet from `~/.config/maw/fleet/`, NOT from the repo-local `.agent/fleet/`. Edits to the repo-local copy do NOT take effect in a `maw wake` call until the runtime copy is synced.

## Symptom
User edited `.agent/fleet/20-payment-gateway.json` to add a `pg-tester` entry, then ran `maw wake pg-tester`. It silently failed (session did not spawn). The repo-local file looked correct to them.

## Real cause
maw-js (`src/commands/shared/wake-resolve.ts:148-156`) reads fleet JSONs from the runtime dir `~/.config/maw/fleet/*.json`, not from any repo's `.agent/fleet/` path. The two are separate files:
- `/Users/dev01/Code/github.com/kokarat/mobiz-payment-gateway/.agent/fleet/20-payment-gateway.json` — the source/committed copy
- `~/.config/maw/fleet/20-payment-gateway.json` — the runtime copy that `maw wake` actually reads

At the moment of failure, the runtime copy did not contain the new `pg-tester` window. The resolver correctly reported no matching window.

## Evidence
`diff` between the two files immediately after failure showed the repo-local already had pg-tester but the runtime copy did not. After the user ran some other maw commands (`fleet ls`, `stop`, `peek`), the runtime copy got updated to match the repo-local — and then `maw wake pg-tester` succeeded on the next try.

## Trigger for the sync (not yet fully characterised)
The runtime copy updated at 13:33 GMT+7 but the exact trigger wasn't logged. Candidates based on nearby audit entries:
- `maw fleet ls` may auto-reconcile.
- `maw stop` may flush state.
- `peek` may re-read.

Worth confirming by reading `src/commands/plugins/fleet/**` for reconcile behavior.

## How to apply
1. When adding/renaming fleet windows, edit **both** copies, or run whatever `maw fleet` subcommand reconciles them.
2. If `maw wake <name>` fails silently, first check: `diff ~/.config/maw/fleet/<fleet-name>.json <repo>/.agent/fleet/<fleet-name>.json`. If they differ, that's the first place to look.
3. Audit log at `~/.config/maw/audit.jsonl` records every `maw wake/peek/fleet/stop` call with timestamp and PID — useful for reconstructing what state maw saw.

## Broader implication for the `.agent/` extraction plan
The human plans to extract `.agent/` into its own tracked repo and symlink it into each project. Once that's done, the symlink target will be the single source of truth — but the `~/.config/maw/fleet/` runtime copy will still need its own sync mechanism. Either:
- maw grows an option to read fleet directly from a path (e.g., `~/.config/maw/maw.config.json` points at `<agent-repo>/fleet/*.json`), OR
- a post-edit hook in the agent repo runs `cp` or `ln -s` into `~/.config/maw/fleet/`.

Worth raising as a design question when the extraction PR opens.

## Tags (3-layer)
- repo:maw-js (the bug/behavior lives in maw source)
- repo:cross (affects any consumer of maw including arra-oracle-v3 and mobiz)
- current
- tester (session origin — this fix was observed while setting up the tester agent)
- brew-ops (the role that diagnosed it)
- gotcha
- fleet
- mock-bank n/a — NOT related; just the situation that surfaced it.

---
*Added via Oracle Learn*
