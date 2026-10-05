BEGIN;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS project_state text NOT NULL DEFAULT 'active';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS closed_at timestamptz;
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_project_state_check;
ALTER TABLE projects ADD CONSTRAINT projects_project_state_check
  CHECK (project_state IN ('active','maintenance','closed'));
UPDATE projects SET project_state='active' WHERE project_state IS NULL;
UPDATE projects SET closed_at=COALESCE(closed_at, now()) WHERE project_state='closed';
UPDATE projects SET closed_at=NULL WHERE project_state<>'closed';
COMMIT;
