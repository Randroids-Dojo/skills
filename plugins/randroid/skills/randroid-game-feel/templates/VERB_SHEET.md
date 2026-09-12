# Core interaction

Fill this only where an existing GDD or task record does not already answer it. Keep the scope proportional to the slice.

Genre and intended pace: [action / turn-based / puzzle / card / text / clicker / other]
Intended input and accessible alternatives: [controls]
Viewing mode: [game camera / close inspection / board / text interface]
Representative starting state: [scenario and build]

| Player action | Input | Consequence | Constraint, uncertainty, or tradeoff | Acknowledgment and result feedback | Verification |
| --- | --- | --- | --- | --- | --- |
| Steer through a bend | Held steering input | Vehicle changes heading and follows traction limits | Speed, road edge, traffic | Wheel/body response, road sound, stable camera | Drive bend, release input, recover from edge contact |
| Commit a tactical card | Select target then confirm | Cost paid once and effect resolves on chosen target | Resources and opponent response | Target preview, confirmation, resolved effect | Legal move, invalid target, cancel, double-submit |
| [Requested action] | [Input] | [Expected transition] | [Meaningful constraint] | [Visible/audible/other cues] | [Repeatable scenario] |

## Smallest useful test

What uncertainty could force the largest rework? [interaction, decision, assembly, camera, performance]
What representative experiment will test it? [small slice]
For a movement toy, what should control feel like without extra goals? For a strategy or text game, what minimal goal/context makes the decision meaningful? [applicable answer]

## First action and recovery

How does the player understand and reach the first meaningful action? [affordance and necessary setup]
What happens on success, rejection, failure, release, or cancel? [applicable states]
What remains perceivable with audio muted, reduced motion, or alternative input? [affected modes]

## Supporting interfaces

Which menus, widgets, text, or configuration serve the core interaction or accessibility? [purpose]
Which unrelated content can wait until that interaction works? [deferred scope]

## Done when

Observed state transition and feedback: [criteria]
Required checks and evidence location: [paths]
Remaining human judgment, if required: [gate and reviewable build]
