# GdUnit4 Quickstart

## Installation

### Option 1: Asset Library (Recommended)

1. Open Godot Editor
2. Go to AssetLib tab
3. Search "GdUnit4"
4. Download and install
5. Enable in Project Settings → Plugins

### Option 2: Git Clone

```bash
cd your-project
git clone https://github.com/MikeSchulze/gdUnit4.git addons/gdUnit4
```

Then enable in Project Settings → Plugins.

### Option 3: Git Submodule

```bash
git submodule add https://github.com/MikeSchulze/gdUnit4.git addons/gdUnit4
```

## Project Structure

```
project/
├── addons/
│   └── gdUnit4/              # GdUnit4 addon
├── test/                      # Test directory (create this)
│   ├── game_test.gd
│   ├── player_test.gd
│   └── ...
├── scripts/
│   └── game.gd
└── project.godot
```

## Your First Test

Create `test/example_test.gd`:

```gdscript
extends GdUnitTestSuite

func test_addition() -> void:
    assert_that(2 + 2).is_equal(4)

func test_string() -> void:
    assert_that("hello").contains("ell")

func test_array() -> void:
    var arr = [1, 2, 3]
    assert_that(arr).has_size(3)
    assert_that(arr).contains(2)
```

## Running Tests

### From Editor

1. Open GdUnit4 panel (bottom dock)
2. Click "Run All" or right-click specific tests

### From Command Line

```bash
# Run all tests
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests

# Run specific test file
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
    --run-tests --add res://test/game_test.gd

# Generate JUnit XML report
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
    --run-tests --report-directory ./reports
```

## Test Lifecycle

```gdscript
extends GdUnitTestSuite

# Called once before all tests in this suite
func before() -> void:
    print("Suite setup")

# Called once after all tests in this suite
func after() -> void:
    print("Suite teardown")

# Called before each test
func before_test() -> void:
    print("Test setup")

# Called after each test
func after_test() -> void:
    print("Test teardown")

func test_example() -> void:
    assert_that(true).is_true()
```

## Memory Management

Use `auto_free()` to automatically free objects after the test:

```gdscript
func test_node_creation() -> void:
    var node = auto_free(Node2D.new())
    assert_that(node).is_not_null()
    # node is automatically freed after test
```

For scene instances:

```gdscript
func test_scene() -> void:
    var scene = auto_free(load("res://player.tscn").instantiate())
    assert_that(scene.health).is_equal(100)
```

## Parameterized Tests

```gdscript
func test_is_even(value: int, expected: bool, test_parameters := [
    [2, true],
    [3, false],
    [4, true],
    [5, false],
]) -> void:
    var is_even = value % 2 == 0
    assert_that(is_even).is_equal(expected)
```

## Mocking

```gdscript
func test_with_mock() -> void:
    var mock_player = mock(Player)

    # Configure mock behavior
    do_return(100).on(mock_player).get_health()

    # Use mock
    assert_that(mock_player.get_health()).is_equal(100)

    # Verify interactions
    verify(mock_player).get_health()
```

## Common Issues

### Tests Not Found

- Ensure file ends with `_test.gd`
- Ensure class extends `GdUnitTestSuite`
- Ensure test methods start with `test_`

### Plugin Not Loading

1. Close Godot
2. Delete `.godot/` directory
3. Reopen project and re-enable plugin

### Headless Mode Issues

Some tests may behave differently in headless mode. Use:

```gdscript
func test_visual_feature() -> void:
    if DisplayServer.get_name() == "headless":
        skip("Requires display")
        return
    # ... test code
```

## Version Compatibility

| GdUnit4 Version | Godot Version |
|-----------------|---------------|
| 4.4.x | 4.3.x |
| 4.3.x | 4.2.x |
| 4.2.x | 4.1.x |

Check [releases](https://github.com/MikeSchulze/gdUnit4/releases) for latest compatibility.
