from pathlib import Path
from datetime import datetime
import shutil
import sys
import re

FILE = Path("src/pages/Movements.tsx")

if not FILE.exists():
    print("ERREUR : src/pages/Movements.tsx introuvable.")
    sys.exit(1)

source = FILE.read_text(encoding="utf-8")

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
backup = FILE.with_name(
    f"Movements.tsx.bak-before-finalize-onboarding-{timestamp}"
)
shutil.copy2(FILE, backup)

movement_form_pos = source.find("function MovementForm({")
if movement_form_pos == -1:
    print("ERREUR : composant MovementForm introuvable.")
    sys.exit(1)

marker = "{type === 'onboarding' && ("
marker_pos = source.find(marker, movement_form_pos)

if marker_pos == -1:
    print("ERREUR : section Matériel/Licences Onboarding introuvable.")
    sys.exit(1)

before = source[:marker_pos]
after = source[marker_pos:]

# Corrige la fermeture incorrecte située juste avant
# la section Matériel/Licences.
match = re.search(r"(</>\s*)\)(\s*)$", before)

if match:
    before = (
        before[:match.start()]
        + match.group(1)
        + ")}"
        + match.group(2)
    )
    print("Fermeture JSX corrigée : ')' remplacé par ')}'.")
else:
    already_correct = re.search(r"(</>\s*)\)\}(\s*)$", before)

    if not already_correct:
        print("ERREUR : fermeture JSX attendue introuvable.")
        print("Dernières lignes avant la section Matériel/Licences :")
        print("\n".join(before.splitlines()[-12:]))
        print(f"Sauvegarde : {backup}")
        sys.exit(1)

    print("Fermeture JSX déjà correcte.")

source = before + after
FILE.write_text(source, encoding="utf-8")

print("")
print("MODIFICATION TERMINEE")
print(f"Sauvegarde : {backup}")
print(f"Fichier : {FILE}")
