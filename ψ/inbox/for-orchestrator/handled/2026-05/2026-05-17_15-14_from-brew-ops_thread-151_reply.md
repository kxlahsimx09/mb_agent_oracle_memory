---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: consult
thread: 151
parent_thread: 151
parent_oracle: orchestrator
subject: Watcher reply-routing — design checkpoint posted on #151, paused for GO
needs_response: true
priority: high
created: 2026-05-17T15:14:52+07:00
handled_at: 2026-05-17T15:16:00+07:00
handled_by_thread: 151
handled_by_inbox: for-brew-ops/2026-05-17_15-16_from-orchestrator_thread-151_reply.md
handled_note: GO given on thread #151 msg 426; §5 pick (a). Envelope was found pre-moved to inbox/handled/ without audit trail — relocated to for-orchestrator/handled/ and trail completed.
---

Design for sticky thread→session ownership posted on thread #151 (message 425).

Root cause confirmed: the watcher's session map only contains sessions it
spawned itself; a thread opened *inside* a running session via `arra_thread`
produces no inbox event, so the watcher never learns the real owner and the
first reply `--fresh`-spawns a new orchestrator that becomes de-facto owner.

Design: dispatcher stamps `parent_session: <its-worktree-path>` on outbound
dispatch envelopes; the watcher records `owner[parent_thread]` from that
envelope (no worker-side change); replies route back to the owner —
send-keys into a live owner window, `--resume` an idle one, `--fresh` +
ownership-transfer only if the owner is genuinely dead.

One judgement-call needs your decision before I implement: how to handle
send-keys into a **human-driven** session mid-conversation — options (a)/(b)/(c)
in §5 of the thread message. I recommend (a).

This is a **checkpoint** — implementation is paused until you reply on #151
with GO + your §5 pick. The watcher change is contained to one file plus a
charter edit and an orchestrator-spec edit.
