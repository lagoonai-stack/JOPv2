import { createHmac } from 'crypto';

const SHARED_SECRET = process.env.JOP_SHARED_SECRET;

export function validateSignature(body: string, receivedSignature: string): boolean {
  if (!SHARED_SECRET) {
    throw new Error('JOP_SHARED_SECRET not configured');
  }

  const expectedSignature = createHmac('sha256', SHARED_SECRET)
    .update(body)
    .digest('hex');

  return receivedSignature === expectedSignature;
}

export function requireAuth(req: Request): { valid: boolean; error?: string } {
  const signature = req.headers.get('X-JOP-Signature');

  if (!signature) {
    return { valid: false, error: 'Missing authentication signature' };
  }

  if (!SHARED_SECRET) {
    return { valid: false, error: 'Service not configured' };
  }

  return { valid: true };
}

export async function validateRequest(req: Request): Promise<{ valid: boolean; body?: unknown; error?: string }> {
  const authCheck = requireAuth(req);
  if (!authCheck.valid) {
    return authCheck;
  }

  try {
    const bodyText = await req.text();
    const signature = req.headers.get('X-JOP-Signature')!;

    if (!validateSignature(bodyText, signature)) {
      return { valid: false, error: 'Invalid signature' };
    }

    // Parse body if it exists
    const body = bodyText ? JSON.parse(bodyText) : {};
    
    return { valid: true, body };
  } catch {
    return { valid: false, error: 'Invalid request format' };
  }
}