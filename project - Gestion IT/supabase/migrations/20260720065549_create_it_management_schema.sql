/*
# ELYADE IT Management — Initial Schema

## Overview
Internal application to automate IT onboarding/offboarding, hardware inventory,
software licenses (Seiitra, Office), and assignment documents (signature sheets
and restitution sheets). Tracks PC stock, licenses, and anticipates shortages
with forecast alerts.

## Tables created
1. `profiles` — extends auth.users with display name + role for audit traceability.
2. `services` — company departments (e.g. Comptabilité, RH, Commercial). Peripherals
   (screens, keyboards, mice) are assigned to services, not people.
3. `employees` — people tracked by the system (active or not). Linked to a service.
4. `contract_types` — lookup: CDI, CDD, Stage, Alternant.
5. `movements` — onboarding or offboarding events. Created from manager form, or
   auto-generated from Lucca email (offboarding). CDD/Stage/Alternant carry an
   automatic offboarding date.
6. `hardware_categories` — lookup of device types with tracking flags
   (tracked individually vs. service-assigned).
7. `hardware_items` — individual hardware units (PC, phone, headset, tablet,
   speaker, signature pad). Tracked by Intune (PC) or Atera (tickets). Has status
   (in_stock, assigned, being_reinstalled, retired).
8. `service_peripherals` — quantity of screens/keyboards/mice assigned per service.
9. `license_types` — Seiitra, Office 365, etc. with total purchased count.
10. `licenses` — individual license seats (assigned or available).
11. `assignments` — formal handover of one hardware item to one employee, with
    signed acceptance document and restitution sheet state.
12. `audit_log` — every create/update/delete recorded with actor identity.

## Security (RLS)
- All tables use `TO authenticated` with ownership via the authenticated user.
- `profiles` is readable by all authenticated users (team app).
- Operational tables are full CRUD for any authenticated user (shared internal app).
- `audit_log` is insert-only for authenticated users; updates/deletes blocked.
*/

-- =========================================================
-- 1. profiles
-- =========================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text NOT NULL,
  email text NOT NULL,
  role text NOT NULL DEFAULT 'agent',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_authenticated" ON public.profiles;
CREATE POLICY "profiles_select_authenticated" ON public.profiles
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "profiles_insert_self" ON public.profiles;
CREATE POLICY "profiles_insert_self" ON public.profiles
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update_self" ON public.profiles;
CREATE POLICY "profiles_update_self" ON public.profiles
  FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- =========================================================
-- 2. services
-- =========================================================
CREATE TABLE IF NOT EXISTS public.services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "services_select_authenticated" ON public.services;
CREATE POLICY "services_select_authenticated" ON public.services
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "services_insert_authenticated" ON public.services;
CREATE POLICY "services_insert_authenticated" ON public.services
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "services_update_authenticated" ON public.services;
CREATE POLICY "services_update_authenticated" ON public.services
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "services_delete_authenticated" ON public.services;
CREATE POLICY "services_delete_authenticated" ON public.services
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 3. contract_types
-- =========================================================
CREATE TABLE IF NOT EXISTS public.contract_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  label text NOT NULL,
  has_end_date boolean NOT NULL DEFAULT false,
  sort_order int NOT NULL DEFAULT 0
);

ALTER TABLE public.contract_types ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "contract_types_select_authenticated" ON public.contract_types;
CREATE POLICY "contract_types_select_authenticated" ON public.contract_types
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "contract_types_insert_authenticated" ON public.contract_types;
CREATE POLICY "contract_types_insert_authenticated" ON public.contract_types
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "contract_types_update_authenticated" ON public.contract_types;
CREATE POLICY "contract_types_update_authenticated" ON public.contract_types
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "contract_types_delete_authenticated" ON public.contract_types;
CREATE POLICY "contract_types_delete_authenticated" ON public.contract_types
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 4. employees
-- =========================================================
CREATE TABLE IF NOT EXISTS public.employees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text,
  service_id uuid REFERENCES public.services(id) ON DELETE SET NULL,
  contract_type_id uuid REFERENCES public.contract_types(id) ON DELETE SET NULL,
  contract_end_date date,
  manager_name text,
  job_title text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "employees_select_authenticated" ON public.employees;
CREATE POLICY "employees_select_authenticated" ON public.employees
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "employees_insert_authenticated" ON public.employees;
CREATE POLICY "employees_insert_authenticated" ON public.employees
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "employees_update_authenticated" ON public.employees;
CREATE POLICY "employees_update_authenticated" ON public.employees
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "employees_delete_authenticated" ON public.employees;
CREATE POLICY "employees_delete_authenticated" ON public.employees
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 5. movements
-- =========================================================
CREATE TABLE IF NOT EXISTS public.movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text NOT NULL CHECK (type IN ('onboarding','offboarding')),
  employee_id uuid REFERENCES public.employees(id) ON DELETE CASCADE,
  service_id uuid REFERENCES public.services(id) ON DELETE SET NULL,
  contract_type_id uuid REFERENCES public.contract_types(id) ON DELETE SET NULL,
  contract_end_date date,
  effective_date date NOT NULL,
  source text NOT NULL DEFAULT 'manager_form' CHECK (source IN ('manager_form','lucca_email','manual')),
  manager_name text,
  job_title text,
  notes text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','in_progress','done','cancelled')),
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.movements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "movements_select_authenticated" ON public.movements;
CREATE POLICY "movements_select_authenticated" ON public.movements
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "movements_insert_authenticated" ON public.movements;
CREATE POLICY "movements_insert_authenticated" ON public.movements
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "movements_update_authenticated" ON public.movements;
CREATE POLICY "movements_update_authenticated" ON public.movements
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "movements_delete_authenticated" ON public.movements;
CREATE POLICY "movements_delete_authenticated" ON public.movements
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 6. hardware_categories
-- =========================================================
CREATE TABLE IF NOT EXISTS public.hardware_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  label text NOT NULL,
  tracked_for_person boolean NOT NULL DEFAULT true,
  managed_by text,
  sort_order int NOT NULL DEFAULT 0
);

ALTER TABLE public.hardware_categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "hwcat_select_authenticated" ON public.hardware_categories;
CREATE POLICY "hwcat_select_authenticated" ON public.hardware_categories
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "hwcat_insert_authenticated" ON public.hardware_categories;
CREATE POLICY "hwcat_insert_authenticated" ON public.hardware_categories
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "hwcat_update_authenticated" ON public.hardware_categories;
CREATE POLICY "hwcat_update_authenticated" ON public.hardware_categories
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "hwcat_delete_authenticated" ON public.hardware_categories;
CREATE POLICY "hwcat_delete_authenticated" ON public.hardware_categories
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 7. hardware_items
-- =========================================================
CREATE TABLE IF NOT EXISTS public.hardware_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid NOT NULL REFERENCES public.hardware_categories(id) ON DELETE RESTRICT,
  reference text,
  serial_number text,
  brand text,
  model text,
  status text NOT NULL DEFAULT 'in_stock' CHECK (status IN ('in_stock','assigned','being_reinstalled','retired','defective')),
  intune_device_id text,
  atera_ticket_id text,
  purchase_date date,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.hardware_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "hw_select_authenticated" ON public.hardware_items;
CREATE POLICY "hw_select_authenticated" ON public.hardware_items
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "hw_insert_authenticated" ON public.hardware_items;
CREATE POLICY "hw_insert_authenticated" ON public.hardware_items
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "hw_update_authenticated" ON public.hardware_items;
CREATE POLICY "hw_update_authenticated" ON public.hardware_items
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "hw_delete_authenticated" ON public.hardware_items;
CREATE POLICY "hw_delete_authenticated" ON public.hardware_items
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 8. service_peripherals
-- =========================================================
CREATE TABLE IF NOT EXISTS public.service_peripherals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_id uuid NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
  category_id uuid NOT NULL REFERENCES public.hardware_categories(id) ON DELETE RESTRICT,
  quantity int NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (service_id, category_id)
);

ALTER TABLE public.service_peripherals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "periph_select_authenticated" ON public.service_peripherals;
CREATE POLICY "periph_select_authenticated" ON public.service_peripherals
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "periph_insert_authenticated" ON public.service_peripherals;
CREATE POLICY "periph_insert_authenticated" ON public.service_peripherals
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "periph_update_authenticated" ON public.service_peripherals;
CREATE POLICY "periph_update_authenticated" ON public.service_peripherals
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "periph_delete_authenticated" ON public.service_peripherals;
CREATE POLICY "periph_delete_authenticated" ON public.service_peripherals
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 9. license_types
-- =========================================================
CREATE TABLE IF NOT EXISTS public.license_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  label text NOT NULL,
  total_seats int NOT NULL DEFAULT 0,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.license_types ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lictype_select_authenticated" ON public.license_types;
CREATE POLICY "lictype_select_authenticated" ON public.license_types
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "lictype_insert_authenticated" ON public.license_types;
CREATE POLICY "lictype_insert_authenticated" ON public.license_types
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "lictype_update_authenticated" ON public.license_types;
CREATE POLICY "lictype_update_authenticated" ON public.license_types
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "lictype_delete_authenticated" ON public.license_types;
CREATE POLICY "lictype_delete_authenticated" ON public.license_types
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 10. licenses
-- =========================================================
CREATE TABLE IF NOT EXISTS public.licenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  license_type_id uuid NOT NULL REFERENCES public.license_types(id) ON DELETE CASCADE,
  seat_key text,
  status text NOT NULL DEFAULT 'available' CHECK (status IN ('available','assigned','reserved','resiliated')),
  assigned_employee_id uuid REFERENCES public.employees(id) ON DELETE SET NULL,
  assigned_at date,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.licenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lic_select_authenticated" ON public.licenses;
CREATE POLICY "lic_select_authenticated" ON public.licenses
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "lic_insert_authenticated" ON public.licenses;
CREATE POLICY "lic_insert_authenticated" ON public.licenses
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "lic_update_authenticated" ON public.licenses;
CREATE POLICY "lic_update_authenticated" ON public.licenses
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "lic_delete_authenticated" ON public.licenses;
CREATE POLICY "lic_delete_authenticated" ON public.licenses
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 11. assignments
-- =========================================================
CREATE TABLE IF NOT EXISTS public.assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id uuid NOT NULL REFERENCES public.employees(id) ON DELETE CASCADE,
  hardware_item_id uuid NOT NULL REFERENCES public.hardware_items(id) ON DELETE RESTRICT,
  movement_id uuid REFERENCES public.movements(id) ON DELETE SET NULL,
  assigned_at date NOT NULL DEFAULT CURRENT_DATE,
  returned_at date,
  signed_doc_url text,
  signed_doc_status text NOT NULL DEFAULT 'pending' CHECK (signed_doc_status IN ('pending','signed','not_signed')),
  restitution_sheet_url text,
  restitution_status text NOT NULL DEFAULT 'pending' CHECK (restitution_status IN ('pending','done','partial','missing')),
  restitution_notes text,
  notes text,
  created_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "assign_select_authenticated" ON public.assignments;
CREATE POLICY "assign_select_authenticated" ON public.assignments
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "assign_insert_authenticated" ON public.assignments;
CREATE POLICY "assign_insert_authenticated" ON public.assignments
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "assign_update_authenticated" ON public.assignments;
CREATE POLICY "assign_update_authenticated" ON public.assignments
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "assign_delete_authenticated" ON public.assignments;
CREATE POLICY "assign_delete_authenticated" ON public.assignments
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 12. audit_log
-- =========================================================
CREATE TABLE IF NOT EXISTS public.audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  actor_name text,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid,
  details jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "audit_select_authenticated" ON public.audit_log;
CREATE POLICY "audit_select_authenticated" ON public.audit_log
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "audit_insert_authenticated" ON public.audit_log;
CREATE POLICY "audit_insert_authenticated" ON public.audit_log
  FOR INSERT TO authenticated WITH CHECK (true);

-- =========================================================
-- Indexes
-- =========================================================
CREATE INDEX IF NOT EXISTS idx_employees_service ON public.employees(service_id);
CREATE INDEX IF NOT EXISTS idx_movements_employee ON public.movements(employee_id);
CREATE INDEX IF NOT EXISTS idx_movements_type_status ON public.movements(type, status);
CREATE INDEX IF NOT EXISTS idx_movements_effective_date ON public.movements(effective_date);
CREATE INDEX IF NOT EXISTS idx_hardware_category_status ON public.hardware_items(category_id, status);
CREATE INDEX IF NOT EXISTS idx_licenses_type_status ON public.licenses(license_type_id, status);
CREATE INDEX IF NOT EXISTS idx_assignments_employee ON public.assignments(employee_id);
CREATE INDEX IF NOT EXISTS idx_audit_created ON public.audit_log(created_at DESC);

-- =========================================================
-- updated_at triggers
-- =========================================================
CREATE OR REPLACE FUNCTION public.touch_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_employees_touch ON public.employees;
CREATE TRIGGER trg_employees_touch BEFORE UPDATE ON public.employees
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_movements_touch ON public.movements;
CREATE TRIGGER trg_movements_touch BEFORE UPDATE ON public.movements
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_hardware_touch ON public.hardware_items;
CREATE TRIGGER trg_hardware_touch BEFORE UPDATE ON public.hardware_items
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_licenses_touch ON public.licenses;
CREATE TRIGGER trg_licenses_touch BEFORE UPDATE ON public.licenses
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_assignments_touch ON public.assignments;
CREATE TRIGGER trg_assignments_touch BEFORE UPDATE ON public.assignments
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_lictype_touch ON public.license_types;
CREATE TRIGGER trg_lictype_touch BEFORE UPDATE ON public.license_types
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

DROP TRIGGER IF EXISTS trg_periph_touch ON public.service_peripherals;
CREATE TRIGGER trg_periph_touch BEFORE UPDATE ON public.service_peripherals
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();
