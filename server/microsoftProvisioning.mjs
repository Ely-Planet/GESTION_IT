// Automatisation Microsoft depuis « Arrivées & Départs ».
//
// Onboarding : création du compte Entra ID (adresse pnom@domaine, mot de passe
// par défaut à changer à la première connexion), manager, groupes et licences
// (ajustables par l'informatique), groupe de synchro 3CX. Mail au manager à la
// clôture de l'arrivée.
// Offboarding : réponse automatique, conversion en boîte partagée avec
// délégation, blocage de la connexion, déconnexion des sessions, retrait des
// groupes et des licences.
// Chaque traitement ajoute un récapitulatif dans la check-list du mouvement.
//
// Permissions d'application :
//   Microsoft Graph : User.ReadWrite.All, GroupMember.ReadWrite.All,
//     Group.Read.All, LicenseAssignment.ReadWrite.All, User.RevokeSessions.All,
//     MailboxSettings.ReadWrite
//   Office 365 Exchange Online : Exchange.ManageAsApp + rôle Entra
//     « Exchange Recipient Administrator » attribué à l'application
//     (boîte partagée et délégation : Graph ne le permet pas).
//
// Variables d'environnement (facultatives) :
//   MICROSOFT_USER_DOMAIN        domaine des adresses (défaut : elyade.com)
//   MICROSOFT_USAGE_LOCATION     pays des licences (défaut : FR)
//   MICROSOFT_DEFAULT_PASSWORD   mot de passe initial (défaut : Elyade@changer2026)
//   MICROSOFT_3CX_GROUP_ID       groupe Microsoft synchronisé par le 3CX
import { pool } from './db.mjs';
import { getGraphAppToken, sendMailWithAttachments } from './graphMail.mjs';
import { formatDisplayName, formatFirstName, formatJobTitle, formatLastName } from './nameFormat.mjs';

const DOMAIN = () => String(process.env.MICROSOFT_USER_DOMAIN || 'elyade.com').toLowerCase();
const USAGE_LOCATION = () => process.env.MICROSOFT_USAGE_LOCATION || 'FR';
const DEFAULT_PASSWORD = () => process.env.MICROSOFT_DEFAULT_PASSWORD || 'Elyade@changer2026';
const THREECX_GROUP_ID = () => process.env.MICROSOFT_3CX_GROUP_ID || null;
// Groupes proposés : services (🏢) et groupes de sécurité (🔐).
const GROUP_PREFIXES = ['🏢', '🔐'];

// ---------------------------------------------------------------------------
// Microsoft Graph
// ---------------------------------------------------------------------------
async function graph(method, url, body) {
  const token = await getGraphAppToken();
  const response = await fetch(url.startsWith('http') ? url : `https://graph.microsoft.com/v1.0${url}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json',
      ...(body ? { 'Content-Type': 'application/json' } : {})
    },
    body: body ? JSON.stringify(body) : undefined
  });
  if (!response.ok) {
    const details = await response.text();
    let message = details.slice(0, 300);
    try {
      message = JSON.parse(details)?.error?.message || message;
    } catch {
      // réponse non JSON
    }
    const error = new Error(
      response.status === 403 ? `Permission Microsoft Graph manquante (403) : ${message}` : `Microsoft Graph ${response.status} : ${message}`
    );
    error.status = response.status;
    throw error;
  }
  if (response.status === 202 || response.status === 204) return null;
  const text = await response.text();
  return text ? JSON.parse(text) : null;
}

async function graphOrNull(url) {
  try {
    return await graph('GET', url);
  } catch (error) {
    if (error.status === 404) return null;
    throw error;
  }
}

async function graphAll(url) {
  const items = [];
  let next = url;
  while (next) {
    const page = await graph('GET', next);
    items.push(...(page?.value || []));
    next = page?.['@odata.nextLink'] || null;
  }
  return items;
}

// Un compte tout juste créé met quelques secondes à être visible partout dans
// Microsoft 365 : on réessaie les opérations qui le ciblent s'il est « introuvable ».
async function withRetry(run, attempts = 5) {
  for (let i = 1; ; i++) {
    try {
      return await run();
    } catch (error) {
      if (error.status !== 404 || i >= attempts) throw error;
      await new Promise((resolve) => setTimeout(resolve, 3000));
    }
  }
}

// ---------------------------------------------------------------------------
// Autorisations accordées à l'application (lues dans ses jetons d'accès)
// ---------------------------------------------------------------------------
// Autorisation nécessaire -> autorisations plus larges qui la couvrent aussi.
const GRAPH_PERMISSIONS = {
  onboarding: {
    'User.ReadWrite.All': ['Directory.ReadWrite.All'],
    'Group.Read.All': ['Group.ReadWrite.All', 'Directory.Read.All', 'Directory.ReadWrite.All'],
    'GroupMember.ReadWrite.All': ['Group.ReadWrite.All', 'Directory.ReadWrite.All'],
    'LicenseAssignment.ReadWrite.All': ['User.ReadWrite.All', 'Directory.ReadWrite.All']
  },
  offboarding: {
    'User.ReadWrite.All': ['Directory.ReadWrite.All'],
    'Group.Read.All': ['Group.ReadWrite.All', 'Directory.Read.All', 'Directory.ReadWrite.All'],
    'GroupMember.ReadWrite.All': ['Group.ReadWrite.All', 'Directory.ReadWrite.All'],
    'LicenseAssignment.ReadWrite.All': ['User.ReadWrite.All', 'Directory.ReadWrite.All'],
    'User.RevokeSessions.All': ['User.ReadWrite.All', 'Directory.ReadWrite.All'],
    'MailboxSettings.ReadWrite': []
  }
};
// Rôles Entra permettant de gérer les boîtes (ID de modèle de rôle).
const EXCHANGE_ROLES = {
  '31392ffb-586c-42d1-9346-e59415a2cc4e': 'Exchange Recipient Administrator',
  '29232cdf-9323-42fd-ade2-1d097af3e4de': 'Exchange Administrator',
  '62e90394-69f5-4237-9190-012177145e10': 'Global Administrator'
};

function tokenClaims(token) {
  try {
    return JSON.parse(Buffer.from(String(token).split('.')[1], 'base64url').toString('utf8'));
  } catch {
    return {};
  }
}

// Liste des autorisations manquantes pour l'arrivée ou le départ.
async function missingPermissions(kind) {
  const missing = [];
  const graphRoles = new Set(tokenClaims(await getGraphAppToken()).roles || []);
  for (const [permission, broader] of Object.entries(GRAPH_PERMISSIONS[kind])) {
    if (!graphRoles.has(permission) && !broader.some((p) => graphRoles.has(p))) {
      missing.push({ api: 'Microsoft Graph', permission });
    }
  }
  { // Exchange : boîtes partagées (arrivée), boîte du collaborateur qui part (départ).
    let claims = {};
    try {
      claims = tokenClaims(await exchangeToken());
    } catch {
      // jeton Exchange impossible : signalé ci-dessous
    }
    if (!(claims.roles || []).includes('Exchange.ManageAsApp')) {
      missing.push({ api: 'Office 365 Exchange Online', permission: 'Exchange.ManageAsApp' });
    }
    // Le rôle Entra n'apparaît dans le jeton que s'il est déjà attribué.
    if (Array.isArray(claims.wids) && !claims.wids.some((id) => EXCHANGE_ROLES[id])) {
      missing.push({ api: 'Rôle Entra', permission: 'Exchange Recipient Administrator (attribué à l’application)' });
    }
  }
  return missing;
}

// ---------------------------------------------------------------------------
// Exchange Online (API d'administration utilisée par le module PowerShell)
// ---------------------------------------------------------------------------
async function exchangeToken() {
  const response = await fetch(`https://login.microsoftonline.com/${process.env.MICROSOFT_TENANT_ID}/oauth2/v2.0/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: process.env.MICROSOFT_CLIENT_ID,
      client_secret: process.env.MICROSOFT_CLIENT_SECRET,
      scope: 'https://outlook.office365.com/.default',
      grant_type: 'client_credentials'
    })
  });
  if (!response.ok) throw new Error(`Jeton Exchange Online impossible : ${(await response.text()).slice(0, 200)}`);
  return (await response.json()).access_token;
}

async function exchange(cmdletName, parameters) {
  const token = await exchangeToken();
  const response = await fetch(`https://outlook.office365.com/adminapi/beta/${process.env.MICROSOFT_TENANT_ID}/InvokeCommand`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'X-AnchorMailbox': `UPN:SystemMailbox{bb558c35-97f1-4cb9-8ff7-d53741dc928c}@${DOMAIN()}`
    },
    body: JSON.stringify({ CmdletInput: { CmdletName: cmdletName, Parameters: parameters } })
  });
  const text = await response.text();
  if (!response.ok) {
    let message = text.slice(0, 300);
    try {
      const json = JSON.parse(text);
      message = json?.error?.details?.[0]?.message || json?.error?.message || message;
    } catch {
      // réponse non JSON
    }
    throw new Error(
      response.status === 401 || response.status === 403
        ? `Exchange Online refuse l'accès (${response.status}) : autorisation Exchange.ManageAsApp ou rôle Exchange manquant. ${message}`
        : `Exchange Online ${response.status} : ${message}`
    );
  }
  return text ? JSON.parse(text) : null;
}

// ---------------------------------------------------------------------------
// Outils
// ---------------------------------------------------------------------------
function requireIT(req, res) {
  const user = req.session?.user;
  if (!user?.isIT && !user?.isITManager) {
    res.status(403).json({ error: 'Réservé au service informatique' });
    return false;
  }
  return true;
}

const letters = (value) =>
  String(value || '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z]/g, '');

const escapeHtml = (value) =>
  String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

const isValidUpn = (upn) => /^[a-z0-9][a-z0-9._-]*@[a-z0-9.-]+\.[a-z]{2,}$/i.test(String(upn || ''));

async function upnTaken(upn) {
  const value = upn.replace(/'/g, "''");
  const result = await graph(
    'GET',
    `/users?$select=id&$filter=${encodeURIComponent(`userPrincipalName eq '${value}' or mail eq '${value}'`)}`
  );
  return (result?.value || []).length > 0;
}

// Adresse au format pnom@domaine (Jean-Marc Le Gall -> jlegall), suffixe 2, 3… si prise.
async function suggestUpn(firstName, lastName) {
  const base = `${letters(firstName).slice(0, 1)}${letters(lastName)}`;
  if (!base) return null;
  for (let i = 1; i <= 9; i++) {
    const candidate = `${base}${i === 1 ? '' : i}@${DOMAIN()}`;
    if (!(await upnTaken(candidate))) return candidate;
  }
  return `${base}@${DOMAIN()}`;
}

async function loadMovement(movementId) {
  return (
    await pool.query(
      `SELECT m.*, e.first_name, e.last_name, e.email AS employee_email, e.microsoft_upn,
              e.microsoft_object_id, e.job_title AS employee_job_title
       FROM movements m LEFT JOIN employees e ON e.id = m.employee_id
       WHERE m.id = $1`,
      [movementId]
    )
  ).rows[0];
}

// Comptes Microsoft actifs (choix du manager, délégation de la boîte).
async function microsoftPeople() {
  return (
    await pool.query(
      `SELECT DISTINCT ON (microsoft_object_id) microsoft_object_id AS id,
              TRIM(CONCAT_WS(' ', first_name, last_name)) AS name, microsoft_upn AS upn
       FROM employees
       WHERE microsoft_object_id IS NOT NULL AND microsoft_upn IS NOT NULL AND COALESCE(account_enabled, true)
       ORDER BY microsoft_object_id`
    )
  ).rows.sort((a, b) => a.name.localeCompare(b.name, 'fr'));
}

// Boîtes pouvant être déléguées : boîtes partagées (comptes désactivés avec une
// adresse, comme le formulaire) et boîtes des utilisateurs actifs.
let sharedCache = { at: 0, value: null };
async function sharedMailboxes() {
  if (sharedCache.value && Date.now() - sharedCache.at < 10 * 60 * 1000) return sharedCache.value;
  const boxes = (await graphAll('/users?$select=id,displayName,mail,userPrincipalName,accountEnabled&$top=999'))
    .filter((u) => u.mail && u.userPrincipalName?.toLowerCase().endsWith(`@${DOMAIN()}`))
    .map((u) => ({ mail: u.mail.toLowerCase(), displayName: u.displayName || u.mail, kind: u.accountEnabled === false ? 'shared' : 'user' }))
    // Boîtes partagées d'abord, puis boîtes utilisateurs.
    .sort((a, b) => (a.kind === b.kind ? a.displayName.localeCompare(b.displayName, 'fr') : a.kind === 'shared' ? -1 : 1));
  sharedCache = { at: Date.now(), value: boxes };
  return boxes;
}

// Adresses saisies par le demandeur (champ « Boîtes partagées » rangé dans les notes).
function requestedMailboxAddresses(notes) {
  const text = String(notes || '').split(/Boîtes partagées demandées\s*:/i)[1] || '';
  return [...new Set((text.match(/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}/gi) || []).map((m) => m.toLowerCase()))];
}

let groupsCache = { at: 0, value: null };
async function selectableGroups() {
  if (groupsCache.value && Date.now() - groupsCache.at < 10 * 60 * 1000) return groupsCache.value;
  const groups = (await graphAll('/groups?$select=id,displayName,mail&$top=999'))
    .filter((g) => GROUP_PREFIXES.some((prefix) => g.displayName?.startsWith(prefix)))
    .map((g) => ({ id: g.id, displayName: g.displayName, mail: g.mail || null }))
    .sort((a, b) => a.displayName.localeCompare(b.displayName, 'fr'));
  groupsCache = { at: Date.now(), value: groups };
  return groups;
}

// Licences Microsoft du tenant (avec places restantes).
async function tenantLicenses() {
  return (
    await pool.query(
      `SELECT s.sku_id, s.display_name AS sku_part_number, COALESCE(lt.label, s.display_name) AS label, lt.id AS license_type_id,
              GREATEST(COALESCE(s.enabled_units, 0) - COALESCE(s.consumed_units, 0), 0)::int AS available
       FROM subscribed_skus s LEFT JOIN license_types lt ON lt.code = s.display_name
       WHERE s.sku_id IS NOT NULL AND COALESCE(s.enabled_units, 0) > 0
       ORDER BY label`
    )
  ).rows;
}

// Licences proposées à l'arrivée : celles activées dans Paramètres → Licences Microsoft.
async function onboardingLicenses() {
  return (
    await pool.query(
      `SELECT s.sku_id, s.display_name AS sku_part_number, COALESCE(lt.label, s.display_name) AS label, lt.id AS license_type_id,
              GREATEST(COALESCE(s.enabled_units, 0) - COALESCE(s.consumed_units, 0), 0)::int AS available
       FROM subscribed_skus s
       JOIN microsoft_license_filters f ON f.sku_part_number = s.display_name AND f.enabled
       LEFT JOIN license_types lt ON lt.code = s.display_name
       WHERE s.sku_id IS NOT NULL
       ORDER BY label`
    )
  ).rows;
}

async function requestedSkuIds(movementId) {
  return (
    await pool.query(
      `SELECT s.sku_id
       FROM movement_licenses ml
       JOIN license_types lt ON lt.id = ml.license_type_id
       JOIN subscribed_skus s ON s.display_name = lt.code
       WHERE ml.movement_id = $1 AND COALESCE(ml.status, 'requested') <> 'skipped' AND s.sku_id IS NOT NULL`,
      [movementId]
    )
  ).rows.map((r) => r.sku_id);
}

async function markActionsDone(movementId, actionTypes) {
  if (!actionTypes.length) return;
  await pool.query(
    `UPDATE movement_actions SET done_at = now()
     WHERE movement_id = $1 AND done_at IS NULL AND action_type = ANY($2::text[])`,
    [movementId, actionTypes]
  );
}

// Récapitulatif dans la check-list : une ligne cochée avec le détail en note.
async function addRecap(movementId, label, steps) {
  const notes = steps.map((s) => `${s.ok ? '✓' : '✗'} ${s.label}${s.error ? ` — ${s.error}` : ''}`).join('\n');
  await pool.query(
    `INSERT INTO movement_actions (movement_id, action_type, label, notes, done_at, sort_order)
     VALUES ($1, 'other', $2, $3, now(), 999)`,
    [movementId, label, notes]
  );
}

async function audit(req, action, movementId, details) {
  await pool
    .query(`INSERT INTO audit_log (actor_name, action, entity_type, entity_id, details) VALUES ($1, $2, 'movement', $3, $4::jsonb)`, [
      req.session.user.displayName || req.session.user.email || null,
      action,
      movementId,
      JSON.stringify(details)
    ])
    .catch((error) => console.error("[Microsoft] Journal d'audit impossible", error.message || error));
}

function stepRunner(steps) {
  return async (label, run) => {
    try {
      const detail = await run();
      steps.push({ label, ok: true, detail: typeof detail === 'string' ? detail : null });
      return true;
    } catch (error) {
      steps.push({ label, ok: false, error: error.message });
      return false;
    }
  };
}

// Compte Microsoft du collaborateur qui part : sa fiche, une fiche en double
// de même e-mail / UPN, ou à défaut une recherche par adresse.
async function resolveDepartingUser(movement) {
  const select = '$select=id,displayName,userPrincipalName,accountEnabled,assignedLicenses';
  if (movement.microsoft_object_id) {
    const user = await graphOrNull(`/users/${encodeURIComponent(movement.microsoft_object_id)}?${select}`);
    if (user) return user;
  }
  const emails = [movement.microsoft_upn, movement.employee_email].filter(Boolean).map((e) => e.toLowerCase());
  if (!emails.length) return null;
  const twin = (
    await pool.query(
      `SELECT microsoft_object_id FROM employees
       WHERE microsoft_object_id IS NOT NULL
         AND (lower(btrim(email)) = ANY($1::text[]) OR lower(btrim(microsoft_upn)) = ANY($1::text[]))
       LIMIT 1`,
      [emails]
    )
  ).rows[0];
  return graphOrNull(`/users/${encodeURIComponent(twin?.microsoft_object_id || emails[0])}?${select}`);
}

// Groupes modifiables par Graph : groupes Microsoft 365 et groupes de sécurité
// non messagerie, hors groupes dynamiques ou synchronisés depuis l'AD local.
function isManageableGroup(group) {
  const dynamic = (group.groupTypes || []).includes('DynamicMembership');
  const unified = (group.groupTypes || []).includes('Unified');
  return !dynamic && !group.onPremisesSyncEnabled && (unified || (group.securityEnabled && !group.mailEnabled));
}

async function userGroups(userId) {
  const groups = await graphAll(
    `/users/${encodeURIComponent(userId)}/memberOf/microsoft.graph.group?$select=id,displayName,groupTypes,mailEnabled,securityEnabled,onPremisesSyncEnabled&$top=999`
  );
  return groups.map((g) => ({ id: g.id, displayName: g.displayName, manageable: isManageableGroup(g) }));
}

async function skuLabels() {
  return new Map((await tenantLicenses()).map((l) => [String(l.sku_id).toLowerCase(), l.label]));
}

// ---------------------------------------------------------------------------
// Mail au manager à la clôture de l'arrivée
// ---------------------------------------------------------------------------
export async function notifyManagerOnboardingDone(movementId) {
  try {
    const movement = await loadMovement(movementId);
    if (!movement || movement.type !== 'onboarding' || !movement.manager_email) return;
    const groups = (
      await pool.query(`SELECT group_name FROM movement_service_groups WHERE movement_id = $1 ORDER BY group_name`, [movementId])
    ).rows.map((r) => r.group_name);
    const licenses = (
      await pool.query(
        `SELECT lt.label FROM movement_licenses ml JOIN license_types lt ON lt.id = ml.license_type_id
         WHERE ml.movement_id = $1 AND ml.status = 'assigned' ORDER BY lt.label`,
        [movementId]
      )
    ).rows.map((r) => r.label);
    const name = [movement.first_name, movement.last_name].filter(Boolean).join(' ');
    const arrival = movement.effective_date ? new Date(movement.effective_date).toLocaleDateString('fr-FR', { timeZone: 'Europe/Paris' }) : null;
    const list = (items) => (items.length ? `<ul>${items.map((i) => `<li>${escapeHtml(i)}</li>`).join('')}</ul>` : '<p>—</p>');

    await sendMailWithAttachments({
      to: movement.manager_email,
      subject: `Arrivée de ${name} : tout est prêt`,
      html: `<div style="font-family:Inter,'Segoe UI',Arial,sans-serif;font-size:14px;line-height:1.6;color:#32373c">
        <p>Bonjour ${escapeHtml(movement.manager_name || '')},</p>
        <p>L'arrivée de <strong>${escapeHtml(name)}</strong>${arrival ? ` (le ${escapeHtml(arrival)})` : ''} est finalisée par le service informatique.</p>
        ${
          movement.microsoft_upn
            ? `<p><strong>Identifiants Microsoft 365</strong><br>
               Adresse : <strong>${escapeHtml(movement.microsoft_upn)}</strong><br>
               Mot de passe provisoire : <strong>${escapeHtml(DEFAULT_PASSWORD())}</strong><br>
               <span style="color:#677082">Il devra être changé à la première connexion.</span></p>`
            : ''
        }
        <p><strong>Accès (groupes)</strong></p>${list(groups)}
        <p><strong>Licences</strong></p>${list(licenses)}
        <p>Pour toute question, contactez le service informatique.</p>
        <p>Cordialement,<br>Service Informatique</p>
      </div>`
    });
    await pool.query(
      `INSERT INTO movement_actions (movement_id, action_type, label, done_at, sort_order) VALUES ($1, 'other', $2, now(), 1000)`,
      [movementId, `Mail de fin d'arrivée envoyé au manager (${movement.manager_email})`]
    );
  } catch (error) {
    console.error("[Microsoft] Mail de fin d'arrivée au manager impossible", error.message || error);
  }
}

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------
export function registerMicrosoftProvisioningRoutes(app) {
  // ---- Onboarding : aperçu ----
  app.get('/api/movements/:id/microsoft-account', async (req, res) => {
    if (!requireIT(req, res)) return;
    try {
      const movement = await loadMovement(req.params.id);
      if (!movement || movement.type !== 'onboarding') return res.status(404).json({ error: 'Arrivée introuvable' });

      const requested = (
        await pool.query(
          `SELECT group_id AS id, group_name AS "displayName" FROM movement_service_groups WHERE movement_id = $1 ORDER BY created_at`,
          [movement.id]
        )
      ).rows;
      let threeCx = null;
      if (THREECX_GROUP_ID()) {
        const group = await graphOrNull(`/groups/${encodeURIComponent(THREECX_GROUP_ID())}?$select=id,displayName`);
        threeCx = group ? { id: group.id, displayName: group.displayName } : null;
      }
      const people = await microsoftPeople();
      let manager = null;
      if (movement.manager_email) {
        const email = movement.manager_email.toLowerCase();
        manager = people.find((p) => p.upn?.toLowerCase() === email) || null;
        if (!manager) {
          const user = await graphOrNull(`/users/${encodeURIComponent(movement.manager_email)}?$select=id,displayName,userPrincipalName`);
          if (user) manager = { id: user.id, name: user.displayName, upn: user.userPrincipalName };
        }
      }

      const allShared = await sharedMailboxes();
      res.json({
        existing: movement.microsoft_object_id ? { id: movement.microsoft_object_id, upn: movement.microsoft_upn } : null,
        givenName: formatFirstName(movement.first_name),
        surname: formatLastName(movement.last_name),
        displayName: formatDisplayName(movement.first_name, movement.last_name),
        jobTitle: formatJobTitle(movement.job_title || movement.employee_job_title || ''),
        upn: movement.microsoft_object_id ? movement.microsoft_upn : await suggestUpn(movement.first_name, movement.last_name),
        defaultPassword: DEFAULT_PASSWORD(),
        manager,
        people,
        requestedGroups: requested,
        groups: await selectableGroups(),
        threeCx,
        sharedMailboxes: allShared,
        requestedSharedMailboxes: requestedMailboxAddresses(movement.notes).map(
          (mail) => allShared.find((box) => box.mail === mail) || { mail, displayName: mail, unknown: true }
        ),
        requestedSkuIds: await requestedSkuIds(movement.id),
        licenses: await onboardingLicenses(),
        missingPermissions: await missingPermissions('onboarding').catch(() => [])
      });
    } catch (error) {
      console.error('[Microsoft] Aperçu création de compte', error);
      res.status(500).json({ error: error.message, missingPermissions: await missingPermissions('onboarding').catch(() => []) });
    }
  });

  // ---- Onboarding : création (ou reprise si le compte existe déjà) ----
  app.post('/api/movements/:id/microsoft-account', async (req, res) => {
    if (!requireIT(req, res)) return;
    const steps = [];
    const step = stepRunner(steps);
    let movement = null;
    try {
      movement = await loadMovement(req.params.id);
      if (!movement || movement.type !== 'onboarding') return res.status(404).json({ error: 'Arrivée introuvable' });
      if (!movement.employee_id) return res.status(400).json({ error: 'Aucune fiche collaborateur liée à cette arrivée' });

      const body = req.body || {};
      const groups = (Array.isArray(body.groups) ? body.groups : [])
        .filter((g) => g?.id)
        .map((g) => ({ id: String(g.id), displayName: String(g.displayName || g.id) }));
      const skuIds = Array.isArray(body.skuIds) ? body.skuIds.map(String) : [];
      let userId = movement.microsoft_object_id || null;
      let upn = movement.microsoft_upn || null;

      if (!userId) {
        upn = String(body.upn || '').trim().toLowerCase();
        const givenName = formatFirstName(body.givenName);
        const surname = formatLastName(body.surname);
        const displayName = formatDisplayName(givenName, surname);
        if (!isValidUpn(upn)) return res.status(400).json({ error: 'Adresse invalide' });
        if (!displayName) return res.status(400).json({ error: "Nom d'affichage obligatoire" });
        if (await upnTaken(upn)) return res.status(409).json({ error: `L'adresse ${upn} est déjà utilisée dans Microsoft 365` });

        const created = await graph('POST', '/users', {
          accountEnabled: true,
          displayName,
          givenName: givenName || undefined,
          surname: surname || undefined,
          jobTitle: formatJobTitle(body.jobTitle) || undefined,
          mailNickname: upn.split('@')[0].replace(/[^a-z0-9._-]/gi, ''),
          userPrincipalName: upn,
          usageLocation: USAGE_LOCATION(),
          passwordProfile: { password: DEFAULT_PASSWORD(), forceChangePasswordNextSignIn: true }
        });
        userId = created.id;
        steps.push({ label: `Compte créé : ${upn} (mot de passe à changer à la première connexion)`, ok: true });

        // La fiche de la demande reçoit l'identité Microsoft : la synchro des
        // utilisateurs la retrouve ensuite au lieu de créer un doublon.
        await pool.query(
          `UPDATE employees SET microsoft_object_id = $1, microsoft_upn = $2, email = COALESCE(email, $2),
                  first_name = COALESCE(NULLIF($4, ''), first_name), last_name = COALESCE(NULLIF($5, ''), last_name),
                  job_title = COALESCE(NULLIF($6, ''), job_title),
                  account_enabled = true, microsoft_synced_at = now(), updated_at = now()
           WHERE id = $3`,
          [userId, upn, movement.employee_id, givenName, surname, formatJobTitle(body.jobTitle)]
        );
      } else {
        steps.push({ label: `Compte existant repris : ${upn}`, ok: true });
      }

      const user = encodeURIComponent(userId);

      // Manager : le demandeur par défaut, ou la personne choisie par l'informatique.
      if (body.manager?.id) {
        const ok = await step(`Manager : ${body.manager.name || body.manager.upn}`, () =>
          withRetry(() => graph('PUT', `/users/${user}/manager/$ref`, { '@odata.id': `https://graph.microsoft.com/v1.0/users/${body.manager.id}` }))
        );
        if (ok && body.manager.upn && body.manager.upn.toLowerCase() !== String(movement.manager_email || '').toLowerCase()) {
          await pool.query(`UPDATE movements SET manager_name = $1, manager_email = $2, updated_at = now() WHERE id = $3`, [
            body.manager.name || null,
            body.manager.upn,
            movement.id
          ]);
        }
      }

      let groupsOk = true;
      let threeCxOk = false;
      for (const group of groups) {
        const is3cx = group.id === THREECX_GROUP_ID();
        const ok = await step(is3cx ? `Téléphonie 3CX : ${group.displayName}` : `Groupe ${group.displayName}`, async () => {
          try {
            await withRetry(() =>
              graph('POST', `/groups/${encodeURIComponent(group.id)}/members/$ref`, {
                '@odata.id': `https://graph.microsoft.com/v1.0/directoryObjects/${userId}`
              })
            );
          } catch (error) {
            if (error.status === 400 && /already exist/i.test(error.message)) return 'déjà membre';
            throw error;
          }
        });
        if (is3cx) threeCxOk = ok;
        else groupsOk = groupsOk && ok;
      }
      // La liste des groupes de l'arrivée reflète ce qui a été validé.
      const kept = groups.filter((g) => g.id !== THREECX_GROUP_ID());
      await pool.query(`DELETE FROM movement_service_groups WHERE movement_id = $1 AND NOT (group_id = ANY($2::text[]))`, [
        movement.id,
        kept.map((g) => g.id)
      ]);
      for (const group of kept) {
        await pool.query(
          `INSERT INTO movement_service_groups (movement_id, group_id, group_name)
           SELECT $1, $2, $3 WHERE NOT EXISTS (SELECT 1 FROM movement_service_groups WHERE movement_id = $1 AND group_id = $2)`,
          [movement.id, group.id, group.displayName]
        );
      }

      let licensesOk = true;
      const licenses = await tenantLicenses();
      for (const skuId of skuIds) {
        const license = licenses.find((l) => String(l.sku_id).toLowerCase() === skuId.toLowerCase());
        const ok = await step(`Licence ${license?.label || skuId}`, () =>
          withRetry(() => graph('POST', `/users/${user}/assignLicense`, { addLicenses: [{ skuId, disabledPlans: [] }], removeLicenses: [] }))
        );
        licensesOk = licensesOk && ok;
        if (ok && license?.license_type_id) {
          const updated = await pool.query(
            `UPDATE movement_licenses SET status = 'assigned', license_id = NULL WHERE movement_id = $1 AND license_type_id = $2`,
            [movement.id, license.license_type_id]
          );
          if (!updated.rowCount) {
            await pool.query(`INSERT INTO movement_licenses (movement_id, license_type_id, status) VALUES ($1, $2, 'assigned')`, [
              movement.id,
              license.license_type_id
            ]);
          }
        }
      }

      // Boîtes partagées : délégation (accès complet, et envoi « en tant que » au choix).
      // La boîte du nouveau collaborateur n'existe que quelques minutes après sa licence.
      const notYet = (error) =>
        /couldn't be found|could not be found|introuvable|n'a pas été trouvé|isn't a mailbox user/i.test(error.message)
          ? new Error("la boîte du collaborateur n'est pas encore créée par Microsoft (quelques minutes après la licence) : relancez « Compléter le compte Microsoft » dans 10 minutes")
          : error;
      const mailboxes = (Array.isArray(body.sharedMailboxes) ? body.sharedMailboxes : []).filter((box) => box?.mail);
      for (const box of mailboxes) {
        const name = box.displayName || box.mail;
        const ok = await step(`Boîte ${name} : accès complet`, () =>
          exchange('Add-MailboxPermission', { Identity: box.mail, User: upn, AccessRights: ['FullAccess'], InheritanceType: 'All', AutoMapping: true }).catch(
            (error) => {
              throw notYet(error);
            }
          )
        );
        if (ok && body.sharedSendAs) {
          await step(`Boîte ${name} : envoi « en tant que »`, () =>
            exchange('Add-RecipientPermission', { Identity: box.mail, Trustee: upn, AccessRights: ['SendAs'], Confirm: false }).catch((error) => {
              throw notYet(error);
            })
          );
        }
      }

      // Check-list : coche ce qui est fait et ajoute le récapitulatif.
      const done = ['account', 'creation'];
      if (groupsOk) done.push('groups');
      if (threeCxOk) done.push('telephony');
      const pendingLicenses = (
        await pool.query(
          `SELECT 1 FROM movement_licenses WHERE movement_id = $1 AND COALESCE(status, 'requested') NOT IN ('assigned', 'skipped') LIMIT 1`,
          [movement.id]
        )
      ).rowCount;
      if (licensesOk && !pendingLicenses) done.push('license', 'license_assignment');
      await markActionsDone(movement.id, done);
      await addRecap(movement.id, 'Récapitulatif Microsoft : création du compte', steps);
      if (['pending', 'envoye'].includes(movement.status)) {
        await pool.query(`UPDATE movements SET status = 'in_progress', updated_at = now() WHERE id = $1`, [movement.id]);
      }

      await audit(req, 'microsoft_account_create', movement.id, { upn, steps });
      res.json({ upn, temporaryPassword: DEFAULT_PASSWORD(), steps });
    } catch (error) {
      console.error('[Microsoft] Création de compte', error);
      steps.push({ label: 'Création du compte', ok: false, error: error.message });
      if (movement) await addRecap(movement.id, 'Récapitulatif Microsoft : création du compte (échec)', steps).catch(() => {});
      res.status(500).json({ error: error.message, steps, missingPermissions: await missingPermissions('onboarding').catch(() => []) });
    }
  });

  // ---- Offboarding : aperçu ----
  app.get('/api/movements/:id/microsoft-offboarding', async (req, res) => {
    if (!requireIT(req, res)) return;
    try {
      const movement = await loadMovement(req.params.id);
      if (!movement || movement.type !== 'offboarding') return res.status(404).json({ error: 'Départ introuvable' });
      const user = await resolveDepartingUser(movement);
      if (!user) return res.json({ user: null });
      const labels = await skuLabels();
      res.json({
        user: { id: user.id, displayName: user.displayName, upn: user.userPrincipalName, accountEnabled: user.accountEnabled },
        licenses: (user.assignedLicenses || []).map((l) => ({ skuId: l.skuId, label: labels.get(String(l.skuId).toLowerCase()) || l.skuId })),
        groups: await userGroups(user.id),
        people: (await microsoftPeople()).filter((p) => p.id !== user.id),
        managerUpn: movement.manager_email || null,
        missingPermissions: await missingPermissions('offboarding').catch(() => [])
      });
    } catch (error) {
      console.error('[Microsoft] Aperçu départ', error);
      res.status(500).json({ error: error.message, missingPermissions: await missingPermissions('offboarding').catch(() => []) });
    }
  });

  // ---- Offboarding : traitement ----
  app.post('/api/movements/:id/microsoft-offboarding', async (req, res) => {
    if (!requireIT(req, res)) return;
    const steps = [];
    const step = stepRunner(steps);
    let movement = null;
    try {
      movement = await loadMovement(req.params.id);
      if (!movement || movement.type !== 'offboarding') return res.status(404).json({ error: 'Départ introuvable' });
      const target = await resolveDepartingUser(movement);
      if (!target) return res.status(404).json({ error: 'Compte Microsoft du collaborateur introuvable' });
      const user = encodeURIComponent(target.id);
      const upn = target.userPrincipalName;
      const options = req.body || {};

      // 1. Réponse automatique (texte saisi à la validation).
      const replyMessage = String(options.autoReply || '').trim();
      if (replyMessage) {
        const html = escapeHtml(replyMessage).replace(/\n/g, '<br>');
        await step('Réponse automatique activée', () =>
          graph('PATCH', `/users/${user}/mailboxSettings`, {
            automaticRepliesSetting: { status: 'alwaysEnabled', externalAudience: 'all', internalReplyMessage: html, externalReplyMessage: html }
          })
        );
      }

      // 2. Boîte partagée, puis délégation (accès complet) à la personne désignée.
      let shared = false;
      if (options.convertToShared) {
        shared = await step('Boîte aux lettres convertie en boîte partagée', () => exchange('Set-Mailbox', { Identity: upn, Type: 'Shared' }));
      }
      const delegate = options.delegate?.upn ? options.delegate : null;
      if (delegate) {
        await step(`Délégation (accès complet) donnée à ${delegate.name || delegate.upn}`, () =>
          exchange('Add-MailboxPermission', {
            Identity: upn,
            User: delegate.upn,
            AccessRights: ['FullAccess'],
            InheritanceType: 'All',
            AutoMapping: true
          })
        );
        if (options.sendAs) {
          await step(`Envoi « en tant que » la boîte donné à ${delegate.name || delegate.upn}`, () =>
            exchange('Add-RecipientPermission', { Identity: upn, Trustee: delegate.upn, AccessRights: ['SendAs'], Confirm: false })
          );
        }
      }

      // Transfert des mails reçus (copie conservée dans la boîte).
      const forwardTo = String(options.forwardTo || '').trim().toLowerCase();
      if (forwardTo) {
        if (!/^[^\s@]+@[^\s@]+\.[a-z]{2,}$/i.test(forwardTo)) {
          steps.push({ label: 'Transfert des mails', ok: false, error: `adresse invalide : ${forwardTo}` });
        } else {
          await step(`Mails transférés vers ${forwardTo} (copie conservée dans la boîte)`, () =>
            exchange('Set-Mailbox', { Identity: upn, ForwardingSmtpAddress: `smtp:${forwardTo}`, DeliverToMailboxAndForward: true })
          );
        }
      }

      // 3. Blocage et déconnexion.
      if (options.block) {
        const ok = await step('Connexion bloquée', () => graph('PATCH', `/users/${user}`, { accountEnabled: false }));
        if (ok) await pool.query(`UPDATE employees SET account_enabled = false, updated_at = now() WHERE microsoft_object_id = $1`, [target.id]);
      }
      if (options.revokeSessions) {
        await step('Sessions déconnectées (ordinateurs, téléphones, Teams…)', () => graph('POST', `/users/${user}/revokeSignInSessions`));
      }

      // 4. Groupes.
      if (options.removeGroups) {
        for (const group of (await userGroups(target.id)).filter((g) => g.manageable)) {
          await step(`Retiré du groupe ${group.displayName}`, () => graph('DELETE', `/groups/${encodeURIComponent(group.id)}/members/${user}/$ref`));
        }
      }

      // 5. Licences : seulement si la boîte est partagée (sinon elle serait supprimée au bout de 30 jours).
      if (options.removeLicenses && (target.assignedLicenses || []).length) {
        if (options.convertToShared && !shared) {
          steps.push({ label: 'Licences conservées', ok: false, error: "la conversion en boîte partagée a échoué : la boîte serait supprimée sans licence" });
        } else {
          const labels = await skuLabels();
          const skuIds = target.assignedLicenses.map((l) => l.skuId);
          const ok = await step(`Licences retirées : ${skuIds.map((id) => labels.get(String(id).toLowerCase()) || id).join(', ')}`, () =>
            graph('POST', `/users/${user}/assignLicense`, { addLicenses: [], removeLicenses: skuIds })
          );
          if (ok) await markActionsDone(movement.id, ['license', 'license_assignment']);
        }
      }

      await addRecap(movement.id, 'Récapitulatif Microsoft : désactivation du compte', steps);
      await audit(req, 'microsoft_account_offboard', movement.id, { upn, steps });
      res.json({ upn, steps });
    } catch (error) {
      console.error('[Microsoft] Départ', error);
      steps.push({ label: 'Traitement du départ', ok: false, error: error.message });
      if (movement) await addRecap(movement.id, 'Récapitulatif Microsoft : désactivation (échec)', steps).catch(() => {});
      res.status(500).json({ error: error.message, steps, missingPermissions: await missingPermissions('offboarding').catch(() => []) });
    }
  });
}
