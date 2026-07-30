import 'dotenv/config';
import { pool } from './db.mjs';
import express from 'express';
import { getSharedMailboxes } from './sharedMailboxes.mjs';
import multer from 'multer';

import session from 'express-session';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import axios from 'axios';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';
import fsp from 'fs/promises';
import PDFDocument from 'pdfkit';
import { ConfidentialClientApplication } from '@azure/msal-node';
import { syncMicrosoftLicenses } from './syncMicrosoftLicenses.mjs';
import { getMicrosoftOnboardingServices } from './microsoftOnboardingServices.mjs';
import { createOnboardingRequest } from './onboardingRequest.mjs';
import { syncMicrosoftUsers } from './syncMicrosoftUsers.mjs';
import { syncLuccaOffboardings } from './luccaOffboardingSync.mjs';


const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const requiredEnv = [
  'APP_URL',
  'SESSION_SECRET',
  'MICROSOFT_TENANT_ID',
  'MICROSOFT_CLIENT_ID',
  'MICROSOFT_CLIENT_SECRET',
  'MICROSOFT_REDIRECT_URI',
  'MICROSOFT_ALLOWED_GROUP_ID'
];

for (const key of requiredEnv) {
  if (!process.env[key]) {
    console.error(`Variable manquante dans .env : ${key}`);
    process.exit(1);
  }
}

const app = express();
const port = Number(process.env.PORT || 3001);
const DOCUMENTS_DIR = path.join(process.cwd(), 'storage', 'documents');

async function ensureDocumentsDir() {
  await fsp.mkdir(DOCUMENTS_DIR, { recursive: true });
}

function safeFilePart(value) {
  return String(value || 'document')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9_-]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, 80);
}

function formatDateFr(value) {
  if (!value) return '-';

  try {
    return new Date(value).toLocaleDateString('fr-FR');
  } catch {
    return String(value);
  }
}

async function getGraphAppToken() {
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
    throw new Error(`Erreur token Microsoft Graph : ${detail}`);
  }

  const tokenJson = await tokenRes.json();
  return tokenJson.access_token;
}

async function generateSignedDocumentPdf(row) {
  await ensureDocumentsDir();

  const snapshot = row.content_snapshot || {};
const isReassignment =
  snapshot?.document_type === 'hardware_reassignment';

const employeeName = snapshot.employee || row.signer_name || 'Collaborateur';
const docLabel = row.doc_type === 'restitution'
  ? 'Restitution'
  : isReassignment
      ? 'MiseAJourMateriel'
      : 'Attribution';

  const datePart = new Date(row.signed_at || row.created_at || Date.now())
    .toISOString()
    .slice(0, 10)
    .replace(/-/g, '');

  const fileName =
    `${docLabel}_${safeFilePart(employeeName)}_${datePart}_${row.id.slice(0, 8)}.pdf`;

  const absolutePath = path.join(DOCUMENTS_DIR, fileName);
  const relativePath = path.join('storage', 'documents', fileName);

  await new Promise((resolve, reject) => {
    const pdf = new PDFDocument({
      size: 'A4',
      margin: 50
    });

    const stream = fs.createWriteStream(absolutePath);

    pdf.pipe(stream);


pdf.image(
  path.join(
    process.cwd(),
    'public/assets/logo-elyade.png'
  ),
  40,
  25,
  {
    width: 60
  }
);

pdf
  .fontSize(16)
  .text(
    isReassignment
      ? "MISE À JOUR DU MATÉRIEL AFFECTÉ"
      : "FICHE D'ATTRIBUTION DE MATÉRIEL INFORMATIQUE",
    50,
    90,
    {
      align: 'center'
    }
  );

    pdf.moveDown(2);

    pdf
      .fontSize(11)
      .text(`Collaborateur : ${employeeName}`);

    pdf.text(`Date d'effet : ${formatDateFr(snapshot.effective_date)}`);

pdf.text(
  `${isReassignment ? 'Date de mise à jour' : 'Date de signature'} : ${formattedDate}`
);
    pdf.moveDown();

    pdf
      .fontSize(14)
      .text('Matériel attribué', { underline: true });

    pdf.moveDown(0.5);

    const items = Array.isArray(snapshot.items) ? snapshot.items : [];

    if (items.length === 0) {
      pdf.fontSize(11).text('Aucun matériel attribué.');
    } else {
      for (const item of items) {
        pdf
          .fontSize(11)
          .text(
            `- ${item.category || '-'} | Réf. ${item.reference || '-'} | Série ${item.serial || '-'}`
          );
      }
    }

    pdf.moveDown();

    pdf
      .fontSize(14)
      .text('Licences attribuées', { underline: true });

    pdf.moveDown(0.5);

    const licenses = Array.isArray(snapshot.licenses)
      ? snapshot.licenses
      : [];

    if (licenses.length === 0) {
      pdf.fontSize(11).text('Aucune licence attribuée.');
    } else {
      for (const license of licenses) {
        pdf
          .fontSize(11)
          .text(
            `- ${license.type || '-'}${license.seat ? ` (${license.seat})` : ''}`
          );
      }
    }

    pdf.moveDown(2);

  if (!isReassignment) {
  pdf
      .fontSize(14)
      .text('Signature', { underline: true });

    pdf.moveDown(0.5);

    if (row.signature_data && row.signature_data.includes(',')) {
      try {
        const base64 = row.signature_data.split(',')[1];
        const buffer = Buffer.from(base64, 'base64');

        pdf.image(buffer, {
          fit: [250, 120]
        });
      } catch {
        pdf.fontSize(10).text('Signature non exploitable.');
      }
    } else {
      pdf.fontSize(10).text('Signature non disponible.');
    }
}
    pdf.moveDown();

    pdf
      .fontSize(9)
      .fillColor('#666666')
      .text(
        'Document généré automatiquement par le Service Informatique ELYADE',
        { align: 'center' }
      );

    pdf.end();

    stream.on('finish', resolve);
    stream.on('error', reject);
  });

  await pool.query(
    `
    UPDATE signed_documents
    SET
      pdf_path = $1,
      pdf_generated_at = now()
    WHERE id = $2
    `,
    [
      relativePath,
      row.id
    ]
  );

  return {
    absolutePath,
    relativePath,
    fileName
  };
}

async function getOrCreateSignedDocumentPdf(documentId) {
  const result = await pool.query(
    `
    SELECT *
    FROM signed_documents
    WHERE id = $1
    `,
    [documentId]
  );

  if (result.rowCount === 0) {
    const error = new Error('Document signé introuvable.');
    error.statusCode = 404;
    throw error;
  }

  const row = result.rows[0];

  if (row.pdf_path) {
    const absolutePath = path.join(process.cwd(), row.pdf_path);

    if (fs.existsSync(absolutePath)) {
      return {
        row,
        absolutePath,
        fileName: path.basename(absolutePath)
      };
    }
  }

  const generated = await generateSignedDocumentPdf(row);

  return {
    row,
    absolutePath: generated.absolutePath,
    fileName: generated.fileName
  };
}

async function sendSignedDocumentMail(documentId) {
  const {
    row,
    absolutePath,
    fileName
  } = await getOrCreateSignedDocumentPdf(documentId);

  if (!row.signer_email) {
    throw new Error('Aucune adresse email signataire renseignée.');
  }

  const token = await getGraphAppToken();

  const pdfBuffer = await fsp.readFile(absolutePath);

const snapshot = row.content_snapshot || {};

const isReassignment =
  snapshot?.document_type === 'hardware_reassignment';

const subject =
  row.doc_type === 'restitution'
    ? 'Document de restitution'
    : isReassignment
        ? 'Mise à jour de votre matériel informatique'
        : 'Fiche d’attribution de matériel informatique';

const html = isReassignment
  ? `
      <p>Bonjour,</p>

      <p>
        Votre matériel informatique a été mis à jour.
      </p>

      <p>
        Vous trouverez en pièce jointe le récapitulatif du matériel qui vous est actuellement affecté.
      </p>

      <p>
        Aucune action n'est requise de votre part.
      </p>

      <br/>

      <p>
        Cordialement,
        <br/>
        Service Informatique ELYADE
      </p>
    `
  : `
      <p>Bonjour,</p>

      <p>
        Veuillez trouver ci-joint votre fiche d'attribution de matériel informatique.
      </p>

      <p>
        Merci de prendre connaissance du document ci-joint et de le signer.
      </p>

      <br/>

      <p>
        Cordialement,
        <br/>
        Service Informatique ELYADE
      </p>
    `;


  const graphRes = await fetch(
    'https://graph.microsoft.com/v1.0/users/informatique@elyade.com/sendMail',
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        message: {
          subject,
          body: {
            contentType: 'HTML',
            content: html
          },
          toRecipients: [
            {
              emailAddress: {
                address: row.signer_email
              }
            }
          ],
          attachments: [
            {
              '@odata.type': '#microsoft.graph.fileAttachment',
              name: fileName,
              contentType: 'application/pdf',
              contentBytes: pdfBuffer.toString('base64')
            }
          ]
        },
        saveToSentItems: true
      })
    }
  );

  if (!graphRes.ok) {
    const detail = await graphRes.text();
    throw new Error(`Erreur envoi mail Microsoft Graph : ${detail}`);
  }

  await pool.query(
    `
    UPDATE signed_documents
    SET
      email_sent_at = now(),
      email_error = null
    WHERE id = $1
    `,
    [documentId]
  );

  return true;
}

const cvStorage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, path.join(process.cwd(), 'public/uploads/cv'));
  },

  filename(req, file, cb) {
    const unique =
      Date.now() + '-' +
      Math.round(Math.random() * 1e9);

    cb(
      null,
      `${unique}-${file.originalname}`
    );
  }
});

const uploadCv = multer({
  storage: cvStorage,
  limits: {
    fileSize: 10 * 1024 * 1024
  }
});

app.set('trust proxy', 1);

app.use(
  helmet({
    contentSecurityPolicy: false
  })
);

app.use(cookieParser());
app.use(express.json());

app.post('/api/sync-microsoft-licenses', syncMicrosoftLicenses);
app.post('/api/microsoft-users/sync', syncMicrosoftUsers);

app.use(
  session({
    name: 'gestionit.sid',
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      maxAge: 8 * 60 * 60 * 1000
    }
  })
);

const msalClient = new ConfidentialClientApplication({
  auth: {
    clientId: process.env.MICROSOFT_CLIENT_ID,
    authority: `https://login.microsoftonline.com/${process.env.MICROSOFT_TENANT_ID}`,
    clientSecret: process.env.MICROSOFT_CLIENT_SECRET
  }
});

const scopes = [
  'openid',
  'profile',
  'email',
  'User.Read',
  'GroupMember.Read.All'
];

function isAuthenticated(req) {
  return Boolean(req.session && req.session.user);
}




app.get(
  '/api/shared-mailboxes',
  getSharedMailboxes
);



app.get('/api/test-lucca-mails', async (req, res) => {
  try {

    const token = await getGraphAppToken();

    const graphRes = await fetch(
      'https://graph.microsoft.com/v1.0/users/informatique@elyade.com/messages?$top=10',
      {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    );

    const graphJson = await graphRes.json();

    res.json(graphJson);

  } catch (error) {

    res.status(500).json({
      error: error.message
    });

  }
});



















app.get('/auth/login', async (req, res) => {
  try {
    const authUrl = await msalClient.getAuthCodeUrl({
      scopes,
      redirectUri: process.env.MICROSOFT_REDIRECT_URI
    });

    res.redirect(authUrl);
  } catch (error) {
    console.error('Erreur génération URL Microsoft', error);
    res.status(500).send('Erreur de connexion Microsoft.');
  }
});

app.get('/auth/callback', async (req, res) => {
  try {
    const code = req.query.code;

    if (!code) {
      return res.status(400).send('Code Microsoft manquant.');
    }

    const tokenResponse = await msalClient.acquireTokenByCode({
      code,
      scopes,
      redirectUri: process.env.MICROSOFT_REDIRECT_URI
    });

    const accessToken = tokenResponse.accessToken;

    const meResponse = await axios.get(
      'https://graph.microsoft.com/v1.0/me?$select=id,displayName,mail,userPrincipalName',
      {
        headers: {
          Authorization: `Bearer ${accessToken}`
        }
      }
    );

    const memberResponse = await axios.post(
      'https://graph.microsoft.com/v1.0/me/checkMemberGroups',
      {
        groupIds: [process.env.MICROSOFT_ALLOWED_GROUP_ID]
      },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json'
        }
      }
    );

    const allowedGroups = memberResponse.data?.value || [];
    const isAllowed = allowedGroups.includes(process.env.MICROSOFT_ALLOWED_GROUP_ID);

    if (!isAllowed) {
      req.session.destroy(() => {});

      return res.status(403).send(`
        <!doctype html>
        <html lang="fr">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>Accès refusé - GESTION_IT</title>
            <style>
              body {
                margin: 0;
                font-family: Arial, sans-serif;
                background: #f6f7f9;
                color: #171717;
              }
              .box {
                max-width: 620px;
                margin: 90px auto;
                background: #ffffff;
                padding: 32px;
                border-radius: 16px;
                box-shadow: 0 12px 35px rgba(0,0,0,.08);
              }
              h1 {
                margin-top: 0;
                color: #b00020;
                font-size: 26px;
              }
              p {
                line-height: 1.5;
                color: #333333;
              }
              a {
                color: #ee0093;
                font-weight: 700;
                text-decoration: none;
              }
            </style>
          </head>
          <body>
            <div class="box">
              <h1>Accès refusé</h1>
              <p>Votre compte Microsoft est valide, mais il n'appartient pas au groupe autorisé.</p>
              <p>Accès réservé au groupe : <strong>🏢 Service Informatique</strong>.</p>
              <p>/auth/logoutChanger de compte</a></p>
            </div>
          </body>
        </html>
      `);
    }

    const user = meResponse.data;

    req.session.user = {
      id: user.id,
      displayName: user.displayName,
      email: user.mail || user.userPrincipalName,
      userPrincipalName: user.userPrincipalName
    };

    res.redirect('/');
  } catch (error) {
    console.error('Erreur callback Microsoft', error.response?.data || error.message || error);
    res.status(500).send('Erreur lors de la connexion Microsoft.');
  }
});

app.get('/auth/logout', (req, res) => {
  req.session.destroy(() => {
    res.clearCookie('gestionit.sid');
    res.redirect('/');
  });
});

app.post('/auth/logout', (req, res) => {
  req.session.destroy(() => {
    res.clearCookie('gestionit.sid');
    res.json({ ok: true });
  });
});

app.get('/api/me', (req, res) => {

  if (!isAuthenticated(req)) {
    return res.status(401).json({
      authenticated: false
    });
  }

  res.json({
    authenticated: true,
    user: req.session.user
  });

});

app.get('/api/microsoft-onboarding-services', getMicrosoftOnboardingServices);

app.post(
  '/api/onboarding-request',
  uploadCv.single('cv'),
  createOnboardingRequest
);

app.get('/api/services', async (req, res) => {

  try {

    const result = await pool.query(`
      SELECT *
      FROM services
      ORDER BY name
    `);

    res.json(result.rows);

  } catch (error) {

    console.error(error);

    res.status(500).json({
      error: error.message
    });

  }

});

app.get('/api/contract-types', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM contract_types
      ORDER BY sort_order
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/employees', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM employees
      ORDER BY last_name
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/movement-service-groups', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM movement_service_groups
      ORDER BY created_at
    `);

    res.json(result.rows);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.post('/api/employees', async (req, res) => {
  try {

const allowedColumns = [
  'category_id',

  'title',

  'reference',
  'serial_number',

  'brand',
  'model',

  'os_id',
  'processor_id',
  'memory_id',
  'size_id',

  'hdmi',
  'displayport',
  'usbc',

  'status',

  'purchase_date',
  'invoice_number',
  'purchase_value',

  'supplier_id',
  'budget_id',

  'warranty_expiration_date',
  'asset_number',

  'intune_device_id',
  'atera_ticket_id',

  'notes'
];



    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (!columns.includes('first_name') || !columns.includes('last_name')) {
      return res.status(400).json({
        error: 'first_name et last_name sont obligatoires.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    const placeholders = columns.map((_, index) => `$${index + 1}`);

    const result = await pool.query(
      `
      INSERT INTO employees (${columns.join(', ')})
      VALUES (${placeholders.join(', ')})
      RETURNING *
      `,
      values
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});



app.get('/api/hardware-categories', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM hardware_categories
      ORDER BY sort_order
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/hardware-items', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM hardware_items
      ORDER BY created_at DESC
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const inventoryLookupTables = {
  brands: 'inventory_brands',
  operatingSystems: 'inventory_operating_systems',
  processors: 'inventory_processors',
  memories: 'inventory_memories',
  sizes: 'inventory_sizes',
  suppliers: 'inventory_suppliers',
  budgets: 'inventory_budgets',
  statuses: 'inventory_statuses'
};

for (const [routeName, tableName] of Object.entries(inventoryLookupTables)) {
  app.get(`/api/inventory-${routeName}`, async (req, res) => {
    try {
      const result = await pool.query(
        `
        SELECT *
        FROM ${tableName}
        ORDER BY sort_order, label
        `
      );

      res.json(result.rows);
    } catch (error) {
      console.error(error);
      res.status(500).json({
        error: error.message
      });
    }
  });

  app.post(`/api/inventory-${routeName}`, async (req, res) => {
    try {
      const { label, sort_order } = req.body;

      if (!label) {
        return res.status(400).json({
          error: 'Le libellé est obligatoire.'
        });
      }

      const result = await pool.query(
        `
        INSERT INTO ${tableName} (
          label,
          sort_order
        )
        VALUES ($1, $2)
        RETURNING *
        `,
        [
          label,
          sort_order ?? 0
        ]
      );

      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({
        error: error.message
      });
    }
  });

  app.patch(`/api/inventory-${routeName}/:id`, async (req, res) => {
    try {
      const allowedColumns = [
        'label',
        'sort_order'
      ];

      const columns = allowedColumns.filter(
        (column) => req.body[column] !== undefined
      );

      if (columns.length === 0) {
        return res.status(400).json({
          error: 'Aucune donnée à mettre à jour.'
        });
      }

      const values = columns.map((column) => req.body[column]);
      values.push(req.params.id);

      const setClause = columns
        .map((column, index) => `${column} = $${index + 1}`)
        .join(', ');

      const result = await pool.query(
        `
        UPDATE ${tableName}
        SET ${setClause}
        WHERE id = $${values.length}
        RETURNING *
        `,
        values
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          error: 'Valeur introuvable.'
        });
      }

      res.json(result.rows[0]);
    } catch (error) {
      console.error(error);
      res.status(500).json({
        error: error.message
      });
    }
  });

  app.delete(`/api/inventory-${routeName}/:id`, async (req, res) => {
    try {
      const result = await pool.query(
        `
        DELETE FROM ${tableName}
        WHERE id = $1
        RETURNING *
        `,
        [
          req.params.id
        ]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          error: 'Valeur introuvable.'
        });
      }

      res.json({
        ok: true,
        deleted: result.rows[0]
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({
        error: error.message
      });
    }
  });
}




app.post('/api/hardware-items', async (req, res) => {
  try {
    const inputRows = Array.isArray(req.body) ? req.body : [req.body];

    if (inputRows.length === 0) {
      return res.status(400).json({
        error: 'Aucun matériel à créer.'
      });
    }

const allowedColumns = [
  'category_id',

  'title',

  'reference',
  'serial_number',

  'brand',
  'model',

  'os_id',
  'processor_id',
  'memory_id',
  'size_id',

  'hdmi',
  'displayport',
'usbc',
  'status',

  'purchase_date',
  'invoice_number',
  'purchase_value',

  'supplier_id',
  'budget_id',

  'warranty_expiration_date',
  'asset_number',

  'intune_device_id',
  'atera_ticket_id',

  'notes'
];


    const insertedRows = [];

    for (const row of inputRows) {
      const columns = allowedColumns.filter((column) => row[column] !== undefined);

      if (!columns.includes('category_id')) {
        return res.status(400).json({
          error: 'category_id est obligatoire pour créer un matériel.'
        });
      }

      const values = columns.map((column) => row[column]);
      const placeholders = columns.map((_, index) => `$${index + 1}`);

      const result = await pool.query(
        `
        INSERT INTO hardware_items (${columns.join(', ')})
        VALUES (${placeholders.join(', ')})
        RETURNING *
        `,
        values
      );

      insertedRows.push(result.rows[0]);
    }

    res.status(201).json(insertedRows);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.put('/api/hardware-items/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const allowedColumns = [
      'category_id',
      'title',
      'reference',
      'serial_number',
      'brand',
      'model',
      'os_id',
      'processor_id',
      'memory_id',
      'size_id',
      'hdmi',
      'displayport',
      'usbc',
      'status',
      'purchase_date',
      'invoice_number',
      'purchase_value',
      'supplier_id',
      'budget_id',
      'warranty_expiration_date',
      'asset_number',
      'intune_device_id',
      'atera_ticket_id',
      'notes'
    ];

    const columns = allowedColumns.filter(
      (column) => req.body[column] !== undefined
    );

    if (columns.length === 0) {
      return res.status(400).json({
        error: 'Aucune donnée à mettre à jour'
      });
    }

    const values = columns.map((column) => req.body[column]);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE hardware_items
      SET ${setClause},
          updated_at = NOW()
      WHERE id = $${columns.length + 1}
      RETURNING *
      `,
      [...values, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Matériel introuvable'
      });
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});


app.patch('/api/hardware-items/:id', async (req, res) => {
  try {

const allowedColumns = [
  'category_id',

  'title',

  'reference',
  'serial_number',

  'brand',
  'model',

  'os_id',
  'processor_id',
  'memory_id',
  'size_id',

  'hdmi',
  'displayport',
'usbc',
  'status',

  'purchase_date',
  'invoice_number',
  'purchase_value',

  'supplier_id',
  'budget_id',

  'warranty_expiration_date',
  'asset_number',

  'intune_device_id',
  'atera_ticket_id',

  'notes'
];


    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (columns.length === 0) {
      return res.status(400).json({
        error: 'Aucune donnée à mettre à jour.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE hardware_items
      SET ${setClause},
          updated_at = now()
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Matériel introuvable.'
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.delete('/api/hardware-items/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `
      DELETE FROM hardware_items
      WHERE id = $1
      RETURNING id
      `,
      [req.params.id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Matériel introuvable.'
      });
    }

    res.json({
      ok: true,
      id: result.rows[0].id
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/license-types', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM license_types
      ORDER BY label
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/onboarding-license-types', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        id,
        code,
        label
      FROM license_types
      WHERE requestable_for_onboarding = true
      ORDER BY label
    `);

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/onboarding-hardware-categories', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        id,
        code,
        label,
        requestable_for_onboarding
      FROM hardware_categories
      ORDER BY label
    `);

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.patch('/api/onboarding-hardware-categories/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `
      UPDATE hardware_categories
      SET requestable_for_onboarding = $1
      WHERE id = $2
      RETURNING *
      `,
      [
        req.body.requestable_for_onboarding,
        req.params.id
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Catégorie introuvable'
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});



app.get('/api/licenses', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM licenses
      ORDER BY created_at DESC
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});



app.post('/api/license-types', async (req, res) => {
  try {

const allowedColumns = [
  'code',
  'label',
  'total_seats',
  'has_expiration',
  'default_renewal_notice_days',
  'notes',
  'requestable_for_onboarding'
];



    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (!columns.includes('code') || !columns.includes('label')) {
      return res.status(400).json({
        error: 'code et label sont obligatoires.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    const placeholders = columns.map((_, index) => `$${index + 1}`);

    const result = await pool.query(
      `
      INSERT INTO license_types (${columns.join(', ')})
      VALUES (${placeholders.join(', ')})
      RETURNING *
      `,
      values
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.patch('/api/license-types/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'code',
      'label',
      'total_seats',
      'has_expiration',
      'default_renewal_notice_days',
      'notes'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (columns.length === 0) {
      return res.status(400).json({
        error: 'Aucune donnée à mettre à jour.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE license_types
      SET ${setClause},
          updated_at = now()
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Type de licence introuvable.'
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.delete('/api/license-types/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `
      DELETE FROM license_types
      WHERE id = $1
      RETURNING id
      `,
      [req.params.id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Type de licence introuvable.'
      });
    }

    res.json({
      ok: true,
      id: result.rows[0].id
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});



app.get('/api/microsoft-license-filters', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM microsoft_license_filters
      ORDER BY sku_part_number
    `);

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.patch('/api/microsoft-license-filters/:sku', async (req, res) => {
  try {
    const result = await pool.query(
      `
      UPDATE microsoft_license_filters
      SET enabled = $1
      WHERE sku_part_number = $2
      RETURNING *
      `,
      [
        req.body.enabled,
        req.params.sku
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Licence introuvable'
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/microsoft-license-stats', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        f.sku_part_number,
        f.enabled,
        s.enabled_units,
        s.consumed_units
      FROM microsoft_license_filters f
      LEFT JOIN subscribed_skus s
        ON s.display_name = f.sku_part_number
      ORDER BY f.sku_part_number
    `);

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.post('/api/licenses', async (req, res) => {
  try {
    const inputRows = Array.isArray(req.body) ? req.body : [req.body];

    if (inputRows.length === 0) {
      return res.status(400).json({
        error: 'Aucune licence à créer.'
      });
    }

    const allowedColumns = [
      'license_type_id',
      'seat_key',
      'status',
      'assigned_employee_id',
      'assigned_at',
      'expiration_date',
      'renewal_notice_days',
      'notes'
    ];

    const insertedRows = [];

    for (const row of inputRows) {
      const columns = allowedColumns.filter((column) => row[column] !== undefined);

      if (!columns.includes('license_type_id')) {
        return res.status(400).json({
          error: 'license_type_id est obligatoire.'
        });
      }

      const values = columns.map((column) => row[column]);
      const placeholders = columns.map((_, index) => `$${index + 1}`);

      const result = await pool.query(
        `
        INSERT INTO licenses (${columns.join(', ')})
        VALUES (${placeholders.join(', ')})
        RETURNING *
        `,
        values
      );

      insertedRows.push(result.rows[0]);
    }

    res.status(201).json(insertedRows);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.patch('/api/licenses/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'license_type_id',
      'seat_key',
      'status',
      'assigned_employee_id',
      'assigned_at',
      'expiration_date',
      'renewal_notice_days',
      'notes'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (columns.length === 0) {
      return res.status(400).json({
        error: 'Aucune donnée à mettre à jour.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE licenses
      SET ${setClause},
          updated_at = now()
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Licence introuvable.'
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});


app.delete('/api/licenses/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `
      DELETE FROM licenses
      WHERE id = $1
      RETURNING id
      `,
      [req.params.id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Licence introuvable.'
      });
    }

    res.json({
      ok: true,
      id: result.rows[0].id
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/movements', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM movements
      ORDER BY effective_date DESC
    `);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/service-peripherals', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM service_peripherals
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      error: error.message
    });

  }
});

app.get('/api/assignments', async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT *
      FROM assignments
      ORDER BY assigned_at DESC
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      error: error.message
    });

  }
});


app.post('/api/assignments', async (req, res) => {
  try {

    const result = await pool.query(
      `
      INSERT INTO assignments (
        employee_id,
        hardware_item_id,
        assigned_at
      )
      VALUES (
        $1,
        $2,
        now()
      )
      RETURNING *
      `,
      [
        req.body.employee_id,
        req.body.hardware_item_id
      ]
    );

    res.json(result.rows[0]);

  } catch (error) {

    res.status(500).json({
      error: error.message
    });

  }
});



app.post('/api/hardware-reassign', async (req, res) => {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const { employee_id, changes } = req.body;

    for (const change of changes) {
      if (!change.new_hardware_id) {
        continue;
      }

      // Clôture de l'affectation actuelle
      await client.query(
        `
        UPDATE assignments
        SET returned_at = NOW()
        WHERE hardware_item_id = $1
          AND returned_at IS NULL
        `,
        [change.old_hardware_id]
      );

      // Création de la nouvelle affectation
      await client.query(
        `
        INSERT INTO assignments (
          employee_id,
          hardware_item_id,
          assigned_at
        )
        VALUES (
          $1,
          $2,
          NOW()
        )
        `,
        [
          employee_id,
          change.new_hardware_id
        ]
      );

      // Ancien matériel
      await client.query(
        `
        UPDATE hardware_items
        SET status = $1,
            updated_at = NOW()
        WHERE id = $2
        `,
        [
          change.old_status,
          change.old_hardware_id
        ]
      );

      // Nouveau matériel
      await client.query(
        `
        UPDATE hardware_items
        SET status = 'assigned',
            updated_at = NOW()
        WHERE id = $1
        `,
        [change.new_hardware_id]
      );
    }

    // Création automatique d'une nouvelle fiche d'affectation signée
    // après réaffectation du matériel
    const employeeResult = await client.query(
      `
      SELECT *
      FROM employees
      WHERE id = $1
      LIMIT 1
      `,
      [employee_id]
    );

    const employee = employeeResult.rows[0];

    const latestMovementResult = await client.query(
      `
      SELECT id
      FROM movements
      WHERE employee_id = $1
        AND type = 'onboarding'
      ORDER BY effective_date DESC, created_at DESC
      LIMIT 1
      `,
      [employee_id]
    );

    const latestMovement = latestMovementResult.rows[0];

    const activeAssignmentsResult = await client.query(
      `
      SELECT
        a.id AS assignment_id,
        a.assigned_at,
        h.id AS hardware_id,
        h.title,
        h.reference,
        h.serial_number,
        h.brand,
        h.model,
        h.status,
        hc.label AS category
      FROM assignments a
      JOIN hardware_items h
        ON h.id = a.hardware_item_id
      LEFT JOIN hardware_categories hc
        ON hc.id = h.category_id
      WHERE a.employee_id = $1
        AND a.returned_at IS NULL
      ORDER BY hc.sort_order, hc.label, h.title
      `,
      [employee_id]
    );

    const changedHardwareIds = changes
      .filter((change) => change.new_hardware_id)
      .map((change) => change.new_hardware_id);

    let assignedLicensesRows = [];

    if (latestMovement?.id) {
      const assignedLicensesResult = await client.query(
        `
        SELECT
          ml.id,
          ml.status,
          lt.label AS type,
          l.seat_key AS seat
        FROM movement_licenses ml
        LEFT JOIN license_types lt
          ON lt.id = ml.license_type_id
        LEFT JOIN licenses l
          ON l.id = ml.license_id
        WHERE ml.movement_id = $1
          AND ml.status = 'assigned'
        ORDER BY lt.label, l.seat_key
        `,
        [latestMovement.id]
      );

      assignedLicensesRows = assignedLicensesResult.rows;
    }

const signedDocumentResult = await client.query(
      `
      INSERT INTO signed_documents (
        movement_id,
        doc_type,
        signer_name,
        signer_email,
        signed_at,
        signature_data,
        status,
        content_snapshot
      )
      VALUES (
        $1,
        'assignment',
        $2,
        $3,
        NOW(),
        NULL,
        'signed',
        $4
      )
      RETURNING *
      `,
      [
        latestMovement?.id ?? null,
        employee
          ? `${employee.first_name} ${employee.last_name}`
          : null,
        employee?.email ?? employee?.microsoft_upn ?? null,

JSON.stringify({
  document_type: 'hardware_reassignment',
  title: 'Mise à jour de la fiche d’affectation matériel',

  employee: employee
    ? `${employee.first_name} ${employee.last_name}`
    : null,

  employee_email: employee?.email ?? employee?.microsoft_upn ?? null,

  movement_type: 'onboarding',
  effective_date: latestMovement?.effective_date ?? null,

  generated_at: new Date().toISOString(),
  reason: 'Réaffectation de matériel depuis l’inventaire',

  items: activeAssignmentsResult.rows.map((row) => ({
    category: row.category,
    title: row.title,
    reference: row.reference,
    serial: row.serial_number,
    serial_number: row.serial_number,
    brand: row.brand,
    model: row.model,
    status: row.status,
    assigned_at: row.assigned_at
  })),

  licenses: assignedLicensesRows.map((row) => ({
    type: row.type,
    seat: row.seat
  })),

  reassignments: changes
    .filter((change) => change.new_hardware_id)
    .map((change) => ({
      old_hardware_id: change.old_hardware_id,
      new_hardware_id: change.new_hardware_id,
      old_status: change.old_status
    }))
})







      ]
    );

    const createdSignedDocument = signedDocumentResult.rows[0];

    await client.query('COMMIT');

    try {
      await getOrCreateSignedDocumentPdf(createdSignedDocument.id);

      if (createdSignedDocument.signer_email) {
        await sendSignedDocumentMail(createdSignedDocument.id);
      }
    } catch (mailOrPdfError) {
      console.error(
        'Erreur PDF / email après réaffectation',
        mailOrPdfError
      );

      await pool.query(
        `
        UPDATE signed_documents
        SET email_error = $1
        WHERE id = $2
        `,
        [
          mailOrPdfError.message,
          createdSignedDocument.id
        ]
      ).catch(console.error);
    }

    res.json({
      success: true,
      signed_document_id: createdSignedDocument.id,
      email_sent: Boolean(createdSignedDocument.signer_email)
    });

  } catch (error) {

    await client.query('ROLLBACK');

    console.error(error);

    res.status(500).json({
      error: error.message
    });

  } finally {
    client.release();
  }
});







app.get('/api/audit-log', async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT *
      FROM audit_log
      ORDER BY created_at DESC
      LIMIT 200
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      error: error.message
    });

  }
});


app.post('/api/audit-log', async (req, res) => {
  try {
    const {
      actor_name,
      action,
      entity_type,
      entity_id,
      details
    } = req.body;

    if (!action || !entity_type) {
      return res.status(400).json({
        error: 'action et entity_type sont obligatoires.'
      });
    }

    const result = await pool.query(
      `
      INSERT INTO audit_log (
        actor_name,
        action,
        entity_type,
        entity_id,
        details
      )
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
      `,
      [
        actor_name ?? null,
        action,
        entity_type,
        entity_id ?? null,
        details ?? null
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});



app.get('/api/movement-actions', async (req, res) => {
  try {

    const result = await pool.query(`
      SELECT *
      FROM movement_actions
      ORDER BY sort_order
    `);

    res.json(result.rows);

  } catch (error) {

    res.status(500).json({
      error: error.message
    });

  }
});

app.get('/api/movement-items', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM movement_items
    `);

    res.json(result.rows);

  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/movement-licenses', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM movement_licenses
    `);

    res.json(result.rows);

  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/signed-documents', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM signed_documents
      ORDER BY created_at DESC
    `);

    res.json(result.rows);

  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/subscribed-skus', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM subscribed_skus
      ORDER BY display_name
    `);

    res.json(result.rows);

  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/dashboard-widgets/:userId', async (req, res) => {
  try {
    const result = await pool.query(
      `
      SELECT *
      FROM dashboard_widgets
      WHERE user_id = $1
      ORDER BY sort_order
      `,
      [req.params.userId]
    );

    res.json(result.rows);

  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.post('/api/dashboard-widgets', async (req, res) => {
  try {
    const allowedColumns = [
      'user_id',
      'widget_key',
      'label',
      'visible',
      'sort_order',
      'config'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (!columns.includes('user_id') || !columns.includes('widget_key') || !columns.includes('label')) {
      return res.status(400).json({
        error: 'user_id, widget_key et label sont obligatoires.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    const placeholders = columns.map((_, index) => `$${index + 1}`);

    const result = await pool.query(
      `
      INSERT INTO dashboard_widgets (${columns.join(', ')})
      VALUES (${placeholders.join(', ')})
      ON CONFLICT (user_id, widget_key)
      DO UPDATE SET
        label = EXCLUDED.label,
        visible = EXCLUDED.visible,
        sort_order = EXCLUDED.sort_order,
        config = EXCLUDED.config
      RETURNING *
      `,
      values
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.patch('/api/dashboard-widgets/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'label',
      'visible',
      'sort_order',
      'config'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (columns.length === 0) {
      return res.status(400).json({
        error: 'Aucune donnée à mettre à jour.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE dashboard_widgets
      SET ${setClause}
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Widget introuvable.'
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.get('/api/health/db', async (req, res) => {
  try {
    const result = await testDb();

    res.json({
      status: 'ok',
      database: result.database,
      user: result.username
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

app.patch('/api/movements/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'type',
      'employee_id',
      'service_id',
      'contract_type_id',
      'contract_end_date',
      'effective_date',
      'source',
      'manager_name',
      'job_title',
      'notes',
      'status',
      'calendar_event_ids'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (columns.length === 0) {
      return res.status(400).json({ error: 'Aucune donnée à mettre à jour.' });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE movements
      SET ${setClause},
          updated_at = now()
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Mouvement introuvable.' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});


app.delete('/api/movements/:id', async (req, res) => {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    const signedDocs = await client.query(
      `
      SELECT id
      FROM signed_documents
      WHERE movement_id = $1
        AND status = 'signed'
      LIMIT 1
      `,
      [req.params.id]
    );

    if (signedDocs.rowCount > 0) {
      await client.query('ROLLBACK');

      return res.status(400).json({
        error:
          'Impossible de supprimer ce mouvement car un document signé existe déjà.'
      });
    }

    await client.query(
      `
      DELETE FROM signed_documents
      WHERE movement_id = $1
      `,
      [req.params.id]
    );

    await client.query(
      `
      DELETE FROM movement_service_groups
      WHERE movement_id = $1
      `,
      [req.params.id]
    );

    await client.query(
      `
      DELETE FROM movement_licenses
      WHERE movement_id = $1
      `,
      [req.params.id]
    );

    await client.query(
      `
      DELETE FROM movement_items
      WHERE movement_id = $1
      `,
      [req.params.id]
    );

    await client.query(
      `
      DELETE FROM movement_actions
      WHERE movement_id = $1
      `,
      [req.params.id]
    );

    const result = await client.query(
      `
      DELETE FROM movements
      WHERE id = $1
      RETURNING *
      `,
      [req.params.id]
    );

    if (result.rowCount === 0) {
      await client.query('ROLLBACK');

      return res.status(404).json({
        error: 'Mouvement introuvable.'
      });
    }

    await client.query('COMMIT');

    res.json({
      ok: true,
      deleted: result.rows[0]
    });
  } catch (error) {
    await client.query('ROLLBACK');

    console.error(error);

    res.status(500).json({
      error: error.message
    });
  } finally {
    client.release();
  }
});

app.post('/api/movements', async (req, res) => {
  try {
    const allowedColumns = [
      'type',
      'employee_id',
      'service_id',
      'contract_type_id',
      'contract_end_date',
      'effective_date',
      'source',
      'manager_name',
      'job_title',
      'notes',
      'status',
      'calendar_event_ids'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (!columns.includes('type') || !columns.includes('effective_date')) {
      return res.status(400).json({
        error: 'type et effective_date sont obligatoires.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    const placeholders = columns.map((_, index) => `$${index + 1}`);

    const result = await pool.query(
      `
      INSERT INTO movements (${columns.join(', ')})
      VALUES (${placeholders.join(', ')})
      RETURNING *
      `,
      values
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/movement-actions', async (req, res) => {
  try {
    const inputRows = Array.isArray(req.body) ? req.body : [req.body];

    const allowedColumns = [
      'movement_id',
      'action_type',
      'label',
      'due_date',
      'done_at',
      'notes',
      'sort_order'
    ];

    const insertedRows = [];

    for (const row of inputRows) {
      const columns = allowedColumns.filter((column) => row[column] !== undefined);

      if (!columns.includes('movement_id') || !columns.includes('action_type') || !columns.includes('label')) {
        return res.status(400).json({
          error: 'movement_id, action_type et label sont obligatoires.'
        });
      }

      const values = columns.map((column) => row[column]);
      const placeholders = columns.map((_, index) => `$${index + 1}`);

      const result = await pool.query(
        `
        INSERT INTO movement_actions (${columns.join(', ')})
        VALUES (${placeholders.join(', ')})
        RETURNING *
        `,
        values
      );

      insertedRows.push(result.rows[0]);
    }

    res.status(201).json(insertedRows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.patch('/api/movement-actions/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'action_type',
      'label',
      'due_date',
      'done_at',
      'notes',
      'sort_order'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (columns.length === 0) {
      return res.status(400).json({ error: 'Aucune donnée à mettre à jour.' });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE movement_actions
      SET ${setClause}
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Action introuvable.' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/movement-items', async (req, res) => {
  try {
    const inputRows = Array.isArray(req.body) ? req.body : [req.body];

    const allowedColumns = [
      'movement_id',
      'category_id',
      'hardware_item_id',
      'status',
      'notes'
    ];

    const insertedRows = [];

    for (const row of inputRows) {
      const columns = allowedColumns.filter((column) => row[column] !== undefined);

      if (!columns.includes('movement_id')) {
        return res.status(400).json({
          error: 'movement_id est obligatoire.'
        });
      }

      const values = columns.map((column) => row[column]);
      const placeholders = columns.map((_, index) => `$${index + 1}`);

      const result = await pool.query(
        `
        INSERT INTO movement_items (${columns.join(', ')})
        VALUES (${placeholders.join(', ')})
        RETURNING *
        `,
        values
      );

      insertedRows.push(result.rows[0]);
    }

    res.status(201).json(insertedRows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.patch('/api/movement-items/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'category_id',
      'hardware_item_id',
      'status',
      'notes'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (columns.length === 0) {
      return res.status(400).json({ error: 'Aucune donnée à mettre à jour.' });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE movement_items
      SET ${setClause}
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Ligne matériel mouvement introuvable.' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/movement-licenses', async (req, res) => {
  try {
    const inputRows = Array.isArray(req.body) ? req.body : [req.body];

    const allowedColumns = [
      'movement_id',
      'license_type_id',
      'license_id',
      'status',
      'notes'
    ];

    const insertedRows = [];

    for (const row of inputRows) {
      const columns = allowedColumns.filter((column) => row[column] !== undefined);

      if (!columns.includes('movement_id') || !columns.includes('license_type_id')) {
        return res.status(400).json({
          error: 'movement_id et license_type_id sont obligatoires.'
        });
      }

      const values = columns.map((column) => row[column]);
      const placeholders = columns.map((_, index) => `$${index + 1}`);

      const result = await pool.query(
        `
        INSERT INTO movement_licenses (${columns.join(', ')})
        VALUES (${placeholders.join(', ')})
        RETURNING *
        `,
        values
      );

      insertedRows.push(result.rows[0]);
    }

    res.status(201).json(insertedRows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.patch('/api/movement-licenses/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'license_type_id',
      'license_id',
      'status',
      'notes'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (columns.length === 0) {
      return res.status(400).json({ error: 'Aucune donnée à mettre à jour.' });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE movement_licenses
      SET ${setClause}
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Ligne licence mouvement introuvable.' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/signed-documents', async (req, res) => {
  try {
    const allowedColumns = [
      'movement_id',
      'doc_type',
      'signer_name',
      'signer_email',
      'signed_at',
      'signature_data',
      'status',
      'content_snapshot'
    ];

    const columns = allowedColumns.filter((column) => req.body[column] !== undefined);

    if (!columns.includes('movement_id') || !columns.includes('doc_type')) {
      return res.status(400).json({
        error: 'movement_id et doc_type sont obligatoires.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    const placeholders = columns.map((_, index) => `$${index + 1}`);

    const result = await pool.query(
      `
      INSERT INTO signed_documents (${columns.join(', ')})
      VALUES (${placeholders.join(', ')})
      RETURNING *
      `,
      values
    );

const createdDocument = result.rows[0];

try {
  await getOrCreateSignedDocumentPdf(createdDocument.id);

  if (createdDocument.signer_email) {
    await sendSignedDocumentMail(createdDocument.id);
  }
} catch (mailOrPdfError) {
  console.error('Erreur PDF / email après signature', mailOrPdfError);

  await pool.query(
    `
    UPDATE signed_documents
    SET email_error = $1
    WHERE id = $2
    `,
    [
      mailOrPdfError.message,
      createdDocument.id
    ]
  ).catch(console.error);
}

res.status(201).json(createdDocument);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/signed-documents/:id/pdf', async (req, res) => {
  try {
    const {
      absolutePath,
      fileName
    } = await getOrCreateSignedDocumentPdf(req.params.id);

    res.download(absolutePath, fileName);
  } catch (error) {
    console.error(error);

    res.status(error.statusCode || 500).json({
      error: error.message
    });
  }
});

app.post('/api/signed-documents/:id/send-email', async (req, res) => {
  try {
    await sendSignedDocumentMail(req.params.id);

    res.json({
      ok: true
    });
  } catch (error) {
    console.error(error);

    await pool.query(
      `
      UPDATE signed_documents
      SET email_error = $1
      WHERE id = $2
      `,
      [
        error.message,
        req.params.id
      ]
    ).catch(console.error);

    res.status(500).json({
      error: error.message
    });
  }
});


app.get('/api/onboarding-action-templates', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *
      FROM onboarding_action_templates
      ORDER BY sort_order, label
    `);

    res.json(result.rows);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.post('/api/onboarding-action-templates', async (req, res) => {
  try {
    const {
      action_type,
      label,
      sort_order,
      is_active
    } = req.body;

    if (!action_type || !label) {
      return res.status(400).json({
        error: 'action_type et label sont obligatoires.'
      });
    }

    const result = await pool.query(
      `
      INSERT INTO onboarding_action_templates (
        action_type,
        label,
        sort_order,
        is_active
      )
      VALUES ($1, $2, $3, $4)
      RETURNING *
      `,
      [
        action_type,
        label,
        Number.isInteger(sort_order) ? sort_order : 0,
        is_active !== undefined ? is_active : true
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.patch('/api/onboarding-action-templates/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'action_type',
      'label',
      'sort_order',
      'is_active'
    ];

    const columns = allowedColumns.filter(
      (column) => req.body[column] !== undefined
    );

    if (columns.length === 0) {
      return res.status(400).json({
        error: 'Aucune donnée à mettre à jour.'
      });
    }

    const values = columns.map((column) => req.body[column]);
    values.push(req.params.id);

    const setClause = columns
      .map((column, index) => `${column} = $${index + 1}`)
      .join(', ');

    const result = await pool.query(
      `
      UPDATE onboarding_action_templates
      SET
        ${setClause},
        updated_at = now()
      WHERE id = $${values.length}
      RETURNING *
      `,
      values
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Modèle de tâche introuvable.'
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.delete('/api/onboarding-action-templates/:id', async (req, res) => {
  try {
    const result = await pool.query(
      `
      DELETE FROM onboarding_action_templates
      WHERE id = $1
      RETURNING *
      `,
      [
        req.params.id
      ]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        error: 'Modèle de tâche introuvable.'
      });
    }

    res.json({
      ok: true,
      deleted: result.rows[0]
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: error.message
    });
  }
});

app.use(express.static(path.join(__dirname, '../dist')));

app.use((req, res) => {
  res.sendFile(path.join(__dirname, '../dist/index.html'));
});

(async () => {
  try {
    await syncLuccaOffboardings();
  } catch (err) {
    console.error(err);
  }
})();

setInterval(async () => {
  try {
    await syncLuccaOffboardings();
  } catch (err) {
    console.error(err);
  }
}, 60000);

app.listen(port, () => {
  console.log(`GESTION_IT backend listening on port ${port}`);
});

