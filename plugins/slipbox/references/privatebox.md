# PrivateBox read access

Use authenticated `gh api` calls against `$SLIPBOX_PRIVATEBOX_REPO`. This path is read-only; all note creation goes through SlipBox.

## List and read notes

```bash
gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/notes" --jq '.[].name'

gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/notes/<note-id>.md" \
  --jq '.content' | base64 -d
```

## Read graph indexes

```bash
gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/index/backlinks.json" \
  --jq '.content' | base64 -d | jq '.'

gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/index/clusters.json" \
  --jq '.content' | base64 -d | jq '.'

gh api "repos/$SLIPBOX_PRIVATEBOX_REPO/contents/index/tensions.json" \
  --jq '.content' | base64 -d | jq '.'
```

## Search

```bash
gh api "search/code?q=<encoded-query>+repo:$SLIPBOX_PRIVATEBOX_REPO+path:notes" \
  --jq '.items[].path'
```

Read the matched notes before summarizing them. GitHub code search finds lexical matches; it is not a semantic result. Use SlipBox links, clusters, and tensions for semantic relationships.

## Note model

Notes are Markdown with YAML frontmatter. Regular note IDs use `YYYYMMDDTHHMMSS-<8hex>`. Useful fields include `id`, optional `title`, optional `type`, tags, source, timestamps, and similarity links. Indexes under `index/` are derived graph state rather than the primary note content.
