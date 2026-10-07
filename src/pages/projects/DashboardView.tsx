import { useEffect, useState } from 'react';
import { projectsApi } from './api';
import TimeByMonth from './TimeByMonth';
import WorkloadPanel from './WorkloadPanel';
import type { DashboardData } from './types';

export default function DashboardView() {
  const [data, setData] = useState<DashboardData | null>(null);

  useEffect(() => {
    projectsApi.dashboard().then(setData);
  }, []);

  if (!data) return <div className="p-6 text-ink-500">Chargement...</div>;

  const maxProjectCharge = Math.max(1, ...data.chargeParProjet.map((p) => Math.max(p.chargeEstimeeH, p.chargePasseeH)));

  return (
    <div className="p-6 w-full max-w-[1800px] mx-auto space-y-6">
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
          <p className="text-sm text-ink-500">Reste à faire équipe</p>
          <p className="text-2xl font-semibold text-ink-900">{data.resteAFaireH}h</p>
          <p className="text-xs text-ink-400 mt-0.5">
            Estimé − temps passé des tâches actives
            {data.nonAffecteH > 0 && <> · dont {data.nonAffecteH}h non affectées</>}
          </p>
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
        <div className="flex flex-wrap items-center justify-between gap-2 mb-4">
          <h2 className="font-semibold text-ink-900">Temps par projet : estimé et réel (depuis le début du projet)</h2>
          <div className="flex items-center gap-4 text-xs text-ink-500">
            <span className="flex items-center gap-1"><span className="w-3 h-2 rounded-full bg-elyade-200" /> Estimé</span>
            <span className="flex items-center gap-1"><span className="w-3 h-2 rounded-full bg-elyade-600" /> Réel</span>
            <span className="flex items-center gap-1"><span className="w-3 h-2 rounded-full bg-red-500" /> Réel &gt; estimé</span>
          </div>
        </div>
        {data.chargeParProjet.length === 0 && <p className="text-sm text-ink-500">Aucun projet actif.</p>}
        {data.chargeParProjet.map((p) => {
          const over = p.chargePasseeH > p.chargeEstimeeH;
          return (
            <div key={p.projetId} className="mb-4">
              <div className="flex justify-between text-xs text-ink-600 mb-1">
                <span className="font-medium text-ink-800">{p.nom}</span>
                <span className={over ? 'text-red-600 font-medium' : ''}>
                  Réel {p.chargePasseeH}h / estimé {p.chargeEstimeeH}h
                </span>
              </div>
              <div className="w-full bg-ink-100 rounded-full h-2 mb-1">
                <div className="h-2 rounded-full bg-elyade-200" style={{ width: `${(p.chargeEstimeeH / maxProjectCharge) * 100}%` }} />
              </div>
              <div className="w-full bg-ink-100 rounded-full h-2">
                <div
                  className={`h-2 rounded-full ${over ? 'bg-red-500' : 'bg-elyade-600'}`}
                  style={{ width: `${(p.chargePasseeH / maxProjectCharge) * 100}%` }}
                />
              </div>
            </div>
          );
        })}
      </div>

      <WorkloadPanel />

      <TimeByMonth rows={data.tempsParMois || []} />

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
