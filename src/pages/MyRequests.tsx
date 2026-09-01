import { useEffect, useState } from 'react';
import { useAuth } from '../context/AuthContext';

export default function MyRequests() {
const { user } = useAuth();  
const [rows, setRows] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
const [selectedRequest, setSelectedRequest] =
  useState<any | null>(null);

const [showDetails, setShowDetails] =
  useState(false);


  useEffect(() => {
    loadData();
  }, []);

async function viewRequest(id: string) {

  const res = await fetch(
    `/api/my-onboarding-requests/${id}`,
    {
      credentials: 'include'
    }
  );

  const data = await res.json();

  setSelectedRequest(data);

  setShowDetails(true);
}

async function resendRequest(id: string) {

  const res = await fetch(
    `/api/my-onboarding-requests/${id}/resend`,
    {
      method: 'POST',
      credentials: 'include'
    }
  );

  if (!res.ok) {
    alert('Erreur lors du renvoi');
    return;
  }

  alert('✅ Mail renvoyé au service RH');
}



  async function loadData() {
    try {

const res = await fetch(
  '/api/my-onboarding-requests',
  {
    credentials: 'include'
  }
);

      const data = await res.json();

      setRows(data);
    } finally {
      setLoading(false);
    }
  }


async function markAsNotHired(
  id: string
) {

  if (
    !confirm(
      'Marquer comme non embauché ?'
    )
  ) {
    return;
  }

  const res = await fetch(
    `/api/my-onboarding-requests/${id}/not-hired`,
{

credentials: 'include',
      method: 'POST'
    }
  );

  if (!res.ok) {
    alert('Erreur');
    return;
  }

  loadData();
}




    


if (loading) {

return (
      <div className="p-6">
        Chargement...
      </div>
    );
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-semibold mb-6">
        Mes demandes
      </h1>

      <div className="bg-white rounded-xl shadow overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b">
              <th className="text-left p-3">
                Collaborateur
              </th>

              <th className="text-left p-3">
                Date arrivée
              </th>

              <th className="text-left p-3">
                Statut
              </th>
            
<th className="text-left p-3">
  Actions
</th>

</tr>
          </thead>

          <tbody>
            {rows.map((row) => (
              <tr
                key={row.id}
                className="border-b"
              >
                <td className="p-3">
                  {row.first_name} {row.last_name}
                </td>

                <td className="p-3">
                  {new Date(
                    row.effective_date
                  ).toLocaleDateString(
                    'fr-FR'
                  )}
                </td>

                <td className="p-3">
                  {row.status ===
                  'non_embauche'
                    ? '❌ Non embauché'
                    : '📤 Envoyé'}
                </td>

<td className="p-3">
  <div className="flex gap-2">


<button
title="Consulter la demande"  
className="btn-ghost text-xl"
  onClick={() =>
    viewRequest(row.id)
  }
>
  👁
</button>


<button
title="Renvoyer la demande au service RH"
  className="btn-ghost text-xl"
  onClick={() =>
    resendRequest(row.id)
  }
>
  📧
</button>


{user?.isRH && (
  <button
title="Marquer comme non embauché"
    className="btn-ghost text-orange-600"
    onClick={() =>
      markAsNotHired(row.id)
    }
  >
    ❌
  </button>
)}


  </div>
</td>

              </tr>
            ))}
          </tbody>
        </table>
      </div>
{showDetails && selectedRequest && (
  <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">

    <div className="bg-white rounded-xl p-6 w-[700px] max-h-[80vh] overflow-auto">

      <h2 className="text-xl font-semibold mb-4">
        Détail de la demande
      </h2>

      <div className="space-y-2">

        <p>
          <strong>Collaborateur :</strong>{' '}
          {selectedRequest.first_name}
          {' '}
          {selectedRequest.last_name}
        </p>

        <p>
          <strong>Date arrivée :</strong>{' '}
          {new Date(
            selectedRequest.effective_date
          ).toLocaleDateString('fr-FR')}
        </p>

        <p>
          <strong>Contrat :</strong>{' '}
          {selectedRequest.contract_type || '-'}
        </p>

        <p>
          <strong>Statut salarié :</strong>{' '}
          {selectedRequest.employee_status || '-'}
        </p>

        <p>
          <strong>Niveau :</strong>{' '}
          {selectedRequest.employee_level || '-'}
        </p>

        <p>
          <strong>Salaire annuel :</strong>{' '}
          {selectedRequest.gross_annual_salary || '-'}
        </p>

        <p>
          <strong>Prime :</strong>{' '}
          {selectedRequest.variable_bonus || '-'}
        </p>

        <p>
          <strong>Référent :</strong>{' '}
          {selectedRequest.referral_employee || '-'}
        </p>

        <p>
          <strong>Voiture de fonction :</strong>{' '}
          {selectedRequest.company_car
            ? 'Oui'
            : 'Non'}
        </p>

        <p>
          <strong>Statut :</strong>{' '}
          {selectedRequest.status}
        </p>

      </div>

      <div className="mt-6 text-right">

        <button
          className="btn-primary"
          onClick={() =>
            setShowDetails(false)
          }
        >
          Fermer
        </button>

      </div>

    </div>

  </div>
)}
</div>
);
}
