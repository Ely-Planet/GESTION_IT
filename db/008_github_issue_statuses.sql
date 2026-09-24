BEGIN;

ALTER TABLE project_tasks DROP CONSTRAINT IF EXISTS project_tasks_status_check;

UPDATE project_tasks
SET status = CASE
  WHEN status = 'termine' THEN 'closed'
  ELSE 'open'
END
WHERE status NOT IN ('open','closed');

ALTER TABLE project_tasks
  ALTER COLUMN status SET DEFAULT 'open';

ALTER TABLE project_tasks
  ADD CONSTRAINT project_tasks_status_check
  CHECK (status IN ('open','closed'));

COMMIT;
