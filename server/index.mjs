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

app.use(express.static(path.join(__dirname, '../dist')));

app.use((req, res) => {
  res.sendFile(path.join(__dirname, '../dist/index.html'));
});

app.listen(port, () => {
  console.log(`GESTION_IT backend listening on port ${port}`);
});

