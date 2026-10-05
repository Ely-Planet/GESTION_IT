import { pool } from './db.mjs';

// Évolutions de schéma du module Projets IT (013) — idempotentes,
// exécutées au démarrage du serveur : le dossier db/ n'est pas copié
// dans l'image Docker.
const SCHEMA_SQL = `
DO $$
BEGIN
  -- Notifications client "en cours" / "terminée" : on marque les tâches
  -- déjà avancées comme notifiées pour ne pas envoyer de mails rétroactifs.
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'project_tasks' AND column_name = 'client_notified_in_progress_at'
  ) THEN
    ALTER TABLE project_tasks
      ADD COLUMN client_notified_in_progress_at timestamptz,
      ADD COLUMN client_notified_done_at timestamptz;
    UPDATE project_tasks
      SET client_notified_in_progress_at = now()
      WHERE status IN ('in_progress', 'in_review', 'done');
    UPDATE project_tasks
      SET client_notified_done_at = now()
      WHERE status = 'done';
  END IF;
END $$;

-- 1 GitHub Project (V2) = 1 projet GESTION_IT
ALTER TABLE projects ADD COLUMN IF NOT EXISTS github_project_id text UNIQUE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS github_project_url text;

-- Carte GitHub (issue ou brouillon) liée à la tâche
ALTER TABLE project_tasks ADD COLUMN IF NOT EXISTS github_item_id text UNIQUE;
-- Date du dernier changement de statut fait dans GESTION_IT : la synchro
-- GitHub ne l'écrase que si le statut GitHub est plus récent.
ALTER TABLE project_tasks ADD COLUMN IF NOT EXISTS status_updated_at timestamptz;
ALTER TABLE project_tasks ADD COLUMN IF NOT EXISTS github_comment_count integer NOT NULL DEFAULT 0;

-- Pièces jointes des demandes client rattachées à la tâche créée
ALTER TABLE project_files ADD COLUMN IF NOT EXISTS task_id uuid REFERENCES project_tasks(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_project_files_request ON project_files(client_request_id);
CREATE INDEX IF NOT EXISTS idx_project_files_task ON project_files(task_id);

-- Texte d'origine du client, conservé si le chef de projet le modifie
ALTER TABLE project_client_requests ADD COLUMN IF NOT EXISTS original_title text;
ALTER TABLE project_client_requests ADD COLUMN IF NOT EXISTS original_description text;
ALTER TABLE project_client_requests ADD COLUMN IF NOT EXISTS reviewed_by uuid REFERENCES app_accounts(id);
ALTER TABLE project_client_requests ADD COLUMN IF NOT EXISTS reviewed_at timestamptz;
ALTER TABLE project_client_requests ADD COLUMN IF NOT EXISTS rejection_reason text;

-- Commentaires de tâche (miroir des commentaires d'issue GitHub)
CREATE TABLE IF NOT EXISTS project_task_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id uuid NOT NULL REFERENCES project_tasks(id) ON DELETE CASCADE,
  author_account_id uuid REFERENCES app_accounts(id),
  author_name text NOT NULL,
  body text NOT NULL,
  github_comment_id bigint UNIQUE,
  github_comment_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_project_task_comments_task ON project_task_comments(task_id);

-- Nettoyage (014) : ancien pied technique recopié depuis GitHub dans la description
UPDATE project_tasks
SET description = NULLIF(btrim(regexp_replace(description, '\\s*Projet GESTION_IT : [^\\n]*\\nIdentifiant de tâche : .*$', '')), '')
WHERE description LIKE '%Identifiant de tâche : %';

-- Notifications affichées sur la page d'accueil
CREATE TABLE IF NOT EXISTS user_notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL REFERENCES app_accounts(id) ON DELETE CASCADE,
  type text NOT NULL,
  title text NOT NULL,
  body text,
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  task_id uuid REFERENCES project_tasks(id) ON DELETE CASCADE,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_user_notifications_account ON user_notifications(account_id, read_at);
`;

export async function ensureProjectsSchema() {
  await pool.query(SCHEMA_SQL);
  console.log('[Projets IT] Schéma 013 vérifié');
}
