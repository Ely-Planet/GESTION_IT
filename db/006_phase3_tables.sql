CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS movement_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    movement_id uuid REFERENCES movements(id),
    category_id uuid REFERENCES hardware_categories(id),
    hardware_item_id uuid REFERENCES hardware_items(id),
    status text DEFAULT 'requested',
    notes text,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS movement_licenses (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    movement_id uuid REFERENCES movements(id),
    license_type_id uuid REFERENCES license_types(id),
    license_id uuid REFERENCES licenses(id),
    status text DEFAULT 'requested',
    notes text,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS signed_documents (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    movement_id uuid REFERENCES movements(id),
    doc_type text,
    signer_name text,
    signer_email text,
    signed_at timestamptz,
    status text DEFAULT 'pending',
    content_snapshot jsonb,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS subscribed_skus (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    sku_id text UNIQUE,
    display_name text,
    applies_to text,
    enabled_units integer DEFAULT 0,
    consumed_units integer DEFAULT 0,
    prepaid_units integer DEFAULT 0,
    synced_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dashboard_widgets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id text NOT NULL,
    widget_key text NOT NULL,
    label text NOT NULL,
    visible boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    config jsonb,
    created_at timestamptz DEFAULT now(),
    UNIQUE(user_id, widget_key)
);
