-- =====================================================
-- Module "Projets IT" — gestion de projets dev/infra,
-- affectations, tâches, demandes clients, échanges.
--
-- Pas de table "users" : l'authentification est 100% SSO
-- Microsoft (voir server/index.mjs /auth/callback). app_accounts
-- est un cache, alimenté à chaque connexion, de toute personne
-- s'étant déjà connectée à l'application — c'est dans cette
-- table que les projets piochent leurs chefs de projet,
-- contributeurs et clients internes.
-- =====================================================

CREATE TABLE IF NOT EXISTS app_accounts (
    id uuid PRIMARY KEY,
    email text NOT NULL,
    display_name text NOT NULL,
    is_it boolean NOT NULL DEFAULT false,
    is_it_manager boolean NOT NULL DEFAULT false,
    is_rh boolean NOT NULL DEFAULT false,
    is_manager boolean NOT NULL DEFAULT false,
    is_director boolean NOT NULL DEFAULT false,
    weekly_capacity_hours integer NOT NULL DEFAULT 35,
    last_login_at timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_app_accounts_email ON app_accounts(email);

-- =====================================================
-- projects
-- =====================================================

CREATE TABLE IF NOT EXISTS projects (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    description text,
    type text NOT NULL CHECK (type IN ('dev', 'infra')),
    status text NOT NULL DEFAULT 'en_attente'
        CHECK (status IN ('en_attente', 'en_cours', 'termine', 'archive')),
    created_by uuid REFERENCES app_accounts(id),
    client_account_id uuid REFERENCES app_accounts(id),
    github_repo_url text,
    due_date date,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_projects_client ON projects(client_account_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);

-- =====================================================
-- project_assignments
-- =====================================================

CREATE TABLE IF NOT EXISTS project_assignments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    account_id uuid NOT NULL REFERENCES app_accounts(id),
    project_role text NOT NULL DEFAULT 'contributeur'
        CHECK (project_role IN ('chef_de_projet', 'contributeur')),
    UNIQUE (project_id, account_id)
);

CREATE INDEX IF NOT EXISTS idx_project_assignments_account ON project_assignments(account_id);

-- =====================================================
-- project_tasks
-- =====================================================

CREATE TABLE IF NOT EXISTS project_tasks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title text NOT NULL,
    description text,
    status text NOT NULL DEFAULT 'a_faire'
        CHECK (status IN ('a_faire', 'en_cours', 'termine', 'bloque')),
    assignee_account_id uuid REFERENCES app_accounts(id),
    estimated_hours numeric NOT NULL DEFAULT 0,
    spent_hours numeric NOT NULL DEFAULT 0,
    origin text NOT NULL DEFAULT 'manuelle'
        CHECK (origin IN ('manuelle', 'demande_client')),
    github_issue_url text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_project_tasks_project ON project_tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_project_tasks_assignee ON project_tasks(assignee_account_id);

-- =====================================================
-- project_client_requests
-- =====================================================

CREATE TABLE IF NOT EXISTS project_client_requests (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    client_account_id uuid NOT NULL REFERENCES app_accounts(id),
    title text NOT NULL,
    description text,
    status text NOT NULL DEFAULT 'en_attente'
        CHECK (status IN ('en_attente', 'validee', 'rejetee')),
    task_id uuid UNIQUE REFERENCES project_tasks(id),
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_project_requests_project ON project_client_requests(project_id);

-- =====================================================
-- project_messages
-- =====================================================

CREATE TABLE IF NOT EXISTS project_messages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    author_account_id uuid NOT NULL REFERENCES app_accounts(id),
    recipient_type text NOT NULL CHECK (recipient_type IN ('equipe', 'client')),
    content text NOT NULL,
    email_sent boolean NOT NULL DEFAULT false,
    created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_project_messages_project ON project_messages(project_id);

-- =====================================================
-- project_files
-- =====================================================

CREATE TABLE IF NOT EXISTS project_files (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
    message_id uuid REFERENCES project_messages(id) ON DELETE CASCADE,
    client_request_id uuid REFERENCES project_client_requests(id) ON DELETE CASCADE,
    filename text NOT NULL,
    storage_path text NOT NULL,
    uploaded_by_account_id uuid REFERENCES app_accounts(id),
    created_at timestamptz DEFAULT now()
);
