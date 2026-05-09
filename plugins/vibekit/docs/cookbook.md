# VibeKit Cookbook

Wire-up patterns for `@randroids-dojo/vibekit` modules. The kit's own [README](https://github.com/Randroids-Dojo/VibeKit) documents the API surface; this cookbook documents how each module composes into a typical consuming project.

Conventions used below:

- Examples assume a Next.js (App Router) + React project with TypeScript, since that is the dominant consumer shape. Adapt to your stack as needed.
- Every snippet uses the kit's tag-pinned dependency style: `"@randroids-dojo/vibekit": "github:Randroids-Dojo/VibeKit#vX.Y.Z"`.
- Server modules (kv, sign, rate-limit) are imported from `@randroids-dojo/vibekit/server`. Importing them from a client component is a build-time error.

---

## joystick

Float-where-you-tap touch joystick state. Pure state machine; the consumer wires pointer events and renders the visual.

```tsx
'use client'
import { useEffect, useRef, useState } from 'react'
import {
  beginJoystick,
  createJoystick,
  endJoystick,
  JOYSTICK_DEADZONE,
  JOYSTICK_RADIUS,
  moveJoystick,
  readJoystick,
} from '@randroids-dojo/vibekit'

export function VirtualJoystick({ onVector }: { onVector: (x: number, y: number) => void }) {
  const stickRef = useRef(createJoystick())
  const [, force] = useState(0)

  useEffect(() => {
    const onDown = (e: PointerEvent) => {
      beginJoystick(stickRef.current, e.pointerId, e.clientX, e.clientY)
      force(n => n + 1)
    }
    const onMove = (e: PointerEvent) => {
      moveJoystick(stickRef.current, e.clientX, e.clientY)
      const v = readJoystick(stickRef.current)
      const len = Math.hypot(v.x, v.y)
      onVector(len < JOYSTICK_DEADZONE ? 0 : v.x, len < JOYSTICK_DEADZONE ? 0 : v.y)
      force(n => n + 1)
    }
    const onUp = () => {
      endJoystick(stickRef.current)
      onVector(0, 0)
      force(n => n + 1)
    }
    window.addEventListener('pointerdown', onDown)
    window.addEventListener('pointermove', onMove)
    window.addEventListener('pointerup', onUp)
    window.addEventListener('pointercancel', onUp)
    return () => {
      window.removeEventListener('pointerdown', onDown)
      window.removeEventListener('pointermove', onMove)
      window.removeEventListener('pointerup', onUp)
      window.removeEventListener('pointercancel', onUp)
    }
  }, [onVector])

  // Render the base + knob from stickRef.current; the deflection vector
  // drives knob position relative to origin.
  // ...
}
```

Common gotchas:

- The kit does NOT apply the deadzone; the consumer does. Different consumers want different thresholds (a steering stick wants a tighter deadzone than a movement stick).
- One `JoystickState` per stick. A two-stick layout (steer + throttle) creates two state objects, each with its own pointer tracking.
- The state mutates in place. Wrapping it in React state is the wrong shape; use a ref + forced re-render or a render callback.

---

## editor-history

Generic `EditorHistory<T>` undo / redo stack. Wrap any value type with reference identity.

```tsx
'use client'
import { useCallback, useState } from 'react'
import {
  canRedo,
  canUndo,
  createHistory,
  pushHistory,
  redoHistory,
  undoHistory,
} from '@randroids-dojo/vibekit'

interface Piece { /* ... */ }

export function useTrackEditor(initial: Piece[]) {
  const [history, setHistory] = useState(() => createHistory(initial))
  const setPieces = useCallback(
    (next: Piece[] | ((prev: Piece[]) => Piece[])) => {
      setHistory(h => {
        const value = typeof next === 'function' ? (next as (p: Piece[]) => Piece[])(h.present) : next
        return pushHistory(h, value)
      })
    },
    [],
  )
  return {
    pieces: history.present,
    setPieces,
    undo: () => setHistory(undoHistory),
    redo: () => setHistory(redoHistory),
    canUndo: canUndo(history),
    canRedo: canRedo(history),
  }
}
```

Wire `Ctrl/Cmd+Z` and `Ctrl/Cmd+Shift+Z` to `undo` / `redo`, gating on `canUndo` / `canRedo`. Bail out when the focused element is an `input`, `textarea`, `select`, or `contentEditable` so form fields keep native undo.

Common gotchas:

- Reference equality: pushing a value that is `=== present` is a no-op. Spread arrays before mutating so each push is a new reference.
- The cap (`EDITOR_HISTORY_MAX_PAST = 100`) bounds memory regardless of `T`'s shape; a 4 KB `T` * 100 entries = 400 KB worst case.
- For non-recordable swaps (e.g. snap-to-cell preview), use `replacePresent`. For clearing both stacks, use `resetHistory`.

---

## confetti

Pure particle simulation for celebration overlays. The renderer (a 2D canvas component) owns the rAF loop; this module owns the particle math.

```tsx
'use client'
import { useEffect, useRef } from 'react'
import {
  CONFETTI_PB_COUNT,
  CONFETTI_PALETTE_PB,
  confettiAlpha,
  isBatchExpired,
  spawnConfettiBatch,
  stepConfetti,
  type ConfettiParticle,
} from '@randroids-dojo/vibekit'

export function PbCelebration({ trigger, seed }: { trigger: number; seed: number }) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    if (!trigger) return
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')!
    let particles: ConfettiParticle[] = spawnConfettiBatch({
      seed,
      count: CONFETTI_PB_COUNT,
      palette: CONFETTI_PALETTE_PB,
      originX: 0.5,
      originY: 0.4,
    })
    let last = performance.now()
    let raf = 0
    const tick = (now: number) => {
      const dt = (now - last) / 1000
      last = now
      particles = stepConfetti(particles, dt)
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      for (const p of particles) {
        ctx.globalAlpha = confettiAlpha(p)
        ctx.fillStyle = p.color
        ctx.fillRect(p.x * canvas.width, p.y * canvas.height, 6, 12)
      }
      ctx.globalAlpha = 1
      if (!isBatchExpired(particles)) raf = requestAnimationFrame(tick)
    }
    raf = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(raf)
  }, [trigger, seed])

  return <canvas ref={canvasRef} style={{ position: 'fixed', inset: 0, pointerEvents: 'none' }} />
}
```

Common gotchas:

- Coordinates are normalized 0-1. Multiply by canvas pixel size at draw time so a window resize never breaks the simulation in flight.
- The seed makes spawns deterministic. Two celebrations with the same seed and inputs produce the same particle layout; use a monotonic counter for `seed` if you want each celebration to look different.
- The rAF loop should self-stop on `isBatchExpired`. Don't keep ticking after the last particle fades; that's wasted CPU on idle.

---

## rng

Tiny seeded Mulberry32 PRNG plus convenience helpers.

```ts
import { gauss, makeRng, pick, range } from '@randroids-dojo/vibekit'

const rng = makeRng(seed)
const damage = range(rng, 8, 12)              // float in [8, 12)
const archetype = pick(rng, ['aggro', 'defensive', 'chaotic'])
const noise = gauss(rng) * 0.05               // standard-normal sample
```

Use this in any system that needs reproducible randomness:

- replay determinism (every consumer of randomness shares one seeded `rng()`),
- ghost integrity tests (the same seed produces the same recording),
- particle / VFX spawns that should look the same on identical inputs,
- AI archetype rolls in difficulty / weather code paths.

Common gotchas:

- One `rng` per system. A system that reaches for `Math.random` directly invalidates its replay determinism without warning.
- `pick` returns `undefined` for an empty array. Decide upstream whether that's a bug or a default.
- Mulberry32 is not crypto-safe. For tokens / nonces, use `crypto.getRandomValues`.

---

## math

Pure helpers re-implemented in many game projects. Pulling them here so the same definition is shared and tested once.

```ts
import { TAU, clamp, inverseLerp, lerp, remap, smoothstep, wrapAngle } from '@randroids-dojo/vibekit'

const damage = clamp(rawHit * crit, 0, 100)
const blend = lerp(low, high, smoothstep(0, 1, t))
const pct = inverseLerp(speedMin, speedMax, currentSpeed)
const heading = wrapAngle(theta + delta)            // maps to (-PI, PI]
const screenX = remap(worldX, worldMin, worldMax, 0, canvasW)
```

Common gotchas:

- `lerp(a, b, t)` does NOT clamp `t`. If you need the clamped variant, compose: `lerp(a, b, clamp(t, 0, 1))`.
- `inverseLerp(a, b, value)` returns `0` when `a === b` so a degenerate range never divides by zero. Means "halfway" when the range is collapsed; pick a different sentinel if that matters.
- `wrapAngle` uses `atan2(sin, cos)` so it's stable across multiple revolutions; safer than manual `% TAU` arithmetic.

---

## storage

Defensive `localStorage` helpers validated with zod schemas. Every function is SSR-safe, JSON-safe, schema-safe, quota-safe.

```ts
'use client'
import { useEffect, useState } from 'react'
import { z } from 'zod'
import {
  listenStorage,
  readStorage,
  updateStorage,
  writeStorage,
} from '@randroids-dojo/vibekit'

const KEY = 'myapp.daily-streak.v1'
const Schema = z.object({
  lastPlayedDate: z.string(),
  currentStreak: z.number().int().min(0),
  bestStreak: z.number().int().min(0),
})
type DailyStreak = z.infer<typeof Schema>

// Read once, defensively. Returns null on SSR, missing, malformed, or quota error.
export function readStreak(): DailyStreak | null {
  return readStorage(KEY, Schema)
}

// Write atomically. Returns false on quota; same-tab listeners fire automatically.
export function recordStreak(today: string): DailyStreak | null {
  let next: DailyStreak | null = null
  updateStorage(KEY, Schema, prev => {
    next = prev === null
      ? { lastPlayedDate: today, currentStreak: 1, bestStreak: 1 }
      : computeNext(prev, today)
    return next
  })
  return next
}

// React hook: hydrate after mount, subscribe to cross-tab + same-tab updates.
export function useStreak(): DailyStreak | null {
  const [value, setValue] = useState<DailyStreak | null>(null)
  useEffect(() => {
    setValue(readStreak())
    return listenStorage(KEY, () => setValue(readStreak()))
  }, [])
  return value
}
```

Common gotchas:

- `listenStorage` subscribes to BOTH cross-tab `storage` events AND same-tab `gamekit:storage` events. The native `storage` event only fires in OTHER tabs; the kit's same-tab event fills the gap.
- The hook pattern lives in the consuming project, not in the kit. The kit stays framework-agnostic. Project-side hooks compose `readStorage` + `listenStorage` (see snippet above).
- Render nothing pre-hydration so the SSR shell stays empty and there's no client-server text mismatch warning.
- Quota errors are silent (`writeStorage` returns false). If your app needs to react, check the boolean and surface to the user.

---

## kv

(Server-only.) Upstash Redis helpers. `getKv` returns null when env vars are missing so dev / preview routes degrade gracefully.

```ts
// app/api/score/route.ts
import { z } from 'zod'
import { getKv, readKv, writeKv } from '@randroids-dojo/vibekit/server'

const ScoreSchema = z.object({
  user: z.string(),
  best: z.number().int(),
})

export async function GET(req: Request) {
  const kv = getKv()
  if (!kv) return new Response('kv unavailable', { status: 503 })
  const userId = new URL(req.url).searchParams.get('user') ?? ''
  const score = await readKv(kv, `score:${userId}`, ScoreSchema)
  return Response.json(score)
}

export async function POST(req: Request) {
  const kv = getKv()
  if (!kv) return new Response('kv unavailable', { status: 503 })
  const body = ScoreSchema.parse(await req.json())
  const ok = await writeKv(kv, `score:${body.user}`, body, { ttlSec: 60 * 60 * 24 * 30 })
  return ok ? Response.json({ ok: true }) : new Response('write failed', { status: 500 })
}
```

Common gotchas:

- `getKv()` is cached for the runtime's lifetime. If you want to swap the client in tests, call `resetKvForTesting()` between assertions.
- Upstash auto-parses JSON on `GET` reads. The kit runs zod over the parsed value directly; do not `JSON.parse` again.
- `readKv` returns `null` for both "missing key" and "schema fail". Treat null as "no value available, use the default" rather than as "user has not stored anything yet" if that distinction matters.

---

## sign

(Server-only.) HMAC-SHA256 signed tokens for race-start / replay / admin flows. Encoding is `<base64url(json)>.<base64url(hmac)>`.

```ts
import { z } from 'zod'
import { signToken, verifyToken } from '@randroids-dojo/vibekit/server'

const RacePayload = z.object({
  raceId: z.string(),
  userId: z.string(),
  iat: z.number().int(),
  exp: z.number().int(),
})
type RacePayload = z.infer<typeof RacePayload>

const SECRET = process.env.RACE_SIGNING_SECRET!

export function issueRaceToken(raceId: string, userId: string): string {
  const now = Math.floor(Date.now() / 1000)
  const payload: RacePayload = { raceId, userId, iat: now, exp: now + 60 * 5 }
  return signToken(payload, SECRET)
}

export function verifyRaceToken(token: string): RacePayload | null {
  const payload = verifyToken(token, SECRET, RacePayload)
  if (payload === null) return null
  if (payload.exp < Math.floor(Date.now() / 1000)) return null  // expired
  return payload
}
```

Common gotchas:

- Encoding is intentionally simpler than JWT: no algorithm header, no expiration parsing built in. The consumer adds `iat` / `exp` to the payload and checks them after `verifyToken` succeeds.
- Comparison is constant-time via `timingSafeEqual`. Do not roll your own.
- The kit throws if the secret is empty; do not pass `''` as a "no signing" mode.

---

## rate-limit

(Server-only.) Fixed-window rate-limit primitive backed by Redis INCR + EXPIRE.

```ts
// app/api/race/start/route.ts
import { getKv } from '@randroids-dojo/vibekit/server'
import { incrementWithExpiry } from '@randroids-dojo/vibekit/server'

const PER_IP_LIMIT = 10           // requests
const WINDOW_SEC = 60             // per minute

export async function POST(req: Request) {
  const kv = getKv()
  if (!kv) return new Response('rate limit storage unavailable', { status: 503 })
  const ip = req.headers.get('x-forwarded-for')?.split(',')[0] ?? 'unknown'
  const count = await incrementWithExpiry(kv, `rl:start-race:${ip}`, WINDOW_SEC)
  if (count === null) {
    // both INCR and EXPIRE failed; pick fail-open or fail-closed deliberately
    return new Response('rate limit storage error', { status: 503 })
  }
  if (count > PER_IP_LIMIT) {
    return new Response(`rate limited (${count} of ${PER_IP_LIMIT} per ${WINDOW_SEC}s)`, { status: 429 })
  }
  // ... do the work
}
```

Common gotchas:

- Fixed-window, not sliding-window. A burst exactly at the window boundary can fire `2 * limit` requests in one second. Use a sliding-window algorithm if you need strict bounds.
- `null` return means BOTH INCR and EXPIRE threw. The caller picks fail-open (proceed) or fail-closed (reject) per route. The primitive does not pick for you.
- Pre-1.0 the policy is your business: the kit gives you the count; you decide the limit, error shape, and whether to surface "remaining" headers.
