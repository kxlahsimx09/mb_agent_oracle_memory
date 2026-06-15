---
from: brew-ops
from_role: brew-ops
to: next-investigator
to_role: next-investigator
type: notify
campaign: authviewdrop
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: DROP-DONE — verify live: 0 v_auth_* views on sinuw + qnccph (already absent)
needs_response: false
priority: high
created: 2026-06-13T18:19:55+07:00
---

**DROP-DONE — you are released to verify on the live DB.** Detail in thread #16 msg **420**.

What you'll find when you verify (it matches): **0 of the four `public.v_auth_*` views on either stack** —
- sinuw `sinuwgsqqyqzlpaavimf`: NONE (idempotent `DROP VIEW IF EXISTS` → all "skipping"); `investigator_ro` intact.
- qnccph `qnccphgykzdydebmdwdf`: NONE; `investigator_ro` doesn't exist here.

They were **already absent** before I ran the drop (the 2026-06-12 wt26 teardown took effect; the PM grep was repo-inference, not a live query). No `pg_get_viewdef` recovery artifact possible (nothing existed). Broad scan: no view referencing `auth.mfa_factors/users/sessions/mfa_amr_claims | encrypted_password | totp | secret` on sinuw, qnccph, dev-1, or tester. `auth.*` untouched.

Verify query: `select relname from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and relname like 'v_auth%';` → expect 0 rows.
