import fs from "fs/promises";
import { nanoid } from "nanoid";
import path from "path";
import type { GeneratedComponent } from "@/lib/code-generator";

/**
 * Persists generated code as a playable preview and builds the response both
 * Rails-facing routes return (/api/v1/preview and /api/v1/edit), so an edited
 * preview is stored and described exactly like a fresh one.
 *
 * public/tmp/{token}.tsx is the code the embed page compiles;
 * public/tmp/{token}.json carries the composition settings for its Player.
 */
export async function savePreview(generated: GeneratedComponent, logTag: string) {
  const previewToken = nanoid();
  const tmpDir = path.join(process.cwd(), "public", "tmp");
  await fs.mkdir(tmpDir, { recursive: true });

  const componentPath = path.join(tmpDir, `${previewToken}.tsx`);
  await fs.writeFile(componentPath, generated.code, "utf-8");

  const metadata = {
    width: generated.width,
    height: generated.height,
    durationInFrames: generated.durationInFrames,
    fps: generated.fps,
    detectedSkills: generated.detectedSkills,
  };
  await fs.writeFile(path.join(tmpDir, `${previewToken}.json`), JSON.stringify(metadata, null, 2), "utf-8");

  const previewUrl = `/embed/${previewToken}`;

  console.log(`[${logTag}] Preview saved:`, {
    previewToken,
    componentPath,
    codeLength: generated.code.length,
    attempts: generated.attempts,
    problems: generated.problems.map((p) => p.rule),
  });

  return {
    type: "success" as const,
    data: {
      previewToken,
      previewUrl,
      componentCode: generated.code,
      metadata: {
        ...metadata,
        attempts: generated.attempts,
        problems: generated.problems,
      },
    },
  };
}
