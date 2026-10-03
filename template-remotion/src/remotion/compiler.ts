import * as Babel from "@babel/standalone";
import { prepareGeneratedCode } from "./code-prepare";
import { LightLeak } from "@remotion/light-leaks";
import { Lottie } from "@remotion/lottie";
import * as RemotionPaths from "@remotion/paths";
import * as RemotionShapes from "@remotion/shapes";
import { ThreeCanvas } from "@remotion/three";
import {
  TransitionSeries,
  linearTiming,
  springTiming,
} from "@remotion/transitions";
import { clockWipe } from "@remotion/transitions/clock-wipe";
import { fade } from "@remotion/transitions/fade";
import { flip } from "@remotion/transitions/flip";
import { slide } from "@remotion/transitions/slide";
import { wipe } from "@remotion/transitions/wipe";
import React, { useEffect, useId, useMemo, useRef, useState } from "react";
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";
import * as turf from "@turf/turf";
import { useMapboxCamera } from "@/hooks/useMapboxCamera";
import {
  AbsoluteFill,
  Img,
  Sequence,
  interpolate,
  interpolateColors,
  spring,
  Easing,
  useCurrentFrame,
  useVideoConfig,
  delayRender,
  continueRender,
  Audio,
  Video,
  Series,
  staticFile,
  AnimatedImage,
} from "remotion";
import {
  useAudioData,
  useWindowedAudioData,
  visualizeAudio,
  visualizeAudioWaveform,
  getWaveformPortion,
  createSmoothSvgPath,
} from "@remotion/media-utils";
import * as THREE from "three";
import { DESIGN_SYSTEM } from "./design-system";

// A design-system name the generated code declares itself (an older video with
// its own `Stagger` helper, say) is left out of the injected scope: a function
// parameter redeclared with const/let in the body is a SyntaxError.
function designSystemScope(code: string): [string[], unknown[]] {
  const names: string[] = [];
  const values: unknown[] = [];
  for (const [name, value] of Object.entries(DESIGN_SYSTEM)) {
    const declared = new RegExp(`\\b(?:const|let|var|function|class)\\s+${name}\\b`).test(code);
    if (!declared) {
      names.push(name);
      values.push(value);
    }
  }
  return [names, values];
}

export interface CompilationResult {
  Component: React.ComponentType | null;
  error: string | null;
}

// Standalone compile function for use outside React components
export function compileCode(code: string): CompilationResult {
  if (!code?.trim()) {
    return { Component: null, error: "No code provided" };
  }

  try {
    const { cleaned, exportedName } = prepareGeneratedCode(code);

    const transpiled = Babel.transform(cleaned, {
      presets: ["react", "typescript"],
      filename: "dynamic-animation.tsx",
    });

    if (!transpiled.code) {
      return { Component: null, error: "Transpilation failed" };
    }

    const Remotion = {
      AbsoluteFill,
      interpolate,
      interpolateColors,
      useCurrentFrame,
      useVideoConfig,
      spring,
      Easing,
      Sequence,
      Img,
      delayRender,
      continueRender,
    };

    const wrappedCode = `${transpiled.code}\nreturn ${exportedName};`;
    const [dsNames, dsValues] = designSystemScope(cleaned);

    const createComponent = new Function(
      "React",
      "Remotion",
      "RemotionShapes",
      "Lottie",
      "ThreeCanvas",
      "THREE",
      "AbsoluteFill",
      "interpolate",
      "interpolateColors",
      "useCurrentFrame",
      "useVideoConfig",
      "spring",
      "Easing",
      "Sequence",
      "Img",
      "delayRender",
      "continueRender",
      "useState",
      "useEffect",
      "useMemo",
      "useRef",
      "useId",
      "Rect",
      "Circle",
      "Triangle",
      "Star",
      "Polygon",
      "Ellipse",
      "Heart",
      "Pie",
      "makeRect",
      "makeCircle",
      "makeTriangle",
      "makeStar",
      "makePolygon",
      "makeEllipse",
      "makeHeart",
      "makePie",
      // Transitions
      "TransitionSeries",
      "linearTiming",
      "springTiming",
      "fade",
      "slide",
      "wipe",
      "flip",
      "clockWipe",
      "LightLeak",
      "mapboxgl",
      "turf",
      "useMapboxCamera",
      "process",
      "Audio",
      "Video",
      "Series",
      "staticFile",
      "AnimatedImage",
      // Media Utils
      "useAudioData",
      "useWindowedAudioData",
      "visualizeAudio",
      "visualizeAudioWaveform",
      "getWaveformPortion",
      "createSmoothSvgPath",
      // Paths
      "evolvePath",
      "getLength",
      "getPointAtLength",
      "getTangentAtLength",
      "getInstructionIndexAtLength",
      "interpolatePath",
      "normalizePath",
      "parsePath",
      "reduceInstructions",
      "resetPath",
      "reversePath",
      "scalePath",
      "serializeInstructions",
      "translatePath",
      "warpPath",
      "getSubpaths",
      "cutPath",
      "extendViewBox",
      "getBoundingBox",
      // Motion library (src/remotion/design-system)
      ...dsNames,
      wrappedCode,
    );

    const Component = createComponent(
      React,
      Remotion,
      RemotionShapes,
      Lottie,
      ThreeCanvas,
      THREE,
      AbsoluteFill,
      interpolate,
      interpolateColors,
      useCurrentFrame,
      useVideoConfig,
      spring,
      Easing,
      Sequence,
      Img,
      delayRender,
      continueRender,
      useState,
      useEffect,
      useMemo,
      useRef,
      useId,
      RemotionShapes.Rect,
      RemotionShapes.Circle,
      RemotionShapes.Triangle,
      RemotionShapes.Star,
      RemotionShapes.Polygon,
      RemotionShapes.Ellipse,
      RemotionShapes.Heart,
      RemotionShapes.Pie,
      RemotionShapes.makeRect,
      RemotionShapes.makeCircle,
      RemotionShapes.makeTriangle,
      RemotionShapes.makeStar,
      RemotionShapes.makePolygon,
      RemotionShapes.makeEllipse,
      RemotionShapes.makeHeart,
      RemotionShapes.makePie,
      // Transitions
      TransitionSeries,
      linearTiming,
      springTiming,
      fade,
      slide,
      wipe,
      flip,
      clockWipe,
      LightLeak,
      mapboxgl,
      turf,
      useMapboxCamera,
      { env: { REMOTION_MAPBOX_TOKEN: process.env.NEXT_PUBLIC_REMOTION_MAPBOX_TOKEN || "" } },
      Audio,
      Video,
      Series,
      staticFile,
      AnimatedImage,
      // Media Utils
      useAudioData,
      useWindowedAudioData,
      visualizeAudio,
      visualizeAudioWaveform,
      getWaveformPortion,
      createSmoothSvgPath,
      // Paths
      RemotionPaths.evolvePath,
      RemotionPaths.getLength,
      RemotionPaths.getPointAtLength,
      RemotionPaths.getTangentAtLength,
      RemotionPaths.getInstructionIndexAtLength,
      RemotionPaths.interpolatePath,
      RemotionPaths.normalizePath,
      RemotionPaths.parsePath,
      RemotionPaths.reduceInstructions,
      RemotionPaths.resetPath,
      RemotionPaths.reversePath,
      RemotionPaths.scalePath,
      RemotionPaths.serializeInstructions,
      RemotionPaths.translatePath,
      RemotionPaths.warpPath,
      RemotionPaths.getSubpaths,
      RemotionPaths.cutPath,
      RemotionPaths.extendViewBox,
      RemotionPaths.getBoundingBox,
      ...dsValues,
    );

    if (typeof Component !== "function") {
      return {
        Component: null,
        error: "Code must be a function that returns a React component",
      };
    }

    return { Component, error: null };
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error.message : "Unknown compilation error";
    return { Component: null, error: errorMessage };
  }
}
