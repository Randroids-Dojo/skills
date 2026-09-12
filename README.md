# Randroids Dojo skills

Portable Agent Skills for Codex, Claude Code, and other compatible clients. Each workflow has one standards-compliant `SKILL.md` core, optional resources and scripts, Codex UI metadata, and Claude plugin packaging.

## Skills

| Skill | Purpose |
| --- | --- |
| `blender-production` | Editable Blender assets with visual, assembly, export, and render verification |
| `decision` | Guided decisions with concise tradeoffs and recommendations |
| `godot` | Godot 4.x development, testing, automation, export, and deployment |
| `randroid` | Catalog and router for the focused Randroid workflows |
| `randroid-loop` | Bounded research or implementation loops with durable task state |
| `randroid-address-pr-comments` | Resolve current PR feedback, verify fixes, and reply with evidence |
| `randroid-vibereview` | Browser-game playtests with VibeReview evidence and ledgers |
| `randroid-clean-slop` | Remove generic visual patterns in interfaces, games, and 3D assets using actual captures |
| `randroid-game-feel` | Improve the chosen gameplay interaction, responsiveness, feedback, and play evidence |
| `slipbox` | SlipBox capture, search, graph browsing, and semantic passes |
| `spiral` | Initialize or audit a Markdown structural-discipline scaffold |
| `spiral-html` | Initialize or audit an HTML-first Spiral scaffold |
| `task-tracking-dots` | Durable Markdown-backed work tracking with Dots |
| `task-tracking-dots-html` | Durable HTML-backed work tracking with the Dots fork |
| `unreal` | Unreal Engine 5.x automation and end-to-end verification |
| `vibekit` | Install and integrate tag-pinned VibeKit modules |
| `youtube-title-thumbnail-packaging` | Truthful double-barrel YouTube title-and-thumbnail pairs |

## Install for Codex and other Agent Skills clients

Install one skill globally through the universal Skills CLI:

```bash
npx skills add Randroids-Dojo/skills --skill godot -y -g
```

The focused Randroid skills are nested in the Claude plugin, so include full-depth discovery:

```bash
npx skills add Randroids-Dojo/skills --skill randroid-loop --full-depth -y -g
npx skills add Randroids-Dojo/skills --skill randroid-address-pr-comments --full-depth -y -g
npx skills add Randroids-Dojo/skills --skill randroid-game-feel --full-depth -y -g
```

Always use `npx skills add ... -g` again to reinstall an updated skill. Do not edit installed copies under `~/.agents/skills/` or symlinks under `~/.claude/skills/`.

Codex discovers global skills from `~/.agents/skills/`. Explicit invocation uses the portable skill name, for example:

```text
$randroid-loop run five implementation iterations and commit locally
$godot add and verify this GdUnit4 test
```

## Install for Claude Code

Add the marketplace and install the desired plugin:

```text
/plugin marketplace add Randroids-Dojo/skills
/plugin install godot
/plugin install randroid
```

Claude Code namespaces plugin skills. The Randroid plugin exposes the focused skills directly:

```text
/randroid:randroid-loop
/randroid:randroid-address-pr-comments
/randroid:randroid-vibereview
/randroid:randroid-clean-slop
/randroid:randroid-game-feel
```

The previous `/randroid:loop`, `/randroid:address-pr-comments`, `/randroid:vibereview`, and `/randroid:clean-slop` commands remain as user-invoked compatibility aliases.

## Authoring architecture

```text
plugins/<plugin>/
├── SKILL.md                 # Portable core: specification frontmatter + workflow
├── agents/openai.yaml       # Codex display metadata and default prompt
├── references/              # Detailed guidance loaded only when needed
├── scripts/                 # Deterministic helpers
├── .claude-plugin/
│   └── plugin.json          # Claude plugin package metadata
└── commands/                # Optional Claude-only compatibility adapters
```

The Randroid plugin contains five focused skills under `plugins/randroid/skills/`. This keeps each activation narrow while allowing one Claude marketplace install. The repository-local `.agents/skills/` directory exposes every portable skill as a direct symlink for Codex development; `.codex/skills` points to that universal catalog.

Portable `SKILL.md` files follow these rules:

- Use only Agent Skills specification frontmatter fields. `name` and `description` are required; optional fields are used only when they add portable information.
- Put both capability and trigger conditions in the description.
- Resolve scripts and references relative to the skill directory.
- Keep platform variables, slash-command arguments, and plugin-root paths in client adapters, not in the portable core.
- Keep the entrypoint concise and route detailed or conditional material to one-level-deep references.
- Require explicit authorization for push, PR, merge, deployment, publication, and other external mutations.

## Validation

Run the same checks used by CI:

```bash
./scripts/validate-skills.sh
```

The suite checks portable frontmatter, name-directory alignment, trigger descriptions, entrypoint budgets, relative links, Codex metadata, Claude manifests, positive and negative trigger fixtures, shell/Python/JavaScript syntax, game-probe report behavior, the official `skills-ref` validator, Skills CLI discovery, and Claude plugin validation when the `claude` CLI is installed. CI also tests the native probe's report logic, C# compilation, and bitmap comparisons with Windows PowerShell 5.1. These checks do not launch a game or certify subjective quality.

The Blender skill is adapted from [per-simmons/blender-production](https://github.com/per-simmons/blender-production) under its preserved MIT license. See its [package README](plugins/blender-production/README.md) for the upstream revision and local additions.

For fast offline structural checks:

```bash
VALIDATE_EXTERNAL=0 ./scripts/validate-skills.sh
```

See [Cross-client skill authoring](docs/agent-skills-learnings.md) for the research-backed design rules and verification matrix.

## License

MIT
