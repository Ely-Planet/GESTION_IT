import { useEffect, useState } from 'react';
import { ArrowLeft } from 'lucide-react';
import { projectsApi } from './api';
import { useAuth } from '../../context/AuthContext';
import { ProgressBar, formatDay } from './ProjectUI';
import TasksTab from './tabs/TasksTab';
import GanttTab from './tabs/GanttTab';
import RequestsTab from './tabs/RequestsTab';
import TeamTab from './tabs/TeamTab';
import ClientsEditor from './ClientsEditor';
import type { Account, ProjectDetailData } from './types';

export default function ProjectDetail({ projectId, onBack }: { projectId: string; onBack: () => void }) {
  const { user } = useAuth();
  const isManager = Boolean(user?.isITManager);

  const [project, setProject] = useState<ProjectDetailData | null>(null);
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [clients, setClients] = useState<Account[]>([]);
  const [sendingLink, setSendingLink] = useState(false);
  const [tab, setTab] = useState('tasks');

  async function load() {
    setProject(await projectsApi.getProject(projectId));
  }

  async function changeProjectState(projectState: 'new' | 'closed') {
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

  async function deleteProject() {
    const response = await fetch(`/api/projects/${projectId}`, {
      method: 'DELETE',
      credentials: 'include',
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(payload.error || 'Erreur lors de la suppression');
    onBack();
  }

  async function addClient(clientAccountId: string) {
    try {
      const result = await projectsApi.addClient(projectId, clientAccountId);
      if (result?.client_link_sent === false) {
        alert("Client ajouté, mais l'e-mail avec le lien du projet n'a pas pu être envoyé.");
      }
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'ajout du client");
    }
    await load();
  }

  async function removeClient(accountId: string) {
    const name = project?.clients?.find((c) => c.account_id === accountId)?.display_name || 'ce client';
    if (!confirm(`Retirer ${name} des clients du projet ? Il n'y aura plus accès.`)) return;
    try {
      await projectsApi.removeClient(projectId, accountId);
    } catch (err: any) {
      alert(err.message || 'Erreur lors du retrait du client');
    }
    await load();
  }

  async function changeDates(patch: { startDate?: string | null; dueDate?: string | null }) {
    try {
      await projectsApi.updateProject(projectId, patch);
    } catch (err: any) {
      alert(err.message || 'Erreur lors de la mise à jour des dates');
    }
    await load();
  }

  async function sendClientLink() {
    setSendingLink(true);
    try {
      await projectsApi.sendClientLink(projectId);
      alert('Le lien du projet a été envoyé aux clients.');
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'envoi du lien");
    } finally {
      setSendingLink(false);
    }
  }

  useEffect(() => {
    void load();
    if (isManager || user?.isIT) {
      projectsApi.listAccounts().then(setAccounts).catch(() => {});
    }
    if (isManager) {
      projectsApi.listClients().then(setClients).catch(() => {});
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [projectId]);

  if (!project) return <div className="p-6 text-ink-500">Chargement...</div>;

  const canManageTeam = isManager || Boolean(project.estChefDeProjet);
  // Vue client : tâches et Gantt en lecture seule, plus ses demandes.
  const clientView = Boolean(project.clientView);
  const projectClients = project.clients || [];

  const tabs: [string, string][] = clientView
    ? [
        ['tasks', 'Tâches'],
        ['gantt', 'Gantt'],
        ['requests', 'Demandes'],
      ]
    : [
        ['tasks', 'Tâches'],
        ['gantt', 'Gantt'],
        ['requests', 'Demandes clients'],
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
            {isManager ? (
              <div className="flex flex-wrap items-center gap-3 mt-2 text-sm text-ink-600">
                <label className="flex items-center gap-2">
                  Début
                  <input
                    key={`start-${project.start_date ?? ''}`}
                    type="date"
                    className="input py-1 text-sm w-40"
                    defaultValue={project.start_date ?? ''}
                    max={project.due_date ?? undefined}
                    onBlur={(e) => {
                      if (e.target.value !== (project.start_date ?? '')) void changeDates({ startDate: e.target.value || null });
                    }}
                  />
                </label>
                <label className="flex items-center gap-2">
                  Échéance
                  <input
                    key={`due-${project.due_date ?? ''}`}
                    type="date"
                    className="input py-1 text-sm w-40"
                    defaultValue={project.due_date ?? ''}
                    min={project.start_date ?? undefined}
                    onBlur={(e) => {
                      if (e.target.value !== (project.due_date ?? '')) void changeDates({ dueDate: e.target.value || null });
                    }}
                  />
                </label>
              </div>
            ) : (project.start_date || project.due_date) && (
              <p className="text-sm text-ink-600 mt-2">
                {project.start_date && <>Début : {formatDay(project.start_date)}</>}
                {project.start_date && project.due_date && ' · '}
                {project.due_date && <>Échéance : {formatDay(project.due_date)}</>}
              </p>
            )}
          </div>
          <div className="flex items-center gap-2 flex-wrap justify-end">
            <span className={`badge ${
              project.project_state === 'closed'
                ? 'bg-ink-100 text-ink-600'
                : project.project_state === 'maintenance'
                  ? 'bg-amber-100 text-amber-700'
                  : project.project_state === 'in_progress'
                    ? 'bg-emerald-100 text-emerald-700'
                    : 'bg-blue-100 text-blue-700'
            }`}>
              {project.project_state === 'closed'
                ? 'Clôturé'
                : project.project_state === 'maintenance'
                  ? 'Maintenance'
                  : project.project_state === 'in_progress'
                    ? 'En cours'
                    : 'Nouveau'}
            </span>

            {isManager && project.project_state !== 'closed' && (
              <button
                className="btn-secondary text-sm"
                onClick={() => {
                  if (confirm('Clôturer ce projet ? Il sera masqué de la liste principale.')) {
                    void changeProjectState('closed').catch((error) => alert(error.message));
                  }
                }}
              >
                Clôturer
              </button>
            )}
            {isManager && project.project_state === 'closed' && (
              <button
                className="btn-secondary text-sm"
                onClick={() => {
                  if (confirm('Réactiver ce projet ? Son état sera recalculé depuis ses tâches.')) {
                    void changeProjectState('new').then(load).catch((error) => alert(error.message));
                  }
                }}
              >
                Réactiver
              </button>
            )}
            {isManager && (
              <button
                className="btn-ghost text-sm text-red-600 hover:text-red-700"
                onClick={() => {
                  if (confirm(`Supprimer définitivement le projet "${project.name}" et toutes ses données ? Cette action est irréversible.`)) {
                    void deleteProject().catch((error) => alert(error.message));
                  }
                }}
              >
                Supprimer
              </button>
            )}
          </div>
        </div>
        <div className="mt-4">
          <div className="flex justify-between text-xs text-ink-500 mb-1">
            <span>Taux de complétude</span>
            <span>{project.tauxCompletude}%</span>
          </div>
          <ProgressBar value={project.tauxCompletude} />
        </div>
        {!clientView && (
          <p className="text-xs text-ink-400 mt-2">
            Charge estimée : {project.chargeEstimeeH}h · Charge passée : {project.chargePasseeH}h
            {project.github_project_url && (
              <> · <a href={project.github_project_url} target="_blank" rel="noreferrer" className="text-elyade-700 hover:underline">Tableau GitHub</a></>
            )}
            {!project.github_project_url && project.github_repo_url && <> · Dépôt GitHub lié</>}
          </p>
        )}
        {canManageTeam && (
          <div className="flex flex-wrap items-center gap-2 mt-3 pt-3 border-t border-ink-100">
            <span className="text-sm text-ink-600">{projectClients.length > 1 ? 'Clients :' : 'Client :'}</span>
            {isManager ? (
              <ClientsEditor
                clients={clients}
                selected={projectClients.map((c) => ({ id: c.account_id, label: c.display_name, email: c.email }))}
                onAdd={(clientAccountId) => void addClient(clientAccountId)}
                onRemove={(accountId) => void removeClient(accountId)}
              />
            ) : (
              <span className="text-sm text-ink-900">{project.client_name || 'Aucun client'}</span>
            )}
            {projectClients.length > 0 && (
              <button className="btn-ghost text-sm" disabled={sendingLink} onClick={() => void sendClientLink()}>
                {sendingLink ? 'Envoi…' : projectClients.length > 1 ? 'Renvoyer le lien aux clients' : 'Renvoyer le lien au client'}
              </button>
            )}
            {isManager && <span className="text-xs text-ink-400">Chaque client ajouté reçoit le lien du projet par e-mail. Les clients voient les tâches sans pouvoir les modifier.</span>}
          </div>
        )}
      </div>

      <>
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

          {tab === 'tasks' && <TasksTab project={project} team={accounts} onChanged={load} readOnly={clientView} />}
          {tab === 'gantt' && <GanttTab project={project} team={accounts} onChanged={load} readOnly={clientView} />}
          {tab === 'requests' && <RequestsTab project={project} team={accounts} onChanged={load} />}
          {tab === 'team' && !clientView && (
            <TeamTab project={project} allAccounts={accounts} canManage={canManageTeam} onChanged={load} />
          )}
      </>
    </div>
  );
}
