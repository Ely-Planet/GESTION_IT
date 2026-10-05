BEGIN;

ALTER TABLE project_tasks
  ADD COLUMN IF NOT EXISTS completed_at timestamptz;

UPDATE project_tasks
SET completed_at = COALESCE(completed_at, updated_at, now())
WHERE status = 'done' AND completed_at IS NULL;

UPDATE project_tasks
SET completed_at = NULL
WHERE status <> 'done' AND completed_at IS NOT NULL;

COMMIT;
