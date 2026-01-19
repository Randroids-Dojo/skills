# skills

A Claude Code plugin marketplace by Randroids Dojo.

## Available Plugins

### randroid

Autonomous development loop with two modes: **Researcher** and **Implementor**.

```
/randroid:loop
```

### godot

Develop, test, build, and deploy Godot 4.x games.

```
/godot:godot
```

## Installation

### Claude Code (Marketplace)

```bash
/plugin marketplace add Randroids-Dojo/skills
/plugin install randroid
/plugin install godot
```

### Codex CLI

Clone and run directly - skills are already symlinked:

```bash
git clone https://github.com/Randroids-Dojo/skills.git
cd skills
codex  # .codex/skills -> plugins/
```

## Repository Structure

```
.
├── .claude-plugin/
│   └── marketplace.json     # Marketplace registry
├── .codex/
│   └── skills -> ../plugins # Symlink for Codex CLI
├── plugins/
│   ├── randroid/            # Autonomous dev loop
│   └── godot/               # Godot game development
├── LICENSE
└── README.md
```

## License

MIT License - see [LICENSE](LICENSE) for details.
