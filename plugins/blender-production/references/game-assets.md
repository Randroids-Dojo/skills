# Production game assets and costly rework

Use this guidance for focal assets, moving assemblies, and repeated modeling failures. Scale it to the requested style, camera distance, interactions, and delivery. A small prop does not need a vehicle engineering program.

## Make the large forms convincing before detail depends on them

Separate a functional blockout from an accepted visual foundation. A blockout that drives and exports proves integration. It does not prove the body, roof, character anatomy, or environment composition is ready for production detail.

Use a compact reference board with identified views and a few observable design relationships: silhouette, proportions, cross sections, feature placement, and material separation. Engineering dimensions constrain a shape but do not define its styling. For an original design, identify what is distinctive without copying a reference identity. Preserve intentional stylization.

Review a cheap neutral/clay contact sheet, orthographic views where useful, and grazing highlights before dense hardware, upholstery, decorative text, or final LODs. Include a real gameplay camera. Record the unresolved major forms and the next correction. This is an agent inspection checkpoint; ask for human approval only when the user or project requires it.

Do not add detail to a surface likely to be rebuilt. Independent runtime work can proceed against the stable blockout. Requested engine-bay or interior detail remains in scope, but follows the visible structures that contain it.

## Choose a representation that can carry the intended form

Procedural Python is a construction method, not evidence of visual quality. Use editable curves, shared cross sections, coherent surfaces, subdivision cages, or direct mesh modeling as appropriate. Repeated boxes, independent lofts, and Boolean patches can be useful components; do not keep them solely because they are easy to script when their joins dominate the render.

Prototype a difficult junction in isolation before multiplying it: roof/pillar/window, door/hinge/body, seat/piping, or wheel/arch. Derive mating boundaries and offsets from shared geometry instead of independently guessing each part's coordinates. Check both the assembled appearance and required movement before locking the interface. Preserve stable engineering hardpoints while allowing unaccepted styling to change coherently.

Define an edit domain by the complete physical interface, then derive its face and vertex mask. Check adjacent walls and narrow corner strips before deforming the selected faces: moving one side of a shared edge while freezing its neighbour can fold an otherwise valid wall. If an unaccepted implementation mask excludes necessary geometry, record a broader connected domain while preserving the actual engineering boundaries, outside surfaces and clearance limits. Historical triangle IDs are not a reason to retain a contradictory assembly.

When repairs alternate between gaps, intersections, ridges, and normal patches at the same junction, step back to its surface layout. Compare a simpler shared-surface alternative at the same camera and light. Preserve the last accepted checkpoint; replace only owned construction. A local repair should reduce the original defect without creating another one nearby.

## Diagnose the cause and validate the actual representation

Use matched views to distinguish geometry, triangulation, custom normals, material response, lighting, and camera effects. For a reflection defect, compare the unchanged mesh with native geometric normals and the authored normals before changing roughness or adding subdivisions. Do not copy a normal field from an obsolete surface merely to preserve a previous numerical result.

Closed edge incidence does not prove that a mesh has no self-intersections. A valid evaluated polygon does not prove its exported triangles are nondegenerate. Check the representation that will actually be delivered, including modified geometry and lower LODs. For assemblies, distinguish intended attachment contact from unintended penetration. Sample near contact events and intermediate poses; endpoint or coarse pose checks need explicit coverage limits.

After reopening, distinguish a hidden object's unevaluated world matrix from changed stored geometry. If a geometry probe needs temporary visibility or driver changes to trigger native evaluation, scope and record them, verify that other raw fields remain exact, and restore every flag even when observation fails. This diagnostic recovery does not replace an unassisted cold-open interaction check.

Choose physical tolerances from the asset contract and intended use. Keep reference uncertainty, geometric fit, floating-point/encoding tolerances, and visual judgment separate. Numerical precision is useful for reproducibility; it cannot establish realism. A new detector needs representative known failures and valid cases so it does not become another source of rework.

Before a long capture, exercise the actual native writer and independent reader together. Exact numeric comparisons need lossless serialization or explicit native bit patterns; shortened JSON decimals can reject unchanged runtime values. Compare authored local transforms and engine-evaluated global transforms according to the pinned engine's rules, including camera basis normalization. Preserve the failed observation when fixing its recorder or reader.

Exercise preparation helpers through every delivery phase, including final sealing after a build. Syntax checks and a successful validate-only branch do not cover later control flow. Use an actual validated build or export as the fixture; check the emitted source identity, complete inputs, destinations and command arguments. Keep that fixture read-only and write each attempt to a fresh output directory. Correct preparation still does not establish a successful native run.

## Verify material meaning through the runtime pipeline

Follow representative materials from the authored shader through exported metadata, native engine import, project-owned adaptation and actual rendering. A successful import can silently ignore an optional material extension. Query support in the pinned engine and inspect the imported values. Trace every use of a shared material through all LODs: replacing a dynamic instrument surface does not prove that a separate static screen received the same correction.

Similar parameter names do not guarantee the same physical meaning. Derive conversions from the pinned shader or primary documentation, then verify actual native values and matched views. Matching normal-incidence reflectance alone does not establish the same grazing-angle response or complete BRDF equivalence. Preserve unsupported-response limits explicitly; do not hide them by loosening validation or inventing a universal conversion.

For a dynamic material replacement, compare both implementations on the actual asset mesh with the same frozen native texture feed and render configuration. Include asymmetric midtones and representative scene feeds: black/white or saturated endpoint patterns can conceal color-space errors. Exercise the supported renderers, independently controlled instances and resource recreation where those behaviors matter. Preserve the declared pixel tolerance and include a deliberate wrong mapping to confirm that the comparison can detect a defect.

Check shared source materials as well as active overrides through instance creation, state changes, deletion and recreation. An override can hide a source mutation from both renders and active-material inventories. Explicitly exercise the state that writes the property; starting in a different lighting or control state can produce a coverage-limited pass. Give each mutable material channel one runtime owner, and verify any older asset or fallback path when changing that ownership. Distinguish resource corruption from a visible defect when the changed source property is inactive.

Rendering equivalence can preserve an unusable view. Inspect mirrors, instruments and camera displays in their actual placement as well as in isolated material comparisons. A correct texture binding does not establish useful framing, visibility or readability.

Bind the quality settings actually used for visual review, including nested viewports and automation overrides. A requested quality tier is not a readback. Use a matched quality comparison before attributing speckled shadows or jagged edges to materials; keep invoked settings distinct from queried native values and do not infer which individual setting caused the improvement when several changed together.

When judging destination appearance in an isolated runtime project, verify the environment actually loaded. Missing presets or imported sky assets can silently select a fallback even when the lighting label is correct. Bind relevant dependencies and read back the active panorama or sky, exposure and lights. If these differ from the destination, repair the fixture and repeat the unchanged asset before adjusting its geometry, materials or camera. Keep fallback captures distinct from production-environment evidence.

When render size is part of acceptance, distinguish window pixels, logical content coordinates, stretched texture getters, render scale and actual output image dimensions. Inspect the pinned engine's getter semantics before inferring a framebuffer size from a texture property. A disposed output-image readback can verify delivered pixels, but may synchronize the GPU and allocate native memory: perform it outside the measured interval, record its cost and retain indirect-effect limits. Preserve supported headless paths without pretending that they produced an image. Correct settings do not override a failed contention or performance gate.

For open-panel framing, test each complete projected mesh envelope against the interface. One rectangle around the entire assembly can combine a raised hood with an outstretched door into an occupied area that contains no geometry. Retain whole-assembly window and clearance limits, require the complete visible mesh inventory, and include both that disjoint-envelope case and real overlap failures. Conservative projected bounds still need inspection of the actual image.

## Spend the budget on what the player can perceive

Allocate geometry, materials, and textures by visible contribution and required interaction. Keep explicit headroom while major forms are unfinished; choose the reserve from measured needs instead of a universal percentage. Avoid consuming almost the entire ceiling on hidden hardware and then degrading the focal silhouette to recover a few triangles.

Consider texture or normal-map detail for flat lettering and small surface features, instances for repetition, and geometry for silhouette, parallax, moving interfaces, and meaningful shadows. Inspection views can justify detail hidden during play. Check both use cases before removing it. Budget savings must survive fixed-camera comparison and runtime LOD transitions; a count alone does not accept the result.

Measure actual native resources in reachable runtime states. Source material families can undercount animated copies, display and mirror overrides, damage highlights, or additional passes. Record active unique resources separately from retained allocations and their high-water mark. Include relevant LODs and state transitions. A test that requests mutually exclusive controls must follow the existing input policy; an unreachable request is a fixture defect, not evidence that the vehicle control is broken.

Before consolidating materials, compare their native properties, shader behavior, texture dependencies and independent control channels. Matching names or colors does not prove that passive trim and an animated lamp can share one material. Preserve the measured overage while investigating; source counts or a proposed cache are not proof that the runtime budget passes.

## Keep iteration coherent

One writer owns each canonical asset and its generated outputs. If specialists are already part of the task, give them a frozen input revision, disjoint outputs, a bounded question, and a receipt: observed result, exact artifact, proposed change, affected interfaces. Combine interacting changes into a coherent candidate before spending on final acceptance. This workflow does not itself authorize delegation.

Keep a small current-state record: accepted source, active candidate, major unresolved defects, next causal experiment, invalidated evidence, and delivery conditions. Archive superseded trials without making their names or prose the source of current status. A growing report count is not a quality measure.

Test promised reproducible construction from a fresh scene early, then at coherent milestones. Reopening a saved blend and exporting it twice tests different guarantees. Preserve legitimate hand edits in the declared source; do not silently overwrite them with a generator. Reuse evidence only when its relevant source and configuration remain valid. Run focused checks during experiments and the complete required gates on the deliverable.

Capture required intermediate references at their actual construction stage. A later artifact renamed as an earlier checkpoint can invalidate field or shape comparisons. If a checker itself needs repair, keep the locked construction inputs intact: bind the revised independent checker separately, record its actual dependencies, and rerun it against the saved source. Preserve the original failure and distinguish verifier recovery from an asset correction.

When a pipeline accepts verification reports, check measured bounds and complete required domains as well as success labels. Derive component and moving-group membership from the current source and its driver ancestry. Match reported footprint coverage to every required face, and distinguish raw clearance from a bound that already subtracts a numerical margin. Include corruption cases with consistent recomputed hashes: deleting a required member or reporting an inadequate bound must still fail. A valid hash proves byte identity, not sufficient geometric coverage.

Keep source-construction and export-tool identities explicit. An updated exporter must validate the actual frozen construction package when its contract binds module paths and bytes, without rewriting the source's generation record. A separate directory argument alone may not select the intended code; verify which package actually ran.

Bind each recorded construction command to the artifacts its phase must produce. Check source, bundle and report destinations against their declared roles, and require the complete unique output inventory, including checkpoints enabled by the locked specification. Two matching command copies with recomputed hashes can still describe the wrong operation. Test coordinated edits to both copies as well as stale hashes. Keep command ancestry, actual native execution and final export acceptance as separate claims.

When progress plateaus, compare the current whole asset with the previous accepted views. Prioritize the most consequential open form or interaction defect; do not start optional microdetail to stay busy. Once the requested acceptance is met, deliver it. Required human judgments remain open until a human supplies them.
