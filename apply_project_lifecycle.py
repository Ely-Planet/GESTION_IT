from pathlib import Path
from datetime import datetime
import re, shutil, subprocess, sys

ROOT = Path.home() / 'www' / 'GESTION_IT'
SERVER = ROOT / 'server/projects.mjs'
LIST = ROOT / 'src/pages/projects/ProjectsList.tsx'
DETAIL = ROOT / 'src/pages/projects/ProjectDetail.tsx'
TYPES = ROOT / 'src/pages/projects/types.ts'
DB = ROOT / 'db/011_project_lifecycle.sql'
STAMP = datetime.now().strftime('%Y%m%d_%H%M%S')

for p in (SERVER, LIST, DETAIL, TYPES):
    if not p.exists(): sys.exit(f'[ERREUR] Fichier absent: {p}')

backup = ROOT / f'backup_project_lifecycle_{STAMP}'
for p in (SERVER, LIST, DETAIL, TYPES):
    d = backup / p.relative_to(ROOT)
    d.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(p, d)
print('[OK] Sauvegarde:', backup)

# 1) Migration
DB.write_text("""BEGIN;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS project_state text NOT NULL DEFAULT 'active';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS closed_at timestamptz;
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_project_state_check;
ALTER TABLE projects ADD CONSTRAINT projects_project_state_check
  CHECK (project_state IN ('active','maintenance','closed'));
UPDATE projects SET project_state='active' WHERE project_state IS NULL;
UPDATE projects SET closed_at=COALESCE(closed_at, now()) WHERE project_state='closed';
UPDATE projects SET closed_at=NULL WHERE project_state<>'closed';
COMMIT;
""", encoding='utf-8')
print('[OK] Migration créée:', DB)

# 2) Backend
s = SERVER.read_text(encoding='utf-8')
# Sort all project lists: active, maintenance, closed.
s = s.replace(
    'ORDER BY p.created_at DESC`,\n        params',
    "ORDER BY CASE p.project_state WHEN 'active' THEN 1 WHEN 'maintenance' THEN 2 ELSE 3 END, p.updated_at DESC, p.created_at DESC`,\n        params",
    1
)
# Include lifecycle fields in list base object.
anchor = "          status: p.status,\n          due_date: p.due_date,"
replacement = "          status: p.status,\n          project_state: p.project_state || 'active',\n          closed_at: p.closed_at,\n          due_date: p.due_date,"
if replacement not in s:
    if anchor not in s: sys.exit('[ERREUR] Objet base projet introuvable')
    s = s.replace(anchor, replacement, 1)

# Dedicated manager endpoint before task routes.
route = r'''
  app.put('/api/projects/:id/state', requireAuth, requireRole('manager'), async (req, res) => {
    try {
      const { projectState } = req.body;
      if (!['active', 'maintenance', 'closed'].includes(projectState)) {
        return res.status(400).json({ error: 'État de projet invalide' });
      }
      const result = await pool.query(
        `UPDATE projects
         SET project_state = $1,
             closed_at = CASE WHEN $1 = 'closed' THEN COALESCE(closed_at, now()) ELSE NULL END,
             updated_at = now()
         WHERE id = $2
         RETURNING *`,
        [projectState, req.params.id]
      );
      if (result.rowCount === 0) return res.status(404).json({ error: 'Projet introuvable' });
      res.json(result.rows[0]);
    } catch (error) {
      console.error('[Projets IT] Changement état projet', error);
      res.status(500).json({ error: error.message });
    }
  });

'''
if "app.put('/api/projects/:id/state'" not in s:
    marker = '  // -------------------------------------------------------------------\n  // Tâches'
    if marker not in s: sys.exit('[ERREUR] Marqueur Tâches introuvable')
    s = s.replace(marker, route + marker, 1)
    print('[OK] Endpoint état projet ajouté')

# Exclude closed projects from dashboard/reporting by default.
s = s.replace("SELECT * FROM projects WHERE status != 'archive'", "SELECT * FROM projects WHERE status != 'archive' AND project_state != 'closed'")
s = s.replace("WHERE p.status != 'archive'`", "WHERE p.status != 'archive' AND p.project_state != 'closed'`")
SERVER.write_text(s, encoding='utf-8')

# 3) Types
t = TYPES.read_text(encoding='utf-8')
for interface_name in ('ProjectListItem', 'ProjectDetailData'):
    start = t.find(f'export interface {interface_name}')
    if start < 0: start = t.find(f'export type {interface_name}')
    if start >= 0:
        end = t.find('\n}', start)
        block = t[start:end]
        if 'project_state' not in block:
            insert_at = t.find('\n', start) + 1
            t = t[:insert_at] + "  project_state?: 'active' | 'maintenance' | 'closed';\n  closed_at?: string | null;\n" + t[insert_at:]
TYPES.write_text(t, encoding='utf-8')
print('[OK] Types mis à jour')

# 4) ProjectsList: filter closed, maintenance last, toggle archives, badges.
f = LIST.read_text(encoding='utf-8')
state_anchor = '  const [showForm, setShowForm] = useState(false);'
if 'showClosedProjects' not in f:
    if state_anchor not in f: sys.exit('[ERREUR] showForm introuvable')
    f = f.replace(state_anchor, state_anchor + "\n  const [showClosedProjects, setShowClosedProjects] = useState(false);", 1)

loading_anchor = "  if (loading) return <div className=\"p-6 text-ink-500\">Chargement...</div>;"
calc = """  const closedProjectsCount = projects.filter((p) => p.project_state === 'closed').length;
  const visibleProjects = projects
    .filter((p) => showClosedProjects || p.project_state !== 'closed')
    .sort((a, b) => {
      const order = { active: 0, maintenance: 1, closed: 2 } as const;
      return (order[a.project_state || 'active'] ?? 0) - (order[b.project_state || 'active'] ?? 0);
    });

"""
if 'const visibleProjects =' not in f:
    if loading_anchor not in f: sys.exit('[ERREUR] Retour loading introuvable')
    f = f.replace(loading_anchor, loading_anchor + '\n\n' + calc, 1)

# Header buttons
old_header = '''        {isManager && (
          <button className="btn-primary" onClick={() => setShowForm((s) => !s)}>
            <Plus className="w-4 h-4" /> Nouveau projet
          </button>
        )}'''
new_header = '''        <div className="flex items-center gap-2">
          {closedProjectsCount > 0 && (
            <button className="btn-ghost text-sm" onClick={() => setShowClosedProjects((value) => !value)}>
              {showClosedProjects ? 'Masquer les projets clôturés' : `Afficher les projets clôturés (${closedProjectsCount})`}
            </button>
          )}
          {isManager && (
            <button className="btn-primary" onClick={() => setShowForm((s) => !s)}>
              <Plus className="w-4 h-4" /> Nouveau projet
            </button>
          )}
        </div>'''
if 'Afficher les projets clôturés' not in f:
    if old_header not in f: sys.exit('[ERREUR] Entête Nouveau projet introuvable')
    f = f.replace(old_header, new_header, 1)

f = f.replace('projects.length === 0', 'visibleProjects.length === 0', 1)
f = f.replace('{projects.map((p) => (', '{visibleProjects.map((p) => (', 1)
# Add lifecycle badge next to current status badge.
badge_anchor = '<StatusBadge status={p.status} />'
lifecycle_badge = '''<div className="flex items-center gap-2">
                  {p.project_state === 'maintenance' && (
                    <span className="badge bg-amber-100 text-amber-700">Maintenance</span>
                  )}
                  {p.project_state === 'closed' && (
                    <span className="badge bg-ink-100 text-ink-600">Clôturé</span>
                  )}
                  <StatusBadge status={p.status} />
                </div>'''
if 'p.project_state === \'maintenance\'' not in f:
    if badge_anchor not in f: sys.exit('[ERREUR] Badge projet introuvable')
    f = f.replace(badge_anchor, lifecycle_badge, 1)
LIST.write_text(f, encoding='utf-8')
print('[OK] Liste projets filtrée et triée')

# 5) ProjectDetail: manager select.
d = DETAIL.read_text(encoding='utf-8')
load_anchor = '''  async function load() {
    setProject(await projectsApi.getProject(projectId));
  }'''
change_fn = '''  async function load() {
    setProject(await projectsApi.getProject(projectId));
  }

  async function changeProjectState(projectState: 'active' | 'maintenance' | 'closed') {
    const response = await fetch(`/api/projects/${projectId}/state`, {
      method: 'PUT',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ projectState }),
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(payload.error || 'Erreur lors du changement d’état');
    await load();
  }'''
if 'changeProjectState' not in d:
    if load_anchor not in d: sys.exit('[ERREUR] Fonction load détail introuvable')
    d = d.replace(load_anchor, change_fn, 1)

old_status = '<StatusBadge status={project.status} />'
new_status = '''<div className="flex items-center gap-2">
            {isManager && (
              <select
                className="input py-1 text-sm w-36"
                value={project.project_state || 'active'}
                onChange={(event) => {
                  const nextState = event.target.value as 'active' | 'maintenance' | 'closed';
                  const label = nextState === 'closed' ? 'clôturer' : nextState === 'maintenance' ? 'mettre en maintenance' : 'réactiver';
                  if (confirm(`Voulez-vous ${label} ce projet ?`)) {
                    void changeProjectState(nextState).catch((error) => alert(error.message));
                  }
                }}
              >
                <option value="active">Actif</option>
                <option value="maintenance">Maintenance</option>
                <option value="closed">Clôturé</option>
              </select>
            )}
            <StatusBadge status={project.status} />
          </div>'''
if 'Voulez-vous ${label} ce projet' not in d:
    if old_status not in d: sys.exit('[ERREUR] Badge détail introuvable')
    d = d.replace(old_status, new_status, 1)
DETAIL.write_text(d, encoding='utf-8')
print('[OK] Sélecteur état ajouté au détail')

# 6) Apply migration
try:
    subprocess.run(['docker','exec','-i','gestion_it_postgres','psql','-U','gestion_it','-d','gestion_it'], input=DB.read_text(), text=True, check=True)
    print('[OK] Migration PostgreSQL appliquée')
except Exception as e:
    print('[ATTENTION] Migration auto impossible:', e)
    print("cat db/011_project_lifecycle.sql | docker exec -i gestion_it_postgres psql -U gestion_it -d gestion_it")

print('\n[SUCCÈS] États projet Actif / Maintenance / Clôturé installés')
print('[INFO] Rebuild: docker compose build --no-cache && docker compose up -d')
