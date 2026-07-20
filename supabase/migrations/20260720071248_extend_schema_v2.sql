/*
# ELYADE IT Management — Schema extensions

## Overview
Adds support for:
1. Movement action tracking (creation, PC delivery, Intune connection) with due dates and reminders.
2. License expiration dates and per-license renewal notice days.
3. Microsoft Graph license auto-sync (subscribed_skus cache).
4. Customizable dashboard widgets per user.

## New tables
- `movement_actions` — checklist of dated actions per movement (creation, PC delivery, connection).
- `subscribed_skus` — cache of Microsoft tenant license SKUs (auto-synced).
- `dashboard_widgets` — per-user dashboard widget configuration (visible/hidden + order).

## Modified tables
- `license_types` — add `has_expiration` (bool) and `default_renewal_notice_days` (int).
- `licenses` — add `expiration_date` (date) and `renewal_notice_days` (int, nullable override).

## Security
- All new tables: RLS enabled, authenticated CRUD.
- `subscribed_skus`: authenticated read-only (synced by edge function with service role).
- `dashboard_widgets`: owner-scoped via auth.uid().
*/

-- =========================================================
-- 1. Alter license_types
-- =========================================================
ALTER TABLE public.license_types
  ADD COLUMN IF NOT EXISTS has_expiration boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS default_renewal_notice_days int NOT NULL DEFAULT 30;

-- =========================================================
-- 2. Alter licenses
-- =========================================================
ALTER TABLE public.licenses
  ADD COLUMN IF NOT EXISTS expiration_date date,
  ADD COLUMN IF NOT EXISTS renewal_notice_days int;

-- Seiitra-like (non-Office) licenses carry expiration
UPDATE public.license_types SET has_expiration = true, default_renewal_notice_days = 30
WHERE code NOT IN ('OFFICE365');

-- =========================================================
-- 3. movement_actions
-- =========================================================
CREATE TABLE IF NOT EXISTS public.movement_actions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  movement_id uuid NOT NULL REFERENCES public.movements(id) ON DELETE CASCADE,
  action_type text NOT NULL CHECK (action_type IN ('creation','pc_delivery','intune_connection','license_assignment','welcome_email','other')),
  label text NOT NULL,
  due_date date,
  done_at timestamptz,
  done_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  notes text,
  sort_order int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.movement_actions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "mact_select_authenticated" ON public.movement_actions;
CREATE POLICY "mact_select_authenticated" ON public.movement_actions
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "mact_insert_authenticated" ON public.movement_actions;
CREATE POLICY "mact_insert_authenticated" ON public.movement_actions
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "mact_update_authenticated" ON public.movement_actions;
CREATE POLICY "mact_update_authenticated" ON public.movement_actions
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "mact_delete_authenticated" ON public.movement_actions;
CREATE POLICY "mact_delete_authenticated" ON public.movement_actions
  FOR DELETE TO authenticated USING (true);

CREATE INDEX IF NOT EXISTS idx_mact_movement ON public.movement_actions(movement_id);
CREATE INDEX IF NOT EXISTS idx_mact_due_date ON public.movement_actions(due_date);

DROP TRIGGER IF EXISTS trg_mact_touch ON public.movement_actions;
CREATE TRIGGER trg_mact_touch BEFORE UPDATE ON public.movement_actions
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- =========================================================
-- 4. subscribed_skus (Microsoft Graph cache)
-- =========================================================
CREATE TABLE IF NOT EXISTS public.subscribed_skus (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sku_id text UNIQUE NOT NULL,
  display_name text,
  applies_to text,
  enabled_units int NOT NULL DEFAULT 0,
  consumed_units int NOT NULL DEFAULT 0,
  prepaid_units int NOT NULL DEFAULT 0,
  synced_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.subscribed_skus ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "sku_select_authenticated" ON public.subscribed_skus;
CREATE POLICY "sku_select_authenticated" ON public.subscribed_skus
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "sku_insert_authenticated" ON public.subscribed_skus;
CREATE POLICY "sku_insert_authenticated" ON public.subscribed_skus
  FOR INSERT TO authenticated WITH CHECK (true);
DROP POLICY IF EXISTS "sku_update_authenticated" ON public.subscribed_skus;
CREATE POLICY "sku_update_authenticated" ON public.subscribed_skus
  FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
DROP POLICY IF EXISTS "sku_delete_authenticated" ON public.subscribed_skus;
CREATE POLICY "sku_delete_authenticated" ON public.subscribed_skus
  FOR DELETE TO authenticated USING (true);

-- =========================================================
-- 5. dashboard_widgets
-- =========================================================
CREATE TABLE IF NOT EXISTS public.dashboard_widgets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  widget_key text NOT NULL,
  label text NOT NULL,
  visible boolean NOT NULL DEFAULT true,
  sort_order int NOT NULL DEFAULT 0,
  config jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, widget_key)
);

ALTER TABLE public.dashboard_widgets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "dw_select_own" ON public.dashboard_widgets;
CREATE POLICY "dw_select_own" ON public.dashboard_widgets
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "dw_insert_own" ON public.dashboard_widgets;
CREATE POLICY "dw_insert_own" ON public.dashboard_widgets
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "dw_update_own" ON public.dashboard_widgets;
CREATE POLICY "dw_update_own" ON public.dashboard_widgets
  FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "dw_delete_own" ON public.dashboard_widgets;
CREATE POLICY "dw_delete_own" ON public.dashboard_widgets
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

DROP TRIGGER IF EXISTS trg_dw_touch ON public.dashboard_widgets;
CREATE TRIGGER trg_dw_touch BEFORE UPDATE ON public.dashboard_widgets
  FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at();

-- =========================================================
-- Seed default dashboard widgets for existing users
-- =========================================================
INSERT INTO public.dashboard_widgets (user_id, widget_key, label, visible, sort_order)
SELECT u.id, w.wkey, w.wlabel, w.wvisible, w.worder
FROM auth.users u
CROSS JOIN (VALUES
  ('pc_stock', 'PC en stock', true, 1),
  ('upcoming_onboardings', 'Arrivées à venir', true, 2),
  ('upcoming_offboardings', 'Départs à venir', true, 3),
  ('active_alerts', 'Alertes actives', true, 4),
  ('license_summary', 'Licences', true, 5),
  ('peripheral_matrix', 'Périphériques par service', true, 6),
  ('upcoming_movements', 'Prochains mouvements', true, 7),
  ('renewal_alerts', 'Renouvellements de licences', true, 8)
) AS w(wkey, wlabel, wvisible, worder)
WHERE NOT EXISTS (
  SELECT 1 FROM public.dashboard_widgets dw WHERE dw.user_id = u.id AND dw.widget_key = w.wkey
);
