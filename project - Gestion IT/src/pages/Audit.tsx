import { useData } from '../hooks/useData';
import { formatFrDateTime } from '../lib/format';
import { ScrollText, History } from 'lucide-react';

export default function Audit() {
  const data = useData();

  return (
    <div className="p-6 lg:p-8 max-w-5xl mx-auto">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-ink-900">Journal d'audit</h1>
        <p className="text-sm text-ink-500 mt-1">
          Traçabilité de toutes les actions effectuées dans l'application
        </p>
      </div>

      <div className="card overflow-hidden">
        {data.loading ? (
          <p className="p-8 text-center text-ink-500">Chargement…</p>
        ) : data.auditLog.length === 0 ? (
          <div className="p-8 text-center">
            <History className="w-8 h-8 text-ink-300 mx-auto mb-2" />
            <p className="text-sm text-ink-500">Aucune action enregistrée pour le moment.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="table-base">
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Acteur</th>
                  <th>Action</th>
                  <th>Entité</th>
                  <th>Détails</th>
                </tr>
              </thead>
              <tbody>
                {data.auditLog.map((l) => (
                  <tr key={l.id}>
                    <td className="whitespace-nowrap text-xs text-ink-600">{formatFrDateTime(l.created_at)}</td>
                    <td className="font-medium">{l.actor_name || '—'}</td>
                    <td>
                      <span className={`badge ${actionTone(l.action)}`}>{l.action}</span>
                    </td>
                    <td className="text-xs text-ink-600">{l.entity_type}</td>
                    <td className="text-xs text-ink-500 font-mono max-w-xs truncate">
                      {l.details ? JSON.stringify(l.details) : '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <div className="mt-4 flex items-start gap-2 text-xs text-ink-500">
        <ScrollText className="w-4 h-4 mt-0.5 text-elyade-600 shrink-0" />
        <p>
          Chaque création, modification ou suppression est automatiquement horodatée et attribuée
          à l'utilisateur authentifié. Ce journal est en lecture seule et ne peut être modifié.
        </p>
      </div>
    </div>
  );
}

function actionTone(action: string): string {
  if (action === 'create') return 'bg-green-50 text-green-700';
  if (action === 'delete') return 'bg-red-50 text-red-700';
  if (action === 'resiliate') return 'bg-red-50 text-red-700';
  if (action === 'assign' || action === 'release') return 'bg-elyade-50 text-elyade-700';
  return 'bg-ink-100 text-ink-600';
}
