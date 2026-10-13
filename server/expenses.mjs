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
`;

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

// Lit et contrôle une dépense envoyée par la page.
function readExpense(body) {
  const value = {
    fiscal_year: String(body.fiscal_year || '').trim(),
    month: Number(body.month),
    supplier: String(body.supplier || '').trim(),
    family: String(body.family || '').trim(),
    category: String(body.category || '').trim() || null,
    subcategory: String(body.subcategory || '').trim() || null,
    invoice_number: String(body.invoice_number || '').trim() || null,
    invoice_date: body.invoice_date ? String(body.invoice_date) : null,
    amount: Number(String(body.amount ?? '').replace(/\s/g, '').replace(',', '.')),
    structure: String(body.structure || '').trim() || null,
    notes: String(body.notes || '').trim() || null
  };
  if (!isFiscalYear(value.fiscal_year)) return { error: 'Exercice invalide (format 2025-2026)' };
  if (!Number.isInteger(value.month) || value.month < 1 || value.month > 12) return { error: 'Mois invalide' };
  if (!value.supplier) return { error: 'Fournisseur obligatoire' };
  if (!value.family) return { error: 'Famille obligatoire' };
  if (!Number.isFinite(value.amount)) return { error: 'Montant invalide' };
  if (value.invoice_date && !/^\d{4}-\d{2}-\d{2}$/.test(value.invoice_date)) return { error: 'Date de facture invalide' };
  return { value };
}

const SELECT = `SELECT id, fiscal_year, month, supplier, family, category, subcategory, invoice_number,
                       to_char(invoice_date, 'YYYY-MM-DD') AS invoice_date, amount::float8 AS amount, structure, notes,
                       created_by, created_at, updated_at
                FROM expenses`;

export function registerExpenseRoutes(app) {
  const schemaReady = pool
    .query(SCHEMA_SQL)
    .then(seedOnce)
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
      const { value, error } = readExpense(req.body || {});
      if (error) return res.status(400).json({ error });
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
      const { value, error } = readExpense(req.body || {});
      if (error) return res.status(400).json({ error });
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
