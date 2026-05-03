# GDD: {{PROJECT_NAME}}

> **Anti-Flatline guardrail.** This GDD is a directory tree, not a single file. Each requirement is its own file. Coverage rows in `docs/GDD_COVERAGE.json` are written at requirement granularity, NOT chapter granularity. A multi-week project should produce on the order of 100+ rows, not 11. If you only have a dozen rows, your coverage is too coarse and the loop will self-terminate before the product is good.

Project pitch: {{PITCH}}

## How to use this directory

- Each `docs/gdd/<n>-<title>.md` file is one requirement or one tightly-scoped section.
- Each file starts with a `Status:` line: `Status: not_started` | `Status: partial` | `Status: done`
- Once a file's work ships, append a `### Build log` section with what landed, the key files, and any non-obvious decisions. Build logs grow with the code.
- Keep file names short and stable. The file path is referenced from `GDD_COVERAGE.json`.

## Conventions

- One requirement, one file, one row in the coverage ledger.
- File names: `<NN>-<kebab-title>.md`, e.g. `05-vehicle-physics.md`, `12-leaderboard-submit.md`.
- Cross-references between sections use relative links.
- The em-dash ban applies here.

## Index

Add entries below as sections are drafted. Each entry: filename + one-line description. This index is the human-readable map; the machine-readable map is `docs/GDD_COVERAGE.json`.

- `01-vision-and-pillars.md`: what {{PROJECT_NAME}} is and what it is not.
- `<draft your first requirement file here>`

## Out of scope

A dedicated `docs/gdd/99-out-of-scope.md` file is the explicit fence. List anything that has been considered and rejected for v1, with a one-line rationale. The loop must not scope-creep into items listed there without approval.
