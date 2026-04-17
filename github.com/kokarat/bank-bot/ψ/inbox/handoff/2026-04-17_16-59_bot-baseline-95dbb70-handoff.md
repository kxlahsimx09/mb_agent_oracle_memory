# Handoff — bot-writer-oracle baseline at 95dbb70

Baseline complete. PR #56 opened on `kokarat/bank-bot`: https://github.com/kokarat/bank-bot/pull/56. Branch `docs/baseline-current-95dbb70`. **Not merged.**

## What's ready for the next session

1. **Workflow 4 (reconcile-drift)** against the doc-fix-only DRIFT rows in `docs/current-system.md` §8: rows 2, 3, 4, 5, 6, 7, 8, 10, 13, 15, 16. No code changes, just CLAUDE.md + README rewrites. Batch in one PR.

2. **DRIFT-1 (SSE disabled)** — escalate to code_reviewer / human. Either (a) delete SSE references from CLAUDE.md + README, or (b) wire up the "Bot Secret auth for SSE" TODO at `app.js:181`. Not a writer-only fix.

3. **DRIFT-9 (direction-aware cursors)** — rewrite CLAUDE.md "Bank Statement Scraping" §. Use `docs/current-system.md` §4.8 as the source text.

4. **Thread #3 — BOT_SECRET in `.env.example`** — needs human. If value is real, rotate on backend and replace in `.env.example` with `changeme`-class placeholder. If already-rotated, replace anyway and add a comment. Do NOT leave a real-looking secret indexable in a public repo.

5. **Baseline triggers** (`docs/current-system.md` §10): next auto re-baseline by 2026-05-01, or earlier if `app.js` / `banks/<bank>/*.js` / `core/*.js` change the runtime shape, or if `banks/kbank/` or `banks/bbl/` appears.

## Open questions I could not resolve

- U-1: `.env.example` BOT_SECRET real or placeholder? → thread #3.
- U-2: `test-statement.js` at repo root — live or historical?
- U-3: `ψ/` + `.agent.bak-20260417-102822/` — cleanup or keep?
- U-4: `saveOTPLog` endpoint shape on mobiz backend — for `pg-writer-oracle` to confirm.

## Unfinished follow-up

- Check next session whether vector-embedding retry succeeded for the one `arra_learn` that failed (`2026-04-17_name-drift-sse-intake-is-disabled-at-runtim.md`). FTS indexed fine so it's searchable; vector recall is the only loss.
