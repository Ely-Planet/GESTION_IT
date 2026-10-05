from pathlib import Path
from datetime import datetime
import re, shutil, subprocess, sys

ROOT = Path.home() / 'www' / 'GESTION_IT'
SERVER = ROOT / 'server/projects.mjs'
LIST = ROOT / 'src/pages/projects/ProjectsList.tsx'
DETAIL = ROOT / 'src/pages/projects/ProjectDetail.tsx'
TYPES = ROOT / 'src/pages/projects/types.ts'
DB = ROOT / 'db/012_project_auto_lifecycle.sql'
STAMP = datetime.now().strftime('%Y%m%d_%H%M%S')

for p in (SERVER, LIST, DETAIL, TYPES):
    if not p.exists(): sys.exit(f'[ERREUR] Fichier absent : {p}')

backup = ROOT / f'backup_project_auto_lifecycle_{STAMP}'
for p in (SERVER, LIST, DETAIL, TYPES):
    d = backup / p.relative_to(ROOT)
    d.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(p, d)
print('[OK] Sauvegarde :', backup)

# -----------------------------------------------------------------------------
# 1. PostgreSQL : cycle automatique piloté par les tâches
# -----------------------------------------------------------------------------
DB.write_text(r'''BEGIN;

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
''', encoding='utf-8')
print('[OK] Migration créée :', DB)

# -----------------------------------------------------------------------------
# 2. Backend : clôture/réactivation et suppression définitive manager
# -----------------------------------------------------------------------------
s = SERVER.read_text(encoding='utf-8')

# Mise à jour de l'endpoint existant.
s = s.replace(
    "if (!['active', 'maintenance', 'closed'].includes(projectState))",
    "if (!['new', 'closed'].includes(projectState))"
)
s = s.replace(
    "closed_at = CASE WHEN $1 = 'closed' THEN COALESCE(closed_at, now()) ELSE NULL END,",
    "closed_at = CASE WHEN $1 = 'closed' THEN COALESCE(closed_at, now()) ELSE NULL END,"
)

# Ajouter suppression sûre de toutes les données dépendantes connues.
delete_route = r'''
  app.delete('/api/projects/:id', requireAuth, requireRole('manager'), async (req, res) => {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const projectId = req.params.id;
      const found = await client.query('SELECT id, name FROM projects WHERE id = $1', [projectId]);
      if (found.rowCount === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ error: 'Projet introuvable' });
      }
      await client.query('DELETE FROM project_files WHERE project_id = $1', [projectId]);
      await client.query('DELETE FROM project_messages WHERE project_id = $1', [projectId]);
      await client.query('DELETE FROM project_client_requests WHERE project_id = $1', [projectId]);
      await client.query('DELETE FROM project_assignments WHERE project_id = $1', [projectId]);
      await client.query('DELETE FROM project_tasks WHERE project_id = $1', [projectId]);
      await client.query('DELETE FROM projects WHERE id = $1', [projectId]);
      await client.query('COMMIT');
      res.json({ ok: true });
    } catch (error) {
      await client.query('ROLLBACK').catch(() => {});
      console.error('[Projets IT] Suppression projet', error);
      res.status(500).json({ error: error.message });
    } finally {
      client.release();
    }
  });

'''
if "app.delete('/api/projects/:id'" not in s:
    marker = '  // -------------------------------------------------------------------\n  // Tâches'
    if marker not in s: sys.exit('[ERREUR] Marqueur Tâches introuvable')
    s = s.replace(marker, delete_route + marker, 1)
    print('[OK] Endpoint suppression projet ajouté')

# Tri : nouveau puis en cours puis maintenance puis clôturé.
s = re.sub(
    r"ORDER BY CASE p\.project_state WHEN 'active' THEN 1 WHEN 'maintenance' THEN 2 ELSE 3 END,",
    "ORDER BY CASE p.project_state WHEN 'new' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'maintenance' THEN 3 ELSE 4 END,",
    s
)
SERVER.write_text(s, encoding='utf-8')

# -----------------------------------------------------------------------------
# 3. Types
# -----------------------------------------------------------------------------
t = TYPES.read_text(encoding='utf-8')
t = t.replace("'active' | 'maintenance' | 'closed'", "'new' | 'in_progress' | 'maintenance' | 'closed'")
TYPES.write_text(t, encoding='utf-8')
print('[OK] Types mis à jour')

# -----------------------------------------------------------------------------
# 4. Liste : Nouveau / En cours / Maintenance / Clôturé
# -----------------------------------------------------------------------------
f = LIST.read_text(encoding='utf-8')
f = f.replace(
    "const order = { active: 0, maintenance: 1, closed: 2 } as const;",
    "const order = { new: 0, in_progress: 1, maintenance: 2, closed: 3 } as const;"
)
f = f.replace("a.project_state || 'active'", "a.project_state || 'new'")
f = f.replace("b.project_state || 'active'", "b.project_state || 'new'")

old_badges = '''                  {p.project_state === 'maintenance' && (
                    <span className="badge bg-amber-100 text-amber-700">Maintenance</span>
                  )}'''
new_badges = '''                  {(p.project_state || 'new') === 'new' && (
                    <span className="badge bg-blue-100 text-blue-700">Nouveau</span>
                  )}
                  {p.project_state === 'in_progress' && (
                    <span className="badge bg-emerald-100 text-emerald-700">En cours</span>
                  )}
                  {p.project_state === 'maintenance' && (
                    <span className="badge bg-amber-100 text-amber-700">Maintenance</span>
                  )}'''
if "Nouveau</span>" not in f:
    if old_badges not in f: sys.exit('[ERREUR] Badge Maintenance introuvable')
    f = f.replace(old_badges, new_badges, 1)
LIST.write_text(f, encoding='utf-8')
print('[OK] Badges et ordre de liste mis à jour')

# -----------------------------------------------------------------------------
# 5. Détail : badge automatique + boutons Clôturer, Réactiver, Supprimer
# -----------------------------------------------------------------------------
d = DETAIL.read_text(encoding='utf-8')
# Type de la fonction existante.
d = d.replace(
    "projectState: 'active' | 'maintenance' | 'closed'",
    "projectState: 'new' | 'closed'"
)

# Ajouter suppression après changeProjectState.
if 'async function deleteProject()' not in d:
    marker = '  useEffect(() => {'
    delete_fn = '''  async function deleteProject() {
    const response = await fetch(`/api/projects/${projectId}`, {
      method: 'DELETE',
      credentials: 'include',
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(payload.error || 'Erreur lors de la suppression');
    onBack();
  }

'''
    if marker not in d: sys.exit('[ERREUR] useEffect introuvable')
    d = d.replace(marker, delete_fn + marker, 1)

# Remplacer le sélecteur manuel par le statut automatique et les actions manager.
pattern = re.compile(
    r'''<div className="flex items-center gap-2">\s*\{isManager && \(\s*<select[\s\S]*?</select>\s*\)\}\s*<StatusBadge status=\{project\.status\} />\s*</div>'''
)
actions = '''<div className="flex items-center gap-2 flex-wrap justify-end">
            <span className={`badge ${
              project.project_state === 'closed'
                ? 'bg-ink-100 text-ink-600'
                : project.project_state === 'maintenance'
                  ? 'bg-amber-100 text-amber-700'
                  : project.project_state === 'in_progress'
                    ? 'bg-emerald-100 text-emerald-700'
                    : 'bg-blue-100 text-blue-700'
            }`}>
              {project.project_state === 'closed'
                ? 'Clôturé'
                : project.project_state === 'maintenance'
                  ? 'Maintenance'
                  : project.project_state === 'in_progress'
                    ? 'En cours'
                    : 'Nouveau'}
            </span>
            <StatusBadge status={project.status} />
            {isManager && project.project_state !== 'closed' && (
              <button
                className="btn-secondary text-sm"
                onClick={() => {
                  if (confirm('Clôturer ce projet ? Il sera masqué de la liste principale.')) {
                    void changeProjectState('closed').catch((error) => alert(error.message));
                  }
                }}
              >
                Clôturer
              </button>
            )}
            {isManager && project.project_state === 'closed' && (
              <button
                className="btn-secondary text-sm"
                onClick={() => {
                  if (confirm('Réactiver ce projet ? Son état sera recalculé depuis ses tâches.')) {
                    void changeProjectState('new').then(load).catch((error) => alert(error.message));
                  }
                }}
              >
                Réactiver
              </button>
            )}
            {isManager && (
              <button
                className="btn-ghost text-sm text-red-600 hover:text-red-700"
                onClick={() => {
                  if (confirm(`Supprimer définitivement le projet "${project.name}" et toutes ses données ? Cette action est irréversible.`)) {
                    void deleteProject().catch((error) => alert(error.message));
                  }
                }}
              >
                Supprimer
              </button>
            )}
          </div>'''
if 'Supprimer définitivement le projet' not in d:
    match = pattern.search(d)
    if not match: sys.exit('[ERREUR] Bloc actions du projet introuvable')
    d = d[:match.start()] + actions + d[match.end():]
DETAIL.write_text(d, encoding='utf-8')
print('[OK] Actions Clôturer / Réactiver / Supprimer ajoutées')

# -----------------------------------------------------------------------------
# 6. Migration
# -----------------------------------------------------------------------------
try:
    subprocess.run(
        ['docker','exec','-i','gestion_it_postgres','psql','-U','gestion_it','-d','gestion_it'],
        input=DB.read_text(encoding='utf-8'), text=True, check=True
    )
    print('[OK] Migration PostgreSQL appliquée')
except Exception as e:
    print('[ATTENTION] Migration automatique impossible :', e)
    print("cat db/012_project_auto_lifecycle.sql | docker exec -i gestion_it_postgres psql -U gestion_it -d gestion_it")

print('\n[SUCCÈS] Cycle automatique des projets installé')
print('[RÈGLES] 0 tâche ou uniquement Backlog = Nouveau')
print('[RÈGLES] Au moins une tâche démarrée = En cours')
print('[RÈGLES] Toutes les tâches Done = Maintenance')
print('[RÈGLES] Clôturé reste manuel et n’est jamais écrasé automatiquement')
print('[INFO] Rebuild : docker compose build --no-cache && docker compose up -d')
