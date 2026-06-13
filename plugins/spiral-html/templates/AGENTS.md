# AGENTS.md

Shared rules for every agentic coding tool working in {{PROJECT_NAME}}. Claude Code, Codex, Cursor, and any future agent: this file is mandatory reading before you write anything.

This repo uses the HTML-first variant of the spiral scaffold. The ledgers and contracts under `docs/` are `.html` files. This file (`AGENTS.md`) and `CLAUDE.md` stay as Markdown so Codex's root-down walk and Claude Code's project-memory import keep working.

Task tracking uses the HTML-backed Dots fork: the `dot-html` CLI (skill `task-tracking-dots-html`), which stores work items as `.html` files under `.dots/`. Do NOT use the Markdown `dot` CLI (skill `task-tracking-dots`) on this project, even if it is also installed. If only the Markdown variant is present, install the HTML fork first (`task-tracking-dots-html` ships an installer); do not silently fall back to Markdown dots.

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
- `docs/IMPLEMENTATION_PLAN.html`
- `docs/WORKING_AGREEMENT.html`
- `docs/gdd/` (the relevant requirement files)
- `docs/PROGRESS_LOG.html`
- `docs/OPEN_QUESTIONS.html`
- `docs/FOLLOWUPS.html`
- `docs/GDD_COVERAGE.json`
- `docs/DEPENDENCY_LEDGER.html` (and run the Dependency Upgrade Gate from `docs/IMPLEMENTATION_PLAN.html`)
- `docs/PLAYTEST.html` and `docs/FUN_FACTOR_AUDIT.html` when coverage is >=80% done
- the current task backlog (HTML Dots via `dot-html`, stored under `.dots/`)

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

Operate continuously until the planned scope is complete. The loop definition lives in `docs/IMPLEMENTATION_PLAN.html`. The process contract lives in `docs/WORKING_AGREEMENT.html`. Follow both on every slice.

For every slice:

1. Read the rule, plan, product, progress, question, followup, coverage, dependency-ledger, and backlog documents listed in Rule 2.
2. Run the Dependency Upgrade Gate (see `docs/IMPLEMENTATION_PLAN.html`). If a watched dep is out of date, the upgrade IS the next slice unless red CI takes over.
3. Pick the highest-priority unblocked task from the implementation plan, dep ledger, GDD coverage gaps, followups, and active backlog.
4. Create one branch for one PR-sized slice. Never push directly to `main`.
5. Implement the slice fully using existing project patterns.
6. Add or update tests appropriate to the risk and surface area.
7. Update `docs/PROGRESS_LOG.html`, `docs/GDD_COVERAGE.json`, `docs/OPEN_QUESTIONS.html`, `docs/FOLLOWUPS.html`, `docs/DEPENDENCY_LEDGER.html`, and the GDD section when the work changes them.
8. Run the local verification suite. At minimum: dash checks, `git diff --check`, type-check, relevant unit tests, broader checks when warranted.
9. Re-run the Dependency Upgrade Gate before opening the PR. If a watched release landed while the slice was in flight, defer the bump to its own PR (do not bundle).
10. Open a PR.
11. Inspect all PR review comments, including inline and threaded comments from CodeRabbit or other review bots.
12. Fix actionable review comments, reply in-thread when the platform supports it, resolve threads when resolved.
13. After every push to the PR branch, wait for any configured bot reviewer to finish its review pass. The wait is settled only when all required checks are green AND at least 60 seconds have passed since the latest PR branch push or latest bot review activity, whichever is later. Re-inspect reviews and review threads after the settled wait.
14. Wait for CI and the preview deploy to pass.
15. Merge only when green, review feedback is handled, bot review has settled, and the preview deploy is healthy.
16. Pull `main`, verify main CI and production deploy, smoke test production.
17. Close the completed backlog item with the PR number and verification.
18. Immediately start the next slice.

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
- If requirements are ambiguous and a reasonable default would be risky, ask. Otherwise choose the simplest consistent path, document the assumption in `docs/OPEN_QUESTIONS.html` with a `Recommended default:`, ship under that default, and keep moving.

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

## RULE 12: 3D scene depth hygiene (z-fighting)

Applies to any 3D scene (three.js / WebGL / WebGPU / R3F / Babylon / Unreal / Godot). Two opaque surfaces that share a plane, or that cross at a shallow grazing angle, cannot be ordered reliably by the depth buffer. They shimmer along the seam. This is z-fighting, and it is the single most common "looks broken" artifact in vibe-coded 3D.

The trap that makes it slip through review:

- **z-fighting is invisible in a still frame.** When the camera is parked, the depth ties resolve to one stable answer and the seam looks clean. It only flickers while the camera (or the geometry) moves, because sub-pixel coverage at the seam flips frame to frame. A static screenshot is not evidence; agents repeatedly "verify" a fix with one screenshot and ship the bug.

Never create these:

- **Coplanar faces.** A decal/sign/billboard face placed at exactly the depth of the panel behind it; a trim strip whose top sits exactly on the surface it trims; two walls at the same coordinate. Any two faces at the same depth fight.
- **Buried accent boxes.** A bezel, marquee, header, plinth, or badge modeled as a small box that pokes *into* a larger body box. Where the small box's face is nearly parallel to and nearly the same depth as the body's face (a few degrees off), it fights; where it grazes a perpendicular face at a shallow angle, the intersection line shimmers.
- **A near plane too small for the scene.** A camera `near` of `0.01` across a 50m+ scene throws away depth precision everywhere. Depth resolution scales with `d² / (near · (far − near))`, so a gap that is safe at 1m fights at 40m.

Do this instead:

- Mount accent geometry **clearly proud of** the parent surface (a few cm in front), or **fully enclosed inside** it (no emergent coplanar face), never flush and never grazing. "Flush" is the bug, not the goal.
- Separate intentionally-stacked planes (billboard over frame, label over wall) by a real epsilon **sized to the scene and camera**, not a token `0.001`. At hall/room scale with a 90m far plane, ~2-3cm clears the noise floor; pick the gap from the actual viewing distance, do not guess small.
- Raise the camera `near` plane to the closest the player can actually get (often 0.1, not 0.01). Halving depth waste is free precision.
- Reach for `polygonOffset` / depth bias only when geometry truly must stay coplanar (decals you cannot lift). It masks, it does not cure; prefer separation.

Verify in **motion**, per RULE 10: pan or orbit the camera past every seam and watch it, or diff consecutive frames *while the camera moves slightly*. A frozen-camera frame diff will show nothing even when the scene is full of z-fighting. Verify from **several angles too**, not just head-on: a coplanar *side* seam (an accent box modeled at the parent's full width, so its side faces share the parent's side plane) is edge-on and invisible from the front, and only shows obliquely, exactly where a passer-by sees it.

---

## Quick pre-commit checklist

1. No em-dashes. Run `grep -rnP '[\x{2014}\x{2013}]' .` (checks for U+2014 em-dash and U+2013 en-dash). Must return nothing.
2. No AI attribution in the commit message.
3. Tests pass locally.
4. GDD is still accurate, or updated.
5. No secrets in the diff.
6. For 3D changes (RULE 12): no new coplanar/flush/grazing surfaces, and any depth fix was verified with the camera in motion, not a single still frame.
