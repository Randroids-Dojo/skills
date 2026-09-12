// Pixel changes are observations, not causal input tests or gameplay judgments.
export function summarizeInput(input, invalidReasons = []) {
  const trials = Object.values(input || {}).filter((trial) => trial != null);
  const invalid = [...invalidReasons];
  if (trials.some((trial) => !Number.isInteger(trial.samples) || trial.samples < 1)) {
    invalid.push("An attempted input has no screenshot samples.");
  }
  for (const trial of trials) {
    if (trial.firstChangeSampleAtMs != null &&
        (!Number.isFinite(trial.firstChangeSampleAtMs) || trial.firstChangeSampleAtMs < 0)) {
      invalid.push("An input observation has an invalid sample timestamp.");
    }
  }
  const observed = trials.some((trial) => trial.firstChangeSampleAtMs != null);
  const status = invalid.length ? "INVALID" : trials.length === 0 ? "NOT_TESTED" :
    observed ? "CHANGE_OBSERVED" : "NO_CHANGE_OBSERVED";
  return {
    status,
    invalidReasons: invalid,
    gameplayVerified: null,
    inputLatencyMs: null,
    interpretation: "Changes may come from idle animation, hover, focus, or unrelated state. No change may mean the wrong input, hidden feedback, or a still/discrete game. Verify the intended state transition separately.",
  };
}

export function parseArgs(args) {
  const options = { input: "none", key: "KeyD", hold: 700, settle: 1500,
    start: "", ready: "", out: "game-probe-out", headed: false };
  const valued = new Set(["input", "key", "hold", "settle", "start", "ready", "out"]);
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (arg === "--help") return { help: true };
    if (arg === "--headed") { options.headed = true; continue; }
    if (arg.startsWith("--")) {
      const name = arg.slice(2);
      if (!valued.has(name)) throw new Error(`Unknown option ${arg}`);
      if (!args[i + 1] || args[i + 1].startsWith("--")) throw new Error(`Missing value for ${arg}`);
      options[name] = args[++i];
    } else {
      if (options.url) throw new Error(`Unexpected argument ${arg}`);
      options.url = arg;
    }
  }
  if (!options.url) throw new Error("A URL is required (see --help).");
  if (!["http:", "https:"].includes(new URL(options.url).protocol)) throw new Error("Use an HTTP(S) URL.");
  if (!["none", "key", "pointer", "both"].includes(options.input)) throw new Error("--input must be none, key, pointer, or both.");
  for (const [name, min, max] of [["hold", 1, 10000], ["settle", 0, 30000]]) {
    options[name] = Number(options[name]);
    if (!Number.isInteger(options[name]) || options[name] < min || options[name] > max) {
      throw new Error(`--${name} must be an integer from ${min} to ${max} milliseconds.`);
    }
  }
  return options;
}
