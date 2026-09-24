import { useState } from 'react';
import { projectsApi } from '../api';
import { StatusBadge } from '../ProjectUI';
import type { Account, ProjectDetailData } from '../types';

const STATUSES = ['open', 'closed'] as const;

export default function TasksTab({
  project,
  team,
  onChanged,
}: {
  project: ProjectDetailData;
  team: Account[];
  onChanged: () => void;
}) {
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ title: '', description: '', assigneeAccountId: '', estimatedHours: '' });

  const canCreateTasks =
    Boolean(project.estChefDeProjet);

  async function createTask(e: React.FormEvent) {
    e.preventDefault();
    try {
      await projectsApi.createTask({
        projectId: project.id,
        title: form.title,
        description: form.description,
        assigneeAccountId: form.assigneeAccountId || null,
        estimatedHours: form.estimatedHours ? Number(form.estimatedHours) : 0,
      });
      setForm({ title: '', description: '', assigneeAccountId: '', estimatedHours: '' });
      setShowForm(false);
      onChanged();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    }
  }

  async function updateStatus(taskId: string, status: string) {
    await projectsApi.updateTask(taskId, { status });
    onChanged();
  }

  async function updateSpentHours(taskId: string, spentHours: string) {
    await projectsApi.updateTask(taskId, { spentHours: Number(spentHours) });
    onChanged();
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-3">
        <h3 className="font-semibold text-ink-900">Tâches ({project.tasks?.length || 0})</h3>
        {canCreateTasks && (
          <button className="btn-secondary text-sm" onClick={() => setShowForm((s) => !s)}>
            + Ajouter une tâche
          </button>
        )}
      </div>

      {canCreateTasks && showForm && (
        <form onSubmit={createTask} className="card p-4 mb-4 space-y-2">
          <input
            className="input"
            placeholder="Titre de la tâche"
            required
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
          />
          <textarea
            className="input"
            placeholder="Description"
            rows={2}
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
          />
          <div className="grid grid-cols-2 gap-2">
            <select
              className="input"
              value={form.assigneeAccountId}
              onChange={(e) => setForm({ ...form, assigneeAccountId: e.target.value })}
            >
              <option value="">Assigner à...</option>
              {team.map((t) => (
                <option key={t.id} value={t.id}>
                  {t.display_name}
                </option>
              ))}
            </select>
            <input
              className="input"
              type="number"
              min="0"
              step="0.5"
              placeholder="Temps estimé (h)"
              value={form.estimatedHours}
              onChange={(e) => setForm({ ...form, estimatedHours: e.target.value })}
            />
          </div>
          <div className="flex gap-2">
            <button className="btn-primary text-sm">Créer</button>
            <button type="button" className="btn-ghost text-sm" onClick={() => setShowForm(false)}>
              Annuler
            </button>
          </div>
        </form>
      )}

      <div className="space-y-2">
        {(project.tasks || []).map((t) => (
          <div key={t.id} className="card p-4 flex flex-wrap items-center justify-between gap-2">
            <div>
              <p className="font-medium text-ink-900">{t.title}</p>
              {t.description && <p className="text-sm text-ink-500">{t.description}</p>}
              <p className="text-xs text-ink-400 mt-1">
                {t.assignee_name ? `Assigné à ${t.assignee_name}` : 'Non assigné'} ·{' '}
                {t.origin === 'demande_client' ? "Issue d'une demande client" : 'Manuelle'}
                {t.github_issue_url && ' · Synchronisée GitHub'}
              </p>
            </div>
            <div className="flex items-center gap-2">
              <input
                type="number"
                min="0"
                step="0.5"
                defaultValue={t.spent_hours}
                className="input w-20 text-sm py-1"
                title="Temps passé (h)"
                onBlur={(e) => updateSpentHours(t.id, e.target.value)}
              />
              <span className="text-xs text-ink-400">/ {t.estimated_hours}h</span>
              <select
                className="input py-1 text-sm w-32"
                value={t.status}
                onChange={(e) => updateStatus(t.id, e.target.value)}
              >
                {STATUSES.map((s) => (
                  <option key={s} value={s}>
                    {s === 'open' ? 'Ouverte' : 'Fermée'}
                  </option>
                ))}
              </select>
              <StatusBadge status={t.status} />
            </div>
          </div>
        ))}
        {(!project.tasks || project.tasks.length === 0) && (
          <p className="text-sm text-ink-500">Aucune tâche pour l'instant.</p>
        )}
      </div>
    </div>
  );
}
