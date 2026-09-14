# CocoaHeadsNetworking

Foundation-only Swift 6 package for the public CocoaHeads catalog. Its local dependency,
`CocoaHeadsCore`, owns the wire models and event-timezone rules. Screens use the fixed
`ScreenDocument` envelope (`schemaVersion`, `screen`, `content`), with ISO 8601 dates.
An absent `endDate` means an event stays ongoing from its start until the next midnight
in its own timezone. A supplied end time preserves the ended-today state until that day's
midnight. Optional venue `arrivalInstructions` carries organizer-supplied access details.

`EventCatalog.features` is ordered editorial content independent of the event list. Each
`CatalogFeature` has its own identity, title, optional subtitle/image, and optional chapter
scope (`chapterID: nil` means national). Destinations use an explicit tagged JSON object:

```json
{"type":"event","eventID":"demo-floripa-hackathon"}
{"type":"externalURL","url":"https://example.com/comunidade"}
{"type":"placeholder","title":"Novidades em breve"}
```

Event destinations must reference an event in the same catalog; chapter scopes must
reference a listed chapter. Feature IDs are unique and links/images accept HTTP(S) URLs.
An unknown destination tag is unsupported behavior and throws `unsupportedScreen` even
when cached content exists. A known destination missing its required fields is an invalid
payload. Older documents without `features` decode as an empty array, while the legacy
event `isFeatured` field remains available for presentation fallback.

`EventRepository` fetches `GET /v1/screens/events` and `GET /v1/screens/events/{id}`.
Each internal request declares its typed response, validation, and mock response, following
Joguei's request/client split. Live clients never fall back to fixture content.

Create an `EventClientConfiguration` with `.production`, `.localhost`, or `.mock` in the
app's composition root. Live environments require an explicit `baseURL`; this package
does not invent a production hostname. Scheme/build configuration remains in the app.
`.mock` never calls HTTP, including media. The known fixture hero URL resolves to a bundled
PNG through `EventImageStore`; unknown image URLs fail without making a request. Live images
still use the injected HTTP transport and persistent cache. Q&A remains a separate CloudKit
feature, and MapKit manages its own tiles; both are outside the catalog gateway's guarantee.

Call `cachedCatalog()` / `cachedEvent(id:)` for immediate previously viewed content, then
refresh with `catalog()` / `event(id:)`. Successful catalogs also cache their complete
event payloads, so those details remain available offline. A fresh result has `isStale`
set to false; explicit cache reads and fallback results have it set to true, with the
original `cachedAt` timestamp. Ordinary transport, HTTP, and invalid-payload failures may
return the last valid snapshot. Unsupported screen/version failures always throw
`unsupportedScreen`, even with cached content. Cancellation propagates without fallback.
These outcomes remain separate so the app can apply its update/retry presentation policy.

Cache entries are written atomically in the app's caches directory, isolated by environment
and base URL. Mock scenarios intentionally share a namespace: run Standard, then Offline
to inspect stale content. Entries are validated again when read. Disk storage is best
effort and can be reclaimed by the OS; memory storage is capped at 32 MiB per cache owner.
Media uses `EventImageStore` with the same namespace rules and a cache-first policy.
There is no media expiry or explicit cache-management UI in this initial foundation.

Mock scenarios: `standard`, `empty`, `offline`, `serverError`, `unsupported`, `malformed`.
Fixture IDs remain stable; dates regenerate from the injected clock on every request, so
refreshing an app left open overnight restores useful live/upcoming/past examples.
The data covers multiple
cities, a city without events, upcoming/past/ongoing/ended-today events, hybrid/online
attendance, an event without an end time, talks, and a featured event. São Paulo's arrival
directions are illustrative fixture content. Fixture registration links use `example.com`.
Independent features include two Floripa entries (event and community link), one São Paulo
event, and a national informational card; their source order is retained.

Tests inject a Sendable HTTP transport and temporary cache directory. Run:

```sh
swift test --package-path CocoaHeadsNetworking
```

The tests make no external network requests.
