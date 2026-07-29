import { pool } from './db.mjs';

const MAILBOX = process.env.LUCCA_OFFBOARDING_MAILBOX || 'support@elyade.com';

function normalizeText(value) {
  return String(value || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

function parseOffboardingName(subject) {
  const cleanSubject = String(subject || '')
    .replace(/^((tr|re|fw|fwd)\s*:)+/i, '')
    .trim();

  let match = cleanSubject.match(
    /offboarding\s+de\s+(.+)$/i
  );

  if (match) {
    return match[1]
      .replace(/\s+-\s+.*$/, '')
      .trim();
  }

  match = cleanSubject.match(
    /offboarding\s+(.+?)(?:\s+-\s+.*)?$/i
  );

  if (match) {
    return match[1].trim();
  }

  return null;
}

function parseDateFromText(text) {
  const match = String(text || '').match(
    /(\d{2})\/(\d{2})\/(\d{4})/
  );

  if (!match) {
    return null;
  }

  const [, day, month, year] = match;

  return `${year}-${month}-${day}`;
}

async function getGraphToken() {
  const tenantId = process.env.MICROSOFT_TENANT_ID;
  const clientId = process.env.MICROSOFT_CLIENT_ID;
  const clientSecret = process.env.MICROSOFT_CLIENT_SECRET;

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

    throw new Error(
      `Impossible d'obtenir le token Graph : ${detail}`
    );
  }

  const tokenJson = await tokenRes.json();

  return tokenJson.access_token;
}

async function findEmployeeByLuccaName(name) {
  const normalizedName = normalizeText(name);

  if (!normalizedName) {
    return null;
  }

  const result = await pool.query(`
    SELECT
      id,
      first_name,
      last_name,
      email,
      microsoft_upn
    FROM employees
    WHERE is_active = true
  `);

  for (const employee of result.rows) {
    const firstLast = normalizeText(
      `${employee.first_name} ${employee.last_name}`
    );

    const lastFirst = normalizeText(
      `${employee.last_name} ${employee.first_name}`
    );

    if (
      normalizedName === firstLast ||
      normalizedName === lastFirst ||
      firstLast.includes(normalizedName) ||
      lastFirst.includes(normalizedName)
    ) {
      return employee;
    }
  }

  return null;
}

async function preloadHardware(client, movementId, employeeId) {
  const result = await client.query(
    `
    SELECT
      a.hardware_item_id,
      h.category_id
    FROM assignments a
    INNER JOIN hardware_items h
      ON h.id = a.hardware_item_id
    WHERE a.employee_id = $1
      AND a.returned_at IS NULL
    `,
    [employeeId]
  );

  for (const row of result.rows) {
    await client.query(
      `
      INSERT INTO movement_items (
        movement_id,
        category_id,
        hardware_item_id,
        status
      )
      VALUES ($1, $2, $3, 'assigned')
      `,
      [
        movementId,
        row.category_id,
        row.hardware_item_id
      ]
    );
  }

  return result.rows.length;
}

async function preloadLicenses(client, movementId, employeeId) {
  const result = await client.query(
    `
    SELECT
      id,
      license_type_id
    FROM licenses
    WHERE assigned_employee_id = $1
      AND status = 'assigned'
    `,
    [employeeId]
  );

  for (const row of result.rows) {
    await client.query(
      `
      INSERT INTO movement_licenses (
        movement_id,
        license_type_id,
        license_id,
        status
      )
      VALUES ($1, $2, $3, 'assigned')
      `,
      [
        movementId,
        row.license_type_id,
        row.id
      ]
    );
  }

  return result.rows.length;
}

export async function syncLuccaOffboardings() {
  console.log('LUCCA OFFBOARDING SYNC START');

  const token = await getGraphToken();

  const url =
    `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(MAILBOX)}/messages` +
    '?$top=20' +
    '&$orderby=receivedDateTime desc' +
    '&$select=id,subject,receivedDateTime,bodyPreview,body,from';

  const mailRes = await fetch(url, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });

  if (!mailRes.ok) {
    const detail = await mailRes.text();

    throw new Error(
      `Impossible de lire la boîte ${MAILBOX} : ${detail}`
    );
  }

  const mailJson = await mailRes.json();

for (const mail of (mailJson.value ?? [])) {
  console.log(
    'DATE :',
    mail.receivedDateTime,
    'SUJET :',
    mail.subject
  );
}
  console.log(
    'NB MAILS :',
    (mailJson.value ?? []).length
  );

  const now = Date.now();
  const maxAgeMs = 2 * 60 * 60 * 1000;

  for (const mail of (mailJson.value ?? [])) {
    const subject = String(mail.subject || '');
    const lowerSubject = subject.toLowerCase();

    const isOffboarding =
      lowerSubject.includes('offboarding') ||
      lowerSubject.includes("tâche à réaliser pour l'offboarding");

    if (!isOffboarding) {
      continue;
    }

    const receivedTime = mail.receivedDateTime
      ? new Date(mail.receivedDateTime).getTime()
      : 0;

    if (!receivedTime || now - receivedTime > maxAgeMs) {
      console.log(
        'OFFBOARDING IGNORE CAR ANCIEN :',
        subject
      );

      continue;
    }

    const alreadyProcessed = await pool.query(
      `
      SELECT 1
      FROM processed_offboarding_emails
      WHERE message_id = $1
      `,
      [mail.id]
    );

    if (alreadyProcessed.rowCount > 0) {
      continue;
    }

    const luccaName = parseOffboardingName(subject);

    if (!luccaName) {
      console.warn(
        'OFFBOARDING NOM NON TROUVE :',
        subject
      );

      continue;
    }

    const employee = await findEmployeeByLuccaName(
      luccaName
    );

    if (!employee) {
      console.warn(
        'OFFBOARDING EMPLOYE NON TROUVE :',
        luccaName,
        subject
      );

      continue;
    }

console.log(
  'BODY PREVIEW :',
  mail.bodyPreview
);


const mailContent =
  `${mail.bodyPreview || ''}\n${mail.body?.content || ''}`;

const effectiveDate =
  parseDateFromText(mailContent) ||
  new Date(mail.receivedDateTime).toISOString().slice(0, 10);
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const existingMovement = await client.query(
        `
        SELECT id
        FROM movements
        WHERE type = 'offboarding'
          AND employee_id = $1
          AND effective_date = $2
          AND source = 'lucca_email'
        LIMIT 1
        `,
        [
          employee.id,
          effectiveDate
        ]
      );

      if (existingMovement.rowCount > 0) {
        await client.query(
          `
          INSERT INTO processed_offboarding_emails (
            message_id
          )
          VALUES ($1)
          ON CONFLICT (message_id)
          DO NOTHING
          `,
          [mail.id]
        );

        await client.query('COMMIT');

        console.log(
          'OFFBOARDING DEJA EXISTANT :',
          subject
        );

        continue;
      }

      const movementResult = await client.query(
        `
        INSERT INTO movements (
          type,
          employee_id,
          service_id,
          contract_type_id,
          contract_end_date,
          effective_date,
          source,
          manager_name,
          job_title,
          notes,
          status
        )
        VALUES (
          'offboarding',
          $1,
          NULL,
          NULL,
          NULL,
          $2,
          'lucca_email',
          NULL,
          $3,
          $4,
          'pending'
        )
        RETURNING *
        `,
        [
          employee.id,
          effectiveDate,
          employee.microsoft_upn || employee.email || null,
          `Créé automatiquement depuis le mail LUCCA : ${subject}`
        ]
      );

      const movement = movementResult.rows[0];

      const hardwareCount = await preloadHardware(
        client,
        movement.id,
        employee.id
      );

      const licenseCount = await preloadLicenses(
        client,
        movement.id,
        employee.id
      );

      await client.query(
        `
        INSERT INTO processed_offboarding_emails (
          message_id
        )
        VALUES ($1)
        ON CONFLICT (message_id)
        DO NOTHING
        `,
        [mail.id]
      );

      await client.query('COMMIT');

      console.log(
        'OFFBOARDING CREE :',
        employee.first_name,
        employee.last_name,
        effectiveDate,
        `materiel=${hardwareCount}`,
        `licences=${licenseCount}`
      );
    } catch (error) {
      await client.query('ROLLBACK');

      console.error(
        'ERREUR CREATION OFFBOARDING :',
        error
      );
    } finally {
      client.release();
    }
  }
}
