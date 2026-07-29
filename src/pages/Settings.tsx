import { useEffect, useState } from 'react';
import OnboardingHardware from './OnboardingHardware';
import MicrosoftLicenses from './MicrosoftLicenses';

type Section =
  | 'home'
  | 'workflow'
  | 'licenses'
  | 'hardware'
  | 'microsoft';

export default function Settings() {
  const [section, setSection] =
    useState<Section>('home');

  if (section === 'workflow') {
    return (
      <WorkflowSettings
        onBack={() => setSection('home')}
      />
    );
  }

if (section === 'hardware') {
  return (
    <OnboardingHardware
      onBack={() => setSection('home')}
    />
  );
}

if (section === 'microsoft') {
  return (
    <MicrosoftLicenses
      onBack={() => setSection('home')}
    />
  );
}


if (section === 'licenses') {
  return (
    <LicenseSettings
      onBack={() => setSection('home')}
    />
  );
}



  const cards = [
    {
      key: 'workflow',
      title: 'Workflow Onboarding',
      description:
        'Gestion des tâches créées automatiquement lors des onboardings'
    },
    {
      key: 'licenses',
      title: 'Licences Onboarding',
      description:
        'Licences visibles dans le formulaire Onboarding'
    },
    {
      key: 'hardware',
      title: 'Matériel Onboarding',
      description:
        'Matériel visible dans le formulaire Onboarding'
    },
    {
      key: 'microsoft',
      title: 'Licences Microsoft',
      description:
        'Licences synchronisées depuis Microsoft 365'
    }
  ];

  return (
    <div className="p-6 lg:p-8">
      <h1 className="text-2xl font-bold text-ink-900">
        Paramétrage
      </h1>

      <p className="mt-2 text-ink-500">
        Administration et configuration.
      </p>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-8">
        {cards.map(card => (
          <button
            key={card.key}

onClick={() => {
  if (card.key === 'workflow') {
    setSection('workflow');
  }

  if (card.key === 'licenses') {
    setSection('licenses');
  }

  if (card.key === 'hardware') {
    setSection('hardware');
  }

  if (card.key === 'microsoft') {
    setSection('microsoft');
  }
}}


            className="text-left bg-white rounded-xl border border-ink-100 p-5 shadow-sm hover:border-elyade-300 hover:shadow"
          >
            <h2 className="font-semibold text-ink-900">
              {card.title}
            </h2>

            <p className="text-sm text-ink-500 mt-2">
              {card.description}
            </p>
          </button>
        ))}
      </div>
    </div>
  );
}


type WorkflowTemplate = {
  id: string;
  action_type: string;
  label: string;
  sort_order: number;
  is_active: boolean;
};


function WorkflowSettings({
  onBack
}: {
  onBack: () => void;
}) {

const [rows, setRows] =
  useState<WorkflowTemplate[]>([]);

const [newLabel, setNewLabel] =
  useState('');

const [newType, setNewType] =
  useState('other');

const [newOrder, setNewOrder] =
  useState(10);


const [loading, setLoading] =
  useState(true);

async function load() {
  const res = await fetch(
    '/api/onboarding-action-templates'
  );

  const data = await res.json();

setRows(
  data.sort(
    (a: WorkflowTemplate, b: WorkflowTemplate) =>
      a.sort_order - b.sort_order
  )
);

  setLoading(false);
}

async function toggle(
  item: WorkflowTemplate
) {
  await fetch(
    `/api/onboarding-action-templates/${item.id}`,
    {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        is_active: !item.is_active
      })
    }
  );

  load();
}

useEffect(() => {
  load();
}, []); 

 return (
    <div className="p-6 lg:p-8">
      <button
        onClick={onBack}
        className="btn-secondary mb-6"
      >
        ← Retour
      </button>

      <h1 className="text-2xl font-bold text-ink-900">
        Workflow Onboarding
      </h1>

      <p className="mt-2 text-ink-500">
        Gestion des modèles de tâches.
      </p>


<div className="card p-4 mb-6">
  <h3 className="font-semibold mb-4">
    Nouvelle tâche
  </h3>

  <div className="grid grid-cols-1 md:grid-cols-4 gap-3">

    <select
      className="input"
      value={newType}
      onChange={e =>
        setNewType(e.target.value)
      }
    >
      <option value="account">
        Compte
      </option>

      <option value="groups">
        Groupes
      </option>

      <option value="license">
        Licence
      </option>

      <option value="hardware">
        Matériel
      </option>

      <option value="telephony">
        Téléphonie
      </option>

      <option value="printing">
        Impression
      </option>

      <option value="communication">
        Communication
      </option>

      <option value="other">
        Autre
      </option>
    </select>

    <input
      className="input"
      placeholder="Libellé"
      value={newLabel}
      onChange={e =>
        setNewLabel(e.target.value)
      }
    />

    <input
      type="number"
      className="input"
      value={newOrder}
      onChange={e =>
        setNewOrder(
          Number(e.target.value)
        )
      }
    />

    <button
      className="btn-primary"
      onClick={async () => {
        if (!newLabel.trim()) {
          return;
        }

        await fetch(
          '/api/onboarding-action-templates',
          {
            method: 'POST',
            headers: {
              'Content-Type':
                'application/json'
            },
            body: JSON.stringify({
              action_type: newType,
              label: newLabel,
              sort_order: newOrder,
              is_active: true
            })
          }
        );

        setNewLabel('');

        load();
      }}
    >
      Ajouter
    </button>

  </div>
</div>


{loading ? (
  <p className="mt-6">
    Chargement...
  </p>
) : (
  <div className="card overflow-hidden mt-6">
    <table className="table-base">
      <thead>
        <tr>
          <th>Ordre</th>
          <th>Type</th>
          <th>Libellé</th>
          <th>Actif</th>
	  <th>Actions</th>
      
	</tr>
      </thead>

      <tbody>
        {rows.map(row => (
          <tr key={row.id}>
            <td>{row.sort_order}</td>

            <td>{row.action_type}</td>

<td>
  <input
    className="input py-1"
    defaultValue={row.label}
    onBlur={async e => {
      if (
        e.target.value === row.label
      ) {
        return;
      }

      await fetch(
        `/api/onboarding-action-templates/${row.id}`,
        {
          method: 'PATCH',
          headers: {
            'Content-Type':
              'application/json'
          },
          body: JSON.stringify({
            label:
              e.target.value
          })
        }
      );

      load();
    }}
  />
</td>

            <td>
              <input
                type="checkbox"
                checked={row.is_active}
                onChange={() => toggle(row)}
              />
            </td>
<td>
  <div className="flex gap-1">
<button
  className="btn-ghost text-xs"
  title="Monter"
  onClick={async () => {
    const previous = rows
      .filter(r => r.sort_order < row.sort_order)
      .sort((a, b) => b.sort_order - a.sort_order)[0];

    if (!previous) return;

    await fetch(
      `/api/onboarding-action-templates/${row.id}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          sort_order: previous.sort_order
        })
      }
    );

    await fetch(
      `/api/onboarding-action-templates/${previous.id}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          sort_order: row.sort_order
        })
      }
    );

    load();
  }}
>
  ⬆️
</button>

<button
  className="btn-ghost text-xs"
  title="Descendre"
  onClick={async () => {
    const next = rows
      .filter(r => r.sort_order > row.sort_order)
      .sort((a, b) => a.sort_order - b.sort_order)[0];

    if (!next) return;

    await fetch(
      `/api/onboarding-action-templates/${row.id}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          sort_order: next.sort_order
        })
      }
    );

    await fetch(
      `/api/onboarding-action-templates/${next.id}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          sort_order: row.sort_order
        })
      }
    );

    load();
  }}
>
  ⬇️
</button>


    <button
      className="btn-ghost text-xs"
      onClick={async () => {
        const label = prompt(
          'Nouveau libellé',
          row.label
        );

        if (!label) return;

        await fetch(
          `/api/onboarding-action-templates/${row.id}`,
          {
            method: 'PATCH',
            headers: {
              'Content-Type':
                'application/json'
            },
            body: JSON.stringify({
              label
            })
          }
        );

        load();
      }}
    >
      ✏️
    </button>

    <button
      className="btn-ghost text-xs text-red-600"
      onClick={async () => {
        if (
          !confirm(
            `Supprimer "${row.label}" ?`
          )
        ) {
          return;
        }

        await fetch(
          `/api/onboarding-action-templates/${row.id}`,
          {
            method: 'DELETE'
          }
        );

        load();
      }}
    >
      🗑️
    </button>
  </div>
</td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>
)}

    </div>
  );
}
type LicenseTypeRow = {
  id: string;
  code: string;
  label: string;
  requestable_for_onboarding: boolean;
};

function LicenseSettings({
  onBack
}: {
  onBack: () => void;
}) {
  const [rows, setRows] =
    useState<LicenseTypeRow[]>([]);

  const [loading, setLoading] =
    useState(true);

  async function load() {
    const res = await fetch(
      '/api/license-types'
    );

    const data = await res.json();

    setRows(data);
    setLoading(false);
  }

  async function toggle(
    row: LicenseTypeRow
  ) {
    await fetch(
      `/api/license-types/${row.id}`,
      {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          requestable_for_onboarding:
            !row.requestable_for_onboarding
        })
      }
    );

    load();
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="p-6 lg:p-8">

      <button
        onClick={onBack}
        className="btn-secondary mb-6"
      >
        ← Retour
      </button>

      <h1 className="text-2xl font-bold text-ink-900">
        Licences Onboarding
      </h1>

      <p className="mt-2 text-ink-500">
        Sélectionnez les licences visibles
        dans le formulaire manager.
      </p>

      {loading ? (
        <p className="mt-6">
          Chargement...
        </p>
      ) : (
        <div className="card overflow-hidden mt-6">

          <table className="table-base">

            <thead>
              <tr>
                <th>Licence</th>
                <th>Code</th>
                <th>Visible</th>
              </tr>
            </thead>

            <tbody>

              {rows.map(row => (
                <tr key={row.id}>

                  <td>
                    {row.label}
                  </td>

                  <td>
                    {row.code}
                  </td>

                  <td>
                    <input
                      type="checkbox"
                      checked={
                        row.requestable_for_onboarding
                      }
                      onChange={() =>
                        toggle(row)
                      }
                    />
                  </td>

                </tr>
              ))}

            </tbody>

          </table>

        </div>
      )}

    </div>
  );
}
