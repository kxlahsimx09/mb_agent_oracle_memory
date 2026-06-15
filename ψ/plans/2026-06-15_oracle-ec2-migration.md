# Plan — Migrate the Oracle ecosystem off the 8 GB Mac → a beefier AWS EC2

**Author:** brew-ops · 2026-06-15 · **Status:** DRAFT (awaiting instance-size sign-off before provisioning)

## 0. Why (the diagnosis that triggered this)
The current runner is an **8 GB / 4-core Mac**. Measured under normal fleet load:
- **14 `claude` agent processes** (Σ 61% CPU, 2.1 GB RSS) + **39 Chrome procs** + **25 git procs**.
- **RAM exhausted** — ~62 MB free; **2.27 GB swapped to disk**; 1.39 M lifetime swapouts.
- **Load avg 3.92 on 4 cores** = CPU saturated.
→ The day-to-day "agent feels slow" is the **machine swapping + CPU-starved**, not model latency (model = Anthropic API, machine-independent). RAM is the hard bottleneck.

## 1. Target
- **Host:** one Linux EC2 in **`ap-southeast-1`** (acct `261955339426`, `root-bootstrap`), default VPC `vpc-04b0ee094dbe5a731`, public subnet + EIP.
- **OS: Ubuntu 24.04 LTS (x86)** — every tool is Linux-native (claude-code, maw, tmux, node/bun, git/gh, supabase/vercel/wrangler CLIs, aws-cli, headless chromium). **No macOS dependency found.** (EC2 mac instances rejected: dedicated-host, 24 h min, ~24× the cost.)
- **Storage:** 200 GB gp3 EBS (footprint to move ≈ 11 GB; node_modules/.next rebuild + headroom).
- **Sizing — RAM is the bottleneck (memory-optimized r-series preferred):**

| Option | vCPU / RAM | ~On-demand (ap-se-1) | ~/mo 24×7 | Note |
|---|---|---|---|---|
| **r7i.2xlarge** ⭐ | 8 / **64 GB** | ~$0.53/hr | ~$385 | recommended — 8× current RAM, 2× cores, mem-optimized |
| r7g.2xlarge (ARM) | 8 / 64 GB | ~$0.43/hr | ~$310 | cheapest 64 GB; ARM (matches the Mac's arch); tiny native-module risk |
| m7i.4xlarge | 16 / 64 GB | ~$0.92/hr | ~$670 | more cores for heavy parallel builds |
| m7i.2xlarge | 8 / 32 GB | ~$0.46/hr | ~$330 | budget; only 4× RAM (may still constrain a big fleet) |

Costs are 24×7 worst case. **Levers:** stop when idle (pay only EBS), a 1-yr Savings Plan (~30-40% off), or spot (~70% off, reclaimable — not for the always-on fleet).

## 2. What moves (inventory)
| Source (Mac) | Size | How |
|---|---|---|
| `~/Code` (repos + git worktrees) | 8.2 GB | **re-clone fresh** on Linux (cleaner than rsyncing worktrees + node_modules); re-create worktrees from the runbook |
| `~/.arra-oracle-v2` (fleet-secrets + oracle data) | 883 MB | **scp over ssh** (sensitive — chmod 600, encrypted in transit, never committed) |
| `~/.config/maw` (fleet config) | 3.8 MB | scp + fix paths/symlinks |
| `~/.claude` (config, projects, **memory**, plans) | 1.5 GB | rsync the `projects/*/memory` + `plans` + settings; drop `shell-snapshots` |
| toolchain | — | install fresh (apt + node/bun + claude + maw + playwright deps) |

## 3. Provisioning runbook (executed after sign-off)
1. **Keypair** `oracle-ec2` → save `~/.ssh/oracle-ec2.pem` (chmod 600). *(none exists yet)*
2. **Security group** `oracle-ec2-sg`: inbound SSH 22 **from operator IP only**; egress all. (No inbound services — agents are outbound-only.)
3. **Launch**: chosen type, Ubuntu 24.04 AMI, 200 GB gp3, public subnet, allocate + associate **EIP**.
4. **Bootstrap** (user-data or first-ssh): apt deps (build-essential, git, tmux, ripgrep, jq, the chromium/playwright libs), Node LTS + bun, gh, aws-cli v2, supabase/vercel/wrangler, **claude-code**, **maw**.
5. **Data**: re-clone repos under `~/Code/github.com/...`; `scp` the secrets + maw config; rsync `~/.claude` memory/plans.
6. **Wire the fleet**: maw config + the **`~/.config/maw/fleet` symlinks** (per [[maw-wake-needs-fleet-dir-symlink]]) + the per-repo `.agent` vaults + maw.config agents (per [[fleet-add-repo-role-procedure]]).
7. **Smoke**: spawn 1-2 agents, run a build, exercise one deploy path (staging EF assert) to confirm the toolchain + creds work.

## 4. Cutover (parallel-run, no big-bang)
- Stand up EC2 **alongside** the Mac (don't kill the Mac fleet). Validate agents + a build + a deploy on EC2.
- Shift the fleet over repo-by-repo; the Mac becomes just an **operator terminal / ssh client**.
- **EBS snapshot** before declaring cutover. Mac stays intact as rollback until EC2 is proven for a few days.

## 5. Security (important — root-bootstrap caveat)
- `root-bootstrap` is the **account ROOT** credential (topology doc: temp grant, revoke after). **Do NOT put root creds on the EC2.** Provision with root from the Mac, but give the EC2 a **scoped IAM role/instance-profile** (or a least-priv IAM user) for the deploys it must run — not root.
- Secrets: `scp` only, chmod 600, never to git. Rotate anything that was ever in a git remote URL (see [[deploy-env-guard-token-in-remote]]).
- SG locks SSH to the operator IP; consider SSM Session Manager instead of open SSH.

## 6. Rollback
Mac untouched until EC2 validated → revert = keep using the Mac. EBS snapshot pre-cutover for the EC2 side.

## 7. Open decision (for the owner)
- **Instance size / budget** (§1 table) — the one cost commitment. Default recommendation: **r7i.2xlarge (8 vCPU / 64 GB)**.
- 24×7 vs stop-when-idle.

---

## Execution log (2026-06-15)

**Decision:** the account's On-Demand **Standard vCPU quota is only 8** (default), and the 2 bank-bot portal `t4g.nano`s consume 4 → r7i.2xlarge (8 vCPU, the 64 GB pick) won't fit. Requested an increase **8→32 vCPU** (Service Quotas `L-1216C47A`, request `939463b0…`, status **CASE_OPENED** = AWS manual review, hours). Owner chose to **start now on the interim 32 GB box** (fits the 4 free vCPU) and **resize to 64 GB** once the case clears.

**Provisioned (interim, LIVE):**
| Resource | Value |
|---|---|
| Instance | `i-0a04dc349691324dd` · **r7i.xlarge** (4 vCPU / **30 GiB**) · Ubuntu 24.04.4 |
| EIP | **3.1.0.33** (alloc `eipalloc-0b709015bded08f0e`) — stable across the resize stop/start |
| Disk | 200 GB gp3 (1% used) |
| Keypair | `oracle-ec2` → `~/.ssh/oracle-ec2.pem` (600) |
| Security group | `oracle-ec2-sg` `sg-0719678a0c780f3e9` — SSH 22 from operator `8.245.7.85/32` only |
| AMI | `ami-03acbba64aef9bf5c` |
| Region/VPC/subnet | ap-southeast-1 / `vpc-04b0ee094dbe5a731` / `subnet-06bc2b2ba99b4cbb8` (1a) |
| SSH | `ssh -i ~/.ssh/oracle-ec2.pem ubuntu@3.1.0.33` |

**Resize to 64 GB when quota approves:** `aws ec2 stop-instances` → `modify-instance-attribute --instance-type r7i.2xlarge` → `start-instances`. Same EBS + EIP + setup; ~5 min downtime.

**Progress:**
- [x] Provision + EIP + SSH verified (30 GiB RAM, no swap pressure — the Mac's core problem solved).
- [~] Toolchain bootstrap: apt base + Node 22 + bun (in flight).
- [ ] CLIs: gh, aws-cli v2, supabase, vercel, wrangler, playwright + chromium deps.
- [ ] claude-code + maw install.
- [ ] **Auth/creds** (sensitive): `gh auth`, AWS creds (prefer an **instance-profile IAM role**, NOT root on the box), claude-code login, vercel/supabase tokens.
- [ ] **Data:** re-clone `~/Code` repos; `scp` `~/.arra-oracle-v2` (fleet-secrets, 600) + `~/.config/maw`; rsync `~/.claude` memory/plans.
- [ ] **Fleet wiring:** maw config + `~/.config/maw/fleet` symlinks + per-repo `.agent` vaults + maw.config agents.
- [ ] **Smoke:** spawn 1-2 agents + a build + one staging-deploy assert.
- [ ] **Cutover:** parallel-run, validate, then shift the fleet; Mac → operator terminal. EBS snapshot pre-cutover.

**Security reminder:** do NOT copy `root-bootstrap` (account-root) creds onto the EC2 — attach a scoped instance-profile role for the deploys it runs. Secrets via `scp` only, chmod 600, never to git.
