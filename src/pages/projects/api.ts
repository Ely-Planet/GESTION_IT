async function request(url: string, options: RequestInit = {}) {
  // Pour un FormData, le navigateur doit poser lui-même le Content-Type multipart.
  const isJsonBody = options.body !== undefined && !(options.body instanceof FormData);
  const res = await fetch(url, {
    credentials: 'include',
    headers: isJsonBody ? { 'Content-Type': 'application/json' } : undefined,
    ...options,
  });

  if (!res.ok) {
    let message = `Erreur ${res.status}`;
    try {
      const data = await res.json();
      if (data?.error) message = data.error;
    } catch {
      // réponse non-JSON, on garde le message par défaut
    }
    throw new Error(message);
  }

  if (res.status === 204) return null;
  return res.json();
}

export const projectsApi = {
  listProjects: () => request('/api/projects'),
  getProject: (id: string) => request(`/api/projects/${id}`),
  createProject: (body: unknown) => request('/api/projects', { method: 'POST', body: JSON.stringify(body) }),
  updateProject: (id: string, body: unknown) => request(`/api/projects/${id}`, { method: 'PUT', body: JSON.stringify(body) }),
  archiveProject: (id: string) => request(`/api/projects/${id}`, { method: 'DELETE' }),

  listAccounts: () => request('/api/projects/accounts'),
  listClients: () => request('/api/projects/clients'),
  updateCapacity: (accountId: string, weeklyCapacityHours: number) =>
    request(`/api/projects/accounts/${accountId}/capacity`, { method: 'PUT', body: JSON.stringify({ weeklyCapacityHours }) }),

  assign: (projectId: string, accountId: string, projectRole: string) =>
    request(`/api/projects/${projectId}/assignments`, { method: 'POST', body: JSON.stringify({ accountId, projectRole }) }),
  unassign: (projectId: string, accountId: string) =>
    request(`/api/projects/${projectId}/assignments/${accountId}`, { method: 'DELETE' }),

  sendClientLink: (projectId: string) => request(`/api/projects/${projectId}/send-client-link`, { method: 'POST' }),

  createTask: (body: unknown) => request('/api/projects/tasks', { method: 'POST', body: JSON.stringify(body) }),
  updateTask: (id: string, body: unknown) => request(`/api/projects/tasks/${id}`, { method: 'PUT', body: JSON.stringify(body) }),
  deleteTask: (id: string) => request(`/api/projects/tasks/${id}`, { method: 'DELETE' }),
  listTaskComments:(taskId: string) => request(`/api/projects/tasks/${taskId}/comments`),
  addTaskComment: (taskId: string, body: string) =>
    request(`/api/projects/tasks/${taskId}/comments`, { method: 'POST', body: JSON.stringify({ body }) }),

  listRequests: (projectId: string) => request(`/api/projects/${projectId}/requests`),
  // multipart : titre, description et jusqu'à 10 pièces jointes (champ "files")
  createRequest: (formData: FormData) => request('/api/projects/requests', { method: 'POST', body: formData }),
  validateRequest: (
    id: string,
    body: { estimatedHours: number; title: string; description: string; assigneeAccountId: string | null }
  ) => request(`/api/projects/requests/${id}/valider`, { method: 'POST', body: JSON.stringify(body) }),
  rejectRequest: (id: string, reason: string) =>
    request(`/api/projects/requests/${id}/rejeter`, { method: 'POST', body: JSON.stringify({ reason }) }),

  listNotifications: () => request('/api/notifications'),
  markNotificationRead: (id: string) => request(`/api/notifications/${id}/read`, { method: 'POST' }),
  markAllNotificationsRead: () => request('/api/notifications/read-all', { method: 'POST' }),

  listMessages: (projectId: string) => request(`/api/projects/${projectId}/messages`),
  sendMessage: (body: unknown) => request('/api/projects/messages', { method: 'POST', body: JSON.stringify(body) }),

  uploadFile: async (formData: FormData) => {
    const res = await fetch('/api/projects/files', { method: 'POST', credentials: 'include', body: formData });
    if (!res.ok) throw new Error('Échec de l\u2019envoi du fichier');
    return res.json();
  },

  dashboard: () => request('/api/projects-dashboard'),
  reporting: () => request('/api/projects-reporting'),
};
