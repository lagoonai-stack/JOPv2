---
name: timing
description: Interpolation and timing in Remotion—prefer interpolate with Bézier easing; springs as a specialized option
metadata:
  tags: easing, bezier, interpolation, spring, timing
---

Drive motion with `interpolate()` over explicit frame range. To customize timing, use **`Easing.bezier`**. The four parameters are the same as CSS `cubic-bezier(x1, y1, x2, y2)`.

A simple linear interpolation is done using the `interpolate` function.

```ts title="Going from 0 to 1 over 100 frames"
import { interpolate } from "remotion";

const opacity = interpolate(frame, [0, 100], [0, 1]);
```

By default, the values are not clamped, so the value can go outside the range [0, 1].  
Here is how they can be clamped:

```ts title="Going from 0 to 1 over 100 frames with extrapolation"
const opacity = interpolate(frame, [0, 100], [0, 1], {
  extrapolateRight: "clamp",
  extrapolateLeft: "clamp",
});
```

## Bézier easing

Use `Easing.bezier(x1, y1, x2, y2)` inside the `interpolate` options object. The curve is identical in spirit to CSS animations and transitions, which helps when you are stealing timing from the web or from a designer’s spec.

```ts
import { interpolate, Easing } from "remotion";

const opacity = interpolate(frame, [0, 60], [0, 1], {
  easing: Easing.bezier(0.16, 1, 0.3, 1),
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
});
```

### Examples (copy-paste curves)

**1. Crisp UI entrance (strong ease-out, no overshoot)** — slows nicely into the rest value; similar to many system “deceleration” curves.

```tsx
const enter = interpolate(frame, [0, 45], [0, 1], {
  easing: Easing.bezier(0.16, 1, 0.3, 1),
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
});
```

**2. Editorial / slow fade (balanced ease-in-out)** — symmetric acceleration and deceleration over a hold-friendly move.

```tsx
const progress = interpolate(frame, [0, 90], [0, 1], {
  easing: Easing.bezier(0.45, 0, 0.55, 1),
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
});
```

**3. Playful overshoot (control point y > 1)** — a little past the target then settles; use sparingly for emphasis.

```tsx
const pop = interpolate(frame, [0, 30], [0, 1], {
  easing: Easing.bezier(0.34, 1.56, 0.64, 1),
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
});
```

## Preset easings (`Easing.in` / `Easing.out` / named curves)

Easing can be added to the `interpolate` function without a custom cubic:

```ts
import { interpolate, Easing } from "remotion";

const value1 = interpolate(frame, [0, 100], [0, 1], {
  easing: Easing.inOut(Easing.cubic),
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
});
```

The default easing is `Easing.linear`.  
Convexities:

- `Easing.in` — starting slow and accelerating
- `Easing.out` — starting fast and slowing down
- `Easing.inOut`

Named curves (from most linear to most curved):

- `Easing.quad`
- `Easing.cubic` (good default when you do not need a custom cubic)
- `Easing.sin`
- `Easing.exp`
- `Easing.circle`

### Easing direction for enter/exit animations

Use `Easing.out` for enter animations (starts fast, decelerates into place) and `Easing.in` for exit animations (starts slow, accelerates away). This feels natural because elements arrive with momentum and leave with gravity. When you need a specific curve from design, prefer a single `Easing.bezier(...)` instead of stacking presets.

## Composing interpolations

When multiple properties share the same timing (e.g. a slide-in panel and a video shift), avoid duplicating the full interpolation for each property. Instead, create a single normalized progress value (0 to 1) and derive each property from it:

```tsx
const slideIn = interpolate(
  frame,
  [slideInStart, slideInStart + slideInDuration],
  [0, 1],
  {
    easing: Easing.bezier(0.22, 1, 0.36, 1),
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  },
);
const slideOut = interpolate(
  frame,
  [slideOutStart, slideOutStart + slideOutDuration],
  [0, 1],
  { easing: Easing.in(Easing.cubic), extrapolateLeft: "clamp", extrapolateRight: "clamp" },
);
const progress = slideIn - slideOut;

// Derive multiple properties from the same progress
const overlayX = interpolate(progress, [0, 1], [100, 0]);
const videoX = interpolate(progress, [0, 1], [0, -20]);
const opacity = interpolate(progress, [0, 1], [0, 1]);
```

The key idea: separate **timing** (when and how fast) from **mapping** (what values to animate between).

---

## Spring Physics Animation

Use `spring()` for natural motion. Prefer it over `interpolate()` for entrance animations and scale bounces.

```tsx
import { spring } from "remotion";

const scale = spring({
  frame,
  fps,
  config: { damping: 12, stiffness: 100 },
  durationInFrames: 30,
});
```

### Presets de Mola por Arquétipo Visual (THEME)

NUNCA escolha a configuração de mola aleatoriamente. A física do movimento DEVE herdar a intenção estética do `THEME`.

*   **PREMIUM DARK / EDITORIAL / CORPORATE:** 
    *   **Exige:** Movimento contínuo, elegante, liso. Proibido usar "bounce".
    *   **Configuração:** *Smooth* (`damping: 200, stiffness: 100`).
*   **NEON / GLOW / PUNCHY / SOCIAL:**
    *   **Exige:** Movimentos incisivos, rápidos, com um toque de elasticidade para reter atenção.
    *   **Configuração:** *Snappy/Bouncy* (`damping: 12-20, stiffness: 150-200`). Para mais destaque, use `damping: 8`.
*   **MINIMAL / CLEAN:**
    *   **Exige:** Leveza, responsivo mas sem excesso de inércia.
    *   **Configuração:** *Snappy* sem bounce (`damping: 20, stiffness: 200`).

```tsx
// Exemplos baseados nos arquétipos:
const snappy = { damping: 20, stiffness: 200 }; // MINIMAL / CLEAN
const bouncy = { damping: 8, stiffness: 100 }; // NEON / GLOW / SOCIAL
const smooth = { damping: 200, stiffness: 100 }; // PREMIUM DARK / EDITORIAL
```

### Delayed Spring Start

Offset the frame for delayed spring animations:

```tsx
const ENTRANCE_DELAY = 20;
const entrance = spring({
  frame: frame - ENTRANCE_DELAY,
  fps,
  config: { damping: 12, stiffness: 100 },
});
// Returns 0 until frame 20, then animates to 1
```

### Combining Spring with Interpolate

Map spring output (0-1) to custom ranges (rotation, translation):

```tsx
const springProgress = spring({ frame, fps, config: { damping: 15 } });

const rotation = interpolate(springProgress, [0, 1], [0, 360]);
const translateY = interpolate(springProgress, [0, 1], [50, 0]);

<div style={{ transform: `translateY(${translateY}px) rotate(${rotation}deg)` }}>
```

### Chained Springs for Sequential Motion

```tsx
const PHASE_2_START = 25; // Slight overlap

const phase1 = spring({ frame, fps, config: { damping: 15 } });
const phase2 = spring({
  frame: frame - PHASE_2_START,
  fps,
  config: { damping: 12 },
});
// phase1 controls entrance, phase2 controls secondary motion
```
