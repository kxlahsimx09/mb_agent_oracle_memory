---
title: §ADR-9 §Amendment 2026-05-31 (campaign ng2arch ITEM E, PR #296, NOT merged — pen
tags: [adr-9, callback, ssrf, redirect, dns-rebind, security, amendment, ratification-pending, ng2arch, callback-003]
created: 2026-05-31
source: next-architect (ng2arch follow-on ITEM E)
---

# §ADR-9 §Amendment 2026-05-31 (campaign ng2arch ITEM E, PR #296, NOT merged — pen

§ADR-9 §Amendment 2026-05-31 (campaign ng2arch ITEM E, PR #296, NOT merged — pending user GO, SECURITY) — Callback Redirect-Following Posture. Closes a redirect-chain SSRF vector CU1-CU8 leave open: CU3 validates the endpoint config-time, CU6 re-checks DNS connect-time (rebind), but neither guards an auto-followed HTTP 3xx whose Location points at an internal/cloud-metadata target (169.254.169.254 / RFC-1918) — SSRF-via-redirect, orthogonal to both. next-writer verified CU1-CU8/WC1-WC11/EG1-EG7 silent on redirect-following.

RATIFIED class (a) within authority: RF2 — redirect-handling is the THIRD LEG of the endpoint-safety triad (config-time CU3 / connect-time-DNS CU6 / response-time-redirect RF); a blocked (or followed-then-rejected) redirect NEVER mutates the source deposit/payout lifecycle (same fail-safe shape as CU6 — writes a callback_attempts row + rides retry/dead-letter).

FLAGGED class (b) [RATIFICATION_PENDING:ng2arch-e] (SECURITY): RF1 — the posture: (a) DO-NOT-FOLLOW [architect lean — disable HTTP-client auto-redirect; a 3xx → `callback_redirect_blocked` attempt + normal retry/dead-letter (Decision #4); never fetch the Location; closes the vector entirely; a callback endpoint is a terminal URL not a redirector] vs (b) follow only to a CU3-revalidated public target with a hop cap (more permissive; adds per-hop SSRF revalidation + TOCTOU surface). NOT architect-self-bound.

GENERALIZABLE: SSRF on an outbound webhook has THREE legs — config-time URL validation, connect-time DNS re-resolution, and response-time redirect handling. Validating the configured URL and re-resolving DNS is insufficient if the client auto-follows a 3xx. Story CALLBACK-003 gained the redirect AC (pending) + a "three-leg triad" edge case. Repo: kxlahsimx09/mb-next-payment-gateway.

---
*Added via Oracle Learn*
