import { NextResponse } from 'next/server';
import { validateRequest } from '@/helpers/auth';
import { generateComponentCode } from '@/lib/code-generator';
import { nanoid } from 'nanoid';
import { z } from 'zod';
import fs from 'fs/promises';
import path from 'path';

const PreviewRequestSchema = z.object({
  prompt: z.string(),
  options: z.object({
    width: z.number().optional(),
    height: z.number().optional(),
    durationInFrames: z.number().optional(),
    fps: z.number().optional(),
    model: z.string().optional(),
  }).optional(),
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

    console.log('[Preview API] Generating component code...');
    const generated = await generateComponentCode(prompt, {
      model: options.model,
      durationInFrames: options.durationInFrames,
      width: options.width,
      height: options.height,
      fps: options.fps,
    });

    console.log('[Preview API] Code generation complete');
    
    // Generate a preview token for the component file
    const previewToken = nanoid();
    
    // Save component code to tmp directory
    const tmpDir = path.join(process.cwd(), 'public', 'tmp');
    await fs.mkdir(tmpDir, { recursive: true });
    
    const componentPath = path.join(tmpDir, `${previewToken}.tsx`);
    await fs.writeFile(componentPath, generated.code, 'utf-8');
    
    // Save metadata JSON file for embed page
    const metadataPath = path.join(tmpDir, `${previewToken}.json`);
    const metadata = {
      width: generated.width,
      height: generated.height,
      durationInFrames: generated.durationInFrames,
      fps: generated.fps,
      detectedSkills: generated.detectedSkills,
    };
    await fs.writeFile(metadataPath, JSON.stringify(metadata, null, 2), 'utf-8');
    
    const previewUrl = `/embed/${previewToken}`;

    console.log('[Preview API] Preview saved:', {
      previewToken,
      componentPath,
      codeLength: generated.code.length,
    });

    return NextResponse.json({
      type: 'success',
      data: {
        previewToken,
        previewUrl,
        componentCode: generated.code,
        metadata: {
          detectedSkills: generated.detectedSkills,
          width: generated.width,
          height: generated.height,
          durationInFrames: generated.durationInFrames,
          fps: generated.fps,
        },
      },
    });
  } catch (error) {
    console.error('[Preview API] Error:', error);
    return NextResponse.json(
      { type: 'error', message: error instanceof Error ? error.message : 'Failed to generate preview' },
      { status: 500 }
    );
  }
}