# Organizer setup

## Current app entry point

The signed-out **Perfil** tab intentionally pushes `CocoaHeadsPlaceholder("Entrar")` when the user
taps **Entre**. `AccountSignInView`, including its local preview account buttons, remains implemented
but is not presented by that route. Reconnect that destination before following the account-creation
steps below on a fresh installation. The organizer workspace and API are foundation work; production
credentials, the Render origin, and database provisioning still need to be supplied.

The app signs in with Apple and then asks the backend for the account's current publishing access. Creating an account grants the `user` role. Change an existing account's role and chapter assignments directly in Postgres to grant organizer access. There is no role-management API, admin-management screen, automatic first-admin promotion, or production seed data.

## Database and local backend

Set these environment variables for your own Postgres instance before running commands from `backend/`:

```sh
export DATABASE_HOST=127.0.0.1
export DATABASE_PORT=5432
export DATABASE_USERNAME=cocoaheads
export DATABASE_PASSWORD='your-local-database-password'
export DATABASE_NAME=cocoaheads
export API_KEYS=local-development-key
export APPLE_BUNDLE_ID=com.cocoaheadsbr.conf
```

Run the migrations, which create the auth tables and the catalog/organizer tables:

```sh
swift run backend migrate --yes
```

Run the local backend on port 8080. Account and organizer routes accept verified user sessions from platforms without device attestation, including Mac Catalyst and Simulator:

```sh
swift run backend serve --hostname 0.0.0.0 --port 8080
```

Use the **CocoaHeads (Localhost)** Xcode scheme. Localhost sign-in still uses Apple's real identity verification and code exchange, so the Apple service credentials below must be configured. The **CocoaHeads (Mock)** scheme provides a separate local account/editor experience without a server.

`APP_ATTEST_DISABLED=true` remains available only for local development of routes that require attestation, such as the existing scraper. It is unnecessary for account and organizer routes. Production rejects this global bypass even on routes with optional attestation. Public catalog requests do not use attestation or authentication at all.

## Apple and backend credentials

Configure the backend's environment with these values. Store service credentials on the backend, outside the app and repository.

| Variable | Value |
| --- | --- |
| `APPLE_BUNDLE_ID` | `com.cocoaheadsbr.conf`, shared by the iOS, visionOS, and Mac Catalyst app builds |
| `APPLE_TEAM_ID` | The Apple Developer team identifier |
| `APPLE_SIGNIN_KEY_ID` | The identifier of a key enabled for Sign in with Apple |
| `APPLE_SIGNIN_PRIVATE_KEY` | The full PEM contents of that key's `.p8` file, preserving newlines |
| `JWT_SIGNING_KEY` | A backend ES256 private-key PEM or strong HMAC secret used to sign access tokens |
| `TOKEN_ENCRYPTION_KEY` | Base64-encoded 32-byte encryption key for stored Apple refresh tokens |
| `API_KEYS` | The allowed app-identification key or comma-separated keys |
| `APP_ATTEST_TEAM_ID` | The team identifier used for device attestation; defaults to `APPLE_TEAM_ID` |
| `APP_ATTEST_ENVIRONMENT` | `production` for production-signed app builds; `development` for device development builds |

The shared app identifier must have Sign in with Apple enabled. On platforms with App Attest support, the client also supplies device assertions and the signing capability and attestation environment must match the backend. Mac Catalyst uses the same bundle identifier (`DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER=NO`), so Apple identity verification uses the same audience. Platforms without App Attest omit the assertion headers and can still sign in and organize events. The backend always verifies Apple identity tokens and authorization-code grants, then checks current database permissions for publishing.

The Render public origin is intentionally left for you to supply. In `Configuration/Server.xcconfig`, set `COCOAHEADS_PRODUCTION_URL` using xcconfig's escaped URL form (`https:/$()/...`) and set `COCOAHEADS_PRODUCTION_API_KEY` to a value allowed by the backend's `API_KEYS`. This app-identification key is not a user credential. Never put the Apple private key, JWT signing key, or token-encryption key into Xcode settings.

## Create chapters and grant access

Run the following through `psql` connected to the intended database, after migrations. Chapter IDs are stable public strings; use the same ID in event drafts and chapter assignments.

```sql
INSERT INTO catalog_chapters (id, name, region)
VALUES ('sao-paulo', 'São Paulo', 'SP')
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name, region = EXCLUDED.region;
```

First sign in through the **Perfil** tab to create the account. Identify the existing account by its UUID; do not grant privileges by matching an unverified email address. The profile exposes the backend user UUID. If needed, inspect accounts in your trusted database session:

```sql
SELECT id, full_name, email, role
FROM users
WHERE deleted_at IS NULL
ORDER BY created_at DESC;
```

Set `user_id` to that account's UUID in `psql`:

```sql
\set user_id 'replace-with-existing-user-uuid'
```

To grant global access across all chapters:

```sql
UPDATE users
SET role = 'admin', updated_at = now()
WHERE id = :'user_id'::uuid AND deleted_at IS NULL;
```

To grant access only to an assigned chapter, update the role and assignment in one transaction. Locking the user row first follows the same order as publishing requests, so a change serializes with an in-flight mutation:

```sql
BEGIN;
SELECT id FROM users
WHERE id = :'user_id'::uuid AND deleted_at IS NULL
FOR UPDATE;

UPDATE users
SET role = 'organizer', updated_at = now()
WHERE id = :'user_id'::uuid AND deleted_at IS NULL;

INSERT INTO organizer_chapters (id, user_id, chapter_id)
SELECT gen_random_uuid(), id, 'sao-paulo'
FROM users
WHERE id = :'user_id'::uuid AND deleted_at IS NULL
ON CONFLICT (user_id, chapter_id) DO NOTHING;
COMMIT;
```

Repeat the assignment insert for each permitted chapter. `admin` ignores chapter assignments; `organizer` requires them; `user` cannot edit events even if old assignments exist.

To revoke one chapter assignment:

```sql
BEGIN;
SELECT id FROM users WHERE id = :'user_id'::uuid FOR UPDATE;
DELETE FROM organizer_chapters
WHERE user_id = :'user_id'::uuid AND chapter_id = 'sao-paulo';
COMMIT;
```

To revoke all organizer/admin privileges:

```sql
BEGIN;
UPDATE users SET role = 'user', updated_at = now()
WHERE id = :'user_id'::uuid AND deleted_at IS NULL;
DELETE FROM organizer_chapters WHERE user_id = :'user_id'::uuid;
COMMIT;
```

Every organizer operation checks the current database role and assignments. Existing bearer tokens do not preserve revoked permissions. Use **Atualizar meu acesso** in **Perfil** after changing access, then open **Área de organização**.

## Publishing contract

Account (`/auth/*`, `/me`) and organizer routes require the API key and their respective Apple-identity or user-session checks. App Attest is verified when present: all three attestation headers may be absent, but supplying any of them requires a complete, valid assertion. Invalid or partial assertions never downgrade to an unattested request. This is a route policy, not a client-reported hardware capability. The existing `/scrape` route still requires App Attest. Public catalog routes bypass all these gates.

| Method and path | Behavior |
| --- | --- |
| `GET /v1/screens/events` | Public `ScreenDocument<EventCatalog>` with chapters and published event snapshots |
| `GET /v1/screens/events/{id}` | Public `ScreenDocument<CommunityEvent>`; unpublished/unknown events return 404 |
| `GET /v1/organizer/access` | `OrganizerAccess(user, chapters)` with current DB access |
| `GET /v1/organizer/events` | Editable `OrganizerEventRecord` values for permitted chapters |
| `POST /v1/organizer/events` | `SaveOrganizerEventRequest(draft)` creates a private draft, returns 201 with a server-generated UUID |
| `PUT /v1/organizer/events/{id}` | `SaveOrganizerEventRequest(draft, expectedRevision)` saves changes without updating the public snapshot |
| `POST /v1/organizer/events/{id}/publish` | `EventRevisionRequest(revision)` validates and publishes the saved draft |

Dates on these routes use ISO-8601, with fractional seconds in responses. `OrganizerEventDraft.startDate` and `endDate` are optional; `registrationURL` is an editable string. Publishing requires a title, chapter, valid start date/timezone, valid registration link, and the location/transmission details appropriate to the event format. An omitted end date remains omitted. Optional image, speaker, Q&A, and supplemental-link fields are preserved.

Each save or publish increments `revision`. A stale revision returns 409; invalid publication returns 422 with a localized reason. Do not automatically replay a mutation after a conflict. Publishing sets `publishedAt == updatedAt`; later edits advance `updatedAt` while preserving `publishedAt` and the existing public snapshot.

The public feed reads only `catalog_events.public_snapshot`. Incomplete drafts and unpublished edits never become visible through the public API. Catalog tables are created empty; chapter setup and subsequent publication supply the content.

## Verification

Core draft validation tests run without Postgres:

```sh
swift test --package-path CocoaHeadsCore
```

The organizer and rotation integration suites create and revert all configured migrations, including auth and catalog tables. Both require an explicitly set `DATABASE_NAME` ending in `_test` before they create a connection. Use a disposable database, separate from development data. Run these suites sequentially against that database; do not run them concurrently.

From the repository root, the following example targets a dedicated local test instance. Replace the host, port, username, and password with that disposable instance's settings. Do not reuse the development database from the setup commands above:

```sh
TEST_DATABASE=1 DATABASE_HOST=127.0.0.1 DATABASE_PORT=55432 \
DATABASE_USERNAME=cocoaheads_test DATABASE_PASSWORD=cocoaheads_test \
DATABASE_NAME=cocoaheads_test \
swift test --package-path backend --filter OrganizerIntegrationTests

TEST_DATABASE=1 DATABASE_HOST=127.0.0.1 DATABASE_PORT=55432 \
DATABASE_USERNAME=cocoaheads_test DATABASE_PASSWORD=cocoaheads_test \
DATABASE_NAME=cocoaheads_test \
swift test --package-path backend --filter RotationIntegrationTests
```

`AuthPersistenceTests` uses a separate `TEST_DATABASE_NAME` setting with the same `_test` suffix requirement, plus its own `TEST_DATABASE_HOST`, `TEST_DATABASE_PORT`, `TEST_DATABASE_USERNAME`, and `TEST_DATABASE_PASSWORD` settings.

The suite covers public browsing without auth headers, draft privacy, explicit publication, invalid drafts, chapter isolation, permission revocation, deleted users, admin scope, stale revisions, and concurrent edits.
