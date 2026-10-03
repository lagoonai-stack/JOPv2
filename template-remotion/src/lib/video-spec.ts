import { z } from "zod";

/**
 * The canonical VideoSpec, as the Rails app sends it.
 *
 * This is the second of the contract's two validation layers. The first runs
 * in Rails (app/services/video_spec.rb), which validates what the agent
 * emitted and computes every derived field. This layer only checks that what
 * arrived is coherent — it deliberately does NOT recompute durations or
 * dimensions. Two implementations of the same formula, drifting apart, is the
 * failure mode this whole contract exists to remove.
 *
 * A spec that fails here is a bug in the caller, not a prompt to improvise on:
 * the route answers 422 with the list of problems instead of falling back to
 * defaults.
 */

export const SPEC_VERSION = "1";

const hexColor = z
  .string()
  .regex(/^#[0-9A-Fa-f]{6}$/, "must be a #RRGGBB hex colour");

export const CONTAINER_TYPES = [
  "card_grande",
  "card_medio",
  "barra",
  "pilula",
  "circulo",
  "fullscreen",
] as const;

const TransitionSchema = z.object({
  mode: z.enum(["morph", "directional"]),
  direction: z.enum(["left", "right", "up", "down"]).nullish(),
  morph_from: z.enum(CONTAINER_TYPES).nullish(),
  morph_to: z.enum(CONTAINER_TYPES).nullish(),
  overlap_frames: z.number().int().min(0).max(60).nullish(),
});

// Motion library vocabulary (src/remotion/design-system). Mirrors
// VideoSpec::ACCENT_TYPES / TEXTURES in Rails.
export const ACCENT_TYPES = ["underline", "strike", "scribble", "circle", "highlight"] as const;
export const TEXTURES = ["dots", "lines", "grid"] as const;

const AccentSchema = z.object({
  type: z.enum(ACCENT_TYPES),
  word: z.string().min(1),
});

const MomentSchema = z.object({
  index: z.number().int().min(1),
  caption: z.string().min(1),
  caption_secondary: z.string().nullish(),
  composition_type: z.enum(["A", "B", "C"]),
  visual_category: z.enum(["produto", "geometrico", "organico", "tipografico"]),
  visual_component: z.string().min(1),
  container_type: z.enum(CONTAINER_TYPES).nullish(),
  background_color: hexColor,
  text_position: z.enum(["centro", "inferior", "superior"]),
  text_align: z.enum(["center", "left", "right"]),
  // Derived upstream — required here precisely because they must not be guessed.
  start_frame: z.number().int().min(0),
  duration_frames: z.number().int().positive(),
  transition_from_previous: TransitionSchema.nullish(),
  accent: AccentSchema.nullish(),
  texture: z.enum(TEXTURES).nullish(),
  notes: z.string().nullish(),
});

export const VideoSpecSchema = z.object({
  spec_version: z.literal(SPEC_VERSION),
  format: z.enum(["vertical", "horizontal"]),
  mode: z.enum(["minimalista", "dinamico"]),
  palette: z.enum(["dark_premium", "bold", "editorial", "neon", "custom"]),
  palette_overrides: z.record(z.string(), z.string()).nullish(),
  theme: z.string().min(1),
  width: z.number().int().positive(),
  height: z.number().int().positive(),
  fps: z.number().int().positive(),
  total_frames: z.number().int().positive(),
  moments: z.array(MomentSchema).min(3).max(12),
});

export type VideoSpec = z.infer<typeof VideoSpecSchema>;
export type VideoSpecMoment = z.infer<typeof MomentSchema>;

export interface SpecParseResult {
  spec: VideoSpec | null;
  errors: string[];
}

/** Validate an incoming spec, returning readable errors rather than throwing. */
export function parseVideoSpec(input: unknown): SpecParseResult {
  const result = VideoSpecSchema.safeParse(input);

  if (result.success) {
    return { spec: result.data, errors: coherenceErrors(result.data) };
  }

  return {
    spec: null,
    errors: result.error.issues.map(
      (issue) => `${issue.path.join(".") || "(root)"}: ${issue.message}`,
    ),
  };
}

/**
 * Checks that only make sense across fields: the timeline has to add up, and
 * the dimensions have to match the declared format. Catches a caller that
 * hand-assembled a spec instead of deriving it.
 */
function coherenceErrors(spec: VideoSpec): string[] {
  const errors: string[] = [];

  const expected =
    spec.format === "vertical"
      ? { width: 1080, height: 1920 }
      : { width: 1920, height: 1080 };

  if (spec.width !== expected.width || spec.height !== expected.height) {
    errors.push(
      `format "${spec.format}" implies ${expected.width}x${expected.height}, got ${spec.width}x${spec.height}`,
    );
  }

  const last = spec.moments[spec.moments.length - 1];
  const impliedTotal = last.start_frame + last.duration_frames;
  if (impliedTotal !== spec.total_frames) {
    errors.push(
      `total_frames is ${spec.total_frames} but the last moment ends at ${impliedTotal}`,
    );
  }

  spec.moments.forEach((moment, position) => {
    if (moment.index !== position + 1) {
      errors.push(
        `moments[${position}].index is ${moment.index}, expected ${position + 1}`,
      );
    }
  });

  return errors;
}

/** Composition settings a spec pins down, for the generation call. */
export function specToGenerationOptions(spec: VideoSpec) {
  return {
    width: spec.width,
    height: spec.height,
    fps: spec.fps,
    durationInFrames: spec.total_frames,
  };
}
