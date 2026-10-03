import type { VideoSpec, VideoSpecMoment } from "./video-spec";

/**
 * Deterministic spec → motion plan, appended to the generator's user prompt.
 *
 * The briefing agent's prose describes each moment in its own words; this
 * plan restates the parts that must not be improvised — frame windows, how
 * moments connect, which motion-library component carries each connection,
 * accents and textures — straight from the validated spec. Start/duration/
 * total arrive already derived from Rails (app/services/video_spec.rb); this
 * module only groups, formats and maps vocabulary onto components.
 *
 * Structure: consecutive moments linked by morph form a SCENE GROUP — one
 * <Sequence> holding one MorphContainer whose shape carries the group from
 * moment to moment. Directional connections happen BETWEEN groups, so a push
 * moves the whole group, container included.
 */

const ACCENT_COMPONENT = {
  underline: "Underline",
  strike: "Strike",
  scribble: "Scribble",
  circle: "CircleAround",
  highlight: "Highlighter",
} as const;

const TEXTURE_COMPONENT = {
  dots: '<DotField animation="wave" opacity={0.25} />',
  lines: '<LineField animation="draw" opacity={0.2} />',
  grid: "<GridReveal opacity={0.15} />",
} as const;

const OPPOSITE = { left: "right", right: "left", up: "down", down: "up" } as const;

// Midpoints of the briefing agent's CONTAINER MORPHÁVEL size table.
function containerSize(type: string, width: number, height: number) {
  switch (type) {
    case "card_grande":
      return { w: 760, h: 460, r: 28 };
    case "card_medio":
      return { w: 580, h: 220, r: 24 };
    case "barra":
      return { w: 620, h: 72, r: 36 };
    case "pilula":
      return { w: 220, h: 48, r: 24 };
    case "circulo":
      return { w: 420, h: 420, r: 210 };
    case "fullscreen":
      return { w: width, h: height, r: 0 };
    default:
      return null;
  }
}

// Below this, a full-frame push would show both scenes for too short a time
// to read as one move; a soft shift with fade looks better.
const MIN_PUSH_OVERLAP = 8;

// Minimalist caption timing from the briefing agent: first word at frame 8,
// one word every 5 frames. The accent lands shortly after its word appears.
function minimalistAccentDelay(caption: string, word: string): number {
  const words = caption.split(/\s+/).filter(Boolean).map((w) => w.toLowerCase());
  const first = word.split(/\s+/)[0]?.toLowerCase() ?? "";
  const index = Math.max(0, words.findIndex((w) => w.includes(first)));
  return 8 + index * 5 + 10;
}

const end = (m: VideoSpecMoment) => m.start_frame + m.duration_frames;
const overlapOf = (m: VideoSpecMoment) => m.transition_from_previous?.overlap_frames ?? 0;

interface SceneGroup {
  number: number;
  moments: VideoSpecMoment[];
  start: number;
  end: number;
}

function groupMoments(spec: VideoSpec): SceneGroup[] {
  const groups: SceneGroup[] = [];
  for (const moment of spec.moments) {
    const current = groups[groups.length - 1];
    if (current && moment.transition_from_previous?.mode === "morph") {
      current.moments.push(moment);
      current.end = end(moment);
    } else {
      groups.push({ number: groups.length + 1, moments: [moment], start: moment.start_frame, end: end(moment) });
    }
  }
  return groups;
}

function describeMoment(moment: VideoSpecMoment, group: SceneGroup, minimalist: boolean): string[] {
  const caption =
    moment.caption_secondary && !minimalist
      ? `"${moment.caption}" + context "${moment.caption_secondary}"`
      : `"${moment.caption}"`;
  const localStart = moment.start_frame - group.start;
  const lines = [
    `  M${moment.index} — absolute [${moment.start_frame}, ${end(moment)}) · local to G${group.number}: from={${localStart}} durationInFrames={${moment.duration_frames}} · ${caption}`,
    `    Visual: ${moment.visual_component} (${moment.visual_category}), composition ${moment.composition_type}, background ${moment.background_color}.`,
  ];
  if (moment.accent) {
    const component = ACCENT_COMPONENT[moment.accent.type];
    const delay = minimalist ? minimalistAccentDelay(moment.caption, moment.accent.word) : 20;
    lines.push(
      `    Accent: wrap "${moment.accent.word}" in <${component} delay={${delay}}>${moment.accent.word}</${component}> (frame local to M${moment.index}).`,
    );
  }
  if (moment.texture) {
    lines.push(`    Texture: ${TEXTURE_COMPONENT[moment.texture]} behind this moment's content, at low opacity.`);
  }
  if (moment.notes) lines.push(`    Intent: ${moment.notes}`);
  return lines;
}

function describeGroup(spec: VideoSpec, group: SceneGroup, minimalist: boolean): string[] {
  const length = group.end - group.start;
  const span =
    group.moments.length > 1
      ? `M${group.moments[0].index}–M${group.moments[group.moments.length - 1].index}`
      : `M${group.moments[0].index}`;
  const lines = [``, `G${group.number} (${span}) — <Sequence from={${group.start}} durationInFrames={${length}}>`];

  const keyframes: string[] = [];
  group.moments.forEach((moment, i) => {
    const size = moment.container_type ? containerSize(moment.container_type, spec.width, spec.height) : null;
    if (!size) return;
    const at = i === 0 ? 0 : moment.start_frame + overlapOf(moment) - group.start;
    keyframes.push(`{ at: ${at}, width: ${size.w}, height: ${size.h}, radius: ${size.r} } // M${moment.index} ${moment.container_type}`);
  });

  if (group.moments.length > 1) {
    const chain = group.moments
      .map((m) => m.container_type ?? "—")
      .join(" → ");
    lines.push(
      `  Modo A — MORPH inside this group: ONE <MorphContainer> (${chain}) that never disappears. Keyframes, local to G${group.number} (add x/y/color for your layout):`,
      ...keyframes.map((k) => `    ${k}`),
      `  Old content fades/blurs out while the container morphs; new content starts entering during the morph (8–12 frames of overlap). Use the children function's index/t to swap content per moment.`,
    );
  } else if (keyframes.length === 1) {
    lines.push(`  Container: ${group.moments[0].container_type} — ${keyframes[0].replace(/^\{ at: 0, /, "{ ")}`);
  }

  lines.push(`  Moments (nested <Sequence>s, frames local to G${group.number}):`);
  for (const moment of group.moments) lines.push(...describeMoment(moment, group, minimalist));
  return lines;
}

function describeConnection(previous: SceneGroup, next: SceneGroup): string[] {
  const first = next.moments[0];
  const t = first.transition_from_previous;
  if (!t) return [``, `G${previous.number} → G${next.number}: hard cut.`];

  const enterFrom = t.direction ?? "right";
  const exitTo = OPPOSITE[enterFrom];
  const overlap = overlapOf(first);
  if (overlap >= MIN_PUSH_OVERLAP) {
    return [
      ``,
      `G${previous.number} → G${next.number} (Modo B — PUSH, ${overlap}f): the groups' Sequences overlap by ${overlap} frames (already in the windows above) — that overlap IS the push.`,
      `  G${previous.number} content in <SceneTransition durationInFrames={${previous.end - previous.start}} exit="${exitTo}" distance="full" exitFrames={${overlap}}>`,
      `  G${next.number} content in <SceneTransition durationInFrames={${next.end - next.start}} enter="${enterFrom}" distance="full" enterFrames={${overlap}}>`,
    ];
  }
  return [
    ``,
    `G${previous.number} → G${next.number} (Modo B — SHIFT): no overlap between the Sequences, so use the default soft distance (no distance="full").`,
    `  G${previous.number} content in <SceneTransition durationInFrames={${previous.end - previous.start}} exit="${exitTo}">  G${next.number} content in <SceneTransition durationInFrames={${next.end - next.start}} enter="${enterFrom}">`,
  ];
}

export function renderMotionPlan(spec: VideoSpec): string {
  const minimalist = spec.mode === "minimalista";
  const groups = groupMoments(spec);

  const lines: string[] = [
    "## MOTION PLAN (authoritative — derived from the approved spec)",
    "",
    `Composition: ${spec.width}x${spec.height} @ ${spec.fps}fps, ${spec.total_frames} frames total. Mode: ${spec.mode}.`,
    "The video is a sequence of SCENE GROUPS. Use these frame windows exactly; they already include every transition overlap.",
  ];
  if (minimalist) {
    lines.push(
      "MINIMALIST: the caption is ONE fixed layer at the bottom, outside every SceneTransition/MorphContainer — only the visual above it moves. Caption words enter one by one (first at local frame 8, then every 5 frames).",
    );
  }

  groups.forEach((group, i) => {
    if (i > 0) lines.push(...describeConnection(groups[i - 1], group));
    lines.push(...describeGroup(spec, group, minimalist));
  });

  return lines.join("\n");
}
