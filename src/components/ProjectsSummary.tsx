import { useEffect, useState } from 'react';
import { CheckCircle2, Clock, FolderKanban, Inbox, ListTodo, UserX } from 'lucide-react';

type Indicators = {
  projetsActifs: number;
  projetsNouveaux: number;
  projetsEnCours: number;
  projetsMaintenance: number;
  tachesOuvertes: number;
  tachesEnCours: number;
  tachesNonAffectees: number;
  mesTaches: number;
  tachesTermineesMois: number;
  demandesEnAttente: number;
  heuresMois: number;
};

const TONES = {
  elyade: 'bg-elyade-50 text-elyade-700',
  green: 'bg-green-50 text-green-700',
  amber: 'bg-amber-50 text-amber-700',
  red: 'bg-red-50 text-red-700',
  ink: 'bg-ink-100 text-ink-700',
} as const;

function Card({ icon: Icon, label, value, hint, tone }: {
  icon: typeof FolderKanban;
  label: string;
  value: string | number;
  hint: string;
  tone: keyof typeof TONES;
}) {
  return (
    <div className="card p-5">
      <span className={`w-10 h-10 rounded-lg flex items-center justify-center ${TONES[tone]}`}>
        <Icon className="w-5 h-5" />
      </span>
      <p className="text-3xl font-bold text-ink-900 mt-3">{value}</p>
      <p className="text-sm font-medium text-ink-700 mt-1">{label}</p>
      <p className="text-xs text-ink-400 mt-0.5">{hint}</p>
    </div>
  );
}

// Indicateurs du module Projets IT pour le tableau de bord principal.
export default function ProjectsSummary() {
  const [data, setData] = useState<Indicators | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    fetch('/api/projects-indicators', { credentials: 'include' })
      .then((r) => (r.ok ? r.json() : Promise.reject(new Error(String(r.status)))))
      .then(setData)
      .catch(() => setError(true));
  }, []);

  if (error) return <div className="card p-5 text-sm text-ink-500">Indicateurs Projets IT indisponibles.</div>;
  if (!data) return <div className="card p-5 text-sm text-ink-500">Chargement des indicateurs Projets IT…</div>;

  const month = new Date().toLocaleDateString('fr-FR', { month: 'long' });

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
      <Card
        icon={FolderKanban}
        label="Projets actifs"
        value={data.projetsActifs}
        hint={`${data.projetsNouveaux} nouveaux · ${data.projetsEnCours} en cours · ${data.projetsMaintenance} maintenance`}
        tone="elyade"
      />
      <Card
        icon={ListTodo}
        label="Tâches ouvertes"
        value={data.tachesOuvertes}
        hint={`${data.tachesEnCours} en cours de réalisation`}
        tone="ink"
      />
      <Card
        icon={UserX}
        label="Tâches non affectées"
        value={data.tachesNonAffectees}
        hint={`Mes tâches ouvertes : ${data.mesTaches}`}
        tone={data.tachesNonAffectees > 0 ? 'amber' : 'green'}
      />
      <Card
        icon={Inbox}
        label="Demandes client"
        value={data.demandesEnAttente}
        hint="en attente de validation"
        tone={data.demandesEnAttente > 0 ? 'red' : 'green'}
      />
      <Card
        icon={CheckCircle2}
        label="Tâches terminées"
        value={data.tachesTermineesMois}
        hint={`en ${month}`}
        tone="green"
      />
      <Card
        icon={Clock}
        label="Temps passé"
        value={`${Math.round(data.heuresMois * 10) / 10}h`}
        hint={`en ${month}, toute l'équipe`}
        tone="amber"
      />
    </div>
  );
}
