import { NextResponse } from 'next/server';
import { validateRequest } from '@/helpers/auth';
import { generateComponentCode } from '@/lib/code-generator';
import { parseVideoSpec, specToGenerationOptions } from '@/lib/video-spec';
import { renderMotionPlan } from '@/lib/motion-plan';
import { savePreview } from '@/lib/preview-store';
import { z } from 'zod';

const PreviewRequestSchema = z.object({
  prompt: z.string(),
  options: z.object({
    width: z.number().optional(),
    height: z.number().optional(),
    durationInFrames: z.number().optional(),
    fps: z.number().optional(),
    model: z.string().optional(),
  }).optional(),
  // The approved spec, when the conversation produced one. Validated below
  // rather than here so a malformed spec answers with readable problems.
  spec: z.unknown().optional(),
  metadata: z.any().optional(),
});

export async function POST(req: Request) {
  try {
    const validation = await validateRequest(req);
    if (!validation.valid) {
      return NextResponse.json(
        { type: 'error', message: validation.error },
        { status: 401 }
      );
    }

    const parsed = PreviewRequestSchema.parse(validation.body);
    const { prompt, options = {} } = parsed;

    // When a spec came along it is the authority on the composition settings:
    // it carries what the user actually approved in the chat. A spec that does
    // not validate is refused rather than quietly ignored — falling back to
    // defaults here is exactly how an agreed vertical video came out 1920x1080.
    let specOptions: ReturnType<typeof specToGenerationOptions> | null = null;
    let motionPlan: string | null = null;
    if (parsed.spec !== undefined && parsed.spec !== null) {
      const { spec, errors } = parseVideoSpec(parsed.spec);

      if (!spec || errors.length > 0) {
        console.error('[Preview API] Invalid spec:', errors);
        return NextResponse.json(
          { type: 'error', message: 'Invalid video spec', details: errors },
          { status: 422 }
        );
      }

      specOptions = specToGenerationOptions(spec);
      motionPlan = renderMotionPlan(spec);
      console.log('[Preview API] Spec accepted:', {
        format: spec.format,
        mode: spec.mode,
        moments: spec.moments.length,
        ...specOptions,
      });
    }

    console.log('[Preview API] Generating component code...');
    // The briefing prose stays the creative brief; the plan pins down what the
    // spec already decided (frames, connections, accents, textures).
    const generationPrompt = motionPlan ? `${prompt}\n\n${motionPlan}` : prompt;
    const generated = await generateComponentCode(generationPrompt, {
      model: options.model,
      durationInFrames: specOptions?.durationInFrames ?? options.durationInFrames,
      width: specOptions?.width ?? options.width,
      height: specOptions?.height ?? options.height,
      fps: specOptions?.fps ?? options.fps,
    });

    console.log('[Preview API] Code generation complete');
    return NextResponse.json(await savePreview(generated, 'Preview API'));
  } catch (error) {
    console.error('[Preview API] Error:', error);
    return NextResponse.json(
      { type: 'error', message: error instanceof Error ? error.message : 'Failed to generate preview' },
      { status: 500 }
    );
  }
}