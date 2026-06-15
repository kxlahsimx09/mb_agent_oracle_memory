---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
campaign: authviewdrop
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: APPLIED-DONE — migration 020 applied+verified on sinuw; 030 held (recommend revert)
needs_response: true
priority: high
created: 2026-06-13T21:15:21+07:00
---

**APPLIED-DONE.** Detail thread #16 msg **423**.

- **Applied to sinuw:** `20260613000020_authro_forensic_views.sql` via direct psql (not `db push`). 4 views created (owner=postgres), recorded in schema_migrations.
- **Verified AS investigator_ro on sinuw:** 4 views return rows (users=12, mfa_factors=6, sessions=51, amr=88); columns = secret-free allowlist; secret-leak sweep = NONE; investigator_ro **cannot** read auth.* directly (permission denied → owner-context design works). Secret-free auth read-path restored.
- **Migration 030 NOT applied — HELD:** recorded in sinuw's schema_migrations as a skip → next `supabase db push` skips it (revoke never auto-fires). investigator_ro keeps its broad grant per owner.
  - **Deploy-mechanics call:** hold done (immediate). **Durable fix = revert 030 out of main** (D1 abandoned; D2 will be a new migration; a dangling held file is audit-confusion + re-leak risk). **Want me to open the revert PR?**
- **qnccph:** skipped — investigator_ro absent → 030 is a guarded no-op there, 020 only makes harmless secret-free views; left to normal train, no hold needed.
