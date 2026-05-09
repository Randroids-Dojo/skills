# Dependency Ledger

Watched dependencies for {{PROJECT_NAME}}. The agent runs the **Dependency Upgrade Gate** (see `docs/IMPLEMENTATION_PLAN.md`) at two trigger points:

1. **After every push to `main`** (after step 16 of the loop: pulled main, verified production), before picking the next slice.
2. **Before opening a new PR** (just before step 10 of the loop), so the new branch starts from a fresh-deps baseline.

If a watched dep has a newer release than the version pinned in this ledger, the upgrade is the next slice (unless step 1 of slice selection in `IMPLEMENTATION_PLAN.md` takes over: red CI, broken `main`, or a P0 incident).

---

## Watch list

Add one entry per watched dep. Remove an entry when the project no longer depends on it. Update the **Currently pinned** line in the same PR that bumps the version.

Per-dep entry shape:

- **Name**: package or repo identifier.
- **Why watched**: one sentence explaining why this dep is on the ledger (internally maintained, framework major, security-sensitive, prior breakage).
- **Source**: where to look for the latest version (npm registry URL, GitHub releases page, git tags).
- **Pin format**: how the project pins (npm semver, github tag, git ref, file path).
- **Currently pinned**: the version on `main` right now. Update on every successful upgrade.
- **Detect-new**: command or URL the agent uses to discover new releases.
- **Migration notes**: per-dep gotchas the agent should expect during upgrades.

### Example: `@randroids-dojo/vibekit`

- **Name**: `@randroids-dojo/vibekit`
- **Why watched**: internally maintained, pre-1.0, breaking changes possible on every release.
- **Source**: https://github.com/Randroids-Dojo/VibeKit/releases
- **Pin format**: `github:Randroids-Dojo/VibeKit#vX.Y.Z` (tag-pinned)
- **Currently pinned**: `v0.1.0`
- **Detect-new**: `gh api repos/Randroids-Dojo/VibeKit/releases/latest --jq .tag_name`
- **Bootstrap / cookbook**: the `vibekit` skill supplies `/vibekit add` (pins the dep, prints this ledger entry) and `/vibekit cookbook` (per-module wire-up patterns: joystick, editor-history, confetti, rng, math, storage, server kv/sign/rate-limit). Optional companion to spiral: a project that prefers a different shared library swaps the skill but keeps this ledger procedure.
- **Migration notes**:
  - The kit is pre-1.0; any release may break callers (release-please uses `bump-patch-for-minor-pre-major`, so feat-level changes still ship as patches and may carry signature changes).
  - Read the kit's `CHANGELOG.md` between the pinned and target tag.
  - Type errors usually surface in `pnpm type-check`; runtime regressions in unit tests + the targeted Playwright smoke for any UI that touches the kit.
  - For wire-up patterns (especially when a kit module's signature shifts), consult `/vibekit cookbook <module>` rather than re-reading the kit's full README.

---

## Upgrade procedure

Run this once per dep that has a newer release. Each upgrade is one PR.

### 0. Skip rule

If a higher-priority slice is in flight (red CI, P0 incident, broken `main`, broken deploy), defer the upgrade and add a backlog item for it. Do not mix dep-bumps into unrelated slices.

### 1. Detect the new version

Run the dep's **Detect-new** command. Compare to the **Currently pinned** value in this ledger. If equal, the gate passes; pick a regular slice. If newer, continue.

### 2. Read the upstream CHANGELOG

Open the dep's CHANGELOG (or release notes) between the pinned and target version. List every breaking change, deprecation, and behavior shift. The agent must understand what migrations the bump implies BEFORE editing project code.

### 3. Branch

Branch name: `chore/deps/<dep-short-name>-<from>-to-<to>` (example: `chore/deps/vibekit-0.1.0-to-0.1.4`). One dep per branch.

### 4. Bump the pin

Update `package.json` (or the project's equivalent) with the new version. Update the **Currently pinned** line in this ledger to match. Run the project's lockfile-refresh command (`pnpm install`, `npm install`, `cargo update -p <name>`, etc.).

### 5. Type-check

Run the project's type-check command. If it fails:

- If the failures look like trivial signature shifts the agent can fix in this PR, do so. Each fix is its own commit (or two: type-error fix + lockfile/pin bump). Re-run type-check until it passes.
- If the failures point to a deeper migration (rename of a public API, dropped feature, restructured option object) that does NOT fit in one PR, **abort**:
  - Revert the pin change.
  - Open an `F-NNN` followup in `docs/FOLLOWUPS.md` describing the migration work.
  - Add a Dot for the migration work.
  - Resume the regular loop without the bump.

The decision rule: a single dep upgrade PR may contain mechanical migrations (renames, option shape changes), but it must not contain new feature work or unrelated refactors. If the migration would force unrelated changes, split.

### 6. Run the test suite

Project-appropriate command. Same decision rule as type-check: trivial fixes belong in the bump PR, deep migrations go in their own PR with the bump deferred.

### 7. Build

Run the production build command before opening the PR if the dep affects runtime code (any client-facing code, server routes, middleware).

### 8. Smoke test

Run the project's Playwright (or equivalent) smoke when the dep affects UI / API routes / core gameplay flows. Specifically: the smoke for any feature that imports from the upgraded dep.

### 9. Open the PR

- **Title**: `chore(deps): bump <dep> from <from> to <to>` (Conventional Commit `chore(deps):` so any release-please-driven downstream knows this is non-releasable).
- **Body** must include:
  - Direct link to the upstream CHANGELOG between the two versions.
  - List of breaking changes that applied to this project.
  - Migrations applied, one paragraph each.
  - Verification commands run (dash check, type-check, test, build, smoke).
  - The new **Currently pinned** value, mirroring the line in this ledger.

### 10. Merge through the standard flow

CI green, bot review settled, preview deploy green, then merge. Pull `main`. Verify production deploy. Smoke test production for the touched flows.

### 11. Close out

Update the **Currently pinned** line if the merge changed it (the bump PR should already do this; double-check). Append a `PROGRESS_LOG.md` entry. If the bump revealed deferred migration work, leave the `F-NNN` followups open.

---

## When to add a dep to this ledger

Add when:

- The dep is **internally maintained** (sibling repo, in-house package). Internal deps ship breaking changes the project actively needs to adopt.
- The dep is **critical infrastructure**: framework major (Next.js, React major), runtime major (Node, Deno, Bun), security-sensitive lib (auth, crypto, signed-token).
- A dep has **bitten this project before** with an unexpected breakage at upgrade time.

Do **not** add commodity deps whose major-version cadence is slow (one upgrade per year or longer) and whose minor versions are rarely breaking. Those go through standard semver-range / lockfile churn (Renovate / Dependabot). The ledger is for deps the agent must consciously think about every time `main` moves.
