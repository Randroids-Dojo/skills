#!/usr/bin/env node

import fs from "node:fs";
import { stripVTControlCharacters } from "node:util";

// validate-portability.mjs checks that these names match the source SKILL.md files.
const expected = Object.keys(
  JSON.parse(fs.readFileSync(new URL("../tests/trigger-cases.json", import.meta.url), "utf8")),
).sort();
const output = stripVTControlCharacters(fs.readFileSync(0, "utf8"));
const discovered = new Set(
  output
    .split(/\r?\n/)
    .map((line) => line.match(/^\s*[│|]\s+([a-z0-9]+(?:-[a-z0-9]+)*)\s*$/u)?.[1])
    .filter(Boolean),
);
const missing = expected.filter((name) => !discovered.has(name));
const unexpected = [...discovered].filter((name) => !expected.includes(name)).sort();
const mode = process.argv[2] ?? "default";

if (missing.length || unexpected.length) {
  console.error("Skills CLI " + mode + " discovery does not match the source catalog.");
  if (missing.length) console.error("Missing: " + missing.join(", "));
  if (unexpected.length) console.error("Unexpected: " + unexpected.join(", "));
  process.exit(1);
}

console.log("Verified " + mode + " CLI discovery of all " + expected.length + " skills.");
