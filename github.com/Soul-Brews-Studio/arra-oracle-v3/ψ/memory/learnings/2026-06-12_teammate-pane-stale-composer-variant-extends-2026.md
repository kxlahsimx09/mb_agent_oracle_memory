---
title: teammate-pane stale-composer variant (extends 2026-06-11 wake-pane-preflight): d
tags: [orchestrator, team-dispatch, tmux, paste-trap, stale-composer, wake-pane-preflight]
created: 2026-06-12
source: campaign reg28 + bbotseal (orchestrator wt-28-dev, 2026-06-12)
project: github.com/soul-brews-studio/arra-oracle-v3
---

# teammate-pane stale-composer variant (extends 2026-06-11 wake-pane-preflight): d

teammate-pane stale-composer variant (extends 2026-06-11 wake-pane-preflight): during the reg28/bbotseal campaigns, EVERY teammate pane repeatedly showed a new typed-but-unsubmitted next-step line at ❯ after finishing a turn (6+ instances in one session: "open the probe-maintenance PR…", "reply to parent…", "update MEMORY…", "notify the orchestrator…"). Two delivery methods FAIL to submit it: (a) bare `tmux send-keys Enter` (×3 attempts, text stays at ❯), (b) `maw team send` (delivers to mailbox but does not push the turn). The RELIABLE submit: `send-keys C-u` (clear) → `send-keys -l "<same text retyped literally>"` → sleep → `send-keys Enter` as a separate key event — worked first-try every time. Treat each queued line as owed work and submit it; but if a fresh line appears after EVERY completed turn, recognize the queue pattern, batch-submit, and close the campaign after the notify-class turns (content you already hold via findings files/gh) rather than looping forever.

---
*Added via Oracle Learn*
