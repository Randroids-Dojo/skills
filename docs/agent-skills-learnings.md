# Cross-client skill authoring

This repository treats the open Agent Skills format as the portable core and keeps Codex- or Claude-specific affordances in sidecars and adapters. The guidance below was refreshed on 2026-08-30 against current official documentation.

## Source hierarchy

Use the sources in this order when requirements differ:

1. [Agent Skills specification](https://agentskills.io/specification) for the portable `SKILL.md` contract.
2. [OpenAI: Build skills](https://developers.openai.com/codex/skills) for Codex discovery, metadata, and product behavior.
3. [Claude Code: Extend Claude with skills](https://docs.claude.com/en/docs/claude-code/skills) and [Claude skill authoring best practices](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices) for Claude discovery and authoring behavior.
4. [Claude Code plugins](https://docs.claude.com/en/docs/claude-code/plugins) for marketplace packaging, commands, hooks, and plugin manifests.

Client-specific fields and variables are not assumed portable merely because one client accepts them.

## Portable core

Every skill directory starts with `SKILL.md` and uses specification frontmatter:

```yaml
---
name: example-skill
description: Performs a concrete workflow. Use when the user asks for its specific outcome or names its domain artifacts.
---
```

The shared contract is intentionally narrow:

- `name` is lowercase hyphen-case, no more than 64 characters, and matches the directory.
- `description` is non-empty, no more than 1024 characters, and explains both what the skill does and when it should activate.
- Optional `license`, `compatibility`, `metadata`, and experimental `allowed-tools` fields are used only when their meaning is portable.
- Unsupported client-only keys do not belong in the portable frontmatter. Some clients reject unknown keys instead of ignoring them.

Descriptions are the primary routing surface. Use concrete user language, artifact names, tools, and boundary cases. For nearby skills, say enough to distinguish them: `spiral` owns Markdown ledgers, while `spiral-html` owns semantic HTML ledgers; the `randroid` router should not activate for a request that directly matches `randroid-loop`.

## Progressive disclosure

Skill loading has three practical tiers: the catalog loads `name` and `description`; activation loads the full `SKILL.md`; detailed resources load only when the workflow asks for them. Design around that cost model.

- Keep `SKILL.md` under 500 lines and roughly 5,000 tokens.
- Put essential workflow, safety boundaries, and navigation in the entrypoint.
- Move detailed API notes, rulesets, examples, and mode-specific procedures to `references/`.
- Prefer one-level-deep links from `SKILL.md`; avoid reference chains that make the agent hunt for the actual instruction.
- Use `scripts/` for deterministic or fragile operations and state whether the agent should execute or merely read each script.

Choose the right degree of freedom. Use outcome-oriented prose where context determines the implementation; use a parameterized helper for repeatable mechanics; use an exact ordered procedure for migrations, release steps, or other fragile operations.

## Cross-client paths and adapters

Portable instructions resolve resources from the directory containing `SKILL.md`:

```text
references/api.md
scripts/verify.sh
```

Do not put `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_SKILL_DIR}`, `$ARGUMENTS`, dynamic command injection, source-checkout paths, or client-specific slash-command names in the portable core.

Client extensions live beside the core:

- `agents/openai.yaml` supplies Codex `display_name`, `short_description`, and a default prompt that explicitly mentions `$skill-name`.
- `.claude-plugin/plugin.json` packages the directory for Claude Code.
- `commands/` may provide thin Claude-only user-invoked aliases or distinct command entrypoints.
- `hooks/` may use Claude plugin variables because hooks are a Claude adapter, not part of the portable skill contract.

When one marketplace plugin contains several coherent jobs, give each job its own nested skill. Expose those nested directories directly in `.agents/skills/` and use full-depth discovery when installing through the Skills CLI.

## Safety and completion contracts

Workflow skills should distinguish normal implementation work from external or irreversible actions. A skill may prepare a commit, PR, deployment, publication, reply, or merge, but it must perform that action only when the user authorized that boundary.

Use safe defaults. For example, the Randroid loop defaults to a bounded or until-complete stopping condition and a local commit workflow. Continuous execution, push, PR creation, merge, and publication are opt-in choices.

Completion criteria should name the evidence required: tests, artifact inspection, remote SHA, CI, deployed endpoint, browser state, or another signal appropriate to the workflow. Do not let a prose completion promise override failed or missing verification.

## Evaluation strategy

Schema validation proves that clients can load a skill; it does not prove that a model selects or follows it correctly. Maintain both structural checks and behavioral cases.

For every skill, keep at least:

- two prompts that should trigger it;
- two nearby prompts that should not trigger it;
- representative workflow scenarios with expected artifacts and verification behavior;
- at least one failure or authorization-boundary scenario for mutating workflows.

Run representative cases in fresh sessions on every client and model family the skill supports. Compare selection, files read, tools invoked, safety behavior, and final artifacts. Add a regression case whenever real use reveals a missed trigger, false trigger, skipped reference, or unsafe default.

This repository stores routing fixtures in `tests/trigger-cases.json`. They are coverage inputs, not a claim that a live model eval has run. Live client/model evaluation remains a release activity because selection depends on the current model and host.

## Verification matrix

| Layer | Check |
| --- | --- |
| Portable schema | Pinned official `skills-ref validate` for every discovered `SKILL.md` |
| Portability | Allowed keys, concise entrypoints, no client-only syntax, valid relative links |
| Codex | `agents/openai.yaml` fields, direct `.agents/skills/` exposure, Skills CLI full-depth discovery |
| Claude | Manifest fields, marketplace validation, plugin validation, command frontmatter |
| Executables | `bash -n` for shell helpers and Python byte-compilation in an isolated cache |
| Routing | Positive and negative trigger fixtures for every skill |
| Behavior | Fresh-session task execution on supported Codex and Claude models |

`scripts/validate-skills.sh` automates every deterministic row and runs Claude validation when the CLI is installed. CI runs the same script on pushes to `main` and pull requests.

## Release checklist

- The skill has one coherent job or is an explicit router to focused skills.
- `name` matches its directory and the description contains concrete trigger language.
- The portable core has no client-specific variables, injected arguments, or source-checkout paths.
- Conditional detail is in linked references and deterministic work is in tested scripts.
- Codex metadata and Claude manifests are present and current.
- Positive and negative trigger fixtures cover adjacent skills.
- Structural validation passes locally and in CI.
- Representative workflows have been exercised in fresh Codex and Claude Code sessions before claiming behavioral parity.
