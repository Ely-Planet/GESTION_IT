import { useEffect, useMemo, useState, type FormEvent } from 'react';
import { AlertTriangle, ArrowLeft, CalendarPlus, CheckCircle2, Clock, DoorOpen, MapPin, Pencil, Trash2, Users, User, Video, XCircle } from 'lucide-react';
import WeekScheduler from '../group/WeekScheduler';
import { busyDuring, mondayOf, statusLabel, toMinutes, toTime } from '../group/scheduleUtils';
import { formatDateTime, type Availability } from '../group/types';

// Points d'équipe et points individuels du service informatique.
// Planification (manager) comme les Projets Groupe ; compte rendu repris du
// point précédent ; chaque participant prépare sa partie avant le point.

type Kind = 'team' | 'individual';
type Person = { account_id: string; display_name: string; email: string; is_it_manager: boolean };
type Room = { email: string; name: string; capacity: number | null };
type Point = {
  id: string;
  kind: Kind;
  subject_account_id: string | null;
  subject_name: string | null;
  title: string;
  agenda: string | null;
  location: string | null;
  room_email: string | null;
  room_name: string | null;
  online: boolean;
  status: 'planned' | 'cancelled';
  organizer_account_id: string;
  organizer_name: string | null;
  attendee_ids: string[];
  online_meeting_url: string | null;
  outlook_error: string | null;
  in_outlook: boolean;
  start_at: string;
  end_at: string;
  past: boolean;
  minutes_validated: boolean | null;
  my_contribution?: { done: boolean } | null;
};
type PointDetail = Point & {
  minutes: { content: string; validated: boolean; updated_by?: string | null; updated_at?: string };
  contributions: { account_id: string; display_name: string; content: string; contributed_at: string | null; updated_at: string }[];
  previous: { id: string; title: string; start_at: string; minutes: string | null } | null;
};

async function api<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, { ...init, headers: { 'Content-Type': 'application/json' } });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(json.error || 'Erreur');
  return json as T;
}

const today = () => new Intl.DateTimeFormat('sv-SE', { timeZone: 'Europe/Paris' }).format(new Date());

// ---------------------------------------------------------------------------
// Planification (manager) : invités, disponibilités, salle, Teams
// ---------------------------------------------------------------------------
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

function PointPlanner({
  kind,
  subject,
  people,
  me,
  initial,
  onClose,
  onSaved,
}: {
  kind: Kind;
  subject: Person | null;
  people: Person[];
  me: string;
  initial: Draft;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [draft, setDraft] = useState<Draft>(initial);
  const [rooms, setRooms] = useState<Room[]>([]);
  const [roomsError, setRoomsError] = useState<string | null>(null);
  const [weekStart, setWeekStart] = useState(mondayOf(initial.date));
  const [availability, setAvailability] = useState<Availability | null>(null);
  const [availabilityError, setAvailabilityError] = useState<string | null>(null);
  const [availabilityLoading, setAvailabilityLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const others = people.filter((p) => p.account_id !== me);

  useEffect(() => {
    api<{ rooms: Room[]; error: string | null }>('/api/points/rooms')
      .then((r) => {
        setRooms(r.rooms);
        setRoomsError(r.error);
      })
      .catch((err: Error) => setRoomsError(err.message));
  }, []);

  const attendeeKey = [...draft.attendeeIds].sort().join(',');
  const roomKey = rooms.map((r) => r.email).join(',');
  useEffect(() => {
    let cancelled = false;
    setAvailabilityLoading(true);
    api<Availability>('/api/points/availability', {
      method: 'POST',
      body: JSON.stringify({ weekStart, attendeeIds: draft.attendeeIds, roomEmails: rooms.map((r) => r.email) }),
    })
      .then((result) => {
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
  }, [weekStart, attendeeKey, roomKey]);

  function selectSlot(date: string, start: string) {
    const duration = Math.max(toMinutes(draft.endTime) - toMinutes(draft.startTime), 30);
    setDraft({ ...draft, date, startTime: start, endTime: toTime(Math.min(toMinutes(start) + duration, 23 * 60 + 30)) });
  }

  const slot = { start: `${draft.date}T${draft.startTime}`, end: `${draft.date}T${draft.endTime}` };
  const scheduleOf = (email: string) => availability?.schedules.find((s) => s.email === email.toLowerCase());
  const roomStatus = useMemo(() => {
    const map = new Map<string, 'libre' | 'occupée' | 'inconnue'>();
    for (const room of rooms) {
      const schedule = scheduleOf(room.email);
      if (!schedule || schedule.error) map.set(room.email, 'inconnue');
      else map.set(room.email, busyDuring(schedule.items, slot.start, slot.end).length ? 'occupée' : 'libre');
    }
    return map;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [rooms, availability, slot.start, slot.end]);

  async function save(e: FormEvent) {
    e.preventDefault();
    if (draft.endTime <= draft.startTime) {
      alert("L'heure de fin doit être après l'heure de début.");
      return;
    }
    const room = rooms.find((r) => r.email === draft.roomEmail);
    if (room && roomStatus.get(room.email) === 'occupée' && !confirm(`La salle « ${room.name} » est occupée sur ce créneau. Envoyer quand même ?`)) return;
    setSaving(true);
    try {
      const body = {
        kind,
        subjectId: subject?.account_id,
        title: draft.title,
        agenda: draft.agenda,
        location: room ? '' : draft.location,
        roomEmail: room?.email || null,
        roomName: room?.name || null,
        online: draft.online,
        start: `${draft.date}T${draft.startTime}`,
        end: `${draft.date}T${draft.endTime}`,
        attendeeIds: kind === 'individual' && subject ? [subject.account_id] : draft.attendeeIds,
      };
      const result = await api<{ outlookError: string | null }>(draft.id ? `/api/points/${draft.id}` : '/api/points', {
        method: draft.id ? 'PUT' : 'POST',
        body: JSON.stringify(body),
      });
      if (result?.outlookError) alert(`Point enregistré, mais l'invitation Outlook n'a pas pu être envoyée :\n${result.outlookError}`);
      onSaved();
      onClose();
    } catch (err: any) {
      alert(err.message || "Erreur lors de l'enregistrement");
    } finally {
      setSaving(false);
    }
  }

  return (
    <form onSubmit={save} className="card p-4 mb-5 space-y-3">
      <input className="input" placeholder="Objet du point" required value={draft.title} onChange={(e) => setDraft({ ...draft, title: e.target.value })} />

      {kind === 'team' ? (
        <div>
          <p className="text-xs text-ink-500 mb-1">Participants</p>
          <div className="flex flex-wrap gap-2">
            {others.map((member) => {
              const checked = draft.attendeeIds.includes(member.account_id);
              const busy = checked ? busyDuring(scheduleOf(member.email)?.items || [], slot.start, slot.end) : [];
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
          </div>
        </div>
      ) : (
        <p className="text-sm text-ink-600">Point individuel{subject ? <> avec <strong>{subject.display_name}</strong></> : null}</p>
      )}

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
      <textarea className="input" rows={3} placeholder="Ordre du jour" value={draft.agenda} onChange={(e) => setDraft({ ...draft, agenda: e.target.value })} />
      <div className="flex gap-2">
        <button className="btn-primary text-sm" disabled={saving}>
          {saving ? 'Envoi…' : draft.id ? 'Enregistrer et mettre à jour l’invitation' : 'Planifier et envoyer l’invitation'}
        </button>
        <button type="button" className="btn-ghost text-sm" onClick={onClose}>Annuler</button>
      </div>
    </form>
  );
}

// ---------------------------------------------------------------------------
// Détail d'un point : compte rendu (manager) et parties des participants
// ---------------------------------------------------------------------------
function PointView({ pointId, me, isManager, onBack, onEdit }: { pointId: string; me: string; isManager: boolean; onBack: () => void; onEdit: (p: Point) => void }) {
  const [point, setPoint] = useState<PointDetail | null>(null);
  const [minutes, setMinutes] = useState('');
  const [contributions, setContributions] = useState<Record<string, string>>({});
  const [saving, setSaving] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function load() {
    try {
      const detail = await api<PointDetail>(`/api/points/${pointId}`);
      setPoint(detail);
      setMinutes(detail.minutes.content);
      setContributions(Object.fromEntries(detail.contributions.map((c) => [c.account_id, c.content])));
    } catch (err: any) {
      setError(err.message);
    }
  }

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pointId]);

  async function saveMinutes(validated: boolean) {
    setSaving('minutes');
    setMessage(null);
    try {
      await api(`/api/points/${pointId}/minutes`, { method: 'PUT', body: JSON.stringify({ content: minutes, validated }) });
      setMessage(validated ? 'Compte rendu validé.' : 'Compte rendu enregistré.');
      await load();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSaving(null);
    }
  }

  async function saveContribution(accountId: string) {
    setSaving(accountId);
    setMessage(null);
    try {
      await api(`/api/points/${pointId}/contribution`, {
        method: 'PUT',
        body: JSON.stringify({ content: contributions[accountId] || '', accountId: accountId === me ? undefined : accountId }),
      });
      setMessage('Partie enregistrée.');
      await load();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSaving(null);
    }
  }

  if (error && !point) return <p className="text-sm text-red-600">{error}</p>;
  if (!point) return <p className="text-sm text-ink-500">Chargement…</p>;

  // Ma partie d'abord.
  const ordered = [...point.contributions].sort((a, b) => Number(b.account_id === me) - Number(a.account_id === me));

  return (
    <div className="space-y-4">
      <button type="button" className="btn-ghost text-sm -ml-2" onClick={onBack}><ArrowLeft className="w-4 h-4" /> Retour aux points</button>

      <div className="card p-4">
        <div className="flex flex-wrap items-start justify-between gap-2">
          <div>
            <h2 className="text-lg font-semibold text-ink-900">
              {point.title}
              {point.status === 'cancelled' && <span className="badge bg-red-50 text-red-700 ml-2">Annulé</span>}
            </h2>
            <p className="text-sm text-ink-600">
              {formatDateTime(point.start_at)} – {point.end_at.slice(11, 16)}
              {point.kind === 'individual' && point.subject_name ? ` · avec ${point.subject_name}` : ''}
            </p>
            <div className="flex flex-wrap gap-x-3 text-xs text-ink-500 mt-1">
              {point.room_name ? (
                <span className="flex items-center gap-1"><DoorOpen className="w-3.5 h-3.5" /> {point.room_name}</span>
              ) : point.location && (
                <span className="flex items-center gap-1"><MapPin className="w-3.5 h-3.5" /> {point.location}</span>
              )}
              {point.online_meeting_url && point.status === 'planned' && (
                <a href={point.online_meeting_url} target="_blank" rel="noreferrer" className="flex items-center gap-1 text-elyade-700 hover:underline">
                  <Video className="w-3.5 h-3.5" /> Rejoindre sur Teams
                </a>
              )}
            </div>
            {point.agenda && <p className="text-sm text-ink-700 whitespace-pre-wrap mt-2">{point.agenda}</p>}
          </div>
          {isManager && point.status === 'planned' && !point.past && (
            <button type="button" className="btn-ghost text-sm" onClick={() => onEdit(point)}><Pencil className="w-4 h-4" /> Modifier</button>
          )}
        </div>
        {point.previous && (
          <p className="text-xs text-ink-500 mt-2">Repris du point du {formatDateTime(point.previous.start_at)} : compte rendu et préparations sont à compléter ou modifier.</p>
        )}
      </div>

      {message && <p className="text-sm text-green-700">{message}</p>}
      {error && <p className="text-sm text-red-600">{error}</p>}

      <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
        <div className="card p-4">
          <h3 className="font-semibold text-ink-900 mb-1">{isManager ? 'Préparation des participants' : 'Ma préparation'}</h3>
          <p className="text-xs text-ink-500 mb-3">
            {isManager
              ? 'Chaque collaborateur prépare sa partie avant le point (rappel 2 jours avant). Elle n’est visible que par lui et par vous.'
              : 'Visible uniquement par vous et le manager. Elle reprend votre préparation précédente (ou le compte rendu précédent) : mettez-la à jour avant le point.'}
          </p>
          {point.previous?.minutes && (
            <details className="mb-4 rounded-lg border border-ink-100 bg-ink-50/50 p-3">
              <summary className="text-sm font-medium text-ink-700 cursor-pointer">
                Compte rendu du point précédent ({formatDateTime(point.previous.start_at)})
              </summary>
              <p className="text-sm text-ink-700 whitespace-pre-wrap mt-2">{point.previous.minutes}</p>
            </details>
          )}
          {ordered.length === 0 && <p className="text-sm text-ink-400">Aucune préparation pour ce point.</p>}
          <div className="space-y-4">
            {ordered.map((c) => {
              const editable = c.account_id === me || isManager;
              return (
                <div key={c.account_id}>
                  <div className="flex items-center justify-between mb-1">
                    <p className="text-sm font-medium text-ink-800">
                      {c.account_id === me ? (isManager ? 'Ma préparation' : 'Votre préparation') : c.display_name}
                    </p>
                    {c.contributed_at ? (
                      <span className="badge bg-emerald-50 text-emerald-700"><CheckCircle2 className="w-3 h-3" /> préparée</span>
                    ) : (
                      <span className="badge bg-amber-50 text-amber-800"><Clock className="w-3 h-3" /> à préparer</span>
                    )}
                  </div>
                  {editable ? (
                    <>
                      <textarea
                        className="input text-sm"
                        rows={8}
                        value={contributions[c.account_id] ?? ''}
                        onChange={(e) => setContributions({ ...contributions, [c.account_id]: e.target.value })}
                      />
                      <button type="button" className="btn-secondary text-xs mt-1" disabled={saving === c.account_id} onClick={() => void saveContribution(c.account_id)}>
                        {saving === c.account_id ? 'Enregistrement…' : 'Enregistrer'}
                      </button>
                    </>
                  ) : (
                    <p className="text-sm text-ink-700 whitespace-pre-wrap bg-ink-50/60 rounded-lg p-3">{c.content || '—'}</p>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        <div className="card p-4">
          <div className="flex items-center justify-between mb-1">
            <h3 className="font-semibold text-ink-900">Compte rendu du point</h3>
            {point.minutes.validated && <span className="badge bg-emerald-50 text-emerald-700"><CheckCircle2 className="w-3 h-3" /> validé</span>}
          </div>
          <p className="text-xs text-ink-500 mb-3">
            {isManager
              ? 'Repris du compte rendu du point précédent tant que vous ne l’avez pas modifié ; complétez-le pendant ou après le point.'
              : 'Rédigé par le manager.'}
            {point.minutes.updated_by ? ` Dernière mise à jour : ${point.minutes.updated_by}.` : ''}
          </p>
          {isManager ? (
            <>
              <textarea className="input text-sm" rows={18} value={minutes} onChange={(e) => setMinutes(e.target.value)} />
              <div className="flex gap-2 mt-2">
                <button type="button" className="btn-secondary text-sm" disabled={saving === 'minutes'} onClick={() => void saveMinutes(false)}>Enregistrer</button>
                <button type="button" className="btn-primary text-sm" disabled={saving === 'minutes'} onClick={() => void saveMinutes(true)}>
                  <CheckCircle2 className="w-4 h-4" /> Valider le compte rendu
                </button>
              </div>
            </>
          ) : (
            <p className="text-sm text-ink-700 whitespace-pre-wrap bg-ink-50/60 rounded-lg p-3">{point.minutes.content || '—'}</p>
          )}
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
export default function Points() {
  const [meta, setMeta] = useState<{ isManager: boolean; me: string; people: Person[] } | null>(null);
  const [kind, setKind] = useState<Kind>('team');
  const [subjectId, setSubjectId] = useState('');
  const [points, setPoints] = useState<Point[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [planning, setPlanning] = useState<Draft | null>(null);
  const [openId, setOpenId] = useState<string | null>(null);

  useEffect(() => {
    api<{ isManager: boolean; me: string; people: Person[] }>('/api/points/meta')
      .then(setMeta)
      .catch((err) => setError(err.message));
  }, []);

  const subject = meta?.people.find((p) => p.account_id === (meta.isManager ? subjectId : meta.me)) || null;

  async function load() {
    if (!meta) return;
    setLoading(true);
    try {
      const query = kind === 'individual' && meta.isManager && subjectId ? `&subject=${subjectId}` : '';
      setPoints(await api<Point[]>(`/api/points?kind=${kind}${query}`));
      setError(null);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [meta, kind, subjectId]);

  function newDraft(): Draft {
    return {
      id: null,
      title: kind === 'team' ? "Point d'équipe informatique" : `Point individuel${subject ? ` — ${subject.display_name}` : ''}`,
      date: today(),
      startTime: '10:00',
      endTime: kind === 'team' ? '11:00' : '10:30',
      roomEmail: '',
      location: '',
      online: true,
      agenda: '',
      attendeeIds:
        kind === 'individual'
          ? subject ? [subject.account_id] : []
          : (meta?.people || []).filter((p) => p.account_id !== meta?.me).map((p) => p.account_id),
    };
  }

  function editDraft(point: Point): Draft {
    return {
      id: point.id,
      title: point.title,
      date: point.start_at.slice(0, 10),
      startTime: point.start_at.slice(11, 16),
      endTime: point.end_at.slice(11, 16),
      roomEmail: point.room_email || '',
      location: point.room_email ? '' : point.location || '',
      online: point.online,
      agenda: point.agenda || '',
      attendeeIds: point.attendee_ids,
    };
  }

  async function cancel(point: Point) {
    if (!confirm(`Annuler le point « ${point.title} » du ${formatDateTime(point.start_at)} ? Les participants seront prévenus.`)) return;
    try {
      const result = await api<{ outlookError: string | null }>(`/api/points/${point.id}/cancel`, { method: 'POST' });
      if (result.outlookError) alert(`Point annulé dans l'application, mais pas dans Outlook :\n${result.outlookError}`);
      await load();
    } catch (err: any) {
      alert(err.message);
    }
  }

  async function remove(point: Point) {
    if (!confirm(`Supprimer définitivement le point « ${point.title} » et son compte rendu ?`)) return;
    try {
      await api(`/api/points/${point.id}`, { method: 'DELETE' });
      await load();
    } catch (err: any) {
      alert(err.message);
    }
  }

  if (!meta) return <div className="p-6 text-ink-500">{error || 'Chargement…'}</div>;

  if (openId) {
    return (
      <div className="p-6 w-full max-w-[1600px] mx-auto">
        {planning ? (
          <PointPlanner
            kind={kind}
            subject={subject}
            people={meta.people}
            me={meta.me}
            initial={planning}
            onClose={() => setPlanning(null)}
            onSaved={() => void load()}
          />
        ) : (
          <PointView
            pointId={openId}
            me={meta.me}
            isManager={meta.isManager}
            onBack={() => {
              setOpenId(null);
              void load();
            }}
            onEdit={(p) => setPlanning(editDraft(p))}
          />
        )}
      </div>
    );
  }

  const upcoming = points.filter((p) => !p.past && p.status === 'planned').sort((a, b) => a.start_at.localeCompare(b.start_at));
  const past = points.filter((p) => p.past || p.status === 'cancelled');
  const canPlan = meta.isManager && (kind === 'team' || Boolean(subject));
  const collaborators = meta.people.filter((p) => p.account_id !== meta.me);

  function renderPoint(point: Point) {
    return (
      <article key={point.id} className={`card p-4 ${point.status === 'cancelled' ? 'opacity-60' : ''}`}>
        <div className="flex flex-wrap items-start justify-between gap-3">
          <button type="button" className="text-left min-w-0 flex-1" onClick={() => setOpenId(point.id)}>
            <p className="font-medium text-ink-900">
              {point.title}
              {point.status === 'cancelled' && <span className="badge bg-red-50 text-red-700 ml-2">Annulé</span>}
            </p>
            <p className="text-sm text-ink-600 mt-0.5">
              {formatDateTime(point.start_at)} – {point.end_at.slice(11, 16)}
              {point.kind === 'individual' && point.subject_name ? ` · ${point.subject_name}` : ''}
            </p>
            <div className="flex flex-wrap gap-2 mt-1.5">
              {point.my_contribution &&
                (point.my_contribution.done ? (
                  <span className="badge bg-emerald-50 text-emerald-700"><CheckCircle2 className="w-3 h-3" /> ma partie préparée</span>
                ) : (
                  point.status === 'planned' && !point.past && <span className="badge bg-amber-50 text-amber-800"><Clock className="w-3 h-3" /> ma partie à préparer</span>
                ))}
              {point.minutes_validated && <span className="badge bg-emerald-50 text-emerald-700">compte rendu validé</span>}
              {point.outlook_error && <span className="badge bg-amber-50 text-amber-800">invitation Outlook non envoyée</span>}
            </div>
          </button>
          <div className="flex items-center gap-1">
            {point.online_meeting_url && point.status === 'planned' && !point.past && (
              <a href={point.online_meeting_url} target="_blank" rel="noreferrer" className="btn-ghost text-xs"><Video className="w-3.5 h-3.5" /> Teams</a>
            )}
            <button type="button" className="btn-secondary text-xs" onClick={() => setOpenId(point.id)}>Ouvrir</button>
            {meta?.isManager && point.status === 'planned' && !point.past && (
              <button type="button" className="btn-ghost p-1.5 text-ink-400 hover:text-amber-600" title="Annuler le point" onClick={() => void cancel(point)}>
                <XCircle className="w-4 h-4" />
              </button>
            )}
            {meta?.isManager && (
              <button type="button" className="btn-ghost p-1.5 text-ink-400 hover:text-red-600" title="Supprimer" onClick={() => void remove(point)}>
                <Trash2 className="w-4 h-4" />
              </button>
            )}
          </div>
        </div>
      </article>
    );
  }

  return (
    <div className="p-6 w-full max-w-[1400px] mx-auto space-y-5">
      <div>
        <h1 className="text-xl font-semibold text-ink-900">Points d'équipe</h1>
        <p className="text-sm text-ink-500">
          Comptes rendus des points d'équipe et individuels, repris d'un point à l'autre. Les points individuels ne sont visibles que par le collaborateur concerné et le manager.
        </p>
      </div>

      <div className="flex gap-1 border-b border-ink-100">
        {(
          [
            ['team', "Points d'équipe", Users],
            ['individual', meta.isManager ? 'Points individuels' : 'Mes points individuels', User],
          ] as const
        ).map(([key, label, Icon]) => (
          <button
            key={key}
            type="button"
            onClick={() => {
              setKind(key);
              setPlanning(null);
            }}
            className={`px-4 py-2 text-sm font-medium border-b-2 -mb-px flex items-center gap-1.5 ${kind === key ? 'border-elyade-600 text-elyade-700' : 'border-transparent text-ink-500 hover:text-ink-700'}`}
          >
            <Icon className="w-4 h-4" /> {label}
          </button>
        ))}
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}

      <div className="flex flex-wrap items-center justify-between gap-2">
        {kind === 'individual' && meta.isManager ? (
          <label className="text-sm flex items-center gap-2">
            Collaborateur
            <select className="input py-1.5 w-64" value={subjectId} onChange={(e) => setSubjectId(e.target.value)}>
              <option value="">Tous</option>
              {collaborators.map((p) => (
                <option key={p.account_id} value={p.account_id}>{p.display_name}</option>
              ))}
            </select>
          </label>
        ) : (
          <span />
        )}
        {canPlan && !planning && (
          <button type="button" className="btn-primary text-sm" onClick={() => setPlanning(newDraft())}>
            <CalendarPlus className="w-4 h-4" /> {kind === 'team' ? "Planifier un point d'équipe" : `Planifier un point avec ${subject?.display_name}`}
          </button>
        )}
        {meta.isManager && kind === 'individual' && !subject && <span className="text-xs text-ink-500">Choisissez un collaborateur pour planifier un point.</span>}
      </div>

      {planning && (
        <PointPlanner
          kind={kind}
          subject={subject}
          people={meta.people}
          me={meta.me}
          initial={planning}
          onClose={() => setPlanning(null)}
          onSaved={() => void load()}
        />
      )}

      {loading ? (
        <p className="text-sm text-ink-500">Chargement…</p>
      ) : (
        <>
          <h2 className="text-sm font-semibold text-ink-700">À venir ({upcoming.length})</h2>
          {upcoming.length === 0 && <p className="text-sm text-ink-400">Aucun point planifié.</p>}
          <div className="space-y-3">{upcoming.map(renderPoint)}</div>
          {past.length > 0 && (
            <>
              <h2 className="text-sm font-semibold text-ink-700 pt-2">Passés et annulés ({past.length})</h2>
              <div className="space-y-3">{past.map(renderPoint)}</div>
            </>
          )}
        </>
      )}
    </div>
  );
}
