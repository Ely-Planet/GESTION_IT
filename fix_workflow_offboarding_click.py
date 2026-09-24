from pathlib import Path
from datetime import datetime
import shutil

f = Path("src/pages/Settings.tsx")

content = f.read_text(encoding="utf-8")

backup = f.with_name(
    f"{f.name}.bak-click-fix-{datetime.now().strftime('%Y%m%d_%H%M%S')}"
)

shutil.copy2(f, backup)

old = """if (card.key === 'workflow') {
    setSection('workflow');
  }"""

new = """if (card.key === 'workflow') {
    setSection('workflow');
  }

  if (card.key === 'workflow-offboarding') {
    setSection('workflow-offboarding');
  }"""

content = content.replace(old, new, 1)

f.write_text(content, encoding="utf-8")

print("OK - Workflow Offboarding clickable")
print("Sauvegarde :", backup)
