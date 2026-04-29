---
title: ## `[AWAITING_THREAD:N]` markers — handoff signal, NOT merge gate
tags: [oracle-shadow, workflow-pattern, marker, AWAITING_THREAD, handoff, merge-policy, writer, tester, auditor, doc-as-observation]
created: 2026-04-28
source: Oracle Learn
project: github.com/soul-brews-studio/arra-oracle-v3
---

# ## `[AWAITING_THREAD:N]` markers — handoff signal, NOT merge gate

## `[AWAITING_THREAD:N]` markers — handoff signal, NOT merge gate

When a workflow (W2/W9/W1/W4/etc.) escalates an unverified claim to another role via `arra_thread`, it places `[AWAITING_THREAD:N]` next to the claim **in the canonical doc** (e.g. `docs/current-system.md`, `docs/test-index.md`, `docs/flows/*.md`). This marker is a **durable handoff signal that lives in main**, not a control flow that blocks anything.

### The three artifacts and their roles

| Artifact | Role | Lifetime |
|---|---|---|
| **Doc** (committed in main) | Home of the marker — durable record of claim's verification state | Forever (until resolver acts) |
| **PR** | Vehicle that introduces marker into doc via diff | Dies on merge |
| **Thread** | Conversation log between escalating-role and resolver-role | Append-only, referenced by marker |

The marker LIVES in the doc. The PR is a courier. The thread is a backref.

### State transitions

```
new claim entering doc unverified
    → writer/tester places [AWAITING_THREAD:N] at the claim
    → opens arra_thread #N with questions for resolver-role
    → commits doc + marker on PR
    → MERGES PR (no wait for thread)
    → marker is now in main, visible to next reader
    
later: resolver-role's natural session reads doc
    → encounters marker
    → reads thread #N for context
    → either:
        a. verifies: strips marker (or replaces with `// verified: file@commit`)
        b. contests: opens follow-up thread, marker stays
    → commits resolution as separate PR
```

### Why merge instead of block

- **Without merge**: claim is in PR description only → resolver-role never sees it during their natural doc-reading workflow
- **With merge**: claim + marker land in canonical doc → resolver sees it in flow → acts on it asynchronously
- **Async scales**: writer doesn't wait for auditor; auditor doesn't track PR queues
- **Stale markers are signals**: a 6-month-old `[AWAITING_THREAD:N]` is louder than a 6-month-old PR (the doc is read; old PRs aren't)

### Why this fits Oracle/Shadow philosophy

1. **Nothing is deleted.** Claim that entered the system unverified is reality. Marker preserves both the claim and its uncertain status. Hiding the claim until verified denies that the unverified-claim state ever existed.

2. **Patterns over intentions.** Marker observes "claim entered pending state" (pattern). It does not enforce "we want this verified" (intention). The marker's removal is itself a future observation when verification happens.

3. **External brain, not commander.** Marker informs the reader. It does not command "do not trust" or "do not act". The reader decides based on context — a developer designing might use the unverified claim, an ops team enforcing might wait.

### Anti-pattern: marker-as-block (incorrect interpretation)

```
❌ "PR has [AWAITING_THREAD:N] → block merge until thread closed"
   → bottleneck; claim stuck in PR description; resolver never sees in flow

❌ "Remove marker before merge to keep doc clean"
   → deletes the flag that signals truth; reader assumes verified

❌ "Open thread first, wait for closure, then add marker"
   → backwards; marker leads, thread resolves later
```

### Default semantics by marker name

| Marker | Semantics |
|---|---|
| `[AWAITING_THREAD:N]` | Handoff (does NOT block merge) — default for cross-role escalation |
| `[RATIFICATION_PENDING:N]` | Handoff (does NOT block merge) — pending formal sign-off, downgrade to `// ratified-via-thread:N` after resolution |
| `[NEEDS_RUNTIME_VERIFY:N]` | Handoff — pending live verification, does NOT block doc/spec merge |
| `[BLOCK_DEPLOY:N]` | (hypothetical) BLOCK — different mechanism for active vulnerabilities |
| `[SECURITY_HOLD:N]` | (hypothetical) BLOCK — explicit name signals different semantics |

**Rule of thumb**: `AWAITING_*` and `*_PENDING` = handoff. `BLOCK_*` and `*_HOLD` = block (when explicitly named).

### Real cases from 2026-04-27 → 28 session

| Thread | Marker | Resolution |
|---|---|---|
| #49 (JWT cache fingerprint) | `[AWAITING_THREAD:49]` in `docs/current-system.md:19` | Thread closed by writer relay 04-27; Q1 still open with auditor; marker STAYS in doc on main; PR #310 merged with marker intact |
| #16 (KTB dispatcher runtime) | `[AWAITING_THREAD:16]` in `docs/test-index.md` | Pending runtime confirmation; marker stays |
| #23 (queue claim cap) | `[RATIFICATION_PENDING:23]` → `// ratified-via-thread:23` | Bot-writer ratified; marker downgraded to attribution comment in W9 cycle |

All three: PRs merged with markers in place. Resolution happens asynchronously by resolver-role's natural workflow read of the doc.

### Common misconception (which the author corrected mid-session)

Initial intuition: "AWAITING means wait, so block merge until resolved." This is wrong because:
- Without merge, the claim never reaches the resolver's natural reading flow
- The thread alone (without doc presence) is not how resolvers find work to do
- Blocking creates a synchronous bottleneck across roles that should be async

**Correct mental model**: Marker is the request-for-attention. Doc is the request board. Merge is the act of posting the request. Thread is the deliberation log.

### Enforcement note

This pattern needs to be in each workflow spec to be reliably executed. arra_learn alone is discoverable but not authoritative — agents read specs first. Workflow specs should explicitly state the handoff semantics in a §Marker semantics section, and the resolver-role specs (e.g. security_auditor) should describe how to find work via doc markers.

---
*Added via Oracle Learn*
