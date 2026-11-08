---
name: funclimb
description: Run bounded, evidence-grounded FunClimb improvement experiments on a game project, preserving its identity and using an independent Claude and Codex council. Use when asked to find the fun, hill climb game quality, or run FunClimb.
---

# FunClimb

Use this skill from the selected game's directory. For example: "Use FunClimb on this game for 45 minutes, zero paid spend, preserving its core controls."

This is an engine-neutral agent workflow around an installed evidence coordinator. The game supplies its own build, input and capture adapter. The CLI does not play games or launch reviewers by itself. Installation does not authorize a new game experiment, provider task, budget, merge or deployment.

## Run the coordinator

The evidence coordinator ships with this skill: `node <this-skill-directory>/scripts/funclimb.mjs <command>`. It needs Node 22 or newer and only the standard library; there is nothing else to install or check out. `--help` lists the commands (init, propose, submit, review, decide, advance, accept, reject, status). Campaign and report paths are relative to the caller's cwd. `node <this-skill-directory>/scripts/demo.mjs <dir>` runs a synthetic campaign end to end to confirm it works; nothing it writes is real evidence.

Read as needed: `references/protocol.md` (proposal, report and review receipt shapes, decision rules and limits), `references/rubric.md` (what to judge), `references/roles.md` (proposer, implementer, observer and council reviewer briefs) and `assets/campaign.template.json`. Read the selected game's AGENTS.md, design contract, current progress and test/build instructions.

Keep campaign data out of the game's git history. By default use `~/.funclimb/campaigns/<game>-<yyyy-mm-dd>-<slug>/`, or a directory the game repo already ignores. Captures are large; never commit them.

Resolve the selected host and current provider models through available T3 tools. Do not reuse the VibeBots pilot's host ids, thread ids, branches, budgets or evidence for another game. Use the current user conversation as this run's single main progress thread; do not create a new top-level thread unless asked. That conversation should be one the user opened on the selected host. A thread launched through a linked environment keeps that link's scope for life: it can change only threads that link started, and switching it to Full access later does not lift that. The pilot's main could not settle its own workers for this reason.

## Start from a player moment

Ask which game, audience and platform matter when they are unknown. Inspect its design contract and current build. Write the causal chain: input, intended action, consequence, resistance or meaningful choice, feedback, next decision. Preserve the genre. Capture a concrete failed or promising moment under actual input. Do not infer gameplay from a screenshot or code inspection alone.

The default acceptance authority is the council. Resolve and freeze its actual providers/models before the run. Execution and delegation stay within the user's authorized scope. In T3 Code use its orchestration tools when council delegation is authorized. Do not substitute models silently or run multiple instances of one provider as an independent cross-provider panel. Read-only reviewers cannot alter the candidate or evaluator.

## Prepare a campaign

1. Infer the intended experience from the user's request and game contract. Ask only for material missing scope or resources. Identify one concrete player experience to improve and record the authorized time, experiment, no-gain and spending limits. Do not carry a stopped campaign's budget into a new run.
2. Start from `assets/campaign.template.json` and replace every game, source, scenario, host, model and budget field with values for this run. Set schemaVersion=2, mode=real, an explicit council acceptance policy, immutable baseline build id, checks, metrics and scenarios. The user's default is existing Claude Code and Codex subscriptions through T3 Code, both voting reviewers required, no third provider or API fallback. Claude may implement, but its reviewer gets a fresh read-only context. costUsd means incremental billed spend; API-equivalent token value belongs separately in usage. Respect plan quotas and pause/resume instead of buying more inference or changing accounts.
3. Include development and fresh validation situations. These are public scenario coverage, not a secret holdout. Reserve additional human tasks or content outside agent context for a real holdout later.
4. Initialize a NEW campaign with `funclimb.mjs init <new-campaign-dir> <config.json>` in the campaign location above. Never overwrite an existing campaign. Preserve local game changes and a reproducible baseline. Use the game's own engine loop and tests; the coordinator is engine-neutral.
5. Preflight on the baseline before freezing. A frozen contract cannot be repaired in place, so every miss here costs a new campaign. The pilot needed four contract versions and still could not promote its candidate.
   - Play every scenario once on the baseline under the exact fixture. Each step must be reachable in the shipped UI and each check must be passable in that environment. Pilot: scenarios asked for fights only a headless bench could run, and a save check could not pass with storage off.
   - Prove the input actor can perform every scripted action on the baseline. Prefer the game's identity-checked selectors, test hooks or accessibility tree over blind canvas search, and count inputs from the raw input log rather than the actor's return value. Pilot: canvas search spent 27 taps failing to select a part, reported 60, and left it unclear whether the game or the driver had failed.
   - Time one trial per scenario, multiply by the full scenario, variant and repeat matrix, then add implementation, packaging and the review reserve. If the total exceeds the budget, shrink the matrix in the contract now. Pilot: about 3 minutes per trial, 18 trials and a 90-minute cap that also covered implementation; 16 of 18 were captured, so the candidate could not be promoted whatever its quality.

Resolve the selected T3 environment and inspect its provider capabilities and quota information where exposed. Do not require API credits or another provider. A local login failure does not establish entitlement or sessions on other hosts. Use T3 environment tools for linked machines, with no silent SSH or CLI inference fallback.

## Explore and test

1. Generate several distinct hypotheses from observed behavior. Include a subtraction or simplification idea when appropriate and an alternative that challenges the current design. Avoid cosmetic-only local optima when the core action fails.
2. Choose one coherent, falsifiable change. Write its predicted player-visible result, risks, allowed files or parameters and cheap disproof test. Propose the experiment to reserve its estimated budget before work. Check what the change sends the player toward, not only how it gets them there: when the candidate surfaces existing advice, hints, targets or recommendations, verify on the baseline that each is correct for every frozen scenario's setup. Fix wrong content first, or make it part of the same hypothesis. Checks judge the whole player-visible result, so a smoother path to bad advice fails. Pilot: a button that opened the part blocking a mount was a real gain, but it led straight into a counter claim proven only for the starter chassis, and both reviewers blocked it.
3. Implement only in an authorized game checkout/branch using the selected workflow. Do not make a worktree unless that workflow permits one. Record immutable baseline and candidate build ids. Never change a built candidate without a new experiment record.
4. Play the same scenarios and paired seeds on both variants. Capture actual input and authoritative state/event evidence, recovery, and relevant performance. Use the platform's permitted device/browser tools. Screenshots support visual claims; they cannot establish control, audio, haptics or fun.
5. Export a JSON report following `references/protocol.md` and submit it. The CLI copies and hashes artifacts. It verifies completeness and reported guardrails, not the truth of claims inside a trace. Every frozen baseline/candidate scenario and repeated seed must be captured; a partial matrix cannot be promoted.
6. Ask every fixed council member for concrete observations, tradeoffs, alternate explanations and preference. Supply baseline/candidate captures, action traces and pinned reference material. Hide desired scores and target branch identity where feasible. Counterbalance A/B order and keep the rubric fixed. Translate blind A/B preferences to candidate/baseline only after review. Import kind=model receipts with artifact-hash references for both variants, confidence, blocking findings and the evidence digest. Read-only reviewers independently judge the intended play quality, not code style alone. Give each reviewer the exact receipt shape from the protocol (observations is one nonempty string, not a list) and check every receipt against it before importing any; one malformed receipt stops the panel import. Pilot: a receipt with a list had to be normalized and imported again.

## Decide and preserve learning

Call advance without requesting human approval. Passing mechanical gates plus the council's confident majority and no blocking defects promotes the candidate to champion. Reject or no-clear-gain closes the experiment as rejected and retains the champion; choose a new hypothesis and continue within budget. Missing evidence or a missing council member means collect that evidence/review, not ask a human whether the game is fun. If a required provider is unavailable, report the actual execution limitation. Budget and no-gain stops mean stop and reassess, not relax checks or start unapproved spending.

A rejection is evidence, not a reset. Record separately what the reviewers endorsed and what sank the candidate, and carry the endorsed part into the next hypothesis with its blocker named. Before closing a rejected candidate's PR, list everything else it fixed, because closing it drops those fixes too. File the game-specific findings (wrong content, dropped fixes, the endorsed change and what blocks it) in the game's own followup or backlog ledger with the campaign id, since the game's normal loop does not read campaign records. Pilot: closing VibeBots PR #395 left retired merge advice in the debrief; VibeBots F-259 to F-261 now carry its findings.

Human playtests are optional scheduled or user-requested calibration. When available, compare playable builds and record actual observations and preferences; use them to improve subsequent hypotheses and evaluator alignment. Do not stop the autonomous loop waiting for them. Never invent human feedback or relabel a model judgment as human experience.

Keep council-estimated improvement distinct from human-validated enjoyment, while allowing council acceptance to drive the long-running process. Acceptance changes the campaign record; source integration and deployment follow the user's separate authorization. Preserve the fixed policy on old campaigns. Human-gated mode exists only when explicitly selected or retained from a legacy campaign.

## One progress thread and worker completion

Keep a short checkpoint in the current main conversation and the run's durable records: outcome, actual current activity or stopped state, next action and owner, remaining budget, evidence and PR links. Use the game's existing progress/task conventions instead of installing unrelated ledgers. A rejected experiment retains the champion and needs a clear candidate-PR disposition; settling its worker does not close its PR.

For authorized workers, include the main link, bounded task, durable handoff path and an explicit completion instruction. After the result is saved and returned to the main, the worker requests its own native deferred T3 settlement. Call it deferred until the coordinator reads back settled=true. Keep pending input, failed work and resumed runs visible. Stop obsolete delegates with task_cancel before settling them. Do not create a new worker merely to test cleanup.

Before a worker settles, check that its result is saved and reported to the main, its run is complete and nothing is pending. Then it settles itself natively, and the main reads back settled=true. Do not change access or take another route after a T3 permission refusal. Keep the current main open until the effort ends or the user explicitly requests settlement.

Update the selected game's progress and playtest records with evidence and remaining gaps. Report measured function, presentation, performance and human experience separately. Deliver the actual candidate and a concrete next experiment. Do not call the game fun or finished because the backlog is empty.
