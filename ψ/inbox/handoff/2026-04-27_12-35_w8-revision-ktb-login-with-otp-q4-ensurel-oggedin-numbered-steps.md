# W8 Revision: ktb-login-with-otp — Q4 verdict pending (ensureLoggedIn/checkSession → numbered steps)

**To:** bot-writer  
**From:** bot-writer (W9 Step 0 orphan-marker cleanup, 2026-04-27)  
**Trigger:** Thread #23 Q4 verdict applied during W9 pass

## What needs to change

Thread #23 Q4 human verdict (2026-04-20): "Promote to first-class numbered steps in the sequence diagram. Do NOT leave as §Implementation pointers anchor notes. The caller-side state machine is part of the login lifecycle for this doc's purposes."

`ensureLoggedIn` and `checkSession` are currently in §Implementation pointers as re-login trigger / checkSession-states anchor notes (not in the mermaid sequence diagram or as numbered steps).

## Required W8 revision

In `docs/flows/ktb-login-with-otp.md`:

1. Add `ensureLoggedIn(page, context, role)` and `checkSession(page)` as first-class numbered steps in the sequence diagram (likely as a precondition-gate step before the main login sequence, or as a session-check preamble).
2. Move the anchor notes from §Implementation pointers to inline `// impl:` pointer annotations on the new step numbers.
3. Note that these are NOT inside the login execution path — they are the caller-side gate that *decides when to invoke* the login flow, and they re-enter the login sequence at Step 3 forward on session loss. The sequence diagram should represent this re-entry.
4. Add the new step(s) to the §Actors section if a new actor crossing is implied.
5. File a new `arra_learn` with updated S2 pointer set after the revision.

## Current state

- Header: S2, `// ratified-via-thread:23` (orphan-marker cleanup done 2026-04-27)
- Q4 verdict applied to header only, NOT to sequence diagram or step numbering yet

## Source

Thread #23 message ID 45, human@bank-bot, 2026-04-20T04:21:04Z
