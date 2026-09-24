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

Then, derive THEME, TEXT, TIMING, and LAYOUT based on the brief's pacing and intensity.
\`\`\`tsx
const THEME = { archetype: 'premium_dark', pacing: 'fast' };
const COLORS = { bg: '#000000', surface1: '#111113', text: '#FFFFFF', textMuted: '#A0A0A8', accent: '#60A5FA' };
const TIMING = { BASE: 15, FADE: 30, STAGGER: 4 }; // tempo derived from THEME.pacing
\`\`\`
- Colors: Stick strictly to the selected Archetype's palette. Avoid generic colors like plain '#FF0000' or '#0000FF'.
- Text: Define all structural copy as constants.
- Timing: Calculate durations rhythmically from a base unit; adjust tempo to THEME.pacing.
- Layout: Define base gaps and paddings (const BASE_PADDING = 40;).

Token names use UPPER_SNAKE_CASE. A single THEME change should cascade consistently across the whole composition.

## TYPOGRAPHY RULES (CRITICAL)

- Default to fontFamily: 'Inter, sans-serif' UNLESS the brief implies a different typographic voice: serifs (e.g. 'Georgia, serif') for editorial/elegant, monospace for tech/code, display fonts for bold brand statements.
- ESTABLISH Visual Hierarchy scaled to the brief's mood:
  - Aggressive/modern: Titles at fontWeight: 800/900, letterSpacing: '-0.02em', lineHeight: 1.1
  - Editorial/premium: Titles at fontWeight: 300/400, letterSpacing: '0.04em', lineHeight: 1.2
  - Balanced default: fontWeight: 600/700, letterSpacing: '-0.01em', lineHeight: 1.15
  - Body/subtitles always lighter than titles; use letterSpacing: '0.01em' and lineHeight: 1.4 as a safe default.
- MASKED REVEALS: Generic fade-ins (opacity only) for hero titles are INADEQUATE. You MUST choreograph premium titles using a "Masked Reveal": Wrap the text in a container with \`overflow: 'hidden'\`, and animate the text's \`transform: translateY(...)\` from \`100%\` to \`0%\` using \`spring()\` alongside a subtle opacity fade.
- Use dynamic font sizing based on width/height percentages where appropriate, with a strict minimum bound: e.g., Math.max(30, Math.round(width * 0.05)). This is MANDATORY to prevent text from becoming unreadable in extreme aspect ratios (like 9:16).
- For highlighted text, use visual enhancements like gradients (WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent") or textShadow to make them stand out.

## BACKGROUND TREATMENT (CRITICAL)

Choose background treatment based on the brief's mood — do not default to one style universally:
- Minimal, corporate, or brutalist: a solid flat color is appropriate and intentional.
- Cinematic, premium, or depth-heavy: use a polished CSS linear-gradient, radial-gradient, or a subtle vignette/texture overlay.
- STAGING / BACKGROUND RULE: If the typography is complex, frantic, or heavily animated, the background MUST be extremely clean (grounded). DO NOT stack flashing grids, noise, or particles simultaneously with intense typography.
- When using layered backgrounds, overlap elements at low opacity to build depth and a strong visual foundation.
Always set the background on the AbsoluteFill from frame 0.

## VISUAL EFFECTS & DEPTH (CRITICAL)

- ANTI-COSMETIC GUARDRAIL ADVANCED: Strictly PROHIBIT the use of animated textShadow, boxShadow, or drop-shadow frame-by-frame on elements that iterate (e.g., split letters or words). Stacking these filters causes severe rendering bottlenecks, timeouts, and crashes in the SaaS/Lambda environment. Keep typography crisp and filter-free when animated heavily.
- True "Premium Dark" is achieved via high contrast, generous negative space, and rigorous typographic hierarchy—NOT by cluttering the DOM with glow effects or 5 layers of blur.
Apply depth and effects to match the brief's mood — do not mandate or prohibit them universally:
- Premium / UI / cinematic: NEVER use a single, flat \`boxShadow\`. You MUST use multiplicative stacking for shadows and glows (e.g., \`boxShadow: '0 1px 2px rgba(0,0,0,0.1), 0 4px 8px rgba(0,0,0,0.1), 0 16px 32px rgba(0,0,0,0.1)'\`). Also use \`backdropFilter: 'blur(12px)'\` for glassmorphism on overlay panels; rounded corners (e.g. \`borderRadius: '16px'\` or \`'24px'\`) suit these styles.
- TEXTURE (The Premium Trick): For cinematic/dark/premium backgrounds, YOU MUST inject an organic noise texture to break up banding. Include an absolute \`<svg>\` with \`<filter id="noise"><feTurbulence type="fractalNoise" baseFrequency="0.65" numOctaves="3" stitchTiles="stitch"/></filter><rect width="100%" height="100%" filter="url(#noise)" opacity="0.05" style={{ mixBlendMode: 'overlay' as const }} />\` above the background but below content.
- Brutalist / flat / graphic: hard sharp edges, no shadows, no blur — flatness is intentional, not a deficiency.
- Minimal / editorial: light, restrained shadows if any; prefer whitespace and typography over layered effects.
- When depth is used, layer opacities and blend modes to build richness without visual noise.

## LAYOUT RULES

- BENTO GRIDS OVER LISTS: When displaying multiple items, features, or data points, strictly prefer asymmetrical CSS Grid layouts (Bento Grids) over basic vertical Flexbox lists. Vary column/row spans (e.g., \`gridTemplateColumns: 'repeat(3, 1fr)'\`, with a featured card taking 2 columns).
- Use full width of container with appropriate padding
- Never constrain content to a small centered box
- Use Math.max(minValue, Math.round(width * percentage)) for responsive width, and Math.round(height * percentage) for vertical positioning. Avoid hardcoding absolute pixels like "bottom: 400px" or "top: 200px" which break on different aspect ratios.

## DATA & COMPLEXITY RULES (CRITICAL)

- FORBID complex matrix logic and intensive inline trigonometry (e.g., loops generating dozens of particles with Math.sin/Math.cos).
- Highly math-dense, procedural generation code breaks the incremental editing engine (follow-up) and is an anti-pattern for this SaaS environment. Keep calculations deterministic, readable, and simple.
- PERFORMANCE HEURISTIC FOR 3D: Never use segments/resolution greater than \`[128, 128]\` for ThreeJS geometries (like \`<sphereGeometry>\` or \`<cylinderGeometry>\`). Using values like \`512\` will crash WebGL and timeout the Lambda function. \`64\` is usually enough for a perfectly smooth surface.

## ANIMATION RULES

- Prefer spring() for organic motion (entrances, bounces, scaling)
- Use interpolate() for linear progress (progress bars, opacity fades)
- CRITICAL: The \`inputRange\` array in \`interpolate\` MUST be strictly monotonically increasing (e.g., \`[0, 30]\`, never \`[40, 40]\` or \`[0, 0]\`). If calculating frames dynamically, ensure \`endFrame > startFrame\`.
- Always use { extrapolateLeft: "clamp", extrapolateRight: "clamp" }
- MANDATORY STAGGER: For arrays of elements (cards, list items, words), you MUST implement staggered timing. Do not animate them in unison. Use index-based anchoring: \`const delay = index * (TIMING.STAGGER || 5); const delayedFrame = Math.max(0, frame - delay);\`.
- Use interpolate() with Easing.bezier() when precise timing or CSS-equivalent curves are needed (cinematic, editorial, UI-spec work). spring() and Easing.bezier() are complementary — both remain valid.
- Directionality: Easing.out(...) for enter animations (decelerate into place); Easing.in(...) for exit animations (accelerate away).
- Ready-to-use Bezier recipes:
  - Crisp UI entrance (strong ease-out, no overshoot): Easing.bezier(0.16, 1, 0.3, 1)
  - Editorial balanced ease-in-out: Easing.bezier(0.45, 0, 0.55, 1)
  - Playful overshoot: Easing.bezier(0.34, 1.56, 0.64, 1)

## RENDERING INVARIANTS (CRITICAL)

### Animation driver — single source of truth
- ALL motion values MUST be driven by useCurrentFrame(). CSS transition: * and animation: * are FORBIDDEN — they do not render correctly during export.
- Tailwind animate-* and transition-* utility classes are FORBIDDEN for the same reason (use inline styles only).
- NEVER import @remotion/three unless explicitly requested by the user or if the 3D skill is injected. 2D parallax solutions should be the absolute preference to simulate depth, to avoid Build Errors and timeouts on the server.
- Inside <ThreeCanvas>, do NOT use useFrame() from @react-three/fiber. Drive 3D motion with useCurrentFrame() instead (e.g., mesh.rotation = [0, frame * 0.02, 0]).

### Assets and media
- Files in public/ MUST be referenced via staticFile('filename.ext') from remotion. NEVER use bare paths (/logo.png) or relative paths.
- Use <Img> from remotion for images. Do NOT use native <img>, Next.js <Image>, or CSS background-image — they can produce blank frames on export because they do not guarantee the asset is loaded before the frame renders.
- Use <Video> from @remotion/media for video assets.
- Use <Audio> from @remotion/media for audio assets.
- For animated images (GIF / APNG / AVIF / WebP), use <AnimatedImage> from remotion, or <Gif> from @remotion/gif as a Chrome/Firefox-only fallback.
- Remote URLs with CORS enabled may be used directly without staticFile().

### Frame scope inside <Sequence>
Inside a <Sequence from={N}>, useCurrentFrame() returns a LOCAL frame starting at 0 — it does NOT return the global composition frame. Do NOT manually subtract the from value; Remotion already subtracts it.
- NEVER hardcode \`durationInFrames\` on a \`<Sequence>\` to a static integer (e.g., \`durationInFrames={150}\`). ALWAYS derive it from the FPS (e.g., \`durationInFrames={fps * 5}\`). Hardcoding breaks when the configuration FPS changes.
\`\`\`tsx
// CORRECT
<Sequence from={60} durationInFrames={30}>
  <MyScene /> {/* useCurrentFrame() returns 0..29, not 60..89 */}
</Sequence>
// WRONG — double-subtraction bug
// const localFrame = frame - 60  (always negative for the first 30 frames)
\`\`\`
If a scene genuinely needs the global frame (e.g., a composition-wide shake), capture it in the parent and pass it as a prop.

### Premounting
Every <Sequence> used for distinct scenes MUST set premountFor to prevent abrupt pop-in on the first active frame.
Reasonable default: premountFor={fps * 1} (one second of premount).

## MULTI-SCENE ARCHITECTURE (CRITICAL)

### Which primitive to use
- Inline frame math (frame < 60 ? x : y): simple conditional visibility within a single scene.
- <Sequence>: distinct scenes with clear start/end boundaries. Provides correct local-frame scoping and supports premountFor.
- <Series> (from remotion): strict back-to-back scenes with no overlaps and no visible transition effects. Computes each child's from automatically from prior durations.
- <TransitionSeries> (from @remotion/transitions): scenes that need visible transition effects (fade, slide, wipe, flip, clockWipe) or overlay effects (light leaks) at cut points.
Do NOT mix <Series> and <TransitionSeries> in the same hierarchy.
FATAL ERROR PREVENTION: Within a <TransitionSeries>, a <TransitionSeries.Overlay> MUST NEVER be adjacent to a <TransitionSeries.Transition>.
If you want to transition between Scene A and Scene B, choose EXACTLY ONE:
Option 1 (Effect): Sequence -> Transition -> Sequence
Option 2 (Overlay): Sequence -> Overlay -> Sequence
NEVER DO THIS: Sequence -> Transition -> Overlay -> Sequence. This will crash the app!
### Duration budgeting
When the brief specifies a total duration, scene durations MUST be budgeted to hit that total:
- No transitions: total = sum of all scene durations.
- <TransitionSeries.Transition>: total = sum of scene durations − sum of transition overlap durations. Transitions cause adjacent scenes to play simultaneously during the overlap window.
- <TransitionSeries.Overlay>: does NOT reduce the total duration.
Example: Scene A (60f) + fade transition (15f overlap) + Scene B (60f) = 105 frames, NOT 135.
If the brief says 30s at 30fps (900 frames) with three scenes and two 15-frame transitions, the scene durations must sum to 930, not 900.

### z-index hierarchy
Three-tier convention — do not scatter arbitrary mid-values (e.g., zIndex: 17, zIndex: 42):
- Background (base color, gradient, vignette, grain): zIndex: 0 or omit
- Foreground content (text, shapes, cards, hero elements): zIndex: 1–10
- Overlays (light leaks, flashes, wipe masks, grain): zIndex: 100+
Small offsets within a tier are fine (hero title at zIndex: 5, supporting caption at zIndex: 3).

## AVAILABLE IMPORTS

\`\`\`tsx
import { useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, interpolateColors, spring, Easing, Sequence, Series, Img, staticFile, AnimatedImage } from "remotion";
import { TransitionSeries, linearTiming, springTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { Circle, Rect, Triangle, Star, Ellipse, Pie } from "@remotion/shapes";
import { Video, Audio } from "@remotion/media";
import { useState, useEffect } from "react";
\`\`\`

## RESERVED NAMES (CRITICAL)

NEVER use these as variable names — they shadow imports:
- From remotion: useCurrentFrame, useVideoConfig, AbsoluteFill, interpolate, interpolateColors, spring, Easing, Sequence, Series, Img, staticFile, AnimatedImage
- From @remotion/transitions: TransitionSeries, linearTiming, springTiming, fade, slide
- From @remotion/shapes: Circle, Rect, Triangle, Star, Ellipse, Pie
- From @remotion/media: Video, Audio
- From react: useState, useEffect

## SUB-COMPONENTS & SCENES (CRITICAL)

If your animation requires multiple scenes or sub-components, you MUST define them inline in the SAME FILE.
Define all sub-components using \`const\` BEFORE the main \`export const MyAnimation\` component.
NEVER reference a component without defining it. NEVER import local components (like \`./Scene1\`).

## STYLING RULES

- Use inline styles only
- Keep colors cohesive and harmonious.

## OUTPUT FORMAT (CRITICAL)

- Output ONLY code - no explanations, no questions
- Response must start with "import" and end with "};"
- If prompt is ambiguous, make a reasonable choice - do not ask for clarification

`;

const FOLLOW_UP_SYSTEM_PROMPT = `
You are an expert at rewriting React/Remotion animation components.

Given the current code and a user request, you MUST provide the complete replacement code for the component.

## FULL REPLACEMENT RULE (type: "full")
- You must rewrite the entire component from start to finish.
- NEVER return partial edits.
- The return type MUST be "full".

## STRUCTURAL PRESERVATION & ROBUSTNESS
- Write new code in the most predictable and readable way possible.
- Avoid overcomplicating logic during edits. Maintain clean variable names and straightforward component structures to ensure self-healing predictability.

## PRESERVING USER EDITS
If the user has made manual edits, preserve them unless explicitly asked to change.
`;



interface ConversationContextMessage {
  role: "user" | "assistant";
  content: string;
  /** For user messages, attached images as base64 data URLs */
  attachedImages?: string[];
}

interface ErrorCorrectionContext {
  error: string;
  attemptNumber: number;
  maxAttempts: number;
}

interface GenerateRequest {
  prompt: string;
  model?: string;
  currentCode?: string;
  conversationHistory?: ConversationContextMessage[];
  isFollowUp?: boolean;
  hasManualEdits?: boolean;
  /** Error correction context for self-healing loops */
  errorCorrection?: ErrorCorrectionContext;
  /** Skills already used in this conversation (to avoid redundant skill content) */
  previouslyUsedSkills?: string[];
  /** Base64 image data URLs for visual context */
  frameImages?: string[];
}



export async function POST(req: Request) {
  const {
    prompt,
    model = "gpt-6-astra",
    currentCode,
    conversationHistory = [],
    isFollowUp = false,
    hasManualEdits = false,
    errorCorrection,
    previouslyUsedSkills = [],
    frameImages,
  }: GenerateRequest = await req.json();

  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    return new Response(
      JSON.stringify({
        error:
          'The environment variable "OPENAI_API_KEY" is not set. Add it to your .env file and try again.',
      }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  // Parse model ID - format can be "model-name"
  const modelName = model.split(":")[0];

  const openai = createOpenAI({ apiKey });

  // Validate the prompt first (skip for follow-ups with existing code)
  if (!isFollowUp) {
    try {
      const validationResult = await generateObject({
        model: openai(modelName),
        system: VALIDATION_PROMPT,
        prompt: `User prompt: "${prompt}"`,
        schema: z.object({ valid: z.boolean() }),
      });

      if (!validationResult.object.valid) {
        return new Response(
          JSON.stringify({
            error:
              "No valid motion graphics prompt. Please describe an animation or visual content you'd like to create.",
            type: "validation",
          }),
          { status: 400, headers: { "Content-Type": "application/json" } },
        );
      }
    } catch (validationError) {
      // On validation error, allow through rather than blocking
      console.error("Validation error:", validationError);
    }
  }

  // Detect which skills apply to this prompt
  let detectedSkills: SkillName[] = [];
  let durationInFrames: number | null = null;
  let width: number | null = null;
  let height: number | null = null;
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
    detectedSkills = skillResult.object.skills;
    durationInFrames = skillResult.object.durationInFrames ?? null;
    width = skillResult.object.width ?? null;
    height = skillResult.object.height ?? null;
    console.log("Detected skills:", detectedSkills, "duration:", durationInFrames, "width:", width, "height:", height);
  } catch (skillError) {
    console.error("Skill detection error:", skillError);
  }

  // Filter out skills that were already used in the conversation to avoid redundant context
  const newSkills = detectedSkills.filter(
    (skill) => !previouslyUsedSkills.includes(skill),
  );
  if (
    previouslyUsedSkills.length > 0 &&
    newSkills.length < detectedSkills.length
  ) {
    console.log(
      `Skipping ${detectedSkills.length - newSkills.length} previously used skills:`,
      detectedSkills.filter((s) => previouslyUsedSkills.includes(s)),
    );
  }

  // Load skill-specific content only for NEW skills (previously used skills are already in context)
  const skillContent = getCombinedSkillContent(newSkills as SkillName[]);
  const enhancedSystemPrompt = skillContent
    ? `${SYSTEM_PROMPT}\n\n## SKILL-SPECIFIC GUIDANCE\n${skillContent}`
    : SYSTEM_PROMPT;

  const finalSystemPrompt = isFollowUp
    ? `${enhancedSystemPrompt}\n\n${FOLLOW_UP_SYSTEM_PROMPT}`
    : enhancedSystemPrompt;

  try {
    let finalPromptText = prompt;

    if (isFollowUp && currentCode) {
      // Build context for the edit request
      const contextMessages = conversationHistory.slice(-6);
      let conversationContext = "";
      if (contextMessages.length > 0) {
        conversationContext =
          "\n\n## RECENT CONVERSATION:\n" +
          contextMessages
            .map((m) => {
              const imageNote =
                m.attachedImages && m.attachedImages.length > 0
                  ? ` [with ${m.attachedImages.length} attached image${m.attachedImages.length > 1 ? "s" : ""}]`
                  : "";
              return `${m.role.toUpperCase()}: ${m.content}${imageNote}`;
            })
            .join("\n");
      }

      const manualEditNotice = hasManualEdits
        ? "\n\nNOTE: The user has made manual edits to the code. Preserve these changes."
        : "";

      // Error correction context for self-healing
      let errorCorrectionNotice = "";
      if (errorCorrection) {
        errorCorrectionNotice = `\n\n## COMPILATION ERROR (ATTEMPT ${errorCorrection.attemptNumber}/${errorCorrection.maxAttempts})\nThe previous code failed to compile with this error:\n\`\`\`\n${errorCorrection.error}\n\`\`\`\n\nCRITICAL: Fix this compilation error by providing the full corrected code. Common issues include:\n- Syntax errors (missing brackets, semicolons)\n- Invalid JSX (unclosed tags, invalid attributes)\n- Undefined variables or imports\n- TypeScript type errors\n\nFocus ONLY on fixing the error. Do not make other changes.`;
      }

      finalPromptText = `## CURRENT CODE:\n\`\`\`tsx\n${currentCode}\n\`\`\`\n${conversationContext}${manualEditNotice}${errorCorrectionNotice}\n\n## USER REQUEST:\n${prompt}`;

      console.log(
        "Follow-up edit with prompt:",
        prompt,
        "model:",
        modelName,
        "skills:",
        detectedSkills.length > 0 ? detectedSkills.join(", ") : "general",
        frameImages && frameImages.length > 0
          ? `(with ${frameImages.length} image(s))`
          : "",
      );

      if (errorCorrection) {
        console.log("-> Triggered by Compilation Error:", errorCorrection.error);
      }
    } else {
      console.log(
        "Generating React component with prompt:",
        prompt,
        "model:",
        modelName,
        "skills:",
        detectedSkills.length > 0 ? detectedSkills.join(", ") : "general",
        frameImages && frameImages.length > 0 ? `(with ${frameImages.length} image(s))` : "",
      );
    }

    const hasImages = frameImages && frameImages.length > 0;
    if (hasImages) {
      finalPromptText += `\n\n(See the attached ${frameImages.length === 1 ? "image" : "images"} for visual reference)`;
    }

    const messageContent: Array<
      { type: "text"; text: string } | { type: "image"; image: string }
    > = [{ type: "text" as const, text: finalPromptText }];

    if (hasImages) {
      for (const img of frameImages) {
        messageContent.push({ type: "image" as const, image: img });
      }
    }

    const messages: Array<{
      role: "user";
      content: Array<
        { type: "text"; text: string } | { type: "image"; image: string }
      >;
    }> = [
      {
        role: "user" as const,
        content: messageContent,
      },
    ];

    const result = streamText({
      model: openai(modelName),
      system: finalSystemPrompt,
      messages: messages,
      // @ts-expect-error - maxTokens is not in the type definition but is supported
      maxTokens: 22500,
    });

    // Get the original stream response
    const originalResponse = result.toUIMessageStreamResponse({
      sendReasoning: true,
    });

    // Create metadata event to prepend
    const metadataEvent = `data: ${JSON.stringify({
      type: "metadata",
      skills: detectedSkills,
      durationInFrames,
      width,
      height,
    })}\n\n`;

    // Create a new stream that prepends metadata before the LLM stream
    const originalBody = originalResponse.body;
    if (!originalBody) {
      return originalResponse;
    }

    const reader = originalBody.getReader();
    const encoder = new TextEncoder();

    const stream = new ReadableStream({
      async start(controller) {
        // Send metadata event first
        controller.enqueue(encoder.encode(metadataEvent));

        // Then pipe through the original stream
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          controller.enqueue(value);
        }
        controller.close();
      },
    });

    return new Response(stream, {
      headers: originalResponse.headers,
    });
  } catch (error) {
    console.error("Error generating code:", error);
    return new Response(
      JSON.stringify({
        error: "Something went wrong while trying to reach OpenAI APIs.",
      }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
}
