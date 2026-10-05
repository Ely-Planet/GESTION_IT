import { pool } from './db.mjs';
import { sendMailWithAttachments } from './graphMail.mjs';
import { ensureProjectsSchema } from './projectsSchema.mjs';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import fsp from 'fs/promises';
import crypto from 'crypto';


// === SYNCHRONISATION ENTRA DES MEMBRES DU SERVICE IT ===
function getFirstEnvValue(...names) {
  for (const name of names) {
    const value = process.env[name];
    if (value && String(value).trim()) {
      return String(value).trim();
    }
  }
  return null;
}

async function getProjectsGraphAccessToken() {
  const tenantId = getFirstEnvValue(
    'MICROSOFT_TENANT_ID',
    'AZURE_TENANT_ID',
    'TENANT_ID'
  );

  const clientId = getFirstEnvValue(
    'MICROSOFT_CLIENT_ID',
    'AZURE_CLIENT_ID',
    'CLIENT_ID'
  );

  const clientSecret = getFirstEnvValue(
    'MICROSOFT_CLIENT_SECRET',
    'AZURE_CLIENT_SECRET',
    'CLIENT_SECRET'
  );

  if (!tenantId || !clientId || !clientSecret) {
    throw new Error(
      'Configuration Graph incomplète : tenant ID, client ID ou secret client absent'
    );
  }

  const body = new URLSearchParams({
    client_id: clientId,
    client_secret: clientSecret,
    scope: 'https://graph.microsoft.com/.default',
    grant_type: 'client_credentials'
  });

  const response = await fetch(
    `https://login.microsoftonline.com/${encodeURIComponent(tenantId)}/oauth2/v2.0/token`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body
    }
  );

  if (!response.ok) {
    const details = await response.text();
    throw new Error(
      `Impossible d'obtenir le jeton Microsoft Graph (${response.status}) : ${details}`
    );
  }

  const token = await response.json();

  if (!token.access_token) {
    throw new Error("Microsoft Graph n'a retourné aucun jeton d'accès");
  }

  return token.access_token;
}

async function fetchAllItGroupMembersFromGraph(accessToken, groupId) {
  const members = [];
  let url =
    `https://graph.microsoft.com/v1.0/groups/${encodeURIComponent(groupId)}` +
    `/transitiveMembers/microsoft.graph.user` +
    `?$select=id,displayName,mail,userPrincipalName,accountEnabled&$top=999`;

  while (url) {
    const response = await fetch(url, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
        Accept: 'application/json'
      }
    });

    if (!response.ok) {
      const details = await response.text();
      throw new Error(
        `Lecture du groupe Service Informatique impossible (${response.status}) : ${details}`
      );
    }

    const page = await response.json();

    if (Array.isArray(page.value)) {
      members.push(...page.value);
    }

    url = page['@odata.nextLink'] || null;
  }

  return members;
}

async function syncItAccountsFromEntra() {
  const groupId = getFirstEnvValue(
    'MICROSOFT_IT_GROUP_ID',
    'MICROSOFT_SERVICE_IT_GROUP_ID',
    'SERVICE_IT_GROUP_ID'
  );

  if (!groupId) {
    throw new Error(
      'Variable du groupe IT absente. Attendu : MICROSOFT_IT_GROUP_ID'
    );
  }

  const accessToken = await getProjectsGraphAccessToken();
  const members = await fetchAllItGroupMembersFromGraph(accessToken, groupId);

  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    for (const member of members) {
      if (!member?.id || member.accountEnabled === false) {
        continue;
      }

      const email = member.mail || member.userPrincipalName || null;
      const displayName =
        member.displayName ||
        member.userPrincipalName ||
        member.mail ||
        member.id;

      await client.query(
        `
        INSERT INTO app_accounts (
          id,
          email,
          display_name,
          is_it,
          is_it_manager,
          is_rh,
          is_manager,
          is_director
        )
        VALUES ($1, $2, $3, true, false, false, false, false)
        ON CONFLICT (id) DO UPDATE SET
          email = EXCLUDED.email,
          display_name = EXCLUDED.display_name,
          is_it = true
        `,
        [member.id, email, displayName]
      );
    }

    // Les personnes sorties du groupe Service Informatique ne sont plus
    // comptées comme membres IT (les managers IT gardent leur statut).
    const activeIds = members
      .filter((member) => member?.id && member.accountEnabled !== false)
      .map((member) => member.id);
    if (activeIds.length > 0) {
      await client.query(
        `UPDATE app_accounts SET is_it = false
         WHERE is_it = true AND is_it_manager = false AND NOT (id = ANY($1::uuid[]))`,
        [activeIds]
      );
    }

    await client.query('COMMIT');

    console.log(
      `[Projets IT] Synchronisation Entra réussie : ${members.length} membre(s) reçu(s)`
    );

    return members.length;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}


const PROJECTS_DIR = path.join(process.cwd(), 'storage', 'projects');

async function ensureProjectsDir() {
  await fsp.mkdir(PROJECTS_DIR, { recursive: true });
}

const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, PROJECTS_DIR);
  },
  filename(req, file, cb) {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, `${unique}-${file.originalname}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 25 * 1024 * 1024 }
});

// ---------------------------------------------------------------------
// Rôles du module, dérivés des groupes Microsoft déjà présents en session
// (voir /auth/callback dans index.mjs) :
//   - isITManager (groupe "🔐 Manager Service Informatique") -> manager
//   - isIT (sans isITManager)                                 -> dev
//   - isDirector                                               -> directeur (lecture seule)
//   - tout le reste (isRH, isManager RH, ou aucun groupe)      -> client interne
// ---------------------------------------------------------------------

function isAuthenticated(req) {
  return Boolean(req.session && req.session.user);
}

function getModuleRole(user) {
  if (!user) return null;
  if (user.isITManager) return 'manager';
  if (user.isIT) return 'dev';
  if (user.isDirector) return 'directeur';
  return 'client';
}

function requireAuth(req, res, next) {
  if (!isAuthenticated(req)) {
    return res.status(401).json({ error: 'Non authentifié' });
  }
  next();
}

function requireRole(...roles) {
  return (req, res, next) => {
    const role = getModuleRole(req.session.user);
    if (!roles.includes(role)) {
      return res.status(403).json({ error: 'Accès refusé pour ce rôle' });
    }
    next();
  };
}

async function isAssignedToProject(accountId, projectId) {
  const result = await pool.query(
    `SELECT 1 FROM project_assignments WHERE project_id = $1 AND account_id = $2`,
    [projectId, accountId]
  );
  return result.rowCount > 0;
}

async function isChefDeProjet(accountId, projectId) {
  const result = await pool.query(
    `SELECT 1 FROM project_assignments WHERE project_id = $1 AND account_id = $2 AND project_role = 'chef_de_projet'`,
    [projectId, accountId]
  );
  return result.rowCount > 0;
}

function completionRate(tasks) {
  if (!tasks.length) return 0;
  const done = tasks.filter((t) => t.status === 'done').length;
  return Math.round((done / tasks.length) * 100);
}

async function notifyClient({ email, subject, html }) {
  try {
    await sendMailWithAttachments({ to: email, subject, html });
    return true;
  } catch (err) {
    console.error('[PROJECTS] Échec envoi e-mail client', err.message || err);
    return false;
  }
}


// Demandes client avec leurs pièces jointes et l'avancement de la tâche créée.
const CLIENT_REQUESTS_SELECT = `
  SELECT r.*, c.display_name AS client_name, c.email AS client_email,
         t.status AS task_status,
         (SELECT COALESCE(json_agg(json_build_object('id', f.id, 'filename', f.filename) ORDER BY f.created_at), '[]'::json)
          FROM project_files f WHERE f.client_request_id = r.id) AS files
  FROM project_client_requests r
  JOIN app_accounts c ON c.id = r.client_account_id
  LEFT JOIN project_tasks t ON t.id = r.task_id
`;

// === NOTIFICATIONS (page d'accueil) ET MAILS CLIENT ===
function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function projectLink(projectId) {
  const base = String(process.env.APP_URL || '').replace(/\/+$/, '');
  return `${base}/?projet=${encodeURIComponent(projectId)}`;
}

// Charte de l'application (tailwind.config.js) : rose Elyade 600 #ca0088,
// police Inter, boutons arrondis 8px (.btn-primary).
const MAIL_FONT = "font-family:Inter,'Segoe UI',Arial,sans-serif";

function clientMailHtml({ name, paragraphs, projectId, linkLabel = 'Ouvrir mon projet' }) {
  return [
    `<div style="${MAIL_FONT};font-size:14px;line-height:1.6;color:#1f2937">`,
    `<p>Bonjour ${escapeHtml(name)},</p>`,
    ...paragraphs.map((paragraph) => `<p>${paragraph}</p>`),
    projectId
      ? `<p style="margin:24px 0"><a href="${projectLink(projectId)}" style="display:inline-block;padding:10px 20px;background:#ca0088;color:#ffffff;border-radius:8px;${MAIL_FONT};font-size:14px;font-weight:600;text-decoration:none">${escapeHtml(linkLabel)}</a></p>`
      : '',
    `<p>L'équipe informatique</p>`,
    '</div>'
  ].join('');
}

async function createNotification({ accountId, type, title, body = null, projectId = null, taskId = null }) {
  if (!accountId) return;
  try {
    await pool.query(
      `INSERT INTO user_notifications (account_id, type, title, body, project_id, task_id)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [accountId, type, title, body, projectId, taskId]
    );
  } catch (error) {
    console.error('[Projets IT] Notification impossible', error.message || error);
  }
}

async function notifyTaskAssignee(task, actorId) {
  if (!task?.assignee_account_id || task.assignee_account_id === actorId) return;
  const projectResult = await pool.query(`SELECT name FROM projects WHERE id = $1`, [task.project_id]);
  await createNotification({
    accountId: task.assignee_account_id,
    type: 'task_assigned',
    title: `Nouvelle tâche : ${task.title}`,
    body: `Projet ${projectResult.rows[0]?.name || ''}`.trim(),
    projectId: task.project_id,
    taskId: task.id
  });
}

async function notifyProjectLeads(projectId, { type, title, body }) {
  const leads = await pool.query(
    `SELECT account_id FROM project_assignments WHERE project_id = $1 AND project_role = 'chef_de_projet'`,
    [projectId]
  );
  // Sans chef de projet, ce sont les managers IT qui sont prévenus.
  const recipients = leads.rowCount
    ? leads.rows.map((row) => row.account_id)
    : (await pool.query(`SELECT id FROM app_accounts WHERE is_it_manager = true`)).rows.map((row) => row.id);
  for (const accountId of recipients) {
    await createNotification({ accountId, type, title, body, projectId });
  }
}

// Mail au client du projet quand une tâche passe en "In progress" ou "Done".
// Un seul mail par statut et par tâche, même si l'appli et la synchro
// GitHub voient le changement en même temps.
async function handleTaskStatusChange(task, previousStatus) {
  if (!task || task.status === previousStatus) return;
  if (task.status !== 'in_progress' && task.status !== 'done') return;

  try {
    const projectResult = await pool.query(
      `SELECT p.id, p.name, c.email AS client_email, c.display_name AS client_name
       FROM projects p JOIN app_accounts c ON c.id = p.client_account_id
       WHERE p.id = $1`,
      [task.project_id]
    );
    const project = projectResult.rows[0];
    if (!project?.client_email) return;

    const column = task.status === 'done' ? 'client_notified_done_at' : 'client_notified_in_progress_at';
    const claim = await pool.query(
      `UPDATE project_tasks SET ${column} = now() WHERE id = $1 AND ${column} IS NULL RETURNING id`,
      [task.id]
    );
    if (claim.rowCount === 0) return;

    const title = escapeHtml(task.title);
    const projectName = escapeHtml(project.name);
    const isDone = task.status === 'done';
    await notifyClient({
      email: project.client_email,
      subject: isDone
        ? `[${project.name}] Tâche terminée : ${task.title}`
        : `[${project.name}] Nous travaillons sur : ${task.title}`,
      html: clientMailHtml({
        name: project.client_name,
        paragraphs: isDone
          ? [`La tâche <strong>« ${title} »</strong> du projet <strong>${projectName}</strong> est terminée.`]
          : [`L'équipe informatique a commencé à travailler sur la tâche <strong>« ${title} »</strong> du projet <strong>${projectName}</strong>.`],
        projectId: project.id
      })
    });
  } catch (error) {
    console.error('[Projets IT] Mail de statut client impossible', error.message || error);
  }
}

// Mail au client avec le lien de son projet, pour qu'il puisse y déposer ses demandes.
async function sendClientProjectLink(projectId) {
  const result = await pool.query(
    `SELECT p.id, p.name, c.email AS client_email, c.display_name AS client_name
     FROM projects p JOIN app_accounts c ON c.id = p.client_account_id
     WHERE p.id = $1`,
    [projectId]
  );
  const project = result.rows[0];
  if (!project?.client_email) return false;
  return notifyClient({
    email: project.client_email,
    subject: `Votre projet "${project.name}" : déposez vos demandes`,
    html: clientMailHtml({
      name: project.client_name,
      paragraphs: [
        `Vous êtes désormais le client du projet <strong>${escapeHtml(project.name)}</strong> dans l'application de gestion IT.`,
        `Depuis le lien ci-dessous, vous pouvez rédiger vos demandes (avec pièces jointes si besoin) et suivre leur avancement. Connectez-vous avec votre compte Microsoft Elyade.`
      ],
      projectId: project.id,
      linkLabel: 'Accéder au projet et déposer une demande'
    })
  });
}

async function loadFileWithProject(fileId) {
  const result = await pool.query(
    `SELECT f.*, COALESCE(f.project_id, r.project_id, m.project_id, t.project_id) AS resolved_project_id
     FROM project_files f
     LEFT JOIN project_client_requests r ON r.id = f.client_request_id
     LEFT JOIN project_messages m ON m.id = f.message_id
     LEFT JOIN project_tasks t ON t.id = f.task_id
     WHERE f.id = $1`,
    [fileId]
  );
  return result.rows[0] || null;
}

async function canAccessProject(user, projectId) {
  if (!projectId) return false;
  const role = getModuleRole(user);
  if (role === 'manager' || role === 'directeur') return true;
  if (role === 'dev' && (await isAssignedToProject(user.id, projectId))) return true;
  const result = await pool.query(`SELECT 1 FROM projects WHERE id = $1 AND client_account_id = $2`, [projectId, user.id]);
  return result.rowCount > 0;
}

async function removeUploadedFiles(files) {
  for (const file of files || []) {
    await fsp.unlink(file.path).catch(() => {});
  }
}

// === SYNCHRONISATION AVEC GITHUB PROJECTS (V2) ===
// 1 GitHub Project = 1 projet GESTION_IT, chaque carte (issue ou brouillon)
// du tableau = 1 tâche. Les dépôts sans tableau ne créent plus de projet.
function parseGitHubRepositoryUrl(value) {
  if (!value) return null;
  try {
    const url = new URL(String(value).trim());
    if (!['github.com', 'www.github.com'].includes(url.hostname.toLowerCase())) return null;
    const parts = url.pathname.replace(/^\/+|\/+$/g, '').split('/');
    if (parts.length < 2) return null;
    return { owner: parts[0], repo: parts[1].replace(/\.git$/i, '') };
  } catch {
    return null;
  }
}

const GITHUB_NOTE_SEPARATOR = '\n\n---\n_GESTION_IT : ';

// Retire de la description d'une carte GitHub les ajouts de GESTION_IT :
// la note de pièces jointes et l'ancien pied "Projet GESTION_IT : …".
function cleanGitHubBody(body) {
  if (!body) return null;
  let text = String(body);
  const noteIndex = text.indexOf(GITHUB_NOTE_SEPARATOR.trimStart());
  if (noteIndex !== -1) text = text.slice(0, noteIndex);
  text = text.replace(/\s*Projet GESTION_IT : [^\n]*\nIdentifiant de tâche : [\s\S]*$/, '');
  return text.trim() || null;
}

function parseGitHubIssueUrl(value) {
  const match = String(value || '').match(/^https:\/\/github\.com\/([^/]+)\/([^/]+)\/issues\/(\d+)/i);
  if (!match) return null;
  return { owner: match[1], repo: match[2], number: match[3] };
}

async function githubRequest(pathname, method = 'GET', body = undefined) {
  const token = process.env.GITHUB_TOKEN;
  if (!token) throw new Error('GITHUB_TOKEN absent');
  const response = await fetch(`https://api.github.com${pathname}`, {
    method,
    headers: {
      Accept: 'application/vnd.github+json',
      Authorization: `Bearer ${token}`,
      'X-GitHub-Api-Version': '2022-11-28',
      'User-Agent': 'ELYade-GESTION-IT'
    },
    body: body === undefined ? undefined : JSON.stringify(body)
  });
  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`GitHub ${response.status}: ${detail}`);
  }
  if (response.status === 204) return null;
  return response.json();
}

async function githubRequestAll(pathname) {
  const rows = [];
  let page = 1;
  while (true) {
    const separator = pathname.includes('?') ? '&' : '?';
    const batch = await githubRequest(`${pathname}${separator}per_page=100&page=${page}`);
    if (!Array.isArray(batch)) throw new Error('Reponse GitHub inattendue');
    rows.push(...batch);
    if (batch.length < 100) break;
    page += 1;
  }
  return rows;
}

async function syncGitHubIssueState(task, status) {
  const issue = parseGitHubIssueUrl(task.github_issue_url);
  if (!issue || status === undefined || status === null) return;
  await githubRequest(
    `/repos/${encodeURIComponent(issue.owner)}/${encodeURIComponent(issue.repo)}/issues/${issue.number}`,
    'PATCH',
    { state: status === 'done' ? 'closed' : 'open' }
  );
}

const PROJECT_V2_STATUS_SLUGS = {
  'backlog': 'backlog',
  'todo': 'backlog',
  'ready': 'ready',
  'in progress': 'in_progress',
  'in_progress': 'in_progress',
  'in review': 'in_review',
  'in_review': 'in_review',
  'done': 'done'
};

function normalizeProjectV2Status(value) {
  return PROJECT_V2_STATUS_SLUGS[String(value || '').trim().toLowerCase()] || 'backlog';
}

function projectV2StatusLabel(slug) {
  return {
    backlog: 'Backlog',
    ready: 'Ready',
    in_progress: 'In progress',
    in_review: 'In review',
    done: 'Done'
  }[slug] || 'Backlog';
}

async function githubGraphQL(query, variables = {}) {
  const token = process.env.GITHUB_TOKEN;
  if (!token) throw new Error('GITHUB_TOKEN absent');
  const response = await fetch('https://api.github.com/graphql', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'User-Agent': 'ELYade-GESTION-IT'
    },
    body: JSON.stringify({ query, variables })
  });
  const payload = await response.json();
  if (!response.ok || payload.errors) {
    throw new Error(`GitHub GraphQL: ${JSON.stringify(payload.errors || payload)}`);
  }
  return payload.data;
}

const BOARD_FIELDS = `
  id
  title
  shortDescription
  url
  closed
  repositories(first: 5) { nodes { url } }
`;

// Tous les tableaux du propriétaire (compte utilisateur ou organisation),
// avec pagination : l'ancienne requête s'arrêtait à 50 tableaux.
async function loadGitHubBoards() {
  const login = process.env.GITHUB_PROJECT_OWNER || 'Ely-Planet';
  let lastError = null;
  for (const ownerType of ['user', 'organization']) {
    try {
      const boards = [];
      let cursor = null;
      do {
        const data = await githubGraphQL(
          `query GestionItBoards($login: String!, $cursor: String) {
            owner: ${ownerType}(login: $login) {
              projectsV2(first: 20, after: $cursor) {
                pageInfo { hasNextPage endCursor }
                nodes { ${BOARD_FIELDS} }
              }
            }
          }`,
          { login, cursor }
        );
        const page = data.owner?.projectsV2;
        if (!page) break;
        boards.push(...(page.nodes || []).filter(Boolean));
        cursor = page.pageInfo.hasNextPage ? page.pageInfo.endCursor : null;
      } while (cursor);
      return boards;
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError || new Error(`Aucun tableau GitHub Projects trouvé pour ${login}`);
}

// Toutes les cartes d'un tableau, avec pagination : l'ancienne requête
// ignorait silencieusement tout ce qui dépassait 100 cartes.
async function loadGitHubBoardItems(boardId) {
  const items = [];
  let cursor = null;
  do {
    const data = await githubGraphQL(
      `query GestionItBoardItems($id: ID!, $cursor: String) {
        node(id: $id) {
          ... on ProjectV2 {
            items(first: 100, after: $cursor) {
              pageInfo { hasNextPage endCursor }
              nodes {
                id
                type
                status: fieldValueByName(name: "Status") {
                  ... on ProjectV2ItemFieldSingleSelectValue { name updatedAt }
                }
                content {
                  ... on Issue { url title body comments { totalCount } }
                  ... on DraftIssue { title body }
                }
              }
            }
          }
        }
      }`,
      { id: boardId, cursor }
    );
    const page = data.node?.items;
    if (!page) break;
    items.push(...(page.nodes || []).filter(Boolean));
    cursor = page.pageInfo.hasNextPage ? page.pageInfo.endCursor : null;
  } while (cursor);
  return items;
}

async function upsertProjectFromBoard(board) {
  const repoUrls = (board.repositories?.nodes || []).map((repo) => repo.url).filter(Boolean);
  const singleRepoUrl = repoUrls.length === 1 ? repoUrls[0] : null;

  let existing = await pool.query(`SELECT * FROM projects WHERE github_project_id = $1`, [board.id]);

  // Reprise d'un ancien projet créé automatiquement pour le dépôt du tableau :
  // il garde son équipe, ses demandes et ses échanges.
  if (existing.rowCount === 0 && singleRepoUrl) {
    existing = await pool.query(
      `SELECT * FROM projects
       WHERE github_project_id IS NULL AND created_by IS NULL AND github_repo_url = $1
       ORDER BY created_at
       LIMIT 1`,
      [singleRepoUrl]
    );
  }

  if (existing.rowCount === 0) {
    const inserted = await pool.query(
      `INSERT INTO projects
         (name, description, type, status, github_project_id, github_project_url, github_repo_url, project_state, closed_at)
       VALUES ($1, $2, 'dev', 'en_cours', $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        board.title,
        board.shortDescription || null,
        board.id,
        board.url,
        singleRepoUrl,
        board.closed ? 'closed' : 'new',
        board.closed ? new Date() : null
      ]
    );
    return inserted.rows[0];
  }

  const updated = await pool.query(
    `UPDATE projects SET
       name = $1,
       description = COALESCE(NULLIF($2, ''), description),
       github_project_id = $3,
       github_project_url = $4,
       github_repo_url = COALESCE(github_repo_url, $5),
       status = CASE WHEN status = 'archive' THEN 'en_cours' ELSE status END,
       project_state = CASE WHEN $6::boolean THEN 'closed' ELSE project_state END,
       closed_at = CASE WHEN $6::boolean THEN COALESCE(closed_at, now()) ELSE closed_at END,
       updated_at = CASE
         WHEN name IS DISTINCT FROM $1 OR github_project_id IS DISTINCT FROM $3 THEN now()
         ELSE updated_at
       END
     WHERE id = $7
     RETURNING *`,
    [board.title, board.shortDescription || '', board.id, board.url, singleRepoUrl, Boolean(board.closed), existing.rows[0].id]
  );
  return updated.rows[0];
}

async function upsertTaskFromBoardItem(projectId, item) {
  if (item.type !== 'ISSUE' && item.type !== 'DRAFT_ISSUE') return null;
  const content = item.content || {};
  const issueUrl = item.type === 'ISSUE' ? content.url || null : null;
  const title = content.title || '(sans titre)';
  const description = cleanGitHubBody(content.body);
  const githubStatus = item.status?.name ? normalizeProjectV2Status(item.status.name) : null;
  const githubStatusAt = item.status?.updatedAt ? new Date(item.status.updatedAt) : null;
  const commentCount = content.comments?.totalCount || 0;

  const existingResult = await pool.query(
    `SELECT t.*, p.created_by AS project_created_by
     FROM project_tasks t
     JOIN projects p ON p.id = t.project_id
     WHERE t.github_item_id = $1
        OR ($2::text IS NOT NULL AND t.github_issue_url = $2 AND t.github_item_id IS NULL)
     ORDER BY (t.github_item_id = $1) DESC NULLS LAST
     LIMIT 1`,
    [item.id, issueUrl]
  );

  if (existingResult.rowCount === 0) {
    const status = githubStatus || 'backlog';
    // Carte déjà avancée à son arrivée : pas de mail client rétroactif.
    await pool.query(
      `INSERT INTO project_tasks
         (project_id, title, description, status, origin, github_issue_url, github_item_id,
          github_comment_count, status_updated_at, completed_at,
          client_notified_in_progress_at, client_notified_done_at)
       VALUES ($1, $2, $3, $4, 'manuelle', $5, $6, $7, $8,
               CASE WHEN $4 = 'done' THEN COALESCE($8, now()) END,
               CASE WHEN $4 IN ('in_progress', 'in_review', 'done') THEN now() END,
               CASE WHEN $4 = 'done' THEN now() END)`,
      [projectId, title, description, status, issueUrl, item.id, commentCount, githubStatusAt]
    );
    return 'created';
  }

  const task = existingResult.rows[0];
  // Les tâches d'un projet créé à la main restent dans ce projet.
  const targetProjectId = task.project_created_by ? task.project_id : projectId;
  const githubIsNewer =
    githubStatus &&
    githubStatus !== task.status &&
    githubStatusAt &&
    (!task.status_updated_at || githubStatusAt > new Date(task.status_updated_at));
  const nextStatus = githubIsNewer ? githubStatus : task.status;

  const unchanged =
    task.project_id === targetProjectId &&
    task.title === title &&
    (task.description || null) === description &&
    task.status === nextStatus &&
    task.github_item_id === item.id &&
    Number(task.github_comment_count || 0) === commentCount;
  if (unchanged) return null;

  const result = await pool.query(
    `UPDATE project_tasks SET
       project_id = $1,
       title = $2,
       description = $3,
       status = $4,
       completed_at = CASE
         WHEN $4 = 'done' AND status <> 'done' THEN COALESCE($5, now())
         WHEN $4 <> 'done' THEN NULL
         ELSE completed_at
       END,
       status_updated_at = CASE WHEN status IS DISTINCT FROM $4 THEN $5 ELSE status_updated_at END,
       github_item_id = $6,
       github_comment_count = $7,
       updated_at = now()
     WHERE id = $8
     RETURNING *`,
    [targetProjectId, title, description, nextStatus, githubStatusAt, item.id, commentCount, task.id]
  );

  if (nextStatus !== task.status) {
    await handleTaskStatusChange(result.rows[0], task.status);
  }
  return 'updated';
}

let githubSyncRunning = false;

async function syncGitHubBoards() {
  if (!process.env.GITHUB_TOKEN) throw new Error('GITHUB_TOKEN absent');
  if (githubSyncRunning) return { skipped: true };
  githubSyncRunning = true;
  try {
    const boards = await loadGitHubBoards();
    let tasksCreated = 0;
    let tasksUpdated = 0;

    for (const board of boards) {
      const project = await upsertProjectFromBoard(board);
      const items = await loadGitHubBoardItems(board.id);
      for (const item of items) {
        const outcome = await upsertTaskFromBoardItem(project.id, item);
        if (outcome === 'created') tasksCreated += 1;
        if (outcome === 'updated') tasksUpdated += 1;
      }
    }

    // Anciens projets créés automatiquement par dépôt, sans tableau GitHub :
    // masqués (archivés), sauf s'ils ont un client.
    let projectsArchived = 0;
    if (boards.length > 0) {
      const archived = await pool.query(
        `UPDATE projects SET status = 'archive', updated_at = now()
         WHERE created_by IS NULL
           AND github_project_id IS NULL
           AND client_account_id IS NULL
           AND status <> 'archive'`
      );
      projectsArchived = archived.rowCount;
    }

    const summary = { boards: boards.length, tasksCreated, tasksUpdated, projectsArchived };
    if (tasksCreated || tasksUpdated || projectsArchived) console.log('[GitHub Sync]', summary);
    return summary;
  } finally {
    githubSyncRunning = false;
  }
}

async function updateGitHubProjectV2Status(task, status) {
  if (!task.github_item_id) return;
  const data = await githubGraphQL(
    `query GestionItItemStatusField($itemId: ID!) {
      node(id: $itemId) {
        ... on ProjectV2Item {
          project {
            id
            field(name: "Status") {
              ... on ProjectV2SingleSelectField { id options { id name } }
            }
          }
        }
      }
    }`,
    { itemId: task.github_item_id }
  );
  const board = data.node?.project;
  const option = (board?.field?.options || []).find(
    (entry) => normalizeProjectV2Status(entry.name) === status
  );
  if (!board?.field || !option) {
    throw new Error(`Statut GitHub ProjectV2 introuvable : ${projectV2StatusLabel(status)}`);
  }
  await githubGraphQL(
    `mutation UpdateGestionItStatus($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
      updateProjectV2ItemFieldValue(input: {
        projectId: $projectId,
        itemId: $itemId,
        fieldId: $fieldId,
        value: { singleSelectOptionId: $optionId }
      }) { projectV2Item { id } }
    }`,
    { projectId: board.id, itemId: task.github_item_id, fieldId: board.field.id, optionId: option.id }
  );
}

// Nouvelle tâche GESTION_IT -> issue dans le dépôt du projet (s'il y en a un),
// ajoutée au tableau GitHub du projet ; sinon carte brouillon dans le tableau.
async function createGitHubItemForTask(task, { attachmentsCount = 0 } = {}) {
  const projectResult = await pool.query(
    `SELECT name, github_repo_url, github_project_id FROM projects WHERE id = $1`,
    [task.project_id]
  );
  const project = projectResult.rows[0];
  if (!project) return null;

  // La carte GitHub reprend la description telle quelle : la synchro la
  // recopie dans GESTION_IT, tout ajout technique finirait dans la description.
  let body = task.description || '';
  if (attachmentsCount) body += `${GITHUB_NOTE_SEPARATOR}${attachmentsCount} pièce(s) jointe(s) dans GESTION_IT_`;

  let issue = null;
  const repository = parseGitHubRepositoryUrl(project.github_repo_url);
  if (repository) {
    issue = await githubRequest(
      `/repos/${encodeURIComponent(repository.owner)}/${encodeURIComponent(repository.repo)}/issues`,
      'POST',
      { title: task.title, body }
    );
  }

  let itemId = null;
  if (project.github_project_id) {
    if (issue) {
      const data = await githubGraphQL(
        `mutation AddGestionItIssue($projectId: ID!, $contentId: ID!) {
          addProjectV2ItemById(input: { projectId: $projectId, contentId: $contentId }) { item { id } }
        }`,
        { projectId: project.github_project_id, contentId: issue.node_id }
      );
      itemId = data.addProjectV2ItemById?.item?.id || null;
    } else {
      const data = await githubGraphQL(
        `mutation AddGestionItDraft($projectId: ID!, $title: String!, $body: String) {
          addProjectV2DraftIssue(input: { projectId: $projectId, title: $title, body: $body }) { projectItem { id } }
        }`,
        { projectId: project.github_project_id, title: task.title, body }
      );
      itemId = data.addProjectV2DraftIssue?.projectItem?.id || null;
    }
  }

  if (!issue && !itemId) return null;

  const updated = await pool.query(
    `UPDATE project_tasks SET github_issue_url = $1, github_item_id = $2, updated_at = now()
     WHERE id = $3 RETURNING *`,
    [issue?.html_url || null, itemId, task.id]
  );
  const linkedTask = updated.rows[0];
  if (itemId) await updateGitHubProjectV2Status(linkedTask, linkedTask.status);
  return linkedTask;
}

// Commentaires de l'issue GitHub -> table project_task_comments.
async function syncTaskCommentsFromGitHub(task) {
  const issue = parseGitHubIssueUrl(task.github_issue_url);
  if (!issue) return;
  const comments = await githubRequestAll(
    `/repos/${encodeURIComponent(issue.owner)}/${encodeURIComponent(issue.repo)}/issues/${issue.number}/comments`
  );
  for (const comment of comments) {
    // Les commentaires écrits depuis GESTION_IT gardent leur auteur et leur texte d'origine.
    await pool.query(
      `INSERT INTO project_task_comments (task_id, author_name, body, github_comment_id, github_comment_url, created_at)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (github_comment_id) DO UPDATE SET
         body = CASE WHEN project_task_comments.author_account_id IS NULL THEN EXCLUDED.body ELSE project_task_comments.body END`,
      [task.id, comment.user?.login || 'GitHub', comment.body || '', comment.id, comment.html_url, comment.created_at]
    );
  }
  const ids = comments.map((comment) => comment.id);
  await pool.query(
    `DELETE FROM project_task_comments
     WHERE task_id = $1 AND github_comment_id IS NOT NULL AND NOT (github_comment_id = ANY($2::bigint[]))`,
    [task.id, ids]
  );
  await pool.query(`UPDATE project_tasks SET github_comment_count = $1 WHERE id = $2`, [comments.length, task.id]);
}


export function registerProjectRoutes(app) {
  ensureProjectsDir().catch((err) => console.error('[PROJECTS] Impossible de créer le dossier storage/projects', err));

  // express.json() ne peuple req.body que si le Content-Type est application/json ;
  // sans corps (ou sans ce header), req.body reste undefined et fait planter
  // les déstructurations ci-dessous. On normalise à {} pour toute requête.
  app.use((req, res, next) => {
    if (req.body === undefined) req.body = {};
    next();
  });


  const schemaReady = ensureProjectsSchema().catch((error) =>
    console.error('[Projets IT] Mise à jour du schéma impossible', error.message || error)
  );

  app.post('/api/projects/github/sync', requireAuth, requireRole('manager'), async (req, res) => {
    try {
      res.json(await syncGitHubBoards());
    } catch (error) {
      console.error('[GitHub Sync] erreur', error);
      res.status(500).json({ error: error.message });
    }
  });

  setTimeout(() => {
    schemaReady.then(() => syncGitHubBoards()).catch((error) =>
      console.error('[GitHub Sync] synchronisation initiale impossible', error.message || error)
    );
  }, 15000).unref();

  const githubSyncTimer = setInterval(() => {
    syncGitHubBoards().catch((error) =>
      console.error('[GitHub Sync] synchronisation periodique impossible', error.message || error)
    );
  }, 60 * 1000);
  githubSyncTimer.unref();

  // -------------------------------------------------------------------
  // Notifications de l'utilisateur connecté (page d'accueil)
  // -------------------------------------------------------------------
  app.get('/api/notifications', requireAuth, async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT n.id, n.type, n.title, n.body, n.project_id, n.task_id, n.read_at, n.created_at,
                p.name AS project_name
         FROM user_notifications n
         LEFT JOIN projects p ON p.id = n.project_id
         WHERE n.account_id = $1
           AND (n.read_at IS NULL OR n.created_at > now() - interval '7 days')
         ORDER BY n.read_at IS NULL DESC, n.created_at DESC
         LIMIT 30`,
        [req.session.user.id]
      );
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/notifications/read-all', requireAuth, async (req, res) => {
    try {
      await pool.query(
        `UPDATE user_notifications SET read_at = now() WHERE account_id = $1 AND read_at IS NULL`,
        [req.session.user.id]
      );
      res.json({ ok: true });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/notifications/:id/read', requireAuth, async (req, res) => {
    try {
      await pool.query(
        `UPDATE user_notifications SET read_at = COALESCE(read_at, now()) WHERE id = $1 AND account_id = $2`,
        [req.params.id, req.session.user.id]
      );
      res.json({ ok: true });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Comptes disponibles pour affectation (manager uniquement)
  // -------------------------------------------------------------------
  app.get('/api/projects/accounts', requireAuth, requireRole('manager', 'dev'), async (req, res) => {
    try {
      try {
        await syncItAccountsFromEntra();
      } catch (syncError) {
        console.error(
          '[Projets IT] Échec de la synchronisation des membres Entra :',
          syncError.message || syncError
        );
      }

      const result = await pool.query(
        `SELECT id, email, display_name, is_it, is_it_manager, is_rh, is_manager, is_director, weekly_capacity_hours
         FROM app_accounts
         WHERE is_it = true OR is_it_manager = true
         ORDER BY display_name`
      );
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });


  // -------------------------------------------------------------------
  // Utilisateurs Microsoft 365 disponibles comme clients
  // -------------------------------------------------------------------
  app.get('/api/projects/clients', requireAuth, requireRole('manager'), async (req, res) => {
    try {
      const result = await pool.query(
        `
        SELECT
          e.id AS employee_id,
          e.microsoft_object_id AS id,
          COALESCE(
            NULLIF(TRIM(CONCAT_WS(' ', e.first_name, e.last_name)), ''),
            e.email,
            e.microsoft_upn
          ) AS display_name,
          COALESCE(e.email, e.microsoft_upn) AS email
        FROM employees e
        WHERE e.is_active = true
          AND e.account_enabled = true
          AND e.microsoft_object_id IS NOT NULL
          AND COALESCE(e.email, e.microsoft_upn) IS NOT NULL
        ORDER BY display_name
        `
      );

      res.json(result.rows);
    } catch (error) {
      console.error('[Projets IT] Liste clients Microsoft 365', error);
      res.status(500).json({ error: error.message });
    }
  });

  async function ensureProjectAccount(client, microsoftObjectId) {
    if (!microsoftObjectId) {
      throw new Error('Identifiant Microsoft obligatoire');
    }

    const employeeResult = await client.query(
      `
      SELECT
        microsoft_object_id,
        COALESCE(email, microsoft_upn) AS email,
        COALESCE(
          NULLIF(TRIM(CONCAT_WS(' ', first_name, last_name)), ''),
          email,
          microsoft_upn
        ) AS display_name
      FROM employees
      WHERE microsoft_object_id = $1
        AND is_active = true
        AND account_enabled = true
      LIMIT 1
      `,
      [microsoftObjectId]
    );

    if (employeeResult.rowCount === 0) {
      throw new Error('Utilisateur Microsoft 365 actif introuvable');
    }

    const employee = employeeResult.rows[0];

    await client.query(
      `
      INSERT INTO app_accounts (
        id,
        email,
        display_name,
        is_it,
        is_it_manager,
        is_rh,
        is_manager,
        is_director
      )
      VALUES ($1, $2, $3, false, false, false, false, false)
      ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        display_name = EXCLUDED.display_name
      `,
      [
        employee.microsoft_object_id,
        employee.email,
        employee.display_name
      ]
    );

    return employee.microsoft_object_id;
  }

  async function replaceProjectDevelopers(client, projectId, developerAssignments) {
    const raw = Array.isArray(developerAssignments) ? developerAssignments : [];
    const assignments = raw.map((item) =>
      typeof item === 'string'
        ? { accountId: item, projectRole: 'contributeur' }
        : {
            accountId: item?.accountId,
            projectRole: item?.projectRole === 'chef_de_projet'
              ? 'chef_de_projet'
              : 'contributeur'
          }
    ).filter((item) => item.accountId);

    await client.query(`DELETE FROM project_assignments WHERE project_id = $1`, [projectId]);

    for (const assignment of assignments) {
      const accountResult = await client.query(
        `SELECT id FROM app_accounts
         WHERE id = $1 AND (is_it = true OR is_it_manager = true)
         LIMIT 1`,
        [assignment.accountId]
      );
      if (accountResult.rowCount === 0) {
        throw new Error(`Le développeur ${assignment.accountId} n'est pas un membre actif du service IT`);
      }
      await client.query(
        `INSERT INTO project_assignments (project_id, account_id, project_role)
         VALUES ($1, $2, $3)
         ON CONFLICT (project_id, account_id)
         DO UPDATE SET project_role = EXCLUDED.project_role`,
        [projectId, assignment.accountId, assignment.projectRole]
      );
    }
  }

  app.put('/api/projects/accounts/:id/capacity', requireAuth, requireRole('manager'), async (req, res) => {
    try {
      const { weeklyCapacityHours } = req.body;
      const result = await pool.query(
        `UPDATE app_accounts SET weekly_capacity_hours = $1 WHERE id = $2 RETURNING *`,
        [weeklyCapacityHours, req.params.id]
      );
      res.json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Projets — liste filtrée par rôle
  // -------------------------------------------------------------------
  app.get('/api/projects', requireAuth, async (req, res) => {
    try {
      const { id: accountId } = req.session.user;
      const role = getModuleRole(req.session.user);

      // Les projets archivés (supprimés, ou anciens projets "dépôt" sans
      // tableau GitHub) ne sont plus affichés.
      let where = `WHERE p.status <> 'archive'`;
      let params = [];

      if (role === 'client') {
        where += ' AND p.client_account_id = $1';
        params = [accountId];
      } else if (role === 'dev') {
        where += ` AND (p.client_account_id = $1
                   OR EXISTS (SELECT 1 FROM project_assignments pa WHERE pa.project_id = p.id AND pa.account_id = $1))`;
        params = [accountId];
      }

      const projectsResult = await pool.query(
        `SELECT p.*, c.display_name AS client_name, c.email AS client_email
         FROM projects p
         LEFT JOIN app_accounts c ON c.id = p.client_account_id
         ${where}
         ORDER BY CASE p.project_state WHEN 'new' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'maintenance' THEN 3 ELSE 4 END, p.updated_at DESC, p.created_at DESC`,
        params
      );

      const projectIds = projectsResult.rows.map((p) => p.id);
      let tasksByProject = {};
      if (projectIds.length) {
        const tasksResult = await pool.query(
          `SELECT * FROM project_tasks WHERE project_id = ANY($1::uuid[])`,
          [projectIds]
        );
        tasksByProject = tasksResult.rows.reduce((acc, t) => {
          (acc[t.project_id] ||= []).push(t);
          return acc;
        }, {});
      }

      const enriched = projectsResult.rows.map((p) => {
        const tasks = tasksByProject[p.id] || [];
        const base = {
          id: p.id,
          name: p.name,
          description: p.description,
          type: p.type,
          status: p.status,
          project_state: p.project_state || 'active',
          closed_at: p.closed_at,
          due_date: p.due_date,
          tauxCompletude: completionRate(tasks)
        };
        if (role === 'client') return base;
        return {
          ...base,
          client_name: p.client_name,
          github_repo_url: p.github_repo_url,
          chargeEstimeeH: tasks.reduce((s, t) => s + Number(t.estimated_hours), 0),
          chargePasseeH: tasks.reduce((s, t) => s + Number(t.spent_hours), 0)
        };
      });

      res.json(enriched);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Détail d'un projet
  // -------------------------------------------------------------------
  app.get('/api/projects/:id', requireAuth, async (req, res) => {
    try {
      const { id: accountId } = req.session.user;
      const role = getModuleRole(req.session.user);
      const projectId = req.params.id;

      const projectResult = await pool.query(
        `SELECT p.*, c.display_name AS client_name, c.email AS client_email
         FROM projects p LEFT JOIN app_accounts c ON c.id = p.client_account_id
         WHERE p.id = $1`,
        [projectId]
      );
      if (projectResult.rowCount === 0) return res.status(404).json({ error: 'Projet introuvable' });
      const project = projectResult.rows[0];

      // Être client est propre au projet : un membre IT choisi comme client
      // d'un projet où il n'est pas dans l'équipe a la vue client.
      const isProjectClient = project.client_account_id === accountId;
      const hasTeamView =
        role === 'manager' ||
        role === 'directeur' ||
        (role === 'dev' && (await isAssignedToProject(accountId, projectId)));

      if (!hasTeamView && !isProjectClient) return res.status(403).json({ error: 'Accès refusé à ce projet' });

      const tasksResult = await pool.query(
        `SELECT t.*, a.display_name AS assignee_name,
                GREATEST(
                  t.github_comment_count,
                  (SELECT COUNT(*) FROM project_task_comments c WHERE c.task_id = t.id)
                )::int AS comment_count,
                (SELECT COALESCE(json_agg(json_build_object('id', f.id, 'filename', f.filename) ORDER BY f.created_at), '[]'::json)
                 FROM project_files f WHERE f.task_id = t.id) AS files
         FROM project_tasks t
         LEFT JOIN app_accounts a ON a.id = t.assignee_account_id
         WHERE t.project_id = $1 ORDER BY t.created_at`,
        [projectId]
      );

      if (!hasTeamView) {
        const requestsResult = await pool.query(
          `${CLIENT_REQUESTS_SELECT}
           WHERE r.project_id = $1 AND r.client_account_id = $2
           ORDER BY r.created_at DESC`,
          [projectId, accountId]
        );
        return res.json({
          id: project.id,
          name: project.name,
          description: project.description,
          type: project.type,
          status: project.status,
          due_date: project.due_date,
          project_state: project.project_state,
          client_account_id: project.client_account_id,
          tauxCompletude: completionRate(tasksResult.rows),
          clientRequests: requestsResult.rows
        });
      }

      const assignmentsResult = await pool.query(
        `SELECT pa.id, pa.project_role, a.id AS account_id, a.display_name, a.email, a.is_it, a.is_it_manager
         FROM project_assignments pa
         JOIN app_accounts a ON a.id = pa.account_id
         WHERE pa.project_id = $1`,
        [projectId]
      );

      res.json({
        ...project,
        tasks: tasksResult.rows,
        assignments: assignmentsResult.rows,
        tauxCompletude: completionRate(tasksResult.rows),
        chargeEstimeeH: tasksResult.rows.reduce((s, t) => s + Number(t.estimated_hours), 0),
        chargePasseeH: tasksResult.rows.reduce((s, t) => s + Number(t.spent_hours), 0),
        estChefDeProjet: role === 'manager' ? true : await isChefDeProjet(accountId, projectId)
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // CRUD projet — manager uniquement
  // -------------------------------------------------------------------
  app.post('/api/projects', requireAuth, requireRole('manager'), async (req, res) => {
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const {
        name,
        description,
        type,
        dueDate,
        clientAccountId,
        developerAssignments,
        developerAccountIds,
        githubRepoUrl
      } = req.body;

      if (!name || !type) {
        await client.query('ROLLBACK');
        return res.status(400).json({ error: 'name et type requis' });
      }

      const normalizedClientId = clientAccountId
        ? await ensureProjectAccount(client, clientAccountId)
        : null;

      const result = await client.query(
        `INSERT INTO projects (
           name,
           description,
           type,
           created_by,
           client_account_id,
           github_repo_url,
           due_date
         )
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING *`,
        [
          name,
          description || null,
          type,
          req.session.user.id,
          normalizedClientId,
          githubRepoUrl || null,
          dueDate || null
        ]
      );

      const project = result.rows[0];

      await replaceProjectDevelopers(
        client,
        project.id,
        developerAssignments ?? developerAccountIds
      );

      await client.query('COMMIT');

      if (project.client_account_id) {
        project.client_link_sent = await sendClientProjectLink(project.id);
      }

      res.status(201).json(project);
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error('[Projets IT] Création projet', error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

  app.put('/api/projects/:id', requireAuth, requireRole('manager'), async (req, res) => {
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const {
        name,
        description,
        type,
        status,
        dueDate,
        clientAccountId,
        developerAssignments,
        developerAccountIds,
        githubRepoUrl
      } = req.body;

      let normalizedClientId;
      const previousResult = await client.query(
        `SELECT client_account_id FROM projects WHERE id = $1`,
        [req.params.id]
      );
      const previousClientId = previousResult.rows[0]?.client_account_id || null;

      if (clientAccountId !== undefined) {
        normalizedClientId = clientAccountId
          ? await ensureProjectAccount(client, clientAccountId)
          : null;
      }

      const result = await client.query(
        `UPDATE projects SET
           name = COALESCE($1, name),
           description = COALESCE($2, description),
           type = COALESCE($3, type),
           status = COALESCE($4, status),
           due_date = COALESCE($5, due_date),
           client_account_id = CASE
             WHEN $6::boolean = true THEN $7::uuid
             ELSE client_account_id
           END,
           github_repo_url = COALESCE($8, github_repo_url),
           updated_at = now()
         WHERE id = $9
         RETURNING *`,
        [
          name,
          description,
          type,
          status,
          dueDate,
          clientAccountId !== undefined,
          normalizedClientId ?? null,
          githubRepoUrl,
          req.params.id
        ]
      );

      if (result.rowCount === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ error: 'Projet introuvable' });
      }

      if (developerAccountIds !== undefined) {
        await replaceProjectDevelopers(
          client,
          req.params.id,
          developerAccountIds
        );
      }

      await client.query('COMMIT');

      const updatedProject = result.rows[0];
      if (updatedProject.client_account_id && updatedProject.client_account_id !== previousClientId) {
        updatedProject.client_link_sent = await sendClientProjectLink(updatedProject.id);
      }

      res.json(updatedProject);
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error('[Projets IT] Modification projet', error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

  app.delete('/api/projects/:id', requireAuth, requireRole('manager'), async (req, res) => {
    try {
      await pool.query(`UPDATE projects SET status = 'archive' WHERE id = $1`, [req.params.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Affectations — manager ou chef de projet
  // -------------------------------------------------------------------
  app.post('/api/projects/:id/assignments', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      const projectId = req.params.id;
      if (role !== 'manager' && !(await isChefDeProjet(req.session.user.id, projectId))) {
        return res.status(403).json({ error: 'Seul le manager ou le chef de projet peut affecter' });
      }
      const { accountId, projectRole } = req.body;
      const result = await pool.query(
        `INSERT INTO project_assignments (project_id, account_id, project_role)
         VALUES ($1, $2, $3)
         ON CONFLICT (project_id, account_id) DO UPDATE SET project_role = EXCLUDED.project_role
         RETURNING *`,
        [projectId, accountId, projectRole || 'contributeur']
      );
      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.delete('/api/projects/:id/assignments/:accountId', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      if (role !== 'manager' && !(await isChefDeProjet(req.session.user.id, req.params.id))) {
        return res.status(403).json({ error: 'Seul le manager ou le chef de projet peut retirer un membre' });
      }
      await pool.query(`DELETE FROM project_assignments WHERE project_id = $1 AND account_id = $2`, [
        req.params.id,
        req.params.accountId
      ]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });


  app.post('/api/projects/:id/send-client-link', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      if (role !== 'manager' && !(await isChefDeProjet(req.session.user.id, req.params.id))) {
        return res.status(403).json({ error: 'Seul le manager ou le chef de projet peut envoyer le lien' });
      }
      const sent = await sendClientProjectLink(req.params.id);
      if (!sent) return res.status(400).json({ error: "Aucun client avec une adresse e-mail sur ce projet, ou échec de l'envoi" });
      res.json({ ok: true });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.put('/api/projects/:id/state', requireAuth, requireRole('manager'), async (req, res) => {
    try {
      const { projectState } = req.body;
      if (!['new', 'closed'].includes(projectState)) {
        return res.status(400).json({ error: 'État de projet invalide' });
      }
      const result = await pool.query(
        `UPDATE projects
         SET project_state = $1,
             closed_at = CASE WHEN $1 = 'closed' THEN COALESCE(closed_at, now()) ELSE NULL END,
             updated_at = now()
         WHERE id = $2
         RETURNING *`,
        [projectState, req.params.id]
      );
      if (result.rowCount === 0) return res.status(404).json({ error: 'Projet introuvable' });
      res.json(result.rows[0]);
    } catch (error) {
      console.error('[Projets IT] Changement état projet', error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Tâches
  // -------------------------------------------------------------------
  const TASK_STATUSES = ['backlog', 'ready', 'in_progress', 'in_review', 'done'];

  // Tâche accessible à l'utilisateur ; envoie l'erreur HTTP et renvoie null sinon.
  async function loadTaskForUser(req, res, { write }) {
    const role = getModuleRole(req.session.user);
    if (role === 'client' || (write && role === 'directeur')) {
      res.status(403).json({ error: 'Accès refusé' });
      return null;
    }
    const taskResult = await pool.query(`SELECT * FROM project_tasks WHERE id = $1`, [req.params.id]);
    if (taskResult.rowCount === 0) {
      res.status(404).json({ error: 'Tâche introuvable' });
      return null;
    }
    const task = taskResult.rows[0];
    if (role === 'dev' && !(await isAssignedToProject(req.session.user.id, task.project_id))) {
      res.status(403).json({ error: 'Accès refusé à cette tâche' });
      return null;
    }
    return task;
  }

  function logGitHubFailures(results) {
    for (const result of results) {
      if (result.status === 'rejected') {
        console.error('[Projets IT] Synchronisation statut GitHub impossible', result.reason?.message || result.reason);
      }
    }
  }

  app.post('/api/projects/tasks', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      const { projectId, title, description, assigneeAccountId, estimatedHours } = req.body;
      if (!projectId || !title) return res.status(400).json({ error: 'projectId et title requis' });

      if (role === 'client' || role === 'directeur') return res.status(403).json({ error: 'Accès refusé' });
      if (role === 'dev' && !(await isChefDeProjet(req.session.user.id, projectId))) {
        return res.status(403).json({ error: 'Seul le chef de projet peut ajouter une tâche' });
      }

      const result = await pool.query(
        `INSERT INTO project_tasks (project_id, title, description, assignee_account_id, estimated_hours, origin)
         VALUES ($1, $2, $3, $4, $5, 'manuelle') RETURNING *`,
        [projectId, title, description || null, assigneeAccountId || null, estimatedHours || 0]
      );
      let task = result.rows[0];
      await notifyTaskAssignee(task, req.session.user.id);
      try {
        task = (await createGitHubItemForTask(task)) || task;
      } catch (githubError) {
        console.error('[Projets IT] Creation carte GitHub impossible', githubError.message || githubError);
        task.github_sync_error = githubError.message || String(githubError);
      }
      res.status(201).json(task);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.put('/api/projects/tasks/:id', requireAuth, async (req, res) => {
    try {
      const task = await loadTaskForUser(req, res, { write: true });
      if (!task) return;
      const role = getModuleRole(req.session.user);

      const { status, spentHours, estimatedHours, assigneeAccountId } = req.body;
      if (status != null && !TASK_STATUSES.includes(status)) {
        return res.status(400).json({ error: 'Statut de tâche invalide' });
      }
      const assigneeProvided = assigneeAccountId !== undefined;
      if (assigneeProvided && role === 'dev' && !(await isChefDeProjet(req.session.user.id, task.project_id))) {
        return res.status(403).json({ error: 'Seul le chef de projet peut affecter une tâche' });
      }

      const result = await pool.query(
        `UPDATE project_tasks SET
           status = COALESCE($1, status),
           completed_at = CASE
             WHEN $1 = 'done' AND status <> 'done' THEN now()
             WHEN $1 IS NOT NULL AND $1 <> 'done' THEN NULL
             ELSE completed_at
           END,
           status_updated_at = CASE
             WHEN $1 IS NOT NULL AND $1 IS DISTINCT FROM status THEN now()
             ELSE status_updated_at
           END,
           spent_hours = COALESCE($2, spent_hours),
           estimated_hours = COALESCE($3, estimated_hours),
           assignee_account_id = CASE WHEN $6::boolean THEN $4::uuid ELSE assignee_account_id END,
           updated_at = now()
         WHERE id = $5 RETURNING *`,
        [status ?? null, spentHours ?? null, estimatedHours ?? null, assigneeAccountId || null, req.params.id, assigneeProvided]
      );
      const updatedTask = result.rows[0];

      // Journal daté : l'écart saisi est attribué au technicien affecté
      // (à défaut, à la personne qui saisit).
      const spentDelta = Number(updatedTask.spent_hours) - Number(task.spent_hours);
      if (spentHours != null && spentDelta !== 0) {
        await pool.query(
          `INSERT INTO project_time_entries (task_id, account_id, hours, entered_by) VALUES ($1, $2, $3, $4)`,
          [task.id, updatedTask.assignee_account_id || req.session.user.id, spentDelta, req.session.user.id]
        );
      }

      res.json(updatedTask);

      if (updatedTask.assignee_account_id && updatedTask.assignee_account_id !== task.assignee_account_id) {
        await notifyTaskAssignee(updatedTask, req.session.user.id);
      }
      if (status && status !== task.status) {
        await handleTaskStatusChange(updatedTask, task.status);
        Promise.allSettled([
          syncGitHubIssueState(updatedTask, status),
          updateGitHubProjectV2Status(updatedTask, status),
        ]).then(logGitHubFailures);
      }
    } catch (error) {
      console.error(error);
      if (!res.headersSent) res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Commentaires de tâche — synchronisés avec l'issue GitHub liée
  // -------------------------------------------------------------------
  app.get('/api/projects/tasks/:id/comments', requireAuth, async (req, res) => {
    try {
      const task = await loadTaskForUser(req, res, { write: false });
      if (!task) return;
      let githubError = null;
      if (task.github_issue_url) {
        try {
          await syncTaskCommentsFromGitHub(task);
        } catch (error) {
          githubError = error.message || String(error);
          console.error('[Projets IT] Lecture commentaires GitHub impossible', githubError);
        }
      }
      const result = await pool.query(
        `SELECT id, author_account_id, author_name, body, github_comment_url, created_at
         FROM project_task_comments WHERE task_id = $1 ORDER BY created_at`,
        [task.id]
      );
      res.json({ comments: result.rows, githubError });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/projects/tasks/:id/comments', requireAuth, async (req, res) => {
    try {
      const task = await loadTaskForUser(req, res, { write: true });
      if (!task) return;
      const body = String(req.body.body || '').trim();
      if (!body) return res.status(400).json({ error: 'Commentaire vide' });

      const author = req.session.user;
      let githubComment = null;
      const issue = parseGitHubIssueUrl(task.github_issue_url);
      if (issue) {
        // Le token GitHub est commun : on indique l'auteur réel dans le texte.
        githubComment = await githubRequest(
          `/repos/${encodeURIComponent(issue.owner)}/${encodeURIComponent(issue.repo)}/issues/${issue.number}/comments`,
          'POST',
          { body: `**${author.displayName}** (via GESTION_IT) :\n\n${body}` }
        );
      }

      const result = await pool.query(
        `INSERT INTO project_task_comments (task_id, author_account_id, author_name, body, github_comment_id, github_comment_url)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING id, author_account_id, author_name, body, github_comment_url, created_at`,
        [task.id, author.id, author.displayName, body, githubComment?.id || null, githubComment?.html_url || null]
      );
      if (githubComment) {
        await pool.query(
          `UPDATE project_tasks SET github_comment_count = github_comment_count + 1 WHERE id = $1`,
          [task.id]
        );
      }
      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Demandes client
  // -------------------------------------------------------------------
  function decodeUploadName(name) {
    // busboy décode les noms de fichiers en latin1 : on restaure les accents.
    try {
      return Buffer.from(name, 'latin1').toString('utf8');
    } catch {
      return name;
    }
  }

  function uploadRequestFiles(req, res, next) {
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

  // Ouvert à quiconque est le client du projet (vérifié ci-dessous), même membre IT.
  app.post('/api/projects/requests', requireAuth, uploadRequestFiles, async (req, res) => {
    const files = req.files || [];
    try {
      const { projectId } = req.body;
      const title = String(req.body.title || '').trim();
      const description = String(req.body.description || '').trim();
      const accountId = req.session.user.id;

      if (!projectId || !title) {
        await removeUploadedFiles(files);
        return res.status(400).json({ error: 'Le titre de la demande est obligatoire' });
      }

      const projectResult = await pool.query(`SELECT * FROM projects WHERE id = $1`, [projectId]);
      if (projectResult.rowCount === 0 || projectResult.rows[0].client_account_id !== accountId) {
        await removeUploadedFiles(files);
        return res.status(403).json({ error: "Ce projet ne vous appartient pas" });
      }
      const project = projectResult.rows[0];

      const client = await pool.connect();
      let request;
      try {
        await client.query('BEGIN');
        const result = await client.query(
          `INSERT INTO project_client_requests (project_id, client_account_id, title, description)
           VALUES ($1, $2, $3, $4) RETURNING *`,
          [projectId, accountId, title, description || null]
        );
        request = result.rows[0];
        for (const file of files) {
          await client.query(
            `INSERT INTO project_files (project_id, client_request_id, filename, storage_path, uploaded_by_account_id)
             VALUES ($1, $2, $3, $4, $5)`,
            [projectId, request.id, decodeUploadName(file.originalname), file.filename, accountId]
          );
        }
        await client.query('COMMIT');
      } catch (error) {
        await client.query('ROLLBACK').catch(() => {});
        throw error;
      } finally {
        client.release();
      }

      await notifyProjectLeads(projectId, {
        type: 'client_request',
        title: `Nouvelle demande client : ${title}`,
        body: `${req.session.user.displayName} — projet ${project.name}`
      });

      res.status(201).json({ ...request, filesCount: files.length });
    } catch (error) {
      await removeUploadedFiles(files);
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/projects/:id/requests', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      if (role === 'client' || role === 'directeur') return res.status(403).json({ error: 'Accès refusé' });
      if (role === 'dev' && !(await isAssignedToProject(req.session.user.id, req.params.id))) {
        return res.status(403).json({ error: 'Accès refusé' });
      }
      const result = await pool.query(
        `${CLIENT_REQUESTS_SELECT} WHERE r.project_id = $1 ORDER BY r.created_at DESC`,
        [req.params.id]
      );
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Validation par le chef de projet : il peut reformuler la demande
  // (titre, description) et l'affecter ; elle devient une tâche.
  app.post('/api/projects/requests/:id/valider', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      if (role === 'client' || role === 'directeur') return res.status(403).json({ error: 'Accès refusé' });

      const { estimatedHours, title, description, assigneeAccountId } = req.body;
      if (!estimatedHours || Number(estimatedHours) <= 0) {
        return res.status(400).json({ error: 'Une prévision de temps (estimatedHours > 0) est obligatoire' });
      }

      const requestResult = await pool.query(`SELECT * FROM project_client_requests WHERE id = $1`, [req.params.id]);
      if (requestResult.rowCount === 0) return res.status(404).json({ error: 'Demande introuvable' });
      const request = requestResult.rows[0];
      if (request.status !== 'en_attente') return res.status(409).json({ error: 'Demande déjà traitée' });

      if (role === 'dev' && !(await isChefDeProjet(req.session.user.id, request.project_id))) {
        return res.status(403).json({ error: 'Seul le chef de projet peut traiter une demande client' });
      }

      const finalTitle = String(title ?? request.title).trim() || request.title;
      const finalDescription = description === undefined
        ? request.description
        : String(description).trim() || null;
      const edited =
        finalTitle !== request.title || (finalDescription || null) !== (request.description || null);

      const client = await pool.connect();
      let task;
      let attachmentsCount = 0;
      try {
        await client.query('BEGIN');
        const taskResult = await client.query(
          `INSERT INTO project_tasks (project_id, title, description, estimated_hours, origin, assignee_account_id)
           VALUES ($1, $2, $3, $4, 'demande_client', $5) RETURNING *`,
          [request.project_id, finalTitle, finalDescription, Number(estimatedHours), assigneeAccountId || null]
        );
        task = taskResult.rows[0];
        await client.query(
          `UPDATE project_client_requests SET
             status = 'validee',
             task_id = $1,
             original_title = CASE WHEN $2::boolean THEN COALESCE(original_title, title) ELSE original_title END,
             original_description = CASE WHEN $2::boolean THEN COALESCE(original_description, description) ELSE original_description END,
             title = $3,
             description = $4,
             reviewed_by = $5,
             reviewed_at = now()
           WHERE id = $6`,
          [task.id, edited, finalTitle, finalDescription, req.session.user.id, request.id]
        );
        const filesResult = await client.query(
          `UPDATE project_files SET task_id = $1 WHERE client_request_id = $2`,
          [task.id, request.id]
        );
        attachmentsCount = filesResult.rowCount;
        await client.query('COMMIT');
      } catch (error) {
        await client.query('ROLLBACK').catch(() => {});
        throw error;
      } finally {
        client.release();
      }

      await notifyTaskAssignee(task, req.session.user.id);
      try {
        task = (await createGitHubItemForTask(task, { attachmentsCount })) || task;
      } catch (githubError) {
        console.error('[Projets IT] Creation carte GitHub depuis demande client impossible', githubError.message || githubError);
        task.github_sync_error = githubError.message || String(githubError);
      }

      const clientResult = await pool.query(`SELECT * FROM app_accounts WHERE id = $1`, [request.client_account_id]);
      const requester = clientResult.rows[0];
      if (requester) {
        const paragraphs = [
          `Votre demande <strong>« ${escapeHtml(request.title)} »</strong> a été acceptée et ajoutée aux tâches de l'équipe informatique.`
        ];
        if (edited) {
          paragraphs.push(`Elle a été reformulée ainsi : <strong>« ${escapeHtml(finalTitle)} »</strong>${finalDescription ? `<br/>${escapeHtml(finalDescription).replace(/\n/g, '<br/>')}` : ''}`);
        }
        paragraphs.push('Vous recevrez un e-mail quand nous commencerons à travailler dessus, puis quand elle sera terminée.');
        await notifyClient({
          email: requester.email,
          subject: `Votre demande "${request.title}" a été acceptée`,
          html: clientMailHtml({ name: requester.display_name, paragraphs, projectId: request.project_id })
        });
      }

      res.json({
        request: { ...request, status: 'validee', task_id: task.id, title: finalTitle, description: finalDescription },
        task
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/projects/requests/:id/rejeter', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      if (role === 'client' || role === 'directeur') return res.status(403).json({ error: 'Accès refusé' });

      const requestResult = await pool.query(`SELECT * FROM project_client_requests WHERE id = $1`, [req.params.id]);
      if (requestResult.rowCount === 0) return res.status(404).json({ error: 'Demande introuvable' });
      const request = requestResult.rows[0];
      if (request.status !== 'en_attente') return res.status(409).json({ error: 'Demande déjà traitée' });

      if (role === 'dev' && !(await isChefDeProjet(req.session.user.id, request.project_id))) {
        return res.status(403).json({ error: 'Seul le chef de projet peut traiter une demande client' });
      }

      const reason = String(req.body.reason || '').trim();
      if (!reason) return res.status(400).json({ error: 'Le motif du rejet est obligatoire' });

      await pool.query(
        `UPDATE project_client_requests
         SET status = 'rejetee', rejection_reason = $1, reviewed_by = $2, reviewed_at = now()
         WHERE id = $3`,
        [reason, req.session.user.id, req.params.id]
      );

      const clientResult = await pool.query(`SELECT * FROM app_accounts WHERE id = $1`, [request.client_account_id]);
      const requester = clientResult.rows[0];
      if (requester) {
        await notifyClient({
          email: requester.email,
          subject: `Votre demande "${request.title}" a été rejetée`,
          html: clientMailHtml({
            name: requester.display_name,
            paragraphs: [
              `Votre demande <strong>« ${escapeHtml(request.title)} »</strong> n'a pas pu être retenue en l'état.`,
              `<strong>Motif :</strong> ${escapeHtml(reason).replace(/\n/g, '<br/>')}`,
              "N'hésitez pas à revenir vers l'équipe informatique pour plus de détails."
            ],
            projectId: request.project_id
          })
        });
      }

      res.json({ ok: true });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Messages / échanges — envoie un vrai e-mail via Microsoft Graph
  // quand l'équipe écrit au client (server/graphMail.mjs).
  // -------------------------------------------------------------------
  app.get('/api/projects/:id/messages', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      const projectId = req.params.id;
      const accountId = req.session.user.id;

      if (role === 'client') {
        const p = await pool.query(`SELECT client_account_id FROM projects WHERE id = $1`, [projectId]);
        if (p.rowCount === 0 || p.rows[0].client_account_id !== accountId) {
          return res.status(403).json({ error: 'Accès refusé' });
        }
      } else if (role === 'dev' && !(await isAssignedToProject(accountId, projectId))) {
        return res.status(403).json({ error: 'Accès refusé' });
      }

      const result = await pool.query(
        `SELECT m.*, a.display_name AS author_name, a.email AS author_email,
                (SELECT json_agg(f.*) FROM project_files f WHERE f.message_id = m.id) AS files
         FROM project_messages m JOIN app_accounts a ON a.id = m.author_account_id
         WHERE m.project_id = $1 ORDER BY m.created_at ASC`,
        [projectId]
      );
      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/projects/messages', requireAuth, async (req, res) => {
    try {
      const role = getModuleRole(req.session.user);
      const { projectId, content } = req.body;
      const accountId = req.session.user.id;
      if (!projectId || !content) return res.status(400).json({ error: 'projectId et content requis' });

      const projectResult = await pool.query(
        `SELECT p.*, c.email AS client_email, c.display_name AS client_name
         FROM projects p LEFT JOIN app_accounts c ON c.id = p.client_account_id WHERE p.id = $1`,
        [projectId]
      );
      if (projectResult.rowCount === 0) return res.status(404).json({ error: 'Projet introuvable' });
      const project = projectResult.rows[0];

      if (role === 'client' && project.client_account_id !== accountId) {
        return res.status(403).json({ error: 'Accès refusé' });
      }
      if (role === 'dev' && !(await isAssignedToProject(accountId, projectId))) {
        return res.status(403).json({ error: 'Accès refusé' });
      }
      if (role === 'directeur') return res.status(403).json({ error: 'Accès refusé (lecture seule)' });

      const recipientType = role === 'client' ? 'equipe' : 'client';
      let emailSent = false;

      if (recipientType === 'client' && project.client_email) {
        emailSent = await notifyClient({
          email: project.client_email,
          subject: `Nouveau message sur votre projet "${project.name}"`,
          html: `<p>Bonjour ${project.client_name},</p><p>${content.replace(/\n/g, '<br/>')}</p>`
        });
      }

      const result = await pool.query(
        `INSERT INTO project_messages (project_id, author_account_id, recipient_type, content, email_sent)
         VALUES ($1, $2, $3, $4, $5) RETURNING *`,
        [projectId, accountId, recipientType, content, emailSent]
      );
      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Fichiers
  // -------------------------------------------------------------------
  app.post('/api/projects/files', requireAuth, upload.single('file'), async (req, res) => {
    try {
      if (!req.file) return res.status(400).json({ error: 'Fichier requis (champ "file")' });
      const { projectId, messageId, clientRequestId } = req.body;
      if (!(await canAccessProject(req.session.user, projectId))) {
        await removeUploadedFiles([req.file]);
        return res.status(403).json({ error: 'Accès refusé à ce projet' });
      }

      const result = await pool.query(
        `INSERT INTO project_files (project_id, message_id, client_request_id, filename, storage_path, uploaded_by_account_id)
         VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
        [projectId, messageId || null, clientRequestId || null, decodeUploadName(req.file.originalname), req.file.filename, req.session.user.id]
      );
      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/projects/files/:id/download', requireAuth, async (req, res) => {
    try {
      const file = await loadFileWithProject(req.params.id);
      if (!file) return res.status(404).json({ error: 'Fichier introuvable' });
      if (!(await canAccessProject(req.session.user, file.resolved_project_id))) {
        return res.status(403).json({ error: 'Accès refusé à ce fichier' });
      }
      const filePath = path.join(PROJECTS_DIR, file.storage_path);
      if (!fs.existsSync(filePath)) return res.status(404).json({ error: 'Fichier introuvable sur le disque' });
      res.download(filePath, file.filename);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // -------------------------------------------------------------------
  // Dashboard manager + reporting directeur
  // -------------------------------------------------------------------
  app.get('/api/projects-dashboard', requireAuth, requireRole('manager'), async (req, res) => {
    try {
      const projectsResult = await pool.query(`SELECT * FROM projects WHERE status != 'archive' AND project_state != 'closed'`);
      const projects = projectsResult.rows;

      const tasksResult = await pool.query(
        `SELECT * FROM project_tasks WHERE project_id = ANY($1::uuid[])`,
        [projects.map((p) => p.id)]
      );
      const tasksByProject = tasksResult.rows.reduce((acc, t) => {
        (acc[t.project_id] ||= []).push(t);
        return acc;
      }, {});

      const nbParStatut = projects.reduce((acc, p) => {
        acc[p.status] = (acc[p.status] || 0) + 1;
        return acc;
      }, {});

      const chargeParProjet = projects.map((p) => {
        const tasks = tasksByProject[p.id] || [];
        return {
          projetId: p.id,
          nom: p.name,
          tauxCompletude: completionRate(tasks),
          chargeEstimeeH: tasks.reduce((s, t) => s + Number(t.estimated_hours), 0),
          chargePasseeH: tasks.reduce((s, t) => s + Number(t.spent_hours), 0)
        };
      });

      // Techniciens = membres du service IT uniquement (app_accounts contient
      // aussi les clients et toute personne s'étant connectée).
      const membersResult = await pool.query(
        `SELECT * FROM app_accounts WHERE is_it = true OR is_it_manager = true ORDER BY display_name`
      );
      const assignmentsResult = await pool.query(
        `SELECT account_id, project_id FROM project_assignments WHERE project_id = ANY($1::uuid[])`,
        [projects.map((p) => p.id)]
      );
      const projectNames = Object.fromEntries(projects.map((p) => [p.id, p.name]));
      const activeTasks = tasksResult.rows.filter((t) => t.status !== 'done');
      const chargeParTechnicien = membersResult.rows.map((u) => {
        const tachesActives = activeTasks.filter((t) => t.assignee_account_id === u.id);
        const parProjet = {};
        for (const t of tachesActives) {
          const entry = (parProjet[t.project_id] ||= {
            projetId: t.project_id,
            nom: projectNames[t.project_id],
            chargeEstimeeH: 0,
            chargePasseeH: 0,
            nbTaches: 0
          });
          entry.chargeEstimeeH += Number(t.estimated_hours);
          entry.chargePasseeH += Number(t.spent_hours);
          entry.nbTaches += 1;
        }
        // Projets du technicien : ceux où il est dans l'équipe ou a une tâche active.
        const projetIds = new Set([
          ...assignmentsResult.rows.filter((a) => a.account_id === u.id).map((a) => a.project_id),
          ...Object.keys(parProjet)
        ]);
        const chargeEstimeeH = tachesActives.reduce((s, t) => s + Number(t.estimated_hours), 0);
        return {
          userId: u.id,
          nom: u.display_name,
          chargeEstimeeH,
          nbProjets: projetIds.size,
          chargeParProjet: Object.values(parProjet).sort((a, b) => b.chargeEstimeeH - a.chargeEstimeeH),
          disponibilite: u.weekly_capacity_hours,
          enSurcharge: chargeEstimeeH > u.weekly_capacity_hours
        };
      });

      const demandesResult = await pool.query(`SELECT COUNT(*) FROM project_client_requests WHERE status = 'en_attente'`);

      // Temps passé sur les 12 derniers mois, par mois, technicien et projet
      // (projets clôturés compris : le temps a bien été passé).
      const tempsResult = await pool.query(
        `SELECT to_char(date_trunc('month', e.logged_at AT TIME ZONE 'Europe/Paris'), 'YYYY-MM') AS mois,
                e.account_id AS "userId",
                COALESCE(a.display_name, 'Non affecté') AS nom,
                t.project_id AS "projetId",
                p.name AS projet,
                SUM(e.hours)::float AS heures
         FROM project_time_entries e
         JOIN project_tasks t ON t.id = e.task_id
         JOIN projects p ON p.id = t.project_id
         LEFT JOIN app_accounts a ON a.id = e.account_id
         WHERE e.logged_at >= date_trunc('month', now() AT TIME ZONE 'Europe/Paris') - interval '11 months'
           AND p.status <> 'archive'
         GROUP BY 1, 2, 3, 4, 5
         HAVING SUM(e.hours) <> 0
         ORDER BY 1`
      );

      res.json({
        nombreTotalProjets: projects.length,
        nbParStatut,
        chargeParProjet,
        chargeParTechnicien,
        chargeGlobaleEquipeH: chargeParTechnicien.reduce((s, u) => s + u.chargeEstimeeH, 0),
        demandesEnAttente: Number(demandesResult.rows[0].count),
        tempsParMois: tempsResult.rows
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Indicateurs Projets IT du tableau de bord principal de l'application.
  app.get('/api/projects-indicators', requireAuth, requireRole('manager', 'dev', 'directeur'), async (req, res) => {
    try {
      const result = await pool.query(
        `WITH actifs AS (
           SELECT id, project_state FROM projects
           WHERE status <> 'archive' AND project_state <> 'closed'
         ),
         taches AS (
           SELECT t.* FROM project_tasks t JOIN actifs a ON a.id = t.project_id
         ),
         mois AS (
           SELECT date_trunc('month', now() AT TIME ZONE 'Europe/Paris') AS debut
         )
         SELECT
           (SELECT COUNT(*) FROM actifs)::int AS "projetsActifs",
           (SELECT COUNT(*) FROM actifs WHERE project_state = 'new')::int AS "projetsNouveaux",
           (SELECT COUNT(*) FROM actifs WHERE project_state = 'in_progress')::int AS "projetsEnCours",
           (SELECT COUNT(*) FROM actifs WHERE project_state = 'maintenance')::int AS "projetsMaintenance",
           (SELECT COUNT(*) FROM taches WHERE status <> 'done')::int AS "tachesOuvertes",
           (SELECT COUNT(*) FROM taches WHERE status IN ('in_progress', 'in_review'))::int AS "tachesEnCours",
           (SELECT COUNT(*) FROM taches WHERE status <> 'done' AND assignee_account_id IS NULL)::int AS "tachesNonAffectees",
           (SELECT COUNT(*) FROM taches WHERE status <> 'done' AND assignee_account_id = $1)::int AS "mesTaches",
           (SELECT COUNT(*) FROM project_tasks, mois
             WHERE status = 'done' AND completed_at AT TIME ZONE 'Europe/Paris' >= mois.debut)::int AS "tachesTermineesMois",
           (SELECT COUNT(*) FROM project_client_requests r JOIN actifs a ON a.id = r.project_id
             WHERE r.status = 'en_attente')::int AS "demandesEnAttente",
           (SELECT COALESCE(SUM(e.hours), 0) FROM project_time_entries e, mois
             WHERE e.logged_at AT TIME ZONE 'Europe/Paris' >= mois.debut)::float AS "heuresMois"`,
        [req.session.user.id]
      );
      res.json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.get('/api/projects-reporting', requireAuth, requireRole('manager', 'directeur'), async (req, res) => {
    try {
      const projectsResult = await pool.query(
        `SELECT p.*, c.display_name AS client_name
         FROM projects p LEFT JOIN app_accounts c ON c.id = p.client_account_id
         WHERE p.status != 'archive' AND p.project_state != 'closed'`
      );
      const projects = projectsResult.rows;
      const tasksResult = await pool.query(
        `SELECT * FROM project_tasks WHERE project_id = ANY($1::uuid[])`,
        [projects.map((p) => p.id)]
      );
      const tasksByProject = tasksResult.rows.reduce((acc, t) => {
        (acc[t.project_id] ||= []).push(t);
        return acc;
      }, {});

      const now = new Date();
      const rapport = projects.map((p) => {
        const tasks = tasksByProject[p.id] || [];
        return {
          id: p.id,
          nom: p.name,
          client: p.client_name,
          statut: p.status,
          tauxCompletude: completionRate(tasks),
          chargeHoraireH: tasks.reduce((s, t) => s + Number(t.estimated_hours), 0),
          dateEcheance: p.due_date,
          enRetard: p.due_date ? new Date(p.due_date) < now && p.status !== 'closed' : false
        };
      });

      res.json(rapport);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });
}
