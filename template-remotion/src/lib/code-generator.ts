import {
  getCombinedSkillContent,
  SKILL_DETECTION_PROMPT,
  SKILL_NAMES,
  type SkillName,
} from "@/skills";
import { createOpenAI } from "@ai-sdk/openai";
import { generateObject, streamText } from "ai";
import { z } from "zod";

const VALIDATION_PROMPT = `You are a prompt classifier for a motion graphics generation tool.

Determine if the user's prompt is asking for motion graphics/animation content that can be created as a React/Remotion component.

VALID prompts include requests for:
- Animated text, titles, or typography
- Data visualizations (charts, graphs, progress bars)
- UI animations (buttons, cards, transitions)
- Logo animations or brand intros
- Social media content (stories, reels, posts)
- Explainer animations
- Kinetic typography
- Abstract motion graphics
- Animated illustrations
- Product showcases
- Countdown timers
- Loading animations
- Any visual/animated content

INVALID prompts include:
- Questions (e.g., "What is 2+2?", "How do I...")
- Requests for text/written content (poems, essays, stories, code explanations)
- Conversations or chat
- Non-visual tasks (calculations, translations, summaries)
- Requests completely unrelated to visual content

Return true if the prompt is valid for motion graphics generation, false otherwise.`;

const SYSTEM_PROMPT = `
You are an expert in generating React components for Remotion animations.

## COMPONENT STRUCTURE

1. Start with ES6 imports
2. Export as: export const MyAnimation = () => { ... };
3. Component body order:
   - Multi-line comment description (2-3 sentences)
   - Hooks (useCurrentFrame, useVideoConfig, etc.)
   - Theme tokens (THEME, COLORS, TEXT, TIMING, LAYOUT) - all UPPER_SNAKE_CASE
   - Calculations and derived values
   - return JSX

## THEME & TOKENS ARCHITECTURE (CRITICAL)

ALL tokens MUST be defined INSIDE the component body, AFTER hooks, before calculations.

First, identify the DESIGN ARCHETYPE that best fits the brief. You MUST use one of these predefined recipes to ensure premium aesthetic quality. Do NOT invent generic colors.

1. PREMIUM DARK (App/SaaS/Cinematic - Default)
   COLORS = { bg: '#000000', surface1: '#111113', surface2: '#1A1A1E', text: '#FFFFFF', textMuted: '#A0A0A8', accent: '#34D399' /* or #60A5FA */ }
2. BOLD & CONTRAST (High Impact/Punchy Social)
   COLORS = { bg: '#0A0A0A', surface1: '#1A1A1A', text: '#F5F5F5', accent: '#1A3FE0' /* or #E01A1A / #F5C518 */ }
3. EDITORIAL (Clean/Corporate/Elegant)
   COLORS = { bg: '#F2F0EB', surface1: '#FFFFFF', text: '#1A1A1A', textMuted: '#6E6E76', accent: '#E63B2E' }
4. NEON/GLOW (Gaming/Web3/Night)
   COLORS = { bg: '#050510', surface1: '#0B0B1A', text: '#FFFFFF', accent: '#00FF88', glow: '#00AAFF' }

Return ONLY valid TypeScript/React code. No markdown formatting, no explanations.
`;

export interface GenerationOptions {
  model?: string;
  durationInFrames?: number;
  width?: number;
  height?: number;
  fps?: number;
}

export interface GeneratedComponent {
  code: string;
  detectedSkills: string[];
  durationInFrames: number;
  width: number;
  height: number;
  fps: number;
}

export async function validatePrompt(prompt: string, modelName: string): Promise<boolean> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY not configured');
  }

  const openai = createOpenAI({ apiKey });

  try {
    const validationResult = await generateObject({
      model: openai(modelName),
      system: VALIDATION_PROMPT,
      prompt: `User prompt: "${prompt}"`,
      schema: z.object({ valid: z.boolean() }),
    });

    return validationResult.object.valid;
  } catch (error) {
    console.error("Validation error:", error);
    // On validation error, allow through rather than blocking
    return true;
  }
}

export async function detectSkills(
  prompt: string,
  modelName: string
): Promise<{
  skills: SkillName[];
  durationInFrames: number | null;
  width: number | null;
  height: number | null;
}> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY not configured');
  }

  const openai = createOpenAI({ apiKey });

  try {
    const skillResult = await generateObject({
      model: openai(modelName),
      system: SKILL_DETECTION_PROMPT,
      prompt: `User prompt: "${prompt}"`,
      schema: z.object({
        skills: z.array(z.enum(SKILL_NAMES)),
        durationInFrames: z.number().nullable(),
        width: z.number().nullable(),
        height: z.number().nullable(),
      }),
    });

    return {
      skills: skillResult.object.skills,
      durationInFrames: skillResult.object.durationInFrames ?? null,
      width: skillResult.object.width ?? null,
      height: skillResult.object.height ?? null,
    };
  } catch (error) {
    console.error("Skill detection error:", error);
    return {
      skills: [],
      durationInFrames: null,
      width: null,
      height: null,
    };
  }
}

export async function generateComponentCode(
  prompt: string,
  options: GenerationOptions = {}
): Promise<GeneratedComponent> {
  const modelName = options.model || "gpt-6-astra";
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    throw new Error('OPENAI_API_KEY not configured');
  }

  // Validate prompt
  const isValid = await validatePrompt(prompt, modelName);
  if (!isValid) {
    throw new Error(
      "No valid motion graphics prompt. Please describe an animation or visual content you'd like to create."
    );
  }

  // Detect skills
  const detection = await detectSkills(prompt, modelName);

  // Use detected values or fallback to options or defaults
  const durationInFrames = detection.durationInFrames ?? options.durationInFrames ?? 300;
  const width = detection.width ?? options.width ?? 1920;
  const height = detection.height ?? options.height ?? 1080;
  const fps = options.fps ?? 30;

  console.log(
    "[CodeGenerator] Detected skills:", detection.skills,
    "duration:", durationInFrames,
    "fps:", fps,
    "width:", width,
    "height:", height
  );

  // Load skill-specific content
  const skillContent = getCombinedSkillContent(detection.skills);
  const enhancedSystemPrompt = skillContent
    ? `${SYSTEM_PROMPT}\n\n## SKILL-SPECIFIC GUIDANCE\n${skillContent}`
    : SYSTEM_PROMPT;

  const openai = createOpenAI({ apiKey });

  // Generate code
  const result = await streamText({
    model: openai(modelName),
    system: enhancedSystemPrompt,
    messages: [
      {
        role: "user",
        content: prompt,
      },
    ],
    // @ts-expect-error - maxTokens is not in the type definition but is supported
    maxTokens: 22500,
  });

  // Collect the full response
  let fullCode = "";
  for await (const chunk of result.textStream) {
    fullCode += chunk;
  }

  // Clean up the code (remove markdown wrappers if present)
  let cleanCode = fullCode.trim();

  // Remove markdown code blocks
  if (cleanCode.startsWith("```")) {
    cleanCode = cleanCode.replace(/^```[\w]*\n/, "").replace(/\n```$/, "");
  }

  // Remove any trailing commentary after the last closing brace
  const lastBraceIndex = cleanCode.lastIndexOf("}");
  if (lastBraceIndex !== -1) {
    cleanCode = cleanCode.substring(0, lastBraceIndex + 1);
  }

  return {
    code: cleanCode.trim(),
    detectedSkills: detection.skills,
    durationInFrames,
    width,
    height,
    fps,
  };
}
