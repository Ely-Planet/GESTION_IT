import { useEffect, useMemo, useState } from 'react';
import { AlertTriangle, CalendarPlus, CheckCircle2, DoorOpen, FileText, MapPin, Pencil, Trash2, Video, XCircle } from 'lucide-react';
import { groupApi } from '../groupApi';
import { useAuth } from '../../../context/AuthContext';
import WeekScheduler from '../WeekScheduler';
import { busyDuring, mondayOf, statusLabel, toMinutes, toTime } from '../scheduleUtils';
import { formatDateTime, type Availability, type GroupMeeting, type GroupProjectDetail, type MeetingRoom } from '../types';

type Draft = {
  id: string | null;
  title: string;
  date: string;
  startTime: string;
  endTime: string;
  roomEmail: string;
  location: string;
  online: boolean;
  agenda: string;
  attendeeIds: string[];
};

const today = () => new Intl.DateTimeFormat('sv-SE', { timeZone: 'Europe/Paris' }).format(new Date());

// Réponse Outlook d'un invité -> libellé, pastille et couleurs.
const RESPONSES: Record<string, { label: string; mark: string; tone: string }> = {
  accepted: { label: 'a accepté', mark: '✓', tone: 'bg-emerald-50 text-emerald-700 border-emerald-200' },
  declined: { label: 'a refusé', mark: '✗', tone: 'bg-red-50 text-red-700 border-red-200' },
  tentativelyAccepted: { label: 'provisoire', mark: '?', tone: 'bg-amber-50 text-amber-700 border-amber-200' },
  pending: { label: 'pas encore répondu', mark: '…', tone: 'bg-ink-50 text-ink-500 border-ink-200' },
};
const responseOf = (responses: Record<string, string> | null, email: string | null | undefined) => {
  const value = email ? responses?.[email.toLowerCase()] : undefined;
  return RESPONSES[value || ''] || RESPONSES.pending;
};

// Réunions du projet : invitation Outlook (Teams) envoyée aux membres choisis,
// salle réservée, disponibilités sur la semaine, rappel du compte rendu.
export default function MeetingsTab({ project, onWriteMinutes }: {
  project: GroupProjectDetail;
  onWriteMinutes: (meeting: GroupMeeting) => void;
}) {
  const { user } = useAuth();
  const [meetings, setMeetings] = useState<GroupMeeting[]>([]);
  const [loading, setLoading] = useState(true);
  const [draft, setDraft] = useState<Draft | null>(null);
  const [saving, setSaving] = useState(false);
  const [rooms, setRooms] = useState<MeetingRoom[]>([]);
  const [roomsError, setRoomsError] = useState<string | null>(null);
  const [roomsRequested, setRoomsRequested] = useState(false);
  const [weekStart, setWeekStart] = useState(mondayOf(today()));
  const [availability, setAvailability] = useState<Availability | null>(null);
  const [availabilityError, setAvailabilityError] = useState<string | null>(null);
  const [availabilityLoading, setAvailabilityLoading] = useState(false);
  const others = project.members.filter((m) => m.account_id !== user?.id);

  async function load() {
    setMeetings(await groupApi.listMeetings(project.id));
  }

  useEffect(() => {
    load().catch(() => setMeetings([])).finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [project.id]);

  // Salles : chargées à l'ouverture du formulaire.
  useEffect(() => {
    if (!draft || roomsRequested) return;
    setRoomsRequested(true);
    groupApi
      .rooms()
      .then((result: { rooms: MeetingRoom[]; error: string | null }) => {
        setRooms(result.rooms);
        setRoomsError(result.error);
      })
      .catch((err: Error) => setRoomsError(err.message));
  }, [draft, roomsRequested]);

  // Disponibilités de la semaine affichée : invités cochés et toutes les salles.
  const attendeeKey = draft ? [...draft.attendeeIds].sort().join(',') : '';
  const roomKey = rooms.map((r) => r.email).join(',');
  useEffect(() => {
    if (!draft) return;
    let cancelled = false;
    setAvailabilityLoading(true);
    groupApi
      .availability(project.id, { weekStart, attendeeIds: draft.attendeeIds, roomEmails: rooms.map((r) => r.email) })
      .then((result: Availability) => {
        if (cancelled) return;
        setAvailability(result);
        setAvailabilityError(null);
      })
      .catch((err: Error) => !cancelled && setAvailabilityError(err.message))
      .finally(() => !cancelled && setAvailabilityLoading(false));
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [Boolean(draft), weekStart, attendeeKey, roomKey, project.id]);

  function openDraft(next: Draft) {
    setDraft(next);
    setWeekStart(mondayOf(next.date));
  }

  function newDraft(): Draft {
    return {
      id: null, title: '', date: today(), startTime: '10:00', endTime: '11:00', roomEmail: '', location: '', online: true, agenda: '',
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
      roomEmail: meeting.room_email || '',
      location: meeting.room_email ? '' : meeting.location || '',
      online: meeting.online,
      agenda: meeting.agenda || '',
      attendeeIds: meeting.attendee_ids,
    };
  }

  // Créneau choisi dans le calendrier : on garde la durée.
  function selectSlot(date: string, start: string) {
    if (!draft) return;
    const duration = Math.max(toMinutes(draft.endTime) - toMinutes(draft.startTime), 30);
    setDraft({ ...draft, date, startTime: start, endTime: toTime(Math.min(toMinutes(start) + duration, 23 * 60 + 30)) });
  }

  // Disponibilité de chacun et des salles sur le créneau choisi.
  const slot = draft ? { start: `${draft.date}T${draft.startTime}`, end: `${draft.date}T${draft.endTime}` } : null;
  const scheduleOf = (email: string) => availability?.schedules.find((s) => s.email === email.toLowerCase());
  const roomStatus = useMemo(() => {
    const map = new Map<string, 'libre' | 'occupée' | 'inconnue'>();
    for (const room of rooms) {
      const schedule = scheduleOf(room.email);
      if (!slot || !schedule || schedule.error) map.set(room.email, 'inconnue');
      else map.set(room.email, busyDuring(schedule.items, slot.start, slot.end).length ? 'occupée' : 'libre');
    }
    return map;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [rooms, availability, slot?.start, slot?.end]);

  async function save(e: React.FormEvent) {
    e.preventDefault();
    if (!draft) return;
    if (draft.endTime <= draft.startTime) {
      alert("L'heure de fin doit être après l'heure de début.");
      return;
    }
    const room = rooms.find((r) => r.email === draft.roomEmail);
    if (room && roomStatus.get(room.email) === 'occupée' && !confirm(`La salle « ${room.name} » est occupée sur ce créneau. Envoyer quand même la demande de réservation ?`)) {
      return;
    }
    setSaving(true);
    try {
      const body = {
        title: draft.title,
        agenda: draft.agenda,
        location: room ? '' : draft.location,
        roomEmail: room?.email || null,
        roomName: room?.name || null,
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

  async function remove(meeting: GroupMeeting) {
    const upcomingMeeting = meeting.status === 'planned' && !meeting.past;
    const message = upcomingMeeting
      ? `Supprimer la réunion « ${meeting.title} » du ${formatDateTime(meeting.start_at)} ?
Elle sera annulée dans Outlook (les invités seront prévenus) et retirée du projet.`
      : `Supprimer la réunion « ${meeting.title} » du ${formatDateTime(meeting.start_at)} du projet ?`;
    if (!confirm(`${message}
Un compte rendu déjà rédigé est conservé.`)) return;
    try {
      const result = await groupApi.deleteMeeting(meeting.id);
      if (result?.outlookError) alert(`Réunion supprimée de l'application, mais pas annulée dans Outlook :
${result.outlookError}`);
      await load();
    } catch (err: any) {
      alert(err.message || 'Erreur lors de la suppression');
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

  function renderMeeting(meeting: GroupMeeting) {
    const canManage = project.estResponsable || meeting.organizer_account_id === user?.id;
    const canEdit = meeting.status === 'planned' && canManage;
    return (
      <article key={meeting.id} className={`card p-4 ${meeting.status === 'cancelled' ? 'opacity-60' : ''}`}>
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
              {meeting.room_name ? (
                <span className="flex items-center gap-1"><DoorOpen className="w-3.5 h-3.5" /> {meeting.room_name}</span>
              ) : meeting.location && (
                <span className="flex items-center gap-1"><MapPin className="w-3.5 h-3.5" /> {meeting.location}</span>
              )}
              {meeting.online_meeting_url && meeting.status === 'planned' && (
                <a href={meeting.online_meeting_url} target="_blank" rel="noreferrer" className="flex items-center gap-1 text-elyade-700 hover:underline">
                  <Video className="w-3.5 h-3.5" /> Rejoindre sur Teams
                </a>
              )}
              {meeting.attendee_ids.length === 0 && <span>Aucun invité</span>}
              {meeting.in_outlook && <span className="text-emerald-700">Invitation Outlook envoyée</span>}
            </div>
            {meeting.attendee_ids.length > 0 && (
              <div className="flex flex-wrap items-center gap-1.5 mt-2">
                <span className="text-xs text-ink-500">Invités :</span>
                {meeting.attendee_ids.map((id) => {
                  const member = project.members.find((m) => m.account_id === id);
                  const response = meeting.in_outlook ? responseOf(meeting.attendee_responses, member?.email) : null;
                  return (
                    <span
                      key={id}
                      className={`badge border ${response ? response.tone : 'bg-white text-ink-600 border-ink-200'}`}
                      title={response ? `${nameOf(id)} ${response.label}` : nameOf(id)}
                    >
                      {response && <span className="font-semibold">{response.mark}</span>} {nameOf(id)}
                    </span>
                  );
                })}
                {meeting.room_email && meeting.in_outlook && (() => {
                  const room = responseOf(meeting.attendee_responses, meeting.room_email);
                  return (
                    <span className={`badge border ${room.tone}`} title={`Salle ${meeting.room_name || meeting.room_email} : ${room.label === 'a accepté' ? 'réservation acceptée' : room.label === 'a refusé' ? 'réservation refusée' : 'réservation en attente'}`}>
                      <DoorOpen className="w-3 h-3" /> {room.mark}
                    </span>
                  );
                })()}
              </div>
            )}
            {meeting.status === 'planned' && !meeting.past && (() => {
              // Alerte : invités (et salle) ayant refusé l'invitation.
              const refused = meeting.attendee_ids
                .filter((id) => responseOf(meeting.attendee_responses, project.members.find((m) => m.account_id === id)?.email) === RESPONSES.declined)
                .map(nameOf);
              if (meeting.room_email && responseOf(meeting.attendee_responses, meeting.room_email) === RESPONSES.declined) {
                refused.push(`la salle ${meeting.room_name || ''}`.trim());
              }
              if (!refused.length) return null;
              const list = refused.length > 1 ? `${refused.slice(0, -1).join(', ')} et ${refused[refused.length - 1]}` : refused[0];
              return (
                <p className="text-xs text-red-700 mt-1">
                  {list.charAt(0).toUpperCase() + list.slice(1)} {refused.length > 1 ? 'ont refusé' : 'a refusé'} l'invitation.
                </p>
              );
            })()}
            {meeting.outlook_error && (
              <p className="flex items-start gap-1.5 text-xs text-amber-800 bg-amber-50 rounded p-2 mt-2">
                <AlertTriangle className="w-3.5 h-3.5 shrink-0 mt-0.5" /> Invitation Outlook non envoyée : {meeting.outlook_error}
              </p>
            )}
            {meeting.agenda && <p className="text-sm text-ink-700 whitespace-pre-wrap mt-2">{meeting.agenda}</p>}
          </div>
          <div className="flex flex-wrap items-center gap-1">
            {meeting.status === 'planned' && (
              meeting.minute_id && !meeting.minute_is_draft ? (
                <button className="badge bg-emerald-50 text-emerald-700 hover:bg-emerald-100" onClick={() => onWriteMinutes(meeting)} title="Ouvrir le compte rendu">
                  <CheckCircle2 className="w-3.5 h-3.5" /> Compte rendu validé
                </button>
              ) : meeting.minute_id ? (
                <button className={`${meeting.past ? 'btn-primary' : 'btn-secondary'} text-xs`} onClick={() => onWriteMinutes(meeting)}>
                  <FileText className="w-3.5 h-3.5" /> {meeting.past ? 'Compléter le compte rendu' : 'Préparer le compte rendu'}
                </button>
              ) : meeting.past && (
                <button className="btn-primary text-xs" onClick={() => onWriteMinutes(meeting)}>
                  <FileText className="w-3.5 h-3.5" /> Saisir le compte rendu
                </button>
              )
            )}
            {canEdit && !meeting.past && (
              <>
                <button className="btn-ghost p-1.5" title="Modifier" onClick={() => openDraft(editDraft(meeting))}><Pencil className="w-4 h-4" /></button>
                <button className="btn-ghost p-1.5 text-ink-400 hover:text-amber-600" title="Annuler la réunion (reste visible, barrée)" onClick={() => void cancel(meeting)}>
                  <XCircle className="w-4 h-4" />
                </button>
              </>
            )}
            {canManage && (
              <button className="btn-ghost p-1.5 text-ink-400 hover:text-red-600" title="Supprimer la réunion" onClick={() => void remove(meeting)}>
                <Trash2 className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>
      </article>
    );
  }

  return (
    <div className="max-w-5xl">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="font-semibold text-ink-900">Réunions</h3>
          <p className="text-xs text-ink-500">Invitation Outlook envoyée depuis votre agenda ; rappel du compte rendu après la réunion.</p>
        </div>
        {!draft && (
          <button className="btn-primary text-sm" onClick={() => openDraft(newDraft())}>
            <CalendarPlus className="w-4 h-4" /> Planifier une réunion
          </button>
        )}
      </div>

      {draft && (
        <form onSubmit={save} className="card p-4 mb-5 space-y-3">
          <input className="input" placeholder="Objet de la réunion" required value={draft.title} onChange={(e) => setDraft({ ...draft, title: e.target.value })} />

          <div>
            <p className="text-xs text-ink-500 mb-1">Invités</p>
            <div className="flex flex-wrap gap-2">
              {others.map((member) => {
                const checked = draft.attendeeIds.includes(member.account_id);
                const busy = checked && slot && member.email ? busyDuring(scheduleOf(member.email)?.items || [], slot.start, slot.end) : [];
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
                    className={`badge cursor-pointer ${checked ? (busy.length ? 'bg-amber-500 text-white' : 'bg-elyade-600 text-white') : 'bg-white text-ink-600 border border-ink-200'}`}
                    title={checked ? (busy.length ? `${statusLabel(busy[0].status)} sur ce créneau` : 'Disponible sur ce créneau') : 'Non invité'}
                  >
                    {member.display_name}
                    {checked && availability && <span className="opacity-90">· {busy.length ? statusLabel(busy[0].status) : 'dispo'}</span>}
                  </button>
                );
              })}
              {others.length === 0 && <span className="text-sm text-ink-400">Aucun autre membre dans le projet.</span>}
            </div>
          </div>

          {availabilityError ? (
            <p className="flex items-start gap-1.5 text-xs text-amber-800 bg-amber-50 rounded p-2">
              <AlertTriangle className="w-3.5 h-3.5 shrink-0 mt-0.5" /> {availabilityError}
            </p>
          ) : (
            <WeekScheduler
              weekStart={weekStart}
              onWeekChange={setWeekStart}
              availability={availability}
              loading={availabilityLoading}
              roomEmail={draft.roomEmail || null}
              selection={{ date: draft.date, start: draft.startTime, end: draft.endTime }}
              onSelect={selectSlot}
            />
          )}

          <div className="grid grid-cols-3 gap-2">
            <label className="text-xs text-ink-500">
              Date
              <input
                className="input mt-1"
                type="date"
                required
                value={draft.date}
                onChange={(e) => {
                  setDraft({ ...draft, date: e.target.value });
                  if (e.target.value) setWeekStart(mondayOf(e.target.value));
                }}
              />
            </label>
            <label className="text-xs text-ink-500">
              Début
              <input className="input mt-1" type="time" required step={300} value={draft.startTime} onChange={(e) => setDraft({ ...draft, startTime: e.target.value })} />
            </label>
            <label className="text-xs text-ink-500">
              Fin
              <input className="input mt-1" type="time" required step={300} value={draft.endTime} onChange={(e) => setDraft({ ...draft, endTime: e.target.value })} />
            </label>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-[1fr_auto] gap-2 items-end">
            <label className="text-xs text-ink-500">
              Salle de réunion
              <select className="input mt-1" value={draft.roomEmail} onChange={(e) => setDraft({ ...draft, roomEmail: e.target.value })}>
                <option value="">Pas de salle / autre lieu</option>
                {rooms.map((room) => {
                  const status = roomStatus.get(room.email);
                  return (
                    <option key={room.email} value={room.email}>
                      {status === 'libre' ? '✓ ' : status === 'occupée' ? '✗ ' : ''}
                      {room.name}
                      {room.capacity ? ` (${room.capacity} pers.)` : ''}
                      {status === 'occupée' ? ' — occupée' : status === 'libre' ? ' — libre' : ''}
                    </option>
                  );
                })}
              </select>
            </label>
            <label className="flex items-center gap-2 text-sm text-ink-700 pb-2">
              <input type="checkbox" checked={draft.online} onChange={(e) => setDraft({ ...draft, online: e.target.checked })} />
              Réunion Teams
            </label>
          </div>
          {roomsError && <p className="text-xs text-amber-700">{roomsError}</p>}
          {!draft.roomEmail && (
            <input className="input" placeholder="Autre lieu (optionnel)" value={draft.location} onChange={(e) => setDraft({ ...draft, location: e.target.value })} />
          )}

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
          <div className="space-y-3 mb-6">{upcoming.map(renderMeeting)}</div>

          {past.length > 0 && (
            <>
              <h4 className="text-sm font-semibold text-ink-700 mb-2">Passées et annulées ({past.length})</h4>
              <div className="space-y-3">{past.map(renderMeeting)}</div>
            </>
          )}
        </>
      )}
    </div>
  );
}
