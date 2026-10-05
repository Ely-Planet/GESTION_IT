import { pool } from './db.mjs';
import { getGraphAppToken } from './graphMail.mjs';

// Licences Microsoft 365 que libérera chaque départ à venir, lues dans
// Microsoft 365 (la base ne garde pas les attributions par personne).
// Mises en cache 10 minutes : le tableau de bord se recharge souvent.
const CACHE_MS = 10 * 60 * 1000;
let cache = { at: 0, value: null };

async function loadOffboardingLicenses() {
  const offboardings = await pool.query(`
    SELECT m.id AS movement_id, e.microsoft_object_id
    FROM movements m
    JOIN employees e ON e.id = m.employee_id
    WHERE m.type = 'offboarding'
      AND COALESCE(m.status, 'pending') NOT IN ('done', 'cancelled')
      AND e.microsoft_object_id IS NOT NULL
  `);
  if (offboardings.rowCount === 0) return {};

  // SKU Microsoft -> type de licence GESTION_IT (code = SKU = display_name)
  const types = await pool.query(`
    SELECT s.sku_id, lt.id AS license_type_id
    FROM subscribed_skus s
    JOIN license_types lt ON lt.code = s.display_name
  `);
  const typeBySku = new Map(types.rows.map((row) => [String(row.sku_id).toLowerCase(), row.license_type_id]));

  const token = await getGraphAppToken();
  const result = {};
  for (const row of offboardings.rows) {
    const response = await fetch(
      `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(row.microsoft_object_id)}?$select=assignedLicenses`,
      { headers: { Authorization: `Bearer ${token}` } }
    );
    // Compte déjà supprimé : plus aucune licence à libérer.
    if (response.status === 404) {
      result[row.movement_id] = [];
      continue;
    }
    if (!response.ok) {
      throw new Error(`Microsoft Graph ${response.status} : ${await response.text()}`);
    }
    const user = await response.json();
    result[row.movement_id] = (user.assignedLicenses || [])
      .map((license) => typeBySku.get(String(license.skuId).toLowerCase()))
      .filter(Boolean);
  }
  return result;
}

export function registerForecastRoutes(app) {
  app.get('/api/forecast/offboarding-licenses', async (req, res) => {
    try {
      if (!cache.value || Date.now() - cache.at > CACHE_MS) {
        cache = { at: Date.now(), value: await loadOffboardingLicenses() };
      }
      res.json(cache.value);
    } catch (error) {
      console.error('[FORECAST] Licences des départs illisibles', error.message || error);
      res.status(502).json({ error: error.message });
    }
  });
}
