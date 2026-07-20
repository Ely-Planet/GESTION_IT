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
  if (!res.ok) return null;
  const json = await res.json();
  return json.access_token as string;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const { movementId, effectiveDate, employeeName } = await req.json();

    const token = await getAccessToken();
    if (!token) {
      // Credentials not configured yet — store placeholder, log warning
      await supabase.from('movements').update({
        calendar_event_ids: JSON.stringify(['pending-credentials']),
      }).eq('id', movementId);

      await supabase.rpc('log_audit', {
        p_action: 'calendar_pending',
        p_entity_type: 'movement',
        p_entity_id: movementId,
        p_details: { reason: 'MS credentials not configured' },
        p_actor_name: 'Calendar Service',
      });

      return new Response(
        JSON.stringify({ ok: true, message: 'Calendar events pending — Microsoft credentials not yet configured' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const userEmail = Deno.env.get('CALENDAR_USER_EMAIL');
    if (!userEmail) {
      return new Response(
        JSON.stringify({ error: 'CALENDAR_USER_EMAIL secret not configured (shared calendar owner email)' }),
        { status: 503, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const arrivalDate = new Date(effectiveDate);
    const prepDate = new Date(arrivalDate);
    prepDate.setDate(prepDate.getDate() - 7);

    const eventIds: string[] = [];

    // Event 1: Onboarding preparation (1 week before)
    const event1 = {
      subject: `Onboarding ${employeeName} — Préparation`,
      body: { contentType: 'Text', content: `Préparer le matériel et les licences pour l'arrivée de ${employeeName}.` },
      start: { dateTime: `${prepDate.toISOString().slice(0, 19)}Z`, timeZone: 'Europe/Paris' },
      end: { dateTime: `${new Date(prepDate.getTime() + 60 * 60 * 1000).toISOString().slice(0, 19)}Z`, timeZone: 'Europe/Paris' },
      location: { displayName: 'Service IT' },
    };

    // Event 2: Arrival day
    const event2 = {
      subject: `Onboarding ${employeeName} — Jour J`,
      body: { contentType: 'Text', content: `Arrivée de ${employeeName}. Remise du matériel et signature des documents d'attribution.` },
      start: { dateTime: `${arrivalDate.toISOString().slice(0, 19)}Z`, timeZone: 'Europe/Paris' },
      end: { dateTime: `${new Date(arrivalDate.getTime() + 2 * 60 * 60 * 1000).toISOString().slice(0, 19)}Z`, timeZone: 'Europe/Paris' },
      location: { displayName: 'Service IT' },
    };

    for (const evt of [event1, event2]) {
      const res = await fetch(`https://graph.microsoft.com/v1.0/users/${userEmail}/calendar/events`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify(evt),
      });
      if (res.ok) {
        const json = await res.json();
        eventIds.push(json.id);
      } else {
        console.error('Event creation failed', await res.text());
      }
    }

    await supabase.from('movements').update({
      calendar_event_ids: JSON.stringify(eventIds),
    }).eq('id', movementId);

    await supabase.rpc('log_audit', {
      p_action: 'calendar_created',
      p_entity_type: 'movement',
      p_entity_id: movementId,
      p_details: { eventIds },
      p_actor_name: 'Calendar Service',
    });

    return new Response(
      JSON.stringify({ ok: true, eventIds }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : 'Unknown error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
