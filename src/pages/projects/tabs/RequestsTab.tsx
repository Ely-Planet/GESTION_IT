import { useEffect, useState } from 'react';
import { projectsApi } from '../api';
import { StatusBadge } from '../ProjectUI';
import { useAuth } from '../../../context/AuthContext';
import type { ClientRequest, ProjectDetailData } from '../types';

export default function RequestsTab({
  project,
  onChanged,
}: {
  project: ProjectDetailData;
  onChanged: () => void;
}) {
  const { user } = useAuth();
  const isClient = !user?.isIT && !user?.isITManager && !user?.isDirector;
  const [requests, setRequests] = useState<ClientRequest[]>([]);
  const [newRequest, setNewRequest] = useState({ title: '', description: '' });
  const [estimations, setEstimations] = useState<Record<string, string>>({});

  async function load() {
    if (isClient) {
      setRequests(project.clientRequests || []);
    } else {
      setRequests(await projectsApi.listRequests(project.id));
    }
  }

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [project.id]);

  async function submitRequest(e: React.FormEvent) {
    e.preventDefault();
    try {
      await projectsApi.createRequest({ projectId: project.id, ...newRequest });
      setNewRequest({ title: '', description: '' });
      void load();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    }
  }

  async function valider(id: string) {
    const estimatedHours = Number(estimations[id]);
    if (!estimatedHours || estimatedHours <= 0) {
      alert('Merci de saisir une prévision de temps (heures) avant de valider.');
      return;
    }
    try {
      await projectsApi.validateRequest(id, estimatedHours);
      void load();
      onChanged();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    }
  }

  async function rejeter(id: string) {
    await projectsApi.rejectRequest(id);
    void load();
  }

  return (
    <div>
      <h3 className="font-semibold text-ink-900 mb-3">Demandes client</h3>

      {isClient && (
        <form onSubmit={submitRequest} className="card p-4 mb-4 space-y-2">
          <p className="label mb-0">Nouvelle demande</p>
          <input
            className="input"
            placeholder="Titre"
            required
            value={newRequest.title}
            onChange={(e) => setNewRequest({ ...newRequest, title: e.target.value })}
          />
          <textarea
            className="input"
            placeholder="Description"
            rows={2}
            value={newRequest.description}
            onChange={(e) => setNewRequest({ ...newRequest, description: e.target.value })}
          />
          <button className="btn-primary text-sm">Envoyer la demande</button>
        </form>
      )}

      <div className="space-y-2">
        {requests.map((r) => (
          <div key={r.id} className="card p-4">
            <div className="flex justify-between items-start">
              <div>
                <p className="font-medium text-ink-900">{r.title}</p>
                {r.description && <p className="text-sm text-ink-500">{r.description}</p>}
              </div>
              <StatusBadge status={r.status} />
            </div>
            {!isClient && r.status === 'en_attente' && (
              <div className="flex items-center gap-2 mt-3">
                <input
                  type="number"
                  min="0.5"
                  step="0.5"
                  placeholder="Temps prévu (h)"
                  className="input w-36 text-sm py-1"
                  onChange={(e) => setEstimations({ ...estimations, [r.id]: e.target.value })}
                />
                <button className="btn-primary text-sm" onClick={() => valider(r.id)}>
                  Valider
                </button>
                <button className="btn-ghost text-sm" onClick={() => rejeter(r.id)}>
                  Rejeter
                </button>
              </div>
            )}
          </div>
        ))}
        {requests.length === 0 && <p className="text-sm text-ink-500">Aucune demande pour l'instant.</p>}
      </div>
    </div>
  );
}
