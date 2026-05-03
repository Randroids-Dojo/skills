---
description: Every shipped feature appends a Build log entry to the relevant GDD section.
paths:
  - "docs/gdd/**.md"
---

# GDD build log discipline

This rule loads when editing GDD section files. Each section is the canonical spec for one requirement. Build logs grow with the code so the next slice can read what landed without rediscovering it.

## What to do

Every GDD section file follows this shape:

```markdown
# <Requirement title>

**Status:** not_started | partial | done

<Spec text: what the feature is, what it does, what it does NOT do.>

### Build log

- <YYYY-MM-DD>: <one-line summary of what shipped>. Files: `src/...`, `tests/...`. PR #N.
- <Earlier entry>
- <Earliest entry, kept verbatim>
```

When a slice touches the requirement covered by this file:

1. Update the `Status:` line if the status changed (`not_started` → `partial`, `partial` → `done`).
2. Append a new entry to the top of the `### Build log` section.
3. The build log entry MUST name the key files added or modified.
4. The build log entry MUST link the PR number once known.
5. Do NOT rewrite past build log entries, even if the implementation has since changed. Add a new entry instead.

## What to avoid

- Updating the spec text to match what shipped (the spec is the *intent*; the build log is *what landed*).
- Removing the Status line.
- Removing or rewriting past build log entries.
- Splitting one feature across multiple GDD section files (the granularity of `docs/GDD_COVERAGE.json` rows is the right unit).

## Why this matters

Build logs are how the next slice starts cheap. A new slice working in a touched area reads the most recent build log entries to understand what files own the behavior, what defaults were chosen, and what assumptions are still live. Without build logs, every slice pays the rediscovery tax. With them, the spiral compounds.
