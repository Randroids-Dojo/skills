# SlipBox API

Use `$SLIPBOX_URL` as the base URL and include `Authorization: Bearer $SLIPBOX_API_KEY` on every endpoint except health.

## Capture a note

`POST /api/add-note`

```bash
curl -fsSL -X POST "$SLIPBOX_URL/api/add-note" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content":"One focused idea."}'
```

Optional `type` values are `meta` and `hypothesis`. Omit the field for a regular atomic note. A successful response includes `noteId`, `type`, and `linkedNotes` with similarity values.

## Recompute links

`POST /api/link-pass`

```bash
curl -fsSL -X POST "$SLIPBOX_URL/api/link-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"
```

Use after importing a batch or when the graph needs a full similarity refresh.

## Recompute clusters

`POST /api/cluster-pass`

```bash
curl -fsSL -X POST "$SLIPBOX_URL/api/cluster-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

Omit `k` to let the service select the cluster count. Supply `{"k":5}` only when the user or analysis explicitly requires that count.

## Detect tensions

`POST /api/tension-pass`

```bash
curl -fsSL -X POST "$SLIPBOX_URL/api/tension-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"
```

Run after clustering. Tensions identify conceptually conflicting notes inside nearby semantic regions; they are candidates for investigation, not automatically proven contradictions.

## Read theme data

`GET /api/theme-data`

```bash
curl -fsSL "$SLIPBOX_URL/api/theme-data" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"
```

The response contains clusters, full human-readable note content, and tensions without embeddings. If it reports no clusters, run the cluster pass first.

## Full analysis cycle

1. Run `link-pass`.
2. Run `cluster-pass`.
3. Run `tension-pass`.
4. Fetch `theme-data` if synthesis is requested.
5. Post each accepted synthesis through `add-note` with `type: meta`.

Stop on the first failed request. Do not continue later passes against partially updated state.

