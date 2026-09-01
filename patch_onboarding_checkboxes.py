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
    f"Movements.tsx.bak-onboarding-checkboxes-{timestamp}"
)
shutil.copy2(FILE, backup)

print(f"Sauvegarde créée : {backup}")

# =========================================================
# 1. SERVICE : remplacer le select par des cases à cocher
#    Sélection unique car le backend utilise service_id.
# =========================================================

old_service = """        <div>
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
        </div>"""

new_service = """        <div className="md:col-span-2">
          <label className="label">
            Service
          </label>

          <p className="mb-2 text-xs text-ink-500">
            Sélectionnez le service du collaborateur.
          </p>

          <div className="grid grid-cols-1 gap-2 rounded-lg border border-ink-200 bg-white p-3 sm:grid-cols-2">
            {data.services
              .slice()
              .sort((a, b) =>
                (a.name ?? '').localeCompare(
                  b.name ?? '',
                  'fr-FR',
                  { sensitivity: 'base' }
                )
              )
              .map((service) => (
                <label
                  key={service.id}
                  className={`flex cursor-pointer items-center gap-2 rounded-md px-2 py-1.5 text-sm hover:bg-elyade-50 ${
                    serviceId === service.id
                      ? 'bg-elyade-50 text-elyade-800'
                      : 'text-ink-700'
                  }`}
                >
                  <input
                    type="checkbox"
                    checked={serviceId === service.id}
                    onChange={(e) =>
                      setServiceId(
                        e.target.checked
                          ? service.id
                          : ''
                      )
                    }
                  />

                  <span>{service.name}</span>
                </label>
              ))}
          </div>
        </div>"""

if old_service not in source:
    print("ERREUR : bloc Service actuel introuvable.")
    print("Aucune modification écrite.")
    sys.exit(1)

source = source.replace(old_service, new_service, 1)

# =========================================================
# 2. MATÉRIEL : remplacer les badges par des checkboxes
# =========================================================

old_hardware = """              <div>
                <label className="label">Matériel à attribuer</label>
                <div className="flex flex-wrap gap-2">
                  {trackedCats.map((c) => {
                    const checked = requestedHardware.includes(c.code);
                    return (
                      <button
                        key={c.id}
                        type="button"
                        onClick={() => setRequestedHardware((prev) => checked ? prev.filter((x) => x !== c.code) : [...prev, c.code])}
                        className={`badge cursor-pointer ${checked ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 border border-ink-200'}`}
                      >
                        {checked && <CheckCircle2 className="w-3 h-3" />}
                        {c.label}
                      </button>
                    );
                  })}
                </div>
              </div>"""

new_hardware = """              <div>
                <label className="label">
                  Matériel demandé
                </label>

                <div className="mt-2 grid grid-cols-1 gap-2 sm:grid-cols-2">
                  {trackedCats
                    .slice()
                    .sort((a, b) =>
                      (a.label ?? '').localeCompare(
                        b.label ?? '',
                        'fr-FR',
                        { sensitivity: 'base' }
                      )
                    )
                    .map((category) => {
                      const checked =
                        requestedHardware.includes(category.code);

                      return (
                        <label
                          key={category.id}
                          className="flex cursor-pointer items-center gap-2 text-sm text-ink-700"
                        >
                          <input
                            type="checkbox"
                            checked={checked}
                            onChange={(e) =>
                              setRequestedHardware((previous) =>
                                e.target.checked
                                  ? previous.includes(category.code)
                                    ? previous
                                    : [...previous, category.code]
                                  : previous.filter(
                                      (code) =>
                                        code !== category.code
                                    )
                              )
                            }
                          />

                          <span>{category.label}</span>
                        </label>
                      );
                    })}
                </div>
              </div>"""

if old_hardware not in source:
    print("ERREUR : bloc Matériel actuel introuvable.")
    print("Aucune modification écrite.")
    sys.exit(1)

source = source.replace(old_hardware, new_hardware, 1)

# =========================================================
# 3. LICENCES : localiser le bloc suivant et remplacer
# =========================================================

license_label = '<label className="label">Licences à attribuer</label>'
license_pos = source.find(license_label)

if license_pos == -1:
    print("ERREUR : libellé Licences à attribuer introuvable.")
    print("Aucune modification écrite.")
    sys.exit(1)

license_div_start = source.rfind(
    "              <div>",
    0,
    license_pos
)

if license_div_start == -1:
    print("ERREUR : début du bloc Licences introuvable.")
    print("Aucune modification écrite.")
    sys.exit(1)

# Trouver la fin du div qui contient le map des licences.
search_pos = license_pos
depth = 0
block_end = None

while search_pos < len(source):
    next_open = source.find("<div", search_pos)
    next_close = source.find("</div>", search_pos)

    if next_close == -1:
        break

    if next_open != -1 and next_open < next_close:
        depth += 1
        search_pos = source.find(">", next_open) + 1
    else:
        if depth == 0:
            block_end = next_close + len("</div>")
            break

        depth -= 1
        search_pos = next_close + len("</div>")

if block_end is None:
    print("ERREUR : fin du bloc Licences introuvable.")
    print("Aucune modification écrite.")
    sys.exit(1)

old_licenses = source[license_div_start:block_end]

if "data.licenseTypes" not in old_licenses:
    print("ERREUR : le bloc détecté ne contient pas data.licenseTypes.")
    print("Aucune modification écrite.")
    sys.exit(1)

new_licenses = """              <div>
                <label className="label">
                  Licences complémentaires
                </label>

                <p className="mb-2 text-xs text-ink-500">
                  Microsoft 365 Business Premium est ajouté automatiquement à chaque nouvel arrivant.
                </p>

                <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
                  {data.licenseTypes
                    .slice()
                    .sort((a, b) =>
                      (a.label ?? '').localeCompare(
                        b.label ?? '',
                        'fr-FR',
                        { sensitivity: 'base' }
                      )
                    )
                    .map((licenseType) => {
                      const checked =
                        requestedLicenses.includes(licenseType.code);

                      return (
                        <label
                          key={licenseType.id}
                          className="flex cursor-pointer items-center gap-2 text-sm text-ink-700"
                        >
                          <input
                            type="checkbox"
                            checked={checked}
                            onChange={(e) =>
                              setRequestedLicenses((previous) =>
                                e.target.checked
                                  ? previous.includes(licenseType.code)
                                    ? previous
                                    : [...previous, licenseType.code]
                                  : previous.filter(
                                      (code) =>
                                        code !== licenseType.code
                                    )
                              )
                            }
                          />

                          <span>{licenseType.label}</span>
                        </label>
                      );
                    })}
                </div>
              </div>"""

source = (
    source[:license_div_start]
    + new_licenses
    + source[block_end:]
)

FILE.write_text(source, encoding="utf-8")

print("OK : formulaire Nouvel onboarding modifié.")
print("  - Service affiché en cases à cocher")
print("  - Matériel affiché en cases à cocher")
print("  - Licences affichées en cases à cocher")
print("  - États et payload existants conservés")
