import { useEffect, useRef, useState } from 'react';
import { Paperclip, X } from 'lucide-react';
import { projectsApi } from '../api';
import { StatusBadge } from '../ProjectUI';
import AttachmentLink from '../AttachmentLink';
import { useAuth } from '../../../context/AuthContext';
import type { Account, ClientRequest, ProjectDetailData, ProjectFile } from '../types';

const MAX_FILES = 10;
const MAX_FILE_SIZE = 25 * 1024 * 1024;

const TASK_PROGRESS_LABELS: Record<string, string> = {
  backlog: 'Planifiée',
  ready: 'Planifiée',
  in_progress: 'En cours de réalisation',
  in_review: 'En cours de réalisation',
  done: 'Terminée',
};

type Review = { title: string; description: string; estimatedHours: string; assigneeAccountId: string };

function FileLinks({ files }: { files?: ProjectFile[] | null }) {
  if (!files?.length) return null;
  return (
    <div className="mt-2 space-y-0.5">
      {files.map((file) => (
        <AttachmentLink key={file.id} file={file} className="text-xs" />
      ))}
    </div>
  );
}

export default function RequestsTab({
  project,
  team,
  onChanged,
}: {
  project: ProjectDetailData;
  team: Account[];
  onChanged: () => void;
}) {
  const { user } = useAuth();
  // Vue équipe si le serveur a envoyé les tâches ; être client est propre au projet.
  const teamView = Array.isArray(project.tasks);
  const canSubmit = Boolean(user?.id) && project.client_account_id === user?.id;
  const canProcess = teamView && Boolean(project.estChefDeProjet);
  const [requests, setRequests] = useState<ClientRequest[]>([]);
  const [newRequest, setNewRequest] = useState({ title: '', description: '' });
  const [files, setFiles] = useState<File[]>([]);
  const [sending, setSending] = useState(false);
  const [reviews, setReviews] = useState<Record<string, Review>>({});
  const fileInput = useRef<HTMLInputElement>(null);

  async function load() {
    if (!teamView) {
      const detail = await projectsApi.getProject(project.id);
      setRequests(detail.clientRequests || []);
    } else {
      setRequests(await projectsApi.listRequests(project.id));
    }
  }

  useEffect(() => {
    if (!teamView) setRequests(project.clientRequests || []);
    else void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [project.id]);

  function addFiles(selected: FileList | null) {
    if (!selected) return;
    const tooBig = Array.from(selected).filter((file) => file.size > MAX_FILE_SIZE);
    if (tooBig.length) alert(`Fichier(s) trop volumineux (25 Mo maximum) : ${tooBig.map((f) => f.name).join(', ')}`);
    const next = [...files, ...Array.from(selected).filter((file) => file.size <= MAX_FILE_SIZE)];
    if (next.length > MAX_FILES) alert(`${MAX_FILES} pièces jointes maximum.`);
    setFiles(next.slice(0, MAX_FILES));
    if (fileInput.current) fileInput.current.value = '';
  }

  async function submitRequest(e: React.FormEvent) {
    e.preventDefault();
    setSending(true);
    try {
      const data = new FormData();
      data.append('projectId', project.id);
      data.append('title', newRequest.title);
      data.append('description', newRequest.description);
      files.forEach((file) => data.append('files', file));
      await projectsApi.createRequest(data);
      setNewRequest({ title: '', description: '' });
      setFiles([]);
      await load();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    } finally {
      setSending(false);
    }
  }

  function reviewOf(r: ClientRequest): Review {
    return reviews[r.id] || { title: r.title, description: r.description || '', estimatedHours: '', assigneeAccountId: '' };
  }

  function updateReview(r: ClientRequest, patch: Partial<Review>) {
    setReviews({ ...reviews, [r.id]: { ...reviewOf(r), ...patch } });
  }

  async function valider(r: ClientRequest) {
    const review = reviewOf(r);
    const estimatedHours = Number(review.estimatedHours);
    if (!estimatedHours || estimatedHours <= 0) {
      alert('Merci de saisir une prévision de temps (heures) avant de valider.');
      return;
    }
    if (!review.title.trim()) {
      alert('Le titre de la demande ne peut pas être vide.');
      return;
    }
    try {
      await projectsApi.validateRequest(r.id, {
        estimatedHours,
        title: review.title,
        description: review.description,
        assigneeAccountId: review.assigneeAccountId || null,
      });
      void load();
      onChanged();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    }
  }

  async function rejeter(r: ClientRequest) {
    const reason = prompt('Motif du rejet (obligatoire, envoyé au client) :');
    if (reason === null) return;
    if (!reason.trim()) {
      alert('Merci d’indiquer le motif du rejet.');
      return;
    }
    try {
      await projectsApi.rejectRequest(r.id, reason);
      void load();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    }
  }

  return (
    <div>
      <h3 className="font-semibold text-ink-900 mb-3">{teamView ? 'Demandes client' : 'Mes demandes'}</h3>

      {canSubmit && (
        <form onSubmit={submitRequest} className="card p-4 mb-4 space-y-2">
          <p className="label mb-0">Nouvelle demande</p>
          <input
            className="input"
            placeholder="Titre de la demande"
            required
            value={newRequest.title}
            onChange={(e) => setNewRequest({ ...newRequest, title: e.target.value })}
          />
          <textarea
            className="input"
            placeholder="Décrivez votre besoin le plus précisément possible"
            rows={5}
            value={newRequest.description}
            onChange={(e) => setNewRequest({ ...newRequest, description: e.target.value })}
          />
          <div>
            <input ref={fileInput} type="file" multiple className="hidden" onChange={(e) => addFiles(e.target.files)} />
            <button type="button" className="btn-ghost text-sm" onClick={() => fileInput.current?.click()}>
              <Paperclip className="w-4 h-4" /> Ajouter des pièces jointes
            </button>
            {files.length > 0 && (
              <ul className="mt-2 space-y-1">
                {files.map((file, index) => (
                  <li key={`${file.name}-${index}`} className="flex items-center gap-2 text-sm text-ink-700">
                    <Paperclip className="w-3 h-3 text-ink-400" />
                    <span className="truncate flex-1">{file.name}</span>
                    <span className="text-xs text-ink-400">{(file.size / 1024 / 1024).toFixed(1)} Mo</span>
                    <button
                      type="button"
                      className="text-ink-400 hover:text-red-600"
                      aria-label={`Retirer ${file.name}`}
                      onClick={() => setFiles(files.filter((_, i) => i !== index))}
                    >
                      <X className="w-4 h-4" />
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </div>
          <button className="btn-primary text-sm" disabled={sending}>
            {sending ? 'Envoi…' : 'Envoyer la demande'}
          </button>
        </form>
      )}

      <div className="space-y-2">
        {requests.map((r) => {
          const pending = r.status === 'en_attente';
          const review = reviewOf(r);
          return (
            <div key={r.id} className="card p-4">
              <div className="flex justify-between items-start gap-3">
                <div className="min-w-0 flex-1">
                  {canProcess && pending ? (
                    <div className="space-y-2">
                      <p className="text-xs text-ink-500">
                        Demande de {r.client_name || 'client'} — modifiable avant validation
                      </p>
                      <input
                        className="input"
                        value={review.title}
                        onChange={(e) => updateReview(r, { title: e.target.value })}
                      />
                      <textarea
                        className="input"
                        rows={4}
                        value={review.description}
                        onChange={(e) => updateReview(r, { description: e.target.value })}
                      />
                    </div>
                  ) : (
                    <>
                      <p className="font-medium text-ink-900">{r.title}</p>
                      {r.description && <p className="text-sm text-ink-500 whitespace-pre-wrap">{r.description}</p>}
                      {teamView && r.original_title && (
                        <p className="text-xs text-ink-400 mt-1">
                          Demande d'origine : « {r.original_title} »
                        </p>
                      )}
                      {r.status === 'rejetee' && r.rejection_reason && (
                        <p className="text-sm text-red-700 bg-red-50 rounded px-2 py-1 mt-2 whitespace-pre-wrap">
                          <span className="font-medium">Motif du rejet :</span> {r.rejection_reason}
                        </p>
                      )}
                    </>
                  )}
                  <FileLinks files={r.files} />
                </div>
                <div className="flex flex-col items-end gap-1 shrink-0">
                  <StatusBadge status={r.status} />
                  {r.status === 'validee' && r.task_status && (
                    <span className="text-xs text-ink-500">{TASK_PROGRESS_LABELS[r.task_status] || r.task_status}</span>
                  )}
                </div>
              </div>
              {canProcess && pending && (
                <div className="flex flex-wrap items-center gap-2 mt-3">
                  <input
                    type="number"
                    min="0.5"
                    step="0.5"
                    placeholder="Temps prévu (h)"
                    className="input w-36 text-sm py-1"
                    value={review.estimatedHours}
                    onChange={(e) => updateReview(r, { estimatedHours: e.target.value })}
                  />
                  <select
                    className="input w-52 text-sm py-1"
                    value={review.assigneeAccountId}
                    onChange={(e) => updateReview(r, { assigneeAccountId: e.target.value })}
                  >
                    <option value="">Assigner à… (facultatif)</option>
                    {team.map((account) => (
                      <option key={account.id} value={account.id}>{account.display_name}</option>
                    ))}
                  </select>
                  <button className="btn-primary text-sm" onClick={() => void valider(r)}>
                    Valider
                  </button>
                  <button className="btn-ghost text-sm" onClick={() => void rejeter(r)}>
                    Rejeter
                  </button>
                </div>
              )}
            </div>
          );
        })}
        {requests.length === 0 && (
          <p className="text-sm text-ink-500">
            {teamView && !project.client_account_id
              ? "Aucun client n'est défini pour ce projet. Choisissez-en un en haut de la page : il recevra le lien pour déposer ses demandes ici."
              : teamView && !canSubmit
                ? `Aucune demande pour l'instant. Les demandes sont rédigées par le client du projet${project.client_name ? ` (${project.client_name})` : ''}.`
                : "Aucune demande pour l'instant."}
          </p>
        )}
      </div>
    </div>
  );
}
