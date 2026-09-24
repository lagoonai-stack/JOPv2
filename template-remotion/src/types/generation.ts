export const MODELS = [
  { id: "claude-sonnet-4-6", name: "Claude 4.6 Sonnet" },
] as const;

export type ModelId = (typeof MODELS)[number]["id"];

export type StreamPhase = "idle" | "reasoning" | "generating";

export type GenerationErrorType = "validation" | "api";
