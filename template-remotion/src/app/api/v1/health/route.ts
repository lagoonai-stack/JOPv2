import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    type: 'success',
    data: {
      status: 'healthy',
      service: 'template-remotion',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
    },
  });
}

export async function POST() {
  return GET();
}