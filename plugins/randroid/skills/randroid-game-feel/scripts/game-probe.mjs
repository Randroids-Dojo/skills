#!/usr/bin/env node
// Optional browser diagnostics. Collection success is not a gameplay verdict.
import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { parseArgs, summarizeInput } from "./probe-observations.mjs";

const usage = "node game-probe.mjs <url> [--input none|key|pointer|both] [--key KeyD] [--hold 700] [--settle 1500] [--start <CSS selector>] [--ready <CSS selector>] [--out dir] [--headed]";
let options;
try { options = parseArgs(process.argv.slice(2)); }
catch (error) { console.error(error.message); process.exit(1); }
if (options.help) { console.log(usage); process.exit(0); }

function loadPlaywright() {
  const bases = [path.join(process.cwd(), "package.json"), import.meta.url];
  for (const base of bases) {
    const req = createRequire(base);
    for (const name of ["@playwright/test", "playwright", "playwright-core"]) {
      try {
        const mod = req(name);
        if (mod && mod.chromium) return mod;
      } catch {}
    }
  }
  return null;
}


// Injected before any page script: counts frame requests, audio contexts,
// input listeners, pointer-lock requests, and gamepad polls.
const INSTRUMENT = `(() => {
  const P = (window.__gameProbe = { raf: 0, audioContexts: 0, listeners: {}, pointerLockRequests: 0, gamepadPolls: 0 });
  const raf = window.requestAnimationFrame.bind(window);
  window.requestAnimationFrame = (cb) => { P.raf++; return raf(cb); };
  for (const name of ["AudioContext", "webkitAudioContext"]) {
    const Orig = window[name];
    if (!Orig) continue;
    window[name] = new Proxy(Orig, { construct(target, a) { P.audioContexts++; return new target(...a); } });
  }
  const origAdd = EventTarget.prototype.addEventListener;
  EventTarget.prototype.addEventListener = function (type, ...rest) {
    P.listeners[type] = (P.listeners[type] || 0) + 1;
    return origAdd.call(this, type, ...rest);
  };
  if (Element.prototype.requestPointerLock) {
    const o = Element.prototype.requestPointerLock;
    Element.prototype.requestPointerLock = function (...a) { P.pointerLockRequests++; return o.apply(this, a); };
  }
  if (navigator.getGamepads) {
    const o = navigator.getGamepads.bind(navigator);
    navigator.getGamepads = () => { P.gamepadPolls++; return o(); };
  }
})();`;

// Runs inside the game page: what is on screen right now?
const AUDIT = () => {
  const vw = innerWidth, vh = innerHeight;
  const vis = (el) => {
    const r = el.getBoundingClientRect();
    const s = getComputedStyle(el);
    return r.width > 0 && r.height > 0 && s.visibility !== "hidden" && s.display !== "none" && Number(s.opacity) > 0.05 && r.bottom > 0 && r.right > 0 && r.top < vh && r.left < vw;
  };
  const q = (sel) => [...document.querySelectorAll(sel)].filter(vis);
  const canvases = q("canvas").map((c) => {
    const r = c.getBoundingClientRect();
    const w = Math.max(0, Math.min(r.right, vw) - Math.max(r.left, 0));
    const h = Math.max(0, Math.min(r.bottom, vh) - Math.max(r.top, 0));
    return { w: Math.round(r.width), h: Math.round(r.height), coverage: Number(((w * h) / (vw * vh)).toFixed(3)) };
  });
  const buttons = q("button, [role=button], input[type=button], input[type=submit]");
  const label = (b) => (b.innerText || b.value || b.getAttribute("aria-label") || "").trim().replace(/\s+/g, " ").slice(0, 30);
  return {
    viewport: { w: vw, h: vh },
    canvases,
    maxCanvasCoverage: canvases.reduce((m, c) => Math.max(m, c.coverage), 0),
    buttons: buttons.length,
    buttonLabels: buttons.slice(0, 12).map(label),
    links: q("a[href]").length,
    fields: q("input:not([type=button]):not([type=submit]):not([type=hidden]), select, textarea").length,
    dialogs: q("dialog[open], [role=dialog], [aria-modal=true]").length,
    forms: q("form").length,
    audioElements: document.querySelectorAll("audio").length,
    scrollable: document.documentElement.scrollHeight > vh + 4 || document.body.scrollHeight > vh + 4,
    words: ((document.body && document.body.innerText) || "").trim().split(/\s+/).filter(Boolean).length,
    pointerLocked: !!document.pointerLockElement,
    probe: window.__gameProbe || null,
  };
};

// Runs inside a scratch page so the game page is never disturbed:
// fraction of downscaled pixels that differ between two screenshots.
const DIFF = async ([a, b]) => {
  const load = (src) => new Promise((res, rej) => { const im = new Image(); im.onload = () => res(im); im.onerror = rej; im.src = src; });
  const [ia, ib] = await Promise.all([load(a), load(b)]);
  const W = 320, H = 180;
  const draw = (im) => { const c = document.createElement("canvas"); c.width = W; c.height = H; const x = c.getContext("2d"); x.drawImage(im, 0, 0, W, H); return x.getImageData(0, 0, W, H).data; };
  const da = draw(ia), db = draw(ib);
  let changed = 0;
  const total = W * H;
  for (let i = 0; i < da.length; i += 4) {
    if (Math.abs(da[i] - db[i]) > 24 || Math.abs(da[i + 1] - db[i + 1]) > 24 || Math.abs(da[i + 2] - db[i + 2]) > 24) changed++;
  }
  return changed / total;
};


const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function main() {
  const pw = loadPlaywright();
  if (!pw) throw new Error("Run from a project with Playwright and Chromium already installed.");
  const out = path.resolve(options.out);
  if (fs.existsSync(out) && fs.readdirSync(out).length > 0) throw new Error("Choose an empty output directory to preserve earlier evidence.");
  fs.mkdirSync(out, { recursive: true });
  const browser = await pw.chromium.launch({ headless: !options.headed });
  try {
    const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
    await context.addInitScript(INSTRUMENT);
    const page = await context.newPage();
    const scratch = await context.newPage();
    await page.bringToFront();
    const consoleErrors = [];
    page.on("pageerror", (error) => consoleErrors.push(String(error.message || error)));
    page.on("console", (message) => { if (message.type() === "error") consoleErrors.push(message.text()); });

    const shot = async (name) => {
      const buffer = await page.screenshot({ type: "png", fullPage: false });
      if (name) fs.writeFileSync(path.join(out, name + ".png"), buffer);
      return "data:image/png;base64," + buffer.toString("base64");
    };
    const diff = (a, b) => scratch.evaluate(DIFF, [a, b]);
    const rafRequestsPerSecond = async () => {
      const a = await page.evaluate(() => window.__gameProbe?.raf || 0);
      const begin = performance.now();
      await sleep(1000);
      const b = await page.evaluate(() => window.__gameProbe?.raf || 0);
      return Number(((b - a) * 1000 / (performance.now() - begin)).toFixed(1));
    };

    const began = performance.now();
    await page.goto(options.url, { waitUntil: "load", timeout: 45000 });
    await sleep(options.settle);
    await shot("boot");
    const bootCapturedAtMs = Math.round(performance.now() - began);
    const auditBoot = await page.evaluate(AUDIT);
    // Start and ready selectors must come from the actual game/tooling context.
    if (options.start) {
      const start = page.locator(options.start);
      if (await start.count() !== 1) throw new Error("--start must match exactly one element.");
      await start.click({ timeout: 5000 });
    }
    if (options.ready) await page.locator(options.ready).waitFor({ state: "visible", timeout: 15000 });
    await shot("play");
    const raf = await rafRequestsPerSecond();
    const idleA = await shot("idle-a");
    await sleep(500);
    const idleB = await shot("idle-b");
    const idleDiff = await diff(idleA, idleB);
    const threshold = 0.003;
    const focusBefore = await page.evaluate(() => document.hasFocus());

    const inputTrial = async (label, act, release) => {
      const baseline = await shot("before-" + label);
      const begin = performance.now();
      let firstChangeSampleAtMs = null, samples = 0, peakDiff = 0;
      try {
        await act();
        // Keep the declared observation window even after detecting a change.
        do {
          const frame = await shot();
          const difference = await diff(baseline, frame);
          samples++;
          peakDiff = Math.max(peakDiff, difference);
          if (difference > threshold && firstChangeSampleAtMs === null) {
            firstChangeSampleAtMs = Math.round(performance.now() - begin);
            fs.writeFileSync(path.join(out, "change-" + label + ".png"), Buffer.from(frame.split(",")[1], "base64"));
          }
        } while (performance.now() - begin < options.hold);
      } finally {
        await release();
      }
      await shot("after-" + label);
      return { label, firstChangeSampleAtMs, samples, peakDiff: Number(peakDiff.toFixed(4)),
        elapsedMs: Math.round(performance.now() - begin) };
    };

    const input = { key: null, pointer: null };
    if (options.input !== "none" && !focusBefore) throw new Error("Game page is not focused; no synthetic input was sent.");
    if (["key", "both"].includes(options.input)) {
      input.key = await inputTrial("key", () => page.keyboard.down(options.key), () => page.keyboard.up(options.key));
    }
    if (["pointer", "both"].includes(options.input)) {
      input.pointer = await inputTrial("pointer", async () => {
        for (let i = 0; i <= 8; i++) {
          await page.mouse.move(440 + i * 50, 360 + Math.sin(i) * 60);
          await sleep(12);
        }
      }, async () => {});
    }
    const focusAfter = await page.evaluate(() => document.hasFocus());
    const invalidReasons = options.input !== "none" && !focusAfter ? ["Focus was lost during the input observations."] : [];
    const auditPlay = await page.evaluate(AUDIT);
    await shot("final");
    const probe = auditPlay.probe || {};
    const report = {
      schemaVersion: 2, collectionStatus: "complete", capturedAt: new Date().toISOString(),
      url: options.url, options, bootCapturedAtMs,
      inputObservation: summarizeInput(input, invalidReasons),
      measurements: {
        rafRequestsPerSecond: raf, idleMotionFraction: Number(idleDiff.toFixed(4)),
        pixelChangeThreshold: threshold, input,
        focusBefore, focusAfter,
        audit: { boot: { ...auditBoot, probe: undefined }, play: { ...auditPlay, probe: undefined } },
        listenersRegistered: probe.listeners || {}, audioContextsCreated: probe.audioContexts || 0,
        pointerLockRequests: probe.pointerLockRequests || 0, gamepadPollCalls: probe.gamepadPolls || 0,
      },
      limitations: [
        "rAF requests are neither rendered FPS nor simulation ticks; worker/iframe loops may be missing.",
        "Pixel sampling does not isolate input causality or measure input latency.",
        "Widget counts, canvas coverage, audio objects, and idle motion do not grade the chosen genre.",
        "Boot capture follows page load and settling; it is not the first displayed frame or time to control.",
        "Start with the intended scenario and verify action, state transition, feedback, and recovery separately.",
      ],
      consoleErrors: consoleErrors.slice(0, 10),
    };
    fs.writeFileSync(path.join(out, "report.json"), JSON.stringify(report, null, 2) + "\n");
    console.log("Collected diagnostic observations: " + report.inputObservation.status);
    console.log("Gameplay and input latency remain unverified. Artifacts: " + out);
    if (report.inputObservation.status === "INVALID") process.exitCode = 2;
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  console.error("game-probe error: " + (error?.message || error));
  process.exitCode = 1;
});
