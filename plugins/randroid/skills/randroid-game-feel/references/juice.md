# Tune feedback around the action

Use this for a specific verb or event after its state transition works. Select effects that communicate what happened, where, and with what importance. Do not apply a genre's entire effects vocabulary to every game.

## Diagnose first

Capture the same action with fixed scene/camera conditions. Identify whether the problem is input delay, unreadable contact, missing acknowledgment, weak weight, ambiguous failure, or noise obscuring the next decision. Change a coherent cause and compare again. Adding more effects is not automatically an improvement.

Separate three times: input received, action acknowledged, and consequence resolved. Real-time controls usually benefit from prompt acknowledgment; deliberate anticipation, turn resolution, and network authority may delay the outcome. Pick a target based on that design and measure it with timestamps plus visual inspection. Screenshot polling alone cannot establish input latency.

## Select feedback by meaning

| Event | Candidate feedback | Check |
| --- | --- | --- |
| Steering or acceleration | Body load, wheel motion, road sound, stable camera response | The feedback agrees with traction and does not add steering delay |
| Contact or attack | Local impact motion, sound, recoil, a restrained flash | Contact location and severity remain readable through repeated impacts |
| Card or tactical selection | Clear focus/selection, preview of costs and targets, confirmed resolution | Pointer, keyboard, and supported assistive paths communicate the same state |
| Invalid action | Local rejection cue and an understandable reason | The player can distinguish rejection from input loss |
| Pickup or reward | Object response, affected inventory/count, optional sound | The reward is perceived without obscuring the next action |
| Failure and recovery | A clear changed state, relevant consequence, accessible retry path | The player knows what happened and regains control as designed |

Use complementary channels when helpful, with a visual or otherwise accessible alternative for essential sound cues. Muting audio or reducing motion must not remove the only signal. Quiet interaction, instant snapping, and a locked camera may be intentional.

## Keep effects bounded

- **Motion:** use recoil, follow-through, squash, or a transition where they communicate weight or continuity. Keep deformations on the visual rig and return to a known rest state. Rapid repetition should not accumulate permanent scale or offsets.
- **Camera:** test follow response in the real view before adding shake. If smoothing is wanted, use time-based damping such as `alpha = 1 - exp(-lambda * dt)` rather than a fixed fraction per frame. Constrain collision and horizon behavior. Test high and low frame rates and reduced motion.
- **Hit-stop:** apply only where pausing clarifies impact. Define which simulation, input, camera, and effects clocks continue. Keep it out of authoritative network/physics timing unless the design explicitly supports it. Check chained contacts, buffering, and pause/resume.
- **Particles and flashes:** place them at the actual event, cap count/lifetime, and check the worst plausible burst. Preserve target readability; compare without flashes or motion when requested by accessibility settings.
- **Audio:** connect it to the real event, handle unavailable/locked output without breaking play, cap overlapping voices, and test repetition and mute. Intensity and variation should convey the event rather than mask it.
- **Input forgiveness:** buffering, coyote time, aim assistance, and cancellation can serve particular designs. Choose duration in time units, preserve the intended difficulty, and test near-boundary cases instead of copying a fixed frame count.

Start with the smallest visible change. Tune magnitude and duration in the actual camera and frame-rate range. A physics driving game should not inherit platformer squash or shooter hit-stop merely because the skill lists them.

## Verification

Exercise success, failure, release/cancel, rapid repeat, overlapping events, and affected accessibility modes. Check that effects return to rest, state changes happen once, and frame-time or memory cost stays within the project budget. Record the before/after scenario, settings, and observed improvement. Subjective preference needs player judgment when it is a required gate.
