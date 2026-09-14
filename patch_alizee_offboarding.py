from pathlib import Path
from datetime import datetime
import shutil
import sys

f = Path("server/luccaOffboardingSync.mjs")

if not f.exists():
    print("Fichier introuvable")
    sys.exit(1)

content = f.read_text(encoding="utf-8")

backup = f.with_name(
    f"{f.name}.bak-alizee-{datetime.now().strftime('%Y%m%d_%H%M%S')}"
)

shutil.copy2(f, backup)

old1 = """const isOffboarding =
      lowerSubject.includes('offboarding') ||
      lowerSubject.includes("tâche à réaliser pour l'offboarding");"""

new1 = """const isOffboarding =
      lowerSubject.includes('offboarding') ||
      lowerSubject.includes("tâche à réaliser pour l'offboarding") ||
      lowerSubject.includes('restitution du matériel');"""

if old1 in content:
    content = content.replace(old1, new1)

old2 = """  return null;
}"""

new2 = """  match = cleanSubject.match(
    /restitution du matériel pour\\s+(.+)$/i
  );

  if (match) {
    return match[1].trim();
  }

  return null;
}"""

if old2 in content:
    content = content.replace(old2, new2, 1)

f.write_text(content, encoding="utf-8")

print("Modification effectuée")
print("Sauvegarde :", backup)
