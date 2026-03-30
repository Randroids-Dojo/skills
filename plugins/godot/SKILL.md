---
name: godot
description: "Develop, test, build, and deploy Godot 4.x games. Use when working with Godot Engine, GDScript, GdUnit4 testing, PlayGodot automation, or exporting games to web/desktop. Covers CI/CD pipelines and deployment to Vercel/GitHub Pages/itch.io."
---

# Godot Skill

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

---

## Testing Overview

| | GdUnit4 | PlayGodot |
|---|---------|-----------|
| Type | Unit testing | Game automation |
| Language | GDScript | Python |
| Runs | Inside Godot | External (like Playwright) |
| Requires | Addon | Custom Godot fork |
| Best for | Unit/component tests | E2E/integration tests |

---

## GdUnit4 (GDScript Tests)

GdUnit4 runs tests written in GDScript directly inside Godot.

### Project Structure

```
project/
├── addons/gdUnit4/          # GdUnit4 addon
├── test/                    # Test directory
│   ├── game_test.gd
│   └── player_test.gd
└── scripts/
    └── game.gd
```

### Setup

```bash
# Install GdUnit4
git clone --depth 1 https://github.com/MikeSchulze/gdUnit4.git addons/gdUnit4

# Enable plugin in Project Settings → Plugins
```

### Basic Unit Test

```gdscript
# test/game_test.gd
extends GdUnitTestSuite

var game: Node

func before_test() -> void:
    game = auto_free(load("res://scripts/game.gd").new())

func test_initial_state() -> void:
    assert_that(game.is_game_active()).is_true()
    assert_that(game.get_current_player()).is_equal("X")

func test_make_move() -> void:
    var success := game.make_move(4)
    assert_that(success).is_true()
    assert_that(game.get_board_state()[4]).is_equal("X")
```

### Scene Test with Input Simulation

```gdscript
# test/game_scene_test.gd
extends GdUnitTestSuite

var runner: GdUnitSceneRunner

func before_test() -> void:
    runner = scene_runner("res://scenes/main.tscn")

func after_test() -> void:
    runner.free()

func test_click_cell() -> void:
    await runner.await_idle_frame()

    var cell = runner.find_child("Cell4")
    runner.set_mouse_position(cell.global_position + cell.size / 2)
    runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
    await runner.await_input_processed()

    var game = runner.scene()
    assert_that(game.get_board_state()[4]).is_equal("X")

func test_keyboard_restart() -> void:
    runner.simulate_key_pressed(KEY_R)
    await runner.await_input_processed()
    assert_that(runner.scene().is_game_active()).is_true()
```

### Running GdUnit4 Tests

```bash
# All tests
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests

# Specific test file
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  --run-tests --add res://test/my_test.gd

# Generate reports for CI
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  --run-tests --report-directory ./reports
```

For the full GdUnit4 assertions API, see `references/assertions.md`. For Scene Runner input simulation, see `references/scene-runner.md`.

---

## PlayGodot (Game Automation)

PlayGodot is a game automation framework for Godot - like Playwright, but for games. It enables E2E testing, automated gameplay, and external control of Godot games via the native RemoteDebugger protocol.

**Requirements:**
- Custom Godot fork: [Randroids-Dojo/godot](https://github.com/Randroids-Dojo/godot) (automation branch)
- [PlayGodot](https://github.com/Randroids-Dojo/PlayGodot) Python library

### Setup

```bash
# Install PlayGodot
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install playgodot

# Option 1: Download pre-built binary (recommended)
# See releases: https://github.com/Randroids-Dojo/godot/releases/tag/automation-latest
# - godot-automation-linux-x86_64.zip
# - godot-automation-macos-universal.zip (Intel + Apple Silicon)

# Option 2: Build custom Godot fork from source
git clone https://github.com/Randroids-Dojo/godot.git
cd godot && git checkout automation
scons platform=macos arch=arm64 target=editor -j8  # macOS Apple Silicon
# scons platform=macos arch=x86_64 target=editor -j8  # macOS Intel
# scons platform=linuxbsd target=editor -j8  # Linux
# scons platform=windows target=editor -j8  # Windows
```

### Test Configuration (conftest.py)

```python
import os
import pytest_asyncio
from pathlib import Path
from playgodot import Godot

GODOT_PROJECT = Path(__file__).parent.parent
GODOT_PATH = os.environ.get("GODOT_PATH", "/path/to/godot-fork")

@pytest_asyncio.fixture
async def game():
    async with Godot.launch(
        str(GODOT_PROJECT),
        headless=True,
        timeout=15.0,
        godot_path=GODOT_PATH,
    ) as g:
        await g.wait_for_node("/root/Game")
        yield g
```

### Writing PlayGodot Tests

```python
import pytest

GAME = "/root/Game"

@pytest.mark.asyncio
async def test_game_starts_empty(game):
    board = await game.call(GAME, "get_board_state")
    assert board == ["", "", "", "", "", "", "", "", ""]

@pytest.mark.asyncio
async def test_clicking_cell(game):
    await game.click("/root/Game/VBoxContainer/GameBoard/GridContainer/Cell4")
    board = await game.call(GAME, "get_board_state")
    assert board[4] == "X"

@pytest.mark.asyncio
async def test_game_win(game):
    for pos in [0, 3, 1, 4, 2]:  # X wins top row
        await game.call(GAME, "make_move", [pos])

    is_active = await game.call(GAME, "is_game_active")
    assert is_active is False
```

### Running PlayGodot Tests

```bash
export GODOT_PATH=/path/to/godot-automation-fork
pytest tests/ -v
pytest tests/test_game.py::test_clicking_cell -v
```

For the full PlayGodot API (node queries, mouse/keyboard/touch input, screenshots, scene management, game state), see `references/playgodot.md`.

---

## Building & Deployment

### Web Export

```bash
# Requires export_presets.cfg with Web preset
godot --headless --export-release "Web" ./build/index.html

# Verify the export succeeded
test -f ./build/index.html && echo "Export OK" || echo "Export FAILED — check export_presets.cfg and installed templates"
```

### Export Preset (export_presets.cfg)

```ini
[preset.0]
name="Web"
platform="Web"
runnable=true
export_path="build/index.html"
```

### Deploy to Vercel

```bash
npm i -g vercel
vercel deploy ./build --prod

# Verify deployment (replace URL with Vercel output)
curl -s -o /dev/null -w "%{http_code}" https://your-project.vercel.app | grep -q 200 && echo "Deploy OK"
```

---

## CI/CD

### GitHub Actions Example

```yaml
- name: Setup Godot
  uses: chickensoft-games/setup-godot@v2
  with:
    version: 4.3.0
    include-templates: true

- name: Run GdUnit4 Tests
  run: |
    godot --headless --path . \
      -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
      --run-tests --report-directory ./reports

- name: Upload Results
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: test-results
    path: reports/
```

---

## References

- `references/gdunit4-quickstart.md` - GdUnit4 setup
- `references/scene-runner.md` - Input simulation API
- `references/assertions.md` - Assertion methods
- `references/playgodot.md` - PlayGodot guide
- `references/deployment.md` - Deployment guide
- `references/ci-integration.md` - CI/CD setup
