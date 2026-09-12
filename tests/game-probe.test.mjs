import assert from "node:assert/strict";
import test from "node:test";
import { parseArgs, summarizeInput } from "../plugins/randroid/skills/randroid-game-feel/scripts/probe-observations.mjs";

test("collection without requested input leaves gameplay untested", () => {
  const result = summarizeInput({ key: null, pointer: null });
  assert.equal(result.status, "NOT_TESTED");
  assert.equal(result.gameplayVerified, null);
  assert.equal(result.inputLatencyMs, null);
});

test("a still card scene supplies no evidence of failed gameplay", () => {
  const result = summarizeInput({ key: { firstChangeSampleAtMs: null, samples: 12 } });
  assert.equal(result.status, "NO_CHANGE_OBSERVED");
  assert.equal(result.gameplayVerified, null);
});

test("spinning scenery cannot certify the intended driving action or latency", () => {
  const result = summarizeInput({ key: { firstChangeSampleAtMs: 12, samples: 30 } });
  assert.equal(result.status, "CHANGE_OBSERVED");
  assert.equal(result.gameplayVerified, null);
  assert.equal(result.inputLatencyMs, null);
});

test("invalid focus overrides a pixel change", () => {
  const result = summarizeInput({ key: { firstChangeSampleAtMs: 0, samples: 1 } }, ["Focus lost"]);
  assert.equal(result.status, "INVALID");
  assert.deepEqual(result.invalidReasons, ["Focus lost"]);
  assert.equal(result.gameplayVerified, null);
});

test("missing samples and invalid timestamps cannot appear as successful observations", () => {
  for (const trial of [
    { samples: 0, firstChangeSampleAtMs: null },
    { firstChangeSampleAtMs: 20 },
    { samples: 1, firstChangeSampleAtMs: -1 },
    { samples: 1, firstChangeSampleAtMs: NaN },
    { samples: 1, firstChangeSampleAtMs: Infinity },
  ]) assert.equal(summarizeInput({ key: trial }).status, "INVALID");
});

test("one invalid trial invalidates a batch containing a visible change", () => {
  assert.equal(summarizeInput({
    key: { samples: 3, firstChangeSampleAtMs: 80 },
    pointer: { samples: 0, firstChangeSampleAtMs: null },
  }).status, "INVALID");
});

test("input is opt-in and options may precede the URL", () => {
  assert.equal(parseArgs(["https://example.test"]).input, "none");
  const result = parseArgs(["--out", "evidence path", "--input", "key", "--key", "Space", "https://example.test", "--hold", "1000", "--settle", "0"]);
  assert.equal(result.url, "https://example.test");
  assert.equal(result.out, "evidence path");
  assert.equal(result.key, "Space");
  assert.equal(result.hold, 1000);
  assert.equal(result.settle, 0);
});

test("bad or unbounded capture arguments fail before opening a browser", () => {
  for (const args of [
    [], ["file:///C:/private.txt"], ["https://example.test", "extra"],
    ["https://example.test", "--input", "guess"],
    ["https://example.test", "--click", "auto"],
    ["https://example.test", "--hold"],
    ...["NaN", "-1", "0", "1.5", "10001"].map((n) => ["https://example.test", "--hold", n]),
    ["https://example.test", "--settle", "30001"],
  ]) assert.throws(() => parseArgs(args));
});

test("help needs no URL or runtime dependencies", () => {
  assert.deepEqual(parseArgs(["--help"]), { help: true });
});
