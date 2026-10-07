import { useEffect, useState } from 'react';
import { ArrowLeft } from 'lucide-react';
import { groupApi, GROUP_MODULE } from './groupApi';
import { ProjectModuleProvider } from '../projects/projectModule';
import { ProgressBar, formatDay } from '../projects/ProjectUI';
import TasksTab from '../projects/tabs/TasksTab';
import GanttTab from '../projects/tabs/GanttTab';
import MeetingsTab from './tabs/MeetingsTab';
import MinutesTab from './tabs/MinutesTab';
import CommunicationsTab from './tabs/CommunicationsTab';
import MembersTab from './tabs/MembersTab';
import { membersAsTeam, type GroupProjectDetail as Detail } from './types';
import type { ProjectDetailData } from '../projects/types';

const TABS: [string, string][] = [
  ['tasks', 'Tâches'],
  ['gantt', 'Gantt'],
  ['meetings', 'Réunions'],
  ['minutes', 'Comptes rendus'],
  ['communications', 'Communications'],
  ['members', 'Membres'],
];

export default function GroupProjectDetail({ projectId, onBack }: { projectId: string; onBack: () => void }) {
  const [project, setProject] = useState<Detail | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState('tasks');
  // Ouverture du compte rendu d'une réunion depuis l'onglet Réunions.
  const [minuteForMeeting, setMinuteForMeeting] = useState<{ id: string; title: string; date: string; minuteId: string | null } | null>(null);

  async function load() {
    try {
      setProject(await groupApi.getProject(projectId));
    } catch (err: any) {
      setError(err.message || 'Projet inaccessible');
    }
  }

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [projectId]);

  async function update(patch: Record<string, unknown>) {
    try {
      await groupApi.updateProject(projectId, patch);
    } catch (err: any) {
      alert(err.message || 'Erreur');
    }
    await load();
  }

  async function remove() {
    if (!project || !confirm(`Supprimer le projet « ${project.name} » ? Il ne sera plus visible par aucun membre.`)) return;
    try {
      await groupApi.deleteProject(projectId);
      onBack();
    } catch (err: any) {
      alert(err.message || 'Erreur lors de la suppression');
    }
  }

  if (error) {
    return (
      <div className="p-6">
        <button onClick={onBack} className="btn-ghost text-sm mb-4 -ml-2"><ArrowLeft className="w-4 h-4" /> Retour aux projets</button>
        <p className="text-sm text-red-600">{error}</p>
      </div>
    );
  }
  if (!project) return <div className="p-6 text-ink-500">Chargement...</div>;

  const team = membersAsTeam(project.members);
  const shared = project as unknown as ProjectDetailData;

  return (
    <ProjectModuleProvider value={GROUP_MODULE}>
      <div className="p-6 w-full max-w-[1800px] mx-auto">
        <button onClick={onBack} className="btn-ghost text-sm mb-4 -ml-2">
          <ArrowLeft className="w-4 h-4" /> Retour aux projets
        </button>

        <div className="card p-5 mb-4">
          <div className="flex flex-wrap justify-between items-start gap-3">
            <div className="min-w-0">
              <h1 className="text-xl font-semibold text-ink-900">
                <span className="text-sm font-mono font-normal text-ink-400 mr-2">{project.ref}</span>
                {project.name}
              </h1>
              {project.description && <p className="text-sm text-ink-500 mt-1 whitespace-pre-wrap">{project.description}</p>}
              {project.estResponsable ? (
                <div className="flex flex-wrap items-center gap-3 mt-2 text-sm text-ink-600">
                  <label className="flex items-center gap-2">
                    Début
                    <input
                      key={`start-${project.start_date ?? ''}`}
                      type="date"
                      className="input py-1 text-sm w-40"
                      defaultValue={project.start_date ?? ''}
                      max={project.due_date ?? undefined}
                      onBlur={(e) => e.target.value !== (project.start_date ?? '') && void update({ startDate: e.target.value || null })}
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
                      onBlur={(e) => e.target.value !== (project.due_date ?? '') && void update({ dueDate: e.target.value || null })}
                    />
                  </label>
                </div>
              ) : (
                (project.start_date || project.due_date) && (
                  <p className="text-sm text-ink-600 mt-2">
                    {project.start_date && <>Début : {formatDay(project.start_date)}</>}
                    {project.start_date && project.due_date && ' · '}
                    {project.due_date && <>Échéance : {formatDay(project.due_date)}</>}
                  </p>
                )
              )}
            </div>
            <div className="flex items-center gap-2">
              <span className={`badge ${project.status === 'closed' ? 'bg-ink-100 text-ink-600' : 'bg-emerald-100 text-emerald-700'}`}>
                {project.status === 'closed' ? 'Clôturé' : 'Actif'}
              </span>
              {project.estResponsable && (
                <>
                  <button
                    className="btn-secondary text-sm"
                    onClick={() => void update({ status: project.status === 'closed' ? 'active' : 'closed' })}
                  >
                    {project.status === 'closed' ? 'Réactiver' : 'Clôturer'}
                  </button>
                  <button className="btn-ghost text-sm text-red-600 hover:text-red-700" onClick={() => void remove()}>
                    Supprimer
                  </button>
                </>
              )}
            </div>
          </div>
          <div className="mt-4">
            <div className="flex justify-between text-xs text-ink-500 mb-1">
              <span>Avancement ({project.tasks.length} tâche{project.tasks.length > 1 ? 's' : ''})</span>
              <span>{project.tauxCompletude}%</span>
            </div>
            <ProgressBar value={project.tauxCompletude} />
          </div>
        </div>

        <div className="flex gap-1 mb-4 border-b border-ink-100 overflow-x-auto">
          {TABS.map(([key, label]) => (
            <button
              key={key}
              onClick={() => setTab(key)}
              className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px whitespace-nowrap transition-colors ${
                tab === key ? 'border-elyade-600 text-elyade-700' : 'border-transparent text-ink-500 hover:text-ink-700'
              }`}
            >
              {label}
            </button>
          ))}
        </div>

        {tab === 'tasks' && <TasksTab project={shared} team={team} onChanged={load} />}
        {tab === 'gantt' && <GanttTab project={shared} team={team} onChanged={load} />}
        {tab === 'meetings' && (
          <MeetingsTab
            project={project}
            onWriteMinutes={(meeting) => {
              setMinuteForMeeting({ id: meeting.id, title: meeting.title, date: meeting.start_at.slice(0, 10), minuteId: meeting.minute_id });
              setTab('minutes');
            }}
          />
        )}
        {tab === 'minutes' && (
          <MinutesTab project={project} prefillMeeting={minuteForMeeting} onPrefillUsed={() => setMinuteForMeeting(null)} />
        )}
        {tab === 'communications' && <CommunicationsTab project={project} />}
        {tab === 'members' && <MembersTab project={project} onChanged={load} />}
      </div>
    </ProjectModuleProvider>
  );
}
