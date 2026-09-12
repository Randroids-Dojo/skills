# Verify the intended interaction

Start with the exact claim and the actual play state. Prefer the project's supported deterministic scenario or authorized computer-use tools. Use these optional probes only when their control method is permitted in the current environment; a shipped script does not override tool restrictions.

## Scenario evidence

Record the build/revision, initial state, chosen input, expected transition, observed transition, feedback, and relevant failure/recovery. Use the intended camera or interface. A driving check needs input that changes vehicle motion under the intended physics; a spinning viewer establishes visual motion only. A tactical card check can pass with discrete selection and no idle animation.

Use a repeatable initial state and a no-input/control trial where causality is unclear. Pair state/event timestamps with frames or a short clip. Screenshots show appearance; a clip shows a sampled sequence; event/state evidence establishes what changed. None independently establishes enjoyment.

For changed controls or feedback, exercise the applicable edges: release/cancel, rejected input, rapid repeat, overlap, focus loss, pause/resume, and affected accessibility modes. Do not turn every small edit into every possible test. Run focused checks during iteration and the project's required gates at delivery.

## Optional browser observations

```bash
node <skill-dir>/scripts/game-probe.mjs <url> --out <empty-dir>
node <skill-dir>/scripts/game-probe.mjs <url> --input key --key KeyD --start "#start" --ready "#play-ready" --out <empty-dir>
```

Run from a project with Playwright and its Chromium already installed. Use `--help` for options. Input is **off by default**; choose `none`, `key`, `pointer`, or `both`. A pointer trial sweeps/hover only. The script never guesses a center click. Start/ready selectors must come from the actual page or project context; a start selector must match exactly one element. Choose a meaningful control for the scenario instead of accepting the default key.

The report records canvas/widget observations, rAF requests, idle pixel changes, selected input trials, console errors, and captures. It writes schema version 2. It does **not** grade DOM rendering, text, menus, or the genre. A requestAnimationFrame request is not a rendered frame or simulation tick. Worker and iframe activity may be missed. Audio objects do not prove audible feedback.

## Optional Windows PowerShell 5.1 observations

```powershell
powershell -File <skill-dir>/scripts/native-probe.ps1 -Exe <game.exe> -Out <empty-dir>
powershell -File <skill-dir>/scripts/native-probe.ps1 -Exe <game.exe> -InputMode key -Key SPACE -HoldMs 900 -Out <empty-dir>
```

This launches a visible local test build. Input is off unless `-InputMode key|pointer|both` or `-Drag` is supplied. It confirms the launched process's window and focus before capture and during trials, re-resolves startup windows, and aborts on focus/rectangle changes. It releases held keys/buttons on failure and requests graceful close unless `-KeepOpen` is set. A build that refuses to close remains open.

Use `-ArgumentLine` for game arguments (`-Args` is an alias). The probe cannot inspect the UI tree or authoritative state. Its boot capture follows settling; neither window appearance time nor that capture is time to first control.

## Read observations honestly

Both report formats use `inputObservation.status`:

| Status | What it establishes |
| --- | --- |
| `NOT_TESTED` | No input trial was requested |
| `CHANGE_OBSERVED` | Pixels exceeded the sampling threshold during a trial |
| `NO_CHANGE_OBSERVED` | No sampled change exceeded the threshold; the intended action remains unverified |
| `INVALID` | Focus, geometry, samples, or timing metadata cannot support the observation |

`gameplayVerified` and `inputLatencyMs` remain `null`. The first-change sample time includes dispatch, capture, and diff overhead. Idle animation, hover, unrelated state, or very small/local feedback can produce false positives or missed changes. Do not report that number as response latency, even an upper bound, without isolating the cause with a separate measurement.

Exit 0 means collection completed; 1 means a collection/usage error; browser exit 2 means collected input observations were invalid. The native collector aborts with an error if its target becomes invalid. Old `GAME-SHAPED`/`APP-SHAPED` verdicts and `respondedWithinMs` fields are retired. Consumers should read schema version 2 and keep scenario acceptance separate.

## Static inspection and delivery

Trace the actual input path and state transition in the relevant scene/component. Searching for buttons, event handlers, update loops, or audio nodes can locate code; their counts cannot decide whether gameplay exists. A click callback can be a valid tactical action, and a render loop can be an inert demonstration.

Attach a concise receipt to the existing task/playtest record:

```text
Claim and scenario: [...]
Build/revision and initial state: [...]
Input -> expected state -> observed state: [...]
Feedback and recovery observed: [...]
Evidence: [clip/frames/event trace], optional diagnostic report [...]
Required checks: [...]
Remaining acceptance gaps or human review: [...]
```

Log reproducible failures by their effect on the current task. Do not invent release blockers from universal widget, text, or idle-motion thresholds. Pilot each distinct costly capture path before a long batch; await the relevant readiness signal within a bounded deadline.
