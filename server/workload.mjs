// Charge des techniciens / développeurs par semaine, mois ou année.
//
// Capacité : weekly_capacity_hours (35 h par défaut) réparties sur les jours
// ouvrés (lundi-vendredi, hors jours fériés français), moins les congés lus
// dans le calendrier Outlook de chacun (Microsoft Graph).
// Charge : reste à faire des tâches actives (estimé - passé), réparti sur les
// jours ouvrés entre aujourd'hui et la date de fin de la tâche. Une tâche
// découpée en sous-tâches voit son reste à faire partagé à parts égales entre
// ses sous-tâches non terminées, chacune pour la personne qui lui est affectée.
import { pool } from './db.mjs';

const DAY_MS = 24 * 60 * 60 * 1000;
const PERIODS = ['week', 'month', 'year'];
const MONTHS = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];

// ---- Jours (AAAA-MM-JJ <-> numéro de jour UTC, sans fuseau) ----
function toDay(value) {
  const [y, m, d] = String(value).slice(0, 10).split('-').map(Number);
  return Date.UTC(y, m - 1, d) / DAY_MS;
}
function fromDay(day) {
  return new Date(day * DAY_MS).toISOString().slice(0, 10);
}
function parisToday() {
  // 'sv-SE' formate en AAAA-MM-JJ.
  return toDay(new Intl.DateTimeFormat('sv-SE', { timeZone: 'Europe/Paris' }).format(new Date()));
}
function frDay(day) {
  const [y, m, d] = fromDay(day).split('-');
  return `${d}/${m}/${y}`;
}

// Jours fériés français (fixes + liés à Pâques).
const holidayCache = new Map();
function frenchHolidays(year) {
  if (holidayCache.has(year)) return holidayCache.get(year);
  // Calcul de Pâques (algorithme de Meeus/Jones/Butcher).
  const a = year % 19;
  const b = Math.floor(year / 100);
  const c = year % 100;
  const d = Math.floor(b / 4);
  const e = b % 4;
  const f = Math.floor((b + 8) / 25);
  const g = Math.floor((b - f + 1) / 3);
  const h = (19 * a + b - d - g + 15) % 30;
  const i = Math.floor(c / 4);
  const k = c % 4;
  const l = (32 + 2 * e + 2 * i - h - k) % 7;
  const m = Math.floor((a + 11 * h + 22 * l) / 451);
  const month = Math.floor((h + l - 7 * m + 114) / 31);
  const day = ((h + l - 7 * m + 114) % 31) + 1;
  const easter = Date.UTC(year, month - 1, day) / DAY_MS;
  const fixed = ['01-01', '05-01', '05-08', '07-14', '08-15', '11-01', '11-11', '12-25'].map((md) => toDay(`${year}-${md}`));
  const set = new Set([...fixed, easter + 1, easter + 39, easter + 50]); // lundi de Pâques, Ascension, lundi de Pentecôte
  holidayCache.set(year, set);
  return set;
}

function isWorkingDay(day) {
  const weekday = new Date(day * DAY_MS).getUTCDay();
  if (weekday === 0 || weekday === 6) return false;
  return !frenchHolidays(new Date(day * DAY_MS).getUTCFullYear()).has(day);
}

function workingDaysBetween(start, end) {
  const days = [];
  for (let day = start; day <= end; day++) if (isWorkingDay(day)) days.push(day);
  return days;
}

// Bornes de la période contenant la date de référence.
export function periodRange(period, refDay) {
  const ref = new Date(refDay * DAY_MS);
  const y = ref.getUTCFullYear();
  const m = ref.getUTCMonth();
  if (period === 'week') {
    const start = refDay - ((ref.getUTCDay() + 6) % 7);
    return { start, end: start + 6, label: `Semaine du ${frDay(start)} au ${frDay(start + 6)}` };
  }
  if (period === 'month') {
    const start = Date.UTC(y, m, 1) / DAY_MS;
    const end = Date.UTC(y, m + 1, 1) / DAY_MS - 1;
    return { start, end, label: `${MONTHS[m][0].toUpperCase()}${MONTHS[m].slice(1)} ${y}` };
  }
  return { start: Date.UTC(y, 0, 1) / DAY_MS, end: Date.UTC(y, 11, 31) / DAY_MS, label: `Année ${y}` };
}

// ---- Congés Outlook (Microsoft Graph) ----
// Événements "Absent" (showAs = oof) ou dont l'objet évoque un congé.
const LEAVE_SUBJECT = /cong[ée]|\bc\.?p\b|\brtt\b|vacance|absen|maladie|r[ée]cup/i;
const leaveCache = new Map(); // clé utilisateur|début|fin -> { at, events }
const LEAVE_CACHE_MS = 15 * 60 * 1000;

async function fetchLeaveEvents(token, userId, start, end) {
  const key = `${userId}|${start}|${end}`;
  const cached = leaveCache.get(key);
  if (cached && Date.now() - cached.at < LEAVE_CACHE_MS) return cached.events;

  const events = [];
  let url =
    `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(userId)}/calendarView` +
    `?startDateTime=${fromDay(start)}T00:00:00&endDateTime=${fromDay(end + 1)}T00:00:00` +
    `&$select=subject,start,end,isAllDay,showAs&$top=250`;
  while (url) {
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
        Accept: 'application/json',
        Prefer: 'outlook.timezone="Europe/Paris"'
      }
    });
    if (!response.ok) {
      const details = await response.text();
      const error = new Error(`Calendrier Outlook illisible (${response.status})`);
      error.status = response.status;
      error.details = details;
      throw error;
    }
    const page = await response.json();
    for (const event of page.value || []) {
      if (event.showAs === 'oof' || LEAVE_SUBJECT.test(event.subject || '')) events.push(event);
    }
    url = page['@odata.nextLink'] || null;
  }
  leaveCache.set(key, { at: Date.now(), events });
  return events;
}

// Heures d'absence par jour ouvré (plafonnées à la capacité du jour).
function leaveHoursByDay(events, dailyHours, start, end) {
  const byDay = new Map();
  const add = (day, hours, subject) => {
    if (day < start || day > end || !isWorkingDay(day) || hours <= 0) return;
    const entry = byDay.get(day) || { hours: 0, subjects: new Set() };
    entry.hours = Math.min(dailyHours, entry.hours + hours);
    if (subject) entry.subjects.add(subject);
    byDay.set(day, entry);
  };
  for (const event of events) {
    // Heures locales Paris (Prefer outlook.timezone) : "AAAA-MM-JJTHH:MM:SS.0000000".
    const s = event.start?.dateTime;
    const e = event.end?.dateTime;
    if (!s || !e) continue;
    const startMs = Date.parse(`${s.slice(0, 19)}Z`);
    const endMs = Date.parse(`${e.slice(0, 19)}Z`);
    if (!(endMs > startMs)) continue;
    for (let day = Math.floor(startMs / DAY_MS); day * DAY_MS < endMs; day++) {
      if (event.isAllDay) {
        add(day, dailyHours, event.subject);
      } else {
        const overlap = Math.min(endMs, (day + 1) * DAY_MS) - Math.max(startMs, day * DAY_MS);
        add(day, overlap / 3600000, event.subject);
      }
    }
  }
  return byDay;
}

// ---- Répartition d'une tâche entre les personnes (sous-tâches) ----
// Reste à faire de la tâche partagé à parts égales entre ses sous-tâches non
// terminées ; chaque part va à la personne affectée à la sous-tâche (à défaut,
// au responsable de la tâche) et suit les dates de la sous-tâche (à défaut,
// celles de la tâche). Sans sous-tâche ouverte, tout revient au responsable.
function splitTaskWork(task, subtasks = []) {
  const remaining = Math.max(Number(task.estimated_hours) - Number(task.spent_hours), 0);
  const open = subtasks.filter((subtask) => subtask.status !== 'done');
  if (!open.length) {
    return task.assignee_account_id
      ? [{ accountId: task.assignee_account_id, remaining, start_date: task.start_date, end_date: task.end_date, viaSousTache: false }]
      : [];
  }
  const share = remaining / open.length;
  return open
    .map((subtask) => {
      const hasOwnDates = Boolean(subtask.start_date || subtask.end_date);
      return {
        accountId: subtask.assignee_account_id || task.assignee_account_id,
        remaining: share,
        start_date: hasOwnDates ? subtask.start_date : task.start_date,
        end_date: hasOwnDates ? subtask.end_date : task.end_date,
        viaSousTache: true
      };
    })
    .filter((item) => item.accountId);
}

// ---- Répartition de la charge sur les jours ----
// item : { remaining, start_date, end_date } (ou une tâche : estimé - passé).
// Renvoie { remaining, perDay, days } ou null si non planifiée.
function spreadTask(task, today) {
  const remaining = task.remaining ?? Math.max(Number(task.estimated_hours) - Number(task.spent_hours), 0);
  if (remaining <= 0) return { remaining: 0, days: [], perDay: 0 };
  const startDate = task.start_date ? toDay(task.start_date) : null;
  const endDate = task.end_date ? toDay(task.end_date) : null;
  if (startDate === null && endDate === null) return null;

  const end = endDate ?? startDate;
  // Tâche en retard : tout le reste à faire est dû aujourd'hui.
  if (end < today) return { remaining, days: [today], perDay: remaining };
  const from = Math.max(startDate ?? today, today);
  let days = workingDaysBetween(from, end);
  if (!days.length) days = [end]; // fenêtre sur un week-end / jour férié
  return { remaining, days, perDay: remaining / days.length };
}

const round1 = (value) => Math.round(value * 10) / 10;

// Temps saisi attribué aux personnes (sous-requête : task_id, account_id,
// hours, logged_at). Sur une tâche découpée, chaque saisie est partagée à parts
// égales entre toutes ses sous-tâches (terminées comprises : le temps couvre
// aussi le travail fait), au profit de la personne affectée à chacune ; à
// défaut, de la personne à qui la saisie était attribuée.
export const TIME_PARTS_SQL = `(
  SELECT e.task_id,
         COALESCE(s.assignee_account_id, e.account_id) AS account_id,
         e.hours / COUNT(*) OVER (PARTITION BY e.id) AS hours,
         e.logged_at
  FROM project_time_entries e
  JOIN project_subtasks s ON s.task_id = e.task_id
  UNION ALL
  SELECT e.task_id, e.account_id, e.hours, e.logged_at
  FROM project_time_entries e
  WHERE NOT EXISTS (SELECT 1 FROM project_subtasks s WHERE s.task_id = e.task_id)
)`;

export async function computeWorkload({ period, date, getGraphToken }) {
  const kind = PERIODS.includes(period) ? period : 'week';
  const today = parisToday();
  const refDay = date && /^\d{4}-\d{2}-\d{2}$/.test(date) ? toDay(date) : today;
  const range = periodRange(kind, refDay);
  const periodWorkingDays = workingDaysBetween(range.start, range.end);
  const containsToday = today >= range.start && today <= range.end;

  const members = (
    await pool.query(
      `SELECT id, display_name, weekly_capacity_hours FROM app_accounts
       WHERE is_it = true OR is_it_manager = true ORDER BY display_name`
    )
  ).rows;

  const tasks = (
    await pool.query(
      `SELECT t.id, t.project_id, t.assignee_account_id, t.estimated_hours, t.spent_hours,
              to_char(t.start_date, 'YYYY-MM-DD') AS start_date,
              to_char(t.end_date, 'YYYY-MM-DD') AS end_date,
              p.name AS project_name
       FROM project_tasks t
       JOIN projects p ON p.id = t.project_id
       WHERE t.status <> 'done'
         AND (t.assignee_account_id IS NOT NULL
              OR EXISTS (SELECT 1 FROM project_subtasks s WHERE s.task_id = t.id AND s.assignee_account_id IS NOT NULL))
         AND p.status <> 'archive'
         AND p.project_state IS DISTINCT FROM 'closed'`
    )
  ).rows;

  const subtasksByTask = {};
  if (tasks.length) {
    const subtaskRows = (
      await pool.query(
        `SELECT task_id, status, assignee_account_id,
                to_char(start_date, 'YYYY-MM-DD') AS start_date,
                to_char(end_date, 'YYYY-MM-DD') AS end_date
         FROM project_subtasks WHERE task_id = ANY($1::uuid[])`,
        [tasks.map((task) => task.id)]
      )
    ).rows;
    for (const row of subtaskRows) (subtasksByTask[row.task_id] ||= []).push(row);
  }

  // Parts de travail : une par tâche, ou une par sous-tâche ouverte.
  const workItems = tasks.flatMap((task) =>
    splitTaskWork(task, subtasksByTask[task.id]).map((item) => ({
      ...item,
      taskId: task.id,
      projectId: task.project_id,
      projectName: task.project_name
    }))
  );

  // Temps réellement saisi sur la période (journal daté).
  const timeRows = (
    await pool.query(
      `SELECT account_id, SUM(hours)::float AS hours
       FROM ${TIME_PARTS_SQL} parts
       WHERE (logged_at AT TIME ZONE 'Europe/Paris')::date BETWEEN $1::date AND $2::date
       GROUP BY account_id`,
      [fromDay(range.start), fromDay(range.end)]
    )
  ).rows;
  const timeByAccount = Object.fromEntries(timeRows.map((row) => [row.account_id, row.hours]));

  // Congés : un seul jeton Graph ; une erreur (permission manquante…) n'empêche
  // pas l'affichage, elle est signalée.
  let token = null;
  let calendarError = null;
  try {
    token = await getGraphToken();
  } catch (error) {
    calendarError = error.message || String(error);
  }

  const technicians = [];
  for (const member of members) {
    const weekly = Number(member.weekly_capacity_hours) || 35;
    const daily = weekly / 5;

    let leaveDays = new Map();
    let memberCalendarError = null;
    if (token) {
      try {
        const events = await fetchLeaveEvents(token, member.id, range.start, range.end);
        leaveDays = leaveHoursByDay(events, daily, range.start, range.end);
      } catch (error) {
        memberCalendarError =
          error.status === 403 || error.status === 401
            ? 'accès au calendrier refusé'
            : error.status === 404
              ? 'boîte aux lettres introuvable'
              : error.message || String(error);
        if (!calendarError && (error.status === 403 || error.status === 401)) {
          calendarError = "Accès aux calendriers Outlook refusé : la permission Microsoft Graph Calendars.ReadBasic.All (application) n'est pas accordée.";
        }
      }
    }

    const grossCapacity = periodWorkingDays.length * daily;
    const leaveHours = [...leaveDays.values()].reduce((sum, entry) => sum + entry.hours, 0);
    const capacity = Math.max(grossCapacity - leaveHours, 0);

    let planned = 0;
    let unplanned = 0;
    const byProject = {};
    for (const item of workItems.filter((w) => w.accountId === member.id)) {
      const spread = spreadTask(item, today);
      let inPeriod = 0;
      let isUnplanned = false;
      if (spread === null) {
        isUnplanned = true;
        // Sans date : comptée dans la période en cours.
        if (containsToday) inPeriod = item.remaining;
      } else {
        inPeriod = spread.days.filter((day) => day >= range.start && day <= range.end).length * spread.perDay;
      }
      if (isUnplanned) unplanned += inPeriod;
      else planned += inPeriod;
      if (inPeriod > 0 || isUnplanned) {
        const entry = (byProject[item.projectId] ||= {
          projetId: item.projectId,
          nom: item.projectName,
          chargeH: 0,
          taches: new Set(),
          nonPlanifiees: new Set(),
          viaSousTaches: new Set()
        });
        entry.chargeH += inPeriod;
        entry.taches.add(item.taskId);
        if (isUnplanned) entry.nonPlanifiees.add(item.taskId);
        if (item.viaSousTache) entry.viaSousTaches.add(item.taskId);
      }
    }

    const load = planned + unplanned;
    technicians.push({
      userId: member.id,
      nom: member.display_name,
      capaciteHebdoH: weekly,
      joursOuvres: periodWorkingDays.length,
      capaciteBruteH: round1(grossCapacity),
      congesH: round1(leaveHours),
      joursConges: round1(leaveHours / daily),
      conges: [...leaveDays.entries()]
        .sort(([a], [b]) => a - b)
        .map(([day, entry]) => ({ date: fromDay(day), heures: round1(entry.hours), motif: [...entry.subjects].join(', ') || null })),
      capaciteH: round1(capacity),
      chargePlanifieeH: round1(planned),
      chargeNonPlanifieeH: round1(unplanned),
      chargeH: round1(load),
      tempsSaisiH: round1(timeByAccount[member.id] || 0),
      tauxCharge: capacity > 0 ? Math.round((load / capacity) * 100) : load > 0 ? null : 0,
      enSurcharge: load > capacity,
      calendrierErreur: memberCalendarError,
      chargeParProjet: Object.values(byProject)
        .map((entry) => ({
          projetId: entry.projetId,
          nom: entry.nom,
          chargeH: round1(entry.chargeH),
          nbTaches: entry.taches.size,
          nbNonPlanifiees: entry.nonPlanifiees.size,
          nbViaSousTaches: entry.viaSousTaches.size
        }))
        .sort((a, b) => b.chargeH - a.chargeH)
    });
  }

  return {
    periode: kind,
    debut: fromDay(range.start),
    fin: fromDay(range.end),
    libelle: range.label,
    contientAujourdhui: containsToday,
    precedente: fromDay(range.start - 1),
    suivante: fromDay(range.end + 1),
    joursOuvres: periodWorkingDays.length,
    calendrierErreur: calendarError,
    techniciens: technicians
  };
}

// Exposés pour les tests.
export { frenchHolidays, leaveHoursByDay, splitTaskWork, spreadTask, toDay, fromDay, workingDaysBetween };
