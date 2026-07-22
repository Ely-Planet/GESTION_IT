export default function Settings() {
  const cards = [
    {
      title: 'Licences Microsoft',
      description: 'Gestion des licences synchronisées depuis Microsoft 365'
    },
    {
      title: 'Licences Onboarding',
      description: 'Licences visibles dans les formulaires managers'
    },
    {
      title: 'Matériel Onboarding',
      description: 'Matériel visible dans les formulaires managers'
    },
    {
      title: 'Services Microsoft',
      description: 'Groupes Microsoft 🏢 utilisables dans les onboarding'
    },
    {
      title: 'Workflow Onboarding',
      description: 'Règles automatiques d’attribution'
    }
  ];

  return (
    <div className="p-6 lg:p-8">
      <h1 className="text-2xl font-bold text-ink-900">
        Paramétrage
      </h1>

      <p className="mt-2 text-ink-500">
        Administration et configuration de l'application.
      </p>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-8">
        {cards.map((card) => (
          <div
            key={card.title}
            className="bg-white rounded-xl border border-ink-100 p-5 shadow-sm"
          >
            <h2 className="font-semibold text-ink-900">
              {card.title}
            </h2>

            <p className="text-sm text-ink-500 mt-2">
              {card.description}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}
