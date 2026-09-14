from pathlib import Path
from datetime import datetime
import shutil

f = Path("server/luccaOffboardingSync.mjs")

content = f.read_text(encoding="utf-8")

backup = f.with_name(
    f"{f.name}.bak-alizee-{datetime.now().strftime('%Y%m%d_%H%M%S')}"
)

shutil.copy2(f, backup)

content = content.replace(
"""const isOffboarding =
      lowerSubject.includes('offboarding') ||
      lowerSubject.includes("tâche à réaliser pour l'offboarding");""",
"""const isOffboarding =
      lowerSubject.includes('offboarding') ||
      lowerSubject.includes('restitution du matériel') ||
      lowerSubject.includes("tâche à réaliser pour l'offboarding");"""
)

old = """  return null;
}"""

new = """  match = cleanSubject.match(
    /restitution du matériel pour\\s+(.+)$/i
  );

  if (match) {
    return match[1].trim();
  }

  return null;
}"""

content = content.replace(old, new, 1)

f.write_text(content, encoding="utf-8")

print("Modification effectuée")
print("Sauvegarde :", backup)
