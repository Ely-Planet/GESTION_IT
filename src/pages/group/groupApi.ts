import { request } from '../projects/api';
import type { ProjectModuleConfig } from '../projects/projectModule';

const BASE = '/api/group-projects';
const json = (method: string, body: unknown): RequestInit => ({ method, body: JSON.stringify(body) });

export const groupApi = {
  access: () => request(`${BASE}/access`),
  accounts: () => request(`${BASE}/accounts`),

  listProjects: () => request(BASE),
  getProject: (id: string) => request(`${BASE}/${id}`),
  createProject: (body: unknown) => request(BASE, json('POST', body)),
  updateProject: (id: string, body: unknown) => request(`${BASE}/${id}`, json('PUT', body)),
  deleteProject: (id: string) => request(`${BASE}/${id}`, { method: 'DELETE' }),

  addMember: (id: string, accountId: string, role = 'membre') => request(`${BASE}/${id}/members`, json('POST', { accountId, role })),
  setMemberRole: (id: string, accountId: string, role: string) => request(`${BASE}/${id}/members/${accountId}`, json('PUT', { role })),
  removeMember: (id: string, accountId: string) => request(`${BASE}/${id}/members/${accountId}`, { method: 'DELETE' }),

  // Mêmes formes que l'API Projets IT : utilisées par les onglets partagés.
  createTask: (formData: FormData) => request(`${BASE}/tasks`, { method: 'POST', body: formData }),
  updateTask: (id: string, body: unknown) => request(`${BASE}/tasks/${id}`, json('PUT', body)),
  deleteTask: (id: string) => request(`${BASE}/tasks/${id}`, { method: 'DELETE' }),
  addTaskFiles: (taskId: string, formData: FormData) => request(`${BASE}/tasks/${taskId}/files`, { method: 'POST', body: formData }),
  listTaskComments: (taskId: string) => request(`${BASE}/tasks/${taskId}/comments`),
  addTaskComment: (taskId: string, body: string) => request(`${BASE}/tasks/${taskId}/comments`, json('POST', { body })),
  createSubtask: (taskId: string, body: unknown) => request(`${BASE}/tasks/${taskId}/subtasks`, json('POST', body)),
  updateSubtask: (id: string, body: unknown) => request(`${BASE}/subtasks/${id}`, json('PUT', body)),
  deleteSubtask: (id: string) => request(`${BASE}/subtasks/${id}`, { method: 'DELETE' }),

  listMinutes: (id: string) => request(`${BASE}/${id}/minutes`),
  createMinute: (id: string, body: unknown) => request(`${BASE}/${id}/minutes`, json('POST', body)),
  updateMinute: (minuteId: string, body: unknown) => request(`${BASE}/minutes/${minuteId}`, json('PUT', body)),
  deleteMinute: (minuteId: string) => request(`${BASE}/minutes/${minuteId}`, { method: 'DELETE' }),

  listCommunications: (id: string) => request(`${BASE}/${id}/communications`),
  syncCommunications: (id: string) => request(`${BASE}/${id}/communications/sync`, { method: 'POST' }),
  sendMail: (id: string, body: { recipientIds: string[]; subject: string; body: string }) => request(`${BASE}/${id}/mails`, json('POST', body)),

  listMeetings: (id: string) => request(`${BASE}/${id}/meetings`),
  createMeeting: (id: string, body: unknown) => request(`${BASE}/${id}/meetings`, json('POST', body)),
  updateMeeting: (meetingId: string, body: unknown) => request(`${BASE}/meetings/${meetingId}`, json('PUT', body)),
  cancelMeeting: (meetingId: string) => request(`${BASE}/meetings/${meetingId}`, { method: 'DELETE' }),
};

// Configuration des onglets partagés (Tâches, Gantt, détail) pour Projets Groupe.
export const GROUP_MODULE: ProjectModuleConfig = {
  api: groupApi,
  filesBase: `${BASE}/files`,
  statusLabels: {
    backlog: 'À faire',
    ready: 'Prêt',
    in_progress: 'En cours',
    in_review: 'En validation',
    done: 'Terminé',
  },
  columns: {
    backlog: { title: 'À FAIRE', subtitle: 'Non démarré' },
    ready: { title: 'PRÊT', subtitle: 'Prêt à démarrer' },
    in_progress: { title: 'EN COURS', subtitle: 'En cours de réalisation' },
    in_review: { title: 'EN VALIDATION', subtitle: 'À valider' },
    done: { title: 'TERMINÉ', subtitle: 'Terminé' },
  },
  github: false,
  timeTracking: false,
  subtasksNote: '',
};
