from pathlib import Path
from datetime import datetime
import shutil

f = Path("server/luccaOffboardingSync.mjs")

content = f.read_text(encoding="utf-8")

backup = f.with_name(
    f"{f.name}.bak-final-{datetime.now().strftime('%Y%m%d_%H%M%S')}"
)

shutil.copy2(f, backup)

old = """match = cleanSubject.match(
/(offboarding|restitution)\\s+(.+?)(?:\\s+-\\s+.*)?$/i
  );

  if (match) {
    return match[2].trim();
  }"""

new = """match = cleanSubject.match(
  /offboarding\\s+(.+?)(?:\\s+-\\s+.*)?$/i
);

if (match) {
  return match[1].trim();
}"""

content = content.replace(old, new)

f.write_text(content, encoding="utf-8")

print("OK")
print("Sauvegarde :", backup)
