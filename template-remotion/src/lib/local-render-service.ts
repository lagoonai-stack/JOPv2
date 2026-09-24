import { bundle } from "@remotion/bundler";
import { renderMedia, selectComposition } from "@remotion/renderer";
import path from "path";
import fs from "fs/promises";
import { nanoid } from "nanoid";

export interface LocalRenderOptions {
  code: string;
  durationInFrames: number;
  fps: number;
  width?: number;
  height?: number;
  codec?: "h264" | "h265";
  videoBitrate?: string;
  scale?: number;
  jpegQuality?: number;
}

export interface LocalRenderResult {
  renderId: string;
  videoPath: string;
  videoUrl: string;
}

// Preview settings: low quality, fast render
const PREVIEW_CONFIG = {
  scale: 0.5,
  jpegQuality: 70,
  videoBitrate: "2M",
};

// Final render settings: high quality
const RENDER_CONFIG = {
  scale: 1,
  jpegQuality: 90,
  videoBitrate: "10M",
};

export async function renderPreviewLocally(
  options: LocalRenderOptions
): Promise<LocalRenderResult> {
  console.log("[LocalRenderService] Starting preview render...");

  const renderId = `preview-${nanoid()}`;
  const publicDir = path.join(process.cwd(), "public", "renders");
  const outputPath = path.join(publicDir, `${renderId}.mp4`);

  // Ensure output directory exists
  await fs.mkdir(publicDir, { recursive: true });

  try {
    // Bundle the Remotion project
    console.log("[LocalRenderService] Bundling...");
    const bundleLocation = await bundle({
      entryPoint: path.join(process.cwd(), "src", "remotion", "index.ts"),
      webpackOverride: (config) => {
        // Add path alias resolution for @/
        config.resolve = {
          ...config.resolve,
          alias: {
            ...config.resolve?.alias,
            '@': path.join(process.cwd(), 'src'),
          },
        };
        return config;
      },
    });

    // Get composition
    console.log("[LocalRenderService] Selecting composition...");
    const composition = await selectComposition({
      serveUrl: bundleLocation,
      id: "DynamicComp",
      inputProps: {
        code: options.code,
        durationInFrames: options.durationInFrames,
        fps: options.fps,
        width: options.width || 1920,
        height: options.height || 1080,
      },
    });

    // Render the video locally
    console.log("[LocalRenderService] Rendering video...");
    await renderMedia({
      composition,
      serveUrl: bundleLocation,
      codec: "h264",
      outputLocation: outputPath,
      inputProps: {
        code: options.code,
        durationInFrames: options.durationInFrames,
        fps: options.fps,
        width: options.width || 1920,
        height: options.height || 1080,
      },
      scale: options.scale ?? PREVIEW_CONFIG.scale,
      imageFormat: "jpeg",
      jpegQuality: options.jpegQuality ?? PREVIEW_CONFIG.jpegQuality,
      videoBitrate: options.videoBitrate ?? PREVIEW_CONFIG.videoBitrate,
    });

    console.log("[LocalRenderService] Preview render complete:", outputPath);

    return {
      renderId,
      videoPath: outputPath,
      videoUrl: `/renders/${renderId}.mp4`,
    };
  } catch (error) {
    console.error("[LocalRenderService] Preview render failed:", error);
    throw error;
  }
}

export async function renderFinalLocally(
  options: LocalRenderOptions
): Promise<LocalRenderResult> {
  console.log("[LocalRenderService] Starting final render...");

  const renderId = `final-${nanoid()}`;
  const publicDir = path.join(process.cwd(), "public", "renders");
  const outputPath = path.join(publicDir, `${renderId}.mp4`);

  // Ensure output directory exists
  await fs.mkdir(publicDir, { recursive: true });

  try {
    // Bundle the Remotion project
    console.log("[LocalRenderService] Bundling...");
    const bundleLocation = await bundle({
      entryPoint: path.join(process.cwd(), "src", "remotion", "index.ts"),
      webpackOverride: (config) => {
        // Add path alias resolution for @/
        config.resolve = {
          ...config.resolve,
          alias: {
            ...config.resolve?.alias,
            '@': path.join(process.cwd(), 'src'),
          },
        };
        return config;
      },
    });

    // Get composition
    console.log("[LocalRenderService] Selecting composition...");
    const composition = await selectComposition({
      serveUrl: bundleLocation,
      id: "DynamicComp",
      inputProps: {
        code: options.code,
        durationInFrames: options.durationInFrames,
        fps: options.fps,
        width: options.width || 1920,
        height: options.height || 1080,
      },
    });

    // Render the video locally
    console.log("[LocalRenderService] Rendering video...");
    await renderMedia({
      composition,
      serveUrl: bundleLocation,
      codec: options.codec || "h264",
      outputLocation: outputPath,
      inputProps: {
        code: options.code,
        durationInFrames: options.durationInFrames,
        fps: options.fps,
        width: options.width || 1920,
        height: options.height || 1080,
      },
      scale: options.scale ?? RENDER_CONFIG.scale,
      imageFormat: "jpeg",
      jpegQuality: options.jpegQuality ?? RENDER_CONFIG.jpegQuality,
      videoBitrate: options.videoBitrate ?? RENDER_CONFIG.videoBitrate,
    });

    console.log("[LocalRenderService] Final render complete:", outputPath);

    return {
      renderId,
      videoPath: outputPath,
      videoUrl: `/renders/${renderId}.mp4`,
    };
  } catch (error) {
    console.error("[LocalRenderService] Final render failed:", error);
    throw error;
  }
}

// Track render jobs in memory (for status checks)
const renderJobs = new Map<
  string,
  {
    status: "rendering" | "done" | "error";
    videoUrl?: string;
    error?: string;
  }
>();

export function setRenderJobStatus(
  renderId: string,
  status: "rendering" | "done" | "error",
  data?: { videoUrl?: string; error?: string }
) {
  renderJobs.set(renderId, { status, ...data });
}

export function getRenderJobStatus(renderId: string) {
  return renderJobs.get(renderId) || { status: "rendering" };
}