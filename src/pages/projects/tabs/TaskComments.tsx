import { useEffect, useState } from 'react';
import { X } from 'lucide-react';
import { projectsApi } from '../api';
import type { Task, TaskComment } from '../types';

export default function TaskComments({ task, onClose, onCountChange }: {
  task: Task;
  onClose: () => void;
  onCountChange: (count: number) => void;
}) {
  const [comments, setComments] = useState<TaskComment[]>([]);
  const [githubError, setGithubError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [body, setBody] = useState('');
  const [sending, setSending] = useState(false);

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
        className="w-full max-w-md h-full bg-white shadow-xl flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between gap-3 p-4 border-b border-ink-100">
          <div className="min-w-0">
            <p className="text-xs text-ink-500">Commentaires</p>
            <h3 className="font-semibold text-ink-900 break-words">{task.title}</h3>
            {task.github_issue_url && (
              <p className="text-xs text-ink-400 mt-1">Synchronisés avec l'issue GitHub</p>
            )}
          </div>
          <button type="button" className="btn-ghost p-1" onClick={onClose} aria-label="Fermer">
            <X className="w-4 h-4" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          {githubError && (
            <p className="text-xs text-amber-700 bg-amber-50 rounded p-2">
              GitHub indisponible, affichage des commentaires déjà connus. ({githubError})
            </p>
          )}
          {loading && <p className="text-sm text-ink-500">Chargement…</p>}
          {!loading && comments.length === 0 && <p className="text-sm text-ink-500">Aucun commentaire.</p>}
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

        <form onSubmit={send} className="p-4 border-t border-ink-100 space-y-2">
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
