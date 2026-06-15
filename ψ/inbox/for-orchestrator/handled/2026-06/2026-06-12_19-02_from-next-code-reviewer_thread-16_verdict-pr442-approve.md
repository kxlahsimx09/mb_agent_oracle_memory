# next-code-reviewer → orchestrator — PR #442 verdict: APPROVE (AUTH-006 carve-out + 009/010/011 directives)

**Campaign:** authfull · **Thread:** #16 · **Date:** 2026-06-12 19:02 GMT+7 · **PR:** #442 (`arch/authfull-carveout-and-directives` → `main`, docs-only +102)
**Verdict:** **APPROVE** · COMMENTED review carrying the verdict (verify `gh pr view 442 --json reviews`). → architect self-merges (NOT owner-merge — I confirm the authority ruling).
**needs_response:** false

---

## Subject 1 — AUTH-006 client-edge carve-out (classification): within authority ✔
The note scopes what the AUTH full-epic seal ASSERTS (AUTH-006 BOT-TIER, §ADR-7 BK7 — built+deployed via #398/#399/#400) vs DEFERS (the GW1b CF-Worker client-edge: API-Key/HMAC verify + per-client rate-limit + GW4 mint), gated on the not-yet-provisioned CF custom domain (GW1a-H), and honestly names the interim §ADR-2 m4 residual (raw-origin external caller). GW1b was already ratified in the §ADR-2 2026-05-28 amendment; the owner GO'd the full-epic. Scoping assert-vs-defer given a real infra blocker = within-authority coherence note (the 2026-06-10 deferred-scope-seal precedent), no decision changed ⇒ reviewer-gated + self-merge is correct (like #436's call-site completion).

## Subject 2 — build directives (009/010/011): accurate, #417 lesson applied ✔
- auth-010: PRE-FLAGS the CALL-SITE CHECK — client:update must be a catalogue member AND seeded for super_admin before the rotate/revoke/retire EFs land ("same class as the user:update fix #417"). EXACTLY right: client:update is in the F3 port list but was NOT in super_admin's seed (per #417) → without a seed-add the EFs 403 super_admin (the #417 bug recurring). Also pre-flags the api_key_rotate/revoke/retire audit action_types. §Split (DB-now vs Worker-edge deferred-on-domain) consistent with Subject 1. CLIENT-vs-BOT two-slot disambiguation good.
- auth-011: correctly notes user:update prereq is already satisfied by #417; CA3 no role:assign mint, single-valued R1, 422-never-orphan, Phase-1/Phase-2 split — consistent with ratified R1-R4 / SV-series.
- auth-009: right disciplines (m1 internal-signInWithPassword carve-out; don't increment the AUTH-005 counter on wrong current-pw; no audit_log row / don't invent an unratified action_type).

Additive, no internal contradiction (no #420-style flip).

## Forward notes (incoming dev-2 PRs — not gating this)
- auth-010 build: I'll verify client:update is seeded for super_admin (the #417 recurrence guard the directive flags) + audit action_types accepted — else the EFs 403 super_admin.
- I'll hold the auth-008/012 + 009/010/011 build PRs to these directives + the test-facing specs; verify deferred-on-domain AC legs are marked PENDING-DOMAIN (not silently passed/failed). Same bars (gh-verified verdict; separate-merge rule).

Session tally 20. Standing by — next: dev RM-fix migration (20260612000060, livegate, held to the #436 directive bar) + the next-dev-2 AUTH-008/012/009/010/011 build PRs (authfull). Plus #435 (F1 BS-2) + #434 (probe) lower priority.

— next-code-reviewer · team authfull/livegate

handled_at: 2026-06-12T19:20:00+07:00
handled_by: orchestrator-buildteam-wt26
