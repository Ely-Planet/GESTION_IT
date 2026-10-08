import { createContext, useContext } from 'react';
import { projectsApi } from './api';
import { STATUS_LABELS, type TaskComment } from './types';

// Les onglets Tâches, Gantt et le détail des tâches servent à deux modules :
// Projets IT (GitHub, clients, temps passé) et Projets Groupe (en français,
// sans GitHub). Le module fournit son API, ses libellés et ses options.
export type TaskStatusKey = 'backlog' | 'ready' | 'in_progress' | 'in_review' | 'done';

export type ProjectModuleApi = {
  createTask: (formData: FormData) => Promise<unknown>;
  updateTask: (id: string, body: unknown) => Promise<unknown>;
  deleteTask: (id: string) => Promise<unknown>;
  addTaskFiles: (taskId: string, formData: FormData) => Promise<unknown>;
  listTaskComments: (taskId: string) => Promise<{ comments: TaskComment[]; githubError: string | null }>;
  addTaskComment: (taskId: string, body: string) => Promise<TaskComment>;
  createSubtask: (taskId: string, body: unknown) => Promise<unknown>;
  updateSubtask: (id: string, body: unknown) => Promise<unknown>;
  deleteSubtask: (id: string) => Promise<unknown>;
};

export type ProjectModuleConfig = {
  api: ProjectModuleApi;
  filesBase: string; // préfixe des téléchargements de pièces jointes
  // Projets Groupe : colonnes du Kanban personnalisables par projet (clés libres).
  statusLabels: Record<TaskStatusKey, string> & Record<string, string>;
  columns: Record<TaskStatusKey, { title: string; subtitle: string }> & Record<string, { title: string; subtitle: string }>;
  columnOrder?: string[]; // ordre des colonnes ; à défaut, les 5 statuts standard
  github: boolean; // liens et synchronisation GitHub
  timeTracking: boolean; // saisie du temps passé / estimé
  subtasksNote: string;
};

export const IT_MODULE: ProjectModuleConfig = {
  api: projectsApi,
  filesBase: '/api/projects/files',
  statusLabels: STATUS_LABELS as Record<TaskStatusKey, string>,
  columns: {
    backlog: { title: 'BACKLOG', subtitle: 'Non démarré' },
    ready: { title: 'READY', subtitle: 'Prêt à démarrer' },
    in_progress: { title: 'IN PROGRESS', subtitle: 'En cours' },
    in_review: { title: 'IN REVIEW', subtitle: 'En revue' },
    done: { title: 'DONE', subtitle: 'Terminé' },
  },
  github: true,
  timeTracking: true,
  subtasksNote: "Internes : le client n'est pas prévenu",
};

const ProjectModuleContext = createContext<ProjectModuleConfig>(IT_MODULE);

export const ProjectModuleProvider = ProjectModuleContext.Provider;

export function useProjectModule() {
  return useContext(ProjectModuleContext);
}
