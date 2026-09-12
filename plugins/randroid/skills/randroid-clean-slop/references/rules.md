# Diagnose generic interfaces and copy

Use this reference for interfaces and copy. For games and 3D assets, use [game-assets.md](game-assets.md). Review the actual design against its purpose, audience, content, and established brand. Familiar fonts, palettes, and components are not defects by themselves.

## Locate the visible problem

Inspect a running screen or supplied capture before changing style. Name the exact element and the experience it harms: competing focal points, an unreadable selected state, unsupported claims, generic imagery that misrepresents the product, or repeated layout that obscures meaningful differences.

Distinguish structure, content, component state, and decoration. Fix the earliest relevant cause. A new font will not repair an unclear hierarchy; more texture will not give an interchangeable product a specific identity. Compare a coherent change with matched captures before extending it across the product.

## Visual and component clues

| Observed pattern | What to inspect | Candidate correction |
| --- | --- | --- |
| Random glows, gradients, blur, or flares compete with content | Focal hierarchy and whether light implies a meaningful layer | Remove competing decoration; preserve intentional brand treatments |
| Palette feels arbitrary or too busy | Semantic roles, contrast, and relation to the actual subject | Define a coherent set of roles and use color where it conveys something |
| Every element has a harsh outline or nested card | Grouping and hierarchy; whether borders are functional | Group with spacing, type, or restrained surfaces while retaining necessary boundaries |
| Selection is only a faint or uneven border | Visibility of hover, focus, selected, disabled, and error states | Make states legible with consistent geometry and more than color where needed |
| Eyebrow text is cramped or over-tracked | Whether the label adds context and remains readable | Improve tracking and spacing, or remove redundant text |
| A status pill appears without a real status | Data source, meaning, and relation to the adjacent content | Bind it to actual state or remove it |
| Spacing or corner styles vary without purpose | Relationships between elements, the spacing scale, and component roles | Align related elements and restore a deliberate rhythm; equal horizontal/vertical padding is not mandatory |
| Button labels wrap or clip badly | Narrow widths, localization, zoom, and the importance of the full label | Adjust layout or concise wording; avoid forcing nowrap when it creates overflow |
| Typography looks undifferentiated | Hierarchy, measure, weight, line height, content, and existing brand | Fix type roles first; change the font only when that serves the design |
| Stock imagery or illustrations feel unrelated | Whether the image actually explains the product, people, place, or work | Use relevant authorized material; do not replace documentary evidence with generated imagery |
| Icons look inconsistent or redundant | Stroke/scale consistency, labels, affordances, and meaning | Use a coherent treatment or remove unnecessary icons; a common icon library may be appropriate |

Purple, Inter, Lucide, a serif, or an unmodified component library can all be appropriate. Their presence is a prompt to inspect intent, never an automatic replacement rule. The useful question is what this choice does for this product.

## Layout and identity

**Centered hero and repeated cards:** inspect whether all content really has equal importance. If a uniform grid hides a key difference, introduce hierarchy tied to that difference. Asymmetry and varied card sizes are options, not default remedies.

**Bento grids and nested surfaces:** check whether grouping helps comparison or simply adds containers. Flatten layers that carry no relationship. Preserve consistent layouts where users benefit from predictable scanning.

**Metrics, testimonials, and step strips:** verify the underlying claims and their relevance. Remove invented proof. Use an actual demonstration, approved customer statement, or traceable metric when available; leave unsupported content out rather than fabricate it.

**Gradient headlines and decorative callouts:** assess legibility, emphasis, and how often the treatment appears. Reduce competing treatments when they weaken the main message. Do not replace every border with a different fashionable border.

**The counter-template trap:** a cream/serif palette, unusual font pairing, fake tape, tilted sticker, or grain texture can become just another interchangeable preset. If a change only swaps one stock appearance for another, return to content, hierarchy, imagery, and interaction. Intentional minimalism and familiar conventions remain valid.

Use a specificity check: with names and logos hidden, which choices still communicate the product's purpose? A generic answer is reason to investigate, not a mandate to make every component novel.

## Copy

Replace vague promises with the concrete action, outcome, and limits supported by the product. Words such as “seamless,” “unlock,” or “empower” often conceal missing information; inspect the sentence rather than applying a universal word detector.

Reduce repeated slogan stacks, contrast constructions, and uniform sentence patterns when they make the content harder to understand. Do not remove necessary uncertainty or turn an aspiration into a factual claim just to sound confident. Preserve the user's requested tone.

For each substantial claim, identify what supports it. Do not invent user counts, performance figures, testimonials, awards, certifications, or capabilities. A visual cleanup request does not authorize changing prices, commitments, or product behavior.

## References and durable prevention

Use references to identify concrete relationships: content hierarchy, image scale, type rhythm, navigation, or interaction states. Respect reference rights and the existing brand. Changing names, colors, and fonts does not by itself establish an original design.

An HTML example can expose structure and motion; a design document can define reusable roles and constraints. Neither guarantees a good result in a new context. Adapt to the actual content and inspect the running product.

After a correction is accepted, record the smallest useful project rule in the existing design system or instruction file. Prefer “selection must remain visible at keyboard focus” or “use the real product capture in this flow” over universal font/color bans. Do not add instruction files or a new design system for a tiny adjustment unless that work is requested or needed.

## Compare and stop

Use the same content and matched view settings before and after. Check affected desktop/narrow layouts, zoom or text expansion, keyboard states, contrast, and behavior as applicable. Avoid smoothing or animation that obscures state or interferes with user preferences.

When two comparable attempts leave the same major issue, reassess the structure or content before another decorative pass. Keep a current candidate and accepted baseline. Finish with visible changes, evidence, and unresolved choices. Stop when the requested design problem is addressed; an endless search for a less common font is not a completion condition.
