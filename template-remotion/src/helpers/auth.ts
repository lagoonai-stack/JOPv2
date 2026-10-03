import { createHmac, timingSafeEqual } from 'crypto';

const SHARED_SECRET = process.env.JOP_SHARED_SECRET;

export function validateSignature(body: string, receivedSignature: string): boolean {
  if (!SHARED_SECRET) {
    throw new Error('JOP_SHARED_SECRET not configured');
  }

  const expectedSignature = createHmac('sha256', SHARED_SECRET)
    .update(body)
    .digest('hex');

  const encoder = new TextEncoder();
  const received = encoder.encode(receivedSignature);
  const expected = encoder.encode(expectedSignature);

  if (received.length !== expected.length) {
    return false;
  }

  return timingSafeEqual(received, expected);
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

/**
 * Full authentication for requests that carry no body (GET).
 *
 * requireAuth() only checks that the header is present — it is the first half
 * of validateRequest(), which then verifies the signature over the body. A GET
 * route calling requireAuth() alone accepts any value in X-JOP-Signature, so
 * bodyless routes must use this instead. Rails signs the empty string for GET
 * (RemotionService#get_with_hmac), so that is what we verify against.
 */
export function validateSignedGet(req: Request): { valid: boolean; error?: string } {
  const presence = requireAuth(req);
  if (!presence.valid) {
    return presence;
  }

  const signature = req.headers.get('X-JOP-Signature')!;

  try {
    if (!validateSignature('', signature)) {
      return { valid: false, error: 'Invalid signature' };
    }
  } catch {
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