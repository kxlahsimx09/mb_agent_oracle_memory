---
title: Test write after vault_repo migration (2026-04-17) — Verifying that arra_learn n
tags: [brew-ops, repo:cross, current, smoke-test, vault-migration]
created: 2026-04-17
source: Vault migration 2026-04-17 GMT+7
project: github.com/soul-brews-studio/arra-oracle-v3
---

# Test write after vault_repo migration (2026-04-17) — Verifying that arra_learn n

Test write after vault_repo migration (2026-04-17) — Verifying that arra_learn now writes to the central repo at `kxlahsimx09/mb_agent_oracle_memory` after setting `vault_repo` in Oracle DB. This entry is a smoke test; delete or supersede if the plumbing works as expected.

## Expected behavior
- `getVaultPsiRoot()` resolves `vault_repo` setting → `ghq list -p kxlahsimx09/mb_agent_oracle_memory` → `/Users/dev01/Code/github.com/kxlahsimx09/mb_agent_oracle_memory`
- File lands at `<central>/github.com/Soul-Brews-Studio/arra-oracle-v3/ψ/memory/learnings/<slug>.md` (because project tag is set)
- DB row inserted directly with `source_file` relative to vault root

If file appears outside the central repo, the migration is incomplete.

---
*Added via Oracle Learn*
