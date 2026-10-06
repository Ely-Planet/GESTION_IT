import { STATUS_LABELS, STATUS_BADGE_CLASSES } from './types';

export function ProgressBar({ value }: { value: number }) {
  return (
    <div className="w-full bg-ink-100 rounded-full h-2">
      <div
        className="bg-elyade-600 h-2 rounded-full transition-all"
        style={{ width: `${Math.min(100, Math.max(0, value))}%` }}
      />
    </div>
  );
}

// '2026-10-05' -> '05/10/2026' (sans passer par Date : pas de décalage de fuseau).
export function formatDay(value: string | null | undefined) {
  if (!value) return '';
  const [y, m, d] = value.slice(0, 10).split('-');
  return `${d}/${m}/${y}`;
}

export function formatPeriod(start: string | null | undefined, end: string | null | undefined) {
  if (start && end) return `${formatDay(start)} → ${formatDay(end)}`;
  if (start) return `Début ${formatDay(start)}`;
  if (end) return `Fin ${formatDay(end)}`;
  return '';
}

export function StatusBadge({ status }: { status: string }) {
  return (
    <span className={`badge ${STATUS_BADGE_CLASSES[status] || 'bg-ink-100 text-ink-700'}`}>
      {STATUS_LABELS[status] || status}
    </span>
  );
}
