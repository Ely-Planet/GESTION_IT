import { useEffect, useMemo, useState } from 'react';
import { ChevronDown, ChevronRight } from 'lucide-react';
import { formatDay } from '../ProjectUI';
import TaskDetail from './TaskDetail';
import { STATUS_LABELS, SUBTASK_STATUS_LABELS, type Account, type ProjectDetailData, type Subtask, type Task } from '../types';

const DAY_MS = 24 * 60 * 60 * 1000;
const LABEL_WIDTH = 300;
const ZOOMS = {
  day: { label: 'Jour', px: 34 },
  week: { label: 'Semaine', px: 14 },
  month: { label: 'Mois', px: 4 },
} as const;
type Zoom = keyof typeof ZOOMS;

const MONTHS = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];

const TASK_BAR: Record<Task['status'], string> = {
  backlog: 'bg-slate-400',
  ready: 'bg-blue-500',
  in_progress: 'bg-amber-500',
  in_review: 'bg-purple-500',
  done: 'bg-emerald-500',
};
const SUBTASK_BAR: Record<Subtask['status'], string> = {
  todo: 'bg-slate-300',
  in_progress: 'bg-amber-300',
  done: 'bg-emerald-300',
};

// Jours comptés en UTC à partir de 'AAAA-MM-JJ' : aucun décalage de fuseau.
function toDay(value: string) {
  const [y, m, d] = value.slice(0, 10).split('-').map(Number);
  return Date.UTC(y, m - 1, d) / DAY_MS;
}
function fromDay(day: number) {
  return new Date(day * DAY_MS);
}
function todayDay() {
  const now = new Date();
  return Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()) / DAY_MS;
}

type Span = { start: number; end: number; derived: boolean };

// Une seule date = jalon d'un jour. Tâche sans date : période déduite de ses sous-tâches.
function spanOf(start: string | null | undefined, end: string | null | undefined): Span | null {
  if (!start && !end) return null;
  const s = toDay((start || end) as string);
  const e = toDay((end || start) as string);
  return { start: Math.min(s, e), end: Math.max(s, e), derived: false };
}
function taskSpan(task: Task): Span | null {
  const own = spanOf(task.start_date, task.end_date);
  if (own) return own;
  const subSpans = (task.subtasks || []).map((s) => spanOf(s.start_date, s.end_date)).filter(Boolean) as Span[];
  if (!subSpans.length) return null;
  return {
    start: Math.min(...subSpans.map((s) => s.start)),
    end: Math.max(...subSpans.map((s) => s.end)),
    derived: true,
  };
}

export default function GanttTab({ project, team, onChanged }: {
  project: ProjectDetailData;
  team: Account[];
  onChanged: () => void;
}) {
  const [zoom, setZoom] = useState<Zoom>('week');
  const [collapsed, setCollapsed] = useState<Set<string>>(new Set());
  const [detailTaskId, setDetailTaskId] = useState<string | null>(null);
  const tasks = useMemo(() => project.tasks || [], [project.tasks]);
  const detailTask = tasks.find((task) => task.id === detailTaskId) || null;
  const canPlan = Boolean(project.estChefDeProjet);
  const px = ZOOMS[zoom].px;
  const today = todayDay();
  const dueDay = project.due_date ? toDay(String(project.due_date)) : null;

  useEffect(() => {
    if (detailTaskId && !detailTask) setDetailTaskId(null);
  }, [detailTaskId, detailTask]);

  const planned = useMemo(
    () =>
      tasks
        .map((task) => ({ task, span: taskSpan(task) }))
        .filter((row): row is { task: Task; span: Span } => row.span !== null)
        .sort((a, b) => a.span.start - b.span.start || a.span.end - b.span.end),
    [tasks]
  );
  const unplanned = tasks.filter((task) => !taskSpan(task));

  const range = useMemo(() => {
    const days: number[] = [today];
    for (const { task, span } of planned) {
      days.push(span.start, span.end);
      for (const subtask of task.subtasks || []) {
        const s = spanOf(subtask.start_date, subtask.end_date);
        if (s) days.push(s.start, s.end);
      }
    }
    if (dueDay !== null) days.push(dueDay);
    // Marge, et début aligné sur un lundi (ou le 1er du mois en vue mois).
    let start = Math.min(...days) - (zoom === 'month' ? 15 : 3);
    const end = Math.max(...days) + (zoom === 'month' ? 30 : 10);
    if (zoom === 'month') {
      const d = fromDay(start);
      start = Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), 1) / DAY_MS;
    } else {
      start -= (fromDay(start).getUTCDay() + 6) % 7;
    }
    return { start, end, length: end - start + 1 };
  }, [planned, today, dueDay, zoom]);

  const width = range.length * px;
  const x = (day: number) => (day - range.start) * px;

  // En-têtes : mois, puis jours (vue jour) ou semaines (vue semaine).
  const months: { label: string; left: number; width: number }[] = [];
  const ticks: { label: string; left: number; width: number; weekend?: boolean }[] = [];
  for (let day = range.start; day <= range.end; day++) {
    const date = fromDay(day);
    if (day === range.start || date.getUTCDate() === 1) {
      const last = months[months.length - 1];
      if (last) last.width = x(day) - last.left;
      months.push({ label: `${MONTHS[date.getUTCMonth()]} ${date.getUTCFullYear()}`, left: x(day), width: 0 });
    }
    const weekday = date.getUTCDay();
    if (zoom === 'day') {
      ticks.push({ label: String(date.getUTCDate()), left: x(day), width: px, weekend: weekday === 0 || weekday === 6 });
    } else if (zoom === 'week' && weekday === 1) {
      ticks.push({ label: `${String(date.getUTCDate()).padStart(2, '0')}/${String(date.getUTCMonth() + 1).padStart(2, '0')}`, left: x(day), width: 7 * px });
    }
  }
  if (months.length) months[months.length - 1].width = width - months[months.length - 1].left;

  function toggle(taskId: string) {
    setCollapsed((current) => {
      const next = new Set(current);
      if (next.has(taskId)) next.delete(taskId);
      else next.add(taskId);
      return next;
    });
  }

  function renderBar({ span, className, title, thin = false }: { span: Span; className: string; title: string; thin?: boolean }) {
    return (
      <div
        title={title}
        className={`absolute top-1/2 -translate-y-1/2 rounded ${thin ? 'h-2.5' : 'h-4'} ${className} ${span.derived ? 'opacity-50 border border-dashed border-ink-500' : ''}`}
        style={{ left: x(span.start) + 1, width: Math.max((span.end - span.start + 1) * px - 2, 6) }}
      />
    );
  }

  return (
    <div>
      <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
        <div>
          <h3 className="font-semibold text-ink-900">Planning du projet</h3>
          <p className="text-xs text-ink-500">
            Les dates se saisissent dans le détail de chaque tâche. Les sous-tâches ne sont jamais notifiées au client.
          </p>
        </div>
        <div className="flex rounded-lg border border-ink-200 overflow-hidden">
          {(Object.keys(ZOOMS) as Zoom[]).map((key) => (
            <button
              key={key}
              type="button"
              onClick={() => setZoom(key)}
              className={`px-3 py-1.5 text-sm ${zoom === key ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 hover:bg-ink-50'}`}
            >
              {ZOOMS[key].label}
            </button>
          ))}
        </div>
      </div>

      {planned.length === 0 ? (
        <div className="card p-8 text-center text-sm text-ink-500">
          Aucune tâche planifiée. Ouvrez une tâche pour lui donner une date de début et de fin.
        </div>
      ) : (
        <div className="card overflow-x-auto">
          <div className="relative" style={{ width: LABEL_WIDTH + width }}>
            {/* En-tête */}
            <div className="flex sticky top-0 z-20 bg-white border-b border-ink-100">
              <div className="sticky left-0 z-30 bg-white border-r border-ink-100 px-3 flex items-end pb-1 text-xs font-medium text-ink-500" style={{ width: LABEL_WIDTH, minWidth: LABEL_WIDTH }}>
                Tâche
              </div>
              <div className="relative" style={{ width, height: zoom === 'month' ? 26 : 46 }}>
                {months.map((month) => (
                  <div key={month.left} className="absolute top-0 h-6 border-l border-ink-200 px-1 text-xs font-medium text-ink-700 truncate" style={{ left: month.left, width: month.width }}>
                    {month.label}
                  </div>
                ))}
                {ticks.map((tick) => (
                  <div key={tick.left} className={`absolute top-6 h-5 border-l border-ink-100 text-[10px] text-center text-ink-500 ${tick.weekend ? 'bg-ink-50' : ''}`} style={{ left: tick.left, width: tick.width }}>
                    {tick.label}
                  </div>
                ))}
              </div>
            </div>

            {/* Lignes */}
            <div className="relative">
              {/* Fond : week-ends (vue jour), aujourd'hui, échéance du projet */}
              <div className="absolute inset-y-0 pointer-events-none" style={{ left: LABEL_WIDTH, width }}>
                {ticks.filter((tick) => tick.weekend).map((tick) => (
                  <div key={tick.left} className="absolute inset-y-0 bg-ink-50" style={{ left: tick.left, width: tick.width }} />
                ))}
                {today >= range.start && today <= range.end && (
                  <div className="absolute inset-y-0 w-0.5 bg-red-500/70 z-10" style={{ left: x(today) + px / 2 }} title="Aujourd'hui" />
                )}
                {dueDay !== null && (
                  <div className="absolute inset-y-0 border-l-2 border-dashed border-elyade-600 z-10" style={{ left: x(dueDay + 1) }} title={`Échéance du projet : ${formatDay(String(project.due_date))}`} />
                )}
              </div>

              {planned.map(({ task, span }) => {
                const subtasks = task.subtasks || [];
                const isOpen = !collapsed.has(task.id);
                return (
                  <div key={task.id}>
                    <div className="flex border-b border-ink-100 hover:bg-elyade-50/30 cursor-pointer" style={{ height: 36 }} onClick={() => setDetailTaskId(task.id)}>
                      <div className="sticky left-0 z-10 bg-white flex items-center gap-1 px-2 border-r border-ink-100" style={{ width: LABEL_WIDTH, minWidth: LABEL_WIDTH }}>
                        {subtasks.length > 0 ? (
                          <button
                            type="button"
                            className="p-0.5 text-ink-400 hover:text-ink-700"
                            onClick={(e) => { e.stopPropagation(); toggle(task.id); }}
                            aria-label={isOpen ? 'Replier les sous-tâches' : 'Déplier les sous-tâches'}
                          >
                            {isOpen ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                          </button>
                        ) : <span className="w-5" />}
                        <span className={`w-2 h-2 rounded-full shrink-0 ${TASK_BAR[task.status]}`} />
                        <span className="text-sm font-medium text-ink-900 truncate" title={task.title}>{task.title}</span>
                      </div>
                      <div className="relative" style={{ width }}>
                        {renderBar({
                          span,
                          className: TASK_BAR[task.status],
                          title: `${task.title} — ${STATUS_LABELS[task.status]}\n${formatDay(fromDay(span.start).toISOString())} → ${formatDay(fromDay(span.end).toISOString())}${span.derived ? '\n(période déduite des sous-tâches)' : ''}`,
                        })}
                      </div>
                    </div>
                    {isOpen && subtasks.map((subtask) => {
                      const subSpan = spanOf(subtask.start_date, subtask.end_date);
                      return (
                        <div key={subtask.id} className="flex border-b border-ink-50 hover:bg-elyade-50/30 cursor-pointer" style={{ height: 28 }} onClick={() => setDetailTaskId(task.id)}>
                          <div className="sticky left-0 z-10 bg-white flex items-center gap-1.5 pl-10 pr-2 border-r border-ink-100" style={{ width: LABEL_WIDTH, minWidth: LABEL_WIDTH }}>
                            <span className={`w-1.5 h-1.5 rounded-full shrink-0 ${SUBTASK_BAR[subtask.status]}`} />
                            <span className={`text-xs truncate ${subtask.status === 'done' ? 'line-through text-ink-400' : 'text-ink-600'}`} title={subtask.title}>
                              {subtask.title}
                            </span>
                          </div>
                          <div className="relative" style={{ width }}>
                            {subSpan ? (
                              renderBar({
                                thin: true,
                                span: subSpan,
                                className: SUBTASK_BAR[subtask.status],
                                title: `${subtask.title} — ${SUBTASK_STATUS_LABELS[subtask.status]}\n${formatDay(subtask.start_date || subtask.end_date)} → ${formatDay(subtask.end_date || subtask.start_date)}`,
                              })
                            ) : (
                              <span className="absolute top-1/2 -translate-y-1/2 text-[10px] text-ink-400" style={{ left: x(span.start) }}>
                                non planifiée
                              </span>
                            )}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      <div className="flex flex-wrap items-center gap-x-4 gap-y-1 mt-3 text-xs text-ink-500">
        {(Object.keys(TASK_BAR) as Task['status'][]).map((status) => (
          <span key={status} className="flex items-center gap-1.5">
            <span className={`w-3 h-2.5 rounded-sm ${TASK_BAR[status]}`} /> {STATUS_LABELS[status]}
          </span>
        ))}
        <span className="flex items-center gap-1.5"><span className="w-0.5 h-3 bg-red-500" /> Aujourd'hui</span>
        {dueDay !== null && <span className="flex items-center gap-1.5"><span className="h-3 border-l-2 border-dashed border-elyade-600" /> Échéance du projet</span>}
        <span className="flex items-center gap-1.5"><span className="w-3 h-2.5 rounded-sm bg-slate-400 opacity-50 border border-dashed border-ink-500" /> Période déduite des sous-tâches</span>
      </div>

      {unplanned.length > 0 && (
        <div className="card p-4 mt-4">
          <h4 className="text-sm font-semibold text-ink-900 mb-2">Tâches non planifiées ({unplanned.length})</h4>
          <div className="flex flex-wrap gap-2">
            {unplanned.map((task) => (
              <button
                key={task.id}
                type="button"
                className="badge bg-ink-100 text-ink-700 hover:bg-elyade-100"
                onClick={() => setDetailTaskId(task.id)}
              >
                {task.title}
              </button>
            ))}
          </div>
        </div>
      )}

      {detailTask && (
        <TaskDetail
          task={detailTask}
          team={team}
          canDelete={canPlan}
          canPlan={canPlan}
          onChanged={onChanged}
          onDeleted={() => { setDetailTaskId(null); onChanged(); }}
          onClose={() => setDetailTaskId(null)}
          onCountChange={() => {}}
        />
      )}
    </div>
  );
}
