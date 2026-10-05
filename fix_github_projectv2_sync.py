from pathlib import Path
from datetime import datetime
import shutil
import sys

path = Path("server/projects.mjs")

if not path.exists():
    sys.exit(f"[ERREUR] Fichier absent : {path}")

backup = Path("/tmp") / (
    "projects.mjs.sync_fix_"
    + datetime.now().strftime("%Y%m%d_%H%M%S")
    + ".bak"
)
shutil.copy2(path, backup)

text = path.read_text(encoding="utf-8")

old = """      const status = issue.state === 'closed' ? 'closed' : 'open';
      const existing = await pool.query(
        `SELECT id FROM project_tasks WHERE github_issue_url = $1 LIMIT 1`,
        [issue.html_url]
      );
      if (existing.rowCount === 0) {
        await pool.query(
          `INSERT INTO project_tasks
           (project_id, title, description, status, origin, github_issue_url, updated_at)
           VALUES ($1, $2, $3, $4, 'manuelle', $5, now())`,
          [project.id, issue.title, issue.body || null, status, issue.html_url]
        );
        tasksCreated += 1;
      } else {
        await pool.query(
          `UPDATE project_tasks
           SET project_id = $1, title = $2, description = $3,
               status = $4, updated_at = now()
           WHERE id = $5`,
          [project.id, issue.title, issue.body || null, status, existing.rows[0].id]
        );
        tasksUpdated += 1;
      }"""

new = """      const existing = await pool.query(
        `SELECT id FROM project_tasks WHERE github_issue_url = $1 LIMIT 1`,
        [issue.html_url]
      );

      if (existing.rowCount === 0) {
        await pool.query(
          `INSERT INTO project_tasks
           (project_id, title, description, status, origin, github_issue_url, updated_at)
           VALUES ($1, $2, $3, 'backlog', 'manuelle', $4, now())`,
          [project.id, issue.title, issue.body || null, issue.html_url]
        );
        tasksCreated += 1;
      } else {
        await pool.query(
          `UPDATE project_tasks
           SET project_id = $1,
               title = $2,
               description = $3,
               updated_at = CASE
                 WHEN title IS DISTINCT FROM $2
                   OR description IS DISTINCT FROM $3
                   OR project_id IS DISTINCT FROM $1
                 THEN now()
                 ELSE updated_at
               END
           WHERE id = $4`,
          [project.id, issue.title, issue.body || null, existing.rows[0].id]
        );
        tasksUpdated += 1;
      }"""

if new in text:
    print("[OK] Correction REST déjà présente")
elif old in text:
    text = text.replace(old, new, 1)
    print("[OK] La synchro REST ne modifie plus le statut Kanban")
else:
    sys.exit(
        "[ERREUR] Bloc REST attendu introuvable. "
        "Aucune modification appliquée."
    )

path.write_text(text, encoding="utf-8")

print("[OK] Les statuts sont maintenant pilotés uniquement par Project v2")
print("[OK] Sauvegarde :", backup)
