# API, MCP, and session ownership

## Choose the control surface

| Work | Useful control |
|---|---|
| Scene/objects/missing files/UI inspection | Purpose-built MCP tools when available |
| Bulk construction/materials/geometry checks | Saved bpy, BMesh, mathutils scripts |
| Long deterministic batch work | Isolated Blender process with explicit inputs/outputs |
| Targeted live correction | MCP operation; code execution when no suitable tool exists |
| Navigation/framing/playback/launch QA | Actual native UI or artifact player |

MCP providers differ. Discover schemas rather than copying names blindly. The observed official Blender Lab provider offers scene/path summaries, object detail, API/manual lookup, screenshots, viewport renders, and code execution. Its execute tool returns a JSON-serializable variable named `result`; follow the installed contract.

Before mutation, get a compact identity response:

```python
import bpy, os
result = {'pid': os.getpid(), 'file': bpy.data.filepath,
          'version': bpy.app.version_string, 'scene': bpy.context.scene.name,
          'engine': bpy.context.scene.render.engine}
```

Compare with the intended session, not just the foreground window. Unsaved files need explicit session identity and a project save location before durable work. Recheck after reconnect/file load/ambiguous response; do not silently attach to another project.

## Repeatable operations

Use data API/BMesh for bulk work without selection side effects. Standard operators are useful when their semantics are wanted; explicitly establish mode, active object, selection, scene/view layer and required area. Inspect datablock user counts before changing shared meshes/materials.

Read evaluated transforms/modifier geometry after dependency-graph update. Use matrix_world for world-space measurements. In Edit mode, use edit BMesh and flush changes. Preserve parenting/rig/animation intent; applying transforms is not universal cleanup.

Create owned collections and retain returned references because automatic name suffixes invalidate assumed lookups. Store parameters/seeds separately. Avoid whole-file reset and indiscriminate orphan purging in an existing project.

Snapshot a collection traversal before changing membership or visibility during that traversal, especially with recursive collection iterators. Reacquire datablocks after loading another file; retained RNA references can be invalid even when the replacement has the same name.

Read-only helper through MCP:

```python
import runpy
probe = runpy.run_path('/absolute/skill/path/scripts/probe_scene.py')
result = probe['inspect_scene'](limit=12)
```

Saved-file inspection:

```text
blender --background /absolute/project/scene.blend --python-exit-code 1 --python /absolute/skill/path/scripts/probe_scene.py -- --output /absolute/project/qa/probe.json
```

CLI arguments execute in order; loading a file can replace earlier settings. Verify flags with installed `--help`. Normal Python generally lacks embedded bpy. Never keep Python threads touching Blender data during rendering; use the main thread/timers for bpy and external processes for orchestration.

## Failures and live progress

Return compact data or paths. If an inline screenshot is truncated, save through a supported Blender screenshot/render API and inspect the actual file. Transport failure is not scene failure; a thumbnail is not final-size microdetail QA.

If MCP is unavailable, inspect configuration, add-on state, port owner and traceback. Official Blender Lab MCP and community `blender-mcp` packages are different implementations. A tested official revision needed compatible MCP SDK 1.x after unconstrained 2.x broke its FastMCP import. This is a historical compatibility example, not a universal pin: verify the current package and lock a working combination locally.

Some add-ons require Online Access even for loopback. Check the provider, keep listeners local, and avoid unrelated global preference changes. Code execution is powerful local execution, not a sandbox.

### Optional scoped file bridge

Use [file_bridge.py](../scripts/file_bridge.py) only when standard MCP repair cannot serve an owned live session and you already have a way to install it in the correct instance. It is an ephemeral main-thread timer, not a network server or permanent add-on.

```python
import runpy
bridge = runpy.run_path('/absolute/skill/path/scripts/file_bridge.py')
result = bridge['install']('/absolute/project/control/session',
                          '/absolute/project/scene.blend',
                          '/absolute/project/scripts')
```

Read `state.json` for identity. Queue one request using a temporary JSON atomically renamed to `request.json`; never overwrite pending request/processing files.

```json
{"request_id":"inspect-001","session":"value-from-state","expected_pid":12345,"expected_blend":"/absolute/project/scene.blend","action":"inspect"}
```

For `run_script`, include `script` within the allowed scripts directory. Scripts have full Blender access; path checks are an accidental-overlap guard, not a security sandbox. An exclusive `bridge.lock` prevents a second installer from taking the queue. If file loading or a crash leaves a stale lease, inspect its PID/session before removing it or use a fresh session directory. The timer rejects wrong identity/paths, stops on file change and is nonpersistent across loads. Only a matching response with `ok: true` proves completion. `STOP` stops the bridge next poll; it does not cancel an independent renderer. Keep control state out of published assets. Do not install a bridge merely to read a healthy busy renderer's filesystem progress.

## Primary references

[Python API](https://docs.blender.org/api/current/), [threading gotchas](https://docs.blender.org/api/current/info_gotchas_threading.html), [Blender Lab MCP](https://www.blender.org/lab/mcp-server/), [MCP source](https://projects.blender.org/lab/blender_mcp), [CLI arguments](https://docs.blender.org/manual/en/latest/advanced/command_line/arguments.html).

Developed against Blender 5.1.2. Select installed-version docs and introspect properties/enums on other versions. Local API/source and actual smoke tests take precedence over remembered tutorials.
