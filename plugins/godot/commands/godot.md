# Godot Development

Develop, test, build, and deploy Godot 4.x games.

## Quick Reference

```bash
# GdUnit4 - Unit testing framework (GDScript, runs inside Godot)
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests

# PlayGodot - Game automation framework (Python, like Playwright for games)
export GODOT_PATH=/path/to/godot-automation-fork
pytest tests/ -v

# Export web build
godot --headless --export-release "Web" ./build/index.html

# Deploy to Vercel
vercel deploy ./build --prod
```

## Testing Overview

| | GdUnit4 | PlayGodot |
|---|---------|-----------|
| Type | Unit testing | Game automation |
| Language | GDScript | Python |
| Runs | Inside Godot | External (like Playwright) |
| Requires | Addon | Custom Godot fork |
| Best for | Unit/component tests | E2E/integration tests |

## Available Tools

For detailed documentation, read the full SKILL.md at `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.

Key capabilities:
- **GdUnit4 Testing** - Unit tests, scene tests, input simulation
- **PlayGodot Automation** - E2E testing like Playwright for games
- **Web/Desktop Exports** - Build and export games
- **CI/CD Pipelines** - GitHub Actions workflows
- **Deployment** - Vercel, GitHub Pages, itch.io
- **Python Helper Scripts** - run_tests.py, parse_results.py, export_build.py
