# next-ui — WUI-130 browser-validated + gap doc corrected

**Slug:** `next-ui-wui130-revalidate` · **Date:** 2026-06-16 (GMT+7) · **Repo:** `kxlahsimx09/mb-next-admin-portal` · **Stack:** sinuw staging (`sinuwgsqqyqzlpaavimf`)
**Closes:** brew-ops `2026-06-16_19-22_brew-ops-botlog-deploy` (re-run the WUI-130 smoke after BOTLOG deploy). Source of truth: `docs/handoff-next-ui.md` live-test recipe + `monitoring-api.ts`.

## TL;DR — GREEN. WUI-130 loads live data end-to-end in the browser. Doc PR #38 opened (NOT merged).

## Task A — browser smoke (sinuw, real-form aal2 login + Playwright local prod build)
Verified by **captured EF network 200 + visible rows**, NOT "no Playwright error" (the silent-CORS trap that falsely marked WUI-130 DONE before). EF `admin-bankbot-log` ACTIVE v1, CORS `withCors` now present (preflight 204 + ACAO echo).

- **fleet_now** → HTTP **200**, **2 bot rows** (matches deploy evidence `v_bankbot_fleet_now`=2; `7777…0001/0002`, scb, `availability:online`). Board rendered.
- **stream** → HTTP **200**, **32 gateway-source rows** painted; **32 `<tr>` rendered in DOM = the network row count** (data actually loaded, not a silent empty). Events `cursor_read`/`statements_push`, all `source:gateway`. (Substrate probe taken first showed 26 — the G5 emitter keeps writing; grew to 32 by UI run. Started at 9 per brew-ops handoff.)
- **resolve_proof** → **untestable / residual**: 0 of the rows carry a proof pointer (`proof_url`/`screenshot_url` null on every row). Phase-1 gateway events have no proof; the proof-lightbox + resolve_proof path can't be exercised until a bot uploads a proof pointer (bb2proof Phase-1b). Did NOT fail the story on it (per brew-ops note). No proof buttons rendered in the table → consistent.
- 0 console errors · 0 failed EF requests · no forbidden panel · no empty-state. Login chain (password → 2FA TOTP → aal2 → /dashboard) all green; screenshots confirmed the page painted (fleet board + 32-row stream table + "หน้า 1 · 32 records" pager).

Substrate check (the exact `efPost` calls the code makes) corroborated independently: aal2 ✓, fleet_now 200·2, stream 200·26, proof_rows 0.

Worktree kept secret-free: `.env.local` + both temp scripts removed, prod server killed, port 3000 free, validation worktree `git worktree remove`d.

## Task B — gap doc corrected (scoped: WUI-130 + WUI-013 ONLY; WUI-006/009/015 untouched — sibling lane)
Branch `docs/wui-130-validated` off `origin/main`@`61253c6`. **PR #38** (OPEN, do not merge).
- `docs/gap-analysis-wui.md`: **WUI-130 → DONE · validated-on-staging** (cite browser smoke; removed the "DONE but EF-missing/CORS-blocked/backend-blocked" caveat); **WUI-013 → annotated validated-on-staging** (auth-step-up-verify fired 200 from the modal, prior round; CORS deployed). Appended a dated progress-log entry.
- `docs/handoff-next-ui.md`: BLOCKER §1 (CORS on 3 EFs) → **RESOLVED**.
- Verified no `+`/`-` change to WUI-006/009/015 lines (they only appear as diff context).

## Updated tally + residual
- **Tally unchanged: 15/34 DONE · 4 PARTIAL · 15 MISSING (+Bankbot WUI-130 DONE·validated).**
- **Residual:** `resolve_proof` / proof-lightbox path is **untestable until a bot uploads a proof pointer** (Phase-1 gateway events carry none) — route to whoever owns bb2proof Phase-1b; re-test resolve_proof once a `proof_url` row exists.
- **Dependency:** next-dev PR #541 (`feat/botlog-bankbot-activity-log`) must merge for the EF to reach `main`/prod; staging already has it. Doc PR #38 awaits owner merge.

## Fallback path
`/home/ubuntu/Code/github.com/kxlahsimx09/mb_agent_oracle_memory/ψ/inbox/handoff/2026-06-16_HH-MM_next-ui-wui130-revalidate.md`
