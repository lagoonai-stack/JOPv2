import { NextResponse } from 'next/server';
import { validateRequest } from '@/helpers/auth';
import { renderFinalLocally, setRenderJobStatus } from '@/lib/local-render-service';
import { z } from 'zod';

const RenderRequestSchema = z.object({
  componentCode: z.string(),
  options: z.object({
    width: z.number().optional(),
    height: z.number().optional(),
    durationInFrames: z.number(),
    fps: z.number(),
    codec: z.enum(['h264', 'h265']).optional(),
    videoBitrate: z.string().optional(),
  }),
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

    const parsed = RenderRequestSchema.parse(validation.body);
    const { componentCode, options } = parsed;

    console.log('[Render API] Starting final render locally...');
    
    // Render locally
    const render = await renderFinalLocally({
      code: componentCode,
      durationInFrames: options.durationInFrames,
      fps: options.fps,
      width: options.width,
      height: options.height,
      codec: options.codec,
      videoBitrate: options.videoBitrate,
    });

    // Mark as done
    setRenderJobStatus(render.renderId, 'done', { videoUrl: render.videoUrl });

    console.log('[Render API] Final render complete:', {
      renderId: render.renderId,
      videoUrl: render.videoUrl,
    });

    return NextResponse.json({
      type: 'success',
      data: {
        renderId: render.renderId,
        bucketName: 'local',
        status: 'done',
        videoUrl: render.videoUrl,
      },
    });
  } catch (error) {
    console.error('[Render API] Error:', error);
    return NextResponse.json(
      { type: 'error', message: error instanceof Error ? error.message : 'Failed to start render' },
      { status: 500 }
    );
  }
}