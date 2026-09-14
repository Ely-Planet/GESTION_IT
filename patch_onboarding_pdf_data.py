from pathlib import Path
from datetime import datetime
import shutil
import sys

file_path = Path("server/onboardingRequest.mjs")

if not file_path.exists():
    print(f"ERREUR : fichier introuvable : {file_path}")
    sys.exit(1)

content = file_path.read_text(encoding="utf-8")
original = content

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
backup_path = file_path.with_name(
    f"{file_path.name}.bak-pdf-data-{timestamp}"
)
shutil.copy2(file_path, backup_path)

modifications = []

# 1. Ajouter contractEndDate dans les données envoyées au PDF
if "contractEndDate: contract_end_date," not in content:
    old = """    contractType: contract_type,

    employeeStatus:"""

    new = """    contractType: contract_type,

    contractEndDate: contract_end_date,

    employeeStatus:"""

    if old not in content:
        print(
            "ERREUR : impossible de trouver le bloc contractType/employeeStatus."
        )
        print(f"Sauvegarde créée : {backup_path}")
        sys.exit(1)

    content = content.replace(old, new, 1)
    modifications.append(
        "Ajout de contractEndDate dans generateOnboardingPdf"
    )
else:
    print(
        "INFO : contractEndDate est déjà transmis au PDF."
    )

# 2. Corriger le booléen referral envoyé au PDF
old_referral = """referral:
  referral === true,"""

new_referral = """referral:
  parseBoolean(referral),"""

if old_referral in content:
    content = content.replace(
        old_referral,
        new_referral,
        1
    )
    modifications.append(
        "Correction du booléen de cooptation avec parseBoolean"
    )
elif "referral:\n  parseBoolean(referral)," in content:
    print(
        "INFO : la cooptation utilise déjà parseBoolean."
    )
else:
    print(
        "ATTENTION : bloc referral non trouvé, aucune modification "
        "automatique sur la cooptation."
    )

if content == original:
    print("Aucune modification nécessaire.")
    print(f"Sauvegarde créée : {backup_path}")
    sys.exit(0)

file_path.write_text(content, encoding="utf-8")

print("MODIFICATIONS EFFECTUÉES :")
for modification in modifications:
    print(f"  - {modification}")

print(f"Sauvegarde : {backup_path}")
print(f"Fichier modifié : {file_path}")
