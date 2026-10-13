import { useEffect, useMemo, useState, type ReactNode } from 'react';
import { CheckCircle2, Copy, UserMinus, UserPlus, X, XCircle } from 'lucide-react';
import type { Employee, Movement } from '../lib/supabase';

// Automatisation Microsoft d'une arrivée (création du compte) ou d'un départ
// (boîte partagée, désactivation). Tout passe par un récapitulatif validé par
// l'informatique ; le résultat est aussi noté dans la check-list.

type Step = { label: string; ok: boolean; error?: string; detail?: string | null };
type Group = { id: string; displayName: string; manageable?: boolean };
type License = { sku_id: string; label: string; available: number };
type Person = { id: string; name: string; upn: string };
type Missing = { api: string; permission: string };
type Mailbox = { mail: string; displayName: string; kind?: 'shared' | 'user'; unknown?: boolean };

// Même mise en forme que le serveur : « Jean-Bernard », « DUPONT », « Chef De Projet ».
const capitalize = (value: string, separators: RegExp) =>
  value
    .trim()
    .replace(/\s+/g, ' ')
    .toLocaleLowerCase('fr-FR')
    .replace(separators, (_, separator: string, letter: string) => separator + letter.toLocaleUpperCase('fr-FR'));
const formatFirstName = (value: string) => capitalize(value, /(^|[\s\-'’])(\p{L})/gu);
const formatLastName = (value: string) => value.trim().replace(/\s+/g, ' ').toLocaleUpperCase('fr-FR');
const formatJobTitle = (value: string) => capitalize(value, /(^|[\s-])(\p{L})/gu);

async function call<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, { ...init, headers: { 'Content-Type': 'application/json' } });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    const error = new Error(json.error || 'Erreur') as Error & { steps?: Step[]; missingPermissions?: Missing[] };
    error.steps = json.steps;
    error.missingPermissions = json.missingPermissions;
    throw error;
  }
  return json as T;
}

// Autorisations que Microsoft n'a pas (encore) accordées à l'application.
function MissingPermissions({ missing }: { missing?: Missing[] }) {
  if (!missing?.length) return null;
  return (
    <div className="mb-4 p-3 rounded-lg bg-amber-50 border border-amber-200 text-sm">
      <p className="font-medium text-amber-800">Autorisations manquantes pour l'application GESTION_IT :</p>
      <ul className="list-disc pl-5 mt-1 text-amber-900">
        {missing.map((m) => (
          <li key={`${m.api}-${m.permission}`}>
            <strong>{m.permission}</strong> <span className="text-amber-700">({m.api})</span>
          </li>
        ))}
      </ul>
      <p className="text-xs text-amber-700 mt-2">
        Entra → Inscriptions d'applications → GESTION_IT → Autorisations d'API : ajoutez-les en « autorisations d'application », puis
        « Accorder un consentement d'administrateur ». La prise en compte peut demander quelques minutes.
      </p>
    </div>
  );
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

// Champ de recherche avec liste de choix.
function SearchPick<T>({
  items,
  label,
  sub,
  onPick,
  placeholder,
}: {
  items: T[];
  label: (item: T) => string;
  sub?: (item: T) => string;
  onPick: (item: T) => void;
  placeholder: string;
}) {
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const matches = useMemo(() => {
    const query = q.trim().toLowerCase();
    return items.filter((item) => `${label(item)} ${sub?.(item) || ''}`.toLowerCase().includes(query)).slice(0, 30);
  }, [items, q, label, sub]);
  return (
    <div className="relative">
      <input
        className="input text-sm"
        placeholder={placeholder}
        value={q}
        onFocus={() => setOpen(true)}
        onBlur={() => setTimeout(() => setOpen(false), 150)}
        onChange={(e) => {
          setQ(e.target.value);
          setOpen(true);
        }}
      />
      {open && (
        <div className="absolute z-10 mt-1 w-full max-h-60 overflow-auto bg-white border border-ink-200 rounded-lg shadow-elevated">
          {matches.length === 0 && <p className="text-xs text-ink-400 p-2">Aucun résultat</p>}
          {matches.map((item, i) => (
            <button
              key={i}
              type="button"
              className="w-full text-left px-3 py-1.5 hover:bg-elyade-50"
              onMouseDown={(e) => e.preventDefault()}
              onClick={() => {
                onPick(item);
                setQ('');
                setOpen(false);
              }}
            >
              <span className="text-sm">{label(item)}</span>
              {sub && <span className="block text-xs text-ink-400">{sub(item)}</span>}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

function PersonField({ value, people, onChange, placeholder }: { value: Person | null; people: Person[]; onChange: (p: Person | null) => void; placeholder: string }) {
  return value ? (
    <div className="flex items-center gap-2 text-sm p-2 rounded-lg border border-ink-200 bg-white">
      <span className="flex-1">
        {value.name} <span className="text-ink-400">({value.upn})</span>
      </span>
      <button type="button" className="btn-ghost text-xs" onClick={() => onChange(null)}>Changer</button>
    </div>
  ) : (
    <SearchPick items={people} label={(p) => p.name} sub={(p) => p.upn} onPick={onChange} placeholder={placeholder} />
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
  defaultPassword: string;
  manager: Person | null;
  people: Person[];
  requestedGroups: Group[];
  groups: Group[];
  threeCx: Group | null;
  requestedSkuIds: string[];
  licenses: License[];
  sharedMailboxes: Mailbox[];
  requestedSharedMailboxes: Mailbox[];
  missingPermissions?: Missing[];
};

function CreateAccountModal({ movement, onClose, onDone }: { movement: Movement; onClose: () => void; onDone: () => void }) {
  const [preview, setPreview] = useState<Preview | null>(null);
  const [form, setForm] = useState({ givenName: '', surname: '', displayName: '', jobTitle: '', upn: '' });
  const [groups, setGroups] = useState<Group[]>([]);
  const [with3cx, setWith3cx] = useState(true);
  const [mailboxes, setMailboxes] = useState<Mailbox[]>([]);
  const [sendAs, setSendAs] = useState(true);
  const [skuIds, setSkuIds] = useState<string[]>([]);
  const [manager, setManager] = useState<Person | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<{ upn: string; temporaryPassword: string | null; steps: Step[] } | null>(null);
  const [copied, setCopied] = useState(false);
  const [missing, setMissing] = useState<Missing[] | undefined>();

  useEffect(() => {
    call<Preview>(`/api/movements/${movement.id}/microsoft-account`)
      .then((p) => {
        setPreview(p);
        setMissing(p.missingPermissions);
        setForm({ givenName: p.givenName, surname: p.surname, displayName: p.displayName, jobTitle: p.jobTitle, upn: p.upn || '' });
        setGroups(p.requestedGroups);
        setSkuIds(p.requestedSkuIds);
        setMailboxes(p.requestedSharedMailboxes.filter((box) => !box.unknown));
        setManager(p.manager);
      })
      .catch((err) => {
        setError(err.message);
        setMissing(err.missingPermissions);
      });
  }, [movement.id]);

  const addableGroups = (preview?.groups || []).filter((g) => !groups.some((x) => x.id === g.id));

  async function submit() {
    setBusy(true);
    setError(null);
    try {
      const allGroups = [...groups, ...(with3cx && preview?.threeCx ? [preview.threeCx] : [])];
      const res = await call<{ upn: string; temporaryPassword: string | null; steps: Step[] }>(`/api/movements/${movement.id}/microsoft-account`, {
        method: 'POST',
        body: JSON.stringify({ ...form, groups: allGroups, skuIds, manager, sharedMailboxes: mailboxes, sharedSendAs: sendAs }),
      });
      setResult(res);
    } catch (err: any) {
      setError(err.message);
      if (err.steps?.length) setResult({ upn: form.upn, temporaryPassword: null, steps: err.steps });
      setMissing(err.missingPermissions ?? missing);
    } finally {
      setBusy(false);
      onDone();
    }
  }

  if (result) {
    const credentials = `Adresse : ${result.upn}\nMot de passe provisoire : ${result.temporaryPassword}`;
    return (
      <Modal title="Compte Microsoft" onClose={onClose}>
        <MissingPermissions missing={missing} />
        <Steps steps={result.steps} />
        {result.temporaryPassword && (
          <div className="mt-4 p-3 rounded-lg bg-elyade-50 border border-elyade-200 text-sm">
            <p>Adresse : <strong>{result.upn}</strong></p>
            <p className="flex items-center gap-2">
              Mot de passe provisoire : <code className="font-mono bg-white px-2 py-0.5 rounded border">{result.temporaryPassword}</code>
              <button
                type="button"
                className="btn-ghost p-1"
                title="Copier les identifiants"
                onClick={() => {
                  void navigator.clipboard.writeText(credentials);
                  setCopied(true);
                }}
              >
                <Copy className="w-4 h-4" />
              </button>
              {copied && <span className="text-xs text-green-700">Copié</span>}
            </p>
            <p className="text-xs text-ink-500 mt-1">À changer à la première connexion. Le manager recevra ces identifiants par mail à la clôture de l'arrivée.</p>
          </div>
        )}
        {error && <p className="text-sm text-red-600 mt-3">{error}</p>}
        <p className="text-xs text-ink-500 mt-3">Le récapitulatif est ajouté à la check-list. Une étape en échec peut être relancée en rouvrant ce bouton.</p>
        <div className="flex justify-end mt-4">
          <button type="button" className="btn-primary text-sm" onClick={onClose}>Fermer</button>
        </div>
      </Modal>
    );
  }

  return (
    <Modal title="Créer le compte Microsoft" onClose={onClose}>
      <MissingPermissions missing={missing} />
      {!preview && !error && <p className="text-sm text-ink-500">Préparation…</p>}
      {error && !preview && <p className="text-sm text-red-600">{error}</p>}
      {preview && (
        <div className="space-y-5">
          {preview.existing ? (
            <p className="text-sm p-2 rounded bg-green-50 border border-green-200">
              Compte déjà créé : <strong>{preview.existing.upn}</strong>. Le manager, les groupes et les licences ci-dessous seront appliqués.
            </p>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <label className="text-sm">
                <span className="label">Prénom</span>
                <input
                  className="input"
                  value={form.givenName}
                  onChange={(e) => setForm({ ...form, givenName: e.target.value })}
                  onBlur={() => setForm({ ...form, givenName: formatFirstName(form.givenName) })}
                />
              </label>
              <label className="text-sm">
                <span className="label">Nom</span>
                <input
                  className="input"
                  value={form.surname}
                  onChange={(e) => setForm({ ...form, surname: e.target.value })}
                  onBlur={() => setForm({ ...form, surname: formatLastName(form.surname) })}
                />
              </label>
              <div className="text-sm">
                <span className="label">Nom affiché</span>
                <p className="py-2 font-medium">{[formatFirstName(form.givenName), formatLastName(form.surname)].filter(Boolean).join(' ')}</p>
              </div>
              <label className="text-sm">
                <span className="label">Poste</span>
                <input
                  className="input"
                  value={form.jobTitle}
                  onChange={(e) => setForm({ ...form, jobTitle: e.target.value })}
                  onBlur={() => setForm({ ...form, jobTitle: formatJobTitle(form.jobTitle) })}
                />
              </label>
              <label className="text-sm sm:col-span-2">
                <span className="label">Adresse mail (identifiant)</span>
                <input className="input font-mono" value={form.upn} onChange={(e) => setForm({ ...form, upn: e.target.value.trim().toLowerCase() })} />
                <span className="text-xs text-ink-500">
                  Format pnom@elyade.com, vérifiée libre. Mot de passe initial : <code>{preview.defaultPassword}</code> (à changer à la première connexion).
                </span>
              </label>
            </div>
          )}

          <div>
            <p className="label">Manager</p>
            <PersonField value={manager} people={preview.people} onChange={setManager} placeholder="Rechercher le manager…" />
            <p className="text-xs text-ink-500 mt-1">Par défaut le demandeur ; il reçoit le mail de fin d'arrivée.</p>
          </div>

          <div>
            <p className="label">Groupes Microsoft</p>
            <div className="flex flex-wrap gap-1.5 mb-2">
              {groups.length === 0 && <span className="text-sm text-ink-400">Aucun groupe.</span>}
              {groups.map((g) => (
                <span key={g.id} className="badge bg-ink-100 text-ink-700">
                  {g.displayName}
                  <button type="button" className="ml-1 text-ink-400 hover:text-red-600" title="Retirer" onClick={() => setGroups(groups.filter((x) => x.id !== g.id))}>
                    <X className="w-3 h-3" />
                  </button>
                </span>
              ))}
            </div>
            <SearchPick
              items={addableGroups}
              label={(g) => g.displayName}
              onPick={(g) => setGroups([...groups, g])}
              placeholder="Ajouter un groupe (🏢 service, 🔐 sécurité)…"
            />
            {preview.threeCx ? (
              <div className="mt-2">
                <Check checked={with3cx} onChange={setWith3cx}>
                  Téléphonie 3CX ({preview.threeCx.displayName}) : le poste est créé par la synchro Microsoft 365 du 3CX
                </Check>
              </div>
            ) : (
              <p className="text-xs text-ink-400 mt-2">Téléphonie 3CX : groupe non configuré (MICROSOFT_3CX_GROUP_ID).</p>
            )}
          </div>

          <div>
            <p className="label">Licences Microsoft</p>
            <div className="space-y-1">
              {preview.licenses.map((l) => (
                <Check
                  key={l.sku_id}
                  checked={skuIds.includes(l.sku_id)}
                  onChange={(on) => setSkuIds(on ? [...skuIds, l.sku_id] : skuIds.filter((id) => id !== l.sku_id))}
                >
                  {l.label}{' '}
                  <span className={l.available > 0 ? 'text-ink-400' : 'text-red-600'}>
                    ({l.available > 0 ? `${l.available} disponible${l.available > 1 ? 's' : ''}` : 'aucune disponible'})
                  </span>
                  {preview.requestedSkuIds.includes(l.sku_id) && <span className="badge bg-elyade-50 text-elyade-700 ml-1">demandée</span>}
                </Check>
              ))}
            </div>
          </div>

          <div>
            <p className="label">Boîtes mail (délégation) : partagées ou utilisateurs</p>
            <div className="flex flex-wrap gap-1.5 mb-2">
              {mailboxes.length === 0 && <span className="text-sm text-ink-400">Aucune boîte.</span>}
              {mailboxes.map((box) => (
                <span key={box.mail} className="badge bg-ink-100 text-ink-700" title={box.mail}>
                  {box.kind === 'user' ? '👤 ' : ''}{box.displayName}
                  <button
                    type="button"
                    className="ml-1 text-ink-400 hover:text-red-600"
                    title="Retirer"
                    onClick={() => setMailboxes(mailboxes.filter((x) => x.mail !== box.mail))}
                  >
                    <X className="w-3 h-3" />
                  </button>
                </span>
              ))}
            </div>
            {preview.requestedSharedMailboxes.some((box) => box.unknown) && (
              <p className="text-xs text-amber-700 mb-2">
                Demandées mais introuvables :{' '}
                {preview.requestedSharedMailboxes.filter((box) => box.unknown).map((box) => box.mail).join(', ')}
              </p>
            )}
            <SearchPick
              items={preview.sharedMailboxes.filter((box) => !mailboxes.some((x) => x.mail === box.mail))}
              label={(box) => box.displayName}
              sub={(box) => `${box.mail}${box.kind === 'user' ? ' · boîte utilisateur' : ' · boîte partagée'}`}
              onPick={(box) => setMailboxes([...mailboxes, box])}
              placeholder="Ajouter une boîte partagée ou utilisateur…"
            />
            <div className="mt-2">
              <Check checked={sendAs} onChange={setSendAs}>Autoriser aussi l'envoi de mails au nom de ces boîtes (« en tant que »)</Check>
            </div>
          </div>

          <p className="text-xs text-ink-500">À faire à la main : PaperCut, matériel.</p>
          {error && <p className="text-sm text-red-600">{error}</p>}
          <div className="flex justify-end gap-2">
            <button type="button" className="btn-ghost text-sm" onClick={onClose}>Annuler</button>
            <button type="button" className="btn-primary text-sm" disabled={busy || (!preview.existing && !form.upn)} onClick={() => void submit()}>
              {busy ? 'En cours…' : preview.existing ? 'Appliquer' : 'Créer le compte'}
            </button>
          </div>
        </div>
      )}
    </Modal>
  );
}

// ---------------------------------------------------------------------------
// Départ : boîte partagée et désactivation
// ---------------------------------------------------------------------------
type OffPreview = {
  user: { id: string; displayName: string; upn: string; accountEnabled: boolean } | null;
  licenses?: { skuId: string; label: string }[];
  groups?: Group[];
  people?: Person[];
  managerUpn?: string | null;
  missingPermissions?: Missing[];
};

function OffboardModal({ movement, onClose, onDone }: { movement: Movement; onClose: () => void; onDone: () => void }) {
  const [preview, setPreview] = useState<OffPreview | null>(null);
  const [options, setOptions] = useState({
    withReply: true,
    convertToShared: true,
    sendAs: false,
    block: true,
    revokeSessions: true,
    removeGroups: true,
    removeLicenses: true,
  });
  const [reply, setReply] = useState('');
  const [delegate, setDelegate] = useState<Person | null>(null);
  const [missing, setMissing] = useState<Missing[] | undefined>();
  const [forward, setForward] = useState<{ on: boolean; person: Person | null; email: string }>({ on: false, person: null, email: '' });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [steps, setSteps] = useState<Step[] | null>(null);

  useEffect(() => {
    call<OffPreview>(`/api/movements/${movement.id}/microsoft-offboarding`)
      .then((p) => {
        setPreview(p);
        setMissing(p.missingPermissions);
        // Délégation proposée au manager, modifiable.
        const manager = p.people?.find((x) => x.upn?.toLowerCase() === p.managerUpn?.toLowerCase());
        if (manager) setDelegate(manager);
      })
      .catch((err) => {
        setError(err.message);
        setMissing(err.missingPermissions);
      });
  }, [movement.id]);

  const set = (key: keyof typeof options) => (value: boolean) => setOptions({ ...options, [key]: value });
  const manageable = (preview?.groups || []).filter((g) => g.manageable);
  const others = (preview?.groups || []).filter((g) => !g.manageable);
  const missingReply = options.withReply && !reply.trim();
  const missingForward = forward.on && !forward.person && !forward.email.trim();

  async function submit() {
    if (!confirm(`Lancer le départ du compte Microsoft de ${preview?.user?.displayName} ?`)) return;
    setBusy(true);
    setError(null);
    try {
      const res = await call<{ steps: Step[] }>(`/api/movements/${movement.id}/microsoft-offboarding`, {
        method: 'POST',
        body: JSON.stringify({
          autoReply: options.withReply ? reply : '',
          convertToShared: options.convertToShared,
          delegate: options.convertToShared ? delegate : null,
          sendAs: options.sendAs,
          forwardTo: forward.on ? forward.person?.upn || forward.email.trim() : '',
          block: options.block,
          revokeSessions: options.revokeSessions,
          removeGroups: options.removeGroups,
          removeLicenses: options.removeLicenses && options.convertToShared,
        }),
      });
      setSteps(res.steps);
    } catch (err: any) {
      setError(err.message);
      if (err.steps?.length) setSteps(err.steps);
      setMissing(err.missingPermissions ?? missing);
    } finally {
      setBusy(false);
      onDone();
    }
  }

  if (steps) {
    return (
      <Modal title="Départ : compte Microsoft" onClose={onClose}>
        <MissingPermissions missing={missing} />
        <Steps steps={steps} />
        {error && <p className="text-sm text-red-600 mt-3">{error}</p>}
        <p className="text-xs text-ink-500 mt-3">Le récapitulatif est ajouté à la check-list.</p>
        <div className="flex justify-end mt-4">
          <button type="button" className="btn-primary text-sm" onClick={onClose}>Fermer</button>
        </div>
      </Modal>
    );
  }

  return (
    <Modal title="Départ : compte Microsoft" onClose={onClose}>
      <MissingPermissions missing={missing} />
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
            <Check checked={options.withReply} onChange={set('withReply')}>Réponse automatique</Check>
            {options.withReply && (
              <textarea
                className="input text-sm"
                rows={5}
                placeholder="Texte de la réponse automatique (obligatoire)"
                value={reply}
                onChange={(e) => setReply(e.target.value)}
              />
            )}
          </div>

          <div className="space-y-2">
            <Check checked={options.convertToShared} onChange={set('convertToShared')}>Convertir la boîte mail en boîte partagée</Check>
            {options.convertToShared && (
              <div className="pl-6 space-y-2">
                <p className="text-xs text-ink-500">Personne qui aura la délégation (accès complet à la boîte) :</p>
                <PersonField value={delegate} people={preview.people || []} onChange={setDelegate} placeholder="Rechercher la personne…" />
                <Check checked={options.sendAs} onChange={set('sendAs')} disabled={!delegate}>Lui permettre aussi d'envoyer des mails au nom de cette boîte</Check>
              </div>
            )}
          </div>

          <div className="space-y-2">
            <Check checked={forward.on} onChange={(on) => setForward({ ...forward, on })}>Transférer les mails reçus</Check>
            {forward.on && (
              <div className="pl-6 space-y-2">
                <PersonField
                  value={forward.person}
                  people={preview.people || []}
                  onChange={(person) => setForward({ ...forward, person, email: '' })}
                  placeholder="Rechercher un collaborateur…"
                />
                {!forward.person && (
                  <input
                    className="input text-sm"
                    type="email"
                    placeholder="…ou saisir une adresse (externe possible)"
                    value={forward.email}
                    onChange={(e) => setForward({ ...forward, email: e.target.value })}
                  />
                )}
                <p className="text-xs text-ink-500">Une copie reste dans la boîte. Le transfert vers l'extérieur peut être bloqué par la stratégie anti-spam Microsoft.</p>
              </div>
            )}
          </div>

          <div className="space-y-2">
            <Check checked={options.block} onChange={set('block')}>Bloquer la connexion</Check>
            <Check checked={options.revokeSessions} onChange={set('revokeSessions')}>Déconnecter toutes les sessions (ordinateurs, téléphones, Teams…)</Check>
            <Check checked={options.removeGroups} onChange={set('removeGroups')} disabled={manageable.length === 0}>
              Retirer des groupes ({manageable.length})
              {manageable.length > 0 && <span className="block text-xs text-ink-500">{manageable.map((g) => g.displayName).join(', ')}</span>}
              {others.length > 0 && <span className="block text-xs text-ink-400">À retirer dans Exchange / l'AD : {others.map((g) => g.displayName).join(', ')}</span>}
            </Check>
            <Check checked={options.removeLicenses && options.convertToShared} onChange={set('removeLicenses')} disabled={!preview.licenses?.length || !options.convertToShared}>
              Retirer les licences Microsoft ({preview.licenses?.map((l) => l.label).join(', ') || 'aucune'})
              <span className="block text-xs text-ink-500">
                {options.convertToShared
                  ? 'Une boîte partagée n’a pas besoin de licence. Les licences ne sont retirées que si la conversion réussit.'
                  : 'Impossible sans boîte partagée : la boîte mail serait supprimée au bout de 30 jours.'}
              </span>
            </Check>
          </div>

          {missingReply && <p className="text-xs text-amber-700">Saisissez le texte de la réponse automatique, ou décochez-la.</p>}
          <div className="flex justify-end gap-2">
            <button type="button" className="btn-ghost text-sm" onClick={onClose}>Annuler</button>
            <button type="button" className="btn-primary text-sm" disabled={busy || missingReply || missingForward} onClick={() => void submit()}>
              {busy ? 'En cours…' : 'Valider le départ'}
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
          <UserMinus className="w-4 h-4" /> Départ : compte Microsoft
        </button>
        {open && <OffboardModal movement={movement} onClose={() => setOpen(false)} onDone={onDone} />}
      </>
    );
  }

  return null;
}
