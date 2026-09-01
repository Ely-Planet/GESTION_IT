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
    f"Movements.tsx.bak-offboarding-picker-{timestamp}"
)

shutil.copy2(FILE, backup)
print(f"Sauvegarde créée : {backup}")

component_pos = source.find("function MovementForm({")

if component_pos == -1:
    print("ERREUR : composant MovementForm introuvable.")
    sys.exit(1)

placeholder_pos = source.find(
    'placeholder="Rechercher un collaborateur..."',
    component_pos
)

if placeholder_pos == -1:
    print(
        "ERREUR : champ de recherche du collaborateur introuvable "
        "dans MovementForm."
    )
    sys.exit(1)

input_start = source.rfind("<input", component_pos, placeholder_pos)

if input_start == -1:
    print("ERREUR : début du champ input introuvable.")
    sys.exit(1)

select_end_marker = "</select>"
select_end = source.find(select_end_marker, placeholder_pos)

if select_end == -1:
    print("ERREUR : fin du select collaborateur introuvable.")
    sys.exit(1)

select_end += len(select_end_marker)

old_block = source[input_start:select_end]

new_block = """<div className="relative">
  <input
    type="text"
    className="input"
    placeholder="Rechercher par nom, prénom ou email..."
    value={employeeSearch}
    onChange={(e) => {
      setEmployeeSearch(e.target.value);
      setSelectedEmployeeId('');
    }}
    autoComplete="off"
    required={!selectedEmployeeId}
  />

  <div className="mt-2 max-h-64 overflow-y-auto rounded-lg border border-ink-200 bg-white shadow-sm">
    {data.employees
      .filter((employee) => employee.is_active)
      .filter((employee) => {
        const search = employeeSearch.trim().toLowerCase();

        if (!search) {
          return true;
        }

        const firstName = employee.first_name ?? '';
        const lastName = employee.last_name ?? '';
        const email =
          employee.email ??
          employee.microsoft_upn ??
          '';

        const searchableText = [
          firstName,
          lastName,
          email,
          `${firstName} ${lastName}`,
          `${lastName} ${firstName}`,
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
      .map((employee) => {
        const employeeEmail =
          employee.email ??
          employee.microsoft_upn ??
          '';

        const isSelected =
          selectedEmployeeId === employee.id;

        return (
          <button
            key={employee.id}
            type="button"
            onClick={() => {
              setSelectedEmployeeId(employee.id);
              setEmployeeSearch(
                `${employee.first_name ?? ''} ${employee.last_name ?? ''}`.trim()
              );
            }}
            className={`w-full border-b border-ink-100 px-3 py-2 text-left last:border-b-0 hover:bg-elyade-50 ${
              isSelected
                ? 'bg-elyade-50 ring-1 ring-inset ring-elyade-300'
                : 'bg-white'
            }`}
          >
            <div className="text-sm font-medium text-ink-800">
              {employee.first_name} {employee.last_name}
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
        const search = employeeSearch.trim().toLowerCase();

        if (!search) {
          return true;
        }

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
      }).length === 0 && (
        <div className="px-3 py-3 text-sm text-ink-400">
          Aucun collaborateur trouvé.
        </div>
      )}
  </div>

  {selectedEmployeeId && (
    <p className="mt-2 text-xs font-medium text-green-700">
      Collaborateur sélectionné
    </p>
  )}
</div>"""

source = source[:input_start] + new_block + source[select_end:]

FILE.write_text(source, encoding="utf-8")

print("OK : sélecteur collaborateur remplacé.")
print("Recherche active sur : prénom, nom, email et Microsoft UPN.")
