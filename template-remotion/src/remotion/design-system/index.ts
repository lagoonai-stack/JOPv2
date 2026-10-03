/**
 * Motion library available to generated code.
 *
 * Single registry: src/remotion/compiler.ts injects every entry of
 * DESIGN_SYSTEM into the generated component's scope under the same name, so
 * adding a component here is all it takes to make it callable. The generator
 * prompt documents how to use them (src/lib/prompts.ts).
 */
import { MorphContainer, useMorph } from "./morph";
import { CircleAround, Highlighter, Scribble, Strike, Underline } from "./strokes";
import { DotField, GridReveal, LineField } from "./textures";
import { SceneTransition, Stagger, StaggerText } from "./transitions";

export const DESIGN_SYSTEM = {
  // Connection between moments
  MorphContainer,
  useMorph,
  SceneTransition,
  // Lettering
  Stagger,
  StaggerText,
  Underline,
  Strike,
  Scribble,
  CircleAround,
  Highlighter,
  // Textures
  DotField,
  LineField,
  GridReveal,
} as const;

export type DesignSystemName = keyof typeof DESIGN_SYSTEM;
