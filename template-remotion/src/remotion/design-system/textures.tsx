/**
 * Living background textures: dot field (stippling), line field and grid.
 *
 * The procedural math lives here, tested once, so generated code never writes
 * particle loops with Math.sin/Math.cos itself (the generator prompt forbids
 * that, for good reason). Everything is a pure function of the frame.
 * Defaults are quiet on purpose: textures sit behind the content.
 */
import React, { useMemo } from "react";
import { Easing, interpolate, random, useCurrentFrame, useVideoConfig } from "remotion";

interface TextureBase {
  /** Area size in px. Defaults to the full composition. */
  width?: number;
  height?: number;
  color?: string;
  opacity?: number;
  /** Frame (relative to the enclosing Sequence) where the texture starts. */
  delay?: number;
  speed?: number;
  style?: React.CSSProperties;
}

function useArea(width?: number, height?: number) {
  const config = useVideoConfig();
  return { w: width ?? config.width, h: height ?? config.height };
}

const layerStyle: React.CSSProperties = { position: "absolute", left: 0, top: 0, pointerEvents: "none" };

export interface DotFieldProps extends TextureBase {
  spacing?: number;
  radius?: number;
  /**
   * wave: ripple travelling out from `origin` · reveal: dots pop in radially
   * from `origin` · breathe: each dot pulses on its own phase · static
   */
  animation?: "wave" | "reveal" | "breathe" | "static";
  /** Origin of wave/reveal as fractions of the area (0–1). */
  origin?: { x: number; y: number };
  /** Frames the reveal takes to cover the whole area. */
  duration?: number;
}

export function DotField({
  width,
  height,
  spacing = 36,
  radius = 2.2,
  color = "#FFFFFF",
  opacity = 0.3,
  animation = "wave",
  origin = { x: 0.5, y: 0.5 },
  delay = 0,
  duration = 30,
  speed = 1,
  style,
}: DotFieldProps) {
  const frame = useCurrentFrame() - delay;
  const { w, h } = useArea(width, height);

  const dots = useMemo(() => {
    const ox = origin.x * w;
    const oy = origin.y * h;
    const maxDist = Math.hypot(Math.max(ox, w - ox), Math.max(oy, h - oy));
    const list: { x: number; y: number; d: number; phase: number }[] = [];
    for (let y = spacing / 2; y < h; y += spacing) {
      for (let x = spacing / 2; x < w; x += spacing) {
        list.push({ x, y, d: Math.hypot(x - ox, y - oy) / maxDist, phase: random(`dot-${x}-${y}`) * Math.PI * 2 });
      }
    }
    return list;
  }, [w, h, spacing, origin.x, origin.y]);

  return (
    <svg width={w} height={h} style={{ ...layerStyle, opacity, ...style }}>
      {dots.map((dot, i) => {
        let scale = 1;
        if (animation === "wave") {
          scale = 0.35 + 0.65 * (0.5 + 0.5 * Math.sin(dot.d * 14 - frame * 0.12 * speed));
        } else if (animation === "breathe") {
          scale = 0.6 + 0.4 * Math.sin(frame * 0.08 * speed + dot.phase);
        } else if (animation === "reveal") {
          const start = dot.d * duration;
          scale = interpolate(frame, [start, start + 8], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
            easing: Easing.out(Easing.back(2)),
          });
        }
        if (frame < 0 && animation !== "static") scale = 0;
        return scale > 0.01 ? <circle key={i} cx={dot.x} cy={dot.y} r={radius * scale} fill={color} /> : null;
      })}
    </svg>
  );
}

export interface LineFieldProps extends TextureBase {
  count?: number;
  direction?: "horizontal" | "vertical" | "diagonal";
  thickness?: number;
  /**
   * draw: lines draw themselves in, staggered · wave: lines undulate ·
   * drift: lines slide slowly sideways
   */
  animation?: "draw" | "wave" | "drift";
  /** Frames each line takes to draw (draw mode). */
  duration?: number;
  /** Frames between consecutive lines starting (draw mode). */
  stagger?: number;
  /** Wave height in px (wave mode). */
  amplitude?: number;
}

export function LineField({
  width,
  height,
  count = 18,
  direction = "horizontal",
  color = "#FFFFFF",
  opacity = 0.2,
  thickness = 1.5,
  animation = "draw",
  delay = 0,
  duration = 24,
  stagger = 2,
  amplitude = 24,
  speed = 1,
  style,
}: LineFieldProps) {
  const frame = useCurrentFrame() - delay;
  const { w, h } = useArea(width, height);

  // Lines are laid out horizontally in a box that covers the area once
  // rotated; vertical/diagonal just rotate that box around the center.
  const angle = direction === "vertical" ? 90 : direction === "diagonal" ? -35 : 0;
  const span = angle === 0 ? w : angle === 90 ? h : Math.hypot(w, h);
  const across = angle === 0 ? h : angle === 90 ? w : Math.hypot(w, h);
  const gap = across / (count + 1);
  const segments = 32;

  const lines = Array.from({ length: count }, (_, i) => {
    const y = -across / 2 + gap * (i + 1);
    const x0 = -span / 2;
    if (animation === "wave") {
      let d = "";
      for (let s = 0; s <= segments; s++) {
        const x = x0 + (span * s) / segments;
        const yy = y + Math.sin(s / 4 + i * 0.5 - frame * 0.08 * speed) * amplitude;
        d += `${s === 0 ? "M" : " L"} ${x.toFixed(1)} ${yy.toFixed(1)}`;
      }
      return <path key={i} d={d} fill="none" stroke={color} strokeWidth={thickness} />;
    }
    if (animation === "drift") {
      const shift = ((frame * 0.6 * speed * (i % 2 === 0 ? 1 : -1)) % gap) * 2;
      return <line key={i} x1={x0 - gap * 2 + shift} x2={x0 + span + gap * 2 + shift} y1={y} y2={y} stroke={color} strokeWidth={thickness} />;
    }
    const p = interpolate(frame, [i * stagger, i * stagger + duration], [0, 1], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: Easing.inOut(Easing.cubic),
    });
    return p > 0 ? (
      <line key={i} x1={x0} x2={x0 + span} y1={y} y2={y} stroke={color} strokeWidth={thickness} strokeDasharray={span} strokeDashoffset={span * (1 - p)} />
    ) : null;
  });

  return (
    <svg width={w} height={h} style={{ ...layerStyle, opacity, ...style }}>
      <g transform={`translate(${w / 2} ${h / 2}) rotate(${angle})`}>{lines}</g>
    </svg>
  );
}

export interface GridRevealProps extends TextureBase {
  cell?: number;
  thickness?: number;
  /** Frames for the whole grid to finish drawing. */
  duration?: number;
  /** Where the drawing starts spreading from. */
  from?: "center" | "top" | "left";
}

export function GridReveal({
  width,
  height,
  cell = 120,
  color = "#FFFFFF",
  opacity = 0.15,
  thickness = 1,
  delay = 0,
  duration = 30,
  from = "center",
  style,
}: GridRevealProps) {
  const frame = useCurrentFrame() - delay;
  const { w, h } = useArea(width, height);
  const lineFrames = Math.max(8, duration * 0.5);

  // "top": horizontal lines cascade downward while vertical ones all draw
  // top → bottom at once; "left" is the same rotated.
  const progressAt = (pos: number, size: number, axis: "x" | "y") => {
    const order =
      from === "center"
        ? Math.abs(pos - size / 2) / (size / 2)
        : (from === "top") === (axis === "y")
          ? pos / size
          : 0;
    const start = order * (duration - lineFrames);
    return interpolate(frame, [start, start + lineFrames], [0, 1], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: Easing.out(Easing.cubic),
    });
  };

  const lines: React.ReactNode[] = [];
  for (let x = cell; x < w; x += cell) {
    const p = progressAt(x, w, "x");
    if (p > 0) lines.push(<line key={`v${x}`} x1={x} x2={x} y1={0} y2={h} stroke={color} strokeWidth={thickness} strokeDasharray={h} strokeDashoffset={h * (1 - p)} />);
  }
  for (let y = cell; y < h; y += cell) {
    const p = progressAt(y, h, "y");
    if (p > 0) lines.push(<line key={`h${y}`} x1={0} x2={w} y1={y} y2={y} stroke={color} strokeWidth={thickness} strokeDasharray={w} strokeDashoffset={w * (1 - p)} />);
  }

  return (
    <svg width={w} height={h} style={{ ...layerStyle, opacity, ...style }}>
      {lines}
    </svg>
  );
}
