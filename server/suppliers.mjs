// Fournisseurs : liste unique (table inventory_suppliers) partagée par
// l'inventaire (hardware_items.supplier_id) et le suivi des dépenses
// (expenses.supplier, par nom). Gestion depuis Paramètres → Inventaire :
// ajout, renommage, suppression, fusion et détection des doublons.
import { pool } from './db.mjs';

function requireIT(req, res, next) {
  const user = req.session?.user;
  if (!user?.isIT && !user?.isITManager) return res.status(403).json({ error: 'Réservé au service informatique' });
  next();
}

// Clé de comparaison : sans accents, casse, ponctuation ni formes juridiques.
// « BOUYGUES TELECOM » et « Bouygues Télécom » -> « bouyguestelecom ».
export function supplierKey(name) {
  return String(name || '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\.(com|fr|net|de)\b/g, ' ')
    .replace(/\b(sas|sasu|sarl|sa|eurl|sci|scop|france|groupe|group|ltd|inc|gmbh|the)\b/g, ' ')
    .replace(/[^a-z0-9]+/g, '');
}

function similarity(a, b) {
  if (!a || !b) return 0;
  const m = a.length;
  const n = b.length;
  let previous = Array.from({ length: n + 1 }, (_, j) => j);
  for (let i = 1; i <= m; i++) {
    const current = [i];
    for (let j = 1; j <= n; j++) {
      current[j] = Math.min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
    }
    previous = current;
  }
  return 1 - previous[n] / Math.max(m, n);
}

// Groupes de doublons : « sûr » si les clés sont identiques, « probable » si
// les noms sont très proches (une ou deux lettres, ou l'un prolonge l'autre).
function findDuplicates(suppliers) {
  const parent = new Map(suppliers.map((s) => [s.id, s.id]));
  const find = (id) => (parent.get(id) === id ? id : find(parent.get(id)));
  const sure = new Set();
  for (let i = 0; i < suppliers.length; i++) {
    for (let j = i + 1; j < suppliers.length; j++) {
      const a = suppliers[i].key;
      const b = suppliers[j].key;
      if (!a || !b) continue;
      const same = a === b;
      const shorter = a.length <= b.length ? a : b;
      const longer = a.length <= b.length ? b : a;
      const close =
        same ||
        (shorter.length >= 4 && similarity(a, b) >= 0.85) ||
        (shorter.length >= 5 && (longer.startsWith(shorter) || longer.endsWith(shorter)) && shorter.length / longer.length >= 0.6);
      if (!close) continue;
      parent.set(find(suppliers[i].id), find(suppliers[j].id));
      if (same) sure.add(`${suppliers[i].id}|${suppliers[j].id}`);
    }
  }
  const groups = new Map();
  for (const s of suppliers) {
    const root = find(s.id);
    groups.set(root, [...(groups.get(root) || []), s]);
  }
  return [...groups.values()]
    .filter((members) => members.length > 1)
    .map((members) => {
      const allSure = members.every((m) => m.key === members[0].key);
      // Nom conservé par défaut : le plus utilisé, puis celui qui n'est pas tout en majuscules.
      const target = [...members].sort(
        (x, y) =>
          y.hardware_count + y.expense_count + y.contract_count - (x.hardware_count + x.expense_count + x.contract_count) ||
          Number(x.label === x.label.toUpperCase()) - Number(y.label === y.label.toUpperCase()) ||
          y.label.length - x.label.length
      )[0];
      return { confidence: allSure ? 'sure' : 'probable', targetId: target.id, members };
    })
    .sort((a, b) => (a.confidence === b.confidence ? a.members[0].label.localeCompare(b.members[0].label, 'fr') : a.confidence === 'sure' ? -1 : 1));
}

async function listSuppliers(db = pool) {
  const rows = (
    await db.query(
      `SELECT s.id, s.label,
              (SELECT COUNT(*) FROM hardware_items h WHERE h.supplier_id = s.id)::int AS hardware_count,
              (SELECT COUNT(*) FROM expenses e WHERE lower(btrim(e.supplier)) = lower(btrim(s.label)))::int AS expense_count,
              (SELECT COUNT(*) FROM contracts c WHERE c.supplier_id = s.id)::int AS contract_count
       FROM inventory_suppliers s
       ORDER BY lower(s.label)`
    )
  ).rows;
  return rows.map((r) => ({ ...r, key: supplierKey(r.label) }));
}

async function findByLabel(label, exceptId = null, db = pool) {
  return (
    await db.query(`SELECT id, label FROM inventory_suppliers WHERE lower(btrim(label)) = lower(btrim($1)) AND ($2::uuid IS NULL OR id <> $2) LIMIT 1`, [
      label,
      exceptId
    ])
  ).rows[0];
}

// Fusionne des fournisseurs dans un autre : matériels réaffectés, dépenses renommées.
async function mergeSuppliers(client, targetId, sourceIds) {
  const target = (await client.query(`SELECT id, label FROM inventory_suppliers WHERE id = $1`, [targetId])).rows[0];
  if (!target) throw Object.assign(new Error('Fournisseur à conserver introuvable'), { status: 404 });
  let hardware = 0;
  let expenses = 0;
  for (const sourceId of sourceIds.filter((id) => id !== targetId)) {
    const source = (await client.query(`SELECT id, label FROM inventory_suppliers WHERE id = $1`, [sourceId])).rows[0];
    if (!source) continue;
    hardware += (await client.query(`UPDATE hardware_items SET supplier_id = $1 WHERE supplier_id = $2`, [target.id, source.id])).rowCount;
    if ((await client.query(`SELECT to_regclass('public.contracts') IS NOT NULL AS ok`)).rows[0].ok) {
      await client.query(`UPDATE contracts SET supplier_id = $1 WHERE supplier_id = $2`, [target.id, source.id]);
    }
    expenses += (
      await client.query(`UPDATE expenses SET supplier = $1, updated_at = now() WHERE lower(btrim(supplier)) = lower(btrim($2))`, [target.label, source.label])
    ).rowCount;
    await client.query(`DELETE FROM inventory_suppliers WHERE id = $1`, [source.id]);
  }
  return { target, hardware, expenses };
}

export function registerSupplierRoutes(app) {
  app.get('/api/suppliers-admin', requireIT, async (req, res) => {
    try {
      const suppliers = await listSuppliers();
      res.json({ suppliers, duplicates: findDuplicates(suppliers) });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  app.post('/api/suppliers-admin', requireIT, async (req, res) => {
    try {
      const label = String(req.body?.label || '').trim().replace(/\s+/g, ' ');
      if (!label) return res.status(400).json({ error: 'Nom du fournisseur obligatoire' });
      const existing = await findByLabel(label);
      if (existing) return res.status(409).json({ error: `Le fournisseur « ${existing.label} » existe déjà` });
      res.status(201).json((await pool.query(`INSERT INTO inventory_suppliers (label, sort_order) VALUES ($1, 0) RETURNING id, label`, [label])).rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });

  // Renommage : les dépenses suivent le nouveau nom.
  app.patch('/api/suppliers-admin/:id', requireIT, async (req, res) => {
    const client = await pool.connect();
    try {
      const label = String(req.body?.label || '').trim().replace(/\s+/g, ' ');
      if (!label) return res.status(400).json({ error: 'Nom du fournisseur obligatoire' });
      const current = (await client.query(`SELECT id, label FROM inventory_suppliers WHERE id = $1`, [req.params.id])).rows[0];
      if (!current) return res.status(404).json({ error: 'Fournisseur introuvable' });
      const other = await findByLabel(label, current.id, client);
      if (other) return res.status(409).json({ error: `« ${other.label} » existe déjà : utilisez la fusion` });
      await client.query('BEGIN');
      await client.query(`UPDATE inventory_suppliers SET label = $1 WHERE id = $2`, [label, current.id]);
      const renamed = await client.query(`UPDATE expenses SET supplier = $1, updated_at = now() WHERE lower(btrim(supplier)) = lower(btrim($2))`, [
        label,
        current.label
      ]);
      await client.query('COMMIT');
      res.json({ id: current.id, label, expenses: renamed.rowCount });
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error(error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

  app.post('/api/suppliers-admin/merge', requireIT, async (req, res) => {
    const client = await pool.connect();
    try {
      // Une ou plusieurs fusions : [{ targetId, sourceIds }].
      const merges = Array.isArray(req.body?.merges) ? req.body.merges : [{ targetId: req.body?.targetId, sourceIds: req.body?.sourceIds }];
      await client.query('BEGIN');
      const results = [];
      for (const merge of merges) {
        if (!merge?.targetId || !Array.isArray(merge.sourceIds) || !merge.sourceIds.length) continue;
        results.push(await mergeSuppliers(client, merge.targetId, merge.sourceIds));
      }
      await client.query('COMMIT');
      res.json({ results });
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error(error);
      res.status(error.status || 500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

  app.delete('/api/suppliers-admin/:id', requireIT, async (req, res) => {
    try {
      const supplier = (await listSuppliers()).find((s) => s.id === req.params.id);
      if (!supplier) return res.status(404).json({ error: 'Fournisseur introuvable' });
      if (supplier.hardware_count || supplier.expense_count || supplier.contract_count) {
        return res.status(409).json({
          error: `« ${supplier.label} » est utilisé (${supplier.hardware_count} matériel(s), ${supplier.expense_count} dépense(s), ${supplier.contract_count} contrat(s)) : fusionnez-le plutôt dans un autre fournisseur`
        });
      }
      await pool.query(`DELETE FROM inventory_suppliers WHERE id = $1`, [supplier.id]);
      res.status(204).end();
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });
}
