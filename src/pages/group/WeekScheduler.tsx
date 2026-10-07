import { ChevronLeft, ChevronRight } from 'lucide-react';
import type { Availability } from './types';
import { addDays, busyDuring, statusLabel, toMinutes, toTime } from './scheduleUtils';

const DAY_NAMES = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];
const FIRST_SLOT = 8 * 60; // 08:00
const LAST_SLOT = 19 * 60; // dernier créneau commençant à 18:30
const SLOT = 30;
// Semaine de travail (lundi-vendredi, 8 h - 19 h) : pour chaque créneau de
// 30 min, nombre d'invités occupés et occupation de la salle choisie.
// Cliquer sur un créneau y place le début de la réunion.
export default function WeekScheduler({ weekStart, onWeekChange, availability, loading, roomEmail, selection, onSelect }: {
  weekStart: string;
  onWeekChange: (weekStart: string) => void;
  availability: Availability | null;
  loading: boolean;
  roomEmail: string | null;
  selection: { date: string; start: string; end: string };
  onSelect: (date: string, start: string) => void;
}) {
  const days = DAY_NAMES.map((_, i) => addDays(weekStart, i));
  const slots: number[] = [];
  for (let m = FIRST_SLOT; m < LAST_SLOT; m += SLOT) slots.push(m);

  const people = availability?.people || [];
  const scheduleOf = (email: string) => availability?.schedules.find((s) => s.email === email);
  const roomSchedule = roomEmail ? scheduleOf(roomEmail.toLowerCase()) : undefined;
  const selStart = toMinutes(selection.start);
  const selEnd = toMinutes(selection.end);

  function cell(day: string, minutes: number) {
    const start = `${day}T${toTime(minutes)}`;
    const end = `${day}T${toTime(minutes + SLOT)}`;
    const busyPeople = people
      .map((p) => ({ person: p, busy: busyDuring(scheduleOf(p.email)?.items || [], start, end) }))
      .filter((entry) => entry.busy.length > 0);
    const roomBusy = roomSchedule ? busyDuring(roomSchedule.items, start, end).length > 0 : false;
    const selected = day === selection.date && minutes >= selStart && minutes < selEnd;
    const ratio = people.length ? busyPeople.length / people.length : 0;
    const tone = busyPeople.length === 0
      ? 'bg-emerald-50 hover:bg-emerald-100'
      : ratio >= 1
        ? 'bg-red-200 hover:bg-red-300'
        : ratio >= 0.5
          ? 'bg-amber-200 hover:bg-amber-300'
          : 'bg-amber-100 hover:bg-amber-200';
    const title = [
      `${toTime(minutes)} – ${toTime(minutes + SLOT)}`,
      busyPeople.length === 0 ? 'Tout le monde est disponible' : busyPeople.map((e) => `${e.person.display_name} : ${statusLabel(e.busy[0].status)}`).join('\n'),
      roomEmail ? (roomBusy ? 'Salle occupée' : 'Salle libre') : '',
    ].filter(Boolean).join('\n');
    return (
      <button
        key={start}
        type="button"
        title={title}
        onClick={() => onSelect(day, toTime(minutes))}
        className={`relative h-5 border-b border-r border-white text-[10px] leading-none ${tone} ${selected ? 'ring-2 ring-inset ring-elyade-600' : ''}`}
        style={roomBusy ? { backgroundImage: 'repeating-linear-gradient(45deg, rgba(71,85,105,.35) 0 3px, transparent 3px 7px)' } : undefined}
      >
        {busyPeople.length > 0 && people.length > 1 && <span className="text-ink-700">{busyPeople.length}</span>}
      </button>
    );
  }

  const unreadable = availability?.schedules.filter((s) => s.error) || [];

  return (
    <div className="border border-ink-200 rounded-lg p-3">
      <div className="flex items-center justify-between mb-2">
        <p className="text-xs font-medium text-ink-700">Disponibilités de la semaine {loading && <span className="text-ink-400">(chargement…)</span>}</p>
        <div className="flex items-center gap-1">
          <button type="button" className="btn-ghost p-1" aria-label="Semaine précédente" onClick={() => onWeekChange(addDays(weekStart, -7))}>
            <ChevronLeft className="w-4 h-4" />
          </button>
          <span className="text-xs text-ink-600 min-w-[9rem] text-center">
            {days[0].slice(8, 10)}/{days[0].slice(5, 7)} – {days[4].slice(8, 10)}/{days[4].slice(5, 7)}/{days[4].slice(0, 4)}
          </span>
          <button type="button" className="btn-ghost p-1" aria-label="Semaine suivante" onClick={() => onWeekChange(addDays(weekStart, 7))}>
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>

      <div className={`grid grid-cols-[3rem_repeat(5,1fr)] text-xs ${loading ? 'opacity-60' : ''}`}>
        <div />
        {days.map((day, i) => (
          <div key={day} className={`text-center font-medium pb-1 ${day === selection.date ? 'text-elyade-700' : 'text-ink-600'}`}>
            {DAY_NAMES[i]} {day.slice(8, 10)}/{day.slice(5, 7)}
          </div>
        ))}
        {slots.map((minutes) => (
          <div key={minutes} className="contents">
            <div className="h-5 pr-1 text-right text-[10px] text-ink-400 leading-5">{minutes % 60 === 0 ? toTime(minutes) : ''}</div>
            {days.map((day) => cell(day, minutes))}
          </div>
        ))}
      </div>

      <div className="flex flex-wrap gap-x-3 gap-y-1 mt-2 text-[11px] text-ink-500">
        <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-sm bg-emerald-50 border border-emerald-200" /> Tous disponibles</span>
        <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-sm bg-amber-100" /> Quelques occupés (nombre affiché)</span>
        <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-sm bg-red-200" /> Tous occupés</span>
        {roomEmail && (
          <span className="flex items-center gap-1">
            <span className="w-3 h-3 rounded-sm bg-white border border-ink-300" style={{ backgroundImage: 'repeating-linear-gradient(45deg, rgba(71,85,105,.35) 0 3px, transparent 3px 7px)' }} /> Salle occupée
          </span>
        )}
        <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-sm ring-2 ring-inset ring-elyade-600" /> Créneau choisi</span>
      </div>
      {unreadable.length > 0 && (
        <p className="text-[11px] text-amber-700 mt-1">Agenda illisible pour : {unreadable.map((s) => s.email).join(', ')}</p>
      )}
    </div>
  );
}
