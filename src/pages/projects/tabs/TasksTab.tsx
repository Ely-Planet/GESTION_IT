import { useEffect, useState } from 'react';
import { GripVertical, MessageSquare, Paperclip } from 'lucide-react';
import { projectsApi } from '../api';
import { StatusBadge } from '../ProjectUI';
import TaskDetail from './TaskDetail';
import type { Account, ProjectDetailData, Task } from '../types';

const STATUSES = ['backlog', 'ready', 'in_progress', 'in_review', 'done'] as const;
type TaskStatus = (typeof STATUSES)[number];

const COLUMN_CONFIG: Record<TaskStatus, { title: string; subtitle: string; style: string }> = {
  backlog: { title: 'BACKLOG', subtitle: 'Non démarré', style: 'border-emerald-200 bg-emerald-50/50' },
  ready: { title: 'READY', subtitle: 'Prêt à démarrer', style: 'border-blue-200 bg-blue-50/50' },
  in_progress: { title: 'IN PROGRESS', subtitle: 'En cours', style: 'border-amber-200 bg-amber-50/50' },
  in_review: { title: 'IN REVIEW', subtitle: 'En revue', style: 'border-purple-200 bg-purple-50/50' },
  done: { title: 'DONE', subtitle: 'Terminé', style: 'border-orange-200 bg-orange-50/50' },
};

type TaskCardProps = {
  task: Task;
  team: Account[];
  canAssign: boolean;
  updating: boolean;
  dragged: boolean;
  onDragStart: (taskId: string) => void;
  onDragEnd: () => void;
  onStatusChange: (taskId: string, status: TaskStatus) => void;
  onSpentHoursChange: (taskId: string, spentHours: string) => void;
  onAssigneeChange: (taskId: string, assigneeAccountId: string) => void;
  onOpen: (task: Task) => void;
};

// Composant déclaré hors de TasksTab : défini à l'intérieur, React le
// recréait à chaque rendu et remplaçait la carte en plein glisser-déposer,
// ce qui annulait le premier déplacement (il fallait le refaire une 2e fois).
function TaskCard({
  task,
  team,
  canAssign,
  updating,
  dragged,
  onDragStart,
  onDragEnd,
  onStatusChange,
  onSpentHoursChange,
  onAssigneeChange,
  onOpen,
}: TaskCardProps) {
  const files = task.files || [];
  return (
    <article
      onClick={(event) => {
        // Les champs de la carte (statut, affectation, temps, liens) gardent leur propre action.
        if ((event.target as HTMLElement).closest('button, select, input, a, textarea')) return;
        onOpen(task);
      }}
      className={`card p-3 cursor-pointer transition-all ${updating ? 'opacity-60 pointer-events-none' : 'hover:shadow-elevated'} ${dragged ? 'opacity-40 scale-[0.98]' : ''}`}
    >
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-start gap-2 min-w-0">
          <button
            type="button"
            draggable={!updating}
            aria-label="Déplacer la tâche"
            title="Glisser pour déplacer"
            className="mt-0.5 shrink-0 cursor-grab active:cursor-grabbing text-ink-400 hover:text-ink-700 touch-none"
            onDragStart={(event) => {
              event.stopPropagation();
              event.dataTransfer.effectAllowed = 'move';
              event.dataTransfer.setData('text/plain', task.id);
              onDragStart(task.id);
            }}
            onDragEnd={onDragEnd}
          >
            <GripVertical className="w-4 h-4" />
          </button>
          <p className="font-medium text-ink-900 break-words">{task.title}</p>
        </div>
        <StatusBadge status={task.status} />
      </div>
      {task.description && <p className="text-sm text-ink-500 mt-2 line-clamp-3">{task.description}</p>}
      {canAssign ? (
        <select
          className="input py-1 text-xs mt-3"
          value={task.assignee_account_id || ''}
          onChange={(e) => onAssigneeChange(task.id, e.target.value)}
        >
          <option value="">Non assigné</option>
          {team.map((account) => (
            <option key={account.id} value={account.id}>Assigné à {account.display_name}</option>
          ))}
        </select>
      ) : (
        <p className="text-xs text-ink-400 mt-3">{task.assignee_name ? `Assigné à ${task.assignee_name}` : 'Non assigné'}</p>
      )}
      <div className="flex items-center gap-2 mt-3">
        <label className="text-xs text-ink-500">Temps passé</label>
        <input type="number" min="0" step="0.5" defaultValue={task.spent_hours} className="input w-20 text-sm py-1" onBlur={(e) => onSpentHoursChange(task.id, e.target.value)} />
        <span className="text-xs text-ink-400">/ {task.estimated_hours} h</span>
      </div>
      {files.length > 0 && (
        <div className="mt-2 space-y-0.5">
          {files.map((file) => (
            <a key={file.id} href={`/api/projects/files/${file.id}/download`} className="flex items-center gap-1 text-xs text-elyade-700 hover:underline">
              <Paperclip className="w-3 h-3 shrink-0" /> <span className="truncate">{file.filename}</span>
            </a>
          ))}
        </div>
      )}
      <div className="flex items-center justify-between gap-2 mt-3 pt-3 border-t border-ink-100">
        <select className="input py-1 text-xs w-28" value={task.status} onChange={(e) => onStatusChange(task.id, e.target.value as TaskStatus)}>
          <option value="backlog">Backlog</option>
          <option value="ready">Ready</option>
          <option value="in_progress">In progress</option>
          <option value="in_review">In review</option>
          <option value="done">Done</option>
        </select>
        <button
          type="button"
          className="flex items-center gap-1 text-xs text-ink-500 hover:text-elyade-700"
          onClick={() => onOpen(task)}
          title="Commentaires"
        >
          <MessageSquare className="w-3.5 h-3.5" /> {task.comment_count || 0}
        </button>
        {task.github_issue_url ? (
          <a href={task.github_issue_url} target="_blank" rel="noreferrer" className="text-xs text-elyade-700 hover:underline">GitHub</a>
        ) : (
          <span className="text-xs text-ink-400">{task.origin === 'demande_client' ? 'Demande client' : 'Tâche interne'}</span>
        )}
      </div>
    </article>
  );
}

export default function TasksTab({ project, team, onChanged }: {
  project: ProjectDetailData;
  team: Account[];
  onChanged: () => void;
}) {
  const [showForm, setShowForm] = useState(false);
  const [showOldDone, setShowOldDone] = useState(false);
  const [draggedTaskId, setDraggedTaskId] = useState<string | null>(null);
  const [dragOverStatus, setDragOverStatus] = useState<TaskStatus | null>(null);
  const [updatingTaskId, setUpdatingTaskId] = useState<string | null>(null);
  const [detailTaskId, setDetailTaskId] = useState<string | null>(null);
  const [form, setForm] = useState({ title: '', description: '', assigneeAccountId: '', estimatedHours: '' });
  const canCreateTasks = Boolean(project.estChefDeProjet);
  const [localTasks, setLocalTasks] = useState<Task[]>(project.tasks || []);
  const tasks = localTasks;
  const detailTask = tasks.find((task) => task.id === detailTaskId) || null;

  useEffect(() => {
    setLocalTasks(project.tasks || []);
  }, [project.tasks]);
  const doneCutoff = Date.now() - 5 * 24 * 60 * 60 * 1000;
  const oldDoneTasks = tasks.filter((task) =>
    task.status === 'done' &&
    Boolean(task.completed_at) &&
    new Date(task.completed_at as string).getTime() < doneCutoff
  );
  const visibleTasks = showOldDone
    ? tasks
    : tasks.filter((task) => !oldDoneTasks.some((doneTask) => doneTask.id === task.id));

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

  async function updateStatus(taskId: string, status: TaskStatus) {
    const previousTasks = localTasks;

    setLocalTasks((current) =>
      current.map((task) =>
        task.id === taskId ? { ...task, status } : task
      )
    );
    setUpdatingTaskId(taskId);

    try {
      await projectsApi.updateTask(taskId, { status });
    } catch (err: any) {
      setLocalTasks(previousTasks);
      alert(err.message || 'Erreur lors du changement de statut');
    } finally {
      setUpdatingTaskId(null);
    }
  }

  async function updateSpentHours(taskId: string, spentHours: string) {
    try {
      await projectsApi.updateTask(taskId, { spentHours: Number(spentHours) });
      onChanged();
    } catch (err: any) {
      alert(err.message || 'Erreur lors de la mise à jour du temps');
    }
  }

  async function updateAssignee(taskId: string, assigneeAccountId: string) {
    const assignee = team.find((account) => account.id === assigneeAccountId);
    setLocalTasks((current) =>
      current.map((task) =>
        task.id === taskId
          ? { ...task, assignee_account_id: assigneeAccountId || null, assignee_name: assignee?.display_name || null }
          : task
      )
    );
    try {
      await projectsApi.updateTask(taskId, { assigneeAccountId: assigneeAccountId || null });
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'affectation");
      onChanged();
    }
  }

  function endDrag() {
    setDraggedTaskId(null);
    setDragOverStatus(null);
  }

  async function dropTask(status: TaskStatus, taskId: string) {
    const task = localTasks.find((item) => item.id === taskId);
    endDrag();
    if (!task || task.status === status) return;
    await updateStatus(task.id, status);
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-semibold text-ink-900">Tâches ({tasks.length})</h3>
        <div className="flex items-center gap-2">
          {oldDoneTasks.length > 0 && (
            <button
              type="button"
              className="btn-ghost text-sm"
              onClick={() => setShowOldDone((value) => !value)}
            >
              {showOldDone
                ? 'Masquer les Done anciens'
                : `Afficher les Done anciens (${oldDoneTasks.length})`}
            </button>
          )}
          {canCreateTasks && (
            <button
              className="btn-secondary text-sm"
              onClick={() => setShowForm((value) => !value)}
            >
              + Ajouter une tâche
            </button>
          )}
        </div>
      </div>

      {canCreateTasks && showForm && (
        <form onSubmit={createTask} className="card p-4 mb-5 space-y-2">
          <input className="input" placeholder="Titre de la tâche" required value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} />
          <textarea className="input" placeholder="Description" rows={2} value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} />
          <div className="grid grid-cols-2 gap-2">
            <select className="input" value={form.assigneeAccountId} onChange={(e) => setForm({ ...form, assigneeAccountId: e.target.value })}>
              <option value="">Assigner à...</option>
              {team.map((a) => <option key={a.id} value={a.id}>{a.display_name}</option>)}
            </select>
            <input className="input" type="number" min="0" step="0.5" placeholder="Temps estimé (h)" value={form.estimatedHours} onChange={(e) => setForm({ ...form, estimatedHours: e.target.value })} />
          </div>
          <div className="flex gap-2">
            <button className="btn-primary text-sm">Créer</button>
            <button type="button" className="btn-ghost text-sm" onClick={() => setShowForm(false)}>Annuler</button>
          </div>
        </form>
      )}

      <div className="flex gap-4 overflow-x-auto pb-4 items-start">
        {STATUSES.map((status) => {
          const columnTasks = visibleTasks.filter((task) => task.status === status);
          const columnConfig = COLUMN_CONFIG[status];
          return (
            <section
              key={status}
              onDragOver={(e) => {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'move';
                if (dragOverStatus !== status) setDragOverStatus(status);
              }}
              onDragLeave={(e) => { if (!e.currentTarget.contains(e.relatedTarget as Node)) setDragOverStatus(null); }}
              onDrop={(e) => {
                e.preventDefault();
                const taskId = e.dataTransfer.getData('text/plain') || draggedTaskId;
                if (taskId) void dropTask(status, taskId);
              }}
              className={`rounded-xl border p-3 min-h-[360px] min-w-[320px] w-[320px] flex-shrink-0 transition-all ${columnConfig.style} ${dragOverStatus === status ? 'ring-2 ring-elyade-500 ring-offset-2 scale-[1.01]' : ''}`}
            >
              <div className="flex items-center justify-between mb-3 px-1">
                <div>
                  <h4 className="font-bold text-sm text-ink-900">{columnConfig.title}</h4>
                  <p className="text-xs text-ink-500">{columnConfig.subtitle}</p>
                </div>
                <span className="badge bg-white text-ink-700">{columnTasks.length}</span>
              </div>
              <div className="space-y-3">
                {columnTasks.map((task) => (
                  <TaskCard
                    key={task.id}
                    task={task}
                    team={team}
                    canAssign={canCreateTasks}
                    updating={updatingTaskId === task.id}
                    dragged={draggedTaskId === task.id}
                    onDragStart={setDraggedTaskId}
                    onDragEnd={endDrag}
                    onStatusChange={(taskId, nextStatus) => void updateStatus(taskId, nextStatus)}
                    onSpentHoursChange={(taskId, spentHours) => void updateSpentHours(taskId, spentHours)}
                    onAssigneeChange={(taskId, assigneeAccountId) => void updateAssignee(taskId, assigneeAccountId)}
                    onOpen={(openedTask) => setDetailTaskId(openedTask.id)}
                  />
                ))}
                {columnTasks.length === 0 && <div className="border-2 border-dashed border-ink-200 rounded-lg p-8 text-center text-sm text-ink-400">Déposez une tâche ici</div>}
              </div>
            </section>
          );
        })}
      </div>

      {detailTask && (
        <TaskDetail
          task={detailTask}
          onClose={() => setDetailTaskId(null)}
          onCountChange={(count) =>
            setLocalTasks((current) =>
              current.map((task) => (task.id === detailTask.id ? { ...task, comment_count: count } : task))
            )
          }
        />
      )}
    </div>
  );
}
