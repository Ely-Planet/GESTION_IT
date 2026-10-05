from pathlib import Path
from datetime import datetime
import shutil, sys

root = Path.home() / 'www' / 'GESTION_IT'
server = root / 'server/projects.mjs'
if not server.exists():
    sys.exit(f'[ERREUR] Fichier absent: {server}')

backup = server.with_name('projects.mjs.backup_done_date_' + datetime.now().strftime('%Y%m%d_%H%M%S'))
shutil.copy2(server, backup)
s = server.read_text(encoding='utf-8')
changed = False

# Récupérer la date de dernière modification du champ Status dans GitHub Project V2.
old = '''... on ProjectV2ItemFieldSingleSelectValue {
                      name
                      field { ... on ProjectV2SingleSelectField { id name } }
                    }'''
new = '''... on ProjectV2ItemFieldSingleSelectValue {
                      name
                      updatedAt
                      field { ... on ProjectV2SingleSelectField { id name } }
                    }'''
if new not in s:
    if old not in s:
        sys.exit('[ERREUR] Fragment ProjectV2ItemFieldSingleSelectValue introuvable')
    s = s.replace(old, new, 1)
    changed = True
    print('[OK] Date GitHub du changement de statut récupérée')
else:
    print('[OK] Date GitHub déjà récupérée')

old_sql = '''const status = normalizeProjectV2Status(statusValue?.name);
      const result = await pool.query(
        `UPDATE project_tasks
         SET title = COALESCE($1, title),
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
         WHERE github_issue_url = $4`,
        [issue.title, issue.body || null, status, issue.url]
      );'''
new_sql = '''const status = normalizeProjectV2Status(statusValue?.name);
      const githubStatusUpdatedAt = statusValue?.updatedAt || null;
      const result = await pool.query(
        `UPDATE project_tasks
         SET title = COALESCE($1, title),
             description = $2,
             completed_at = CASE
               WHEN $3 = 'done' THEN COALESCE($5::timestamptz, completed_at, now())
               ELSE NULL
             END,
             status = $3,
             updated_at = CASE
               WHEN title IS DISTINCT FROM $1
                 OR description IS DISTINCT FROM $2
                 OR status IS DISTINCT FROM $3
               THEN now()
               ELSE updated_at
             END
         WHERE github_issue_url = $4`,
        [issue.title, issue.body || null, status, issue.url, githubStatusUpdatedAt]
      );'''
if new_sql not in s:
    if old_sql not in s:
        sys.exit('[ERREUR] Bloc SQL ProjectV2 attendu introuvable')
    s = s.replace(old_sql, new_sql, 1)
    changed = True
    print('[OK] completed_at utilise maintenant la date réelle GitHub')
else:
    print('[OK] completed_at utilise déjà la date GitHub')

if changed:
    server.write_text(s, encoding='utf-8')

print('[SUCCES] Correctif des Done anciens appliqué')
print('[OK] Sauvegarde:', backup)
print('[INFO] Rebuild: docker compose build --no-cache && docker compose up -d')
