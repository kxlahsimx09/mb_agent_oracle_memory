---
title: ## DRIFT-14: `BlacklistAllUserTokens` force-logout is dead code
tags: [drift, auth, jwt, force-logout, dead-code, redis, security]
created: 2026-04-27
source: pg-writer W2 pass 2026-04-27 (thread #49 follow-up)
project: github.com/kokarat/mobiz-payment-gateway
---

# ## DRIFT-14: `BlacklistAllUserTokens` force-logout is dead code

## DRIFT-14: `BlacklistAllUserTokens` force-logout is dead code

**File:** `helpers/token_blacklist.go`
**Discovered:** 2026-04-27 during W2 pass following commit `c0f9c6f` (#315) — JWT cache fingerprint review

### What's broken

`BlacklistAllUserTokens(userID, userType)` (lines 79-93) writes a Unix timestamp to Redis at:

```
user:forcelogout:{user_type}:{user_id}
```

with TTL = `GetJWTExpiresIn()` (8h). The intent per the function's TODO comments is: when a user is banned/disabled, password is changed, or admin forces "logout all devices", any access token issued *before* this timestamp should be rejected.

`GetUserForceLogoutTime(userID, userType)` (lines 96-111) is the reader function for the same key — but **no caller exists**. Verified by:

```bash
$ grep -rn "GetUserForceLogoutTime" .
helpers/token_blacklist.go:96:func GetUserForceLogoutTime(...)  # definition only
```

`ValidateJWT` does not call it. `JWTAuthMiddleware` does not call it. No controller or middleware references it. The flag is written but never read.

### Operational consequence

- "Logout all sessions" admin pathway: writes the flag, but every request continues to validate normally. User stays logged in until either (a) the access-token expires (≤8h), (b) the cache entry expires (≤8h), or (c) `JWT_SECRET` rotates and pods restart (which retires every cached entry — see §7.6 / commit `c0f9c6f`).
- Password change / user disable workflows that call `BlacklistAllUserTokens` give a false sense of security: the audit log will show "tokens revoked" but the live session keeps working.
- The single-token blacklist (`BlacklistToken` / `IsTokenBlacklisted`) **is** wired correctly — `ValidateJWT:301` calls `IsTokenBlacklisted`. Only the *all-user* path is dead.

### Why this matters specifically now

Commit `c0f9c6f` makes secret rotation a viable force-logout mechanism (cache namespace switch). That's now the only practical "logout everyone" lever in production. Without DRIFT-14 fixed, admins cannot terminate a single user's sessions on demand without rotating the global secret (which logs out *all* users).

### Suggested fix shape

In `ValidateJWT` (helpers/jwt.go), after the blacklist check (line 301) and before/after signature verify, add:

```go
forceLogoutTs, found := GetUserForceLogoutTime(userID, userType)
if found {
    iat, _ := claims["iat"].(float64)
    if int64(iat) < forceLogoutTs {
        return false, emptyClaims, errors.New("session terminated by admin")
    }
}
```

Tradeoff: this adds a Redis Get on every authenticated request. Fits inside the existing fail-open pattern of `IsTokenBlacklisted`. Could also be cached at the cache-write step.

### Tags

`#drift #repo:mobiz-payment-gateway #current #technical-writer #dead-code #auth`

---
*Added via Oracle Learn*
