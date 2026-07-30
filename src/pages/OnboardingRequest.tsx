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

type Employee = {
  id: string;
  first_name: string;
  last_name: string;
  email: string | null;
  microsoft_upn: string | null;
  is_active: boolean;
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
const [employees, setEmployees] = useState<Employee[]>([]);
const [firstName, setFirstName] = useState('');
const [lastName, setLastName] = useState('');
const [jobTitle, setJobTitle] = useState('');
const [sharedMailboxes, setSharedMailboxes] = useState('');
const [effectiveDate, setEffectiveDate] = useState('');
const [employeeStatus, setEmployeeStatus] = useState('');
const [employeeLevel, setEmployeeLevel] = useState('');

const [grossAnnualSalary, setGrossAnnualSalary] = useState('');
const [variableBonus, setVariableBonus] = useState('');

const [school, setSchool] = useState('');

const [isReferral, setIsReferral] = useState(false);
const [referralEmployee, setReferralEmployee] = useState('');
const [referralSearch, setReferralSearch] =
  useState('');
const [cvFile, setCvFile] = useState<File | null>(null);
const [contractType, setContractType] = useState('CDI');
const [contractEndDate, setContractEndDate] = useState('');
const stageDurationDays =
  effectiveDate && contractEndDate
    ? Math.floor(
        (
          new Date(contractEndDate).getTime() -
          new Date(effectiveDate).getTime()
        ) /
          (1000 * 60 * 60 * 24)
      )
    : 0;
const [contractReason, setContractReason] = useState('');
const [internshipMission, setInternshipMission] = useState('');

const [selectedServices, setSelectedServices] = useState<string[]>([]);
  const [selectedHardware, setSelectedHardware] = useState<string[]>([]);
  const [selectedLicenses, setSelectedLicenses] = useState<string[]>([]);

  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    async function load() {


const [
  servicesRes,
  sharedMailboxesRes,
  hardwareRes,
  licensesRes,
  employeesRes
] = await Promise.all([
  fetch('/api/microsoft-onboarding-services'),
  fetch('/api/shared-mailboxes'),
  fetch('/api/onboarding-hardware-categories'),
  fetch('/api/onboarding-license-types'),
  fetch('/api/employees')
]);


      setServices(await servicesRes.json());
      setHardware(await hardwareRes.json());
      setLicenses(await licensesRes.json());
setEmployees(await employeesRes.json());
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

const filteredReferralEmployees = employees
  .filter((employee) => employee.is_active)
  .filter((employee) =>
    `${employee.first_name} ${employee.last_name} ${employee.email ?? ''} ${employee.microsoft_upn ?? ''}`
      .toLowerCase()
      .includes(referralSearch.toLowerCase())
  )
  .sort((a, b) =>
    `${a.last_name} ${a.first_name}`.localeCompare(
      `${b.last_name} ${b.first_name}`,
      'fr'
    )
  )
  .slice(0, 15);


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
      
const formData = new FormData();

formData.append('first_name', firstName);
formData.append('last_name', lastName);
formData.append('job_title', jobTitle);
formData.append('effective_date', effectiveDate);

formData.append('contract_type', contractType);
formData.append(
  'contract_end_date',
  contractType === 'CDD' || contractType === 'Stage'
    ? contractEndDate
    : ''
);

formData.append('contract_reason', contractReason);
formData.append('internship_mission', internshipMission);

formData.append('employee_status', employeeStatus);
formData.append('employee_level', employeeLevel);
formData.append('gross_annual_salary', grossAnnualSalary);
formData.append('variable_bonus', variableBonus);

formData.append('school', school);

formData.append('referral', String(isReferral));
formData.append('referral_employee', referralEmployee);

formData.append(
  'service_groups',
  JSON.stringify(
    services.filter(
      s => selectedServices.includes(s.id)
    )
  )
);

formData.append(
  'shared_mailboxes',
  sharedMailboxes
);

formData.append(
  'hardware_category_ids',
  JSON.stringify(selectedHardware)
);

formData.append(
  'license_type_ids',
  JSON.stringify(selectedLicenses)
);

if (cvFile) {
  formData.append('cv', cvFile);
}

const res = await fetch('/api/onboarding-request', {
  method: 'POST',
  body: formData
});



      const json = await res.json().catch(() => ({}));

      if (!res.ok) {
        setError(json.error ?? 'Erreur lors de la création de la demande.');
        return;
      }

      setSuccess('Demande d’onboarding créée avec succès.');

      setFirstName('');
      setLastName('');
setJobTitle('');
setEffectiveDate('');
setContractType('CDI');
setContractEndDate('');
setContractReason('');
setInternshipMission('');
      setSelectedServices([]);
      setSelectedHardware([]);
      setSelectedLicenses([]);
setSharedMailboxes('');
setSchool('');
setVariableBonus('');
setGrossAnnualSalary('');
setEmployeeStatus('');
setEmployeeLevel('');
setReferralEmployee('');
setReferralSearch('');
setIsReferral(false);
setCvFile(null);

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

<div>
  <label className="label">
    Fonction
  </label>

  <input
    className="input"
    value={jobTitle}
    onChange={(e) => setJobTitle(e.target.value)}
    placeholder="Gestionnaire locatif"
  />
</div>


  <div>
    <label className="label">
      Date d'arrivée prévue
    </label>

    <input
      type="date"
      className="input"
      value={effectiveDate}
      onChange={(e) => setEffectiveDate(e.target.value)}
    />
  </div>

  <div>
    <label className="label">
      Contrat
    </label>

    <select
      className="input"
      value={contractType}
onChange={(e) => {
  const value = e.target.value;

  setContractType(value);

  if (value === 'Alternance') {
    setEmployeeLevel('E1');
  }
}}
    >
      <option value="CDI">CDI</option>
      <option value="CDD">CDD</option>
      <option value="Stage">Stage</option>
      <option value="Alternance">Alternance</option>
    </select>
  </div>

{contractType !== 'Stage' &&
 contractType !== 'Alternance' && (
<div>
  <label className="label">Statut</label>

  <select
    className="input"
    value={employeeStatus}
    onChange={(e) =>
      setEmployeeStatus(e.target.value)
    }
  >
    <option value="">Sélectionner</option>

    <option value="Employé">
      Employé
    </option>

    <option value="Agent de maîtrise">
      Agent de maîtrise
    </option>

    <option value="Cadre">
      Cadre
    </option>
  </select>
</div>
)}

{contractType !== 'Stage' && (
<div>
  <label className="label">Niveau</label>

  <select
    className="input"
    value={employeeLevel}
    onChange={(e) =>
      setEmployeeLevel(e.target.value)
    }
    disabled={contractType === 'Alternance'}
  >
    <option value="">Sélectionner</option>

    <option value="E1">E1</option>
    <option value="E2">E2</option>
    <option value="E3">E3</option>

    <option value="AM1">AM1</option>
    <option value="AM2">AM2</option>

    <option value="C1">C1</option>
    <option value="C2">C2</option>
    <option value="C3">C3</option>
    <option value="C4">C4</option>
  </select>
</div>
)}

{(contractType === 'CDI' ||
  contractType === 'CDD') && (
  <div>
    <label className="label">
      Salaire annuel brut
    </label>

    <input
      type="number"
      className="input"
      value={grossAnnualSalary}
      onChange={(e) =>
        setGrossAnnualSalary(
          e.target.value
        )
      }
    />
  </div>
)}

<div>
  <label className="label">
    Prime variable
  </label>

  <input
    className="input"
    placeholder="Facultatif"
    value={variableBonus}
    onChange={(e) =>
      setVariableBonus(
        e.target.value
      )
    }
  />
</div>

  {(contractType === 'CDD' ||
    contractType === 'Stage') && (
    <div>
      <label className="label">
        Date de fin de contrat
      </label>

      <input
        type="date"
        className="input"
        value={contractEndDate}
        onChange={(e) =>
          setContractEndDate(e.target.value)
        }
      />
    </div>
  )}

{contractType === 'CDD' && (
  <div>
    <label className="label">Motif</label>

    <input
      type="text"
      className="input"
      placeholder="Exemple : Remplacement congé maternité"
      value={contractReason}
      onChange={(e) =>
        setContractReason(e.target.value)
      }
    />
  </div>
)}

{(contractType === 'Stage' ||
  contractType === 'Alternance') && (
  <div>
    <label className="label">
      École
    </label>

    <input
      className="input"
      value={school}
      onChange={(e) =>
        setSchool(e.target.value)
      }
    />
  </div>
)}
{contractType === 'Alternance' && (
  <div>
    <label className="label">
      Rémunération
    </label>

    <input
      className="input"
      value="Grille conventionnelle apprentissage"
      readOnly
    />
  </div>
)}

{contractType === 'Stage' &&
 stageDurationDays > 60 && (
  <div>
    <label className="label">
      Rémunération
    </label>

    <input
      className="input"
      value="Gratification conventionnelle de stage (> 2 mois)"
      readOnly
    />
  </div>
)}


{contractType === 'Stage' && (
  <div>
    <label className="label">Mission</label>

    <textarea
      rows={4}
      className="input"
      placeholder="Décrire la mission du stagiaire"
      value={internshipMission}
      onChange={(e) =>
        setInternshipMission(e.target.value)
      }
    />
  </div>
)}


<div>
  <label className="label">
    CV du candidat
  </label>

  <input
    type="file"
    className="input"
    accept=".pdf,.doc,.docx"
    onChange={(e) =>
      setCvFile(
        e.target.files?.[0] ?? null
      )
    }
  />
</div>

<div>
  <label className="label">
    Cooptation
  </label>

  <label className="flex items-center gap-3 mt-2 text-sm">
    <input
      type="checkbox"
      checked={isReferral}
      onChange={(e) => {
        setIsReferral(e.target.checked);

        if (!e.target.checked) {
          setReferralEmployee('');
          setReferralSearch('');
        }
      }}
    />

    <span>
      Candidat recommandé par un collaborateur Elyade
    </span>
  </label>
</div>

{isReferral && (
  <div className="md:col-span-2">
    <label className="label">
      Collaborateur référent
    </label>

    <input
      className="input"
      placeholder="Rechercher un collaborateur..."
      value={referralSearch}
      onChange={(e) => {
        setReferralSearch(e.target.value);
        setReferralEmployee('');
      }}
    />

    {referralSearch && !referralEmployee && (
      <div className="mt-2 border rounded-lg bg-white max-h-60 overflow-auto">
        {filteredReferralEmployees.length === 0 && (
          <div className="px-3 py-2 text-sm text-ink-500">
            Aucun collaborateur trouvé
          </div>
        )}

        {filteredReferralEmployees.map((employee) => (
          <button
            key={employee.id}
            type="button"
            className="w-full text-left px-3 py-2 hover:bg-elyade-50"
            onClick={() => {
              setReferralEmployee(employee.id);
              setReferralSearch(
                `${employee.first_name} ${employee.last_name}`
              );
            }}
          >
            <div>
              {employee.first_name} {employee.last_name}
            </div>

            {(employee.email || employee.microsoft_upn) && (
              <div className="text-xs text-ink-500">
                {employee.email ?? employee.microsoft_upn}
              </div>
            )}
          </button>
        ))}
      </div>
    )}
  </div>
)}




</div>

        </section>

        <section className="card p-5">
          <h2 className="font-semibold text-ink-900 mb-4">
            Service (plusieurs cases possibles)
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
    Boîtes partagées nécessaires
  </h2>

  <textarea
	rows={8}
    className="input"
    placeholder="Exemple : 
accueil@elyade.com
contentieux@elyade.com

⚠  Merci de ne pas inscrire : les mêmes que Jean Dupond 
Nous ne pourrons pas répondre techniquement et le nouveau collaborateur n'aura aucune boite partagée. 
Il faut absolument lister les messageries nécessaires"
    value={sharedMailboxes}
    onChange={(e) =>
      setSharedMailboxes(e.target.value)
    }
  />
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
