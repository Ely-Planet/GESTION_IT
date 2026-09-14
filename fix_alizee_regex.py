from pathlib import Path
from datetime import datetime
import shutil

f = Path("server/luccaOffboardingSync.mjs")

content = f.read_text(encoding="utf-8")

backup = f.with_name(
    f"{f.name}.bak-fix-alizee-{datetime.now().strftime('%Y%m%d_%H%M%S')}"
)

shutil.copy2(f, backup)

content = content.replace(
    "/(offboarding|Restitution)\\s+de\\s+(.+)$/i",
    "/offboarding\\s+de\\s+(.+)$/i"
)

content = content.replace(
    "/(offboarding|Restitution)\\s+(.+?)(?:\\s+-\\s+.*)?$/i",
    "/offboarding\\s+(.+?)(?:\\s+-\\s+.*)?$/i"
)

f.write_text(content, encoding="utf-8")

print('OK')
print('Sauvegarde :', backup)
