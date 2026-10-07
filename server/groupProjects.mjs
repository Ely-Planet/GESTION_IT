// Module "Projets Groupe" : projets des managers et directeurs.
//
// - Accès : les managers et directeurs créent des projets ; chacun ne voit que
//   les projets dont il est membre (n'importe quel collaborateur Microsoft 365
//   peut être membre). Les "responsables" gèrent le projet et ses membres ;
//   tous les membres gèrent tâches, comptes rendus, mails et réunions.
// - Pas de GitHub ni de client : statuts du Kanban en français côté interface.
// - Communications : mail envoyé depuis la boîte du membre (Graph), réponses
//   relevées dans cette boîte (même conversation) et rangées dans le projet.
// - Réunions : invitation Outlook (Teams) créée dans le calendrier de
//   l'organisateur, notification aux membres, rappel du compte rendu.
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import fsp from 'fs/promises';
import crypto from 'crypto';
import { pool } from './db.mjs';
import { getGraphAppToken, sendMailWithAttachments } from './graphMail.mjs';
import { ensureGroupProjectsSchema } from './groupProjectsSchema.mjs';

const FILES_DIR = path.join(process.cwd(), 'storage', 'group-projects');
const TASK_STATUSES = ['backlog', 'ready', 'in_progress', 'in_review', 'done'];
const SUBTASK_STATUSES = ['todo', 'in_progress', 'done'];
const TASK_STATUS_FR = { backlog: 'À faire', ready: 'Prêt', in_progress: 'En cours', in_review: 'En validation', done: 'Terminé' };
const INLINE_PREVIEW_TYPES = {
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.webp': 'image/webp',
  '.bmp': 'image/bmp',
  '.pdf': 'application/pdf',
  '.txt': 'text/plain; charset=utf-8',
  '.log': 'text/plain; charset=utf-8',
  '.csv': 'text/plain; charset=utf-8',
  '.json': 'text/plain; charset=utf-8',
  '.md': 'text/plain; charset=utf-8'
};

const upload = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => cb(null, FILES_DIR),
    filename: (req, file, cb) => cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}-${file.originalname}`)
  }),
  limits: { fileSize: 25 * 1024 * 1024 }
});

function uploadFiles(req, res, next) {
  upload.array('files', 10)(req, res, (error) => {
    if (!error) return next();
    const message = error.code === 'LIMIT_FILE_SIZE'
      ? 'Fichier trop volumineux (25 Mo maximum par fichier)'
      : error.code === 'LIMIT_UNEXPECTED_FILE'
        ? '10 pièces jointes maximum'
        : error.message;
    res.status(400).json({ error: message });
  });
}

async function removeUploadedFiles(files) {
  for (const file of files || []) await fsp.unlink(file.path).catch(() => {});
}

function decodeUploadName(name) {
  // busboy décode les noms de fichiers en latin1 : on restaure les accents.
  try {
    return Buffer.from(name, 'latin1').toString('utf8');
  } catch {
    return name;
  }
}

function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function appLink(projectId) {
  const base = String(process.env.APP_URL || '').replace(/\/+$/, '');
  return `${base}/?projetGroupe=${encodeURIComponent(projectId)}`;
}

const isDate = (value) => /^\d{4}-\d{2}-\d{2}$/.test(String(value)) && !Number.isNaN(Date.parse(String(value)));

// Dates de planning (startDate / endDate) : undefined = inchangé, null / '' = effacé.
function readPlanningDates(body, current = { start_date: null, end_date: null }) {
  const result = { startProvided: body.startDate !== undefined, endProvided: body.endDate !== undefined };
  for (const [key, field] of [['startDate', 'start'], ['endDate', 'end']]) {
    const value = body[key];
    if (value === undefined || value === null || value === '') result[field] = null;
    else if (isDate(value)) result[field] = String(value);
    else return { error: 'Date invalide (format AAAA-MM-JJ attendu)' };
  }
  const start = result.startProvided ? result.start : current.start_date;
  const end = result.endProvided ? result.end : current.end_date;
  if (start && end && start > end) return { error: 'La date de fin doit être postérieure ou égale à la date de début' };
  return result;
}

// ---------------------------------------------------------------------------
// Accès
// ---------------------------------------------------------------------------
function requireAuth(req, res, next) {
  if (!req.session?.user) return res.status(401).json({ error: 'Non authentifié' });
  next();
}

const canCreateProjects = (user) => Boolean(user?.isManager || user?.isDirector || user?.isITManager);

async function memberRole(projectId, accountId) {
  const result = await pool.query(
    `SELECT m.role FROM group_project_members m JOIN group_projects p ON p.id = m.project_id
     WHERE m.project_id = $1 AND m.account_id = $2 AND p.status <> 'archive'`,
    [projectId, accountId]
  );
  return result.rows[0]?.role || null;
}

// Rôle de l'utilisateur dans le projet ; envoie 403 et renvoie null s'il n'en est pas membre.
async function requireMember(req, res, projectId, { responsable = false } = {}) {
  const role = await memberRole(projectId, req.session.user.id);
  if (!role) {
    res.status(403).json({ error: 'Vous ne faites pas partie de ce projet' });
    return null;
  }
  if (responsable && role !== 'responsable') {
    res.status(403).json({ error: 'Réservé aux responsables du projet' });
    return null;
  }
  return role;
}

export async function hasGroupProjectAccess(accountId) {
  const result = await pool.query(
    `SELECT 1 FROM group_project_members m JOIN group_projects p ON p.id = m.project_id
     WHERE m.account_id = $1 AND p.status <> 'archive' LIMIT 1`,
    [accountId]
  );
  return result.rowCount > 0;
}

// Compte applicatif d'un collaborateur Microsoft 365 (créé au besoin depuis l'annuaire).
async function ensureAccount(db, microsoftObjectId) {
  const employee = (
    await db.query(
      `SELECT microsoft_object_id,
              COALESCE(email, microsoft_upn) AS email,
              COALESCE(NULLIF(TRIM(CONCAT_WS(' ', first_name, last_name)), ''), email, microsoft_upn) AS display_name
       FROM employees
       WHERE microsoft_object_id = $1 AND is_active = true AND account_enabled = true
       LIMIT 1`,
      [microsoftObjectId]
    )
  ).rows[0];
  if (!employee) {
    const existing = await db.query(`SELECT id FROM app_accounts WHERE id = $1`, [microsoftObjectId]);
    if (existing.rowCount) return microsoftObjectId;
    throw new Error('Utilisateur Microsoft 365 actif introuvable');
  }
  await db.query(
    `INSERT INTO app_accounts (id, email, display_name, is_it, is_it_manager, is_rh, is_manager, is_director)
     VALUES ($1, $2, $3, false, false, false, false, false)
     ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email, display_name = EXCLUDED.display_name`,
    [employee.microsoft_object_id, employee.email, employee.display_name]
  );
  return employee.microsoft_object_id;
}

async function listMembers(projectId, db = pool) {
  return (
    await db.query(
      `SELECT a.id AS account_id, a.display_name, a.email, m.role
       FROM group_project_members m JOIN app_accounts a ON a.id = m.account_id
       WHERE m.project_id = $1
       ORDER BY m.role = 'responsable' DESC, a.display_name`,
      [projectId]
    )
  ).rows;
}

async function notify({ accountIds, type, title, body = null, projectId, exceptId = null }) {
  for (const accountId of new Set(accountIds)) {
    if (!accountId || accountId === exceptId) continue;
    await pool
      .query(
        `INSERT INTO user_notifications (account_id, type, title, body, group_project_id) VALUES ($1, $2, $3, $4, $5)`,
        [accountId, type, title, body, projectId]
      )
      .catch((error) => console.error('[Projets Groupe] Notification impossible', error.message || error));
  }
}

async function projectName(projectId) {
  return (await pool.query(`SELECT name FROM group_projects WHERE id = $1`, [projectId])).rows[0]?.name || '';
}

const projectRef = (refNumber) => `PG-${String(refNumber ?? 0).padStart(4, '0')}`;

// Préfixe de l'objet des mails : référence + début du nom du projet.
async function mailSubjectPrefix(projectId) {
  const project = (await pool.query(`SELECT name, ref_number FROM group_projects WHERE id = $1`, [projectId])).rows[0];
  const name = project?.name || '';
  const shortName = name.length > 40 ? `${name.slice(0, 39).trimEnd()}…` : name;
  return `[${projectRef(project?.ref_number)} · ${shortName}]`;
}

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Retrouve un mail envoyé (sendMail ne renvoie rien) dans les éléments envoyés :
// par l'en-tête X-GestionIT-Ref, à défaut par l'objet et l'heure d'envoi.
async function findSentMessage(mailboxId, { tracking, subject, sentAfter }, { attempts = 1 } = {}) {
  const params = new URLSearchParams({
    $top: '25',
    $orderby: 'sentDateTime desc',
    $select: 'conversationId,internetMessageId,subject,sentDateTime,internetMessageHeaders'
  });
  for (let attempt = 0; attempt < attempts; attempt++) {
    if (attempt) await wait(2500);
    const page = await graph('GET', `/users/${encodeURIComponent(mailboxId)}/mailFolders/sentitems/messages?${params}`);
    const messages = page?.value || [];
    const byHeader = messages.find((m) =>
      (m.internetMessageHeaders || []).some((h) => h.name?.toLowerCase() === 'x-gestionit-ref' && h.value === tracking)
    );
    const bySubject = messages.find((m) => m.subject === subject && (!sentAfter || m.sentDateTime >= sentAfter));
    const found = byHeader || bySubject;
    if (found?.conversationId) return found;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Microsoft Graph
// ---------------------------------------------------------------------------
async function graph(method, url, body, { headers = {} } = {}) {
  const token = await getGraphAppToken();
  const response = await fetch(url.startsWith('http') ? url : `https://graph.microsoft.com/v1.0${url}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json',
      ...(body ? { 'Content-Type': 'application/json' } : {}),
      ...headers
    },
    body: body ? JSON.stringify(body) : undefined
  });
  if (!response.ok) {
    const details = await response.text();
    const error = new Error(
      response.status === 403
        ? `Microsoft Graph a refusé l'accès (403) : permission d'application manquante. ${details.slice(0, 300)}`
        : `Microsoft Graph ${response.status} : ${details.slice(0, 300)}`
    );
    error.status = response.status;
    throw error;
  }
  if (response.status === 202 || response.status === 204) return null;
  return response.json();
}

const recipientsOf = (list) =>
  (list || []).map((r) => ({ name: r.emailAddress?.name || null, email: r.emailAddress?.address || null }));

// Relève les réponses des conversations envoyées depuis les projets (90 derniers jours).
async function resolvePendingSentMessages() {
  const pending = (
    await pool.query(
      `SELECT id, mailbox_account_id, tracking_ref, subject, sent_at FROM group_messages
       WHERE direction = 'sent' AND conversation_id LIKE 'pending:%' AND sent_at > now() - interval '7 days'`
    )
  ).rows;
  for (const message of pending) {
    try {
      const found = await findSentMessage(message.mailbox_account_id, {
        tracking: message.tracking_ref,
        subject: message.subject,
        sentAfter: new Date(new Date(message.sent_at).getTime() - 60000).toISOString()
      });
      if (found) {
        await pool.query(
          `UPDATE group_messages SET conversation_id = $1, internet_message_id = COALESCE($2, internet_message_id) WHERE id = $3`,
          [found.conversationId, found.internetMessageId || null, message.id]
        );
      }
    } catch (error) {
      console.error('[Projets Groupe] Mail envoyé introuvable dans les éléments envoyés', error.message || error);
    }
  }
}

const MAX_ATTACHMENT_BYTES = 25 * 1024 * 1024;

// Nom de fichier sûr pour le disque (le nom d'origine est conservé en base).
const diskName = (name) => `${Date.now()}-${Math.round(Math.random() * 1e9)}-${String(name || 'piece-jointe').replace(/[^\w.\-]+/g, '_').slice(-120)}`;

// Télécharge les pièces jointes d'un mail Outlook et les range dans le projet.
// Les images intégrées au corps (logos de signature) sont ignorées ; les liens
// OneDrive, mails joints et fichiers trop volumineux sont signalés.
async function fetchMailAttachments({ messageRowId, projectId, mailboxId, graphMessageId }) {
  const page = await graph(
    'GET',
    `/users/${encodeURIComponent(mailboxId)}/messages/${encodeURIComponent(graphMessageId)}/attachments`
  );
  const skipped = [];
  let saved = 0;
  for (const attachment of page?.value || []) {
    const type = attachment['@odata.type'] || '';
    if (attachment.isInline) continue;
    if (!type.endsWith('fileAttachment')) {
      skipped.push(`${attachment.name || 'élément'} (${type.endsWith('referenceAttachment') ? 'lien OneDrive' : 'élément Outlook joint'})`);
      continue;
    }
    if (!attachment.contentBytes || (attachment.size || 0) > MAX_ATTACHMENT_BYTES) {
      skipped.push(`${attachment.name} (trop volumineux)`);
      continue;
    }
    const storagePath = diskName(attachment.name);
    await fsp.writeFile(path.join(FILES_DIR, storagePath), Buffer.from(attachment.contentBytes, 'base64'));
    await pool.query(
      `INSERT INTO group_files (project_id, message_id, filename, storage_path) VALUES ($1, $2, $3, $4)`,
      [projectId, messageRowId, attachment.name || 'piece-jointe', storagePath]
    );
    saved += 1;
  }
  await pool.query(
    `UPDATE group_messages SET attachments_fetched = true, attachments_note = $1 WHERE id = $2`,
    [skipped.length ? `Non récupéré : ${skipped.join(', ')} — à ouvrir dans Outlook` : null, messageRowId]
  );
  return saved;
}

async function syncMailReplies() {
  await resolvePendingSentMessages();
  const conversations = (
    await pool.query(
      `SELECT DISTINCT ON (conversation_id) project_id, conversation_id, mailbox_account_id
       FROM group_messages
       WHERE direction = 'sent' AND sent_at > now() - interval '90 days' AND conversation_id NOT LIKE 'pending:%'
       ORDER BY conversation_id, sent_at`
    )
  ).rows;
  let added = 0;
  for (const conversation of conversations) {
    try {
      const params = new URLSearchParams({
        $filter: `conversationId eq '${conversation.conversation_id.replace(/'/g, "''")}'`,
        $select: 'id,internetMessageId,from,toRecipients,ccRecipients,subject,uniqueBody,receivedDateTime,sentDateTime,hasAttachments,isDraft',
        $top: '100'
      });
      const page = await graph('GET', `/users/${encodeURIComponent(conversation.mailbox_account_id)}/messages?${params}`, null, {
        headers: { Prefer: 'outlook.body-content-type="text"' }
      });
      for (const message of page?.value || []) {
        if (message.isDraft || !message.internetMessageId) continue;
        const inserted = await pool.query(
          `INSERT INTO group_messages (project_id, direction, mailbox_account_id, conversation_id, internet_message_id,
                                       from_name, from_email, recipients, subject, body, has_attachments, sent_at)
           VALUES ($1, 'reply', $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
           ON CONFLICT (internet_message_id) DO NOTHING
           RETURNING id`,
          [
            conversation.project_id,
            conversation.mailbox_account_id,
            conversation.conversation_id,
            message.internetMessageId,
            message.from?.emailAddress?.name || null,
            message.from?.emailAddress?.address || null,
            JSON.stringify([...recipientsOf(message.toRecipients), ...recipientsOf(message.ccRecipients)]),
            message.subject || null,
            (message.uniqueBody?.content || '').trim(),
            Boolean(message.hasAttachments),
            message.receivedDateTime || message.sentDateTime || new Date().toISOString()
          ]
        );
        if (inserted.rowCount) {
          added += 1;
          const members = await listMembers(conversation.project_id);
          const fromEmail = (message.from?.emailAddress?.address || '').toLowerCase();
          await notify({
            accountIds: members.filter((m) => (m.email || '').toLowerCase() !== fromEmail).map((m) => m.account_id),
            type: 'group_mail_reply',
            title: `Réponse de ${message.from?.emailAddress?.name || fromEmail} : ${message.subject || ''}`.trim(),
            body: `Projet ${await projectName(conversation.project_id)} — Communications`,
            projectId: conversation.project_id
          });
        }
        if (message.hasAttachments) {
          const row = (
            await pool.query(
              `SELECT id, project_id FROM group_messages WHERE internet_message_id = $1 AND NOT attachments_fetched`,
              [message.internetMessageId]
            )
          ).rows[0];
          if (row) {
            try {
              await fetchMailAttachments({
                messageRowId: row.id,
                projectId: row.project_id,
                mailboxId: conversation.mailbox_account_id,
                graphMessageId: message.id
              });
            } catch (attachmentError) {
              console.error('[Projets Groupe] Pièces jointes du mail impossibles à récupérer', attachmentError.message || attachmentError);
            }
          }
        }
      }
    } catch (error) {
      console.error('[Projets Groupe] Relève des réponses impossible', conversation.conversation_id, error.message || error);
    }
  }
  if (added) console.log(`[Projets Groupe] ${added} réponse(s) de mail rangée(s)`);
}

let roomsCache = { at: 0, value: null };

async function listRooms() {
  if (roomsCache.value && Date.now() - roomsCache.at < 60 * 60 * 1000) return roomsCache.value;
  try {
    const page = await graph('GET', '/places/microsoft.graph.room?$top=200');
    const rooms = (page?.value || [])
      .filter((room) => room.emailAddress)
      .map((room) => ({
        email: room.emailAddress.toLowerCase(),
        name: room.displayName || room.emailAddress,
        capacity: room.capacity ?? null,
        building: room.building || null,
        floor: room.floorLabel || (room.floorNumber != null ? String(room.floorNumber) : null)
      }))
      .sort((a, b) => a.name.localeCompare(b.name, 'fr'));
    roomsCache = { at: Date.now(), value: { rooms, error: null } };
  } catch (error) {
    // Pas de cache sur erreur : la permission peut être accordée entre-temps.
    return {
      rooms: [],
      error: error.status === 403
        ? "Liste des salles indisponible : la permission Microsoft Graph Place.Read.All (application) n'est pas accordée."
        : error.message
    };
  }
  return roomsCache.value;
}

// ---------------------------------------------------------------------------
// Tâches de fond : retards, rappels de compte rendu
// ---------------------------------------------------------------------------
async function notifyOverdueTasks() {
  const tasks = await pool.query(
    `UPDATE group_tasks t
     SET overdue_notified_for = t.end_date, overdue_notified_account = t.assignee_account_id
     FROM group_projects p
     WHERE p.id = t.project_id AND p.status = 'active'
       AND t.status <> 'done' AND t.assignee_account_id IS NOT NULL
       AND t.end_date < (now() AT TIME ZONE 'Europe/Paris')::date
       AND (t.overdue_notified_for IS DISTINCT FROM t.end_date OR t.overdue_notified_account IS DISTINCT FROM t.assignee_account_id)
     RETURNING t.title, t.project_id, t.assignee_account_id, to_char(t.end_date, 'DD/MM/YYYY') AS end_fr, p.name AS project_name`
  );
  for (const t of tasks.rows) {
    await notify({
      accountIds: [t.assignee_account_id],
      type: 'task_overdue',
      title: `Tâche en retard : ${t.title}`,
      body: `Projet ${t.project_name} — date de fin dépassée (${t.end_fr})`,
      projectId: t.project_id
    });
  }
  const subtasks = await pool.query(
    `UPDATE group_subtasks s
     SET overdue_notified_for = s.end_date, overdue_notified_account = s.assignee_account_id
     FROM group_tasks t, group_projects p
     WHERE t.id = s.task_id AND p.id = t.project_id AND p.status = 'active'
       AND s.status <> 'done' AND t.status <> 'done' AND s.assignee_account_id IS NOT NULL
       AND s.end_date < (now() AT TIME ZONE 'Europe/Paris')::date
       AND (s.overdue_notified_for IS DISTINCT FROM s.end_date OR s.overdue_notified_account IS DISTINCT FROM s.assignee_account_id)
     RETURNING s.title, s.assignee_account_id, t.title AS task_title, t.project_id,
               to_char(s.end_date, 'DD/MM/YYYY') AS end_fr, p.name AS project_name`
  );
  for (const s of subtasks.rows) {
    await notify({
      accountIds: [s.assignee_account_id],
      type: 'subtask_overdue',
      title: `Sous-tâche en retard : ${s.title}`,
      body: `Tâche ${s.task_title} — projet ${s.project_name} — date de fin dépassée (${s.end_fr})`,
      projectId: s.project_id
    });
  }
}

// Après une réunion sans compte rendu : rappel à l'organisateur (notification
// + mail), puis un second rappel 2 jours plus tard s'il manque toujours.
async function remindMissingMinutes() {
  const due = await pool.query(
    `UPDATE group_meetings g
     SET minutes_reminders = g.minutes_reminders + 1, minutes_reminded_at = now()
     FROM group_projects p, app_accounts o
     WHERE p.id = g.project_id AND p.status = 'active' AND o.id = g.organizer_account_id
       AND g.status = 'planned' AND g.end_at < now()
       AND NOT EXISTS (SELECT 1 FROM group_minutes m WHERE m.meeting_id = g.id AND NOT m.is_draft)
       AND (g.minutes_reminders = 0 OR (g.minutes_reminders = 1 AND g.minutes_reminded_at < now() - interval '2 days'))
     RETURNING g.id, g.title, g.project_id, g.organizer_account_id, p.name AS project_name,
               o.email AS organizer_email, o.display_name AS organizer_name,
               to_char(g.start_at AT TIME ZONE 'Europe/Paris', 'DD/MM/YYYY à HH24:MI') AS start_fr`
  );
  for (const meeting of due.rows) {
    await notify({
      accountIds: [meeting.organizer_account_id],
      type: 'group_minutes_reminder',
      title: `Compte rendu à saisir : ${meeting.title}`,
      body: `Réunion du ${meeting.start_fr} — projet ${meeting.project_name}`,
      projectId: meeting.project_id
    });
    if (meeting.organizer_email) {
      await sendMailWithAttachments({
        to: meeting.organizer_email,
        subject: `[${meeting.project_name}] Compte rendu à saisir : ${meeting.title}`,
        html: `<div style="font-family:Inter,'Segoe UI',Arial,sans-serif;font-size:14px;line-height:1.6;color:#1f2937">
          <p>Bonjour ${escapeHtml(meeting.organizer_name)},</p>
          <p>La réunion <strong>« ${escapeHtml(meeting.title)} »</strong> du ${escapeHtml(meeting.start_fr)}
          (projet <strong>${escapeHtml(meeting.project_name)}</strong>) n'a pas encore de compte rendu.</p>
          <p style="margin:24px 0"><a href="${appLink(meeting.project_id)}" style="display:inline-block;padding:10px 20px;background:#ca0088;color:#ffffff;border-radius:8px;font-weight:600;text-decoration:none">Saisir le compte rendu</a></p>
        </div>`
      }).catch((error) => console.error('[Projets Groupe] Mail de rappel impossible', error.message || error));
    }
  }
}

// ---------------------------------------------------------------------------
// Requêtes communes
// ---------------------------------------------------------------------------
const TASKS_SELECT = `
  SELECT t.id, t.project_id, t.title, t.description, t.status, t.assignee_account_id,
         a.display_name AS assignee_name, t.estimated_hours, t.spent_hours,
         'manuelle' AS origin, NULL AS github_issue_url, NULL AS github_item_id, t.completed_at,
         to_char(t.start_date, 'YYYY-MM-DD') AS start_date, to_char(t.end_date, 'YYYY-MM-DD') AS end_date,
         (SELECT COUNT(*) FROM group_task_comments c WHERE c.task_id = t.id)::int AS comment_count,
         (SELECT COALESCE(json_agg(json_build_object('id', f.id, 'filename', f.filename) ORDER BY f.created_at), '[]'::json)
          FROM group_files f WHERE f.task_id = t.id) AS files,
         (SELECT COALESCE(json_agg(json_build_object(
                   'id', s.id, 'task_id', s.task_id, 'title', s.title, 'status', s.status,
                   'assignee_account_id', s.assignee_account_id, 'assignee_name', sa.display_name,
                   'start_date', to_char(s.start_date, 'YYYY-MM-DD'), 'end_date', to_char(s.end_date, 'YYYY-MM-DD'),
                   'sort_order', s.sort_order) ORDER BY s.sort_order, s.created_at), '[]'::json)
          FROM group_subtasks s LEFT JOIN app_accounts sa ON sa.id = s.assignee_account_id
          WHERE s.task_id = t.id) AS subtasks
  FROM group_tasks t
  LEFT JOIN app_accounts a ON a.id = t.assignee_account_id
`;

const SUBTASK_SELECT = `
  SELECT s.id, s.task_id, s.title, s.status, s.assignee_account_id, a.display_name AS assignee_name,
         to_char(s.start_date, 'YYYY-MM-DD') AS start_date, to_char(s.end_date, 'YYYY-MM-DD') AS end_date, s.sort_order
  FROM group_subtasks s LEFT JOIN app_accounts a ON a.id = s.assignee_account_id
`;

const MEETINGS_SELECT = `
  SELECT g.id, g.project_id, g.title, g.agenda, g.location, g.room_email, g.room_name, g.online, g.status,
         to_char(g.start_at AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD"T"HH24:MI') AS start_at,
         to_char(g.end_at AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD"T"HH24:MI') AS end_at,
         g.organizer_account_id, o.display_name AS organizer_name, g.attendee_ids,
         g.online_meeting_url, g.outlook_error, (g.outlook_event_id IS NOT NULL) AS in_outlook,
         (SELECT m.id FROM group_minutes m WHERE m.meeting_id = g.id ORDER BY m.is_draft, m.created_at LIMIT 1) AS minute_id,
         (SELECT m.is_draft FROM group_minutes m WHERE m.meeting_id = g.id ORDER BY m.is_draft, m.created_at LIMIT 1) AS minute_is_draft,
         (g.end_at < now()) AS past
  FROM group_meetings g LEFT JOIN app_accounts o ON o.id = g.organizer_account_id
`;

async function loadTask(req, res, taskId) {
  const task = (await pool.query(`SELECT * FROM group_tasks WHERE id = $1`, [taskId])).rows[0];
  if (!task) {
    res.status(404).json({ error: 'Tâche introuvable' });
    return null;
  }
  return (await requireMember(req, res, task.project_id)) ? task : null;
}

async function insertTaskFiles(db, task, files, accountId) {
  for (const file of files) {
    await db.query(
      `INSERT INTO group_files (project_id, task_id, filename, storage_path, uploaded_by) VALUES ($1, $2, $3, $4, $5)`,
      [task.project_id, task.id, decodeUploadName(file.originalname), file.filename, accountId]
    );
  }
}

async function notifyTaskAssignee(task, actorId) {
  if (!task?.assignee_account_id || task.assignee_account_id === actorId) return;
  await notify({
    accountIds: [task.assignee_account_id],
    type: 'task_assigned',
    title: `Nouvelle tâche : ${task.title}`,
    body: `Projet ${await projectName(task.project_id)}`,
    projectId: task.project_id
  });
}

function completionRate(tasks) {
  if (!tasks.length) return 0;
  return Math.round((tasks.filter((t) => t.status === 'done').length / tasks.length) * 100);
}

// ---- Compte rendu préparé à partir de l'invitation ----
async function meetingForMinutes(meetingId) {
  const meeting = (
    await pool.query(
      `SELECT g.title, g.agenda, g.location, g.room_name, g.online, g.attendee_ids,
              to_char(g.start_at AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD') AS day,
              to_char(g.start_at AT TIME ZONE 'Europe/Paris', 'DD/MM/YYYY') AS day_fr,
              to_char(g.start_at AT TIME ZONE 'Europe/Paris', 'HH24:MI') AS start_fr,
              to_char(g.end_at AT TIME ZONE 'Europe/Paris', 'HH24:MI') AS end_fr,
              o.display_name AS organizer_name
       FROM group_meetings g LEFT JOIN app_accounts o ON o.id = g.organizer_account_id
       WHERE g.id = $1`,
      [meetingId]
    )
  ).rows[0];
  if (!meeting) return null;
  meeting.attendee_names = (
    await pool.query(`SELECT display_name FROM app_accounts WHERE id = ANY($1::uuid[]) ORDER BY display_name`, [meeting.attendee_ids])
  ).rows.map((row) => row.display_name);
  return meeting;
}

const minutesTitle = (meetingTitle) => `Compte rendu — ${meetingTitle}`;

function minutesTemplate(meeting) {
  const place = [meeting.room_name || meeting.location, meeting.online ? 'Teams' : null].filter(Boolean).join(' / ');
  return [
    `Réunion du ${meeting.day_fr} de ${meeting.start_fr} à ${meeting.end_fr}${place ? ` — ${place}` : ''}`,
    `Organisateur : ${meeting.organizer_name || '—'}`,
    `Participants : ${[meeting.organizer_name, ...meeting.attendee_names].filter(Boolean).join(', ')}`,
    '',
    'Ordre du jour :',
    meeting.agenda || '-',
    '',
    'Points abordés :',
    '- ',
    '',
    'Décisions :',
    '- ',
    '',
    'Actions (qui / quoi / quand) :',
    '- '
  ].join('\n');
}

// Date et heure locales Paris "AAAA-MM-JJTHH:MM".
const isLocalDateTime = (value) => /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(String(value || ''));

function outlookEventBody({ project, meeting, attendees }) {
  return {
    subject: `[${project.name}] ${meeting.title}`,
    body: {
      contentType: 'HTML',
      content:
        `<p>${escapeHtml(meeting.agenda || '').replace(/\n/g, '<br/>')}</p>` +
        `<p style="color:#6b7280;font-size:12px">Réunion du projet « ${escapeHtml(project.name)} » — ` +
        `<a href="${appLink(project.id)}">ouvrir le projet</a></p>`
    },
    start: { dateTime: `${meeting.start}:00`, timeZone: 'Europe/Paris' },
    end: { dateTime: `${meeting.end}:00`, timeZone: 'Europe/Paris' },
    location: meeting.roomEmail
      ? { displayName: meeting.roomName || meeting.roomEmail, locationEmailAddress: meeting.roomEmail, locationType: 'conferenceRoom' }
      : meeting.location ? { displayName: meeting.location } : undefined,
    // La salle est invitée comme ressource : c'est ce qui la réserve.
    attendees: [
      ...attendees
        .filter((a) => a.email)
        .map((a) => ({ emailAddress: { address: a.email, name: a.display_name }, type: 'required' })),
      ...(meeting.roomEmail ? [{ emailAddress: { address: meeting.roomEmail, name: meeting.roomName || meeting.roomEmail }, type: 'resource' }] : [])
    ],
    isOnlineMeeting: Boolean(meeting.online),
    ...(meeting.online ? { onlineMeetingProvider: 'teamsForBusiness' } : {}),
    allowNewTimeProposals: true
  };
}

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------
export function registerGroupProjectRoutes(app, { afterSchema = Promise.resolve() } = {}) {
  fsp.mkdir(FILES_DIR, { recursive: true }).catch((error) =>
    console.error('[Projets Groupe] Dossier de stockage impossible', error.message || error)
  );

  // Le schéma s'appuie sur user_notifications, créé par le module Projets IT.
  const schemaReady = afterSchema
    .then(() => ensureGroupProjectsSchema())
    .catch((error) => console.error('[Projets Groupe] Schéma impossible', error.message || error));

  const runJobs = () =>
    schemaReady
      .then(() => notifyOverdueTasks())
      .then(() => remindMissingMinutes())
      .catch((error) => console.error('[Projets Groupe] Tâches de fond', error.message || error));
  setTimeout(runJobs, 25000).unref();
  setInterval(runJobs, 30 * 60 * 1000).unref();

  const runMailSync = () => schemaReady.then(syncMailReplies).catch((error) =>
    console.error('[Projets Groupe] Relève des mails', error.message || error)
  );
  setTimeout(runMailSync, 40000).unref();
  setInterval(runMailSync, 5 * 60 * 1000).unref();

  // ---- Accès à la page (affichage du menu) ----
  app.get('/api/group-projects/access', requireAuth, async (req, res) => {
    try {
      res.json({
        canCreate: canCreateProjects(req.session.user),
        isMember: await hasGroupProjectAccess(req.session.user.id)
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Collaborateurs Microsoft 365 pouvant être ajoutés ----
  app.get('/api/group-projects/accounts', requireAuth, async (req, res) => {
    try {
      if (!canCreateProjects(req.session.user) && !(await hasGroupProjectAccess(req.session.user.id))) {
        return res.status(403).json({ error: 'Accès refusé' });
      }
      const result = await pool.query(
        `SELECT e.microsoft_object_id AS id,
                COALESCE(NULLIF(TRIM(CONCAT_WS(' ', e.first_name, e.last_name)), ''), e.email, e.microsoft_upn) AS display_name,
                COALESCE(e.email, e.microsoft_upn) AS email
         FROM employees e
         WHERE e.is_active = true AND e.account_enabled = true
           AND e.microsoft_object_id IS NOT NULL AND COALESCE(e.email, e.microsoft_upn) IS NOT NULL
         ORDER BY display_name`
      );
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Salles de réunion (boîtes de ressource Exchange) ----
  app.get('/api/group-projects/rooms', requireAuth, async (req, res) => {
    try {
      if (!canCreateProjects(req.session.user) && !(await hasGroupProjectAccess(req.session.user.id))) {
        return res.status(403).json({ error: 'Accès refusé' });
      }
      res.json(await listRooms());
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Disponibilités sur une semaine (lundi -> vendredi) des invités et des salles.
  // Seul le statut (occupé, provisoire, absent…) est renvoyé, jamais l'objet des rendez-vous.
  app.post('/api/group-projects/:id/availability', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id))) return;
      const { weekStart } = req.body;
      if (!isDate(weekStart)) return res.status(400).json({ error: 'Semaine invalide' });
      const attendeeIds = Array.isArray(req.body.attendeeIds) ? req.body.attendeeIds : [];
      const roomEmails = (Array.isArray(req.body.roomEmails) ? req.body.roomEmails : []).filter(Boolean).slice(0, 40);
      const members = await listMembers(req.params.id);
      const people = members.filter((m) => m.email && (attendeeIds.includes(m.account_id) || m.account_id === req.session.user.id));
      const emails = [...new Set([...people.map((p) => p.email.toLowerCase()), ...roomEmails.map((e) => String(e).toLowerCase())])];
      const end = new Date(`${weekStart}T00:00:00Z`);
      end.setUTCDate(end.getUTCDate() + 5);
      const weekEnd = end.toISOString().slice(0, 10);
      const schedules = [];
      for (let i = 0; i < emails.length; i += 20) {
        const result = await graph(
          'POST',
          `/users/${encodeURIComponent(req.session.user.id)}/calendar/getSchedule`,
          {
            schedules: emails.slice(i, i + 20),
            startTime: { dateTime: `${weekStart}T00:00:00`, timeZone: 'Europe/Paris' },
            endTime: { dateTime: `${weekEnd}T00:00:00`, timeZone: 'Europe/Paris' },
            availabilityViewInterval: 30
          },
          { headers: { Prefer: 'outlook.timezone="Europe/Paris"' } }
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
      res.json({
        weekStart,
        people: people.map((p) => ({ account_id: p.account_id, display_name: p.display_name, email: p.email.toLowerCase() })),
        schedules
      });
    } catch (error) {
      console.error('[Projets Groupe] Disponibilités', error);
      res.status(error.status === 403 ? 502 : 500).json({
        error: error.status === 403
          ? "Disponibilités indisponibles : la permission Microsoft Graph Calendars.ReadWrite (ou Calendars.Read) de l'application n'est pas accordée."
          : error.message
      });
    }
  });

  // Projets IT de l'utilisateur (équipe ou client), en lecture simplifiée.
  app.get('/api/group-projects/it-projects', requireAuth, async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT p.id, p.name, p.project_state,
                to_char(p.start_date, 'YYYY-MM-DD') AS start_date, to_char(p.due_date, 'YYYY-MM-DD') AS due_date,
                (SELECT COUNT(*) FROM project_tasks t WHERE t.project_id = p.id)::int AS nb_taches,
                (SELECT COUNT(*) FROM project_tasks t WHERE t.project_id = p.id AND t.status = 'done')::int AS nb_taches_terminees,
                (SELECT COUNT(*) FROM project_tasks t WHERE t.project_id = p.id AND t.status <> 'done' AND t.assignee_account_id = $1)::int AS mes_taches,
                CASE
                  WHEN EXISTS (SELECT 1 FROM project_assignments a WHERE a.project_id = p.id AND a.account_id = $1 AND a.project_role = 'chef_de_projet') THEN 'chef_de_projet'
                  WHEN EXISTS (SELECT 1 FROM project_assignments a WHERE a.project_id = p.id AND a.account_id = $1) THEN 'equipe'
                  ELSE 'client'
                END AS mon_role
         FROM projects p
         WHERE p.status <> 'archive'
           AND p.project_state IS DISTINCT FROM 'closed'
           AND (EXISTS (SELECT 1 FROM project_assignments a WHERE a.project_id = p.id AND a.account_id = $1)
                OR EXISTS (SELECT 1 FROM project_clients c WHERE c.project_id = p.id AND c.account_id = $1))
         ORDER BY p.updated_at DESC`,
        [req.session.user.id]
      );
      res.json(
        result.rows.map((p) => ({
          ...p,
          tauxCompletude: p.nb_taches ? Math.round((p.nb_taches_terminees / p.nb_taches) * 100) : 0
        }))
      );
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Projets ----
  app.get('/api/group-projects', requireAuth, async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT p.id, p.name, p.description, p.status, p.ref_number,
                to_char(p.start_date, 'YYYY-MM-DD') AS start_date, to_char(p.due_date, 'YYYY-MM-DD') AS due_date,
                m.role AS my_role,
                (SELECT COUNT(*) FROM group_project_members x WHERE x.project_id = p.id)::int AS nb_membres,
                (SELECT COUNT(*) FROM group_tasks t WHERE t.project_id = p.id)::int AS nb_taches,
                (SELECT COUNT(*) FROM group_tasks t WHERE t.project_id = p.id AND t.status = 'done')::int AS nb_taches_terminees,
                (SELECT to_char(min(g.start_at) AT TIME ZONE 'Europe/Paris', 'YYYY-MM-DD"T"HH24:MI')
                 FROM group_meetings g WHERE g.project_id = p.id AND g.status = 'planned' AND g.start_at > now()) AS prochaine_reunion
         FROM group_projects p
         JOIN group_project_members m ON m.project_id = p.id AND m.account_id = $1
         WHERE p.status <> 'archive'
         ORDER BY p.status = 'closed', p.updated_at DESC`,
        [req.session.user.id]
      );
      res.json(
        result.rows.map((p) => ({
          ...p,
          ref: projectRef(p.ref_number),
          tauxCompletude: p.nb_taches ? Math.round((p.nb_taches_terminees / p.nb_taches) * 100) : 0
        }))
      );
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/group-projects', requireAuth, async (req, res) => {
    if (!canCreateProjects(req.session.user)) {
      return res.status(403).json({ error: 'Seuls les managers et directeurs peuvent créer un projet' });
    }
    const client = await pool.connect();
    try {
      const name = String(req.body.name || '').trim();
      const { description, startDate, dueDate, memberIds } = req.body;
      if (!name) return res.status(400).json({ error: 'Nom du projet requis' });
      for (const value of [startDate, dueDate]) {
        if (value && !isDate(value)) return res.status(400).json({ error: 'Date invalide' });
      }
      if (startDate && dueDate && startDate > dueDate) {
        return res.status(400).json({ error: "La date de début doit précéder l'échéance" });
      }
      await client.query('BEGIN');
      // Le créateur est responsable ; son compte existe (il est connecté).
      const project = (
        await client.query(
          `INSERT INTO group_projects (name, description, start_date, due_date, created_by)
           VALUES ($1, $2, $3, $4, $5) RETURNING *`,
          [name, description || null, startDate || null, dueDate || null, req.session.user.id]
        )
      ).rows[0];
      await client.query(
        `INSERT INTO group_project_members (project_id, account_id, role) VALUES ($1, $2, 'responsable')`,
        [project.id, req.session.user.id]
      );
      const added = [];
      for (const microsoftObjectId of [...new Set(Array.isArray(memberIds) ? memberIds : [])]) {
        const accountId = await ensureAccount(client, microsoftObjectId);
        const inserted = await client.query(
          `INSERT INTO group_project_members (project_id, account_id) VALUES ($1, $2) ON CONFLICT DO NOTHING RETURNING account_id`,
          [project.id, accountId]
        );
        if (inserted.rowCount) added.push(accountId);
      }
      await client.query('COMMIT');
      await notify({
        accountIds: added,
        type: 'group_member_added',
        title: `Vous êtes membre du projet ${project.name}`,
        body: `Ajouté par ${req.session.user.displayName}`,
        projectId: project.id,
        exceptId: req.session.user.id
      });
      res.status(201).json(project);
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error('[Projets Groupe] Création', error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

  app.get('/api/group-projects/:id', requireAuth, async (req, res) => {
    try {
      const role = await requireMember(req, res, req.params.id);
      if (!role) return;
      const project = (
        await pool.query(
          `SELECT p.id, p.name, p.description, p.status, p.created_by, p.ref_number,
                  to_char(p.start_date, 'YYYY-MM-DD') AS start_date, to_char(p.due_date, 'YYYY-MM-DD') AS due_date
           FROM group_projects p WHERE p.id = $1`,
          [req.params.id]
        )
      ).rows[0];
      const tasks = (await pool.query(`${TASKS_SELECT} WHERE t.project_id = $1 ORDER BY t.created_at`, [req.params.id])).rows;
      res.json({
        ...project,
        ref: projectRef(project.ref_number),
        myRole: role,
        estResponsable: role === 'responsable',
        // Les composants partagés avec Projets IT s'appuient sur ce drapeau.
        estChefDeProjet: true,
        members: await listMembers(req.params.id),
        tasks,
        tauxCompletude: completionRate(tasks)
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.put('/api/group-projects/:id', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id, { responsable: true }))) return;
      const current = (
        await pool.query(
          `SELECT to_char(start_date, 'YYYY-MM-DD') AS start_date, to_char(due_date, 'YYYY-MM-DD') AS due_date
           FROM group_projects WHERE id = $1`,
          [req.params.id]
        )
      ).rows[0];
      const { name, description, status, startDate, dueDate } = req.body;
      if (status !== undefined && !['active', 'closed'].includes(status)) return res.status(400).json({ error: 'Statut invalide' });
      for (const value of [startDate, dueDate]) {
        if (value && !isDate(value)) return res.status(400).json({ error: 'Date invalide' });
      }
      const start = startDate !== undefined ? startDate || null : current.start_date;
      const due = dueDate !== undefined ? dueDate || null : current.due_date;
      if (start && due && start > due) return res.status(400).json({ error: "La date de début doit précéder l'échéance" });
      const result = await pool.query(
        `UPDATE group_projects SET
           name = COALESCE($1, name), description = COALESCE($2, description), status = COALESCE($3, status),
           start_date = $4::date, due_date = $5::date, updated_at = now()
         WHERE id = $6 RETURNING *`,
        [name ? String(name).trim() : null, description ?? null, status ?? null, start, due, req.params.id]
      );
      res.json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Suppression : le projet est archivé (masqué pour tous).
  app.delete('/api/group-projects/:id', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id, { responsable: true }))) return;
      await pool.query(`UPDATE group_projects SET status = 'archive', updated_at = now() WHERE id = $1`, [req.params.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Membres (responsables) ----
  app.post('/api/group-projects/:id/members', requireAuth, async (req, res) => {
    const client = await pool.connect();
    try {
      if (!(await requireMember(req, res, req.params.id, { responsable: true }))) return;
      const { accountId: microsoftObjectId, role = 'membre' } = req.body;
      if (!microsoftObjectId) return res.status(400).json({ error: 'accountId requis' });
      if (!['responsable', 'membre'].includes(role)) return res.status(400).json({ error: 'Rôle invalide' });
      await client.query('BEGIN');
      const accountId = await ensureAccount(client, microsoftObjectId);
      const inserted = await client.query(
        `INSERT INTO group_project_members (project_id, account_id, role) VALUES ($1, $2, $3)
         ON CONFLICT DO NOTHING RETURNING account_id`,
        [req.params.id, accountId, role]
      );
      await client.query('COMMIT');
      if (inserted.rowCount) {
        const name = await projectName(req.params.id);
        await notify({
          accountIds: [accountId],
          type: 'group_member_added',
          title: `Vous êtes membre du projet ${name}`,
          body: `Ajouté par ${req.session.user.displayName}`,
          projectId: req.params.id,
          exceptId: req.session.user.id
        });
      }
      res.status(201).json(await listMembers(req.params.id));
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error(error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

  app.put('/api/group-projects/:id/members/:accountId', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id, { responsable: true }))) return;
      const { role } = req.body;
      if (!['responsable', 'membre'].includes(role)) return res.status(400).json({ error: 'Rôle invalide' });
      if (role === 'membre') {
        const others = await pool.query(
          `SELECT 1 FROM group_project_members WHERE project_id = $1 AND role = 'responsable' AND account_id <> $2`,
          [req.params.id, req.params.accountId]
        );
        if (!others.rowCount) return res.status(400).json({ error: 'Le projet doit garder au moins un responsable' });
      }
      await pool.query(
        `UPDATE group_project_members SET role = $1 WHERE project_id = $2 AND account_id = $3`,
        [role, req.params.id, req.params.accountId]
      );
      res.json(await listMembers(req.params.id));
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.delete('/api/group-projects/:id/members/:accountId', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id, { responsable: true }))) return;
      const target = (
        await pool.query(`SELECT role FROM group_project_members WHERE project_id = $1 AND account_id = $2`, [
          req.params.id,
          req.params.accountId
        ])
      ).rows[0];
      if (target?.role === 'responsable') {
        const others = await pool.query(
          `SELECT 1 FROM group_project_members WHERE project_id = $1 AND role = 'responsable' AND account_id <> $2`,
          [req.params.id, req.params.accountId]
        );
        if (!others.rowCount) return res.status(400).json({ error: 'Le projet doit garder au moins un responsable' });
      }
      await pool.query(`DELETE FROM group_project_members WHERE project_id = $1 AND account_id = $2`, [
        req.params.id,
        req.params.accountId
      ]);
      res.json(await listMembers(req.params.id));
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Tâches ----
  app.post('/api/group-projects/tasks', requireAuth, uploadFiles, async (req, res) => {
    const files = req.files || [];
    try {
      const { projectId, title, description, assigneeAccountId, estimatedHours } = req.body;
      if (!projectId || !String(title || '').trim()) {
        await removeUploadedFiles(files);
        return res.status(400).json({ error: 'Titre de la tâche requis' });
      }
      if (!(await requireMember(req, res, projectId))) return removeUploadedFiles(files);
      const dates = readPlanningDates(req.body);
      if (dates.error) {
        await removeUploadedFiles(files);
        return res.status(400).json({ error: dates.error });
      }
      const client = await pool.connect();
      let task;
      try {
        await client.query('BEGIN');
        task = (
          await client.query(
            `INSERT INTO group_tasks (project_id, title, description, assignee_account_id, estimated_hours, start_date, end_date, created_by)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
            [projectId, String(title).trim(), description || null, assigneeAccountId || null, Number(estimatedHours) || 0,
              dates.start, dates.end, req.session.user.id]
          )
        ).rows[0];
        await insertTaskFiles(client, task, files, req.session.user.id);
        await client.query('COMMIT');
      } catch (error) {
        await client.query('ROLLBACK').catch(() => {});
        await removeUploadedFiles(files);
        throw error;
      } finally {
        client.release();
      }
      await pool.query(`UPDATE group_projects SET updated_at = now() WHERE id = $1`, [projectId]);
      await notifyTaskAssignee(task, req.session.user.id);
      res.status(201).json(task);
    } catch (error) {
      console.error(error);
      if (!res.headersSent) res.status(500).json({ error: error.message });
    }
  });

  app.put('/api/group-projects/tasks/:id', requireAuth, async (req, res) => {
    try {
      const task = await loadTask(req, res, req.params.id);
      if (!task) return;
      const { status, spentHours, estimatedHours, assigneeAccountId, title, description } = req.body;
      if (status != null && !TASK_STATUSES.includes(status)) return res.status(400).json({ error: 'Statut invalide' });
      const current = (
        await pool.query(
          `SELECT to_char(start_date, 'YYYY-MM-DD') AS start_date, to_char(end_date, 'YYYY-MM-DD') AS end_date FROM group_tasks WHERE id = $1`,
          [task.id]
        )
      ).rows[0];
      const dates = readPlanningDates(req.body, current);
      if (dates.error) return res.status(400).json({ error: dates.error });
      const assigneeProvided = assigneeAccountId !== undefined;
      const result = await pool.query(
        `UPDATE group_tasks SET
           status = COALESCE($1, status),
           completed_at = CASE WHEN $1 = 'done' AND status <> 'done' THEN now()
                               WHEN $1 IS NOT NULL AND $1 <> 'done' THEN NULL ELSE completed_at END,
           spent_hours = COALESCE($2, spent_hours),
           estimated_hours = COALESCE($3, estimated_hours),
           assignee_account_id = CASE WHEN $4::boolean THEN $5::uuid ELSE assignee_account_id END,
           start_date = CASE WHEN $6::boolean THEN $7::date ELSE start_date END,
           end_date = CASE WHEN $8::boolean THEN $9::date ELSE end_date END,
           title = COALESCE($10, title),
           description = CASE WHEN $11::boolean THEN $12 ELSE description END,
           updated_at = now()
         WHERE id = $13 RETURNING *`,
        [
          status ?? null, spentHours ?? null, estimatedHours ?? null,
          assigneeProvided, assigneeAccountId || null,
          dates.startProvided, dates.start, dates.endProvided, dates.end,
          title ? String(title).trim() : null, description !== undefined, description || null,
          task.id
        ]
      );
      const updated = result.rows[0];
      if (updated.assignee_account_id && updated.assignee_account_id !== task.assignee_account_id) {
        await notifyTaskAssignee(updated, req.session.user.id);
      }
      res.json(updated);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.delete('/api/group-projects/tasks/:id', requireAuth, async (req, res) => {
    try {
      const task = await loadTask(req, res, req.params.id);
      if (!task) return;
      await pool.query(`DELETE FROM group_tasks WHERE id = $1`, [task.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/group-projects/tasks/:id/files', requireAuth, uploadFiles, async (req, res) => {
    const files = req.files || [];
    try {
      const task = await loadTask(req, res, req.params.id);
      if (!task) return removeUploadedFiles(files);
      if (!files.length) return res.status(400).json({ error: 'Aucun fichier reçu' });
      await insertTaskFiles(pool, task, files, req.session.user.id);
      res.status(201).json(
        (await pool.query(`SELECT id, filename FROM group_files WHERE task_id = $1 ORDER BY created_at`, [task.id])).rows
      );
    } catch (error) {
      await removeUploadedFiles(files);
      console.error(error);
      if (!res.headersSent) res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/group-projects/tasks/:id/comments', requireAuth, async (req, res) => {
    try {
      const task = await loadTask(req, res, req.params.id);
      if (!task) return;
      const comments = (
        await pool.query(
          `SELECT id, author_account_id, author_name, body, NULL AS github_comment_url, created_at
           FROM group_task_comments WHERE task_id = $1 ORDER BY created_at`,
          [task.id]
        )
      ).rows;
      res.json({ comments, githubError: null });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/group-projects/tasks/:id/comments', requireAuth, async (req, res) => {
    try {
      const task = await loadTask(req, res, req.params.id);
      if (!task) return;
      const body = String(req.body.body || '').trim();
      if (!body) return res.status(400).json({ error: 'Commentaire vide' });
      const result = await pool.query(
        `INSERT INTO group_task_comments (task_id, author_account_id, author_name, body) VALUES ($1, $2, $3, $4)
         RETURNING id, author_account_id, author_name, body, NULL AS github_comment_url, created_at`,
        [task.id, req.session.user.id, req.session.user.displayName, body]
      );
      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Sous-tâches ----
  async function loadSubtask(req, res) {
    const subtask = (await pool.query(`SELECT * FROM group_subtasks WHERE id = $1`, [req.params.id])).rows[0];
    if (!subtask) {
      res.status(404).json({ error: 'Sous-tâche introuvable' });
      return null;
    }
    return (await loadTask(req, res, subtask.task_id)) ? subtask : null;
  }

  app.post('/api/group-projects/tasks/:id/subtasks', requireAuth, async (req, res) => {
    try {
      const task = await loadTask(req, res, req.params.id);
      if (!task) return;
      const title = String(req.body.title || '').trim();
      if (!title) return res.status(400).json({ error: 'Titre requis' });
      const dates = readPlanningDates(req.body);
      if (dates.error) return res.status(400).json({ error: dates.error });
      const inserted = await pool.query(
        `INSERT INTO group_subtasks (task_id, title, assignee_account_id, start_date, end_date, sort_order)
         VALUES ($1, $2, $3, $4, $5, (SELECT COALESCE(MAX(sort_order), 0) + 1 FROM group_subtasks WHERE task_id = $1))
         RETURNING id`,
        [task.id, title, req.body.assigneeAccountId || null, dates.start, dates.end]
      );
      res.status(201).json((await pool.query(`${SUBTASK_SELECT} WHERE s.id = $1`, [inserted.rows[0].id])).rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.put('/api/group-projects/subtasks/:id', requireAuth, async (req, res) => {
    try {
      const subtask = await loadSubtask(req, res);
      if (!subtask) return;
      const { title, status, assigneeAccountId } = req.body;
      if (status != null && !SUBTASK_STATUSES.includes(status)) return res.status(400).json({ error: 'Statut invalide' });
      if (title !== undefined && !String(title).trim()) return res.status(400).json({ error: 'Titre requis' });
      const current = (
        await pool.query(
          `SELECT to_char(start_date, 'YYYY-MM-DD') AS start_date, to_char(end_date, 'YYYY-MM-DD') AS end_date FROM group_subtasks WHERE id = $1`,
          [subtask.id]
        )
      ).rows[0];
      const dates = readPlanningDates(req.body, current);
      if (dates.error) return res.status(400).json({ error: dates.error });
      await pool.query(
        `UPDATE group_subtasks SET
           title = COALESCE($1, title),
           status = COALESCE($2, status),
           completed_at = CASE WHEN $2 = 'done' AND status <> 'done' THEN now()
                               WHEN $2 IS NOT NULL AND $2 <> 'done' THEN NULL ELSE completed_at END,
           assignee_account_id = CASE WHEN $3::boolean THEN $4::uuid ELSE assignee_account_id END,
           start_date = CASE WHEN $5::boolean THEN $6::date ELSE start_date END,
           end_date = CASE WHEN $7::boolean THEN $8::date ELSE end_date END,
           updated_at = now()
         WHERE id = $9`,
        [
          title !== undefined ? String(title).trim() : null, status ?? null,
          assigneeAccountId !== undefined, assigneeAccountId || null,
          dates.startProvided, dates.start, dates.endProvided, dates.end, subtask.id
        ]
      );
      res.json((await pool.query(`${SUBTASK_SELECT} WHERE s.id = $1`, [subtask.id])).rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.delete('/api/group-projects/subtasks/:id', requireAuth, async (req, res) => {
    try {
      const subtask = await loadSubtask(req, res);
      if (!subtask) return;
      await pool.query(`DELETE FROM group_subtasks WHERE id = $1`, [subtask.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Fichiers ----
  app.get('/api/group-projects/files/:id/download', requireAuth, async (req, res) => {
    try {
      const file = (await pool.query(`SELECT * FROM group_files WHERE id = $1`, [req.params.id])).rows[0];
      if (!file) return res.status(404).json({ error: 'Fichier introuvable' });
      if (!(await requireMember(req, res, file.project_id))) return;
      const filePath = path.join(FILES_DIR, file.storage_path);
      if (!fs.existsSync(filePath)) return res.status(404).json({ error: 'Fichier introuvable sur le disque' });
      const inlineType = INLINE_PREVIEW_TYPES[path.extname(file.filename).toLowerCase()];
      if (req.query.inline === '1' && inlineType) {
        res.setHeader('Content-Type', inlineType);
        res.setHeader('Content-Disposition', `inline; filename*=UTF-8''${encodeURIComponent(file.filename)}`);
        res.setHeader('X-Content-Type-Options', 'nosniff');
        if (inlineType.startsWith('text/')) res.setHeader('Content-Security-Policy', "default-src 'none'; sandbox");
        return res.sendFile(filePath);
      }
      res.download(filePath, file.filename);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Comptes rendus ----
  app.get('/api/group-projects/:id/minutes', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id))) return;
      const result = await pool.query(
        `SELECT m.id, m.meeting_id, m.title, to_char(m.meeting_date, 'YYYY-MM-DD') AS meeting_date, m.content, m.is_draft,
                m.author_account_id, a.display_name AS author_name, u.display_name AS updated_by_name,
                m.created_at, m.updated_at
         FROM group_minutes m
         LEFT JOIN app_accounts a ON a.id = m.author_account_id
         LEFT JOIN app_accounts u ON u.id = m.updated_by
         WHERE m.project_id = $1
         ORDER BY m.meeting_date DESC, m.created_at DESC`,
        [req.params.id]
      );
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/group-projects/:id/minutes', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id))) return;
      const title = String(req.body.title || '').trim();
      const content = String(req.body.content || '').trim();
      const { meetingDate, meetingId } = req.body;
      if (!title || !content || !isDate(meetingDate)) {
        return res.status(400).json({ error: 'Titre, date et contenu du compte rendu requis' });
      }
      if (meetingId) {
        const meeting = await pool.query(`SELECT 1 FROM group_meetings WHERE id = $1 AND project_id = $2`, [meetingId, req.params.id]);
        if (!meeting.rowCount) return res.status(400).json({ error: 'Réunion inconnue pour ce projet' });
      }
      const result = await pool.query(
        `INSERT INTO group_minutes (project_id, meeting_id, title, meeting_date, content, author_account_id, updated_by)
         VALUES ($1, $2, $3, $4, $5, $6, $6) RETURNING id`,
        [req.params.id, meetingId || null, title, meetingDate, content, req.session.user.id]
      );
      const members = await listMembers(req.params.id);
      await notify({
        accountIds: members.map((m) => m.account_id),
        type: 'group_minutes',
        title: `Compte rendu : ${title}`,
        body: `Projet ${await projectName(req.params.id)} — par ${req.session.user.displayName}`,
        projectId: req.params.id,
        exceptId: req.session.user.id
      });
      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.put('/api/group-projects/minutes/:minuteId', requireAuth, async (req, res) => {
    try {
      const minute = (await pool.query(`SELECT * FROM group_minutes WHERE id = $1`, [req.params.minuteId])).rows[0];
      if (!minute) return res.status(404).json({ error: 'Compte rendu introuvable' });
      if (!(await requireMember(req, res, minute.project_id))) return;
      const { title, content, meetingDate } = req.body;
      // finalize : le brouillon devient le compte rendu définitif (fin des rappels).
      const finalize = req.body.finalize === true;
      if (meetingDate !== undefined && !isDate(meetingDate)) return res.status(400).json({ error: 'Date invalide' });
      if ((title !== undefined && !String(title).trim()) || (content !== undefined && !String(content).trim())) {
        return res.status(400).json({ error: 'Titre et contenu ne peuvent pas être vides' });
      }
      await pool.query(
        `UPDATE group_minutes SET title = COALESCE($1, title), content = COALESCE($2, content),
                meeting_date = COALESCE($3::date, meeting_date), updated_by = $4, updated_at = now(),
                is_draft = CASE WHEN $6::boolean THEN false ELSE is_draft END
         WHERE id = $5`,
        [title ? String(title).trim() : null, content ? String(content).trim() : null, meetingDate || null, req.session.user.id, minute.id, finalize]
      );
      if (finalize && minute.is_draft) {
        const members = await listMembers(minute.project_id);
        await notify({
          accountIds: members.map((m) => m.account_id),
          type: 'group_minutes',
          title: `Compte rendu : ${title ? String(title).trim() : minute.title}`,
          body: `Projet ${await projectName(minute.project_id)} — par ${req.session.user.displayName}`,
          projectId: minute.project_id,
          exceptId: req.session.user.id
        });
      }
      res.json({ ok: true });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.delete('/api/group-projects/minutes/:minuteId', requireAuth, async (req, res) => {
    try {
      const minute = (await pool.query(`SELECT * FROM group_minutes WHERE id = $1`, [req.params.minuteId])).rows[0];
      if (!minute) return res.status(404).json({ error: 'Compte rendu introuvable' });
      const role = await requireMember(req, res, minute.project_id);
      if (!role) return;
      if (role !== 'responsable' && minute.author_account_id !== req.session.user.id) {
        return res.status(403).json({ error: "Seul l'auteur ou un responsable peut supprimer ce compte rendu" });
      }
      await pool.query(`DELETE FROM group_minutes WHERE id = $1`, [minute.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Communications (mails) ----
  app.get('/api/group-projects/:id/communications', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id))) return;
      const result = await pool.query(
        `SELECT g.id, g.direction, g.conversation_id, g.from_name, g.from_email, g.recipients, g.subject, g.body,
                g.has_attachments, g.attachments_fetched, g.attachments_note, g.sent_at, a.display_name AS mailbox_name,
                (SELECT COALESCE(json_agg(json_build_object('id', f.id, 'filename', f.filename) ORDER BY f.created_at), '[]'::json)
                 FROM group_files f WHERE f.message_id = g.id) AS files
         FROM group_messages g LEFT JOIN app_accounts a ON a.id = g.mailbox_account_id
         WHERE g.project_id = $1
         ORDER BY g.sent_at`,
        [req.params.id]
      );
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Mail envoyé depuis la boîte de l'utilisateur à des membres choisis.
  app.post('/api/group-projects/:id/mails', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id))) return;
      const subject = String(req.body.subject || '').trim();
      const body = String(req.body.body || '').trim();
      const recipientIds = Array.isArray(req.body.recipientIds) ? req.body.recipientIds : [];
      if (!subject || !body || !recipientIds.length) {
        return res.status(400).json({ error: 'Objet, message et au moins un destinataire requis' });
      }
      const members = await listMembers(req.params.id);
      const recipients = members.filter((m) => recipientIds.includes(m.account_id) && m.email);
      if (recipients.length !== new Set(recipientIds).size) {
        return res.status(400).json({ error: 'Les destinataires doivent être des membres du projet avec une adresse e-mail' });
      }
      const name = await projectName(req.params.id);
      const fullSubject = `${await mailSubjectPrefix(req.params.id)} ${subject}`;
      const mailboxId = req.session.user.id;
      const tracking = crypto.randomUUID();
      const sentAfter = new Date(Date.now() - 60000).toISOString();
      const html =
        `<div style="font-family:Inter,'Segoe UI',Arial,sans-serif;font-size:14px;line-height:1.6;color:#1f2937">` +
        `${escapeHtml(body).replace(/\n/g, '<br/>')}` +
        `<p style="color:#6b7280;font-size:12px;margin-top:24px">Projet « ${escapeHtml(name)} » — ` +
        `répondez à ce mail : votre réponse sera rangée dans les communications du projet.</p></div>`;
      // Envoi direct depuis la boîte de l'utilisateur (permission Mail.Send).
      try {
        await graph('POST', `/users/${encodeURIComponent(mailboxId)}/sendMail`, {
          message: {
            subject: fullSubject,
            body: { contentType: 'HTML', content: html },
            toRecipients: recipients.map((r) => ({ emailAddress: { address: r.email, name: r.display_name } })),
            internetMessageHeaders: [{ name: 'X-GestionIT-Ref', value: tracking }]
          },
          saveToSentItems: true
        });
      } catch (sendError) {
        if (sendError.status === 403) {
          return res.status(502).json({
            error:
              "Envoi impossible : Microsoft refuse que l'application envoie depuis votre boîte Outlook " +
              "(permission Mail.Send de l'application, ou restriction Exchange limitant l'application à certaines boîtes). " +
              "Transmettez ce message à l'administrateur Microsoft 365."
          });
        }
        throw sendError;
      }
      // Conversation du mail envoyé : nécessaire pour relever les réponses.
      let found = null;
      try {
        found = await findSentMessage(mailboxId, { tracking, subject: fullSubject, sentAfter }, { attempts: 4 });
      } catch (readError) {
        console.error('[Projets Groupe] Lecture des éléments envoyés impossible', readError.message || readError);
      }
      const saved = await pool.query(
        `INSERT INTO group_messages (project_id, direction, mailbox_account_id, conversation_id, internet_message_id,
                                     from_name, from_email, recipients, subject, body, tracking_ref)
         VALUES ($1, 'sent', $2, $3, $4, $5, $6, $7, $8, $9, $10)
         ON CONFLICT (internet_message_id) DO NOTHING RETURNING id`,
        [
          req.params.id, mailboxId, found?.conversationId || `pending:${tracking}`, found?.internetMessageId || null,
          req.session.user.displayName, req.session.user.email,
          JSON.stringify(recipients.map((r) => ({ name: r.display_name, email: r.email }))),
          fullSubject, body, tracking
        ]
      );
      res.status(201).json({ id: saved.rows[0]?.id || null, suiviReponses: Boolean(found) });
    } catch (error) {
      console.error('[Projets Groupe] Envoi de mail', error);
      res.status(500).json({ error: `Envoi impossible : ${error.message}` });
    }
  });

  app.post('/api/group-projects/:id/communications/sync', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id))) return;
      await syncMailReplies();
      res.json({ ok: true });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Réunions ----
  app.get('/api/group-projects/:id/meetings', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id))) return;
      const result = await pool.query(`${MEETINGS_SELECT} WHERE g.project_id = $1 ORDER BY g.start_at DESC`, [req.params.id]);
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  function readMeeting(body) {
    const meeting = {
      title: String(body.title || '').trim(),
      agenda: String(body.agenda || '').trim() || null,
      location: String(body.location || '').trim() || null,
      roomEmail: String(body.roomEmail || '').trim() || null,
      roomName: String(body.roomName || '').trim() || null,
      online: body.online !== false,
      start: body.start,
      end: body.end,
      attendeeIds: Array.isArray(body.attendeeIds) ? [...new Set(body.attendeeIds)] : []
    };
    if (!meeting.title) return { error: 'Titre de la réunion requis' };
    if (!isLocalDateTime(meeting.start) || !isLocalDateTime(meeting.end)) return { error: 'Date et heure invalides' };
    if (meeting.end <= meeting.start) return { error: 'La fin doit être après le début' };
    return { meeting };
  }

  app.post('/api/group-projects/:id/meetings', requireAuth, async (req, res) => {
    try {
      if (!(await requireMember(req, res, req.params.id))) return;
      const { meeting, error } = readMeeting(req.body);
      if (error) return res.status(400).json({ error });
      const members = await listMembers(req.params.id);
      const attendees = members.filter((m) => meeting.attendeeIds.includes(m.account_id) && m.account_id !== req.session.user.id);
      const project = { id: req.params.id, name: await projectName(req.params.id) };

      const saved = (
        await pool.query(
          `INSERT INTO group_meetings (project_id, title, agenda, location, online, start_at, end_at, organizer_account_id, attendee_ids,
                                       room_email, room_name)
           VALUES ($1, $2, $3, $4, $5, ($6::timestamp AT TIME ZONE 'Europe/Paris'), ($7::timestamp AT TIME ZONE 'Europe/Paris'), $8, $9, $10, $11)
           RETURNING id`,
          [req.params.id, meeting.title, meeting.agenda, meeting.roomEmail ? meeting.roomName : meeting.location, meeting.online,
            meeting.start, meeting.end, req.session.user.id, attendees.map((a) => a.account_id), meeting.roomEmail, meeting.roomName]
        )
      ).rows[0];

      // Invitation Outlook depuis le calendrier de l'organisateur.
      let outlookError = null;
      try {
        const event = await graph('POST', `/users/${encodeURIComponent(req.session.user.id)}/events`, outlookEventBody({ project, meeting, attendees }));
        await pool.query(`UPDATE group_meetings SET outlook_event_id = $1, online_meeting_url = $2 WHERE id = $3`, [
          event.id, event.onlineMeeting?.joinUrl || null, saved.id
        ]);
      } catch (graphError) {
        outlookError = graphError.message || String(graphError);
        await pool.query(`UPDATE group_meetings SET outlook_error = $1 WHERE id = $2`, [outlookError, saved.id]);
      }

      // Compte rendu prêt à remplir, reprenant l'invitation (ordre du jour).
      const forMinutes = await meetingForMinutes(saved.id);
      await pool.query(
        `INSERT INTO group_minutes (project_id, meeting_id, title, meeting_date, content, author_account_id, updated_by, is_draft)
         VALUES ($1, $2, $3, $4, $5, $6, $6, true)`,
        [req.params.id, saved.id, minutesTitle(meeting.title), forMinutes.day, minutesTemplate(forMinutes), req.session.user.id]
      );

      const when = `${meeting.start.slice(8, 10)}/${meeting.start.slice(5, 7)} à ${meeting.start.slice(11)}`;
      await notify({
        accountIds: attendees.map((a) => a.account_id),
        type: 'group_meeting',
        title: `Réunion : ${meeting.title} — ${when}`,
        body: `Projet ${project.name} — organisée par ${req.session.user.displayName}`,
        projectId: req.params.id
      });
      res.status(201).json({ id: saved.id, outlookError });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  async function loadMeeting(req, res) {
    const meeting = (await pool.query(`SELECT * FROM group_meetings WHERE id = $1`, [req.params.meetingId])).rows[0];
    if (!meeting) {
      res.status(404).json({ error: 'Réunion introuvable' });
      return null;
    }
    const role = await requireMember(req, res, meeting.project_id);
    if (!role) return null;
    if (role !== 'responsable' && meeting.organizer_account_id !== req.session.user.id) {
      res.status(403).json({ error: "Seul l'organisateur ou un responsable peut modifier cette réunion" });
      return null;
    }
    return meeting;
  }

  app.put('/api/group-projects/meetings/:meetingId', requireAuth, async (req, res) => {
    try {
      const existing = await loadMeeting(req, res);
      if (!existing) return;
      const { meeting, error } = readMeeting(req.body);
      if (error) return res.status(400).json({ error });
      const members = await listMembers(existing.project_id);
      const attendees = members.filter(
        (m) => meeting.attendeeIds.includes(m.account_id) && m.account_id !== existing.organizer_account_id
      );
      const templateBefore = minutesTemplate(await meetingForMinutes(existing.id));
      await pool.query(
        `UPDATE group_meetings SET title = $1, agenda = $2, location = $3, online = $4,
           start_at = ($5::timestamp AT TIME ZONE 'Europe/Paris'), end_at = ($6::timestamp AT TIME ZONE 'Europe/Paris'),
           attendee_ids = $7, minutes_reminders = CASE WHEN ($6::timestamp AT TIME ZONE 'Europe/Paris') <> end_at THEN 0 ELSE minutes_reminders END,
           room_email = $9, room_name = $10, updated_at = now()
         WHERE id = $8`,
        [meeting.title, meeting.agenda, meeting.roomEmail ? meeting.roomName : meeting.location, meeting.online, meeting.start, meeting.end,
          attendees.map((a) => a.account_id), existing.id, meeting.roomEmail, meeting.roomName]
      );
      // Brouillon de compte rendu pas encore retouché : mis à jour avec la réunion.
      const forMinutes = await meetingForMinutes(existing.id);
      await pool.query(
        `UPDATE group_minutes SET
           content = CASE WHEN content = $1 THEN $2 ELSE content END,
           title = CASE WHEN title = $3 THEN $4 ELSE title END,
           meeting_date = $5
         WHERE meeting_id = $6 AND is_draft`,
        [templateBefore, minutesTemplate(forMinutes), minutesTitle(existing.title), minutesTitle(meeting.title), forMinutes.day, existing.id]
      );

      let outlookError = null;
      try {
        const project = { id: existing.project_id, name: await projectName(existing.project_id) };
        const payload = outlookEventBody({ project, meeting, attendees });
        if (existing.outlook_event_id) {
          await graph('PATCH', `/users/${encodeURIComponent(existing.organizer_account_id)}/events/${encodeURIComponent(existing.outlook_event_id)}`, payload);
        } else {
          const event = await graph('POST', `/users/${encodeURIComponent(existing.organizer_account_id)}/events`, payload);
          await pool.query(`UPDATE group_meetings SET outlook_event_id = $1, online_meeting_url = $2 WHERE id = $3`, [
            event.id, event.onlineMeeting?.joinUrl || null, existing.id
          ]);
        }
        await pool.query(`UPDATE group_meetings SET outlook_error = NULL WHERE id = $1`, [existing.id]);
      } catch (graphError) {
        outlookError = graphError.message || String(graphError);
        await pool.query(`UPDATE group_meetings SET outlook_error = $1 WHERE id = $2`, [outlookError, existing.id]);
      }
      await notify({
        accountIds: attendees.map((a) => a.account_id),
        type: 'group_meeting',
        title: `Réunion modifiée : ${meeting.title} — ${meeting.start.slice(8, 10)}/${meeting.start.slice(5, 7)} à ${meeting.start.slice(11)}`,
        body: `Projet ${await projectName(existing.project_id)}`,
        projectId: existing.project_id,
        exceptId: req.session.user.id
      });
      res.json({ ok: true, outlookError });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Annule la réunion dans Outlook (les invités sont prévenus par Outlook et
  // dans l'application) et retire le brouillon de compte rendu non retouché.
  async function cancelEverywhere(existing, actor) {
    let outlookError = null;
    if (existing.status === 'planned' && existing.outlook_event_id && new Date(existing.end_at) > new Date()) {
      try {
        await graph('POST', `/users/${encodeURIComponent(existing.organizer_account_id)}/events/${encodeURIComponent(existing.outlook_event_id)}/cancel`, {
          comment: `Réunion annulée par ${actor.displayName}`
        });
      } catch (graphError) {
        outlookError = graphError.message || String(graphError);
      }
    }
    const untouched = minutesTemplate(await meetingForMinutes(existing.id));
    await pool.query(`DELETE FROM group_minutes WHERE meeting_id = $1 AND is_draft AND content = $2`, [existing.id, untouched]);
    if (existing.status === 'planned' && new Date(existing.end_at) > new Date()) {
      await notify({
        accountIds: [...existing.attendee_ids, existing.organizer_account_id],
        type: 'group_meeting',
        title: `Réunion annulée : ${existing.title}`,
        body: `Projet ${await projectName(existing.project_id)}`,
        projectId: existing.project_id,
        exceptId: actor.id
      });
    }
    return outlookError;
  }

  // Annulation : la réunion reste visible (barrée) dans le projet.
  app.delete('/api/group-projects/meetings/:meetingId', requireAuth, async (req, res) => {
    try {
      const existing = await loadMeeting(req, res);
      if (!existing) return;
      const outlookError = await cancelEverywhere(existing, req.session.user);
      await pool.query(`UPDATE group_meetings SET status = 'cancelled', updated_at = now() WHERE id = $1`, [existing.id]);
      res.json({ ok: true, outlookError });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Suppression : la réunion disparaît du projet (annulée dans Outlook si elle
  // est à venir). Un compte rendu déjà rédigé est conservé, sans lien.
  app.post('/api/group-projects/meetings/:meetingId/delete', requireAuth, async (req, res) => {
    try {
      const existing = await loadMeeting(req, res);
      if (!existing) return;
      const outlookError = await cancelEverywhere(existing, req.session.user);
      await pool.query(`DELETE FROM group_meetings WHERE id = $1`, [existing.id]);
      res.json({ ok: true, outlookError });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  return schemaReady;
}

// Exposés pour les tests.
export { notifyOverdueTasks, remindMissingMinutes, syncMailReplies, TASK_STATUS_FR };
