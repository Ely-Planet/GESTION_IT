import { useEffect, useState } from 'react';
import { CalendarClock, FolderKanban, Plus, Users } from 'lucide-react';
import { groupApi } from './groupApi';
import GroupProjectDetail from './GroupProjectDetail';
import ClientsEditor from '../projects/ClientsEditor';
import { ProgressBar, formatPeriod } from '../projects/ProjectUI';
import { formatDateTime, type DirectoryAccount, type GroupProjectListItem, type ItProjectSummary } from './types';
import type { Account } from '../projects/types';

// Page "Projets Groupe" : les managers et directeurs créent des projets ;
// chacun ne voit que les projets dont il est membre.
const IT_STATE: Record<string, string> = { new: 'Nouveau', in_progress: 'En cours', maintenance: 'Maintenance', closed: 'Clôturé' };
const IT_ROLE: Record<string, string> = { chef_de_projet: 'Chef de projet', equipe: 'Équipe', client: 'Client' };

export default function GroupProjects({ initialProjectId = null, onOpenItProject }: {
  initialProjectId?: string | null;
  onOpenItProject: (projectId: string) => void;
}) {
  const [selectedId, setSelectedId] = useState<string | null>(initialProjectId);
  const [projects, setProjects] = useState<GroupProjectListItem[]>([]);
  const [itProjects, setItProjects] = useState<ItProjectSummary[]>([]);
  const [canCreate, setCanCreate] = useState(false);
  const [accounts, setAccounts] = useState<DirectoryAccount[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [showClosed, setShowClosed] = useState(false);
  const emptyForm = { name: '', description: '', startDate: '', dueDate: '', memberIds: [] as string[] };
  const [form, setForm] = useState(emptyForm);
  const [saving, setSaving] = useState(false);

  async function load() {
    setProjects(await groupApi.listProjects());
  }

  useEffect(() => {
    if (selectedId) return;
    setLoading(true);
    Promise.all([
      load(),
      groupApi.itProjects().then(setItProjects).catch(() => setItProjects([])),
      groupApi.access().then((access: { canCreate: boolean }) => {
        setCanCreate(access.canCreate);
        if (access.canCreate) return groupApi.accounts().then(setAccounts);
      }),
    ])
      .catch((err: Error) => alert(err.message))
      .finally(() => setLoading(false));
  }, [selectedId]);

  async function createProject(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    try {
      const created = await groupApi.createProject({
        name: form.name,
        description: form.description || null,
        startDate: form.startDate || null,
        dueDate: form.dueDate || null,
        memberIds: form.memberIds,
      });
      setForm(emptyForm);
      setShowForm(false);
      setSelectedId(created.id);
    } catch (err: any) {
      alert(err.message || 'Erreur lors de la création');
    } finally {
      setSaving(false);
    }
  }

  if (selectedId) return <GroupProjectDetail projectId={selectedId} onBack={() => setSelectedId(null)} />;
  if (loading) return <div className="p-6 text-ink-500">Chargement...</div>;

  const visible = projects.filter((p) => showClosed || p.status !== 'closed');
  const closedCount = projects.filter((p) => p.status === 'closed').length;
  const pickerAccounts = accounts as unknown as Account[];

  return (
    <div className="p-6 w-full max-w-[1800px] mx-auto">
      <div className="flex flex-wrap items-center justify-between gap-3 mb-6">
        <div>
          <h1 className="text-xl font-semibold text-ink-900">Projets Groupe</h1>
          <p className="text-sm text-ink-500">Vos projets : tâches, planning, réunions, comptes rendus et échanges.</p>
        </div>
        <div className="flex items-center gap-2">
          {closedCount > 0 && (
            <button className="btn-ghost text-sm" onClick={() => setShowClosed((v) => !v)}>
              {showClosed ? 'Masquer les projets clôturés' : `Afficher les projets clôturés (${closedCount})`}
            </button>
          )}
          {canCreate && (
            <button className="btn-primary text-sm" onClick={() => setShowForm((v) => !v)}>
              <Plus className="w-4 h-4" /> Nouveau projet
            </button>
          )}
        </div>
      </div>

      {canCreate && showForm && (
        <form onSubmit={createProject} className="card p-5 mb-6 space-y-3">
          <input className="input" placeholder="Nom du projet" required value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
          <textarea className="input" rows={2} placeholder="Description" value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} />
          <div className="grid grid-cols-2 gap-3">
            <label className="text-xs text-ink-500">
              Date de début
              <input className="input mt-1" type="date" value={form.startDate} max={form.dueDate || undefined} onChange={(e) => setForm({ ...form, startDate: e.target.value })} />
            </label>
            <label className="text-xs text-ink-500">
              Échéance
              <input className="input mt-1" type="date" value={form.dueDate} min={form.startDate || undefined} onChange={(e) => setForm({ ...form, dueDate: e.target.value })} />
            </label>
          </div>
          <div>
            <p className="text-xs text-ink-500 mb-1">Membres du projet (vous en êtes responsable)</p>
            <ClientsEditor
              clients={pickerAccounts}
              selected={form.memberIds.map((id) => {
                const account = accounts.find((a) => a.id === id);
                return { id, label: account?.display_name || id, email: account?.email };
              })}
              onAdd={(id) => setForm({ ...form, memberIds: [...new Set([...form.memberIds, id])] })}
              onRemove={(id) => setForm({ ...form, memberIds: form.memberIds.filter((x) => x !== id) })}
            />
          </div>
          <div className="flex gap-2">
            <button className="btn-primary text-sm" disabled={saving}>{saving ? 'Création…' : 'Créer le projet'}</button>
            <button type="button" className="btn-ghost text-sm" onClick={() => setShowForm(false)}>Annuler</button>
          </div>
        </form>
      )}

      {visible.length === 0 ? (
        <div className="card p-8 text-center text-sm text-ink-500">
          {canCreate ? 'Aucun projet pour le moment. Créez votre premier projet.' : "Vous ne faites partie d'aucun projet pour le moment."}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
          {visible.map((p) => (
            <button key={p.id} type="button" className="card p-5 text-left hover:shadow-elevated transition" onClick={() => setSelectedId(p.id)}>
              <div className="flex items-start justify-between gap-2">
                <h2 className="font-semibold text-ink-900">
                  <span className="text-xs font-mono font-normal text-ink-400 mr-1.5">{p.ref}</span>
                  {p.name}
                </h2>
                <span className={`badge ${p.status === 'closed' ? 'bg-ink-100 text-ink-600' : 'bg-emerald-100 text-emerald-700'}`}>
                  {p.status === 'closed' ? 'Clôturé' : 'Actif'}
                </span>
              </div>
              {p.description && <p className="text-sm text-ink-500 mt-1 line-clamp-2">{p.description}</p>}
              <div className="flex flex-wrap gap-x-4 gap-y-1 mt-3 text-xs text-ink-500">
                <span className="flex items-center gap-1"><Users className="w-3.5 h-3.5" /> {p.nb_membres} membre{p.nb_membres > 1 ? 's' : ''}</span>
                {p.my_role === 'responsable' && <span className="text-elyade-700">Responsable</span>}
                {formatPeriod(p.start_date, p.due_date) && <span>{formatPeriod(p.start_date, p.due_date)}</span>}
                {p.prochaine_reunion && (
                  <span className="flex items-center gap-1 text-sky-700"><CalendarClock className="w-3.5 h-3.5" /> {formatDateTime(p.prochaine_reunion)}</span>
                )}
              </div>
              <div className="mt-3">
                <div className="flex justify-between text-xs text-ink-500 mb-1">
                  <span>{p.nb_taches} tâche{p.nb_taches > 1 ? 's' : ''}</span>
                  <span>{p.tauxCompletude}%</span>
                </div>
                <ProgressBar value={p.tauxCompletude} />
              </div>
            </button>
          ))}
        </div>
      )}

      {itProjects.length > 0 && (
        <section className="mt-8">
          <h2 className="font-semibold text-ink-900 flex items-center gap-2 mb-1">
            <FolderKanban className="w-4 h-4 text-elyade-600" /> Mes projets IT
          </h2>
          <p className="text-xs text-ink-500 mb-3">Projets du service informatique dont vous faites partie (équipe ou client). Cliquez pour les ouvrir dans Projets IT.</p>
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-3">
            {itProjects.map((p) => (
              <button key={p.id} type="button" className="card p-4 text-left hover:shadow-elevated transition" onClick={() => onOpenItProject(p.id)}>
                <div className="flex items-start justify-between gap-2">
                  <p className="font-medium text-ink-900 text-sm">{p.name}</p>
                  <span className="badge bg-blue-50 text-blue-700 shrink-0">IT</span>
                </div>
                <p className="text-xs text-ink-500 mt-1">
                  {IT_STATE[p.project_state || 'new'] || 'Nouveau'} · {IT_ROLE[p.mon_role]}
                  {p.mes_taches > 0 && <> · {p.mes_taches} tâche{p.mes_taches > 1 ? 's' : ''} pour vous</>}
                  {p.due_date && <> · échéance {formatPeriod(null, p.due_date).replace('Fin ', '')}</>}
                </p>
                <div className="mt-2">
                  <div className="flex justify-between text-[11px] text-ink-400 mb-0.5">
                    <span>{p.nb_taches} tâche{p.nb_taches > 1 ? 's' : ''}</span>
                    <span>{p.tauxCompletude}%</span>
                  </div>
                  <ProgressBar value={p.tauxCompletude} />
                </div>
              </button>
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
