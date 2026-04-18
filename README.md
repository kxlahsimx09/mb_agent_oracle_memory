# mb_agent_oracle_memory

Central repo holding **both** the Oracle vault and the `.agent/` configuration for every project in the Soul-Brews ecosystem. One brain, many project repos, all symlinked.

## Layout

```
mb_agent_oracle_memory/
├── ψ/                                    # UNIVERSAL vault (not scoped to any project)
│   ├── memory/
│   │   ├── resonance/                    # soul-brews-core principles (P-001..P-004)
│   │   ├── learnings/                    # cross-project learnings
│   │   ├── retrospectives/               # session retros
│   │   └── traces/                       # evidence chains
│   └── inbox/
│       └── handoff/                      # pending handoff messages
│
├── github.com/<owner>/<repo>/            # project-scoped content
│   ├── .agent/                           # charter + skills + fleet for this project
│   │   ├── AGENTS.md
│   │   ├── fleet/<fleet>.json
│   │   └── skills/<role>/SKILL.md + references/
│   └── ψ/memory/                         # project-scoped vault (arra_learn with project tag)
│
├── scripts/
│   ├── setup-symlinks.sh                 # run once per machine — creates .agent/ symlinks
│   ├── verify.sh                         # check symlinks + vault state
│   └── check-skill-drift.sh              # compare shared SKILL.md copies
│
└── README.md                             # (this file)
```

## How Oracle finds it

```
Oracle DB has setting:  vault_repo = kxlahsimx09/mb_agent_oracle_memory
arra_learn calls:       ghq list -p <vault_repo> → this dir
arra_learn writes:      <this-dir>/<project>/ψ/memory/learnings/<file>.md
                     OR <this-dir>/ψ/memory/learnings/<file>.md   (if no project)
Indexer scans:          <this-dir>/ψ/memory/... + all <this-dir>/**/ψ/memory/...
```

## How project repos see their `.agent/`

Each project repo (e.g. `mobiz-payment-gateway`) has its `.agent/` as a **symlink** to this central repo. Run `scripts/setup-symlinks.sh` once per machine.

```
~/Code/github.com/kokarat/mobiz-payment-gateway/.agent
    → <this-repo>/github.com/kokarat/mobiz-payment-gateway/.agent
```

Edits in either location appear in both (it's the same inode). Single source of truth.

## Projects currently mounted

| Project | Roles active |
|---|---|
| `github.com/kokarat/mobiz-payment-gateway` | `pg-writer`, `pg-tester` |
| `github.com/kokarat/bank-bot` | `bot-writer` |
| `github.com/Soul-Brews-Studio/arra-oracle-v3` | `brew-ops` |

To mount a new project:
1. Create `github.com/<owner>/<repo>/.agent/` with its `AGENTS.md`, `fleet/`, `skills/`.
2. Add the project to the `PROJECTS` array in `scripts/setup-symlinks.sh`.
3. Run the script.
4. Commit + push this repo.

## P-001 applies

This repo is the vault. **Nothing is deleted.** Corrections are new files superseding old ones via `arra_supersede`. Old files stay. Git history is the audit log on top of the append-only discipline.
