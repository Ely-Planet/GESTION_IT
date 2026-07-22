import { pool } from './db.mjs';

function cleanString(value) {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

export async function createOnboardingRequest(req, res) {
  if (!req.session?.user) {
    return res.status(401).json({
      error: 'Utilisateur non authentifié.'
    });
  }

const {
  first_name,
  last_name,
  email,
  effective_date,
  job_title,
  service_groups,
  hardware_category_ids,
  license_type_ids
} = req.body;


  const firstName = cleanString(first_name);
  const lastName = cleanString(last_name);
  const effectiveDate = cleanString(effective_date);

  if (!firstName || !lastName || !effectiveDate) {
    return res.status(400).json({
      error: 'Prénom, nom et date d’arrivée sont obligatoires.'
    });
  }

const selectedGroups = Array.isArray(service_groups)
  ? service_groups.filter(g => g?.id)
  : [];

if (selectedGroups.length === 0) {
  return res.status(400).json({
    error: 'Au moins un groupe Microsoft doit être sélectionné.'
  });
}

  const hardwareIds = Array.isArray(hardware_category_ids)
    ? hardware_category_ids.filter(Boolean)
    : [];

  const selectedLicenseIds = Array.isArray(license_type_ids)
    ? license_type_ids.filter(Boolean)
    : [];

  const managerName = req.session.user.displayName ?? null;
  const managerEmail =
    req.session.user.email ??
    req.session.user.userPrincipalName ??
    null;

  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const employeeResult = await client.query(
      `
      INSERT INTO employees (
        first_name,
        last_name,
        email,
        manager_name,
        job_title,
        is_active
      )
      VALUES ($1, $2, $3, $4, $5, true)
      RETURNING *
      `,
      [
        firstName,
        lastName,
        cleanString(email),
        managerName,
        cleanString(job_title)
      ]
    );

    const employee = employeeResult.rows[0];


const movementResult = await client.query(
  `
  INSERT INTO movements (
    type,
    employee_id,
    effective_date,
    source,
    manager_name,
    manager_email,
    job_title,
    notes,
    status
  )
  VALUES (
    'onboarding',
    $1,
    $2,
    'manager_form',
    $3,
    $4,
    $5,
    $6,
    'pending'
  )
  RETURNING *
  `,
  [
    employee.id,
    effectiveDate,
    managerName,
    managerEmail,
    cleanString(job_title),
    'Demande créée depuis le formulaire manager.'
  ]
);


    const movement = movementResult.rows[0];

for (const group of selectedGroups) {
  await client.query(
    `
    INSERT INTO movement_service_groups (
      movement_id,
      group_id,
      group_name,
      group_mail
    )
    VALUES ($1, $2, $3, $4)
    `,
    [
      movement.id,
      group.id,
      group.displayName,
      group.mail ?? null
    ]
  );
}


    for (const categoryId of hardwareIds) {
      await client.query(
        `
        INSERT INTO movement_items (
          movement_id,
          category_id,
          status
        )
        VALUES ($1, $2, 'requested')
        `,
        [
          movement.id,
          categoryId
        ]
      );
    }

    const businessPremiumResult = await client.query(
      `
      SELECT id
      FROM license_types
      WHERE code = 'SPB'
      LIMIT 1
      `
    );

    if (businessPremiumResult.rowCount === 0) {
      throw new Error('Licence automatique Microsoft 365 Business Premium introuvable.');
    }

    const licenseIds = new Set();

    licenseIds.add(businessPremiumResult.rows[0].id);

    for (const licenseTypeId of selectedLicenseIds) {
      licenseIds.add(licenseTypeId);
    }

    for (const licenseTypeId of licenseIds) {
      await client.query(
        `
        INSERT INTO movement_licenses (
          movement_id,
          license_type_id,
          status
        )
        VALUES ($1, $2, 'requested')
        `,
        [
          movement.id,
          licenseTypeId
        ]
      );
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
        managerName,
        'create',
        'onboarding_request',
        movement.id,
        JSON.stringify({
          employee_id: employee.id,
          movement_id: movement.id,
          hardware_count: hardwareIds.length,
          license_count: licenseIds.size,
	service_groups: selectedGroups.map(
	  g => g.displayName
	)        })
      ]
    );

    await client.query('COMMIT');

    return res.status(201).json({
      ok: true,
      employee,
      movement
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
