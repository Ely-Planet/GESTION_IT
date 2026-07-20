import { useState, type FormEvent } from 'react';
import { useAuth } from '../context/AuthContext';
import { Building2, Lock, Mail, User as UserIcon, ShieldCheck } from 'lucide-react';

export default function Login() {
  const { signIn, signUp } = useAuth();
  const [mode, setMode] = useState<'signin' | 'signup'>('signin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [displayName, setDisplayName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setBusy(true);
    if (mode === 'signin') {
      const { error } = await signIn(email, password);
      if (error) setError(error);
    } else {
      const { error } = await signUp(email, password, displayName);
      if (error) setError(error);
    }
    setBusy(false);
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-ink-50 via-elyade-50 to-ink-50 px-4">
      <div className="w-full max-w-md">
        <div className="flex flex-col items-center mb-8">
          <div className="w-16 h-16 rounded-2xl bg-elyade-600 flex items-center justify-center shadow-elevated mb-4">
            <Building2 className="w-8 h-8 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-ink-900">ELYADE IT Manager</h1>
          <p className="text-sm text-ink-500 mt-1">Gestion interne IT — Onboarding & Offboarding</p>
        </div>

        <div className="card p-6">
          <div className="flex gap-1 p-1 bg-ink-100 rounded-lg mb-6">
            <button
              type="button"
              onClick={() => setMode('signin')}
              className={`flex-1 py-2 text-sm font-medium rounded-md transition ${
                mode === 'signin' ? 'bg-white text-elyade-700 shadow-sm' : 'text-ink-500'
              }`}
            >
              Connexion
            </button>
            <button
              type="button"
              onClick={() => setMode('signup')}
              className={`flex-1 py-2 text-sm font-medium rounded-md transition ${
                mode === 'signup' ? 'bg-white text-elyade-700 shadow-sm' : 'text-ink-500'
              }`}
            >
              Créer un compte
            </button>
          </div>

          <form onSubmit={onSubmit} className="space-y-4">
            {mode === 'signup' && (
              <div>
                <label className="label" htmlFor="name">Nom complet</label>
                <div className="relative">
                  <UserIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-ink-400" />
                  <input
                    id="name"
                    className="input pl-9"
                    placeholder="Jean Dupont"
                    value={displayName}
                    onChange={(e) => setDisplayName(e.target.value)}
                    required
                  />
                </div>
              </div>
            )}
            <div>
              <label className="label" htmlFor="email">Email</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-ink-400" />
                <input
                  id="email"
                  type="email"
                  className="input pl-9"
                  placeholder="vous@elyade.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
            </div>
            <div>
              <label className="label" htmlFor="password">Mot de passe</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-ink-400" />
                <input
                  id="password"
                  type="password"
                  className="input pl-9"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  minLength={6}
                />
              </div>
            </div>

            {error && (
              <div className="rounded-lg bg-red-50 border border-red-200 px-3 py-2 text-sm text-red-700">
                {error}
              </div>
            )}

            <button type="submit" className="btn-primary w-full" disabled={busy}>
              {busy ? 'Veuillez patienter…' : mode === 'signin' ? 'Se connecter' : 'Créer le compte'}
            </button>
          </form>

          <div className="mt-6 pt-5 border-t border-ink-100 flex items-start gap-2 text-xs text-ink-500">
            <ShieldCheck className="w-4 h-4 mt-0.5 text-elyade-600 shrink-0" />
            <p>
              Utilisez votre identifiant Microsoft. Toutes les actions sont horodatées et signées
              dans le journal d'audit pour traçabilité.
            </p>
          </div>
        </div>

        <p className="text-center text-xs text-ink-400 mt-6">
          © ELYADE — Outil interne de gestion IT
        </p>
      </div>
    </div>
  );
}
