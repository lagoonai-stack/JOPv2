/**
 * Morphing container — the "Modo A" connection between moments.
 *
 * One container persists across moments and changes shape from one keyframe
 * to the next: a card becomes a pill, the pill becomes a ring, the ring becomes
 * the closing frame. It lives OUTSIDE the moments' <Sequence>s, so its `at`
 * values are absolute frames of the whole video. Each keyframe is held until
 * `morphFrames` before the next one, then interpolates with
 * Easing.inOut(Easing.cubic) — the curve the direction prompt prescribes.
 */
import React from "react";
import { Easing, interpolate, interpolateColors, useCurrentFrame } from "remotion";

export interface MorphShape {
  /** Center of the shape, in px of the composition. */
  x: number;
  y: number;
  width: number;
  height: number;
  /** Corner radius in px. Use Math.min(width, height) / 2 for a circle/pill. */
  radius?: number;
  rotate?: number;
  color?: string;
  borderColor?: string;
  borderWidth?: number;
  opacity?: number;
}

export interface MorphKeyframe extends MorphShape {
  /** Absolute frame where the container reaches this shape. */
  at: number;
}

export interface MorphState {
  shape: Required<MorphShape>;
  /** Index of the keyframe the container is at (or leaving). */
  index: number;
  /** 0 while holding, 0→1 while morphing to keyframe index + 1. */
  t: number;
}

const TRANSPARENT = "rgba(0, 0, 0, 0)";

function complete(k: MorphShape): Required<MorphShape> {
  return {
    x: k.x,
    y: k.y,
    width: k.width,
    height: k.height,
    radius: k.radius ?? 0,
    rotate: k.rotate ?? 0,
    color: k.color ?? TRANSPARENT,
    borderColor: k.borderColor ?? TRANSPARENT,
    borderWidth: k.borderWidth ?? 0,
    opacity: k.opacity ?? 1,
  };
}

/** Current shape of a keyframed morph — for when the content has to follow it. */
export function useMorph(keyframes: MorphKeyframe[], morphFrames = 18): MorphState {
  const frame = useCurrentFrame();
  const kfs = [...keyframes].sort((a, b) => a.at - b.at);
  if (kfs.length === 0) {
    return { shape: complete({ x: 0, y: 0, width: 0, height: 0, opacity: 0 }), index: 0, t: 0 };
  }

  for (let i = 0; i < kfs.length - 1; i++) {
    const next = kfs[i + 1];
    if (frame >= next.at) continue;

    const from = complete(kfs[i]);
    const to = complete(next);
    const span = Math.min(morphFrames, next.at - kfs[i].at);
    const t = interpolate(frame, [next.at - span, next.at], [0, 1], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
      easing: Easing.inOut(Easing.cubic),
    });
    if (t === 0) return { shape: from, index: i, t: 0 };

    const lerp = (a: number, b: number) => a + (b - a) * t;
    return {
      shape: {
        x: lerp(from.x, to.x),
        y: lerp(from.y, to.y),
        width: lerp(from.width, to.width),
        height: lerp(from.height, to.height),
        radius: lerp(from.radius, to.radius),
        rotate: lerp(from.rotate, to.rotate),
        color: interpolateColors(t, [0, 1], [from.color, to.color]),
        borderColor: interpolateColors(t, [0, 1], [from.borderColor, to.borderColor]),
        borderWidth: lerp(from.borderWidth, to.borderWidth),
        opacity: lerp(from.opacity, to.opacity),
      },
      index: i,
      t,
    };
  }

  return { shape: complete(kfs[kfs.length - 1]), index: kfs.length - 1, t: 0 };
}

export interface MorphContainerProps {
  keyframes: MorphKeyframe[];
  morphFrames?: number;
  /** Static content, or a function of the morph state to swap content per keyframe. */
  children?: React.ReactNode | ((state: MorphState) => React.ReactNode);
  style?: React.CSSProperties;
}

export function MorphContainer({ keyframes, morphFrames = 18, children, style }: MorphContainerProps) {
  const state = useMorph(keyframes, morphFrames);
  const { shape } = state;
  return (
    <div
      style={{
        position: "absolute",
        left: shape.x - shape.width / 2,
        top: shape.y - shape.height / 2,
        width: shape.width,
        height: shape.height,
        borderRadius: shape.radius,
        background: shape.color,
        border: shape.borderWidth > 0 ? `${shape.borderWidth}px solid ${shape.borderColor}` : undefined,
        boxSizing: "border-box",
        opacity: shape.opacity,
        transform: shape.rotate ? `rotate(${shape.rotate}deg)` : undefined,
        overflow: "hidden",
        ...style,
      }}
    >
      {typeof children === "function" ? children(state) : children}
    </div>
  );
}
