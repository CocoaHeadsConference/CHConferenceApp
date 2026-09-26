# User Authentication & App Authentication — Specification

> **Status:** Design spec. No code in this document — it is the blueprint for a
> follow-up implementation task.
> **Branch of record:** `claude/vapor-user-auth-spec-jey32u`
> **Scope:** the Vapor backend in [`/backend`](../) and its iOS client.

---

## 1. Overview & goals

We are introducing **user accounts** as the foundation for future features. Today the
backend is a single, unauthenticated route — `POST /scrape` (a Firecrawl shim, see
[`ScrapingController.swift`](../Sources/backend/Controllers/EventScrape/ScrapingController.swift)) —
reachable by anyone on the internet. There are no Fluent models, no migrations, no auth
middleware, and no users. `JWT` is not yet a dependency.

This spec defines **two independent security layers**. They are orthogonal — a request
must pass both to reach a user-scoped route:

1. **App authentication** — *"is this a legitimate client?"*
   API-key middleware. Applied to **all** routes, including the existing `/scrape`.
   Goal: identify requests as coming from our app (see §6 for why this is not an
   integrity guarantee and why App Attest was dropped).
2. **User authentication** — *"who is this person?"*
   Sign in with Apple → backend-issued JWT. Applied to user-scoped routes only.

```
                ┌─ App authentication ─┐
Request ──▶ [ X-API-Key check ] ──▶ ...
                                     │
                   ┌── User authentication ──┐
               ──▶ [ Bearer JWT check ] ──▶ handler
```

### Non-goals for this phase
- Role **enforcement** logic (the `role` field exists; gating by role is future work).
- The future features that users will underpin.
- Any non-Apple login provider.

---

## 2. Identifiers & environment

### Identifiers
- **Main app bundle id:** `com.cocoaheadsbr.conf` — this is the `aud` claim to validate
  in the Apple identity token, and the client id for Apple's token/revoke endpoints.
- App Clip (`com.cocoaheadsbr.conf.baseClip`) and Watch
  (`com.cocoaheadsbr.conf.watchkitapp`) are **out of scope** for sign-in.

### Environment variables
Follow the existing `Environment.get(...)` pattern already used in
[`FirecrawlService.swift`](../Sources/backend/Controllers/EventScrape/FirecrawlService.swift)
and [`configure.swift`](../Sources/backend/configure.swift). Document these alongside the
existing `DATABASE_*` and `FIRECRAWL_API_KEY` vars.

| Variable | Purpose |
| --- | --- |
| `JWT_SIGNING_KEY` | Secret/keypair the backend uses to sign its own access tokens. ES256 keypair recommended (see §5). |
| `APPLE_BUNDLE_ID` | Expected `aud` of the Apple identity token; also the client id. (`com.cocoaheadsbr.conf`) |
| `API_KEYS` | Comma-separated static client keys for the coarse API-key gate (§6). |
| `ACCESS_TOKEN_TTL` | Access-token lifetime (default ~15 min). |
| `REFRESH_TOKEN_TTL` | Refresh-token lifetime (default ~30–60 days). |
| `ACCOUNT_PURGE_GRACE_DAYS` | Hard-purge delay after soft-delete (default 30, see §8). |
| **Apple Sign In service credentials** (needed to mint the client-secret JWT for Apple's token & revoke endpoints — §4, §8): | |
| `APPLE_TEAM_ID` | Apple Developer Team ID. |
| `APPLE_SIGNIN_KEY_ID` | Key ID of the Sign in with Apple `.p8` key. |
| `APPLE_SIGNIN_PRIVATE_KEY` | The `.p8` private-key contents (ES256). |

---

## 3. Data model (Fluent — the project's first migrations)

There are currently **no models or migrations**. These are new. Register them in
[`configure.swift`](../Sources/backend/configure.swift) (which presently registers none),
and they will run through the `migrate` / `revert` services already stubbed in
[`docker-compose.yml`](../docker-compose.yml).

### `User`
| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | PK |
| `appleUserIdentifier` | String | Apple `sub`. **Unique, indexed.** Stable per Apple ID + team. |
| `email` | String? | Apple returns this only on **first** authorization. May be a Hide-My-Email relay (§10). |
| `fullName` | String? | Apple returns this only on first authorization. Persist then. |
| `role` | enum (String) | `user` \| `organizer` \| `admin`. Default `user`. (§7) |
| `appleRefreshToken` | String? | **Encrypted at rest.** Required to revoke Apple's grant at deletion (§8). |
| `deletedAt` | Date? | Soft-delete tombstone (§8). |
| `createdAt` | Date | Fluent `@Timestamp`. |
| `updatedAt` | Date | Fluent `@Timestamp`. |

### `RefreshToken`
| Field | Type | Notes |
| --- | --- | --- |
| `id` | UUID | PK |
| `userID` | UUID | FK → `User`. |
| `tokenHash` | String | Hash of the token. **Never store the raw token.** |
| `expiresAt` | Date | |
| `revoked` | Bool | Set on logout / rotation / deletion. |
| `createdAt` | Date | |

---

## 4. Sign in with Apple flow

### Sequence
1. **Client** runs `ASAuthorizationController` and obtains an Apple `identityToken`
   (a JWT) plus an `authorizationCode`.
2. Client calls **`POST /auth/apple`** with the identity token, the `authorizationCode`,
   the user's name/email (present only on first run), and the API key.
3. **Server**:
   - Verifies the Apple identity token using Vapor's JWT package built-in Apple support
     — `request.jwt.apple.verify(applicationIdentifier:)` — which fetches/caches Apple's
     JWKS and validates `iss` / `aud` / `exp`.
   - **Upserts** a `User` keyed on the Apple `sub`. Persists name/email if provided.
   - **Exchanges the `authorizationCode` for Apple tokens:** builds a client-secret JWT
     (signed with the `.p8` key via `APPLE_SIGNIN_KEY_ID` / `APPLE_TEAM_ID`) and
     `POST`s to `https://appleid.apple.com/auth/token` to obtain Apple's **refresh
     token**, then stores it (encrypted) on the `User`. This is mandatory groundwork —
     without it we cannot satisfy Apple's deletion/revocation requirement (§8).
   - Issues a backend **access token** + **refresh token** (§5).

### Endpoints
| Method & path | Purpose | Auth required |
| --- | --- | --- |
| `POST /auth/apple` | Sign in / sign up via Apple. Returns token pair. | App-auth only |
| `POST /auth/refresh` | Rotate refresh token, issue new access token. | Valid refresh token |
| `POST /auth/logout` | Revoke the presented refresh token. | Bearer JWT |
| `GET /me` | Return the current user (example protected route). | Bearer JWT |
| `DELETE /me` | Delete the account (§8). | Bearer JWT |

### Dependency to add
Add the `JWT` product from [`vapor/jwt`](https://github.com/vapor/jwt) to
[`backend/Package.swift`](../Package.swift). This provides both the Apple identity-token
verification and the backend's own JWT signing.

---

## 5. Session tokens

- **Access token** — a backend-signed JWT.
  - Algorithm: **ES256** recommended (keypair via `JWT_SIGNING_KEY`); HS256 acceptable.
  - TTL: short (~15 min, `ACCESS_TOKEN_TTL`).
  - Claims: `sub` = user id, `role`, `exp`, `iat`.
  - Verified statelessly by a `Bearer` authenticator middleware
    (`AsyncBearerAuthenticator`) — no DB hit on the hot path.
- **Refresh token** — an opaque random string.
  - Only its **hash** is stored (`RefreshToken.tokenHash`); the raw value is returned to
    the client once and kept in the Keychain.
  - TTL: long (~30–60 days, `REFRESH_TOKEN_TTL`).
  - **Single-use rotation:** each `/auth/refresh` revokes the presented token and issues
    a new one. Revocable on logout and on account deletion.

---

## 6. App authentication layer (API key)

Order of checks for a protected route: **API key → (user routes) Bearer JWT.**
The existing `/scrape` route becomes gated behind app-auth.

### API key middleware
- Checks an `X-API-Key` header against the configured `API_KEYS` (static env var, per the
  chosen approach).
- **Caveat (documented intentionally):** a key baked into a shipped app is extractable
  from the binary. This is a coarse gate, **not** a client-integrity guarantee.

### App Attest (removed)
An earlier revision of this spec added an App Attest assertion gate. It was removed:
`DCAppAttestService` is unsupported on the Mac (and the Simulator), so Mac clients could
never attest, and making it optional on account routes would let any client bypass it by
omitting the headers. User-scoped routes are protected by Sign in with Apple, backend
tokens, and server-side role checks; abuse of costly routes should be handled with rate
limiting (§10).

---

## 7. Roles (foundation only)

- `enum Role: String, Codable { case user, organizer, admin }`, default `user`.
- Embedded in the access-token claims so future authorization is a stateless check.
- **No enforcement middleware in this phase.** Document the intended shape of a future
  `RoleMiddleware` (e.g. `.grouped(RoleMiddleware(.admin))`) so the field is
  forward-compatible. Role **assignment** mechanics are deferred.

---

## 8. Account deletion (REQUIRED — Apple App Review Guideline 5.1.1(v))

Any app offering account creation **must** offer in-app account deletion. For Sign in
with Apple, Apple additionally requires revoking the user's grant via their
server-to-server endpoint. This is a first-class part of the spec, not future work.

- **Endpoint:** `DELETE /me` (authenticated). A confirmation step is optional.
- **Model: soft-delete + scheduled purge.** A permanent "deleted" flag that retains the
  user forever does **not** satisfy the guideline. On deletion:
  1. Set `User.deletedAt`; immediately **scrub/anonymize PII** (`email`, `fullName`) and
     treat the account as gone for all app purposes.
  2. Revoke **all** of the user's `RefreshToken`s.
  3. Call Apple's revocation endpoint
     `POST https://appleid.apple.com/auth/revoke` with the stored `appleRefreshToken`
     plus a freshly minted client-secret JWT, to revoke Apple's grant.
  4. **Hard-purge** the row after a short grace period (`ACCOUNT_PURGE_GRACE_DAYS`,
     default ~30 days, for support / abuse recovery) — via a scheduled job (`Queues`
     task) or a startup sweep.
- **Dependency chain:** step 3 only works because §4 exchanges and stores the Apple
  refresh token at sign-in.
- **iOS requirement:** a clearly reachable in-app "Delete Account" action — Apple rejects
  flows that only point users to a website or email (see §9).

---

## 9. iOS client impact (documentation only — no client code in this task)

- **HTTP layer needed.** None exists today; the app is CloudKit-only and
  [`MeetupService.swift`](../../CocoaHeadsKit/Sources/CocoaHeadsKit/Meetup/MeetupService.swift)
  is a `fatalError` stub. A small `URLSession`-based client must be built.
- **Sign in with Apple capability + entitlement** must be added (not currently present in
  the app's entitlements).
- **Keychain storage** for the refresh token (no Keychain usage
  exists today).
- **"Delete Account" UI** is mandatory and must be reachable in-app (Guideline 5.1.1(v))
  — calls `DELETE /me`, then clears the local Keychain/session.
- **Shared DTOs** (`AppleSignInRequest`, `TokenResponse`, `RefreshRequest`) belong in
  [`CocoaHeadsCore`](../../CocoaHeadsCore), which is already shared by the app and the
  backend — mirroring how `MeetupEvent` / `MeetupEventRequest` are shared.

---

## 10. Security considerations & open questions

- **API key extractability** — the API key is only a coarse gate; there is no
  client-integrity guarantee (see §6).
- **Token replay** — refresh-token single-use rotation; revocation on logout.
- **Hide My Email** — the stored `email` may be an Apple relay address; do not assume it
  is reachable or stable.
- **Secrets at rest** — encryption for the stored Apple refresh token; key management for
  the `.p8` Sign in with Apple signing key.
- **Rate limiting** on `/auth/*` and `DELETE /me` (future).

---

## 11. Summary of follow-up implementation work

1. Add `vapor/jwt` to `Package.swift`.
2. Create `User`, `RefreshToken` models + migrations; register them in
   `configure.swift`.
3. Add new env vars (config + `docker-compose.yml`).
4. Build middleware: API-key, Bearer JWT.
5. Build controllers/routes: `/auth/apple`, `/auth/refresh`, `/auth/logout`, `/me`
   (GET + DELETE). Gate `/scrape` behind app-auth.
6. Implement Apple `authorizationCode` exchange + revocation client.
7. Implement the soft-delete scrub + scheduled hard-purge job.
8. Add shared auth DTOs to `CocoaHeadsCore`.
9. iOS: HTTP client, Sign in with Apple, Keychain, Delete Account UI.
