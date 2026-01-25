# PlayGodot Game Automation Guide

[PlayGodot](https://github.com/Randroids-Dojo/PlayGodot) is a game automation framework for Godot - like Playwright, but for games. Control games from Python, write E2E tests, capture screenshots, and simulate input via Godot's native debugger protocol.

## Requirements

- **Custom Godot build** - [Randroids-Dojo/godot](https://github.com/Randroids-Dojo/godot) (automation branch)
- **Python 3.9+** - For running automation scripts
- **PlayGodot package** - `pip install playgodot`

## Installation

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

## Quick Start

```python
import asyncio
from playgodot import Godot

async def automate_game():
    async with Godot.launch("path/to/project", godot_path="/path/to/godot-fork") as game:
        await game.wait_for_node("/root/Main")
        await game.click("/root/Main/UI/StartButton")
        await game.screenshot("game_started.png")

asyncio.run(automate_game())
```

## Test Configuration

Create a `conftest.py` file for pytest:

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

## API Reference

### Node Interaction

```python
# Get node info
node = await game.get_node("/root/Game/Player")

# Properties
health = await game.get_property("/root/Game/Player", "health")
await game.set_property("/root/Game/Player", "health", 50)

# Call methods
result = await game.call("/root/Game/Player", "take_damage", [25])

# Check existence
exists = await game.node_exists("/root/Game/Enemy")
```

### Input Simulation

```python
# Mouse
await game.click("/root/Game/StartButton")
await game.click(400, 300)
await game.double_click("/root/Game/Item")
await game.right_click(100, 100)
await game.drag("/root/Game/DragItem", "/root/Game/DropZone")

# Keyboard
await game.press_key("space")
await game.press_key("ctrl+s")
await game.type_text("Hello World")

# Input actions
await game.press_action("jump")
await game.hold_action("sprint", 2.0)

# Touch
await game.tap(300, 200)
await game.swipe(100, 100, 400, 100)
await game.pinch((200, 200), 0.5)
```

### Node Queries

```python
# Find nodes by pattern
buttons = await game.query_nodes("*Button*")

# Count matching nodes
count = await game.count_nodes("*Enemy*")
```

### Screenshots

```python
# Capture viewport
png_data = await game.screenshot()

# Save to file
await game.screenshot("/tmp/screenshot.png")

# Capture specific node
await game.screenshot(node="/root/Game/UI")

# Compare screenshots (returns similarity 0.0-1.0)
similarity = await game.compare_screenshot("expected.png")
assert similarity > 0.99

# Assert screenshot matches reference
await game.assert_screenshot("reference.png", threshold=0.99)
await game.assert_screenshot("reference.png", threshold=0.95, save_diff="diff.png")
```

### Scene Management

```python
# Get current scene
scene = await game.get_current_scene()

# Change scene
await game.change_scene("res://scenes/level2.tscn")

# Reload
await game.reload_scene()
```

### Game State Control

```python
# Pause/unpause
await game.pause()
await game.unpause()
is_paused = await game.is_paused()

# Time scale
await game.set_time_scale(0.5)  # Slow motion
await game.set_time_scale(2.0)  # Fast forward
scale = await game.get_time_scale()
```

### Waiting

```python
# Wait for node
node = await game.wait_for_node("/root/Game/SpawnedEnemy", timeout=5.0)

# Wait for visibility
await game.wait_for_visible("/root/Game/UI/GameOverPanel", timeout=10.0)

# Wait for signal
await game.wait_for_signal("game_over")
await game.wait_for_signal("health_changed", source="/root/Game/Player")
result = await game.wait_for_signal("score_updated", timeout=10.0)
print(result["args"])  # Signal arguments

# Wait for condition
async def check_score():
    score = await game.call("/root/Game", "get_score")
    return score >= 100

await game.wait_for(check_score, timeout=30.0)
```

## E2E Testing Example

```python
import pytest

GAME = "/root/Game"

@pytest.mark.asyncio
async def test_game_starts_empty(game):
    board = await game.call(GAME, "get_board_state")
    assert board == ["", "", "", "", "", "", "", "", ""]

@pytest.mark.asyncio
async def test_clicking_cell(game):
    await game.click("/root/Game/Board/Cell4")
    board = await game.call(GAME, "get_board_state")
    assert board[4] == "X"

@pytest.mark.asyncio
async def test_win_condition(game):
    for pos in [0, 3, 1, 4, 2]:  # X wins top row
        await game.call(GAME, "make_move", [pos])

    is_active = await game.call(GAME, "is_game_active")
    assert is_active == False

    winner = await game.call(GAME, "get_winner")
    assert winner == "X"
```

## Running Tests

```bash
# Set Godot path
export GODOT_PATH=/path/to/godot-automation-fork

# Run all tests
pytest tests/ -v

# Run specific test
pytest tests/test_game.py::test_clicking_cell -v

# Stop on first failure
pytest tests/ -v -x
```

## Debugging

### Verbose Output

```python
async with Godot.launch(
    str(GODOT_PROJECT),
    verbose=True,  # Enable debug logging
) as g:
    ...
```

### Visible Window

```python
async with Godot.launch(
    str(GODOT_PROJECT),
    headless=False,  # Show game window
    resolution=(1280, 720),
) as g:
    ...
```

### Custom Port

```python
async with Godot.launch(
    str(GODOT_PROJECT),
    port=6008,  # Custom port (default is 6007)
) as g:
    ...
```

## How It Works

PlayGodot uses Godot's native RemoteDebugger protocol:

1. PlayGodot starts a TCP server on port 6007
2. Godot is launched with `--remote-debug tcp://127.0.0.1:6007`
3. Godot connects to PlayGodot as a debugging client
4. PlayGodot sends automation commands (`automation:get_node`, `automation:click`, etc.)
5. Commands are serialized using Godot's binary Variant format

This requires no addons or game modifications - just the automation-enabled Godot fork.

## Resources

- [PlayGodot Repository](https://github.com/Randroids-Dojo/PlayGodot)
- [Godot Automation Fork](https://github.com/Randroids-Dojo/godot)
