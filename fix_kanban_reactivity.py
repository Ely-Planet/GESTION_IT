from pathlib import Path
from datetime import datetime
import re
import shutil
import sys

ROOT = Path.home() / 'www' / 'GESTION_IT'
TASKS = ROOT / 'src/pages/projects/tabs/TasksTab.tsx'
SERVER = ROOT / 'server/projects.mjs'
STAMP = datetime.now().strftime('%Y%m%d_%H%M%S')

for path in (TASKS, SERVER):
    if not path.exists():
        sys.exit(f'[ERREUR] Fichier absent : {path}')

backup = ROOT / f'backup_kanban_reactivity_{STAMP}'
for path in (TASKS, SERVER):
    destination = backup / path.relative_to(ROOT)
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(path, destination)
print('[OK] Sauvegarde :', backup)

# ------------------------------------------------------------------
# FRONTEND : mise a jour optimiste, sans attendre GitHub ni le parent
# ------------------------------------------------------------------
text = TASKS.read_text(encoding='utf-8')

text = text.replace(
    "import { useState } from 'react';",
    "import { useEffect, useState } from 'react';",
    1,
)

old_tasks = "  const tasks = project.tasks || [];"
new_tasks = """  const [localTasks, setLocalTasks] = useState<Task[]>(project.tasks || []);
  const tasks = localTasks;

  useEffect(() => {
    setLocalTasks(project.tasks || []);
  }, [project.tasks]);"""
if 'const [localTasks, setLocalTasks]' not in text:
    if old_tasks not in text:
        sys.exit('[ERREUR] Declaration tasks introuvable dans TasksTab.tsx')
    text = text.replace(old_tasks, new_tasks, 1)
    print('[OK] Etat local optimiste ajoute')

# Remplacer la fonction updateStatus quelle que soit sa mise en forme actuelle.
pattern = re.compile(
    r"  async function updateStatus\(taskId: string, status: TaskStatus\) \{[\s\S]*?\n  \}\n\n  async function updateSpentHours",
    re.MULTILINE,
)
replacement = """  async function updateStatus(taskId: string, status: TaskStatus) {
    const previousTasks = localTasks;

    setLocalTasks((current) =>
      current.map((task) =>
        task.id === taskId ? { ...task, status } : task
      )
    );
    setUpdatingTaskId(taskId);

    try {
      await projectsApi.updateTask(taskId, { status });
    } catch (err: any) {
      setLocalTasks(previousTasks);
      alert(err.message || 'Erreur lors du changement de statut');
    } finally {
      setUpdatingTaskId(null);
    }
  }

  async function updateSpentHours"""
if not pattern.search(text):
    sys.exit('[ERREUR] Fonction updateStatus introuvable')
text = pattern.sub(replacement, text, count=1)
print('[OK] Mise a jour visuelle immediate ajoutee')

# Drop robuste : l'identifiant vient de dataTransfer, jamais d'un state React en retard.
pattern_drop = re.compile(
    r"  async function dropTask\(status: TaskStatus(?:, taskId: string)?\) \{[\s\S]*?\n  \}\n\n  function TaskCard",
    re.MULTILINE,
)
replacement_drop = """  async function dropTask(status: TaskStatus, taskId: string) {
    const task = localTasks.find((item) => item.id === taskId);

    if (!task || task.status === status) {
      setDraggedTaskId(null);
      setDragOverStatus(null);
      return;
    }

    setDraggedTaskId(null);
    setDragOverStatus(null);
    await updateStatus(task.id, status);
  }

  function TaskCard"""
if not pattern_drop.search(text):
    sys.exit('[ERREUR] Fonction dropTask introuvable')
text = pattern_drop.sub(replacement_drop, text, count=1)
print('[OK] dropTask fiabilise')

# Autoriser le nettoyage lors d'un drag annule.
text = re.sub(
    r"onDragEnd=\{\(\) => \{[\s\S]*?\}\}",
    """onDragEnd={() => {
          setDraggedTaskId(null);
          setDragOverStatus(null);
        }}""",
    text,
    count=1,
)

# Remplacer onDrop par une version utilisant dataTransfer.
pattern_on_drop = re.compile(
    r"onDrop=\{\(e\) => \{[\s\S]*?\}\}",
    re.MULTILINE,
)
new_on_drop = """onDrop={(e) => {
                e.preventDefault();
                const taskId = e.dataTransfer.getData('text/plain');
                if (taskId) void dropTask(status, taskId);
              }}"""
if not pattern_on_drop.search(text):
    sys.exit('[ERREUR] Gestionnaire onDrop introuvable')
text = pattern_on_drop.sub(new_on_drop, text, count=1)

TASKS.write_text(text, encoding='utf-8')

# ------------------------------------------------------------------
# BACKEND : repondre tout de suite, synchroniser GitHub en arriere-plan
# ------------------------------------------------------------------
server = SERVER.read_text(encoding='utf-8')

# Intervalle GitHub : 1 minute au lieu de 5.
old_interval = "}, 5 * 60 * 1000);"
new_interval = "}, 60 * 1000);"
if old_interval in server:
    server = server.replace(old_interval, new_interval, 1)
    print('[OK] Synchronisation GitHub reglee sur 1 minute')
elif new_interval in server:
    print('[OK] Synchronisation GitHub deja sur 1 minute')
else:
    print('[ATTENTION] Intervalle GitHub non trouve, aucune modification de frequence')

# Ne plus bloquer la reponse HTTP pendant les appels GitHub.
old_sync = """      try {
        await syncGitHubIssueState(updatedTask, status);
        if (status) await updateGitHubProjectV2Status(updatedTask, status);
      } catch (githubError) {
        console.error('[Projets IT] Synchronisation statut GitHub impossible', githubError.message || githubError);
        updatedTask.github_sync_error = githubError.message || String(githubError);
      }
      res.json(updatedTask);"""
new_sync = """      res.json(updatedTask);

      if (status) {
        Promise.allSettled([
          syncGitHubIssueState(updatedTask, status),
          updateGitHubProjectV2Status(updatedTask, status),
        ]).then((results) => {
          for (const result of results) {
            if (result.status === 'rejected') {
              console.error(
                '[Projets IT] Synchronisation statut GitHub impossible',
                result.reason?.message || result.reason
              );
            }
          }
        });
      }"""
if old_sync in server:
    server = server.replace(old_sync, new_sync, 1)
    print('[OK] Reponse API immediate, synchro GitHub non bloquante')
elif 'Promise.allSettled([' in server and 'updateGitHubProjectV2Status(updatedTask, status)' in server:
    print('[OK] Synchronisation GitHub deja non bloquante')
else:
    print('[ATTENTION] Bloc synchro apres update non reconnu; seule la frequence a ete modifiee')

SERVER.write_text(server, encoding='utf-8')

print('\n[SUCCES] Correctif fluidite Kanban applique')
print('[INFO] Rebuild : docker compose build --no-cache && docker compose up -d')
