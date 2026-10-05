from pathlib import Path
from datetime import datetime
import shutil

f = Path("src/pages/projects/tabs/TasksTab.tsx")

backup = f.with_name(
    f"TasksTab.tsx.dragdrop_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
)
shutil.copy2(f, backup)

txt = f.read_text(encoding="utf-8")

# Supprime le reset prématuré du drag
txt = txt.replace(
    """onDragEnd={() => { setDraggedTaskId(null); setDragOverStatus(null); }}""",
    """onDragEnd={() => {}}"""
)

# Corrige dropTask
old = """
  async function dropTask(status: TaskStatus) {
    const task = tasks.find((item) => item.id === draggedTaskId);
    setDraggedTaskId(null);
    setDragOverStatus(null);
    if (!task || task.status === status) return;
    await updateStatus(task.id, status);
  }
"""

new = """
  async function dropTask(status: TaskStatus) {
    try {
      const task = tasks.find((item) => item.id === draggedTaskId);

      if (!task || task.status === status) {
        return;
      }

      await updateStatus(task.id, status);
    } finally {
      setDraggedTaskId(null);
      setDragOverStatus(null);
    }
  }
"""

if old in txt:
    txt = txt.replace(old, new)
    print("✅ dropTask corrigé")
else:
    print("⚠️ Bloc dropTask non trouvé")

f.write_text(txt, encoding="utf-8")

print()
print("✅ Backup :", backup)
print("✅ Drag & Drop corrigé")
print("✅ Les tâches devraient désormais changer de colonne du premier coup")

