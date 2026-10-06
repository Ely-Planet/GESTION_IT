import { useEffect, useState } from 'react';
import { Bell, CheckCheck } from 'lucide-react';
import { projectsApi } from '../pages/projects/api';
import type { AppNotification } from '../pages/projects/types';

// Notifications de l'utilisateur (tâche affectée ou en retard, nouvelle demande client),
// affichées en haut de sa page d'accueil.
export default function NotificationsPanel({ onOpenProject }: { onOpenProject: (projectId: string) => void }) {
  const [notifications, setNotifications] = useState<AppNotification[]>([]);

  async function load() {
    try {
      setNotifications(await projectsApi.listNotifications());
    } catch {
      setNotifications([]);
    }
  }

  useEffect(() => {
    void load();
    const timer = window.setInterval(() => void load(), 60 * 1000);
    return () => window.clearInterval(timer);
  }, []);

  const unread = notifications.filter((n) => !n.read_at);
  if (unread.length === 0) return null;

  async function open(notification: AppNotification) {
    await projectsApi.markNotificationRead(notification.id).catch(() => {});
    setNotifications((current) => current.filter((n) => n.id !== notification.id));
    if (notification.project_id) onOpenProject(notification.project_id);
  }

  async function markAllRead() {
    await projectsApi.markAllNotificationsRead().catch(() => {});
    setNotifications([]);
  }

  return (
    <div className="px-6 pt-6 w-full max-w-[1800px] mx-auto">
      <div className="card p-4 border-l-4 border-elyade-600">
        <div className="flex items-center justify-between mb-2">
          <h2 className="flex items-center gap-2 font-semibold text-ink-900">
            <Bell className="w-4 h-4 text-elyade-600" />
            {unread.length === 1 ? '1 nouvelle notification' : `${unread.length} nouvelles notifications`}
          </h2>
          <button type="button" className="btn-ghost text-xs" onClick={() => void markAllRead()}>
            <CheckCheck className="w-3.5 h-3.5" /> Tout marquer comme lu
          </button>
        </div>
        <ul className="divide-y divide-ink-100">
          {unread.map((notification) => (
            <li key={notification.id}>
              <button
                type="button"
                className="w-full text-left py-2 flex items-start justify-between gap-3 hover:bg-ink-50 rounded px-1"
                onClick={() => void open(notification)}
              >
                <span className="min-w-0">
                  <span className="block text-sm font-medium text-ink-900 truncate">{notification.title}</span>
                  {notification.body && <span className="block text-xs text-ink-500 truncate">{notification.body}</span>}
                </span>
                <span className="text-xs text-ink-400 shrink-0">
                  {new Date(notification.created_at).toLocaleString('fr-FR', { dateStyle: 'short', timeStyle: 'short' })}
                </span>
              </button>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
