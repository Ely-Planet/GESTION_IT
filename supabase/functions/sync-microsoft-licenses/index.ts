import { createClient } from 'npm:@supabase/supabase-js@2.57.4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
);

interface SkuRecord {
  skuId: string;
  capabilityStatus?: string;
  appliesTo?: string;
  prepaidUnits?: { enabled: number; suspended: number; warning: number };
  consumedUnits: number;
  servicePlans?: unknown[];
}

async function getAccessToken(): Promise<string | null> {
  const tenantId = Deno.env.get('MS_TENANT_ID');
  const clientId = Deno.env.get('MS_CLIENT_ID');
  const clientSecret = Deno.env.get('MS_CLIENT_SECRET');
  if (!tenantId || !clientId || !clientSecret) return null;

  const url = `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`;
  const body = new URLSearchParams({
    client_id: clientId,
    client_secret: clientSecret,
    scope: 'https://graph.microsoft.com/.default',
    grant_type: 'client_credentials',
  });
  const res = await fetch(url, { method: 'POST', body });
  if (!res.ok) {
    console.error('Token fetch failed', await res.text());
    return null;
  }
  const json = await res.json();
  return json.access_token as string;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const token = await getAccessToken();
    if (!token) {
      return new Response(
        JSON.stringify({ error: 'Microsoft tenant credentials not configured (MS_TENANT_ID, MS_CLIENT_ID, MS_CLIENT_SECRET required)' }),
        { status: 503, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const graphRes = await fetch('https://graph.microsoft.com/v1.0/subscribedSkus', {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!graphRes.ok) {
      const txt = await graphRes.text();
      return new Response(
        JSON.stringify({ error: `Graph API error: ${graphRes.status}`, detail: txt }),
        { status: 502, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }
    const json = await graphRes.json();
    const skus: SkuRecord[] = json.value ?? [];

    for (const sku of skus) {
      const enabled = sku.prepaidUnits?.enabled ?? 0;
      const row = {
        sku_id: sku.skuId,
        display_name: sku.appliesTo ?? sku.skuId,
        applies_to: sku.appliesTo ?? null,
        enabled_units: enabled,
        consumed_units: sku.consumedUnits ?? 0,
        prepaid_units: enabled,
        synced_at: new Date().toISOString(),
      };
      const { error } = await supabase
        .from('subscribed_skus')
        .upsert(row, { onConflict: 'sku_id' });
      if (error) console.error('Upsert SKU failed', sku.skuId, error.message);
    }

    await supabase.rpc('log_audit', {
      p_action: 'sync',
      p_entity_type: 'subscribed_skus',
      p_entity_id: null,
      p_details: { count: skus.length },
      p_actor_name: 'Microsoft Graph Sync',
    });

    return new Response(
      JSON.stringify({ ok: true, synced: skus.length }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : 'Unknown error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
