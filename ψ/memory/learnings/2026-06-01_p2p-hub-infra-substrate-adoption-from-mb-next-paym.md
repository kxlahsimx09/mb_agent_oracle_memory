---
title: p2p-hub infra-substrate adoption from mb-next-payment-gateway — feasibility (arc
tags: [infrastructure, adr, supabase, cloudflare, egress, aws, p2p-hub, mb-next, feasibility]
created: 2026-06-01
source: next-architect feasibility assessment, Oracle thread #6, PR #17
project: github.com/kxlahsimx09/p2p-hub
---

# p2p-hub infra-substrate adoption from mb-next-payment-gateway — feasibility (arc

p2p-hub infra-substrate adoption from mb-next-payment-gateway — feasibility (architect, 2026-06-01, Oracle thread #6, PR kxlahsimx09/p2p-hub#17, ADR-1 RATIFICATION_PENDING:6).

DIRECTIVE: adopt mb-next's stack "as closely as possible" across Supabase / Cloudflare / egress / AWS. p2p-hub had NO docs/adr.md (mb-next has 20 ADRs) and only local-Supabase + a Vercel docs-site.

VERDICT PER AREA (grounded in mb-next docs/adr.md — cross-DB caveat: those ADR numbers live in a SEPARATE repo's namespace; p2p-hub's ADR-1 is independent):
- SUPABASE = FEASIBLE AS-IS. p2p-hub already runs the identical config.toml template (Postgres major_version 17, edge_runtime deno_version 2; only project_id + port-base differ) + same EF/thin-PL/pgSQL split (migrations 001-005, EF admin-approve-topup). mb-next ADR-1 (docs/adr.md:3-12), ADR-3 (:157-167). Pure convergence, no code change; promote local→managed.
- CLOUDFLARE = FEASIBLE WITH ADAPTATION → DEMAND-GATE. mb-next's CF Worker gateway (ADR-2 Amd 2026-05-28, docs/adr.md:119-155: CF edge WAF/DDoS + thin Hono Worker doing HMAC+per-client rate-limit, mints Ed25519 GW4 assertion the EF trusts; Workers+KV+Rate-Limit binding+Hyperdrive→Supabase) is justified by a PUBLIC machine create API with a load driver. p2p-hub lacks that driver today → reserve the pattern, build only when a public machine API needs WAF/HMAC/rate-limit. NO conflict with the Vercel docs-site (documentation-only, orthogonal; do not move to CF Pages).
- EGRESS = FEASIBLE AS-IS and the LOAD-BEARING convergence win. Supabase EF egress is non-static (Deno Deploy, Supabase's own documented limitation). mb-next solves outbound static-IP via a CONNECT forward proxy on an account-owned AWS Elastic IP; prod compute = ECS/Fargate in a private subnet → NAT Gateway + EIP, ap-southeast-1 (ADR-9 EG1-EG7 docs/adr.md:2307-2341; EG8-EG10 :2367-2398). API Gateway REJECTED as egress (shared, non-whitelistable); CF Aegis dedicated-egress-IP rejected (Enterprise-tier). p2p-hub hits the SAME problem at the §C8 Thunder-verify gate (api.thunder.in.th, design-exploration:937-965) when the mock→real switch happens — reuse the proxy verbatim for BOTH Thunder calls AND callbacks. Touches CODE (Deno.createHttpClient({proxy}) egress wrapper + proxy-cred EF secrets), not just ops. Hard prerequisite for the mock→real Thunder ("Phase G") switch.
- AWS = FEASIBLE AS-IS, EGRESS-ONLY. Not a compute/data platform (Supabase is backbone). AWS enters only as the egress IP-pinning element (Fargate+NAT-GW+EIP). Self-hosted bot-host would be a separate ADR-6-class decision.

KEY PATTERN: when a sibling repo in the same family already ratified an infra decision for a problem you ALSO have (here: non-static Supabase EF egress vs an allow-listed outbound dependency), adopt the mechanism verbatim and phase the rest by driver — don't speculatively adopt vendors (CF) before the matching load/security driver exists. Phased multi-cloud (Supabase have-it → AWS egress when Thunder goes real → CF when a public machine API appears) keeps mechanism-convergence without paying full overhead early.

---
*Added via Oracle Learn*
