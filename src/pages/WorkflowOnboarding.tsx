import { useEffect, useState } from 'react';

type Template = {
  id: string;
  action_type: string;
  label: string;
  sort_order: number;
  is_active: boolean;
};

export default function WorkflowOnboarding() {
  const [templates, setTemplates] = useState<Template[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    setLoading(true);

    const data = await fetch(
      '/api/onboarding-action-templates'
    )
      .then(r => r.json())
      .catch(() => []);

    setTemplates(data);
    setLoading(false);
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="p-6 lg:p-8">
      <h1 className="text-2xl font-bold text-ink-900">
        Workflow Onboarding
      </h1>

      <p className="mt-2 text-ink-500">
        Gestion des tâches créées automatiquement lors d'un onboarding.
      </p>

      <div className="mt-8 bg-white rounded-xl border border-ink-100 overflow-hidden">
        <table className="table-base">
          <thead>
            <tr>
              <th>Ordre</th>
              <th>Type</th>
              <th>Libellé</th>
              <th>Actif</th>
            </tr>
          </thead>

          <tbody>
            {loading ? (
              <tr>
                <td colSpan={4}>
                  Chargement...
                </td>
              </tr>
            ) : (
              templates.map(t => (
                <tr key={t.id}>
                  <td>{t.sort_order}</td>
                  <td>{t.action_type}</td>
                  <td>{t.label}</td>
                  <td>{t.is_active ? '✅' : '❌'}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
``
