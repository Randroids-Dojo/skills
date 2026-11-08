import { test } from 'node:test';
import assert from 'node:assert/strict';
import * as fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { syntheticFixture } from '../plugins/funclimb/scripts/synthetic.mjs';
import { initialize, load, validateConfig, propose, submit, review, decide, close, advance, accounting } from '../plugins/funclimb/scripts/core.mjs';

function setup(t, change = () => {}) {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'funclimb-test-'));
  t.after(() => fs.rmSync(temp, { recursive: true, force: true }));
  const source = path.join(temp, 'source'), root = path.join(temp, 'campaign');
  const f = syntheticFixture(source); change(f);
  initialize(root, f.config); propose(root, f.proposal);
  return { ...f, root, source };
}
function submitted(f) { return submit(f.root, f.proposal.id, f.report, f.source).evidenceDigest; }
function reviewed(f, hash) {
  review(f.root, f.proposal.id, f.model(hash));
  review(f.root, f.proposal.id, f.model(hash, 'synthetic-provider-b'));
  review(f.root, f.proposal.id, f.model(hash, 'synthetic-provider-c'));
}

test('the complete council promotes a candidate without any human receipt', t => {
  const f = setup(t), hash = submitted(f);
  review(f.root, f.proposal.id, f.model(hash));
  review(f.root, f.proposal.id, f.model(hash, 'synthetic-provider-b'));
  assert.equal(decide(f.root, f.proposal.id).status, 'needs-model-review');
  assert.throws(() => close(f.root, f.proposal.id, 'accepted', 'incomplete panel'), /needs-model-review/);
  review(f.root, f.proposal.id, { ...f.model(hash, 'synthetic-provider-c'), preference: 'baseline' });
  assert.equal(decide(f.root, f.proposal.id).status, 'eligible');
  const result = advance(f.root, f.proposal.id);
  assert.equal(result.acceptanceBasis, 'council');
  assert.equal(load(f.root).acceptedRevision, 'demo-candidate');
  assert.equal(load(f.root).experiments[0].reviews.some(r => r.kind === 'human'), false);
});

test('a functional failure vetoes positive reviews and preserves baseline', t => {
  const f = setup(t); f.report.trials[3].checks.recovery = 'fail';
  reviewed(f, submitted(f));
  assert.equal(decide(f.root, f.proposal.id).status, 'reject');
  assert.throws(() => close(f.root, f.proposal.id, 'accepted', 'ignore failure'), /Cannot accept/);
  assert.equal(load(f.root).acceptedRevision, 'demo-base');
});

test('an incomplete check remains unverified instead of passing', t => {
  const f = setup(t); delete f.report.trials[0].checks.feedback; submitted(f);
  assert.equal(decide(f.root, f.proposal.id).status, 'needs-evidence');
});

test('a reproduced baseline defect can be fixed instead of vetoing all improvement', t => {
  const f = setup(t); f.report.trials[0].checks.recovery = 'fail';
  reviewed(f, submitted(f));
  assert.equal(decide(f.root, f.proposal.id).status, 'eligible');
});

test('performance regression in a validation seed vetoes the candidate', t => {
  const f = setup(t); f.report.trials.at(-1).metrics['frame-p95'] = 25;
  reviewed(f, submitted(f));
  assert.equal(decide(f.root, f.proposal.id).status, 'reject');
});

test('same seeds and repeated runs are required across both variants', t => {
  const f = setup(t); f.report.trials.at(-1).seed = 'different'; submitted(f);
  assert.match(decide(f.root, f.proposal.id).reasons.join(' '), /seeds differ/);
});

test('omitting validation scenarios cannot produce an eligible candidate', t => {
  const f = setup(t); f.report.trials = f.report.trials.filter(r => r.scenarioId === 'core');
  reviewed(f, submitted(f));
  assert.equal(decide(f.root, f.proposal.id).status, 'needs-evidence');
});

test('screenshots alone cannot establish action and consequence', t => {
  const f = setup(t); f.report.artifacts.forEach(a => { a.kind = 'screenshot'; }); submitted(f);
  assert.match(decide(f.root, f.proposal.id).reasons.join(' '), /screenshots alone/);
});

test('changed artifact contents invalidate decisions and acceptance', t => {
  const f = setup(t); reviewed(f, submitted(f));
  const state = load(f.root), file = state.experiments[0].report.artifacts[0].path;
  fs.writeFileSync(path.join(f.root, file), 'altered');
  assert.throws(() => decide(f.root, f.proposal.id), /Artifact changed/);
  assert.throws(() => close(f.root, f.proposal.id, 'accepted', 'stale'), /Artifact changed/);
});

test('evidence, reviews and proposals cannot silently change after submission', t => {
  const f = setup(t), hash = submitted(f);
  assert.throws(() => submit(f.root, f.proposal.id, f.report, f.source), /immutable/);
  assert.throws(() => review(f.root, f.proposal.id, f.model('stale')), /current evidenceDigest/);
  const file = path.join(f.root, 'state.json'), state = load(f.root);
  state.experiments[0].proposal.change = 'changed after evaluation';
  fs.writeFileSync(file, JSON.stringify(state));
  assert.throws(() => load(f.root), /Proposal changed/);
  assert.ok(hash);
});

test('synthetic evidence cannot be imported into a real campaign', t => {
  const f = setup(t, f => { f.config.mode = 'real'; });
  assert.throws(() => submitted(f), /mode mismatch/);
});

test('explicit opt-in human mode still requires actual human feedback', t => {
  const f = setup(t, f => { f.config.acceptance = { mode: 'human' }; }), hash = submitted(f);
  assert.throws(() => review(f.root, f.proposal.id, { ...f.human(hash), playedBoth: false }), /actually playing/);
  reviewed(f, hash);
  assert.equal(decide(f.root, f.proposal.id).status, 'needs-human-playtest');
  review(f.root, f.proposal.id, { ...f.human(hash), reviewer: 'second-human-fixture', preference: 'baseline' });
  assert.equal(decide(f.root, f.proposal.id).status, 'reject');
});

test('multiple reviewers on one provider do not simulate an independent council', t => {
  const f = setup(t), hash = submitted(f);
  review(f.root, f.proposal.id, f.model(hash));
  assert.throws(() => review(f.root, f.proposal.id, { ...f.model(hash), reviewer: 'another-model' }), /one council vote/);
  review(f.root, f.proposal.id, f.human(hash));
  assert.equal(decide(f.root, f.proposal.id).status, 'needs-model-review');
});

test('accepting one candidate makes competing experiments stale', t => {
  const f = setup(t);
  propose(f.root, { ...f.proposal, id: 'competitor', candidateRevision: 'demo-other' });
  reviewed(f, submitted(f)); close(f.root, f.proposal.id, 'accepted', 'fixture');
  assert.equal(decide(f.root, 'competitor').status, 'reject');
});

test('budget reservations prevent overbooking, actual overrun remains recorded', t => {
  const f = setup(t, f => { f.config.budget.maxMinutes = 10; });
  assert.throws(() => propose(f.root, { ...f.proposal, id: 'second' }), /budget exhausted/);
  f.report.minutes = 11; submitted(f);
  assert.equal(accounting(load(f.root)).minutes, 11);
  assert.equal(decide(f.root, f.proposal.id).status, 'reject');
  assert.throws(() => propose(f.root, { ...f.proposal, id: 'third', estimatedMinutes: 0 }), /budget exhausted/);
});

test('no-gain stop and experiment cap stop endless unsuccessful iteration', t => {
  const f = setup(t, f => { f.config.budget.stopAfterNoGain = 1; });
  close(f.root, f.proposal.id, 'rejected', 'No benefit');
  assert.throws(() => propose(f.root, { ...f.proposal, id: 'second' }), /stop reached/);
  const config = structuredClone(f.config); config.budget.maxExperiments = 0;
  assert.throws(() => validateConfig(config), /budgets/);
});

test('contract edits, duplicate seeds and wrong build evidence are rejected', t => {
  const f = setup(t);
  const duplicate = structuredClone(f.report); duplicate.trials.push(duplicate.trials[0]);
  assert.throws(() => submit(f.root, f.proposal.id, duplicate, f.source), /Duplicate/);
  const wrong = structuredClone(f.report); wrong.artifacts[0].revision = 'wrong';
  assert.throws(() => submit(f.root, f.proposal.id, wrong, f.source), /revision mismatch/);
  const file = path.join(f.root, 'state.json'), state = load(f.root);
  state.config.checks = []; fs.writeFileSync(file, JSON.stringify(state));
  assert.throws(() => load(f.root), /check ids/);
});

test('a second writer is refused and cannot clear an existing lock', t => {
  const f = setup(t), lock = path.join(f.root, '.lock'); fs.mkdirSync(lock);
  assert.throws(() => close(f.root, f.proposal.id, 'rejected', 'racing'), /EEXIST/);
  assert.ok(fs.existsSync(lock)); fs.rmdirSync(lock);
  close(f.root, f.proposal.id, 'rejected', 'clean close');
  assert.equal(decide(f.root, f.proposal.id).status, 'rejected');
});

test('CLI supports paths with spaces, reports failure and never overwrites a campaign', t => {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'funclimb cli '));
  t.after(() => fs.rmSync(temp, { recursive: true, force: true }));
  const cli = fileURLToPath(new URL('../plugins/funclimb/scripts/funclimb.mjs', import.meta.url));
  const config = syntheticFixture(path.join(temp, 'source')).config;
  const file = path.join(temp, 'config.json'), root = path.join(temp, 'campaign with spaces');
  fs.writeFileSync(file, JSON.stringify(config));
  const run = (...args) => spawnSync(process.execPath, [cli, ...args], { encoding: 'utf8' });
  assert.equal(run('init', root, file).status, 0);
  const status = run('status', root);
  assert.equal(status.status, 0);
  assert.equal(JSON.parse(status.stdout).acceptance.mode, 'council');
  assert.equal(run('init', root, file).status, 1);
  assert.equal(run('decide', root, 'missing').status, 1);
  assert.equal(run('bogus').status, 1);
});

test('ties and low-confidence praise cause an automatic no-gain rejection, not a human wait', t => {
  const f = setup(t), hash = submitted(f);
  review(f.root, f.proposal.id, { ...f.model(hash), confidence: 'low' });
  review(f.root, f.proposal.id, { ...f.model(hash, 'synthetic-provider-b'), preference: 'tie' });
  review(f.root, f.proposal.id, { ...f.model(hash, 'synthetic-provider-c'), preference: 'inconclusive' });
  assert.equal(decide(f.root, f.proposal.id).status, 'no-clear-gain');
  assert.equal(advance(f.root, f.proposal.id).outcome, 'rejected');
  assert.equal(load(f.root).acceptedRevision, 'demo-base');
  assert.equal(accounting(load(f.root)).noGain, 1);
  propose(f.root, { ...f.proposal, id: 'next-hypothesis' });
});

test('a blocking council finding vetoes approval votes', t => {
  const f = setup(t), hash = submitted(f);
  review(f.root, f.proposal.id, f.model(hash));
  review(f.root, f.proposal.id, f.model(hash, 'synthetic-provider-b'));
  review(f.root, f.proposal.id, { ...f.model(hash, 'synthetic-provider-c'), blockingFindings: ['Synthetic trace reveals obscured action feedback.'] });
  assert.equal(advance(f.root, f.proposal.id).outcome, 'rejected');
  assert.equal(load(f.root).acceptedRevision, 'demo-base');
});

test('council receipts must ground comparison in both variants and cannot swap providers', t => {
  const f = setup(t), hash = submitted(f), receipt = f.model(hash);
  assert.throws(() => review(f.root, f.proposal.id, { ...receipt, provider: 'unplanned-reviewer' }), /frozen council/);
  assert.throws(() => review(f.root, f.proposal.id, { ...receipt, evidenceRefs: [] }), /artifact hashes/);
  assert.throws(() => review(f.root, f.proposal.id, { ...receipt, evidenceRefs: receipt.evidenceRefs.slice(0, 1) }), /both variants/);
  assert.throws(() => review(f.root, f.proposal.id, { ...receipt, blockingFindings: undefined }), /blockingFindings/);
});

test('optional human calibration cannot quietly restore a human gate in council mode', t => {
  const f = setup(t), hash = submitted(f); reviewed(f, hash);
  review(f.root, f.proposal.id, { ...f.human(hash), preference: 'baseline' });
  assert.equal(advance(f.root, f.proposal.id).acceptanceBasis, 'council');
  assert.equal(load(f.root).experiments[0].reviews.filter(r => r.kind === 'human').length, 1);
});

test('legacy campaigns retain their original human policy instead of being silently regraded', t => {
  const f = setup(t, f => { f.config.schemaVersion = 1; delete f.config.acceptance; });
  const hash = submitted(f); reviewed(f, hash);
  assert.equal(advance(f.root, f.proposal.id).status, 'needs-human-playtest');
  review(f.root, f.proposal.id, f.human(hash));
  assert.equal(advance(f.root, f.proposal.id).acceptanceBasis, 'human');
});

test('autonomous council promotions can ratchet through multiple successive candidates', t => {
  const f = setup(t);
  for (let round = 1; round <= 3; round++) {
    const id = round === 1 ? f.proposal.id : `round-${round}`;
    const baseline = load(f.root).acceptedRevision;
    const candidate = round === 1 ? f.proposal.candidateRevision : `champion-${round}`;
    if (round > 1) propose(f.root, { ...f.proposal, id, baselineRevision: baseline, candidateRevision: candidate });
    const report = structuredClone(f.report);
    report.baselineRevision = baseline; report.candidateRevision = candidate;
    report.artifacts.forEach(a => { a.revision = report[a.variant + 'Revision']; });
    const hash = submit(f.root, id, report, f.source).evidenceDigest;
    for (const provider of f.config.acceptance.providers) review(f.root, id, f.model(hash, provider));
    assert.equal(advance(f.root, id).outcome, 'accepted');
    // The first existing fixture candidate is the first champion in the chain.
    if (round === 1) assert.equal(load(f.root).acceptedRevision, 'demo-candidate');
  }
  assert.equal(load(f.root).acceptedRevision, 'champion-3');
});

test('new campaign policies require a fixed panel and a strict majority', t => {
  const f = setup(t), config = structuredClone(f.config);
  config.acceptance.votesRequired = 1;
  assert.throws(() => validateConfig(config), /strict majority/);
  config.acceptance.votesRequired = 2; config.acceptance.providers.pop();
  assert.throws(() => validateConfig(config), /match the fixed council/);
});

test('two subscription providers must both prefer the candidate; no third provider is needed', t => {
  const f = setup(t, f => { f.config.minModelProviders = 2; f.config.acceptance.providers.pop(); });
  const hash = submitted(f);
  review(f.root, f.proposal.id, f.model(hash));
  assert.equal(decide(f.root, f.proposal.id).status, 'needs-model-review');
  review(f.root, f.proposal.id, f.model(hash, 'synthetic-provider-b'));
  assert.equal(advance(f.root, f.proposal.id).acceptanceBasis, 'council');
});

test('two-provider disagreement retains the champion without requesting a person', t => {
  const f = setup(t, f => { f.config.minModelProviders = 2; f.config.acceptance.providers.pop(); });
  const hash = submitted(f);
  review(f.root, f.proposal.id, f.model(hash));
  review(f.root, f.proposal.id, { ...f.model(hash, 'synthetic-provider-b'), preference: 'baseline' });
  assert.equal(advance(f.root, f.proposal.id).outcome, 'rejected');
  assert.equal(load(f.root).acceptedRevision, 'demo-base');
});

test('API-equivalent subscription usage does not consume the incremental paid-spending budget', t => {
  const f = setup(t);
  f.report.usage = { billing: 'existing-subscriptions', apiEquivalentCostUsd: 150, note: 'Synthetic usage estimate, not a charge.' };
  f.report.costUsd = 0;
  reviewed(f, submitted(f));
  assert.equal(accounting(load(f.root)).costUsd, 0);
  assert.equal(advance(f.root, f.proposal.id).outcome, 'accepted');
});

test('subscription execution profiles cannot request an API fallback or silently change the panel', t => {
  const f = setup(t);
  const config = JSON.parse(fs.readFileSync(new URL('../plugins/funclimb/assets/campaign.template.json', import.meta.url), 'utf8'));
  assert.doesNotThrow(() => validateConfig(config));
  config.execution.allowApiFallback = true;
  assert.throws(() => validateConfig(config), /no API fallback/);
  config.execution.allowApiFallback = false;
  config.execution.reviewers[1].provider = 'unexpected-provider';
  assert.throws(() => validateConfig(config), /exactly match the fixed panel/);
  assert.ok(f.root);
});
