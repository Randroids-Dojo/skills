# Evidence and delivery

## Technical and visual acceptance

Maintain a compact defect ledger. Each repair needs an observed issue and a confirming view. Retest affected neighbors; broaden only for changes with wider effects.

Measured work needs source IDs, coordinate/unit conversion, camera registration and uncertainty. Original/stylized work needs brief-specific silhouette, palette, material and composition checks. Pixel similarity can mislead when light/lens/state differ; use multi-view geometry evidence.

Inspect actual artifacts, never generated substitutes or mock screenshots. Metrics flag candidates but cannot certify aesthetics. Open the real images: full frame for composition, delivery-size crops for detail. Label crops and preserve their content.

## Coverage depends on deliverable

- Product/object: orbit, relevant top/bottom, grazing highlights, joins/details, support.
- Character: front/side/back, hero details, pose extremes and deformation in motion.
- Environment: wide/reverse views, reachable undersides, doors/stairs and floor/ceiling boundaries.
- Film: every shot, both sides of every cut, start/end, consecutive spans, reflective/organic/simulated regions, actual playback.
- Interactive: real input/movement, reset/home, starting view and worst case at target device/resolution.

A correctly decoded nominal-fps movie can still freeze, flash, shimmer or have bad camera motion. Use image differences to flag issues, not automatically reject intended holds/cuts. Record player, test duration and concurrent load with decoded/dropped/corrupt metrics. A tiny looping clip under GPU contention does not verify an entire film.

Before a costly capture batch, render a cheap pilot of every distinct camera path and moving configuration: start, end, likely closest approach, and a short consecutive span. Check framing, light placement, occlusion, and moving-part intersections. A turntable pilot does not validate an interior tour or door-opening camera. Fix the failed shot before full rendering, and bind reusable output to the accepted source and capture recipe. Pilot evidence covers the pilot only; final motion still needs review.

## Reopen and package

Reopen the accepted file from its final location with intended engine/camera/view. Check images, tiled textures/sequences, libraries, fonts, audio, simulation/probe caches, add-ons and required scripts. `probe_scene.py` detects basic missing files and unresolved sequence/tiled resources; it does not prove every cache is portable.

Record the initial reopened state before attempting recovery. A hidden driven object can expose a dependency-graph or control-lifecycle problem that an in-memory check missed. Diagnose the actual driver and normal application lifecycle, preserve the failed observation, and verify any required initialization in the delivered experience. Assigning expected transforms or silently warming controls in a verifier does not repair that experience.

Exercise persisted validation records through their real write/read path. JSON converts tuples to lists; use explicit JSON-native capture values when exact inventory comparison is required. Preserve values, ordering and membership checks, with representative corruptions that must still reject. An in-memory equality check alone cannot prove the saved record will replay correctly.

Choose packed/relative assets for the format and preserve licenses. External-drive absolute paths are not portable. Exported GLB/USD/FBX/web viewers need separate inspection because materials, procedures, rigs and instances may translate differently. Do not silently replace editable scenes or full navigation with movies/panoramas.

## Remote delivery

When requested, publish only the agreed artifact through an authorized destination. Verify the returned HTTPS viewer/video, playback and seeking; include a usable download. Keep research/source/scripts/credentials out of uploads and report real access/expiry. Local media paths alone cannot support remote viewing.

Do not send third-party messages or buy cloud services merely for convenience. For remote rendering, make a concrete plan for dependencies, Blender/add-on versions, hardware, cost and a representative test, with required service authorization.

## Stop at the agreed scope

State what exists, what passed and precise limitations: source fidelity, renderer approximation, missing coverage/cache, unreviewed motion, or unsupported export. Do not claim “perfect” from technical checks.

When the user says wrap up, freeze accepted content and finish delivery. Old goals/monitors must not restart lighting or modeling. Stop recurring checks after agreed local/remote handoff and identify the accepted artifact clearly for another agent.
