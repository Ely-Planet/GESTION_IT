// Suivi des contrats informatiques (remplace la liste SharePoint « Suivi des
// contrats SI »). Réservé au groupe « 🔐 Manager Informatique » (isITManager).
//
// Prochaine échéance : un contrat à tacite reconduction dont la date de fin est
// passée est reconduit d'une période (durée d'engagement, à défaut 1 an) ;
// la date limite de résiliation = échéance - préavis.
// Alerte par mail avant la date limite de résiliation (90, 30 puis 7 jours),
// adressée à CONTRACTS_ALERT_EMAIL (défaut : informatique@elyade.com).
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from './db.mjs';
import { sendMailWithAttachments } from './graphMail.mjs';
import { supplierKey } from './suppliers.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SEED_FILE = path.join(__dirname, 'data', 'contractsSeed.json');
const ALERT_EMAIL = () => process.env.CONTRACTS_ALERT_EMAIL || 'informatique@elyade.com';
const STATUSES = ['Actif', 'À renouveler', 'En cours de résiliation', 'Résilié'];

const SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS contracts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  label text NOT NULL,
  supplier_id uuid REFERENCES inventory_suppliers(id) ON DELETE SET NULL,
  category text,
  start_date date,
  commitment_months integer,
  tacit_renewal boolean NOT NULL DEFAULT false,
  notice_months integer,
  renewal_date date,
  termination_deadline date,
  end_date date,
  status text NOT NULL DEFAULT 'Actif',
  annual_cost numeric(12, 2),
  notes text,
  alert_level integer NOT NULL DEFAULT 0,
  alert_for date,
  created_by text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS app_flags (key text PRIMARY KEY, created_at timestamptz NOT NULL DEFAULT now());
`;

// Fournisseur de la liste commune d'après le libellé (« XEFI - Microsoft » -> XEFI).
async function matchSupplier(label) {
  const candidate = supplierKey(String(label || '').split(/\s[-+]\s/)[0]);
  if (!candidate) return null;
  const suppliers = (await pool.query(`SELECT id, label FROM inventory_suppliers`)).rows.map((s) => ({ ...s, key: supplierKey(s.label) }));
  return (
    suppliers.find((s) => s.key === candidate) ||
    suppliers.find((s) => candidate.length >= 3 && (s.key.startsWith(candidate) || s.key.endsWith(candidate))) ||
    suppliers.find((s) => s.key.length >= 5 && candidate.startsWith(s.key)) ||
    null
  )?.id || null;
}

async function seedOnce() {
  const flag = await pool.query(`INSERT INTO app_flags (key) VALUES ('contracts_seeded') ON CONFLICT DO NOTHING RETURNING key`);
  if (!flag.rowCount || !fs.existsSync(SEED_FILE)) return;
  const rows = JSON.parse(fs.readFileSync(SEED_FILE, 'utf8'));
  for (const r of rows) {
    await pool.query(
      `INSERT INTO contracts (label, supplier_id, category, start_date, commitment_months, tacit_renewal, notice_months,
                              renewal_date, termination_deadline, end_date, status, annual_cost, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, 'Reprise SharePoint')`,
      [r.label, await matchSupplier(r.label), r.category, r.start_date, r.commitment_months, Boolean(r.tacit_renewal), r.notice_months,
        r.renewal_date, r.termination_deadline, r.end_date, r.status || 'Actif', r.annual_cost]
    );
  }
  console.log(`[Contrats] ${rows.length} contrat(s) repris de la liste SharePoint`);
}

// ---------------------------------------------------------------------------
// Échéances
// ---------------------------------------------------------------------------
const toDate = (iso) => (iso ? new Date(`${iso}T00:00:00Z`) : null);
const toIso = (date) => (date ? date.toISOString().slice(0, 10) : null);
function addMonths(date, months) {
  const d = new Date(date);
  const day = d.getUTCDate();
  d.setUTCDate(1);
  d.setUTCMonth(d.getUTCMonth() + months);
  const last = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 0)).getUTCDate();
  d.setUTCDate(Math.min(day, last));
  return d;
}
const todayUtc = () => {
  const now = new Date();
  return new Date(Date.UTC(now.getFullYear(), now.getMonth(), now.getDate()));
};

export function contractTerms(c, today = todayUtc()) {
  let end = toDate(c.end_date);
  let rolled = false;
  if (end && c.tacit_renewal && end < today) {
    const period = c.commitment_months > 0 ? c.commitment_months : 12;
    while (end < today) end = addMonths(end, period);
    rolled = true;
  }
  const stored = toDate(c.termination_deadline);
  const notice = Number(c.notice_months) || 0;
  // Après reconduction, la date limite est recalculée ; sinon celle saisie prime.
  const deadline = rolled || !stored ? (end ? addMonths(end, -notice) : stored) : stored;
  const days = deadline ? Math.round((deadline - today) / 86400000) : null;
  return {
    next_end_date: toIso(end),
    next_deadline: toIso(deadline),
    days_to_deadline: days,
    rolled,
    inconsistent: Boolean(toDate(c.end_date) && stored && stored > toDate(c.end_date))
  };
}

const alertLevel = (days) => (days === null || days < 0 ? 0 : days <= 7 ? 3 : days <= 30 ? 2 : days <= 90 ? 1 : 0);

const SELECT = `
  SELECT c.id, c.label, c.supplier_id, s.label AS supplier, c.category,
         to_char(c.start_date, 'YYYY-MM-DD') AS start_date, c.commitment_months, c.tacit_renewal, c.notice_months,
         to_char(c.renewal_date, 'YYYY-MM-DD') AS renewal_date, to_char(c.termination_deadline, 'YYYY-MM-DD') AS termination_deadline,
         to_char(c.end_date, 'YYYY-MM-DD') AS end_date, c.status, c.annual_cost::float8 AS annual_cost, c.notes,
         c.updated_at,
         -- Dépenses du fournisseur sur l'exercice en cours (avril - mars).
         (SELECT COALESCE(SUM(e.amount), 0)::float8 FROM expenses e
          WHERE s.label IS NOT NULL AND lower(btrim(e.supplier)) = lower(btrim(s.label))
            AND e.fiscal_year = CASE WHEN EXTRACT(MONTH FROM now()) >= 4
                                     THEN EXTRACT(YEAR FROM now())::int || '-' || (EXTRACT(YEAR FROM now())::int + 1)
                                     ELSE (EXTRACT(YEAR FROM now())::int - 1) || '-' || EXTRACT(YEAR FROM now())::int END) AS supplier_spent_fy
  FROM contracts c LEFT JOIN inventory_suppliers s ON s.id = c.supplier_id`;

const withTerms = (row) => ({ ...row, ...contractTerms(row) });

function requireITManager(req, res, next) {
  if (!req.session?.user?.isITManager) return res.status(403).json({ error: 'Réservé au groupe Manager Informatique' });
  next();
}

const isIsoDate = (v) => /^\d{4}-\d{2}-\d{2}$/.test(String(v || ''));
function readContract(body) {
  const optionalDate = (v) => (v ? String(v) : null);
  const optionalInt = (v) => (v === '' || v === null || v === undefined ? null : Number(v));
  const value = {
    label: String(body.label || '').trim(),
    supplier_id: body.supplier_id || null,
    category: String(body.category || '').trim() || null,
    start_date: optionalDate(body.start_date),
    commitment_months: optionalInt(body.commitment_months),
    tacit_renewal: Boolean(body.tacit_renewal),
    notice_months: optionalInt(body.notice_months),
    renewal_date: optionalDate(body.renewal_date),
    termination_deadline: optionalDate(body.termination_deadline),
    end_date: optionalDate(body.end_date),
    status: STATUSES.includes(body.status) ? body.status : 'Actif',
    annual_cost: body.annual_cost === '' || body.annual_cost === null || body.annual_cost === undefined
      ? null
      : Number(String(body.annual_cost).replace(/\s/g, '').replace(',', '.')),
    notes: String(body.notes || '').trim() || null
  };
  if (!value.label) return { error: 'Nom du contrat obligatoire' };
  for (const key of ['start_date', 'renewal_date', 'termination_deadline', 'end_date']) {
    if (value[key] && !isIsoDate(value[key])) return { error: 'Date invalide' };
  }
  for (const key of ['commitment_months', 'notice_months']) {
    if (value[key] !== null && (!Number.isInteger(value[key]) || value[key] < 0)) return { error: 'Durée invalide (en mois)' };
  }
  if (value.annual_cost !== null && !Number.isFinite(value.annual_cost)) return { error: 'Coût annuel invalide' };
  return { value };
}

const COLUMNS = ['label', 'supplier_id', 'category', 'start_date', 'commitment_months', 'tacit_renewal', 'notice_months', 'renewal_date',
  'termination_deadline', 'end_date', 'status', 'annual_cost', 'notes'];

// ---------------------------------------------------------------------------
// Alertes par mail avant la date limite de résiliation
// ---------------------------------------------------------------------------
async function sendDeadlineAlerts() {
  const rows = (await pool.query(`${SELECT} WHERE c.status IN ('Actif', 'À renouveler')`)).rows.map(withTerms);
  const due = [];
  for (const row of rows) {
    const level = alertLevel(row.days_to_deadline);
    if (!level) continue;
    const current = (await pool.query(`SELECT alert_level, to_char(alert_for, 'YYYY-MM-DD') AS alert_for FROM contracts WHERE id = $1`, [row.id])).rows[0];
    if (current.alert_for === row.next_deadline && current.alert_level >= level) continue;
    due.push({ row, level });
  }
  if (!due.length) return;
  const fr = (iso) => (iso ? new Date(`${iso}T00:00:00Z`).toLocaleDateString('fr-FR', { timeZone: 'UTC' }) : '—');
  const lines = due
    .sort((a, b) => a.row.days_to_deadline - b.row.days_to_deadline)
    .map(
      ({ row }) => `<tr>
        <td style="padding:6px 10px;border-bottom:1px solid #eceef1"><strong>${row.label}</strong>${row.supplier ? `<br><span style="color:#677082">${row.supplier}</span>` : ''}</td>
        <td style="padding:6px 10px;border-bottom:1px solid #eceef1">${fr(row.next_deadline)}<br><span style="color:#ca0088">dans ${row.days_to_deadline} jour(s)</span></td>
        <td style="padding:6px 10px;border-bottom:1px solid #eceef1">${fr(row.next_end_date)}${row.tacit_renewal ? '<br><span style="color:#677082">tacite reconduction</span>' : ''}</td>
        <td style="padding:6px 10px;border-bottom:1px solid #eceef1;text-align:right">${row.annual_cost !== null ? row.annual_cost.toLocaleString('fr-FR', { style: 'currency', currency: 'EUR' }) : '—'}</td>
      </tr>`
    )
    .join('');
  await sendMailWithAttachments({
    to: ALERT_EMAIL(),
    subject: `Contrats : ${due.length} date(s) limite de résiliation à venir`,
    html: `<div style="font-family:Inter,'Segoe UI',Arial,sans-serif;font-size:14px;color:#32373c">
      <p>Bonjour,</p>
      <p>Les contrats suivants approchent de leur date limite de résiliation. Sans action, ceux en tacite reconduction seront renouvelés.</p>
      <table style="border-collapse:collapse;font-size:13px">
        <tr style="background:#f6f7f9;color:#677082;text-align:left"><th style="padding:6px 10px">Contrat</th><th style="padding:6px 10px">Résilier avant le</th><th style="padding:6px 10px">Échéance</th><th style="padding:6px 10px;text-align:right">Coût annuel</th></tr>
        ${lines}
      </table>
      <p style="margin-top:16px">Suivi complet dans GESTION_IT → Suivi des contrats.</p>
    </div>`
  });
  for (const { row, level } of due) {
    await pool.query(`UPDATE contracts SET alert_level = $1, alert_for = $2 WHERE id = $3`, [level, row.next_deadline, row.id]);
  }
  console.log(`[Contrats] Alerte envoyée pour ${due.length} contrat(s)`);
}

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------
export function registerContractRoutes(app, { after = Promise.resolve() } = {}) {
  // Après la mise à jour de la liste commune des fournisseurs (module Dépenses).
  const schemaReady = after
    .then(() => pool.query(SCHEMA_SQL))
    .then(seedOnce)
    .catch((error) => console.error('[Contrats] Schéma ou reprise impossible', error.message || error));

  const runAlerts = () =>
    schemaReady.then(sendDeadlineAlerts).catch((error) => console.error('[Contrats] Alertes impossibles', error.message || error));
  setTimeout(runAlerts, 60 * 1000).unref();
  setInterval(runAlerts, 6 * 60 * 60 * 1000).unref();

  app.get('/api/contracts', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      res.json((await pool.query(`${SELECT} ORDER BY c.label`)).rows.map(withTerms));
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/contracts', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const { value, error } = readContract(req.body || {});
      if (error) return res.status(400).json({ error });
      const created = await pool.query(
        `INSERT INTO contracts (${COLUMNS.join(', ')}, created_by) VALUES (${COLUMNS.map((_, i) => `$${i + 1}`).join(', ')}, $${COLUMNS.length + 1}) RETURNING id`,
        [...COLUMNS.map((c) => value[c]), req.session.user.displayName || req.session.user.email || null]
      );
      res.status(201).json(withTerms((await pool.query(`${SELECT} WHERE c.id = $1`, [created.rows[0].id])).rows[0]));
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.put('/api/contracts/:id', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const { value, error } = readContract(req.body || {});
      if (error) return res.status(400).json({ error });
      // Échéance modifiée : les alertes repartent de zéro.
      const result = await pool.query(
        `UPDATE contracts SET ${COLUMNS.map((c, i) => `${c} = $${i + 1}`).join(', ')}, alert_level = 0, alert_for = NULL, updated_at = now()
         WHERE id = $${COLUMNS.length + 1}`,
        [...COLUMNS.map((c) => value[c]), req.params.id]
      );
      if (!result.rowCount) return res.status(404).json({ error: 'Contrat introuvable' });
      res.json(withTerms((await pool.query(`${SELECT} WHERE c.id = $1`, [req.params.id])).rows[0]));
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.delete('/api/contracts/:id', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      await pool.query(`DELETE FROM contracts WHERE id = $1`, [req.params.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });
}
