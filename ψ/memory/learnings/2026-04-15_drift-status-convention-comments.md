---
name: drift — model comments contradict runtime status convention
description: Wallet/Client/MDRProfile model files comment "0=active, 1=inactive" while runtime enforces the opposite (1=active). CLAUDE.md §Status Codes Convention matches runtime.
type: learning
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - rbac
  - data-model
  - drift
source: models/wallets.go:18 + models/clients.go:33 + models/mdr_profile.go:24 + middlewares/apiKeyCheck.go:58 @ 379e984
project: github.com/kokarat/mobiz-payment-gateway
created: 2026-04-15
---

# DRIFT — Entity-status convention: model comments vs runtime

## Fact

Runtime enforces `status == 1` ⇒ active:

- `middlewares/apiKeyCheck.go:58` — `if client.Status != 1 { return 401 "Client is not active" }`
- `services/bankRotation.go:66` — same pattern
- `services/withdrawalQueue.go:70` — partner active guard

But the struct comments lie:

- `models/wallets.go:18` — `// 0=active, 1=inactive, 2=suspended (default: 0)`
- `models/clients.go:33` — same
- `models/mdr_profile.go:24` — `// 0=active, 1=inactive (default: 0)`

CLAUDE.md §"Status Codes Convention" says universally `1=Active, 0=Inactive, 2=Suspended` — which matches runtime.

## Why it matters

- A new contributor reading the struct comment will write code that treats 0 as active and silently lock out users.
- Any doc that claims to be "derived from the model" will inherit the wrong convention if the writer trusted the comment.

## How to apply

- When documenting entity status, cite the *runtime check* file:line (`apiKeyCheck.go:58`, etc.), not the struct comment.
- When the struct comment is encountered, mark `[DRIFT]` and include a pointer to this learning.
- Fix candidate for a future PR: update the three comments. Outside this session's scope.

## Trace

commit `379e984` → docs/current-system.md §2.1 + §9 DRIFT-2 → resolution PR (this PR documents; code-comment fix tracked separately)
