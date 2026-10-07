import { useEffect, useState } from 'react';
import { FileText, Pencil, Plus, Trash2 } from 'lucide-react';
import { groupApi } from '../groupApi';
import { formatDay } from '../../projects/ProjectUI';
import { useAuth } from '../../../context/AuthContext';
import type { GroupMinute, GroupProjectDetail } from '../types';

type Draft = { id: string | null; title: string; meetingDate: string; content: string; meetingId: string | null };

const today = () => new Intl.DateTimeFormat('sv-SE', { timeZone: 'Europe/Paris' }).format(new Date());

// Comptes rendus des réunions du projet (texte libre), modifiables par tous les membres.
export default function MinutesTab({ project, prefillMeeting, onPrefillUsed }: {
  project: GroupProjectDetail;
  prefillMeeting: { id: string; title: string; date: string } | null;
  onPrefillUsed: () => void;
}) {
  const { user } = useAuth();
  const [minutes, setMinutes] = useState<GroupMinute[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<Draft | null>(null);
  const [openId, setOpenId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function load() {
    setMinutes(await groupApi.listMinutes(project.id));
  }

  useEffect(() => {
    load().catch(() => setMinutes([])).finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [project.id]);

  // Depuis l'onglet Réunions : formulaire prérempli pour la réunion choisie.
  useEffect(() => {
    if (!prefillMeeting) return;
    setDraft({ id: null, title: `Compte rendu — ${prefillMeeting.title}`, meetingDate: prefillMeeting.date, content: '', meetingId: prefillMeeting.id });
    onPrefillUsed();
  }, [prefillMeeting, onPrefillUsed]);

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (!draft) return;
    setSaving(true);
    try {
      const body = { title: draft.title, meetingDate: draft.meetingDate, content: draft.content, meetingId: draft.meetingId };
      if (draft.id) await groupApi.updateMinute(draft.id, body);
      else await groupApi.createMinute(project.id, body);
      setDraft(null);
      await load();
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'enregistrement");
    } finally {
      setSaving(false);
    }
  }

  async function remove(minute: GroupMinute) {
    if (!confirm(`Supprimer le compte rendu « ${minute.title} » ?`)) return;
    try {
      await groupApi.deleteMinute(minute.id);
      await load();
    } catch (err: any) {
      alert(err.message || 'Erreur lors de la suppression');
    }
  }

  return (
    <div className="max-w-4xl">
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-semibold text-ink-900">Comptes rendus ({minutes.length})</h3>
        {!draft && (
          <button className="btn-secondary text-sm" onClick={() => setDraft({ id: null, title: '', meetingDate: today(), content: '', meetingId: null })}>
            <Plus className="w-4 h-4" /> Nouveau compte rendu
          </button>
        )}
      </div>

      {draft && (
        <form onSubmit={save} className="card p-4 mb-5 space-y-2">
          <div className="grid grid-cols-1 sm:grid-cols-[1fr_auto] gap-2">
            <input className="input" placeholder="Titre (ex. Comité de pilotage n°3)" required value={draft.title} onChange={(e) => setDraft({ ...draft, title: e.target.value })} />
            <input className="input" type="date" required value={draft.meetingDate} onChange={(e) => setDraft({ ...draft, meetingDate: e.target.value })} />
          </div>
          {draft.meetingId && <p className="text-xs text-ink-500">Lié à la réunion planifiée : le rappel de compte rendu s'arrêtera.</p>}
          <textarea
            className="input font-normal"
            rows={14}
            required
            placeholder={'Participants :\n\nPoints abordés :\n- \n\nDécisions :\n- \n\nActions (qui / quoi / quand) :\n- '}
            value={draft.content}
            onChange={(e) => setDraft({ ...draft, content: e.target.value })}
          />
          <div className="flex gap-2">
            <button className="btn-primary text-sm" disabled={saving}>{saving ? 'Enregistrement…' : 'Enregistrer'}</button>
            <button type="button" className="btn-ghost text-sm" onClick={() => setDraft(null)}>Annuler</button>
          </div>
        </form>
      )}

      {loading && <p className="text-sm text-ink-500">Chargement…</p>}
      {!loading && minutes.length === 0 && !draft && <div className="card p-8 text-center text-sm text-ink-500">Aucun compte rendu pour le moment.</div>}

      <div className="space-y-3">
        {minutes.map((minute) => {
          const open = openId === minute.id;
          const canDelete = project.estResponsable || minute.author_account_id === user?.id;
          return (
            <article key={minute.id} className="card p-4">
              <div className="flex items-start justify-between gap-3">
                <button type="button" className="text-left min-w-0 flex-1" onClick={() => setOpenId(open ? null : minute.id)}>
                  <p className="font-medium text-ink-900 flex items-center gap-2">
                    <FileText className="w-4 h-4 text-elyade-600 shrink-0" /> {minute.title}
                  </p>
                  <p className="text-xs text-ink-500 mt-0.5">
                    Réunion du {formatDay(minute.meeting_date)} · rédigé par {minute.author_name || '—'}
                    {minute.updated_by_name && minute.updated_at !== minute.created_at && <> · modifié par {minute.updated_by_name}</>}
                    {minute.meeting_id && <> · réunion planifiée</>}
                  </p>
                </button>
                <div className="flex items-center gap-1 shrink-0">
                  <button
                    type="button"
                    className="btn-ghost p-1.5"
                    title="Modifier"
                    onClick={() => setDraft({ id: minute.id, title: minute.title, meetingDate: minute.meeting_date, content: minute.content, meetingId: minute.meeting_id })}
                  >
                    <Pencil className="w-4 h-4" />
                  </button>
                  {canDelete && (
                    <button type="button" className="btn-ghost p-1.5 text-ink-400 hover:text-red-600" title="Supprimer" onClick={() => void remove(minute)}>
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
              </div>
              {open ? (
                <p className="text-sm text-ink-800 whitespace-pre-wrap break-words mt-3 pt-3 border-t border-ink-100">{minute.content}</p>
              ) : (
                <p className="text-sm text-ink-500 mt-2 line-clamp-2 whitespace-pre-wrap">{minute.content}</p>
              )}
            </article>
          );
        })}
      </div>
    </div>
  );
}
