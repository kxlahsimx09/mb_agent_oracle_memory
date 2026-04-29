---
title: ψ-trap-retro-leak — pattern observed 2026-04-19 15:06 on mobiz W2 run. Agent wro
tags: [brew-ops, workflow-edit, workflow-2, technical-writer, vault-discipline, ψ-trap, retro-leak, config-ambiguity, pattern, repo:cross, 2026-04-19]
created: 2026-04-19
source: W2 Step 9 retro leak 2026-04-19 15:06 + W2 spec fix (both repos) same day
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ψ-trap-retro-leak — pattern observed 2026-04-19 15:06 on mobiz W2 run. Agent wro

ψ-trap-retro-leak — pattern observed 2026-04-19 15:06 on mobiz W2 run. Agent wrote the Step 9 retrospective to `mobiz-payment-gateway/ψ/memory/retrospectives/2026-04/19/15.06_w2-track-commit-admin-cancel-payout.md` (stray inside the product repo's working tree) instead of `~/.arra-oracle-v2/ψ/memory/retrospectives/2026-04/19/15.06_...` (the vault, via symlink).

## Root cause

Not an agent failure — a **spec ambiguity**. Pre-fix W2 Step 9 said only "Run `rrr`" with no explicit path, letting the agent resolve `ψ/memory/...` cwd-relative from whichever worktree it was in. `ψ/memory/` looks like a vault-relative path to any reader (the vault's structure is `ψ/memory/{learnings,retrospectives,traces}/`), but:

- The canonical vault lives at `$(ghq list -p kxlahsimx09/mb_agent_oracle_memory)/ψ`.
- That vault is surfaced to agents via the symlink `~/.arra-oracle-v2/ψ → <vault>/ψ`.
- A stray `ψ/` directory at the root of any project repo would look identical BUT is not indexed by Oracle, is invisible to sibling agents, and (critically) is not gitignored by default — so `git add` will track it into the product repo's permanent history.

## Historical context found during the incident audit

Mobiz-payment-gateway already has **21 files committed** to its git history from this exact trap, dating back to 2026-02. Three cleanup-and-revert rounds in history:

- `414f568` — "docs: remove all ψ/ from repo (session state belongs in Oracle vault)"
- `2965cda` — "Revert 'docs: remove all ψ/ from repo ...'"  (the revert)
- `da4d13a` — "docs: move session artifacts out of repo (belong in Oracle vault)"

Pattern: the cleanup happens, then someone else's worktree still has stray `ψ/` files, they commit them, the re-accumulation begins. Cleanup without the prevention at Step 9 (spec level) is Sisyphean.

Bank-bot has 10 stray files in its working tree as of today, **none committed yet** — the leak path is open but hasn't been exploited.

## Recovery recipe (documented in W2 specs now)

```bash
STRAY="<path-from-find>"
VAULT_DEST=~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/
mkdir -p "$VAULT_DEST"
if [ -f "$VAULT_DEST/$(basename "$STRAY")" ]; then
  diff -q "$STRAY" "$VAULT_DEST/$(basename "$STRAY")" && rm "$STRAY" || echo "differs — merge"
else
  mv "$STRAY" "$VAULT_DEST"
fi
(cd $(ghq list -p Soul-Brews-Studio/arra-oracle-v3) && bun run index)
```

Today's 15.06 retro was recovered this way + re-indexed (3 FTS chunks under `retro_15.06_w2-track-commit-admin-cancel-payout_{0,1,2}`). No content lost.

## Prevention landed today

Both W2 specs (mobiz Step 9, bank-bot Step 7) now have:

1. **Pre-write `readlink` check** — halts if the symlink doesn't resolve to the canonical vault.
2. **Explicit absolute path** for the destination: `~/.arra-oracle-v2/ψ/memory/retrospectives/YYYY-MM/DD/<slug>.md`.
3. **Named list of 4 traps NOT to take** — relative `ψ/memory/...`, `./ψ/memory/...`, `<project-path>/ψ/memory/...`, `.agent/../ψ/memory/...`.
4. **Post-write stray-find** that MUST return empty on the project repo tree.
5. **Recovery recipe** inline in the spec for next time (no Oracle-search roundtrip needed to remember).
6. **New §The ψ/ trap section** at end-of-file explaining the topology + citing the historical context.
7. **DoD tightened**: absolute-path retro line + stray-check line as explicit acceptance criteria.

## Not fixed in this pass (tracked as open)

- **W1, W4, W8, W9** specs have the same `rrr` convention and the same trap surface. Only W2 fixed per scope; others inherit same discipline on next revision.
- **`.gitignore` of mobiz + bank-bot still lacks `ψ/`** — the spec prevents the WRITE but doesn't prevent the `git add` once a stray exists. Stopping-the-bleeding gitignore patch is a separate follow-up (product-repo change, not vault change).
- **21 already-committed files in mobiz git history** remain. History rewrite (`git filter-repo` + force-push) is destructive; policy is to leave them and prevent new ones.

## Pattern name for the brew-ops library

**Config-ambiguity-via-convenience-alias.** Any time a system exposes a "convenient" short path (`ψ/memory/...`) that resolves one way in the intended context and another way when the context shifts, the ambiguity will eventually be exploited by a tool that doesn't know which context it's in. Defence: always specify the absolute form (`~/.arra-oracle-v2/ψ/memory/...`) and add a pre/post verification that the side-effect landed where intended. The convenience alias is still fine for humans; automation must use the absolute path.

Related pattern observed earlier in this ecosystem: the `--continue` flag in maw's `commands.default` (claude resumes conversation — convenient for humans; confusing for scripts that expected fresh state). Fix was the same shape: make the script-facing path unambiguous via the new `--fresh` flag.

Tags: brew-ops, workflow-edit, workflow-2, technical-writer, vault-discipline, ψ-trap, retro-leak, config-ambiguity, pattern, repo:cross

---
*Added via Oracle Learn*
