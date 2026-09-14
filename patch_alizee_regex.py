from pathlib import Path
from datetime import datetime
import shutil
import re

f = Path("server/luccaOffboardingSync.mjs")

content = f.read_text(encoding="utf-8")

backup = f.with_name(
    f"{f.name}.bak-regex-{datetime.now().strftime('%Y%m%d_%H%M%S')}"
)

shutil.copy2(f, backup)

pattern = re.compile(
    r"function parseOffboardingName\(subject\)\s*\{.*?return null;\s*\}",
    re.S
)

replacement = r"""function parseOffboardingName(subject) {
  const cleanSubject = String(subject || '')
    .replace(/^((tr|re|fw|fwd)\s*:)+/i, '')
    .trim();

  let match = cleanSubject.match(
    /offboarding\s+de\s+(.+)$/i
  );

  if (match) {
    return match[1]
      .replace(/\s+-\s+.*$/, '')
      .trim();
  }

  match = cleanSubject.match(
    /offboarding\s+(.+?)(?:\s+-\s+.*)?$/i
  );

  if (match) {
    return match[1].trim();
  }

  match = cleanSubject.match(
    /restitution du matériel pour\s+(.+)$/i
  );

  if (match) {
    return match[1].trim();
  }

  return null;
}"""

content = pattern.sub(replacement, content, count=1)

f.write_text(content, encoding="utf-8")

print("OK - Fonction remplacée")
print("Sauvegarde :", backup)
