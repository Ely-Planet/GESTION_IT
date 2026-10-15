// Points d'équipe et points individuels du service informatique.
//
// - Équipe : membres des groupes Informatique (isIT) et Manager Informatique
//   (isITManager). Seul le manager planifie les points.
// - Points d'équipe : visibles par toute l'équipe.
// - Points individuels : visibles par le collaborateur concerné et le manager.
// - Planification comme les Projets Groupe : disponibilités, salle, Teams,
//   invitation Outlook depuis l'agenda du manager.
// - Compte rendu : repris du point précédent (même type, même collaborateur
//   pour un point individuel) ; chaque participant a sa partie, reprise elle
//   aussi de son point précédent, à préremplir avant le point (rappel par
//   notification et mail 2 jours avant).
import { pool } from './db.mjs';
import { getGraphAppToken, sendMailWithAttachments } from './graphMail.mjs';

const SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS team_points (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kind text NOT NULL CHECK (kind IN ('team', 'individual')),
  subject_account_id uuid REFERENCES app_accounts(id) ON DELETE CASCADE,
  title text NOT NULL,
  agenda text,
  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  location text,
  room_email text,
  room_name text,
  online boolean NOT NULL DEFAULT true,
  organizer_account_id uuid REFERENCES app_accounts(id),
  attendee_ids uuid[] NOT NULL DEFAULT '{}',
  outlook_event_id text,
  online_meeting_url text,
  outlook_error text,
  status text NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'cancelled')),
  previous_point_id uuid,
  reminder_sent_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_team_points_kind ON team_points(kind, subject_account_id, start_at);
CREATE TABLE IF NOT EXISTS team_point_minutes (
  point_id uuid PRIMARY KEY REFERENCES team_points(id) ON DELETE CASCADE,
  content text NOT NULL DEFAULT '',
  validated boolean NOT NULL DEFAULT false,
  updated_by text,
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS team_point_contributions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  point_id uuid NOT NULL REFERENCES team_points(id) ON DELETE CASCADE,
  account_id uuid NOT NULL REFERENCES app_accounts(id) ON DELETE CASCADE,
  content text NOT NULL DEFAULT '',
  contributed_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (point_id, account_id)
);
`;

const MINUTES_TEMPLATE = 'Points abordés :\n- \n\nDécisions :\n- \n\nActions (qui / quoi / quand) :\n- ';
const CONTRIBUTION_TEMPLATE = 'Réalisé depuis le dernier point :\n- \n\nEn cours / à venir :\n- \n\nPoints bloquants / besoins :\n- ';

// ---------------------------------------------------------------------------
// Accès
// ---------------------------------------------------------------------------
const isManager = (user) => Boolean(user?.isITManager);
const isTeamMember = (user) => Boolean(user?.isIT || user?.isITManager);

function requireTeam(req, res, next) {
  if (!isTeamMember(req.session?.user)) return res.status(403).json({ error: 'Réservé au service informatique' });
  next();
}
function requireManager(req, res, next) {
  if (!isManager(req.session?.user)) return res.status(403).json({ error: 'Réservé au manager du service informatique' });
  next();
}

const canSee = (user, point) => point.kind === 'team' || isManager(user) || point.subject_account_id === user.id;

// Équipe informatique (comptes connus de l'application).
async function teamPeople() {
  return (
    await pool.query(
      `SELECT id AS account_id, display_name, email, is_it_manager
       FROM app_accounts WHERE (is_it OR is_it_manager) AND email IS NOT NULL
       ORDER BY display_name`
    )
  ).rows;
}

// ---------------------------------------------------------------------------
// Microsoft Graph (agenda, salles, disponibilités)
// ---------------------------------------------------------------------------
async function graph(method, url, body, headers = {}) {
  const token = await getGraphAppToken();
  const response = await fetch(`https://graph.microsoft.com/v1.0${url}`, {
    method,
    headers: { Authorization: `Bearer ${token}`, Accept: 'application/json', ...(body ? { 'Content-Type': 'application/json' } : {}), ...headers },
    body: body ? JSON.stringify(body) : undefined
  });
  if (!response.ok) {
    const details = await response.text();
    const error = new Error(response.status === 403 ? `Microsoft Graph a refusé l'accès (403) : ${details.slice(0, 200)}` : `Microsoft Graph ${response.status} : ${details.slice(0, 200)}`);
    error.status = response.status;
    throw error;
  }
  if (response.status === 202 || response.status === 204) return null;
  const text = await response.text();
  return text ? JSON.parse(text) : null;
}

let roomsCache = { at: 0, value: null };
async function listRooms() {
  if (roomsCache.value && Date.now() - roomsCache.at < 60 * 60 * 1000) return roomsCache.value;
  try {
    const page = await graph('GET', '/places/microsoft.graph.room?$top=200');
    const rooms = (page?.value || [])
      .filter((r) => r.emailAddress)
      .map((r) => ({ email: r.emailAddress.toLowerCase(), name: r.displayName || r.emailAddress, capacity: r.capacity ?? null }))
      .sort((a, b) => a.name.localeCompare(b.name, 'fr'));
    roomsCache = { at: Date.now(), value: { rooms, error: null } };
    return roomsCache.value;
  } catch (error) {
    return { rooms: [], error: error.status === 403 ? 'Liste des salles indisponible (permission Place.Read.All).' : error.message };
  }
}

const appLink = () => `${String(process.env.APP_URL || '').replace(/\/+$/, '')}/`;
const escapeHtml = (v) => String(v ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

function outlookEvent(point, attendees) {
  return {
    subject: point.title,
    body: {
      contentType: 'HTML',
      content:
        `<p>${escapeHtml(point.agenda || '').replace(/\n/g, '<br/>')}</p>` +
        `<p style="color:#6b7280;font-size:12px">Préparez votre partie du compte rendu dans GESTION_IT → Points d'équipe avant le point. ` +
        `<a href="${appLink()}">Ouvrir GESTION_IT</a></p>`
    },
    start: { dateTime: `${point.start}:00`, timeZone: 'Europe/Paris' },
    end: { dateTime: `${point.end}:00`, timeZone: 'Europe/Paris' },
    location: point.roomEmail
      ? { displayName: point.roomName || point.roomEmail, locationEmailAddress: point.roomEmail, locationType: 'conferenceRoom' }
      : point.location
        ? { displayName: point.location }
        : undefined,
    attendees: [
      ...attendees.filter((a) => a.email).map((a) => ({ emailAddress: { address: a.email, name: a.display_name }, type: 'required' })),
      ...(point.roomEmail ? [{ emailAddress: { address: point.roomEmail, name: point.roomName || point.roomEmail }, type: 'resource' }] : [])
    ],
    isOnlineMeeting: Boolean(point.online),
    ...(point.online ? { onlineMeetingProvider: 'teamsForBusiness' } : {}),
    allowNewTimeProposals: true
  };
}

const isLocalDateTime = (v) => /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(String(v || ''));
function readPoint(body) {
  const point = {
    title: String(body.title || '').trim(),
    agenda: String(body.agenda || '').trim() || null,
    start: String(body.start || ''),
    end: String(body.end || ''),
    location: String(body.location || '').trim() || null,
    roomEmail: body.roomEmail ? String(body.roomEmail).toLowerCase() : null,
    roomName: body.roomName ? String(body.roomName) : null,
    online: body.online !== false,
    attendeeIds: Array.isArray(body.attendeeIds) ? [...new Set(body.attendeeIds.map(String))] : []
  };
  if (!point.title) return { error: 'Objet du point obligatoire' };
  if (!isLocalDateTime(point.start) || !isLocalDateTime(point.end) || point.end <= point.start) return { error: 'Horaires invalides' };
  return { point };
}

// ---------------------------------------------------------------------------
// Lecture
// ---------------------------------------------------------------------------
const POINT_SELECT = `
  SELECT p.id, p.kind, p.subject_account_id, s.display_name AS subject_name, p.title, p.agenda, p.location, p.room_email, p.room_name,
         p.online, p.status, p.organizer_account_id, o.display_name AS organizer_name, p.attendee_ids, p.online_meeting_url,
         p.outlook_error, (p.outlook_event_id IS NOT NULL) AS in_outlook, p.previous_point_id,
         to_char(p.start_at AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD"T"HH24:MI') AS start_at,
         to_char(p.end_at AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD"T"HH24:MI') AS end_at,
         (p.end_at < now()) AS past,
         m.validated AS minutes_validated
  FROM team_points p
  LEFT JOIN app_accounts s ON s.id = p.subject_account_id
  LEFT JOIN app_accounts o ON o.id = p.organizer_account_id
  LEFT JOIN team_point_minutes m ON m.point_id = p.id`;

async function loadPoint(id) {
  return (await pool.query(`${POINT_SELECT} WHERE p.id = $1`, [id])).rows[0] || null;
}

// Point précédent (même type ; même collaborateur pour un point individuel).
async function previousPoint(kind, subjectId, beforeIso, exceptId = null) {
  return (
    await pool.query(
      `SELECT id FROM team_points
       WHERE kind = $1 AND status = 'planned' AND ($2::uuid IS NULL OR subject_account_id = $2)
         AND start_at < ($3::timestamp AT TIME ZONE 'Europe/Paris') AND ($4::uuid IS NULL OR id <> $4)
       ORDER BY start_at DESC LIMIT 1`,
      [kind, subjectId, beforeIso, exceptId]
    )
  ).rows[0]?.id || null;
}

// Participants qui ont une partie à remplir.
const contributorsOf = (kind, subjectId, attendeeIds, organizerId) =>
  kind === 'individual' ? [subjectId] : [...new Set([...(attendeeIds || []), organizerId].filter(Boolean))];

// Peut préparer ce point : tout membre de l'équipe pour un point d'équipe,
// le collaborateur concerné pour un point individuel.
const isEligible = (point, user) => (point.kind === 'team' ? isTeamMember(user) : point.subject_account_id === user.id);

// Contenu de départ d'une préparation : la dernière préparation enregistrée de
// la personne (même type de point), à défaut le compte rendu du point précédent.
async function contributionSource(point, accountId, previousMinutes) {
  const previous = (
    await pool.query(
      `SELECT c.content FROM team_point_contributions c JOIN team_points p ON p.id = c.point_id
       WHERE c.account_id = $1 AND c.contributed_at IS NOT NULL AND p.kind = $2 AND p.status = 'planned'
         AND ($3::uuid IS NULL OR p.subject_account_id = $3) AND p.id <> $4
         AND p.start_at < (SELECT start_at FROM team_points WHERE id = $4)
       ORDER BY p.start_at DESC LIMIT 1`,
      [accountId, point.kind, point.subject_account_id, point.id]
    )
  ).rows[0]?.content;
  return previous || previousMinutes || CONTRIBUTION_TEMPLATE;
}

// À l'ouverture d'un point : tant qu'ils n'ont pas été modifiés, le compte rendu
// reprend le dernier compte rendu du point précédent, et chaque préparation la
// dernière préparation de la personne. La personne qui ouvre le point reçoit sa
// préparation si elle n'en a pas encore (participant ajouté après coup).
async function syncPoint(point, viewer) {
  const previousId = await previousPoint(point.kind, point.subject_account_id, point.start_at, point.id);
  const previousMinutes = previousId
    ? (await pool.query(`SELECT content FROM team_point_minutes WHERE point_id = $1`, [previousId])).rows[0]?.content || null
    : null;

  const minutes = (await pool.query(`SELECT content, updated_by FROM team_point_minutes WHERE point_id = $1`, [point.id])).rows[0];
  if (!minutes) {
    await pool.query(`INSERT INTO team_point_minutes (point_id, content) VALUES ($1, $2) ON CONFLICT (point_id) DO NOTHING`, [
      point.id,
      previousMinutes || MINUTES_TEMPLATE
    ]);
  } else if (!minutes.updated_by && previousMinutes && minutes.content !== previousMinutes) {
    await pool.query(`UPDATE team_point_minutes SET content = $1 WHERE point_id = $2 AND updated_by IS NULL`, [previousMinutes, point.id]);
  }

  if (point.status === 'planned' && isEligible(point, viewer)) {
    await pool.query(
      `INSERT INTO team_point_contributions (point_id, account_id, content) VALUES ($1, $2, $3) ON CONFLICT (point_id, account_id) DO NOTHING`,
      [point.id, viewer.id, await contributionSource(point, viewer.id, previousMinutes)]
    );
  }
  const untouched = (
    await pool.query(`SELECT account_id, content FROM team_point_contributions WHERE point_id = $1 AND contributed_at IS NULL`, [point.id])
  ).rows;
  for (const row of untouched) {
    const source = await contributionSource(point, row.account_id, previousMinutes);
    if (source !== row.content) {
      await pool.query(`UPDATE team_point_contributions SET content = $1 WHERE point_id = $2 AND account_id = $3 AND contributed_at IS NULL`, [
        source,
        point.id,
        row.account_id
      ]);
    }
  }
  return { previousId, previousMinutes };
}

async function prepareContents(client, pointId, kind, subjectId, contributors, previousId) {
  const previousMinutes = previousId
    ? (await client.query(`SELECT content FROM team_point_minutes WHERE point_id = $1`, [previousId])).rows[0]?.content
    : null;
  await client.query(`INSERT INTO team_point_minutes (point_id, content) VALUES ($1, $2) ON CONFLICT (point_id) DO NOTHING`, [
    pointId,
    previousMinutes || MINUTES_TEMPLATE
  ]);
  for (const accountId of contributors) {
    // Partie reprise du dernier point (du même type) où la personne en avait une.
    const previous = (
      await client.query(
        `SELECT c.content FROM team_point_contributions c JOIN team_points p ON p.id = c.point_id
         WHERE c.account_id = $1 AND p.kind = $2 AND ($3::uuid IS NULL OR p.subject_account_id = $3) AND p.id <> $4 AND p.status = 'planned'
         ORDER BY p.start_at DESC LIMIT 1`,
        [accountId, kind, subjectId, pointId]
      )
    ).rows[0]?.content;
    await client.query(
      `INSERT INTO team_point_contributions (point_id, account_id, content) VALUES ($1, $2, $3) ON CONFLICT (point_id, account_id) DO NOTHING`,
      [pointId, accountId, previous || CONTRIBUTION_TEMPLATE]
    );
  }
}

// ---------------------------------------------------------------------------
// Rappel 2 jours avant : participants dont la partie n'est pas encore remplie
// ---------------------------------------------------------------------------
async function sendReminders() {
  const points = (
    await pool.query(
      `SELECT p.id, p.kind, p.title, s.display_name AS subject_name,
              to_char(p.start_at AT TIME ZONE 'Europe/Paris', 'DD/MM/YYYY à HH24:MI') AS start_fr
       FROM team_points p LEFT JOIN app_accounts s ON s.id = p.subject_account_id
       WHERE p.status = 'planned' AND p.reminder_sent_at IS NULL
         AND p.start_at > now() AND p.start_at <= now() + interval '2 days'`
    )
  ).rows;
  for (const point of points) {
    const waiting = (
      await pool.query(
        `SELECT a.id, a.display_name, a.email FROM team_point_contributions c JOIN app_accounts a ON a.id = c.account_id
         WHERE c.point_id = $1 AND c.contributed_at IS NULL`,
        [point.id]
      )
    ).rows;
    for (const person of waiting) {
      const label = point.kind === 'team' ? "point d'équipe" : 'point individuel';
      await pool
        .query(`INSERT INTO user_notifications (account_id, type, title, body) VALUES ($1, 'team_point_reminder', $2, $3)`, [
          person.id,
          `À préparer : ${label} du ${point.start_fr}`,
          `${point.title} — complétez votre partie du compte rendu avant le point (GESTION_IT → Points d'équipe)`
        ])
        .catch((error) => console.error('[Points] Notification impossible', error.message || error));
      if (person.email) {
        await sendMailWithAttachments({
          to: person.email,
          subject: `À préparer : ${point.title} (${point.start_fr})`,
          html: `<div style="font-family:Inter,'Segoe UI',Arial,sans-serif;font-size:14px;line-height:1.6;color:#32373c">
            <p>Bonjour ${escapeHtml(person.display_name || '')},</p>
            <p>Le ${label} <strong>« ${escapeHtml(point.title)} »</strong> a lieu le ${escapeHtml(point.start_fr)}.</p>
            <p>Merci de compléter votre partie du compte rendu avant le point : elle reprend ce que vous aviez écrit la dernière fois, il suffit de la mettre à jour.</p>
            <p style="margin:24px 0"><a href="${appLink()}" style="display:inline-block;padding:10px 20px;background:#ca0088;color:#ffffff;border-radius:8px;font-weight:600;text-decoration:none">Préparer mon point</a></p>
            <p>GESTION_IT → Points d'équipe</p>
          </div>`
        }).catch((error) => console.error('[Points] Mail de rappel impossible', person.email, error.message || error));
      }
    }
    await pool.query(`UPDATE team_points SET reminder_sent_at = now() WHERE id = $1`, [point.id]);
  }
}

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------
export function registerTeamPointRoutes(app) {
  const schemaReady = pool.query(SCHEMA_SQL).catch((error) => console.error('[Points] Schéma impossible', error.message || error));
  const runReminders = () => schemaReady.then(sendReminders).catch((error) => console.error('[Points] Rappels impossibles', error.message || error));
  setTimeout(runReminders, 45 * 1000).unref();
  setInterval(runReminders, 30 * 60 * 1000).unref();

  app.get('/api/points/meta', requireTeam, async (req, res) => {
    try {
      await schemaReady;
      res.json({ isManager: isManager(req.session.user), me: req.session.user.id, people: await teamPeople() });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/points/rooms', requireManager, async (req, res) => {
    res.json(await listRooms());
  });

  // Disponibilités (statut seulement) des invités et des salles sur une semaine.
  app.post('/api/points/availability', requireManager, async (req, res) => {
    try {
      const { weekStart } = req.body;
      if (!/^\d{4}-\d{2}-\d{2}$/.test(String(weekStart || ''))) return res.status(400).json({ error: 'Semaine invalide' });
      const attendeeIds = Array.isArray(req.body.attendeeIds) ? req.body.attendeeIds : [];
      const roomEmails = (Array.isArray(req.body.roomEmails) ? req.body.roomEmails : []).filter(Boolean).slice(0, 40);
      const people = (await teamPeople()).filter((p) => attendeeIds.includes(p.account_id) || p.account_id === req.session.user.id);
      const emails = [...new Set([...people.map((p) => p.email.toLowerCase()), ...roomEmails.map((e) => String(e).toLowerCase())])];
      const end = new Date(`${weekStart}T00:00:00Z`);
      end.setUTCDate(end.getUTCDate() + 5);
      const schedules = [];
      for (let i = 0; i < emails.length; i += 20) {
        const result = await graph(
          'POST',
          `/users/${encodeURIComponent(req.session.user.id)}/calendar/getSchedule`,
          {
            schedules: emails.slice(i, i + 20),
            startTime: { dateTime: `${weekStart}T00:00:00`, timeZone: 'Europe/Paris' },
            endTime: { dateTime: `${end.toISOString().slice(0, 10)}T00:00:00`, timeZone: 'Europe/Paris' },
            availabilityViewInterval: 30
          },
          { Prefer: 'outlook.timezone="Europe/Paris"' }
        );
        for (const schedule of result?.value || []) {
          schedules.push({
            email: String(schedule.scheduleId || '').toLowerCase(),
            error: schedule.error?.message || null,
            items: (schedule.scheduleItems || [])
              .filter((item) => item.status && item.status !== 'free')
              .map((item) => ({ status: item.status, start: item.start?.dateTime?.slice(0, 16), end: item.end?.dateTime?.slice(0, 16) }))
          });
        }
      }
      res.json({ weekStart, people: people.map((p) => ({ account_id: p.account_id, display_name: p.display_name, email: p.email.toLowerCase() })), schedules });
    } catch (error) {
      console.error('[Points] Disponibilités', error);
      res.status(error.status === 403 ? 502 : 500).json({ error: error.message });
    }
  });

  // Liste des points visibles : ?kind=team|individual[&subject=<compte>]
  app.get('/api/points', requireTeam, async (req, res) => {
    try {
      await schemaReady;
      const kind = req.query.kind === 'individual' ? 'individual' : 'team';
      const user = req.session.user;
      let subject = req.query.subject ? String(req.query.subject) : null;
      if (kind === 'individual' && !isManager(user)) subject = user.id; // un collaborateur ne voit que les siens
      const rows = (
        await pool.query(
          `${POINT_SELECT}
           WHERE p.kind = $1 AND ($2::uuid IS NULL OR p.subject_account_id = $2)
           ORDER BY p.start_at DESC`,
          [kind, subject]
        )
      ).rows;
      // Ma partie : remplie ou non.
      const mine = (
        await pool.query(`SELECT point_id, contributed_at FROM team_point_contributions WHERE account_id = $1`, [user.id])
      ).rows.reduce((acc, r) => ({ ...acc, [r.point_id]: r.contributed_at }), {});
      res.json(
        rows.filter((p) => canSee(user, p)).map((p) => ({ ...p, my_contribution: p.id in mine ? { done: Boolean(mine[p.id]) } : null }))
      );
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/points/:id', requireTeam, async (req, res) => {
    try {
      await schemaReady;
      const user = req.session.user;
      const point = await loadPoint(req.params.id);
      if (!point || !canSee(user, point)) return res.status(404).json({ error: 'Point introuvable' });
      const { previousId, previousMinutes } = await syncPoint(point, user);
      const minutes = (
        await pool.query(`SELECT content, validated, updated_by, updated_at FROM team_point_minutes WHERE point_id = $1`, [point.id])
      ).rows[0] || { content: '', validated: false };
      // Chaque collaborateur ne voit que sa propre préparation ; le manager voit toutes les préparations.
      const contributions = (
        await pool.query(
          `SELECT c.account_id, a.display_name, c.content, c.contributed_at, c.updated_at
           FROM team_point_contributions c JOIN app_accounts a ON a.id = c.account_id
           WHERE c.point_id = $1 AND ($2::boolean OR c.account_id = $3)
           ORDER BY a.display_name`,
          [point.id, isManager(user), user.id]
        )
      ).rows;
      const previous = previousId ? await loadPoint(previousId) : null;
      res.json({
        ...point,
        minutes,
        contributions,
        previous: previous ? { id: previous.id, title: previous.title, start_at: previous.start_at, minutes: previousMinutes } : null
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/points', requireManager, async (req, res) => {
    const client = await pool.connect();
    try {
      await schemaReady;
      const kind = req.body?.kind === 'individual' ? 'individual' : 'team';
      const { point, error } = readPoint(req.body || {});
      if (error) return res.status(400).json({ error });
      const people = await teamPeople();
      const subjectId = kind === 'individual' ? String(req.body.subjectId || '') : null;
      if (kind === 'individual' && !people.some((p) => p.account_id === subjectId)) return res.status(400).json({ error: 'Collaborateur introuvable' });
      const attendeeIds = kind === 'individual' ? [subjectId] : point.attendeeIds.filter((id) => people.some((p) => p.account_id === id));
      const previousId = await previousPoint(kind, subjectId, point.start);

      await client.query('BEGIN');
      const saved = (
        await client.query(
          `INSERT INTO team_points (kind, subject_account_id, title, agenda, start_at, end_at, location, room_email, room_name, online,
                                    organizer_account_id, attendee_ids, previous_point_id)
           VALUES ($1, $2, $3, $4, ($5::timestamp AT TIME ZONE 'Europe/Paris'), ($6::timestamp AT TIME ZONE 'Europe/Paris'), $7, $8, $9, $10, $11, $12, $13)
           RETURNING id`,
          [kind, subjectId, point.title, point.agenda, point.start, point.end, point.roomEmail ? point.roomName : point.location,
            point.roomEmail, point.roomName, point.online, req.session.user.id, attendeeIds, previousId]
        )
      ).rows[0];
      await prepareContents(client, saved.id, kind, subjectId, contributorsOf(kind, subjectId, attendeeIds, req.session.user.id), previousId);
      await client.query('COMMIT');

      let outlookError = null;
      try {
        const attendees = people.filter((p) => attendeeIds.includes(p.account_id) && p.account_id !== req.session.user.id);
        const event = await graph('POST', `/users/${encodeURIComponent(req.session.user.id)}/events`, outlookEvent(point, attendees));
        await pool.query(`UPDATE team_points SET outlook_event_id = $1, online_meeting_url = $2 WHERE id = $3`, [event.id, event.onlineMeeting?.joinUrl || null, saved.id]);
      } catch (graphError) {
        outlookError = graphError.message;
        await pool.query(`UPDATE team_points SET outlook_error = $1 WHERE id = $2`, [outlookError, saved.id]);
      }
      res.status(201).json({ id: saved.id, outlookError });
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error(error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

  app.put('/api/points/:id', requireManager, async (req, res) => {
    try {
      await schemaReady;
      const existing = (await pool.query(`SELECT * FROM team_points WHERE id = $1`, [req.params.id])).rows[0];
      if (!existing) return res.status(404).json({ error: 'Point introuvable' });
      const { point, error } = readPoint(req.body || {});
      if (error) return res.status(400).json({ error });
      const people = await teamPeople();
      const attendeeIds = existing.kind === 'individual' ? existing.attendee_ids : point.attendeeIds.filter((id) => people.some((p) => p.account_id === id));
      await pool.query(
        `UPDATE team_points SET title = $1, agenda = $2, start_at = ($3::timestamp AT TIME ZONE 'Europe/Paris'),
                end_at = ($4::timestamp AT TIME ZONE 'Europe/Paris'), location = $5, room_email = $6, room_name = $7, online = $8,
                attendee_ids = $9, reminder_sent_at = NULL, updated_at = now()
         WHERE id = $10`,
        [point.title, point.agenda, point.start, point.end, point.roomEmail ? point.roomName : point.location, point.roomEmail, point.roomName,
          point.online, attendeeIds, existing.id]
      );
      // Nouveaux invités : leur partie est préparée.
      const client = await pool.connect();
      try {
        await prepareContents(client, existing.id, existing.kind, existing.subject_account_id,
          contributorsOf(existing.kind, existing.subject_account_id, attendeeIds, existing.organizer_account_id), existing.previous_point_id);
      } finally {
        client.release();
      }
      let outlookError = null;
      if (existing.outlook_event_id) {
        try {
          const attendees = people.filter((p) => attendeeIds.includes(p.account_id) && p.account_id !== existing.organizer_account_id);
          await graph('PATCH', `/users/${encodeURIComponent(existing.organizer_account_id)}/events/${encodeURIComponent(existing.outlook_event_id)}`, outlookEvent(point, attendees));
        } catch (graphError) {
          outlookError = graphError.message;
        }
      }
      res.json({ id: existing.id, outlookError });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Annulation (le point reste visible) ou suppression ; annulé aussi dans Outlook.
  for (const [route, remove] of [['/api/points/:id/cancel', false], ['/api/points/:id', true]]) {
    app[remove ? 'delete' : 'post'](route, requireManager, async (req, res) => {
      try {
        await schemaReady;
        const existing = (await pool.query(`SELECT * FROM team_points WHERE id = $1`, [req.params.id])).rows[0];
        if (!existing) return res.status(404).json({ error: 'Point introuvable' });
        let outlookError = null;
        if (existing.outlook_event_id && existing.status === 'planned' && new Date(existing.end_at) > new Date()) {
          try {
            await graph('POST', `/users/${encodeURIComponent(existing.organizer_account_id)}/events/${encodeURIComponent(existing.outlook_event_id)}/cancel`, {
              comment: 'Point annulé.'
            });
          } catch (graphError) {
            outlookError = graphError.message;
          }
        }
        if (remove) await pool.query(`DELETE FROM team_points WHERE id = $1`, [existing.id]);
        else await pool.query(`UPDATE team_points SET status = 'cancelled', updated_at = now() WHERE id = $1`, [existing.id]);
        res.json({ outlookError });
      } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
      }
    });
  }

  // Compte rendu du point (manager).
  app.put('/api/points/:id/minutes', requireManager, async (req, res) => {
    try {
      await schemaReady;
      await pool.query(
        `INSERT INTO team_point_minutes (point_id, content, validated, updated_by, updated_at) VALUES ($1, $2, $3, $4, now())
         ON CONFLICT (point_id) DO UPDATE SET content = EXCLUDED.content, validated = EXCLUDED.validated, updated_by = EXCLUDED.updated_by, updated_at = now()`,
        [req.params.id, String(req.body?.content || ''), Boolean(req.body?.validated), req.session.user.displayName || req.session.user.email || 'Manager']
      );
      res.json({ ok: true });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Ma partie du compte rendu (chacun la sienne ; le manager peut compléter celles des autres).
  app.put('/api/points/:id/contribution', requireTeam, async (req, res) => {
    try {
      await schemaReady;
      const point = await loadPoint(req.params.id);
      const user = req.session.user;
      if (!point || !canSee(user, point)) return res.status(404).json({ error: 'Point introuvable' });
      const accountId = req.body?.accountId && isManager(user) ? String(req.body.accountId) : user.id;
      // Sa propre préparation : toute personne concernée par le point (équipe ou collaborateur du point individuel).
      const exists = (await pool.query(`SELECT 1 FROM team_point_contributions WHERE point_id = $1 AND account_id = $2`, [point.id, accountId])).rowCount;
      if (!exists && !(accountId === user.id && isEligible(point, user))) {
        return res.status(403).json({ error: "Vous n'êtes pas participant de ce point" });
      }
      await pool.query(
        `INSERT INTO team_point_contributions (point_id, account_id, content, contributed_at, updated_at) VALUES ($1, $2, $3, now(), now())
         ON CONFLICT (point_id, account_id) DO UPDATE
           SET content = EXCLUDED.content, contributed_at = COALESCE(team_point_contributions.contributed_at, now()), updated_at = now()`,
        [point.id, accountId, String(req.body?.content || '')]
      );
      res.json({ ok: true });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });
}
