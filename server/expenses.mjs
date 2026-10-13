// Suivi des dépenses informatiques (remplace le classeur « Suivi des dépenses.xlsx »).
// Réservé au groupe « 🔐 Manager Informatique » (isITManager, variable
// MICROSOFT_IT_MANAGER_GROUP_ID).
//
// Exercice d'avril à mars (« 2025-2026 ») ; trimestres : avril-juin = Trim 1,
// juillet-sept. = Trim 2, oct.-déc. = Trim 3, janv.-mars = Trim 4.
// Au premier démarrage, les lignes du classeur sont reprises (data/expensesSeed.json).
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool } from './db.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SEED_FILE = path.join(__dirname, 'data', 'expensesSeed.json');

const SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year text NOT NULL,
  month integer NOT NULL CHECK (month BETWEEN 1 AND 12),
  supplier text NOT NULL,
  family text NOT NULL,
  category text,
  subcategory text,
  invoice_number text,
  invoice_date date,
  amount numeric(12, 2) NOT NULL,
  structure text,
  notes text,
  created_by text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_expenses_fiscal_year ON expenses(fiscal_year);
CREATE TABLE IF NOT EXISTS app_flags (
  key text PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now()
);
-- Fournisseurs (liste de référence, un nom unique sans tenir compte de la casse).
CREATE TABLE IF NOT EXISTS expense_suppliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_by text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_expense_suppliers_name ON expense_suppliers (lower(btrim(name)));
CREATE INDEX IF NOT EXISTS idx_expenses_invoice_number ON expenses (lower(btrim(invoice_number)));
`;

const SUPPLIERS_SEED_FILE = path.join(__dirname, 'data', 'expenseSuppliersSeed.json');

// Fournisseurs : liste unique partagée avec l'inventaire (inventory_suppliers).
async function ensureSupplier(name, db = pool) {
  const label = String(name || '').trim();
  if (!label) return;
  await db.query(
    `INSERT INTO inventory_suppliers (label, sort_order)
     SELECT $1, 0 WHERE NOT EXISTS (SELECT 1 FROM inventory_suppliers WHERE lower(btrim(label)) = lower(btrim($1)))`,
    [label]
  );
}

// Une seule fois : fournisseurs de la feuille « Base » du classeur et ceux créés
// avant l'unification (expense_suppliers). À chaque démarrage : ceux de l'historique.
async function syncSuppliers() {
  const flag = await pool.query(`INSERT INTO app_flags (key) VALUES ('suppliers_unified') ON CONFLICT DO NOTHING RETURNING key`);
  if (flag.rowCount) {
    const names = fs.existsSync(SUPPLIERS_SEED_FILE) ? JSON.parse(fs.readFileSync(SUPPLIERS_SEED_FILE, 'utf8')) : [];
    const legacy = (await pool.query(`SELECT name FROM expense_suppliers`)).rows.map((r) => r.name);
    for (const name of [...names, ...legacy]) await ensureSupplier(name);
  }
  const history = (await pool.query(`SELECT DISTINCT btrim(supplier) AS name FROM expenses WHERE btrim(supplier) <> ''`)).rows;
  for (const row of history) await ensureSupplier(row.name);
}

// Exercice comptable du 1er avril au 31 mars : facture du 15/02/2026 -> 2025-2026, mois 2.
function fiscalFromDate(isoDate) {
  const [year, month] = isoDate.split('-').map(Number);
  return { month, fiscal_year: month >= 4 ? `${year}-${year + 1}` : `${year - 1}-${year}` };
}

// Facture déjà saisie (même numéro, sans tenir compte des espaces ni de la casse).
async function findDuplicateInvoice(invoiceNumber, exceptId) {
  if (!invoiceNumber) return null;
  return (
    await pool.query(
      `SELECT id, supplier, amount::float8 AS amount, to_char(invoice_date, 'DD/MM/YYYY') AS invoice_date, fiscal_year
       FROM expenses
       WHERE lower(regexp_replace(invoice_number, '\\s', '', 'g')) = lower(regexp_replace($1, '\\s', '', 'g'))
         AND ($2::uuid IS NULL OR id <> $2)
       LIMIT 1`,
      [invoiceNumber, exceptId || null]
    )
  ).rows[0] || null;
}

// Reprise unique du classeur (même si toutes les lignes sont supprimées ensuite).
async function seedOnce() {
  const flag = await pool.query(`INSERT INTO app_flags (key) VALUES ('expenses_seeded') ON CONFLICT DO NOTHING RETURNING key`);
  if (!flag.rowCount) return;
  if (!fs.existsSync(SEED_FILE)) return;
  const rows = JSON.parse(fs.readFileSync(SEED_FILE, 'utf8'));
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const r of rows) {
      await client.query(
        `INSERT INTO expenses (fiscal_year, month, supplier, family, category, subcategory, invoice_number, invoice_date, amount, structure, created_by)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'Reprise Excel')`,
        [r.y, r.m, r.s, r.f, r.c || null, r.sc || null, r.n || null, r.d || null, r.a, r.st || null]
      );
    }
    await client.query('COMMIT');
    console.log(`[Dépenses] ${rows.length} ligne(s) reprises du classeur Excel`);
  } catch (error) {
    await client.query('ROLLBACK').catch(() => {});
    await pool.query(`DELETE FROM app_flags WHERE key = 'expenses_seeded'`).catch(() => {});
    throw error;
  } finally {
    client.release();
  }
}

function requireITManager(req, res, next) {
  if (!req.session?.user?.isITManager) return res.status(403).json({ error: 'Réservé au groupe Manager Informatique' });
  next();
}

const isFiscalYear = (value) => {
  const match = /^(\d{4})-(\d{4})$/.exec(String(value || ''));
  return Boolean(match && Number(match[2]) === Number(match[1]) + 1);
};

// Lit et contrôle une dépense envoyée par la page. L'exercice et le mois sont
// déduits de la date de facture (obligatoire pour une nouvelle dépense ; une
// ligne reprise d'Excel sans date garde son exercice et son mois).
function readExpense(body, { requireDate }) {
  const invoiceDate = body.invoice_date ? String(body.invoice_date) : null;
  if (invoiceDate && !/^\d{4}-\d{2}-\d{2}$/.test(invoiceDate)) return { error: 'Date de facture invalide' };
  if (requireDate && !invoiceDate) return { error: 'Date de facture obligatoire' };
  const derived = invoiceDate ? fiscalFromDate(invoiceDate) : null;
  const value = {
    fiscal_year: derived ? derived.fiscal_year : String(body.fiscal_year || '').trim(),
    month: derived ? derived.month : Number(body.month),
    supplier: String(body.supplier || '').trim(),
    family: String(body.family || '').trim(),
    category: String(body.category || '').trim() || null,
    subcategory: String(body.subcategory || '').trim() || null,
    invoice_number: String(body.invoice_number || '').trim() || null,
    invoice_date: invoiceDate,
    amount: Number(String(body.amount ?? '').replace(/\s/g, '').replace(',', '.')),
    structure: String(body.structure || '').trim() || null,
    notes: String(body.notes || '').trim() || null
  };
  if (!isFiscalYear(value.fiscal_year)) return { error: 'Exercice invalide (format 2025-2026)' };
  if (!Number.isInteger(value.month) || value.month < 1 || value.month > 12) return { error: 'Mois invalide' };
  if (!value.supplier) return { error: 'Fournisseur obligatoire' };
  if (!value.family) return { error: 'Famille obligatoire' };
  if (!Number.isFinite(value.amount)) return { error: 'Montant invalide' };
  return { value };
}

// Contrôles communs à la création et à la modification : facture en double,
// fournisseur ajouté à la liste s'il n'y est pas encore.
async function checkAndPrepare(value, exceptId, res) {
  const duplicate = await findDuplicateInvoice(value.invoice_number, exceptId);
  if (duplicate) {
    res.status(409).json({
      error: `La facture ${value.invoice_number} est déjà saisie : ${duplicate.supplier}, ${duplicate.amount.toLocaleString('fr-FR', {
        style: 'currency',
        currency: 'EUR'
      })}${duplicate.invoice_date ? ` du ${duplicate.invoice_date}` : ''} (exercice ${duplicate.fiscal_year}).`,
      duplicate
    });
    return false;
  }
  await ensureSupplier(value.supplier);
  return true;
}

const SELECT = `SELECT id, fiscal_year, month, supplier, family, category, subcategory, invoice_number,
                       to_char(invoice_date, 'YYYY-MM-DD') AS invoice_date, amount::float8 AS amount, structure, notes,
                       created_by, created_at, updated_at
                FROM expenses`;

export function registerExpenseRoutes(app) {
  const schemaReady = pool
    .query(SCHEMA_SQL)
    .then(seedOnce)
    .then(syncSuppliers)
    .catch((error) => console.error('[Dépenses] Schéma ou reprise impossible', error.message || error));

  app.get('/api/expenses', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      res.json((await pool.query(`${SELECT} ORDER BY fiscal_year DESC, ((month + 8) % 12) DESC, created_at DESC`)).rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/expenses', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const { value, error } = readExpense(req.body || {}, { requireDate: true });
      if (error) return res.status(400).json({ error });
      if (!(await checkAndPrepare(value, null, res))) return;
      const result = await pool.query(
        `INSERT INTO expenses (fiscal_year, month, supplier, family, category, subcategory, invoice_number, invoice_date, amount, structure, notes, created_by)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING id`,
        [value.fiscal_year, value.month, value.supplier, value.family, value.category, value.subcategory, value.invoice_number,
          value.invoice_date, value.amount, value.structure, value.notes, req.session.user.displayName || req.session.user.email || null]
      );
      res.status(201).json((await pool.query(`${SELECT} WHERE id = $1`, [result.rows[0].id])).rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.put('/api/expenses/:id', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const { value, error } = readExpense(req.body || {}, { requireDate: false });
      if (error) return res.status(400).json({ error });
      if (!(await checkAndPrepare(value, req.params.id, res))) return;
      const result = await pool.query(
        `UPDATE expenses SET fiscal_year = $1, month = $2, supplier = $3, family = $4, category = $5, subcategory = $6,
                invoice_number = $7, invoice_date = $8, amount = $9, structure = $10, notes = $11, updated_at = now()
         WHERE id = $12`,
        [value.fiscal_year, value.month, value.supplier, value.family, value.category, value.subcategory, value.invoice_number,
          value.invoice_date, value.amount, value.structure, value.notes, req.params.id]
      );
      if (!result.rowCount) return res.status(404).json({ error: 'Dépense introuvable' });
      res.json((await pool.query(`${SELECT} WHERE id = $1`, [req.params.id])).rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // ---- Fournisseurs : liste, avec leurs classements habituels (historique) ----
  app.get('/api/expense-suppliers', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const suppliers = (await pool.query(`SELECT id, label AS name FROM inventory_suppliers ORDER BY lower(label)`)).rows;
      // Combinaisons famille / catégorie / sous-catégorie / structure les plus fréquentes par fournisseur.
      const habits = (
        await pool.query(
          `SELECT lower(btrim(supplier)) AS supplier_key, family, category, subcategory, structure,
                  COUNT(*)::int AS uses, MAX(created_at) AS last_used
           FROM expenses
           GROUP BY 1, family, category, subcategory, structure
           ORDER BY uses DESC, last_used DESC`
        )
      ).rows;
      const bySupplier = new Map();
      for (const habit of habits) {
        const list = bySupplier.get(habit.supplier_key) || [];
        if (list.length < 5) list.push({ family: habit.family, category: habit.category, subcategory: habit.subcategory, structure: habit.structure, uses: habit.uses });
        bySupplier.set(habit.supplier_key, list);
      }
      res.json(suppliers.map((s) => ({ ...s, habits: bySupplier.get(s.name.trim().toLowerCase()) || [] })));
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/expense-suppliers', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      const name = String(req.body?.name || '').trim().replace(/\s+/g, ' ');
      if (!name) return res.status(400).json({ error: 'Nom du fournisseur obligatoire' });
      const existing = (await pool.query(`SELECT id, label AS name FROM inventory_suppliers WHERE lower(btrim(label)) = lower($1)`, [name])).rows[0];
      if (existing) return res.status(409).json({ error: `Le fournisseur « ${existing.name} » existe déjà`, supplier: existing });
      const created = (
        await pool.query(`INSERT INTO inventory_suppliers (label, sort_order) VALUES ($1, 0) RETURNING id, label AS name`, [name])
      ).rows[0];
      res.status(201).json({ ...created, habits: [] });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.delete('/api/expenses/:id', requireITManager, async (req, res) => {
    try {
      await schemaReady;
      await pool.query(`DELETE FROM expenses WHERE id = $1`, [req.params.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });
}
