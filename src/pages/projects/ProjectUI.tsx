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

export function StatusBadge({ status }: { status: string }) {
  return (
    <span className={`badge ${STATUS_BADGE_CLASSES[status] || 'bg-ink-100 text-ink-700'}`}>
      {STATUS_LABELS[status] || status}
    </span>
  );
}
