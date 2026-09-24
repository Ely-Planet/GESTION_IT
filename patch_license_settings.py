from pathlib import Path
from datetime import datetime
import shutil
import sys

server_file = Path("server/index.mjs")
settings_file = Path("src/pages/Settings.tsx")

for file_path in (server_file, settings_file):
    if not file_path.exists():
        print(f"ERREUR : fichier introuvable : {file_path}")
        sys.exit(1)

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

for file_path in (server_file, settings_file):
    backup = file_path.with_name(
        f"{file_path.name}.bak-license-settings-{timestamp}"
    )
    shutil.copy2(file_path, backup)
    print(f"Sauvegarde créée : {backup}")

# ============================================================
# BACKEND : autoriser requestable_for_onboarding dans le PATCH
# ============================================================

server_content = server_file.read_text(encoding="utf-8")

route_start = server_content.find(
    "app.patch('/api/license-types/:id'"
)

if route_start == -1:
    print("ERREUR : route PATCH /api/license-types/:id introuvable.")
    sys.exit(1)

route_end = server_content.find(
    "app.delete('/api/license-types/:id'",
    route_start
)

if route_end == -1:
    print("ERREUR : fin de la route PATCH introuvable.")
    sys.exit(1)

before_route = server_content[:route_start]
patch_route = server_content[route_start:route_end]
after_route = server_content[route_end:]

if "'requestable_for_onboarding'" not in patch_route:
    old_allowed_end = """      'default_renewal_notice_days',
      'notes'
    ];"""

    new_allowed_end = """      'default_renewal_notice_days',
      'notes',
      'requestable_for_onboarding'
    ];"""

    if old_allowed_end not in patch_route:
        print(
            "ERREUR : liste allowedColumns du PATCH non reconnue."
        )
        sys.exit(1)

    patch_route = patch_route.replace(
        old_allowed_end,
        new_allowed_end,
        1
    )

    print(
        "OK : requestable_for_onboarding autorisé dans le PATCH."
    )
else:
    print(
        "INFO : requestable_for_onboarding est déjà autorisé."
    )

server_content = before_route + patch_route + after_route
server_file.write_text(server_content, encoding="utf-8")

# ============================================================
# FRONTEND : fonctions toggle et rename
# ============================================================

settings_content = settings_file.read_text(encoding="utf-8")

license_component_start = settings_content.find(
    "function LicenseSettings("
)

if license_component_start == -1:
    print("ERREUR : composant LicenseSettings introuvable.")
    sys.exit(1)

inventory_component_start = settings_content.find(
    "function InventorySettings(",
    license_component_start
)

if inventory_component_start == -1:
    print("ERREUR : fin du composant LicenseSettings introuvable.")
    sys.exit(1)

before_component = settings_content[:license_component_start]
license_component = settings_content[
    license_component_start:inventory_component_start
]
after_component = settings_content[inventory_component_start:]

# Remplacer la fonction toggle
old_toggle = """  async function toggle(
    row: LicenseTypeRow
  ) {
    await fetch(
      `/api/license-types/${row.id}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          requestable_for_onboarding:
            !row.requestable_for_onboarding
        })
      }
    );

    load();
  }"""

new_toggle = """  async function toggle(
    row: LicenseTypeRow
  ) {
    const newValue =
      !row.requestable_for_onboarding;

    setRows(currentRows =>
      currentRows.map(currentRow =>
        currentRow.id === row.id
          ? {
              ...currentRow,
              requestable_for_onboarding:
                newValue
            }
          : currentRow
      )
    );

    try {
      const res = await fetch(
        `/api/license-types/${row.id}`,
        {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            requestable_for_onboarding:
              newValue
          })
        }
      );

      if (!res.ok) {
        const errorData = await res
          .json()
          .catch(() => null);

        throw new Error(
          errorData?.error ||
          `Erreur HTTP ${res.status}`
        );
      }
    } catch (error) {
      setRows(currentRows =>
        currentRows.map(currentRow =>
          currentRow.id === row.id
            ? {
                ...currentRow,
                requestable_for_onboarding:
                  row.requestable_for_onboarding
              }
            : currentRow
        )
      );

      alert(
        error instanceof Error
          ? error.message
          : 'Impossible de modifier la licence.'
      );
    }
  }

  function changeLabel(
    id: string,
    label: string
  ) {
    setRows(currentRows =>
      currentRows.map(currentRow =>
        currentRow.id === id
          ? {
              ...currentRow,
              label
            }
          : currentRow
      )
    );
  }

  async function saveLabel(
    row: LicenseTypeRow
  ) {
    const label = row.label.trim();

    if (!label) {
      alert(
        'Le nom de la licence ne peut pas être vide.'
      );
      return;
    }

    try {
      const res = await fetch(
        `/api/license-types/${row.id}`,
        {
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            label
          })
        }
      );

      if (!res.ok) {
        const errorData = await res
          .json()
          .catch(() => null);

        throw new Error(
          errorData?.error ||
          `Erreur HTTP ${res.status}`
        );
      }

      await load();
    } catch (error) {
      alert(
        error instanceof Error
          ? error.message
          : 'Impossible de renommer la licence.'
      );
    }
  }"""

if old_toggle not in license_component:
    print(
        "ERREUR : fonction toggle attendue introuvable. "
        "Aucune modification frontend enregistrée."
    )
    sys.exit(1)

license_component = license_component.replace(
    old_toggle,
    new_toggle,
    1
)

# Ajouter une colonne Actions
old_header = """                <th>Licence</th>
                <th>Code</th>
                <th>Visible</th>"""

new_header = """                <th>Nom affiché</th>
                <th>Code</th>
                <th>Visible</th>
                <th>Actions</th>"""

if old_header not in license_component:
    print("ERREUR : en-tête du tableau licences introuvable.")
    sys.exit(1)

license_component = license_component.replace(
    old_header,
    new_header,
    1
)

# Remplacer la cellule label par un champ modifiable
old_label_cell = """                  <td>
                    {row.label}
                  </td>"""

new_label_cell = """                  <td>
                    <input
                      type="text"
                      className="input"
                      value={row.label}
                      onChange={e =>
                        changeLabel(
                          row.id,
                          e.target.value
                        )
                      }
                      onKeyDown={e => {
                        if (e.key === 'Enter') {
                          saveLabel(row);
                        }
                      }}
                    />
                  </td>"""

if old_label_cell not in license_component:
    print("ERREUR : cellule du libellé introuvable.")
    sys.exit(1)

license_component = license_component.replace(
    old_label_cell,
    new_label_cell,
    1
)

# Ajouter la cellule Actions après le checkbox
old_checkbox_cell = """                  <td>
                    <input
                      type="checkbox"
                      checked={
                        row.requestable_for_onboarding
                      }
                      onChange={() =>
                        toggle(row)
                      }
                    />
                  </td>"""

new_checkbox_cell = """                  <td>
                    <input
                      type="checkbox"
                      checked={Boolean(
                        row.requestable_for_onboarding
                      )}
                      onChange={() =>
                        toggle(row)
                      }
                    />
                  </td>

                  <td>
                    <button
                      type="button"
                      className="btn-primary"
                      onClick={() =>
                        saveLabel(row)
                      }
                    >
                      Enregistrer
                    </button>
                  </td>"""

if old_checkbox_cell not in license_component:
    print("ERREUR : cellule checkbox introuvable.")
    sys.exit(1)

license_component = license_component.replace(
    old_checkbox_cell,
    new_checkbox_cell,
    1
)

settings_content = (
    before_component
    + license_component
    + after_component
)

settings_file.write_text(
    settings_content,
    encoding="utf-8"
)

print("OK : renommage des licences ajouté.")
print("OK : checkbox Visible corrigé.")
print("OK : gestion des erreurs ajoutée.")
print()
print("PATCH TERMINÉ.")
