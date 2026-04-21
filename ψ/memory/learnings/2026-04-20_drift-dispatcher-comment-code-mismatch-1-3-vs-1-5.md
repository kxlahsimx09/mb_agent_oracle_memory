---
title: drift — dispatcher comment says "1-3 stealth" but code produces 1-5
name: drift-dispatcher-comment-code-mismatch-1-3-vs-1-5
description: scheduler/withdrawal_dispatcher.go:220 comment claims the `< 5 unassigned` tier uses "random 1-3 (stealth — idle pattern)" but line :236 code is `mrand.Intn(5) + 1` which produces 1-5. Comment-code drift introduced by 386f0a7 (PR #242). Queue for W4 — one-line fix, code-reviewer judgment call on which direction (comment → 1-5 or code → mrand.Intn(3)+1) is correct.
type: feedback
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - drift
  - comment-code-mismatch
  - flow:withdrawal-queue-dispatch-and-claim
source: scheduler/withdrawal_dispatcher.go
project: github.com/kokarat/mobiz-payment-gateway
---

## Finding

At HEAD `68accc6`, `scheduler/withdrawal_dispatcher.go:214-236` describes the per-bank cap algorithm. The comment block (lines 214-220) lists four tiers for `unassigned` backlog:

```
>= 100 unassigned : 5 fixed (drain mode)
>=  20 unassigned : random 3-5
>=   5 unassigned : random 2-4
else              : random 1-3 (stealth — idle pattern)
```

But the code at lines 228-237 implements a different mapping:

```go
case unassigned >= 100:
    perBankCap = 5
case unassigned >= 20:
    perBankCap = mrand.Intn(2) + 4 // 4..5
case unassigned >= 5:
    perBankCap = mrand.Intn(3) + 3 // 3..5
default:
    perBankCap = mrand.Intn(5) + 1 // 1..5
```

So the actual tiers are: `>=100: 5 fixed`, `>=20: 4-5`, `>=5: 3-5`, `else: 1-5`. The comment's middle two tiers (3-5, 2-4) and the "1-3 stealth" low tier do not match.

## Why

PR #242 (`386f0a7` — "fix: adjust dispatcher caps — >=5: 3-5, <5: 1-5") changed the code but did not update the comment. The commit message itself agrees with the code, not the comment. The comment still reflects a pre-#242 intent that was replaced.

## Impact

- Operator / code-reviewer confusion when reading the comment.
- W8 flow doc previously transcribed "tier-randomised cap 1–5" (2026-04-18 version, @252849e) — which was close to the code but not the comment. The 2026-04-20 W8 revision (this pass) cited the code directly, with `[AWAITING_THREAD:29]` asking whether the comment's original intent ("1-3 stealth") is canonical or whether the code's 1-5 is.

## How to apply

Queue for W4. One-line fix (by code-reviewer or the author of `386f0a7`) — either:

- **A**: update comment to match code (`else : random 1-5`).
- **B**: restore the stealth intent by changing code to `mrand.Intn(3) + 1` (produces 1-3). Would require regression check against any integration tests or dashboards that expect >3 per batch at low backlog.

The `#w8-revision` thread #29 asks the human which direction was intended. The resolution here tracks that thread's answer to (3).

## Related

- W8 revision doc: `docs/flows/withdrawal-queue-dispatch-and-claim.md` — step 3 pointer now references this comment-code drift.
- Commit that introduced it: `386f0a71e2fe163c989457616931c4ac41fbbc96` (PR #242).
- W8 revision trace: `b27c8d35-f7f3-46b5-8cf4-51e48f4ba7ec`.
