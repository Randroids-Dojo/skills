import { createHash, randomUUID } from 'node:crypto';
import * as fs from 'node:fs';
import path from 'node:path';

export const digest = value => createHash('sha256').update(JSON.stringify(value)).digest('hex');
const hashFile = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const requireThat = (condition, message) => { if (!condition) throw new Error(message); };
const text = value => typeof value === 'string' && value.trim().length > 0;
const number = value => Number.isFinite(value) && value >= 0;
const list = value => Array.isArray(value) && value.length > 0;
const unique = values => new Set(values).size === values.length;
const slug = value => typeof value === 'string' && /^[a-z][a-z0-9-]{0,63}$/.test(value);
const now = () => new Date().toISOString();
export const readJson = file => {
  try { return JSON.parse(fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, '')); }
  catch (error) { throw new Error(`Cannot read JSON from ${file}: ${error.message}`); }
};
export const acceptancePolicy = config => config.schemaVersion === 1 ? { mode: 'human' } : config.acceptance;

export function validateConfig(config) {
  requireThat([1, 2].includes(config?.schemaVersion), 'Config schemaVersion must be 1 or 2.');
  requireThat(text(config.name) && text(config.baselineRevision), 'Name and baselineRevision are required.');
  requireThat(['real', 'synthetic'].includes(config.mode), 'mode must be real or synthetic.');
  requireThat(list(config.pillars) && config.pillars.every(text), 'Define the intended experience pillars.');
  requireThat(['input', 'action', 'consequence', 'resistance', 'feedback', 'nextDecision'].every(k => text(config.coreLoop?.[k])), 'Define all six coreLoop fields.');
  requireThat(list(config.scenarios) && config.scenarios.every(s => slug(s.id) && text(s.procedure) && ['development', 'validation'].includes(s.group)), 'Define scenarios with id, procedure and group.');
  requireThat(unique(config.scenarios.map(s => s.id)), 'Scenario ids must be unique.');
  requireThat(['development', 'validation'].every(g => config.scenarios.some(s => s.group === g)), 'Include development and fresh validation scenarios.');
  requireThat(list(config.checks) && config.checks.every(slug) && unique(config.checks), 'Define unique required check ids.');
  requireThat(Array.isArray(config.metrics) && config.metrics.every(m => slug(m.id) && text(m.unit) && ['lower', 'higher'].includes(m.better) && number(m.maxRegression)), 'Metrics need id, unit, better and maxRegression.');
  requireThat(unique(config.metrics.map(m => m.id)), 'Metric ids must be unique.');
  requireThat(Number.isInteger(config.minTrials) && config.minTrials >= 1, 'minTrials must be a positive integer.');
  requireThat(Number.isInteger(config.minModelProviders) && config.minModelProviders >= 0, 'minModelProviders must be a nonnegative integer.');
  if (config.schemaVersion === 2) {
    const policy = config.acceptance;
    requireThat(['council', 'human'].includes(policy?.mode), 'Declare acceptance.mode as council or human.');
    if (policy.mode === 'council') {
      requireThat(list(policy.providers) && policy.providers.every(text) && unique(policy.providers) && policy.providers.length >= 2, 'Freeze at least two unique council providers.');
      requireThat(config.minModelProviders === policy.providers.length, 'minModelProviders must match the fixed council panel.');
      requireThat(Number.isInteger(policy.votesRequired) && policy.votesRequired > policy.providers.length / 2 && policy.votesRequired <= policy.providers.length, 'Council votesRequired must be a strict majority of the fixed panel.');
    }
  }
  if (config.execution) {
    const execution = config.execution;
    requireThat(config.schemaVersion === 2 && acceptancePolicy(config).mode === 'council', 'Subscription execution requires an explicit version-2 council.');
    requireThat(execution.transport === 't3-code' && execution.billing === 'existing-subscriptions' && execution.allowApiFallback === false, 'Use T3 Code with existing subscriptions and no API fallback.');
    const panel = acceptancePolicy(config).providers;
    requireThat(list(execution.reviewers) && unique(execution.reviewers.map(r => r.provider)) && execution.reviewers.length === panel.length && execution.reviewers.every(r => panel.includes(r.provider) && text(r.model) && r.context === 'fresh-read-only'), 'Execution reviewers must exactly match the fixed panel in fresh read-only contexts.');
    requireThat(panel.includes(execution.implementer?.provider) && text(execution.implementer.model), 'Implementer must use a configured subscription provider and model.');
    requireThat(execution.onQuotaLimit === 'pause-and-resume' && execution.onDisagreement === 'retain-champion-and-revise', 'Quota or disagreement must not trigger a paid fallback or human gate.');
  }
  const b = config.budget;
  requireThat(b && number(b.maxCostUsd) && number(b.maxMinutes) && b.maxMinutes > 0 && Number.isInteger(b.maxExperiments) && b.maxExperiments > 0 && Number.isInteger(b.stopAfterNoGain) && b.stopAfterNoGain > 0, 'Define finite cost, minutes, experiment and no-gain budgets.');
  return config;
}

// The template validates on purpose; refuse to freeze a campaign that still carries its placeholders.
const placeholder = /^(Replace with|Describe )/;
function noPlaceholders(value, where = 'config') {
  if (typeof value === 'string') requireThat(!placeholder.test(value.trim()), `Replace the template placeholder at ${where}.`);
  else if (value && typeof value === 'object') for (const [key, inner] of Object.entries(value)) noPlaceholders(inner, `${where}.${key}`);
}

export function initialize(root, config) {
  validateConfig(config);
  noPlaceholders(config);
  fs.mkdirSync(root, { recursive: true });
  requireThat(fs.readdirSync(root).length === 0, 'Campaign directory must be empty.');
  const state = { schemaVersion: 1, config, configDigest: digest(config), acceptedRevision: config.baselineRevision, experiments: [], events: [{ type: 'initialized', at: now() }] };
  fs.writeFileSync(path.join(root, 'state.json'), JSON.stringify(state, null, 2) + '\n', { flag: 'wx' });
  return state;
}

function inside(root, relative) {
  const resolvedRoot = fs.realpathSync(root);
  const target = fs.realpathSync(path.resolve(root, relative));
  requireThat(target.startsWith(resolvedRoot + path.sep), 'Artifact escaped campaign directory.');
  return target;
}

export function load(root) {
  const state = readJson(path.join(root, 'state.json'));
  requireThat(state && typeof state === 'object' && !Array.isArray(state), 'state.json must contain a JSON object.');
  requireThat(state.schemaVersion === 1, 'Unsupported campaign schema.');
  requireThat(Array.isArray(state.experiments) && Array.isArray(state.events), 'state.json must list experiments and events.');
  validateConfig(state.config);
  requireThat(digest(state.config) === state.configDigest, 'Campaign contract changed. Start a new campaign.');
  for (const e of state.experiments) {
    requireThat(digest(e.proposal) === e.proposalDigest, `Proposal changed: ${e.id}`);
    requireThat(Array.isArray(e.reviews), `state.json experiment ${e.id} must list its reviews.`);
    if (!e.report) continue;
    requireThat(digest(e.report) === e.evidenceDigest, `Evidence changed: ${e.id}`);
    for (const a of e.report.artifacts) {
      const file = inside(root, a.path);
      requireThat(fs.statSync(file).isFile() && hashFile(file) === a.sha256, `Artifact changed: ${a.path}`);
    }
    for (const review of e.reviews) requireThat(review.evidenceDigest === e.evidenceDigest, 'Review refers to stale evidence.');
  }
  return state;
}

function mutate(root, operation) {
  const lock = path.join(root, '.lock');
  fs.mkdirSync(lock); // A second writer fails instead of overwriting another agent's receipt.
  const tmp = path.join(root, `.state-${randomUUID()}.tmp`);
  try {
    const state = load(root);
    const result = operation(state);
    fs.writeFileSync(tmp, JSON.stringify(state, null, 2) + '\n', { flag: 'wx' });
    fs.renameSync(tmp, path.join(root, 'state.json'));
    return result;
  } finally {
    if (fs.existsSync(tmp)) fs.unlinkSync(tmp);
    fs.rmdirSync(lock);
  }
}

function experiment(state, id) {
  const e = state.experiments.find(e => e.id === id);
  requireThat(e, `Unknown experiment: ${id}`);
  return e;
}

function active(e) { requireThat(!e.outcome, 'Experiment is closed. Start a new experiment.'); }

export function accounting(state) {
  const total = key => state.experiments.reduce((sum, e) => sum + (e.report ? e.report[key] : e.outcome ? 0 : e.proposal[key === 'costUsd' ? 'estimatedCostUsd' : 'estimatedMinutes']), 0);
  let noGain = 0;
  for (const event of [...state.events].reverse()) {
    if (event.type === 'accepted') break;
    if (event.type === 'rejected') noGain++;
  }
  return { costUsd: total('costUsd'), minutes: total('minutes'), experiments: state.experiments.length, noGain };
}

export function propose(root, proposal) {
  return mutate(root, state => {
    requireThat(proposal && slug(proposal.id), 'Experiment id must be a lowercase slug.');
    requireThat(['hypothesis', 'change', 'expectedObservation', 'risk', 'candidateRevision'].every(k => text(proposal[k])), 'Describe hypothesis, change, expectedObservation, risk and candidateRevision.');
    requireThat(proposal.baselineRevision === state.acceptedRevision, 'Proposal must start from the current accepted revision.');
    requireThat(proposal.candidateRevision !== proposal.baselineRevision, 'Candidate must differ from baseline.');
    requireThat(number(proposal.estimatedCostUsd) && number(proposal.estimatedMinutes), 'Declare finite cost and time estimates.');
    requireThat(!state.experiments.some(e => e.id === proposal.id), 'Experiment id already exists.');
    const totals = accounting(state), budget = state.config.budget;
    requireThat(totals.experiments < budget.maxExperiments && totals.noGain < budget.stopAfterNoGain, 'Experiment or no-gain stop reached. Reassess before another campaign.');
    requireThat(totals.costUsd + proposal.estimatedCostUsd <= budget.maxCostUsd && totals.minutes + proposal.estimatedMinutes <= budget.maxMinutes, 'Cost or time budget exhausted (including reservations).');
    const e = { id: proposal.id, proposal, proposalDigest: digest(proposal), reviews: [], createdAt: now() };
    state.experiments.push(e);
    state.events.push({ type: 'proposed', id: e.id, at: now() });
    return e;
  });
}

export function submit(root, id, report, sourceDir) {
  return mutate(root, state => {
    const e = experiment(state, id); active(e);
    requireThat(!e.report, 'Evidence is immutable. Use a new experiment for changed evidence.');
    requireThat(report?.schemaVersion === 1 && report.mode === state.config.mode, 'Report schema or mode mismatch.');
    requireThat(report.baselineRevision === e.proposal.baselineRevision && report.candidateRevision === e.proposal.candidateRevision, 'Report build revisions do not match proposal.');
    requireThat(['platform', 'device', 'input', 'settings'].every(k => text(report.environment?.[k])), 'Record a shared comparison environment: platform, device, input, settings.');
    requireThat(number(report.costUsd) && number(report.minutes), 'Record finite actual cost and minutes, even when zero.');
    requireThat(list(report.trials) && list(report.artifacts), 'Trials and artifacts are required.');
    requireThat(unique(report.trials.map(t => JSON.stringify([t.scenarioId, t.variant, t.seed]))), 'Duplicate scenario/variant/seed trial.');
    for (const t of report.trials) {
      requireThat(state.config.scenarios.some(s => s.id === t.scenarioId) && ['baseline', 'candidate'].includes(t.variant) && text(t.seed), 'Trial must name a configured scenario, variant and seed.');
      requireThat(t.checks && Object.values(t.checks).every(v => ['pass', 'fail', 'not-tested'].includes(v)), 'Check results must be pass, fail or not-tested.');
      requireThat(t.metrics && Object.values(t.metrics).every(Number.isFinite), 'Trial metrics must be finite numbers.');
    }
    const copied = structuredClone(report);
    // Validate the whole manifest before writing any artifact files.
    const sources = report.artifacts.map(a => {
      requireThat(state.config.scenarios.some(s => s.id === a.scenarioId) && ['baseline', 'candidate'].includes(a.variant), 'Artifact must name a configured scenario and variant.');
      requireThat(a.revision === report[a.variant + 'Revision'], 'Artifact revision mismatch.');
      requireThat(['trace', 'video', 'screenshot', 'log'].includes(a.kind) && text(a.path), 'Artifact needs a supported kind and path.');
      const source = path.resolve(sourceDir, a.path), stat = fs.statSync(source);
      requireThat(stat.isFile() && stat.size > 0 && stat.size <= 100 * 1024 * 1024, 'Artifact must be a nonempty file of at most 100 MiB.');
      return source;
    });
    const artifactDir = path.join(root, 'artifacts', id, randomUUID());
    fs.mkdirSync(artifactDir, { recursive: true });
    copied.artifacts = report.artifacts.map((a, i) => {
      const target = path.join(artifactDir, `${i}-${path.basename(sources[i])}`);
      fs.copyFileSync(sources[i], target, fs.constants.COPYFILE_EXCL);
      // Hash the stored copy, so a source still being written cannot leave a hash the campaign can never match.
      return { ...a, path: path.relative(root, target), sha256: hashFile(target) };
    });
    e.report = copied; e.evidenceDigest = digest(copied);
    state.events.push({ type: 'submitted', id, evidenceDigest: e.evidenceDigest, at: now() });
    return { id, evidenceDigest: e.evidenceDigest };
  });
}

export function review(root, id, receipt) {
  return mutate(root, state => {
    const e = experiment(state, id); active(e);
    requireThat(e.report && receipt?.evidenceDigest === e.evidenceDigest, 'Review must cite the current evidenceDigest.');
    requireThat(receipt.mode === state.config.mode && ['model', 'human'].includes(receipt.kind), 'Review mode or kind mismatch.');
    requireThat(text(receipt.reviewer) && text(receipt.observations), 'Reviewer and concrete observations are required.');
    requireThat(['candidate', 'baseline', 'tie', 'inconclusive'].includes(receipt.preference), 'State a preference, tie or inconclusive result.');
    requireThat(!e.reviews.some(r => r.kind === receipt.kind && r.reviewer === receipt.reviewer), 'Reviewer already recorded. Start a new experiment to revisit.');
    if (receipt.kind === 'model') {
      requireThat(text(receipt.provider), 'Model review must identify its provider.');
      const policy = acceptancePolicy(state.config);
      if (policy.mode === 'council') {
        requireThat(policy.providers.includes(receipt.provider), 'Review provider is not on the frozen council panel.');
        requireThat(!e.reviews.some(r => r.kind === 'model' && r.provider === receipt.provider), 'Only one council vote per provider is allowed.');
        requireThat(['low', 'medium', 'high'].includes(receipt.confidence), 'Council review needs an explicit confidence level.');
        requireThat(Array.isArray(receipt.blockingFindings) && receipt.blockingFindings.every(text), 'Council review must declare blockingFindings, including an empty list when none.');
        requireThat(list(receipt.evidenceRefs) && receipt.evidenceRefs.every(ref => text(ref.observation) && e.report.artifacts.some(a => a.sha256 === ref.sha256)), 'Council review must cite existing artifact hashes with concrete observations.');
        requireThat(['baseline', 'candidate'].every(v => receipt.evidenceRefs.some(ref => e.report.artifacts.some(a => a.sha256 === ref.sha256 && a.variant === v))), 'Council review must examine evidence from both variants.');
      }
    }
    if (receipt.kind === 'human') requireThat(receipt.playedBoth === true, 'Human enjoyment receipt requires actually playing both variants.');
    e.reviews.push({ ...receipt, at: now() });
    state.events.push({ type: 'reviewed', id, kind: receipt.kind, reviewer: receipt.reviewer, at: now() });
    return { id, reviews: e.reviews.length };
  });
}

export function assess(state, id) {
  const e = experiment(state, id), config = state.config;
  if (e.outcome) return { status: e.outcome, reasons: [e.outcomeReason], metrics: [], acceptanceBasis: e.acceptanceBasis ?? null };
  const missing = [], failed = [], metrics = [];
  if (e.proposal.baselineRevision !== state.acceptedRevision) failed.push('Baseline is stale after another experiment was accepted.');
  if (!e.report) return { status: failed.length ? 'reject' : 'needs-evidence', reasons: [...failed, 'Capture and import actual gameplay evidence.'], metrics };
  const report = e.report;
  const used = accounting(state);
  if (used.costUsd > config.budget.maxCostUsd || used.minutes > config.budget.maxMinutes) failed.push('Reported usage and reservations exceed the campaign budget.');
  for (const s of config.scenarios) {
    const base = report.trials.filter(t => t.scenarioId === s.id && t.variant === 'baseline');
    const candidate = report.trials.filter(t => t.scenarioId === s.id && t.variant === 'candidate');
    if (base.length < config.minTrials || candidate.length < config.minTrials) missing.push(`${s.id}: insufficient repeated trials.`);
    if (JSON.stringify(base.map(t => t.seed).sort()) !== JSON.stringify(candidate.map(t => t.seed).sort())) missing.push(`${s.id}: baseline and candidate seeds differ.`);
    for (const variant of ['baseline', 'candidate']) {
      if (!report.artifacts.some(a => a.scenarioId === s.id && a.variant === variant && ['trace', 'video'].includes(a.kind))) missing.push(`${s.id}/${variant}: needs trace or video; screenshots alone are insufficient.`);
    }
    for (const t of [...base, ...candidate]) {
      for (const check of config.checks) {
        if (t.checks[check] === 'fail' && t.variant === 'candidate') failed.push(`${s.id}/${t.variant}/${t.seed}: ${check} failed.`);
        else if (!['pass', 'fail'].includes(t.checks[check])) missing.push(`${s.id}/${t.variant}/${t.seed}: ${check} not verified.`);
      }
    }
    for (const m of config.metrics) {
      const deltas = [];
      for (const t of candidate) {
        const b = base.find(b => b.seed === t.seed);
        if (!b || !Number.isFinite(t.metrics[m.id]) || !Number.isFinite(b.metrics[m.id])) { missing.push(`${s.id}/${t.seed}: missing paired ${m.id}.`); continue; }
        const benefit = (m.better === 'lower' ? -1 : 1) * (t.metrics[m.id] - b.metrics[m.id]);
        deltas.push(benefit);
        if (benefit < -m.maxRegression) failed.push(`${s.id}/${t.seed}: ${m.id} regressed beyond ${m.maxRegression} ${m.unit}.`);
      }
      if (deltas.length) {
        deltas.sort((a, b) => a - b);
        const mid = Math.floor(deltas.length / 2);
        metrics.push({ scenarioId: s.id, id: m.id, unit: m.unit, pairedTrials: deltas.length, medianBenefit: deltas.length % 2 ? deltas[mid] : (deltas[mid - 1] + deltas[mid]) / 2, note: 'Descriptive only. No significance or enjoyment claim.' });
      }
    }
  }
  if (failed.length) return { status: 'reject', reasons: failed, metrics };
  if (missing.length) return { status: 'needs-evidence', reasons: missing, metrics };
  const providers = new Set(e.reviews.filter(r => r.kind === 'model').map(r => r.provider));
  if (providers.size < config.minModelProviders) return { status: 'needs-model-review', reasons: [`Need all ${config.minModelProviders} configured model providers; have ${providers.size}.`], metrics };
  const policy = acceptancePolicy(config);
  if (policy.mode === 'council') {
    const reviews = e.reviews.filter(r => r.kind === 'model');
    const blocking = reviews.flatMap(r => r.blockingFindings.map(finding => `${r.provider}: ${finding}`));
    const votes = reviews.filter(r => r.preference === 'candidate' && r.confidence !== 'low').length;
    const council = { votes, required: policy.votesRequired, panel: reviews.map(r => ({ provider: r.provider, preference: r.preference, confidence: r.confidence })) };
    if (blocking.length) return { status: 'reject', reasons: blocking, metrics, council };
    if (votes < policy.votesRequired) return { status: 'no-clear-gain', reasons: ['Council did not find a sufficiently confident improvement. Keep the baseline and try another hypothesis within budget.'], metrics, council };
    return { status: 'eligible', acceptanceBasis: 'council', reasons: ['Evidence checks passed and the fixed council favors the candidate. Promote automatically and continue; human calibration is optional.'], metrics, council };
  }
  const humans = e.reviews.filter(r => r.kind === 'human');
  if (humans.some(r => r.preference === 'baseline')) return { status: 'reject', reasons: ['A human playtester preferred the baseline. Preserve it and revisit the hypothesis.'], metrics };
  if (!humans.length || humans.some(r => r.preference !== 'candidate')) return { status: 'needs-human-playtest', reasons: ['Need actual play of both builds and a clear human preference for the candidate.'], metrics };
  return { status: 'eligible', acceptanceBasis: 'human', reasons: ['Evidence checks passed and the explicitly selected human policy is satisfied.'], metrics };
}

export function decide(root, id) { return assess(load(root), id); }

function recordOutcome(state, e, outcome, reason, basis = null) {
  if (outcome === 'accepted') state.acceptedRevision = e.proposal.candidateRevision;
  e.outcome = outcome; e.outcomeReason = reason; e.acceptanceBasis = basis;
  state.events.push({ type: outcome, id: e.id, at: now(), reason, revision: state.acceptedRevision, acceptanceBasis: basis });
  return { id: e.id, outcome, acceptedRevision: state.acceptedRevision, acceptanceBasis: basis, mode: state.config.mode };
}

export function advance(root, id) {
  return mutate(root, state => {
    const e = experiment(state, id); active(e);
    const decision = assess(state, id);
    if (decision.status === 'eligible') return recordOutcome(state, e, 'accepted', decision.reasons.join(' '), decision.acceptanceBasis);
    if (['reject', 'no-clear-gain'].includes(decision.status)) return recordOutcome(state, e, 'rejected', decision.reasons.join(' '));
    return decision;
  });
}

export function close(root, id, outcome, reason) {
  return mutate(root, state => {
    const e = experiment(state, id); active(e);
    requireThat(['accepted', 'rejected'].includes(outcome) && text(reason), 'Close with accepted/rejected and a reason.');
    let basis = null;
    if (outcome === 'accepted') {
      const decision = assess(state, id);
      requireThat(decision.status === 'eligible', `Cannot accept: ${decision.status}. ${decision.reasons.join(' ')}`);
      basis = decision.acceptanceBasis;
    }
    return recordOutcome(state, e, outcome, reason, basis);
  });
}
