# AGENTS.md

Shared rules for every agentic coding tool working in {{PROJECT_NAME}}. Claude Code, Codex, Cursor, and any future agent: this file is mandatory reading before you write anything.

Project pitch: {{PITCH}}

---

## RULE 1: NEVER USE EM-DASHES. EVER.

No em-dashes. Not in chat. Not in code comments. Not in commit messages. Not in PR descriptions. Not in docs. Not in test names. Not anywhere.

Use a period, comma, colon, parentheses, or rewrite the sentence. En-dashes are not substitutes. Plain hyphens are fine for ranges like `pages 10-20` and compound words.

Before every tool call that writes text, scan your output for Unicode codepoints U+2014 (em-dash) and U+2013 (en-dash). Rewrite if either is present.

If porting or quoting text from another source, strip all em-dashes from the ported text before committing.

---

## RULE 2: Read the GDD before making design decisions

The Game Design Document at `docs/gdd/` is the source of truth for what {{PROJECT_NAME}} is. Before proposing architecture, adding features, or changing data schemas, read it. If the GDD and your idea disagree, the GDD wins unless explicitly approved.

Before each implementation slice, read:

- `AGENTS.md`
- `README.md`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/WORKING_AGREEMENT.md`
- `docs/gdd/` (the relevant requirement files)
- `docs/PROGRESS_LOG.md`
- `docs/OPEN_QUESTIONS.md`
- `docs/FOLLOWUPS.md`
- `docs/GDD_COVERAGE.json`
- `docs/PLAYTEST.md` and `docs/FUN_FACTOR_AUDIT.md` when coverage is ≥80% done
- the current task backlog (Dots or equivalent)

### Path-scoped Rules

Three additional rule files live under `.claude/rules/`. They are loaded automatically:

- **Claude Code** loads them based on the `paths:` glob in their frontmatter.
- **Codex** loads them via per-directory `AGENTS.md` symlinks (`docs/AGENTS.md`, `docs/gdd/AGENTS.md`) on its root-down walk.

The three rules:

- `.claude/rules/slice-discipline.md` (paths: source-code globs): no drive-by refactors, no speculative abstractions, refactor-in-slice.
- `.claude/rules/ledger-append-only.md` (paths: the four ledger files): never delete past entries.
- `.claude/rules/gdd-build-log.md` (paths: GDD section files): append a build log entry on every shipped feature.

When you add a source directory (`src/`, `app/`, `lib/`, `components/`, `pages/`, `tests/`, etc.) to this project, run this once to make slice-discipline visible to Codex inside that tree:

```
ln -sf ../.claude/rules/slice-discipline.md <src-dir>/AGENTS.md
```

Claude Code already picks up slice-discipline by path glob without the symlink.

---

## RULE 3: Stack constraints

{{STACK}}

Do not introduce new dependencies in core categories without explicit user approval.

---

## RULE 4: Commit messages and PR descriptions

- Write them as a human would.
- No AI attribution. No `Co-Authored-By: Claude`. No "Generated with Claude Code" footers. No mention of Claude, Anthropic, or AI assistance.
- Keep them short, clean, professional. Focus on the why, not the what.

---

## RULE 5: Autonomous PR loop

Operate continuously until the planned scope is complete. The loop definition lives in `docs/IMPLEMENTATION_PLAN.md`. The process contract lives in `docs/WORKING_AGREEMENT.md`. Follow both on every slice.

For every slice:

1. Read the rule, plan, product, progress, question, followup, coverage, and backlog documents listed in Rule 2.
2. Pick the highest-priority unblocked task from the implementation plan, GDD coverage gaps, followups, and active backlog.
3. Create one branch for one PR-sized slice. Never push directly to `main`.
4. Implement the slice fully using existing project patterns.
5. Add or update tests appropriate to the risk and surface area.
6. Update `docs/PROGRESS_LOG.md`, `docs/GDD_COVERAGE.json`, `docs/OPEN_QUESTIONS.md`, `docs/FOLLOWUPS.md`, and the GDD section when the work changes them.
7. Run the local verification suite. At minimum: dash checks, `git diff --check`, type-check, relevant unit tests, broader checks when warranted.
8. Open a PR.
9. Inspect all PR review comments, including inline and threaded comments from CodeRabbit or other review bots.
10. Fix actionable review comments, reply in-thread when the platform supports it, resolve threads when resolved.
11. After every push to the PR branch, wait for any configured bot reviewer to finish its review pass. The wait is settled only when all required checks are green AND at least 60 seconds have passed since the latest PR branch push or latest bot review activity, whichever is later. Re-inspect reviews and review threads after the settled wait.
12. Wait for CI and the preview deploy to pass.
13. Merge only when green, review feedback is handled, bot review has settled, and the preview deploy is healthy.
14. Pull `main`, verify main CI and production deploy, smoke test production.
15. Close the completed backlog item with the PR number and verification.
16. Immediately start the next slice.

Do not stop at planning. Do not stop after opening a PR. Do not stop after merge. If blocked, log the blocker, update the backlog item, move to the next unblocked slice.

Never mark work complete with failing tests, unresolved actionable review comments, a bot review still in flight after the latest push, red CI, or a broken deploy.

---

## RULE 6: Destructive and shared-system actions

Always confirm with the user before:

- `git push --force`, `git reset --hard`, `rm -rf`, dropping data stores, deleting files or branches.
- Direct pushes to `main` or any protected branch.
- Modifying CI/CD configuration.
- Uploading content to third-party services.

Prior approval for one destructive action is not approval for all of them. Ask each time.

---

## RULE 7: When in doubt, ask. And prefer simple consistent flows.

- When a UX decision could go branchy (different behavior per route, per state, per user), default to one consistent rule across all cases.
- Always explain why you are prompting the user for input.
- If requirements are ambiguous and a reasonable default would be risky, ask. Otherwise choose the simplest consistent path, document the assumption in `docs/OPEN_QUESTIONS.md` with a `Recommended default:`, ship under that default, and keep moving.

---

## RULE 8: Secrets and environment variables

- Never commit `.env`, `.env.local`, or any file containing credentials.
- Never print secret values in logs, chat, or commit messages.
- Document expected env vars in `README.md`. Set them in the deployment dashboard, not in the repo.

---

## RULE 9: Testing expectations

- New pure logic must have unit tests.
- New API routes must have at least one route-handler test plus one smoke test.
- Do not mark a task complete with failing tests.

## RULE 10: Motion and overlay QA

When adding auto-scrolling, credits, animated overlays, portals, or modal UI:

- Verify the visible pixels move, not just that a control says the animation is active.
- Add coverage that measures a changing DOM rect, transform, canvas pixel, or other observable movement over time.
- Do not pause auto-motion on focus by default. Focus can happen on mount and silently disable the feature.
- For modal overlays, set z-index above every fixed interactive app surface and confirm background controls cannot sit above the dialog.
- Preserve normal keyboard activation on focused buttons and form controls.
- Expose toggle state with `aria-pressed` or equivalent accessible state.

---

## RULE 11: One backing store per project

Every Vercel project gets its own dedicated storage resources. Never share an Upstash KV, Postgres, Blob, or any other backing store across projects, even when key-prefix or schema namespacing would prevent collisions.

Why:

- Shared rate limits. One project's runaway loop pressures the other's ceiling.
- Shared billing. Cost attribution becomes impossible.
- Shared rotation. A token leak in one project forces every co-tenant to redeploy.
- Shared blast radius on outages. A misconfigured PUT in one project can fill the other's storage budget.

How:

- Provision storage via the Vercel marketplace UI before wiring code that needs it. The CLI does not expose marketplace provisioning; this is one of the few setup steps that lives in the dashboard.
- After provisioning, attach the resource to exactly one Vercel project. Never use `vercel env add` to copy another project's connection string into this project.
- The first env vars on a fresh project should come from the project's own provisioned store, not from another project's `.env.local`.
- Local dev pulls from the project's own Vercel env via `vercel env pull` (which respects the project link in `.vercel/project.json`).

If you find yourself about to run `vercel env add KV_REST_API_URL` with a value that came from another project's env, stop. Provision a dedicated store first.

---

## Quick pre-commit checklist

1. No em-dashes. Run `grep -rnP '[\x{2014}\x{2013}]' .` (checks for U+2014 em-dash and U+2013 en-dash). Must return nothing.
2. No AI attribution in the commit message.
3. Tests pass locally.
4. GDD is still accurate, or updated.
5. No secrets in the diff.
