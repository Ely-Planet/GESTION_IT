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

interface InboundEmailPayload {
  from?: string;
  to?: string;
  subject?: string;
  'body-plain'?: string;
  'body-html'?: string;
  'stripped-text'?: string;
  recipient?: string;
  sender?: string;
  subject_line?: string;
  body?: string;
}

function detectType(subject: string, body: string): 'onboarding' | 'offboarding' | null {
  const text = `${subject} ${body}`.toLowerCase();
  const offKeywords = ['départ', 'depart', 'offboarding', 'fin de contrat', 'rupture', 'solde de tout compte', 'lucca'];
  const onKeywords = ['arrivée', 'arrivee', 'onboarding', 'nouveau collaborateur', 'nouvelle embauche', 'embauche', 'formulaire', 'formulaire microsoft'];
  if (offKeywords.some((k) => text.includes(k))) return 'offboarding';
  if (onKeywords.some((k) => text.includes(k))) return 'onboarding';
  return null;
}

function extractDate(text: string): string | null {
  const patterns = [/(\d{4}-\d{2}-\d{2})/, /(\d{2}\/\d{2}\/\d{4})/g];
  for (const p of patterns) {
    const m = text.match(p);
    if (m) {
      let d = m[1];
      if (d.includes('/')) {
        const [day, month, year] = d.split('/');
        d = `${year}-${month}-${day}`;
      }
      if (!isNaN(new Date(d).getTime())) return d;
    }
  }
  return null;
}

function extractName(text: string): { first: string; last: string } | null {
  const patterns = [
    /(?:nom|name|collaborateur|salarié|salarie|prénom nom)\s*[:\-]?\s*([A-ZÀ-Ý][a-zà-ÿ]+)\s+([A-ZÀ-Ý][a-zà-ÿ]+)/i,
    /([A-ZÀ-Ý][a-zà-ÿ]+)\s+([A-ZÀ-Ý][a-zà-ÿ]+)/,
  ];
  for (const p of patterns) {
    const m = text.match(p);
    if (m) return { first: m[1], last: m[2] };
  }
  return null;
}

function extractField(text: string, fieldNames: string[]): string | null {
  for (const name of fieldNames) {
    const re = new RegExp(`${name}\\s*[:\\-]?\\s*(.+?)(?:\\n|$)`, 'i');
    const m = text.match(re);
    if (m && m[1].trim()) return m[1].trim();
  }
  return null;
}

function extractRequestedHardware(text: string): string[] {
  const lower = text.toLowerCase();
  const found: string[] = [];
  const map: Record<string, string> = {
    'pc': 'PC', 'ordinateur': 'PC', 'portable': 'PC',
    'téléphone': 'PHONE', 'telephone': 'PHONE', 'mobile': 'PHONE', 'smartphone': 'PHONE',
    'casque': 'HEADSET',
    'tablette': 'TABLET', 'tablet': 'TABLET', 'ipad': 'TABLET',
    'enceinte': 'SPEAKER',
    'pad de signature': 'SIGNATURE_PAD', 'signature': 'SIGNATURE_PAD',
  };
  for (const [k, v] of Object.entries(map)) {
    if (lower.includes(k) && !found.includes(v)) found.push(v);
  }
  return found;
}

function extractRequestedLicenses(text: string): string[] {
  const lower = text.toLowerCase();
  const found: string[] = [];
  if (lower.includes('office') || lower.includes('microsoft 365') || lower.includes('o365')) found.push('OFFICE365');
  if (lower.includes('seiitra')) found.push('SEIITRA');
  return found;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const payload = (await req.json()) as InboundEmailPayload;
    const subject = payload.subject ?? payload.subject_line ?? '';
    const body = payload['body-plain'] ?? payload['stripped-text'] ?? payload.body ?? payload['body-html'] ?? '';
    const from = payload.from ?? payload.sender ?? '';

    const type = detectType(subject, body);
    if (!type) {
      return new Response(
        JSON.stringify({ ok: true, message: 'Email ignored — no movement detected' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const effectiveDate = extractDate(`${subject} ${body}`) ?? new Date().toISOString().slice(0, 10);
    const name = extractName(`${subject} ${body}`);
    const jobTitle = extractField(body, ['poste', 'fonction', 'job title', 'emploi']);
    const serviceName = extractField(body, ['service', 'département', 'department']);
    const manager = extractField(body, ['manager', 'responsable']);

    let employeeId: string | null = null;
    if (name) {
      const { data: existing } = await supabase
        .from('employees')
        .select('id')
        .ilike('first_name', name.first)
        .ilike('last_name', name.last)
        .maybeSingle();
      if (existing) {
        employeeId = existing.id;
      } else {
        const { data: created } = await supabase
          .from('employees')
          .insert({
            first_name: name.first,
            last_name: name.last,
            job_title: jobTitle,
            manager_name: manager,
            is_active: type === 'onboarding',
          })
          .select('id')
          .single();
        employeeId = created?.id ?? null;
      }
    }

    let serviceId: string | null = null;
    if (serviceName) {
      const { data: svc } = await supabase
        .from('services')
        .select('id')
        .ilike('name', serviceName)
        .maybeSingle();
      if (svc) serviceId = svc.id;
    }

    const movementRow = {
      type,
      employee_id: employeeId,
      service_id: serviceId,
      effective_date: effectiveDate,
      source: 'lucca_email',
      status: 'pending',
      job_title: jobTitle,
      manager_name: manager,
      notes: `Email reçu de ${from}\nSujet: ${subject}\n\n${body.slice(0, 2000)}`,
    };

    const { data: movement, error } = await supabase
      .from('movements')
      .insert(movementRow)
      .select('id')
      .single();

    if (error) throw error;

    // Seed default action checklist
    const actions = type === 'onboarding'
      ? [
          { action_type: 'creation', label: 'Création compte AD / Microsoft', sort_order: 1 },
          { action_type: 'license_assignment', label: 'Attribution licences (Office, Seiitra)', sort_order: 2 },
          { action_type: 'pc_delivery', label: 'Livraison PC', sort_order: 3 },
          { action_type: 'intune_connection', label: 'Connexion Intune', sort_order: 4 },
          { action_type: 'welcome_email', label: 'Email de bienvenue', sort_order: 5 },
        ]
      : [
          { action_type: 'creation', label: 'Demande récupération matériel', sort_order: 1 },
          { action_type: 'pc_delivery', label: 'Réinstallation PC', sort_order: 2 },
          { action_type: 'license_assignment', label: 'Libération licences', sort_order: 3 },
        ];

    for (const a of actions) {
      await supabase.from('movement_actions').insert({
        movement_id: movement.id,
        action_type: a.action_type,
        label: a.label,
        sort_order: a.sort_order,
        due_date: effectiveDate,
      });
    }

    // Parse requested hardware from Microsoft Form body
    const requestedHardware = extractRequestedHardware(`${subject} ${body}`);
    for (const code of requestedHardware) {
      const { data: cat } = await supabase
        .from('hardware_categories')
        .select('id')
        .eq('code', code)
        .maybeSingle();
      if (cat) {
        await supabase.from('movement_items').insert({
          movement_id: movement.id,
          category_id: cat.id,
          status: 'requested',
        });
      }
    }

    // Parse requested licenses
    const requestedLicenses = extractRequestedLicenses(`${subject} ${body}`);
    for (const code of requestedLicenses) {
      const { data: lt } = await supabase
        .from('license_types')
        .select('id')
        .eq('code', code)
        .maybeSingle();
      if (lt) {
        await supabase.from('movement_licenses').insert({
          movement_id: movement.id,
          license_type_id: lt.id,
          status: 'requested',
        });
      }
    }

    await supabase.rpc('log_audit', {
      p_action: 'create',
      p_entity_type: 'movement',
      p_entity_id: movement.id,
      p_details: { source: 'lucca_email', type, subject, requestedHardware, requestedLicenses },
      p_actor_name: 'Lucca Email Webhook',
    });

    // Trigger calendar event creation for onboarding
    if (type === 'onboarding') {
      try {
        const calUrl = `${Deno.env.get('SUPABASE_URL')}/functions/v1/create-calendar-events`;
        await fetch(calUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${Deno.env.get('SUPABASE_ANON_KEY')}` },
          body: JSON.stringify({ movementId: movement.id, effectiveDate, employeeName: name ? `${name.first} ${name.last}` : 'Collaborateur' }),
        });
      } catch (e) {
        console.warn('Calendar creation failed', e);
      }
    }

    return new Response(
      JSON.stringify({
        ok: true,
        movement_id: movement.id,
        type,
        requestedHardware,
        requestedLicenses,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : 'Unknown error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  }
});
