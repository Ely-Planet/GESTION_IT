export async function logAudit(
  action: string,
  entityType: string,
  entityId?: string | null,
  details?: Record<string, unknown>,
  actorName?: string,
) {
  try {
    await fetch('/api/audit-log', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        action,
        entity_type: entityType,
        entity_id: entityId ?? null,
        details: details ?? null,
        actor_name: actorName ?? null,
      }),
    });
  } catch (e) {
    console.warn('Audit log failed', e);
  }
}
