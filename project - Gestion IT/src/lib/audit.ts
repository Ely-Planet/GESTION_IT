import { supabase } from './supabase';

export async function logAudit(
  action: string,
  entityType: string,
  entityId?: string | null,
  details?: Record<string, unknown>,
  actorName?: string,
) {
  try {
    await supabase.rpc('log_audit', {
      p_action: action,
      p_entity_type: entityType,
      p_entity_id: entityId ?? null,
      p_details: details ?? null,
      p_actor_name: actorName ?? null,
    });
  } catch (e) {
    console.warn('Audit log failed', e);
  }
}
