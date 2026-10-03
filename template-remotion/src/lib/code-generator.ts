import {
  getCombinedSkillContent,
  SKILL_DETECTION_PROMPT,
  SKILL_NAMES,
  type SkillName,
} from "@/skills";
import { createOpenAI } from "@ai-sdk/openai";
import { generateObject, streamText } from "ai";
import { z } from "zod";
import {
  FOLLOW_UP_SYSTEM_PROMPT,
  SYSTEM_PROMPT,
  VALIDATION_PROMPT,
  buildEditHistoryContext,
  buildFollowUpUserPrompt,
} from "@/lib/prompts";
import {
  describeProblems,
  hasBlockingProblem,
  inspectGeneratedCode,
  type CodeProblem,
} from "@/lib/code-validator";
import { VIDEO_DEFAULTS } from "@/lib/video-defaults";

/**
 * How many times a generation may be re-attempted when the produced code has a
 * blocking problem. Three is the same budget the local UI's auto-correction
 * hook uses, and each attempt is a full generation — the cost ceiling is real.
 */
const MAX_GENERATION_ATTEMPTS = 3;

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
  /** How many generation passes it took (1 when the first output was clean). */
  attempts: number;
  /** Findings on the delivered code — empty when it passed cleanly. */
  problems: CodeProblem[];
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

  // Precedence: what the caller explicitly asked for wins over what the skill
  // detector inferred from the prose, which in turn wins over the defaults.
  // The caller (the Rails app) sends the spec the user already approved in the
  // chat — re-inferring dimensions from the prompt at this point is how a video
  // agreed as vertical came out horizontal.
  const durationInFrames =
    options.durationInFrames ?? detection.durationInFrames ?? VIDEO_DEFAULTS.durationInFrames;
  const width = options.width ?? detection.width ?? VIDEO_DEFAULTS.width;
  const height = options.height ?? detection.height ?? VIDEO_DEFAULTS.height;
  const fps = options.fps ?? VIDEO_DEFAULTS.fps;

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

  const { code, problems, attempts } = await generateWithRetry(
    modelName,
    apiKey,
    enhancedSystemPrompt,
    prompt
  );

  return {
    code,
    detectedSkills: detection.skills,
    durationInFrames,
    width,
    height,
    fps,
    attempts,
    problems,
  };
}

export interface EditOptions extends GenerationOptions {
  /** Skills detected when the video was first generated (Rails keeps them). */
  skills?: string[];
  /** Adjustments already applied to this code, oldest first. */
  previousInstructions?: string[];
}

/**
 * Apply a conversational adjustment ("make the caption bigger", "swap the
 * background of moment 3") to existing component code.
 *
 * Goes through the same generate → inspect → retry loop as a fresh
 * generation, so an edit can't deliver code that breaks the render rules.
 * No validatePrompt: an adjustment is not a request for a video. Composition
 * settings come from the caller and are never re-detected.
 */
export async function editComponentCode(
  currentCode: string,
  instruction: string,
  options: EditOptions = {}
): Promise<GeneratedComponent> {
  const modelName = options.model || "gpt-6-astra";
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY not configured");
  }

  const known = (options.skills ?? []).filter((s): s is SkillName =>
    (SKILL_NAMES as readonly string[]).includes(s)
  );
  const skills = known.length > 0 ? known : (await detectSkills(instruction, modelName)).skills;

  const skillContent = getCombinedSkillContent(skills);
  const system = [
    SYSTEM_PROMPT,
    skillContent ? `## SKILL-SPECIFIC GUIDANCE\n${skillContent}` : "",
    FOLLOW_UP_SYSTEM_PROMPT,
  ]
    .filter(Boolean)
    .join("\n\n");

  const userContent = buildFollowUpUserPrompt(
    currentCode,
    instruction,
    buildEditHistoryContext(options.previousInstructions ?? [])
  );

  console.log("[CodeGenerator] Edit:", instruction, "skills:", skills);
  const { code, problems, attempts } = await generateWithRetry(modelName, apiKey, system, userContent);

  return {
    code,
    detectedSkills: skills,
    durationInFrames: options.durationInFrames ?? VIDEO_DEFAULTS.durationInFrames,
    width: options.width ?? VIDEO_DEFAULTS.width,
    height: options.height ?? VIDEO_DEFAULTS.height,
    fps: options.fps ?? VIDEO_DEFAULTS.fps,
    attempts,
    problems,
  };
}

/**
 * Generate, inspect, and retry on blocking problems. Without this loop the
 * first thing to look at the code is the user's browser, and a failure there
 * is terminal: this path has no follow-up or manual-edit affordance.
 */
async function generateWithRetry(
  modelName: string,
  apiKey: string,
  system: string,
  prompt: string
): Promise<{ code: string; problems: CodeProblem[]; attempts: number }> {
  const openai = createOpenAI({ apiKey });
  let code = "";
  let problems: CodeProblem[] = [];
  let attempts = 0;

  while (attempts < MAX_GENERATION_ATTEMPTS) {
    attempts++;

    const userContent =
      attempts === 1
        ? prompt
        : buildCorrectionPrompt(prompt, code, problems, attempts);

    const raw = await streamCode(openai(modelName), system, userContent);
    code = sanitizeGeneratedCode(raw);
    problems = inspectGeneratedCode(code);

    if (!hasBlockingProblem(problems)) {
      if (problems.length > 0) {
        console.warn(
          `[CodeGenerator] attempt ${attempts} accepted with warnings:\n${describeProblems(problems)}`
        );
      }
      break;
    }

    console.warn(
      `[CodeGenerator] attempt ${attempts}/${MAX_GENERATION_ATTEMPTS} rejected:\n${describeProblems(problems)}`
    );
  }

  if (hasBlockingProblem(problems)) {
    // Out of attempts. Return the code anyway — a preview that renders an error
    // the user can react to beats a request that simply fails — but say so, so
    // the caller can log it and the failure rate becomes measurable.
    console.error(
      `[CodeGenerator] exhausted ${MAX_GENERATION_ATTEMPTS} attempts; delivering last output with:\n${describeProblems(problems)}`
    );
  }

  return { code, problems, attempts };
}

/** One generation pass, collected from the stream. */
async function streamCode(
  model: Parameters<typeof streamText>[0]["model"],
  system: string,
  userContent: string
): Promise<string> {
  // streamText reports provider failures (no credits, bad key, rate limit)
  // through onError and simply ends the text stream — without this the
  // generator returned 200 with empty code and the user got a blank preview.
  let streamError: unknown = null;
  const result = await streamText({
    model,
    system,
    messages: [{ role: "user", content: userContent }],
    // @ts-expect-error - maxTokens is not in the type definition but is supported
    maxTokens: 22500,
    onError: ({ error }) => {
      streamError = error;
    },
  });

  let fullCode = "";
  for await (const chunk of result.textStream) {
    fullCode += chunk;
  }

  if (!fullCode.trim()) {
    const reason = streamError instanceof Error ? streamError.message : String(streamError ?? "empty response");
    throw new Error(`Code generation returned no code: ${reason}`);
  }

  return fullCode;
}

/** Strip markdown wrappers and any commentary trailing the component. */
function sanitizeGeneratedCode(raw: string): string {
  let cleanCode = raw.trim();

  if (cleanCode.startsWith("```")) {
    cleanCode = cleanCode.replace(/^```[\w]*\n/, "").replace(/\n```$/, "");
  }

  const lastBraceIndex = cleanCode.lastIndexOf("}");
  if (lastBraceIndex !== -1) {
    cleanCode = cleanCode.substring(0, lastBraceIndex + 1);
  }

  return cleanCode.trim();
}

/**
 * Re-ask with the broken code and what is wrong with it. Warnings ride along
 * once a retry is already happening, since fixing them costs nothing extra.
 */
function buildCorrectionPrompt(
  originalPrompt: string,
  previousCode: string,
  problems: CodeProblem[],
  attempt: number
): string {
  return [
    `## ORIGINAL REQUEST`,
    originalPrompt,
    ``,
    `## PREVIOUS ATTEMPT (${attempt - 1}/${MAX_GENERATION_ATTEMPTS}) — REJECTED`,
    "```tsx",
    previousCode,
    "```",
    ``,
    `## PROBLEMS FOUND`,
    describeProblems(problems),
    ``,
    `Return the COMPLETE corrected component. Fix every problem above and change nothing else. Output only code, starting with "import" and ending with "};".`,
  ].join("\n");
}
