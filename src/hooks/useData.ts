import { useCallback, useEffect, useState } from 'react';
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
inventoryBrands: any[];
inventoryOperatingSystems: any[];
inventoryProcessors: any[];
inventoryMemories: any[];
inventorySizes: any[];
inventorySuppliers: any[];
inventoryBudgets: any[];
inventoryStatuses: any[];  
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
  movementServiceGroups: any[];  
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
inventoryBrands: [],
inventoryOperatingSystems: [],
inventoryProcessors: [],
inventoryMemories: [],
inventorySizes: [],
inventorySuppliers: [],
inventoryBudgets: [],
inventoryStatuses: [],    
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
    movementServiceGroups: [],  
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

  inventoryBrands,
  inventoryOperatingSystems,
  inventoryProcessors,
  inventoryMemories,
  inventorySizes,
  inventorySuppliers,
  inventoryBudgets,
  inventoryStatuses,

  servicePeripherals,
  licenseTypes,
  licenses,
  assignments,
  auditLog,
  movementActions,
  subscribedSkus,
] = await Promise.all([




        fetch('/api/services')
          .then(r => r.json())
          .catch(() => []),

        fetch('/api/contract-types')
          .then(r => r.json())
          .catch(() => []),

        fetch('/api/employees')
          .then(r => r.json())
          .catch(() => []),

        fetch('/api/movements')
          .then(r => r.json())
          .catch(() => []),

        fetch('/api/hardware-categories')
          .then(r => r.json())
          .catch(() => []),

        fetch('/api/hardware-items')
          .then(r => r.json())
          .catch(() => []),

fetch('/api/inventory-brands')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/inventory-operatingSystems')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/inventory-processors')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/inventory-memories')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/inventory-sizes')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/inventory-suppliers')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/inventory-budgets')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/inventory-statuses')
  .then(r => r.json())
  .catch(() => []),



fetch('/api/service-peripherals')
  .then(r => r.json())
  .catch(() => []),

        fetch('/api/license-types')
          .then(r => r.json())
          .catch(() => []),

        fetch('/api/licenses')
          .then(r => r.json())
          .catch(() => []),

fetch('/api/assignments')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/audit-log')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/movement-actions')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/subscribed-skus')
  .then(r => r.json())
  .catch(() => []),

      ]);

const [
  movementItems,
  movementLicenses,
  movementServiceGroups,
  signedDocuments
] = await Promise.all([


fetch('/api/movement-items')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/movement-licenses')
  .then(r => r.json())
  .catch(() => []),

fetch('/api/movement-service-groups')
  .then(r => r.json())
  .catch(() => []),


fetch('/api/signed-documents')
  .then(r => r.json())
  .catch(() => []),

      ]);

      let widgets: DashboardWidget[] = [];

      if (user) {
        widgets = await fetch(`/api/dashboard-widgets/${user.id}`)
          .then(r => r.json())
          .catch(() => []);
      }



      setState({
        services: services as Service[],
        contractTypes: contractTypes as ContractType[],
        employees: employees as Employee[],
        movements: movements as Movement[],
        hardwareCategories: hardwareCategories as HardwareCategory[],
        hardware: hardware as HardwareItem[],
inventoryBrands: inventoryBrands as any[],
inventoryOperatingSystems: inventoryOperatingSystems as any[],
inventoryProcessors: inventoryProcessors as any[],
inventoryMemories: inventoryMemories as any[],
inventorySizes: inventorySizes as any[],
inventorySuppliers: inventorySuppliers as any[],
inventoryBudgets: inventoryBudgets as any[],
inventoryStatuses: inventoryStatuses as any[],      

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
        movementServiceGroups: movementServiceGroups as any[],
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
