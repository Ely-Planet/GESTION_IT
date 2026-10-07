import type { BusyItem } from './types';

// Outils de calcul des créneaux (heure de Paris, chaînes AAAA-MM-JJTHH:MM).
const STATUS_FR: Record<string, string> = {
  busy: 'occupé',
  tentative: 'provisoire',
  oof: 'absent',
  workingElsewhere: 'travaille ailleurs',
  unknown: 'inconnu',
};

export const toMinutes = (time: string) => Number(time.slice(0, 2)) * 60 + Number(time.slice(3, 5));
export const toTime = (minutes: number) => `${String(Math.floor(minutes / 60)).padStart(2, '0')}:${String(minutes % 60).padStart(2, '0')}`;

export function addDays(date: string, days: number) {
  const d = new Date(`${date}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString().slice(0, 10);
}

export function mondayOf(date: string) {
  const d = new Date(`${date}T00:00:00Z`);
  return addDays(date, -((d.getUTCDay() + 6) % 7));
}

// Statuts d'un agenda qui recouvrent l'intervalle [start, end) ("AAAA-MM-JJTHH:MM").
export function busyDuring(items: BusyItem[], start: string, end: string) {
  return items.filter((item) => item.start < end && item.end > start && item.status !== 'workingElsewhere');
}

export const statusLabel = (status: string) => STATUS_FR[status] || status;

