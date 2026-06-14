# Clean Slop — Rules

A frontend looks like "AI slop" when it carries the generic tells of a one-shot LLM design: random glows, a purple gradient, Inter everywhere, harsh white borders, stock photos, and lazy component states. These rules give you (1) the **vocabulary** to name each tell, (2) a **concrete fix** for each, and (3) a **prevention workflow** so the next prompt doesn't reintroduce it.

The single most useful habit: **learn the names of these problems.** Once you can say "that's a lazy selected state" or "kill the random lights", you can prompt the fix precisely instead of vaguely asking to "make it look better".

## How to use

1. **Scan** the design (or a screenshot of it) against the Slop Signs checklist below.
2. For each hit, apply the **Fix** — either edit the code directly or issue the named **fix-prompt**.
3. Re-screenshot and repeat. Slop is removed iteratively, not in one shot.
4. Bake the **Prevention** rules into the project's `AGENTS.md` / design system so it stops coming back.

When given an image or a running URL, take a screenshot first and point at the *exact* element when prompting a fix — vague prompts produce vague fixes.

---

## Slop Signs — scan checklist

Quick pass; details and fixes follow.

- [ ] **Random lights / glows** scattered around the layout
- [ ] **Purple gradient** (or purple as the default accent)
- [ ] **Too many colors** / clashing colors (e.g. gray next to purple)
- [ ] **Inter** (or another over-used default font)
- [ ] **Harsh white/light borders** on cards and sections
- [ ] **Lazy selected state** — just a border, and uneven
- [ ] **Eyebrow** kicker in cramped, over-tracked all-caps
- [ ] **Pointless status pill** appearing out of nowhere
- [ ] **Uneven spacing** (top ≠ left, inconsistent rhythm)
- [ ] **Inconsistent section shapes** (rounded card on a square design)
- [ ] **Button text wrapping** to two lines
- [ ] **Unsplash / generic stock photos**
- [ ] **Illustrations** where a real photo/image belongs
- [ ] **Lucide** (or the default icon set everyone uses)

---

## Visual & color slop

### 1. Random lights / glows  ← the worst offender
Glowing blobs and light flares sprinkled across the page. Reads as "sass-ish" and is everywhere in AI output.
- **Fix:** Remove almost all of them. Keep at most one or two, and only where they're intentional and tasteful.
- **Prompt:** `Remove the random glows/lights. Keep at most one subtle light, only if it serves the focal point.`

### 2. Purple gradient
The signature "AI slop, very 2025" look — purple gradient hero, purple accent everywhere.
- **Fix:** Choose a distinctive palette instead: **earth tones, pastels, off-white, beige, green earth tones.**
- **Prompt:** `Replace the purple gradient. Use a [beige / earth-tone / off-white] palette with one restrained accent.`

### 3. Too many / clashing colors
Multiple unrelated hues; colors that don't belong together (gray paired with purple).
- **Fix:** Constrain to a small, cohesive palette (one accent + neutrals). Define it in the design system.
- **Prompt:** `Constrain the palette to [neutral base] + one accent. Remove colors that don't fit.`

### 4. Harsh white borders
Bright 1px white/light borders outlining every card and section.
- **Fix:** Use **border gradients** or subtle low-contrast borders that match the surface.
- **Prompt:** `Replace white borders with subtle border-gradients (or low-contrast borders matching the background).`

---

## Component & layout slop

### 5. Lazy selected state
The selected menu/tab item is "just a border" — and the border is uneven.
- **Fix:** Make selection intentional and even: a background fill, weight/colour change, or a clean underline with consistent geometry.
- **Prompt:** `Give the selected nav item a real selected state (background fill or weight change), with even, consistent borders.`

### 6. Eyebrow (kicker) cramped in all-caps
The small label above a heading: ALL CAPS with too much letter-spacing, jammed too close to surrounding content.
- **Fix:** Moderate the tracking, give it breathing room — or drop it if it adds nothing.
- **Prompt:** `Fix the eyebrow: reduce letter-spacing, add spacing around it, or remove it.`

### 7. Pointless status pill
A status indicator that appears "out of nowhere" and isn't meaningful, with uneven spacing.
- **Fix:** Remove it unless it conveys real information. If kept, give it **equal top and left spacing**.
- **Prompt:** `Remove the status pill — it's not meaningful. (If kept, equal padding top and left.)`

### 8. Uneven spacing
Inconsistent gaps; top spacing ≠ left spacing.
- **Rule:** Keep the **same spacing top and left**, and a consistent spacing scale across the page.
- **Prompt:** `Even out the spacing — same top/left padding, consistent vertical rhythm between sections.`

### 9. Inconsistent section shapes
One section (often pricing) uses rounded cards while the rest of the site is squared off (or vice versa).
- **Fix:** Match border-radius and visual treatment to the rest of the page.
- **Prompt:** `Make the pricing section consistent with the rest — match the [square/rounded] corner style.`

### 10. Button text wrapping to two lines
A button whose label breaks onto two lines.
- **Fix:** Shorten the label, widen the button, or set `white-space: nowrap`.
- **Prompt:** `Keep button labels on one line — shorten the text or widen the button.`

---

## Content slop

### 11. Inter (and other default fonts)
Inter is the AI default; it instantly reads as generic. Other "AI always reaches for this" fonts have the same problem.
- **Fix:** Pick a distinctive Google Font and try a few until it feels right. Get familiar with the catalog (free). Serif headings, or faces like **Urbanist**, are good escapes from the default.
- **Prompt:** `Change the font away from Inter. Try [serif heading + clean sans body], options: Urbanist / [others]. Show me a couple.`

### 12. Unsplash / generic stock photos
Recognizable stock imagery screams AI slop.
- **Fix:** **Generate** images (or use intentional, on-brand photography). Avoid Unsplash.
- **Prompt:** `Replace the stock/Unsplash images with generated, on-brand images.`

### 13. Illustrations where a photo belongs
Models default to illustrations for heroes that should use real images.
- **Fix:** Explicitly call for images/photos.
- **Prompt:** `No illustrations — use real images for the hero (and anywhere a photo fits better).`

### 14. Lucide (and default icon sets)
Lucide is the icon set everyone ships, so it reads as generic.
- **Fix:** Use a distinctive set — e.g. **Basil** or **Iconoir**.
- **Prompt:** `Swap Lucide icons for [Basil / Iconoir].`

---

## Prevention workflow

Stop slop at the source instead of cleaning it up every time.

### Never prompt bare — bring a design system or taste skill
Don't ship `create a beautiful landing page in dark mode`. Always attach **a design system (`design.md`)** or a **taste/design skill**. A bare, unspecific prompt is what produces slop in the first place.

### Use references (mood board + URL)
- **Image reference:** screenshot a design you admire and drop it into the prompt as a starting point. Designers call this a mood board — same idea with AI.
- **URL reference:** import/screenshot a site you like (it screenshots the whole page for you) as scaffolding.
- **Then make it yours:** change the brand, names, numbers, colors, and fonts so the result is *inspired by*, not a *copy of*, the reference.

### `design.md` vs HTML reference — know the trade-off
- **HTML reference** is **richer and more prescriptive** — it includes animations and *guarantees* the result looks like what you saw.
- **`design.md`** is a **system/process** (typography, colors, spacing, motion). It is **not a guarantee** — given only a hero or pricing snippet it can still look bad; it mostly hands over colors and type.
- Use HTML when you need the look reproduced faithfully; use `design.md` when you want a reusable system across pages.
- You can turn any design into a `design.md` by exporting it to HTML and asking an LLM to "turn this into a design system in markdown — typography, colors, spacing, motion."

### Put minimal durable rules in `AGENTS.md`
`AGENTS.md` runs on every prompt — keep it **minimal**. Good things to pin: preferred/forbidden fonts (e.g. "never Inter"), the palette, the icon set, which browser to use, the default style. Reference the design system / skill from here.

### Prompt away specific mistakes
Name the exact fix rather than asking for "better":
- `No illustrations — use images for the hero.`
- `Alternate section: dark background, beige accents.`
- `More spacing between sections.`
- `Add a pricing section / trusted-by logos / footer.`
- `Turn this section into dark mode.`

### Borrow patterns from a pattern library
For a specific component (e.g. a pricing section), find the pattern on a library like **Mobbin**, screenshot it, bring it back as a reference, and prompt: `Adapt this into my design, replace the pricing section, and put it in dark mode.` A screenshot alone isn't enough — feed it back as an explicit reference and tell it to adapt, not copy.

### Know the standard landing-page sections
So you can ask for what's missing: **hero, trusted-by (logos), features, pricing, testimonials, contact form, story/about, footer.**

### Animations & polish (one pass each)
- **Animations:** one prompt — `rich interactions and smooth scroll`.
- **Polish checklist:** fully responsive · **SVG logo only** (just the logo, not every brand logo — that bloats the code) · tasteful shadows · border gradients · background blur · generated images/video over plain color fills.

### Toggle to escape "looks like another site"
When it feels derivative, flip a section between **light/dark mode**, **change the font**, and shift the palette toward **earth tones / pastels / off-white**. Small toggles make the design feel distinct.

---

## Iterate with screenshots
The reliable way to fix issues is to **get your hands dirty**: take a screenshot, point at the exact broken element, prompt the fix, re-screenshot, repeat. One-shot prompts pack in a lot and leave small defects (stray particles, white borders, wrapped buttons) — clean those up one screenshot at a time.

## Model awareness
Different models have different default design tendencies — some lean heavier on glows and density, some put more effort into spacing and hover states. **Learn your model's defaults** so you know which slop signs to watch for, and lean on references/design systems hardest with the models that need the most steering. No model gets it right bare; references and a design system close the gap.
