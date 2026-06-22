# [for next-live-tester] B.8 OTP-producer — consume the pre-minted cred (skip self-mint)

**From:** brew-ops · **To:** next-live-tester · **Date:** 2026-06-16 10:09 (GMT+7) · **Stack:** `mb-next-staging` / sinuw (`sinuwgsqqyqzlpaavimf`)
**Pairs with:** orchestrator handoff `for-brew-ops/2026-06-16_09-16` ASK 2 (owner chose **path (b)**, after (a) was found unworkable).

## Root cause (verified, not the handoff's first guess)
B.8 AMBER is **not** an enc-key problem. `OTP_PRODUCER_ENC_KEY` in `staging.env` is fine (50 chars, ≥16). The null comes from **mint-once collision**:
- `mint_otp_producer_credential(p_env)` RAISEs `otp_producer_credential_exists` when a live credential already exists for that env (migration `20260614000010_bbot010_otp_relay.sql`; `otp_producer_credentials` has a unique live-slot-per-env index).
- DB check on sinuw: **env=`sim` already has 1 active row** (`producer_key` prefix `otpp_pPHm6Wp1`, minted 2026-06-14). So `mintOtpProducer()`'s RPC always errors → no row → returns null → B.8 AMBER.
- Re-minting can never succeed for `sim`; rotating/deleting it would break the **deployed** KTB portal OTPService (it posts via this same fleet cred). So: **consume the existing cred**, don't mint.

## What brew-ops already did (slot — DONE)
Added the existing pre-minted SIM producer credential to the launcher's default slot `staging.env`:
```
export OTP_PRODUCER_KEY=…      # otpp_pPHm6Wp1… — the live 2026-06-14 sim cred (matches DB)
export OTP_PRODUCER_SECRET=…
```
(`OTP_PRODUCER_ENV=sim` and `OTP_PRODUCER_ENC_KEY` were already present and stay.) **No launcher change needed** — the creds are in `staging.env` itself (the tri-epic launcher's default `SLOT`), not the un-sourced `staging-otp-sim-producer.env`.

## The harness change (yours)
`poc/integration/src/live/bot-driver.ts` → `mintOtpProducer()`: prefer the pre-minted creds when present; keep self-mint only as the fallback for an env that has never minted one.

```ts
export async function mintOtpProducer(ctx: JourneyCtx): Promise<OtpProducerCred | null> {
  // PREFER a pre-minted fleet credential — the sim producer cred is mint-ONCE
  // (unique live slot per env); once minted, a second mint RAISEs
  // otp_producer_credential_exists, so self-mint can never succeed for sim.
  const preKey = process.env.OTP_PRODUCER_KEY ?? "";
  const preSecret = process.env.OTP_PRODUCER_SECRET ?? "";
  if (preKey && preSecret) {
    logBeat(ctx, { beat: "otp-producer-mint", env: OTP_ENV(),
                   producer_key_prefix: preKey.slice(0, 12), source: "pre-minted" });
    return { producerKey: preKey, secret: preSecret };
  }
  // Fallback: self-mint (only an env that has NEVER minted a producer cred).
  if (OTP_ENC().length < 16) return null;
  const r = await rpc(ctx, "mint_otp_producer_credential",
    { p_enc_key: OTP_ENC(), p_env: OTP_ENV(), p_actor_type: "admin", p_reason: "olive tri-epic live harness" });
  const row = Array.isArray(r.body) ? r.body[0] : r.body;
  if (!row?.producer_key || !row?.producer_secret) return null;
  logBeat(ctx, { beat: "otp-producer-mint", env: OTP_ENV(), producer_key_prefix: String(row.producer_key).slice(0, 12) });
  return { producerKey: row.producer_key, secret: row.producer_secret };
}
```

## Acceptance / verify
On a gated BBOT run (`OWNER_GO_LIVE_BBOT=1 ./run-live-tri-epic.sh`, APPEND mode, **never** `LIVE_DEDICATED_STACK=1` — sinuw is shared):
- B.8 logs `otp-producer-mint` with `producer_key_prefix: "otpp_pPHm6Wp1"` + `source: "pre-minted"` (non-null), and
- the producer-plane write (`postOtp` → `bot-otp-log`) returns **200**.
- B.8 AMBER → GREEN.

## Scope / ownership
- Harness-only (one function in `bot-driver.ts`); open a PR on the gateway repo → owner merges. No gateway EF / DB / slot change from your side (slot is brew-ops, done).
- The producer credential is the **live fleet cred** the deployed bots use — do NOT rotate/re-mint it.
