// Suivi des contrats informatiques (remplace la liste SharePoint « Suivi des
// contrats SI »). Réservé au groupe « 🔐 Manager Informatique » (isITManager).
//
// Saisie : date de début, durée d'engagement, préavis, mode de reconduction,
// facturation (fréquence + montant). Tout le reste est calculé :
//   - sans tacite reconduction : date de fin = début + durée ; le contrat
//     se renouvelle à la main (bouton « Renouveler », historique conservé) ;
//   - tacite reconduction (même durée / durée personnalisée) : date de
//     renouvellement = fin de la période en cours, reconduite tant qu'elle
//     est passée ; date limite de résiliation = renouvellement - préavis ;
//   - tacite reconduction puis sans engagement : après la période initiale,
//     résiliable à tout moment avec le préavis.
// Coût sur l'exercice comptable (1er avril - 31 mars) : somme des échéances de
// facturation (annuelle, trimestrielle, mensuelle) tombant dans l'exercice.
// Alerte par mail avant la date de décision (90, 30, 7 jours), adressée à
// CONTRACTS_ALERT_EMAIL (défaut : informatique@elyade.com).
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from './db.mjs';
import { sendMailWithAttachments } from './graphMail.mjs';
import { supplierKey } from './suppliers.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SEED_FILE = path.join(__dirname, 'data', 'contractsSeed.json');
const ALERT_EMAIL = () => process.env.CONTRACTS_ALERT_EMAIL || 'informatique@elyade.com';
const STATUSES = ['Actif', 'En cours de résiliation', 'Résilié', 'Terminé'];
const RENEWAL_MODES = ['none', 'same', 'no_commitment', 'custom'];
const BILLING_MONTHS = { annual: 12, quarterly: 3, monthly: 1 };

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
-- Reconduction et facturation (les dates de fin / limite deviennent calculées ;
-- end_date ne sert plus qu'à ancrer un contrat repris sans date de début).
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS renewal_mode text;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS renewal_months integer;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS billing_frequency text;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS billing_amount numeric(12, 2);
UPDATE contracts SET renewal_mode = CASE
    WHEN NOT tacit_renewal THEN 'none'
    WHEN COALESCE(commitment_months, 0) = 0 THEN 'no_commitment'
    ELSE 'same' END
  WHERE renewal_mode IS NULL;
UPDATE contracts SET billing_frequency = 'annual', billing_amount = annual_cost WHERE billing_frequency IS NULL;
-- Renouvellements manuels (contrats sans tacite reconduction).
CREATE TABLE IF NOT EXISTS contract_renewals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
  previous_start date,
  previous_end date,
  previous_months integer,
  previous_amount numeric(12, 2),
  new_start date,
  new_months integer,
  renewed_by text,
  renewed_at timestamptz NOT NULL DEFAULT now()
);
-- Catégories (gérées dans Paramètres).
CREATE TABLE IF NOT EXISTS contract_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  label text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_contract_categories_label ON contract_categories (lower(btrim(label)));
-- Décision prise pour l'échéance en cours : les alertes de cette échéance s'arrêtent.
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS decision_for date;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS decision_type text;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS decision_note text;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS decision_by text;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS decision_at timestamptz;
-- Date d'effet d'une résiliation (ou d'un non-renouvellement).
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS termination_effective date;
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
  if (flag.rowCount && fs.existsSync(SEED_FILE)) {
    const rows = JSON.parse(fs.readFileSync(SEED_FILE, 'utf8'));
    for (const r of rows) {
      const mode = !r.tacit_renewal ? 'none' : r.commitment_months > 0 ? 'same' : 'no_commitment';
      await pool.query(
        `INSERT INTO contracts (label, supplier_id, category, start_date, commitment_months, tacit_renewal, notice_months,
                                renewal_date, termination_deadline, end_date, status, annual_cost, renewal_mode,
                                billing_frequency, billing_amount, created_by)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'annual', $12, 'Reprise SharePoint')`,
        [r.label, await matchSupplier(r.label), r.category, r.start_date, r.commitment_months, Boolean(r.tacit_renewal), r.notice_months,
          r.renewal_date, r.termination_deadline, r.end_date, r.status || 'Actif', r.annual_cost, mode]
      );
    }
    console.log(`[Contrats] ${rows.length} contrat(s) repris de la liste SharePoint`);
  }
  // Catégories : celles déjà utilisées (une fois).
  const categoriesFlag = await pool.query(`INSERT INTO app_flags (key) VALUES ('contract_categories_seeded') ON CONFLICT DO NOTHING RETURNING key`);
  if (categoriesFlag.rowCount) {
    await pool.query(
      `INSERT INTO contract_categories (label)
       SELECT DISTINCT btrim(category) FROM contracts WHERE btrim(COALESCE(category, '')) <> ''
       ON CONFLICT DO NOTHING`
    );
  }
}

// ---------------------------------------------------------------------------
// Calcul des échéances et du coût sur l'exercice
// ---------------------------------------------------------------------------
const toDate = (iso) => (iso ? new Date(`${String(iso).slice(0, 10)}T00:00:00Z`) : null);
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
export function fiscalYearOf(date) {
  const y = date.getUTCFullYear();
  return date.getUTCMonth() + 1 >= 4 ? `${y}-${y + 1}` : `${y - 1}-${y}`;
}
const fiscalBounds = (fy) => {
  const start = Number(String(fy).slice(0, 4));
  return { from: new Date(Date.UTC(start, 3, 1)), to: new Date(Date.UTC(start + 1, 2, 31)) };
};

export function contractTerms(c, today = todayUtc()) {
  const start = toDate(c.start_date);
  const months = Number(c.commitment_months) || 0;
  const notice = Number(c.notice_months) || 0;
  const mode = c.renewal_mode || 'none';
  // Fin de la période initiale (ou date de fin reprise si le début manque).
  const initialEnd = start && months > 0 ? addMonths(start, months) : !start ? toDate(c.end_date) : null;
  const result = { end_date: null, renewal_date: null, termination_deadline: null, cancellable_from: null, decision_date: null, decision: null };

  if (mode === 'none') {
    result.end_date = toIso(initialEnd);
    result.decision_date = result.end_date;
    result.decision = 'renew';
  } else if (mode === 'no_commitment' || (mode === 'same' && months === 0)) {
    if (initialEnd && initialEnd > today) {
      result.renewal_date = toIso(initialEnd);
      result.termination_deadline = toIso(addMonths(initialEnd, -notice));
    } else {
      // Sans engagement : résiliable à tout moment, effet après le préavis.
      result.cancellable_from = toIso(addMonths(today, notice));
    }
  } else if (initialEnd) {
    const period = mode === 'custom' ? Number(c.renewal_months) || 12 : months || 12;
    let end = initialEnd;
    while (end <= today) end = addMonths(end, period);
    result.renewal_date = toIso(end);
    result.termination_deadline = toIso(addMonths(end, -notice));
  }
  if (result.termination_deadline) {
    result.decision_date = result.termination_deadline;
    result.decision = 'terminate';
  }
  const decision = toDate(result.decision_date);
  result.days_to_decision = decision ? Math.round((decision - today) / 86400000) : null;
  result.annual_cost = c.billing_amount === null || c.billing_amount === undefined ? null : Number(c.billing_amount) * (12 / (BILLING_MONTHS[c.billing_frequency] || 12));
  return result;
}

// Montant facturé sur un exercice : échéances (à partir du début du contrat)
// tombant entre le 1er avril et le 31 mars, jusqu'à la fin du contrat.
export function fiscalYearCost(c, fy) {
  const amount = Number(c.billing_amount);
  if (!Number.isFinite(amount) || !amount) return 0;
  const step = BILLING_MONTHS[c.billing_frequency] || 12;
  const { from, to } = fiscalBounds(fy);
  const start = toDate(c.start_date);
  const terms = contractTerms(c);
  let stop = c.renewal_mode === 'none' ? toDate(terms.end_date) : null;
  // Résiliation (date d'effet) ou contrat clos : plus de facturation ensuite.
  const effective = toDate(c.termination_effective) || (c.status === 'Résilié' || c.status === 'Terminé' ? toDate(c.end_date) || todayUtc() : null);
  if (effective && (!stop || effective < stop)) stop = effective;
  if (!start) return amount * (12 / step); // début inconnu : estimation sur une année pleine
  let total = 0;
  for (let d = start, i = 0; d <= to && i < 1000; d = addMonths(start, step * ++i)) {
    if (stop && d >= stop) break;
    if (d >= from) total += amount;
  }
  return Math.round(total * 100) / 100;
}

const SELECT = `
  SELECT c.id, c.label, c.supplier_id, s.label AS supplier, c.category,
         to_char(c.start_date, 'YYYY-MM-DD') AS start_date, c.commitment_months, c.notice_months,
         c.renewal_mode, c.renewal_months, c.billing_frequency, c.billing_amount::float8 AS billing_amount,
         to_char(c.end_date, 'YYYY-MM-DD') AS stored_end_date, c.status, c.notes, c.updated_at,
         to_char(c.decision_for, 'YYYY-MM-DD') AS decision_for, c.decision_type, c.decision_note, c.decision_by, c.decision_at,
         to_char(c.termination_effective, 'YYYY-MM-DD') AS termination_effective,
         (SELECT COALESCE(json_agg(json_build_object(
                   'previous_start', to_char(r.previous_start, 'YYYY-MM-DD'), 'previous_end', to_char(r.previous_end, 'YYYY-MM-DD'),
                   'new_start', to_char(r.new_start, 'YYYY-MM-DD'), 'new_months', r.new_months, 'renewed_by', r.renewed_by,
                   'renewed_at', r.renewed_at) ORDER BY r.renewed_at DESC), '[]'::json)
          FROM contract_renewals r WHERE r.contract_id = c.id) AS renewals
  FROM contracts c LEFT JOIN inventory_suppliers s ON s.id = c.supplier_id`;

function present(row, fy) {
  const terms = contractTerms({ ...row, end_date: row.stored_end_date });
  // Décision prise pour l'échéance en cours (ou résiliation en cours) : plus d'alerte.
  const decided = Boolean(row.decision_for && (row.decision_for === terms.decision_date || !terms.decision_date)) || row.status !== 'Actif';
  return { ...row, ...terms, decided, fiscal_cost: fiscalYearCost({ ...row, end_date: row.stored_end_date }, fy) };
}

// Dépenses de chaque fournisseur sur l'exercice (suivi des dépenses).
async function supplierSpent(fy) {
  const rows = (
    await pool.query(
      `SELECT lower(btrim(supplier)) AS key, SUM(amount)::float8 AS total FROM expenses WHERE fiscal_year = $1 GROUP BY 1`,
      [fy]
    )
  ).rows;
  return new Map(rows.map((r) => [r.key, r.total]));
}

function requireITManager(req, res, next) {
  if (!req.session?.user?.isITManager) return res.status(403).json({ error: 'Réservé au groupe Manager Informatique' });
  next();
}

const isIsoDate = (v) => /^\d{4}-\d{2}-\d{2}$/.test(String(v || ''));
function readContract(body) {
  const optionalInt = (v) => (v === '' || v === null || v === undefined ? null : Number(v));
  const money = (v) => (v === '' || v === null || v === undefined ? null : Number(String(v).replace(/\s/g, '').replace(',', '.')));
  const value = {
    label: String(body.label || '').trim(),
    supplier_id: body.supplier_id || null,
    category: String(body.category || '').trim() || null,
    start_date: body.start_date ? String(body.start_date) : null,
    commitment_months: optionalInt(body.commitment_months),
    notice_months: optionalInt(body.notice_months),
    renewal_mode: RENEWAL_MODES.includes(body.renewal_mode) ? body.renewal_mode : 'none',
    renewal_months: optionalInt(body.renewal_months),
    billing_frequency: BILLING_MONTHS[body.billing_frequency] ? body.billing_frequency : 'annual',
    billing_amount: money(body.billing_amount),
    status: STATUSES.includes(body.status) ? body.status : 'Actif',
    notes: String(body.notes || '').trim() || null
  };
  if (!value.label) return { error: 'Nom du contrat obligatoire' };
  if (!value.start_date || !isIsoDate(value.start_date)) return { error: 'Date de début obligatoire' };
  for (const key of ['commitment_months', 'notice_months', 'renewal_months']) {
    if (value[key] !== null && (!Number.isInteger(value[key]) || value[key] < 0)) return { error: 'Durée invalide (en mois)' };
  }
  if (value.renewal_mode === 'custom' && !value.renewal_months) return { error: 'Durée de renouvellement personnalisée obligatoire' };
  if (value.renewal_mode === 'none' && !value.commitment_months) return { error: 'Durée du contrat obligatoire sans tacite reconduction' };
  if (value.billing_amount !== null && !Number.isFinite(value.billing_amount)) return { error: 'Montant de facturation invalide' };
  return { value };
}

const COLUMNS = ['label', 'supplier_id', 'category', 'start_date', 'commitment_months', 'notice_months', 'renewal_mode', 'renewal_months',
  'billing_frequency', 'billing_amount', 'status', 'notes'];

// Colonnes historiques tenues à jour pour les autres usages (tacite, coût annuel).
const legacyValues = (value) => ({
  tacit_renewal: value.renewal_mode !== 'none',
  annual_cost: value.billing_amount === null ? null : value.billing_amount * (12 / BILLING_MONTHS[value.billing_frequency])
});

// ---------------------------------------------------------------------------
// Alertes par mail avant la date de décision
// ---------------------------------------------------------------------------
const alertLevel = (days) => (days === null || days < 0 ? 0 : days <= 7 ? 3 : days <= 30 ? 2 : days <= 90 ? 1 : 0);

async function sendDeadlineAlerts() {
  const fy = fiscalYearOf(todayUtc());
  const rows = (await pool.query(`${SELECT} WHERE c.status = 'Actif'`)).rows.map((r) => present(r, fy));
  const due = [];
  for (const row of rows) {
    const level = alertLevel(row.days_to_decision);
    if (!level) continue;
    if (row.decided) continue; // décision déjà prise pour cette échéance
    const current = (await pool.query(`SELECT alert_level, to_char(alert_for, 'YYYY-MM-DD') AS alert_for FROM contracts WHERE id = $1`, [row.id])).rows[0];
    if (current.alert_for === row.decision_date && current.alert_level >= level) continue;
    due.push({ row, level });
  }
  if (!due.length) return;
  const fr = (iso) => (iso ? new Date(`${iso}T00:00:00Z`).toLocaleDateString('fr-FR', { timeZone: 'UTC' }) : '—');
  const euro = (v) => (v === null ? '—' : v.toLocaleString('fr-FR', { style: 'currency', currency: 'EUR' }));
  const lines = due
    .sort((a, b) => a.row.days_to_decision - b.row.days_to_decision)
    .map(
      ({ row }) => `<tr>
        <td style="padding:6px 10px;border-bottom:1px solid #eceef1"><strong>${row.label}</strong>${row.supplier ? `<br><span style="color:#677082">${row.supplier}</span>` : ''}</td>
        <td style="padding:6px 10px;border-bottom:1px solid #eceef1">${row.decision === 'renew' ? 'À renouveler avant le' : 'À résilier avant le'} ${fr(row.decision_date)}<br><span style="color:#ca0088">dans ${row.days_to_decision} jour(s)</span></td>
        <td style="padding:6px 10px;border-bottom:1px solid #eceef1;text-align:right">${euro(row.annual_cost)} / an</td>
      </tr>`
    )
    .join('');
  await sendMailWithAttachments({
    to: ALERT_EMAIL(),
    subject: `Contrats : ${due.length} décision(s) à prendre`,
    html: `<div style="font-family:Inter,'Segoe UI',Arial,sans-serif;font-size:14px;color:#32373c">
      <p>Bonjour,</p>
      <p>Les contrats suivants approchent de leur date de décision : résiliation (sinon reconduction tacite) ou renouvellement (sinon fin du contrat).</p>
      <table style="border-collapse:collapse;font-size:13px">${lines}</table>
      <p style="margin-top:16px">Suivi complet dans GESTION_IT → Suivi des contrats.</p>
    </div>`
  });
  for (const { row, level } of due) {
    await pool.query(`UPDATE contracts SET alert_level = $1, alert_for = $2 WHERE id = $3`, [level, row.decision_date, row.id]);
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

  // Résiliations et non-renouvellements arrivés à leur date d'effet.
  const closeEnded = () =>
    pool.query(
      `UPDATE contracts SET status = CASE WHEN renewal_mode = 'none' THEN 'Terminé' ELSE 'Résilié' END,
              end_date = termination_effective, updated_at = now()
       WHERE status = 'En cours de résiliation' AND termination_effective <= current_date`
    );
  const runAlerts = () =>
    schemaReady.then(sendDeadlineAlerts).then(closeEnded).catch((error) => console.error('[Contrats] Alertes impossibles', error.message || error));
  setTimeout(runAlerts, 60 * 1000).unref();
  setInterval(runAlerts, 6 * 60 * 60 * 1000).unref();

  // ?fy=2025-2026 : coût et dépenses sur cet exercice (défaut : exercice en cours).
  app.get('/api/contracts', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const fy = /^\d{4}-\d{4}$/.test(String(req.query.fy || '')) ? String(req.query.fy) : fiscalYearOf(todayUtc());
      const spent = await supplierSpent(fy);
      const rows = (await pool.query(`${SELECT} ORDER BY c.label`)).rows.map((r) => ({
        ...present(r, fy),
        supplier_spent_fy: r.supplier ? spent.get(r.supplier.trim().toLowerCase()) || 0 : null
      }));
      res.json({ fiscalYear: fy, currentFiscalYear: fiscalYearOf(todayUtc()), contracts: rows });
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
      const legacy = legacyValues(value);
      const created = await pool.query(
        `INSERT INTO contracts (${COLUMNS.join(', ')}, tacit_renewal, annual_cost, created_by)
         VALUES (${COLUMNS.map((_, i) => `$${i + 1}`).join(', ')}, $${COLUMNS.length + 1}, $${COLUMNS.length + 2}, $${COLUMNS.length + 3}) RETURNING id`,
        [...COLUMNS.map((c) => value[c]), legacy.tacit_renewal, legacy.annual_cost, req.session.user.displayName || req.session.user.email || null]
      );
      res.status(201).json({ id: created.rows[0].id });
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
      const legacy = legacyValues(value);
      // Les dates saisies remplacent l'ancrage repris (end_date) ; alertes remises à zéro.
      const result = await pool.query(
        `UPDATE contracts SET ${COLUMNS.map((c, i) => `${c} = $${i + 1}`).join(', ')},
                tacit_renewal = $${COLUMNS.length + 1}, annual_cost = $${COLUMNS.length + 2},
                end_date = NULL, alert_level = 0, alert_for = NULL, updated_at = now()
         WHERE id = $${COLUMNS.length + 3}`,
        [...COLUMNS.map((c) => value[c]), legacy.tacit_renewal, legacy.annual_cost, req.params.id]
      );
      if (!result.rowCount) return res.status(404).json({ error: 'Contrat introuvable' });
      res.json({ id: req.params.id });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Décision pour l'échéance en cours (arrête les alertes de cette échéance) :
  //   keep          tacite : on laisse reconduire
  //   terminate     tacite : résiliation envoyée -> « En cours de résiliation »,
  //                 puis « Résilié » à la date d'effet
  //   renew_planned sans tacite : renouvellement prévu (bouton Renouveler ensuite)
  //   end           sans tacite : pas de renouvellement -> « Terminé » à la date de fin
  app.post('/api/contracts/:id/decision', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const contract = (await pool.query(`${SELECT} WHERE c.id = $1`, [req.params.id])).rows[0];
      if (!contract) return res.status(404).json({ error: 'Contrat introuvable' });
      const terms = contractTerms({ ...contract, end_date: contract.stored_end_date });
      const type = String(req.body?.type || '');
      const allowed = contract.renewal_mode === 'none' ? ['renew_planned', 'end'] : ['keep', 'terminate'];
      if (!allowed.includes(type)) return res.status(400).json({ error: 'Décision invalide pour ce contrat' });
      const note = String(req.body?.note || '').trim() || null;
      const by = req.session.user.displayName || req.session.user.email || null;
      let effective = null;
      if (type === 'terminate') {
        effective = isIsoDate(req.body?.effective_date) ? req.body.effective_date : terms.renewal_date || terms.cancellable_from;
        if (!effective) return res.status(400).json({ error: "Date d'effet de la résiliation inconnue : saisissez-la" });
      }
      if (type === 'end') effective = terms.end_date;
      await pool.query(
        `UPDATE contracts SET decision_for = $1, decision_type = $2, decision_note = $3, decision_by = $4, decision_at = now(),
                termination_effective = $5,
                status = CASE WHEN $5::date IS NOT NULL THEN 'En cours de résiliation' ELSE status END,
                updated_at = now()
         WHERE id = $6`,
        [terms.decision_date || toIso(todayUtc()), type, note, by, effective, contract.id]
      );
      res.json({ id: contract.id });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Annulation de la décision : le contrat redevient actif et les alertes reprennent.
  app.delete('/api/contracts/:id/decision', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      await pool.query(
        `UPDATE contracts SET decision_for = NULL, decision_type = NULL, decision_note = NULL, decision_by = NULL, decision_at = NULL,
                status = CASE WHEN status = 'En cours de résiliation' THEN 'Actif' ELSE status END,
                termination_effective = CASE WHEN status = 'En cours de résiliation' THEN NULL ELSE termination_effective END,
                alert_level = 0, alert_for = NULL, updated_at = now()
         WHERE id = $1`,
        [req.params.id]
      );
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Renouvellement manuel (sans tacite reconduction) : nouvelle période à partir
  // de la fin de la précédente ; durée et montant modifiables.
  app.post('/api/contracts/:id/renew', requireITManager, async (req, res) => {
    const client = await pool.connect();
    try {
      await schemaReady;
      const contract = (await client.query(`${SELECT} WHERE c.id = $1`, [req.params.id])).rows[0];
      if (!contract) return res.status(404).json({ error: 'Contrat introuvable' });
      if (contract.renewal_mode !== 'none') return res.status(400).json({ error: 'Ce contrat se renouvelle par tacite reconduction' });
      const terms = contractTerms({ ...contract, end_date: contract.stored_end_date });
      const newStart = req.body?.start_date || terms.end_date;
      const months = req.body?.months ? Number(req.body.months) : contract.commitment_months;
      const amount = req.body?.billing_amount !== undefined && req.body.billing_amount !== ''
        ? Number(String(req.body.billing_amount).replace(/\s/g, '').replace(',', '.'))
        : contract.billing_amount;
      if (!isIsoDate(newStart)) return res.status(400).json({ error: 'Date de début du renouvellement invalide' });
      if (!Number.isInteger(months) || months <= 0) return res.status(400).json({ error: 'Durée du renouvellement invalide' });
      if (amount !== null && !Number.isFinite(amount)) return res.status(400).json({ error: 'Montant invalide' });
      await client.query('BEGIN');
      await client.query(
        `INSERT INTO contract_renewals (contract_id, previous_start, previous_end, previous_months, previous_amount, new_start, new_months, renewed_by)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [contract.id, contract.start_date, terms.end_date, contract.commitment_months, contract.billing_amount, newStart, months,
          req.session.user.displayName || req.session.user.email || null]
      );
      await client.query(
        `UPDATE contracts SET start_date = $1, commitment_months = $2, billing_amount = $3,
                annual_cost = $3 * (12.0 / CASE billing_frequency WHEN 'monthly' THEN 1 WHEN 'quarterly' THEN 3 ELSE 12 END),
                end_date = NULL, status = 'Actif', alert_level = 0, alert_for = NULL,
                decision_for = NULL, decision_type = NULL, decision_note = NULL, termination_effective = NULL, updated_at = now()
         WHERE id = $4`,
        [newStart, months, amount, contract.id]
      );
      await client.query('COMMIT');
      res.json({ id: contract.id });
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error(error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
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

  // ---- Catégories (Paramètres) ----
  app.get('/api/contract-categories', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      res.json(
        (
          await pool.query(
            `SELECT k.id, k.label, (SELECT COUNT(*) FROM contracts c WHERE lower(btrim(c.category)) = lower(btrim(k.label)))::int AS usage
             FROM contract_categories k ORDER BY k.sort_order, lower(k.label)`
          )
        ).rows
      );
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/contract-categories', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const label = String(req.body?.label || '').trim();
      if (!label) return res.status(400).json({ error: 'Libellé obligatoire' });
      const created = await pool.query(`INSERT INTO contract_categories (label) VALUES ($1) ON CONFLICT DO NOTHING RETURNING id, label`, [label]);
      if (!created.rowCount) return res.status(409).json({ error: `La catégorie « ${label} » existe déjà` });
      res.status(201).json(created.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Renommage : les contrats suivent.
  app.patch('/api/contract-categories/:id', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const label = String(req.body?.label || '').trim();
      if (!label) return res.status(400).json({ error: 'Libellé obligatoire' });
      const current = (await pool.query(`SELECT label FROM contract_categories WHERE id = $1`, [req.params.id])).rows[0];
      if (!current) return res.status(404).json({ error: 'Catégorie introuvable' });
      const other = (await pool.query(`SELECT 1 FROM contract_categories WHERE lower(btrim(label)) = lower(btrim($1)) AND id <> $2`, [label, req.params.id])).rowCount;
      if (other) return res.status(409).json({ error: `La catégorie « ${label} » existe déjà` });
      await pool.query(`UPDATE contract_categories SET label = $1 WHERE id = $2`, [label, req.params.id]);
      await pool.query(`UPDATE contracts SET category = $1 WHERE lower(btrim(category)) = lower(btrim($2))`, [label, current.label]);
      res.json({ id: req.params.id, label });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.delete('/api/contract-categories/:id', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const current = (await pool.query(`SELECT label FROM contract_categories WHERE id = $1`, [req.params.id])).rows[0];
      if (!current) return res.status(404).json({ error: 'Catégorie introuvable' });
      const used = (await pool.query(`SELECT COUNT(*)::int AS n FROM contracts WHERE lower(btrim(category)) = lower(btrim($1))`, [current.label])).rows[0].n;
      if (used) return res.status(409).json({ error: `« ${current.label} » est utilisée par ${used} contrat(s) : changez-leur d'abord de catégorie` });
      await pool.query(`DELETE FROM contract_categories WHERE id = $1`, [req.params.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });
}
