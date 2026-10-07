import { useMemo, useState } from 'react';
import type { TimeByMonthRow } from './types';

type GroupBy = 'tech' | 'projet';

// Les 12 derniers mois, du plus ancien au mois en cours, au format AAAA-MM.
function lastTwelveMonths() {
  const now = new Date();
  return Array.from({ length: 12 }, (_, index) => {
    const date = new Date(now.getFullYear(), now.getMonth() - 11 + index, 1);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
  });
}

function monthLabel(month: string) {
  const [year, monthIndex] = month.split('-').map(Number);
  return new Date(year, monthIndex - 1, 1).toLocaleDateString('fr-FR', { month: 'short', year: '2-digit' });
}

function formatHours(value: number) {
  if (!value) return '–';
  return `${Math.round(value * 10) / 10}h`;
}

// Temps passé mois par mois, en lignes par technicien (ou par projet),
// filtrable sur un projet (ou un technicien).
export default function TimeByMonth({ rows }: { rows: TimeByMonthRow[] }) {
  const [groupBy, setGroupBy] = useState<GroupBy>('tech');
  const [filterId, setFilterId] = useState('');
  const months = useMemo(lastTwelveMonths, []);

  const filterOptions = useMemo(() => {
    const options = new Map<string, string>();
    for (const row of rows) {
      if (groupBy === 'tech') options.set(row.projetId, row.projet);
      else options.set(row.userId || '', row.nom);
    }
    return [...options.entries()].sort((a, b) => a[1].localeCompare(b[1], 'fr'));
  }, [rows, groupBy]);

  const table = useMemo(() => {
    const lines = new Map<string, { label: string; byMonth: Record<string, number>; total: number }>();
    const columnTotals: Record<string, number> = {};
    let grandTotal = 0;
    for (const row of rows) {
      const filterKey = groupBy === 'tech' ? row.projetId : row.userId || '';
      if (filterId && filterKey !== filterId) continue;
      const key = groupBy === 'tech' ? row.userId || '' : row.projetId;
      const label = groupBy === 'tech' ? row.nom : row.projet;
      const line = lines.get(key) || { label, byMonth: {}, total: 0 };
      line.byMonth[row.mois] = (line.byMonth[row.mois] || 0) + row.heures;
      line.total += row.heures;
      lines.set(key, line);
      columnTotals[row.mois] = (columnTotals[row.mois] || 0) + row.heures;
      grandTotal += row.heures;
    }
    return {
      lines: [...lines.values()].sort((a, b) => b.total - a.total),
      columnTotals,
      grandTotal,
    };
  }, [rows, groupBy, filterId]);

  return (
    <div className="card p-5">
      <div className="flex flex-wrap items-center justify-between gap-3 mb-4">
        <h2 className="font-semibold text-ink-900">Temps passé par mois</h2>
        <div className="flex flex-wrap items-center gap-2">
          <div className="flex rounded-lg border border-ink-200 overflow-hidden text-sm">
            {(['tech', 'projet'] as const).map((value) => (
              <button
                key={value}
                type="button"
                className={`px-3 py-1 ${groupBy === value ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 hover:bg-ink-50'}`}
                onClick={() => {
                  setGroupBy(value);
                  setFilterId('');
                }}
              >
                {value === 'tech' ? 'Par technicien' : 'Par projet'}
              </button>
            ))}
          </div>
          <select className="input w-56 text-sm py-1" value={filterId} onChange={(e) => setFilterId(e.target.value)}>
            <option value="">{groupBy === 'tech' ? 'Tous les projets' : 'Tous les techniciens'}</option>
            {filterOptions.map(([id, label]) => (
              <option key={id} value={id}>{label}</option>
            ))}
          </select>
        </div>
      </div>

      {table.lines.length === 0 ? (
        <p className="text-sm text-ink-500">Aucun temps saisi sur les 12 derniers mois.</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-xs text-ink-500 border-b border-ink-100">
                <th className="text-left font-medium py-2 pr-4 sticky left-0 bg-white">
                  {groupBy === 'tech' ? 'Technicien' : 'Projet'}
                </th>
                {months.map((month) => (
                  <th key={month} className="text-right font-medium py-2 px-2 whitespace-nowrap">{monthLabel(month)}</th>
                ))}
                <th className="text-right font-semibold py-2 pl-3 text-ink-700">Total</th>
              </tr>
            </thead>
            <tbody>
              {table.lines.map((line) => (
                <tr key={line.label} className="border-b border-ink-50">
                  <td className="py-1.5 pr-4 text-ink-800 whitespace-nowrap sticky left-0 bg-white">{line.label}</td>
                  {months.map((month) => (
                    <td key={month} className={`py-1.5 px-2 text-right tabular-nums ${line.byMonth[month] ? 'text-ink-800' : 'text-ink-300'}`}>
                      {formatHours(line.byMonth[month] || 0)}
                    </td>
                  ))}
                  <td className="py-1.5 pl-3 text-right font-semibold text-ink-900 tabular-nums">{formatHours(line.total)}</td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr className="border-t border-ink-200 text-ink-900 font-semibold">
                <td className="py-2 pr-4 sticky left-0 bg-white">Total</td>
                {months.map((month) => (
                  <td key={month} className="py-2 px-2 text-right tabular-nums">{formatHours(table.columnTotals[month] || 0)}</td>
                ))}
                <td className="py-2 pl-3 text-right tabular-nums">{formatHours(table.grandTotal)}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      )}
      <p className="text-xs text-ink-400 mt-3">
        Temps rattaché au mois de sa saisie dans « Temps passé ». Le temps saisi avant cette évolution est rattaché au mois de la dernière modification de la tâche.
        Sur une tâche découpée en sous-tâches, le temps est partagé à parts égales entre ses sous-tâches, au profit de la personne affectée à chacune.
      </p>
    </div>
  );
}
