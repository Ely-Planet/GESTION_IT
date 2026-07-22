import { type FormEvent, useEffect, useState } from 'react';

type Service = {
  id: string;
  displayName: string;
  mail: string | null;
};

type Hardware = {
  id: string;
  code: string;
  label: string;
  requestable_for_onboarding: boolean;
};

type License = {
  id: string;
  code: string;
  label: string;
};

export default function OnboardingRequest() {
  const [services, setServices] = useState<Service[]>([]);
  const [hardware, setHardware] = useState<Hardware[]>([]);
  const [licenses, setLicenses] = useState<License[]>([]);

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [jobTitle, setJobTitle] = useState('');
  const [effectiveDate, setEffectiveDate] = useState('');
const [selectedServices, setSelectedServices] = useState<string[]>([]);
  const [selectedHardware, setSelectedHardware] = useState<string[]>([]);
  const [selectedLicenses, setSelectedLicenses] = useState<string[]>([]);

  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      const [servicesRes, hardwareRes, licensesRes] = await Promise.all([
        fetch('/api/microsoft-onboarding-services'),
        fetch('/api/onboarding-hardware-categories'),
        fetch('/api/onboarding-license-types')
      ]);

      setServices(await servicesRes.json());
      setHardware(await hardwareRes.json());
      setLicenses(await licensesRes.json());
    }

    load();
  }, []);

  function toggleHardware(id: string, checked: boolean) {
    setSelectedHardware((prev) =>
      checked ? [...prev, id] : prev.filter((x) => x !== id)
    );
  }

  function toggleLicense(id: string, checked: boolean) {
    setSelectedLicenses((prev) =>
      checked ? [...prev, id] : prev.filter((x) => x !== id)
    );
  }

  async function submit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setSuccess(null);


    if (
  !firstName.trim() ||
  !lastName.trim() ||
  !effectiveDate ||
  selectedServices.length === 0
) {
      setError('Prénom, nom, date d’arrivée et service sont obligatoires.');
      return;
    }

    setBusy(true);

    try {
      const res = await fetch('/api/onboarding-request', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          first_name: firstName,
          last_name: lastName,
          email,
          job_title: jobTitle,
          effective_date: effectiveDate,
	  service_groups: services.filter( 
		s => selectedServices.includes(s.id)
	  ),
          hardware_category_ids: selectedHardware,
          license_type_ids: selectedLicenses
        })
      });

      const json = await res.json().catch(() => ({}));

      if (!res.ok) {
        setError(json.error ?? 'Erreur lors de la création de la demande.');
        return;
      }

      setSuccess('Demande d’onboarding créée avec succès.');

      setFirstName('');
      setLastName('');
      setEmail('');
      setJobTitle('');
      setEffectiveDate('');
      setSelectedServiceId('');
      setSelectedHardware([]);
      setSelectedLicenses([]);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue.');
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="p-6 lg:p-8 max-w-5xl mx-auto">
      <h1 className="text-2xl font-bold text-ink-900">
        Demande d&apos;onboarding
      </h1>

      <p className="text-sm text-ink-500 mt-2">
        Formulaire de demande d&apos;arrivée d&apos;un collaborateur.
      </p>

      {error && (
        <div className="mt-4 p-3 rounded-lg bg-red-50 text-red-700 text-sm border border-red-200">
          {error}
        </div>
      )}

      {success && (
        <div className="mt-4 p-3 rounded-lg bg-green-50 text-green-700 text-sm border border-green-200">
          {success}
        </div>
      )}

      <form onSubmit={submit} className="mt-8 space-y-8">
        <section className="card p-5">
          <h2 className="font-semibold text-ink-900 mb-4">
            Collaborateur
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input
              className="input"
              placeholder="Prénom"
              value={firstName}
              onChange={(e) => setFirstName(e.target.value)}
            />

            <input
              className="input"
              placeholder="Nom"
              value={lastName}
              onChange={(e) => setLastName(e.target.value)}
            />

            <input
              className="input"
              placeholder="Email personnel ou futur email professionnel"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />

            <input
              className="input"
              placeholder="Fonction"
              value={jobTitle}
              onChange={(e) => setJobTitle(e.target.value)}
            />

            <input
              type="date"
              className="input"
              value={effectiveDate}
              onChange={(e) => setEffectiveDate(e.target.value)}
            />
          </div>
        </section>

        <section className="card p-5">
          <h2 className="font-semibold text-ink-900 mb-4">
            Service Microsoft
          </h2>

<div className="grid grid-cols-1 md:grid-cols-2 gap-2">
  {services.map((service) => (
    <label
      key={service.id}
      className="flex items-center gap-2 text-sm"
    >
      <input
        type="checkbox"
        checked={selectedServices.includes(service.id)}
        onChange={(e) => {
          if (e.target.checked) {
            setSelectedServices([
              ...selectedServices,
              service.id
            ]);
          } else {
            setSelectedServices(
              selectedServices.filter(
                id => id !== service.id
              )
            );
          }
        }}
      />

      {service.displayName}
    </label>
  ))}
</div>

        </section>

        <section className="card p-5">
          <h2 className="font-semibold text-ink-900 mb-4">
            Matériel demandé
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {hardware
              .filter((item) => item.requestable_for_onboarding)
              .map((item) => (
                <label key={item.id} className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={selectedHardware.includes(item.id)}
                    onChange={(e) => toggleHardware(item.id, e.target.checked)}
                  />

                  {item.label}
                </label>
              ))}
          </div>
        </section>

        <section className="card p-5">
          <h2 className="font-semibold text-ink-900 mb-2">
            Licences complémentaires
          </h2>

          <p className="text-sm text-ink-500 mb-4">
            Microsoft 365 Business Premium sera ajouté automatiquement à chaque nouvel arrivant.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {licenses.map((license) => (
              <label key={license.id} className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={selectedLicenses.includes(license.id)}
                  onChange={(e) => toggleLicense(license.id, e.target.checked)}
                />

                {license.label}
              </label>
            ))}
          </div>
        </section>

        <div className="flex justify-end">
          <button
            type="submit"
            className="btn-primary"
            disabled={busy}
          >
            {busy ? 'Création...' : 'Créer la demande'}
          </button>
        </div>
      </form>
    </div>
  );
}
