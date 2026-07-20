/*
# ELYADE IT Management — Seed reference data

Populates lookup tables with default values so the app is immediately usable:
- contract_types: CDI, CDD, Stage, Alternant (with has_end_date flag)
- hardware_categories: PC, Phone, Headset, Tablet, Speaker, SignaturePad (person-tracked),
  plus Screen, Keyboard, Mouse (service-assigned, not person-tracked)
- license_types: Seiitra, Office 365
- A few default services for the peripheral assignment module.

Idempotent: uses ON CONFLICT DO NOTHING.
*/

INSERT INTO public.contract_types (code, label, has_end_date, sort_order) VALUES
  ('CDI', 'CDI', false, 1),
  ('CDD', 'CDD', true, 2),
  ('STAGE', 'Stage', true, 3),
  ('ALTERNANT', 'Alternant', true, 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.hardware_categories (code, label, tracked_for_person, managed_by, sort_order) VALUES
  ('PC', 'PC portable', true, 'Intune', 1),
  ('PHONE', 'Téléphone', true, 'Intune', 2),
  ('HEADSET', 'Casque', true, NULL, 3),
  ('TABLET', 'Tablette', true, 'Intune', 4),
  ('SPEAKER', 'Enceinte', true, NULL, 5),
  ('SIGNATURE_PAD', 'Pad de signature', true, NULL, 6),
  ('SCREEN', 'Écran', false, NULL, 7),
  ('KEYBOARD', 'Clavier', false, NULL, 8),
  ('MOUSE', 'Souris', false, NULL, 9)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.license_types (code, label, total_seats) VALUES
  ('SEIITRA', 'Seiitra', 0),
  ('OFFICE365', 'Office 365', 0)
ON CONFLICT (code) DO NOTHING;

INSERT INTO public.services (name) VALUES
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

-- Helper: log an audit entry from the client (RLS insert-only)
CREATE OR REPLACE FUNCTION public.log_audit(
  p_action text,
  p_entity_type text,
  p_entity_id uuid DEFAULT NULL,
  p_details jsonb DEFAULT NULL,
  p_actor_name text DEFAULT NULL
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.audit_log (actor_id, actor_name, action, entity_type, entity_id, details)
  VALUES (auth.uid(), COALESCE(p_actor_name, ''), p_action, p_entity_type, p_entity_id, p_details);
END;
$$;
