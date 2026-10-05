from pathlib import Path
import re
from datetime import datetime
import shutil

file = Path("src/pages/projects/tabs/TasksTab.tsx")

backup = file.with_name(
    f"TasksTab.tsx.ui_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
)
shutil.copy2(file, backup)

content = file.read_text(encoding="utf-8")

# 1. Kanban scrollable horizontalement
content = content.replace(
    'className="grid grid-cols-1 lg:grid-cols-5',
    'className="flex gap-4 overflow-x-auto pb-4'
)

# 2. Colonnes largeur fixe GitHub-like
content = content.replace(
    'rounded-xl border p-3 min-h-[360px]',
    'rounded-xl border p-3 min-h-[360px] min-w-[320px] w-[320px] flex-shrink-0'
)

# 3. Zone DONE plus compacte
content = content.replace(
    'columnTasks.length === 0 && <div className="border-2 border-dashed',
    'columnTasks.length === 0 && <div className="border-2 border-dashed'
)

# 4. Carte plus compacte
content = content.replace(
    'className={`card p-4 transition-all',
    'className={`card p-3 transition-all'
)

# 5. Supprimer le texte GitHub qui déborde
content = content.replace(
    'Voir sur GitHub',
    'GitHub'
)

# 6. Ajouter bouton suppression
marker = """
<StatusBadge status={task.status} />
"""

if marker in content:
    content = content.replace(
        marker,
        marker + """
          <button
            onClick={async () => {
              if (!confirm('Supprimer cette tâche ?')) return;

              await fetch(`/api/projects/tasks/${task.id}`, {
                method: 'DELETE',
                credentials: 'include'
              });

              window.location.reload();
            }}
            className="text-red-500 hover:text-red-700 text-sm ml-2"
            title="Supprimer"
          >
            🗑
          </button>
"""
    )

file.write_text(content, encoding="utf-8")

print("✅ Patch Kanban UI appliqué")
print("✅ Backup :", backup)
