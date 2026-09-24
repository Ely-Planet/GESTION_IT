from pathlib import Path
from datetime import datetime
import shutil
import subprocess
import re
import sys

ROOT = Path.cwd()
SERVER = ROOT / "server/index.mjs"
SETTINGS = ROOT / "src/pages/Settings.tsx"

for file_path in (SERVER, SETTINGS):
    if not file_path.exists():
        print(f"ERREUR : fichier introuvable : {file_path}")
        sys.exit(1)

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

for file_path in (SERVER, SETTINGS):
    backup = file_path.with_name(
        f"{file_path.name}.bak-workflow-offboarding-{timestamp}"
    )
    shutil.copy2(file_path, backup)
    print(f"Sauvegarde : {backup}")

# ============================================================
# 1. AJOUT DES ROUTES BACKEND
# ============================================================

server_content = SERVER.read_text(encoding="utf-8")

if "/api/offboarding-action-templates" not in server_content:
    start_marker = "app.get('/api/onboarding-action-templates'"
    start = server_content.find(start_marker)

    if start == -1:
        print("ERREUR : routes onboarding introuvables dans server/index.mjs")
        sys.exit(1)

    next_route = server_content.find("\napp.", start + len(start_marker))

    while next_route != -1:
        candidate = server_content[next_route + 1:]

        if not candidate.startswith(
            "app.post('/api/onboarding-action-templates'"
        ) and not candidate.startswith(
            "app.patch('/api/onboarding-action-templates/:id'"
        ) and not candidate.startswith(
            "app.delete('/api/onboarding-action-templates/:id'"
        ):
            break

        next_route = server_content.find("\napp.", next_route + 5)

    if next_route == -1:
        print("ERREUR : fin des routes onboarding introuvable")
        sys.exit(1)

    onboarding_routes = server_content[start:next_route]

    offboarding_routes = onboarding_routes.replace(
        "/api/onboarding-action-templates",
        "/api/offboarding-action-templates"
    ).replace(
        "onboarding_action_templates",
        "offboarding_action_templates"
    )

    server_content = (
        server_content[:next_route]
        + "\n\n// Workflow Offboarding\n"
        + offboarding_routes
        + server_content[next_route:]
    )

    SERVER.write_text(server_content, encoding="utf-8")
    print("OK : routes API Workflow Offboarding ajoutées")
else:
    print("INFO : routes API Workflow Offboarding déjà présentes")

# ============================================================
# 2. MODIFICATION DE SETTINGS.TSX
# ============================================================

settings_content = SETTINGS.read_text(encoding="utf-8")

# Ajouter la nouvelle valeur à l'union section
if "'workflow-offboarding'" not in settings_content:
    settings_content = settings_content.replace(
        "| 'workflow'",
        "| 'workflow'\n  | 'workflow-offboarding'",
        1
    )

# Rendre WorkflowSettings paramétrable
old_signature = """function WorkflowSettings({
  onBack
}: {
  onBack: () => void;
}) {"""

new_signature = """function WorkflowSettings({
  onBack,
  workflowType = 'onboarding'
}: {
  onBack: () => void;
  workflowType?: 'onboarding' | 'offboarding';
}) {

const workflowApi =
  workflowType === 'offboarding'
    ? '/api/offboarding-action-templates'
    : '/api/onboarding-action-templates';

const workflowTitle =
  workflowType === 'offboarding'
    ? 'Workflow Offboarding'
    : 'Workflow Onboarding';"""

if old_signature in settings_content:
    settings_content = settings_content.replace(
        old_signature,
        new_signature,
        1
    )
elif "const workflowApi =" not in settings_content:
    print(
        "ERREUR : signature WorkflowSettings introuvable. "
        "Restauration nécessaire."
    )
    sys.exit(1)

# Remplacer les URLs uniquement dans WorkflowSettings
function_start = settings_content.find("function WorkflowSettings(")

if function_start == -1:
    print("ERREUR : fonction WorkflowSettings introuvable")
    sys.exit(1)

workflow_part = settings_content[function_start:]

workflow_part = workflow_part.replace(
    "'/api/onboarding-action-templates'",
    "workflowApi"
)

workflow_part = workflow_part.replace(
    "`/api/onboarding-action-templates/${item.id}`",
    "`${workflowApi}/${item.id}`"
)

workflow_part = workflow_part.replace(
    "Workflow Onboarding",
    "{workflowTitle}"
)

settings_content = (
    settings_content[:function_start]
    + workflow_part
)

# Ajouter la navigation vers la section offboarding
navigation_marker = """if (section === 'workflow') {
    return (
      <WorkflowSettings"""

if navigation_marker in settings_content and (
    "section === 'workflow-offboarding'" not in settings_content
):
    onboarding_block_match = re.search(
        r"""if \(section === 'workflow'\) \{
\s*return \(
\s*<WorkflowSettings
.*?
\s*/>
\s*\);
\s*\}""",
        settings_content,
        re.S
    )

    if onboarding_block_match:
        onboarding_block = onboarding_block_match.group(0)

        offboarding_block = onboarding_block.replace(
            "section === 'workflow'",
            "section === 'workflow-offboarding'",
            1
        )

        offboarding_block = offboarding_block.replace(
            "<WorkflowSettings",
            "<WorkflowSettings\n        workflowType=\"offboarding\"",
            1
        )

        settings_content = settings_content.replace(
            onboarding_block,
            onboarding_block + "\n\n" + offboarding_block,
            1
        )
    else:
        print(
            "ATTENTION : bloc de navigation Workflow non reconnu."
        )

# Dupliquer la carte Workflow Onboarding
if (
    "key: 'workflow-offboarding'" not in settings_content
    and "key: 'workflow'" in settings_content
):
    card_match = re.search(
        r"""\{
\s*key:\s*'workflow',
.*?
\s*\}""",
        settings_content,
        re.S
    )

    if card_match:
        onboarding_card = card_match.group(0)

        offboarding_card = onboarding_card.replace(
            "key: 'workflow'",
            "key: 'workflow-offboarding'",
            1
        ).replace(
            "Workflow Onboarding",
            "Workflow Offboarding",
            1
        ).replace(
            "onboarding",
            "offboarding"
        )

        settings_content = settings_content.replace(
            onboarding_card,
            onboarding_card + ",\n    " + offboarding_card,
            1
        )
    else:
        print("ATTENTION : carte Workflow Onboarding non reconnue")

# Ajouter le clic de la nouvelle carte
click_marker = """if (card.key === 'workflow') {
    setSection('workflow');"""

if (
    click_marker in settings_content
    and "setSection('workflow-offboarding')" not in settings_content
):
    click_block_match = re.search(
        r"""if \(card\.key === 'workflow'\) \{
\s*setSection\('workflow'\);
\s*return;
\s*\}""",
        settings_content
    )

    if click_block_match:
        click_block = click_block_match.group(0)

        offboarding_click = click_block.replace(
            "card.key === 'workflow'",
            "card.key === 'workflow-offboarding'",
            1
        ).replace(
            "setSection('workflow')",
            "setSection('workflow-offboarding')",
            1
        )

        settings_content = settings_content.replace(
            click_block,
            click_block + "\n\n" + offboarding_click,
            1
        )
    else:
        print("ATTENTION : gestion du clic Workflow non reconnue")

SETTINGS.write_text(settings_content, encoding="utf-8")
print("OK : Settings.tsx modifié")

# ============================================================
# 3. CRÉATION DE LA TABLE ET DU TRIGGER POSTGRESQL
# ============================================================

sql = r"""
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS offboarding_action_templates (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    action_type text NOT NULL,
    label text NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION create_offboarding_movement_actions()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.type = 'offboarding' THEN
        INSERT INTO movement_actions (
            movement_id,
            action_type,
            label,
            sort_order
        )
        SELECT
            NEW.id,
            template.action_type,
            template.label,
            template.sort_order
        FROM offboarding_action_templates AS template
        WHERE template.is_active = true
          AND NOT EXISTS (
              SELECT 1
              FROM movement_actions AS existing
              WHERE existing.movement_id = NEW.id
                AND existing.action_type = template.action_type
                AND existing.label = template.label
          )
        ORDER BY template.sort_order;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_create_offboarding_actions
ON movements;

CREATE TRIGGER trg_create_offboarding_actions
AFTER INSERT ON movements
FOR EACH ROW
WHEN (NEW.type = 'offboarding')
EXECUTE FUNCTION create_offboarding_movement_actions();
"""

command = [
    "docker",
    "exec",
    "-i",
    "gestion_it_postgres",
    "psql",
    "-v",
    "ON_ERROR_STOP=1",
    "-U",
    "gestion_it",
    "-d",
    "gestion_it"
]

result = subprocess.run(
    command,
    input=sql,
    text=True,
    capture_output=True
)

if result.returncode != 0:
    print("ERREUR PostgreSQL :")
    print(result.stderr)
    sys.exit(1)

print("OK : table offboarding_action_templates créée")
print("OK : trigger automatique créé")

print()
print("PATCH TERMINÉ")
print("Fichiers modifiés :")
print("  - server/index.mjs")
print("  - src/pages/Settings.tsx")
print("Base modifiée :")
print("  - offboarding_action_templates")
print("  - trg_create_offboarding_actions")
