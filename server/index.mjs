import 'dotenv/config';
import { pool } from './db.mjs';
import express from 'express';
import session from 'express-session';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';
import axios from 'axios';
import path from 'path';
import { fileURLToPath } from 'url';
import { ConfidentialClientApplication } from '@azure/msal-node';
import { syncMicrosoftLicenses } from './syncMicrosoftLicenses.mjs';
import { getMicrosoftOnboardingServices } from './microsoftOnboardingServices.mjs';
import { createOnboardingRequest } from './onboardingRequest.mjs';

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

app.set('trust proxy', 1);

app.use(
  helmet({
    contentSecurityPolicy: false
  })
);

app.use(cookieParser());
app.use(express.json());

app.post('/api/sync-microsoft-licenses', syncMicrosoftLicenses);

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

app.post('/api/onboarding-request', createOnboardingRequest);

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
      'first_name',
      'last_name',
      'email',
      'service_id',
      'contract_type_id',
      'contract_end_date',
      'manager_name',
      'job_title',
      'is_active'
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
      'reference',
      'serial_number',
      'brand',
      'model',
      'status',
      'intune_device_id',
      'atera_ticket_id',
      'purchase_date',
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

app.patch('/api/hardware-items/:id', async (req, res) => {
  try {
    const allowedColumns = [
      'category_id',
      'reference',
      'serial_number',
      'brand',
      'model',
      'status',
      'intune_device_id',
      'atera_ticket_id',
      'purchase_date',
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
      'notes'
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

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});





app.use(express.static(path.join(__dirname, '../dist')));

app.use((req, res) => {
  res.sendFile(path.join(__dirname, '../dist/index.html'));
});

app.listen(port, () => {
  console.log(`GESTION_IT backend listening on port ${port}`);
});

