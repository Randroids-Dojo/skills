# GdUnit4 Assertions

## Basic Pattern

```gdscript
assert_that(actual_value).assertion_method(expected_value)
```

## Value Assertions

### Equality

```gdscript
assert_that(value).is_equal(expected)
assert_that(value).is_not_equal(other)
```

### Null Checks

```gdscript
assert_that(value).is_null()
assert_that(value).is_not_null()
```

### Boolean

```gdscript
assert_that(condition).is_true()
assert_that(condition).is_false()
```

### Type Checks

```gdscript
assert_that(value).is_instanceof(MyClass)
```

## Number Assertions

```gdscript
# Comparisons
assert_that(number).is_less(10)
assert_that(number).is_less_equal(10)
assert_that(number).is_greater(5)
assert_that(number).is_greater_equal(5)

# Range
assert_that(number).is_between(1, 100)
assert_that(number).is_not_between(50, 60)

# Special values
assert_that(number).is_zero()
assert_that(number).is_not_zero()
assert_that(number).is_negative()
assert_that(number).is_positive()

# Approximate equality (for floats)
assert_that(3.14159).is_equal_approx(3.14, 0.01)
```

## String Assertions

```gdscript
# Content
assert_that(text).contains("substring")
assert_that(text).not_contains("forbidden")

# Position
assert_that(text).starts_with("prefix")
assert_that(text).ends_with("suffix")

# Pattern
assert_that(text).matches("regex_pattern")

# Length
assert_that(text).is_empty()
assert_that(text).is_not_empty()
assert_that(text).has_length(10)

# Case
assert_that(text).is_equal_ignoring_case("HELLO")
```

## Array Assertions

```gdscript
# Content
assert_that(array).contains(element)
assert_that(array).not_contains(element)
assert_that(array).contains_exactly([1, 2, 3])
assert_that(array).contains_same_elements([3, 1, 2])  # Order doesn't matter

# Size
assert_that(array).is_empty()
assert_that(array).is_not_empty()
assert_that(array).has_size(5)

# Position
assert_that(array).starts_with([1, 2])
assert_that(array).ends_with([4, 5])
```

## Dictionary Assertions

```gdscript
# Keys
assert_that(dict).contains_key("name")
assert_that(dict).not_contains_key("secret")
assert_that(dict).contains_keys(["name", "age"])

# Values
assert_that(dict).contains_value(42)
assert_that(dict).contains_key_value("name", "Alice")

# Size
assert_that(dict).is_empty()
assert_that(dict).has_size(3)
```

## Object Assertions

```gdscript
# Same instance
assert_that(obj1).is_same(obj2)
assert_that(obj1).is_not_same(obj2)

# Type
assert_that(node).is_instanceof(Node2D)
assert_that(node).is_not_instanceof(Control)
```

## Signal Assertions

```gdscript
# Basic signal check
await assert_signal(emitter).is_emitted("signal_name")

# With timeout
await assert_signal(emitter).wait_until(2000).is_emitted("signal_name")

# Signal not emitted
await assert_signal(emitter).wait_until(1000).is_not_emitted("signal_name")

# With arguments
await assert_signal(emitter).is_emitted("value_changed", [100])
```

## Vector Assertions

```gdscript
# Vector2
assert_that(vec2).is_equal(Vector2(10, 20))
assert_that(vec2).is_equal_approx(Vector2(10.1, 20.1), Vector2(0.2, 0.2))

# Vector3
assert_that(vec3).is_equal(Vector3(1, 2, 3))
```

## File Assertions

```gdscript
assert_that(file_path).exists()
assert_that(file_path).not_exists()
assert_that(file_path).is_file()
assert_that(file_path).is_directory()
```

## Custom Failure Messages

```gdscript
assert_that(value)\
    .override_failure_message("Custom failure message")\
    .is_equal(expected)
```

## Fluent Chaining

```gdscript
assert_that(text)\
    .is_not_null()\
    .is_not_empty()\
    .starts_with("Hello")\
    .contains("World")
```

## Negation

Use `is_not_*` variants:

```gdscript
assert_that(value).is_not_null()
assert_that(value).is_not_equal(other)
assert_that(array).not_contains(element)
assert_that(text).not_contains("forbidden")
```

## Assert Failure

Explicitly fail a test:

```gdscript
func test_not_implemented() -> void:
    fail("This test is not yet implemented")
```

## Skip Test

Skip conditionally:

```gdscript
func test_platform_specific() -> void:
    if OS.get_name() != "Windows":
        skip("Windows only test")
        return
    # ... test code
```

## Exception Testing

```gdscript
func test_throws_error() -> void:
    await assert_error(func(): some_function())\
        .is_thrown()

# With message check
await assert_error(func(): some_function())\
    .has_message("Expected error message")
```

## Performance Assertions

```gdscript
func test_performance() -> void:
    # Assert function completes within time limit
    await assert_that(func(): expensive_operation())\
        .is_completed_in(1000)  # 1 second max
```

## Common Patterns

### Testing Properties

```gdscript
func test_player_health() -> void:
    var player = auto_free(Player.new())

    assert_that(player.health).is_equal(100)
    assert_that(player.is_alive()).is_true()

    player.take_damage(30)

    assert_that(player.health).is_equal(70)
    assert_that(player.is_alive()).is_true()
```

### Testing Collections

```gdscript
func test_inventory() -> void:
    var inventory = auto_free(Inventory.new())

    assert_that(inventory.items).is_empty()

    inventory.add_item("sword")
    inventory.add_item("shield")

    assert_that(inventory.items).has_size(2)
    assert_that(inventory.items).contains("sword")
    assert_that(inventory.items).contains_exactly(["sword", "shield"])
```

### Testing Signals

```gdscript
func test_death_signal() -> void:
    var player = auto_free(Player.new())

    player.health = 10
    player.take_damage(10)

    await assert_signal(player).is_emitted("died")
```
