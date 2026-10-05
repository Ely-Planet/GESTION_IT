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
        <div className="flex flex-wrap items-center justify-between gap-2 mb-4">
          <h2 className="font-semibold text-ink-900">Temps par projet : estimé et réel</h2>
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

      <div className="card p-5">
        <h2 className="font-semibold text-ink-900 mb-4">Charge active par technicien / développeur</h2>
        {data.chargeParTechnicien.length === 0 && <p className="text-sm text-ink-500">Aucun membre du service IT.</p>}
        <div className="space-y-5">
          {data.chargeParTechnicien.map((u) => (
            <div key={u.userId} className="border-b border-ink-100 pb-4 last:border-0 last:pb-0">
              <div className="flex flex-wrap items-center gap-2 mb-1">
                <span className="font-medium text-ink-900">{u.nom}</span>
                <span className="badge bg-ink-100 text-ink-700">
                  {u.nbProjets} projet{u.nbProjets > 1 ? 's' : ''}
                </span>
              </div>
              <BarRow
                label={`Charge active (dispo. ${u.disponibilite}h)`}
                value={u.chargeEstimeeH}
                max={maxTechCharge}
                highlight={u.enSurcharge}
              />
              {u.chargeParProjet.length > 0 ? (
                <table className="w-full text-xs text-ink-600">
                  <thead>
                    <tr className="text-ink-400">
                      <th className="text-left font-normal pb-1">Projet</th>
                      <th className="text-right font-normal pb-1">Tâches actives</th>
                      <th className="text-right font-normal pb-1">Estimé</th>
                      <th className="text-right font-normal pb-1">Réel</th>
                    </tr>
                  </thead>
                  <tbody>
                    {u.chargeParProjet.map((p) => (
                      <tr key={p.projetId} className="border-t border-ink-50">
                        <td className="py-1">{p.nom}</td>
                        <td className="py-1 text-right">{p.nbTaches}</td>
                        <td className="py-1 text-right">{p.chargeEstimeeH}h</td>
                        <td className={`py-1 text-right ${p.chargePasseeH > p.chargeEstimeeH ? 'text-red-600 font-medium' : ''}`}>{p.chargePasseeH}h</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              ) : (
                <p className="text-xs text-ink-400">Aucune tâche active affectée.</p>
              )}
            </div>
          ))}
        </div>
        <p className="text-xs text-ink-400 mt-3">En rouge : charge active supérieure à la disponibilité déclarée, ou temps réel supérieur à l'estimé.</p>
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
