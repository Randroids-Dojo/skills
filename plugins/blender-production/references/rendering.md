# Rendering, smooth motion, and performance

## Three different jobs

| Goal | Measure/deliver |
|---|---|
| Interactive exploration | Actual moving viewport frame times, input response, compilation pauses, memory, resolution |
| Still image | Converged image at requested resolution; full-size detail review |
| Smooth film | Finished images at exact timeline times, constant playback fps, temporal review, encoded movie |

A progressive viewport becomes noisy when motion resets its history. RAM alone does not make a heavy converged renderer real-time. A prerendered movie can play smoothly even if each source frame takes minutes; movie fps is not render throughput.

Choose engines from the result and benchmark. EEVEE can serve final output when its approximations pass the views; Cycles can suit difficult transport/reflections. Workbench establishes geometry/framing, not material realism. None is universal.

## Benchmark representative work

Save a baseline. Test difficult views appropriate to the subject: exterior, deep interior, reflective close-up, organic/animated regions, plus consecutive frames and a cut when applicable. Separate cold loading/compilation from warm frame cost.

Record engine/version/build/device, resolution, samples, color pipeline, ray/shadow/denoising settings, caches, competing work, peak memory and output size. Estimate by shot and include encoding/QA with uncertainty.

Log JSONL such as:

```json
{"frame":1,"shot":"hero","seconds":12.8,"cold":false,"timings":{"update":0.02,"draw":12.65,"readback":0.01,"save":0.1}}
```

`python scripts/benchmark.py frames.jsonl --remaining 500` summarizes timings. It also accepts `title` and excludes reused `existing: true` frames. ETA only makes sense when the sample represents remaining work.

## Optimize the bottleneck

| Dominant phase | Candidates to measure |
|---|---|
| Dependency-graph update | Avoid redundant frame/property changes; limit unrelated evaluation; appropriate baking/instancing |
| GPU draw/tracing/shadows | LOD, geometry/texture budgets, probe/shadow/ray costs, shader complexity, actual backend, samples/denoising |
| Repeated load/compile | Reuse process/scene; supported persistent data; avoid launching Blender per frame |
| Memory pressure | Preserve instances; bounded textures/probes/caches; remove duplicated owned data; inspect other workloads |
| Readback/save/encode | Storage, format/compression, copies, bounded encode threads |

When draw costs 99%, rewriting PNG saves will barely help. Disabling animation outside view can affect reflections/shadows and might save little; benchmark it.

Verify the actual hardware backend. Cycles device settings do not control EEVEE the same way. Apple Silicon shares memory with other apps. Extra Blender processes on one GPU can reduce throughput. Do not add parallel workers by default or interrupt another task without authorization. Independent devices can render disjoint frames after verifying scene/dependency/version equivalence.

Change one factor, render identical camera/time, compare images and motion, and keep/reject from evidence. Samples, coarse shadows, resolution and interpolation affect output; don't silently sacrifice accepted quality. Hardware video encoding speeds the encoding phase, not the preceding 3D render.

Observed in a large EEVEE production scene: draw dominated while updates/saves were tiny; halved samples reintroduced grain; coarser shadows, holding one animation still and minimizing the window did not provide a consistent worthwhile gain under variable load. These observations motivate testing, not universal settings. Competing high-resolution GPU work coincided with much slower frames; this was not a proof of a specific allocation mechanism.

## Resumable rendering

Render display-ready SDR PNGs, or scene-linear EXR for compositing/HDR, then encode. Avoid a monolithic video-only export for expensive work.

Use a configuration-specific output folder/manifest: source checkpoint hash, dependency hashes/immutable versions, engine/version/device, color management, cameras/timing, fps/dimensions and settings. Changed dependencies invalidate affected frames even when filenames exist. Reuse only compatible verified frames.

Write temporary frames and atomically rename after success. Quarantine partial/corrupt output without deleting valid work. Keep per-frame logs and compact atomic progress, with one writer per frame. Output frame n at fps F corresponds to (n-first)/F; map simulation time deliberately across differing frame rates.

Check STOP between frames and restore temporary settings on cleanup. Do not kill a native UI to cancel a job. Stale progress/timeouts require checking PID, timer/job state, logs or an executing stack before declaring failure; long GPU calls can delay MCP responses.

A native timer renderer should process one frame per callback, save/restore state, use a unique job key, free GPU resources and unregister on completion/error. Keep bpy on the main thread. External supervisors can hold bounded sleep-prevention assertions and launch encoding.

### Optional cached viewport export

For an approved EEVEE viewport with costly full-render initialization, investigate `gpu.types.GPUOffScreen.draw_view3d` in its native context. It needs a valid View3D space/region, main thread, explicit view/projection matrices and careful color handling. [GPUOffScreen API](https://docs.blender.org/api/current/gpu.types.html#gpu.types.GPUOffScreen).

It is not automatically equivalent to final rendering. Check viewport/final visibility and modifiers, overlays, materials/probes, convergence, camera aspect, alpha, row orientation and compositor effects. Do not apply the display transform both during drawing and saving. Compare frames/motion before a long export. Recreating buffers may reduce accumulation of resources but lose cache benefits; choose cadence from evidence, not a copied frame count.

Actual long-sequence review exposed isolated brightness flashes on the first image after offscreen-context creation/recreation, camera changes, and resumed segments. A technically valid PNG/MP4 did not catch them. Render and discard warm-up draws until the same camera/time is stable, then save; verify the needed warm-up count rather than assuming one draw is converged. Include scheduled context-recreation boundaries and reused pilot segments in temporal QA, not just scene cuts. Repair only proven affected frames at their exact original times and re-encode after validation; do not conceal the problem with duplicated/interpolated frames.

## Encode and finish

The companion helper accepts 6-digit PNG names and explicit dimensions/range/fps:

```text
python scripts/sequence_tools.py check /absolute/frames --first 1 --count 900 --width 1920 --height 1080
python scripts/sequence_tools.py encode /absolute/frames /absolute/tour.mp4 --first 1 --count 900 --width 1920 --height 1080 --fps 30
```

It checks coverage and PNG CRC/structure, encodes H.264/yuv420p with faststart, verifies count/fps/duration/dimensions and decodes the full movie before atomic delivery. Input must be display-referred SDR PNG, not linear/HDR. It leaves visual review pending.

Start encoding from the completion callback. A 30-minute monitor never pauses the render for 30 minutes; it can only delay final agent QA/delivery. Shorten checks near completion if useful, then stop after delivery. Do not rerender finished work to make monitoring appear faster.
