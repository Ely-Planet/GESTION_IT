import { useEffect, useMemo, useState } from 'react';
import { Mail, Paperclip, RefreshCw, Reply, Send } from 'lucide-react';
import { groupApi } from '../groupApi';
import { useAuth } from '../../../context/AuthContext';
import type { GroupMessage, GroupProjectDetail } from '../types';

const formatSentAt = (value: string) =>
  new Date(value).toLocaleString('fr-FR', { dateStyle: 'short', timeStyle: 'short', timeZone: 'Europe/Paris' });

// Mails envoyés depuis le projet (depuis la boîte de l'expéditeur) et leurs
// réponses, relevées automatiquement toutes les 5 minutes.
export default function CommunicationsTab({ project }: { project: GroupProjectDetail }) {
  const { user } = useAuth();
  const [messages, setMessages] = useState<GroupMessage[]>([]);
  const [loading, setLoading] = useState(true);
  const [syncing, setSyncing] = useState(false);
  const [composing, setComposing] = useState(false);
  const [recipientIds, setRecipientIds] = useState<string[]>([]);
  const [subject, setSubject] = useState('');
  const [body, setBody] = useState('');
  const [sending, setSending] = useState(false);

  const others = project.members.filter((m) => m.account_id !== user?.id && m.email);

  async function load() {
    setMessages(await groupApi.listCommunications(project.id));
  }

  useEffect(() => {
    load().catch(() => setMessages([])).finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [project.id]);

  // Une conversation = le mail envoyé et ses réponses, du plus récent au plus ancien.
  const threads = useMemo(() => {
    const byConversation = new Map<string, GroupMessage[]>();
    for (const message of messages) {
      const list = byConversation.get(message.conversation_id) || [];
      list.push(message);
      byConversation.set(message.conversation_id, list);
    }
    return [...byConversation.values()]
      .map((list) => list.sort((a, b) => a.sent_at.localeCompare(b.sent_at)))
      .sort((a, b) => b[b.length - 1].sent_at.localeCompare(a[a.length - 1].sent_at));
  }, [messages]);

  async function refresh() {
    setSyncing(true);
    try {
      await groupApi.syncCommunications(project.id);
      await load();
    } catch (err: any) {
      alert(err.message || 'Relève impossible');
    } finally {
      setSyncing(false);
    }
  }

  async function send(e: React.FormEvent) {
    e.preventDefault();
    if (!recipientIds.length) {
      alert('Choisissez au moins un destinataire.');
      return;
    }
    setSending(true);
    try {
      await groupApi.sendMail(project.id, { recipientIds, subject, body });
      setComposing(false);
      setRecipientIds([]);
      setSubject('');
      setBody('');
      await load();
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'envoi");
    } finally {
      setSending(false);
    }
  }

  return (
    <div className="max-w-4xl">
      <div className="flex flex-wrap items-center justify-between gap-2 mb-4">
        <div>
          <h3 className="font-semibold text-ink-900">Communications</h3>
          <p className="text-xs text-ink-500">
            Le mail part de votre boîte Outlook. Les réponses (y compris « Répondre à tous ») sont rangées ici automatiquement.
          </p>
        </div>
        <div className="flex gap-2">
          <button className="btn-ghost text-sm" disabled={syncing} onClick={() => void refresh()}>
            <RefreshCw className={`w-4 h-4 ${syncing ? 'animate-spin' : ''}`} /> Relever les réponses
          </button>
          {!composing && (
            <button className="btn-primary text-sm" onClick={() => setComposing(true)}>
              <Mail className="w-4 h-4" /> Nouveau mail
            </button>
          )}
        </div>
      </div>

      {composing && (
        <form onSubmit={send} className="card p-4 mb-5 space-y-3">
          <div>
            <div className="flex items-center justify-between mb-1">
              <p className="text-xs text-ink-500">Destinataires</p>
              {others.length > 1 && (
                <button
                  type="button"
                  className="text-xs text-elyade-700 hover:underline"
                  onClick={() => setRecipientIds(recipientIds.length === others.length ? [] : others.map((m) => m.account_id))}
                >
                  {recipientIds.length === others.length ? 'Aucun' : 'Tous les membres'}
                </button>
              )}
            </div>
            {others.length === 0 ? (
              <p className="text-sm text-ink-400">Aucun autre membre avec une adresse e-mail.</p>
            ) : (
              <div className="flex flex-wrap gap-2">
                {others.map((member) => {
                  const checked = recipientIds.includes(member.account_id);
                  return (
                    <button
                      key={member.account_id}
                      type="button"
                      onClick={() =>
                        setRecipientIds(checked ? recipientIds.filter((id) => id !== member.account_id) : [...recipientIds, member.account_id])
                      }
                      className={`badge cursor-pointer ${checked ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 border border-ink-200'}`}
                      title={member.email || undefined}
                    >
                      {member.display_name}
                    </button>
                  );
                })}
              </div>
            )}
          </div>
          <input className="input" placeholder="Objet" required value={subject} onChange={(e) => setSubject(e.target.value)} />
          <p className="text-xs text-ink-400 -mt-2">Le nom du projet est ajouté automatiquement au début de l'objet.</p>
          <textarea className="input" rows={8} placeholder="Votre message" required value={body} onChange={(e) => setBody(e.target.value)} />
          <div className="flex gap-2">
            <button className="btn-primary text-sm" disabled={sending}>
              <Send className="w-4 h-4" /> {sending ? 'Envoi…' : 'Envoyer depuis ma boîte'}
            </button>
            <button type="button" className="btn-ghost text-sm" onClick={() => setComposing(false)}>Annuler</button>
          </div>
        </form>
      )}

      {loading && <p className="text-sm text-ink-500">Chargement…</p>}
      {!loading && threads.length === 0 && <div className="card p-8 text-center text-sm text-ink-500">Aucun échange pour le moment.</div>}

      <div className="space-y-4">
        {threads.map((thread) => {
          const first = thread[0];
          const replies = thread.length - 1;
          return (
            <section key={first.conversation_id} className="card overflow-hidden">
              <div className="px-4 py-3 bg-ink-50/60 border-b border-ink-100">
                <p className="font-medium text-ink-900">{first.subject || '(sans objet)'}</p>
                <p className="text-xs text-ink-500">
                  {replies === 0 ? 'Aucune réponse pour le moment' : `${replies} réponse${replies > 1 ? 's' : ''}`}
                </p>
              </div>
              <ol className="divide-y divide-ink-100">
                {thread.map((message) => (
                  <li key={message.id} className="px-4 py-3">
                    <div className="flex flex-wrap items-center justify-between gap-2 text-xs text-ink-500 mb-1">
                      <span className="flex items-center gap-1.5">
                        {message.direction === 'reply' ? <Reply className="w-3.5 h-3.5" /> : <Send className="w-3.5 h-3.5" />}
                        <strong className="text-ink-800">{message.from_name || message.from_email || '—'}</strong>
                        {message.direction === 'sent' && message.recipients.length > 0 && (
                          <span>→ {message.recipients.map((r) => r.name || r.email).join(', ')}</span>
                        )}
                      </span>
                      <span>{formatSentAt(message.sent_at)}</span>
                    </div>
                    <p className="text-sm text-ink-800 whitespace-pre-wrap break-words">{message.body || ''}</p>
                    {message.has_attachments && (
                      <p className="text-xs text-ink-400 mt-1 flex items-center gap-1">
                        <Paperclip className="w-3 h-3" /> Pièce(s) jointe(s) dans le mail Outlook
                      </p>
                    )}
                  </li>
                ))}
              </ol>
            </section>
          );
        })}
      </div>
    </div>
  );
}
