from pathlib import Path
from datetime import datetime
import re
import shutil
import subprocess
import sys

ROOT = Path.home() / 'www' / 'GESTION_IT'
SERVER = ROOT / 'server/projects.mjs'
TYPES = ROOT / 'src/pages/projects/types.ts'
TASKS = ROOT / 'src/pages/projects/tabs/TasksTab.tsx'
DB_DIR = ROOT / 'db'
STAMP = datetime.now().strftime('%Y%m%d_%H%M%S')

for path in (SERVER, TYPES, TASKS):
    if not path.exists():
        sys.exit(f'[ERREUR] Fichier absent : {path}')

backup_dir = ROOT / f'backup_github_projectv2_{STAMP}'
backup_dir.mkdir(parents=True, exist_ok=True)
for path in (SERVER, TYPES, TASKS):
    dest = backup_dir / path.relative_to(ROOT)
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, dest)
print('[OK] Sauvegarde :', backup_dir)

# -----------------------------------------------------------------------------
# 1. Migration PostgreSQL : workflow GitHub Projects v2
# -----------------------------------------------------------------------------
DB_DIR.mkdir(exist_ok=True)
migration = DB_DIR / '009_github_projectv2_statuses.sql'
migration.write_text('''BEGIN;

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
''', encoding='utf-8')
print('[OK] Migration créée :', migration)

# -----------------------------------------------------------------------------
# 2. Backend : GraphQL ProjectV2 + synchronisation bidirectionnelle
# -----------------------------------------------------------------------------
s = SERVER.read_text(encoding='utf-8')

projectv2_helpers = r'''
// === GITHUB PROJECTS V2 : STATUTS KANBAN ===
const PROJECT_V2_STATUS_SLUGS = {
  'backlog': 'backlog',
  'ready': 'ready',
  'in progress': 'in_progress',
  'in_progress': 'in_progress',
  'in review': 'in_review',
  'in_review': 'in_review',
  'done': 'done'
};

function normalizeProjectV2Status(value) {
  return PROJECT_V2_STATUS_SLUGS[String(value || '').trim().toLowerCase()] || 'backlog';
}

function projectV2StatusLabel(slug) {
  return {
    backlog: 'Backlog',
    ready: 'Ready',
    in_progress: 'In progress',
    in_review: 'In review',
    done: 'Done'
  }[slug] || 'Backlog';
}

async function githubGraphQL(query, variables = {}) {
  const token = process.env.GITHUB_TOKEN;
  if (!token) throw new Error('GITHUB_TOKEN absent');
  const response = await fetch('https://api.github.com/graphql', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'User-Agent': 'ELYade-GESTION-IT'
    },
    body: JSON.stringify({ query, variables })
  });
  const payload = await response.json();
  if (!response.ok || payload.errors) {
    throw new Error(`GitHub GraphQL: ${JSON.stringify(payload.errors || payload)}`);
  }
  return payload.data;
}

async function loadGitHubProjectV2Data() {
  const data = await githubGraphQL(`
    query GestionItProjects($login: String!) {
      user(login: $login) {
        projectsV2(first: 50) {
          nodes {
            id
            title
            fields(first: 50) {
              nodes {
                ... on ProjectV2SingleSelectField {
                  id
                  name
                  options { id name }
                }
              }
            }
            items(first: 100) {
              nodes {
                id
                fieldValues(first: 30) {
                  nodes {
                    ... on ProjectV2ItemFieldSingleSelectValue {
                      name
                      field { ... on ProjectV2SingleSelectField { id name } }
                    }
                  }
                }
                content {
                  ... on Issue {
                    id
                    url
                    title
                    body
                    state
                    repository { nameWithOwner }
                  }
                }
              }
            }
          }
        }
      }
    }
  `, { login: process.env.GITHUB_PROJECT_OWNER || 'Ely-Planet' });
  return data.user?.projectsV2?.nodes || [];
}

function findProjectV2Status(projectNode, issueUrl) {
  const item = (projectNode.items?.nodes || []).find((node) => node.content?.url === issueUrl);
  if (!item) return null;
  const statusValue = (item.fieldValues?.nodes || []).find((value) => value.field?.name === 'Status');
  return { item, status: normalizeProjectV2Status(statusValue?.name) };
}

async function syncGitHubProjectV2ToGestionIt() {
  const projectsV2 = await loadGitHubProjectV2Data();
  let updated = 0;
  for (const projectNode of projectsV2) {
    for (const item of projectNode.items?.nodes || []) {
      const issue = item.content;
      if (!issue?.url) continue;
      const statusValue = (item.fieldValues?.nodes || []).find((value) => value.field?.name === 'Status');
      const status = normalizeProjectV2Status(statusValue?.name);
      const result = await pool.query(
        `UPDATE project_tasks
         SET title = COALESCE($1, title), description = $2, status = $3, updated_at = now()
         WHERE github_issue_url = $4`,
        [issue.title, issue.body || null, status, issue.url]
      );
      updated += result.rowCount;
    }
  }
  console.log('[GitHub ProjectV2 Sync]', { projects: projectsV2.length, tasksUpdated: updated });
  return { projects: projectsV2.length, tasksUpdated: updated };
}

async function updateGitHubProjectV2Status(task, status) {
  if (!task.github_issue_url) return;
  const projectsV2 = await loadGitHubProjectV2Data();
  for (const projectNode of projectsV2) {
    const found = findProjectV2Status(projectNode, task.github_issue_url);
    if (!found) continue;
    const statusField = (projectNode.fields?.nodes || []).find((field) => field?.name === 'Status');
    const option = (statusField?.options || []).find(
      (entry) => normalizeProjectV2Status(entry.name) === status
    );
    if (!statusField || !option) {
      throw new Error(`Statut GitHub ProjectV2 introuvable : ${projectV2StatusLabel(status)}`);
    }
    await githubGraphQL(`
      mutation UpdateGestionItStatus(
        $projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!
      ) {
        updateProjectV2ItemFieldValue(input: {
          projectId: $projectId,
          itemId: $itemId,
          fieldId: $fieldId,
          value: { singleSelectOptionId: $optionId }
        }) { projectV2Item { id } }
      }
    `, {
      projectId: projectNode.id,
      itemId: found.item.id,
      fieldId: statusField.id,
      optionId: option.id
    });
    return;
  }
}
'''

if 'async function loadGitHubProjectV2Data' not in s:
    marker = 'export function registerProjectRoutes(app) {'
    if marker not in s:
        sys.exit('[ERREUR] Marqueur registerProjectRoutes introuvable')
    s = s.replace(marker, projectv2_helpers + '\n' + marker, 1)
    print('[OK] Fonctions GitHub Projects v2 ajoutées')
else:
    print('[OK] Fonctions GitHub Projects v2 déjà présentes')

# Le statut natif de l'issue reste cohérent : Done ferme, les autres rouvrent.
s = s.replace("status === 'closed' ? 'closed' : 'open'", "status === 'done' ? 'closed' : 'open'")
s = s.replace("status === 'termine' ? 'closed' : 'open'", "status === 'done' ? 'closed' : 'open'")
s = s.replace("t.status === 'closed'", "t.status === 'done'")

# Ajouter la mutation ProjectV2 après la synchro open/closed existante.
needle = 'await syncGitHubIssueState(updatedTask, status);'
replacement = '''await syncGitHubIssueState(updatedTask, status);
        if (status) await updateGitHubProjectV2Status(updatedTask, status);'''
if replacement not in s:
    if needle not in s:
        sys.exit('[ERREUR] Appel syncGitHubIssueState introuvable')
    s = s.replace(needle, replacement, 1)
    print('[OK] Mise à jour GESTION_IT vers ProjectV2 ajoutée')

# Utiliser le statut ProjectV2 pendant la synchronisation périodique.
route_marker = "  app.post('/api/projects/github/sync', requireAuth, requireRole('manager'), async (req, res) => {"
if route_marker in s and 'syncGitHubProjectV2ToGestionIt()' not in s[s.find(route_marker):s.find(route_marker)+500]:
    old = 'res.json(await syncGitHubRepositoriesAndIssues());'
    new = '''const repositories = await syncGitHubRepositoriesAndIssues();
      const projectsV2 = await syncGitHubProjectV2ToGestionIt();
      res.json({ repositories, projectsV2 });'''
    if old in s:
        s = s.replace(old, new, 1)

# Après chaque synchronisation REST périodique, appliquer ProjectV2.
periodic = 'syncGitHubRepositoriesAndIssues().catch((error) =>'
if periodic in s:
    s = s.replace(
        'syncGitHubRepositoriesAndIssues().catch((error) =>',
        'syncGitHubRepositoriesAndIssues().then(() => syncGitHubProjectV2ToGestionIt()).catch((error) =>'
    )

SERVER.write_text(s, encoding='utf-8')

# -----------------------------------------------------------------------------
# 3. Types React et libellés
# -----------------------------------------------------------------------------
t = TYPES.read_text(encoding='utf-8')
t = re.sub(
    r"status:\s*'open'\s*\|\s*'closed';",
    "status: 'backlog' | 'ready' | 'in_progress' | 'in_review' | 'done';",
    t
)
for key, label in [
    ('backlog', 'Backlog'), ('ready', 'Ready'), ('in_progress', 'In progress'),
    ('in_review', 'In review'), ('done', 'Done')
]:
    if re.search(rf"\b{re.escape(key)}\s*:", t) is None:
        t = t.replace(
            'export const STATUS_LABELS: Record<string, string> = {',
            f"export const STATUS_LABELS: Record<string, string> = {{\n  {key}: '{label}',",
            1
        )

badge_entries = """  backlog: 'bg-slate-100 text-slate-700',
  ready: 'bg-blue-100 text-blue-700',
  in_progress: 'bg-amber-100 text-amber-700',
  in_review: 'bg-purple-100 text-purple-700',
  done: 'bg-orange-100 text-orange-700',
"""
if 'in_progress:' not in t[t.find('STATUS_BADGE_CLASSES'):]:
    t = t.replace(
        'export const STATUS_BADGE_CLASSES: Record<string, string> = {',
        'export const STATUS_BADGE_CLASSES: Record<string, string> = {\n' + badge_entries,
        1
    )
TYPES.write_text(t, encoding='utf-8')
print('[OK] Types et badges Kanban mis à jour')

# -----------------------------------------------------------------------------
# 4. Frontend TasksTab : cinq colonnes GitHub ProjectV2
# -----------------------------------------------------------------------------
f = TASKS.read_text(encoding='utf-8')
f = f.replace(
    "const STATUSES = ['open', 'closed'] as const;",
    "const STATUSES = ['backlog', 'ready', 'in_progress', 'in_review', 'done'] as const;"
)

# Remplacer les options du sélecteur.
f = re.sub(
    r'<option value="open">Ouverte</option>\s*<option value="closed">Fermée</option>',
    '''<option value="backlog">Backlog</option>
            <option value="ready">Ready</option>
            <option value="in_progress">In progress</option>
            <option value="in_review">In review</option>
            <option value="done">Done</option>''',
    f
)

# Remplacer la configuration visuelle des colonnes dans le composant complet généré.
f = f.replace("const open = status === 'open';", "const columnConfig = {\n            backlog: { title: 'BACKLOG', subtitle: 'Non démarré', style: 'border-emerald-200 bg-emerald-50/50' },\n            ready: { title: 'READY', subtitle: 'Prêt à démarrer', style: 'border-blue-200 bg-blue-50/50' },\n            in_progress: { title: 'IN PROGRESS', subtitle: 'En cours', style: 'border-amber-200 bg-amber-50/50' },\n            in_review: { title: 'IN REVIEW', subtitle: 'En revue', style: 'border-purple-200 bg-purple-50/50' },\n            done: { title: 'DONE', subtitle: 'Terminé', style: 'border-orange-200 bg-orange-50/50' },\n          }[status];")
f = f.replace(
    "${open ? 'border-emerald-200 bg-emerald-50/50' : 'border-purple-200 bg-purple-50/50'}",
    "${columnConfig.style}"
)
f = f.replace("{open ? 'OPEN' : 'CLOSED'}", "{columnConfig.title}")
f = f.replace("{open ? 'Issues ouvertes' : 'Issues fermées'}", "{columnConfig.subtitle}")
f = f.replace('lg:grid-cols-2', 'lg:grid-cols-5')
TASKS.write_text(f, encoding='utf-8')
print('[OK] TasksTab converti en Kanban 5 colonnes')

# -----------------------------------------------------------------------------
# 5. Appliquer la migration par le conteneur PostgreSQL
# -----------------------------------------------------------------------------
try:
    subprocess.run(
        ['docker', 'exec', '-i', 'gestion_it_postgres', 'psql', '-U', 'gestion_it', '-d', 'gestion_it'],
        input=migration.read_text(encoding='utf-8'),
        text=True,
        check=True
    )
    print('[OK] Migration PostgreSQL appliquée')
except Exception as error:
    print('[ATTENTION] Migration non appliquée automatiquement :', error)
    print('[INFO] À lancer manuellement :')
    print("cat db/009_github_projectv2_statuses.sql | docker exec -i gestion_it_postgres psql -U gestion_it -d gestion_it")

print('\n[SUCCÈS] GitHub Projects v2 intégré à GESTION_IT')
print('[IMPORTANT] Le token GitHub doit disposer du droit Projects: Read and write.')
print('[INFO] Définissez éventuellement GITHUB_PROJECT_OWNER=Ely-Planet dans .env.')
print('[INFO] Rebuild : docker compose build --no-cache && docker compose up -d')
