import { useEffect, useState } from 'react';
import { Plus } from 'lucide-react';
import { projectsApi } from './api';
import { useAuth } from '../../context/AuthContext';
import { ProgressBar, StatusBadge } from './ProjectUI';
import type { Account, ProjectListItem } from './types';

export default function ProjectsList({ onOpen }: { onOpen: (id: string) => void }) {
  const { user } = useAuth();
  const isManager = Boolean(user?.isITManager);
  const isClient = !user?.isIT && !user?.isITManager && !user?.isDirector;

  const [projects, setProjects] = useState<ProjectListItem[]>([]);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [clients, setClients] = useState<Account[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({
    name: '',
    description: '',
    type: 'dev',
    clientAccountId: '',
    dueDate: '',
    githubRepoUrl: '',
    developerAssignments: [] as { accountId: string; projectRole: 'contributeur' | 'chef_de_projet' }[],
  });

  async function load() {
    setProjects(await projectsApi.listProjects());
  }

  useEffect(() => {
    setLoading(true);
    Promise.all([
      load(),
      isManager ? projectsApi.listAccounts().then(setAccounts) : Promise.resolve(),
      isManager ? projectsApi.listClients().then(setClients) : Promise.resolve(),
    ]).finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function createProject(e: React.FormEvent) {
    e.preventDefault();
    try {
      await projectsApi.createProject({ ...form, clientAccountId: form.clientAccountId || null });
      setShowForm(false);
      setForm({ name: '', description: '', type: 'dev', clientAccountId: '', dueDate: '', githubRepoUrl: '', developerAssignments: [] });
      void load();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    }
  }

  if (loading) return <div className="p-6 text-ink-500">Chargement...</div>;

  return (
    <div className="p-6 w-full max-w-[1800px] mx-auto">
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-xl font-semibold text-ink-900">{isClient ? 'Mes projets' : 'Projets IT'}</h1>
        {isManager && (
          <button className="btn-primary" onClick={() => setShowForm((s) => !s)}>
            <Plus className="w-4 h-4" /> Nouveau projet
          </button>
        )}
      </div>

      {showForm && (
        <form onSubmit={createProject} className="card p-4 mb-6 space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <input
              className="input"
              placeholder="Nom du projet"
              required
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
            />
            <select className="input" value={form.type} onChange={(e) => setForm({ ...form, type: e.target.value })}>
              <option value="dev">Développement</option>
              <option value="infra">Infrastructure</option>
            </select>
          </div>
          <textarea
            className="input"
            placeholder="Description"
            rows={2}
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
          />
          <div className="grid grid-cols-3 gap-3">
            <select
              className="input"
              value={form.clientAccountId}
              onChange={(e) => setForm({ ...form, clientAccountId: e.target.value })}
            >
              <option value="">Client interne (optionnel)</option>
              {clients.map((client) => (
                <option key={client.id} value={client.id}>
                  {client.display_name} ({client.email})
                </option>
              ))}
            </select>
            <input
              className="input"
              type="date"
              value={form.dueDate}
              onChange={(e) => setForm({ ...form, dueDate: e.target.value })}
            />
            <input
              className="input"
              placeholder="URL dépôt GitHub (optionnel)"
              value={form.githubRepoUrl}
              onChange={(e) => setForm({ ...form, githubRepoUrl: e.target.value })}
            />
          </div>
          <div>
            <p className="text-sm font-medium text-ink-700 mb-2">Développeurs affectés</p>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 border border-ink-200 rounded-lg p-3">
              {accounts.map((account) => {
                const assignment = form.developerAssignments.find((item) => item.accountId === account.id);
                return (
                  <div key={account.id} className="flex items-center gap-2 text-sm text-ink-700">
                    <input
                      type="checkbox"
                      checked={Boolean(assignment)}
                      onChange={(event) => {
                        const developerAssignments = event.target.checked
                          ? [...form.developerAssignments, { accountId: account.id, projectRole: 'contributeur' as const }]
                          : form.developerAssignments.filter((item) => item.accountId !== account.id);
                        setForm({ ...form, developerAssignments });
                      }}
                    />
                    <span className="flex-1">{account.display_name}</span>
                    {assignment && (
                      <select
                        className="input w-40"
                        value={assignment.projectRole}
                        onChange={(event) => setForm({
                          ...form,
                          developerAssignments: form.developerAssignments.map((item) =>
                            item.accountId === account.id
                              ? { ...item, projectRole: event.target.value as 'contributeur' | 'chef_de_projet' }
                              : item
                          ),
                        })}
                      >
                        <option value="contributeur">Développeur</option>
                        <option value="chef_de_projet">Chef de projet</option>
                      </select>
                    )}
                  </div>
                );
              })}
              {accounts.length === 0 && <p className="text-xs text-ink-400">Aucun membre IT disponible.</p>}
            </div>
          </div>
          {clients.length === 0 && <p className="text-xs text-ink-400">Aucun utilisateur Microsoft 365 actif disponible.</p>}
          <div className="flex gap-2">
            <button className="btn-primary">Créer le projet</button>
            <button type="button" className="btn-ghost" onClick={() => setShowForm(false)}>
              Annuler
            </button>
          </div>
        </form>
      )}

      {projects.length === 0 ? (
        <p className="text-sm text-ink-500">Aucun projet pour l'instant.</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {projects.map((p) => (
            <button
              key={p.id}
              onClick={() => onOpen(p.id)}
              className="card p-4 text-left hover:shadow-elevated transition-shadow"
            >
              <div className="flex items-start justify-between">
                <div>
                  <h2 className="font-semibold text-ink-900">{p.name}</h2>
                  <p className="text-sm text-ink-500">{p.type === 'dev' ? 'Développement' : 'Infrastructure'}</p>
                </div>
                <StatusBadge status={p.status} />
              </div>
              {p.description && <p className="text-sm text-ink-600 mt-2 line-clamp-2">{p.description}</p>}
              <div className="mt-3">
                <div className="flex justify-between text-xs text-ink-500 mb-1">
                  <span>Complétude</span>
                  <span>{p.tauxCompletude}%</span>
                </div>
                <ProgressBar value={p.tauxCompletude} />
              </div>
              {!isClient && (
                <p className="text-xs text-ink-400 mt-2">
                  Charge estimée : {p.chargeEstimeeH ?? 0}h — passée : {p.chargePasseeH ?? 0}h
                </p>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
