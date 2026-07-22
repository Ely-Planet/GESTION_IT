import { useMemo, useState, type FormEvent } from 'react';
import {
  ArrowDownToLine,
  ArrowUpFromLine,
  Plus,
  Mail,
  Filter,
  X,
  CheckCircle2,
  Circle,
  Clock,
  ChevronDown,
  ChevronRight,
  ListChecks,
  Package,
  KeyRound,
  PenTool,
  FileSignature,
  Calendar,
  Trash2,
} from 'lucide-react';
import { useData } from '../hooks/useData';
import { logAudit } from '../lib/audit';
import { useAuth } from '../context/AuthContext';
import {
  formatFrDate,
  MOVEMENT_STATUS,
  statusLabel,
} from '../lib/format';
import type { Movement, MovementAction, MovementItem, MovementLicense } from '../lib/supabase';

export default function Movements() {
  const data = useData();
  const { profile } = useAuth();

const [filter, setFilter] = useState<
  'all' |
  'onboarding' |
  'offboarding' |
  'manager_requests'
>('all');


const [showForm, setShowForm] = useState(false);
  const [formType, setFormType] = useState<'onboarding' | 'offboarding'>('onboarding');
  const [expanded, setExpanded] = useState<string | null>(null);
  const [signModal, setSignModal] = useState<{ movementId: string; docType: 'assignment' | 'restitution' } | null>(null);

const filtered = useMemo(() => {
  if (filter === 'manager_requests') {
    return data.movements.filter(
      (m) => m.source === 'manager_form'
    );
  }

  return data.movements.filter(
    (m) => filter === 'all' || m.type === filter
  );
}, [data.movements, filter]);


  async function changeStatus(m: Movement, status: Movement['status']) {
    const res = await fetch(`/api/movements/${m.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ status }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur mise à jour mouvement' }));
      alert(err.error ?? 'Erreur mise à jour mouvement');
      return;
    }

    await logAudit(
      'update',
      'movement',
      m.id,
      { status },
      profile?.display_name
    ).catch(console.error);

    data.reload();
  }

  async function toggleAction(a: MovementAction) {
    const patch = a.done_at
      ? { done_at: null }
      : { done_at: new Date().toISOString() };

    const res = await fetch(`/api/movement-actions/${a.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(patch),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur mise à jour action' }));
      alert(err.error ?? 'Erreur mise à jour action');
      return;
    }

    await logAudit(
      a.done_at ? 'uncomplete' : 'complete',
      'movement_action',
      a.id,
      patch,
      profile?.display_name
    ).catch(console.error);

    data.reload();
  }

  async function addAction(movementId: string) {
    const label = prompt('Libellé de l’action :');
    if (!label) return;

    const due = prompt('Date d’échéance (AAAA-MM-JJ, optionnel) :');

    const payload = {
      movement_id: movementId,
      action_type: 'other',
      label,
      due_date: due || null,
      sort_order: 99,
    };

    const res = await fetch('/api/movement-actions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur création action' }));
      alert(err.error ?? 'Erreur création action');
      return;
    }

    await logAudit(
      'create',
      'movement_action',
      null,
      { movement_id: movementId, label },
      profile?.display_name
    ).catch(console.error);

    data.reload();
  }

  async function assignHardwareItem(mi: MovementItem, hardwareItemId: string) {
    const res = await fetch(`/api/movement-items/${mi.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        hardware_item_id: hardwareItemId,
        status: 'assigned',
      }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur attribution matériel au mouvement' }));
      alert(err.error ?? 'Erreur attribution matériel au mouvement');
      return;
    }

    const hwRes = await fetch(`/api/hardware-items/${hardwareItemId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ status: 'assigned' }),
    });

    if (!hwRes.ok) {
      const err = await hwRes.json().catch(() => ({ error: 'Erreur mise à jour matériel' }));
      alert(err.error ?? 'Erreur mise à jour matériel');
      return;
    }

    await logAudit(
      'assign',
      'movement_item',
      mi.id,
      { hardware_item_id: hardwareItemId },
      profile?.display_name
    ).catch(console.error);

    data.reload();
  }

  async function skipMovementItem(mi: MovementItem) {
    const res = await fetch(`/api/movement-items/${mi.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ status: 'skipped' }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur ignore matériel' }));
      alert(err.error ?? 'Erreur ignore matériel');
      return;
    }

    await logAudit(
      'skip',
      'movement_item',
      mi.id,
      {},
      profile?.display_name
    ).catch(console.error);

    data.reload();
  }

  async function assignLicense(ml: MovementLicense, licenseId: string) {
    const res = await fetch(`/api/movement-licenses/${ml.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        license_id: licenseId,
        status: 'assigned',
      }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur attribution licence au mouvement' }));
      alert(err.error ?? 'Erreur attribution licence au mouvement');
      return;
    }

    const employeeId = data.movements.find((m) => m.id === ml.movement_id)?.employee_id ?? null;

    const licRes = await fetch(`/api/licenses/${licenseId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        status: 'assigned',
        assigned_employee_id: employeeId,
        assigned_at: new Date().toISOString().slice(0, 10),
      }),
    });

    if (!licRes.ok) {
      const err = await licRes.json().catch(() => ({ error: 'Erreur mise à jour licence' }));
      alert(err.error ?? 'Erreur mise à jour licence');
      return;
    }

    await logAudit(
      'assign',
      'movement_license',
      ml.id,
      { license_id: licenseId },
      profile?.display_name
    ).catch(console.error);

    data.reload();
  }

  async function skipMovementLicense(ml: MovementLicense) {
    const res = await fetch(`/api/movement-licenses/${ml.id}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ status: 'skipped' }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: 'Erreur ignore licence' }));
      alert(err.error ?? 'Erreur ignore licence');
      return;
    }

    await logAudit(
      'skip',
      'movement_license',
      ml.id,
      {},
      profile?.display_name
    ).catch(console.error);

    data.reload();
  }


  return (
    <div className="p-6 lg:p-8 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-2xl font-bold text-ink-900">Arrivées & Départs</h1>
          <p className="text-sm text-ink-500 mt-1">
            Onboardings et offboardings — créés par email (Microsoft Form / Lucca) ou manuellement
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={() => { setFormType('onboarding'); setShowForm(true); }} className="btn-primary">
            <ArrowDownToLine className="w-4 h-4" />
            Onboarding
          </button>
          <button onClick={() => { setFormType('offboarding'); setShowForm(true); }} className="btn-secondary">
            <ArrowUpFromLine className="w-4 h-4" />
            Offboarding
          </button>
        </div>
      </div>

      <div className="flex items-center gap-2 mb-4">
        <Filter className="w-4 h-4 text-ink-400" />
{(
  [
    'all',
    'onboarding',
    'offboarding',
    'manager_requests'
  ] as const
).map((f) => (

          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition ${
              filter === f ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 border border-ink-200 hover:bg-ink-50'
            }`}
          >

{
  f === 'all'
    ? 'Tous'
    : f === 'onboarding'
      ? 'Arrivées'
      : f === 'offboarding'
        ? 'Départs'
        : 'Demandes managers'
}


          </button>
        ))}
      </div>

      <div className="card overflow-hidden">
        {data.loading ? (
          <p className="p-8 text-center text-ink-500">Chargement…</p>
        ) : filtered.length === 0 ? (
          <p className="p-8 text-center text-ink-500">Aucun mouvement.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="table-base">
              <thead>
                <tr>
                  <th className="w-8"></th>
                  <th>Type</th>
                  <th>Collaborateur</th>
                  <th>Service</th>
                  <th>Date effet</th>
                  <th>Source</th>
                  <th>Matériel</th>
                  <th>Licences</th>
                  <th>Calendrier</th>
                  <th>Statut</th>
                  <th className="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((m) => {
                  const emp = data.employees.find((e) => e.id === m.employee_id);
                  const svc = data.services.find((s) => s.id === m.service_id);
                  const actions = data.movementActions.filter((a) => a.movement_id === m.id);
                  const done = actions.filter((a) => a.done_at).length;
                  const items = data.movementItems.filter((i) => i.movement_id === m.id);
                  const itemsAssigned = items.filter((i) => i.status === 'assigned').length;
                  const lics = data.movementLicenses.filter((l) => l.movement_id === m.id);
                  const licsAssigned = lics.filter((l) => l.status === 'assigned').length;
                  const docs = data.signedDocuments.filter((d) => d.movement_id === m.id);
                  const isOpen = expanded === m.id;
                  const overdueActions = actions.filter((a) => !a.done_at && a.due_date && a.due_date < new Date().toISOString().slice(0, 10));
                  return (
                    <>
                      <tr key={m.id}>
                        <td className="text-center">
                          <button onClick={() => setExpanded(isOpen ? null : m.id)} className="btn-ghost p-1">
                            {isOpen ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                          </button>
                        </td>
                        <td>
                          <span className={`badge ${m.type === 'onboarding' ? 'bg-green-50 text-green-700' : 'bg-amber-50 text-amber-700'}`}>
                            {m.type === 'onboarding' ? <ArrowDownToLine className="w-3 h-3" /> : <ArrowUpFromLine className="w-3 h-3" />}
                            {m.type === 'onboarding' ? 'Arrivée' : 'Départ'}
                          </span>
                        </td>
                        <td className="font-medium">
                          {emp ? `${emp.first_name} ${emp.last_name}` : '—'}
                          {m.job_title && <span className="block text-xs text-ink-400">{m.job_title}</span>}
                        </td>
                        <td>{svc?.name ?? '—'}</td>
                        <td>{formatFrDate(m.effective_date)}</td>
                        <td>
                          <span className="flex items-center gap-1 text-xs text-ink-600">
                            {m.source === 'lucca_email' && <Mail className="w-3 h-3 text-elyade-600" />}
                            {m.source === 'manager_form' ? 'Formulaire' : m.source === 'lucca_email' ? 'Email' : 'Manuel'}
                          </span>
                        </td>
                        <td>
                          {items.length > 0 ? (
                            <span className={`badge ${itemsAssigned === items.length ? 'bg-green-50 text-green-700' : 'bg-ink-100 text-ink-600'}`}>
                              <Package className="w-3 h-3" />
                              {itemsAssigned}/{items.length}
                            </span>
                          ) : '—'}
                        </td>
                        <td>
                          {lics.length > 0 ? (
                            <span className={`badge ${licsAssigned === lics.length ? 'bg-green-50 text-green-700' : 'bg-ink-100 text-ink-600'}`}>
                              <KeyRound className="w-3 h-3" />
                              {licsAssigned}/{lics.length}
                            </span>
                          ) : '—'}
                        </td>
                        <td>
                          {m.calendar_event_ids && m.calendar_event_ids.length > 0 ? (
                            <span className="badge bg-blue-50 text-blue-700">
                              <Calendar className="w-3 h-3" />
                              {m.calendar_event_ids[0] === 'pending-credentials' ? 'En attente' : `${m.calendar_event_ids.length} RDV`}
                            </span>
                          ) : '—'}
                        </td>
                        <td><StatusBadge status={m.status} /></td>
                        <td className="text-right">
                          <div className="flex justify-end gap-1">
                            {m.type === 'onboarding' && m.status !== 'done' && (
                              <button
                                title="Faire signer l'attribution"
                                onClick={() => setSignModal({ movementId: m.id, docType: 'assignment' })}
                                className="btn-ghost p-1.5 text-elyade-600"
                              >
                                <PenTool className="w-4 h-4" />
                              </button>
                            )}
                            {m.type === 'offboarding' && (
                              <button
                                title="Faire signer la restitution"
                                onClick={() => setSignModal({ movementId: m.id, docType: 'restitution' })}
                                className="btn-ghost p-1.5 text-amber-600"
                              >
                                <FileSignature className="w-4 h-4" />
                              </button>
                            )}
                            {m.status !== 'done' && m.status !== 'cancelled' && (
                              <>
                                <button onClick={() => changeStatus(m, 'in_progress')} className="btn-ghost text-xs px-2 py-1">Démarrer</button>
                                <button onClick={() => changeStatus(m, 'done')} className="btn-ghost text-xs px-2 py-1 text-green-700">Terminer</button>
                              </>
                            )}
                          </div>
                        </td>
                      </tr>
                      {isOpen && (
                        <tr key={`${m.id}-detail`} className="bg-ink-50/40">
                          <td></td>
                          <td colSpan={10} className="p-4">
                            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                              <ActionChecklist actions={actions} onToggle={toggleAction} onAdd={() => addAction(m.id)} />
                              <div className="space-y-4">
                                <ItemsPanel
                                  movement={m}
                                  items={items}
                                  data={data}
                                  onAssign={assignHardwareItem}
                                  onSkip={skipMovementItem}
                                />
                                <MicrosoftGroupsPanel
				movement={m}
				data={data}
				/>



				<LicensesPanel
                                  movement={m}
                                  licenses={lics}
                                  data={data}
                                  onAssign={assignLicense}
                                  onSkip={skipMovementLicense}
                                />
                                <DocumentsPanel docs={docs} movement={m} data={data} />
                              </div>
                            </div>
                          </td>
                        </tr>
                      )}
                    </>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {showForm && (
        <MovementForm
          type={formType}
          onClose={() => setShowForm(false)}
          onSaved={() => { setShowForm(false); data.reload(); }}
        />
      )}

      {signModal && (
        <SignatureModal
          movementId={signModal.movementId}
          docType={signModal.docType}
          data={data}
          onClose={() => setSignModal(null)}
          onSigned={() => { setSignModal(null); data.reload(); }}
        />
      )}
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  const tones: Record<string, string> = {
    pending: 'bg-ink-100 text-ink-600',
    in_progress: 'bg-blue-50 text-blue-700',
    done: 'bg-green-50 text-green-700',
    cancelled: 'bg-red-50 text-red-700',
  };
  return <span className={`badge ${tones[status] ?? 'bg-ink-100 text-ink-600'}`}>{statusLabel(status, MOVEMENT_STATUS)}</span>;
}

function ActionChecklist({
  actions, onToggle, onAdd,
}: {
  actions: MovementAction[];
  onToggle: (a: MovementAction) => void;
  onAdd: () => void;
}) {
  const today = new Date().toISOString().slice(0, 10);
  return (
    <div>
      <div className="flex items-center justify-between mb-3">
        <h4 className="text-sm font-semibold text-ink-800 flex items-center gap-2">
          <ListChecks className="w-4 h-4 text-elyade-600" />
          Checklist d'actions
        </h4>
        <button onClick={onAdd} className="btn-ghost text-xs">
          <Plus className="w-3.5 h-3.5" /> Ajouter
        </button>
      </div>
      <div className="space-y-1.5">
        {actions.length === 0 && <p className="text-sm text-ink-400 py-2">Aucune action.</p>}
        {actions.map((a) => {
          const done = !!a.done_at;
          const overdue = !done && a.due_date && a.due_date < today;
          return (
            <div key={a.id} className="flex items-center gap-3 p-2.5 bg-white rounded-lg border border-ink-100">
              <button onClick={() => onToggle(a)} className="shrink-0">
                {done ? <CheckCircle2 className="w-5 h-5 text-green-500" /> : <Circle className="w-5 h-5 text-ink-300 hover:text-elyade-400" />}
              </button>
              <div className="flex-1 min-w-0">
                <p className={`text-sm ${done ? 'line-through text-ink-400' : 'text-ink-800 font-medium'}`}>{a.label}</p>
                {a.due_date && (
                  <p className={`text-xs flex items-center gap-1 ${overdue ? 'text-red-600' : 'text-ink-500'}`}>
                    <Clock className="w-3 h-3" />
                    {formatFrDate(a.due_date)} {overdue && '· en retard'} {done && `· fait le ${formatFrDate(a.done_at)}`}
                  </p>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

function ItemsPanel({
  movement, items, data, onAssign, onSkip,
}: {
  movement: Movement;
  items: MovementItem[];
  data: ReturnType<typeof useData>;
  onAssign: (mi: MovementItem, hwId: string) => void;
  onSkip: (mi: MovementItem) => void;
}) {
  return (
    <div className="card p-4">
      <h4 className="text-sm font-semibold text-ink-800 flex items-center gap-2 mb-3">
        <Package className="w-4 h-4 text-elyade-600" />
        Matériel à attribuer
      </h4>
      {items.length === 0 ? (
        <p className="text-sm text-ink-400 py-2">Aucun matériel demandé.</p>
      ) : (
        <div className="space-y-2">
          {items.map((mi) => {
            const cat = data.hardwareCategories.find((c) => c.id === mi.category_id);
            const hw = mi.hardware_item_id ? data.hardware.find((h) => h.id === mi.hardware_item_id) : null;
            const available = data.hardware.filter(
              (h) => h.category_id === mi.category_id && (h.status === 'in_stock' || h.status === 'being_reinstalled'),
            );
            return (
              <div key={mi.id} className="p-2.5 bg-white rounded-lg border border-ink-100">
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm font-medium text-ink-800">{cat?.label ?? '—'}</span>
                  <span className={`badge ${mi.status === 'assigned' ? 'bg-green-50 text-green-700' : mi.status === 'skipped' ? 'bg-ink-100 text-ink-400' : 'bg-amber-50 text-amber-700'}`}>
                    {mi.status === 'assigned' ? 'Attribué' : mi.status === 'skipped' ? 'Ignoré' : 'Demandé'}
                  </span>
                </div>
                {hw && <p className="text-xs text-ink-500 font-mono">{hw.serial_number ?? hw.reference ?? hw.id.slice(0, 8)}</p>}
                {mi.status === 'requested' && (
                  <div className="flex items-center gap-2 mt-2">
                    <select
                      className="input py-1 text-xs flex-1"
                      defaultValue=""
                      onChange={(e) => { if (e.target.value) onAssign(mi, e.target.value); }}
                    >
                      <option value="">Sélectionner…</option>
                      {available.map((h) => (
                        <option key={h.id} value={h.id}>
                          {h.serial_number ?? h.reference ?? h.id.slice(0, 8)} {h.status === 'being_reinstalled' ? '(réinstall.)' : ''}
                        </option>
                      ))}
                    </select>
                    <button onClick={() => onSkip(mi)} className="btn-ghost text-xs px-2 py-1 text-ink-400">Ignorer</button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function MicrosoftGroupsPanel({
  movement,
  data,
}: {
  movement: Movement;
  data: ReturnType<typeof useData>;
}) {
  const groups = data.movementServiceGroups.filter(
    (g) => g.movement_id === movement.id
  );

  return (
    <div className="card p-4">
      <h4 className="text-sm font-semibold text-ink-800 mb-3">
        🏢 Groupes Microsoft demandés
      </h4>

      {groups.length === 0 ? (
        <p className="text-sm text-ink-400">
          Aucun groupe Microsoft.
        </p>
      ) : (
        <div className="space-y-2">
          {groups.map((group) => (
            <div
              key={group.id}
              className="p-2.5 bg-white rounded-lg border border-ink-100"
            >
              <div className="font-medium text-sm text-ink-800">
                {group.group_name}
              </div>

              {group.group_mail && (
                <div className="text-xs text-ink-500">
                  {group.group_mail}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}




function LicensesPanel({
  movement, licenses, data, onAssign, onSkip,
}: {
  movement: Movement;
  licenses: MovementLicense[];
  data: ReturnType<typeof useData>;
  onAssign: (ml: MovementLicense, licId: string) => void;
  onSkip: (ml: MovementLicense) => void;
}) {
  return (
    <div className="card p-4">
      <h4 className="text-sm font-semibold text-ink-800 flex items-center gap-2 mb-3">
        <KeyRound className="w-4 h-4 text-elyade-600" />
        Licences à attribuer
      </h4>
      {licenses.length === 0 ? (
        <p className="text-sm text-ink-400 py-2">Aucune licence demandée.</p>
      ) : (
        <div className="space-y-2">
          {licenses.map((ml) => {
            const lt = data.licenseTypes.find((t) => t.id === ml.license_type_id);
            const lic = ml.license_id ? data.licenses.find((l) => l.id === ml.license_id) : null;
            const available = data.licenses.filter(
              (l) => l.license_type_id === ml.license_type_id && l.status === 'available',
            );
            return (
              <div key={ml.id} className="p-2.5 bg-white rounded-lg border border-ink-100">
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm font-medium text-ink-800">{lt?.label ?? '—'}</span>
                  <span className={`badge ${ml.status === 'assigned' ? 'bg-green-50 text-green-700' : ml.status === 'skipped' ? 'bg-ink-100 text-ink-400' : 'bg-amber-50 text-amber-700'}`}>
                    {ml.status === 'assigned' ? 'Attribuée' : ml.status === 'skipped' ? 'Ignorée' : 'Demandée'}
                  </span>
                </div>
                {lic && <p className="text-xs text-ink-500 font-mono">{lic.seat_key ?? lic.id.slice(0, 8)}</p>}
                {ml.status === 'requested' && (
                  <div className="flex items-center gap-2 mt-2">
                    <select
                      className="input py-1 text-xs flex-1"
                      defaultValue=""
                      onChange={(e) => { if (e.target.value) onAssign(ml, e.target.value); }}
                    >
                      <option value="">Sélectionner…</option>
                      {available.map((l) => (
                        <option key={l.id} value={l.id}>{l.seat_key ?? l.id.slice(0, 8)}</option>
                      ))}
                    </select>
                    <button onClick={() => onSkip(ml)} className="btn-ghost text-xs px-2 py-1 text-ink-400">Ignorer</button>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function DocumentsPanel({
  docs, movement, data,
}: {
  docs: import('../lib/supabase').SignedDocument[];
  movement: Movement;
  data: ReturnType<typeof useData>;
}) {
  return (
    <div className="card p-4">
      <h4 className="text-sm font-semibold text-ink-800 flex items-center gap-2 mb-3">
        <FileSignature className="w-4 h-4 text-elyade-600" />
        Documents signés
      </h4>
      {docs.length === 0 ? (
        <p className="text-sm text-ink-400 py-2">Aucun document signé. Utilisez les boutons signature dans la ligne du mouvement.</p>
      ) : (
        <div className="space-y-2">
          {docs.map((d) => (
            <div key={d.id} className="p-2.5 bg-white rounded-lg border border-ink-100 flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-ink-800">
                  {d.doc_type === 'assignment' ? 'Attribution de matériel' : 'Restitution de matériel'}
                </p>
                <p className="text-xs text-ink-500">
                  {d.signer_name ?? '—'} · {formatFrDate(d.signed_at)}
                </p>
              </div>
              <span className={`badge ${d.status === 'signed' ? 'bg-green-50 text-green-700' : 'bg-ink-100 text-ink-500'}`}>
                {d.status === 'signed' ? 'Signé' : 'En attente'}
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

function SignatureModal({
  movementId, docType, data, onClose, onSigned,
}: {
  movementId: string;
  docType: 'assignment' | 'restitution';
  data: ReturnType<typeof useData>;
  onClose: () => void;
  onSigned: () => void;
}) {
  const { profile } = useAuth();
  const [signerName, setSignerName] = useState('');
  const [signerEmail, setSignerEmail] = useState('');
  const [drawing, setDrawing] = useState(false);
  const [signatureData, setSignatureData] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const canvasRef = useState<HTMLCanvasElement | null>(null);
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null);

  const movement = data.movements.find((m) => m.id === movementId);
  const emp = data.employees.find((e) => e.id === movement?.employee_id);
  const items = data.movementItems.filter((i) => i.movement_id === movementId);
  const lics = data.movementLicenses.filter((l) => l.movement_id === movementId);

  const docItems = docType === 'assignment'
    ? items.filter((i) => i.status === 'assigned')
    : items.filter((i) => i.status === 'assigned');

  const docLicenses = lics.filter((l) => l.status === 'assigned');

  function startDraw(e: React.MouseEvent<HTMLCanvasElement>) {
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    setDrawing(true);
    const rect = canvas.getBoundingClientRect();
    ctx.beginPath();
    ctx.moveTo(e.clientX - rect.left, e.clientY - rect.top);
  }

  function draw(e: React.MouseEvent<HTMLCanvasElement>) {
    if (!drawing || !canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    const rect = canvas.getBoundingClientRect();
    ctx.lineTo(e.clientX - rect.left, e.clientY - rect.top);
    ctx.strokeStyle = '#ca0088';
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  function endDraw() {
    setDrawing(false);
    if (canvas) {
      setSignatureData(canvas.toDataURL());
    }
  }

  function clearSignature() {
    if (canvas) {
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
      }
    }
    setSignatureData(null);
  }

  function setCanvasRef(el: HTMLCanvasElement | null) {
    setCanvas(el);
  }

  async function submit() {
    if (!signerName) { setError('Veuillez saisir le nom du signataire.'); return; }
    if (!signatureData) { setError('Veuillez signer dans la zone de signature.'); return; }
    setBusy(true);
    setError(null);
    try {
      const snapshot = {
        employee: emp ? `${emp.first_name} ${emp.last_name}` : null,
        movement_type: movement?.type,
        effective_date: movement?.effective_date,
        items: docItems.map((i) => {
          const cat = data.hardwareCategories.find((c) => c.id === i.category_id);
          const hw = i.hardware_item_id ? data.hardware.find((h) => h.id === i.hardware_item_id) : null;
          return { category: cat?.label, serial: hw?.serial_number, reference: hw?.reference };
        }),
        licenses: docLicenses.map((l) => {
          const lt = data.licenseTypes.find((t) => t.id === l.license_type_id);
          const lic = l.license_id ? data.licenses.find((x) => x.id === l.license_id) : null;
          return { type: lt?.label, seat: lic?.seat_key };
        }),
      };

      const res = await fetch('/api/signed-documents', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          movement_id: movementId,
          doc_type: docType,
          signer_name: signerName,
          signer_email: signerEmail || null,
          signature_data: signatureData,
          signed_at: new Date().toISOString(),
          status: 'signed',
          content_snapshot: snapshot,
        }),
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({ error: 'Erreur signature document' }));
        throw new Error(err.error ?? 'Erreur signature document');
      }



      await logAudit('sign', 'signed_document', null, { movement_id: movementId, doc_type: docType, signer: signerName }, profile?.display_name);
      onSigned();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Erreur');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4" onClick={onClose}>
      <div className="card w-full max-w-2xl max-h-[90vh] overflow-auto" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 py-4 border-b border-ink-100 sticky top-0 bg-white rounded-t-xl">
          <h2 className="text-lg font-semibold text-ink-900 flex items-center gap-2">
            {docType === 'assignment' ? <PenTool className="w-5 h-5 text-elyade-600" /> : <FileSignature className="w-5 h-5 text-amber-600" />}
            {docType === 'assignment' ? 'Signature — Attestation d\'attribution' : 'Signature — Fiche de restitution'}
          </h2>
          <button onClick={onClose} className="btn-ghost p-1.5"><X className="w-5 h-5" /></button>
        </div>

        <div className="p-5 space-y-4">
          {/* Document preview */}
          <div className="border border-ink-200 rounded-lg p-4 bg-ink-50/30">
            <h3 className="text-base font-bold text-ink-900 mb-2">
              {docType === 'assignment' ? 'ATTESTATION D\'ATTRIBUTION DE MATÉRIEL' : 'FICHE DE RESTITUTION DE MATÉRIEL'}
            </h3>
            <p className="text-sm text-ink-600 mb-3">
              Collaborateur : <strong>{emp ? `${emp.first_name} ${emp.last_name}` : '—'}</strong>
              {movement?.job_title && <> · {movement.job_title}</>}
            </p>
            <p className="text-sm text-ink-600 mb-3">
              Date : {formatFrDate(movement?.effective_date ?? null)}
            </p>

            <table className="w-full text-sm mb-3">
              <thead>
                <tr className="border-b border-ink-200">
                  <th className="text-left py-1">Matériel</th>
                  <th className="text-left py-1">Référence / Série</th>
                </tr>
              </thead>
              <tbody>
                {docItems.length === 0 && <tr><td colSpan={2} className="py-2 text-ink-400">Aucun matériel attribué.</td></tr>}
                {docItems.map((i) => {
                  const cat = data.hardwareCategories.find((c) => c.id === i.category_id);
                  const hw = i.hardware_item_id ? data.hardware.find((h) => h.id === i.hardware_item_id) : null;
                  return (
                    <tr key={i.id} className="border-b border-ink-100">
                      <td className="py-1.5">{cat?.label ?? '—'}</td>
                      <td className="py-1.5 font-mono text-xs">{hw?.serial_number ?? hw?.reference ?? '—'}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>

            {docLicenses.length > 0 && (
              <>
                <p className="text-sm font-medium text-ink-700 mt-3 mb-1">Licences attribuées :</p>
                <ul className="text-sm text-ink-600 list-disc list-inside">
                  {docLicenses.map((l) => {
                    const lt = data.licenseTypes.find((t) => t.id === l.license_type_id);
                    const lic = l.license_id ? data.licenses.find((x) => x.id === l.license_id) : null;
                    return <li key={l.id}>{lt?.label} {lic?.seat_key ? `(${lic.seat_key})` : ''}</li>;
                  })}
                </ul>
              </>
            )}

            {docType === 'restitution' && (
              <p className="text-xs text-ink-500 mt-3 italic">
                Le matériel restitué est vérifié et son état consigné. Tout matériel manquant ou défectueux est signalé.
              </p>
            )}
          </div>

          {/* Signer info */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Nom du signataire</label>
              <input className="input" value={signerName} onChange={(e) => setSignerName(e.target.value)} placeholder={emp ? `${emp.first_name} ${emp.last_name}` : 'Nom'} required />
            </div>
            <div>
              <label className="label">Email (optionnel)</label>
              <input type="email" className="input" value={signerEmail} onChange={(e) => setSignerEmail(e.target.value)} placeholder={emp?.email ?? 'email'} />
            </div>
          </div>

          {/* Signature pad */}
          <div>
            <label className="label">Signature</label>
            <div className="border-2 border-ink-200 rounded-lg bg-white relative" style={{ height: '160px' }}>
              <canvas
                ref={setCanvasRef}
                width={560}
                height={160}
                className="w-full h-full cursor-crosshair touch-none"
                onMouseDown={startDraw}
                onMouseMove={draw}
                onMouseUp={endDraw}
                onMouseLeave={endDraw}
              />
              {!signatureData && (
                <span className="absolute inset-0 flex items-center justify-center text-ink-300 text-sm pointer-events-none">
                  Signez ici avec la souris
                </span>
              )}
            </div>
            <button onClick={clearSignature} className="btn-ghost text-xs mt-1">
              <Trash2 className="w-3.5 h-3.5" /> Effacer
            </button>
          </div>

          {error && <div className="rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-sm text-red-700">{error}</div>}

          <div className="flex justify-end gap-2 pt-2">
            <button onClick={onClose} className="btn-secondary">Annuler</button>
            <button onClick={submit} className="btn-primary" disabled={busy}>
              <PenTool className="w-4 h-4" />
              {busy ? 'Signature…' : 'Signer numériquement'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function MovementForm({
  type,
  onClose,
  onSaved,
}: {
  type: 'onboarding' | 'offboarding';
  onClose: () => void;
  onSaved: () => void;
}) {
  const data = useData();
  const { profile, user } = useAuth();
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [serviceId, setServiceId] = useState('');
  const [contractTypeId, setContractTypeId] = useState('');
  const [contractEndDate, setContractEndDate] = useState('');
  const [effectiveDate, setEffectiveDate] = useState(new Date().toISOString().slice(0, 10));
  const [managerName, setManagerName] = useState('');
  const [jobTitle, setJobTitle] = useState('');
  const [notes, setNotes] = useState('');
  const [source, setSource] = useState<'manager_form' | 'lucca_email' | 'manual'>('manager_form');
  const [requestedHardware, setRequestedHardware] = useState<string[]>([]);
  const [requestedLicenses, setRequestedLicenses] = useState<string[]>([]);

  const contract = data.contractTypes.find((c) => c.id === contractTypeId);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);

    try {

      let employeeId: string | null = null;

      if (firstName && lastName) {
        const empRes = await fetch('/api/employees', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            first_name: firstName,
            last_name: lastName,
            email: email || null,
            service_id: serviceId || null,
            contract_type_id: contractTypeId || null,
            contract_end_date: contractEndDate || null,
            manager_name: managerName || null,
            job_title: jobTitle || null,
            is_active: type === 'onboarding',
          }),
        });

        if (!empRes.ok) {
          const err = await empRes.json().catch(() => ({ error: 'Erreur création salarié' }));
          throw new Error(err.error ?? 'Erreur création salarié');
        }

        const emp = await empRes.json();
        employeeId = emp.id;
      }


      const payload = {
        type,
        employee_id: employeeId,
        service_id: serviceId || null,
        contract_type_id: contractTypeId || null,
        contract_end_date: contractEndDate || null,
        effective_date: effectiveDate,
        source,
        manager_name: managerName || null,
        job_title: jobTitle || null,
        notes: notes || null,
        status: 'pending',
        created_by: user?.id ?? null,
      };

      const movRes = await fetch('/api/movements', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });

      if (!movRes.ok) {
        const err = await movRes.json().catch(() => ({ error: 'Erreur création mouvement' }));
        throw new Error(err.error ?? 'Erreur création mouvement');
      }

      const mov = await movRes.json();





      // Seed default action checklist
      const defaultActions = type === 'onboarding'
        ? [
            { action_type: 'creation' as const, label: 'Création compte AD / Microsoft', sort_order: 1 },
            { action_type: 'license_assignment' as const, label: 'Attribution licences (Office, Seiitra)', sort_order: 2 },
            { action_type: 'pc_delivery' as const, label: 'Livraison PC', sort_order: 3 },
            { action_type: 'intune_connection' as const, label: 'Connexion Intune', sort_order: 4 },
            { action_type: 'welcome_email' as const, label: 'Email de bienvenue', sort_order: 5 },
          ]
        : [
            { action_type: 'creation' as const, label: 'Demande récupération matériel', sort_order: 1 },
            { action_type: 'pc_delivery' as const, label: 'Réinstallation PC', sort_order: 2 },
            { action_type: 'license_assignment' as const, label: 'Libération licences', sort_order: 3 },
          ];

      await fetch('/api/movement-actions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(
          defaultActions.map((a) => ({
            movement_id: mov.id,
            action_type: a.action_type,
            label: a.label,
            due_date: effectiveDate,
            sort_order: a.sort_order,
          }))
        ),
      });




      // Create requested hardware items


      const requestedHardwareRows = requestedHardware
        .map((code) => {
          const cat = data.hardwareCategories.find((c) => c.code === code);

          if (!cat) return null;

          return {
            movement_id: mov.id,
            category_id: cat.id,
            status: 'requested',
          };
        })
        .filter(Boolean);

      if (requestedHardwareRows.length > 0) {
        const hwReqRes = await fetch('/api/movement-items', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(requestedHardwareRows),
        });

        if (!hwReqRes.ok) {
          const err = await hwReqRes.json().catch(() => ({ error: 'Erreur création matériels mouvement' }));
          throw new Error(err.error ?? 'Erreur création matériels mouvement');
        }
      }



      // Create requested licenses

      const requestedLicenseRows = requestedLicenses
        .map((code) => {
          const lt = data.licenseTypes.find((t) => t.code === code);

          if (!lt) return null;

          return {
            movement_id: mov.id,
            license_type_id: lt.id,
            status: 'requested',
          };
        })
        .filter(Boolean);

      if (requestedLicenseRows.length > 0) {
        const licReqRes = await fetch('/api/movement-licenses', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(requestedLicenseRows),
        });

        if (!licReqRes.ok) {
          const err = await licReqRes.json().catch(() => ({ error: 'Erreur création licences mouvement' }));
          throw new Error(err.error ?? 'Erreur création licences mouvement');
        }
      }




      await logAudit('create', 'movement', mov.id, payload, profile?.display_name);
      onSaved();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Erreur');
    } finally {
      setBusy(false);
    }
  }

  const trackedCats = data.hardwareCategories.filter((c) => c.tracked_for_person);

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4" onClick={onClose}>
      <div className="card w-full max-w-2xl max-h-[90vh] overflow-auto" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 py-4 border-b border-ink-100 sticky top-0 bg-white rounded-t-xl">
          <h2 className="text-lg font-semibold text-ink-900 flex items-center gap-2">
            {type === 'onboarding' ? <ArrowDownToLine className="w-5 h-5 text-green-600" /> : <ArrowUpFromLine className="w-5 h-5 text-amber-600" />}
            {type === 'onboarding' ? 'Nouvel onboarding' : 'Nouvel offboarding'}
          </h2>
          <button onClick={onClose} className="btn-ghost p-1.5"><X className="w-5 h-5" /></button>
        </div>

        <form onSubmit={onSubmit} className="p-5 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Prénom</label>
              <input className="input" value={firstName} onChange={(e) => setFirstName(e.target.value)} required />
            </div>
            <div>
              <label className="label">Nom</label>
              <input className="input" value={lastName} onChange={(e) => setLastName(e.target.value)} required />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Email</label>
              <input type="email" className="input" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="prenom.nom@elyade.com" />
            </div>
            <div>
              <label className="label">Poste</label>
              <input className="input" value={jobTitle} onChange={(e) => setJobTitle(e.target.value)} placeholder="ex: Gestionnaire locatif" />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Service</label>
              <select className="input" value={serviceId} onChange={(e) => setServiceId(e.target.value)}>
                <option value="">—</option>
                {data.services.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
              </select>
            </div>
            <div>
              <label className="label">Type de contrat</label>
              <select className="input" value={contractTypeId} onChange={(e) => setContractTypeId(e.target.value)}>
                <option value="">—</option>
                {data.contractTypes.map((c) => <option key={c.id} value={c.id}>{c.label}</option>)}
              </select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Date d'effet</label>
              <input type="date" className="input" value={effectiveDate} onChange={(e) => setEffectiveDate(e.target.value)} required />
            </div>
            <div>
              <label className="label">Fin de contrat {contract?.has_end_date ? '(automatique)' : ''}</label>
              <input type="date" className="input" value={contractEndDate} onChange={(e) => setContractEndDate(e.target.value)} disabled={!contract?.has_end_date && !contractTypeId} />
              {contract?.has_end_date && <p className="text-xs text-elyade-600 mt-1">Un offboarding sera généré automatiquement à cette date.</p>}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Manager</label>
              <input className="input" value={managerName} onChange={(e) => setManagerName(e.target.value)} placeholder="Nom du manager" />
            </div>
            <div>
              <label className="label">Source</label>
              <select className="input" value={source} onChange={(e) => setSource(e.target.value as typeof source)}>
                <option value="manager_form">Formulaire manager</option>
                <option value="lucca_email">Email Lucca</option>
                <option value="manual">Saisie manuelle</option>
              </select>
            </div>
          </div>

          {type === 'onboarding' && (
            <div className="p-4 rounded-lg bg-elyade-50/30 border border-elyade-100 space-y-3">
              <div>
                <label className="label">Matériel à attribuer</label>
                <div className="flex flex-wrap gap-2">
                  {trackedCats.map((c) => {
                    const checked = requestedHardware.includes(c.code);
                    return (
                      <button
                        key={c.id}
                        type="button"
                        onClick={() => setRequestedHardware((prev) => checked ? prev.filter((x) => x !== c.code) : [...prev, c.code])}
                        className={`badge cursor-pointer ${checked ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 border border-ink-200'}`}
                      >
                        {checked && <CheckCircle2 className="w-3 h-3" />}
                        {c.label}
                      </button>
                    );
                  })}
                </div>
              </div>
              <div>
                <label className="label">Licences à attribuer</label>
                <div className="flex flex-wrap gap-2">
                  {data.licenseTypes.map((lt) => {
                    const checked = requestedLicenses.includes(lt.code);
                    return (
                      <button
                        key={lt.id}
                        type="button"
                        onClick={() => setRequestedLicenses((prev) => checked ? prev.filter((x) => x !== lt.code) : [...prev, lt.code])}
                        className={`badge cursor-pointer ${checked ? 'bg-elyade-600 text-white' : 'bg-white text-ink-600 border border-ink-200'}`}
                      >
                        {checked && <CheckCircle2 className="w-3 h-3" />}
                        {lt.label}
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>
          )}

          <div>
            <label className="label">Notes</label>
            <textarea className="input min-h-[80px]" value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="Informations complémentaires…" />
          </div>

          {error && <div className="rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-sm text-red-700">{error}</div>}

          <div className="flex justify-end gap-2 pt-2">
            <button type="button" onClick={onClose} className="btn-secondary">Annuler</button>
            <button type="submit" className="btn-primary" disabled={busy}>
              <Plus className="w-4 h-4" />
              {busy ? 'Création…' : 'Créer le mouvement'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
