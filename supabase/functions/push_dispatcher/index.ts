// Supabase Edge Function: push_dispatcher
//
// Turns every in-app `notifications` row into a remote FCM push. Wire it as a
// Database Webhook: Supabase Studio → Database → Webhooks → "AFTER INSERT on
// public.notifications" → HTTP POST to this function, with header
//   x-webhook-secret: <PUSH_WEBHOOK_SECRET>
//
// Because it hangs off the `notifications` table, ALL notification sources
// (tutor-applied, new-job matches, admin broadcasts, system messages, …)
// become push notifications with no extra per-source wiring.
//
// Secrets (supabase secrets set ...):
//   PUSH_WEBHOOK_SECRET   shared secret echoed by the webhook header
//   FCM_PROJECT_ID        Firebase project id
//   FCM_CLIENT_EMAIL      service-account client_email
//   FCM_PRIVATE_KEY       service-account private_key (PEM, with \n newlines)
//   SUPABASE_URL          (provided by the platform)
//   SUPABASE_SERVICE_ROLE_KEY (provided by the platform)

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

interface NotificationRow {
  id: string;
  user_id: string;
  kind: string;
  title: string;
  body: string | null;
  ref_type: string | null;
  ref_id: string | null;
}

const FCM_SCOPE = 'https://www.googleapis.com/auth/firebase.messaging';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
);

Deno.serve(async (req) => {
  // Only the database webhook (which knows the shared secret) may call this.
  if (req.headers.get('x-webhook-secret') !== Deno.env.get('PUSH_WEBHOOK_SECRET')) {
    return new Response('forbidden', { status: 401 });
  }

  let payload: { record?: NotificationRow };
  try {
    payload = await req.json();
  } catch {
    return new Response('bad request', { status: 400 });
  }
  const row = payload.record;
  if (!row?.user_id) return json({ skipped: 'no_record' });

  // 1. Type still enabled?
  const { data: enabled } = await supabase.rpc('notif_kind_enabled', { p_kind: row.kind });
  if (enabled === false) return json({ skipped: 'kind_disabled' });

  // 2. Recipient has a device token, plus their quiet-hours window.
  const { data: profile } = await supabase
    .from('profiles')
    .select('push_token, quiet_hours_start, quiet_hours_end')
    .eq('id', row.user_id)
    .maybeSingle();
  const token = profile?.push_token as string | null | undefined;
  if (!token) return json({ skipped: 'no_token' });
  if (inQuietHours(profile?.quiet_hours_start, profile?.quiet_hours_end)) {
    return json({ skipped: 'quiet_hours' });
  }

  // 3. Per-user hourly cap (platform_settings.notif_hourly_cap, default 20).
  const cap = await hourlyCap();
  const since = new Date(Date.now() - 60 * 60 * 1000).toISOString();
  const { count } = await supabase
    .from('notifications')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', row.user_id)
    .gte('created_at', since);
  if ((count ?? 0) > cap) return json({ skipped: 'rate_capped' });

  // 4. Send.
  try {
    const accessToken = await getAccessToken();
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${Deno.env.get('FCM_PROJECT_ID')}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title: row.title, body: row.body ?? '' },
            // The app's push_deep_link.dart turns these into an in-app route.
            data: {
              ref_type: row.ref_type ?? '',
              ref_id: row.ref_id ?? '',
              kind: row.kind,
            },
            android: { priority: 'high' },
          },
        }),
      },
    );
    if (!res.ok) {
      const detail = await res.text();
      console.error('[push_dispatcher] FCM error', res.status, detail);
      return json({ sent: false, status: res.status }, 502);
    }
    return json({ sent: true });
  } catch (err) {
    console.error('[push_dispatcher] failed', err);
    return json({ sent: false }, 500);
  }
});

function json(obj: unknown, status = 200): Response {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

async function hourlyCap(): Promise<number> {
  const { data } = await supabase
    .from('platform_settings')
    .select('value')
    .eq('key', 'notif_hourly_cap')
    .maybeSingle();
  const n = Number(data?.value);
  return Number.isFinite(n) && n > 0 ? n : 20;
}

/** "HH:MM[:SS]" times; window may wrap past midnight. Compared in UTC — set
 *  quiet hours relative to the user's expected device clock. */
function inQuietHours(start?: string | null, end?: string | null): boolean {
  if (!start || !end) return false;
  const now = new Date();
  const mins = now.getUTCHours() * 60 + now.getUTCMinutes();
  const s = toMinutes(start);
  const e = toMinutes(end);
  if (s === e) return false;
  return s < e ? mins >= s && mins < e : mins >= s || mins < e;
}

function toMinutes(t: string): number {
  const [h, m] = t.split(':');
  return Number(h) * 60 + Number(m);
}

// ── OAuth2 access token from the service account (RS256 JWT, cached) ────────
let cachedToken: { token: string; expiresAt: number } | null = null;

async function getAccessToken(): Promise<string> {
  if (cachedToken && cachedToken.expiresAt > Date.now() + 60_000) {
    return cachedToken.token;
  }
  const clientEmail = Deno.env.get('FCM_CLIENT_EMAIL')!;
  const privateKeyPem = Deno.env.get('FCM_PRIVATE_KEY')!.replace(/\\n/g, '\n');
  const now = Math.floor(Date.now() / 1000);
  const claim = {
    iss: clientEmail,
    scope: FCM_SCOPE,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };
  const header = { alg: 'RS256', typ: 'JWT' };
  const unsigned = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(claim))}`;
  const key = await importPrivateKey(privateKeyPem);
  const sig = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${b64urlBytes(new Uint8Array(sig))}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });
  if (!res.ok) throw new Error(`token exchange failed: ${res.status} ${await res.text()}`);
  const data = await res.json();
  cachedToken = {
    token: data.access_token,
    expiresAt: Date.now() + (data.expires_in ?? 3600) * 1000,
  };
  return cachedToken.token;
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const body = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const der = Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

function b64url(s: string): string {
  return b64urlBytes(new TextEncoder().encode(s));
}

function b64urlBytes(bytes: Uint8Array): string {
  let bin = '';
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}
