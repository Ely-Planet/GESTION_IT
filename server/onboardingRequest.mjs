import fs from 'fs';
import path from 'path';
import { sendMailWithAttachments } from './graphMail.mjs';
import { pool } from './db.mjs';
import { generateOnboardingPdf } from './onboardingPdf.mjs';

function cleanString(value) {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function parseJsonArray(value) {
  if (Array.isArray(value)) return value;

  if (typeof value !== 'string') return [];

  try {
    const parsed = JSON.parse(value);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

function parseBoolean(value) {
  return value === true || value === 'true';
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
contract_reason,
internship_mission,
employee_status,
employee_level,
gross_annual_salary,
variable_bonus,
school,
referral,
contract_type,
referral_employee,
  service_groups,
shared_mailboxes,
  company_car,
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

const selectedGroups = parseJsonArray(service_groups)
  .filter(g => g?.id);

if (selectedGroups.length === 0) {
  return res.status(400).json({
    error: 'Au moins un groupe Microsoft doit être sélectionné.'
  });
}

const hardwareIds = parseJsonArray(hardware_category_ids)
  .filter(Boolean);

const selectedLicenseIds = parseJsonArray(license_type_ids)
  .filter(Boolean);

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
'envoye'
  )
  RETURNING *
  `,

[
  employee.id,
  effectiveDate,
  managerName,
  managerEmail,
  cleanString(job_title),

  shared_mailboxes
    ? `Demande créée depuis le formulaire manager.\n\nBoîtes partagées demandées :\n${shared_mailboxes}`
    : 'Demande créée depuis le formulaire manager.'
]


);


    const movement = movementResult.rows[0];

console.log(
  'SERVICES PDF',
  selectedGroups.map(g => g.displayName)
);

let referralEmployeeName = null;

if (referral_employee) {
  const referralResult = await client.query(
    `
    SELECT
      first_name,
      last_name
    FROM employees
    WHERE id = $1
    `,
    [referral_employee]
  );

  if (referralResult.rows.length) {
    referralEmployeeName =
      `${referralResult.rows[0].first_name} ${referralResult.rows[0].last_name}`;
  }
}


const pdfInfo =
  await generateOnboardingPdf({
    requesterName: managerName,
    requesterEmail: managerEmail,

    firstName,
    lastName,

    jobTitle: job_title,

    effectiveDate,

    contractType: contract_type,

    employeeStatus:
      employee_status,

    employeeLevel:
      employee_level,

    grossAnnualSalary:
      gross_annual_salary,

    variableBonus:
      variable_bonus,

    school,
companyCar:
  company_car === 'true',

    internshipMission:
      internship_mission,
referral:
  referral === true,

referralEmployee:
  referralEmployeeName,

services:
  selectedGroups.map(
    g => g.displayName
  ),
    sharedMailboxes:
      shared_mailboxes
  });

console.log(
  'PDF RH créé :',
  pdfInfo.filePath
);

const cvFileName = req.file?.originalname ?? null;

const cvFilePath = req.file
  ? `public/uploads/cv/${req.file.filename}`
  : null;

const pdfBuffer = fs.readFileSync(
  pdfInfo.filePath
);

const cvBuffer =
  cvFilePath
    ? fs.readFileSync(
        path.join(process.cwd(), cvFilePath)
      )
    : null;
await sendMailWithAttachments({
  to: 'Service_RH@elyade.com',

  subject:
    `Demande onboarding - ${firstName} ${lastName}`,

  html: `
    <p>Bonjour,</p>

    <p>
<br>
      Une nouvelle demande d'onboarding a été créée.
    </p>
<br>
   <p>
      <strong>Demandeur :</strong>
      ${managerName}
    </p>
<br>
    <p>
      <strong>Collaborateur :</strong>
      ${firstName} ${lastName}
    </p>

    <p>
      <strong>Fonction :</strong>
      ${job_title || '-'}
    </p>

    <p>
      <strong>Date d'arrivée :</strong>
      ${effectiveDate}
    </p>
<br>
    <p>
      Le PDF récapitulatif et le CV sont joints.
    </p>

    <p>
      Cordialement,<br>
Service Informatique
    </p>
  `,

  attachments: [
    {
      '@odata.type':
        '#microsoft.graph.fileAttachment',

      name: pdfInfo.fileName,

      contentType: 'application/pdf',

      contentBytes:
        pdfBuffer.toString('base64')
    },

    ...(cvBuffer
      ? [
          {
            '@odata.type':
              '#microsoft.graph.fileAttachment',

            name: cvFileName,

            contentType:
              'application/pdf',

            contentBytes:
              cvBuffer.toString('base64')
          }
        ]
      : [])
  ]
});


if (company_car === 'true' || company_car === true) {

  await sendMailWithAttachments({
    to: 'moyensgeneraux@elyade.com',

    subject:
      `Demande véhicule de fonction - ${firstName} ${lastName}`,

    html: `
      <p>Bonjour,</p>

      <p>
        Une demande de véhicule de fonction a été créée pour un nouveau collaborateur.
      </p>

<br>
   <p>
      <strong>Demandeur :</strong>
      ${managerName}
    </p>
<br>
   <p>
      <strong>Collaborateur :</strong>
      ${firstName} ${lastName}
    </p>

      <p>
        <strong>Fonction :</strong>
        ${job_title || '-'}
      </p>

      <p>
        <strong>Date d'arrivée :</strong>
        ${effectiveDate}
      </p>

      <p>
        <strong>Type de contrat :</strong>
        ${contract_type || '-'}
      </p>

      <p>
        <strong>Service :</strong>
        ${
          selectedGroups
            .map(g => g.displayName)
            .join(', ') || '-'
        }
      </p>

      <p>
        Merci de prévoir un véhicule de fonction pour ce collaborateur.
      </p>

      <p>
        Cordialement,<br>
        Service Informatique
      </p>
    `
  });

}



await client.query(
  `
  INSERT INTO onboarding_details (
    movement_id,
    contract_type,
    employee_status,
    employee_level,
    gross_annual_salary,
    variable_bonus,
    contract_reason,
    school,
    internship_mission,
    referral,
    referral_employee,
    cv_file_name,
    cv_file_path
  )
  VALUES (
    $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13
  )
  `,
  [
    movement.id,

    cleanString(contract_type),

    cleanString(employee_status),

    cleanString(employee_level),

    gross_annual_salary
      ? Number(gross_annual_salary)
      : null,

    cleanString(variable_bonus),

    cleanString(contract_reason),

    cleanString(school),

    cleanString(internship_mission),

    parseBoolean(referral),

    cleanString(referral_employee),

    cvFileName,

    cvFilePath
  ]
);



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
  WHERE label ILIKE '%Business Premium%'
  LIMIT 1
  `
);

const licenseIds = new Set();

const businessPremiumLicenseTypeId =
  businessPremiumResult.rows[0].id;

licenseIds.add(businessPremiumLicenseTypeId);

for (const licenseTypeId of selectedLicenseIds) {
  licenseIds.add(licenseTypeId);
}

for (const licenseTypeId of licenseIds) {
  const status =
    licenseTypeId === businessPremiumLicenseTypeId
      ? 'assigned'
      : 'requested';

  await client.query(
    `
    INSERT INTO movement_licenses (
      movement_id,
      license_type_id,
      status
    )
    VALUES ($1, $2, $3)
    `,
    [
      movement.id,
      licenseTypeId,
      status
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

const templatesResult = await client.query(`
  SELECT
    action_type,
    label,
    sort_order
  FROM onboarding_action_templates
  WHERE is_active = true
  ORDER BY sort_order
`);

for (const action of templatesResult.rows) {
  await client.query(
    `
    INSERT INTO movement_actions (
      movement_id,
      action_type,
      label,
      sort_order
    )
    VALUES ($1, $2, $3, $4)
    `,
    [
      movement.id,
      action.action_type,
      action.label,
      action.sort_order
    ]
  );
}




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
