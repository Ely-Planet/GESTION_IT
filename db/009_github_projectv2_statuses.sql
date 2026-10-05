BEGIN;

ALTER TABLE project_tasks DROP CONSTRAINT IF EXISTS project_tasks_status_check;

UPDATE project_tasks
SET status = CASE
  WHEN status IN ('closed', 'termine', 'done') THEN 'done'
  WHEN status = 'ready' THEN 'ready'
  WHEN status = 'in_progress' THEN 'in_progress'
  WHEN status = 'in_review' THEN 'in_review'
  ELSE 'backlog'
END;

ALTER TABLE project_tasks ALTER COLUMN status SET DEFAULT 'backlog';
ALTER TABLE project_tasks ADD CONSTRAINT project_tasks_status_check
CHECK (status IN ('backlog', 'ready', 'in_progress', 'in_review', 'done'));

COMMIT;
