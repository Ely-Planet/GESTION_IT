from pathlib import Path
from datetime import datetime
import re
import shutil
import sys

root = Path.home() / 'www' / 'GESTION_IT'
path = root / 'src/pages/projects/tabs/TasksTab.tsx'
if not path.exists():
    sys.exit(f'[ERREUR] Fichier absent : {path}')

backup = path.with_name('TasksTab.tsx.drag_handle_' + datetime.now().strftime('%Y%m%d_%H%M%S') + '.bak')
shutil.copy2(path, backup)
text = path.read_text(encoding='utf-8')

# Ajouter l'icone de poignee.
if "from 'lucide-react'" not in text:
    text = text.replace(
        "import { useEffect, useState } from 'react';",
        "import { useEffect, useState } from 'react';\nimport { GripVertical } from 'lucide-react';",
        1,
    )
elif 'GripVertical' not in text:
    text = re.sub(
        r"import \{([^}]*)\} from 'lucide-react';",
        lambda m: "import {" + m.group(1).rstrip() + ", GripVertical } from 'lucide-react';",
        text,
        count=1,
    )

# Retirer le draggable de toute la carte. Les champs input/select/lien perturbent le drag natif.
article_pattern = re.compile(
    r'''      <article\n\s*draggable=\{!updating\}\n\s*onDragStart=\{\(e\) => \{[\s\S]*?\n\s*\}\}\n\s*onDragEnd=\{\(\) => \{[\s\S]*?\n\s*\}\}\n\s*className=''',
    re.MULTILINE,
)
if article_pattern.search(text):
    text = article_pattern.sub("      <article\n        className=", text, count=1)
else:
    # Variante avec event au lieu de e.
    article_pattern = re.compile(
        r'''      <article\n\s*draggable=\{!updating\}\n\s*onDragStart=\{\(event\) => \{[\s\S]*?\n\s*\}\}\n\s*onDragEnd=\{\(\) => \{[\s\S]*?\n\s*\}\}\n\s*className=''',
        re.MULTILINE,
    )
    if not article_pattern.search(text):
        sys.exit('[ERREUR] Bloc draggable de la carte introuvable')
    text = article_pattern.sub("      <article\n        className=", text, count=1)

# Enlever les curseurs de drag portes par toute la carte.
text = text.replace("cursor-grab active:cursor-grabbing ", "")

# Ajouter une poignee draggable explicite avant le titre.
header = '''        <div className="flex items-start justify-between gap-2">
          <p className="font-medium text-ink-900">{task.title}</p>'''
new_header = '''        <div className="flex items-start justify-between gap-2">
          <div className="flex items-start gap-2 min-w-0">
            <button
              type="button"
              draggable={!updating}
              aria-label="Déplacer la tâche"
              title="Glisser pour déplacer"
              className="mt-0.5 shrink-0 cursor-grab active:cursor-grabbing text-ink-400 hover:text-ink-700 touch-none"
              onDragStart={(event) => {
                event.stopPropagation();
                setDraggedTaskId(task.id);
                event.dataTransfer.effectAllowed = 'move';
                event.dataTransfer.setData('text/plain', task.id);
              }}
              onDragEnd={() => {
                setDraggedTaskId(null);
                setDragOverStatus(null);
              }}
            >
              <GripVertical className="w-4 h-4" />
            </button>
            <p className="font-medium text-ink-900 break-words">{task.title}</p>
          </div>'''
if header not in text:
    # Variante leading-snug.
    header = '''        <div className="flex items-start justify-between gap-2">
          <p className="font-medium text-ink-900 leading-snug">{task.title}</p>'''
if header not in text:
    sys.exit('[ERREUR] En-tête de carte introuvable')
text = text.replace(header, new_header, 1)

path.write_text(text, encoding='utf-8')
print('[OK] Poignée de déplacement ajoutée')
print('[OK] La carte entière ne capture plus les clics de drag')
print('[OK] Sauvegarde :', backup)
print('[INFO] Utiliser l’icône à gauche du titre pour déplacer une tâche')
