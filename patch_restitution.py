from pathlib import Path
from datetime import datetime
import re
import shutil
import subprocess
import sys

FILE = Path("server/index.mjs")

if not FILE.exists():
    print("ERREUR : server/index.mjs introuvable.")
    sys.exit(1)

source = FILE.read_text(encoding="utf-8")

START_MARKER = "// AUTO-RESTITUTION-MATERIEL-START"
END_MARKER = "// AUTO-RESTITUTION-MATERIEL-END"

if START_MARKER in source:
    print("Le correctif est déjà présent. Aucune modification effectuée.")
    sys.exit(0)

route_marker = "app.post('/api/signed-documents'"

route_start = source.find(route_marker)

if route_start == -1:
    print("ERREUR : route POST /api/signed-documents introuvable.")
    sys.exit(1)

next_route = source.find("\napp.", route_start + len(route_marker))

if next_route == -1:
    route_end = len(source)
else:
    route_end = next_route

route_content = source[route_start:route_end]

# Détection automatique de l'objet utilisé pour faire les requêtes SQL.
# Exemples attendus : pool.query(...), db.query(...), client.query(...)
query_objects = re.findall(r"\b([A-Za-z_$][A-Za-z0-9_$]*)\.query\s*\(", route_content)

preferred_objects = ["client", "pool", "db"]

db_object = None

for candidate in preferred_objects:
    if candidate in query_objects:
        db_object = candidate
        break

if not db_object and query_objects:
    db_object = query_objects[0]

if not db_object:
    print("ERREUR : impossible de déterminer l'objet SQL utilisé dans la route.")
    print("Objets détectés :", query_objects)
    sys.exit(1)

print(f"Objet SQL détecté : {db_object}")

def run_psql(sql):
    command = [
        "docker", "exec", "gestion_it_postgres",
        "psql", "-U", "gestion_it", "-d", "gestion_it",
        "-At", "-c", sql
    ]

    try:
        result = subprocess.run(
            command,
            check=True,
            text=True,
            capture_output=True
        )
        return [line.strip() for line in result.stdout.splitlines() if line.strip()]
    except Exception as exc:
        print(f"ATTENTION : vérification PostgreSQL impossible : {exc}")
        return []

statuses = run_psql(
    "SELECT DISTINCT status::text FROM hardware_items "
    "WHERE status IS NOT NULL ORDER BY 1;"
)

print("Statuts matériels détectés :", statuses or "non détectés")

stock_candidates = [
    "in_stock",
    "stock",
    "en_stock",
    "available",
    "disponible"
]

reinstall_candidates = [
    "reinstalling",
    "reinstallation",
    "in_reinstallation",
    "en_reinstallation",
    "to_reinstall",
    "a_reinstaller"
]

stock_status = next(
    (status for status in stock_candidates if status in statuses),
    None
)

reinstall_status = next(
    (status for status in reinstall_candidates if status in statuses),
    None
)

if stock_status is None:
    print("")
    print("ERREUR : statut correspondant à un matériel en stock non trouvé.")
    print("Statuts disponibles :", statuses)
    print("Le fichier n'a pas été modifié.")
    sys.exit(1)

if reinstall_status is None:
    print("")
    print("ERREUR : statut correspondant à une réinstallation non trouvé.")
    print("Statuts disponibles :", statuses)
    print("Le fichier n'a pas été modifié.")
    sys.exit(1)

print(f"Statut stock retenu : {stock_status}")
print(f"Statut réinstallation retenu : {reinstall_status}")

# On insère le traitement juste après l'ouverture du try de la route.
try_match = re.search(r"\btry\s*\{", route_content)

if not try_match:
    print("ERREUR : bloc try introuvable dans la route.")
    sys.exit(1)

insert_position = route_start + try_match.end()

patch = f"""

    {START_MARKER}
    /*
     * Lors de la signature d'une restitution :
     * 1. retrouve le collaborateur du mouvement ;
     * 2. clôture toutes ses affectations actives ;
     * 3. remet les périphériques et autres matériels en stock ;
     * 4. place les PC fixes et PC portables en réinstallation.
     */
    if (
      req.body?.doc_type === 'restitution' &&
      req.body?.movement_id
    ) {{
      const restitutionMovementResult = await {db_object}.query(
        `
        SELECT employee_id
        FROM movements
        WHERE id = $1
        LIMIT 1
        `,
        [req.body.movement_id]
      );

      const restitutionEmployeeId =
        restitutionMovementResult.rows[0]?.employee_id;

      if (!restitutionEmployeeId) {{
        throw new Error(
          'Collaborateur introuvable pour le mouvement de restitution'
        );
      }}

      /*
       * On récupère et clôture en une seule opération toutes les
       * affectations encore actives du collaborateur.
       */
      const returnedAssignmentsResult = await {db_object}.query(
        `
        UPDATE assignments
        SET
          returned_at = NOW(),
          restitution_status = 'done',
          updated_at = NOW()
        WHERE employee_id = $1
          AND returned_at IS NULL
        RETURNING hardware_item_id
        `,
        [restitutionEmployeeId]
      );

      const returnedHardwareIds =
        returnedAssignmentsResult.rows.map(
          (row) => row.hardware_item_id
        );

      if (returnedHardwareIds.length > 0) {{
        /*
         * La catégorie est identifiée à partir de son code ou de son
         * libellé. Cela couvre notamment :
         * PC fixe, PC portable, ordinateur fixe et ordinateur portable.
         */
        await {db_object}.query(
          `
          UPDATE hardware_items h
          SET
            status = CASE
              WHEN (
                (
                  LOWER(COALESCE(hc.code, '')) LIKE '%pc%'
                  OR LOWER(COALESCE(hc.label, '')) LIKE '%pc%'
                  OR LOWER(COALESCE(hc.code, '')) LIKE '%ordinateur%'
                  OR LOWER(COALESCE(hc.label, '')) LIKE '%ordinateur%'
                )
                AND (
                  LOWER(COALESCE(hc.code, '')) LIKE '%portable%'
                  OR LOWER(COALESCE(hc.label, '')) LIKE '%portable%'
                  OR LOWER(COALESCE(hc.code, '')) LIKE '%fixe%'
                  OR LOWER(COALESCE(hc.label, '')) LIKE '%fixe%'
                )
              )
              THEN '{reinstall_status}'
              ELSE '{stock_status}'
            END,
            updated_at = NOW()
          FROM hardware_categories hc
          WHERE hc.id = h.category_id
            AND h.id = ANY($1::uuid[])
          `,
          [returnedHardwareIds]
        );
      }}

      console.log(
        `[RESTITUTION] ${{returnedHardwareIds.length}} matériel(s) restitué(s) ` +
        `pour le collaborateur ${{restitutionEmployeeId}}`
      );
    }}
    {END_MARKER}
"""

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
backup = FILE.with_name(f"index.mjs.bak-restitution-{timestamp}")

shutil.copy2(FILE, backup)

updated_source = (
    source[:insert_position]
    + patch
    + source[insert_position:]
)

FILE.write_text(updated_source, encoding="utf-8")

print("")
print("Correctif inséré avec succès.")
print(f"Sauvegarde créée : {backup}")
print(f"Fichier modifié : {FILE}")
print("")
print("Résumé :")
print("- toutes les affectations actives sont clôturées ;")
print("- les autres matériels reviennent en stock ;")
print("- les PC fixes et portables passent en réinstallation ;")
print("- le traitement se déclenche uniquement pour doc_type=restitution.")
