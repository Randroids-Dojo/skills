---
name: slipbox
description: "Interact with the SlipBox semantic knowledge engine and read notes from PrivateBox. Use when capturing ideas, searching notes, browsing your knowledge graph, or running semantic analysis passes (link, cluster, tension)."
compatibility: Requires SLIPBOX_API_KEY, SLIPBOX_URL, and SLIPBOX_PRIVATEBOX_REPO env vars. Reading PrivateBox notes requires GITHUB_TOKEN or the gh CLI.
---

# SlipBox Skill

> **IMPORTANT: Before doing anything else, run the setup check below. Do not skip this step.**

## Setup Check

Run this command immediately upon skill invocation:

```bash
echo "SLIPBOX_API_KEY: ${SLIPBOX_API_KEY:+${SLIPBOX_API_KEY:0:6}…(set)}" | sed 's/^SLIPBOX_API_KEY: $/SLIPBOX_API_KEY: (MISSING)/'
echo "SLIPBOX_URL: ${SLIPBOX_URL:-(MISSING)}"
echo "SLIPBOX_PRIVATEBOX_REPO: ${SLIPBOX_PRIVATEBOX_REPO:-(MISSING)}"
```

If any show `(MISSING)`:

- **STOP IMMEDIATELY. Do not attempt any further action.**
- Do not guess values, use defaults, search for shell config files, or attempt fallbacks of any kind.
- Tell the user exactly which variables are missing and that they must set them in `~/.zshrc` (or `~/.zprofile`) and re-source their shell before trying again.
- End your response there and wait for the user to fix the issue.

Once env vars are confirmed, verify the service is reachable:

```bash
curl -sL "$SLIPBOX_URL/api/health"
# {"status":"ok"}
```

If the health check fails or returns anything other than `{"status":"ok"}`:

- **STOP IMMEDIATELY. Do not attempt any further action.**
- Report the response to the user and tell them the service is unavailable.
- End your response there and wait for the user.

## API Error Handling

If any API call returns an error response (any JSON with an `"error"` field, or a non-2xx HTTP status):

- **STOP IMMEDIATELY. Do not attempt any further action.**
- Do not try to write notes directly to PrivateBox or any other fallback.
- Do not retry with different parameters or modified requests.
- Report the exact error response to the user and wait for them to resolve it.

---

## About

Interact with the SlipBox semantic knowledge engine and browse your PrivateBox notes.

**SlipBox service**: `$SLIPBOX_URL`
**PrivateBox repo**: `$SLIPBOX_PRIVATEBOX_REPO`

## Configuration

Required environment variables (set in shell):

```env
SLIPBOX_API_KEY=<shared-secret>          # Bearer token for API auth
SLIPBOX_URL=https://slip-box-rho.vercel.app  # SlipBox service base URL
SLIPBOX_PRIVATEBOX_REPO=Randroids-Dojo/PrivateBox   # GitHub repo for notes (owner/repo)
```

All other configuration (OpenAI, GitHub, PrivateBox) lives on the deployed Vercel service.

---

## Quick Reference

All API calls require: `Authorization: Bearer $SLIPBOX_API_KEY`

```bash
# Health check
curl -sL "$SLIPBOX_URL/api/health"

# Add a note
curl -sL -X POST "$SLIPBOX_URL/api/add-note" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content": "Atomic idea goes here."}'

# Add a typed note (type: "meta" or "hypothesis")
curl -sL -X POST "$SLIPBOX_URL/api/add-note" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content": "## Cluster: ...", "type": "meta"}'

# Re-link all notes (recompute similarity links)
curl -sL -X POST "$SLIPBOX_URL/api/link-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"

# Cluster notes into thematic groups
curl -sL -X POST "$SLIPBOX_URL/api/cluster-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"k": 5}'

# Detect conceptual tensions (contradictions within clusters)
curl -sL -X POST "$SLIPBOX_URL/api/tension-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"

# Fetch theme data (clusters + note content + tensions) for agent synthesis
curl -sL "$SLIPBOX_URL/api/theme-data" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"
```

---

## API Reference

### POST /api/add-note

Capture an atomic idea. SlipBox embeds it, links it to similar notes, and commits it to PrivateBox.

Optional `type` field sets a semantic type in the note's frontmatter. Valid values: `"meta"` (AI-generated cluster summary) or `"hypothesis"` (AI-generated research hypothesis). Omit for regular atomic notes.

```bash
# Regular note
curl -sL -X POST "$SLIPBOX_URL/api/add-note" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "The Zettelkasten method treats each note as a discrete, reusable idea."
  }'

# Meta-note (cluster synthesis)
curl -sL -X POST "$SLIPBOX_URL/api/add-note" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "## Cluster: Agentic Systems\n\nNotes in this cluster explore...",
    "type": "meta"
  }'
```

Response:
```json
{
  "noteId": "20260222T153045-a1b2c3d4",
  "type": "meta",
  "linkedNotes": [
    {"noteId": "20260110T091200-b2c3d4e5", "similarity": 0.91},
    {"noteId": "20260115T143000-c3d4e5f6", "similarity": 0.85}
  ]
}
```

`type` is `null` in the response for regular notes.

### POST /api/link-pass

Recompute semantic similarity links across all notes. Run after adding many notes in bulk.

```bash
curl -sL -X POST "$SLIPBOX_URL/api/link-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"
```

Response:
```json
{"message": "Link pass complete", "notesProcessed": 42, "totalLinks": 156}
```

### POST /api/cluster-pass

Run k-means clustering on note embeddings. Omit `k` to auto-select cluster count.

```bash
curl -sL -X POST "$SLIPBOX_URL/api/cluster-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"k": 5}'
```

Response:
```json
{
  "message": "Cluster pass complete",
  "noteCount": 42,
  "clusterCount": 5,
  "clusters": [{"id": "cluster-0", "size": 9, "noteIds": ["20260222T153045-a1b2c3d4", ...]}, ...]
}
```

### POST /api/tension-pass

Detect conceptual tensions — notes with contradictory content that cluster near each other.

```bash
curl -sL -X POST "$SLIPBOX_URL/api/tension-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"
```

Response:
```json
{
  "message": "Tension pass complete",
  "noteCount": 42,
  "clusterCount": 5,
  "tensionCount": 8,
  "tensions": [{"id": "tension-0", "noteA": "...", "noteB": "...", "similarity": 0.68, "clusterId": "cluster-0"}, ...]
}
```

### GET /api/theme-data

Returns clusters with full note content and tensions for local LLM agent synthesis. No embeddings — only human-readable data. Use this to read your knowledge graph and synthesize meta-notes per cluster, then POST them back via `/api/add-note`.

Requires a current clusters index (run `cluster-pass` first).

```bash
curl -sL "$SLIPBOX_URL/api/theme-data" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"
```

Response:
```json
{
  "clusters": [
    {
      "id": "cluster-0",
      "noteIds": ["20260222T153045-a1b2c3d4", "20260110T091200-b2c3d4e5"],
      "notes": {
        "20260222T153045-a1b2c3d4": {"title": "Optional title", "body": "Atomic idea content."},
        "20260110T091200-b2c3d4e5": {"body": "Another idea."}
      }
    }
  ],
  "tensions": [
    {"id": "tension-0", "noteA": "20260222T153045-a1b2c3d4", "noteB": "20260110T091200-b2c3d4e5", "similarity": 0.65, "clusterId": "cluster-0"}
  ],
  "clusterCount": 1,
  "noteCount": 2,
  "tensionCount": 1,
  "computedAt": "2026-02-23T01:33:00.000Z"
}
```

If no clusters exist yet, returns `{ "message": "No clusters found. Run cluster-pass first.", "clusters": [], ... }`.

---

## Note Format

Notes in PrivateBox are Markdown files with YAML frontmatter:

```markdown
---
id: 20260222T153045-a1b2c3d4
title: "Optional title"
type: meta
tags: ["tag1", "tag2"]
source: "URL or origin"
created: 2026-02-22T15:30:45.000Z
updated: 2026-02-22T15:30:45.000Z
links:
  - target: 20260110T091200-b2c3d4e5
    similarity: 0.91
  - target: 20260115T143000-c3d4e5f6
    similarity: 0.85
---

Atomic idea content in Markdown.
```

`type` is omitted for regular notes. Valid values: `meta`, `hypothesis`.

**Note ID format**: `YYYYMMDDTHHMMSS-<8hex>` (timestamp + content hash)

**Index files** (in `index/` directory of PrivateBox):
- `index/embeddings.json` — noteId → vector + model + timestamp
- `index/backlinks.json` — noteId → array of linking notes
- `index/clusters.json` — thematic groups of notes
- `index/tensions.json` — pairs of contradictory notes

---

## Reading Notes from PrivateBox

Use the `gh` CLI to read notes without needing direct GitHub API calls.

```bash
# List all notes
gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/notes" \
  --jq '.[].name'

# Read a specific note by ID
gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/notes/20260222T153045-a1b2c3d4.md" \
  --jq '.content' | base64 -d

# Read the backlinks index
gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/index/backlinks.json" \
  --jq '.content' | base64 -d | jq '.'

# Read the clusters index
gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/index/clusters.json" \
  --jq '.content' | base64 -d | jq '.'

# Read the tensions index
gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/index/tensions.json" \
  --jq '.content' | base64 -d | jq '.'
```

### Search notes by content

```bash
# Search PrivateBox notes for a keyword (uses GitHub code search)
gh api "search/code?q=<keyword>+repo:$SLIPBOX_PRIVATEBOX_REPO+path:notes" \
  --jq '.items[].path'

# Or clone locally for fast full-text search
gh repo clone "$SLIPBOX_PRIVATEBOX_REPO" /tmp/privatebox
grep -r "keyword" /tmp/privatebox/notes/ --include="*.md" -l
```

### Find notes by tag

```bash
gh api "search/code?q=tags+keyword+repo:$SLIPBOX_PRIVATEBOX_REPO+path:notes" \
  --jq '.items[].path'
```

---

## Workflows

### Capture an idea

1. Write the atomic idea as a single focused thought.
2. POST to `/api/add-note` with the content.
3. Note the returned `noteId` and `linkedNotes` to see what concepts it connects to.
4. Optionally run `/api/link-pass` afterward if adding many notes in bulk.

### Browse and explore

1. List notes with `gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/notes"`.
2. Read individual notes by ID.
3. Follow `links` in frontmatter to explore connected ideas.
4. Use the clusters index to browse thematic groups.
5. Use the tensions index to identify areas of conceptual conflict worth investigating.

### Synthesize theme meta-notes

After running a full analysis cycle, use `GET /api/theme-data` to read every cluster with its note contents, then write one atomic synthesis note per cluster and POST each back via `/api/add-note`.

```bash
# 1. Fetch theme data
curl -sL "$SLIPBOX_URL/api/theme-data" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"

# 2. For each cluster, synthesize a meta-note and POST it back with type "meta"
curl -sL -X POST "$SLIPBOX_URL/api/add-note" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "## Cluster: Agentic Systems\n\nNotes in this cluster explore...",
    "type": "meta"
  }'
```

The `type: meta` field is written to the note's frontmatter and can be used by future passes to filter AI-generated notes from atomic notes.

### Run a full analysis cycle

After adding a batch of notes or to refresh the graph:

```bash
# Step 1: Recompute links
curl -sL -X POST "$SLIPBOX_URL/api/link-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"

# Step 2: Recluster
curl -sL -X POST "$SLIPBOX_URL/api/cluster-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"

# Step 3: Detect tensions
curl -sL -X POST "$SLIPBOX_URL/api/tension-pass" \
  -H "Authorization: Bearer $SLIPBOX_API_KEY"
```
