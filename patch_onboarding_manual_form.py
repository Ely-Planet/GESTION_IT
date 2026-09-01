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
    f"Movements.tsx.bak-onboarding-form-{timestamp}"
)

shutil.copy2(FILE, backup)

movement_form_start = source.find("function MovementForm({")

if movement_form_start == -1:
    print("ERREUR : MovementForm introuvable.")
    sys.exit(1)

# ---------------------------------------------------------
# 1. Ajouter l'état contractReason s'il n'existe pas
# ---------------------------------------------------------

state_marker = (
    "const [contractEndDate, setContractEndDate] = useState('');"
)

contract_reason_state = (
    "const [contractReason, setContractReason] = useState('');"
)

movement_form_source = source[movement_form_start:]

if contract_reason_state not in movement_form_source:
    state_position = source.find(
        state_marker,
        movement_form_start
    )

    if state_position == -1:
        print(
            "ERREUR : état contractEndDate introuvable "
            "dans MovementForm."
        )
        print(f"Sauvegarde : {backup}")
        sys.exit(1)

    insert_position = state_position + len(state_marker)

    source = (
        source[:insert_position]
        + "\n  "
        + contract_reason_state
        + source[insert_position:]
    )

# ---------------------------------------------------------
# 2. Élargir uniquement la popup Onboarding
# ---------------------------------------------------------

old_modal_class = (
    '<div className="card w-full max-w-2xl '
    'max-h-[90vh] overflow-auto" '
    'onClick={(e) => e.stopPropagation()}>'
)

new_modal_class = (
    '<div '
    'className={`card w-full max-h-[90vh] overflow-auto '
    '${type === \'onboarding\' ? \'max-w-5xl\' : \'max-w-2xl\'}`} '
    'onClick={(e) => e.stopPropagation()}>'
)

movement_form_start = source.find("function MovementForm({")
modal_position = source.find(
    old_modal_class,
    movement_form_start
)

if modal_position != -1:
    source = (
        source[:modal_position]
        + new_modal_class
        + source[modal_position + len(old_modal_class):]
    )
else:
    print(
        "ATTENTION : largeur de la popup non modifiée, "
        "balise exacte non trouvée."
    )

# ---------------------------------------------------------
# 3. Repérer exclusivement la branche Onboarding du ternaire
# ---------------------------------------------------------

movement_form_start = source.find("function MovementForm({")

offboarding_ternary = source.find(
    "{type === 'offboarding' ? (",
    movement_form_start
)

if offboarding_ternary == -1:
    print("ERREUR : ternaire Offboarding/Onboarding introuvable.")
    print(f"Sauvegarde : {backup}")
    sys.exit(1)

else_marker = ") : ("
onboarding_branch_start = source.find(
    else_marker,
    offboarding_ternary
)

if onboarding_branch_start == -1:
    print("ERREUR : début de la branche Onboarding introuvable.")
    print(f"Sauvegarde : {backup}")
    sys.exit(1)

onboarding_branch_start += len(else_marker)

needs_marker = "{type === 'onboarding' && ("

needs_position = source.find(
    needs_marker,
    onboarding_branch_start
)

if needs_position == -1:
    print("ERREUR : section Matériel/Licences introuvable.")
    print(f"Sauvegarde : {backup}")
    sys.exit(1)

# La branche actuelle se termine par </> puis )}
closing_fragment_position = source.rfind(
    "</>",
    onboarding_branch_start,
    needs_position
)

if closing_fragment_position == -1:
    print("ERREUR : fin de la branche Onboarding introuvable.")
    print(f"Sauvegarde : {backup}")
    sys.exit(1)

closing_expression_position = source.find(
    ")}",
    closing_fragment_position
)

if (
    closing_expression_position == -1
    or closing_expression_position > needs_position
):
    print("ERREUR : fermeture du ternaire Onboarding introuvable.")
    print(f"Sauvegarde : {backup}")
    sys.exit(1)

branch_end = closing_expression_position + 2

# ---------------------------------------------------------
# 4. Nouveau formulaire Onboarding
# ---------------------------------------------------------

new_onboarding_branch = r'''
  <>
    <section className="card border border-ink-100 p-5">
      <h3 className="mb-4 text-base font-semibold text-ink-900">
        Collaborateur
      </h3>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div>
          <label className="label">
            Prénom
          </label>

          <input
            className="input"
            value={firstName}
            onChange={(e) => setFirstName(e.target.value)}
            placeholder="Prénom"
            required
          />
        </div>

        <div>
          <label className="label">
            Nom
          </label>

          <input
            className="input"
            value={lastName}
            onChange={(e) => setLastName(e.target.value)}
            placeholder="Nom"
            required
          />
        </div>

        <div>
          <label className="label">
            Fonction
          </label>

          <input
            className="input"
            value={jobTitle}
            onChange={(e) => setJobTitle(e.target.value)}
            placeholder="Exemple : Gestionnaire locatif"
          />
        </div>

        <div>
          <label className="label">
            Email
          </label>

          <input
            type="email"
            className="input"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="prenom.nom@elyade.com"
          />
        </div>

        <div>
          <label className="label">
            Date d'arrivée prévue
          </label>

          <input
            type="date"
            className="input"
            value={effectiveDate}
            onChange={(e) => setEffectiveDate(e.target.value)}
            required
          />
        </div>

        <div>
          <label className="label">
            Service
          </label>

          <select
            className="input"
            value={serviceId}
            onChange={(e) => setServiceId(e.target.value)}
          >
            <option value="">
              Sélectionner un service
            </option>

            {data.services.map((service) => (
              <option
                key={service.id}
                value={service.id}
              >
                {service.name}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="label">
            Contrat
          </label>

          <select
            className="input"
            value={contractTypeId}
            onChange={(e) => {
              const value = e.target.value;

              setContractTypeId(value);

              const selectedContract =
                data.contractTypes.find(
                  (contractType) =>
                    contractType.id === value
                );

              const selectedLabel =
                selectedContract?.label
                  ?.trim()
                  .toLocaleLowerCase('fr-FR') ?? '';

              if (selectedLabel !== 'cdd') {
                setContractReason('');
              }

              if (
                selectedLabel !== 'cdd' &&
                selectedLabel !== 'stage' &&
                !selectedContract?.has_end_date
              ) {
                setContractEndDate('');
              }
            }}
            required
          >
            <option value="">
              Sélectionner un contrat
            </option>

            {data.contractTypes.map((contractType) => (
              <option
                key={contractType.id}
                value={contractType.id}
              >
                {contractType.label}
              </option>
            ))}
          </select>
        </div>

        {contractTypeId &&
          (
            contract?.has_end_date ||
            contract?.label
              ?.trim()
              .toLocaleLowerCase('fr-FR') === 'cdd' ||
            contract?.label
              ?.trim()
              .toLocaleLowerCase('fr-FR') === 'stage'
          ) && (
          <div>
            <label className="label">
              Date de fin de contrat
            </label>

            <input
              type="date"
              className="input"
              value={contractEndDate}
              onChange={(e) =>
                setContractEndDate(e.target.value)
              }
            />

            <p className="mt-1 text-xs text-elyade-600">
              Un offboarding pourra être généré à cette date.
            </p>
          </div>
        )}

        {contract?.label
          ?.trim()
          .toLocaleLowerCase('fr-FR') === 'cdd' && (
          <div>
            <label className="label">
              Motif du CDD
            </label>

            <input
              type="text"
              className="input"
              value={contractReason}
              onChange={(e) =>
                setContractReason(e.target.value)
              }
              placeholder="Exemple : remplacement congé maternité"
            />
          </div>
        )}
      </div>
    </section>

    <section className="card border border-ink-100 p-5">
      <h3 className="mb-4 text-base font-semibold text-ink-900">
        Manager
      </h3>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div className="relative">
          <label className="label">
            Compte Microsoft du manager
          </label>

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
                    .toLocaleLowerCase('fr-FR');

                  const searchableText = [
                    employee.first_name ?? '',
                    employee.last_name ?? '',
                    employee.email ?? '',
                    employee.microsoft_upn ?? '',
                    `${employee.first_name ?? ''} ${employee.last_name ?? ''}`,
                    `${employee.last_name ?? ''} ${employee.first_name ?? ''}`,
                  ]
                    .join(' ')
                    .toLocaleLowerCase('fr-FR');

                  return searchableText.includes(search);
                })
                .sort((a, b) =>
                  `${a.last_name ?? ''} ${a.first_name ?? ''}`
                    .localeCompare(
                      `${b.last_name ?? ''} ${b.first_name ?? ''}`,
                      'fr-FR',
                      { sensitivity: 'base' }
                    )
                )
                .slice(0, 20)
                .map((employee) => {
                  const employeeName =
                    `${employee.first_name ?? ''} ${employee.last_name ?? ''}`
                      .trim();

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
                    .toLocaleLowerCase('fr-FR');

                  const searchableText = [
                    employee.first_name ?? '',
                    employee.last_name ?? '',
                    employee.email ?? '',
                    employee.microsoft_upn ?? '',
                  ]
                    .join(' ')
                    .toLocaleLowerCase('fr-FR');

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
        </div>

        <div>
          <label className="label">
            Source
          </label>

          <select
            className="input"
            value={source}
            onChange={(e) =>
              setSource(e.target.value as typeof source)
            }
          >
            <option value="manual">
              Saisie manuelle
            </option>

            <option value="manager_form">
              Formulaire manager
            </option>

            <option value="lucca_email">
              Email Lucca
            </option>
          </select>
        </div>
      </div>
    </section>
  </>
)'''

source = (
    source[:onboarding_branch_start]
    + new_onboarding_branch
    + source[branch_end:]
)

# ---------------------------------------------------------
# 5. Ajouter manager_email au payload si absent
# ---------------------------------------------------------

movement_form_start = source.find("function MovementForm({")

payload_start = source.find(
    "const payload = {",
    movement_form_start
)

payload_end = source.find(
    "};",
    payload_start
)

if payload_start == -1 or payload_end == -1:
    print("ERREUR : payload du mouvement introuvable.")
    print(f"Sauvegarde : {backup}")
    sys.exit(1)

payload = source[payload_start:payload_end]

if "manager_email:" not in payload:
    manager_name_line = "        manager_name: managerName || null,"

    if manager_name_line not in payload:
        print(
            "ERREUR : manager_name introuvable "
            "dans le payload."
        )
        print(f"Sauvegarde : {backup}")
        sys.exit(1)

    manager_email_code = r'''
        manager_email:
          type === 'onboarding' && selectedManagerId
            ? (
                data.employees.find(
                  (employee) =>
                    employee.id === selectedManagerId
                )?.email ??
                data.employees.find(
                  (employee) =>
                    employee.id === selectedManagerId
                )?.microsoft_upn ??
                null
              )
            : null,'''.rstrip()

    payload = payload.replace(
        manager_name_line,
        manager_name_line + "\n" + manager_email_code,
        1
    )

    source = (
        source[:payload_start]
        + payload
        + source[payload_end:]
    )

# ---------------------------------------------------------
# 6. Enregistrer le motif CDD dans les notes du mouvement
# ---------------------------------------------------------

movement_form_start = source.find("function MovementForm({")

payload_start = source.find(
    "const payload = {",
    movement_form_start
)

payload_end = source.find(
    "};",
    payload_start
)

payload = source[payload_start:payload_end]

old_notes = "        notes: notes || null,"

new_notes = r'''        notes:
          type === 'onboarding'
            ? [
                contractReason.trim()
                  ? `Motif du CDD : ${contractReason.trim()}`
                  : null,
                notes.trim() || null,
              ]
                .filter(Boolean)
                .join('\n') || null
            : notes || null,'''.rstrip()

if old_notes in payload:
    payload = payload.replace(
        old_notes,
        new_notes,
        1
    )

    source = (
        source[:payload_start]
        + payload
        + source[payload_end:]
    )
elif "Motif du CDD :" not in payload:
    print(
        "ATTENTION : ligne notes non reconnue, "
        "motif CDD non ajouté au payload."
    )

FILE.write_text(source, encoding="utf-8")

print("")
print("FORMULAIRE ONBOARDING MODIFIE")
print(f"Sauvegarde : {backup}")
print(f"Fichier : {FILE}")
print("")
print("Champs conservés :")
print("- prénom et nom")
print("- fonction")
print("- email")
print("- date d'arrivée")
print("- service")
print("- contrat")
print("- date de fin selon le contrat")
print("- motif du CDD")
print("- manager Microsoft")
print("- source")
print("- matériel, licences et notes existants")
print("")
print("Champs exclus :")
print("- salaire")
print("- CV")
print("- statut")
print("- prime")
print("- niveau")
print("- école")
print("- rémunération")
