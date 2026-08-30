#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const pluginsDir = path.join(root, "plugins");
const allowedFrontmatter = new Set([
  "name",
  "description",
  "license",
  "compatibility",
  "metadata",
  "allowed-tools",
]);
const errors = [];

function walk(directory, filename, matches = []) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) walk(entryPath, filename, matches);
    if (entry.isFile() && entry.name === filename) matches.push(entryPath);
  }
  return matches;
}

function unquote(value) {
  const trimmed = value.trim();
  if (
    trimmed.length >= 2 &&
    ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
      (trimmed.startsWith("'") && trimmed.endsWith("'")))
  ) {
    return trimmed.slice(1, -1);
  }
  return trimmed;
}

function parseFrontmatter(file, source) {
  const lines = source.split(/\r?\n/);
  if (lines[0] !== "---") {
    errors.push(`${file}: SKILL.md must begin with YAML frontmatter`);
    return {};
  }
  const end = lines.indexOf("---", 1);
  if (end < 0) {
    errors.push(`${file}: frontmatter is not closed`);
    return {};
  }
  const values = {};
  for (const line of lines.slice(1, end)) {
    const match = line.match(/^([a-zA-Z0-9_-]+):\s*(.*)$/);
    if (!match) continue;
    const [, key, value] = match;
    if (!allowedFrontmatter.has(key)) {
      errors.push(`${file}: unsupported portable frontmatter key '${key}'`);
    }
    values[key] = unquote(value);
  }
  return values;
}

function validateRelativeLinks(file, source) {
  const linkPattern = /\[[^\]]+\]\(([^)]+)\)/g;
  for (const match of source.matchAll(linkPattern)) {
    const target = match[1].trim().replace(/^<|>$/g, "").split("#", 1)[0];
    if (!target || target.startsWith("#") || /^[a-z][a-z0-9+.-]*:/i.test(target)) continue;
    const resolved = path.resolve(path.dirname(file), decodeURIComponent(target));
    if (!fs.existsSync(resolved)) errors.push(`${file}: broken relative link '${target}'`);
  }
}

function readYamlField(source, key) {
  const match = source.match(new RegExp(`^\\s*${key}:\\s*["']?(.+?)["']?\\s*$`, "m"));
  return match?.[1] ?? "";
}

const skillFiles = walk(pluginsDir, "SKILL.md").sort();
const skillNames = [];

for (const absoluteFile of skillFiles) {
  const file = path.relative(root, absoluteFile);
  const source = fs.readFileSync(absoluteFile, "utf8");
  const frontmatter = parseFrontmatter(file, source);
  const expectedName = path.basename(path.dirname(absoluteFile));

  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(frontmatter.name ?? "")) {
    errors.push(`${file}: name must use lowercase hyphen-case`);
  }
  if (frontmatter.name !== expectedName) {
    errors.push(`${file}: name '${frontmatter.name}' must match directory '${expectedName}'`);
  }
  if (!frontmatter.description || frontmatter.description.length > 1024) {
    errors.push(`${file}: description must contain 1-1024 characters`);
  }
  if (!/\bUse when\b/i.test(frontmatter.description ?? "")) {
    errors.push(`${file}: description must state when the skill should trigger`);
  }
  if (source.split(/\r?\n/).length > 500 || source.length > 20000) {
    errors.push(`${file}: portable entrypoint exceeds the 500-line or ~5,000-token budget`);
  }

  const banned = [
    [/\$\{CLAUDE_/g, "Claude-only environment variables"],
    [/\$ARGUMENTS\b/g, "Claude command arguments"],
    [/!\s*`/g, "dynamic shell injection"],
    [/\bplugins\/[a-z0-9-]+\/scripts\//g, "source-checkout script paths"],
    [/\brandroid:/g, "client-specific slash-command names"],
  ];
  for (const [pattern, label] of banned) {
    if (pattern.test(source)) errors.push(`${file}: portable body contains ${label}`);
  }

  validateRelativeLinks(file, source);

  const openaiFile = path.join(path.dirname(absoluteFile), "agents", "openai.yaml");
  if (!fs.existsSync(openaiFile)) {
    errors.push(`${file}: missing agents/openai.yaml`);
  } else {
    const openai = fs.readFileSync(openaiFile, "utf8");
    const displayName = readYamlField(openai, "display_name");
    const shortDescription = readYamlField(openai, "short_description");
    const defaultPrompt = readYamlField(openai, "default_prompt");
    if (!displayName) errors.push(`${path.relative(root, openaiFile)}: missing display_name`);
    if (shortDescription.length < 25 || shortDescription.length > 64) {
      errors.push(`${path.relative(root, openaiFile)}: short_description must contain 25-64 characters`);
    }
    if (!defaultPrompt.includes(`$${frontmatter.name}`)) {
      errors.push(`${path.relative(root, openaiFile)}: default_prompt must mention $${frontmatter.name}`);
    }
  }

  skillNames.push(frontmatter.name);
}

const triggerFile = path.join(root, "tests", "trigger-cases.json");
if (!fs.existsSync(triggerFile)) {
  errors.push("tests/trigger-cases.json: missing trigger fixtures");
} else {
  const fixtures = JSON.parse(fs.readFileSync(triggerFile, "utf8"));
  const fixtureNames = Object.keys(fixtures).sort();
  const expectedNames = [...skillNames].sort();
  if (JSON.stringify(fixtureNames) !== JSON.stringify(expectedNames)) {
    errors.push("tests/trigger-cases.json: fixture names must exactly match discovered skill names");
  }
  for (const [name, cases] of Object.entries(fixtures)) {
    const positive = cases.filter((entry) => entry.shouldTrigger === true);
    const negative = cases.filter((entry) => entry.shouldTrigger === false);
    if (positive.length < 2 || negative.length < 2) {
      errors.push(`tests/trigger-cases.json: ${name} needs at least two positive and two negative cases`);
    }
    if (cases.some((entry) => typeof entry.prompt !== "string" || !entry.prompt.trim())) {
      errors.push(`tests/trigger-cases.json: ${name} contains an empty prompt`);
    }
  }
}

const pluginNames = [];
for (const pluginDir of fs.readdirSync(pluginsDir, { withFileTypes: true }).filter((entry) => entry.isDirectory())) {
  if (!fs.existsSync(path.join(pluginsDir, pluginDir.name, "SKILL.md"))) continue;
  pluginNames.push(pluginDir.name);
  const manifest = path.join(pluginsDir, pluginDir.name, ".claude-plugin", "plugin.json");
  if (!fs.existsSync(manifest)) {
    errors.push(`${path.relative(root, manifest)}: missing Claude plugin manifest`);
    continue;
  }
  const data = JSON.parse(fs.readFileSync(manifest, "utf8"));
  if (data.name !== pluginDir.name) errors.push(`${path.relative(root, manifest)}: name must match plugin directory`);
  if (!data.version || !data.description || !data.author?.name) {
    errors.push(`${path.relative(root, manifest)}: version, description, and author.name are required`);
  }
}

const marketplaceFile = path.join(root, ".claude-plugin", "marketplace.json");
const marketplace = JSON.parse(fs.readFileSync(marketplaceFile, "utf8"));
const marketplaceNames = marketplace.plugins.map((plugin) => plugin.name).sort();
if (JSON.stringify(marketplaceNames) !== JSON.stringify(pluginNames.sort())) {
  errors.push(".claude-plugin/marketplace.json: entries must exactly match top-level plugin directories");
}

const catalogDir = path.join(root, ".agents", "skills");
const catalogNames = fs.readdirSync(catalogDir).sort();
if (JSON.stringify(catalogNames) !== JSON.stringify([...skillNames].sort())) {
  errors.push(".agents/skills: direct catalog entries must exactly match discovered skill names");
}
for (const name of skillNames) {
  const catalogEntry = path.join(catalogDir, name);
  if (!fs.lstatSync(catalogEntry).isSymbolicLink()) {
    errors.push(`${path.relative(root, catalogEntry)}: catalog entry must be a symlink to its source skill`);
  } else if (!fs.existsSync(path.join(catalogEntry, "SKILL.md"))) {
    errors.push(`${path.relative(root, catalogEntry)}: catalog symlink does not resolve to a skill`);
  }
}

const legacyCodexLink = path.join(root, ".codex", "skills");
if (!fs.lstatSync(legacyCodexLink).isSymbolicLink() || fs.readlinkSync(legacyCodexLink) !== "../.agents/skills") {
  errors.push(".codex/skills: must point to ../.agents/skills");
}

if (errors.length) {
  for (const error of errors) console.error(`ERROR ${error}`);
  process.exit(1);
}

console.log(`Validated ${skillFiles.length} portable skills, Codex metadata files, Claude manifests, links, and trigger fixtures.`);
