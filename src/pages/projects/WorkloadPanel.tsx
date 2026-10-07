import { useEffect, useState } from 'react';
import { AlertTriangle, CalendarOff, ChevronLeft, ChevronRight } from 'lucide-react';
import { projectsApi } from './api';
import { formatDay } from './ProjectUI';
import type { WorkloadData, WorkloadPeriod } from './types';

const PERIODS: [WorkloadPeriod, string][] = [
  ['week', 'Semaine'],
  ['month', 'Mois'],
  ['year', 'Année'],
];

// Charge active par technicien sur la période choisie, comparée à sa capacité
// (35 h / semaine par défaut, jours fériés et congés Outlook déduits).
export default function WorkloadPanel() {
  const [period, setPeriod] = useState<WorkloadPeriod>('week');
  const [date, setDate] = useState<string | null>(null);
  const [data, setData] = useState<WorkloadData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);
    projectsApi
      .workload(period, date)
      .then((result: WorkloadData) => !cancelled && setData(result))
      .catch((err: Error) => !cancelled && setError(err.message))
      .finally(() => !cancelled && setLoading(false));
    return () => {
      cancelled = true;
    };
  }, [period, date]);

  const max = data
    ? Math.max(1, ...data.techniciens.map((t) => Math.max(t.chargeH, t.capaciteBruteH)))
    : 1;

  return (
    <div className="card p-5">
      <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
        <h2 className="font-semibold text-ink-900">Charge active par technicien / développeur</h2>
        <div className="flex flex-wrap items-center gap-2">
          <div className="flex rounded-lg border border-ink-200 overflow-hidden">
            {PERIODS.map(([key, label]) => (
              <button
                key={key}
                type="button"
                onClick={() => { setPeriod(key); setDate(null); }}
                className={`px-3 py-1.5 text-sm ${period === key ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 hover:bg-ink-50'}`}
              >
                {label}
              </button>
            ))}
          </div>
          <div className="flex items-center gap-1">
            <button type="button" className="btn-ghost p-1.5" aria-label="Période précédente" disabled={!data} onClick={() => data && setDate(data.precedente)}>
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="text-sm font-medium text-ink-800 min-w-[13rem] text-center">{data?.libelle ?? '…'}</span>
            <button type="button" className="btn-ghost p-1.5" aria-label="Période suivante" disabled={!data} onClick={() => data && setDate(data.suivante)}>
              <ChevronRight className="w-4 h-4" />
            </button>
            {data && !data.contientAujourdhui && (
              <button type="button" className="btn-ghost text-xs" onClick={() => setDate(null)}>Aujourd'hui</button>
            )}
          </div>
        </div>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}
      {loading && !data && <p className="text-sm text-ink-500">Chargement…</p>}

      {data && (
        <div className={loading ? 'opacity-60' : ''}>
          <p className="text-xs text-ink-500 mb-3">
            {data.joursOuvres} jour{data.joursOuvres > 1 ? 's' : ''} ouvré{data.joursOuvres > 1 ? 's' : ''} (hors week-ends et jours fériés)
            · base 35 h / semaine (7 h par jour ouvré) ou capacité déclarée du technicien, congés Outlook déduits.
          </p>
          {data.calendrierErreur && (
            <div className="flex items-start gap-2 text-xs text-amber-800 bg-amber-50 rounded-lg p-2.5 mb-4">
              <AlertTriangle className="w-4 h-4 shrink-0" />
              <span>Congés non pris en compte : {data.calendrierErreur}</span>
            </div>
          )}
          {data.techniciens.length === 0 && <p className="text-sm text-ink-500">Aucun membre du service IT.</p>}

          <div className="space-y-5">
            {data.techniciens.map((t) => {
              const loadPct = (t.chargeH / max) * 100;
              const capacityPct = (t.capaciteH / max) * 100;
              return (
                <div key={t.userId} className="border-b border-ink-100 pb-4 last:border-0 last:pb-0">
                  <div className="flex flex-wrap items-center justify-between gap-2 mb-1.5">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="font-medium text-ink-900">{t.nom}</span>
                      {t.joursConges > 0 && (
                        <span
                          className="badge bg-sky-50 text-sky-700"
                          title={t.conges.map((c) => `${formatDay(c.date)} : ${c.heures} h${c.motif ? ` (${c.motif})` : ''}`).join('\n')}
                        >
                          <CalendarOff className="w-3 h-3" /> {t.joursConges} j de congés
                        </span>
                      )}
                      {t.calendrierErreur && !data.calendrierErreur && (
                        <span className="badge bg-amber-50 text-amber-700" title="Congés non pris en compte pour cette personne">
                          Calendrier : {t.calendrierErreur}
                        </span>
                      )}
                    </div>
                    <span className={`text-sm ${t.enSurcharge ? 'text-red-600 font-semibold' : 'text-ink-700'}`}>
                      {t.chargeH} h / {t.capaciteH} h
                      {t.tauxCharge !== null && <span className="text-xs font-normal text-ink-500"> ({t.tauxCharge} %)</span>}
                    </span>
                  </div>

                  {/* Barre : charge (couleur) et repère de capacité (trait). */}
                  <div className="relative w-full bg-ink-100 rounded-full h-3">
                    <div
                      className={`h-3 rounded-full ${t.enSurcharge ? 'bg-red-500' : 'bg-elyade-600'}`}
                      style={{ width: `${Math.min(100, loadPct)}%` }}
                    />
                    <div
                      className="absolute -top-1 -bottom-1 w-0.5 bg-ink-800"
                      style={{ left: `${Math.min(100, capacityPct)}%` }}
                      title={`Capacité ${t.capaciteH} h`}
                    />
                  </div>
                  <p className="text-xs text-ink-500 mt-1.5">
                    Capacité {t.capaciteBruteH} h
                    {t.congesH > 0 && <> − {t.congesH} h de congés</>}
                    {' '}= <strong className="text-ink-700">{t.capaciteH} h</strong>
                    {' · '}Charge planifiée {t.chargePlanifieeH} h
                    {t.chargeNonPlanifieeH > 0 && <> + {t.chargeNonPlanifieeH} h sans dates</>}
                    {' · '}<span title="Même calcul que le tableau « Temps passé par mois » (en vue Mois, c'est la colonne du mois)">
                      Temps déjà saisi sur la période {t.tempsSaisiH} h
                    </span>
                  </p>

                  {t.chargeParProjet.length > 0 ? (
                    <table className="w-full text-xs text-ink-600 mt-2">
                      <thead>
                        <tr className="text-ink-400">
                          <th className="text-left font-normal pb-1">Projet</th>
                          <th className="text-right font-normal pb-1">Tâches actives</th>
                          <th className="text-right font-normal pb-1">Charge sur la période</th>
                        </tr>
                      </thead>
                      <tbody>
                        {t.chargeParProjet.map((p) => (
                          <tr key={p.projetId} className="border-t border-ink-50">
                            <td className="py-1">{p.nom}</td>
                            <td className="py-1 text-right">
                              {p.nbTaches}
                              {p.nbNonPlanifiees > 0 && <span className="text-ink-400"> (dont {p.nbNonPlanifiees} sans dates)</span>}
                              {p.nbViaSousTaches > 0 && (
                                <span className="text-ink-400" title="Part du reste à faire calculée d'après les sous-tâches qui lui sont affectées">
                                  {' '}· {p.nbViaSousTaches} via sous-tâches
                                </span>
                              )}
                            </td>
                            <td className="py-1 text-right">{p.chargeH} h</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  ) : (
                    <p className="text-xs text-ink-400 mt-2">Aucune charge sur cette période.</p>
                  )}
                </div>
              );
            })}
          </div>

          <p className="text-xs text-ink-400 mt-4">
            La charge porte sur le travail qui reste (à venir), le temps saisi sur le travail fait : ils ne s'additionnent pas.
            Charge = reste à faire des tâches actives (estimé − temps passé), réparti sur les jours ouvrés entre aujourd'hui et la date
            de fin de chaque tâche ; une tâche en retard compte entièrement aujourd'hui, une tâche sans dates compte dans la période en
            cours. Une tâche découpée en sous-tâches est partagée à parts égales entre ses sous-tâches non terminées, au profit de la
            personne affectée à chacune (à défaut, le responsable de la tâche), sur les dates de la sous-tâche. Trait noir : capacité.
            En rouge : charge supérieure à la capacité.
          </p>
        </div>
      )}
    </div>
  );
}
