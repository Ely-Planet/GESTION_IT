import { useCallback, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { useAuth } from '../context/AuthContext';
import type {
  Service,
  ContractType,
  Employee,
  Movement,
  HardwareCategory,
  HardwareItem,
  ServicePeripheral,
  LicenseType,
  License,
  Assignment,
  AuditLog,
  MovementAction,
  SubscribedSku,
  DashboardWidget,
  MovementItem,
  MovementLicense,
  SignedDocument,
} from '../lib/supabase';
type DataState = {
  services: Service[];
  contractTypes: ContractType[];
  employees: Employee[];
  movements: Movement[];
  hardwareCategories: HardwareCategory[];
  hardware: HardwareItem[];
  servicePeripherals: ServicePeripheral[];
  licenseTypes: LicenseType[];
  licenses: License[];
  assignments: Assignment[];
  auditLog: AuditLog[];
  movementActions: MovementAction[];
  subscribedSkus: SubscribedSku[];
  widgets: DashboardWidget[];
  movementItems: MovementItem[];
  movementLicenses: MovementLicense[];
  signedDocuments: SignedDocument[];
  loading: boolean;
  error: string | null;
  reload: () => Promise<void>;
};

export function useData(): DataState {
  const { user } = useAuth();
  const [state, setState] = useState<Omit<DataState, 'reload' | 'loading' | 'error'>>({
    services: [],
    contractTypes: [],
    employees: [],
    movements: [],
    hardwareCategories: [],
    hardware: [],
    servicePeripherals: [],
    licenseTypes: [],
    licenses: [],
    assignments: [],
    auditLog: [],
    movementActions: [],
    subscribedSkus: [],
    widgets: [],
    movementItems: [],
    movementLicenses: [],
    signedDocuments: [],
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const reload = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [
        services,
        contractTypes,
        employees,
        movements,
        hardwareCategories,
        hardware,
        servicePeripherals,
        licenseTypes,
        licenses,
        assignments,
        auditLog,
        movementActions,
        subscribedSkus,
      ] = await Promise.all([
        supabase.from('services').select('*').then((r) => r.data ?? []),
        supabase.from('contract_types').select('*').order('sort_order').then((r) => r.data ?? []),
        supabase.from('employees').select('*').order('last_name').then((r) => r.data ?? []),
        supabase.from('movements').select('*').order('effective_date', { ascending: false }).then((r) => r.data ?? []),
        supabase.from('hardware_categories').select('*').order('sort_order').then((r) => r.data ?? []),
        supabase.from('hardware_items').select('*').order('created_at', { ascending: false }).then((r) => r.data ?? []),
        supabase.from('service_peripherals').select('*').then((r) => r.data ?? []),
        supabase.from('license_types').select('*').order('label').then((r) => r.data ?? []),
        supabase.from('licenses').select('*').order('created_at', { ascending: false }).then((r) => r.data ?? []),
        supabase.from('assignments').select('*').order('assigned_at', { ascending: false }).then((r) => r.data ?? []),
        supabase.from('audit_log').select('*').order('created_at', { ascending: false }).limit(200).then((r) => r.data ?? []),
        supabase.from('movement_actions').select('*').order('sort_order').then((r) => r.data ?? []),
        supabase.from('subscribed_skus').select('*').order('display_name').then((r) => r.data ?? []),
      ]);

      const [movementItems, movementLicenses, signedDocuments] = await Promise.all([
        supabase.from('movement_items').select('*').then((r) => r.data ?? []),
        supabase.from('movement_licenses').select('*').then((r) => r.data ?? []),
        supabase.from('signed_documents').select('*').order('created_at', { ascending: false }).then((r) => r.data ?? []),
      ]);

      let widgets: DashboardWidget[] = [];
      if (user) {
        const { data } = await supabase
          .from('dashboard_widgets')
          .select('*')
          .eq('user_id', user.id)
          .order('sort_order');
        widgets = (data as DashboardWidget[]) ?? [];
      }

      setState({
        services: services as Service[],
        contractTypes: contractTypes as ContractType[],
        employees: employees as Employee[],
        movements: movements as Movement[],
        hardwareCategories: hardwareCategories as HardwareCategory[],
        hardware: hardware as HardwareItem[],
        servicePeripherals: servicePeripherals as ServicePeripheral[],
        licenseTypes: licenseTypes as LicenseType[],
        licenses: licenses as License[],
        assignments: assignments as Assignment[],
        auditLog: auditLog as AuditLog[],
        movementActions: movementActions as MovementAction[],
        subscribedSkus: subscribedSkus as SubscribedSku[],
        widgets,
        movementItems: movementItems as MovementItem[],
        movementLicenses: movementLicenses as MovementLicense[],
        signedDocuments: signedDocuments as SignedDocument[],
      });
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Erreur de chargement');
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    reload();
  }, [reload]);

  return { ...state, loading, error, reload };
}

export type DataService = ReturnType<typeof useData>;
