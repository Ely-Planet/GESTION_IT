import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string;

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});

export type Profile = {
  id: string;
  display_name: string;
  email: string;
  role: string;
  created_at: string;
};

export type Service = {
  id: string;
  name: string;
  created_at: string;
};

export type ContractType = {
  id: string;
  code: string;
  label: string;
  has_end_date: boolean;
  sort_order: number;
};

export type Employee = {
  id: string;
  first_name: string;
  last_name: string;
  email: string | null;
  service_id: string | null;
  contract_type_id: string | null;
  contract_end_date: string | null;
  manager_name: string | null;
  job_title: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
};

export type Movement = {
  id: string;
  type: 'onboarding' | 'offboarding';
  employee_id: string | null;
  service_id: string | null;
  contract_type_id: string | null;
  contract_end_date: string | null;
  effective_date: string;
  source: 'manager_form' | 'lucca_email' | 'manual';
  manager_name: string | null;
  job_title: string | null;
  notes: string | null;
  status: 'pending' | 'in_progress' | 'done' | 'cancelled';
  created_by: string | null;
  calendar_event_ids: string[] | null;
  created_at: string;
  updated_at: string;
};

export type HardwareCategory = {
  id: string;
  code: string;
  label: string;
  tracked_for_person: boolean;
  managed_by: string | null;
  sort_order: number;
};

export type HardwareItem = {
  id: string;
  category_id: string;
  reference: string | null;
  serial_number: string | null;
  brand: string | null;
  model: string | null;
  status: 'in_stock' | 'assigned' | 'being_reinstalled' | 'retired' | 'defective';
  intune_device_id: string | null;
  atera_ticket_id: string | null;
  purchase_date: string | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
};

export type ServicePeripheral = {
  id: string;
  service_id: string;
  category_id: string;
  quantity: number;
  updated_at: string;
};

export type LicenseType = {
  id: string;
  code: string;
  label: string;
  total_seats: number;
  has_expiration: boolean;
  default_renewal_notice_days: number;
  notes: string | null;
  created_at: string;
  updated_at: string;
};

export type License = {
  id: string;
  license_type_id: string;
  seat_key: string | null;
  status: 'available' | 'assigned' | 'reserved' | 'resiliated';
  assigned_employee_id: string | null;
  assigned_at: string | null;
  expiration_date: string | null;
  renewal_notice_days: number | null;
  notes: string | null;
  created_at: string;
  updated_at: string;
};

export type MovementAction = {
  id: string;
  movement_id: string;
  action_type: 'creation' | 'pc_delivery' | 'intune_connection' | 'license_assignment' | 'welcome_email' | 'other';
  label: string;
  due_date: string | null;
  done_at: string | null;
  done_by: string | null;
  notes: string | null;
  sort_order: number;
  created_at: string;
  updated_at: string;
};

export type SubscribedSku = {
  id: string;
  sku_id: string;
  display_name: string | null;
  applies_to: string | null;
  enabled_units: number;
  consumed_units: number;
  prepaid_units: number;
  synced_at: string;
};

export type DashboardWidget = {
  id: string;
  user_id: string;
  widget_key: string;
  label: string;
  visible: boolean;
  sort_order: number;
  config: Record<string, unknown> | null;
  created_at: string;
  updated_at: string;
};

export type MovementItem = {
  id: string;
  movement_id: string;
  category_id: string | null;
  hardware_item_id: string | null;
  status: 'requested' | 'assigned' | 'skipped';
  notes: string | null;
  created_at: string;
  updated_at: string;
};

export type MovementLicense = {
  id: string;
  movement_id: string;
  license_type_id: string;
  license_id: string | null;
  status: 'requested' | 'assigned' | 'skipped';
  notes: string | null;
  created_at: string;
  updated_at: string;
};

export type SignedDocument = {
  id: string;
  movement_id: string;
  doc_type: 'assignment' | 'restitution';
  signer_name: string | null;
  signer_email: string | null;
  signature_data: string | null;
  signed_at: string | null;
  status: 'pending' | 'signed' | 'declined';
  content_snapshot: Record<string, unknown> | null;
  created_at: string;
  updated_at: string;
};

export type Assignment = {
  id: string;
  employee_id: string;
  hardware_item_id: string;
  movement_id: string | null;
  assigned_at: string;
  returned_at: string | null;
  signed_doc_url: string | null;
  signed_doc_status: 'pending' | 'signed' | 'not_signed';
  restitution_sheet_url: string | null;
  restitution_status: 'pending' | 'done' | 'partial' | 'missing';
  restitution_notes: string | null;
  notes: string | null;
  created_by: string | null;
  created_at: string;
  updated_at: string;
};

export type AuditLog = {
  id: string;
  actor_id: string | null;
  actor_name: string | null;
  action: string;
  entity_type: string;
  entity_id: string | null;
  details: Record<string, unknown> | null;
  created_at: string;
};
