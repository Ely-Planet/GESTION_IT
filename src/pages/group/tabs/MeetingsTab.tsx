import { useEffect, useState } from 'react';
import { AlertTriangle, CalendarPlus, CheckCircle2, FileText, MapPin, Pencil, Video, XCircle } from 'lucide-react';
import { groupApi } from '../groupApi';
import { useAuth } from '../../../context/AuthContext';
import { formatDateTime, type GroupMeeting, type GroupProjectDetail } from '../types';

type Draft = {
  id: string | null;
  title: string;
  date: string;
  startTime: string;
  endTime: string;
  location: string;
  online: boolean;
  agenda: string;
  attendeeIds: string[];
};

const today = () => new Intl.DateTimeFormat('sv-SE', { timeZone: 'Europe/Paris' }).format(new Date());

// Réunions du projet : invitation Outlook (Teams) envoyée aux membres choisis,
// notification dans l'application, rappel du compte rendu après la réunion.
export default function MeetingsTab({ project, onWriteMinutes }: {
  project: GroupProjectDetail;
  onWriteMinutes: (meeting: GroupMeeting) => void;
}) {
  const { user } = useAuth();
  const [meetings, setMeetings] = useState<GroupMeeting[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<Draft | null>(null);
  const [saving, setSaving] = useState(false);
  const others = project.members.filter((m) => m.account_id !== user?.id);

  async function load() {
    setMeetings(await groupApi.listMeetings(project.id));
  }

  useEffect(() => {
    load().catch(() => setMeetings([])).finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [project.id]);

  function newDraft(): Draft {
    return {
      id: null, title: '', date: today(), startTime: '10:00', endTime: '11:00', location: '', online: true, agenda: '',
      attendeeIds: others.map((m) => m.account_id),
    };
  }

  function editDraft(meeting: GroupMeeting): Draft {
    return {
      id: meeting.id,
      title: meeting.title,
      date: meeting.start_at.slice(0, 10),
      startTime: meeting.start_at.slice(11, 16),
      endTime: meeting.end_at.slice(11, 16),
      location: meeting.location || '',
      online: meeting.online,
      agenda: meeting.agenda || '',
      attendeeIds: meeting.attendee_ids,
    };
  }

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (!draft) return;
    if (draft.endTime <= draft.startTime) {
      alert("L'heure de fin doit être après l'heure de début.");
      return;
    }
    setSaving(true);
    try {
      const body = {
        title: draft.title,
        agenda: draft.agenda,
        location: draft.location,
        online: draft.online,
        start: `${draft.date}T${draft.startTime}`,
        end: `${draft.date}T${draft.endTime}`,
        attendeeIds: draft.attendeeIds,
      };
      const result = draft.id ? await groupApi.updateMeeting(draft.id, body) : await groupApi.createMeeting(project.id, body);
      if (result?.outlookError) {
        alert(`Réunion enregistrée et membres notifiés dans l'application, mais l'invitation Outlook n'a pas pu être envoyée :\n${result.outlookError}`);
      }
      setDraft(null);
      await load();
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'enregistrement");
    } finally {
      setSaving(false);
    }
  }

  async function cancel(meeting: GroupMeeting) {
    if (!confirm(`Annuler la réunion « ${meeting.title} » du ${formatDateTime(meeting.start_at)} ? Les invités seront prévenus.`)) return;
    try {
      const result = await groupApi.cancelMeeting(meeting.id);
      if (result?.outlookError) alert(`Réunion annulée dans l'application, mais pas dans Outlook :\n${result.outlookError}`);
      await load();
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'annulation");
    }
  }

  const upcoming = meetings.filter((m) => !m.past && m.status === 'planned').sort((a, b) => a.start_at.localeCompare(b.start_at));
  const past = meetings.filter((m) => m.past || m.status === 'cancelled');
  const nameOf = (id: string) => project.members.find((m) => m.account_id === id)?.display_name || 'Ancien membre';

  function MeetingCard({ meeting }: { meeting: GroupMeeting }) {
    const canEdit = meeting.status === 'planned' && (project.estResponsable || meeting.organizer_account_id === user?.id);
    return (
      <article className={`card p-4 ${meeting.status === 'cancelled' ? 'opacity-60' : ''}`}>
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="min-w-0">
            <p className="font-medium text-ink-900">
              {meeting.title}
              {meeting.status === 'cancelled' && <span className="badge bg-red-50 text-red-700 ml-2">Annulée</span>}
            </p>
            <p className="text-sm text-ink-600 mt-0.5">
              {formatDateTime(meeting.start_at)} – {meeting.end_at.slice(11, 16)} · organisée par {meeting.organizer_name || '—'}
            </p>
            <div className="flex flex-wrap gap-x-3 gap-y-1 mt-1 text-xs text-ink-500">
              {meeting.location && <span className="flex items-center gap-1"><MapPin className="w-3.5 h-3.5" /> {meeting.location}</span>}
              {meeting.online_meeting_url && meeting.status === 'planned' && (
                <a href={meeting.online_meeting_url} target="_blank" rel="noreferrer" className="flex items-center gap-1 text-elyade-700 hover:underline">
                  <Video className="w-3.5 h-3.5" /> Rejoindre sur Teams
                </a>
              )}
              <span>Invités : {meeting.attendee_ids.length ? meeting.attendee_ids.map(nameOf).join(', ') : 'aucun'}</span>
              {meeting.in_outlook && <span className="text-emerald-700">Invitation Outlook envoyée</span>}
            </div>
            {meeting.outlook_error && (
              <p className="flex items-start gap-1.5 text-xs text-amber-800 bg-amber-50 rounded p-2 mt-2">
                <AlertTriangle className="w-3.5 h-3.5 shrink-0 mt-0.5" /> Invitation Outlook non envoyée : {meeting.outlook_error}
              </p>
            )}
            {meeting.agenda && <p className="text-sm text-ink-700 whitespace-pre-wrap mt-2">{meeting.agenda}</p>}
          </div>
          <div className="flex flex-wrap items-center gap-1">
            {meeting.past && meeting.status === 'planned' && (
              meeting.minute_id ? (
                <span className="badge bg-emerald-50 text-emerald-700"><CheckCircle2 className="w-3.5 h-3.5" /> Compte rendu saisi</span>
              ) : (
                <button className="btn-primary text-xs" onClick={() => onWriteMinutes(meeting)}>
                  <FileText className="w-3.5 h-3.5" /> Saisir le compte rendu
                </button>
              )
            )}
            {canEdit && !meeting.past && (
              <>
                <button className="btn-ghost p-1.5" title="Modifier" onClick={() => setDraft(editDraft(meeting))}><Pencil className="w-4 h-4" /></button>
                <button className="btn-ghost p-1.5 text-ink-400 hover:text-red-600" title="Annuler la réunion" onClick={() => void cancel(meeting)}>
                  <XCircle className="w-4 h-4" />
                </button>
              </>
            )}
          </div>
        </div>
      </article>
    );
  }

  return (
    <div className="max-w-4xl">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="font-semibold text-ink-900">Réunions</h3>
          <p className="text-xs text-ink-500">Invitation Outlook envoyée depuis votre agenda ; rappel du compte rendu après la réunion.</p>
        </div>
        {!draft && (
          <button className="btn-primary text-sm" onClick={() => setDraft(newDraft())}>
            <CalendarPlus className="w-4 h-4" /> Planifier une réunion
          </button>
        )}
      </div>

      {draft && (
        <form onSubmit={save} className="card p-4 mb-5 space-y-3">
          <input className="input" placeholder="Objet de la réunion" required value={draft.title} onChange={(e) => setDraft({ ...draft, title: e.target.value })} />
          <div className="grid grid-cols-3 gap-2">
            <label className="text-xs text-ink-500">
              Date
              <input className="input mt-1" type="date" required value={draft.date} onChange={(e) => setDraft({ ...draft, date: e.target.value })} />
            </label>
            <label className="text-xs text-ink-500">
              Début
              <input className="input mt-1" type="time" required value={draft.startTime} onChange={(e) => setDraft({ ...draft, startTime: e.target.value })} />
            </label>
            <label className="text-xs text-ink-500">
              Fin
              <input className="input mt-1" type="time" required value={draft.endTime} onChange={(e) => setDraft({ ...draft, endTime: e.target.value })} />
            </label>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-[1fr_auto] gap-2 items-center">
            <input className="input" placeholder="Lieu (optionnel)" value={draft.location} onChange={(e) => setDraft({ ...draft, location: e.target.value })} />
            <label className="flex items-center gap-2 text-sm text-ink-700">
              <input type="checkbox" checked={draft.online} onChange={(e) => setDraft({ ...draft, online: e.target.checked })} />
              Réunion Teams
            </label>
          </div>
          <div>
            <p className="text-xs text-ink-500 mb-1">Invités</p>
            <div className="flex flex-wrap gap-2">
              {others.map((member) => {
                const checked = draft.attendeeIds.includes(member.account_id);
                return (
                  <button
                    key={member.account_id}
                    type="button"
                    onClick={() =>
                      setDraft({
                        ...draft,
                        attendeeIds: checked ? draft.attendeeIds.filter((id) => id !== member.account_id) : [...draft.attendeeIds, member.account_id],
                      })
                    }
                    className={`badge cursor-pointer ${checked ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 border border-ink-200'}`}
                  >
                    {member.display_name}
                  </button>
                );
              })}
              {others.length === 0 && <span className="text-sm text-ink-400">Aucun autre membre dans le projet.</span>}
            </div>
          </div>
          <textarea className="input" rows={4} placeholder="Ordre du jour" value={draft.agenda} onChange={(e) => setDraft({ ...draft, agenda: e.target.value })} />
          <div className="flex gap-2">
            <button className="btn-primary text-sm" disabled={saving}>
              {saving ? 'Envoi…' : draft.id ? 'Enregistrer et mettre à jour l’invitation' : 'Planifier et envoyer l’invitation'}
            </button>
            <button type="button" className="btn-ghost text-sm" onClick={() => setDraft(null)}>Annuler</button>
          </div>
        </form>
      )}

      {loading && <p className="text-sm text-ink-500">Chargement…</p>}

      {!loading && (
        <>
          <h4 className="text-sm font-semibold text-ink-700 mb-2">À venir ({upcoming.length})</h4>
          {upcoming.length === 0 && <p className="text-sm text-ink-400 mb-5">Aucune réunion planifiée.</p>}
          <div className="space-y-3 mb-6">{upcoming.map((m) => <MeetingCard key={m.id} meeting={m} />)}</div>

          {past.length > 0 && (
            <>
              <h4 className="text-sm font-semibold text-ink-700 mb-2">Passées et annulées ({past.length})</h4>
              <div className="space-y-3">{past.map((m) => <MeetingCard key={m.id} meeting={m} />)}</div>
            </>
          )}
        </>
      )}
    </div>
  );
}
