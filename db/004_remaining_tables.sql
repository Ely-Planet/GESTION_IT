CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- licenses
-- =====================================================

CREATE TABLE IF NOT EXISTS licenses (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    license_type_id uuid NOT NULL REFERENCES license_types(id),
    seat_key text,
    status text NOT NULL DEFAULT 'available',
    assigned_employee_id uuid REFERENCES employees(id),
    assigned_at date,
    expiration_date date,
    renewal_notice_days integer,
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- =====================================================
-- movements
-- =====================================================

CREATE TABLE IF NOT EXISTS movements (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    type text NOT NULL,
    employee_id uuid REFERENCES employees(id),
    service_id uuid REFERENCES services(id),
    contract_type_id uuid REFERENCES contract_types(id),
    contract_end_date date,
    effective_date date NOT NULL,
    source text DEFAULT 'manual',
    manager_name text,
    job_title text,
    notes text,
    status text DEFAULT 'pending',
    calendar_event_ids jsonb,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);
