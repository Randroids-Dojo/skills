# Clean Slop — Rules

A frontend looks like "AI slop" when it carries the generic tells of a one-shot LLM design: random glows, a purple gradient, Inter everywhere, harsh white borders, stock photos, and lazy component states. These rules give you (1) the **vocabulary** to name each tell, (2) a **concrete fix** for each, and (3) a **prevention workflow** so the next prompt doesn't reintroduce it.

**Tells are generational and self-consuming.** Purple gradients were the 2024–25 tell; the popular escape routes (cream + serif "warm editorial", faux-analog quirk, the Space Grotesk pairing) are the 2026 tells. This ruleset covers both waves plus copy slop — and the meta-rule is that any *counter-aesthetic* gets absorbed within a year. The only durable defense is specificity: real content, real constraints, real voice, opinionated choices tied to what the product actually does.

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

Layout-pattern slop:

- [ ] **Unmodified shadcn/Tailwind defaults** (stock tokens, radius, shadows, indigo accent)
- [ ] **Centered hero + three identical feature cards** (or default bento grid), badge/pill above the H1
- [ ] **Stat banner row** ("10k+ users / 99.9% uptime") and numbered **step strip** (01–02–03)
- [ ] **Gradient hero text** (background-clip headline)
- [ ] **Emoji as icons**
- [ ] **Colored left borders** on callouts; **cards nested in cards**

Second-generation slop (the "anti-slop" look):

- [ ] **Warm-editorial default** (cream + serif + coral/sage) — the new purple
- [ ] **Escape-combo fonts** (Space Grotesk + Instrument Serif, lone serif-italic accent word)
- [ ] **CSS-faked imperfection** (rotated stickers, fake tape, stamps, marker underlines, dot-grid paper)

Copy slop:

- [ ] **LLM vocabulary** (delve, seamless, elevate, unlock, empower, "in today's fast-paced world")
- [ ] **LLM constructions** ("It's not X, it's Y", rule of three, "No X. No Y. Just Z.", em-dash density, slogan stacks)

---

## Visual & color slop

### 1. Random lights / glows  ← the worst offender

Glowing blobs and light flares sprinkled across the page. Reads as "sass-ish" and is everywhere in AI output.
- **Fix:** Remove almost all of them. Keep at most one or two, and only where they're intentional and tasteful.
- **Prompt:** `Remove the random glows/lights. Keep at most one subtle light, only if it serves the focal point.`

### 2. Purple gradient

The signature "AI slop, very 2025" look — purple gradient hero, purple accent everywhere. Root cause: Tailwind UI's `bg-indigo-500` default saturated the training data.
- **Fix:** Choose a distinctive palette instead — but **beware: beige/earth-tone/off-white is now the default escape and a tell in itself (see #21)**. Derive the palette from the brand's subject matter, not from a counter-trend.
- **Prompt:** `Replace the purple gradient. Derive a palette from [what the product actually is]; one restrained accent, no template beige.`

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
- **Fix:** Pick a distinctive Google Font and try a few until it feels right. Get familiar with the catalog (free). Serif headings, or faces like **Urbanist**, can work — but **the most-recommended escape pairing is now a tell too (see #22)**. Pick faces nobody would predict.
- **Prompt:** `Change the font away from Inter. No Space Grotesk / Instrument Serif either. Show me 3 pairings with a distinctive display face.`

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

## Layout-pattern slop

The default skeleton every one-shot landing page shares. Ranked data from mined Reddit discussions (github.com/JCarterJohnson/vibecoded-design-tells) puts these at the top of "how people spot AI sites."

### 15. Unmodified shadcn/Tailwind defaults  ← the #1 named tell

Stock tokens, default radius, default shadows, `bg-indigo-500` accents. shadcn is explicitly designed to be copy-pasted by AI agents, so the untouched look reads as "nobody made a decision here."
- **Fix:** Override the tokens: radius, shadow scale, spacing, and above all the accent color. Keeping shadcn is fine; keeping its defaults is not.
- **Prompt:** `Re-theme the shadcn/Tailwind defaults: custom radius, shadows, spacing scale, and accent. No stock indigo.`

### 16. Centered hero + three identical feature cards

Oversized centered hero, vague headline, badge/pill floating above the H1, then a 3-column grid of same-height cards (thin-line icon, heading, two lines of text). Default bento grids are the same reflex in a different shape.
- **Fix:** Break the triptych: asymmetry, varied rhythm, one distinctive layout primitive repeated with intent. Test: strip all text from a screenshot — is the layout still distinctive, or just cards in rows?
- **Prompt:** `Break the three-card grid: asymmetric layout, varied card sizes. Cut the badge above the H1.`

### 17. Stat banner & numbered step strip

"10k+ users / 99.9% uptime / 24/7 support" rows and 01–02–03 "How it works" strips. Filler patterns that assert credibility instead of showing it — worse when the numbers are invented.
- **Fix:** Real numbers with real sources, or cut the section. Show the product doing the thing instead of a strip claiming it does.
- **Prompt:** `Remove the stat banner and step strip. Replace with one concrete proof: screenshot, demo, or a real metric.`

### 18. Gradient hero text

A gradient-filled headline via `background-clip` — the text equivalent of the purple gradient.
- **Fix:** Solid ink. Let the typeface carry the headline.
- **Prompt:** `Remove the gradient text fill — solid-color headline.`

### 19. Emoji as icons

Emojis standing in for an icon system in nav, cards, and section headers.
- **Fix:** A real, distinctive icon set (see #14) — or no icons at all.
- **Prompt:** `Replace the emoji icons with [icon set], or drop the icons entirely.`

### 20. Colored left borders & nested cards

A colored left border on every callout ("almost as reliable a sign of AI design as em-dashes for text"), and cards inside cards inside cards.
- **Fix:** Vary callout treatment: background tint, type weight, spacing. Flatten the nesting — group with whitespace and typography, not boxes.
- **Prompt:** `Remove the colored left borders and un-nest the cards. Group with spacing and type instead of boxes.`

---

## Second-generation slop — the "anti-slop" look

If your "fix" is on this list, it is not a fix anymore. These are the escape routes from first-wave slop that got absorbed back into the models' defaults.

### 21. Warm-editorial default (cream + serif + coral/sage)

The reflex escape from AI purple: cream/beige canvas, literary serif headlines, coral or sage accents, "considered" editorial vibe. Now flagged as an emerging AI default in its own right — and it reads specifically as the Claude/Anthropic house style (ivory, book-cloth coral, serif display), which anyone who uses claude.ai recognizes on sight.
- **Fix:** Derive the palette from the brand's actual subject matter, not from a counter-aesthetic. Push at least one hue off the template median (newsprint yellow instead of ivory, printer's red instead of coral). One dominant + one accent + one neutral, with tokens named for function, not decoration.
- **Prompt:** `Cream-and-serif is the new default. Derive the palette from [what the product actually is] and move each hue off the template median.`

### 22. Escape-combo fonts

Space Grotesk headlines + Inter body + Instrument Serif italic accents — or the lone serif-italic word inside an otherwise-sans page. The most-recommended "fix" pairing of 2025, therefore now a tell.
- **Fix:** Same principle as #11, one level deeper: pick faces nobody would predict, pair display + body from different families with intent. Models to study: Stripe, Vercel, Linear — all commissioned or customized type rather than adopting a trend pairing.
- **Prompt:** `No Space Grotesk / Instrument Serif / lone-serif-italic-accent. Propose 3 pairings with a display face that has a reason to be here.`

### 23. CSS-faked imperfection

"Hand-made" signals synthesized entirely in code: `rotate(-1deg)` stickers, fake tape from translucent rectangles, double-border stamps, `::after` marker underlines, dot-grid paper texture. Imperfection is supposed to signal a human hand; perfectly regular, programmatic imperfection signals the opposite — a designer clocks it in seconds.
- **Fix:** One real artifact recontextualizes everything around it: a scan, a photograph, actual handwriting, or a hand-drawn SVG with genuinely irregular strokes. If every "imperfect" element on the page is a CSS transform, cut half of them and make one real.
- **Prompt:** `Replace the CSS-faked analog elements with one real artifact (scan / photo / hand-drawn SVG). Delete the rest of the fake quirk.`

---

## Copy slop

Copy is scanned before design is. The same page can pass a visual audit and still scream AI in its first headline.

### 24. LLM vocabulary

delve, seamless, elevate, unlock, unleash, empower, supercharge, streamline, effortless, robust, comprehensive, cutting-edge, game-changing, next-gen, revolutionize, transform, harness, leverage, journey, landscape, tapestry, testament — and the opener "In today's fast-paced world." (Canonical catalog: en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing.)
- **Fix:** Put a ban list in the prompt. Replace each banned word with what you would actually say to a customer — specifics, numbers, names.
- **Prompt:** `Rewrite without: [ban list]. Concrete claims only — name the feature, the number, the customer.`

### 25. LLM constructions

Negative parallelism ("It's not just X, it's Y" / "The trick isn't X. It's Y."), rule-of-three everything, "No X. No Y. Just Z." chains, em-dash density (~3× human rate), stacks of punchy two-beat slogans, uniform sentence length, hedging ("can potentially help"). One tagline is a brand; five aphorisms per scroll is a language model.
- **Fix:** One tagline, not a lattice. Vary sentence length. Commit to claims instead of hedging. Read it aloud: would the founder say this sentence to a customer?
- **Prompt:** `Rewrite: kill the "It's not X, it's Y" constructions, cut to one slogan, vary sentence length, commit to the claims.`

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

When it feels derivative, flip a section between **light/dark mode**, **change the font**, and shift the palette. Small toggles make the design feel distinct. **Caveat (see #21–22):** don't toggle onto a trend — earth tones / pastels / off-white and the trendy font pairings are now defaults too. Toggle toward something derived from the brand, not toward this year's counter-aesthetic.

---

## Iterate with screenshots
The reliable way to fix issues is to **get your hands dirty**: take a screenshot, point at the exact broken element, prompt the fix, re-screenshot, repeat. One-shot prompts pack in a lot and leave small defects (stray particles, white borders, wrapped buttons) — clean those up one screenshot at a time.

## Model awareness
Different models have different default design tendencies — some lean heavier on glows and density, some put more effort into spacing and hover states, and some (notably Claude) default to their own vendor's house aesthetic when told to avoid the generic one. **Learn your model's defaults** so you know which slop signs to watch for, and lean on references/design systems hardest with the models that need the most steering. No model gets it right bare; references and a design system close the gap.

## Sources worth rereading

- github.com/JCarterJohnson/vibecoded-design-tells — ranked tells mined from 3.2M Reddit posts
- en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing — the definitive copy-tell catalog
- frontend.horse/articles/the-linear-look — the pre-AI ancestor of the dark-glow aesthetic
- developersdigest.tech/blog/ai-design-slop-and-how-to-spot-it — most granular pattern list (16 patterns)
- 925studios.co/blog/ai-slop-web-design-guide — tells plus concrete fixes
