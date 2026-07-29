import { pool } from './db.mjs';

function splitDisplayName(displayName, upn) {
  const clean = String(displayName || '').trim();

  if (clean) {
    const parts = clean.split(/\s+/);

    if (parts.length === 1) {
      return {
        firstName: parts[0],
        lastName: ''
      };
    }

    return {
      firstName: parts[0],
      lastName: parts.slice(1).join(' ')
    };
  }

  const fallback = String(upn || '')
    .split('@')[0]
    .replace(/[._-]/g, ' ')
    .trim();

  if (!fallback) {
    return {
      firstName: 'Utilisateur',
      lastName: 'Microsoft'
    };
  }

  const parts = fallback.split(/\s+/);

  return {
    firstName: parts[0] || 'Utilisateur',
    lastName: parts.slice(1).join(' ')
  };
}

export async function syncMicrosoftUsers(req, res) {
  const client = await pool.connect();

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

    let url =
      'https://graph.microsoft.com/v1.0/users' +
      '?$select=id,displayName,givenName,surname,mail,userPrincipalName,accountEnabled,jobTitle' +
      '&$top=999';

    let created = 0;
    let updated = 0;
    let skipped = 0;
    let skippedGuests = 0;

    await client.query('BEGIN');

    while (url) {
      const graphRes = await fetch(url, {
        headers: {
          Authorization: `Bearer ${tokenJson.access_token}`
        }
      });

      if (!graphRes.ok) {
        const detail = await graphRes.text();
        throw new Error(`Erreur Graph utilisateurs : ${detail}`);
      }

      const graphJson = await graphRes.json();
      const users = graphJson.value ?? [];

      for (const user of users) {
        const objectId = user.id;
        const upn = user.userPrincipalName;
        const mail = user.mail || upn;
        const displayName = user.displayName || upn;
        const accountEnabled = user.accountEnabled === true;
        const jobTitle = user.jobTitle || null;

        if (!objectId || !upn) {
          skipped++;
          continue;
        }

        if (String(upn).includes('#EXT#')) {
          skippedGuests++;
          continue;
        }

        const firstName =
          user.givenName ||
          splitDisplayName(displayName, upn).firstName;

        const lastName =
          user.surname ||
          splitDisplayName(displayName, upn).lastName ||
          '';

        const existing = await client.query(
          `
          SELECT id
          FROM employees
          WHERE microsoft_object_id = $1
             OR LOWER(microsoft_upn) = LOWER($2)
             OR LOWER(email) = LOWER($2)
          LIMIT 1
          `,
          [objectId, upn]
        );

        if (existing.rows.length > 0) {
          await client.query(
            `
            UPDATE employees
            SET
              first_name = $1,
              last_name = $2,
              email = $3,
              microsoft_upn = $4,
              microsoft_object_id = $5,
              account_enabled = $6,
              job_title = COALESCE($7, job_title),
              is_active = $6,
              microsoft_synced_at = now(),
              updated_at = now()
            WHERE id = $8
            `,
            [
              firstName,
              lastName,
              mail,
              upn,
              objectId,
              accountEnabled,
              jobTitle,
              existing.rows[0].id
            ]
          );

          updated++;
        } else {
          await client.query(
            `
            INSERT INTO employees (
              first_name,
              last_name,
              email,
              microsoft_upn,
              microsoft_object_id,
              account_enabled,
              job_title,
              is_active,
              microsoft_synced_at,
              created_at,
              updated_at
            )
            VALUES (
              $1, $2, $3, $4, $5, $6, $7, $6, now(), now(), now()
            )
            `,
            [
              firstName,
              lastName,
              mail,
              upn,
              objectId,
              accountEnabled,
              jobTitle
            ]
          );

          created++;
        }
      }

      url = graphJson['@odata.nextLink'] || null;
    }

    await client.query(
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
        'employees',
        null,
        JSON.stringify({
          created,
          updated,
          skipped,
          skippedGuests
        })
      ]
    );

    await client.query('COMMIT');

    return res.json({
      ok: true,
      created,
      updated,
      skipped,
      skippedGuests
    });
  } catch (error) {
    await client.query('ROLLBACK');

    console.error(error);

    return res.status(500).json({
      error: error.message
    });
  } finally {
    client.release();
  }
}
