import { useEffect, useState, type ReactNode } from 'react';
import { CheckCircle2, Copy, UserMinus, UserPlus, X, XCircle } from 'lucide-react';
import type { Employee, Movement } from '../lib/supabase';

// Automatisation Microsoft d'une arrivée (création du compte) ou d'un départ
// (désactivation). Tout passe par un récapitulatif validé par l'informatique.

type Step = { label: string; ok: boolean; error?: string; detail?: string | null };
type Group = { id: string; displayName: string; missing?: boolean; manageable?: boolean };
type License = { sku_id: string; label: string; available: number };

async function call<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, { ...init, headers: { 'Content-Type': 'application/json' } });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    const error = new Error(json.error || 'Erreur') as Error & { steps?: Step[] };
    error.steps = json.steps;
    throw error;
  }
  return json as T;
}

function Modal({ title, onClose, children }: { title: string; onClose: () => void; children: ReactNode }) {
  return (
    <div className="fixed inset-0 z-50 bg-ink-950/40 flex items-start justify-center overflow-y-auto p-4" onClick={onClose}>
      <div className="card w-full max-w-2xl my-8 p-5" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-ink-900">{title}</h3>
          <button type="button" className="btn-ghost p-1.5" onClick={onClose} aria-label="Fermer">
            <X className="w-4 h-4" />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

function Steps({ steps }: { steps: Step[] }) {
  return (
    <ul className="space-y-1.5">
      {steps.map((s, i) => (
        <li key={i} className="flex items-start gap-2 text-sm">
          {s.ok ? <CheckCircle2 className="w-4 h-4 text-green-600 mt-0.5 shrink-0" /> : <XCircle className="w-4 h-4 text-red-600 mt-0.5 shrink-0" />}
          <span>
            {s.label}
            {s.detail && <span className="text-ink-400"> ({s.detail})</span>}
            {s.error && <span className="block text-xs text-red-600">{s.error}</span>}
          </span>
        </li>
      ))}
    </ul>
  );
}

function Check({ checked, onChange, children, disabled }: { checked: boolean; onChange: (v: boolean) => void; children: ReactNode; disabled?: boolean }) {
  return (
    <label className={`flex items-start gap-2 text-sm ${disabled ? 'opacity-50' : ''}`}>
      <input type="checkbox" className="mt-1" checked={checked} disabled={disabled} onChange={(e) => onChange(e.target.checked)} />
      <span>{children}</span>
    </label>
  );
}

// ---------------------------------------------------------------------------
// Arrivée : création du compte
// ---------------------------------------------------------------------------
type Preview = {
  existing: { id: string; upn: string } | null;
  givenName: string;
  surname: string;
  displayName: string;
  jobTitle: string;
  upn: string | null;
  domain: string;
  manager: { id: string; displayName: string; upn: string } | null;
  managerName: string | null;
  groups: Group[];
  threeCx: Group | null;
  licenses: License[];
};

function CreateAccountModal({ movement, onClose, onDone }: { movement: Movement; onClose: () => void; onDone: () => void }) {
  const [preview, setPreview] = useState<Preview | null>(null);
  const [form, setForm] = useState({ givenName: '', surname: '', displayName: '', jobTitle: '', upn: '' });
  const [groupIds, setGroupIds] = useState<string[]>([]);
  const [skuIds, setSkuIds] = useState<string[]>([]);
  const [withManager, setWithManager] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<{ upn: string; temporaryPassword: string | null; steps: Step[] } | null>(null);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    call<Preview>(`/api/movements/${movement.id}/microsoft-account`)
      .then((p) => {
        setPreview(p);
        setForm({ givenName: p.givenName, surname: p.surname, displayName: p.displayName, jobTitle: p.jobTitle, upn: p.upn || '' });
        setGroupIds([...p.groups.map((g) => g.id), ...(p.threeCx && !p.threeCx.missing ? [p.threeCx.id] : [])]);
        setSkuIds(p.licenses.map((l) => l.sku_id));
      })
      .catch((err) => setError(err.message));
  }, [movement.id]);

  const toggle = (list: string[], set: (v: string[]) => void, id: string, on: boolean) =>
    set(on ? [...list, id] : list.filter((x) => x !== id));

  async function submit() {
    setBusy(true);
    setError(null);
    try {
      const res = await call<{ upn: string; temporaryPassword: string | null; steps: Step[] }>(`/api/movements/${movement.id}/microsoft-account`, {
        method: 'POST',
        body: JSON.stringify({ ...form, groupIds, skuIds, managerId: withManager ? preview?.manager?.id : null }),
      });
      setResult(res);
      onDone();
    } catch (err: any) {
      setError(err.message);
      if (err.steps?.length) setResult({ upn: form.upn, temporaryPassword: null, steps: err.steps });
    } finally {
      setBusy(false);
    }
  }

  if (result) {
    return (
      <Modal title="Compte Microsoft" onClose={onClose}>
        <Steps steps={result.steps} />
        {result.temporaryPassword && (
          <div className="mt-4 p-3 rounded-lg bg-elyade-50 border border-elyade-200">
            <p className="text-sm text-ink-700 mb-2">
              Identifiants à transmettre au manager (le mot de passe ne sera <strong>plus affiché</strong> ensuite) :
            </p>
            <p className="text-sm">Adresse : <strong>{result.upn}</strong></p>
            <p className="text-sm flex items-center gap-2">
              Mot de passe provisoire : <code className="font-mono bg-white px-2 py-0.5 rounded border">{result.temporaryPassword}</code>
              <button
                type="button"
                className="btn-ghost p-1"
                title="Copier"
                onClick={() => {
                  void navigator.clipboard.writeText(`Adresse : ${result.upn}\nMot de passe provisoire : ${result.temporaryPassword}`);
                  setCopied(true);
                }}
              >
                <Copy className="w-4 h-4" />
              </button>
              {copied && <span className="text-xs text-green-700">Copié</span>}
            </p>
            <p className="text-xs text-ink-500 mt-2">Le collaborateur devra choisir son propre mot de passe à la première connexion.</p>
          </div>
        )}
        {error && <p className="text-sm text-red-600 mt-3">{error}</p>}
        <p className="text-xs text-ink-500 mt-3">
          Une étape en échec peut être relancée : rouvrez « Créer le compte Microsoft », le compte existant est repris.
        </p>
        <div className="flex justify-end mt-4">
          <button type="button" className="btn-primary text-sm" onClick={onClose}>Fermer</button>
        </div>
      </Modal>
    );
  }

  return (
    <Modal title="Créer le compte Microsoft" onClose={onClose}>
      {!preview && !error && <p className="text-sm text-ink-500">Préparation…</p>}
      {error && !preview && <p className="text-sm text-red-600">{error}</p>}
      {preview && (
        <div className="space-y-4">
          {preview.existing ? (
            <p className="text-sm p-2 rounded bg-green-50 border border-green-200">
              Compte déjà créé : <strong>{preview.existing.upn}</strong>. Seuls les groupes et licences cochés seront (re)appliqués.
            </p>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <label className="text-sm">
                <span className="label">Prénom</span>
                <input className="input" value={form.givenName} onChange={(e) => setForm({ ...form, givenName: e.target.value })} />
              </label>
              <label className="text-sm">
                <span className="label">Nom</span>
                <input className="input" value={form.surname} onChange={(e) => setForm({ ...form, surname: e.target.value })} />
              </label>
              <label className="text-sm">
                <span className="label">Nom affiché</span>
                <input className="input" value={form.displayName} onChange={(e) => setForm({ ...form, displayName: e.target.value })} />
              </label>
              <label className="text-sm">
                <span className="label">Fonction</span>
                <input className="input" value={form.jobTitle} onChange={(e) => setForm({ ...form, jobTitle: e.target.value })} />
              </label>
              <label className="text-sm sm:col-span-2">
                <span className="label">Adresse (identifiant de connexion)</span>
                <input className="input font-mono" value={form.upn} onChange={(e) => setForm({ ...form, upn: e.target.value.trim().toLowerCase() })} />
                <span className="text-xs text-ink-500">Proposée libre dans Microsoft 365 ; modifiable (homonymes, nom composé…).</span>
              </label>
            </div>
          )}

          <div>
            <p className="label">Manager</p>
            {preview.manager ? (
              <Check checked={withManager} onChange={setWithManager}>
                {preview.manager.displayName} <span className="text-ink-400">({preview.manager.upn})</span>
              </Check>
            ) : (
              <p className="text-sm text-ink-500">{preview.managerName ? `${preview.managerName} : compte Microsoft introuvable` : 'Non renseigné'}</p>
            )}
          </div>

          <div>
            <p className="label">Groupes</p>
            <div className="space-y-1">
              {preview.groups.length === 0 && !preview.threeCx && <p className="text-sm text-ink-500">Aucun groupe demandé.</p>}
              {preview.groups.map((g) => (
                <Check key={g.id} checked={groupIds.includes(g.id)} onChange={(on) => toggle(groupIds, setGroupIds, g.id, on)}>
                  {g.displayName}
                </Check>
              ))}
              {preview.threeCx && (
                <Check
                  checked={groupIds.includes(preview.threeCx.id)}
                  disabled={preview.threeCx.missing}
                  onChange={(on) => toggle(groupIds, setGroupIds, preview.threeCx!.id, on)}
                >
                  Téléphonie 3CX : {preview.threeCx.displayName}
                  <span className="block text-xs text-ink-500">Le poste est créé par la synchronisation Microsoft 365 du 3CX.</span>
                </Check>
              )}
              {!preview.threeCx && (
                <p className="text-xs text-ink-400">Téléphonie 3CX : groupe non configuré (variable MICROSOFT_3CX_GROUP_ID).</p>
              )}
            </div>
          </div>

          <div>
            <p className="label">Licences Microsoft</p>
            <div className="space-y-1">
              {preview.licenses.length === 0 && <p className="text-sm text-ink-500">Aucune licence Microsoft demandée.</p>}
              {preview.licenses.map((l) => (
                <Check key={l.sku_id} checked={skuIds.includes(l.sku_id)} onChange={(on) => toggle(skuIds, setSkuIds, l.sku_id, on)}>
                  {l.label}{' '}
                  <span className={l.available > 0 ? 'text-ink-400' : 'text-red-600'}>
                    ({l.available > 0 ? `${l.available} disponible${l.available > 1 ? 's' : ''}` : 'aucune disponible'})
                  </span>
                </Check>
              ))}
            </div>
          </div>

          <p className="text-xs text-ink-500">
            Restent à faire à la main : accès aux boîtes partagées, PaperCut, matériel. Les étapes réussies sont cochées dans la check-list.
          </p>
          {error && <p className="text-sm text-red-600">{error}</p>}
          <div className="flex justify-end gap-2">
            <button type="button" className="btn-ghost text-sm" onClick={onClose}>Annuler</button>
            <button type="button" className="btn-primary text-sm" disabled={busy || (!preview.existing && !form.upn)} onClick={() => void submit()}>
              {busy ? 'Création en cours…' : preview.existing ? 'Appliquer' : 'Créer le compte'}
            </button>
          </div>
        </div>
      )}
    </Modal>
  );
}

// ---------------------------------------------------------------------------
// Départ : désactivation
// ---------------------------------------------------------------------------
type OffPreview = {
  user: { id: string; displayName: string; upn: string; accountEnabled: boolean } | null;
  licenses?: { skuId: string; label: string }[];
  groups?: Group[];
  defaultReply?: string;
};

function OffboardModal({ movement, onClose, onDone }: { movement: Movement; onClose: () => void; onDone: () => void }) {
  const [preview, setPreview] = useState<OffPreview | null>(null);
  const [options, setOptions] = useState({ block: true, revokeSessions: true, removeGroups: true, removeLicenses: false, withReply: true });
  const [reply, setReply] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [steps, setSteps] = useState<Step[] | null>(null);

  useEffect(() => {
    call<OffPreview>(`/api/movements/${movement.id}/microsoft-offboarding`)
      .then((p) => {
        setPreview(p);
        setReply(p.defaultReply || '');
      })
      .catch((err) => setError(err.message));
  }, [movement.id]);

  async function submit() {
    if (!confirm(`Désactiver le compte Microsoft de ${preview?.user?.displayName} ?`)) return;
    setBusy(true);
    setError(null);
    try {
      const res = await call<{ steps: Step[] }>(`/api/movements/${movement.id}/microsoft-offboarding`, {
        method: 'POST',
        body: JSON.stringify({
          block: options.block,
          revokeSessions: options.revokeSessions,
          removeGroups: options.removeGroups,
          removeLicenses: options.removeLicenses,
          autoReply: options.withReply ? reply : '',
        }),
      });
      setSteps(res.steps);
      onDone();
    } catch (err: any) {
      setError(err.message);
      if (err.steps?.length) setSteps(err.steps);
    } finally {
      setBusy(false);
    }
  }

  const set = (key: keyof typeof options) => (value: boolean) => setOptions({ ...options, [key]: value });
  const manageable = (preview?.groups || []).filter((g) => g.manageable);
  const others = (preview?.groups || []).filter((g) => !g.manageable);

  if (steps) {
    return (
      <Modal title="Désactivation du compte Microsoft" onClose={onClose}>
        <Steps steps={steps} />
        {error && <p className="text-sm text-red-600 mt-3">{error}</p>}
        <div className="flex justify-end mt-4">
          <button type="button" className="btn-primary text-sm" onClick={onClose}>Fermer</button>
        </div>
      </Modal>
    );
  }

  return (
    <Modal title="Désactiver le compte Microsoft" onClose={onClose}>
      {!preview && !error && <p className="text-sm text-ink-500">Recherche du compte…</p>}
      {error && <p className="text-sm text-red-600 mb-3">{error}</p>}
      {preview && !preview.user && <p className="text-sm text-amber-700">Aucun compte Microsoft trouvé pour ce collaborateur. Associez-le d'abord.</p>}
      {preview?.user && (
        <div className="space-y-4">
          <p className="text-sm">
            <strong>{preview.user.displayName}</strong> <span className="text-ink-500">({preview.user.upn})</span>
            {!preview.user.accountEnabled && <span className="badge bg-ink-100 text-ink-600 ml-2">Déjà bloqué</span>}
          </p>

          <div className="space-y-2">
            <Check checked={options.withReply} onChange={set('withReply')}>Activer une réponse automatique</Check>
            {options.withReply && <textarea className="input text-sm" rows={5} value={reply} onChange={(e) => setReply(e.target.value)} />}
            <Check checked={options.block} onChange={set('block')}>Bloquer la connexion</Check>
            <Check checked={options.revokeSessions} onChange={set('revokeSessions')}>Déconnecter toutes les sessions (ordinateurs, téléphones, Teams…)</Check>
            <Check checked={options.removeGroups} onChange={set('removeGroups')} disabled={manageable.length === 0}>
              Retirer des groupes ({manageable.length})
              {manageable.length > 0 && <span className="block text-xs text-ink-500">{manageable.map((g) => g.displayName).join(', ')}</span>}
              {others.length > 0 && (
                <span className="block text-xs text-ink-400">
                  À retirer dans Exchange / l'AD : {others.map((g) => g.displayName).join(', ')}
                </span>
              )}
            </Check>
            <Check checked={options.removeLicenses} onChange={set('removeLicenses')} disabled={!preview.licenses?.length}>
              Retirer les licences Microsoft ({preview.licenses?.map((l) => l.label).join(', ') || 'aucune'})
              <span className="block text-xs text-amber-700">
                Attention : sans licence, la boîte mail est supprimée au bout de 30 jours. Convertissez-la d'abord en boîte partagée dans Exchange si elle doit être conservée.
              </span>
            </Check>
          </div>

          <div className="flex justify-end gap-2">
            <button type="button" className="btn-ghost text-sm" onClick={onClose}>Annuler</button>
            <button type="button" className="btn-primary text-sm" disabled={busy} onClick={() => void submit()}>
              {busy ? 'En cours…' : 'Désactiver'}
            </button>
          </div>
        </div>
      )}
    </Modal>
  );
}

// ---------------------------------------------------------------------------
// Bouton affiché dans le panneau « Compte Microsoft associé »
// ---------------------------------------------------------------------------
export default function MicrosoftAutomation({
  movement,
  employee,
  onDone,
}: {
  movement: Movement;
  employee: Employee | undefined;
  onDone: () => void;
}) {
  const [open, setOpen] = useState(false);
  if (movement.status === 'cancelled') return null;

  if (movement.type === 'onboarding') {
    return (
      <>
        <button type="button" className="btn-secondary text-sm" onClick={() => setOpen(true)}>
          <UserPlus className="w-4 h-4" /> {employee?.microsoft_object_id ? 'Compléter le compte Microsoft' : 'Créer le compte Microsoft'}
        </button>
        {open && <CreateAccountModal movement={movement} onClose={() => setOpen(false)} onDone={onDone} />}
      </>
    );
  }

  if (movement.type === 'offboarding' && employee) {
    return (
      <>
        <button type="button" className="btn-secondary text-sm" onClick={() => setOpen(true)}>
          <UserMinus className="w-4 h-4" /> Désactiver le compte Microsoft
        </button>
        {open && <OffboardModal movement={movement} onClose={() => setOpen(false)} onDone={onDone} />}
      </>
    );
  }

  return null;
}
