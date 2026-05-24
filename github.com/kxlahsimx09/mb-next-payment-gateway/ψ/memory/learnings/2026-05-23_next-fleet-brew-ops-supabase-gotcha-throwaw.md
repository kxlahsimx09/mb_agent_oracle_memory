---
title: #next #fleet #brew-ops #supabase #gotcha — Throwaway hosted-project TEARDOWN pro
tags: [supabase, teardown, fleet-secrets, security, brew-ops, next]
created: 2026-05-23
source: Oracle Learn
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #next #fleet #brew-ops #supabase #gotcha — Throwaway hosted-project TEARDOWN pro

#next #fleet #brew-ops #supabase #gotcha — Throwaway hosted-project TEARDOWN procedure (verified 2026-05-22/23, thread #216, project xxnhfvkchfpoomdxixmr). Complements [[2026-05-22_next-fleet-brew-ops-supabase-loadtest-verif]].

1. **Delete the project:** `DELETE https://api.supabase.com/v1/projects/{ref}` (PAT-authed) → HTTP 200 returns the deleted project; verify with a follow-up GET → `400 {"message":"Resource has been removed"}`. Equivalent to `supabase projects delete` but non-interactive. **Re-confirm the ref before deleting** (must be the dedicated throwaway, never a shared/prod project).
2. **Drop ephemeral creds from `fleet-secrets/<proj>/`** — and ⚠️ **editor swap files leak secrets:** removing `supabase.env` is not enough; a `.supabase.env.swp` (vim swap, created if the file was ever opened in vim) holds the full plaintext secret content and survives. Remove it too (exact path; the harness blocks glob `rm`), then `rmdir` the now-empty dir. Leave sibling repos' secrets dirs untouched.
3. **You delete the PROJECT, not the ORG.** A project created under a new Pro org leaves the org's +$25/mo subscription — that's the user's to downgrade/cancel; flag it, don't try to cancel it via the project-delete path.
4. **Final cost (for the record):** estimate from uptime — `created_at`→now hours × compute rate (Medium ≈ $0.082/hr). egress/EF/storage negligible for a small run. The ≤cost-ceiling guardrail is what actually matters; the ≤time-window is a backstop for cost, and it slips if the teardown-ping lags the run's completion (here ~9.5h idle post-run because the ping came late) — a scheduled safety-net teardown at the window deadline prevents the slip.

---
*Added via Oracle Learn*
