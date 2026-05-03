---
description: Ledger files are append-only. Never delete or rewrite past entries.
paths:
  - "docs/PROGRESS_LOG.md"
  - "docs/OPEN_QUESTIONS.md"
  - "docs/FOLLOWUPS.md"
  - "docs/GDD_COVERAGE.json"
---

# Ledger append-only discipline

This rule loads when editing the four ledger files. They are the externalized memory of the project. The agent does not remember; the project remembers itself. That contract breaks if past entries are rewritten.

## What to do

### `docs/PROGRESS_LOG.md`

- Add new entries at the TOP of the relevant section. Newest first.
- Never edit a past entry. If a past entry is wrong, add a new entry that corrects it.
- Every implementation slice gets its own entry. Format: Branch / PR / Changed / Verification / Assumptions / GDD coverage / Followups.

### `docs/OPEN_QUESTIONS.md`

- New questions get the next monotonic `Q-NNN` ID.
- When a question resolves, leave the entry in place. Update `Status:` to `resolved` and fill in `Resolution:`. Move the entry under the `## Resolved` section.
- Never delete a past question, even if it was wrong. Add a new question that supersedes it and reference the old ID in the `Resolution:` line.

### `docs/FOLLOWUPS.md`

- New followups get the next monotonic `F-NNN` ID.
- When a followup ships, leave the entry in place and append a `- Resolved: PR #N` line. Move under a `## Resolved` section if you have one.
- Never delete a past followup, even if it became irrelevant. Add a `- Resolved: N/A (dropped because <reason>)` line and move it.

### `docs/GDD_COVERAGE.json`

- Update `status` and append to `implementationRefs` / `testRefs` / `followupRefs` as work ships.
- Do not delete rows whose requirements got cut. Set `status: "out_of_scope"` and add a note.
- The `id` of a row is permanent. Do not renumber.

## Why this matters

A future slice cannot trust ledgers that get retroactively edited. The audit trail is the contract. Treating these files as a database (overwrite + delete) destroys the institutional memory that lets the spiral run for weeks.
