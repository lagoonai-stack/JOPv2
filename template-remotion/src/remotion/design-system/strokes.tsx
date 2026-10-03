/**
 * Hand-drawn annotations over lettering: underline, strike-through, scribble,
 * circle and highlighter marker.
 *
 * Each one wraps inline text and draws itself over it, so generated code stays
 * a one-liner: `<h1>DINHEIRO <Underline delay={20}>EXIGE</Underline></h1>`.
 * The path geometry is built from the wrapped text's measured size; the
 * "hand-made" wobble comes from remotion's seeded `random`, so every frame of
 * every render draws the exact same stroke.
 */
import { evolvePath } from "@remotion/paths";
import React, { useLayoutEffect, useRef, useState } from "react";
import { Easing, interpolate, random, useCurrentFrame } from "remotion";

export interface StrokeProps {
  children: React.ReactNode;
  /** Frame (relative to the enclosing Sequence) where drawing starts. */
  delay?: number;
  /** Frames the stroke takes to draw itself. */
  duration?: number;
  /** Defaults to the text color. */
  color?: string;
  /** Stroke width in px. Defaults to a fraction of the text height. */
  thickness?: number;
  /** 0 = geometric, 1 = natural hand wobble, 2 = sloppy. */
  roughness?: number;
  /** Change it to get a different, still deterministic, stroke. */
  seed?: number;
  /** Frame where the stroke fades away. Omit to keep it until the end. */
  exitAt?: number;
  exitDuration?: number;
  style?: React.CSSProperties;
}

type Size = { w: number; h: number };
type Point = [number, number];

// offsetWidth/Height ignore CSS transforms, so the Player's preview scaling
// and parent scale() animations don't distort the measured geometry.
function useElementSize(): [React.RefObject<HTMLSpanElement | null>, Size] {
  const ref = useRef<HTMLSpanElement>(null);
  const [size, setSize] = useState<Size>({ w: 0, h: 0 });
  useLayoutEffect(() => {
    const el = ref.current;
    if (!el) return;
    const w = el.offsetWidth;
    const h = el.offsetHeight;
    if (w !== size.w || h !== size.h) setSize({ w, h });
  });
  return [ref, size];
}

function jitter(seed: number, key: string | number, amount: number): number {
  return (random(`stroke-${seed}-${key}`) - 0.5) * 2 * amount;
}

/** Smooth path through the points (Catmull-Rom converted to cubic Béziers). */
function smoothPath(points: Point[]): string {
  if (points.length < 2) return "";
  const f = (n: number) => n.toFixed(2);
  let d = `M ${f(points[0][0])} ${f(points[0][1])}`;
  for (let i = 0; i < points.length - 1; i++) {
    const p0 = points[i - 1] ?? points[i];
    const p1 = points[i];
    const p2 = points[i + 1];
    const p3 = points[i + 2] ?? p2;
    const c1: Point = [p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6];
    const c2: Point = [p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6];
    d += ` C ${f(c1[0])} ${f(c1[1])} ${f(c2[0])} ${f(c2[1])} ${f(p2[0])} ${f(p2[1])}`;
  }
  return d;
}

function useStrokeTiming(delay: number, duration: number, exitAt?: number, exitDuration = 10) {
  const frame = useCurrentFrame();
  const progress = interpolate(frame, [delay, delay + Math.max(1, duration)], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.65, 0, 0.35, 1),
  });
  const fade =
    exitAt === undefined
      ? 1
      : interpolate(frame, [exitAt, exitAt + Math.max(1, exitDuration)], [1, 0], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        });
  return { progress, fade };
}

const wrapperStyle: React.CSSProperties = {
  position: "relative",
  display: "inline-block",
};

function StrokeOverlay({
  children,
  delay = 0,
  duration = 18,
  color = "currentColor",
  thickness,
  roughness = 1,
  seed = 1,
  exitAt,
  exitDuration,
  style,
  build,
  thicknessRatio,
}: StrokeProps & { build: (size: Size, wobble: number, seed: number) => string; thicknessRatio: number }) {
  const [ref, size] = useElementSize();
  const { progress, fade } = useStrokeTiming(delay, duration, exitAt, exitDuration);
  const d = size.w > 0 ? build(size, roughness, seed) : "";
  const strokeWidth = thickness ?? Math.max(2, size.h * thicknessRatio);
  const dash = d && progress > 0 ? evolvePath(progress, d) : null;

  return (
    <span ref={ref} style={{ ...wrapperStyle, ...style }}>
      {children}
      {dash && (
        <svg
          width={size.w}
          height={size.h}
          style={{ position: "absolute", left: 0, top: 0, overflow: "visible", pointerEvents: "none", opacity: fade }}
        >
          <path
            d={d}
            fill="none"
            stroke={color}
            strokeWidth={strokeWidth}
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeDasharray={dash.strokeDasharray}
            strokeDashoffset={dash.strokeDashoffset}
          />
        </svg>
      )}
    </span>
  );
}

/** Slightly curved line drawn left → right under the text. */
export function Underline(props: StrokeProps) {
  return (
    <StrokeOverlay
      {...props}
      thicknessRatio={0.07}
      build={({ w, h }, r, seed) => {
        const pad = w * 0.03;
        const a = h * 0.04 * r;
        return smoothPath([
          [-pad, h * 0.98 + jitter(seed, "u0", a)],
          [w * 0.35, h * 1.03 + jitter(seed, "u1", a)],
          [w * 0.7, h * 1.0 + jitter(seed, "u2", a)],
          [w + pad, h * 0.95 + jitter(seed, "u3", a)],
        ]);
      }}
    />
  );
}

/** Strike-through, slightly tilted, drawn left → right across the middle. */
export function Strike(props: StrokeProps) {
  return (
    <StrokeOverlay
      {...props}
      thicknessRatio={0.07}
      build={({ w, h }, r, seed) => {
        const pad = w * 0.04;
        const a = h * 0.04 * r;
        return smoothPath([
          [-pad, h * 0.6 + jitter(seed, "s0", a)],
          [w * 0.5, h * 0.53 + jitter(seed, "s1", a)],
          [w + pad, h * 0.47 + jitter(seed, "s2", a)],
        ]);
      }}
    />
  );
}

/** Back-and-forth zigzag that scratches the text out. */
export function Scribble(props: StrokeProps) {
  return (
    <StrokeOverlay
      {...props}
      duration={props.duration ?? 24}
      thicknessRatio={0.08}
      build={({ w, h }, r, seed) => {
        const passes = Math.max(8, Math.round(w / (h * 0.22)));
        const a = h * 0.06 * r;
        const points: Point[] = [];
        for (let i = 0; i <= passes; i++) {
          const x = -w * 0.03 + (w * 1.06 * i) / passes + jitter(seed, `x${i}`, w * 0.01 * r);
          const y = (i % 2 === 0 ? h * 0.18 : h * 0.84) + jitter(seed, `y${i}`, a);
          points.push([x, y]);
        }
        return smoothPath(points);
      }}
    />
  );
}

/** Loose hand-drawn loop around the text, overshooting where it started. */
export function CircleAround(props: StrokeProps) {
  return (
    <StrokeOverlay
      {...props}
      duration={props.duration ?? 24}
      thicknessRatio={0.05}
      build={({ w, h }, r, seed) => {
        const cx = w / 2;
        const cy = h / 2;
        const rx = w / 2 + Math.max(h * 0.35, w * 0.08);
        const ry = h / 2 + h * 0.35;
        const steps = 40;
        const startAngle = -Math.PI * 0.6;
        const sweep = Math.PI * 2 * 1.08;
        const points: Point[] = [];
        for (let i = 0; i <= steps; i++) {
          const t = i / steps;
          const angle = startAngle + sweep * t;
          // Radius drifts outward along the loop, so the overshoot doesn't
          // land exactly on the start like a geometric ellipse would.
          const drift = 1 + 0.06 * t * r + jitter(seed, `c${i}`, 0.015 * r);
          points.push([cx + Math.cos(angle) * rx * drift, cy + Math.sin(angle) * ry * drift]);
        }
        return smoothPath(points);
      }}
    />
  );
}

/** Marker sweep behind the text, left → right. */
export function Highlighter({
  children,
  delay = 0,
  duration = 14,
  color = "rgba(255, 214, 0, 0.55)",
  seed = 1,
  roughness = 1,
  exitAt,
  exitDuration,
  style,
}: Omit<StrokeProps, "thickness">) {
  const { progress, fade } = useStrokeTiming(delay, duration, exitAt, exitDuration);
  const tilt = jitter(seed, "hl", 1.2 * roughness);
  return (
    <span style={{ ...wrapperStyle, isolation: "isolate", ...style }}>
      <span
        style={{
          position: "absolute",
          left: "-0.12em",
          right: "-0.12em",
          top: "18%",
          bottom: "8%",
          background: color,
          borderRadius: "0.12em",
          transform: `rotate(${tilt}deg) scaleX(${progress})`,
          transformOrigin: "left center",
          opacity: fade,
          zIndex: -1,
        }}
      />
      {children}
    </span>
  );
}
