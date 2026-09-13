# Realism in reflective manufactured assets

Use for vehicles, appliances, instruments, and similar assets where surface shape is legible through reflections. Keep the intended design and style. The methods below are a Blender/game-asset adaptation of the linked public tutorials and documentation, researched on 2026-09-13; they require an asset-specific comparison before adoption.

## Establish the missing middle of the form

A recognizable outline can still enclose crude surfaces. Before small hardware, establish the medium forms: roof crown, fender shoulders, transitions around apertures, and the depth and section of trim. Check several perspective angles as well as orthographic views. Measure individual part thickness and edge radius; correct overall dimensions do not prevent an inflated, miniature appearance. Keep the control mesh editable while these relationships change. Jonathan Lampel explains this hierarchy and the often-missed scale of individual pieces in [6 Principles of Great 3D Modeling](https://blog.cgcookie.com/posts/6-principles-of-great-3d-modeling/).

For an original design, use reference to understand construction and proportions while preserving its own identity. Record uncertain measurements instead of combining incompatible reference views into an apparently exact model.

## Separate broad curvature from panel detailing

Chris Plush's [anti-pinching tutorial introduction](https://www.blendernation.com/2017/06/02/advanced-subsurf-modeling-techniques-avoid-pinching/) describes using Shrinkwrap when details distort a subdivided surface. Saksham Kumar's first-person [Corvette breakdown](https://www.blendernation.com/2019/02/15/behind-the-scenes-corvette-c7-stingray/) explains the practical separation: an uncut guide establishes reflections; detailed panels follow it.

For a suitable curved assembly, try this small construction experiment:

1. Preserve a simple, smoothly evaluated guide with the intended broad form. Resolve its silhouette and reflection flow before cutting holes or seams.
2. Derive separate working panels from that surface. Add openings and local topology on these panels while retaining the guide independently.
3. Conform the intended exterior vertices to the guide. Restrict influence so deliberate creases, gap walls, lips, inner faces, and separate components retain their own shape.
4. Inspect the evaluated result after subdivision, wrapping, thickness, and edge treatment. Modifier order depends on the construction; wrapping after thickness can collapse a panel's inner shell. Inspect section cuts, panel separation, and projection near tight corners.

Shrinkwrap changes vertex positions. Its target, projection direction/distance, offset and vertex-group influence determine what follows the guide; verify those controls in the installed Blender version. See the [Blender Shrinkwrap reference](https://docs.blender.org/UATEST/manual/en/dev/modeling/modifiers/deform/shrinkwrap.html). This is not a remedy for a poorly shaped guide. Use separate guides or another surface method when one projection cannot represent the assembly.

When an existing guide is inferred from geometry, retain the actual pre-cut or pre-replacement inputs. Reconstructing it from the revised panel can silently change the reference. Compare the intended guide, evaluated physical sections, and rendered response separately. Exact agreement at control knots does not establish conformity between them or a convincing shape. Check the sampled spans and the transition into neighboring surfaces; different interpolation rules on adjacent rows can introduce a bend that neither endpoint checks nor smoothly interpolated normals reveal.

## Judge curvature as well as edge closure

Connected edges establish positional continuity (G0). Matching tangent direction (G1) removes a sharp directional break, but the rate of bending can still change abruptly. Curvature continuity (G2) addresses that transition. Both the interiors of surfaces and their boundaries matter. Autodesk's [curvature tutorial](https://help.autodesk.com/cloudhelp/2014/CHS/Alias/files/GUID-9DD73E22-A5EF-4952-BB84-2CEE2109993C.htm) explains why a green continuity check or smooth-looking diagnostic image alone is insufficient. Its CAD tolerances and control-vertex rules are not automatic requirements for a polygon game asset.

A practical Blender adaptation of [zebra diagnostics](https://help.autodesk.com/cloudhelp/2022/ENU/Alias-Reference/files/Menus/Object-Display-menu/ObjectDisplay-Diagnostic-Shading/GUID-10E80531-E391-4A1F-BF55-946E441204FF.html) is a plain reflective material and broad strip lights or a striped reflection environment. Sweep the reflected pattern across the surface and inspect multiple directions. Look for unexpected kinks, pinching, waviness, and abrupt changes in band width. Preserve designed creases. Use these images to locate defects, then inspect sections/control geometry; they do not certify formal Class-A, G2, or G3 quality.

Compare with custom-normal effects disabled when shading may be concealing the cause. Blender's [Weighted Normal modifier](https://docs.blender.org/manual/en/5.0/modeling/modifiers/normals/weighted_normal.html) changes shading normals. It cannot repair a wrong silhouette, intersecting panels, or an incorrect physical cross-section.

Make that diagnostic in a temporary copy and verify that the intended corner normals actually changed. Preserve the evaluated physical mesh, including thickness and other shape modifiers; clearing the entire modifier stack can invalidate the comparison. Keep camera transforms, lens, lights, exposure, material settings and control poses paired. Inspect the whole object alongside the close reflection sweep so a locally smoother joint does not hide a swollen silhouette or move the kink downstream.

## Resolve primary surfaces before edge blends

When a fillet or rounded junction repeatedly fails, inspect the underlying surfaces at their intended intersection. Retain the simple construction before blending. Autodesk's [Golden Rule 7](https://help.autodesk.com/cloudhelp/2019/ENU/Alias-Tutorials/files/GUID-EEA9ABA1-1B0A-43A7-AC36-ED4E89BB8F4D.htm) explains how early blends can obscure bad proportions and create expensive rework. Large soft shapes may appropriately start as blends; this is a diagnostic method, not a demand for a sharp final design.

Assign edge profiles by component and manufacturing reference. A stamped panel, rubber seal, cast housing, and machined fastener need different sections and radii. Nathan Young demonstrates varying bevel treatment by surface group in [Marmoset's artist breakdown](https://marmoset.co/posts/toolbags-bevel-shader-in-action-3-artists-weigh-in/). Variation should have a reason. Do not randomly roughen every edge. Check whether a shader bevel survives the destination workflow or needs geometry/baking.

## Build the finish from observed layers

Separate base material, coating, and local surface condition. For coated paint, the outer finish can have a different reflection width from the underlying layer; [Marmoset's clearcoat tutorial](https://marmoset.co/posts/create-clearcoat-materials-in-toolbag-4/) illustrates this. Match any metallic-flake contribution to the actual finish and delivered pixel scale. An opaque painted metal panel does not automatically need bare-metal response across its surface.

Roughness controls how concentrated the reflection appears; texture resolution and UV density affect material boundaries. Use these deliberately to distinguish paint, rubber, glass, plastic, and exposed metal. Add fine variation only where supported by reference and visible at the intended distance. See [Adobe's PBR Guide, Part 2](https://www.adobe.com/learn/substance-3d-designer/web/the-pbr-guide-part-2).

Test materials under more than one lighting environment while retaining paired camera/exposure settings for comparisons. Adobe's [OpenPBR best practices](https://experienceleague.adobe.com/en/docs/substance-3d/general-knowledge/openpbr/openpbr-overview#best-practices-for-material-creation) recommend incremental material construction and warn against tuning a finish for only one scene. Translate physical behavior to supported Blender and game-engine features; shader parameter names and numerical responses are not necessarily interchangeable.

## Preserve the improvement through baking and export

Use geometry for important silhouette and visible depth. Reserve normal maps for suitable surface detail; they encode direction rather than actual displacement. Give the runtime mesh enough curvature resolution and keep it close to the source shape. Hold triangulation, UVs, normals, and tangent interpretation consistent between baking and runtime. Inspect normal-map orientation, projection errors, seams, and the final texture at delivery resolution and mip levels. A good high-resolution bake does not establish the quality of its compressed or downsampled runtime form. [Marmoset's baking tutorial](https://marmoset.co/posts/toolbag-baking-tutorial/) explains these failure modes.

After subdividing or retriangulating a reflective surface, compare the interpolated fields inside its triangles as well as the retained corners. Sampling and normalizing a new corner direction can change the field between vertices even when the physical surface is unchanged. Distinguish preservation of an accepted field from authoring a new target for an intentionally changed shape. If repeated refinement cannot meet the declared error and budget together, reconsider the topology or surface construction before adding more triangles.

## Run one representative comparison before expanding

This is a proposed validation exercise, not a claim that the researched methods have already improved the current asset:

1. Choose one troublesome assembly with broad curvature and an opening, such as a fender around a lamp or a roof/window corner. Save the accepted baseline separately.
2. State the defect and isolate the cause. Compare the current construction with a guide-based or otherwise simplified surface candidate using identical shape targets, cameras, materials, and lighting.
3. Inspect a silhouette view, a grazing reflection sweep, and a section through the assembly. Check whether the repaired area creates a kink, thickness error, or gap in its neighbors.
4. Export that candidate and inspect the same defect in the destination engine at actual play/showroom distances. Record both the visible result and the cost in geometry, materials, and rendering.
5. Expand the method only if it improves the observed defect and preserves adjoining surfaces and delivery constraints. Otherwise revise the hypothesis. Adding microdetail does not resolve a failed broad-form comparison.

Use the production checkpoints in [game-assets.md](game-assets.md) for the wider asset. Keep research confidence, helper validation, observed visual improvement, and any required human approval as separate evidence.
