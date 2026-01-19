# GdUnit4 Scene Runner

The Scene Runner enables integration testing with input simulation.

## Creating a Scene Runner

```gdscript
extends GdUnitTestSuite

var runner: GdUnitSceneRunner

func before_test() -> void:
    runner = scene_runner("res://scenes/main.tscn")

func after_test() -> void:
    runner.free()
```

## Accessing the Scene

```gdscript
# Get the root node of the loaded scene
var game = runner.scene()

# Find child nodes
var player = runner.find_child("Player")
var ui = runner.find_child("UI/HUD")
```

## Mouse Input

### Position

```gdscript
# Set mouse position (viewport coordinates)
runner.set_mouse_position(Vector2(100, 200))

# Get current mouse position
var pos = runner.get_mouse_position()
```

### Buttons

```gdscript
# Press (and hold) mouse button
runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)

# Release mouse button
runner.simulate_mouse_button_released(MOUSE_BUTTON_LEFT)

# Press and immediately release
runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)

# Right click
runner.simulate_mouse_button_press(MOUSE_BUTTON_RIGHT)

# Middle click
runner.simulate_mouse_button_press(MOUSE_BUTTON_MIDDLE)
```

### Click at Position

```gdscript
# Move and click
runner.set_mouse_position(Vector2(100, 200))
runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
await runner.await_input_processed()
```

### Double Click

```gdscript
runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT, true)  # double_click=true
```

### Drag and Drop

```gdscript
# Start position
runner.set_mouse_position(Vector2(100, 100))
runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
await runner.await_input_processed()

# Move while holding
runner.set_mouse_position(Vector2(300, 300))
await runner.await_input_processed()

# Release
runner.simulate_mouse_button_released(MOUSE_BUTTON_LEFT)
await runner.await_input_processed()
```

## Keyboard Input

### Single Keys

```gdscript
# Press key (and hold)
runner.simulate_key_pressed(KEY_SPACE)

# Release key
runner.simulate_key_released(KEY_SPACE)

# Press and release
runner.simulate_key_press(KEY_SPACE)
```

### Key Codes

Common key codes:
- `KEY_SPACE`, `KEY_ENTER`, `KEY_ESCAPE`, `KEY_TAB`
- `KEY_UP`, `KEY_DOWN`, `KEY_LEFT`, `KEY_RIGHT`
- `KEY_A` through `KEY_Z`
- `KEY_0` through `KEY_9`
- `KEY_F1` through `KEY_F12`

### Modifier Keys

```gdscript
# Ctrl+S (shift, ctrl, alt, meta)
runner.simulate_key_pressed(KEY_S, false, true, false, false)

# Shift+A
runner.simulate_key_pressed(KEY_A, true, false, false, false)

# Ctrl+Shift+Z
runner.simulate_key_pressed(KEY_Z, true, true, false, false)
```

Parameters: `key, shift=false, ctrl=false, alt=false, meta=false`

## Input Actions

```gdscript
# Press action (as defined in Input Map)
runner.simulate_action_pressed("jump")

# Release action
runner.simulate_action_released("jump")

# Press and release
runner.simulate_action_press("jump")
```

## Waiting

### Essential Wait

Always wait after simulating input:

```gdscript
runner.simulate_key_press(KEY_SPACE)
await runner.await_input_processed()  # Required!
```

### Frame Waiting

```gdscript
# Wait one idle frame
await runner.await_idle_frame()

# Wait multiple frames
for i in range(10):
    await runner.await_idle_frame()
```

### Signal Waiting

```gdscript
# Wait for signal (with timeout)
await runner.await_signal("game_over", [], 5000)  # 5 second timeout

# Wait for signal with arguments
await runner.await_signal("score_changed", [100], 2000)
```

### Condition Waiting

```gdscript
# Wait until function returns expected value
var game = runner.scene()
await runner.await_func(game, "is_game_over").is_true()

# With timeout
await runner.await_func(game, "get_health").is_less(50).wait_until(3000)
```

## Touch Input (Mobile)

```gdscript
# Touch press
runner.simulate_screen_touch_pressed(0, Vector2(100, 200))  # index, position

# Touch release
runner.simulate_screen_touch_released(0)

# Double tap
runner.simulate_screen_touch_pressed(0, Vector2(100, 200), true)  # double_tap=true
```

## Complete Example

```gdscript
extends GdUnitTestSuite

var runner: GdUnitSceneRunner

func before_test() -> void:
    runner = scene_runner("res://scenes/game.tscn")

func after_test() -> void:
    runner.free()

func test_player_moves_right() -> void:
    await runner.await_idle_frame()

    var player = runner.find_child("Player")
    var initial_x = player.position.x

    # Hold right arrow for 0.5 seconds
    runner.simulate_key_pressed(KEY_RIGHT)
    for i in range(30):  # ~0.5 seconds at 60fps
        await runner.await_idle_frame()
    runner.simulate_key_released(KEY_RIGHT)

    assert_that(player.position.x).is_greater(initial_x)

func test_button_click_starts_game() -> void:
    await runner.await_idle_frame()

    var start_button = runner.find_child("UI/StartButton")
    var button_center = start_button.global_position + start_button.size / 2

    runner.set_mouse_position(button_center)
    runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
    await runner.await_input_processed()

    var game = runner.scene()
    assert_that(game.is_game_active()).is_true()

func test_game_over_signal() -> void:
    await runner.await_idle_frame()

    var game = runner.scene()
    game.trigger_game_over()

    await runner.await_signal("game_over", [], 2000)
    # If we get here, signal was emitted
```

## Tips

1. **Always await** - Input simulation is async; always use `await`
2. **Find nodes carefully** - Use `find_child()` which searches recursively
3. **Set position first** - Move mouse before clicking
4. **Use actions** - Prefer `simulate_action_*` over raw keys for game input
5. **Handle timing** - Some animations need multiple frames to complete
