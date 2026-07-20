import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';

type MicrosoftUser = {
  id: string;
  displayName: string;
  email: string;
  userPrincipalName: string;
};

type Profile = {
  id: string;
  email: string;
  display_name: string;
  role: string;
};

type AuthContextValue = {
  session: boolean;
  user: MicrosoftUser | null;
  profile: Profile | null;
  loading: boolean;
  signInWithMicrosoft: () => void;
  signOut: () => Promise<void>;
};

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<MicrosoftUser | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  async function loadMe() {
    try {
      const res = await fetch('/api/me', {
        credentials: 'include'
      });

      if (!res.ok) {
        setUser(null);
        setProfile(null);
        return;
      }

      const data = await res.json();

      if (data.authenticated && data.user) {
        setUser(data.user);
        setProfile({
          id: data.user.id,
          email: data.user.email,
          display_name: data.user.displayName,
          role: 'service_informatique'
        });
      } else {
        setUser(null);
        setProfile(null);
      }
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void loadMe();
  }, []);

  function signInWithMicrosoft() {
    window.location.href = '/auth/login';
  }

  async function signOut() {
    await fetch('/auth/logout', {
      method: 'POST',
      credentials: 'include'
    });

    setUser(null);
    setProfile(null);
    window.location.href = '/';
  }

  return (
    <AuthContext.Provider
      value={{
        session: Boolean(user),
        user,
        profile,
        loading,
        signInWithMicrosoft,
        signOut
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
