export function formatFrDate(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (isNaN(d.getTime())) return iso;
  return d.toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', year: 'numeric' });
}

export function formatFrDateTime(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (isNaN(d.getTime())) return iso;
  return d.toLocaleString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export const MOVEMENT_STATUS: Record<string, string> = {
  pending: 'En attente',
  in_progress: 'En cours',
  done: 'Terminé',
  cancelled: 'Annulé',
};

export const HARDWARE_STATUS: Record<string, string> = {
  in_stock: 'En stock',
  assigned: 'Attribué',
  being_reinstalled: 'Réinstallation',
  retired: 'Réformé',
  defective: 'Défectueux',
};

export const LICENSE_STATUS: Record<string, string> = {
  available: 'Disponible',
  assigned: 'Attribuée',
  reserved: 'Réservée',
  resiliated: 'Résiliée',
};

export const ASSIGNMENT_DOC_STATUS: Record<string, string> = {
  pending: 'En attente',
  signed: 'Signé',
  not_signed: 'Non signé',
};

export const RESTITUTION_STATUS: Record<string, string> = {
  pending: 'En attente',
  done: 'Restitué',
  partial: 'Partiel',
  missing: 'Manquant',
};

export function statusLabel(code: string, map: Record<string, string> = MOVEMENT_STATUS): string {
  return map[code] ?? code;
}
