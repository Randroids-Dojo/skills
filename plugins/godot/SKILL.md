---
name: godot
description: Develop, test, automate, export, and deploy Godot 4.x games. Use when working with Godot projects, GDScript, GdUnit4, PlayGodot, project exports, or Godot CI and deployment.
---

# Godot

Work from the target project's actual Godot version, project settings, addons, and export presets. Preserve project conventions rather than imposing a generic scene architecture.

## Preflight

1. Read repository instructions and inspect `project.godot`, `export_presets.cfg`, installed addons, and the existing test layout.
2. Resolve the Godot executable and verify its version before choosing commands or APIs.
3. Determine the required verification level:
   - GdUnit4 for unit, component, and in-engine scene tests;
   - PlayGodot for external end-to-end automation, screenshots, or input simulation;
   - a real exported build when behavior depends on platform or browser packaging.
4. Do not claim real-render, input, export, or deployment success from static checks alone.

## Test and implement

- For GdUnit4 setup, test layout, and runner commands, read [references/gdunit4-quickstart.md](references/gdunit4-quickstart.md).
- For scene input simulation, read [references/scene-runner.md](references/scene-runner.md).
- For assertion syntax, read [references/assertions.md](references/assertions.md) only when writing or repairing assertions.
- For PlayGodot installation and external automation, read [references/playgodot.md](references/playgodot.md). Confirm the required custom Godot build exists before selecting this path.

Prefer the project's existing runner. A common GdUnit4 command is:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests
```

Use the bundled helpers by resolving them relative to this skill directory:

- `scripts/validate_project.py` for project preflight;
- `scripts/run_tests.py` for repeatable test execution;
- `scripts/export_build.py` for exports;
- `scripts/parse_results.py` for machine-readable test results.

Inspect helper options before running them, and do not overwrite a project's established commands when its own scripts are authoritative.

## Export and deployment

1. Read [references/deployment.md](references/deployment.md) when creating or changing export presets or deployment behavior.
2. Export into the project's designated build directory and inspect the produced artifact.
3. For web builds, serve the export and exercise it in a browser; verify asset loading, input, viewport behavior, console errors, and any required cross-origin isolation.
4. Read [references/ci-integration.md](references/ci-integration.md) when changing CI rather than copying an unverified workflow example.
5. Treat production deployment as a separate authorization boundary. After an authorized deployment, verify the live target rather than stopping at a successful CLI exit.

Finish with the Godot version, tests or runtime checks performed, produced artifact or deployment state, and any behavior that remains unverified.
