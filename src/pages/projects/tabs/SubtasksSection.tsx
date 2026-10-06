import { useState } from 'react';
import { CheckCircle2, Circle, Trash2 } from 'lucide-react';
import { projectsApi } from '../api';
import { SUBTASK_STATUS_LABELS, type Account, type Subtask, type Task } from '../types';

// Sous-tâches d'une tâche : découpage interne de l'équipe, jamais envoyé
// au client (pas de mail, pas de portail) ni à GitHub.
export default function SubtasksSection({ task, team, onChanged }: {
  task: Task;
  team: Account[];
  onChanged: () => void;
}) {
  const subtasks = task.subtasks || [];
  const emptyForm = { title: '', startDate: '', endDate: '', assigneeAccountId: '' };
  const [form, setForm] = useState(emptyForm);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);

  async function run(id: string | null, action: () => Promise<unknown>) {
    setBusyId(id);
    try {
      await action();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    } finally {
      setBusyId(null);
      onChanged();
    }
  }

  async function add(e: React.FormEvent) {
    e.preventDefault();
    if (!form.title.trim()) return;
    setAdding(true);
    try {
      await projectsApi.createSubtask(task.id, {
        title: form.title.trim(),
        startDate: form.startDate || null,
        endDate: form.endDate || null,
        assigneeAccountId: form.assigneeAccountId || null,
      });
      setForm(emptyForm);
      onChanged();
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'ajout de la sous-tâche");
    } finally {
      setAdding(false);
    }
  }

  function update(subtask: Subtask, patch: Record<string, unknown>) {
    void run(subtask.id, () => projectsApi.updateSubtask(subtask.id, patch));
  }

  const done = subtasks.filter((subtask) => subtask.status === 'done').length;

  return (
    <section>
      <div className="flex items-baseline justify-between mb-1">
        <h4 className="text-sm font-semibold text-ink-900">
          Sous-tâches {subtasks.length > 0 && `(${done}/${subtasks.length})`}
        </h4>
        <span className="text-xs text-ink-400">Internes : le client n'est pas prévenu</span>
      </div>

      <div className="space-y-2 mt-2">
        {subtasks.length === 0 && <p className="text-sm text-ink-400">Aucune sous-tâche.</p>}
        {subtasks.map((subtask) => {
          const isDone = subtask.status === 'done';
          return (
            <div
              key={subtask.id}
              className={`rounded-lg border border-ink-100 p-2.5 ${busyId === subtask.id ? 'opacity-60 pointer-events-none' : ''}`}
            >
              <div className="flex items-start gap-2">
                <button
                  type="button"
                  className="mt-0.5 shrink-0"
                  title={isDone ? 'Rouvrir' : 'Marquer terminée'}
                  onClick={() => update(subtask, { status: isDone ? 'todo' : 'done' })}
                >
                  {isDone
                    ? <CheckCircle2 className="w-4 h-4 text-green-600" />
                    : <Circle className="w-4 h-4 text-ink-300 hover:text-elyade-500" />}
                </button>
                <input
                  key={`title-${subtask.title}`}
                  className={`flex-1 min-w-0 text-sm bg-transparent border-0 p-0 focus:ring-0 ${isDone ? 'line-through text-ink-400' : 'text-ink-800'}`}
                  defaultValue={subtask.title}
                  onBlur={(e) => {
                    const title = e.target.value.trim();
                    if (title && title !== subtask.title) update(subtask, { title });
                    else e.target.value = subtask.title;
                  }}
                />
                <button
                  type="button"
                  className="shrink-0 text-ink-300 hover:text-red-600"
                  title="Supprimer la sous-tâche"
                  onClick={() => {
                    if (confirm(`Supprimer la sous-tâche « ${subtask.title} » ?`)) {
                      void run(subtask.id, () => projectsApi.deleteSubtask(subtask.id));
                    }
                  }}
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 mt-2 pl-6">
                <select
                  className="input py-1 text-xs"
                  value={subtask.status}
                  onChange={(e) => update(subtask, { status: e.target.value })}
                >
                  {Object.entries(SUBTASK_STATUS_LABELS).map(([value, label]) => (
                    <option key={value} value={value}>{label}</option>
                  ))}
                </select>
                <select
                  className="input py-1 text-xs"
                  value={subtask.assignee_account_id || ''}
                  onChange={(e) => update(subtask, { assigneeAccountId: e.target.value || null })}
                >
                  <option value="">Non assignée</option>
                  {team.map((account) => <option key={account.id} value={account.id}>{account.display_name}</option>)}
                </select>
                <input
                  key={`start-${subtask.start_date ?? ''}`}
                  type="date"
                  className="input py-1 text-xs"
                  title="Date de début"
                  defaultValue={subtask.start_date ?? ''}
                  max={subtask.end_date ?? undefined}
                  onBlur={(e) => {
                    if (e.target.value !== (subtask.start_date ?? '')) update(subtask, { startDate: e.target.value || null });
                  }}
                />
                <input
                  key={`end-${subtask.end_date ?? ''}`}
                  type="date"
                  className="input py-1 text-xs"
                  title="Date de fin"
                  defaultValue={subtask.end_date ?? ''}
                  min={subtask.start_date ?? undefined}
                  onBlur={(e) => {
                    if (e.target.value !== (subtask.end_date ?? '')) update(subtask, { endDate: e.target.value || null });
                  }}
                />
              </div>
            </div>
          );
        })}
      </div>

      <form onSubmit={add} className="mt-3 rounded-lg border border-dashed border-ink-200 p-2.5 space-y-2">
        <input
          className="input py-1 text-sm"
          placeholder="Nouvelle sous-tâche…"
          value={form.title}
          onChange={(e) => setForm({ ...form, title: e.target.value })}
        />
        {form.title.trim() && (
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
            <select
              className="input py-1 text-xs"
              value={form.assigneeAccountId}
              onChange={(e) => setForm({ ...form, assigneeAccountId: e.target.value })}
            >
              <option value="">Non assignée</option>
              {team.map((account) => <option key={account.id} value={account.id}>{account.display_name}</option>)}
            </select>
            <input
              type="date"
              className="input py-1 text-xs"
              title="Date de début"
              value={form.startDate}
              min={task.start_date ?? undefined}
              max={form.endDate || task.end_date || undefined}
              onChange={(e) => setForm({ ...form, startDate: e.target.value })}
            />
            <input
              type="date"
              className="input py-1 text-xs"
              title="Date de fin"
              value={form.endDate}
              min={form.startDate || task.start_date || undefined}
              max={task.end_date ?? undefined}
              onChange={(e) => setForm({ ...form, endDate: e.target.value })}
            />
            <button className="btn-primary text-xs py-1" disabled={adding}>
              {adding ? 'Ajout…' : 'Ajouter'}
            </button>
          </div>
        )}
      </form>
    </section>
  );
}
