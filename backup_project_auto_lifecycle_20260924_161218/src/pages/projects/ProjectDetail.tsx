import { useEffect, useState } from 'react';
import { ArrowLeft } from 'lucide-react';
import { projectsApi } from './api';
import { useAuth } from '../../context/AuthContext';
import { ProgressBar, StatusBadge } from './ProjectUI';
import TasksTab from './tabs/TasksTab';
import RequestsTab from './tabs/RequestsTab';
import MessagesTab from './tabs/MessagesTab';
import TeamTab from './tabs/TeamTab';
import type { Account, ProjectDetailData } from './types';

export default function ProjectDetail({ projectId, onBack }: { projectId: string; onBack: () => void }) {
  const { user } = useAuth();
  const [project, setProject] = useState<ProjectDetailData | null>(null);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [tab, setTab] = useState('tasks');

  const isManager = Boolean(user?.isITManager);
  const isClient = !user?.isIT && !user?.isITManager && !user?.isDirector;

  async function load() {
    setProject(await projectsApi.getProject(projectId));
  }

  async function changeProjectState(projectState: 'active' | 'maintenance' | 'closed') {
    const response = await fetch(`/api/projects/${projectId}/state`, {
      method: 'PUT',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ projectState }),
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(payload.error || 'Erreur lors du changement d’état');
    await load();
  }

  useEffect(() => {
    void load();
    if (isManager || user?.isIT) {
      projectsApi.listAccounts().then(setAccounts).catch(() => {});
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [projectId]);

  if (!project) return <div className="p-6 text-ink-500">Chargement...</div>;

  const canManageTeam = isManager || Boolean(project.estChefDeProjet);

  const tabs: [string, string][] = isClient
    ? [
        ['requests', 'Mes demandes'],
        ['messages', 'Échanges'],
      ]
    : [
        ['tasks', 'Tâches'],
        ['requests', 'Demandes clients'],
        ['messages', 'Échanges'],
        ['team', 'Équipe'],
      ];

  return (
    <div className="p-6 w-full max-w-[1800px] mx-auto">
      <button onClick={onBack} className="btn-ghost text-sm mb-4 -ml-2">
        <ArrowLeft className="w-4 h-4" /> Retour aux projets
      </button>

      <div className="card p-5 mb-4">
        <div className="flex justify-between items-start">
          <div>
            <h1 className="text-xl font-semibold text-ink-900">{project.name}</h1>
            {project.description && <p className="text-sm text-ink-500 mt-1">{project.description}</p>}
          </div>
          <div className="flex items-center gap-2">
            {isManager && (
              <select
                className="input py-1 text-sm w-36"
                value={project.project_state || 'active'}
                onChange={(event) => {
                  const nextState = event.target.value as 'active' | 'maintenance' | 'closed';
                  const label = nextState === 'closed' ? 'clôturer' : nextState === 'maintenance' ? 'mettre en maintenance' : 'réactiver';
                  if (confirm(`Voulez-vous ${label} ce projet ?`)) {
                    void changeProjectState(nextState).catch((error) => alert(error.message));
                  }
                }}
              >
                <option value="active">Actif</option>
                <option value="maintenance">Maintenance</option>
                <option value="closed">Clôturé</option>
              </select>
            )}
            <StatusBadge status={project.status} />
          </div>
        </div>
        <div className="mt-4">
          <div className="flex justify-between text-xs text-ink-500 mb-1">
            <span>Taux de complétude</span>
            <span>{project.tauxCompletude}%</span>
          </div>
          <ProgressBar value={project.tauxCompletude} />
        </div>
        {!isClient && (
          <p className="text-xs text-ink-400 mt-2">
            Charge estimée : {project.chargeEstimeeH}h · Charge passée : {project.chargePasseeH}h
            {project.github_repo_url && <> · Dépôt GitHub lié</>}
          </p>
        )}
      </div>

      <div className="flex gap-1 mb-4 border-b border-ink-100">
        {tabs.map(([key, label]) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px transition-colors ${
              tab === key ? 'border-elyade-600 text-elyade-700' : 'border-transparent text-ink-500 hover:text-ink-700'
            }`}
          >
            {label}
          </button>
        ))}
      </div>

      {tab === 'tasks' && !isClient && <TasksTab project={project} team={accounts} onChanged={load} />}
      {tab === 'requests' && <RequestsTab project={project} onChanged={load} />}
      {tab === 'messages' && <MessagesTab projectId={project.id} />}
      {tab === 'team' && !isClient && (
        <TeamTab project={project} allAccounts={accounts} canManage={canManageTeam} onChanged={load} />
      )}
    </div>
  );
}
