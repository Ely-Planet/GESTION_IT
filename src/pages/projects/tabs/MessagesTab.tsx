import { useEffect, useRef, useState } from 'react';
import { projectsApi } from '../api';
import { useAuth } from '../../../context/AuthContext';
import type { ProjectMessage } from '../types';

export default function MessagesTab({ projectId }: { projectId: string }) {
  const { user } = useAuth();
  const [messages, setMessages] = useState<ProjectMessage[]>([]);
  const [content, setContent] = useState('');
  const fileInput = useRef<HTMLInputElement>(null);

  async function load() {
    setMessages(await projectsApi.listMessages(projectId));
  }

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [projectId]);

  async function send(e: React.FormEvent) {
    e.preventDefault();
    if (!content.trim()) return;
    try {
      const message = await projectsApi.sendMessage({ projectId, content });
      const file = fileInput.current?.files?.[0];
      if (file) {
        const data = new FormData();
        data.append('file', file);
        data.append('messageId', message.id);
        data.append('projectId', projectId);
        await projectsApi.uploadFile(data);
        if (fileInput.current) fileInput.current.value = '';
      }
      setContent('');
      void load();
    } catch (err: any) {
      alert(err.message || 'Erreur');
    }
  }

  return (
    <div>
      <h3 className="font-semibold text-ink-900 mb-3">Échanges</h3>
      <div className="space-y-3 mb-4 max-h-96 overflow-y-auto">
        {messages.map((m) => (
          <div key={m.id} className={`card p-4 ${m.author_account_id === user?.id ? 'bg-elyade-50/60 border-elyade-100' : ''}`}>
            <div className="flex justify-between text-xs text-ink-400 mb-1">
              <span className="font-medium text-ink-600">{m.author_name}</span>
              <span>{new Date(m.created_at).toLocaleString('fr-FR')}</span>
            </div>
            <p className="text-sm text-ink-800">{m.content}</p>
            {m.recipient_type === 'client' && (
              <p className="text-xs text-ink-400 mt-1">{m.email_sent ? 'E-mail envoyé au client' : "E-mail non envoyé"}</p>
            )}
            {m.files?.map((f) => (
              <a key={f.id} href={`/api/projects/files/${f.id}/download`} className="text-xs text-elyade-600 underline block mt-1">
                📎 {f.filename}
              </a>
            ))}
          </div>
        ))}
        {messages.length === 0 && <p className="text-sm text-ink-500">Aucun message pour l'instant.</p>}
      </div>

      <form onSubmit={send} className="card p-4 space-y-2">
        <textarea
          className="input"
          rows={2}
          placeholder="Écrire un message..."
          value={content}
          onChange={(e) => setContent(e.target.value)}
        />
        <div className="flex justify-between items-center">
          <input type="file" ref={fileInput} className="text-sm" />
          <button className="btn-primary text-sm">Envoyer</button>
        </div>
      </form>
    </div>
  );
}
