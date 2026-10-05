from pathlib import Path
from datetime import datetime
import re
import shutil
import subprocess
import sys

ROOT = Path.home() / 'www' / 'GESTION_IT'
SERVER = ROOT / 'server/projects.mjs'
TASKS = ROOT / 'src/pages/projects/tabs/TasksTab.tsx'
DB_DIR = ROOT / 'db'
STAMP = datetime.now().strftime('%Y%m%d_%H%M%S')

for path in (SERVER, TASKS):
    if not path.exists():
        sys.exit(f'[ERREUR] Fichier absent : {path}')

backup_dir = ROOT / f'backup_done_visibility_{STAMP}'
for path in (SERVER, TASKS):
    destination = backup_dir / path.relative_to(ROOT)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, destination)
print('[OK] Sauvegarde :', backup_dir)

# 1. Migration : date réelle de passage à Done.
DB_DIR.mkdir(exist_ok=True)
migration = DB_DIR / '010_project_tasks_completed_at.sql'
migration.write_text('''BEGIN;

ALTER TABLE project_tasks
  ADD COLUMN IF NOT EXISTS completed_at timestamptz;

UPDATE project_tasks
SET completed_at = COALESCE(completed_at, updated_at, now())
WHERE status = 'done' AND completed_at IS NULL;

UPDATE project_tasks
SET completed_at = NULL
WHERE status <> 'done' AND completed_at IS NOT NULL;

COMMIT;
''', encoding='utf-8')
print('[OK] Migration créée :', migration)

# 2. Backend : gérer completed_at sur chaque changement de statut.
s = SERVER.read_text(encoding='utf-8')

old_update = '''status = COALESCE($1, status),
           spent_hours = COALESCE($2, spent_hours),'''
new_update = '''status = COALESCE($1, status),
           completed_at = CASE
             WHEN $1 = 'done' AND status <> 'done' THEN now()
             WHEN $1 IS NOT NULL AND $1 <> 'done' THEN NULL
             ELSE completed_at
           END,
           spent_hours = COALESCE($2, spent_hours),'''
if new_update not in s:
    if old_update not in s:
        sys.exit('[ERREUR] Bloc UPDATE project_tasks introuvable dans server/projects.mjs')
    s = s.replace(old_update, new_update, 1)
    print('[OK] completed_at ajouté à la mise à jour manuelle')
else:
    print('[OK] completed_at déjà géré dans la mise à jour manuelle')

# Synchronisation ProjectV2 : ne pas réinitialiser completed_at à chaque passage du cron.
old_projectv2 = '''SET title = COALESCE($1, title), description = $2, status = $3, updated_at = now()
         WHERE github_issue_url = $4'''
new_projectv2 = '''SET title = COALESCE($1, title),
             description = $2,
             completed_at = CASE
               WHEN $3 = 'done' AND status <> 'done' THEN now()
               WHEN $3 <> 'done' THEN NULL
               ELSE completed_at
             END,
             status = $3,
             updated_at = CASE
               WHEN title IS DISTINCT FROM $1
                 OR description IS DISTINCT FROM $2
                 OR status IS DISTINCT FROM $3
               THEN now()
               ELSE updated_at
             END
         WHERE github_issue_url = $4'''
if new_projectv2 not in s:
    if old_projectv2 not in s:
        sys.exit('[ERREUR] Bloc de synchronisation ProjectV2 introuvable')
    s = s.replace(old_projectv2, new_projectv2, 1)
    print('[OK] completed_at ajouté à la synchronisation ProjectV2')
else:
    print('[OK] completed_at déjà géré dans ProjectV2')

SERVER.write_text(s, encoding='utf-8')

# 3. Frontend : masquer les Done vieux de 5 jours avec bouton d'affichage.
f = TASKS.read_text(encoding='utf-8')

show_state_anchor = "  const [showForm, setShowForm] = useState(false);"
show_state_new = """  const [showForm, setShowForm] = useState(false);
  const [showOldDone, setShowOldDone] = useState(false);"""
if 'const [showOldDone, setShowOldDone]' not in f:
    if show_state_anchor not in f:
        sys.exit('[ERREUR] État showForm introuvable dans TasksTab.tsx')
    f = f.replace(show_state_anchor, show_state_new, 1)
    print('[OK] État showOldDone ajouté')

# Ajouter les calculs juste après const tasks.
tasks_anchor = "  const tasks = project.tasks || [];"
calculations = """  const tasks = project.tasks || [];
  const doneCutoff = Date.now() - 5 * 24 * 60 * 60 * 1000;
  const oldDoneTasks = tasks.filter((task) =>
    task.status === 'done' &&
    Boolean(task.completed_at) &&
    new Date(task.completed_at as string).getTime() < doneCutoff
  );
  const visibleTasks = showOldDone
    ? tasks
    : tasks.filter((task) => !oldDoneTasks.some((doneTask) => doneTask.id === task.id));"""
if 'const oldDoneTasks =' not in f:
    if tasks_anchor not in f:
        sys.exit('[ERREUR] Déclaration tasks introuvable dans TasksTab.tsx')
    f = f.replace(tasks_anchor, calculations, 1)
    print('[OK] Filtrage des Done de plus de 5 jours ajouté')

# Les colonnes doivent utiliser visibleTasks, mais le drag doit continuer à chercher dans toutes les tâches.
f = f.replace(
    "const columnTasks = tasks.filter((task) => task.status === status);",
    "const columnTasks = visibleTasks.filter((task) => task.status === status);"
)

# Ajouter le bouton près d'Ajouter une tâche.
old_header = '''        {canCreateTasks && <button className="btn-secondary text-sm" onClick={() => setShowForm((v) => !v)}>+ Ajouter une tâche</button>}'''
new_header = '''        <div className="flex items-center gap-2">
          {oldDoneTasks.length > 0 && (
            <button
              type="button"
              className="btn-ghost text-sm"
              onClick={() => setShowOldDone((value) => !value)}
            >
              {showOldDone
                ? 'Masquer les Done anciens'
                : `Afficher les Done anciens (${oldDoneTasks.length})`}
            </button>
          )}
          {canCreateTasks && (
            <button
              className="btn-secondary text-sm"
              onClick={() => setShowForm((value) => !value)}
            >
              + Ajouter une tâche
            </button>
          )}
        </div>'''
if 'Afficher les Done anciens' not in f:
    if old_header not in f:
        # Variante multiligne du composant généré précédemment.
        pattern = re.compile(
            r"\s*\{canCreateTasks && \(\s*<button[\s\S]*?\+ Ajouter une tâche\s*</button>\s*\)\}",
            re.MULTILINE
        )
        match = pattern.search(f)
        if not match:
            sys.exit('[ERREUR] Bouton Ajouter une tâche introuvable')
        f = f[:match.start()] + '\n' + new_header + f[match.end():]
    else:
        f = f.replace(old_header, new_header, 1)
    print('[OK] Bouton Afficher/Masquer ajouté')

TASKS.write_text(f, encoding='utf-8')

# 4. Type TypeScript : completed_at facultatif.
types_file = ROOT / 'src/pages/projects/types.ts'
if types_file.exists():
    types = types_file.read_text(encoding='utf-8')
    if 'completed_at?: string | null;' not in types:
        anchor = "  github_issue_url: string | null;"
        if anchor in types:
            types = types.replace(anchor, anchor + "\n  completed_at?: string | null;", 1)
        else:
            # Insertion dans Task avant la fermeture du type via origin.
            anchor = "  origin: 'manuelle' | 'demande_client';"
            if anchor in types:
                types = types.replace(anchor, anchor + "\n  completed_at?: string | null;", 1)
            else:
                sys.exit('[ERREUR] Type Task introuvable dans types.ts')
        types_file.write_text(types, encoding='utf-8')
        print('[OK] completed_at ajouté au type Task')

# 5. Appliquer la migration immédiatement.
try:
    subprocess.run(
        ['docker', 'exec', '-i', 'gestion_it_postgres', 'psql', '-U', 'gestion_it', '-d', 'gestion_it'],
        input=migration.read_text(encoding='utf-8'),
        text=True,
        check=True,
    )
    print('[OK] Migration PostgreSQL appliquée')
except Exception as error:
    print('[ATTENTION] Migration automatique impossible :', error)
    print('[À FAIRE] cat db/010_project_tasks_completed_at.sql | docker exec -i gestion_it_postgres psql -U gestion_it -d gestion_it')

print('\n[SUCCÈS] Les tâches Done depuis plus de 5 jours sont masquées par défaut.')
print('[INFO] Rebuild : docker compose build --no-cache && docker compose up -d')
