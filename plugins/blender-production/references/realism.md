# Shape, surface, light, and motion

Use these methods for the chosen style. Preserve intentional simplification in stylized work; photographic wear is not mandatory.

## Diagnose before changing

| Symptom | Inspect |
|---|---|
| Toy-like/inflated | Scale, silhouette, edge radius, subdivision, displacement |
| Floating/box assembly | Support, joint fit, contact geometry/shadows |
| Flat material | Roughness, light direction, texture scale, macrostructure |
| Stretched wood | Board-level UVs/axes, distortion, end grain |
| Plastic stone/cloth | Oversized bump, uniform specular, coat, missing shape detail |
| Light leak | Thickness, normals, coincident faces, shadows, probe validity |
| Reflection disappears during turn | Screen-space limits, fallback, probe coverage/parallax |
| Bright dots/grain | Sampling, tiny intense sources, normals, materials, temporal history |
| Denoising smears/crawl | Too few samples/guides, lost detail, temporal inconsistency |

Don't fix a gap with a fill light or darken material to compensate for wrong exposure. Make a causal change and compare identical views.

## Geometry and camera

Start from reference proportions/measurements. Photographs encode perspective, lens distortion, lighting, and sometimes different historical states. Register several views; mark uncertain dimensions. Use subject-appropriate units and coordinates; changing display units does not rescale existing geometry/physics.

Silhouette, parallax, intersections and visible cast shadows generally require geometry. Establish large forms before microtexture. Give solids thickness where views/optics require it; inspect boolean results, coplanar surfaces, normals, joins, support and seams after modifiers.

Plausible mesh bevels provide real highlight surfaces on manufactured edges. Preserve broad planes and intended sharp edges. Subdivision is not a realism switch; shader bevel/displacement support differs by engine. Organic work needs volumes/anatomy/branch structure before pores/leaves. Test intended/extreme poses for deforming assets.

## Material scale and response

Treat each finish as a surface with physical behavior. Check neutral-light swatches and in-scene crops. Use suitable licensed scans with source/license/physical coverage recorded. Generic scan assets do not prove reference fidelity.

Color textures need their intended color interpretation; roughness/normal/height/masks normally use Non-Color. Verify normal-map orientation. Tangent normals need correct UV/tangent interpretation: naive box projection across three axes does not reorient them correctly. Use proper UVs, reoriented triplanar normals, or an appropriate height/bump fallback.

Keep texture frequency in physical units. Object coordinates can change with scale/coordinate object; compare differently sized parts. Align grain with boards, veneer and joinery; handle visible end grain separately.

- Macro: shape, panels, folds, stone courses, branch structure — geometry.
- Meso: joints, larger pores, local wear — geometry/displacement/bump according to projected effect.
- Micro: weave, fine grain, roughness variation — restrained shading at delivery resolution.

Albedo is not measured height. Baked shadows, highlights and color boundaries can create false relief; use actual height where possible and inspect glossy scans for lumps. An albedo-derived bump is an artistic fallback that needs scrutiny. Strong noise everywhere often reduces realism and increases cost.

Roughness is highlight spread. Coat, sheen, transmission, metallic and IOR are distinct controls. Paint is usually dielectric even over metal; exposed metal uses metallic response. Choose a deliberate glass thickness/interface model and check grazing reflections and multi-pane views in the delivery engine.

Wetness changes diffuse appearance and roughness. Cloth needs seams/compression/folds alongside weave/sheen. Wear should follow use/exposure evidence rather than uniform random dirt.

## Light and color

Establish coherent environment/key, fill/bounce, practical lights and shadow structure. Match light direction and apparent size. Manage added Sun energy deliberately if the environment already contains a strong sun. Inspect installed sky enums instead of assuming old tutorial settings.

Record working color space separately from view transform, exposure, look, white balance and display target. AgX is a useful photographic starting transform where supported, not mandatory for technical/stylized work. Recheck materials if color management changes.

Judge contact, shadow depth, highlights and silhouette at fixed camera settings. Preserve important bright/dark detail without flattening contrast. Per-shot exposure changes should be intentional; continuous movement may need a designed transition.

For EEVEE, probe extents, surface validity, parallax and stale indirect/reflection caches can matter more than brightness. Rebuild affected captures after changes. Local captures can be more accurate and cheaper than one huge volume. Benchmark plane probes and inspect reflections when the source leaves screen.

For Cycles, test samples/denoising/light paths against hard views. Check stacked glass/dense transparency before reducing transmission limits. Compare unclamped/undenoised crops when optimizations remove legitimate highlights or microdetail.

## Environments and animation

Use constrained distributions and multiple variants; retain instances. Near assets need recognizable silhouette/depth, distant ones can use LOD. Ground contact, root/trunk support, leaf orientation and canopy gaps matter more than random counts.

Water depends on bed/banks, depth, flow, obstacles, falling-sheet shape, reflections, foam and impacts. Choose animated surfaces or simulation to fit the shot; pilot a bounded cache before expensive bakes. Long-exposure still-water aesthetics differ from believable motion.

Watch for foliage shimmer, reflection pops, loop seams, cloth jitter and denoising crawl. A settled frame does not establish temporal quality.

## Primary reference entry points

[Principled BSDF](https://docs.blender.org/manual/en/latest/render/shader_nodes/shader/principled.html), [color management](https://docs.blender.org/manual/en/latest/render/color_management.html), [EEVEE limitations](https://docs.blender.org/manual/en/latest/render/eevee/limitations/limitations.html), [Cycles material settings](https://docs.blender.org/manual/en/latest/render/cycles/material_settings.html). Select installed-version docs and verify uncertain behavior with a small scene.
