# Release Playtest Checklist

> **The second gate.** When all coverage rows in `docs/GDD_COVERAGE.json` are `done`, this checklist becomes the active backlog. The loop is not finished until every item here is checked or explicitly deferred to a future release.
>
> This exists because shipping a complete-on-paper system is not the same as shipping a good system. Coverage rows track *systems*; this checklist tracks *experience*. Both gates must close.

## How to use this doc

- Each section captures one experience-level question the systems-level coverage will not catch.
- Items use `[ ]` checkboxes. Check when the experience is verified (live playtest, recorded session, or qualitative review).
- An item that fails review becomes a new `F-NNN` entry in `docs/FOLLOWUPS.md` with `Priority: blocks-release`.
- Re-run the relevant section after any large system lands.

## First 90 seconds

The window where a new player decides whether to keep playing.

- [ ] First-time experience does not require external instructions. The user understands the goal within 30 seconds.
- [ ] First input has a visible, satisfying response (sound, motion, particle, animation).
- [ ] No dead ends, modal dialogs, or auth walls in the first minute.
- [ ] If the user does nothing, the screen still communicates what to do.
- [ ] First completion of the core action delivers a clear positive signal.

## Core loop fun

The minute-to-minute moment-to-moment quality.

- [ ] The core action is satisfying when performed perfectly.
- [ ] The core action is satisfying when performed imperfectly (no harsh punishment for trying).
- [ ] The user can tell, without reading the HUD, whether they are doing well.
- [ ] Repetition does not become tedious within a 5-minute session.
- [ ] Difficulty curve has clear progression. Plateaus are intentional.

## Variety and surprise

- [ ] At least three meaningfully different situations / opponents / states / levels exist.
- [ ] Each variation feels distinct from the others, not a recolor.
- [ ] Random elements (where applicable) produce surprise without producing frustration.

## Session arc

The length of time a user wants to play in one sitting.

- [ ] A session has a clear in / play / out flow. The user can stop cleanly.
- [ ] Progress persists between sessions (saves, leaderboards, profile, settings).
- [ ] Returning users get a "welcome back" signal (recent items, new options, last-played continuation).

## Audio and feel

- [ ] No audio loop is fatiguing after 5 minutes.
- [ ] Audio reinforces successful actions (positive cues) and warns of failure conditions (negative cues).
- [ ] The user can mute / adjust audio without leaving the experience.

## Performance and reliability

- [ ] Frame rate stays inside acceptable bounds on the lowest target hardware.
- [ ] No reproducible crash, hang, or visual artifact in 15 minutes of play.
- [ ] Loading times are acceptable, or are masked by something the user enjoys watching.

## Accessibility

- [ ] Text is readable at the smallest target screen size.
- [ ] Color is not the sole channel for any critical information.
- [ ] Keyboard / gamepad / touch parity is maintained for all primary actions.
- [ ] Motion-sensitive users have a "reduce motion" path.

## Deferred

Items intentionally pushed to a future release. Each one names the release.

(none yet)
