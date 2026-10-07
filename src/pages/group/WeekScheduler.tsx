import { useEffect, useRef } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import type { Availability } from './types';
import { addDays, busyDuring, mondayOf, statusLabel, toMinutes, toTime } from './scheduleUtils';

const DAY_NAMES = ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.'];
const MONTHS = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
const FIRST_SLOT = 8 * 60; // 08:00
const LAST_SLOT = 19 * 60; // fin de journée
const SLOT = 30;
const ROW_PX = 26;
const STRIPES = 'repeating-linear-gradient(135deg, rgba(100,116,139,.28) 0 4px, transparent 4px 9px)';

const parisNow = () => {
  const parts = new Intl.DateTimeFormat('sv-SE', { timeZone: 'Europe/Paris', dateStyle: 'short', timeStyle: 'short' }).format(new Date());
  return parts.replace(' ', 'T').slice(0, 16); // AAAA-MM-JJTHH:MM
};

function weekLabel(weekStart: string) {
  const end = addDays(weekStart, 4);
  const [, m1, d1] = weekStart.split('-').map(Number);
  const [y2, m2, d2] = end.split('-').map(Number);
  return m1 === m2 ? `${d1} – ${d2} ${MONTHS[m2 - 1]} ${y2}` : `${d1} ${MONTHS[m1 - 1]} – ${d2} ${MONTHS[m2 - 1]} ${y2}`;
}

// Semaine de travail (lundi-vendredi, 8 h - 19 h) : pour chaque créneau de
// 30 min, invités occupés et occupation de la salle choisie. Un clic sur un
// créneau y place le début de la réunion (durée conservée).
export default function WeekScheduler({ weekStart, onWeekChange, availability, loading, roomEmail, selection, onSelect }: {
  weekStart: string;
  onWeekChange: (weekStart: string) => void;
  availability: Availability | null;
  loading: boolean;
  roomEmail: string | null;
  selection: { date: string; start: string; end: string };
  onSelect: (date: string, start: string) => void;
}) {
  const scroller = useRef<HTMLDivElement>(null);
  const now = parisNow();
  const today = now.slice(0, 10);
  const days = DAY_NAMES.map((_, i) => addDays(weekStart, i));
  const slots: number[] = [];
  for (let m = FIRST_SLOT; m < LAST_SLOT; m += SLOT) slots.push(m);

  const people = availability?.people || [];
  const scheduleOf = (email: string) => availability?.schedules.find((s) => s.email === email);
  const roomSchedule = roomEmail ? scheduleOf(roomEmail.toLowerCase()) : undefined;
  const selStart = toMinutes(selection.start);
  const selEnd = toMinutes(selection.end);

  // Fait défiler la grille jusqu'au créneau choisi.
  useEffect(() => {
    if (!scroller.current) return;
    const top = Math.max(0, ((selStart - FIRST_SLOT) / SLOT) * ROW_PX - ROW_PX * 2);
    scroller.current.scrollTo({ top, behavior: 'smooth' });
  }, [selStart, weekStart]);

  function renderCell(day: string, minutes: number) {
    const start = `${day}T${toTime(minutes)}`;
    const end = `${day}T${toTime(minutes + SLOT)}`;
    const past = end <= now;
    const busyPeople = people
      .map((p) => ({ person: p, busy: busyDuring(scheduleOf(p.email)?.items || [], start, end) }))
      .filter((entry) => entry.busy.length > 0);
    const roomBusy = roomSchedule ? busyDuring(roomSchedule.items, start, end).length > 0 : false;
    const selected = day === selection.date && minutes >= selStart && minutes < selEnd;
    const firstSelected = selected && minutes === Math.max(selStart - (selStart % SLOT), FIRST_SLOT);
    const allBusy = people.length > 0 && busyPeople.length === people.length;

    const background = selected
      ? 'bg-elyade-600 text-white'
      : past
        ? 'bg-ink-50'
        : allBusy
          ? 'bg-rose-100'
          : busyPeople.length
            ? 'bg-amber-50'
            : 'bg-white hover:bg-elyade-50';

    const title = [
      `${toTime(minutes)} – ${toTime(minutes + SLOT)}`,
      busyPeople.length === 0 ? 'Tout le monde est disponible' : busyPeople.map((e) => `• ${e.person.display_name} : ${statusLabel(e.busy[0].status)}`).join('\n'),
      roomEmail ? (roomBusy ? 'Salle occupée' : 'Salle libre') : '',
      past ? 'Créneau passé' : '',
    ].filter(Boolean).join('\n');

    return (
      <button
        key={start}
        type="button"
        title={title}
        disabled={past}
        onClick={() => onSelect(day, toTime(minutes))}
        className={`relative border-l border-ink-100 ${minutes % 60 === 0 ? 'border-t border-t-ink-200' : 'border-t border-t-ink-100 border-dashed'} ${background} ${past ? 'cursor-not-allowed' : 'cursor-pointer'} transition-colors`}
        style={{ height: ROW_PX, ...(roomBusy && !selected ? { backgroundImage: STRIPES } : {}) }}
      >
        {firstSelected && (
          <span className="absolute inset-x-1 top-0.5 text-[10px] font-semibold leading-tight text-left truncate">
            {selection.start} – {selection.end}
          </span>
        )}
        {!selected && busyPeople.length > 0 && (
          <span className={`absolute right-1 top-1/2 -translate-y-1/2 rounded-full px-1.5 text-[10px] font-medium leading-4 ${allBusy ? 'bg-rose-500 text-white' : 'bg-amber-400 text-white'}`}>
            {people.length > 1 ? `${busyPeople.length}/${people.length}` : '•'}
          </span>
        )}
      </button>
    );
  }

  const unreadable = availability?.schedules.filter((s) => s.error) || [];
  const thisWeek = mondayOf(today);

  return (
    <div className="rounded-xl border border-ink-200 bg-white overflow-hidden">
      {/* Barre de navigation */}
      <div className="flex flex-wrap items-center justify-between gap-2 px-3 py-2 border-b border-ink-100 bg-ink-50/60">
        <p className="text-sm font-medium text-ink-800">
          Disponibilités {loading && <span className="text-xs font-normal text-ink-400">· mise à jour…</span>}
        </p>
        <div className="flex items-center gap-1">
          {weekStart !== thisWeek && (
            <button type="button" className="btn-ghost text-xs px-2 py-1" onClick={() => onWeekChange(thisWeek)}>Cette semaine</button>
          )}
          <button type="button" className="btn-ghost p-1" aria-label="Semaine précédente" onClick={() => onWeekChange(addDays(weekStart, -7))}>
            <ChevronLeft className="w-4 h-4" />
          </button>
          <span className="text-sm font-medium text-ink-700 min-w-[10rem] text-center">{weekLabel(weekStart)}</span>
          <button type="button" className="btn-ghost p-1" aria-label="Semaine suivante" onClick={() => onWeekChange(addDays(weekStart, 7))}>
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* En-tête des jours */}
      <div className="grid grid-cols-[3.5rem_repeat(5,1fr)] border-b border-ink-200">
        <div />
        {days.map((day, i) => {
          const isToday = day === today;
          const isSelected = day === selection.date;
          return (
            <div key={day} className={`py-1.5 text-center border-l border-ink-100 ${isSelected ? 'bg-elyade-50' : ''}`}>
              <p className={`text-[11px] uppercase tracking-wide ${isSelected ? 'text-elyade-700' : 'text-ink-500'}`}>{DAY_NAMES[i]}</p>
              <p className={`mx-auto mt-0.5 w-7 h-7 rounded-full flex items-center justify-center text-sm font-semibold ${isToday ? 'bg-elyade-600 text-white' : isSelected ? 'text-elyade-700' : 'text-ink-800'}`}>
                {Number(day.slice(8, 10))}
              </p>
            </div>
          );
        })}
      </div>

      {/* Grille horaire */}
      <div ref={scroller} className={`max-h-[22rem] overflow-y-auto ${loading ? 'opacity-70' : ''}`}>
        <div className="grid grid-cols-[3.5rem_repeat(5,1fr)]">
          {slots.map((minutes) => (
            <div key={minutes} className="contents">
              <div className="relative pr-2 text-right" style={{ height: ROW_PX }}>
                {minutes % 60 === 0 && <span className="absolute right-2 -top-2 text-[11px] text-ink-400 bg-white px-0.5">{toTime(minutes)}</span>}
              </div>
              {days.map((day) => renderCell(day, minutes))}
            </div>
          ))}
        </div>
      </div>

      {/* Légende */}
      <div className="flex flex-wrap gap-x-4 gap-y-1 px-3 py-2 border-t border-ink-100 text-[11px] text-ink-500">
        <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-white border border-ink-200" /> Tous disponibles</span>
        <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-amber-50 border border-amber-200" /> Certains occupés</span>
        <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-rose-100 border border-rose-200" /> Tous occupés</span>
        {roomEmail && (
          <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm border border-ink-200" style={{ backgroundImage: STRIPES }} /> Salle occupée</span>
        )}
        <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-sm bg-elyade-600" /> Votre réunion</span>
        <span className="text-ink-400">Survolez un créneau pour voir qui est occupé.</span>
      </div>
      {unreadable.length > 0 && (
        <p className="px-3 pb-2 text-[11px] text-amber-700">Agenda illisible pour : {unreadable.map((s) => s.email).join(', ')}</p>
      )}
    </div>
  );
}
