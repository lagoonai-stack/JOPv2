---
name: charts
description: Premium chart and data visualization components for Remotion - bar charts, ring/pie charts, and animated line charts
metadata:
  tags: charts, data, visualization, bar-chart, pie-chart, line-chart, svg-paths, graphs, premium-ui
---

# Premium Charts & Data Visualization in Remotion

Prefer chart components that look like native screens of a premium SaaS product (Linear, Vercel, Stripe) rather than generic spreadsheet visuals.

## Design guidelines

1. Use design-system color variables rather than arbitrary hardcoded values for bars or lines.
2. Anchor charts inside a card container with appropriate background and shadow depth.
3. Drive all animations from `useCurrentFrame()` — disable any third-party animation libraries.
4. Use subdued colors for axis labels (11–13 px, uppercase) and bold typography for hero values.

## Expected color system

Each example assumes a `COLORS` constant. Declare it once per composition or import it from your theme:

```ts
// Adapt values to your project theme
const COLORS = {
  accent:    "#34D399",                    // primary accent
  surface1:  "#111113",                    // card background
  border:    "rgba(255, 255, 255, 0.06)", // track fill / subtle border
  text:      "#FFFFFF",                    // primary text
  textMuted: "#A0A0A8",                    // axis labels / secondary
};
```

## Bar Chart (Linear-style)

Rounded bars with a visible background track for a tactile feel.

```tsx
import { useCurrentFrame, useVideoConfig, spring } from "remotion";

const COLORS = {
  accent: "#34D399",
  border: "rgba(255, 255, 255, 0.06)",
};

const STAGGER_DELAY = 5; // frames between each bar's animation start
const MAX_HEIGHT = 200;  // px — set to match your card height

// Replace with your actual dataset
const data = [
  { label: "Jan", value: 0.6 },
  { label: "Feb", value: 0.8 },
  { label: "Mar", value: 1.0 },
];

export const BarChart = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <div style={{ display: "flex", gap: 12, alignItems: "flex-end" }}>
      {data.map((item, i) => {
        const progress = spring({
          frame,
          fps,
          delay: i * STAGGER_DELAY,
          config: { damping: 200 },
        });

        return (
          <div
            key={item.label}
            style={{
              height: MAX_HEIGHT,
              width: 40,
              backgroundColor: COLORS.border,
              borderRadius: 8,
              overflow: "hidden",
              position: "relative",
            }}
          >
            {/* Fill — value growing from the bottom up */}
            <div
              style={{
                position: "absolute",
                bottom: 0,
                width: "100%",
                height: progress * item.value * MAX_HEIGHT,
                backgroundColor: COLORS.accent,
                boxShadow: `0 0 12px ${COLORS.accent}40`,
              }}
            />
          </div>
        );
      })}
    </div>
  );
};
```

## Ring / Pie Chart (Apple Health style)

Circular arc with rounded stroke caps animated via `strokeDashoffset`.

The `<defs>` block defines the SVG glow filter referenced by `filter="url(#glow)"`.

```tsx
import { useCurrentFrame, interpolate, Easing } from "remotion";

const COLORS = {
  accent: "#34D399",
  border: "rgba(255, 255, 255, 0.06)",
};

// Chart parameters — adjust to your composition
const radius = 120; // px
const center = 160; // half of SVG viewBox size (width/height = center * 2)
const value  = 72;  // current value
const total  = 100; // maximum value

export const RingChart = () => {
  const frame = useCurrentFrame();

  const progress = interpolate(frame, [0, 60], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });

  const circumference = 2 * Math.PI * radius;
  const segmentLength = (value / total) * circumference;
  const offset = interpolate(
    progress,
    [0, 1],
    [circumference, circumference - segmentLength],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );

  return (
    <svg viewBox={`0 0 ${center * 2} ${center * 2}`} width={center * 2} height={center * 2}>
      <defs>
        <filter id="glow">
          <feGaussianBlur stdDeviation="6" result="blur" />
          <feMerge>
            <feMergeNode in="blur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      {/* Base track ring */}
      <circle
        r={radius}
        cx={center}
        cy={center}
        fill="none"
        stroke={COLORS.border}
        strokeWidth={24}
      />

      {/* Animated arc with glow */}
      <circle
        r={radius}
        cx={center}
        cy={center}
        fill="none"
        stroke={COLORS.accent}
        strokeWidth={24}
        strokeLinecap="round"
        strokeDasharray={circumference}
        strokeDashoffset={offset}
        transform={`rotate(-90 ${center} ${center})`}
        filter="url(#glow)"
      />
    </svg>
  );
};
```

## Line Chart / Path Animation (Stripe-style)

Use `@remotion/paths` for smooth animated line charts. Keep axes minimal — let the line carry the visual weight.

Install: `npx remotion add @remotion/paths`

```tsx
import { useCurrentFrame, interpolate, Easing } from "remotion";
import { evolvePath } from "@remotion/paths";

const COLORS = {
  accent: "#34D399",
};

// SVG path — generate from your data points
const path = "M 100 200 L 200 150 L 300 180 L 400 100";

export const LineChart = () => {
  const frame = useCurrentFrame();

  const progress = interpolate(frame, [15, 75], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.quad),
  });

  const { strokeDasharray, strokeDashoffset } = evolvePath(progress, path);

  return (
    <svg viewBox="0 0 500 300" width={500} height={300}>
      <path
        d={path}
        fill="none"
        stroke={COLORS.accent}
        strokeWidth={6}
        strokeLinecap="round"
        strokeLinejoin="round"
        strokeDasharray={strokeDasharray}
        strokeDashoffset={strokeDashoffset}
        style={{ filter: `drop-shadow(0 8px 16px ${COLORS.accent}60)` }}
      />
    </svg>
  );
};
```

### Floating indicator

Animate a dot along the path using `getPointAtLength`:

```tsx
import { useCurrentFrame, interpolate, Easing } from "remotion";
import { getLength, getPointAtLength } from "@remotion/paths";

const COLORS = { accent: "#34D399" };
const path = "M 100 200 L 200 150 L 300 180 L 400 100";

export const PathIndicator = () => {
  const frame = useCurrentFrame();

  const progress = interpolate(frame, [15, 75], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.quad),
  });

  const pathLength = getLength(path);
  const point = getPointAtLength(path, progress * pathLength);

  return (
    <div
      style={{
        position: "absolute",
        left: point.x - 10,
        top: point.y - 10,
        width: 20,
        height: 20,
        borderRadius: "50%",
        backgroundColor: "#FFFFFF",
        border: `4px solid ${COLORS.accent}`,
        boxShadow: "0 0 20px rgba(0,0,0,0.5)",
      }}
    />
  );
};
```
