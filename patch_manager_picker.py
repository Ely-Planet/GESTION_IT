from pathlib import Path
from datetime import datetime
import shutil
import sys

FILE = Path("src/pages/Movements.tsx")

if not FILE.exists():
    print("ERREUR : src/pages/Movements.tsx introuvable.")
    sys.exit(1)

source = FILE.read_text(encoding="utf-8")

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
backup = FILE.with_name(
    f"Movements.tsx.bak-manager-picker-{timestamp}"
)

shutil.copy2(FILE, backup)
print(f"Sauvegarde créée : {backup}")

# ---------------------------------------------------------
# 1. Ajouter les états nécessaires au sélecteur de manager
# ---------------------------------------------------------

old_state = """  const [managerName, setManagerName] = useState('');"""

new_state = """  const [managerName, setManagerName] = useState('');
  const [managerSearch, setManagerSearch] = useState('');
  const [selectedManagerId, setSelectedManagerId] = useState('');"""

if old_state not in source:
    print("ERREUR : déclaration managerName introuvable.")
    sys.exit(1)

source = source.replace(old_state, new_state, 1)

# ---------------------------------------------------------
# 2. Remplacer le champ texte Manager par un sélecteur
# ---------------------------------------------------------

old_manager_block = """            <div>
              <label className="label">Manager</label>
              <input className="input" value={managerName} onChange={(e) => setManagerName(e.target.value)} placeholder="Nom du manager" />
            </div>"""

new_manager_block = """            <div className="relative">
              <label className="label">Manager</label>

              <input
                type="text"
                className="input"
                value={managerSearch}
                placeholder="Rechercher par nom, prénom ou email..."
                autoComplete="off"
                onChange={(e) => {
                  setManagerSearch(e.target.value);
                  setSelectedManagerId('');
                  setManagerName('');
                }}
              />

              {managerSearch.trim() && !selectedManagerId && (
                <div className="absolute z-50 mt-1 max-h-64 w-full overflow-y-auto rounded-lg border border-ink-200 bg-white shadow-lg">
                  {data.employees
                    .filter((employee) => employee.is_active)
                    .filter((employee) => {
                      const search = managerSearch
                        .trim()
                        .toLowerCase();

                      const searchableText = [
                        employee.first_name ?? '',
                        employee.last_name ?? '',
                        employee.email ?? '',
                        employee.microsoft_upn ?? '',
                        `${employee.first_name ?? ''} ${employee.last_name ?? ''}`,
                        `${employee.last_name ?? ''} ${employee.first_name ?? ''}`,
                      ]
                        .join(' ')
                        .toLowerCase();

                      return searchableText.includes(search);
                    })
                    .sort((a, b) =>
                      `${a.last_name ?? ''} ${a.first_name ?? ''}`.localeCompare(
                        `${b.last_name ?? ''} ${b.first_name ?? ''}`,
                        'fr',
                        { sensitivity: 'base' }
                      )
                    )
                    .slice(0, 20)
                    .map((employee) => {
                      const employeeName =
                        `${employee.first_name ?? ''} ${employee.last_name ?? ''}`.trim();

                      const employeeEmail =
                        employee.email ??
                        employee.microsoft_upn ??
                        '';

                      return (
                        <button
                          key={employee.id}
                          type="button"
                          className="w-full border-b border-ink-100 px-3 py-2 text-left last:border-b-0 hover:bg-elyade-50"
                          onClick={() => {
                            setSelectedManagerId(employee.id);
                            setManagerName(employeeName);
                            setManagerSearch(
                              employeeEmail
                                ? `${employeeName} - ${employeeEmail}`
                                : employeeName
                            );
                          }}
                        >
                          <div className="text-sm font-medium text-ink-800">
                            {employeeName}
                          </div>

                          {employeeEmail && (
                            <div className="text-xs text-ink-500">
                              {employeeEmail}
                            </div>
                          )}
                        </button>
                      );
                    })}

                  {data.employees
                    .filter((employee) => employee.is_active)
                    .filter((employee) => {
                      const search = managerSearch
                        .trim()
                        .toLowerCase();

                      const searchableText = [
                        employee.first_name ?? '',
                        employee.last_name ?? '',
                        employee.email ?? '',
                        employee.microsoft_upn ?? '',
                      ]
                        .join(' ')
                        .toLowerCase();

                      return searchableText.includes(search);
                    }).length === 0 && (
                      <div className="px-3 py-3 text-sm text-ink-400">
                        Aucun manager trouvé.
                      </div>
                    )}
                </div>
              )}

              {selectedManagerId && (
                <p className="mt-1 text-xs font-medium text-green-700">
                  Manager sélectionné
                </p>
              )}
            </div>"""

if old_manager_block not in source:
    print("ERREUR : ancien champ Manager introuvable.")
    print("Aucune modification écrite.")
    sys.exit(1)

source = source.replace(
    old_manager_block,
    new_manager_block,
    1
)

FILE.write_text(source, encoding="utf-8")

print("OK : sélecteur de manager ajouté.")
print("La recherche couvre prénom, nom, email et Microsoft UPN.")
print("managerName continue d'être renseigné pour le payload existant.")
