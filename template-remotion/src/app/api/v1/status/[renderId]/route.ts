import { NextResponse } from 'next/server';
import { requireAuth } from '@/helpers/auth';
import { getRenderJobStatus } from '@/lib/local-render-service';

export async function GET(
  req: Request,
  { params }: { params: Promise<{ renderId: string }> }
) {
  try {
    const authCheck = requireAuth(req);
    if (!authCheck.valid) {
      return NextResponse.json(
        { type: 'error', message: authCheck.error },
        { status: 401 }
      );
    }

    const { renderId } = await params;

    console.log(`[Status API] Checking status for ${renderId}...`);
    const jobStatus = getRenderJobStatus(renderId);

    if (jobStatus.status === 'error') {
      return NextResponse.json({
        type: 'error',
        data: {
          renderId,
          status: 'error',
          error: jobStatus.error || 'Render failed',
        },
      });
    }

    if (jobStatus.status === 'done') {
      return NextResponse.json({
        type: 'done',
        data: {
          renderId,
          status: 'done',
          videoUrl: jobStatus.videoUrl,
          progress: 1,
        },
      });
    }

    return NextResponse.json({
      type: 'progress',
      data: {
        renderId,
        status: 'rendering',
        progress: 0.5,
      },
    });
  } catch (error) {
    console.error('[Status API] Error:', error);
    return NextResponse.json(
      { type: 'error', message: error instanceof Error ? error.message : 'Failed to get status' },
      { status: 500 }
    );
  }
}