CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- contract_types
-- =====================================================

CREATE TABLE IF NOT EXISTS contract_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code text NOT NULL UNIQUE,
    label text NOT NULL,
    has_end_date boolean NOT NULL DEFAULT false,
    sort_order integer NOT NULL DEFAULT 0
);

INSERT INTO contract_types(code,label,has_end_date,sort_order)
VALUES
('CDI','CDI',false,1),
('CDD','CDD',true,2),
('STAGE','Stage',true,3),
('ALTERNANT','Alternant',true,4)
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- employees
-- =====================================================

CREATE TABLE IF NOT EXISTS employees (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text,
    service_id uuid REFERENCES services(id),
    contract_type_id uuid REFERENCES contract_types(id),
    contract_end_date date,
    manager_name text,
    job_title text,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- =====================================================
-- hardware_categories
-- =====================================================

CREATE TABLE IF NOT EXISTS hardware_categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code text NOT NULL UNIQUE,
    label text NOT NULL,
    tracked_for_person boolean NOT NULL DEFAULT true,
    managed_by text,
    sort_order integer NOT NULL DEFAULT 0
);

INSERT INTO hardware_categories
(code,label,tracked_for_person,managed_by,sort_order)
VALUES
('PC','PC portable',true,'Intune',1),
('PHONE','Téléphone',true,'Intune',2),
('HEADSET','Casque',true,NULL,3),
('TABLET','Tablette',true,'Intune',4),
('SPEAKER','Enceinte',true,NULL,5),
('SIGNATURE_PAD','Pad de signature',true,NULL,6),
('SCREEN','Écran',false,NULL,7),
('KEYBOARD','Clavier',false,NULL,8),
('MOUSE','Souris',false,NULL,9)
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- hardware_items
-- =====================================================

CREATE TABLE IF NOT EXISTS hardware_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id uuid NOT NULL REFERENCES hardware_categories(id),
    reference text,
    serial_number text,
    brand text,
    model text,
    status text NOT NULL DEFAULT 'in_stock',
    intune_device_id text,
    atera_ticket_id text,
    purchase_date date,
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- =====================================================
-- license_types
-- =====================================================

CREATE TABLE IF NOT EXISTS license_types (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code text NOT NULL UNIQUE,
    label text NOT NULL,
    total_seats integer NOT NULL DEFAULT 0,
    has_expiration boolean NOT NULL DEFAULT false,
    default_renewal_notice_days integer NOT NULL DEFAULT 30,
    notes text,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

INSERT INTO license_types
(code,label,total_seats,has_expiration,default_renewal_notice_days)
VALUES
('SEIITRA','Seiitra',0,true,30),
('OFFICE365','Office 365',0,false,30)
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- licenses
-- =====================================================

CREATE TABLE IF
