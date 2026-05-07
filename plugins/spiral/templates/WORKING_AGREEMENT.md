# Working Agreement

This file defines the process rules for implementation slices on {{PROJECT_NAME}}.

## Branches

- Start every slice from current `main`.
- Branch names should be short and descriptive: `feature/manual-shifting`, `fix/leaderboard-pagination`, `docs/update-coverage`.
- Never push directly to `main`.
- Do not mix unrelated changes in one branch.

## Commits

- Use short human commit messages.
- Do not include AI attribution.
- Keep commits focused. A PR may contain more than one commit when review fixes are added.

## Pull Requests

Every PR must include:

- Summary of user-facing and technical changes.
- Verification commands run.
- GDD, coverage, followup, or open-question updates.
- Any known limitations or blocked checks.

After opening a PR:

- Read flat comments, reviews, and threaded inline comments.
- Treat CodeRabbit or bot review comments as actionable unless clearly incorrect.
- Fix valid comments and push followup commits.
- After every followup push, wait for any configured bot reviewer to finish reviewing that pushed commit.
- The bot review wait is settled only when all required checks are green AND at least 60 seconds have passed since the latest PR branch push or latest bot review activity, whichever is later.
- Re-read flat reviews and threaded inline comments after each push and after the settled wait. Merge only after bot review is finished or the settled wait confirms no fresh bot feedback appeared.
- Reply when the context would help future readers.
- Resolve threads when fixed.

## Verification

Minimum for docs-only changes:

- Dash check (U+2014 em-dash and U+2013 en-dash): `grep -rnP '[\x{2014}\x{2013}]' . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.next` (must return nothing).
- `git diff --check`.
- Project-specific type-check command.

Minimum for code changes:

- Dash checks.
- `git diff --check`.
- Type-check.
- Relevant unit tests.
- Full test suite when shared logic, storage, schemas, or core systems are touched.
- Build command before opening or merging PRs that affect runtime code.
- Smoke test (Playwright or equivalent) when UI routes, API routes, routing, or core flows are touched.

Never mark work complete with failing required verification.

## Merge And Deploy

- Merge only through PRs.
- Wait for CI, preview deploy, and bot review after the latest push.
- After merge, pull `main`.
- Verify main commit status.
- Verify production deploy status.
- Smoke test production with an HTTP check at minimum. Use deeper browser smoke when UI behavior changed.

## Clarifications

Ask only when ambiguity is expensive or risky. When a simple consistent default is available, choose it, record the assumption in `docs/OPEN_QUESTIONS.md` with a `Recommended default:` line, and continue.

## Risk Gates

Always stop for explicit user approval before:

- Force pushes.
- Hard resets.
- Recursive deletes.
- Dropping data store keys or deleting remote data.
- Deleting branches other than branches created for the current completed PR.
- Modifying CI/CD configuration.
- Uploading content to third-party services outside the existing PR and deploy flow.
- Handling secrets.
