import { useEffect, useState } from 'react';
import { Building2, ShieldCheck } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Login() {
  const { signInWithMicrosoft } = useAuth();
  const [busy, setBusy] = useState(false);

  function login() {
    setBusy(true);
    signInWithMicrosoft();
  }

  useEffect(() => {
    const started = sessionStorage.getItem('gestionit_autologin_started');

    if (!started) {
      sessionStorage.setItem('gestionit_autologin_started', 'true');
      login();
    }
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-elyade-50 via-white to-ink-50 flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-elyade-600 text-white mb-5 shadow-soft">
            <Building2 className="w-8 h-8" />
          </div>

          <h1 className="text-2xl font-bold text-ink-900">
            ELYADE IT Manager
          </h1>

          <p className="text-sm text-ink-500 mt-2">
            Gestion interne IT — Onboarding & Offboarding
          </p>
        </div>

        <div className="card p-6">
          <button
            type="button"
            onClick={login}
            disabled={busy}
            className="btn-primary w-full flex items-center justify-center gap-2"
          >
            <ShieldCheck className="w-5 h-5" />
            {busy ? 'Connexion Microsoft en cours…' : 'Se connecter avec Microsoft'}
          </button>

          <div className="mt-6 border-t border-ink-100 pt-5 flex items-start gap-3 text-xs text-ink-500">
            <ShieldCheck className="w-4 h-4 text-elyade-600 shrink-0 mt-0.5" />
            <p>
              L'accès est réservé aux membres du groupe Microsoft
              <strong> 🏢 Service Informatique</strong>. Toutes les actions sont
              horodatées dans le journal d'audit.
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
