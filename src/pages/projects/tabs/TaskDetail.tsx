import { useEffect, useState } from 'react';
import { ExternalLink, Trash2, X } from 'lucide-react';
import { useProjectModule } from '../projectModule';
import { StatusBadge } from '../ProjectUI';
import SubtasksSection from './SubtasksSection';
import AttachmentLink from '../AttachmentLink';
import FilePicker from '../FilePicker';
import type { Account, Task, TaskComment } from '../types';

// Panneau latéral d'une tâche : planning, sous-tâches, description complète,
// pièces jointes et commentaires (synchronisés avec l'issue GitHub liée).
export default function TaskDetail({ task, team, canDelete, canPlan, onClose, onCountChange, onDeleted, onChanged }: {
  task: Task;
  team: Account[];
  canDelete: boolean;
  canPlan: boolean;
  onClose: () => void;
  onCountChange: (count: number) => void;
  onDeleted: () => void;
  onChanged: () => void;
}) {
  const mod = useProjectModule();
  const projectsApi = mod.api;
  const [deleting, setDeleting] = useState(false);
  const [newFiles, setNewFiles] = useState<File[]>([]);
  const [uploading, setUploading] = useState(false);

  async function uploadFiles() {
    if (!newFiles.length) return;
    setUploading(true);
    try {
      const data = new FormData();
      newFiles.forEach((file) => data.append('files', file));
      await projectsApi.addTaskFiles(task.id, data);
      setNewFiles([]);
      onChanged();
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'envoi des pièces jointes");
    } finally {
      setUploading(false);
    }
  }

  async function updateDates(patch: { startDate?: string | null; endDate?: string | null }) {
    try {
      await projectsApi.updateTask(task.id, patch);
      onChanged();
    } catch (err: any) {
      alert(err.message || 'Erreur lors de la mise à jour des dates');
      onChanged();
    }
  }

  async function deleteTask() {
    const githubNote = task.github_issue_url || task.github_item_id
      ? '\n\nLa carte sera aussi retirée du tableau GitHub (et l’issue fermée).'
      : '';
    if (!confirm(`Supprimer définitivement la tâche « ${task.title} » ?\nSes commentaires, sous-tâches et pièces jointes seront supprimés.${githubNote}`)) return;
    setDeleting(true);
    try {
      await projectsApi.deleteTask(task.id);
      onDeleted();
    } catch (err: any) {
      alert(err.message || 'Erreur lors de la suppression');
      setDeleting(false);
    }
  }

  const [comments, setComments] = useState<TaskComment[]>([]);
  const [githubError, setGithubError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [body, setBody] = useState('');
  const [sending, setSending] = useState(false);
  const files = task.files || [];

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    projectsApi
      .listTaskComments(task.id)
      .then((data: { comments: TaskComment[]; githubError: string | null }) => {
        if (cancelled) return;
        setComments(data.comments);
        setGithubError(data.githubError);
        onCountChange(data.comments.length);
      })
      .catch((err: Error) => !cancelled && setGithubError(err.message))
      .finally(() => !cancelled && setLoading(false));
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [task.id]);

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);

  async function send(e: React.FormEvent) {
    e.preventDefault();
    if (!body.trim()) return;
    setSending(true);
    try {
      const comment: TaskComment = await projectsApi.addTaskComment(task.id, body.trim());
      const next = [...comments, comment];
      setComments(next);
      onCountChange(next.length);
      setBody('');
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'envoi du commentaire");
    } finally {
      setSending(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex justify-end bg-black/30" onClick={onClose}>
      <aside
        className="w-full max-w-xl h-full bg-white shadow-xl flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-3 p-5 border-b border-ink-100">
          <div className="min-w-0">
            <div className="flex items-center gap-2 mb-1">
              <StatusBadge status={task.status} />
              {mod.github && (
                <span className="text-xs text-ink-400">
                  {task.origin === 'demande_client' ? 'Demande client' : 'Tâche interne'}
                </span>
              )}
            </div>
            <h3 className="text-lg font-semibold text-ink-900 break-words">{task.title}</h3>
            <p className="text-xs text-ink-500 mt-1">
              {task.assignee_name ? `Assigné à ${task.assignee_name}` : 'Non assigné'}
              {mod.timeTracking && <>{' · '}Temps passé {task.spent_hours} h / {task.estimated_hours} h</>}
            </p>
            {task.github_issue_url && (
              <a href={task.github_issue_url} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1 text-xs text-elyade-700 hover:underline mt-1">
                Ouvrir sur GitHub <ExternalLink className="w-3 h-3" />
              </a>
            )}
          </div>
          <div className="flex items-center gap-1 shrink-0">
            {canDelete && (
              <button
                type="button"
                className="btn-ghost text-sm text-red-600 hover:text-red-700"
                disabled={deleting}
                onClick={() => void deleteTask()}
              >
                <Trash2 className="w-4 h-4" /> {deleting ? 'Suppression…' : 'Supprimer'}
              </button>
            )}
            <button type="button" className="btn-ghost p-1" onClick={onClose} aria-label="Fermer">
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto p-5 space-y-6">
          <section>
            <h4 className="text-sm font-semibold text-ink-900 mb-2">Planning</h4>
            <div className="grid grid-cols-2 gap-3">
              <label className="text-xs text-ink-500">
                Date de début
                <input
                  key={`start-${task.start_date ?? ''}`}
                  type="date"
                  className="input mt-1"
                  disabled={!canPlan}
                  defaultValue={task.start_date ?? ''}
                  max={task.end_date ?? undefined}
                  onBlur={(e) => {
                    if (e.target.value !== (task.start_date ?? '')) void updateDates({ startDate: e.target.value || null });
                  }}
                />
              </label>
              <label className="text-xs text-ink-500">
                Date de fin
                <input
                  key={`end-${task.end_date ?? ''}`}
                  type="date"
                  className="input mt-1"
                  disabled={!canPlan}
                  defaultValue={task.end_date ?? ''}
                  min={task.start_date ?? undefined}
                  onBlur={(e) => {
                    if (e.target.value !== (task.end_date ?? '')) void updateDates({ endDate: e.target.value || null });
                  }}
                />
              </label>
            </div>
            {!canPlan && <p className="text-xs text-ink-400 mt-1">Seul le chef de projet peut modifier les dates de la tâche.</p>}
          </section>

          <SubtasksSection task={task} team={team} onChanged={onChanged} />

          <section>
            <h4 className="text-sm font-semibold text-ink-900 mb-2">Description</h4>
            {task.description ? (
              <p className="text-sm text-ink-700 whitespace-pre-wrap break-words">{task.description}</p>
            ) : (
              <p className="text-sm text-ink-400">Aucune description.</p>
            )}
          </section>

          <section>
            <h4 className="text-sm font-semibold text-ink-900 mb-2">Pièces jointes ({files.length})</h4>
            {files.length === 0 ? (
              <p className="text-sm text-ink-400">Aucune pièce jointe.</p>
            ) : (
              <ul className="space-y-1">
                {files.map((file) => (
                  <li key={file.id}>
                    <AttachmentLink file={file} className="text-sm w-full" />
                  </li>
                ))}
              </ul>
            )}
            <div className="mt-3">
              <FilePicker files={newFiles} onChange={setNewFiles} />
              {newFiles.length > 0 && (
                <button type="button" className="btn-primary text-sm mt-2" disabled={uploading} onClick={() => void uploadFiles()}>
                  {uploading ? 'Envoi…' : `Joindre ${newFiles.length} fichier(s)`}
                </button>
              )}
            </div>
          </section>

          <section>
            <h4 className="text-sm font-semibold text-ink-900 mb-2">
              Commentaires {loading ? '' : `(${comments.length})`}
            </h4>
            {task.github_issue_url && <p className="text-xs text-ink-400 mb-2">Synchronisés avec l'issue GitHub.</p>}
            {githubError && (
              <p className="text-xs text-amber-700 bg-amber-50 rounded p-2 mb-2">
                GitHub indisponible, affichage des commentaires déjà connus. ({githubError})
              </p>
            )}
            {loading && <p className="text-sm text-ink-500">Chargement…</p>}
            {!loading && comments.length === 0 && <p className="text-sm text-ink-400">Aucun commentaire.</p>}
            <div className="space-y-3">
              {comments.map((comment) => (
                <div key={comment.id} className="rounded-lg border border-ink-100 p-3">
                  <div className="flex items-center justify-between gap-2 text-xs text-ink-500 mb-1">
                    <span className="font-medium text-ink-700">{comment.author_name}</span>
                    <span>{new Date(comment.created_at).toLocaleString('fr-FR')}</span>
                  </div>
                  <p className="text-sm text-ink-800 whitespace-pre-wrap break-words">{comment.body}</p>
                  {comment.github_comment_url && (
                    <a href={comment.github_comment_url} target="_blank" rel="noreferrer" className="text-xs text-elyade-700 hover:underline">
                      Voir sur GitHub
                    </a>
                  )}
                </div>
              ))}
            </div>
          </section>
        </div>

        <form onSubmit={send} className="p-5 border-t border-ink-100 space-y-2">
          <textarea
            className="input"
            rows={3}
            placeholder="Ajouter un commentaire…"
            value={body}
            onChange={(e) => setBody(e.target.value)}
          />
          <button className="btn-primary text-sm" disabled={sending || !body.trim()}>
            {sending ? 'Envoi…' : 'Commenter'}
          </button>
        </form>
      </aside>
    </div>
  );
}
