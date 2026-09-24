---
title: Chart & Data Visualization
impact: HIGH
impactDescription: improves data viz quality and animation polish
tags: charts, data, visualization, bar-chart, pie-chart, graphs
---

## Bar Chart Animations

Stagger bar entrances with 3-5 frame delays and use spring() for organic motion.

**Incorrect (all bars animate together):**

```tsx
const bars = data.map((item, i) => {
  const height = spring({ frame, fps, config: { damping: 18 } });
  return <div style={{ height: height * item.value }} />;
});
```

**Correct (staggered entrances):**

```tsx
const STAGGER_DELAY = 5;

const bars = data.map((item, i) => {
  const delay = i * STAGGER_DELAY;
  const height = spring({
    frame: frame - delay,
    fps,
    config: { damping: 18, stiffness: 80 },
  });
  return <div style={{ height: height * item.value }} />;
});
```

## Data Scales & Domains (CRITICAL)

The numeric domains (`minVal`, `maxVal`) and Y-axis steps MUST be calculated dynamically from the data array. Never hardcode the scale (e.g., 0 to 100), as it breaks the component when the data changes.

**Correct (Dynamic Scale):**

```tsx
const dataValues = data.map(d => d.value);
const maxVal = Math.max(...dataValues);
// Generate Y-axis steps based on maxVal instead of hardcoding [0, 25, 50, 75, 100]
```

## Always Include Y-Axis Labels

Charts without axis labels are hard to read. Always add labeled tick marks.

**Incorrect (no axis):**

```tsx
<div style={{ display: "flex", alignItems: "flex-end", gap: 8 }}>{bars}</div>
```

**Correct (with Y-axis):**

```tsx
// Calculate these dynamically in your actual code!
const yAxisSteps = [0, 25, 50, 75, 100];

<div style={{ display: "flex" }}>
  <div
    style={{
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between",
    }}
  >
    {yAxisSteps.reverse().map((step) => (
      <span style={{ fontSize: 12, color: "#888" }}>{step}</span>
    ))}
  </div>
  <div
    style={{
      display: "flex",
      alignItems: "flex-end",
      gap: 8,
      borderLeft: "1px solid #333",
    }}
  >
    {bars}
  </div>
</div>;
```

## Value Labels Inside Bars

Position value labels inside bars when height is sufficient, fade in after bar animates.

```tsx
const barHeight = normalizedHeight * progress;

<div style={{ height: barHeight, backgroundColor: COLOR_BAR }}>
  {barHeight > 30 && (
    <span style={{ opacity: progress, fontSize: 11 }}>
      {item.value.toLocaleString()}
    </span>
  )}
</div>;
```

## Pie Chart Animation

Animate segments using stroke-dashoffset, starting from 12 o'clock.

```tsx
const circumference = 2 * Math.PI * radius;
const segmentLength = (value / total) * circumference;
const offset = interpolate(progress, [0, 1], [segmentLength, 0]);

<circle
  r={radius}
  cx={center}
  cy={center}
  fill="none"
  stroke={color}
  strokeWidth={strokeWidth}
  strokeDasharray={`${segmentLength} ${circumference}`}
  strokeDashoffset={offset}
  transform={`rotate(-90 ${center} ${center})`}
/>;
```

## Line Chart / Path Animation

Use `@remotion/paths` for animating SVG paths (line charts, stock graphs, signatures).

Install: `npx remotion add @remotion/paths`  
Docs: https://remotion.dev/docs/paths.md

### Convert data points to SVG path

```tsx
type Point = { x: number; y: number };

const generateLinePath = (points: Point[]): string => {
  if (points.length < 2) return "";
  return points.map((p, i) => `${i === 0 ? "M" : "L"} ${p.x} ${p.y}`).join(" ");
};
```

### Draw path with animation

```tsx
import { evolvePath } from "@remotion/paths";

const path = "M 100 200 L 200 150 L 300 180 L 400 100";
const progress = interpolate(frame, [0, 2 * fps], [0, 1], {
  extrapolateLeft: "clamp",
  extrapolateRight: "clamp",
  easing: Easing.out(Easing.quad),
});

const { strokeDasharray, strokeDashoffset } = evolvePath(progress, path);

<path
  d={path}
  fill="none"
  stroke="#FF3232"
  strokeWidth={4}
  strokeDasharray={strokeDasharray}
  strokeDashoffset={strokeDashoffset}
/>;
```

### Follow path with marker/arrow

> **CRITICAL RULE:** Always remember to add the import statement for `getLength`, `getPointAtLength`, and `getTangentAtLength` from `@remotion/paths` at the top of your file when using these functions, otherwise the code will crash with a ReferenceError.

```tsx
import {
  getLength,
  getPointAtLength,
  getTangentAtLength,
} from "@remotion/paths";

const pathLength = getLength(path);
const point = getPointAtLength(path, progress * pathLength);
const tangent = getTangentAtLength(path, progress * pathLength);
const angle = Math.atan2(tangent.y, tangent.x);

<g
  style={{
    transform: `translate(${point.x}px, ${point.y}px) rotate(${angle}rad)`,
    transformOrigin: "0 0",
  }}
>
  <polygon points="0,0 -20,-10 -20,10" fill="#FF3232" />
</g>;
```
