import * as Babel from "@babel/standalone";
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
    let cleaned = code;

    // Extract the last code block if markdown blocks are present
    const blockRegex = /```[a-zA-Z]*\r?\n([\s\S]*?)```/g;
    let match;
    let lastBlock = "";
    while ((match = blockRegex.exec(code)) !== null) {
      lastBlock = match[1];
    }
    
    if (lastBlock) {
      cleaned = lastBlock;
    } else {
      // Fallback for unclosed blocks or blocks without language tags
      const unclosedMatch = code.match(/```[a-zA-Z]*\r?\n([\s\S]*)$/);
      if (unclosedMatch) {
        cleaned = unclosedMatch[1];
      } else {
        // Fallback: just strip any stray markdown backticks
        cleaned = code.replace(/^[\s\S]*?```[a-zA-Z]*\r?\n/, "").replace(/```\s*$/, "");
        // Strip stray language tags that Claude sometimes prepends without backticks
        cleaned = cleaned.replace(/^\s*(?:typescript|tsx|ts|jsx|js)\s*\r?\n/i, "");
      }
    }

    // Remove type imports
    cleaned = cleaned.replace(/import\s+type\s*\{[\s\S]*?\}\s*from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s+\w+\s*,\s*\{[\s\S]*?\}\s*from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s*\{[\s\S]*?\}\s*from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s+\*\s+as\s+\w+\s+from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s+\w+\s+from\s*["'][^"']+["'];?/g, "");
    cleaned = cleaned.replace(/import\s*["'][^"']+["'];?/g, "");

    cleaned = cleaned.trim();

    // Find the main component name
    let exportedName = "DynamicAnimation";
    
    // Look for `export const Name` or `export default Name` or `export function Name`
    // We want the LAST export in the file in case it exports helpers too.
    const exportRegex = /export\s+(?:const|function|default)\s+(?:function\s+)?([A-Za-z0-9_]+)/g;
    let exportMatch;
    while ((exportMatch = exportRegex.exec(cleaned)) !== null) {
      if (exportMatch[1] && exportMatch[1] !== "default") {
        exportedName = exportMatch[1];
      }
    }
    
    // Replace export default Name; with just nothing (we'll return it manually)
    cleaned = cleaned.replace(/export\s+default\s+(?:function\s+)?[A-Za-z0-9_]+;?/g, "");
    
    // Remove all remaining `export ` keywords
    cleaned = cleaned.replace(/export\s+const\s+/g, "const ");
    cleaned = cleaned.replace(/export\s+function\s+/g, "function ");

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
