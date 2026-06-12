---
title: GW4 staging drift: Worker GW4_SK_k1 held a different keypair than EF GW4_VERIFY_
tags: [brew-ops, repo:mb-next-payment-gateway, staging, gw4, cf-worker, drift, gotcha, secrets]
created: 2026-06-11
source: thread #13 blocker 17-15; _shared/gateway-assertion.ts; gateway/cf-worker/src/index.ts; witness probe 2026-06-11 17:35 GMT+7
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# GW4 staging drift: Worker GW4_SK_k1 held a different keypair than EF GW4_VERIFY_

GW4 staging drift: Worker GW4_SK_k1 held a different keypair than EF GW4_VERIFY_KEYS{k1} — same kid, so the failure is exactly `verify_failed` (not unknown_kid). Fixed 2026-06-11 by one `wrangler secret put GW4_SK_k1 --name mb-next-gw-staging` with the canonical key.

Debug recipe that localized it in minutes:
1. The EF taxonomy in _shared/gateway-assertion.ts is fine-grained: unknown_kid / iss_aud_mismatch / expired / request_hash_mismatch / verify_failed. `verify_failed` specifically = kid RESOLVED in the keyring but the signature didn't verify → same-kid keypair drift, secret-sync class (brew-ops), NOT claims logic (next-dev).
2. Which side drifted? You can't read EF secret values, but `supabase secrets list` digests are sha256 of the raw value. Recompute sha256 over the candidate serialization — node's key order for an Ed25519 pub JWK is {"crv","x","kty"} — and compare. Here {"k1":{"crv":"Ed25519","x":"sLTM…","kty":"OKP"}} matched digest ecd3ff49…, proving the EF ring was already canonical (= pub of the slot's GATEWAY_ASSERTION_SIGNING_KEY, per the staging.env comment) and the WORKER was the drifted side. One-sided fix, no EF churn.
3. Canonical key source: fleet-secrets mb-next-payment-gateway/slots/staging.env GATEWAY_ASSERTION_SIGNING_KEY (Ed25519 PKCS8 b64). Derive priv/pub JWK with node createPrivateKey({der,pkcs8})/createPublicKey + .export({format:'jwk'}).
4. CF auth gotcha: the CF_API_TOKEN in the dev slots is stale (400 code 9106); the host's wrangler OAuth session (~/Library/Preferences/.wrangler/config/default.toml) is what works — run wrangler WITHOUT CLOUDFLARE_API_TOKEN env override.
5. Witness probe without the tester harness: staging `client` table stores api_key/api_key_secret in clear — sign X-Signature: t=<ms>,v1=hex(hmac-sha256(secret, `${t}.${body}`)) and POST through the Worker. Any non-verify_failed answer (e.g. 400 IDEMPOTENCY_KEY_REQUIRED) proves the assertion hop.

Likely origin: the Worker deploy (workflow-7, 2026-06-09) generated/used its own GW4_SK_k1 while the authdeploy campaign set the EF ring from the slot key — first real machine-create through the staging Worker (2026-06-11) exposed it. Prevention: when deploying the CF worker to a slot stack, ALWAYS set GW4_SK_<active kid> from the slot's GATEWAY_ASSERTION_SIGNING_KEY, never generate fresh while reusing an existing kid.

---
*Added via Oracle Learn*
