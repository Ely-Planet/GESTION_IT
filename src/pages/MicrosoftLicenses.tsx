import { useEffect, useState } from 'react';

type Filter = {
  sku_part_number: string;
  enabled: boolean;
};

const LABELS: Record<string, string> = {
  O365_BUSINESS_PREMIUM: 'Microsoft 365 Business Standard',
  SPB: 'Microsoft 365 Business Premium',
  Microsoft_365_Copilot: 'Microsoft 365 Copilot',
  POWER_BI_PRO: 'Power BI Pro',
  POWER_BI_STANDARD: 'Power BI Standard',
  EXCHANGESTANDARD: 'Exchange Online Plan 1',
  POWERAPPS_DEV: 'Power Apps Developer',
  POWERAPPS_VIRAL: 'Power Apps Viral',
  Power_Pages_vTrial_for_Makers: 'Power Pages vTrial pour les créateurs',
  FLOW_FREE: 'Power Automate Free',
  'Teams_Premium_(for_Departments)': 'Teams Premium',
  WINDOWS_STORE: 'Windows Store',
  RIGHTSMANAGEMENT_ADHOC: 'Azure Rights Management',
  CCIBOTS_PRIVPREV_VIRAL: 'Copilot Studio Preview',
  SPZA_IW: 'SharePoint Zone App'
};

export default function MicrosoftLicenses() {
  const [rows, setRows] = useState<Filter[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    const res = await fetch('/api/microsoft-license-filters');
    const data = await res.json();

    setRows(data);
    setLoading(false);
  }

  async function toggle(item: Filter) {
    await fetch(
      `/api/microsoft-license-filters/${encodeURIComponent(item.sku_part_number)}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          enabled: !item.enabled
        })
      }
    );

    load();
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="p-6 lg:p-8 max-w-6xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-ink-900">
          Licences Microsoft
        </h1>

        <p className="text-sm text-ink-500 mt-1">
          Sélectionnez les licences Microsoft qui seront synchronisées dans
          l'application.
        </p>
      </div>

      {loading ? (
        <p>Chargement...</p>
      ) : (
        <div className="card overflow-hidden">
          <table className="table-base">
            <thead>
              <tr>
                <th>Licence Microsoft</th>
                <th>Synchronisation</th>
              </tr>
            </thead>

            <tbody>
              {rows.map((row) => (
                <tr key={row.sku_part_number}>
                  <td>
                    <div>
                      <div className="font-medium text-ink-900">
                        {LABELS[row.sku_part_number] ??
                          row.sku_part_number}
                      </div>

                      <div className="text-xs text-ink-400">
                        {row.sku_part_number}
                      </div>
                    </div>
                  </td>

                  <td>
                    <input
                      type="checkbox"
                      checked={row.enabled}
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
