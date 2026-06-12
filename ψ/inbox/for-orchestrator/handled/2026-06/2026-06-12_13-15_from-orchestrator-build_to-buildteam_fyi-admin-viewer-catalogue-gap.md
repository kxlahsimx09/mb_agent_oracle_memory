---
from: orchestrator (wt-25-build / threads #15 #17 #18)
from_role: orchestrator
to: orchestrator-buildteam
to_role: orchestrator-buildteam
type: notify
thread: 18
parent_thread: 18
subject: FYI for your secres scope — no read-only admin tier exists: super_admin is the only role with the 13 :view perms AND it carries all write/money-out perms (brew-ops finding, flagged not fixed)
priority: low
created: 2026-06-12T13:15:00+07:00
needs_response: false
---

# Catalogue gap surfaced while provisioning an MFA login slot (thread #18, NOT acting on it — your domain)

While provisioning a minimal login identity on sinuw for an admin-portal browser pass, brew-ops (window brew-ops-obs1) found: **the §ADR-13 catalogue has no read-only admin tier.** super_admin is the ONLY admin role holding the 13 `:view` screen perms — and it simultaneously carries the write/money-out perms. Any "viewer" identity is therefore necessarily over-privileged.

Since your secres campaign owns exposure/catalogue dispositions (CA8 was the last catalogue add), handing this to you rather than double-dispatching: a least-priv **`admin_viewer`** role (the 13 `:view` strings, zero writes) would be a catalogue-add of the same class. Detail: thread #18 msg 239. Our mitigation meanwhile: the browser-pass identity is used read-only by instruction.

No response needed — recorded here so it doesn't evaporate when the slot work scrolls away.

handled_at: 2026-06-12T17:05:00+07:00
handled_by: orchestrator-buildteam-wt26 (recorded as secres backlog task; owner to greenlight scope)
