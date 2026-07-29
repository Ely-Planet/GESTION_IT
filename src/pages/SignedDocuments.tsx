import { useMemo, useState } from 'react';
import { Search, FileSignature } from 'lucide-react';
import { useData } from '../hooks/useData';

export default function SignedDocuments() {
  const data = useData();
  const [q, setQ] = useState('');
const [selectedDoc, setSelectedDoc] = useState<any>(null);
  const docs = useMemo(() => {
    return data.signedDocuments.filter((d) => {
      const text = `
        ${d.signer_name ?? ''}
        ${d.signer_email ?? ''}
      `
        .toLowerCase();

      return text.includes(q.toLowerCase());
    });
  }, [data.signedDocuments, q]);

  return (
    <div className="p-6 lg:p-8">

      <h1 className="text-2xl font-bold text-ink-900">
        Coffre-fort documentaire
      </h1>

      <p className="text-ink-500 mt-2">
        Consultation des documents signés.
      </p>

      <div className="mt-6 relative max-w-lg">
        <Search className="absolute left-3 top-3 w-4 h-4 text-ink-400" />

        <input
          className="input pl-10"
          placeholder="Rechercher un collaborateur..."
          value={q}
          onChange={(e) => setQ(e.target.value)}
        />
      </div>

      <div className="card mt-6 overflow-hidden">

        <table className="table-base">

          <thead>
            <tr>
              <th>Collaborateur</th>
              <th>Email</th>
              <th>Type</th>
              <th>Date</th>
              <th>Statut</th>
	      <th>Actions</th>

            </tr>
          </thead>

          <tbody>

            {docs.map((d) => (

              <tr key={d.id}>

                <td>{d.signer_name ?? '-'}</td>

                <td>{d.signer_email ?? '-'}</td>

                <td>
                  {d.doc_type === 'assignment'
                    ? 'Attribution'
                    : 'Restitution'}
                </td>

                <td>
                  {d.signed_at
                    ? new Date(d.signed_at).toLocaleDateString('fr-FR')
                    : '-'}
                </td>

                <td>
                  <span className="badge bg-green-50 text-green-700">
                    Signé
                  </span>
                </td>

<td>
  <button
    onClick={() => setSelectedDoc(d)}
    className="btn-ghost text-xs"
  >
    Consulter
  </button>
</td>

              </tr>

            ))}

          </tbody>

        </table>

{selectedDoc && (

  <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">

    <div className="bg-white rounded-xl p-6 w-full max-w-4xl max-h-[90vh] overflow-auto">

<div className="flex items-center justify-between mb-6">

  <h2 className="text-xl font-bold">
    Document signé
  </h2>

  <div className="flex items-center gap-2">

    <button
      onClick={() => window.print()}
      className="btn-primary"
    >
      Imprimer
    </button>

<button
  onClick={() => {
    window.open(
      `/api/signed-documents/${selectedDoc.id}/pdf`,
      '_blank'
    );
  }}
  className="btn-secondary"
>
  Télécharger PDF
</button>
<button
  onClick={async () => {
    const res = await fetch(
      `/api/signed-documents/${selectedDoc.id}/send-email`,
      {
        method: 'POST',
      }
    );

    if (!res.ok) {
      const err = await res.json().catch(() => ({
        error: 'Erreur envoi mail'
      }));

      alert(err.error ?? 'Erreur envoi mail');

      return;
    }

    alert('Document renvoyé par email.');
  }}
  className="btn-secondary"
>
  Renvoyer par mail
</button>

    <button
      onClick={() => setSelectedDoc(null)}
      className="btn-ghost"
    >
      Fermer
    </button>

  </div>

</div>
      <div className="space-y-4">

        <div>

          <h3 className="font-semibold">
            Signataire
          </h3>

          <p>
            {selectedDoc.signer_name}
          </p>

          <p className="text-sm text-ink-500">
            {selectedDoc.signer_email}
          </p>

        </div>

        <div>

          <h3 className="font-semibold">
            Date de signature
          </h3>

          <p>
            {new Date(
              selectedDoc.signed_at
            ).toLocaleString('fr-FR')}
          </p>

        </div>

        <div>

          <h3 className="font-semibold">
            Contenu du document
          </h3>

<div className="space-y-6">

  <div>
    <h3 className="font-semibold text-lg">
      Collaborateur
    </h3>

    <p>
      {String(
        selectedDoc.content_snapshot?.employee ?? '-'
      )}
    </p>
  </div>

  <div>
    <h3 className="font-semibold text-lg">
      Date d'effet
    </h3>

    <p>
      {selectedDoc.content_snapshot?.effective_date
        ? new Date(
            String(
              selectedDoc.content_snapshot.effective_date
            )
          ).toLocaleDateString('fr-FR')
        : '-'}
    </p>
  </div>

  <div>
    <h3 className="font-semibold text-lg mb-2">
      Matériel attribué
    </h3>

    <table className="table-base">

      <thead>
        <tr>
          <th>Catégorie</th>
          <th>Référence</th>
          <th>N° série</th>
        </tr>
      </thead>

      <tbody>

        {(
          selectedDoc.content_snapshot?.items as any[]
          ?? []
        ).map((item, i) => (

          <tr key={i}>
            <td>{item.category ?? '-'}</td>
            <td>{item.reference ?? '-'}</td>
            <td>{item.serial ?? '-'}</td>
          </tr>

        ))}

      </tbody>

    </table>
  </div>

  <div>
    <h3 className="font-semibold text-lg mb-2">
      Licences attribuées
    </h3>

    {(
      selectedDoc.content_snapshot?.licenses as any[]
      ?? []
    ).length === 0 ? (

      <p>Aucune licence attribuée</p>

    ) : (

      <ul>

        {(
          selectedDoc.content_snapshot?.licenses as any[]
          ?? []
        ).map((l, i) => (

          <li key={i}>
            {l.type}
            {l.seat ? ` (${l.seat})` : ''}
          </li>

        ))}

      </ul>

    )}
  </div>

</div>

        </div>

        {selectedDoc.signature_data && (

          <div>

            <h3 className="font-semibold mb-2">
              Signature
            </h3>

            <img
              src={selectedDoc.signature_data}
              alt="Signature"
              className="border rounded bg-white"
            />

          </div>

        )}

      </div>

    </div>

  </div>

)}
      </div>

    </div>
  );
}
