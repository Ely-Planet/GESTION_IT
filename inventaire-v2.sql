BEGIN;

ALTER TABLE hardware_items
ADD COLUMN IF NOT EXISTS title TEXT,
ADD COLUMN IF NOT EXISTS os_id UUID,
ADD COLUMN IF NOT EXISTS processor_id UUID,
ADD COLUMN IF NOT EXISTS memory_id UUID,
ADD COLUMN IF NOT EXISTS size_id UUID,

ADD COLUMN IF NOT EXISTS hdmi BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS displayport BOOLEAN DEFAULT false,

ADD COLUMN IF NOT EXISTS invoice_number TEXT,
ADD COLUMN IF NOT EXISTS purchase_value NUMERIC(10,2),

ADD COLUMN IF NOT EXISTS supplier_id UUID,
ADD COLUMN IF NOT EXISTS budget_id UUID,

ADD COLUMN IF NOT EXISTS warranty_expiration_date DATE,
ADD COLUMN IF NOT EXISTS asset_number TEXT;

CREATE TABLE IF NOT EXISTS inventory_brands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_operating_systems (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_processors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_memories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_sizes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_budgets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_statuses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  label TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO inventory_operating_systems(label) VALUES
('Windows 11'),
('Windows 10'),
('macOS'),
('Android'),
('iOS')
ON CONFLICT DO NOTHING;

INSERT INTO inventory_processors(label) VALUES
('i3'),
('i5'),
('i7'),
('i9')
ON CONFLICT DO NOTHING;

INSERT INTO inventory_memories(label) VALUES
('8 Go'),
('16 Go'),
('32 Go'),
('64 Go')
ON CONFLICT DO NOTHING;

INSERT INTO inventory_sizes(label) VALUES
('13"'),
('15"'),
('16"'),
('17"'),
('22"'),
('24"'),
('27"'),
('32"')
ON CONFLICT DO NOTHING;

INSERT INTO inventory_brands(label) VALUES
('Dell'),
('HP'),
('Lenovo'),
('Apple'),
('Samsung'),
('Motorola'),
('Microsoft')
ON CONFLICT DO NOTHING;

INSERT INTO inventory_statuses(label) VALUES
('En stock'),
('Attribué'),
('En réinstallation'),
('Défectueux'),
('Réformé')
ON CONFLICT DO NOTHING;

COMMIT;
