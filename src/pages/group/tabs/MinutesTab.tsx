import { useEffect, useState } from 'react';
import { CheckCircle2, FileText, Pencil, Plus, Trash2 } from 'lucide-react';
import { groupApi } from '../groupApi';
import { formatDay } from '../../projects/ProjectUI';
import { useAuth } from '../../../context/AuthContext';
import type { GroupMinute, GroupProjectDetail } from '../types';

type Draft = {
  id: string | null;
  title: string;
  meetingDate: string;
  content: string;
  meetingId: string | null;
  isDraft: boolean; // brouillon préparé à la planification de la réunion
};

const today = () => new Intl.DateTimeFormat('sv-SE', { timeZone: 'Europe/Paris' }).format(new Date());

const toDraft = (minute: GroupMinute): Draft => ({
  id: minute.id,
  title: minute.title,
  meetingDate: minute.meeting_date,
  content: minute.content,
  meetingId: minute.meeting_id,
  isDraft: minute.is_draft,
});

// Comptes rendus des réunions du projet. Chaque réunion planifiée crée un
// brouillon reprenant l'invitation (ordre du jour) ; il devient définitif une
// fois « validé », ce qui arrête les rappels.
export default function MinutesTab({ project, prefillMeeting, onPrefillUsed }: {
  project: GroupProjectDetail;
  prefillMeeting: { id: string; title: string; date: string; minuteId: string | null } | null;
  onPrefillUsed: () => void;
}) {
  const { user } = useAuth();
  const [minutes, setMinutes] = useState<GroupMinute[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<Draft | null>(null);
  const [openId, setOpenId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function load() {
    const list: GroupMinute[] = await groupApi.listMinutes(project.id);
    setMinutes(list);
    return list;
  }

  useEffect(() => {
    load()
      .then((list) => {
        // Depuis l'onglet Réunions : compte rendu de la réunion choisie.
        if (!prefillMeeting) return;
        const existing = prefillMeeting.minuteId ? list.find((m) => m.id === prefillMeeting.minuteId) : null;
        setDraft(
          existing
            ? toDraft(existing)
            : { id: null, title: `Compte rendu — ${prefillMeeting.title}`, meetingDate: prefillMeeting.date, content: '', meetingId: prefillMeeting.id, isDraft: false }
        );
        onPrefillUsed();
      })
      .catch(() => setMinutes([]))
      .finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [project.id]);

  async function save(finalize: boolean) {
    if (!draft) return;
    if (!draft.title.trim() || !draft.content.trim() || !draft.meetingDate) {
      alert('Titre, date et contenu sont obligatoires.');
      return;
    }
    setSaving(true);
    try {
      const body = { title: draft.title, meetingDate: draft.meetingDate, content: draft.content, meetingId: draft.meetingId, finalize };
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

  const drafts = minutes.filter((m) => m.is_draft).length;

  return (
    <div className="max-w-4xl">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="font-semibold text-ink-900">Comptes rendus ({minutes.length})</h3>
          {drafts > 0 && <p className="text-xs text-amber-700">{drafts} compte{drafts > 1 ? 's' : ''} rendu{drafts > 1 ? 's' : ''} préparé{drafts > 1 ? 's' : ''} à compléter</p>}
        </div>
        {!draft && (
          <button
            className="btn-secondary text-sm"
            onClick={() => setDraft({ id: null, title: '', meetingDate: today(), content: '', meetingId: null, isDraft: false })}
          >
            <Plus className="w-4 h-4" /> Nouveau compte rendu
          </button>
        )}
      </div>

      {draft && (
        <form
          onSubmit={(e) => {
            e.preventDefault();
            void save(true);
          }}
          className="card p-4 mb-5 space-y-2"
        >
          {draft.isDraft && (
            <p className="text-xs text-amber-800 bg-amber-50 rounded p-2">
              Compte rendu préparé à partir de l'invitation. Complétez-le puis validez-le : le rappel à l'organisateur s'arrêtera.
            </p>
          )}
          <div className="grid grid-cols-1 sm:grid-cols-[1fr_auto] gap-2">
            <input className="input" placeholder="Titre (ex. Comité de pilotage n°3)" required value={draft.title} onChange={(e) => setDraft({ ...draft, title: e.target.value })} />
            <input className="input" type="date" required value={draft.meetingDate} onChange={(e) => setDraft({ ...draft, meetingDate: e.target.value })} />
          </div>
          <textarea
            className="input font-normal"
            rows={18}
            required
            placeholder={'Participants :\n\nPoints abordés :\n- \n\nDécisions :\n- \n\nActions (qui / quoi / quand) :\n- '}
            value={draft.content}
            onChange={(e) => setDraft({ ...draft, content: e.target.value })}
          />
          <div className="flex flex-wrap gap-2">
            <button className="btn-primary text-sm" disabled={saving}>
              <CheckCircle2 className="w-4 h-4" /> {saving ? 'Enregistrement…' : draft.isDraft ? 'Valider le compte rendu' : 'Enregistrer'}
            </button>
            {draft.isDraft && (
              <button type="button" className="btn-secondary text-sm" disabled={saving} onClick={() => void save(false)}>
                Enregistrer le brouillon
              </button>
            )}
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
            <article key={minute.id} className={`card p-4 ${minute.is_draft ? 'border-l-4 border-l-amber-400' : ''}`}>
              <div className="flex items-start justify-between gap-3">
                <button type="button" className="text-left min-w-0 flex-1" onClick={() => setOpenId(open ? null : minute.id)}>
                  <p className="font-medium text-ink-900 flex items-center gap-2 flex-wrap">
                    <FileText className="w-4 h-4 text-elyade-600 shrink-0" /> {minute.title}
                    {minute.is_draft && <span className="badge bg-amber-50 text-amber-700">Brouillon à compléter</span>}
                  </p>
                  <p className="text-xs text-ink-500 mt-0.5">
                    Réunion du {formatDay(minute.meeting_date)} · {minute.is_draft ? 'préparé' : 'rédigé'} par {minute.author_name || '—'}
                    {minute.updated_by_name && minute.updated_at !== minute.created_at && <> · modifié par {minute.updated_by_name}</>}
                  </p>
                </button>
                <div className="flex items-center gap-1 shrink-0">
                  <button type="button" className={minute.is_draft ? 'btn-primary text-xs' : 'btn-ghost p-1.5'} title="Modifier" onClick={() => setDraft(toDraft(minute))}>
                    <Pencil className="w-4 h-4" /> {minute.is_draft && 'Compléter'}
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
