# Blender Production

Build, refine, inspect, render, and visually verify editable Blender work using Python and available live tools.

## Origin and maintenance

Adapted from [per-simmons/blender-production](https://github.com/per-simmons/blender-production) at revision `941f74d39888e4f9cad3f804ab8807a6824c1058`. The original copyright and MIT terms remain in [LICENSE](LICENSE).

Randroids Dojo additions cover production game assets, repeated modeling failures, shared assembly surfaces, visual foundations before dependent detail, exported geometry and motion checks, and pilots for costly capture batches. The preserved [upstream validation record](references/validation.md) describes its original helper tests; it is not a claim that this adaptation reran every Blender scenario.

## Install this maintained version

```bash
npx skills add Randroids-Dojo/skills --skill blender-production -y -g
```

## Contents

- [SKILL.md](SKILL.md): session ownership, observable acceptance, construction, rendering, QA.
- [Game assets](references/game-assets.md): design relationships, assembly interfaces, export/motion checks, and efficient iteration.
- [Control](references/control.md): Python/API/MCP selection and scoped recovery.
- [Realism](references/realism.md): appearance and diagnostic methods.
- [Rendering](references/rendering.md): performance, benchmarking, and resumable sequences.
- [QA and delivery](references/qa-delivery.md): visual review, capture pilots, and packaging.
- `scripts/`: scene probe, benchmark summary, sequence integrity/encoding, and scoped file bridge.

Use an installed Blender version appropriate to the project and probe uncertain API behavior. Blender Python supports repeatable construction; MCP is optional when available and permitted. Do not replace a project's established control or delivery pipeline merely to install this skill.
