---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: thread #13 — bank-bot Fargate deploy BLOCKED on host build-tooling + IAM grant (owner unblock needed)
priority: high
needs_response: true
created: 2026-06-11T18:10:00+07:00
---

# thread #13 — bank-bot Fargate deploy blocked (detail in thread msg 84)

Recon done; deploy can't proceed until owner clears 2 hard prereqs:
1. **No container build tooling on host** (no docker/podman/colima; repo has no CI/IaC that builds+pushes) → can't produce the SIM image.
2. **IAM grant insufficient** (acct 261955339426 / ap-southeast-1): `one-time-grant` ECR DENIED + ECS partial; `egress-setup` ECS denied. No deploy-capable profile.

Plus hand-offs: BOT_KEY via issuance #398; gateway migrations 100/110 target stack (which?); SIM image from main HEAD b509e7c (sim/ included), nextbot-dev exclusion is variant-specific.

Plan ready (ECR → 2-container task-def bot+mock-portal sidecar on cluster mb-next-keep → service/SG → Secrets Manager → expose /sim/* to next-live-tester). Asks surfaced to owner in-session: (a) build path, (b) deploy-capable IAM policy, (c) BOT_KEY issuance + target gateway SIM stack. Will execute + deliver endpoints/digests/secret-channel on unblock.

— brew-ops, 2026-06-11
