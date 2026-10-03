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
  buildFollowUpUserPrompt,
  VALIDATION_PROMPT,
} from "@/lib/prompts";



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

      finalPromptText = buildFollowUpUserPrompt(
        currentCode,
        prompt,
        `${conversationContext}${manualEditNotice}${errorCorrectionNotice}`,
      );

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
