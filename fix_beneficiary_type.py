from pathlib import Path

f = Path("src/pages/Movements.tsx")

content = f.read_text(encoding="utf-8")

old = """body: JSON.stringify({
        employee_id: employeeId,
        changes: ["""

new = """body: JSON.stringify({
        beneficiary_type: 'employee',
        employee_id: employeeId,
        changes: ["""

if old not in content:
    print("Bloc non trouvé")
    exit(1)

backup = Path("src/pages/Movements.tsx.bak-beneficiary-type")
backup.write_text(content, encoding="utf-8")

content = content.replace(old, new, 1)

f.write_text(content, encoding="utf-8")

print("✅ Correction effectuée")
print("✅ Sauvegarde :", backup)
