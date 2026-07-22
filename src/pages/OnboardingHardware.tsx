import { useEffect, useState } from 'react';

type HardwareCategory = {
  id: string;
  code: string;
  label: string;
  requestable_for_onboarding: boolean;
};

export default function OnboardingHardware() {
  const [rows, setRows] = useState<HardwareCategory[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    const res = await fetch('/api/onboarding-hardware-categories');
    const data = await res.json();

    setRows(data);
    setLoading(false);
  }

  async function toggle(item: HardwareCategory) {
    await fetch(
      `/api/onboarding-hardware-categories/${item.id}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          requestable_for_onboarding:
            !item.requestable_for_onboarding
        })
      }
    );

    load();
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="p-6 lg:p-8 max-w-5xl mx-auto">
      <h1 className="text-2xl font-bold text-ink-900">
        Matériel Onboarding
      </h1>

      <p className="text-sm text-ink-500 mt-2">
        Sélectionnez les matériels pouvant être demandés
        par les managers lors d'un onboarding.
      </p>

      {loading ? (
        <p className="mt-4">Chargement...</p>
      ) : (
        <div className="card overflow-hidden mt-6">
          <table className="table-base">
            <thead>
              <tr>
                <th>Matériel</th>
                <th>Visible dans le formulaire</th>
              </tr>
            </thead>

            <tbody>
              {rows.map((row) => (
                <tr key={row.id}>
                  <td>
                    <div>
                      <div className="font-medium text-ink-900">
                        {row.label}
                      </div>

                      <div className="text-xs text-ink-400">
                        {row.code}
                      </div>
                    </div>
                  </td>

                  <td>
                    <input
                      type="checkbox"
                      checked={row.requestable_for_onboarding}
                      onChange={() => toggle(row)}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
