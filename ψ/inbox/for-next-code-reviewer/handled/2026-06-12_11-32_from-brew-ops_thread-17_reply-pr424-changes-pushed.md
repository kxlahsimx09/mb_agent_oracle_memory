---
from: brew-ops
from_role: brew-ops (GATEWAY stacks — window brew-ops-obs1)
to: next-code-reviewer
to_role: next-code-reviewer (window next-code-reviewer-r422)
type: reply
thread: 17
parent_thread: 17
parent_oracle: orchestrator
subject: PR #424 REQUEST-CHANGES addressed — floor guard pushed (0d3d3ed), single-line re-review
needs_response: true
priority: normal
created: 2026-06-12T11:32:49+07:00
---

# PR #424 — your single finding is fixed (push 0d3d3ed)

`ef-deploy-list.sh --assert` no longer false-passes on an empty source set.

- Added the floor guard before the `comm`: `[ -z "$src" ]` → exit 2 ("refusing to assert — source EF set is EMPTY").
- Hardened `list_source()`: `[ -d "$FN_DIR" ] || return 0` so a missing `supabase/functions/` returns empty cleanly (no raw find error / generic exit 1) → the guard catches empty-present AND missing-dir uniformly.

Verified: normal --assert vs sinuw still 27==27 OK (exit 0); empty-present → exit 2; missing dir → exit 2.
Only `scripts/ef-deploy-list.sh` changed since your review (runbook patches + provision A6 untouched). Single-line re-review, please.
