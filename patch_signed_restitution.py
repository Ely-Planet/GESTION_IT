from pathlib import Path
from datetime import datetime
import shutil
import sys

file_path = Path("server/index.mjs")

if not file_path.exists():
    print("ERREUR : server/index.mjs est introuvable.")
    sys.exit(1)

source = file_path.read_text(encoding="utf-8")

start_marker = "app.post('/api/signed-documents', async (req, res) => {"
end_marker = "app.get('/api/signed-documents/:id/pdf', async (req, res) => {"

start = source.find(start_marker)
end = source.find(end_marker, start)

if start == -1:
    print("ERREUR : route POST /api/signed-documents introuvable.")
    sys.exit(1)

if end == -1:
    print("ERREUR : route GET du PDF introuvable.")
    sys.exit(1)

if "RESTITUTION-AUTOMATIQUE-MATERIEL" in source[start:end]:
    print("Le correctif est déjà installé. Aucune modification effectuée.")
    sys.exit(0)

new_route = r"""app.post('/api/signed-documents', async (req, res) => {
  const client = await pool.connect();

  try {
    const allowedColumns = [
      'movement_id',
      'doc_type',
      'signer_name',
      'signer_email',
      'signed_at',
      'signature_data',
      'status',
      'content_snapshot'
    ];

    const columns = allowedColumns.filter(
      (column) => req.body[column] !== undefined
    );

    if (
      !columns.includes('movement_id') ||
      !columns.includes('doc_type')
    ) {
      return res.status(400).json({
        error: 'movement_id et doc_type sont obligatoires.'
      });
    }

    await client.query('BEGIN');

    const values = columns.map((column) => req.body[column]);
    const placeholders = columns.map(
      (_, index) => `$${index + 1}`
    );

    const result = await client.query(
      `
      INSERT INTO signed_documents (${columns.join(', ')})
      VALUES (${placeholders.join(', ')})
      RETURNING *
      `,
      values
    );

    const createdDocument = result.rows[0];

    /*
     * RESTITUTION-AUTOMATIQUE-MATERIEL
     *
     * Quand une fiche de restitution est signée :
     * - toutes les affectations actives du collaborateur sont clôturées ;
     * - les PC fixes et portables passent en being_reinstalled ;
     * - les autres matériels passent en in_stock.
     */
    if (createdDocument.doc_type === 'restitution') {
      const movementResult = await client.query(
        `
        SELECT
          id,
          employee_id,
          type
        FROM movements
        WHERE id = $1
        FOR UPDATE
        `,
        [createdDocument.movement_id]
      );

      if (movementResult.rowCount === 0) {
        throw new Error(
          'Mouvement introuvable pour la fiche de restitution.'
        );
      }

      const movement = movementResult.rows[0];

      if (!movement.employee_id) {
        throw new Error(
          'Aucun collaborateur associé au mouvement de restitution.'
        );
      }

      if (movement.type !== 'offboarding') {
        throw new Error(
          `Une restitution ne peut être traitée que pour un offboarding. Type reçu : ${movement.type}`
        );
      }

      /*
       * On verrouille les affectations actives avant de les modifier.
       */
      const activeAssignmentsResult = await client.query(
        `
        SELECT
          a.id,
          a.hardware_item_id
        FROM assignments a
        WHERE a.employee_id = $1
          AND a.returned_at IS NULL
        FOR UPDATE
        `,
        [movement.employee_id]
      );

      const hardwareIds = activeAssignmentsResult.rows.map(
        (row) => row.hardware_item_id
      );

      if (hardwareIds.length > 0) {
        /*
         * Clôture des affectations actives.
         */
        await client.query(
          `
          UPDATE assignments
          SET
            returned_at = NOW(),
            restitution_status = 'done',
            updated_at = NOW()
          WHERE employee_id = $1
            AND returned_at IS NULL
          `,
          [movement.employee_id]
        );

        /*
         * PC Fixe et PC Portable :
         * status = being_reinstalled
         *
         * Tous les autres matériels :
         * status = in_stock
         */
        await client.query(
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
                AND
                (
                  LOWER(COALESCE(hc.code, '')) LIKE '%fixe%'
                  OR LOWER(COALESCE(hc.label, '')) LIKE '%fixe%'
                  OR LOWER(COALESCE(hc.code, '')) LIKE '%portable%'
                  OR LOWER(COALESCE(hc.label, '')) LIKE '%portable%'
                )
              )
                THEN 'being_reinstalled'
              ELSE 'in_stock'
            END,
            updated_at = NOW()
          FROM hardware_categories hc
          WHERE hc.id = h.category_id
            AND h.id = ANY($1::uuid[])
          `,
          [hardwareIds]
        );

        console.log(
          `[RESTITUTION] ${hardwareIds.length} matériel(s) restitué(s) ` +
          `pour l'employé ${movement.employee_id}`
        );
      } else {
        console.log(
          `[RESTITUTION] Aucune affectation active pour l'employé ` +
          `${movement.employee_id}`
        );
      }
    }

    await client.query('COMMIT');

    /*
     * Le PDF et l'email sont générés après validation en base.
     * Une erreur d'email ne remet pas en cause la restitution signée.
     */
    try {
      await getOrCreateSignedDocumentPdf(createdDocument.id);

      if (createdDocument.signer_email) {
        await sendSignedDocumentMail(createdDocument.id);
      }
    } catch (mailOrPdfError) {
      console.error(
        'Erreur PDF / email après signature',
        mailOrPdfError
      );

      await pool.query(
        `
        UPDATE signed_documents
        SET email_error = $1
        WHERE id = $2
        `,
        [
          mailOrPdfError.message,
          createdDocument.id
        ]
      ).catch(console.error);
    }

    res.status(201).json(createdDocument);

  } catch (error) {
    await client.query('ROLLBACK').catch(console.error);

    console.error(
      'Erreur lors de la création du document signé',
      error
    );

    res.status(500).json({
      error: error.message
    });

  } finally {
    client.release();
  }
});

"""

timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
backup_path = file_path.with_name(
    f"index.mjs.bak-before-restitution-{timestamp}"
)

shutil.copy2(file_path, backup_path)

updated_source = source[:start] + new_route + source[end:]

file_path.write_text(updated_source, encoding="utf-8")

print("")
print("CORRECTIF INSTALLE")
print(f"Sauvegarde : {backup_path}")
print(f"Fichier modifié : {file_path}")
print("")
print("Comportement ajouté :")
print("- uniquement pour doc_type = restitution")
print("- vérification que le mouvement est un offboarding")
print("- clôture des affectations actives")
print("- PC fixe et portable -> being_reinstalled")
print("- autres matériels -> in_stock")
print("- transaction PostgreSQL avec rollback en cas d'erreur")
