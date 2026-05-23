# Payment integration — eSewa / Khalti / IME Pay

Phase 11 shipped the **durable layer** for coin top-ups: `coin_packs` + `coin_top_ups` tables, `start_top_up` / `finalize_top_up` / `cancel_top_up` RPCs, the Coin Packs UI, provider picker sheet, and a `FakeTopUpsRepository` that simulates the verified-webhook callback for local dev.

The remaining work — **wiring real SDKs and webhook verification** — depends on merchant credentials. Follow this guide once you have them.

## 1. Merchant onboarding

Apply with each provider; you'll receive a merchant id, secret key, and (sandbox + production) API endpoints.

- **eSewa** — `https://developer.esewa.com.np`
- **Khalti** — `https://docs.khalti.com`
- **IME Pay** — `https://www.imepay.com.np/imerb/`

Store the secrets in Supabase project secrets (Settings → Edge Functions → Secrets), **not** in `pubspec.yaml` or `--dart-define`.

## 2. Flutter SDK integration

Pick the official Flutter plugin or wrap the provider's web checkout in a `webview_flutter` instance:

```yaml
# Optional — add only when you ship that provider.
esewa_pnp: ^1.0.x       # or khalti_flutter / ime_pay_flutter equivalents
```

Inside `CoinPacksPage._buy(pack)`, replace the `debugSimulateSuccess` block with:

```dart
final created = await repo.startTopUp(pack: pack, provider: provider);
final ok = await launchProviderCheckout(
  provider: provider,
  amountNpr: pack.priceNpr,
  merchantTransactionId: created.id,
);
if (!ok) {
  await repo.cancelTopUp(created.id);
  return;
}
// Show the receipt screen; the wallet will be credited once the webhook
// finalises the row server-side (you can poll `getTopUp(created.id)`).
```

The provider returns control to the app on success or cancel; **the wallet credit must wait for the webhook** to avoid trusting the client.

## 3. Webhook Edge Function

Create one Edge Function per provider (or one with a `provider` path param) at `supabase/functions/topup_webhook/index.ts`:

```ts
import { serve } from 'https://deno.land/std/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js';

serve(async (req) => {
  const sb = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );
  const body = await req.json();
  const topUpId = body.merchantTransactionId;       // matches start_top_up id
  const signature = req.headers.get('x-provider-signature');

  // 1. Verify the signature using the provider's secret. Each provider
  //    documents its own HMAC scheme. Reject if invalid.
  if (!verifySignature(provider, body, signature)) {
    return new Response('bad_signature', { status: 400 });
  }

  // 2. Atomically promote the row + credit the wallet.
  await sb.rpc('finalize_top_up', {
    p_top_up_id: topUpId,
    p_provider_ref: body.providerTransactionId,
    p_payload: body,
    p_ok: body.status === 'success',
  });

  return new Response('ok');
});
```

`finalize_top_up` is idempotent — the same webhook delivered twice does not double-credit.

## 4. Refund flow (admin panel)

The admin panel (`docs/admin_panel_plan.md`) calls:
- `admin_credit(user_id, -amount, 'manual_refund')` to refund coins, AND
- the provider's refund REST API to return the NPR.

Both happen inside a single admin action wrapped in `audit_events` so we have a full trail.

## 5. Local dev — no merchant account

When `SUPABASE_URL` is empty the app uses `FakeTopUpsRepository`. The Coin Packs page automatically calls `debugSimulateSuccess` after a brief delay so the wallet ledgers a fresh credit and the new balance appears in the UI. Use this to demo the end-to-end UX without any provider setup.

## 6. Test plan

- **Unit:** `test/features/topups/fake_top_ups_repository_test.dart` covers pending/success/cancel paths.
- **Integration:** add a `webhook_replay_test` that POSTs sample provider payloads to the Edge Function with known-good and tampered signatures.
- **Manual:** sandbox-pay one of each provider in staging, then audit `coin_top_ups` and `wallet_ledger` rows to verify idempotency.
