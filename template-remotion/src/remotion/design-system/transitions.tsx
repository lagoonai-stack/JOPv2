/**
 * Directional scene transitions ("Modo B") and staggered entrances.
 *
 * SceneTransition wraps the content of one moment, inside its <Sequence>, so
 * frames are relative to the moment. Pair an exit with the opposite entrance
 * of the next moment (exit "left" → next enter "right") for a continuous push.
 */
import React from "react";
import { AbsoluteFill, Easing, interpolate, useCurrentFrame, useVideoConfig } from "remotion";

export type TransitionKind = "left" | "right" | "up" | "down" | "fade" | "zoom" | "blur" | "none";

export interface SceneTransitionProps {
  children: React.ReactNode;
  /** Length of the moment, so the exit lands on its last frame. */
  durationInFrames: number;
  /** Side the content comes FROM. */
  enter?: TransitionKind;
  /** Side the content leaves TO. */
  exit?: TransitionKind;
  enterFrames?: number;
  exitFrames?: number;
  /**
   * Travel distance of directional moves, in px (a soft shift, with fade).
   * "full" pushes the whole scene across the frame without fading — the next
   * moment entering from the opposite side reads as one continuous push.
   */
  distance?: number | "full";
  style?: React.CSSProperties;
}

const OFFSETS: Record<string, [number, number]> = {
  left: [-1, 0],
  right: [1, 0],
  up: [0, -1],
  down: [0, 1],
};

function transformFor(kind: TransitionKind, hidden: number, distance: number | "full", frameSize: [number, number]) {
  // hidden: 1 = fully off, 0 = in place
  const parts: string[] = [];
  let opacity = 1;
  let filter: string | undefined;
  if (kind === "none") return { parts, opacity, filter };

  const offset = OFFSETS[kind];
  const full = distance === "full" && offset !== undefined;
  opacity = full ? 1 : 1 - hidden;
  if (offset) {
    const dx = full ? frameSize[0] : (distance as number);
    const dy = full ? frameSize[1] : (distance as number);
    parts.push(`translate(${offset[0] * dx * hidden}px, ${offset[1] * dy * hidden}px)`);
  }
  if (kind === "zoom") parts.push(`scale(${1 - 0.08 * hidden})`);
  if (kind === "blur") filter = `blur(${14 * hidden}px)`;
  return { parts, opacity, filter };
}

export function SceneTransition({
  children,
  durationInFrames,
  enter = "fade",
  exit = "fade",
  enterFrames = 15,
  exitFrames = 12,
  distance = 120,
  style,
}: SceneTransitionProps) {
  const frame = useCurrentFrame();
  const { width, height } = useVideoConfig();
  // A full-frame push only reads as one continuous move if the outgoing and
  // incoming scenes ride the same curve — then they stay exactly one frame
  // apart. Soft moves keep the decelerating entrance / accelerating exit.
  const push = distance === "full";
  const enterHidden = interpolate(frame, [0, enterFrames], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: push ? Easing.inOut(Easing.cubic) : Easing.out(Easing.cubic),
  });
  const exitHidden = interpolate(frame, [durationInFrames - exitFrames, durationInFrames], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: push ? Easing.inOut(Easing.cubic) : Easing.in(Easing.cubic),
  });

  const a = transformFor(enter, enterHidden, distance, [width, height]);
  const b = transformFor(exit, exitHidden, distance, [width, height]);
  const filters = [a.filter, b.filter].filter(Boolean).join(" ");

  return (
    <AbsoluteFill
      style={{
        transform: [...a.parts, ...b.parts].join(" ") || undefined,
        opacity: a.opacity * b.opacity,
        filter: filters || undefined,
        ...style,
      }}
    >
      {children}
    </AbsoluteFill>
  );
}

export interface StaggerProps {
  children: React.ReactNode;
  /** Frames between one child's entrance and the next. */
  each?: number;
  delay?: number;
  /** Side each child comes from; "none" = fade only. */
  from?: "up" | "down" | "left" | "right" | "none";
  distance?: number;
  duration?: number;
  blur?: boolean;
  /** "span" keeps children inline (words); "div" stacks blocks. */
  as?: "span" | "div";
  style?: React.CSSProperties;
}

function useEntrance(delay: number, duration: number) {
  const frame = useCurrentFrame();
  return interpolate(frame, [delay, delay + duration], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.out(Easing.cubic),
  });
}

function StaggerItem({
  index,
  each,
  delay,
  from,
  distance,
  duration,
  blur,
  as,
  children,
}: Required<Omit<StaggerProps, "style" | "children">> & { index: number; children: React.ReactNode }) {
  const hidden = useEntrance(delay + index * each, duration);
  const offset = from === "none" ? [0, 0] : OFFSETS[from];
  const Tag = as;
  return (
    <Tag
      style={{
        display: as === "span" ? "inline-block" : "block",
        transform: `translate(${offset[0] * distance * hidden}px, ${offset[1] * distance * hidden}px)`,
        opacity: 1 - hidden,
        filter: blur ? `blur(${10 * hidden}px)` : undefined,
      }}
    >
      {children}
    </Tag>
  );
}

/** Each direct child enters `each` frames after the previous one. */
export function Stagger({
  children,
  each = 4,
  delay = 0,
  from = "up",
  distance = 40,
  duration = 14,
  blur = false,
  as = "div",
  style,
}: StaggerProps) {
  const items = React.Children.toArray(children);
  const Tag = as;
  return (
    <Tag style={style}>
      {items.map((child, i) => (
        <StaggerItem
          key={i}
          index={i}
          each={each}
          delay={delay}
          from={from}
          distance={distance}
          duration={duration}
          blur={blur}
          as={as}
        >
          {child}
        </StaggerItem>
      ))}
    </Tag>
  );
}

export interface StaggerTextProps extends Omit<StaggerProps, "children" | "as"> {
  text: string;
  /** Animate word by word (default) or letter by letter. */
  by?: "word" | "char";
}

/** Lettering that builds itself word by word (or letter by letter). */
export function StaggerText({ text, by = "word", each, style, ...rest }: StaggerTextProps) {
  const units = by === "char" ? Array.from(text) : text.split(/\s+/).filter(Boolean);
  const step = each ?? (by === "char" ? 2 : 5);
  return (
    <span style={{ whiteSpace: "pre-wrap", ...style }}>
      {units.map((unit, i) => (
        <React.Fragment key={i}>
          <StaggerItem
            index={i}
            each={step}
            delay={rest.delay ?? 0}
            from={rest.from ?? "up"}
            distance={rest.distance ?? 24}
            duration={rest.duration ?? 12}
            blur={rest.blur ?? false}
            as="span"
          >
            {unit === " " ? " " : unit}
          </StaggerItem>
          {by === "word" && i < units.length - 1 ? " " : null}
        </React.Fragment>
      ))}
    </span>
  );
}
