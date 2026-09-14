# Validation scope

Validated on September 9, 2026 with Blender 5.1.2, Python 3.14 for external helpers, and local FFmpeg/ffprobe. Tests used a separate temporary directory and a fresh background Blender process without rendering or touching an existing project.

Passed observable checks:

- A valid six-frame 64×64 PNG sequence passes; missing frames, wrong dimensions, truncated files and changed chunk CRC fail.
- H.264 encoding produces six frames at 30 fps, passes stream and full decode checks, retains visual review as pending, and refuses to overwrite a finished video.
- Benchmark aggregation excludes cold and reused frames from warm timing and calculates a known remaining-time fixture correctly.
- In actual Blender, the probe returns the correct process identity, bounds object output, and detects a missing image and shared mesh.
- In actual Blender, the scoped bridge accepts inspection and an allowed project script; rejects wrong PID, wrong file and outside-directory scripts; and stops/releases its state when STOP is supplied. Timer callbacks were invoked explicitly in the isolated test; prolonged native UI timer scheduling and reconnection were not exercised by this smoke test.

This validation establishes helper behavior, not photoreal quality on every subject or compatibility with every Blender/MCP version. The material, lighting, viewport and performance guidance combines observed production outcomes with renderer-specific techniques that require a task-specific pilot. New scripts are original helpers, not copied provider implementation.

Use the installed-version API and test uncertain features in isolation. Web access to the primary Blender documentation returned fetch errors during skill creation; existing local research, installed source/API and actual Blender checks supported the version-specific guidance. No new remote MCP connection or installation was required for these tests.

The reflective-surface reference added on 2026-09-13 was checked against public artist tutorials and primary Blender, Autodesk, Adobe, and Marmoset documentation. Its comparison exercise is an adaptation for production game assets, not a completed car-model experiment or a formal surface-quality certification. Older tutorials support modeling principles; inspect installed-version controls before reproducing their UI steps.

Subsequent Blender 5.1.2 vehicle trials on the same date exercised paired whole-object and grazing renders, a moving reflection sequence, changed-versus-automatic native normals, retained guide inputs, and physical sections. Independent inspection found a local reflection improvement while larger form defects remained. These trials support the diagnostic method, not complete vehicle or formal curvature acceptance. Saved-record tests also reproduced a tuple/list inventory mismatch and verified explicit JSON-list capture with wrong-value, order and membership controls; that was a verifier defect, not damaged geometry. Reopen trials exposed a hidden driven-object initialization issue whose recovery must remain separate from normal cold-open delivery behavior.

Later trials reproduced small evaluated UV differences in a no-edit load/update/capture control while raw data stayed exact; the control did not exercise every candidate-specific operation. Separate finite-field checks found that retaining corner samples during retriangulation did not preserve the complete normal field. These observations support controlled attribution and interior-field comparisons. They do not establish a universal drift allowance or make a failed asset acceptable.

On 2026-09-14, an actual Blender 5.1.2 GLB contained an optional scalar specular extension that official Godot 4.7.1 ignored while reporting import success. The native material retained its default scalar; tracing its six LOD uses distinguished dynamically replaced instrument surfaces from unchanged static navigation surfaces. Separately, 38 exported-byte controls passed, including 34 corruption rejections and an explicit nonshipping second-UV fixture for a valid single-UV asset. These observations support material-path inspection and representative validation fixtures; full runtime adaptation, angular appearance and asset acceptance require their own evidence.
