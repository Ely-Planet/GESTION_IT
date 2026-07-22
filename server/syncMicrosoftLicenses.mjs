import { pool } from './db.mjs';

const LICENSE_LABELS = {
  'SPB': 'Microsoft 365 Business Premium',
  'O365_BUSINESS_PREMIUM': 'Microsoft 365 Business Standard',
  'Microsoft_365_Copilot': 'Microsoft 365 Copilot',
  'EXCHANGESTANDARD': 'Exchange Online Plan 1',
  'POWER_BI_PRO': 'Power BI Pro',
  'POWER_BI_STANDARD': 'Microsoft Fabric gratuit',
  'PBI_PREMIUM_PER_USER': 'Power BI Premium par utilisateur',
  'FLOW_FREE': 'Microsoft Power Automate Free',
  'POWERAPPS_DEV': 'Microsoft Power Apps for Developer',
  'POWERAPPS_VIRAL': 'Microsoft Power Apps Plan 2 Trial',
  'Power_Pages_vTrial_for_Makers': 'Power Pages vTrial pour les créateurs',
  'RIGHTSMANAGEMENT_ADHOC': 'Gestion des droits Adhoc',
  'CCIBOTS_PRIVPREV_VIRAL': 'Version d’évaluation Copilot Studio',
  'SPZA_IW': 'SharePoint Zone App',
  'WINDOWS_STORE': 'Windows Store',
  'Teams_Premium_(for_Departments)': 'Teams Premium',
  'RMSBASIC': 'Azure Rights Management Basic'
};

function labelForSku(skuPartNumber) {
  return (
    LICENSE_LABELS[skuPartNumber] ??
    String(skuPartNumber)
      .replace(/_/g, ' ')
      .replace(/\(/g, '')
      .replace(/\)/g, '')
  );
}

export async function syncMicrosoftLicenses(req, res) {
  try {
    const tenantId = process.env.MICROSOFT_TENANT_ID;
    const clientId = process.env.MICROSOFT_CLIENT_ID;
    const clientSecret = process.env.MICROSOFT_CLIENT_SECRET;

    if (!tenantId || !clientId || !clientSecret) {
      return res.status(500).json({
        error: 'Variables Microsoft manquantes'
      });
    }

    const tokenRes = await fetch(
      `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: new URLSearchParams({
          client_id: clientId,
          client_secret: clientSecret,
          scope: 'https://graph.microsoft.com/.default',
          grant_type: 'client_credentials'
        })
      }
    );

    if (!tokenRes.ok) {
      const detail = await tokenRes.text();

      return res.status(500).json({
        error: 'Impossible d’obtenir le token Microsoft',
        detail
      });
    }

    const tokenJson = await tokenRes.json();

    const graphRes = await fetch(
      'https://graph.microsoft.com/v1.0/subscribedSkus',
      {
        headers: {
          Authorization: `Bearer ${tokenJson.access_token}`
        }
      }
    );

    if (!graphRes.ok) {
      const detail = await graphRes.text();

      return res.status(500).json({
        error: 'Erreur Graph',
        detail
      });
    }

    const graphJson = await graphRes.json();
    const skus = graphJson.value ?? [];

    let imported = 0;
    let skipped = 0;

    for (const sku of skus) {
      const skuId = sku.skuId;
      const skuPartNumber = sku.skuPartNumber ?? sku.skuId;
      const enabledUnits = sku.prepaidUnits?.enabled ?? 0;
      const consumedUnits = sku.consumedUnits ?? 0;

      await pool.query(
        `
        INSERT INTO subscribed_skus (
          sku_id,
          display_name,
          applies_to,
          enabled_units,
          consumed_units,
          prepaid_units,
          synced_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, now())
        ON CONFLICT (sku_id)
        DO UPDATE
        SET
          display_name = EXCLUDED.display_name,
          applies_to = EXCLUDED.applies_to,
          enabled_units = EXCLUDED.enabled_units,
          consumed_units = EXCLUDED.consumed_units,
          prepaid_units = EXCLUDED.prepaid_units,
          synced_at = now()
        `,
        [
          skuId,
          skuPartNumber,
          sku.appliesTo ?? null,
          enabledUnits,
          consumedUnits,
          enabledUnits
        ]
      );

      const filterResult = await pool.query(
        `
        INSERT INTO microsoft_license_filters (
          sku_part_number,
          enabled
        )
        VALUES ($1, false)
        ON CONFLICT (sku_part_number)
        DO UPDATE
        SET sku_part_number = EXCLUDED.sku_part_number
        RETURNING enabled
        `,
        [skuPartNumber]
      );

      const shouldImport = filterResult.rows[0]?.enabled === true;

      if (shouldImport) {
        await pool.query(
          `
          INSERT INTO license_types (
            code,
            label,
            total_seats,
            has_expiration,
            default_renewal_notice_days
          )
          VALUES ($1, $2, $3, false, 30)
          ON CONFLICT (code)
          DO UPDATE
          SET
            label = EXCLUDED.label,
            total_seats = EXCLUDED.total_seats,
            updated_at = now()
          `,
          [
            skuPartNumber,
            labelForSku(skuPartNumber),
            enabledUnits
          ]
        );

        imported++;
      } else {
        await pool.query(
          `
          DELETE FROM license_types lt
          WHERE lt.code = $1
          AND NOT EXISTS (
            SELECT 1
            FROM licenses l
            WHERE l.license_type_id = lt.id
          )
          AND NOT EXISTS (
            SELECT 1
            FROM movement_licenses ml
            WHERE ml.license_type_id = lt.id
          )
          `,
          [skuPartNumber]
        );

        skipped++;
      }
    }

    await pool.query(
      `
      INSERT INTO audit_log (
        actor_name,
        action,
        entity_type,
        entity_id,
        details
      )
      VALUES ($1, $2, $3, $4, $5::jsonb)
      `,
      [
        'Microsoft Graph Sync',
        'sync',
        'subscribed_skus',
        null,
        JSON.stringify({
          total: skus.length,
          imported,
          skipped
        })
      ]
    );

    return res.json({
      ok: true,
      synced: skus.length,
      imported,
      skipped
    });
  } catch (error) {
    console.error(error);

    return res.status(500).json({
      error: error.message
    });
  }
}
