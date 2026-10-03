import { NextResponse } from 'next/server';
import { validateRequest } from '@/helpers/auth';
import { editComponentCode } from '@/lib/code-generator';
import { savePreview } from '@/lib/preview-store';
import { z } from 'zod';

/**
 * POST /api/v1/edit — conversational adjustment of an existing preview.
 *
 * Called by Rails (VideoController#request_edit) with the conversation's
 * current component code and the user's instruction. Answers in the same
 * shape as /api/v1/preview: a new preview token for the adjusted code.
 * Composition settings are passed through as-is — an edit never changes the
 * size, fps or length the user approved.
 */
const EditRequestSchema = z.object({
  componentCode: z.string().min(1),
  instruction: z.string().trim().min(1).max(2000),
  previousInstructions: z.array(z.string()).max(50).optional(),
  skills: z.array(z.string()).optional(),
  options: z
    .object({
      width: z.number().optional(),
      height: z.number().optional(),
      durationInFrames: z.number().optional(),
      fps: z.number().optional(),
      model: z.string().optional(),
    })
    .optional(),
  metadata: z.any().optional(),
});

export async function POST(req: Request) {
  try {
    const validation = await validateRequest(req);
    if (!validation.valid) {
      return NextResponse.json({ type: 'error', message: validation.error }, { status: 401 });
    }

    const parsed = EditRequestSchema.safeParse(validation.body);
    if (!parsed.success) {
      return NextResponse.json(
        { type: 'error', message: 'Invalid edit request', details: parsed.error.issues.map((i) => `${i.path.join('.')}: ${i.message}`) },
        { status: 422 }
      );
    }

    const { componentCode, instruction, previousInstructions = [], skills = [], options = {} } = parsed.data;
    console.log('[Edit API] Applying adjustment:', instruction, `(after ${previousInstructions.length} previous)`);

    const generated = await editComponentCode(componentCode, instruction, {
      ...options,
      skills,
      previousInstructions,
    });

    return NextResponse.json(await savePreview(generated, 'Edit API'));
  } catch (error) {
    console.error('[Edit API] Error:', error);
    return NextResponse.json(
      { type: 'error', message: error instanceof Error ? error.message : 'Failed to edit preview' },
      { status: 500 }
    );
  }
}
