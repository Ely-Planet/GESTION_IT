BEGIN;

ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_project_state_check;
ALTER TABLE projects ALTER COLUMN project_state SET DEFAULT 'new';

UPDATE projects SET project_state = 'new' WHERE project_state = 'active' OR project_state IS NULL;

ALTER TABLE projects ADD CONSTRAINT projects_project_state_check
CHECK (project_state IN ('new', 'in_progress', 'maintenance', 'closed'));

CREATE OR REPLACE FUNCTION refresh_project_lifecycle(p_project_id uuid)
RETURNS void AS $$
DECLARE
  current_state text;
  total_tasks integer;
  done_tasks integer;
  started_tasks integer;
  automatic_state text;
BEGIN
  SELECT project_state INTO current_state FROM projects WHERE id = p_project_id;
  IF current_state IS NULL OR current_state = 'closed' THEN RETURN; END IF;

  SELECT COUNT(*),
         COUNT(*) FILTER (WHERE status = 'done'),
         COUNT(*) FILTER (WHERE status <> 'backlog')
    INTO total_tasks, done_tasks, started_tasks
  FROM project_tasks
  WHERE project_id = p_project_id;

  automatic_state := CASE
    WHEN total_tasks = 0 THEN 'new'
    WHEN done_tasks = total_tasks THEN 'maintenance'
    WHEN started_tasks > 0 THEN 'in_progress'
    ELSE 'new'
  END;

  UPDATE projects
  SET project_state = automatic_state,
      closed_at = NULL,
      updated_at = CASE WHEN project_state IS DISTINCT FROM automatic_state THEN now() ELSE updated_at END
  WHERE id = p_project_id AND project_state <> 'closed';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION project_tasks_lifecycle_trigger()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM refresh_project_lifecycle(OLD.project_id);
    RETURN OLD;
  END IF;
  PERFORM refresh_project_lifecycle(NEW.project_id);
  IF TG_OP = 'UPDATE' AND OLD.project_id IS DISTINCT FROM NEW.project_id THEN
    PERFORM refresh_project_lifecycle(OLD.project_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_project_tasks_lifecycle ON project_tasks;
CREATE TRIGGER trg_project_tasks_lifecycle
AFTER INSERT OR UPDATE OF status, project_id OR DELETE ON project_tasks
FOR EACH ROW EXECUTE FUNCTION project_tasks_lifecycle_trigger();

DO $$
DECLARE r record;
BEGIN
  FOR r IN SELECT id FROM projects WHERE project_state <> 'closed' LOOP
    PERFORM refresh_project_lifecycle(r.id);
  END LOOP;
END $$;

COMMIT;
