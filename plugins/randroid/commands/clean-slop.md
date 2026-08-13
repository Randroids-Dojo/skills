# Randroid Clean Slop

Detect and fix AI "slop" in a vibe-coded UI — visuals and copy, first-generation tells and the "anti-slop" second generation — and prevent it from coming back.

## When to use

- A design "smells like AI" — generic, one-shot LLM look.
- The user asks to "de-slop", clean up, or make a frontend look less AI-generated.
- A final polish pass before shipping a vibe-coded UI.

## Flow

When this command is invoked:

1. Read the full ruleset at `${CLAUDE_PLUGIN_ROOT}/clean-slop-rules.md`.
2. If a screenshot or running URL is available, capture/look at it first; otherwise scan the relevant frontend code.
3. Run the **Slop Signs** scan (quick list below). For every hit, apply the named **Fix** / fix-prompt from the ruleset.
4. Re-screenshot and repeat — slop is removed iteratively, not in one shot.
5. Offer to bake the **Prevention** rules into the project's `AGENTS.md` / design system so it stops recurring.

## Quick scan

- Random **glows/lights** scattered around
- **Purple gradient** / purple default accent
- Too many / **clashing colors**
- **Inter** (or another over-used font)
- Harsh **white borders**
- Lazy **selected state** (just a border, uneven)
- Cramped all-caps **eyebrow**, pointless **status pill**, **uneven spacing**
- **Inconsistent section shapes**, **button text wrapping** to two lines
- **Unsplash/stock photos**, **illustrations** where photos belong
- **Lucide** (or default) icons
- **Unmodified shadcn/Tailwind defaults**, **gradient hero text**
- **Centered hero + three identical feature cards** / default bento grid, badge above the H1
- **Stat banners**, numbered **step strips**, **colored left borders**, cards nested in cards
- **Emoji as icons**
- **Warm-editorial default** (cream + serif + coral/sage) — the new purple
- **Escape-combo fonts** (Space Grotesk + Instrument Serif)
- **CSS-faked imperfection** (rotated stickers, fake tape, stamps, marker underlines)
- **Copy slop**: LLM vocabulary ("seamless", "elevate"), "It's not X, it's Y", slogan stacks, em-dash density

## Full ruleset

The named fix for every sign plus the prevention workflow (design systems, references, palettes, fonts, icons, sections, animations, polish) lives in `${CLAUDE_PLUGIN_ROOT}/clean-slop-rules.md`.
