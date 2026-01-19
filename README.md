# randroid-skills

A collection of Claude Code skills by Randroids Dojo.

## What are Skills?

Skills are folders of instructions, scripts, and resources that Claude loads dynamically to improve performance on specialized tasks. Each skill contains a `SKILL.md` file with YAML frontmatter and markdown instructions.

## Repository Structure

```
.
├── .claude/
│   ├── settings.json          # Claude Code settings
│   └── skills -> ../skills    # Symlink to skills directory
├── .claude-plugin/
│   ├── plugin.json            # Plugin metadata for marketplace
│   └── marketplace.json       # Marketplace registry info
├── skills/
│   └── randroid-loop/         # Autonomous development loop skill
│       ├── SKILL.md
│       ├── hooks/
│       ├── scripts/
│       └── state/
├── LICENSE                    # MIT License
└── README.md
```

## Available Skills

### randroid-loop

Autonomous development loop with two modes: **Researcher** and **Implementor**.

- **Research mode** - Explore, investigate, and plan. Creates specs for implementation.
- **Implement mode** - Execute on specs. Write code, tests, and documentation.

Features:
- Self-sustaining agentic workflow
- Dots system for task tracking
- Multiple git workflows (commit, push, PR, PR+merge)
- Fresh or persistent context modes
- Configurable iteration limits (N iterations, infinite, or until complete)

Usage:
```
/randroid              # Interactive mode
/randroid research     # Research mode
/randroid implement    # Implement mode
```

See [skills/randroid-loop/SKILL.md](skills/randroid-loop/SKILL.md) for full documentation.

## Installing Skills

### Option 1: Plugin Marketplace (Recommended)

```bash
/plugin marketplace add Randroids-Dojo/randroid-skills
/plugin install randroid-loop
```

### Option 2: Project-Level

Add to your project so all team members get it via git:

```bash
git clone https://github.com/Randroids-Dojo/randroid-skills.git
mkdir -p your-project/.claude/skills
cp -r randroid-skills/skills/randroid-loop your-project/.claude/skills/
cd your-project
git add .claude/skills
git commit -m "Add randroid-loop skill"
```

### Option 3: Personal Installation

Install for all your projects (just for you):

```bash
git clone https://github.com/Randroids-Dojo/randroid-skills.git
mkdir -p ~/.claude/skills
cp -r randroid-skills/skills/randroid-loop ~/.claude/skills/
```

## Symlink Structure

This repo uses symlinks so that `.claude/skills` points to the top-level `skills/` directory. This allows:
- Clean separation of skills from Claude-specific config
- Easy maintenance of multiple skills
- Compatibility with both Claude Code and Codex workflows

## Resources

- [Claude Code Skills Documentation](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Randroids Dojo GitHub](https://github.com/Randroids-Dojo)

## License

MIT License - see [LICENSE](LICENSE) for details.
