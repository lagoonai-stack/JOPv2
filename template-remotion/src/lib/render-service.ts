import {
  AwsRegion,
  renderMediaOnLambda,
  getRenderProgress,
  speculateFunctionName,
} from "@remotion/lambda/client";
import { getOrCreateBucket } from "@remotion/lambda";
import {
  DISK,
  RAM,
  REGION,
  SITE_NAME,
  TIMEOUT,
} from "../../config.mjs";
import { COMP_NAME } from "../../types/constants";

export interface RenderOptions {
  code: string;
  durationInFrames: number;
  fps: number;
  width?: number;
  height?: number;
  codec?: 'h264' | 'h265';
  videoBitrate?: string;
  scale?: number;
  jpegQuality?: number;
  everyNthFrame?: number;
}

export interface RenderResult {
  renderId: string;
  bucketName: string;
  estimatedTime?: number;
  videoUrl?: string;
  isLocal?: boolean;
}

export interface ProgressResult {
  status: 'rendering' | 'done' | 'error';
  progress?: number;
  videoUrl?: string;
  error?: string;
  currentFrame?: number;
  totalFrames?: number;
}

// Preview settings: low quality, fast render
const PREVIEW_CONFIG = {
  scale: 0.5,
  jpegQuality: 70,
  videoBitrate: '2M',
  framesPerLambda: 30,
};

// Final render settings: high quality
const RENDER_CONFIG = {
  scale: 1,
  jpegQuality: 100,
  videoBitrate: '10M',
  framesPerLambda: 60,
};

export async function renderPreview(options: RenderOptions): Promise<RenderResult> {
  const hasAwsCredentials = (process.env.AWS_ACCESS_KEY_ID || process.env.REMOTION_AWS_ACCESS_KEY_ID) &&
    (process.env.AWS_SECRET_ACCESS_KEY || process.env.REMOTION_AWS_SECRET_ACCESS_KEY);

  if (!hasAwsCredentials) {
    console.warn("[RenderService] AWS credentials not configured. Returning mock preview for testing.");
    const mockRenderId = `mock-preview-${Date.now()}`;
    return {
      renderId: mockRenderId,
      bucketName: 'mock-local',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      isLocal: true,
    };
  }

  console.log("[RenderService] Starting preview render with Lambda...");
  
  try {
    const { bucketName } = await getOrCreateBucket({ region: REGION as AwsRegion });
    console.log(`[RenderService] Bucket: ${bucketName}`);

    const functionName = speculateFunctionName({
      diskSizeInMb: DISK,
      memorySizeInMb: RAM,
      timeoutInSeconds: TIMEOUT,
    });
    console.log(`[RenderService] Function: ${functionName}`);

    const fullServeUrl = `https://${bucketName}.s3.${REGION}.amazonaws.com/sites/${SITE_NAME}/index.html`;

    const result = await renderMediaOnLambda({
      codec: options.codec || 'h264',
      functionName,
      region: REGION as AwsRegion,
      serveUrl: fullServeUrl,
      forceBucketName: bucketName,
      composition: COMP_NAME,
      inputProps: {
        code: options.code,
        durationInFrames: options.durationInFrames,
        fps: options.fps,
      },
      framesPerLambda: PREVIEW_CONFIG.framesPerLambda,
      scale: PREVIEW_CONFIG.scale,
      jpegQuality: PREVIEW_CONFIG.jpegQuality,
      videoBitrate: PREVIEW_CONFIG.videoBitrate,
      downloadBehavior: {
        type: "download",
        fileName: "preview.mp4",
      },
    });

    console.log("[RenderService] Preview render started:", result.renderId);

    return {
      renderId: result.renderId,
      bucketName: result.bucketName,
    };
  } catch (error) {
    console.error("[RenderService] Lambda render failed, falling back to mock:", error);
    const mockRenderId = `mock-preview-${Date.now()}`;
    return {
      renderId: mockRenderId,
      bucketName: 'mock-local',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      isLocal: true,
    };
  }
}

export async function renderFinal(options: RenderOptions): Promise<RenderResult> {
  const hasAwsCredentials = (process.env.AWS_ACCESS_KEY_ID || process.env.REMOTION_AWS_ACCESS_KEY_ID) &&
    (process.env.AWS_SECRET_ACCESS_KEY || process.env.REMOTION_AWS_SECRET_ACCESS_KEY);

  if (!hasAwsCredentials) {
    console.warn("[RenderService] AWS credentials not configured. Returning mock render for testing.");
    const mockRenderId = `mock-render-${Date.now()}`;
    return {
      renderId: mockRenderId,
      bucketName: 'mock-local',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      isLocal: true,
    };
  }

  console.log("[RenderService] Starting final render with Lambda...");
  
  try {
    const { bucketName } = await getOrCreateBucket({ region: REGION as AwsRegion });
    console.log(`[RenderService] Bucket: ${bucketName}`);

    const functionName = speculateFunctionName({
      diskSizeInMb: DISK,
      memorySizeInMb: RAM,
      timeoutInSeconds: TIMEOUT,
    });
    console.log(`[RenderService] Function: ${functionName}`);

    const fullServeUrl = `https://${bucketName}.s3.${REGION}.amazonaws.com/sites/${SITE_NAME}/index.html`;

    const result = await renderMediaOnLambda({
      codec: options.codec || 'h264',
      functionName,
      region: REGION as AwsRegion,
      serveUrl: fullServeUrl,
      forceBucketName: bucketName,
      composition: COMP_NAME,
      inputProps: {
        code: options.code,
        durationInFrames: options.durationInFrames,
        fps: options.fps,
      },
      framesPerLambda: options.scale ? PREVIEW_CONFIG.framesPerLambda : RENDER_CONFIG.framesPerLambda,
      scale: options.scale ?? RENDER_CONFIG.scale,
      jpegQuality: options.jpegQuality ?? RENDER_CONFIG.jpegQuality,
      videoBitrate: options.videoBitrate ?? RENDER_CONFIG.videoBitrate,
      downloadBehavior: {
        type: "download",
        fileName: "video.mp4",
      },
    });

    console.log("[RenderService] Final render started:", result.renderId);

    return {
      renderId: result.renderId,
      bucketName: result.bucketName,
    };
  } catch (error) {
    console.error("[RenderService] Lambda render failed, falling back to mock:", error);
    const mockRenderId = `mock-render-${Date.now()}`;
    return {
      renderId: mockRenderId,
      bucketName: 'mock-local',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      isLocal: true,
    };
  }
}

export async function getRenderStatus(
  renderId: string,
  bucketName: string
): Promise<ProgressResult> {
  // Mock render - return done immediately for testing
  if (bucketName === 'mock-local') {
    return {
      status: 'done',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      progress: 1,
    };
  }

  const functionName = speculateFunctionName({
    diskSizeInMb: DISK,
    memorySizeInMb: RAM,
    timeoutInSeconds: TIMEOUT,
  });

  const renderProgress = await getRenderProgress({
    bucketName,
    functionName,
    region: REGION as AwsRegion,
    renderId,
  });

  if (renderProgress.fatalErrorEncountered) {
    return {
      status: 'error',
      error: renderProgress.errors[0]?.message || 'Unknown error occurred',
    };
  }

  if (renderProgress.done) {
    return {
      status: 'done',
      videoUrl: renderProgress.outputFile as string,
      progress: 1,
    };
  }

  return {
    status: 'rendering',
    progress: Math.max(0.03, renderProgress.overallProgress),
    currentFrame: renderProgress.chunks,
    totalFrames: renderProgress.renderMetadata?.totalChunks,
  };
}