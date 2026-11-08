#!/usr/bin/env node
// Synthetic end-to-end run of the coordinator. Usage: node demo.mjs <output-dir>
import * as fs from 'node:fs';
import path from 'node:path';
import { syntheticFixture } from './synthetic.mjs';
import { initialize, propose, submit, review, decide, advance } from './core.mjs';

const target = process.argv[2];
if (!target) {
  console.error('Usage: node demo.mjs <output-dir>');
  process.exit(1);
}
const base = path.resolve(target);
fs.mkdirSync(base, { recursive: true });
const run = fs.mkdtempSync(path.join(base, 'run-'));
const source = path.join(run, 'source'), campaign = path.join(run, 'campaign');
const f = syntheticFixture(source);
f.config.acceptance.providers = ['synthetic-provider-a', 'synthetic-provider-b'];
f.config.minModelProviders = 2;
const write = (file, data) => fs.writeFileSync(path.join(source, file), JSON.stringify(data, null, 2) + '\n');
write('config.json', f.config); write('proposal.json', f.proposal); write('report.json', f.report);
initialize(campaign, f.config);
propose(campaign, f.proposal);
const receipt = submit(campaign, f.proposal.id, f.report, source);
review(campaign, f.proposal.id, f.model(receipt.evidenceDigest));
console.log('SYNTHETIC ONLY. No model called, no game played, no money spent.');
console.log('After one provider reviews:', decide(campaign, f.proposal.id).status);
review(campaign, f.proposal.id, f.model(receipt.evidenceDigest, 'synthetic-provider-b'));
console.log('After both providers approve:', decide(campaign, f.proposal.id).status);
console.log(advance(campaign, f.proposal.id));
console.log('No human receipt needed. The synthetic champion advanced automatically.');
console.log('Receipts:', campaign);
