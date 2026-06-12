---
title: Lane B (thread #13): static-IP HTTPS ingress for a Fargate SIM portal WITHOUT an
tags: [brew-ops, repo:cross, aws, fargate, ec2, caddy, tls, deploy, bank-bot, sp3]
created: 2026-06-11
source: thread #13 Lane B build 2026-06-11; ec2proxy-build.sh; instance i-0d96a92a6035b46f1
project: github.com/kxlahsimx09/mb-next-bank-bot
---

# Lane B (thread #13): static-IP HTTPS ingress for a Fargate SIM portal WITHOUT an

Lane B (thread #13): static-IP HTTPS ingress for a Fargate SIM portal WITHOUT an NLB — pattern that works on AWS acct 261955339426 (which is ELB-blocked) — EC2 micro-proxy + EIP + Caddy + Let's Encrypt + sslip.io, with the portal COLOCATED on the proxy.

Topology: one t4g.nano (AL2023 arm64) holds the EIP 18.136.227.108. Caddy terminates TLS (LE) for 18-136-227-108.sslip.io (sslip.io = free wildcard DNS: <dashed-ip>.sslip.io → that IP, so no domain ownership + LE issues a valid cert). Portal runs as a node systemd unit from CANONICAL repo source (sim/mock-portal/{server.js,store.js,pages.js} are pure Node builtins — no npm, no ECR), HOST=127.0.0.1:4925 loopback, SIM_DATA_FILE on EBS (survives the portal's own restart → closes SS4 with zero EFS). Caddy reverse_proxy 127.0.0.1:4925; /sim/* IP-gated via `@blk { path /sim/* ; not remote_ip <owner/32> } respond @blk 403`. Bot stays Fargate (own service mb-next-bankbot-bot, BANK_URL=https://18-136-227-108.sslip.io) so SP3 = bot-only restart and the portal (separate EC2) survives.

Build gotchas burned on this one:
1. **user-data 25600-byte hard cap** — embed portal source as ONE gzipped tarball base64 (`tar czf - *.js | base64 | tr -d '\n'`), decode+untar on the instance. 3 separate base64 files blew the cap.
2. **t4g.nano first-boot dnf install nodejs is SLOW (~2-3 min)** — :443 stays closed that whole time; don't mistake slow-boot for failure. v1 looked dead at 5 min; it was just dnf.
3. **No console/SSM visibility**: one-time-grant lacks ec2:GetConsoleOutput + ssm:* (SSM perms are on the INSTANCE role, not the deploy user). Debug trick: cloud-init `exec > /var/log/portal-build.log 2>&1; set -x` + `python3 -m http.server 8080 --directory /var/log &` as the FIRST user-data action, SG :8080 to your /32 only → curl http://EIP:8080/portal-build.log to read the live boot log. REVOKE :8080 after.
4. **Caddy install**: pinned GitHub release tarball (`caddy_<ver>_linux_arm64.tar.gz`) with curl --retry beats the caddyserver.com/api/download redirect.
5. **TLS challenge**: :80-closed + TLS-ALPN-01 (disable_http_challenge) is finicky; the robust ops choice is :80 OPEN to 0.0.0.0/0 + default Caddy auto-HTTPS (HTTP-01) — :80 only serves the ACME challenge + 308 redirect.
6. **cloud-init internet during boot**: pass --associate-public-ip-address on run-instances (subnet may not auto-assign); EIP associates AFTER instance-running and swaps the auto IP — Caddy's cert request retries until the EIP lands.

SP3 proof shape (SS6, L2a AMBER→GREEN): inject R → bot push "1 inserted,0 skipped" → stop bot task → DURING restart curl https portal=200 + EIP unmoved + /sim/rows still has R → new bot re-scrapes → gateway "0 inserted,1 skipped", DB count stays 1. The "R survived the bot restart" positive assert is what excludes the pre-split trivial empty-portal hold.

---
*Added via Oracle Learn*
