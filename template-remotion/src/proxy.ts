import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const PROTECTED_API_PATHS = ['/api/v1'];

export default function proxy(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  
  // Skip auth for non-protected routes
  const isProtected = PROTECTED_API_PATHS.some(path => pathname.startsWith(path));
  if (!isProtected) {
    return NextResponse.next();
  }

  // Get signature from header
  const signature = request.headers.get('X-JOP-Signature');
  
  if (!signature) {
    return NextResponse.json(
      { type: 'error', message: 'Missing authentication signature' },
      { status: 401 }
    );
  }

  // Signature validation happens in route handlers
  // because we need access to the request body and Node.js crypto
  
  return NextResponse.next();
}

export const config = {
  matcher: '/api/:path*',
};