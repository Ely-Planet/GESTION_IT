from pathlib import Path
from datetime import datetime
import shutil
import sys

root = Path.home() / 'www' / 'GESTION_IT'
files = [
    root / 'src/pages/projects/ProjectsList.tsx',
    root / 'src/pages/projects/ProjectDetail.tsx',
]
stamp = datetime.now().strftime('%Y%m%d_%H%M%S')

for path in files:
    if not path.exists():
        sys.exit(f'[ERREUR] Fichier absent : {path}')
    shutil.copy2(path, path.with_name(path.name + '.single_status_' + stamp + '.bak'))

# Liste : retirer l'ancien badge p.status, conserver Nouveau/En cours/Maintenance/Cloture.
path = files[0]
text = path.read_text(encoding='utf-8')
text = text.replace(
    "import { ProgressBar, StatusBadge } from './ProjectUI';",
    "import { ProgressBar } from './ProjectUI';"
)
old = '''                  <StatusBadge status={p.status} />'''
if old not in text:
    sys.exit('[ERREUR] Ancien badge de la liste introuvable')
text = text.replace(old, '', 1)
path.write_text(text, encoding='utf-8')
print('[OK] Ancien statut retiré de la liste')

# Detail : retirer l'ancien badge project.status, conserver le statut automatique et les actions.
path = files[1]
text = path.read_text(encoding='utf-8')
text = text.replace(
    "import { ProgressBar, StatusBadge } from './ProjectUI';",
    "import { ProgressBar } from './ProjectUI';"
)
old = '''            <StatusBadge status={project.status} />'''
if old not in text:
    sys.exit('[ERREUR] Ancien badge du détail introuvable')
text = text.replace(old, '', 1)
path.write_text(text, encoding='utf-8')
print('[OK] Ancien statut retiré du détail')

print('[SUCCES] Un seul statut projet est maintenant affiché')
