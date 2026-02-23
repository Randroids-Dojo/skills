# SlipBox

Interact with the SlipBox semantic knowledge engine and read notes from PrivateBox.

**Service**: `http://localhost:3000` (run `npm run dev` in the SlipBox project root)
**Notes repo**: https://github.com/Randroids-Dojo/PrivateBox
**Auth**: `Authorization: Bearer $SLIPBOX_API_KEY`

## Setup Check

Before any API calls, verify env vars are set:

```bash
echo "SLIPBOX_API_KEY: ${SLIPBOX_API_KEY:-(MISSING)}"
echo "GITHUB_TOKEN:    ${GITHUB_TOKEN:-(MISSING)}"
echo "OPENAI_API_KEY:  ${OPENAI_API_KEY:-(MISSING)}"
```

If any show `(MISSING)`, stop and tell the user. Add missing vars to `~/.zshrc` or `.env.local` in the SlipBox project. Do not proceed until `SLIPBOX_API_KEY` is set.

## Quick Reference

```bash
# Health check
curl -s http://localhost:3000/api/health

# Add a note
curl -s -X POST http://localhost:3000/api/add-note \
  -H "Authorization: Bearer $SLIPBOX_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content": "Atomic idea."}'

# Read a note from PrivateBox
gh api repos/Randroids-Dojo/PrivateBox/contents/notes/<noteId>.md \
  --jq '.content' | base64 -d

# List all notes
gh api repos/Randroids-Dojo/PrivateBox/contents/notes --jq '.[].name'

# Run full analysis (link → cluster → tension)
curl -s -X POST http://localhost:3000/api/link-pass -H "Authorization: Bearer $SLIPBOX_API_KEY"
curl -s -X POST http://localhost:3000/api/cluster-pass -H "Authorization: Bearer $SLIPBOX_API_KEY"
curl -s -X POST http://localhost:3000/api/tension-pass -H "Authorization: Bearer $SLIPBOX_API_KEY"
```

For full documentation, read `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.
