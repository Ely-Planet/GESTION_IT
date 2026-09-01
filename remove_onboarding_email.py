from pathlib import Path
from datetime import datetime
import shutil
import re
import sys

path = Path("src/pages/Movements.tsx")

if not path.exists():
    print("ERREUR : src/pages/Movements.tsx introuvable.")
    sys.exit(1)

source = path.read_text(encoding="utf-8")

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
backup = path.with_name(
    f"Movements.tsx.bak-before-remove-onboarding-email-{timestamp}"
)
shutil.copy2(path, backup)

movement_form_start = source.find("function MovementForm({")

if movement_form_start == -1:
    print("ERREUR : MovementForm introuvable.")
    sys.exit(1)

offboarding_start = source.find(
    "{type === 'offboarding' ? (",
    movement_form_start
)

if offboarding_start == -1:
    print("ERREUR : formulaire Offboarding/Onboarding introuvable.")
    sys.exit(1)

onboarding_start = source.find(
    ") : (",
    offboarding_start
)

if onboarding_start == -1:
    print("ERREUR : début du formulaire Onboarding introuvable.")
    sys.exit(1)

material_section = source.find(
    "{type === 'onboarding' && (",
    onboarding_start
)

if material_section == -1:
    print("ERREUR : section matériel Onboarding introuvable.")
    sys.exit(1)

onboarding_form = source[onboarding_start:material_section]

# Recherche exclusivement le bloc Email du formulaire Onboarding.
email_pattern = re.compile(
    r"""
    \s*<div>\s*
      <label\s+className="label">\s*
        Email\s*
      </label>\s*
      <input\s*
        type="email"\s*
        className="input"\s*
        value=\{email\}\s*
        onChange=\{\(e\)\s*=>\s*setEmail\(e\.target\.value\)\}\s*
        placeholder="prenom\.nom@elyade\.com"\s*
      />\s*
    </div>
    """,
    re.VERBOSE
)

updated_onboarding_form, count = email_pattern.subn(
    "",
    onboarding_form,
    count=1
)

if count != 1:
    print("ERREUR : bloc Email exact non trouvé dans le formulaire Onboarding.")
    print("Aucune modification effectuée.")
    print(f"Sauvegarde disponible : {backup}")
    sys.exit(1)

source = (
    source[:onboarding_start]
    + updated_onboarding_form
    + source[material_section:]
)

# Corrige la fermeture JSX si elle est encore restée sous la forme :
# </>
# )
# {type === 'onboarding' && (
source = re.sub(
    r"""
    </>\s*
    \)\s*
    (?=\{type\s*===\s*'onboarding'\s*&&\s*\()
    """,
    "</>\n)}\n          ",
    source,
    count=1,
    flags=re.VERBOSE
)

path.write_text(source, encoding="utf-8")

# Contrôles après modification.
final_source = path.read_text(encoding="utf-8")
final_movement_start = final_source.find("function MovementForm({")
final_onboarding_start = final_source.find(
    ") : (",
    final_source.find(
        "{type === 'offboarding' ? (",
        final_movement_start
    )
)
final_material_start = final_source.find(
    "{type === 'onboarding' && (",
    final_onboarding_start
)

final_onboarding = final_source[
    final_onboarding_start:final_material_start
]

errors = []

if 'value={email}' in final_onboarding:
    errors.append("le champ Email est encore présent dans l'Onboarding")

required_markers = [
    "value={firstName}",
    "value={lastName}",
    "value={jobTitle}",
    "value={effectiveDate}",
    "value={serviceId}",
    "value={contractTypeId}",
    "value={managerSearch}",
    "selectedManagerId",
]

for marker in required_markers:
    if marker not in final_onboarding:
        errors.append(f"élément attendu absent : {marker}")

if errors:
    print("ERREUR DE CONTROLE :")
    for error in errors:
        print(f"- {error}")
    print(f"Sauvegarde disponible : {backup}")
    sys.exit(1)

print("")
print("MODIFICATION APPLIQUEE")
print(f"Sauvegarde : {backup}")
print("- champ Email retiré uniquement du formulaire Onboarding")
print("- manager Microsoft conservé")
print("- services conservés")
print("- contrats conservés")
print("- matériel conservé")
print("- licences conservées")
print("- Offboarding non modifié")
print("- email de la fenêtre de signature non modifié")
