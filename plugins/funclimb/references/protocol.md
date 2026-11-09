# Campaign protocol, version 2

The executable fixture lives in `scripts/synthetic.mjs`; every value and receipt there is synthetic. Start a real campaign from `assets/campaign.template.json` and fill it from the target game's contract.

## Proposal

```json
{
  "id": "short-slug",
  "baselineRevision": "immutable accepted build",
  "candidateRevision": "immutable candidate build",
  "hypothesis": "A specific change should improve a specific player moment because...",
  "change": "One coherent change and its boundary",
  "expectedObservation": "What could a player now do or understand?",
  "risk": "What might become worse?",
  "estimatedCostUsd": 0,
  "estimatedMinutes": 10
}
```

## Evidence report

Fields: `schemaVersion=1`, `mode=real|synthetic`, `baselineRevision`, `candidateRevision`, `environment`, `costUsd`, `minutes`, `trials`, `artifacts`, `notes`. `environment` has nonempty `platform`, `device`, `input` and `settings` strings, shared by both variants. Each trial has `scenarioId`, `variant=baseline|candidate`, a nonempty string `seed`, `checks` and `metrics`. Check values are `pass|fail|not-tested`. Metrics use finite numeric values in the units frozen by the config. A baseline failure may reproduce a defect; candidate failures reject. Missing checks never become passes.

Each scenario needs at least `minTrials` per variant, with identical seed sets, and a trace or video artifact per variant. An artifact has `scenarioId`, `variant`, `revision`, `kind=trace|video|screenshot|log`, and `path` relative to the report file. Imports copy nonempty files, up to 100 MiB per artifact, into the campaign and record SHA-256. The CLI does not parse trace semantics or inspect video. The observer must establish causality and repeat coverage. Use clips or linked capture bundles within this limit.

Config `checks` lists every check id. A scenario may add its own `checks`, a nonempty subset of that list; its trials then need only those checks verified. Without it, every global check applies. Every global check must be required by at least one scenario. Scope a check out of a scenario only when the scenario cannot exercise it, never because it fails there. A candidate `fail` reported for a check outside a scenario's list still rejects.

## Baseline preflight

Run `funclimb.mjs preflight <config.json> <baseline-report.json>` before init. The baseline report uses the evidence report shape with `baselineRevision` equal to the config's, no candidate, and only `variant=baseline` trials and artifacts. It needs every scenario at `minTrials` or more distinct seeds and a trace or video per scenario, with artifact paths relative to the report. Every required check must be `pass` or `fail` for every seed; `not-tested` or a missing check is a problem. Every frozen metric must be present and finite. The command prints a pass, or the problems and a nonzero exit. A baseline `fail` passes with a warning: confirm it reproduces a real defect, not a check the environment cannot pass.

`init <dir> <config.json> --preflight <baseline-report.json>` reruns the same check and freezes only on a pass, recording a `preflight` event with the report digest in state.json. `init <dir> <config.json> --skip-preflight "reason"` freezes without it and records a `preflight-skipped` event with the reason. Campaigns created before preflight have neither event and load and decide as before.

For every paired seed, the metric's higher/lower preference determines benefit. A regression larger than `maxRegression` rejects the candidate even if the aggregate looks good. Median benefit is descriptive, with no statistical significance claim. Set noise tolerances before experiments. Do not use a frame metric as an input-latency measurement.

For a deterministic game, a seed may identify a recorded fixture and reset repetition rather than a random number. Record the actual starting state and repetition separately in the trace, and pair both across variants. Repeating an identical deterministic fight tests reproducibility; it does not provide independent samples of balance or enjoyment. A headless simulation cannot replace the visible interaction a scenario requires. Correcting an unsupported scenario creates a new campaign before experiments, preserving the old frozen contract.

## Council review receipt

```json
{
  "mode": "real",
  "kind": "model",
  "reviewer": "actual reviewer model and role",
  "provider": "configured provider id",
  "evidenceDigest": "digest returned by submit",
  "preference": "candidate",
  "confidence": "high",
  "blockingFindings": [],
  "evidenceRefs": [
    { "sha256": "baseline artifact hash", "observation": "Specific baseline moment" },
    { "sha256": "candidate artifact hash", "observation": "Comparable candidate moment" }
  ],
  "observations": "Grounded comparison, tradeoffs, and why this variant is preferable"
}
```

`observations` is one nonempty string, not a list. `blockingFindings` is a list of strings, empty when there are none. Check every receipt against this shape before importing any of them.

Config `schemaVersion=2` declares `acceptance.mode=council`, a fixed `providers` array and `votesRequired` (a strict majority). `minModelProviders` equals the panel length. Collect all panel members, one vote per provider. Votes from outside the panel, duplicate provider votes, uncited comparisons and missing confidence or blocker declarations are rejected. Candidate votes at medium or high confidence count; low confidence abstains. Any blocking finding vetoes promotion. Otherwise the required majority makes the candidate eligible. Record minority disagreement; do not ask a human to break a tie. No majority means no-clear-gain and another experiment within budget.

Optional human receipts use `kind=human`, `reviewer`, `evidenceDigest`, `mode`, `preference`, `observations` and `playedBoth=true`. They are calibration data in council mode and cannot silently reintroduce a human wait. Explicit `acceptance.mode=human` and legacy config `schemaVersion=1` keep the older human policy. Never change a frozen campaign's policy in place. Neither model nor human identity is authenticated by the receipt store.

## Autonomous state and decisions

Preflight and init once, then propose, submit, complete the council, advance, then the next experiment. `advance` promotes eligible candidates and records `acceptanceBasis=council`; reject or no-clear-gain automatically closes the experiment as rejected and keeps the champion. Missing evidence or reviews stays pending for the agent to collect. No human receipt is required under the default council policy. A closed experiment cannot be changed. Promotion advances the baseline and invalidates competing old-baseline proposals. It does not itself alter game source, branches or releases.

The state and report storage schema is version 1; version 2 is the campaign config policy version. `state.json` is replaced atomically under a single-writer lock, keeping proposals, reports, reviews and events. Hashes detect content drift, not deliberate local tampering. Interrupted imports may leave unreferenced artifacts. Inspect an abandoned `.lock` directory before removing it; do not remove an active writer's lock.

## Accounting and known limits

Estimates reserve cost and minutes before work; actual reported usage replaces them after submission. Closing a never-submitted experiment releases its reservation and assumes no spend. An overrun is kept, blocks acceptance and prevents further over-budget work. Provider billing, quotas, wall-clock deadlines and the authenticity of reported values are not enforced. This is a local cooperative workflow, not a security boundary.

Validation scenarios are visible robustness checks, not hidden test data. A true final holdout needs separate management. The CLI does not resolve git revisions, produce game builds, capture inputs, call models, authenticate people, enforce task boundaries or prove subjective enjoyment. Those are the agent's and the game adapter's responsibilities.

## T3 subscription execution

The `execution` contract declares `transport=t3-code`, `billing=existing-subscriptions`, `allowApiFallback=false`, an implementer and exactly matching fresh-read-only reviewers. Provider ids must match the council; the default is `claudeAgent` and `codex` with two votes required. Models must exist on the selected T3 host. Validation checks this declared contract, not actual billing or task dispatch.

`costUsd` and `estimatedCostUsd` mean incremental charges, not the API-equivalent value of included subscription inference. Optional `report.usage` can keep tokens, quota readings or an `apiEquivalentCostUsd` estimate without debiting the paid-spending budget. Respect plan quotas and pause and resume, without new purchases or credential copying. Local authentication is not the state of every T3 machine.
