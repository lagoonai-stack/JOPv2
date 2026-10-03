/**
 * Single source of truth for composition defaults on the Node side.
 *
 * These are the values used when NOTHING is known about the requested video —
 * neither an explicit request from the caller nor a dimension/duration the
 * skill detector could read out of the prompt. Callers that know better (the
 * Rails app sends the approved spec) must pass explicit options; this object is
 * the last resort, not a negotiating position.
 */
export const VIDEO_DEFAULTS = {
  width: 1920,
  height: 1080,
  fps: 30,
  durationInFrames: 300,
} as const;
