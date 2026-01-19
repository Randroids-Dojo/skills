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

### Codex CLI (Manual)

Clone and copy to your project's skills directory:

```bash
git clone https://github.com/Randroids-Dojo/skills.git
cp -r skills/plugins/randroid your-project/skills/
```

Then symlink for both Claude and Codex:

```bash
mkdir -p .claude .codex
ln -s ../skills .claude/skills
ln -s ../skills .codex/skills
```

## Repository Structure

```
.
├── .claude-plugin/
│   └── marketplace.json     # Marketplace registry
├── plugins/
│   ├── randroid/            # Autonomous dev loop
│   └── godot/               # Godot game development
├── LICENSE
└── README.md
```

## License

MIT License - see [LICENSE](LICENSE) for details.
