/**
 * useMapboxCamera — Centralized, deterministic Mapbox camera controller for Remotion.
 *
 * Abstracts all camera math away from LLM-generated code.
 * Accepts a list of keyframes and drives the camera exclusively via `map.jumpTo()`,
 * interpolated against `useCurrentFrame()`. This is the ONLY sanctioned camera API.
 *
 * Rules enforced by this hook:
 * - No mixing of jumpTo and setFreeCameraOptions in the same frame loop.
 * - No raw camera math inside useEffect in the component.
 * - Frame interpolation uses Remotion's `interpolate` with clamping.
 */

import { useEffect } from "react";
import { interpolate, Easing } from "remotion";
import type * as mapboxgl from "mapbox-gl";

export interface CameraKeyframe {
  /** Global frame at which this keyframe starts. */
  startFrame: number;
  /** Global frame at which this keyframe ends. */
  endFrame: number;
  /** Starting center position as [longitude, latitude]. */
  startCenter: [number, number];
  /** Ending center position as [longitude, latitude]. */
  endCenter: [number, number];
  /** Starting zoom level. */
  startZoom?: number;
  /** Ending zoom level. */
  endZoom?: number;
  /** Starting pitch in degrees (0 = flat, 60 = steep). */
  startPitch?: number;
  /** Ending pitch in degrees. */
  endPitch?: number;
  /** Starting bearing in degrees (0 = north). */
  startBearing?: number;
  /** Ending bearing in degrees. */
  endBearing?: number;
  /**
   * Optional easing function (t: 0..1) => (0..1).
   * Defaults to Easing.inOut(Easing.sin) for smooth motion.
   */
  easing?: (t: number) => number;
}

export interface UseMapboxCameraProps {
  /** The Mapbox map instance. Hook is a no-op when null. */
  map: Map | null;
  /** Current Remotion frame (from useCurrentFrame()). */
  frame: number;
  /** Ordered list of camera keyframes. Segments must not overlap. */
  keyframes: CameraKeyframe[];
}

/**
 * Drives the Mapbox camera deterministically from Remotion's frame clock.
 * Call this hook at the TOP LEVEL of your component, not inside useEffect.
 *
 * @example
 * const frame = useCurrentFrame();
 * useMapboxCamera({ map, frame, keyframes: [
 *   { startFrame: 0, endFrame: 60, startCenter: [-74.006, 40.712], endCenter: [-73.9, 40.75] },
 * ]});
 */
export function useMapboxCamera({ map, frame, keyframes }: UseMapboxCameraProps) {
  useEffect(() => {
    if (!map) return;

    // Find the active keyframe segment for the current frame.
    // If the frame is before all keyframes, use the first keyframe's start.
    // If the frame is after all keyframes, hold the last keyframe's end.
    let activeKeyframe: CameraKeyframe | null = null;
    let localProgress = 0;

    for (const kf of keyframes) {
      if (frame <= kf.endFrame) {
        activeKeyframe = kf;
        const segmentDuration = kf.endFrame - kf.startFrame;
        if (segmentDuration <= 0) {
          localProgress = 1;
        } else {
          const easingFn = kf.easing ?? Easing.inOut(Easing.sin);
          localProgress = easingFn(
            interpolate(frame, [kf.startFrame, kf.endFrame], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            })
          );
        }
        break;
      }
    }

    // If no keyframe found (frame is past all keyframes), hold last keyframe end state.
    if (!activeKeyframe && keyframes.length > 0) {
      activeKeyframe = keyframes[keyframes.length - 1];
      localProgress = 1;
    }

    if (!activeKeyframe) return;

    const kf = activeKeyframe;
    const t = localProgress;

    // Interpolate all camera properties linearly (easing already applied to t).
    const lng = kf.startCenter[0] + (kf.endCenter[0] - kf.startCenter[0]) * t;
    const lat = kf.startCenter[1] + (kf.endCenter[1] - kf.startCenter[1]) * t;

    const zoom =
      kf.startZoom !== undefined && kf.endZoom !== undefined
        ? kf.startZoom + (kf.endZoom - kf.startZoom) * t
        : undefined;

    const pitch =
      kf.startPitch !== undefined && kf.endPitch !== undefined
        ? kf.startPitch + (kf.endPitch - kf.startPitch) * t
        : undefined;

    const bearing =
      kf.startBearing !== undefined && kf.endBearing !== undefined
        ? kf.startBearing + (kf.endBearing - kf.startBearing) * t
        : undefined;

    // Single, unified camera call — no mixing of APIs.
    map.jumpTo({
      center: [lng, lat],
      ...(zoom !== undefined && { zoom }),
      ...(pitch !== undefined && { pitch }),
      ...(bearing !== undefined && { bearing }),
    });
  }, [map, frame, keyframes]);
}
