CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS services (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO services (name)
VALUES
('Direction'),
('Comptabilité'),
('Ressources Humaines'),
('Commercial'),
('Gestion Locative'),
('Syndic'),
('Transaction'),
('Neuf'),
('Informatique')
ON CONFLICT (name) DO NOTHING;

