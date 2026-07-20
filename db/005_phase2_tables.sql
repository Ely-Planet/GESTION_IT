CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS service_peripherals (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id uuid REFERENCES services(id),
    category_id uuid REFERENCES hardware_categories(id),
    quantity integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assignments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id uuid REFERENCES employees(id),
    hardware_item_id uuid REFERENCES hardware_items(id),
    assigned_at timestamptz DEFAULT now(),
    returned_at timestamptz
);

CREATE TABLE IF NOT EXISTS audit_log (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_name text,
    action text,
    entity_type text,
    entity_id uuid,
    details jsonb,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS movement_actions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    movement_id uuid REFERENCES movements(id),
    action_type text,
    label text,
    due_date date,
    done_at timestamptz,
    notes text,
    sort_order integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

