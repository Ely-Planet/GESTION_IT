/*
# ELYADE IT Management — Schema v3: movement items, signatures, calendar

## Overview
Adds support for:
1. Requested hardware + licenses per movement (parsed from Microsoft Form emails).
2. Digital signature documents (assignment + restitution) attached to movements.
3. Calendar events tracking (2 RDV per onboarding on shared service calendar).

## New tables
- `movement_items` — hardware items linked to a movement (requested + assigned).
- `movement_licenses` — licenses linked to a movement (requested + assigned).
- `signed_documents` — digitally signed assignment/restitution documents per movement.

## Modified tables
- `movements` — add `calendar_event_ids` (jsonb array of Graph event IDs).

## Security
- All new tables: RLS enabled, authenticated CRUD.
*/

-- =========================================================
-- 1. movement_items
-- =========================================================
CREATE TABLE IF NOT EXISTS public.movement_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  movement_id uuid NOT NULL REFERENCES public.movements(id) ON DELETE CASCADE,
  category_id uuid REFERENCES public.hardware_categories(id) ON DELETE SET NULL,
  hardware_item_id uuid REFERENCES public.hardware_items(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'requested' CHECK (status IN ('requested','assigned','skipped')),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.movement_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "mit_select_authenticated" ON public.movement_items;
CREATE POLICY "mit_select_authenticated" ON public.movement_items
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "mit_insert_authenticated" ON public.movement_items;
CREATE POLICY "mit_insert_authenticated" ON public.movement_items
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "mit_update_authenticated" ON public.movement_items;
CREATE POLICY "mit_update_authenticated" ON public.movement_items
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "mit_delete_authenticated" ON public.movement_items;
CREATE POLICY "mit_delete_authenticated" ON public.movement_items
  FOR DELETE TO authenticated USING (true);

CREATE INDEX IF NOT EXISTS idx_mit_movement ON public.movement_items(movement_id);

DROP TRIGGER IF EXISTS trg_mit_touch ON public.movement_items;
CREATE TRIGGER trg_mit_touch BEFORE UPDATE ON public.movement_items
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- =========================================================
-- 2. movement_licenses
-- =========================================================
CREATE TABLE IF NOT EXISTS public.movement_licenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  movement_id uuid NOT NULL REFERENCES public.movements(id) ON DELETE CASCADE,
  license_type_id uuid NOT NULL REFERENCES public.license_types(id) ON DELETE CASCADE,
  license_id uuid REFERENCES public.licenses(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'requested' CHECK (status IN ('requested','assigned','skipped')),
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.movement_licenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "mlic_select_authenticated" ON public.movement_licenses;
CREATE POLICY "mlic_select_authenticated" ON public.movement_licenses
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "mlic_insert_authenticated" ON public.movement_licenses;
CREATE POLICY "mlic_insert_authenticated" ON public.movement_licenses
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "mlic_update_authenticated" ON public.movement_licenses;
CREATE POLICY "mlic_update_authenticated" ON public.movement_licenses
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "mlic_delete_authenticated" ON public.movement_licenses;
CREATE POLICY "mlic_delete_authenticated" ON public.movement_licenses
  FOR DELETE TO authenticated USING (true);

CREATE INDEX IF NOT EXISTS idx_mlic_movement ON public.movement_licenses(movement_id);

DROP TRIGGER IF EXISTS trg_mlic_touch ON public.movement_licenses;
CREATE TRIGGER trg_mlic_touch BEFORE UPDATE ON public.movement_licenses
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- =========================================================
-- 3. signed_documents
-- =========================================================
CREATE TABLE IF NOT EXISTS public.signed_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  movement_id uuid NOT NULL REFERENCES public.movements(id) ON DELETE CASCADE,
  doc_type text NOT NULL CHECK (doc_type IN ('assignment','restitution')),
  signer_name text,
  signer_email text,
  signature_data text,
  signed_at timestamptz,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','signed','declined')),
  content_snapshot jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.signed_documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "sd_select_authenticated" ON public.signed_documents;
CREATE POLICY "sd_select_authenticated" ON public.signed_documents
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "sd_insert_authenticated" ON public.signed_documents;
CREATE POLICY "sd_insert_authenticated" ON public.signed_documents
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "sd_update_authenticated" ON public.signed_documents;
CREATE POLICY "sd_update_authenticated" ON public.signed_documents
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "sd_delete_authenticated" ON public.signed_documents;
CREATE POLICY "sd_delete_authenticated" ON public.signed_documents
  FOR DELETE TO authenticated USING (true);

CREATE INDEX IF NOT EXISTS idx_sd_movement ON public.signed_documents(movement_id);

DROP TRIGGER IF EXISTS trg_sd_touch ON public.signed_documents;
CREATE TRIGGER trg_sd_touch BEFORE UPDATE ON public.signed_documents
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- =========================================================
-- 4. movements: calendar_event_ids
-- =========================================================
ALTER TABLE public.movements
  ADD COLUMN IF NOT EXISTS calendar_event_ids jsonb;
