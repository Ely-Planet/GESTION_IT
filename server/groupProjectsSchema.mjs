import { pool } from './db.mjs';

// Module "Projets Groupe" : projets des managers et directeurs (sans GitHub),
// avec membres, tâches / sous-tâches, comptes rendus, communications par mail
// et réunions Outlook. Tables séparées de Projets IT. Idempotent, exécuté au
// démarrage du serveur (le dossier db/ n'est pas copié dans l'image Docker).
const SCHEMA_SQL = `
CREATE TABLE IF NOT EXISTS group_projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  start_date date,
  due_date date,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed', 'archive')),
  created_by uuid REFERENCES app_accounts(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Membres : "responsable" (gère le projet et ses membres) ou "membre".
CREATE TABLE IF NOT EXISTS group_project_members (
  project_id uuid NOT NULL REFERENCES group_projects(id) ON DELETE CASCADE,
  account_id uuid NOT NULL REFERENCES app_accounts(id) ON DELETE CASCADE,
  role text NOT NULL DEFAULT 'membre' CHECK (role IN ('responsable', 'membre')),
  added_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (project_id, account_id)
);
CREATE INDEX IF NOT EXISTS idx_group_members_account ON group_project_members(account_id);

CREATE TABLE IF NOT EXISTS group_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES group_projects(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  status text NOT NULL DEFAULT 'backlog' CHECK (status IN ('backlog', 'ready', 'in_progress', 'in_review', 'done')),
  assignee_account_id uuid REFERENCES app_accounts(id) ON DELETE SET NULL,
  estimated_hours numeric NOT NULL DEFAULT 0,
  spent_hours numeric NOT NULL DEFAULT 0,
  start_date date,
  end_date date,
  completed_at timestamptz,
  overdue_notified_for date,
  overdue_notified_account uuid,
  created_by uuid REFERENCES app_accounts(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_group_tasks_project ON group_tasks(project_id);

CREATE TABLE IF NOT EXISTS group_subtasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id uuid NOT NULL REFERENCES group_tasks(id) ON DELETE CASCADE,
  title text NOT NULL,
  status text NOT NULL DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'done')),
  assignee_account_id uuid REFERENCES app_accounts(id) ON DELETE SET NULL,
  start_date date,
  end_date date,
  sort_order integer NOT NULL DEFAULT 0,
  completed_at timestamptz,
  overdue_notified_for date,
  overdue_notified_account uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_group_subtasks_task ON group_subtasks(task_id);

CREATE TABLE IF NOT EXISTS group_task_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id uuid NOT NULL REFERENCES group_tasks(id) ON DELETE CASCADE,
  author_account_id uuid REFERENCES app_accounts(id),
  author_name text NOT NULL,
  body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_group_task_comments_task ON group_task_comments(task_id);

CREATE TABLE IF NOT EXISTS group_files (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES group_projects(id) ON DELETE CASCADE,
  task_id uuid REFERENCES group_tasks(id) ON DELETE CASCADE,
  minute_id uuid,
  filename text NOT NULL,
  storage_path text NOT NULL,
  uploaded_by uuid REFERENCES app_accounts(id),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_group_files_task ON group_files(task_id);

-- Réunions : invitation Outlook (Graph) dans le calendrier de l'organisateur.
CREATE TABLE IF NOT EXISTS group_meetings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES group_projects(id) ON DELETE CASCADE,
  title text NOT NULL,
  agenda text,
  location text,
  online boolean NOT NULL DEFAULT true,
  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  organizer_account_id uuid NOT NULL REFERENCES app_accounts(id),
  attendee_ids uuid[] NOT NULL DEFAULT '{}',
  status text NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'cancelled')),
  outlook_event_id text,
  online_meeting_url text,
  outlook_error text,
  minutes_reminders integer NOT NULL DEFAULT 0,
  minutes_reminded_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_group_meetings_project ON group_meetings(project_id, start_at);

-- Comptes rendus de réunion (liés ou non à une réunion planifiée).
CREATE TABLE IF NOT EXISTS group_minutes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES group_projects(id) ON DELETE CASCADE,
  meeting_id uuid REFERENCES group_meetings(id) ON DELETE SET NULL,
  title text NOT NULL,
  meeting_date date NOT NULL,
  content text NOT NULL,
  author_account_id uuid REFERENCES app_accounts(id),
  updated_by uuid REFERENCES app_accounts(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_group_minutes_project ON group_minutes(project_id, meeting_date);

-- Communications : mails envoyés depuis la boîte d'un membre et réponses
-- relevées dans cette même boîte (même conversation Outlook).
CREATE TABLE IF NOT EXISTS group_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES group_projects(id) ON DELETE CASCADE,
  direction text NOT NULL CHECK (direction IN ('sent', 'reply')),
  mailbox_account_id uuid NOT NULL REFERENCES app_accounts(id),
  conversation_id text NOT NULL,
  internet_message_id text UNIQUE,
  from_name text,
  from_email text,
  recipients jsonb NOT NULL DEFAULT '[]',
  subject text,
  body text,
  has_attachments boolean NOT NULL DEFAULT false,
  sent_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_group_messages_project ON group_messages(project_id, sent_at);
CREATE INDEX IF NOT EXISTS idx_group_messages_conversation ON group_messages(conversation_id);

-- Notifications de la page d'accueil : lien vers un projet Groupe.
ALTER TABLE user_notifications ADD COLUMN IF NOT EXISTS group_project_id uuid REFERENCES group_projects(id) ON DELETE CASCADE;
`;

export async function ensureGroupProjectsSchema() {
  await pool.query(SCHEMA_SQL);
  console.log('[Projets Groupe] Schéma vérifié');
}
