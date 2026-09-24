import { useEffect, useState } from 'react';
import { projectsApi } from './api';
import { ProgressBar, StatusBadge } from './ProjectUI';
import type { ReportingRow } from './types';

export default function ReportingView() {
  const [rows, setRows] = useState<ReportingRow[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    projectsApi.reporting().then(setRows).finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="p-6 text-ink-500">Chargement...</div>;

  return (
    <div className="p-6 max-w-5xl mx-auto">
      <h1 className="text-xl font-semibold text-ink-900 mb-4">Reporting projets (lecture seule)</h1>
      <div className="card overflow-x-auto">
        <table className="table-base">
          <thead>
            <tr>
              <th>Projet</th>
              <th>Client</th>
              <th>Statut</th>
              <th>Complétude</th>
              <th>Charge (h)</th>
              <th>Échéance</th>
              <th>Retard</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.id}>
                <td className="font-medium text-ink-900">{r.nom}</td>
                <td>{r.client || '—'}</td>
                <td>
                  <StatusBadge status={r.statut} />
                </td>
                <td className="w-40">
                  <div className="flex items-center gap-2">
                    <ProgressBar value={r.tauxCompletude} />
                    <span className="text-xs">{r.tauxCompletude}%</span>
                  </div>
                </td>
                <td>{r.chargeHoraireH}h</td>
                <td>{r.dateEcheance ? new Date(r.dateEcheance).toLocaleDateString('fr-FR') : '—'}</td>
                <td>
                  {r.enRetard ? (
                    <span className="badge bg-red-100 text-red-700">En retard</span>
                  ) : (
                    <span className="badge bg-emerald-100 text-emerald-700">OK</span>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {rows.length === 0 && <p className="text-sm text-ink-500 p-4">Aucun projet actif.</p>}
      </div>
    </div>
  );
}
