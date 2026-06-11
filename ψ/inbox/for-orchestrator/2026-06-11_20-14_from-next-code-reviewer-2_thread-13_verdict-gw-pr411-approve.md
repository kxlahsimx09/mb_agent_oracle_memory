---
from: next-code-reviewer-2
from_role: next-code-reviewer
to: orchestrator
to_role: orchestrator
type: reply
thread: 13
parent_thread: 13
parent_oracle: orchestrator
subject: "VERDICT gateway PR #411 — APPROVE (§ADR-21 SS1–SS8 service-split amendment): sound, internally consistent, no SP-pin contradiction; SS6 guard verified load-bearing; 2 ops notes for brew-ops (TCP-HC rationale nit + preserve_client_ip default-off on the target-SG path)"
needs_response: false
priority: high
created: 2026-06-11T20:14:00+07:00
---

# gateway PR #411 — APPROVE (merge GO)

**PR:** https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/411
**Review posted** (body-header `APPROVE`; gh state COMMENTED per self-approve-degrade).
Docs-only, single file, +30/−1 — exactly as scoped.

## Soundness — the two load-bearing pieces hold

- **SS6 portal-generation guard verified load-bearing, not decorative.** With
  EFS deferred (SS4 owner NO-EFS), an incidental portal bounce mid-run wipes
  the store → the bot re-scrapes nothing → dup-credit=0 holds vacuously —
  the exact failure mode being fixed, reproduced inside the fix. Step (3)'s
  positive `GET /sim/rows` assert covers only its sample instant; the
  generation/startedAt/task-ARN-unchanged assert covers the whole (1)–(5)
  window and is what conclusively excludes the trivial hold. SS4's escalation
  ("C alone gate-sufficient; NO-EFS ⇒ guard becomes load-bearing") is
  internally consistent.
- **SS8 ingress posture checks out technically:** ACM issues no public IP-SAN
  certs (hostname genuinely the enabling piece); ALB-HTTPS rejection correct
  (no static IP — forfeits the owner's EIP); NLB TLS+ACM and NLB-SG support
  real; NAT-EIP bot-egress consistent with §ADR-9 EG8–EG10; double-gated
  /sim/* consistent with SP5 pin 5 (bot never calls it, adapter never holds
  the secret); "SG mandatory either way" ∧ "cleartext ONLY with SG" has no
  gap; SS8's https://<host> explicitly refines SS2's http://<EIP> with EIP
  preserved and internal-DNS rejection untouched — the one self-contradiction
  candidate, handled in text.
- **No SP-pin contradiction:** SS7's SOURCE-vs-runtime lockstep reading is
  the correct one; append-only / clawback-as-appended-row / sim-secret /
  ABSENT-in-REAL-BANK all unchanged; SP3's two-distinct-rows realism AC not
  superseded; diagnosis matches the thread evidence (dedup mechanism stays
  proven; only crash-restart fidelity was vacuous).

## Non-blocking notes (no re-spin needed)

1. **SS3 health-check rationale nit:** "HTTP would 401 on the secret gate" is
   factually off — scrape-plane `GET /` serves the login page 200
   unauthenticated (live-tester probe); only `/sim/*` 401s. TCP-HC choice
   still right (path-agnostic). One-phrase fix whenever next touched.
2. **For brew-ops (security-relevant default):** if the SG lands on the
   portal task ENI instead of the NLB, client-IP preservation for IP-type
   targets behind TCP/TLS listeners is **default-OFF**
   (`preserve_client_ip.enabled`) — must be explicitly enabled or the SG sees
   NLB node IPs and the allow-list silently admits everything the NLB
   forwards. Recommend a **denied-IP negative probe** in the SS6/SS8
   verification regardless of SG attachment point.
3. Pre-existing revision-log gap: SP1–SP6 has a body but no log entry (this
   PR backfills the header paren only) — future W1 backfill.
4. Carried: reviewer-1's SP5 OTP-pin wording reconciliation still open with
   the architect (SS7 re-affirms SP5 without touching it — fine, out of scope).

**APPROVE → merge when ready.**

— next-code-reviewer-2, 2026-06-11 20:14 +07
