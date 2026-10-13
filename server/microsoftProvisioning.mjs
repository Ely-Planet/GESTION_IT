// Automatisation Microsoft (Graph) depuis « Arrivées & Départs ».
//
// Onboarding : création du compte Entra ID (mot de passe provisoire à changer),
// manager, groupes demandés + groupe de synchro 3CX, licences Microsoft.
// Offboarding : réponse automatique, blocage de la connexion, déconnexion
// des sessions, retrait des groupes et (au choix) des licences.
//
// Chaque action est d'abord présentée (aperçu) puis lancée par l'informatique.
// Permissions d'application Graph nécessaires : User.ReadWrite.All,
// GroupMember.ReadWrite.All, LicenseAssignment.ReadWrite.All,
// User.RevokeSessions.All, MailboxSettings.ReadWrite.
//
// Variables d'environnement (facultatives) :
//   MICROSOFT_USER_DOMAIN      domaine des adresses (défaut : elyade.com)
//   MICROSOFT_USAGE_LOCATION   pays des licences (défaut : FR)
//   MICROSOFT_3CX_GROUP_ID     groupe Microsoft synchronisé par le 3CX
import crypto from 'crypto';
import { pool } from './db.mjs';
import { getGraphAppToken } from './graphMail.mjs';

const DOMAIN = () => String(process.env.MICROSOFT_USER_DOMAIN || 'elyade.com').toLowerCase();
const USAGE_LOCATION = () => process.env.MICROSOFT_USAGE_LOCATION || 'FR';
const THREECX_GROUP_ID = () => process.env.MICROSOFT_3CX_GROUP_ID || null;

// ---------------------------------------------------------------------------
// Microsoft Graph
// ---------------------------------------------------------------------------
async function graph(method, url, body) {
  const token = await getGraphAppToken();
  const response = await fetch(`https://graph.microsoft.com/v1.0${url}`, {
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
      response.status === 403
        ? `Permission Microsoft Graph manquante (403) : ${message}`
        : `Microsoft Graph ${response.status} : ${message}`
    );
    error.status = response.status;
    throw error;
  }
  if (response.status === 202 || response.status === 204) return null;
  const text = await response.text();
  return text ? JSON.parse(text) : null;
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

async function graphOrNull(url) {
  try {
    return await graph('GET', url);
  } catch (error) {
    if (error.status === 404) return null;
    throw error;
  }
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

// "Jean-Marc Dupont" -> "jean-marc.dupont"
function slug(value) {
  return String(value || '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9-]+/g, '')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}

const isValidUpn = (upn) => /^[a-z0-9][a-z0-9._-]*@[a-z0-9.-]+\.[a-z]{2,}$/i.test(String(upn || ''));

// Mot de passe provisoire : 16 caractères, majuscules, minuscules, chiffres, symboles.
function temporaryPassword() {
  const sets = ['ABCDEFGHJKLMNPQRSTUVWXYZ', 'abcdefghijkmnopqrstuvwxyz', '23456789', '!@#$%*?-+='];
  const all = sets.join('');
  const chars = sets.map((set) => set[crypto.randomInt(set.length)]);
  while (chars.length < 16) chars.push(all[crypto.randomInt(all.length)]);
  for (let i = chars.length - 1; i > 0; i--) {
    const j = crypto.randomInt(i + 1);
    [chars[i], chars[j]] = [chars[j], chars[i]];
  }
  return chars.join('');
}

async function upnTaken(upn) {
  const value = upn.replace(/'/g, "''");
  const result = await graph(
    'GET',
    `/users?$select=id&$filter=${encodeURIComponent(`userPrincipalName eq '${value}' or mail eq '${value}'`)}`
  );
  return (result?.value || []).length > 0;
}

async function suggestUpn(firstName, lastName) {
  const base = [slug(firstName), slug(lastName)].filter(Boolean).join('.');
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

// Licences Microsoft demandées : type de licence dont le code est un SKU du tenant.
async function requestedMicrosoftLicenses(movementId) {
  return (
    await pool.query(
      `SELECT ml.id AS movement_license_id, lt.label, s.sku_id, s.display_name AS sku_part_number,
              GREATEST(COALESCE(s.enabled_units, 0) - COALESCE(s.consumed_units, 0), 0)::int AS available
       FROM movement_licenses ml
       JOIN license_types lt ON lt.id = ml.license_type_id
       JOIN subscribed_skus s ON s.display_name = lt.code
       WHERE ml.movement_id = $1 AND COALESCE(ml.status, 'requested') <> 'skipped' AND s.sku_id IS NOT NULL
       ORDER BY lt.label`,
      [movementId]
    )
  ).rows;
}

async function markActionsDone(movementId, actionTypes) {
  if (!actionTypes.length) return;
  await pool.query(
    `UPDATE movement_actions SET done_at = now()
     WHERE movement_id = $1 AND done_at IS NULL AND action_type = ANY($2::text[])`,
    [movementId, actionTypes]
  );
}

async function audit(req, action, movementId, details) {
  await pool
    .query(
      `INSERT INTO audit_log (actor_name, action, entity_type, entity_id, details) VALUES ($1, $2, 'movement', $3, $4::jsonb)`,
      [req.session.user.displayName || req.session.user.email || null, action, movementId, JSON.stringify(details)]
    )
    .catch((error) => console.error('[Microsoft] Journal d\'audit impossible', error.message || error));
}

// Compte Microsoft du collaborateur qui part : sa fiche, ou une fiche en double
// de même e-mail / UPN, ou à défaut une recherche par adresse.
async function resolveDepartingUser(movement) {
  if (movement.microsoft_object_id) {
    const user = await graphOrNull(
      `/users/${encodeURIComponent(movement.microsoft_object_id)}?$select=id,displayName,userPrincipalName,accountEnabled,assignedLicenses`
    );
    if (user) return user;
  }
  const emails = [movement.microsoft_upn, movement.employee_email].filter(Boolean).map((e) => e.toLowerCase());
  if (emails.length) {
    const twin = (
      await pool.query(
        `SELECT microsoft_object_id FROM employees
         WHERE microsoft_object_id IS NOT NULL
           AND (lower(btrim(email)) = ANY($1::text[]) OR lower(btrim(microsoft_upn)) = ANY($1::text[]))
         LIMIT 1`,
        [emails]
      )
    ).rows[0];
    const id = twin?.microsoft_object_id || emails[0];
    return graphOrNull(`/users/${encodeURIComponent(id)}?$select=id,displayName,userPrincipalName,accountEnabled,assignedLicenses`);
  }
  return null;
}

// Groupes modifiables par Graph : groupes Microsoft 365 et groupes de sécurité
// non messagerie, hors groupes dynamiques ou synchronisés depuis l'AD local.
function isManageableGroup(group) {
  const dynamic = (group.groupTypes || []).includes('DynamicMembership');
  const unified = (group.groupTypes || []).includes('Unified');
  return !dynamic && !group.onPremisesSyncEnabled && (unified || (group.securityEnabled && !group.mailEnabled));
}

async function userGroups(userId) {
  const page = await graph(
    'GET',
    `/users/${encodeURIComponent(userId)}/memberOf/microsoft.graph.group?$select=id,displayName,groupTypes,mailEnabled,securityEnabled,onPremisesSyncEnabled&$top=999`
  );
  return (page?.value || []).map((g) => ({ id: g.id, displayName: g.displayName, manageable: isManageableGroup(g) }));
}

async function skuLabels() {
  const rows = (
    await pool.query(
      `SELECT s.sku_id, s.display_name, lt.label
       FROM subscribed_skus s LEFT JOIN license_types lt ON lt.code = s.display_name`
    )
  ).rows;
  return new Map(rows.map((r) => [String(r.sku_id).toLowerCase(), r.label || r.display_name]));
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

      const groups = (
        await pool.query(
          `SELECT group_id AS id, group_name AS "displayName" FROM movement_service_groups WHERE movement_id = $1 ORDER BY created_at`,
          [movement.id]
        )
      ).rows;
      let threeCx = null;
      if (THREECX_GROUP_ID()) {
        const group = await graphOrNull(`/groups/${encodeURIComponent(THREECX_GROUP_ID())}?$select=id,displayName`);
        threeCx = group ? { id: group.id, displayName: group.displayName } : { id: THREECX_GROUP_ID(), displayName: 'Groupe 3CX introuvable', missing: true };
      }
      let manager = null;
      if (movement.manager_email) {
        const user = await graphOrNull(`/users/${encodeURIComponent(movement.manager_email)}?$select=id,displayName,userPrincipalName`);
        if (user) manager = { id: user.id, displayName: user.displayName, upn: user.userPrincipalName };
      }

      res.json({
        existing: movement.microsoft_object_id ? { id: movement.microsoft_object_id, upn: movement.microsoft_upn } : null,
        givenName: movement.first_name || '',
        surname: movement.last_name || '',
        displayName: [movement.first_name, movement.last_name].filter(Boolean).join(' '),
        jobTitle: movement.job_title || movement.employee_job_title || '',
        upn: movement.microsoft_object_id ? movement.microsoft_upn : await suggestUpn(movement.first_name, movement.last_name),
        domain: DOMAIN(),
        manager,
        managerName: movement.manager_name || null,
        groups,
        threeCx,
        licenses: await requestedMicrosoftLicenses(movement.id)
      });
    } catch (error) {
      console.error('[Microsoft] Aperçu création de compte', error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Onboarding : création (ou reprise si le compte existe déjà) ----
  app.post('/api/movements/:id/microsoft-account', async (req, res) => {
    if (!requireIT(req, res)) return;
    const steps = [];
    const step = async (label, run) => {
      try {
        const detail = await run();
        steps.push({ label, ok: true, detail: detail || null });
        return true;
      } catch (error) {
        steps.push({ label, ok: false, error: error.message });
        return false;
      }
    };
    try {
      const movement = await loadMovement(req.params.id);
      if (!movement || movement.type !== 'onboarding') return res.status(404).json({ error: 'Arrivée introuvable' });
      if (!movement.employee_id) return res.status(400).json({ error: "Aucune fiche collaborateur liée à cette arrivée" });

      const body = req.body || {};
      const groupIds = Array.isArray(body.groupIds) ? body.groupIds.map(String) : [];
      const skuIds = Array.isArray(body.skuIds) ? body.skuIds.map(String) : [];
      let userId = movement.microsoft_object_id || null;
      let upn = movement.microsoft_upn || null;
      let password = null;

      if (!userId) {
        upn = String(body.upn || '').trim().toLowerCase();
        const givenName = String(body.givenName || '').trim();
        const surname = String(body.surname || '').trim();
        const displayName = String(body.displayName || `${givenName} ${surname}`).trim();
        if (!isValidUpn(upn)) return res.status(400).json({ error: 'Adresse (UPN) invalide' });
        if (!displayName) return res.status(400).json({ error: "Nom d'affichage obligatoire" });
        if (await upnTaken(upn)) return res.status(409).json({ error: `L'adresse ${upn} est déjà utilisée dans Microsoft 365` });

        password = temporaryPassword();
        const created = await graph('POST', '/users', {
          accountEnabled: true,
          displayName,
          givenName: givenName || undefined,
          surname: surname || undefined,
          jobTitle: String(body.jobTitle || '').trim() || undefined,
          mailNickname: upn.split('@')[0].replace(/[^a-z0-9._-]/gi, ''),
          userPrincipalName: upn,
          usageLocation: USAGE_LOCATION(),
          passwordProfile: { password, forceChangePasswordNextSignIn: true }
        });
        userId = created.id;
        steps.push({ label: `Compte créé : ${upn}`, ok: true });

        // La fiche de la demande reçoit l'identité Microsoft : la synchro des
        // utilisateurs la retrouve ensuite au lieu de créer un doublon.
        await pool.query(
          `UPDATE employees SET microsoft_object_id = $1, microsoft_upn = $2, email = COALESCE(email, $2),
                  account_enabled = true, microsoft_synced_at = now(), updated_at = now()
           WHERE id = $3`,
          [userId, upn, movement.employee_id]
        );
      } else {
        steps.push({ label: `Compte existant repris : ${upn}`, ok: true });
      }

      const user = encodeURIComponent(userId);

      if (body.managerId) {
        await step('Manager renseigné', () =>
          withRetry(() =>
            graph('PUT', `/users/${user}/manager/$ref`, { '@odata.id': `https://graph.microsoft.com/v1.0/users/${body.managerId}` })
          )
        );
      }

      const groupNames = new Map(
        (await pool.query(`SELECT group_id, group_name FROM movement_service_groups WHERE movement_id = $1`, [movement.id])).rows.map((g) => [
          g.group_id,
          g.group_name
        ])
      );
      let groupsOk = true;
      let threeCxOk = false;
      for (const groupId of groupIds) {
        const is3cx = groupId === THREECX_GROUP_ID();
        const label = is3cx ? 'Groupe 3CX (création du poste par la synchro 3CX)' : `Groupe ${groupNames.get(groupId) || groupId}`;
        const ok = await step(label, async () => {
          try {
            await withRetry(() =>
              graph('POST', `/groups/${encodeURIComponent(groupId)}/members/$ref`, {
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

      let licensesOk = true;
      if (skuIds.length) {
        const labels = await skuLabels();
        for (const skuId of skuIds) {
          const ok = await step(`Licence ${labels.get(skuId.toLowerCase()) || skuId}`, () =>
            withRetry(() =>
              graph('POST', `/users/${user}/assignLicense`, { addLicenses: [{ skuId, disabledPlans: [] }], removeLicenses: [] })
            )
          );
          licensesOk = licensesOk && ok;
          if (ok) {
            await pool.query(
              `UPDATE movement_licenses ml SET status = 'assigned', license_id = NULL
               FROM license_types lt, subscribed_skus s
               WHERE ml.movement_id = $1 AND lt.id = ml.license_type_id AND s.display_name = lt.code AND lower(s.sku_id) = lower($2)`,
              [movement.id, skuId]
            );
          }
        }
      }

      // Check-list : coche ce qui est fait.
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
      if (movement.status === 'pending' || movement.status === 'envoye') {
        await pool.query(`UPDATE movements SET status = 'in_progress', updated_at = now() WHERE id = $1`, [movement.id]);
      }

      await audit(req, 'microsoft_account_create', movement.id, { upn, steps });
      res.json({ upn, temporaryPassword: password, steps });
    } catch (error) {
      console.error('[Microsoft] Création de compte', error);
      steps.push({ label: 'Création du compte', ok: false, error: error.message });
      res.status(error.status === 403 ? 502 : 500).json({ error: error.message, steps });
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
        defaultReply:
          `Bonjour,\n\n${user.displayName} ne fait plus partie d'ELYADE.` +
          (movement.manager_email ? ` Pour toute demande, merci de contacter ${movement.manager_email}.` : '') +
          `\n\nCordialement,`
      });
    } catch (error) {
      console.error('[Microsoft] Aperçu départ', error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Offboarding : désactivation ----
  app.post('/api/movements/:id/microsoft-offboarding', async (req, res) => {
    if (!requireIT(req, res)) return;
    const steps = [];
    const step = async (label, run) => {
      try {
        await run();
        steps.push({ label, ok: true });
        return true;
      } catch (error) {
        steps.push({ label, ok: false, error: error.message });
        return false;
      }
    };
    try {
      const movement = await loadMovement(req.params.id);
      if (!movement || movement.type !== 'offboarding') return res.status(404).json({ error: 'Départ introuvable' });
      const target = await resolveDepartingUser(movement);
      if (!target) return res.status(404).json({ error: 'Compte Microsoft du collaborateur introuvable' });
      const user = encodeURIComponent(target.id);
      const options = req.body || {};

      // La réponse automatique passe en premier : la boîte doit encore avoir sa licence.
      const replyMessage = String(options.autoReply || '').trim();
      if (replyMessage) {
        const html = replyMessage
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/\n/g, '<br>');
        await step('Réponse automatique activée', () =>
          graph('PATCH', `/users/${user}/mailboxSettings`, {
            automaticRepliesSetting: { status: 'alwaysEnabled', externalAudience: 'all', internalReplyMessage: html, externalReplyMessage: html }
          })
        );
      }
      if (options.block) {
        const ok = await step('Connexion bloquée', () => graph('PATCH', `/users/${user}`, { accountEnabled: false }));
        if (ok) await pool.query(`UPDATE employees SET account_enabled = false, updated_at = now() WHERE microsoft_object_id = $1`, [target.id]);
      }
      if (options.revokeSessions) {
        await step('Sessions déconnectées (ordinateurs, téléphones, Teams…)', () => graph('POST', `/users/${user}/revokeSignInSessions`));
      }
      if (options.removeGroups) {
        for (const group of (await userGroups(target.id)).filter((g) => g.manageable)) {
          await step(`Retiré du groupe ${group.displayName}`, () =>
            graph('DELETE', `/groups/${encodeURIComponent(group.id)}/members/${user}/$ref`)
          );
        }
      }
      if (options.removeLicenses && (target.assignedLicenses || []).length) {
        const labels = await skuLabels();
        const skuIds = target.assignedLicenses.map((l) => l.skuId);
        await step(`Licences retirées : ${skuIds.map((id) => labels.get(String(id).toLowerCase()) || id).join(', ')}`, () =>
          graph('POST', `/users/${user}/assignLicense`, { addLicenses: [], removeLicenses: skuIds })
        );
      }

      await audit(req, 'microsoft_account_offboard', movement.id, { upn: target.userPrincipalName, steps });
      res.json({ upn: target.userPrincipalName, steps });
    } catch (error) {
      console.error('[Microsoft] Départ', error);
      res.status(500).json({ error: error.message, steps });
    }
  });
}
