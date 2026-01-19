# skills

A collection of Claude Code plugins by Randroids Dojo.

## Repository Structure

```
.
├── .claude/
│   ├── settings.json
│   └── skills -> ../.skills
├── .codex/
│   └── skills -> ../.skills
├── .skills -> plugins              # Shared symlink for both Claude and Codex
├── .claude-plugin/
│   └── marketplace.json            # Marketplace registry
├── plugins/
│   ├── randroid-loop/              # Autonomous development loop
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   │   ├── randroid-loop.md
│   │   │   └── randroid.md
│   │   ├── hooks/
│   │   ├── scripts/
│   │   └── SKILL.md
│   └── godot/                      # Godot game development
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       │   └── godot.md
│       ├── references/
│       ├── scripts/
│       └── SKILL.md
├── LICENSE
└── README.md
```

## Available Plugins

### randroid-loop

Autonomous development loop with two modes: **Researcher** and **Implementor**.

- **Research mode** - Explore, investigate, and plan
- **Implement mode** - Execute on specs, write code and tests

Features: dots system for task tracking, multiple git workflows, configurable iterations.

```
/randroid-loop
```

### godot

Develop, test, build, and deploy Godot 4.x games.

- **GdUnit4** - Unit testing framework for GDScript
- **PlayGodot** - Game automation (like Playwright for games)
- **Exports** - Web/desktop builds
- **CI/CD** - GitHub Actions workflows
- **Deployment** - Vercel, GitHub Pages, itch.io

```
/godot
```

## Installation

### From Marketplace

```bash
/plugin marketplace add Randroids-Dojo/skills
/plugin install randroid-loop
/plugin install godot
```

### Project-Level

```bash
git clone https://github.com/Randroids-Dojo/skills.git
cp -r skills/plugins/randroid-loop your-project/.claude/skills/
```

### Personal Installation

```bash
git clone https://github.com/Randroids-Dojo/skills.git
cp -r skills/plugins/randroid-loop ~/.claude/skills/
```

## Symlink Structure

This repo uses a shared `.skills` directory that both `.claude/skills` and `.codex/skills` symlink to. This allows the same plugins to work with both Claude Code and Codex.

## Resources

- [Claude Code Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Randroids Dojo GitHub](https://github.com/Randroids-Dojo)

## License

MIT License - see [LICENSE](LICENSE) for details.
