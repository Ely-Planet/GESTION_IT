import { useEffect, useState } from 'react';
import { projectsApi } from './api';
import type { DashboardData } from './types';

function BarRow({ label, value, max, highlight }: { label: string; value: number; max: number; highlight?: boolean }) {
  const pct = max > 0 ? Math.min(100, (value / max) * 100) : 0;
  return (
    <div className="mb-3">
      <div className="flex justify-between text-xs text-ink-600 mb-1">
        <span>{label}</span>
        <span>{value}h</span>
      </div>
      <div className="w-full bg-ink-100 rounded-full h-2.5">
        <div
          className={`h-2.5 rounded-full ${highlight ? 'bg-red-500' : 'bg-elyade-600'}`}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}

export default function DashboardView() {
  const [data, setData] = useState<DashboardData | null>(null);

  useEffect(() => {
    projectsApi.dashboard().then(setData);
  }, []);

  if (!data) return <div className="p-6 text-ink-500">Chargement...</div>;

  const maxProjectCharge = Math.max(1, ...data.chargeParProjet.map((p) => Math.max(p.chargeEstimeeH, p.chargePasseeH)));
  const maxTechCharge = Math.max(1, ...data.chargeParTechnicien.map((u) => Math.max(u.chargeEstimeeH, u.disponibilite)));

  return (
    <div className="p-6 max-w-5xl mx-auto space-y-6">
      <h1 className="text-xl font-semibold text-ink-900">Dashboard Projets IT</h1>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="card p-4">
          <p className="text-sm text-ink-500">Projets actifs</p>
          <p className="text-2xl font-semibold text-ink-900">{data.nombreTotalProjets}</p>
        </div>
        <div className="card p-4">
          <p className="text-sm text-ink-500">Demandes en attente</p>
          <p className="text-2xl font-semibold text-ink-900">{data.demandesEnAttente}</p>
        </div>
        <div className="card p-4">
          <p className="text-sm text-ink-500">Charge globale équipe</p>
          <p className="text-2xl font-semibold text-ink-900">{data.chargeGlobaleEquipeH}h</p>
        </div>
        <div className="card p-4">
          <p className="text-sm text-ink-500 mb-1">Répartition par statut</p>
          <div className="text-xs text-ink-600 space-y-0.5">
            {Object.entries(data.nbParStatut).map(([statut, n]) => (
              <div key={statut} className="flex justify-between">
                <span>{statut.replace('_', ' ')}</span>
                <span className="font-medium">{n}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="card p-5">
        <h2 className="font-semibold text-ink-900 mb-4">Charge horaire par projet (estimée)</h2>
        {data.chargeParProjet.map((p) => (
          <BarRow key={p.projetId} label={p.nom} value={p.chargeEstimeeH} max={maxProjectCharge} />
        ))}
      </div>

      <div className="card p-5">
        <h2 className="font-semibold text-ink-900 mb-4">Charge active par technicien / développeur</h2>
        {data.chargeParTechnicien.map((u) => (
          <BarRow key={u.userId} label={`${u.nom} (dispo. ${u.disponibilite}h)`} value={u.chargeEstimeeH} max={maxTechCharge} highlight={u.enSurcharge} />
        ))}
        <p className="text-xs text-ink-400 mt-1">En rouge : charge active supérieure à la disponibilité déclarée.</p>
      </div>

      <div className="card p-5">
        <h2 className="font-semibold text-ink-900 mb-4">Taux de complétude par projet</h2>
        <div className="space-y-3">
          {data.chargeParProjet.map((p) => (
            <div key={p.projetId}>
              <div className="flex justify-between text-sm text-ink-700 mb-1">
                <span>{p.nom}</span>
                <span>{p.tauxCompletude}%</span>
              </div>
              <div className="w-full bg-ink-100 rounded-full h-2">
                <div className="bg-elyade-600 h-2 rounded-full" style={{ width: `${p.tauxCompletude}%` }} />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
