--
-- PostgreSQL database dump
--

\restrict 0REjESXUk3ucDeisodJSbigmrbaKL63ZtbDYRfZEbsVgHv0mIJJAWZwedIvmWZu

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assignments; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    employee_id uuid,
    hardware_item_id uuid,
    assigned_at timestamp with time zone DEFAULT now(),
    returned_at timestamp with time zone,
    group_id text,
    group_name text
);


ALTER TABLE public.assignments OWNER TO gestion_it;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.audit_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    actor_name text,
    action text,
    entity_type text,
    entity_id uuid,
    details jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.audit_log OWNER TO gestion_it;

--
-- Name: contract_types; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.contract_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    label text NOT NULL,
    has_end_date boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.contract_types OWNER TO gestion_it;

--
-- Name: dashboard_widgets; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.dashboard_widgets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id text NOT NULL,
    widget_key text NOT NULL,
    label text NOT NULL,
    visible boolean DEFAULT true,
    sort_order integer DEFAULT 0,
    config jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.dashboard_widgets OWNER TO gestion_it;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.employees (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text,
    service_id uuid,
    contract_type_id uuid,
    contract_end_date date,
    manager_name text,
    job_title text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    microsoft_upn text,
    microsoft_object_id text,
    account_enabled boolean,
    microsoft_synced_at timestamp with time zone
);


ALTER TABLE public.employees OWNER TO gestion_it;

--
-- Name: hardware_assignments; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.hardware_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    hardware_item_id uuid NOT NULL,
    employee_id uuid,
    group_name text,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    returned_at timestamp with time zone,
    CONSTRAINT ck_assignment_target CHECK ((((employee_id IS NOT NULL) AND (group_name IS NULL)) OR ((employee_id IS NULL) AND (group_name IS NOT NULL))))
);


ALTER TABLE public.hardware_assignments OWNER TO gestion_it;

--
-- Name: hardware_categories; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.hardware_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    label text NOT NULL,
    tracked_for_person boolean DEFAULT true NOT NULL,
    managed_by text,
    sort_order integer DEFAULT 0 NOT NULL,
    requestable_for_onboarding boolean DEFAULT false NOT NULL
);


ALTER TABLE public.hardware_categories OWNER TO gestion_it;

--
-- Name: hardware_groups; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.hardware_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.hardware_groups OWNER TO gestion_it;

--
-- Name: hardware_items; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.hardware_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_id uuid NOT NULL,
    reference text,
    serial_number text,
    brand text,
    model text,
    status text DEFAULT 'in_stock'::text NOT NULL,
    intune_device_id text,
    atera_ticket_id text,
    purchase_date date,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    title text,
    os_id uuid,
    processor_id uuid,
    memory_id uuid,
    size_id uuid,
    hdmi boolean DEFAULT false,
    displayport boolean DEFAULT false,
    invoice_number text,
    purchase_value numeric(10,2),
    supplier_id uuid,
    budget_id uuid,
    warranty_expiration_date date,
    asset_number text,
    usbc boolean DEFAULT false
);


ALTER TABLE public.hardware_items OWNER TO gestion_it;

--
-- Name: inventory_brands; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.inventory_brands (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_brands OWNER TO gestion_it;

--
-- Name: inventory_budgets; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.inventory_budgets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_budgets OWNER TO gestion_it;

--
-- Name: inventory_memories; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.inventory_memories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_memories OWNER TO gestion_it;

--
-- Name: inventory_operating_systems; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.inventory_operating_systems (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_operating_systems OWNER TO gestion_it;

--
-- Name: inventory_processors; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.inventory_processors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_processors OWNER TO gestion_it;

--
-- Name: inventory_sizes; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.inventory_sizes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_sizes OWNER TO gestion_it;

--
-- Name: inventory_statuses; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.inventory_statuses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_statuses OWNER TO gestion_it;

--
-- Name: inventory_suppliers; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.inventory_suppliers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.inventory_suppliers OWNER TO gestion_it;

--
-- Name: license_types; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.license_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code text NOT NULL,
    label text NOT NULL,
    total_seats integer DEFAULT 0 NOT NULL,
    has_expiration boolean DEFAULT false NOT NULL,
    default_renewal_notice_days integer DEFAULT 30 NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    requestable_for_onboarding boolean DEFAULT true NOT NULL
);


ALTER TABLE public.license_types OWNER TO gestion_it;

--
-- Name: licenses; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.licenses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    license_type_id uuid NOT NULL,
    seat_key text,
    status text DEFAULT 'available'::text NOT NULL,
    assigned_employee_id uuid,
    assigned_at date,
    expiration_date date,
    renewal_notice_days integer,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.licenses OWNER TO gestion_it;

--
-- Name: microsoft_license_filters; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.microsoft_license_filters (
    sku_part_number text NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.microsoft_license_filters OWNER TO gestion_it;

--
-- Name: movement_actions; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.movement_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    movement_id uuid,
    action_type text,
    label text,
    due_date date,
    done_at timestamp with time zone,
    notes text,
    sort_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.movement_actions OWNER TO gestion_it;

--
-- Name: movement_items; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.movement_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    movement_id uuid,
    category_id uuid,
    hardware_item_id uuid,
    status text DEFAULT 'requested'::text,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.movement_items OWNER TO gestion_it;

--
-- Name: movement_licenses; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.movement_licenses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    movement_id uuid,
    license_type_id uuid,
    license_id uuid,
    status text DEFAULT 'requested'::text,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.movement_licenses OWNER TO gestion_it;

--
-- Name: movement_service_groups; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.movement_service_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    movement_id uuid NOT NULL,
    group_id text NOT NULL,
    group_name text NOT NULL,
    group_mail text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.movement_service_groups OWNER TO gestion_it;

--
-- Name: movements; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.movements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type text NOT NULL,
    employee_id uuid,
    service_id uuid,
    contract_type_id uuid,
    contract_end_date date,
    effective_date date NOT NULL,
    source text DEFAULT 'manual'::text,
    manager_name text,
    job_title text,
    notes text,
    status text DEFAULT 'pending'::text,
    calendar_event_ids jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    manager_email text,
    microsoft_service_group_id text,
    microsoft_service_group_name text,
    microsoft_service_group_mail text
);


ALTER TABLE public.movements OWNER TO gestion_it;

--
-- Name: onboarding_action_templates; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.onboarding_action_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    action_type text NOT NULL,
    label text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.onboarding_action_templates OWNER TO gestion_it;

--
-- Name: onboarding_details; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.onboarding_details (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    movement_id uuid NOT NULL,
    contract_type text,
    employee_status text,
    employee_level text,
    gross_annual_salary numeric,
    variable_bonus text,
    contract_reason text,
    school text,
    internship_mission text,
    referral boolean DEFAULT false,
    referral_employee text,
    cv_file_name text,
    cv_file_path text,
    created_at timestamp with time zone DEFAULT now(),
    company_car boolean DEFAULT false,
    pdf_file_path text
);


ALTER TABLE public.onboarding_details OWNER TO gestion_it;

--
-- Name: processed_offboarding_emails; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.processed_offboarding_emails (
    message_id text NOT NULL,
    processed_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.processed_offboarding_emails OWNER TO gestion_it;

--
-- Name: service_peripherals; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.service_peripherals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    service_id uuid,
    category_id uuid,
    quantity integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.service_peripherals OWNER TO gestion_it;

--
-- Name: services; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.services (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.services OWNER TO gestion_it;

--
-- Name: signed_documents; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.signed_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    movement_id uuid,
    doc_type text,
    signer_name text,
    signer_email text,
    signed_at timestamp with time zone,
    status text DEFAULT 'pending'::text,
    content_snapshot jsonb,
    created_at timestamp with time zone DEFAULT now(),
    signature_data text,
    pdf_path text,
    pdf_generated_at timestamp with time zone,
    email_sent_at timestamp with time zone,
    email_error text
);


ALTER TABLE public.signed_documents OWNER TO gestion_it;

--
-- Name: subscribed_skus; Type: TABLE; Schema: public; Owner: gestion_it
--

CREATE TABLE public.subscribed_skus (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sku_id text,
    display_name text,
    applies_to text,
    enabled_units integer DEFAULT 0,
    consumed_units integer DEFAULT 0,
    prepaid_units integer DEFAULT 0,
    synced_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.subscribed_skus OWNER TO gestion_it;

--
-- Data for Name: assignments; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.assignments (id, employee_id, hardware_item_id, assigned_at, returned_at, group_id, group_name) FROM stdin;
e21e60f8-dc09-4d0e-8a0c-94fd8dd4b5ff	67a15374-4fb2-45b7-b17b-d92803dda093	504cd49c-5767-441c-85fc-b7e6f44752f2	2026-08-27 13:52:51.566754+00	\N	\N	\N
85b6a29a-d264-4a4e-9d25-9417cdc961d9	62825a56-d294-42b1-9488-cc41ba7af2e3	83de2b8f-24ce-4bab-973d-354fddb50d24	2026-08-27 13:52:51.580001+00	\N	\N	\N
15b8f050-4443-4cc1-84a7-06330c6759f2	8a3cae01-f152-423d-9a56-31a4fbcda459	e2bd998b-cbe0-426b-bb5a-ca8a5e7cefee	2026-08-27 13:52:51.589734+00	\N	\N	\N
f5252afe-db84-4579-b5d0-dd32d440c7e8	444e04c7-6655-4235-b260-54051ac6a617	2e287485-a401-4daf-be75-7864ca816924	2026-08-27 13:52:51.600784+00	\N	\N	\N
a75b4860-6f94-4ea6-88a5-29958bb7c180	353a3cb6-3af1-4d2a-88fb-414dcd089eb4	5f4cc620-9767-475a-ab9b-2107aaff29c3	2026-08-27 13:52:51.609548+00	\N	\N	\N
8f4a5916-8ba3-479c-802b-e151e449d3fd	ca071ca7-de86-41a1-bdd8-b1dbf0860682	26d31eec-d990-4eff-bc0e-9a316f049945	2026-08-27 13:52:51.617015+00	\N	\N	\N
157c8d2d-29dc-4733-8a35-5b2b6b7c107e	b879539a-de37-4fc7-9151-0c5566faad30	5ab2f8a4-d338-49b1-9196-8bcad9b32967	2026-08-27 13:52:51.629109+00	\N	\N	\N
52edf5c1-4732-41cc-a7d2-368450b8c7da	c7e3300a-fe49-4b28-aafe-c2402982831b	8afa3cb8-b8fb-42ea-9b8b-921e454a0b45	2026-08-27 13:52:51.637465+00	\N	\N	\N
122d7eaf-f954-43ae-b9b7-37dc585e76be	d0f3989d-81cb-48f8-afdd-e926c6d53ebe	be94d2a7-e11c-42ed-9e30-23ecbe350fc9	2026-08-27 13:52:51.643941+00	\N	\N	\N
8a9b1458-4a97-4718-b2d5-cc79b18cac7d	0d15c9cd-6825-4027-9637-c4808db041ef	b04eb105-e7e5-413e-97df-e55b0d1e7062	2026-08-27 13:52:51.650278+00	\N	\N	\N
04c6c938-066e-4d84-97a1-0931637e8533	0d15c9cd-6825-4027-9637-c4808db041ef	c58c54ed-e678-4194-b02b-93903ffb8e91	2026-08-27 13:52:51.658822+00	\N	\N	\N
1a182292-0531-4210-aa5e-c155bc219ecd	0b0b9e6e-7a8f-48a5-a80b-0aac21d13158	ae685279-e184-48b2-8b9e-58e2020a0290	2026-08-27 13:52:51.664613+00	\N	\N	\N
566c3821-800b-406e-aa26-fad1d240b5b7	f5509f28-5d95-4659-9d72-e61ac963e824	cc942cf3-2a5f-45cc-876c-b63eb445fe20	2026-08-27 13:52:51.67045+00	\N	\N	\N
247571c5-f9d3-4020-8efc-5f18b20b7c3f	ddd7b7c7-e9a5-4884-bca2-f911d16dc496	386c2382-8ae8-429d-9a29-8160770e22fa	2026-08-27 13:52:51.677966+00	\N	\N	\N
d42d9fe3-497d-4ecb-8a5a-5c79041d50a0	5027181d-b736-4199-ae12-b407eea5631d	cc9d93fe-d9e3-48b5-a364-b1ee6d0ca286	2026-08-27 13:52:51.682638+00	\N	\N	\N
ab4cd288-5672-473f-9b98-f76e40234ef2	089fa072-87d5-4d87-beb9-c3d9a34b0d73	672c11e3-2a69-4af3-8c2b-9a03ef928156	2026-08-27 13:52:51.687183+00	\N	\N	\N
a7d2ab9f-e54f-4d43-8025-c62319e65604	e143e82d-f0a6-437e-9151-76f6ca279a06	039bfe89-85f9-4b8e-be6e-d092c5cc3d7a	2026-08-27 13:52:51.697612+00	\N	\N	\N
6610f8f3-6d0b-49c8-8c6f-c22de8e8d3dd	a5a6872a-ebe1-4401-9e04-036f29764adf	19f0ea05-2bbd-4532-a6a7-d6be6f18982f	2026-08-27 13:52:51.705708+00	\N	\N	\N
204f7e17-5ac3-4aff-9f56-d94e554ea119	9065235a-5dbe-42c0-9bbb-3557592c5e2a	11b315f9-cd73-48bf-9cb2-b3771cba8f66	2026-08-27 13:52:51.713916+00	\N	\N	\N
9b4c09f2-f630-4c5d-84ff-8c013105eb47	0a7d08d8-d7a1-4510-8a6f-dd7c6ea30f99	c3aed48f-bbbd-4793-8848-449aa3a45e0c	2026-08-27 13:52:51.719113+00	\N	\N	\N
8568a567-760d-4594-85be-3c10f6c59619	3ee22ac9-0477-4511-86b9-0f2490ad3efd	2b95e275-3aa5-480f-bafd-5bf363aba77f	2026-08-27 13:52:51.727778+00	\N	\N	\N
3ba2c897-5016-43a8-9e17-31835ab0a829	1758e62e-2ca5-4996-862c-7e4a016121ca	46cfb42e-a9ee-4835-9a57-fbd5c1216723	2026-08-27 13:52:51.74771+00	\N	\N	\N
8222ebd8-79b9-421b-bde0-25dc3376fb7b	d599617a-9ad6-4407-bf89-40ff581f9e06	1e70e6a4-7515-4272-86e5-e105e506abf1	2026-08-27 13:52:51.762178+00	\N	\N	\N
377aef42-e6eb-4d9f-b822-760bc4595e29	eebd0b93-b853-4497-81c3-417686db6d6b	8f87e689-6e33-4dea-911b-c1895c5b83ba	2026-08-27 13:52:51.769505+00	\N	\N	\N
ae5c61fd-76e8-4069-9093-6502bceb5552	06add6f1-e7a4-4a8c-a6a9-e1065db303c8	b7c54d47-fbd0-49b7-9327-c1b52af883d3	2026-08-27 13:52:51.785305+00	\N	\N	\N
9366f060-8529-4184-838b-b2d81ed0f942	dac6b804-7dd0-44aa-9eef-151b056591db	3e836a03-7c1b-468e-9f99-bcabc647eb14	2026-08-27 13:52:51.817558+00	\N	\N	\N
fff5301c-7100-4819-a46b-40dc11e2d276	4b1abe45-669a-4c9f-bb9e-eecbda56240d	4d617e82-a6b4-45b2-9760-8af581999015	2026-08-27 13:52:51.823601+00	\N	\N	\N
229128fc-9629-4b5b-a518-4628c53c8270	c8486efb-2791-46a7-862b-a033d4c7218d	2fc321d2-e6f8-4333-83ee-c1425ce9d5e7	2026-08-27 13:52:51.83743+00	\N	\N	\N
fd07e629-e3cc-43d6-a5f6-d768adccfd34	8b1a90a9-1974-48a0-abfd-06cc552fade5	a5986267-7e47-4eda-9e1e-899746c99d06	2026-08-27 13:52:51.842819+00	\N	\N	\N
aab6da0b-f8dc-448a-8eae-a445397372c8	f56a985e-06ae-44b7-a5dd-a3c87dae0dee	f55391ba-9e07-4c0f-8b04-c4d6af867a38	2026-08-27 13:52:51.847503+00	\N	\N	\N
031ce571-af52-4760-b309-09032f7cb5ff	5aeb030d-1a20-4162-b6ec-0912ea44547e	b80e1754-1bdc-4878-84a3-53c0016e2143	2026-08-27 13:52:51.856971+00	\N	\N	\N
e61eb84e-2422-49c9-a266-32fac64c204e	3df0dec0-7d7b-42e1-be5b-3befb44ae276	1bd90f40-abba-4947-aebb-4c6ada82e26a	2026-08-27 13:52:51.86641+00	\N	\N	\N
3135400a-d80d-4683-ac78-26b62f88c817	949c8129-c894-46dc-9fe4-85d8a55bad96	69dbb3a1-4dbb-46ab-8f65-c7aa1dabaddf	2026-08-27 13:52:51.878222+00	\N	\N	\N
bd6c663e-2ad7-4b4a-be34-c8cd29f28715	1b558fb2-b0dc-409d-9c82-bcebfa448a08	c93e091c-1f71-4c64-a768-ad5bfdfc23d4	2026-08-27 13:52:51.882657+00	\N	\N	\N
816b12f4-5636-4d45-baa6-e7d291e5613a	6e7662ae-3bbe-4f61-8b32-dad4b1417fce	199a7413-03f5-44bb-90bd-03b62a5f898a	2026-08-27 13:52:51.888544+00	\N	\N	\N
37c42d13-1eec-4723-bb0e-d9e61c4d11d2	4efac293-84a5-40b1-b82e-044ef50720ee	5037a231-994f-4461-9d0a-e4ad26d0bb7c	2026-08-27 13:52:51.897042+00	\N	\N	\N
31092f4d-fd5d-4d3f-9ba4-07684ba5494f	47d649ea-5c0a-40a0-8338-b3c7e0697f1d	792d9c94-8ac6-4097-988e-fc2b4778e0ce	2026-08-27 13:52:51.902967+00	\N	\N	\N
765c4999-4775-485e-a035-1771ee8021fb	c1f31f22-5966-46e4-9487-6f6fdc24007a	ad8a6a80-518a-4e32-b6c6-3d768ef7672c	2026-08-27 13:52:51.909487+00	\N	\N	\N
f3cbfc53-85a8-48d8-bd70-201768aba5d6	ac51fd68-5eaa-4066-b39e-88a5a6b3034d	10d92acb-1af2-46ae-aba7-829024611c39	2026-08-27 13:52:51.922017+00	\N	\N	\N
ad08f2f0-78d4-4b91-bf1e-a5c496e22b68	0dce424d-c1a8-4fe4-8ec9-3ff08e35a631	f1d876bb-c999-41bb-bf9b-f620f6b462c3	2026-08-27 13:52:51.931739+00	\N	\N	\N
1d0eac6a-d966-4363-9501-4d417220d38a	94946c82-3397-4a16-95d4-8937e9fdbeea	efbec61d-63d5-4ff6-81ff-6097ae8d00cb	2026-08-27 13:52:51.946723+00	\N	\N	\N
7639f72a-124a-477a-b850-844b962e40f6	\N	5e49fba4-a303-476c-8041-82d2cdb5e482	2026-08-27 13:52:51.956285+00	\N	\N	🏢 Pole Gestion - Membres
3646b4b5-8749-4055-ab7c-ff2f3fcfe1f5	1bc9c89b-a771-442a-8921-26e105e8fb23	3b7c0f55-01fa-42e4-99e0-e9020404c945	2026-08-27 13:52:51.961098+00	\N	\N	\N
f7287866-0c82-43f4-a259-0fee5e6c15f0	d0f3989d-81cb-48f8-afdd-e926c6d53ebe	6b61a653-8659-435c-be37-33f4084705d3	2026-08-27 13:52:51.965385+00	\N	\N	\N
cb46ef76-2b46-4806-a8ae-0339ff2bb7a3	7c678469-22f7-465e-905e-9696f3fd9754	31f21015-6900-4c8a-b563-06315df91bff	2026-08-27 13:52:51.969822+00	\N	\N	\N
2742a48f-bdf9-4a48-ada9-880cb4e8ea05	2072bfae-71ea-4931-b9f7-b35f96aec16c	14e4af3d-fb74-44c8-be08-97dba4cca479	2026-08-27 13:52:51.974891+00	\N	\N	\N
b43ccdf3-306e-47df-a00c-1bb099bc42d9	835e058d-b2fe-4387-8c6a-2434f5a40065	a691d8cf-5b12-4ea3-ae5d-98abf2205060	2026-08-27 13:52:51.982231+00	\N	\N	\N
5c0bb681-17c5-406f-9f1e-d3f32e01662a	d332732c-b65e-4733-9d07-bacff5667d34	54413157-435c-41cf-818c-b9c776460dcf	2026-08-27 13:52:51.986008+00	\N	\N	\N
d64b307a-374f-4b94-8af6-c61da4588d76	af21baf0-247d-486c-84ee-5f01f048deea	e3b9a878-d04c-4eb8-b34c-f59ad4aae656	2026-08-27 13:52:51.990315+00	\N	\N	\N
b35b359c-dcf8-4a02-9e47-9a407f791ef7	624b8afa-d057-4c18-b7f1-e165bb81895e	4ecb8aa3-2ab4-4cef-9ed8-40426cef5b44	2026-08-27 13:52:51.995567+00	\N	\N	\N
75f59832-05c4-42bf-a337-ecd7ef5cbb31	28cbe8e0-28d1-4d4d-9747-6ee4f3cfb79a	61096722-ef9c-43d6-a3ab-5612feb94f47	2026-08-27 13:52:52.001404+00	\N	\N	\N
335871c6-909f-4205-a02b-32714f375612	011fd794-af58-48a7-bffd-e7c71af42a2d	ceb16e59-ec61-4a29-abcf-61f730097f8b	2026-08-27 13:52:52.010373+00	\N	\N	\N
989a0774-8016-492d-9132-69de530aef22	a2f07f8e-0b1e-4ea9-aa51-30d9b0f0269b	618a8198-60e4-47c8-bb13-396bd887fb39	2026-08-27 13:52:52.018576+00	\N	\N	\N
720601a7-538c-4ba7-86fd-8d69b0242ccb	e062c123-edff-4312-8f10-26b8d1846bd5	6b1e5aa3-903d-4fa8-8676-179480fa5c27	2026-08-27 13:52:52.024324+00	\N	\N	\N
91232491-9d49-49ba-9cca-ea7281eefe8f	12b792db-ddc9-4cbe-b2b7-40a050a6aab2	2e9169b5-fcb7-45ce-bb51-4982b95a4806	2026-08-27 13:52:52.109087+00	\N	\N	\N
a50b1df8-2d4c-4838-9bbe-6389dbc1ac23	c390c330-806a-4eb9-a910-1c5887fed2cc	c42b03b8-0d64-4605-8fed-b27ee3f8e115	2026-08-27 13:52:52.11706+00	\N	\N	\N
1dd180d9-6ade-45e5-8ce0-4700898d278e	011fd794-af58-48a7-bffd-e7c71af42a2d	55fbe128-eb3f-4e55-9596-94282160b105	2026-08-27 13:52:52.123708+00	\N	\N	\N
36c8c2a0-d3f9-4861-9ba9-53e55704e4a9	1bc9c89b-a771-442a-8921-26e105e8fb23	49f9a078-e085-40f6-9590-09df40a850f0	2026-08-27 13:52:52.130305+00	\N	\N	\N
7f5c0a60-a0f6-4fd8-80e3-cdbcbfaff358	93022cf0-2102-454b-bece-f0f0f7fbb888	d87510ac-398f-4083-bb46-4426226e0d91	2026-08-27 13:52:52.13481+00	\N	\N	\N
86deb33a-828f-4c57-b4d3-1c16559af90b	cdbd094b-2737-408d-8a1b-84d04221564e	464501ce-35cc-4687-9eee-2355d17bb43b	2026-08-27 13:52:52.144801+00	\N	\N	\N
79a3317a-29a8-4e0a-9c89-4f1391c413e9	379cccaa-e70b-4dd8-a6af-b8002a72c0cf	b9b0bad0-53dc-4d76-a91c-c31609b47948	2026-08-27 13:52:52.150776+00	\N	\N	\N
d1004aa5-8dd3-44cb-9286-0664ff68a515	12b792db-ddc9-4cbe-b2b7-40a050a6aab2	71fcbe7d-2ae9-4796-b443-d14ba678b873	2026-08-27 13:52:52.156584+00	\N	\N	\N
3e8654a6-c7f8-4fec-992c-6a14e063ac8e	38b36da7-b0d1-4662-be52-b6ee57aca061	eb419c86-8ea3-44e9-b82f-a028f930a33b	2026-08-27 13:52:52.170291+00	\N	\N	\N
1379daac-17bd-4aed-8595-0d6951a0568c	332e4560-d344-482f-a585-9840f287e29c	6e0e9c64-b7af-4810-aba3-0878e77b0d08	2026-08-27 13:52:52.182697+00	\N	\N	\N
eaa2c4b4-49fc-4e51-9887-cda004a3db63	b6edb5ed-b618-4d73-91f2-baab882280c5	b4f0ce9f-f7aa-4cf4-aa88-4dd6f0c4cdd3	2026-08-27 13:52:52.197174+00	\N	\N	\N
0f3d9882-3a2f-44f1-a15a-c357dbff5d1c	d2d8d59b-d86d-4485-bd98-3086eda03728	a8841aa5-7911-4237-9dd4-d06d71927588	2026-08-27 13:52:52.200742+00	\N	\N	\N
e2e48bfd-57f0-4f25-8592-7010d4707e9b	f924a33d-9e33-4ac2-bf9c-610260528a75	f47ae662-b814-4e53-bc37-821e2430b39e	2026-08-27 13:52:52.204289+00	\N	\N	\N
24e4ffc8-a52e-4230-879e-0675d133669c	379cccaa-e70b-4dd8-a6af-b8002a72c0cf	4c99897d-2c85-4b0a-8909-b75925519659	2026-08-27 13:52:52.216965+00	\N	\N	\N
0951e105-9ab4-42f0-b630-af4408772407	2fb8e5c5-afa8-4103-b324-f045e2fc0ed0	e95ed0bd-9f4e-4e01-9294-d0999d60f57c	2026-08-27 13:52:52.223011+00	\N	\N	\N
24d01a75-0f7b-4a64-befd-6b295d2ae0e1	b034df7e-e084-4199-a48b-77d2012c816d	d605e023-b0c8-4aca-8841-0eda4002ffc6	2026-08-27 13:52:52.231581+00	\N	\N	\N
da14c65c-4b38-467f-9bd7-be223105db63	f97bf5d9-114d-466a-b855-d17caee3e260	c385d20a-7411-41fd-be0e-71342850a981	2026-08-27 13:52:52.235928+00	\N	\N	\N
8f28db60-fd96-4764-abbf-229b6d341e59	b19c168d-5d4b-4a65-983e-e9b0b7ab5105	062b0b80-1619-4cc2-a299-d20dd56e18b5	2026-08-27 13:52:52.252681+00	\N	\N	\N
450c49dc-61fb-4edc-adad-b269391e6dc8	55b21729-5058-4fad-b7c1-c455a5485274	74a8b22c-0cd4-49e7-87f6-4721e71e2797	2026-08-27 13:52:52.259473+00	\N	\N	\N
21ead07f-8343-40a6-8f22-1744f3204911	b5066669-f502-40ba-a6c3-815ed0c04b1e	55257ab9-0497-4bec-95e1-62f5808025b1	2026-08-27 13:52:52.271647+00	\N	\N	\N
abfaf4db-5ba7-4b7f-a943-4e40c2074edd	533716fc-b5c3-4565-b5c9-2e520a37b4b8	a4c1d217-2e35-42ac-9c86-79e31292ec42	2026-08-27 13:52:52.277895+00	\N	\N	\N
639075e3-1f33-479d-9552-41c07e0377cf	9974a641-06b3-4a2a-b2be-323cc17f7a21	2bed3b9f-46db-4e64-9783-89fce001fc40	2026-08-27 13:52:52.281554+00	\N	\N	\N
a5e1dbf8-b333-402e-851d-b26f96860157	e47b7fac-fc2a-473f-a536-f3e366d83887	8c10445c-5ce9-4934-abd5-9cbc633cad4f	2026-08-27 13:52:52.285287+00	\N	\N	\N
4b2a9943-93eb-465f-a543-6207169c546e	6bd4d90a-fb4e-4ded-ad05-62efba5bb299	753c2761-e170-4677-9217-c84fb9f43a33	2026-08-27 13:52:52.289468+00	\N	\N	\N
ea5ebddd-3f80-4d00-ab98-09b76a9c8b2f	27fd1784-c0c8-4669-bba2-19a68cba8a26	b4f2f2ff-b987-4df0-94ee-6fac4b3f86bc	2026-08-27 13:52:52.293368+00	\N	\N	\N
375628b5-a404-46c6-9f17-1b4fa418d05e	0a7d08d8-d7a1-4510-8a6f-dd7c6ea30f99	c2e27d53-96ad-4b40-bd5a-ba4f1ffb3a22	2026-08-27 13:52:52.303892+00	\N	\N	\N
1dffa105-5964-4dfb-b64b-42634ab4bd8d	8bc894ba-63e8-4902-9cb2-96eb0ca1b713	e2e4c3a2-5bc6-4bc0-b7ae-af3a299b8d62	2026-08-27 13:52:52.312597+00	\N	\N	\N
b61bdf54-9b89-4c4c-98fd-5c2503ca3e3a	f7acd69e-21af-4923-8371-a465df0e0006	44707ad9-f9f7-47a4-a4c9-9854fe30de53	2026-08-27 13:52:52.317251+00	\N	\N	\N
eb1484bb-767d-4b0f-9893-e39ca87713a7	41bc86f4-b749-436e-b2d4-6acc57903fcd	1b25cf14-ad60-4877-92ae-e4c91753f68b	2026-08-27 13:52:52.321714+00	\N	\N	\N
b19aeda6-26ff-4f88-a342-f6030970d69a	f97bf5d9-114d-466a-b855-d17caee3e260	6c4b1765-cace-42e3-80bc-78d719251158	2026-08-27 13:52:52.326209+00	\N	\N	\N
12052bc1-549c-47ad-9a54-8ecaa17e9b6b	b4c59353-93b4-4b09-88b8-1c9b010a79be	408d1420-c53c-49c2-acff-5fbd5b85ba51	2026-08-27 13:52:52.330573+00	\N	\N	\N
ac5fcffd-5462-49a9-bdd4-ddc809ee9ff2	d2db7239-1ca7-49b3-bc43-86c0cb25a825	b81f912f-afe4-4e4f-b459-37e1e1ca885c	2026-08-27 13:52:52.333952+00	\N	\N	\N
c0028434-28fd-4bfa-abcd-da2497a0910d	e8ee2211-2079-4c3e-8eec-6c67f4ef71ad	66c0fc17-776a-4fe9-8a88-10a88c5b9321	2026-08-27 13:52:52.337931+00	\N	\N	\N
2941eacd-9603-46f3-91dd-74a369cf242e	c64b1a5f-f7f8-4966-b5be-57e7d35a7b9f	77f2e45e-268e-4ca4-b699-4a3705f89c38	2026-08-27 13:52:52.34306+00	\N	\N	\N
35fa7ecd-37bf-499b-bbc4-c980c056f4dd	9799327d-781f-4c43-a284-08528389e366	6f02a407-07df-4c93-8b59-41309c136fdc	2026-08-27 13:52:52.347172+00	\N	\N	\N
625bc706-7b41-469f-819a-6be9b41667e0	c1f31f22-5966-46e4-9487-6f6fdc24007a	a088fc33-9349-4c6b-9871-3a80ca62bf99	2026-08-27 13:52:52.35152+00	\N	\N	\N
0c4e0a89-d9ab-41d0-bd76-cde39603560a	32fda97f-4cf9-485a-82be-e93ef5070597	237576c5-f79a-4834-a63f-762032dd31f4	2026-08-27 13:52:52.356319+00	\N	\N	\N
1aae813f-87d5-476b-8fa1-b3b29335a506	60dd1daa-9636-4017-8182-74bc53fb122d	5c5bc088-1f4c-452c-a524-ac6adb3b938b	2026-08-27 13:52:52.359774+00	\N	\N	\N
e9314c16-58fc-4b45-b9ad-e276bec956ea	e062c123-edff-4312-8f10-26b8d1846bd5	8acbbb09-4818-4dec-8bcc-345b59f4b67d	2026-08-27 13:52:52.363933+00	\N	\N	\N
b7989470-bf90-4279-b070-0c361b37c934	40b4e542-806e-491e-9218-e7eae5547492	ac0d185a-6836-42cc-afba-a1ee31480167	2026-08-27 13:52:52.36764+00	\N	\N	\N
bf2f5d68-00cd-4b4c-9521-38c4db4dd9b6	093bf052-2c9e-4c20-bf8e-6c218eca2a55	407d9c93-0af3-4ddd-8f90-aafd7d3d4c2f	2026-08-27 13:52:52.373475+00	\N	\N	\N
11616e22-f7b0-46d5-9c16-cc4c5b66fc4e	79d59a7e-d32c-4723-a9e3-80a370d4ed60	ccaea36a-e26b-4cd0-a6a0-8542e33c0717	2026-08-27 13:52:52.379905+00	\N	\N	\N
1246c791-7b15-46f0-963c-978d6cd87a83	56b096de-5526-435e-8ad6-183e9e9c7d84	325bf443-a67b-47dd-89b4-29a51bb8566c	2026-08-27 13:52:52.383048+00	\N	\N	\N
4274628c-6af1-45c5-8fcb-1f765050f8e4	62d06322-8057-4756-9750-fb595d22f5e8	69d2dcf9-97fc-4ca7-a289-e1c631bc94cb	2026-08-27 13:52:52.389347+00	\N	\N	\N
d0cb234a-2cfc-47ab-8c4d-14814de1dd93	8f444a89-57da-4701-a844-496667163785	44e6bf26-881c-4026-b223-d4f18ad56692	2026-08-27 13:52:52.3936+00	\N	\N	\N
bb50aaba-14e0-4c9e-8d14-828aed9930b6	17b27cd2-575d-4d51-b91c-00c52aa7d060	3c8290f5-da9d-4d9d-9ecc-24a7ebe9d198	2026-08-27 13:52:52.397434+00	\N	\N	\N
041aca40-a5ec-45f0-99a5-b5e599121908	a0c0e609-3488-482f-b518-cf726119cd3d	a6e23e07-d016-45d5-bc09-6a83ada9e4b4	2026-08-27 13:52:52.401025+00	\N	\N	\N
8a7f6c29-cc85-4f1e-99db-5c6161e87f5b	56cec5e0-aee5-4f42-b08c-02c0f743453a	3bef5c8e-75cd-481f-b4bf-71d7e9855c1f	2026-08-27 13:52:52.404851+00	\N	\N	\N
840ced25-d75b-47e1-84cf-03963e908518	835e058d-b2fe-4387-8c6a-2434f5a40065	28503f39-4b58-474d-9d90-a890cb6d4298	2026-08-27 13:52:52.408488+00	\N	\N	\N
ef5ea05d-b4ed-4d55-814f-03636f436c29	6e5256c5-869a-42a3-b1bd-f316c085dec9	14f4afbc-187c-4d93-9c74-d2c6441c8e35	2026-08-27 13:52:52.413746+00	\N	\N	\N
c5384306-303e-40f0-bc12-41c9cb6d86bb	a45742a5-894a-4a32-83b8-0b3cf7cfb970	c14ac38c-c1dd-41bd-bbf3-b36f9359262c	2026-08-27 13:52:52.419865+00	\N	\N	\N
1184f33b-937d-42b2-9f1b-0fe9c64a6c3f	85cc63ff-7df5-4fe8-ae5b-96f55bd68811	9c01634e-7a4e-484e-abe3-cdfc2c87d405	2026-08-27 13:52:52.431536+00	\N	\N	\N
b7a1c893-b8c1-4087-b6d7-71abd53c8523	fed7ae60-6b89-49c2-b2eb-a472b1789ca0	60818c0a-2db2-448d-bea6-1f7b2bd24a7b	2026-08-27 13:52:52.437713+00	\N	\N	\N
4b610f25-5f7a-4664-bc9f-879171309a00	7a0824ae-2296-44d5-8e32-669745de4c12	d8de54ea-ac31-4a43-9526-6396232ba18b	2026-08-27 13:52:52.442997+00	\N	\N	\N
eede30e0-a703-461c-82f5-7d6717475cdc	7b830831-6b84-4f8c-b6b2-bed2e07c2502	7ac3e90b-f2fd-462b-9a8b-7911398867c4	2026-08-27 13:52:52.504944+00	\N	\N	\N
9de95fd7-bd91-4c40-ab91-e6643d7d61a0	f3b2032f-00f9-43fb-951f-4e9596848dc3	c5bb0233-ab70-498e-b157-c4aa0157592d	2026-08-27 13:52:52.510001+00	\N	\N	\N
2993e541-4acb-44eb-8919-ab9ecd0552ab	9974a641-06b3-4a2a-b2be-323cc17f7a21	a1e8ffa9-cdfb-468c-a8dd-9f0bf36f43c8	2026-08-27 13:52:52.514236+00	\N	\N	\N
171a7ff6-3201-4a09-bd96-756604e4c6dd	af477549-4032-4bc5-a340-ef63921d1a65	62b707cf-5bb6-4b89-a9aa-6185eb1bdbb7	2026-08-27 13:52:52.522288+00	\N	\N	\N
a2557bd3-9ac1-4ab3-a725-68bd3583311c	d76138d8-2d01-45a2-a025-bde2ea8f3819	ba73d2b0-14a5-405a-b818-b1e4a6de0c7d	2026-08-27 13:52:52.528561+00	\N	\N	\N
3d5fddf6-8731-42b4-82ee-d221ff41b9a0	df94363a-8e80-45ce-a78a-e91ea33fb6ee	eac493d0-f097-427e-bee7-1ef988523654	2026-08-27 13:52:52.532761+00	\N	\N	\N
12bf747d-a919-44fc-80f0-78c7341d3aa3	bafcbdde-b731-4ed8-a334-2202d4cf4d98	1dcf0c6a-edff-4e76-99f5-41a31b5d68b1	2026-08-27 13:52:52.537399+00	\N	\N	\N
4b217f59-a464-49ae-bf10-642fc6af88bf	04c017aa-66e4-4d34-a1af-634088e37b9d	471b2e75-11bc-44db-ba71-c87c6f53043d	2026-08-27 13:52:52.543104+00	\N	\N	\N
d914acdd-3d06-4106-babb-917a891fd20f	0a7d08d8-d7a1-4510-8a6f-dd7c6ea30f99	40981cfa-4c42-4a87-9744-6fc1fe5662ce	2026-08-27 13:52:52.550756+00	\N	\N	\N
a41b8ba3-309b-47c2-abbc-b93e3afa8ab3	f9e5949c-1359-4820-928e-2bb57723ccd5	54195c87-6b75-4c01-b4d6-e359dbc0b01f	2026-08-27 13:52:52.559685+00	\N	\N	\N
0ab12899-85f7-4b4f-b9a4-4f61bdf8d478	114f8ba5-5564-42c4-9034-2e01a493c713	73552151-386d-4f81-be6a-d5284e4f1ecb	2026-08-27 13:52:52.563962+00	\N	\N	\N
3c9d74bf-0818-4c94-a62d-0db4168fd569	3ee22ac9-0477-4511-86b9-0f2490ad3efd	d6dd2963-c2ea-42c2-8b57-77d00305043f	2026-08-27 13:52:52.573193+00	\N	\N	\N
b61cb948-d5a4-41a6-ae2c-b29a8f0986c0	ac93458f-7a43-45a1-b163-67f5769e55f8	8c7f1ef1-d20b-40b2-ba6c-586f030ac422	2026-08-27 13:52:52.57762+00	\N	\N	\N
0b88c7b2-bfca-45b3-b97e-442016f8bb84	1d64afa0-46c7-4add-9402-f81fe8c9db9b	9eb2d449-b561-4f18-bb5e-9f5b66c7a9aa	2026-08-27 13:52:52.583412+00	\N	\N	\N
d724e719-c6b1-4996-b4c5-9672f04ca9bc	6a300cbe-f185-4dea-833c-3e73e3278d14	db6a32cf-c7b9-4907-88b1-d0811640c541	2026-08-27 13:52:52.587023+00	\N	\N	\N
aeef0bf4-cafe-4ecf-9cf7-ed181e85ef53	125ed49d-4a83-46f1-a3f4-abd1380b639f	cdb8c2c5-28b0-46f7-b7a3-19b986e06d01	2026-08-27 13:52:52.59082+00	\N	\N	\N
fe6aa668-c015-4620-a35c-9db058b01198	690d99b6-c9bd-4fa6-bb8e-5c28874e0762	c62cb68f-3da1-4a44-93bd-5e0635029242	2026-08-27 13:52:52.599243+00	\N	\N	\N
88d0ecc7-8732-4c0a-b161-91d3859ef995	2b67753a-e872-408d-a2a6-b1e970334a2b	504309be-c3c5-447d-b2f3-909d607fd815	2026-08-27 13:52:52.603166+00	\N	\N	\N
3074b0b7-7919-4414-9214-76766161b5ec	c8486efb-2791-46a7-862b-a033d4c7218d	8a408b20-7f08-4404-b227-215f0b3d1635	2026-08-27 13:52:52.60769+00	\N	\N	\N
b1ab4a69-05c3-4767-94cd-4204fb960bbe	ac55a2c1-d471-4e28-9e74-bd89845f2904	e3e6e43f-58fb-4bee-9119-ecf78836f569	2026-08-27 13:52:52.612183+00	\N	\N	\N
c90a4d30-ac0b-473e-b978-3ab95ffec66b	b425a749-eddf-4991-951b-045fae50c701	374693f8-d6c5-4d7d-8ad9-8c4379dd881f	2026-08-27 13:52:52.617197+00	\N	\N	\N
a3a847a2-a822-4846-b849-562332b29007	8b1a90a9-1974-48a0-abfd-06cc552fade5	7970f3a2-38db-402e-bd1d-1198302aa45e	2026-08-27 13:52:52.621895+00	\N	\N	\N
3eaaf8e1-e5f6-4afa-b332-1c5ee0f73466	101b53e9-b554-478a-9e95-3a2c2d44c9f1	7eee1aff-c151-45f3-b529-656ccc6712ab	2026-08-27 13:52:52.626263+00	\N	\N	\N
d87a5a58-7ead-40ef-814f-2ac8307c64f9	4759c448-dd61-400c-b21f-f0864cf40f9a	18721009-def0-4c4b-9ba1-a87efd48a3be	2026-08-27 13:52:52.630097+00	\N	\N	\N
168d97bf-8000-46d0-ae7a-08695628930e	36fd2e0f-5bcb-4022-aa08-f1cdaed0ecbe	1ba28d18-0a35-4a13-a7e7-f2caf8bbdfc8	2026-08-27 13:52:52.634546+00	\N	\N	\N
1d22ba9a-03d2-433a-8e2f-11a600147160	9c8b043d-a01c-4089-af23-294d15b8b655	8b51f6ca-9bc1-4732-bd3b-605a40329413	2026-08-27 13:52:52.639193+00	\N	\N	\N
8df60630-6f8b-4016-b677-0f4b01e624a1	b651b723-1d84-4f6b-b59e-62ded0251782	93d4e9a9-412a-40ab-b33c-833ae19f8719	2026-08-27 13:52:52.644081+00	\N	\N	\N
03a5ab4b-3576-4add-926d-ba26e61b656c	d72ad9ae-253e-4a5f-9fb0-5478cf511525	d57058af-2bf3-4a40-8710-3d7773ee0dbb	2026-08-27 13:52:52.648306+00	\N	\N	\N
2a5d2e03-49e3-4e88-963b-9236d3b134fb	ac1e61ff-8759-467b-b90f-07705b747949	c8f99c13-bc7d-4ca8-ac63-823af817eb21	2026-08-27 13:52:52.658623+00	\N	\N	\N
a8889aa7-111a-4f60-a1f1-b8af4e20ab57	5027181d-b736-4199-ae12-b407eea5631d	471c10b4-5dc7-4677-8b77-70a5112bdfe0	2026-08-27 13:52:52.663583+00	\N	\N	\N
f1e10adc-a011-4fda-a20f-da1ac2095541	7c165005-a800-432f-b1fe-0b613e7ae8d6	682dac50-adf9-486d-b992-7ee3f407634d	2026-08-27 13:52:52.666408+00	\N	\N	\N
997e8ad3-d28e-4286-b564-b0a719110d40	304ad137-6619-4dde-8e30-d2533d7ad1c7	695e0165-536f-49fd-9117-f199e4ef2e7b	2026-08-27 13:52:52.669822+00	\N	\N	\N
d1f13174-7588-4822-bad8-a13fe2510ae6	12f03f63-55d3-4301-a7f9-e522fee49feb	41fb5167-73d4-447c-bc95-2e0be34de0fa	2026-08-27 13:52:52.672708+00	\N	\N	\N
433855e6-640d-4d66-804e-b070896659ca	000945e1-51d6-45d4-bdf2-91a65126cfc9	066f2f9d-8414-4529-a84d-228ed49ae5df	2026-08-27 13:52:52.676063+00	\N	\N	\N
420c6c89-5daa-44f4-8748-d01cc4832f95	48060b50-0791-4e4e-ac10-b67e84b373ad	be017b54-2b49-4018-a400-ed45eb464142	2026-08-27 13:52:52.679224+00	\N	\N	\N
d81a0193-8065-4ad2-b444-a5aee7979d49	aac653bf-37ba-4cc1-b91e-220b8be7c496	31d1b026-51b4-4afa-ac36-69f79816a3b4	2026-08-27 13:52:52.683791+00	\N	\N	\N
b707ab37-a30d-40d7-878e-6e703d613d21	743c37c3-f9a6-4596-9bc8-de61ed772a9b	bc15c5ff-b792-4fcd-b23f-2ec2fdb48550	2026-08-27 13:52:52.686273+00	\N	\N	\N
4fe2483a-2063-48a1-828f-f5d5e99886a8	fa8430fb-b1ad-4515-9cc4-f9ebeaec8581	6d1aa29a-fdc3-4909-8e22-a8ecf0a56d19	2026-08-27 13:52:52.688808+00	\N	\N	\N
c314b6cc-3e61-4259-86c4-e72c9b8cc649	ce5c22dd-4ad4-406e-8cba-e2367519bdd6	872d4e47-adaf-4a7e-8b01-d9f9f8cc24a0	2026-08-27 13:52:52.691729+00	\N	\N	\N
233cec65-d209-454f-a85b-0ea34c33787b	f2cb2c15-2ec4-46e7-af22-329e368bb83b	c42ceec7-30f4-4cdd-8ce2-3ca31552c51a	2026-08-27 13:52:52.696054+00	\N	\N	\N
8824f004-7e36-478b-b8f7-59cd792b0f74	093bf052-2c9e-4c20-bf8e-6c218eca2a55	a305f92e-560d-41ea-9ac9-bc539af58712	2026-08-27 13:52:52.700312+00	\N	\N	\N
f4309923-9497-4243-ad5f-b0d5d882f8a2	\N	ec79cce6-4b27-4296-a744-4f022ab849df	2026-08-27 13:52:52.707264+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
6c90b77c-3f6c-439d-a2aa-1fe415130452	\N	f302655e-e370-422f-ba84-b1db64d42526	2026-08-27 13:52:52.710126+00	\N	\N	🏢 Pole Comptabilite Syndic - Membres
5a7b9485-6b16-4f63-a1a7-8364323de4e5	\N	b781387c-cf77-422f-aa8f-ec925a1543fa	2026-08-27 13:52:52.712879+00	\N	\N	🏢 Pole Sinistre - Membres
55207e73-64ed-4bb2-9c87-9d62af792e0f	f3b2032f-00f9-43fb-951f-4e9596848dc3	a7263e14-acbb-403a-a4c0-e33ff1fbb106	2026-08-27 13:52:52.718583+00	\N	\N	\N
53825270-260a-4f37-8e3c-4121b1a7f498	\N	9a7eb301-33b1-4c9e-b9fe-8a0922374736	2026-08-27 13:52:52.723491+00	\N	\N	🏢 Pole Syndic - Membres
e0aec585-bf9e-49c4-bd4e-61d747af574a	8f444a89-57da-4701-a844-496667163785	629b46cf-8b32-4264-b401-3e3d0da3f329	2026-08-27 13:52:52.727631+00	\N	\N	\N
45e93127-03d9-4565-942b-17666b7b77aa	7c165005-a800-432f-b1fe-0b613e7ae8d6	2c2f6031-9c95-4126-a501-8442a836b0e6	2026-08-27 13:52:52.731186+00	\N	\N	\N
8f13926a-f800-4f85-b172-69ac3e88ba76	d332732c-b65e-4733-9d07-bacff5667d34	b9824ff6-4b2e-4b12-8314-0915868a5ac2	2026-08-27 13:52:52.735923+00	\N	\N	\N
25bbfc81-a812-44c5-a922-807acc58ce07	624b8afa-d057-4c18-b7f1-e165bb81895e	accabaed-6f4d-4813-a22f-dd213c46682d	2026-08-27 13:52:52.739916+00	\N	\N	\N
bb5ecee3-a088-47a5-af8d-59d2c1b79349	f7acd69e-21af-4923-8371-a465df0e0006	173d8164-6448-4540-b14d-e09d87a2b15b	2026-08-27 13:52:52.746403+00	\N	\N	\N
7ad1f24f-4538-4536-91b3-f83f8131d5e2	62d06322-8057-4756-9750-fb595d22f5e8	8cbdeae8-2fa6-4693-b309-76551e05860d	2026-08-27 13:52:52.750637+00	\N	\N	\N
e8fdae5c-876e-4104-aa85-9704f10adb35	\N	24b7ad5d-fe51-443f-875f-5cfb56a93dec	2026-08-27 13:52:52.75398+00	\N	\N	🏢 Pole Gestion - Membres
11bd4f55-9030-4954-b4dc-3d90cdcce564	0d15c9cd-6825-4027-9637-c4808db041ef	9c1528e8-762a-4660-8b64-e38a10b5ecc0	2026-08-27 13:52:52.758113+00	\N	\N	\N
0e141ec3-dc72-4ded-8c49-bbf1e31503c5	0b0b9e6e-7a8f-48a5-a80b-0aac21d13158	b1e7c366-4de4-4389-9db0-a1eb6b1207ac	2026-08-27 13:52:52.761786+00	\N	\N	\N
3bf1c17d-5133-49d8-9600-ca5896c1a54a	a2f07f8e-0b1e-4ea9-aa51-30d9b0f0269b	031aab57-9222-48f0-963e-c79e0a3a7bd3	2026-08-27 13:52:52.764832+00	\N	\N	\N
e0f657ab-e1de-476a-b638-98ec34adbe33	\N	864a1241-ff49-4453-a6da-712386e1f80b	2026-08-27 13:52:52.767457+00	\N	\N	🏢 Pole Gestion - Membres
4abc2061-58e5-42a8-92c8-dca9d1aa39a6	\N	771bc21e-4ba5-4f65-8233-7189e0fb0d99	2026-08-27 13:52:52.770342+00	\N	\N	🏢 Pole Transaction - Membres
b157ad04-4d88-4cb5-a4a1-ec8a8ba891c9	6bd4d90a-fb4e-4ded-ad05-62efba5bb299	4d900e14-5a7b-4618-90e3-affd49e66302	2026-08-27 13:52:52.773783+00	\N	\N	\N
7886f6e4-697f-4d46-9ed4-39a9faa07a2d	85cc63ff-7df5-4fe8-ae5b-96f55bd68811	58f2f11b-0ee0-4200-a8ab-c7d496275fac	2026-08-27 13:52:52.777365+00	\N	\N	\N
e4fa50f9-41ca-483d-8839-3a995805240b	7b830831-6b84-4f8c-b6b2-bed2e07c2502	1612d463-d72d-491c-a856-3a2e28fa35e1	2026-08-27 13:52:52.780636+00	\N	\N	\N
22bd1204-1f0f-4cef-9278-6c1b15f521ab	47d649ea-5c0a-40a0-8338-b3c7e0697f1d	4f8c310e-0313-4e22-abef-ded83114eb5a	2026-08-27 13:52:52.784544+00	\N	\N	\N
75c5e7b8-3ce1-4a34-b02e-c4adf3ddcf34	2072bfae-71ea-4931-b9f7-b35f96aec16c	bdff1f10-ef19-47fe-8598-c96400e06ff0	2026-08-27 13:52:52.792125+00	\N	\N	\N
533979c8-dcfa-4ec0-bcb7-a0ca64776852	093bf052-2c9e-4c20-bf8e-6c218eca2a55	2ee2e1e1-6694-4219-98d7-f5ba78dd1f7e	2026-08-27 13:52:52.798155+00	\N	\N	\N
613b8e52-7c46-4858-bff6-7f9f75f35e1e	093bf052-2c9e-4c20-bf8e-6c218eca2a55	6404fdcb-ec82-40c0-8f95-643d720a5c88	2026-08-27 13:52:52.802817+00	\N	\N	\N
7e1ceb71-2420-4993-ac7e-29cd90ca51bd	8a3cae01-f152-423d-9a56-31a4fbcda459	f051a158-9d6d-4670-8962-9c8b9d3942e5	2026-08-27 13:52:52.80746+00	\N	\N	\N
2642207c-aa39-45f4-a3c2-be82a4dc7078	8a3cae01-f152-423d-9a56-31a4fbcda459	d717829f-01e0-4116-8c8e-18e55ce0914e	2026-08-27 13:52:52.812434+00	\N	\N	\N
a77f4394-2ee0-4011-ba70-c50b3820fb56	\N	defc356d-bc00-4ba6-8af1-906353eaf601	2026-08-27 13:52:52.818158+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
99b8ee62-cadf-4320-872e-68d40dd6f503	ddd7b7c7-e9a5-4884-bca2-f911d16dc496	8500bf05-c1dd-4590-9ca6-cb051170aebd	2026-08-27 13:52:52.823039+00	\N	\N	\N
87315901-ded0-427e-b3b5-d85c416fdb76	\N	19cdc4ba-85d7-4d3d-b906-6d2303e5b8ff	2026-08-27 13:52:52.829947+00	\N	\N	🏢 Pole Neuf - Membres
f9efb94e-066d-4296-8000-08ec9caa7bde	9065235a-5dbe-42c0-9bbb-3557592c5e2a	642229c4-b688-4835-9653-d71fbe2a3f66	2026-08-27 13:52:52.835415+00	\N	\N	\N
78c6a51a-ec64-45be-a230-a0df9f1e1d66	ac55a2c1-d471-4e28-9e74-bd89845f2904	c6ae6f1f-32a1-4dab-bb3d-6062f2bb7a73	2026-08-27 13:52:52.840161+00	\N	\N	\N
e5e98380-804d-4aa1-8b94-c41d88e4ed59	62d06322-8057-4756-9750-fb595d22f5e8	72e3c162-7447-473e-a2d3-dacc1b9b4c8a	2026-08-27 13:52:52.844745+00	\N	\N	\N
762f6fce-6375-4fdf-912e-a9ec32edaafd	\N	e3fcb5fd-0078-4215-9a1f-cdfa5c799c28	2026-08-27 13:52:52.847754+00	\N	\N	🏢 Pole Syndic - Membres
a43da449-43b5-4afe-b5ac-701370645f0c	40b4e542-806e-491e-9218-e7eae5547492	0e27c974-5c41-410c-9b77-34f88ce5c26a	2026-08-27 13:52:52.851571+00	\N	\N	\N
65fe4e73-1cb3-4d06-8f60-1e6e83319500	3ee22ac9-0477-4511-86b9-0f2490ad3efd	e99d0525-8c32-45a7-b101-e3be2a611b11	2026-08-27 13:52:52.855878+00	\N	\N	\N
f212d764-2f88-4799-a1a8-25f9fc2e8307	dac6b804-7dd0-44aa-9eef-151b056591db	36bbaf39-67c3-44d6-9ef4-f2553ba94dda	2026-08-27 13:52:52.860089+00	\N	\N	\N
021c8b9f-a616-419d-bbdc-7722260bb8c4	f56a985e-06ae-44b7-a5dd-a3c87dae0dee	e1d10124-49bb-46b6-b225-4ffe7f761947	2026-08-27 13:52:52.863787+00	\N	\N	\N
683c07ae-8f2e-449d-a7cf-0b2fa58a1bb2	2072bfae-71ea-4931-b9f7-b35f96aec16c	08dcff25-6af8-4da2-8c15-c0178dcfe5da	2026-08-27 13:52:52.867621+00	\N	\N	\N
b5b8d5d4-e2c7-4240-92cc-d89fc1ae1645	27fd1784-c0c8-4669-bba2-19a68cba8a26	c886de43-f4b0-4f37-b61b-8c6e28a7ee83	2026-08-27 13:52:52.872075+00	\N	\N	\N
0ed85575-1c28-4132-a496-09f09622d7f0	0d15c9cd-6825-4027-9637-c4808db041ef	6e88752c-8a00-4118-94b9-e32955abf8ad	2026-08-27 13:52:52.876301+00	\N	\N	\N
01a86e47-0fb1-459d-ac03-c05542ea7d67	0d15c9cd-6825-4027-9637-c4808db041ef	f8395b0b-f039-4dd9-81fb-f4cd30bab28b	2026-08-27 13:52:52.880141+00	\N	\N	\N
66079cbc-2750-4b1f-b78a-b490d5b4a4db	3df0dec0-7d7b-42e1-be5b-3befb44ae276	75fad8a4-7f91-4511-9e7a-75f4a09fc416	2026-08-27 13:52:52.883877+00	\N	\N	\N
95c2eb7a-70cf-4cf3-a506-a74d98537fc9	1758e62e-2ca5-4996-862c-7e4a016121ca	a08f1082-b427-4239-8429-1296c20f6625	2026-08-27 13:52:52.888547+00	\N	\N	\N
910b8cda-3ed6-41dc-a95f-95d0af66306e	4efac293-84a5-40b1-b82e-044ef50720ee	f65daf67-7b73-40c0-bfc8-128610e4f502	2026-08-27 13:52:52.945121+00	\N	\N	\N
2bc2f136-deaa-423c-8229-f64cf6a53285	\N	99e9a205-de2d-455f-b3d0-865b4a8f35e2	2026-08-27 13:52:52.948252+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
03e47149-0c13-4556-a9bd-4c5458c17881	101b53e9-b554-478a-9e95-3a2c2d44c9f1	90e35969-063f-4166-8560-9bd240c6cbf1	2026-08-27 13:52:52.952449+00	\N	\N	\N
a2fd46cd-a7a5-4860-ac49-b0c9547005ed	\N	6c1c69c4-3202-4fa2-8a1c-68fae009177b	2026-08-27 13:52:52.956022+00	\N	\N	🏢 Service RH - Membres
4ed39127-7a8a-4339-8389-31ef49bbf7ff	\N	b90de252-7cfe-440c-9e41-f478d848c2e8	2026-08-27 13:52:52.960329+00	\N	\N	🏢 Pole Service Relation clients - Membres
ded5c111-0938-406d-8f44-b5366fb100f0	57ad174b-600a-4156-ad48-e8ea11a03e15	02977d1f-66d1-475c-bcbb-6cc1f0c9b602	2026-08-27 13:52:52.964375+00	\N	\N	\N
11ecf40c-1b88-4542-9a54-2149c5e4f3f8	5027181d-b736-4199-ae12-b407eea5631d	e8c20401-ce1b-4737-bc64-af0f7e134e80	2026-08-27 13:52:52.96871+00	\N	\N	\N
e5b8083f-81e1-42db-8c7d-a1f119763e5c	1bc9c89b-a771-442a-8921-26e105e8fb23	e3d6078f-e93b-433d-844a-c356edcbbdd4	2026-08-27 13:52:52.972866+00	\N	\N	\N
f46b5591-1a39-496d-acb2-ea2fce8fc9b3	55b21729-5058-4fad-b7c1-c455a5485274	81dda35c-f120-4ce5-8e53-296f7355e7d4	2026-08-27 13:52:52.977003+00	\N	\N	\N
16cac682-bf57-4fb7-8202-755a3ee9d3dc	\N	a4d14608-e97b-4090-a9d9-e548a5351d41	2026-08-27 13:52:52.986787+00	\N	\N	🏢 Pole Sinistre - Membres
4f88a50a-be4e-4963-90a3-9a48eb825d6a	55b21729-5058-4fad-b7c1-c455a5485274	733dc0eb-fc54-4e8a-a9b4-595207a519f0	2026-08-27 13:52:52.991089+00	\N	\N	\N
632e60e7-d172-4990-915b-ebc638631c02	8a3cae01-f152-423d-9a56-31a4fbcda459	e33907c6-353f-44a1-8e51-d625ae566d12	2026-08-27 13:52:52.999249+00	\N	\N	\N
5b620f88-9277-4a38-876f-b3f44e7f08a3	55b21729-5058-4fad-b7c1-c455a5485274	8bde2d36-3cd5-41ae-85cc-4cf4b9e30df9	2026-08-27 13:52:53.003068+00	\N	\N	\N
fb7e0df0-445d-406c-b501-c9953702b90e	\N	876c4e22-5076-4b3c-8728-d185631144bd	2026-08-27 13:52:53.006335+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
460e77bb-25be-4d98-8dba-61f3ef39b1c0	a5a6872a-ebe1-4401-9e04-036f29764adf	9d195e8d-5a98-48f8-ac22-326542d7c4fe	2026-08-27 13:52:53.009325+00	\N	\N	\N
a35de48e-2f87-455b-99d4-7568d05000cc	56cec5e0-aee5-4f42-b08c-02c0f743453a	e4ca18f9-33f3-4ce6-9b78-7254310f953e	2026-08-27 13:52:53.012453+00	\N	\N	\N
8f5cd2a3-bf87-4f1c-ba37-60f3cecde176	cdbd094b-2737-408d-8a1b-84d04221564e	e973db32-69d4-42ff-9073-058f8c1f5780	2026-08-27 13:52:53.015805+00	\N	\N	\N
f3ba2cc6-83ab-4c19-a763-d0dc091911a0	\N	69abe379-1ce3-4125-92e4-c1fed50f6310	2026-08-27 13:52:53.020166+00	\N	\N	🏢 Pole Développement CGP - Membres
f66f9485-4b62-4820-920b-59561835e9b9	743c37c3-f9a6-4596-9bc8-de61ed772a9b	efbea799-1918-4093-a216-6ed31808d540	2026-08-27 13:52:53.023425+00	\N	\N	\N
db71cfb4-b7cb-4d5f-9ce2-a4a37cd213ca	a0c0e609-3488-482f-b518-cf726119cd3d	8ed20b7f-ef2d-4251-b578-373516669447	2026-08-27 13:52:53.027122+00	\N	\N	\N
40b1301c-3b0e-4008-a160-88ecd595407c	e143e82d-f0a6-437e-9151-76f6ca279a06	64b6e03b-a62a-4b30-a5d8-e6f7ff0e2f90	2026-08-27 13:52:53.030304+00	\N	\N	\N
a0911eba-a768-48d9-b53b-966b788ac4b3	e8ee2211-2079-4c3e-8eec-6c67f4ef71ad	7cff8e86-09a3-4ec8-af7d-5a445176a411	2026-08-27 13:52:53.033485+00	\N	\N	\N
ecaae00a-ed87-441d-9261-eefe4fd8e8a7	114f8ba5-5564-42c4-9034-2e01a493c713	024e764a-98ef-4b75-ab80-14cc62ce24a3	2026-08-27 13:52:53.04151+00	\N	\N	\N
f6cb2359-1868-463b-9cb6-341d6d839c60	a45742a5-894a-4a32-83b8-0b3cf7cfb970	016f2c5b-3c84-4f49-8306-a350d8dccde4	2026-08-27 13:52:53.044612+00	\N	\N	\N
a24bf602-fbdc-40c5-84cb-a386d4246a5f	c7e3300a-fe49-4b28-aafe-c2402982831b	da76d859-afc0-4d91-8d64-49b01b2e0c9b	2026-08-27 13:52:53.048187+00	\N	\N	\N
e87fd4d6-67de-4f35-9052-47cfedfa77f9	2072bfae-71ea-4931-b9f7-b35f96aec16c	f7438fa6-eee5-4323-8bad-cde143ffa645	2026-08-27 13:52:53.052147+00	\N	\N	\N
f2d06a1f-4002-4e89-b8d3-e37f55a54547	af477549-4032-4bc5-a340-ef63921d1a65	48271fa9-1065-4a7d-a26d-0db849056378	2026-08-27 13:52:53.056145+00	\N	\N	\N
a9174aea-81b6-4d49-b685-1d402bc32618	aac653bf-37ba-4cc1-b91e-220b8be7c496	fb9ec0ae-4be5-496d-9b21-0093ccb4d470	2026-08-27 13:52:53.059605+00	\N	\N	\N
ca440e4d-ee34-48bc-8e60-c42a532c0023	690d99b6-c9bd-4fa6-bb8e-5c28874e0762	eea84635-5af1-4458-94ba-4dfae3d1e68a	2026-08-27 13:52:53.063185+00	\N	\N	\N
05fef79f-90d8-426c-af51-31c01246ae36	690d99b6-c9bd-4fa6-bb8e-5c28874e0762	42783e57-9826-4a11-9769-b5e408a8070f	2026-08-27 13:52:53.066509+00	\N	\N	\N
9c1adf76-c6ee-4d83-bd28-efcb180e720e	624b8afa-d057-4c18-b7f1-e165bb81895e	4ce7cd82-4ac7-486d-94ef-4f08064d313d	2026-08-27 13:52:53.069928+00	\N	\N	\N
f5cd6f77-15db-4e97-828a-bd483feeb27f	6e7662ae-3bbe-4f61-8b32-dad4b1417fce	e6c5d23c-ee14-429d-a78b-6802bfbe5ab3	2026-08-27 13:52:53.073139+00	\N	\N	\N
449e9d63-c369-4825-9d4f-a7d9ba324d35	2fb8e5c5-afa8-4103-b324-f045e2fc0ed0	d67aa5b5-4dcf-4ef6-9c65-53c8d04b3116	2026-08-27 13:52:53.078183+00	\N	\N	\N
ea2ab957-697d-4249-bd87-d9dafd020cdc	\N	5a0aa1c6-b337-43eb-9254-06dbfdca657a	2026-08-27 13:52:53.081418+00	\N	\N	🏢 Pole Service Relation clients - Membres
4d25cb4a-e131-4386-ac7e-9d6a0c0a8e03	df94363a-8e80-45ce-a78a-e91ea33fb6ee	fb798749-172a-4c6a-b6df-85ee0b4cea06	2026-08-27 13:52:53.084469+00	\N	\N	\N
9c93c0e9-cc32-4d82-8544-8c9bb90d0404	12b792db-ddc9-4cbe-b2b7-40a050a6aab2	6d611e9c-c401-403a-bbe2-2be06a540b7f	2026-08-27 13:52:53.08719+00	\N	\N	\N
cb5cc91b-37ed-4166-a9ed-d50445a15dfe	79d59a7e-d32c-4723-a9e3-80a370d4ed60	d1c488f3-e6c6-4f40-a4fd-ebc4e5ac6f41	2026-08-27 13:52:53.091351+00	\N	\N	\N
71557b5a-312c-46d5-8c2e-cc2ba9ca55fb	4b1abe45-669a-4c9f-bb9e-eecbda56240d	9e43363b-f489-4127-aad4-25e046aa5de8	2026-08-27 13:52:53.095565+00	\N	\N	\N
37ca7567-2707-46fc-bf93-629affc23f12	114f8ba5-5564-42c4-9034-2e01a493c713	a5dd26f2-e4ef-4972-b956-769b2b46daab	2026-08-27 13:52:53.100002+00	\N	\N	\N
f5430c45-0cba-4986-9764-735bcdd418b0	7c678469-22f7-465e-905e-9696f3fd9754	c431e21e-095b-4bd6-aa4f-53db8c3b61cd	2026-08-27 13:52:53.105152+00	\N	\N	\N
64033bf2-ffdf-4339-87f8-3b5516df6851	6e5256c5-869a-42a3-b1bd-f316c085dec9	eaf30617-6c9a-4668-a285-3ad142b8d548	2026-08-27 13:52:53.108717+00	\N	\N	\N
5dc6241e-614c-44e4-ac65-4aa05fc60df1	b425a749-eddf-4991-951b-045fae50c701	729778ef-8cd4-4964-b600-e01222de9127	2026-08-27 13:52:53.112526+00	\N	\N	\N
a78299fa-a98a-48f8-8e04-35ed4a0c04cf	62d06322-8057-4756-9750-fb595d22f5e8	43fac690-c7a5-4c01-92bc-3831176f6bce	2026-08-27 13:52:53.116118+00	\N	\N	\N
0e9b0541-a54f-485d-b9af-e474f12e0077	743c37c3-f9a6-4596-9bc8-de61ed772a9b	352d0a2b-f2ef-48c9-a44f-89fb354e9612	2026-08-27 13:52:53.120373+00	\N	\N	\N
01747119-a503-4de2-938c-a3e5289d883a	\N	90fe5efa-ceb6-40f6-ac55-1c247f0e9bec	2026-08-27 13:52:53.123573+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
656bc359-5051-45fc-85be-5e2787168eb7	af477549-4032-4bc5-a340-ef63921d1a65	991c7b13-5322-44ca-a5cf-f7abd7aaa536	2026-08-27 13:52:53.128559+00	\N	\N	\N
81329612-4acc-435c-b0e3-edeea18c1dcc	b4c59353-93b4-4b09-88b8-1c9b010a79be	f5cc819a-800a-44a3-9b42-472d13eefe0f	2026-08-27 13:52:53.132036+00	\N	\N	\N
dd4d8c3f-e7de-421a-a55b-1f2a3dcf119e	\N	f12dfa98-eb40-41b5-bde7-f2f51a771c4b	2026-08-27 13:52:53.135397+00	\N	\N	🏢 Pole Gestion - Membres
16b92bc2-663e-47c3-ae08-842b11c2fed1	f5509f28-5d95-4659-9d72-e61ac963e824	9960b2a2-b047-4f7a-a690-0a2476b4707d	2026-08-27 13:52:53.138949+00	\N	\N	\N
8a0b2808-1a9f-4dd9-8338-2b95d24dcf1f	\N	4fd7a203-1e49-4fbd-87d3-dc442e96dd69	2026-08-27 13:52:53.142521+00	\N	\N	🏢 Pole Syndic - Membres
718c1992-1f03-4e96-9b81-b2649b0206a6	36fd2e0f-5bcb-4022-aa08-f1cdaed0ecbe	176a1449-68c3-4255-86d5-a8991e1ad44a	2026-08-27 13:52:53.145921+00	\N	\N	\N
de72acff-6f71-4e62-9db1-fc600886a74f	d2db7239-1ca7-49b3-bc43-86c0cb25a825	fb85c4cd-6e19-439f-b1be-92ec091840ee	2026-08-27 13:52:53.149218+00	\N	\N	\N
11e12291-903b-45c6-a29c-c1d0e229c461	1d64afa0-46c7-4add-9402-f81fe8c9db9b	6905a37f-bec4-45bc-9740-9bfaaeba534d	2026-08-27 13:52:53.152361+00	\N	\N	\N
0c21260f-92cc-4e5a-b7f9-d18689669e77	\N	4b7e9678-87fa-41d6-a1e4-64ff465408e8	2026-08-27 13:52:53.155007+00	\N	\N	🏢 Pole Comptabilite Syndic - Membres
e6f04a4e-0ad3-4c87-b578-73d8273c5c51	bafcbdde-b731-4ed8-a334-2202d4cf4d98	ec38bcd7-5083-4dde-8944-d2d24e54a60f	2026-08-27 13:52:53.158039+00	\N	\N	\N
bee8da22-8d21-4e2f-83eb-d19bc5d81ff7	7a0c6e20-cc0e-4d27-9e4e-46ef784836fe	2a2a0138-8713-4135-ab74-04399ffc186f	2026-08-27 13:52:53.16131+00	\N	\N	\N
a5da45eb-b109-43b4-9a4f-d81fdcc48633	125ed49d-4a83-46f1-a3f4-abd1380b639f	fce847d5-14be-4fc0-af9f-37a5428ec5dd	2026-08-27 13:52:53.164534+00	\N	\N	\N
686e119e-b3d3-4916-8d1e-e6dcaa0e68dc	41bc86f4-b749-436e-b2d4-6acc57903fcd	0bd3e746-0045-42fc-bc22-3fba1aa56ee7	2026-08-27 13:52:53.170167+00	\N	\N	\N
1cb1ef00-1444-415a-90ed-70b67a6b877d	\N	544d0585-8b70-4507-878e-775838c320c8	2026-08-27 13:52:53.177737+00	\N	\N	🏢 Pole Sinistre - Membres
f632bf4c-64c4-48cf-a9d2-c969dd2ac6cc	ca071ca7-de86-41a1-bdd8-b1dbf0860682	e076278e-0392-4c0e-95aa-9b3d8207ec44	2026-08-27 13:52:53.182374+00	\N	\N	\N
a3b5a54c-5423-421b-a254-c4c01c8a9d48	38b36da7-b0d1-4662-be52-b6ee57aca061	88134a96-263c-4858-a1e0-d8ebb6e1f578	2026-08-27 13:52:53.187049+00	\N	\N	\N
a7bcae6d-134c-4a1c-b3c3-6178d107c42a	b5066669-f502-40ba-a6c3-815ed0c04b1e	e3fac7b5-b383-4b1c-87f9-e3eff35361c1	2026-08-27 13:52:53.190139+00	\N	\N	\N
72eab773-e4a7-495b-a7d1-466e85388ea9	38b36da7-b0d1-4662-be52-b6ee57aca061	32fb8a8b-a93d-4732-98a3-07cb1f247f0c	2026-08-27 13:52:53.195565+00	\N	\N	\N
d8e0d815-da87-4b37-948d-2b3b18386250	1b558fb2-b0dc-409d-9c82-bcebfa448a08	214845ed-0d1d-42b5-8156-68065149a68a	2026-08-27 13:52:53.198379+00	\N	\N	\N
d626aa15-8521-4807-96d5-4a42ec2496fb	c390c330-806a-4eb9-a910-1c5887fed2cc	515dbf3e-ddbd-4108-94e9-6bc859d5142a	2026-08-27 13:52:53.203883+00	\N	\N	\N
d47c487e-47dd-4799-8259-ece980c6b217	c390c330-806a-4eb9-a910-1c5887fed2cc	35cd1782-5f72-494c-9911-3a856ffc77d9	2026-08-27 13:52:53.208048+00	\N	\N	\N
a71abe1a-338b-474b-b03e-0ab7ec152d8f	9940abdc-e864-4c64-85bf-83ec644b3809	b5666646-b63b-4620-956f-d9bf11f83dc6	2026-08-27 13:52:53.212254+00	\N	\N	\N
4b44d4c5-baa2-41d5-9ca9-a057ce514903	f97bf5d9-114d-466a-b855-d17caee3e260	4e0c0323-e37a-4673-95f3-a9357b5f32ef	2026-08-27 13:52:53.21584+00	\N	\N	\N
55d3d6ab-fbfd-4807-99fb-1715458169fe	93022cf0-2102-454b-bece-f0f0f7fbb888	564b0676-a350-403f-9a37-b5a07f75aa37	2026-08-27 13:52:53.219012+00	\N	\N	\N
28e5e3cc-036c-4d2c-a71f-13718f326179	9c8b043d-a01c-4089-af23-294d15b8b655	e786df17-e6cf-4a51-a13f-fe77ff1a7bc3	2026-08-27 13:52:53.222527+00	\N	\N	\N
eabee452-726f-46f0-80c5-1cb21c747cff	\N	ad5d7b93-0ec5-4d63-af1b-5555229d088a	2026-08-27 13:52:53.225975+00	\N	\N	🏢 Pole Gestion - Membres
488fa497-4d85-4949-b20b-9ecd51d26058	d2db7239-1ca7-49b3-bc43-86c0cb25a825	53703171-b862-491d-9bd5-455afed32205	2026-08-27 13:52:53.229042+00	\N	\N	\N
52eb86d8-1499-45b8-b47a-5b223f056894	e143e82d-f0a6-437e-9151-76f6ca279a06	cf0ca725-eb8f-480e-ba1a-16f10f7b02bc	2026-08-27 13:52:53.232739+00	\N	\N	\N
ce10b8e5-cfa5-4a4d-b1a1-60477bb8b7f6	\N	e123b65c-bedd-46b2-9352-8b298666f279	2026-08-27 13:52:53.235896+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
b115a055-5328-43c8-9d89-8dda6d3971b7	f9e5949c-1359-4820-928e-2bb57723ccd5	d6c6d691-c28f-4722-8565-542ede62cc35	2026-08-27 13:52:53.239257+00	\N	\N	\N
ac202e94-c820-467d-8214-5848e7f03f5b	d285fb75-5788-4701-ace3-14e15a052e46	fe39ca45-df5b-437e-bd61-415b5ba0ca86	2026-08-27 13:52:53.243102+00	\N	\N	\N
1a4f9ea1-02ab-4327-a46c-ad885f4804d3	32fda97f-4cf9-485a-82be-e93ef5070597	b88f6afc-a910-465f-882d-d41a1142e598	2026-08-27 13:52:53.247525+00	\N	\N	\N
60800d84-ae91-4d5c-b624-772e3504d723	38d9a85c-9a79-470f-8cd7-014914acf3c7	31c4888c-ccef-4d2c-8ea0-9f2bfd51717e	2026-08-27 13:52:53.251183+00	\N	\N	\N
057effa5-bb8c-40c9-9600-0429be86c9fe	8bc894ba-63e8-4902-9cb2-96eb0ca1b713	a3a20549-42e9-4aa2-bc84-57f1359d0782	2026-08-27 13:52:53.254607+00	\N	\N	\N
30d319f7-e7de-48d4-89e9-f48157e9bb16	c79f6259-fd29-43d8-9711-259796f7bcfc	847e8eff-7afb-4722-b6f0-5f60d5941b39	2026-08-27 13:52:53.258473+00	\N	\N	\N
a1877cab-2edc-4bee-9229-bcb1b1d04b3f	093bf052-2c9e-4c20-bf8e-6c218eca2a55	04e478f8-c944-4cc9-903d-e56600bc69af	2026-08-27 13:52:53.262201+00	\N	\N	\N
84c93efb-06e1-4666-8db5-e1ba5d7b1e1d	2b67753a-e872-408d-a2a6-b1e970334a2b	4c0c8543-bae8-4851-929e-49bcc6b2c748	2026-08-27 13:52:53.265855+00	\N	\N	\N
d3e88fc0-84bc-4752-876d-28173315da88	8bc894ba-63e8-4902-9cb2-96eb0ca1b713	0f537940-a2a3-4fed-97b3-1fb219e92bff	2026-08-27 13:52:53.269135+00	\N	\N	\N
f5fdd0f3-b3aa-4dc2-ada4-b3464d9326dd	ac1e61ff-8759-467b-b90f-07705b747949	7b0fddbf-613b-47ab-83ee-30f1163e40bf	2026-08-27 13:52:53.274047+00	\N	\N	\N
b3526229-c8e4-4250-9d4d-a3e2f0ff4ecf	b879539a-de37-4fc7-9151-0c5566faad30	c6d65b19-16f6-4040-9c07-be8989f5c88b	2026-08-27 13:52:53.331431+00	\N	\N	\N
8d6ec8ac-b457-4bdd-bff4-4dfb1e913508	\N	e7457b2a-6fd9-4a85-9f40-c6221fe390f2	2026-08-27 13:52:53.335112+00	\N	\N	🏢 Pole Développement CGP - Membres
f3f61e6c-f505-48c9-ae61-bb9c954ad1d9	\N	f6774f67-fa04-4448-9ecd-3c981e85e45b	2026-08-27 13:52:53.33912+00	\N	\N	🏢 Pole Gestion - Membres
af056b32-d673-49a6-83f0-5dd9f5af6af5	df94363a-8e80-45ce-a78a-e91ea33fb6ee	70130e3a-7450-4d47-a2fd-76cdd89f75a2	2026-08-27 13:52:53.342947+00	\N	\N	\N
ef541319-ac33-486e-9e49-fb5ac967ca1e	55b21729-5058-4fad-b7c1-c455a5485274	3c15d1f1-55b6-45aa-862d-bc959789b082	2026-08-27 13:52:53.346833+00	\N	\N	\N
e193b957-9f80-4e1f-815e-ca1dffc6ecda	\N	cff76dce-addf-43de-9779-8268897f1c07	2026-08-27 13:52:53.350665+00	\N	\N	🏢 Pole Phoning Location - Membres
dc810170-7e36-49c6-bbac-89c7acc2b6b0	\N	32fe786e-2edd-4a38-9764-1232e0fdb0d3	2026-08-27 13:52:53.353124+00	\N	\N	🏢 Pole Technique Location - Membres
889bf190-989d-4a2e-9909-6e26b11513df	8a3cae01-f152-423d-9a56-31a4fbcda459	c218b437-835c-4519-bf7a-66755d92458a	2026-08-27 13:52:53.356423+00	\N	\N	\N
871d4e94-6168-425d-a0ad-3084b8d13dcf	fb9500b3-29fa-4dbb-b740-f7b413e25399	b0abd3e7-068c-430b-8e56-7e90f20c3999	2026-08-27 13:52:53.360529+00	\N	\N	\N
e17b2713-8cef-49f9-879a-fa6369738270	0dce424d-c1a8-4fe4-8ec9-3ff08e35a631	2f1622c1-fe12-4b77-84b7-43ff33a2ecc6	2026-08-27 13:52:53.365774+00	\N	\N	\N
c028cdd7-28f7-44f6-afac-ec49d58ee52c	ce5c22dd-4ad4-406e-8cba-e2367519bdd6	41fd22c5-8471-4227-b245-28ce4afad6e0	2026-08-27 13:52:53.369314+00	\N	\N	\N
e2f64387-70b8-4843-9527-1628349e19ed	ac93458f-7a43-45a1-b163-67f5769e55f8	fbdafd89-9925-4b3b-9082-27783b602f2b	2026-08-27 13:52:53.37278+00	\N	\N	\N
1f675354-a28a-41f2-8953-da93c7ae8345	835e058d-b2fe-4387-8c6a-2434f5a40065	7ea8daa5-42b8-45b2-8c79-ad045833ef48	2026-08-27 13:52:53.376346+00	\N	\N	\N
5f2fc2d6-82e6-40ec-9ecb-4414ac56160c	304ad137-6619-4dde-8e30-d2533d7ad1c7	a7d127fd-99f6-4bac-94e1-c5b493654d09	2026-08-27 13:52:53.37978+00	\N	\N	\N
8ada35f0-6a50-4e64-91f3-fc03e5760059	af21baf0-247d-486c-84ee-5f01f048deea	81ac6b1c-02da-40d7-9042-e725b6e92214	2026-08-27 13:52:53.383281+00	\N	\N	\N
a26a87e9-66cf-447c-a789-43fa30d10bdc	\N	8b4c9d48-660b-4928-bbb1-edd9efcc22a6	2026-08-27 13:52:53.386076+00	\N	\N	🏢 Pole Gestion - Membres
ab6d6152-a6a8-4492-ab46-ec836949b4f1	\N	2ae0fbb7-5c60-4a19-8e0d-ad3452a0db37	2026-08-27 13:52:53.388832+00	\N	\N	🏢 Pole Gestion - Membres
fe21d348-79e9-416a-a8e2-9ee99a576c0d	62d06322-8057-4756-9750-fb595d22f5e8	b4ea54f5-36b2-4db7-aea7-1a625eb07ef5	2026-08-27 13:52:53.394163+00	\N	\N	\N
2cb4e2c4-1ba7-4111-96f3-4cd262fe9b85	a5a6872a-ebe1-4401-9e04-036f29764adf	89dc1624-cb93-4888-8087-0c7bd45927af	2026-08-27 13:52:53.39789+00	\N	\N	\N
0815b34e-6ffb-4ca8-b2b4-f60c9ba12d97	b6edb5ed-b618-4d73-91f2-baab882280c5	e7412f06-6f50-4de9-90a6-d95b84386b6a	2026-08-27 13:52:53.401322+00	\N	\N	\N
f7819a32-1cb3-4ad9-ab6f-80d15db1afc0	6a300cbe-f185-4dea-833c-3e73e3278d14	393fb8e0-890b-45b7-9285-a183668bab7e	2026-08-27 13:52:53.404907+00	\N	\N	\N
43f36a6a-05b9-4d56-a0ba-bdc391229442	690d99b6-c9bd-4fa6-bb8e-5c28874e0762	75e267be-e52f-45b8-9754-0b68b6fd2dc1	2026-08-27 13:52:53.408944+00	\N	\N	\N
fd4e8dda-79c9-4078-aa52-8ede960d2742	\N	11a2e325-f7aa-4c87-b995-cd09b0e27d39	2026-08-27 13:52:53.412558+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
10efe157-45dd-481f-8fe5-0c031a3574f1	60dd1daa-9636-4017-8182-74bc53fb122d	28c5e785-358d-4c30-9bf6-e7bb1e452f4b	2026-08-27 13:52:53.417056+00	\N	\N	\N
ff04945c-7046-46a7-8cbd-632bf945138e	\N	12170ac3-ec36-4e1e-9e6e-1d1a46d3ce97	2026-08-27 13:52:53.420926+00	\N	\N	🏢 Pole Technique Location - Membres
2019f0d8-5db6-4953-9af9-75a17a1de5c4	\N	fb98bffb-c309-43f3-a0c1-0d0d5c9ebe13	2026-08-27 13:52:53.424375+00	\N	\N	🏢 Pole Dossier Location - Membres
b4b5f908-26b2-48cb-a959-94a2f05ae8c4	533716fc-b5c3-4565-b5c9-2e520a37b4b8	c350bc72-2edb-43ef-b1fe-135e68e46e32	2026-08-27 13:52:53.429501+00	\N	\N	\N
23bb3831-a4d3-4676-b6a6-45d0933e7d16	12f03f63-55d3-4301-a7f9-e522fee49feb	ed3bff67-c19f-4411-8d57-b0719d735357	2026-08-27 13:52:53.433978+00	\N	\N	\N
e2b790cc-6805-44f7-9c80-c77ecaadebed	\N	bb858bb7-cfdf-49cd-9d6f-79c8284703ce	2026-08-27 13:52:53.440343+00	\N	\N	🏢 Pole Syndic - Membres
a93d23e5-472f-4e9c-b7d2-bdc81e7d4430	cdbd094b-2737-408d-8a1b-84d04221564e	dc4362fb-3265-47d3-b674-99d33d55828d	2026-08-27 13:52:53.445333+00	\N	\N	\N
14df285d-019f-4249-bc65-fed55fdcb71e	62d06322-8057-4756-9750-fb595d22f5e8	dd8b3900-e91e-434b-94dd-7f8c22bce4ce	2026-08-27 13:52:53.451244+00	\N	\N	\N
975ed5ba-751b-4e28-9754-cd3f304cd355	\N	56d6d1b6-56d4-4c09-950e-df30d76459af	2026-08-27 13:52:53.461312+00	\N	\N	🏢 Pole Commercial Location - Membres
dca78ee9-1a34-4098-8241-b5111f69a1fc	\N	b6b6ccef-8821-43be-ae88-1ec7dfd86684	2026-08-27 13:52:53.469859+00	\N	\N	🏢 Pole Technique Location - Membres
dde98637-e5a8-4895-b657-50714da561dc	\N	22de5b61-cc1c-4275-a52a-35947197ebbe	2026-08-27 13:52:53.475053+00	\N	\N	🏢 Pole Transaction - Membres
eaa428fd-0f70-4c67-8602-867a2e2dccef	06add6f1-e7a4-4a8c-a6a9-e1065db303c8	532e0b09-4fea-4bbf-afed-10807a9e978a	2026-08-27 13:52:53.480141+00	\N	\N	\N
f4504cc6-868e-45de-acb6-a58a39ca4f66	c1f31f22-5966-46e4-9487-6f6fdc24007a	1dd71e5e-c3bb-4978-98bd-082742310a77	2026-08-27 13:52:53.484463+00	\N	\N	\N
7c30362e-ec51-4d6d-b75e-21101b559eba	\N	705ac6d3-5214-406b-8532-6e43fc34a0a8	2026-08-27 13:52:53.49878+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
fde65df7-fa4f-4d50-af85-c0da681ce0c0	\N	1cb896ca-7481-44f1-b36e-e993f5787c7f	2026-08-27 13:52:53.50372+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
59852be4-1746-404c-9449-27770429b5cd	\N	9413e14d-2a03-428c-a08c-9c46eaffbdfc	2026-08-27 13:52:53.510684+00	\N	\N	🏢 Pole Développement CGP - Membres
7b1f6348-4035-439b-b2ac-d75a067fb313	101b53e9-b554-478a-9e95-3a2c2d44c9f1	0d6e90e7-f0a9-42ff-867a-7ea70f0f4883	2026-08-27 13:52:53.514409+00	\N	\N	\N
71333ce9-1ba3-4138-920b-88921238d63e	9065235a-5dbe-42c0-9bbb-3557592c5e2a	9fed90dd-f022-43d9-a772-d14126529c99	2026-08-27 13:52:53.517502+00	\N	\N	\N
acbfd040-3fc0-43bb-9985-851ddc030f4b	c7e3300a-fe49-4b28-aafe-c2402982831b	664ccc2b-cac1-40e7-b223-b9d07bf34444	2026-08-27 13:52:53.520935+00	\N	\N	\N
256a20b8-2ac7-4106-b63a-904e46650060	9799327d-781f-4c43-a284-08528389e366	4ce36569-3836-4395-bde1-5d2bddec54d8	2026-08-27 13:52:53.524891+00	\N	\N	\N
72511842-93f2-4b03-b0c4-f31b12af7e50	8b1a90a9-1974-48a0-abfd-06cc552fade5	f4ded520-d5a3-4e4e-9ee2-318886f380c0	2026-08-27 13:52:53.530142+00	\N	\N	\N
dd24fc8f-7503-4c66-8fc9-fb498b96ad94	7a0824ae-2296-44d5-8e32-669745de4c12	0aa0ca79-86e7-4240-b68d-6d0507674257	2026-08-27 13:52:53.53537+00	\N	\N	\N
b263f268-0ded-45d1-94b3-719c051c492d	5027181d-b736-4199-ae12-b407eea5631d	dc724d87-37dc-495e-b0fd-9c034ab88706	2026-08-27 13:52:53.540218+00	\N	\N	\N
fc490bb0-9493-407f-906e-7d2ff132c02a	e143e82d-f0a6-437e-9151-76f6ca279a06	66c7a4fa-69e0-4e7c-8d5e-5892c7b8fc0e	2026-08-27 13:52:53.551176+00	\N	\N	\N
afa27315-be4f-4b49-960b-0c3c50521c73	47d649ea-5c0a-40a0-8338-b3c7e0697f1d	3efa309d-8a46-4b64-9087-6b2d99ded2f0	2026-08-27 13:52:53.557897+00	\N	\N	\N
db1a2607-9e0f-4c7a-9a92-50d7cba99762	62d06322-8057-4756-9750-fb595d22f5e8	1d1d99c7-ec79-43dc-ac04-a841fb250066	2026-08-27 13:52:53.563534+00	\N	\N	\N
2836f31d-b87d-4858-ba8a-779720cb2fd0	d285fb75-5788-4701-ace3-14e15a052e46	c9d44038-4880-45c2-a9bb-ef3ac741474c	2026-08-27 13:52:53.569957+00	\N	\N	\N
98b4887a-d417-4cb5-b393-89fbc083d4b6	a45742a5-894a-4a32-83b8-0b3cf7cfb970	96240e29-2392-4c75-b0fb-0b17505853b4	2026-08-27 13:52:53.575794+00	\N	\N	\N
4fe75cc3-f85f-4545-8b40-7a5f87f10ea6	c390c330-806a-4eb9-a910-1c5887fed2cc	5f8b6668-b759-43be-8629-13951b8c5bea	2026-08-27 13:52:53.580822+00	\N	\N	\N
ad39aced-29b0-4135-a1ec-bef1b917fa50	4bd56618-dece-43fd-8fc9-fe98d930c922	97cb824a-5378-439f-a716-8083c3905482	2026-08-27 13:52:53.590376+00	\N	\N	\N
1ea5f64a-d4f4-4985-a485-7932f614435f	fed7ae60-6b89-49c2-b2eb-a472b1789ca0	f9f2b649-6a9c-47a2-8347-6137aacc4bbe	2026-08-27 13:52:53.59394+00	\N	\N	\N
8bfb3d68-37ac-400a-a508-bf3d8a2aa90c	0a7d08d8-d7a1-4510-8a6f-dd7c6ea30f99	5cb68c16-f2c4-4875-ad96-1db6b6f822ce	2026-08-27 13:52:53.597358+00	\N	\N	\N
37775716-bacc-47ca-8e78-439ad2cd29e1	9c8b043d-a01c-4089-af23-294d15b8b655	74245c03-c9dc-48c8-8f2f-7675bb70a333	2026-08-27 13:52:53.600886+00	\N	\N	\N
61e055be-e6ad-4853-98f7-ebbbc1eb0e7c	ac51fd68-5eaa-4066-b39e-88a5a6b3034d	75eb0f9a-33a2-42c5-a564-52d990d571c5	2026-08-27 13:52:53.605498+00	\N	\N	\N
5f436851-bf97-4eec-87b6-8e5788125bae	743c37c3-f9a6-4596-9bc8-de61ed772a9b	d2ab5b17-5a18-4118-a563-00becb735928	2026-08-27 13:52:53.611118+00	\N	\N	\N
a3db6d44-618b-4328-b129-be58618418e0	eebd0b93-b853-4497-81c3-417686db6d6b	c0c84983-cf6b-46d1-922d-7afe8d4799bc	2026-08-27 13:52:53.617094+00	\N	\N	\N
a25f553d-2207-4f85-a558-638757bca8fd	40b4e542-806e-491e-9218-e7eae5547492	c0d789de-f290-425e-b681-78b4079ea1f7	2026-08-27 13:52:53.627618+00	\N	\N	\N
ed85c387-72db-48d3-9804-229224db5a0f	3df0dec0-7d7b-42e1-be5b-3befb44ae276	245e41ef-21ea-4d7f-91d0-bb307c01ca6f	2026-08-27 13:52:53.63802+00	\N	\N	\N
cbbd10a2-1943-4233-ab96-5c5ecae2b6f3	a5a6872a-ebe1-4401-9e04-036f29764adf	c4ce777d-f7b9-4a31-bbf8-2f299e255f3d	2026-08-27 13:52:53.64629+00	\N	\N	\N
113c44a7-77dd-4d81-accd-441bce0d8634	6a300cbe-f185-4dea-833c-3e73e3278d14	dd7c2ba2-7e03-481c-aab1-afd7d4eb74af	2026-08-27 13:52:53.654513+00	\N	\N	\N
5f8b5e20-ec62-4809-9018-72705635a273	ac55a2c1-d471-4e28-9e74-bd89845f2904	5a110a5f-bfb1-4da8-bd28-f727d7f496ef	2026-08-27 13:52:53.661356+00	\N	\N	\N
01695a92-726e-44db-a84e-a2b5b7422f34	0d15c9cd-6825-4027-9637-c4808db041ef	8b23c6a0-a239-4b63-ac0d-710e4ccf5b00	2026-08-27 13:52:53.672279+00	\N	\N	\N
19107b6e-2932-42da-b86f-ba0fb718fae9	57ad174b-600a-4156-ad48-e8ea11a03e15	1c3dab3e-77b4-4ef6-96d5-ed7d94e0d266	2026-08-27 13:52:53.67985+00	\N	\N	\N
f554e91c-4477-4e94-bf12-6cc342378347	\N	cb1d49d8-bb1c-46e7-a4f9-632e54a9f4d8	2026-08-27 13:52:53.685689+00	\N	\N	🏢 Pole Gestion - Membres
e1797211-ee71-490c-b871-576bafbbecc0	f5509f28-5d95-4659-9d72-e61ac963e824	41928a28-2d13-49b8-845d-4f25f0b9149b	2026-08-27 13:52:53.693219+00	\N	\N	\N
b259cf76-b393-48fb-a885-fb3214a6f62d	e47b7fac-fc2a-473f-a536-f3e366d83887	59f0f77b-15e0-4642-a8ce-2cfd7e18e829	2026-08-27 13:52:53.701856+00	\N	\N	\N
cb63453e-618c-44a3-a518-d943b9cd0594	48060b50-0791-4e4e-ac10-b67e84b373ad	9179b9a7-4f41-4db9-a7a7-0a786617e8c7	2026-08-27 13:52:53.710293+00	\N	\N	\N
35f97245-0dc9-4400-bd93-f58b99004446	af477549-4032-4bc5-a340-ef63921d1a65	15832213-cb29-441a-98a6-6a6b5d8438c3	2026-08-27 13:52:53.721806+00	\N	\N	\N
583fd2ba-2fb3-4922-bb1c-c52ac67f4c89	40b4e542-806e-491e-9218-e7eae5547492	d1f4d1b2-09e3-4a97-aaaf-55c2c66de3e3	2026-08-27 13:52:53.725328+00	\N	\N	\N
e9f79f0f-338e-404c-ab59-af5f410762ef	f3b2032f-00f9-43fb-951f-4e9596848dc3	4cbfcc9a-cd7e-4106-ba27-fe79b5ca118d	2026-08-27 13:52:53.728932+00	\N	\N	\N
a0a6a671-0469-47f6-9191-9da31b8d4903	12b792db-ddc9-4cbe-b2b7-40a050a6aab2	008628d6-e55c-45c8-b428-902947d54b1e	2026-08-27 13:52:53.731969+00	\N	\N	\N
d7ea583b-7fd7-4ad8-9376-836be4de8fe2	d0f3989d-81cb-48f8-afdd-e926c6d53ebe	bf04a170-8f66-4dba-9a5c-9be85258ddb3	2026-08-27 13:52:53.736687+00	\N	\N	\N
cd3b89ec-6a27-4523-8126-38fed3b15ecb	12f03f63-55d3-4301-a7f9-e522fee49feb	f443171c-0b54-4c4e-b4fb-3914a2091978	2026-08-27 13:52:53.747171+00	\N	\N	\N
0b6409df-47e3-4c15-a1a1-cc444f991499	7c678469-22f7-465e-905e-9696f3fd9754	9110e06c-f9e6-4224-91a0-5076f0d94833	2026-08-27 13:52:53.750923+00	\N	\N	\N
a637ffad-fe61-4fc8-9455-e588e47b1ed2	101b53e9-b554-478a-9e95-3a2c2d44c9f1	e678c8bf-3c62-4a3f-9b86-bea30eb080c3	2026-08-27 13:52:53.755158+00	\N	\N	\N
c225360f-44c4-47be-a16f-bd8dce38bee2	8b1a90a9-1974-48a0-abfd-06cc552fade5	5d2187d0-51ad-434e-91c0-d6a03c6844d2	2026-08-27 13:52:53.759408+00	\N	\N	\N
4ea77c22-d578-469e-ae07-b822efaec37d	1b558fb2-b0dc-409d-9c82-bcebfa448a08	7a08093b-1495-4bf9-add8-3c7277969478	2026-08-27 13:52:53.821094+00	\N	\N	\N
141d130d-442c-4d64-bad7-3b5f47468c23	af21baf0-247d-486c-84ee-5f01f048deea	de719553-79a7-4c33-981a-7d2c37e77fa7	2026-08-27 13:52:53.826409+00	\N	\N	\N
a7ff8c5b-a3eb-4629-bfa4-62f9669e1150	d2d8d59b-d86d-4485-bd98-3086eda03728	abeddb0a-9a03-43a2-a92c-4712a63c2350	2026-08-27 13:52:53.830961+00	\N	\N	\N
1c2be6d7-39f9-4b81-bd2b-0c7f53f0ede5	85cc63ff-7df5-4fe8-ae5b-96f55bd68811	27c88ade-78b2-43d5-bf8f-b89cbb1e5877	2026-08-27 13:52:53.836112+00	\N	\N	\N
32af4a18-d092-47af-b525-9710ebfbf54c	f9e5949c-1359-4820-928e-2bb57723ccd5	c4bbf0df-504f-4e0d-a3ce-9bd041c168ff	2026-08-27 13:52:53.847558+00	\N	\N	\N
d846bc9e-d096-4868-9af1-f8170c3b7fc2	af477549-4032-4bc5-a340-ef63921d1a65	88e35168-489e-442e-aa0a-2e74b2a1d081	2026-08-27 13:52:53.85267+00	\N	\N	\N
75d32142-4071-48fa-8ff6-f7edd4b46339	85cc63ff-7df5-4fe8-ae5b-96f55bd68811	af58d9fb-ee20-4c0b-85b5-0f37c7082777	2026-08-27 13:52:53.860646+00	\N	\N	\N
cefa907a-8145-465f-bd62-f664575a58ce	5027181d-b736-4199-ae12-b407eea5631d	5e160da2-3b10-46b4-911a-257cd10f83dd	2026-08-27 13:52:53.866937+00	\N	\N	\N
93209d0b-a5d7-4189-bf43-d3727d344a70	8a3cae01-f152-423d-9a56-31a4fbcda459	e9cb2078-c1dd-40d4-8950-fd44343c9387	2026-08-27 13:52:53.872654+00	\N	\N	\N
65d2975f-2ca7-4929-b387-4e73b9358a4f	8a3cae01-f152-423d-9a56-31a4fbcda459	a4d3a47c-d2c5-4aa8-a871-d4c1fe357f28	2026-08-27 13:52:53.879299+00	\N	\N	\N
538a9534-cc95-4c30-aae2-7885b6ca57be	b651b723-1d84-4f6b-b59e-62ded0251782	7136d1f2-c5db-4939-b639-42e5a5943630	2026-08-27 13:52:53.883912+00	\N	\N	\N
2559a474-0bb8-4500-b239-ac539b875d20	\N	24616f2c-e3f7-43ca-965b-a4fbc556f6c5	2026-08-27 13:52:54.770305+00	\N	\N	🏢 Pole Commercial Location - Membres
f14a8f9b-8bc4-48c6-b5b2-58134e430ed8	\N	acf1f22d-3a4f-4206-8fa6-8cc21476f9d5	2026-08-27 13:52:54.833301+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
f01dd01b-ef87-4904-939f-b25dfff232fa	\N	29e29a9f-3070-4471-8c18-622e88baa212	2026-08-27 13:52:54.840937+00	\N	\N	🏢 Pole Commercial Location - Membres
77aa4f27-454f-48df-bb16-e36f2509e8aa	\N	af414a20-ec0e-4471-b41f-c33853c80c39	2026-08-27 13:52:54.847721+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
da5c6e9f-c384-4aa3-8c49-0df7aded53de	\N	99916e00-56e4-4b35-a5fd-909eef8f2704	2026-08-27 13:52:54.854079+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
d1444f1d-70a4-4c0c-83f1-829080f732f5	\N	31f4836f-58f0-431d-8ba4-389daeb11a10	2026-08-27 13:52:54.861593+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
ce284e94-591b-4481-8176-f36e7ca754e3	\N	a3259189-c703-4940-8404-8216f546557d	2026-08-27 13:52:54.86891+00	\N	\N	🏢 Pole Sinistre - Membres
64db922f-5644-48e8-b1b0-a4954bcd63b4	\N	b4897fcf-c25a-4b0b-9131-7da8f9e4cac4	2026-08-27 13:52:54.879047+00	\N	\N	🏢 Pole Sinistre - Membres
ef162273-8264-4e5e-acb1-c564c1060fd2	\N	720cdc7e-9037-4f3c-bf27-377ad9e8b8a9	2026-08-27 13:52:54.888921+00	\N	\N	🏢 Pole Sinistre - Membres
1fc34c68-a71c-4f90-a415-454be6fb844f	\N	ee4cd3c5-b326-4871-ab48-c6b848f418a4	2026-08-27 13:52:54.897011+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
ec582552-43ad-4ebb-b0aa-b251c8f4941b	\N	70d3b172-2c31-4ce3-9cbf-395fa145c20d	2026-08-27 13:52:54.907034+00	\N	\N	🏢 Pole Sinistre - Membres
df98a4d3-e277-453c-b4d6-0c2fe036747d	\N	2aa09086-0e15-44b5-a018-ad5523399af3	2026-08-27 13:52:54.914826+00	\N	\N	🏢 Pole Sinistre - Membres
d94a7f18-0064-4943-b830-62a8fada6e4e	\N	d8e1443a-229c-432d-838a-30dee4c41851	2026-08-27 13:52:54.92205+00	\N	\N	🏢 Pole Sinistre - Membres
ed1e1c3a-5dd4-4751-a868-bb91247c8fb6	\N	84fff1e7-4f57-4de1-a3b2-ae57c91a6ef3	2026-08-27 13:52:54.929038+00	\N	\N	🏢 Pole Sinistre - Membres
9440d69c-c847-4de1-82ba-50cf531e8f64	\N	48b47d4c-36bc-4b03-a6a1-bf20f39a5f9f	2026-08-27 13:52:54.936057+00	\N	\N	🏢 Pole Sinistre - Membres
020853aa-37e0-4413-931f-89f400e359ed	\N	3e190b28-2fdb-478b-8cc0-97e6b33c7ca4	2026-08-27 13:52:54.942994+00	\N	\N	🏢 Pole Sinistre - Membres
55f3efa3-972b-44ae-a9cc-a5a249c057ec	\N	369810dc-e6bc-4877-b331-641c31b131c1	2026-08-27 13:52:54.950678+00	\N	\N	🏢 Pole Sinistre - Membres
d00bf4e7-6dc5-4d06-a8cf-4deed2cdbdf9	\N	2bfae808-19fd-4837-a820-4fa3db5c740b	2026-08-27 13:52:54.959153+00	\N	\N	🏢 Pole Commercial Location - Membres
9c389fa1-75ba-4137-9e9e-6cefe7b0887b	\N	667feb96-feb2-494d-babb-379dbb4ba2e2	2026-08-27 13:52:55.201082+00	\N	\N	🏢 Pole Gestion - Membres
7e6e6155-cbe5-4255-9274-6c63650f6e51	\N	393fa0ce-2520-4048-9811-406b796ff26c	2026-08-27 13:52:55.207213+00	\N	\N	🏢 Pole Sinistre - Membres
4899f76e-5b1c-4a28-af69-f11c531a2064	\N	92d97f2a-29e8-44a0-802e-0b7675e6e4c5	2026-08-27 13:52:55.210518+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
3e94954c-9f07-4102-be53-da02a1f58bff	\N	441e49b3-b6fc-4388-bf28-12f564600968	2026-08-27 13:52:55.213528+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
25fbec98-12db-474a-b2f7-fd090b443737	\N	0157054d-2d79-4a99-8164-51492a6dddd9	2026-08-27 13:52:55.216888+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
6bf27922-e0be-407f-9808-dc54883d9ce1	\N	9ce0a426-717d-48e0-b5c2-b411da531739	2026-08-27 13:52:55.219164+00	\N	\N	🏢 Pole Sinistre - Membres
92370081-3a94-497f-84c4-457cb77b7a95	\N	dd93e1d2-ff2d-4858-ac04-a72b78a864a1	2026-08-27 13:52:55.222315+00	\N	\N	🏢 Pole Transaction - Membres
b76871b9-72f2-4f2b-8362-67d1c6b35e87	62d06322-8057-4756-9750-fb595d22f5e8	5e255a49-cefe-4364-a727-d6396712b446	2026-08-27 15:33:33.125628+00	\N	\N	\N
911b7767-8adf-4351-b691-b822d44f20a8	\N	4e8da17e-2a97-4f19-a10d-6d43062f1c23	2026-08-28 07:09:41.343706+00	\N	78a00eb7-3ea3-4102-a6d4-fe8750935824	🏢 Pole Relations Fournisseurs
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.audit_log (id, actor_name, action, entity_type, entity_id, details, created_at) FROM stdin;
a40eb10f-83d4-48c7-850a-3d2a525ef44d	Thomas DIDRICHE	sync	subscribed_skus	\N	{"count": 17}	2026-07-21 15:30:02.173746+00
a826212b-0ea0-486c-b59d-0fbbda7a2b8f	Thomas DIDRICHE	sync	subscribed_skus	\N	{"count": 17}	2026-07-21 15:31:16.365848+00
214d8d8d-a353-4a33-b058-21da23ed2f81	Thomas DIDRICHE	sync	subscribed_skus	\N	{"count": 17}	2026-07-21 15:42:46.513397+00
d03d4663-4c44-4eb5-b533-acd0baa58279	Thomas DIDRICHE	sync	subscribed_skus	\N	{"count": 17}	2026-07-21 15:42:50.91278+00
0968cd0b-66be-48f5-95de-29973084ed52	Thomas DIDRICHE	sync	subscribed_skus	\N	{"count": 17}	2026-07-21 15:46:05.304508+00
4e85338c-c478-4878-bc2f-123341f66e0e	Thomas DIDRICHE	sync	subscribed_skus	\N	{"count": 17}	2026-07-21 15:49:16.16804+00
7b37e36a-4d67-4b90-b2ef-df9d2ba3c82c	Thomas DIDRICHE	sync	subscribed_skus	\N	{"count": 17}	2026-07-21 15:49:36.007552+00
d7deb82e-a8a1-4b23-816f-27967397159f	Microsoft Graph Sync	sync	subscribed_skus	\N	{"total": 17, "skipped": 14, "imported": 3}	2026-07-22 09:25:18.19323+00
12965c41-8f4b-4cb9-aeab-c3fa4215ba5a	Microsoft Graph Sync	sync	subscribed_skus	\N	{"total": 17, "skipped": 13, "imported": 4}	2026-07-22 09:26:38.805143+00
98072602-8f95-4019-8d8e-13070deea663	Thomas DIDRICHE	create	hardware	9f039fb1-e061-48b1-8521-870e9466efe9	{"quantity": 1, "category_id": "591e509f-b8f4-4b8c-ae1c-174b8f513139"}	2026-07-22 10:33:21.743242+00
3a0e6125-1460-4ad2-9be5-1dd57e687de4	Microsoft Graph Sync	sync	subscribed_skus	\N	{"total": 17, "skipped": 13, "imported": 4}	2026-07-22 10:41:26.880755+00
a4310fbd-004f-4cb0-a324-72e068339a4e	Thomas DIDRICHE	create	onboarding_request	0b6740ee-5ad0-4dbd-8c56-1137933137f6	{"employee_id": "1e4c6d30-2665-479f-a16b-803bf285a11f", "movement_id": "0b6740ee-5ad0-4dbd-8c56-1137933137f6", "license_count": 2, "service_group": "🏢 Pole Neuf", "hardware_count": 3}	2026-07-22 11:04:08.282709+00
41cff1c4-dfcb-415b-b747-97b5387acfe9	Thomas DIDRICHE	create	onboarding_request	892fad26-a73f-4582-aa75-d616e44a3a2a	{"employee_id": "0e926d51-7989-4e89-95c6-3dd5a6b395a9", "movement_id": "892fad26-a73f-4582-aa75-d616e44a3a2a", "license_count": 1, "service_group": "🏢 Pole Relations Promoteurs", "hardware_count": 1}	2026-07-22 11:04:52.290399+00
22b95e8a-a874-4c3b-9c0e-c9a37c44759b	Thomas DIDRICHE	assign	movement_item	6b128b98-7bda-4b9b-af65-9371719a397d	{"hardware_item_id": "3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c"}	2026-07-22 11:05:03.293566+00
40bfebea-81de-4fba-a732-83cf41ca21d0	Thomas DIDRICHE	assign	movement_license	739310b6-3df8-43bf-9be8-b3b9ad0d4803	{"license_id": "7d4d4252-5592-469d-8c26-a6cf5f4720b9"}	2026-07-22 11:06:26.572609+00
283e7fd4-ef00-4f46-908e-02a0aabea73d	Thomas DIDRICHE	create	onboarding_request	dc79d05d-db75-4398-816e-0b06b0d87778	{"employee_id": "86f61584-f933-4be8-a46a-96dd1101f9c8", "movement_id": "dc79d05d-db75-4398-816e-0b06b0d87778", "license_count": 2, "hardware_count": 2, "service_groups": ["🏢 Managers", "🏢 Pole Gestion"]}	2026-07-22 12:22:34.346893+00
9db9ac88-ba28-439c-871a-9733a1907fd2	Thomas DIDRICHE	create	movement_action	\N	{"label": "test", "movement_id": "0b6740ee-5ad0-4dbd-8c56-1137933137f6"}	2026-07-22 15:15:07.907348+00
108d8397-a63a-4dcd-b1dc-ddd4181cebb0	Thomas DIDRICHE	complete	movement_action	9a85a30a-e6ff-4ed6-ae1d-1132b03d7ab7	{"done_at": "2026-07-22T15:15:09.379Z"}	2026-07-22 15:15:09.679339+00
03cbc98f-fc12-479d-ba6e-1b0605e68a64	Thomas DIDRICHE	update	movement	0b6740ee-5ad0-4dbd-8c56-1137933137f6	{"status": "in_progress"}	2026-07-22 15:15:22.180273+00
0d3eb4a2-4909-4fc4-b6b4-9fe55f1aac01	Thomas DIDRICHE	uncomplete	movement_action	9a85a30a-e6ff-4ed6-ae1d-1132b03d7ab7	{"done_at": null}	2026-07-22 15:15:59.078157+00
6657795b-3e87-48cd-8e27-30a9ca354f7e	Thomas DIDRICHE	complete	movement_action	9a85a30a-e6ff-4ed6-ae1d-1132b03d7ab7	{"done_at": "2026-07-22T15:15:59.964Z"}	2026-07-22 15:16:00.272843+00
b95c43f4-851e-4dda-b2f5-48737b52f394	Thomas DIDRICHE	create	onboarding_request	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	{"employee_id": "c3b2533e-f3fc-4743-b7a5-fc4fa038c387", "movement_id": "3fa92b71-50aa-4c3c-9780-1e103c8cc4d7", "license_count": 2, "hardware_count": 2, "service_groups": ["🏢 Pole Gestionnaires Insitu"]}	2026-07-22 15:21:46.540959+00
9a706500-8a6c-42a3-96b8-26140b08a93d	Thomas DIDRICHE	delete	license_type	039d065e-42c2-4f74-aec5-b0bfdce02401	{"code": "OFFICE365", "label": "Office 365"}	2026-07-22 16:19:39.610381+00
456e8319-900e-43f1-a543-a7df4504b249	Thomas DIDRICHE	create	license	5a76c99c-ad5f-4469-9576-2b8a03e24c11	{"count": 1, "license_type_id": "5a94f564-3165-43e9-b435-257276cd0e0d"}	2026-07-22 16:22:56.247453+00
1123fa25-d738-405a-bd1c-6868c0ed70c6	Thomas DIDRICHE	create	onboarding_request	d0a8a113-2be7-4acd-b5be-3c00030367a6	{"employee_id": "1e104c2f-7d26-4971-b39b-25d1d504c59e", "movement_id": "d0a8a113-2be7-4acd-b5be-3c00030367a6", "license_count": 2, "hardware_count": 2, "service_groups": ["🏢 Pole Dossier Location"]}	2026-07-22 16:31:20.573797+00
f7896ac2-2689-48fb-ac81-cb167a653291	Thomas DIDRICHE	assign	movement_license	a5eae043-a294-4557-acee-de8236404322	{"microsoft_license": true}	2026-07-22 16:50:38.545543+00
5002579b-7d8d-4b07-b97d-4fbd323fa2dc	Thomas DIDRICHE	assign	movement_license	e400c35a-9f68-4972-b932-844d00cc92c6	{"microsoft_license": true}	2026-07-22 16:50:42.098987+00
10e2e39c-e0df-4851-8f0e-ae097ea99546	Thomas DIDRICHE	create	license	24b164ac-150e-4c5e-b025-80208fb59145	{"count": 1, "license_type_id": "5a94f564-3165-43e9-b435-257276cd0e0d"}	2026-07-22 16:51:26.79213+00
2a24b18c-5393-42e3-b623-7e82fccde658	Thomas DIDRICHE	create	license	4dd3dcf5-53a1-472c-b26c-ce9dd687aa58	{"count": 1, "license_type_id": "5a94f564-3165-43e9-b435-257276cd0e0d"}	2026-07-22 17:03:50.56644+00
a87c42ad-7757-4540-90c9-679dc221d071	Microsoft Graph Sync	sync	employees	\N	{"created": 416, "skipped": 0, "updated": 0, "skippedGuests": 0}	2026-07-22 18:03:59.550799+00
8e89dc7a-7f2f-45b4-b400-1cdb2f1c9a1e	Dalyll REGUIA	update	dashboard_widgets	\N	{"orderedKeys": ["upcoming_onboardings", "pc_stock", "upcoming_offboardings", "active_alerts", "renewal_alerts", "license_summary", "peripheral_matrix", "upcoming_movements", "action_reminders"]}	2026-07-28 08:07:40.977217+00
866e6e1a-4182-4029-8352-704c4788c82d	Dalyll REGUIA	update	dashboard_widgets	\N	{"orderedKeys": ["pc_stock", "upcoming_offboardings", "upcoming_onboardings", "active_alerts", "renewal_alerts", "license_summary", "peripheral_matrix", "upcoming_movements", "action_reminders"]}	2026-07-28 08:07:48.882838+00
9b4703c9-7e93-40a4-947e-c1ac286f0744	Dalyll REGUIA	update	dashboard_widgets	\N	{"orderedKeys": ["active_alerts", "pc_stock", "upcoming_offboardings", "upcoming_onboardings", "renewal_alerts", "license_summary", "peripheral_matrix", "upcoming_movements", "action_reminders"]}	2026-07-28 08:07:52.501499+00
b357b717-7508-42a1-b100-bd6c9db767b4	Dalyll REGUIA	update	dashboard_widgets	\N	{"orderedKeys": ["active_alerts", "pc_stock", "upcoming_offboardings", "renewal_alerts", "upcoming_onboardings", "license_summary", "peripheral_matrix", "upcoming_movements", "action_reminders"]}	2026-07-28 08:07:56.679731+00
20cf78e9-3fb5-4b24-867a-107a95cff019	Dalyll REGUIA	update	dashboard_widgets	\N	{"orderedKeys": ["pc_stock", "active_alerts", "upcoming_offboardings", "renewal_alerts", "upcoming_onboardings", "license_summary", "peripheral_matrix", "upcoming_movements", "action_reminders"]}	2026-07-28 08:08:12.708693+00
a01f0b49-ce4c-479e-b888-7b26e007d1b6	Dalyll REGUIA	update	dashboard_widgets	\N	{"orderedKeys": ["pc_stock", "active_alerts", "renewal_alerts", "upcoming_offboardings", "upcoming_onboardings", "license_summary", "peripheral_matrix", "upcoming_movements", "action_reminders"]}	2026-07-28 08:10:59.915627+00
77b906fd-8cf1-4ee5-a2d8-683d175e7e7c	Thomas DIDRICHE	assign	movement_item	8364f0f4-c0a7-4824-ba6b-71f848ffd99d	{"hardware_item_id": "9f039fb1-e061-48b1-8521-870e9466efe9"}	2026-07-28 09:15:40.528724+00
030d50c5-0168-45e9-8e99-6912050bd900	Thomas DIDRICHE	create	hardware	04d2e68c-364b-45c3-bb11-9449dbc7571a	{"quantity": 1, "category_id": "3ab36349-b101-4fe4-9cd2-33f5ee8270a0"}	2026-07-28 09:27:49.215394+00
dfa786dc-8183-41f2-8e19-f3adfe7c8fd7	Thomas DIDRICHE	assign	movement_item	86bbfbad-20a2-45ad-a238-6d9b3caa10e9	{"hardware_item_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a"}	2026-07-28 09:28:22.97141+00
a7ae205f-ba81-456a-83b9-304bcd5769ea	Thomas DIDRICHE	complete	movement_action	b6a836d1-a0f6-48d9-b045-4d35a246e414	{"done_at": "2026-07-28T09:33:51.021Z"}	2026-07-28 09:33:51.872526+00
4cc8e111-88f1-4ae0-881d-72994948d239	Thomas DIDRICHE	complete	movement_action	480df30f-91ad-4a18-b643-b5cc25aa4ca9	{"done_at": "2026-07-28T09:33:56.901Z"}	2026-07-28 09:33:57.616568+00
da3d99de-2f55-4217-b9f2-72a7f7cd587f	Thomas DIDRICHE	update	movement	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	{"status": "in_progress"}	2026-07-28 09:34:09.333751+00
c581e7a2-fdb2-44e4-a11d-776a1603a2e4	Thomas DIDRICHE	sign	signed_document	\N	{"signer": "thomas DIDRICHE", "doc_type": "assignment", "movement_id": "3fa92b71-50aa-4c3c-9780-1e103c8cc4d7"}	2026-07-28 09:34:56.97887+00
16e8ed4f-9299-4704-a362-6c5b25be017b	Thomas DIDRICHE	sign	signed_document	\N	{"signer": "didriche", "doc_type": "assignment", "movement_id": "892fad26-a73f-4582-aa75-d616e44a3a2a"}	2026-07-28 12:00:25.915748+00
1d66846f-8951-4144-b663-377ce7cdcf1b	Thomas DIDRICHE	sign	signed_document	\N	{"signer": "didriche", "doc_type": "assignment", "movement_id": "892fad26-a73f-4582-aa75-d616e44a3a2a"}	2026-07-28 12:03:50.177592+00
3b017456-d1e4-4aef-9f4c-9d405b9873d3	Thomas DIDRICHE	sign	signed_document	\N	{"signer": "didriche", "doc_type": "assignment", "movement_id": "892fad26-a73f-4582-aa75-d616e44a3a2a"}	2026-07-28 12:06:04.599502+00
44f11f18-5fca-49d9-8c77-753c5e67c436	Thomas DIDRICHE	delete	movement	87577c20-fa6f-40d2-bdb9-e0ca9bde1bd1	{"type": "offboarding", "effective_date": "2026-07-28T00:00:00.000Z"}	2026-07-28 15:09:36.090286+00
6537f82c-e8b6-4753-ae06-003fb2af14f1	Thomas DIDRICHE	delete	movement	042e6ed2-0ae1-4b9f-9d05-1883e8e6246b	{"type": "offboarding", "effective_date": "2026-07-28T00:00:00.000Z"}	2026-07-28 15:17:51.689194+00
985b4a9c-2371-487a-9c31-14df029e0de9	Thomas DIDRICHE	delete	movement	d0a8a113-2be7-4acd-b5be-3c00030367a6	{"type": "onboarding", "effective_date": "2026-07-23T00:00:00.000Z"}	2026-07-28 15:20:32.082436+00
0c1850f2-84c1-4c68-b941-43f94b6f107e	Thomas DIDRICHE	delete	movement	dc79d05d-db75-4398-816e-0b06b0d87778	{"type": "onboarding", "effective_date": "2026-08-08T00:00:00.000Z"}	2026-07-28 15:20:44.14197+00
83e24c2d-ade2-403b-99ed-51bcd3db68f5	Thomas DIDRICHE	update	movement	aff6ae75-6da1-4c9c-8a6c-2d7384100259	{"status": "done"}	2026-07-28 15:47:09.048004+00
0a7dd503-2774-4585-bdca-e1159284c2e1	Thomas DIDRICHE	update	movement	0b6740ee-5ad0-4dbd-8c56-1137933137f6	{"status": "done"}	2026-07-28 15:47:17.863201+00
f9d6087c-1b89-4a4f-9f2b-9c40f1dea5c6	Thomas DIDRICHE	update	hardware	04d2e68c-364b-45c3-bb11-9449dbc7571a	{"from": "assigned", "status": "being_reinstalled"}	2026-07-29 06:49:03.163035+00
6f0f994b-6505-4b5e-a64b-470154057e0c	Thomas DIDRICHE	update	hardware	04d2e68c-364b-45c3-bb11-9449dbc7571a	{"from": "being_reinstalled", "status": "in_stock"}	2026-07-29 06:49:10.84622+00
d7d49df5-5331-4d84-962b-6837fc1fdc67	Thomas DIDRICHE	update	hardware	\N	{}	2026-07-29 10:01:44.979459+00
7a9a076e-95bd-4918-acaa-316eee8dc599	Thomas DIDRICHE	update	hardware	\N	{}	2026-07-29 10:09:26.235272+00
712a1ed8-7f8a-4db5-8495-1f129a10c366	Thomas DIDRICHE	update	hardware	\N	{}	2026-07-29 10:09:36.680546+00
78098fb1-3e05-415f-aa07-99038276a24f	Thomas DIDRICHE	update	hardware	\N	{}	2026-07-29 10:16:58.804679+00
b18c22ac-700a-4051-8c52-407c371a67e0	Thomas DIDRICHE	update	hardware	\N	{}	2026-07-29 10:17:08.226933+00
ef39d91e-3ec1-4e8a-a8ad-18347f7d901f	Thomas DIDRICHE	update	hardware	516624f5-7af1-41f6-aa60-73ebb661eb38	{}	2026-07-29 10:20:08.933976+00
e13cb153-613b-4714-b9e9-d9d0760a54fb	Thomas DIDRICHE	delete	hardware	516624f5-7af1-41f6-aa60-73ebb661eb38	{"serial": "qsfqsefqsefqsefseqfsfssefff"}	2026-07-29 10:20:16.309844+00
d59a1dbb-2ac9-41ce-9276-900f3c692e25	Thomas DIDRICHE	delete	hardware	1b6de711-62e5-4b03-b9c4-2b7b24f39248	{"serial": "qsfqsefqsefqsefseqfsfssefff"}	2026-07-29 10:20:18.819623+00
2bedb8bb-de89-4a48-8184-6958b6c75f32	Thomas DIDRICHE	delete	hardware	2c29f02f-1b58-4d98-9994-7488eac7218b	{"serial": "qsfqsefqsefqsefseqfsfssefff"}	2026-07-29 10:20:21.611262+00
9a9098c4-44b4-4428-9ff8-6f8384ff8714	Thomas DIDRICHE	delete	hardware	fa232203-8c91-45c9-b861-f58c1174e655	{"serial": "qsfqsefqsefqsefseqfsfssefff"}	2026-07-29 10:20:24.232998+00
807f0d50-b90e-4ea7-aaf7-f26148a54d0f	Thomas DIDRICHE	delete	hardware	5c3f61d0-c692-44f8-a724-79e8d39f2670	{"serial": "qsfqsefqsefqsefseqfsfssefff"}	2026-07-29 10:20:26.694463+00
aec6c0e6-0128-42f2-a61b-13693a2e7f7c	Thomas DIDRICHE	create	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"quantity": 1, "category_id": "3ab36349-b101-4fe4-9cd2-33f5ee8270a0"}	2026-07-29 13:00:11.888469+00
899d5326-4228-409f-aaec-c9110deb4425	Thomas FILLETTE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "assigned", "status": "being_reinstalled"}	2026-07-29 13:18:10.471303+00
efb08239-7cfe-4988-bdec-8a8dff9d6a76	Thomas FILLETTE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "being_reinstalled", "status": "in_stock"}	2026-07-29 13:18:15.235526+00
ef3e300c-b880-4bee-aa82-0a1a1de7ebc6	Thomas DIDRICHE	update	hardware	04d2e68c-364b-45c3-bb11-9449dbc7571a	{"from": "being_reinstalled", "status": "in_stock"}	2026-07-29 13:34:19.50657+00
6c191f37-a5db-4fb0-9067-0ab0f0077cf7	Thomas DIDRICHE	assign	movement_license	b1d90408-afdc-43d2-89cb-6e314b551ac7	{"microsoft_license": true}	2026-07-29 14:12:59.647973+00
82a06746-9160-435b-a800-be7f4ca402f9	Thomas DIDRICHE	sign	signed_document	\N	{"signer": "Thomas DIDRICHE", "doc_type": "assignment", "movement_id": "892fad26-a73f-4582-aa75-d616e44a3a2a"}	2026-07-29 14:13:40.864548+00
f4600d92-8e77-48a9-aab6-f2a6daabc066	Thomas DIDRICHE	sign	signed_document	\N	{"signer": "thomas didriche", "doc_type": "assignment", "movement_id": "892fad26-a73f-4582-aa75-d616e44a3a2a"}	2026-07-29 14:20:00.330851+00
ba62078d-3495-4c72-a981-058541b1433a	Thomas DIDRICHE	sign	signed_document	\N	{"signer": "thomas didriche", "doc_type": "assignment", "movement_id": "3fa92b71-50aa-4c3c-9780-1e103c8cc4d7"}	2026-07-29 14:31:59.010162+00
914257e4-4b1e-4a05-876a-3f04a2a1cce8	Thomas DIDRICHE	create	onboarding_request	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	{"employee_id": "cdcdb6aa-634c-43d8-a053-35f9c6285ea8", "movement_id": "f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef", "license_count": 2, "hardware_count": 3, "service_groups": ["🏢 Pole Neuf"]}	2026-07-29 16:13:09.253461+00
ce6fae64-9d93-43f9-8f2d-fe553cfed6a7	Thomas DIDRICHE	create	onboarding_request	4b0c9fe6-96ed-4d89-801a-c17c673889f8	{"employee_id": "6691355d-ea0c-4b91-9ee8-8101697e3f05", "movement_id": "4b0c9fe6-96ed-4d89-801a-c17c673889f8", "license_count": 2, "hardware_count": 3, "service_groups": ["🏢 Pole Relations Promoteurs"]}	2026-07-29 16:16:07.001416+00
9684da43-b182-4f0a-8359-fbad6f2cfc38	Thomas DIDRICHE	create	onboarding_request	69e23f72-9f35-4a55-8e97-66ba7262a1e8	{"employee_id": "a4e879e2-7e22-45f3-a75f-bc00d652198e", "movement_id": "69e23f72-9f35-4a55-8e97-66ba7262a1e8", "license_count": 1, "hardware_count": 1, "service_groups": ["🏢 Pole Service Relation clients"]}	2026-07-30 06:58:20.679863+00
49229403-2f71-40e7-a114-6e7f8a76b1a6	Thomas DIDRICHE	create	onboarding_request	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	{"employee_id": "a760e3d2-88e4-4884-8d19-1889a862c1c4", "movement_id": "aa8a22e0-06f5-46c7-8ff0-536e0434bde3", "license_count": 2, "hardware_count": 2, "service_groups": ["🏢 Pole Sinistre"]}	2026-07-30 07:06:13.03858+00
8ef0587b-b34d-4514-a26b-4994a857a16e	Thomas DIDRICHE	create	onboarding_request	d1839fd9-a603-4c8d-97c0-702d9fd5b040	{"employee_id": "bcb23b56-60f9-4e6e-8b5d-ca2b7acf3378", "movement_id": "d1839fd9-a603-4c8d-97c0-702d9fd5b040", "license_count": 2, "hardware_count": 1, "service_groups": ["🏢 Pole Gestion"]}	2026-07-30 10:15:04.046137+00
93313fcd-5d53-4318-9b1c-28fa45330eb0	Thomas DIDRICHE	create	onboarding_request	a123f0f9-90a9-4e74-80f0-1155bbd64729	{"employee_id": "2f1fd062-8860-4869-aeda-8f671935c0ea", "movement_id": "a123f0f9-90a9-4e74-80f0-1155bbd64729", "license_count": 2, "hardware_count": 1, "service_groups": ["🏢 Pole Neuf"]}	2026-07-30 12:35:32.903509+00
619a9b6a-b75b-4bde-939a-75855abe5797	Thomas DIDRICHE	create	onboarding_request	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	{"employee_id": "3a434a21-51f1-4086-803e-1a3bb61a8558", "movement_id": "0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82", "license_count": 1, "hardware_count": 2, "service_groups": ["🏢 Pole Relations Fournisseurs"]}	2026-07-30 12:43:32.668054+00
41e7c94f-e0fd-4ef7-8ea0-36b5b8daae7d	Thomas DIDRICHE	create	onboarding_request	69c04646-2360-4aad-8751-da3db414881d	{"employee_id": "0a8657cc-4819-48d1-a11e-b840e7d91ced", "movement_id": "69c04646-2360-4aad-8751-da3db414881d", "license_count": 3, "hardware_count": 2, "service_groups": ["🏢 Service Informatique"]}	2026-07-30 13:08:41.546011+00
03829b81-4b1e-439f-a0e3-b49783b86cde	Thomas DIDRICHE	create	onboarding_request	98fdcd35-746f-488b-a047-2d4b515ab541	{"employee_id": "db3c5e00-b3d0-4667-ad5e-aed47b6e7129", "movement_id": "98fdcd35-746f-488b-a047-2d4b515ab541", "license_count": 1, "hardware_count": 1, "service_groups": ["🏢 Pole Projet"]}	2026-07-30 13:39:15.823801+00
64a0728b-6c5c-4e26-8bc1-f2a2b3e22cc3	Thomas DIDRICHE	create	onboarding_request	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	{"employee_id": "3d7eb1dc-873f-45d1-a26f-51e7d1f0e7a1", "movement_id": "cceaf7ef-e141-4967-a5ed-21aba1a5f39e", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Qualite"]}	2026-07-30 14:42:01.254566+00
21fcd138-af25-4c17-b1bf-750cc421972c	Thomas DIDRICHE	create	onboarding_request	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	{"employee_id": "ab288e7b-6393-4315-8b09-26410514fb7a", "movement_id": "a2fbdce4-c944-48bc-8a8f-f763a9199ae8", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Neuf"]}	2026-07-30 15:59:44.257566+00
0d624b07-1d24-44b0-99fa-0f1e06872d22	Thomas DIDRICHE	create	onboarding_request	6c72dd2c-f583-42fd-9865-35a78dd1b478	{"employee_id": "70a0cc86-c612-486c-a100-74001a9ff631", "movement_id": "6c72dd2c-f583-42fd-9865-35a78dd1b478", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Gestion"]}	2026-07-31 14:01:15.675655+00
8224b070-890b-4705-83ee-d9e211389158	Thomas DIDRICHE	create	onboarding_request	499e9466-0f33-444e-9576-0b9114f8c115	{"employee_id": "e3258fea-12a4-477e-aec1-afb092a94e9d", "movement_id": "499e9466-0f33-444e-9576-0b9114f8c115", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Développement CGP"]}	2026-07-31 14:16:26.467844+00
9f8f4b93-0354-4441-a9a2-b4de0994acfc	Thomas DIDRICHE	create	onboarding_request	150669ed-4cf2-461e-b96e-28527ae36507	{"employee_id": "18a1512b-eab8-4594-99fb-9b254688c6c6", "movement_id": "150669ed-4cf2-461e-b96e-28527ae36507", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Gestionnaires Insitu"]}	2026-07-31 14:24:36.940674+00
c5d2ab64-7c03-4480-8387-aa84259b7d0a	Thomas DIDRICHE	create	onboarding_request	20916465-e099-43f4-8b12-27cd7fb5f085	{"employee_id": "543e1412-60f4-4182-bac8-1aaab1417197", "movement_id": "20916465-e099-43f4-8b12-27cd7fb5f085", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Relations Promoteurs"]}	2026-07-31 14:29:28.712363+00
b43792b4-b630-44d0-81a3-82730c77f859	Thomas DIDRICHE	create	onboarding_request	e8bc38ba-fc34-4789-92b7-a31ef0482b58	{"employee_id": "c7c5fec0-367f-41d1-a08a-5a293558072e", "movement_id": "e8bc38ba-fc34-4789-92b7-a31ef0482b58", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Qualite"]}	2026-07-31 14:38:35.523272+00
8d7ef0a4-18ed-405b-ac2c-1124c98c8a16	Thomas DIDRICHE	create	onboarding_request	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	{"employee_id": "31a1c6f6-61f8-40ea-8377-abc57055d253", "movement_id": "3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Phoning Location"]}	2026-07-31 14:58:17.840371+00
3d7e2f22-229f-4137-9a5b-96f1db287fb8	Thomas DIDRICHE	create	onboarding_request	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	{"employee_id": "90e0b1f7-bd5c-422a-9ff2-a2f6776be765", "movement_id": "80a8c5bf-3ab4-4e94-8605-e4c2af7e1138", "license_count": 1, "hardware_count": 0, "service_groups": ["🏢 Pole Sinistre"]}	2026-07-31 15:22:58.006993+00
ac93a5cd-4122-445c-99c0-4a0d7aefb1e9	Thomas DIDRICHE	update	dashboard_widget	\N	{"key": "upcoming_movements", "visible": false}	2026-07-31 15:52:11.97667+00
29685132-a141-46d1-ac01-3a397f6b6cd8	Thomas DIDRICHE	update	dashboard_widget	\N	{"key": "upcoming_movements", "visible": true}	2026-07-31 15:52:12.802957+00
876dd54d-7c71-4969-b8fc-8b134ea76a11	Thomas DIDRICHE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "assigned", "status": "being_reinstalled"}	2026-08-26 13:48:03.268251+00
749f52f6-ea92-4028-8fb2-03453d41b667	Thomas DIDRICHE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "being_reinstalled", "status": "in_stock"}	2026-08-26 13:48:15.580458+00
8b2a8456-7984-4ba2-802b-41bad6c76035	Thomas DIDRICHE	update	hardware	9f039fb1-e061-48b1-8521-870e9466efe9	{"from": "assigned", "status": "being_reinstalled"}	2026-08-26 14:18:21.642392+00
cbca1b35-7c10-4c78-a819-4e78b2d46176	Thomas DIDRICHE	update	hardware	9f039fb1-e061-48b1-8521-870e9466efe9	{"from": "being_reinstalled", "status": "in_stock"}	2026-08-26 14:18:24.557948+00
07596143-263c-4fdf-b797-6201e7e59631	Thomas DIDRICHE	update	hardware	3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c	{"from": "assigned", "status": "being_reinstalled"}	2026-08-26 14:18:26.778822+00
40269861-a4de-423e-9fe8-a1d554746dd4	Thomas DIDRICHE	update	hardware	3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c	{"from": "being_reinstalled", "status": "in_stock"}	2026-08-26 14:18:27.801506+00
4d61903f-074e-4555-bee5-1856c0c69896	Thomas DIDRICHE	update	movement	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	{"status": "in_progress"}	2026-08-26 14:18:39.866335+00
caf48db3-e0e0-4ffc-a174-d9dde4db95c3	Thomas DIDRICHE	assign	movement_item	3bec5c9c-c739-4b4d-9d3d-6b279726785e	{"hardware_item_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e"}	2026-08-26 14:19:20.266496+00
bf132c9f-7f38-450c-93e2-b94f1cf8e0bf	Thomas DIDRICHE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "assigned", "status": "being_reinstalled"}	2026-08-26 14:19:32.529207+00
651e0f1c-0fec-474c-a109-63f9acc2aefb	Thomas DIDRICHE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "being_reinstalled", "status": "in_stock"}	2026-08-26 14:19:34.047685+00
2a052213-498c-46b4-8907-75e49514d000	Thomas DIDRICHE	delete	movement	69c04646-2360-4aad-8751-da3db414881d	{"type": "onboarding", "effective_date": "2026-09-01T00:00:00.000Z"}	2026-08-26 14:20:19.074453+00
08b38df3-6930-4225-9387-a3dfdc805bdc	Thomas DIDRICHE	assign	movement_item	9031967f-2775-4a5e-8824-4a8f37d456ad	{"hardware_item_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e"}	2026-08-26 14:20:31.901501+00
76981a15-4720-495e-b2b3-a914aa8444d6	Thomas DIDRICHE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "assigned", "status": "being_reinstalled"}	2026-08-26 14:20:52.536109+00
3e44734b-ed54-4470-af9e-fad0bf5b9d9b	Thomas DIDRICHE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "being_reinstalled", "status": "in_stock"}	2026-08-26 14:20:53.851392+00
8a8ab3a1-7abd-4147-998c-692be1567136	Thomas DIDRICHE	assign	movement_item	142b90f4-3b1e-4fcc-a8df-bd8e83ce4b5e	{"hardware_item_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e"}	2026-08-26 14:27:47.897931+00
014b0e4c-4fee-477a-908d-b18c2b13d3a3	Thomas DIDRICHE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "assigned", "status": "being_reinstalled"}	2026-08-26 14:28:00.895445+00
c8cda4fe-b2db-4d42-8778-9f7e95f4e475	Thomas DIDRICHE	update	hardware	b270d931-f4fe-477b-83dd-2d4195b8b28e	{"from": "being_reinstalled", "status": "in_stock"}	2026-08-26 14:28:02.469278+00
9eb2d73a-e446-409f-994c-93fe8100f552	Thomas DIDRICHE	delete	movement	98fdcd35-746f-488b-a047-2d4b515ab541	{"type": "onboarding", "effective_date": "2026-09-01T00:00:00.000Z"}	2026-08-26 14:29:46.606231+00
d79b3783-b8b3-43ec-b181-32b6b8b40631	Thomas DIDRICHE	delete	movement	69e23f72-9f35-4a55-8e97-66ba7262a1e8	{"type": "onboarding", "effective_date": "2026-09-16T00:00:00.000Z"}	2026-08-26 14:29:49.12741+00
a68d8823-6d8c-4516-bbf0-193c5b4e4867	Thomas DIDRICHE	assign	movement_item	9e105ae0-2d5b-420d-834a-545ac24990f5	{"hardware_item_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a"}	2026-08-26 14:30:08.282471+00
5bfd1e20-4408-4709-b360-b2e4748040f0	Thomas DIDRICHE	update	hardware	04d2e68c-364b-45c3-bb11-9449dbc7571a	{"from": "assigned", "status": "being_reinstalled"}	2026-08-26 14:30:16.548291+00
1a5ae4d1-33e9-460f-b45a-c599ef0664c4	Thomas DIDRICHE	update	hardware	04d2e68c-364b-45c3-bb11-9449dbc7571a	{"from": "being_reinstalled", "status": "in_stock"}	2026-08-26 14:30:18.047681+00
7b24bd29-1414-48cc-b470-5e6b3f155b6a	Thomas DIDRICHE	assign	movement_item	43aa9286-5020-41db-8a30-96899d04da54	{"hardware_item_id": "3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c"}	2026-08-26 14:32:40.776007+00
e4e1b055-c526-48f8-a23a-9ac523947600	Thomas DIDRICHE	update	hardware	3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c	{"from": "assigned", "status": "being_reinstalled"}	2026-08-26 14:32:48.672437+00
974c23fc-863b-4eb8-b3f9-62bf7e8bba33	Thomas DIDRICHE	assign	movement_item	c7592bac-1ece-4c43-b67a-ecaedb91576c	{"hardware_item_id": "9f039fb1-e061-48b1-8521-870e9466efe9"}	2026-08-26 14:57:03.365938+00
8c28b4b2-1b58-4254-aff1-0c9f0d5556ea	Thomas DIDRICHE	assign	movement_item	43aa9286-5020-41db-8a30-96899d04da54	{"employee_id": "62d06322-8057-4756-9750-fb595d22f5e8", "new_hardware_item_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e", "old_hardware_item_id": "3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c"}	2026-08-26 15:11:01.271025+00
2d89b8bd-9ace-4065-970b-a07ea8ea7170	Thomas DIDRICHE	assign	movement_item	9e105ae0-2d5b-420d-834a-545ac24990f5	{"employee_id": "62d06322-8057-4756-9750-fb595d22f5e8", "new_hardware_item_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a", "old_hardware_item_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e"}	2026-08-26 15:12:22.250078+00
819c3e36-acd6-42f0-a1ee-6e17576d39b9	Thomas DIDRICHE	import	hardware	\N	{"ok": 20, "skipped": 1006}	2026-08-26 16:02:20.100671+00
b398a8b3-d1ce-4db0-acb9-5c8597f0c32a	Thomas DIDRICHE	import	hardware	\N	{"ok": 20, "skipped": 1006}	2026-08-27 07:12:14.452475+00
c60bd5e7-bd9e-4a9e-8bea-b63eaaa1e808	Thomas DIDRICHE	import	hardware	\N	{"ok": 20, "skipped": 1006}	2026-08-27 07:13:57.435632+00
c8806b2d-5054-44eb-ae56-6b159e7d1e7f	Thomas DIDRICHE	import	hardware	\N	{"ok": 713, "skipped": 313}	2026-08-27 07:20:42.900195+00
2b2eb412-fd05-4033-aefe-44b1d440e546	Thomas DIDRICHE	import	hardware	\N	{"ok": 713, "skipped": 313}	2026-08-27 12:25:51.578788+00
91b14cbe-0e0c-4451-98b0-0845cbc56486	Thomas DIDRICHE	import	hardware	\N	{"ok": 713, "skipped": 313}	2026-08-27 13:34:56.898507+00
3ecf2a26-d66f-41fc-be1a-31774e1eeaec	Thomas DIDRICHE	import	hardware	\N	{"ok": 1025, "skipped": 1}	2026-08-27 13:52:55.354569+00
\.


--
-- Data for Name: contract_types; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.contract_types (id, code, label, has_end_date, sort_order) FROM stdin;
038f8a06-7121-4f4f-b042-d5ff44ea8b7e	CDI	CDI	f	1
cf4b3e62-0c2c-42b8-9925-2f50c990e0d2	CDD	CDD	t	2
00d548ca-2df6-4257-9c41-f9526827bb21	STAGE	Stage	t	3
962b8d84-46ee-4d70-859b-f47ecdab24e0	ALTERNANT	Alternant	t	4
\.


--
-- Data for Name: dashboard_widgets; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.dashboard_widgets (id, user_id, widget_key, label, visible, sort_order, config, created_at) FROM stdin;
5bfc637f-fcb9-4750-83d7-31b7bef7ae84	e862925b-6e2b-465a-a7e9-699a26ea0d27	upcoming_movements	Prochains mouvements	t	8	\N	2026-07-31 15:52:11.920925+00
c6e8908d-628f-4d03-8148-392dd1ba9dd0	607a6776-426a-4781-8d30-a5fc099a58bc	pc_stock	Stock PC / Téléphones / Casques	t	1	\N	2026-07-28 08:07:40.705737+00
1024483f-b7f4-460d-af0e-9c06ff49bac5	607a6776-426a-4781-8d30-a5fc099a58bc	active_alerts	Alertes prévisionnelles	t	2	\N	2026-07-28 08:07:40.780093+00
13121d0d-3528-4c32-bb85-e7d90c950664	607a6776-426a-4781-8d30-a5fc099a58bc	renewal_alerts	Renouvellements de licences	t	3	\N	2026-07-28 08:07:40.807134+00
6c65d984-a2b3-40c3-9f32-14343c19543b	607a6776-426a-4781-8d30-a5fc099a58bc	upcoming_offboardings	Départs à venir	t	4	\N	2026-07-28 08:07:40.745803+00
6d66f0ad-5972-4fc2-bc3f-40c83912d188	607a6776-426a-4781-8d30-a5fc099a58bc	upcoming_onboardings	Arrivées à venir	t	5	\N	2026-07-28 08:07:40.667989+00
74648787-b1eb-4a52-8661-c194379d3aa7	607a6776-426a-4781-8d30-a5fc099a58bc	license_summary	Licences	t	6	\N	2026-07-28 08:07:40.841905+00
798fc39f-91f7-42b1-a4c4-0e83cfb6250a	607a6776-426a-4781-8d30-a5fc099a58bc	peripheral_matrix	Périphériques par service	t	7	\N	2026-07-28 08:07:40.881813+00
bec5edb7-b521-4032-928d-9f7d0cfc1192	607a6776-426a-4781-8d30-a5fc099a58bc	upcoming_movements	Prochains mouvements	t	8	\N	2026-07-28 08:07:40.915658+00
9d7abc9b-35b0-46f4-abcf-91f3b143791f	607a6776-426a-4781-8d30-a5fc099a58bc	action_reminders	Rappels d'actions	t	9	\N	2026-07-28 08:07:40.945267+00
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.employees (id, first_name, last_name, email, service_id, contract_type_id, contract_end_date, manager_name, job_title, is_active, created_at, updated_at, microsoft_upn, microsoft_object_id, account_enabled, microsoft_synced_at) FROM stdin;
1e4c6d30-2665-479f-a16b-803bf285a11f	Toto	Tata	\N	\N	\N	\N	Thomas DIDRICHE	dff	t	2026-07-22 11:04:08.282709+00	2026-07-22 11:04:08.282709+00	\N	\N	\N	\N
0e926d51-7989-4e89-95c6-3dd5a6b395a9	gfzqsghil	feklfjg	\N	\N	\N	\N	Thomas DIDRICHE	qvsb d	t	2026-07-22 11:04:52.290399+00	2026-07-22 11:04:52.290399+00	\N	\N	\N	\N
86f61584-f933-4be8-a46a-96dd1101f9c8	zertyuiop	zertyuiop	\N	\N	\N	\N	Thomas DIDRICHE	neuneu	t	2026-07-22 12:22:34.346893+00	2026-07-22 12:22:34.346893+00	\N	\N	\N	\N
c3b2533e-f3fc-4743-b7a5-fc4fa038c387	ezrtyuio	qertyui	\N	\N	\N	\N	Thomas DIDRICHE	qestry	t	2026-07-22 15:21:46.540959+00	2026-07-22 15:21:46.540959+00	\N	\N	\N	\N
1e104c2f-7d26-4971-b39b-25d1d504c59e	dfdhnfdnfnfgnfn	nfdnfgnfgnfn	\N	\N	\N	\N	Thomas DIDRICHE	fnfdndfnfwn	t	2026-07-22 16:31:20.573797+00	2026-07-22 16:31:20.573797+00	\N	\N	\N	\N
ac55a2c1-d471-4e28-9e74-bd89845f2904	Adrien	ABADIE	aabadie@elyade.com	\N	\N	\N	\N	Assistante Syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	aabadie@elyade.com	7fbb9cc2-8fc0-46d5-a38f-5f2ea6d51941	t	2026-07-22 18:03:59.550799+00
12b792db-ddc9-4cbe-b2b7-40a050a6aab2	Amandine	AGAR	aagar@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	aagar@elyade.com	bcf7ad08-1c26-4c25-b899-71375db21c7b	t	2026-07-22 18:03:59.550799+00
ddd7b7c7-e9a5-4884-bca2-f911d16dc496	Alexandra	ARNAUD	aarnaud@elyade.com	\N	\N	\N	\N	Responsable pôle Contentieux / Juridique	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	aarnaud@elyade.com	9a685b9f-76f5-4898-8965-cf9e5c791e16	t	2026-07-22 18:03:59.550799+00
a2f07f8e-0b1e-4ea9-aa51-30d9b0f0269b	Antonin	BARTHAS	abarthas@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriété	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	abarthas@elyade.com	3700fd8d-8c96-4ff9-af72-9d8f41b8a0c2	t	2026-07-22 18:03:59.550799+00
820aa876-0c69-4407-ac07-b7a6d766c98b	Abeille	Raphael	AbeilleRaphael@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	AbeilleRaphael@elyade.com	58e03164-b11b-49c8-8b79-edc8df5721b0	t	2026-07-22 18:03:59.550799+00
56b096de-5526-435e-8ad6-183e9e9c7d84	Anissa	BENHAMOU	abenhamou@elyade.com	\N	\N	\N	\N	Success manager	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	abenhamou@elyade.com	212ebb76-3f80-4d3a-a4f7-fa31790f576c	t	2026-07-22 18:03:59.550799+00
58af1fc3-1da2-44a3-b7bf-fe444ea5dbb3	Accueil	Elyade	accueil@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	accueil@elyade.com	7e4bd24d-9e72-46ea-b636-b5606c0c41ec	t	2026-07-22 18:03:59.550799+00
f9e5949c-1359-4820-928e-2bb57723ccd5	Aurélie	COMBES	acombes@elyade.com	\N	\N	\N	\N	Comptable gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	acombes@elyade.com	b7aca105-c3a0-45bb-92f8-fc0ce6cc8178	t	2026-07-22 18:03:59.550799+00
92b25786-3bd7-4fac-b2b6-326a7902244f	Admin	KM	admin-KM@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	admin-KM@teamselyade.onmicrosoft.com	15b1ec64-c920-4ce6-b7bf-a41f7a44765a	t	2026-07-22 18:03:59.550799+00
1acf4b23-a4b3-4cc6-a453-52f6d4fd6df4	Administrateur	réseau	Admin_de_r_seau@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Admin_de_r_seau@teamselyade.onmicrosoft.com	aee822cc-c815-40a9-8aa7-8f5344deaf47	t	2026-07-22 18:03:59.550799+00
3c6445e4-b1d9-4d20-acb6-8cab8ca9cb5d	ADMIN	LOCAL	admin_local@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	admin_local@elyade.com	d455b5e2-89d1-4cdc-9eb4-4eac35ba4476	t	2026-07-22 18:03:59.550799+00
d63c789c-93d8-47ab-946f-c8724898a864	Admin365	Elyade	admin365@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	admin365@elyade.com	7b2b7bd9-d355-47a3-bccf-8ac34f39f513	t	2026-07-22 18:03:59.550799+00
5c31075d-e923-4521-a299-f9c254dcc305	Admin	Login	adminlogin@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adminlogin@teamselyade.onmicrosoft.com	07dda2c9-b452-47d4-8a64-6f40c124d647	t	2026-07-22 18:03:59.550799+00
04acfbef-f6af-47d8-b2ff-44495d63e0a4	Adobe_adm01		Adobe_adm01@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_adm01@elyade.com	b2c9bb2b-c661-4d21-bbfd-8167c0591401	t	2026-07-22 18:03:59.550799+00
6123e520-734d-4618-837d-ebc4e351e957	Adobe	Comm	Adobe_comm_01@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_comm_01@elyade.com	55199d2d-551d-4ad4-b3c0-2c0c559f1373	t	2026-07-22 18:03:59.550799+00
a81c1672-a7c8-4b84-9304-89c8540874c2	adobe_comptabilite		adobe_comptabilite@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adobe_comptabilite@elyade.com	2a67d94d-04c0-4b7a-8cb8-7c9e4d01109f	f	2026-07-22 18:03:59.550799+00
ad3e01f9-fa00-4608-baab-2b499fc3959c	Adobe	Compta ESI	adobe_comptaesi01@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adobe_comptaesi01@elyade.com	d75ed9e4-c9cc-4467-8601-eda31338c961	t	2026-07-22 18:03:59.550799+00
864a03cc-b1ef-4df3-b2fb-51dad35a105f	Adobe	Dev 02	Adobe_Dev_02@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_Dev_02@elyade.com	688f83a8-0e0f-4e2d-8ffc-eef0ae1536b1	t	2026-07-22 18:03:59.550799+00
72b05f2c-1083-4dcf-8245-45aad72e646b	Adobe	Developpement	Adobe_Dev01@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_Dev01@elyade.com	6b9ac225-9e90-4d6d-bde5-5e2bc1d23386	t	2026-07-22 18:03:59.550799+00
203f049a-6e7e-4dba-b223-eb034d550879	Adobe	Dossiers Loc 01	Adobe_dossiersloc_01@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_dossiersloc_01@elyade.com	e3cabd4b-72d3-480a-ba61-0c06742d1354	t	2026-07-22 18:03:59.550799+00
e943904f-cc45-4673-8c13-52a26bd210e6	Adobe	Dossiers Loc 02	Adobe_dossiersLoc_02@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_dossiersLoc_02@elyade.com	f7ed540d-b241-4974-ab94-6631e4765abc	t	2026-07-22 18:03:59.550799+00
54475c22-c3ff-4c52-bb59-e69c14bfebee	Adobe	Phoning 03	Adobe_phoning_03@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_phoning_03@elyade.com	5574cd87-bcb7-4e29-aff5-b1c90b9bfe5f	t	2026-07-22 18:03:59.550799+00
1beb7d03-e33b-49d4-95e5-c7c3f63a7c4f	Adobe	Projet 01	adobe_projet_01@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adobe_projet_01@elyade.com	5b504a74-514e-408b-b18e-fe24c08f2ddf	t	2026-07-22 18:03:59.550799+00
bd01c1c3-7f2f-45cd-9dc8-864af3977fef	Adobe	Projet 02	Adobe_Projet_02@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_Projet_02@elyade.com	ade7f42b-cc6f-4624-a0f4-1fbfc1df6e1a	f	2026-07-22 18:03:59.550799+00
479f2b49-6891-440a-b15e-24c2e3cd1d2d	AdobeTransaction02		Adobe_Transaction_02@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_Transaction_02@elyade.com	5da18da0-d14c-4f49-8cb7-f2b939426037	t	2026-07-22 18:03:59.550799+00
6e352ab6-b825-40ab-a3ac-7e4a10803ee0	Adobe	Transaction03	Adobe_Transaction_03@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Adobe_Transaction_03@elyade.com	513b4958-a066-4b44-8fc4-6a3aaeff7e78	f	2026-07-22 18:03:59.550799+00
be4d1f71-5958-48b6-a3d5-06ef5864614b	AdobePhoning01		AdobePhoning01@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	AdobePhoning01@elyade.com	83f2d7a6-2ceb-4925-bbf8-6f3254ef1bbe	t	2026-07-22 18:03:59.550799+00
939aab9f-8918-49ed-aaf3-98295baea635	AdobePhoning02		AdobePhoning02@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	AdobePhoning02@elyade.com	4165264c-8f44-4445-9e8b-4408354333bc	t	2026-07-22 18:03:59.550799+00
413462d2-eac1-4694-bbe9-71fc347c2290	Adobe	RH	adoberh02@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adoberh02@elyade.com	8cf20502-20eb-4f85-a2c4-721dca767299	t	2026-07-22 18:03:59.550799+00
7b032f0a-4f83-458b-9d9f-8282b6437d2e	Adobe	RSE	adoberse@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adoberse@elyade.com	1d936266-96a8-45dd-b0cf-84441eb5a5d7	t	2026-07-22 18:03:59.550799+00
f7c224cb-baff-4f4a-a670-f01fd3ac6d4c	AdobeTransaction		adobetransaction@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adobetransaction@elyade.com	e2dcf593-d611-4e25-bc95-b1c9a27b0269	t	2026-07-22 18:03:59.550799+00
94d1c869-4895-41e9-885f-1a1d488a30e3	AdSynch		AdSynch@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	AdSynch@teamselyade.onmicrosoft.com	d8a0a02f-490e-4192-a008-2c05c0a724e4	t	2026-07-22 18:03:59.550799+00
c93c8f77-9e9f-4e4b-8cd6-4be3624f33d7	On-Premises	Directory Synchronization Service Account	ADToAADSyncServiceAccount@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ADToAADSyncServiceAccount@teamselyade.onmicrosoft.com	6a5dab09-0716-4f69-9adf-8f586281a5a3	t	2026-07-22 18:03:59.550799+00
e34f26ba-dfb4-4d63-a62c-ce2ca523f769	Amandine	DUMAS	adumas@elyade.com	\N	\N	\N	\N	Attachée clientèle location	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adumas@elyade.com	dec31ca9-0d3f-4a5a-84cf-a93881597a44	t	2026-07-22 18:03:59.550799+00
ce5c22dd-4ad4-406e-8cba-e2367519bdd6	Anna	DUPUY	adupuy@elyade.com	\N	\N	\N	\N	Assistante pôle neuf	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	adupuy@elyade.com	5d1960c4-87b1-46e0-8736-4fecbf663bb9	t	2026-07-22 18:03:59.550799+00
b07ed237-0e10-47d8-b08a-4f5bffb57f48	agoravita	agoravita	agoravita@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	agoravita@teamselyade.onmicrosoft.com	18c32462-d6ca-4adf-82e3-b1c4f042fac4	f	2026-07-22 18:03:59.550799+00
dae2946c-832b-4edb-8b5d-2935a98628c0	Marie	Oeuvrard	BookingMarieOeuvrard@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingMarieOeuvrard@elyade.com	8f24ce19-a0aa-4397-8ee8-17cdeca48ab2	t	2026-07-22 18:03:59.550799+00
7cf8575c-4324-434d-8461-34723f182514	Anais	INVERNON	ainvernon@elyade.com	\N	\N	\N	\N	Attachée clientèle location	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ainvernon@elyade.com	5fc3b237-7fa7-4c6e-b47d-129e30bd956e	t	2026-07-22 18:03:59.550799+00
dc859169-5ded-4d4e-8e1d-33817fb5c60e	_Allolily	Allolily	allolily@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	allolily@elyade.com	a51daf2a-8362-4365-8c6a-0cf897781373	t	2026-07-22 18:03:59.550799+00
6ad12f2b-777b-40d7-8017-6065764e3526	Axelle	LOPES	alopes@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	alopes@elyade.com	0159fbdd-acb1-48b2-8e1b-6641aef2912a	t	2026-07-22 18:03:59.550799+00
1b558fb2-b0dc-409d-9c82-bcebfa448a08	Ahmed	LOUBAK ADEN	aloubakaden@elyade.com	\N	\N	\N	\N	Assistant.e comptable	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	aloubakaden@elyade.com	58f8d565-2364-44dc-b8af-e7cf689c824e	t	2026-07-22 18:03:59.550799+00
d76d9822-78c9-4020-9e54-f800a9ffed18	Amandine	AGAR	AmandineAGAR@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	AmandineAGAR@elyade.com	47515b4a-8ddd-4ab7-9d02-7ce851ebb6a5	t	2026-07-22 18:03:59.550799+00
e062c123-edff-4312-8f10-26b8d1846bd5	Adeline	MILLAN	amillan@elyade.com	\N	\N	\N	\N	Comptable gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	amillan@elyade.com	fb74a8c1-c968-4cf6-9119-c028136a5abc	t	2026-07-22 18:03:59.550799+00
c9cc1cfc-af20-4be6-a3b7-14f38bb0514c	animateurs		anims@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	anims@elyade.com	77390fe6-2878-4129-bc5d-95d1429f4b88	t	2026-07-22 18:03:59.550799+00
b58e68ca-31d6-4084-a7d3-cd89be5090de	Annonces		annonces@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	annonces@elyade.com	9ef7418f-443a-4f61-9976-b2bb207fbc01	f	2026-07-22 18:03:59.550799+00
9974a641-06b3-4a2a-b2be-323cc17f7a21	Adeline	OSBINI	aosbini@elyade.com	\N	\N	\N	\N	Chargée de livraison	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	aosbini@elyade.com	f63075a2-43cf-465b-bfee-b77538232129	t	2026-07-22 18:03:59.550799+00
d2db7239-1ca7-49b3-bc43-86c0cb25a825	Aurelie	PALUDETTO	apaludetto@elyade.com	\N	\N	\N	\N	Responsable relation client gestion locative	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	apaludetto@elyade.com	2a83cac8-882a-4654-b8ac-b4c2adb2c807	t	2026-07-22 18:03:59.550799+00
75418943-1492-41c8-91b8-4d23076a23fe	Alizee	PELERIN	apelerin@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	apelerin@elyade.com	201eb25a-6a73-41e4-b6a4-f862077d7090	t	2026-07-22 18:03:59.550799+00
743c37c3-f9a6-4596-9bc8-de61ed772a9b	Angéla	PEREIRA	apereira@elyade.com	\N	\N	\N	\N	Responsable Administrative et Comptable Gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	apereira@elyade.com	b6009cde-65bf-4004-af71-c0d1784857aa	t	2026-07-22 18:03:59.550799+00
06add6f1-e7a4-4a8c-a6a9-e1065db303c8	Alizée	POULIN-PLAZANET	apoulin-plazanet@elyade.com	\N	\N	\N	\N	Juriste - gestionnaire contentieux	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	apoulin-plazanet@elyade.com	ded9aca6-8098-4f77-bc09-8489161c3014	t	2026-07-22 18:03:59.550799+00
326a37bf-8fbe-46ed-aead-abdd45ac590c	_Appel	de fonds	appeldefonds@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	appeldefonds@elyade.com	bdd1e610-563d-4767-9943-522b68d3fcc7	t	2026-07-22 18:03:59.550799+00
f56a985e-06ae-44b7-a5dd-a3c87dae0dee	Agoua-Sarah	AKADJE	asakadje@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	asakadje@elyade.com	30e0b9b0-1dec-4aae-93b0-4191b93141be	t	2026-07-22 18:03:59.550799+00
d6bf4eff-3cdd-4851-9c36-4783f7689e36	Atera		atera@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	atera@elyade.com	0f6fa521-7569-49d1-9b0e-fc2a905d5029	f	2026-07-22 18:03:59.550799+00
d302520a-3f7d-46e3-a0c3-7adc7c160abc	Andy	Touré	atoure@elyade.com	\N	\N	\N	\N	 Chargée montage immobilier neuf	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	atoure@elyade.com	356f950f-a23a-44cb-8299-4bbd250aaadc	t	2026-07-22 18:03:59.550799+00
f6018b47-45eb-45b7-833b-f37ca6e5542b	AzureAdSYnch	SYnch	AzureAdSYnch@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	AzureAdSYnch@elyade.com	b303878a-1f17-4c50-b81d-0adb4ef05fd5	t	2026-07-22 18:03:59.550799+00
7c165005-a800-432f-b1fe-0b613e7ae8d6	Brice	CHAMAYOU	bchamayou@elyade.com	\N	\N	\N	\N	Directeur juridique et assurantiel	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bchamayou@elyade.com	00d11a93-3ea5-4876-8aa5-55e956051b1e	t	2026-07-22 18:03:59.550799+00
a9699b23-503b-4baa-bc57-ac3bd78abf5f	Betty	KOUAME	BettyKOUAME@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BettyKOUAME@elyade.com	e6c709f0-39ad-4a0a-9aed-472e6c780a94	t	2026-07-22 18:03:59.550799+00
7be26beb-3cea-49a6-82bb-9d06e9038b23	Big	Brother	bigbrother@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bigbrother@teamselyade.onmicrosoft.com	d72bac5e-a631-421d-9eab-3015d0342e36	t	2026-07-22 18:03:59.550799+00
5eb7b2c2-d1ca-4bb5-ab6e-83d1335e78d1	Bilan	patrimonial	Bilanpatrimonial@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Bilanpatrimonial@elyade.com	220122cb-2245-40bc-85e9-5c8d4cc4385a	t	2026-07-22 18:03:59.550799+00
a3435b49-ac1c-4b5a-8020-34918e1a730d	Baptiste	INVERNON	binvernon@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	binvernon@elyade.com	806ff45f-25cf-4026-a437-1d4f36ea9098	t	2026-07-22 18:03:59.550799+00
d332732c-b65e-4733-9d07-bacff5667d34	Betty	KOUAME	bkouame@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bkouame@elyade.com	383e9f05-ab75-4ce8-9868-876744f7aa19	t	2026-07-22 18:03:59.550799+00
700216f8-2916-4d24-b926-0d9f409cc45b	Booking	- Diagnostic patrimonial de mon bien	Booking-Diagnosticpatrimonialdemonbien@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Booking-Diagnosticpatrimonialdemonbien@elyade.com	b8f6f58e-f3d5-49a1-a1fd-43dbd228f3a9	t	2026-07-22 18:03:59.550799+00
88c815d1-b299-434b-bede-c016a97d7819	Booking	- Marie RAUZY	Booking-MarieRAUZY@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Booking-MarieRAUZY@elyade.com	b6d0f92d-c24a-4014-84f6-0bb563e25a26	t	2026-07-22 18:03:59.550799+00
73628716-cf61-456c-b70c-cd8c5a3502e3	Booking	- Paul NEGRE-JUNYENT	Booking-PaulNEGREJUNYENT@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Booking-PaulNEGREJUNYENT@elyade.com	1c3722a1-de8a-41c1-b55e-38052144e4f0	t	2026-07-22 18:03:59.550799+00
2abe8f19-e0b7-43c2-bfd5-11a33c860672	Bilan	de performances	Booking_Bilandeperformances@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Booking_Bilandeperformances@elyade.com	9d4a5984-d62d-4639-92b4-88ef5f173823	t	2026-07-22 18:03:59.550799+00
78ab5906-9e62-4376-a4df-e0ee87108eba	Alizée	POULIN-PLAZANET	BookingAlizePOULINPLAZANET@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingAlizePOULINPLAZANET@elyade.com	0975ee8e-8edc-4867-b286-1d6d1c7076f9	t	2026-07-22 18:03:59.550799+00
34cd2010-0b95-404c-8c09-538d4df93040	Valentin	MARAVAL	BookingdeValentinMARAVAL@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingdeValentinMARAVAL@elyade.com	8a48f39f-d06a-4c28-a515-7f3445c29fe7	t	2026-07-22 18:03:59.550799+00
a386ed59-4a31-4b5e-b4c9-6e1c5ad973f8	Booking	Dorine VINCENT	BookingDorineVINCENT@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingDorineVINCENT@elyade.com	7f8da86e-82c2-4f53-a5f1-bf7048766f6a	t	2026-07-22 18:03:59.550799+00
10ebc041-6f41-4b0c-a1f7-eea60bc49d60	booking.elisaclavel		bookingelisaclavel@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookingelisaclavel@elyade.com	7b218b14-dff3-4a58-8bcf-ae063b6dffd7	t	2026-07-22 18:03:59.550799+00
3ff305a6-1757-403e-88d2-6f577e46379b	Booking	Equipe RH	BookingEquipeRH@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingEquipeRH@elyade.com	dfd7fb0f-11e9-44af-98e9-0594954f68e6	t	2026-07-22 18:03:59.550799+00
8af9b4a5-7f76-412f-84f1-e52bfc012f8d	Booking	Gestion à cloner	BookingGestioncloner@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingGestioncloner@elyade.com	c886147e-d9c5-47df-9873-c09f37340f8a	t	2026-07-22 18:03:59.550799+00
8cdad341-d571-44b9-8bca-49d46d5b246a	Booking	Gestion à cloner RDV 30 minutes	BookingGestionclonerRDV30minutes@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingGestionclonerRDV30minutes@elyade.com	fabbd0e7-3698-4164-968f-4a0c20bbaf1e	t	2026-07-22 18:03:59.550799+00
96cb6fd5-9d66-4dcc-976a-24ea1fa38e99	Booking	du Service Informatique Elyade	BookingInformatique@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingInformatique@elyade.com	b1228b7d-6aa2-4d9c-81f4-a414403609a9	t	2026-07-22 18:03:59.550799+00
3156422c-f09a-4b9f-a32a-c2bb568c7945	Booking	Juline BIBAS	BookingJulineBIBAS@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingJulineBIBAS@elyade.com	7843acaa-3eea-4f1b-b743-c069811f756c	t	2026-07-22 18:03:59.550799+00
159b86ea-9c9c-43ac-9a0d-04d184d8908d	Booking	Laurine KARDIFA	BookingLaurineKARDIFA@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingLaurineKARDIFA@elyade.com	bcb0043b-6c66-44dc-adc0-f0bf2e801f55	t	2026-07-22 18:03:59.550799+00
de335beb-54b0-4fd9-8f67-e354b2cf4c41	Booking	Lydie et Stéphane	BookingLydieRodriguez@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingLydieRodriguez@elyade.com	b95b7888-c211-4bde-b99d-7548c4ff80df	t	2026-07-22 18:03:59.550799+00
e55dd84f-552e-4dc1-8546-31debb4fa4f5	Manon	Santos	BookingManonSantos@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingManonSantos@elyade.com	d80302df-107a-4e18-b98d-f18ca3fda3b9	t	2026-07-22 18:03:59.550799+00
42231e5b-9f57-47f2-8f4d-390207c0fa45	Marion	SAYSSAC	BookingMarionSAYSSAC@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingMarionSAYSSAC@elyade.com	b39bdb63-f50b-48b0-b326-759eb6211ebb	t	2026-07-22 18:03:59.550799+00
78689726-8046-4eff-b497-1c450d791708	Booking	Mélissa	BookingMlissa@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingMlissa@elyade.com	53c94115-f10a-4066-8a26-fd81b1041870	t	2026-07-22 18:03:59.550799+00
cde5e576-af99-4b03-8f8b-9d3f7389ebc5	bookingnath		bookingnath@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookingnath@elyade.com	d8b3d4d1-d384-41fe-beb3-ce8f599653ee	t	2026-07-22 18:03:59.550799+00
270b5ebc-6c27-4a5f-92e9-fce91caff972	Booking	pôle neuf	Bookingpleneuf@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Bookingpleneuf@elyade.com	109036a2-1169-4061-bbda-3984b4a56862	t	2026-07-22 18:03:59.550799+00
f307230b-c70e-47c6-8734-026390a0a21f	Booking	RSE	BookingRSE@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingRSE@elyade.com	721214c7-c138-4f30-96e7-77cc7e7f92ca	t	2026-07-22 18:03:59.550799+00
e4f26849-3a2f-4de6-a1ee-0d0b41d41380	Aurélie	PALUDETTO	bookings.aureliepaludetto@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.aureliepaludetto@elyade.com	919417a7-236d-4735-922b-5ac39330b13f	t	2026-07-22 18:03:59.550799+00
43ab27df-124a-4b2a-873c-5ae18010e497	Camille	BLEUSE	bookings.camillebleuse@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.camillebleuse@elyade.com	0dc88f41-e5df-4d7c-b8bf-e81ce33154d8	t	2026-07-22 18:03:59.550799+00
ed1d2ed9-e00f-4d86-a7fb-af964b1a683f	Carine	MATEU	bookings.carinemateu@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.carinemateu@elyade.com	ff64328f-1b30-49be-8a14-84a645df9eb2	t	2026-07-22 18:03:59.550799+00
cbed6feb-5e6e-48fb-8f21-f032b5698a90	Céline	BAS	bookings.celinebas@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.celinebas@elyade.com	b677e76c-d5a5-4a20-a121-57b4c39308ea	t	2026-07-22 18:03:59.550799+00
90fea7ea-1de8-4d4e-a8fc-620b54fc726b	Clara	GRANGER	bookings.claragranger@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.claragranger@elyade.com	f6c95960-8960-4263-9644-15505c48b374	t	2026-07-22 18:03:59.550799+00
53b81cc4-5703-43e4-9df2-cfe1aeb5803b	Coline	LARREYA	bookings.colinelarreya@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.colinelarreya@elyade.com	afad81e9-93db-4b5c-88e6-060781a908ca	t	2026-07-22 18:03:59.550799+00
d8bd7e38-866f-4f16-a4a1-f4cafdc3f355	Emilie	PARPAIOLA	bookings.emilieparpaiola@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.emilieparpaiola@elyade.com	e5f19158-8859-40cc-b3ec-a481c7bb94b1	t	2026-07-22 18:03:59.550799+00
283b931a-a71d-4aa7-af00-4775afb10315	Gestion	Locative	bookings.gestionlocative@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.gestionlocative@elyade.com	9846cbec-20f9-43c4-b589-db4f60da6b5c	t	2026-07-22 18:03:59.550799+00
23ebf505-cc8a-41d9-a1ad-80790ca38a28	Johanna	JULIEN	bookings.johannajulien@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.johannajulien@elyade.com	b3fba1c6-86a9-4a47-9bf6-e18812203563	t	2026-07-22 18:03:59.550799+00
2b01c10d-93ab-4346-a312-62a09aa5d470	Justine	LOPES	bookings.justinelopes@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.justinelopes@elyade.com	09ca451d-1c27-481d-a768-3f4d474e8947	t	2026-07-22 18:03:59.550799+00
d23e0887-00c2-4a3f-9e92-57881e2f4ce0	Lionel	VIGNAUX	bookings.lionelvignaux@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.lionelvignaux@elyade.com	daa69c96-488f-45d3-92a9-54683f66e998	t	2026-07-22 18:03:59.550799+00
02c90d1d-3453-4d15-9d12-cfd19d6be387	Margaux	AUJOULAT	bookings.margauxaujoulat@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.margauxaujoulat@elyade.com	2c79180d-0f83-4aff-aad7-eddb04580b5f	t	2026-07-22 18:03:59.550799+00
6005c33d-eb3a-4143-a452-446a36afacbc	Marjorie	ZUCCHETTI	bookings.MarjorieZUCCHETTI@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.MarjorieZUCCHETTI@elyade.com	45df2721-3c43-4407-82ff-4d0c7e0278f6	t	2026-07-22 18:03:59.550799+00
d7aaab37-7a8f-4642-a603-32683611a7db	Marylise	VEAUTE	bookings.maryliseveaute@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.maryliseveaute@elyade.com	f7f3031a-c132-4fe3-b637-dc9a8ccd6669	t	2026-07-22 18:03:59.550799+00
1755d230-3da3-45db-833c-d02200838f2d	Ophélie	DELCUSE	bookings.opheliedelcuse@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.opheliedelcuse@elyade.com	491d1d7d-0253-40e2-8f49-84130e657c9d	t	2026-07-22 18:03:59.550799+00
1255e49c-c7d9-4a81-81d8-6c4c8ffcbf73	Romain	HEDJAL	bookings.romainhedjal@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.romainhedjal@elyade.com	6dc90f65-13bb-4d91-bf12-0f347909da7c	t	2026-07-22 18:03:59.550799+00
7ceb25f7-fe35-4401-95b0-9ead2c0e2c49	Sonia	HESNARD-COURET	bookings.soniahesnardcouret@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.soniahesnardcouret@elyade.com	5d3f5ff0-c483-4748-aee5-33a5b9fbbf8b	t	2026-07-22 18:03:59.550799+00
8f6fcd61-c6ca-40de-8639-32c3ed8d6e9a	Ugo	THIEBAUT	bookings.ugothiebaut@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bookings.ugothiebaut@elyade.com	cc201768-b465-4ad3-b6cf-1fe0f1e17cc4	t	2026-07-22 18:03:59.550799+00
123ba3ce-e4a4-4d56-a6a0-4ff4c23d4793	Sarah	AKADJE	BOOKINGSarahAKADJE@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BOOKINGSarahAKADJE@elyade.com	9c448b5a-8213-43ea-af97-1bb89dc169f3	t	2026-07-22 18:03:59.550799+00
39e88901-5133-4834-b3fe-0638e461ff9e	Accompagnement	Acquéreurs	BookingSRC@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingSRC@elyade.com	93f9b920-b301-4dfb-bff6-5d0e39774358	t	2026-07-22 18:03:59.550799+00
0d8c4432-0b1e-4c52-8920-27df44f8ec6f	BOOKINGS	- Sylvie CASSAGNE POLICAND	BOOKINGSSylvieCASSAGNEPOLICAND@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BOOKINGSSylvieCASSAGNEPOLICAND@elyade.com	85f7bc9d-de3d-41c3-a623-2e477cf483be	t	2026-07-22 18:03:59.550799+00
0583c61d-9b3e-40ae-bf15-4c574d0f5102	Booking	Thomas	BookingThomas@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingThomas@elyade.com	7c0da83e-9350-4da0-a116-ad0083dc16b1	t	2026-07-22 18:03:59.550799+00
aa2cd23e-fb5e-41df-9ecb-f2487c81e8b3	Vaitea	LEGENS	BookingVaiteaLEGENS@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BookingVaiteaLEGENS@elyade.com	e50df5b8-749c-4219-aff5-a3c1ea0c8df0	t	2026-07-22 18:03:59.550799+00
44f49193-df05-44ea-a8d1-e5c8500b0e05	BORDIGNON	Marina	BORDIGNONMarina@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	BORDIGNONMarina@elyade.com	c63fc24e-2954-4bec-9a57-4965b12f2361	t	2026-07-22 18:03:59.550799+00
24c79205-afec-4334-bd1e-a06e92fd6904	Boitier	quicksearch	bqsch@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	bqsch@teamselyade.onmicrosoft.com	28c6c31e-4d46-41a1-9f2a-839ca5937b74	t	2026-07-22 18:03:59.550799+00
f97bf5d9-114d-466a-b855-d17caee3e260	Carine	MATEU	camateu@elyade.com	\N	\N	\N	\N	Responsable back office Transaction	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	camateu@elyade.com	e2b2cb8f-9471-4b19-b7f2-834eee27bb26	t	2026-07-22 18:03:59.550799+00
0601ee98-398f-48ba-a706-455a9eeb4fac	Camille	BALLIN	cballin@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cballin@elyade.com	17c81a4a-24e6-4a8c-8c71-61d5db0aa100	t	2026-07-22 18:03:59.550799+00
fb9500b3-29fa-4dbb-b740-f7b413e25399	Céline	BAS	cbas@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cbas@elyade.com	da6afcc6-df47-47fc-9654-ce91d5a189c0	t	2026-07-22 18:03:59.550799+00
df94363a-8e80-45ce-a78a-e91ea33fb6ee	Camille	BLEUSE	cableuse@elyade.com	\N	\N	\N	\N	Animateur.trice relation client	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cbleuse@elyade.com	f731c084-c89d-4a63-818a-70204bc118dc	t	2026-07-22 18:03:59.550799+00
8f444a89-57da-4701-a844-496667163785	Cécile	BOIVIN	cboivin@elyade.com	\N	\N	\N	\N	Responsable service projet et développement	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cboivin@elyade.com	15ab0d87-1dde-48ec-953a-960cd47902df	t	2026-07-22 18:03:59.550799+00
6a300cbe-f185-4dea-833c-3e73e3278d14	Camille	BOURNIQUEL	cbourniquel@elyade.com	\N	\N	\N	\N	Assistante Syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cbourniquel@elyade.com	706fe13a-5d72-49c7-aeb5-4ea503ade2f9	t	2026-07-22 18:03:59.550799+00
b034df7e-e084-4199-a48b-77d2012c816d	Cédric	COCOLO	ccocolo@elyade.com	\N	\N	\N	\N	Conseiller / négociateur Transaction	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ccocolo@elyade.com	34aa0210-406b-4fa6-b434-d5288630afa2	t	2026-07-22 18:03:59.550799+00
6ef7ebd7-34e2-4382-940b-b847a5fb2dd4	Cédric	CORNUOT	ccornuot@elyade.com	\N	\N	\N	\N	Animateur location	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ccornuot@elyade.com	a551bb6d-811e-4caa-8bae-2892422615c3	f	2026-07-22 18:03:59.550799+00
bafcbdde-b731-4ed8-a334-2202d4cf4d98	Claire	DEHAN	cdehan@elyade.com	\N	\N	\N	\N	Comptable gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cdehan@elyade.com	4726f8a0-5bb2-4d2c-ad92-bbb7e5be31d8	t	2026-07-22 18:03:59.550799+00
12f03f63-55d3-4301-a7f9-e522fee49feb	Constance	FERLA	cferla@elyade.com	\N	\N	\N	\N	Coordinatrice Syndic immobilier neuf	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cferla@elyade.com	cfc7cbd6-7633-43d7-a8b6-22b75320ccf7	t	2026-07-22 18:03:59.550799+00
b6edb5ed-b618-4d73-91f2-baab882280c5	Cédric	FIRMIN	cfirmin@elyade.com	\N	\N	\N	\N	Animateur CGP	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cfirmin@elyade.com	ad6ebe2e-c2df-4b6a-8d5b-0ea1a98ba169	t	2026-07-22 18:03:59.550799+00
38d9a85c-9a79-470f-8cd7-014914acf3c7	Constance	FOURES	cfoures@elyade.com	\N	\N	\N	\N	Conseiller de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cfoures@elyade.com	d60149df-a884-481c-9cc6-6168816401f0	f	2026-07-22 18:03:59.550799+00
fa8430fb-b1ad-4515-9cc4-f9ebeaec8581	Corinne	FRAYSSINES	cfrayssines@elyade.com	\N	\N	\N	\N	Success manager	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cfrayssines@elyade.com	4298c8ba-0008-4133-9c6b-becab3e511c8	t	2026-07-22 18:03:59.550799+00
47d649ea-5c0a-40a0-8338-b3c7e0697f1d	Cassandre	GERS	cgers@elyade.com	\N	\N	\N	\N	Attachée clientèle location	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cgers@elyade.com	c2a63386-54a4-4feb-9943-eb1a78eef73f	t	2026-07-22 18:03:59.550799+00
3fc67d4a-9c9b-46bc-91ce-be6598ae4e5d	Clara	GRANGER	cgranger@elyade.com	\N	\N	\N	\N	Comptable syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cgranger@elyade.com	365ae5f3-d3a2-471e-b98b-c742a09d82e7	t	2026-07-22 18:03:59.550799+00
28cbe8e0-28d1-4d4d-9747-6ee4f3cfb79a	Coline	LARREYA	clarreya@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	clarreya@elyade.com	87b73866-1327-40c2-90d7-914d4523cc69	t	2026-07-22 18:03:59.550799+00
20e7bcd0-90dc-4503-8cd5-3bf95562fc53	Gestion	des clés	cles@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cles@elyade.com	95350e2e-0847-489e-9e19-5a600d6d6ffb	t	2026-07-22 18:03:59.550799+00
87fac48a-73e3-4748-b35a-278c05316ea0	Coralie	MILLES	cmilles@elyade.com	\N	\N	\N	\N	Comptable gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cmilles@elyade.com	389b570c-1b6a-4cf3-bc65-e080d3e6bf4e	t	2026-07-22 18:03:59.550799+00
b49664b4-f7ad-4df0-93a7-5b5f4b0237b0	Support	Communication	comm@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	comm@elyade.com	7d519858-aa5c-414d-95ee-22939aab7404	t	2026-07-22 18:03:59.550799+00
1a29ce43-d2ac-45f8-8958-ea3fc075e286	commandes		commandes@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	commandes@elyade.com	2c28278d-0c99-4a00-bfad-80a43ede89c6	t	2026-07-22 18:03:59.550799+00
04fb30da-a101-40ba-9d53-909ebb5df91f	Communication		communication@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	communication@elyade.com	cc6c9278-2376-49d3-8439-0befea5d189b	t	2026-07-22 18:03:59.550799+00
2f2295fa-c73e-4a2a-8927-9bd5c919bada	Compta	Syndic	compta-syndic@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	compta-syndic@elyade.com	0ec27d20-713f-4e85-bf51-4a4f4a229f43	f	2026-07-22 18:03:59.550799+00
8deef15f-729e-431b-8879-4d16a447a6c2	_Comptabilite		comptabilite@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	comptabilite@elyade.com	61c068b3-4589-4dc7-aa8f-40e04c381103	f	2026-07-22 18:03:59.550799+00
93022cf0-2102-454b-bece-f0f0f7fbb888	Compta	ESI	comptaesi@elyade.com	\N	\N	\N	\N	Poste Publique Comptable Gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	comptaesi@elyade.com	bd748376-5c9e-4b87-8202-791b427650f4	t	2026-07-22 18:03:59.550799+00
c5377012-f0da-4699-b41e-3cb16af14081	Comptabilite	GENERAL	comptageneral@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	comptageneral@teamselyade.onmicrosoft.com	9e8c6245-1eab-493a-a4f2-dcfe69f0f3a5	t	2026-07-22 18:03:59.550799+00
353a3cb6-3af1-4d2a-88fb-414dcd089eb4	Christelle	PAYSSE	cpaysse@elyade.com	\N	\N	\N	\N	Responsable back office Transaction	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cpaysse@elyade.com	cdefeb82-122a-4eec-a09f-226ff18dc238	t	2026-07-22 18:03:59.550799+00
6a38b771-6c34-4fd5-9c25-f842f383de99	CSE		CSE@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	CSE@elyade.com	2b7ce8ec-fbc1-45a6-ba39-4e686899e48b	t	2026-07-22 18:03:59.550799+00
40b4e542-806e-491e-9218-e7eae5547492	Célia	SEPTIER	cseptier@elyade.com	\N	\N	\N	\N	Assistante Syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cseptier@elyade.com	761fb9d1-b98b-4956-abf9-7035a9f654a5	t	2026-07-22 18:03:59.550799+00
6e7662ae-3bbe-4f61-8b32-dad4b1417fce	Corinne	VIGNAU	cvignau@elyade.com	\N	\N	\N	\N	Responsable d’affaires et partenariats immobiliers	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	cvignau@elyade.com	3499e2fb-fe00-46c8-9bb2-48a557e982c8	t	2026-07-22 18:03:59.550799+00
b5cf0adf-f9cc-4771-8c9b-b78814b16385	DEHAN		DEHAN@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	DEHAN@elyade.com	496ccbe9-93d5-4091-b918-100bd768ff0a	t	2026-07-22 18:03:59.550799+00
eb58bf37-f872-49f8-bfa1-501bdb3f40b4	dmarc	(Mail Systeme)	dmarc@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dmarc@elyade.com	3f6952d8-a997-4561-a9db-bfd7a6b3fcd2	f	2026-07-22 18:03:59.550799+00
00a9b480-73fe-4fe5-b82b-957471e38127	Dossiers		dossiers@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dossiers@elyade.com	b0822826-d9f9-49a0-bfbd-ab80e012fe65	f	2026-07-22 18:03:59.550799+00
825f170d-c377-4990-957a-d2bc9408788f	dpeapave		dpeapave@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dpeapave@elyade.com	44d53b1b-6eab-489e-9604-b35b4477112c	f	2026-07-22 18:03:59.550799+00
27284377-2736-439c-8739-4f43b696a719	dpediagamter		dpediagamter@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dpediagamter@elyade.com	38e73cde-3114-4176-91fe-157e05e32d11	t	2026-07-22 18:03:59.550799+00
0aca4d7d-ffcf-4437-91b5-6389c64dafe5	dpemonagil		dpemonagil@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dpemonagil@elyade.com	852330c9-1306-4bd3-b2a2-49a1e8a51493	t	2026-07-22 18:03:59.550799+00
311711ba-11fc-4130-995d-463dc8bf326a	dpesocobois		dpesocobois@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dpesocobois@elyade.com	44f186e5-b554-4599-8263-5f2d8653f3f8	f	2026-07-22 18:03:59.550799+00
378849ab-990b-4879-8740-2c521a08b9b2	_DPO		dpo@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dpo@elyade.com	81143216-f8b8-4de5-8bb0-cfcf1701ef7d	f	2026-07-22 18:03:59.550799+00
9c8b043d-a01c-4089-af23-294d15b8b655	Dalyll	REGUIA	dreguia@elyade.com	\N	\N	\N	\N	Développeur Informatique	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dreguia@elyade.com	607a6776-426a-4781-8d30-a5fc099a58bc	t	2026-07-22 18:03:59.550799+00
5b261ff2-3847-4eda-a8fd-17ea44ce52b1	Delphine	TONELLO-NADJAR	dtonello-nadjar@elyade.com	\N	\N	\N	\N	Gestionnaire sinistres	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dtonello-nadjar@elyade.com	da1ac308-50ae-4dfd-8551-9a14592a6ffe	f	2026-07-22 18:03:59.550799+00
624b8afa-d057-4c18-b7f1-e165bb81895e	Dorine	VINCENT	dvincent@elyade.com	\N	\N	\N	\N	Animatrice CGP	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	dvincent@elyade.com	297c5906-e875-496e-814f-0117207fc202	t	2026-07-22 18:03:59.550799+00
1bc9c89b-a771-442a-8921-26e105e8fb23	Elsa	BARASCUD	ebarascud@elyade.com	\N	\N	\N	\N	Attachée clientèle location	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ebarascud@elyade.com	8476331d-23ad-40ee-a100-ca30a700d13f	t	2026-07-22 18:03:59.550799+00
b5066669-f502-40ba-a6c3-815ed0c04b1e	Elsa	BERNEGE	ebernege@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ebernege@elyade.com	c8e0f4ec-67b7-48af-909b-aab6d6ecb19b	t	2026-07-22 18:03:59.550799+00
b19c168d-5d4b-4a65-983e-e9b0b7ab5105	Elisa	CAPEL	ecapel@elyade.com	\N	\N	\N	\N	Responsable fournisseurs	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ecapel@elyade.com	9bf85ab5-3835-470b-bfed-a5e737c3e3b5	f	2026-07-22 18:03:59.550799+00
62825a56-d294-42b1-9488-cc41ba7af2e3	Elisa	CLAVEL	eclavel@elyade.com	\N	\N	\N	\N	Chargée de livraison	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	eclavel@elyade.com	5548cf9c-c6d6-4143-a0c5-3ddd3aa58eb8	t	2026-07-22 18:03:59.550799+00
b47a4d59-6d13-41cc-a286-ab5a90e4796a	Elodie	DE BIASI	edebiasi@elyade.com	\N	\N	\N	\N	Juriste ESI	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	edebiasi@elyade.com	82aa4551-6790-4b96-af83-1b9ffdbcbc17	t	2026-07-22 18:03:59.550799+00
d04e152e-d241-44e5-a93d-0592a0bcbb90	EDLS		EDLS@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	EDSL@elyade.com	d6ab418a-2086-4e63-a2ab-24d5989c91b8	t	2026-07-22 18:03:59.550799+00
217feea2-76d3-4362-9102-7a1ded85946f	Emmeline	FLORENTIN	eflorentin@elyade.com	\N	\N	\N	\N	Animation Produits Junior - Partenaires	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	eflorentin@elyade.com	b5464082-e365-44ba-a9e0-6061a539765b	t	2026-07-22 18:03:59.550799+00
55b21729-5058-4fad-b7c1-c455a5485274	Esther	HERLINGER	eherlinger@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	eherlinger@elyade.com	4c05865d-1572-4879-b949-d4156027ac26	t	2026-07-22 18:03:59.550799+00
3df0dec0-7d7b-42e1-be5b-3befb44ae276	Emilie	KOEHL	ekoehl@elyade.com	\N	\N	\N	\N	Directrice Relation Clientèle ESI	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ekoehl@elyade.com	d076acdd-05a0-4a5a-8b43-f575e9837911	t	2026-07-22 18:03:59.550799+00
85cc63ff-7df5-4fe8-ae5b-96f55bd68811	Emilie	LAUTIER-VINEL	elautier-vinel@elyade.com	\N	\N	\N	\N	Responsable fournisseurs	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	elautier-vinel@elyade.com	f455ecf2-42b5-466d-bf78-46bb458cff29	t	2026-07-22 18:03:59.550799+00
addb801b-b1d8-40eb-a598-5b620ea13a33	Elsa	BERNEGE	ElsaBERNEGE@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ElsaBERNEGE@elyade.com	01f055fc-8e8c-413c-ac66-c00ccfc4204d	t	2026-07-22 18:03:59.550799+00
f02d68f2-2ea7-4d7e-a694-c74fa3410c70	Elyade	Contentieux	elyade.contentieux@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	elyade.contentieux@elyade.com	96326b7f-8785-48bb-acdc-822a35010fda	f	2026-07-22 18:03:59.550799+00
98389e0d-2582-465d-bb60-b729ae6897c3	Elyade	Loc	elyadeloc@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	elyadeloc@elyade.com	5c33be46-28e9-4ac5-87fd-5d23b66d0457	t	2026-07-22 18:03:59.550799+00
4dbda5fd-ef92-4afd-a879-c99a987f95db	ELYADE	Location	ELYADELocation@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ELYADELocation@elyade.com	179461b3-5f92-49ec-8884-6bb0a6a0b2b9	t	2026-07-22 18:03:59.550799+00
8491ce66-74a6-4313-9dc2-ac9f36f034f7	Enzo	MASSONNIÉ	emassonnie@elyade.com	\N	\N	\N	\N	Technicien informatique support et exploitation	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	emassonnie@elyade.com	d7064244-6e27-409a-9575-ba94b92105f0	t	2026-07-22 18:03:59.550799+00
69733cfd-e6a7-4a93-8d4e-194472472e34	Emilie	KOEHL	EmilieKOEHL@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	EmilieKOEHL@elyade.com	113c073e-e6b6-42d7-a39e-e4c7fd7ad72a	t	2026-07-22 18:03:59.550799+00
2444cc3b-cd82-42dc-a3b2-55bea5339a9c	Emilie	Lautier Vinel	EmilieLautierVinel@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	EmilieLautierVinel@elyade.com	2bb905fb-814e-4757-bf1d-bf744450fba9	t	2026-07-22 18:03:59.550799+00
533716fc-b5c3-4565-b5c9-2e520a37b4b8	Emilie	PARPAIOLA	eparpaiola@elyade.com	\N	\N	\N	\N	Juriste - gestionnaire contentieux	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	eparpaiola@elyade.com	9a7638c7-6232-490b-b4b9-16e073a5d0de	t	2026-07-22 18:03:59.550799+00
cc141c45-bc2e-4126-826f-69268e0ab8ac	Equinoxe	salle de fitness	Equinoxe-sallefitness@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Equinoxe-sallefitness@elyade.com	69e48ef3-ec12-4e44-8c4e-ddc062bce1db	t	2026-07-22 18:03:59.550799+00
3650531b-0e4b-4f56-b590-1ba136657b26	Equinoxe	salle de soins	Equinoxe-sallesoins@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Equinoxe-sallesoins@elyade.com	c0e506c4-c0dc-4a60-9000-96c516ebea04	t	2026-07-22 18:03:59.550799+00
53e7bf63-3e69-44e8-bfd1-18e0a521c14a	Equinoxe	salle de vie	Equinoxe-sallevie@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Equinoxe-sallevie@elyade.com	4c76be88-f3f4-404f-aa04-a2da2f2a6f61	t	2026-07-22 18:03:59.550799+00
02e9ca9c-a24f-486b-a934-46f0460e7524	Equipements		equipements@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	equipements@elyade.com	e3a06528-3841-4ef7-9a8b-3eadb094134e	f	2026-07-22 18:03:59.550799+00
b425a749-eddf-4991-951b-045fae50c701	Emilie	ROUZOUL	erouzoul@elyade.com	\N	\N	\N	\N	Responsable BackOffice et Soutien Juridique	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	erouzoul@elyade.com	d122b9d2-17c7-4467-8b0d-c75bfcd59618	t	2026-07-22 18:03:59.550799+00
48060b50-0791-4e4e-ac10-b67e84b373ad	Enya	SARDA	esarda@elyade.com	\N	\N	\N	\N	Assistante Syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	esarda@elyade.com	6ff4db08-bae6-4cdd-8901-49dea562f021	t	2026-07-22 18:03:59.550799+00
d82642f0-9496-40c7-8d25-5c80fbf04372	estimation-ESI		estimation-ESI@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	estimation-ESI@elyade.com	e53c3e26-e9a9-493a-addf-bd524c369c22	f	2026-07-22 18:03:59.550799+00
f7acd69e-21af-4923-8371-a465df0e0006	Elodie	TRANTOUL	etrantoul@elyade.com	\N	\N	\N	\N	Animateur Reseaux & Revenue Manager	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	etrantoul@elyade.com	f3b18f0e-4f63-4733-84a9-fb81ebea86ad	t	2026-07-22 18:03:59.550799+00
88fd6f62-6f95-4c1e-8da6-6b2f63b222b3	Etudes	de Marché	etudesdemarche@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	etudesdemarche@elyade.com	4ff7bf46-788f-45a3-97ec-f9481aa2cb18	f	2026-07-22 18:03:59.550799+00
f3b2032f-00f9-43fb-951f-4e9596848dc3	Fadéla	AL MASRI	falmasri@elyade.com	\N	\N	\N	\N	Responsable montage dossier	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	falmasri@elyade.com	7ea1498a-75c4-4e58-b5dd-f37188831059	t	2026-07-22 18:03:59.550799+00
7f1ae62a-c502-40c9-9153-40869516853c	Fiona	DOUCET	fdoucet@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	fdoucet@elyade.com	1eb66b59-bd43-45df-a6a9-cea30cfbb2a5	f	2026-07-22 18:03:59.550799+00
f285ffce-b4a3-45df-aa5f-12e8c8decd6a	Florie	GLAISE	fglaise@elyade.com	\N	\N	\N	\N	Gestionnaire Sinistres	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	fglaise@elyade.com	2be72cf5-b5f2-4e38-8de4-3f3cef451e70	f	2026-07-22 18:03:59.550799+00
9f016b33-d2af-445c-a963-afaf20641d72	fin-decennale		fin-decennale@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	fin-decennale@elyade.com	3d743d02-a59b-4eb5-bb1b-994de28f3a9c	f	2026-07-22 18:03:59.550799+00
57ad174b-600a-4156-ad48-e8ea11a03e15	Fayza	NAJI	fnaji@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	fnaji@elyade.com	f730440b-baea-4271-bc3a-f0dc28bfbc1f	t	2026-07-22 18:03:59.550799+00
15fa5be5-194a-42ca-a535-29656e1772e3	formations		formations@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	formations@elyade.com	4737fd81-5420-47e4-93b9-7f81e744bd02	t	2026-07-22 18:03:59.550799+00
e100c7e4-68c9-479d-abc7-ba10440c7a9c	Formulaire	ELYADE	formulaire@elyade.com	\N	\N	\N	\N	Formulaire Annonces Web	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	formulaire@elyade.com	fc4fe6d9-4e1e-44ea-9832-6f87b233b8be	t	2026-07-22 18:03:59.550799+00
7c9a2f42-4bdd-4aaa-9d2a-eb7d5a336e69	FOURES	Constance	FOURESConstance@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	FOURESConstance@elyade.com	57f3f540-7d9d-427a-9ffa-d631ea43020c	t	2026-07-22 18:03:59.550799+00
121f1bf7-0e18-4a86-867e-80ed108af6de	Florian	PRADIER	fpradier@elyade.com	\N	\N	\N	\N	Responsable administratif et comptable Syndic	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	fpradier@elyade.com	d9d730b3-da89-42b5-8ba5-a50f78d640b3	f	2026-07-22 18:03:59.550799+00
fe9015c8-7288-4a12-a2a5-ec8aa958b47d	fsso		fsso@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	fsso@teamselyade.onmicrosoft.com	a8228cfd-f420-435b-b85f-e5c6cd4e8813	t	2026-07-22 18:03:59.550799+00
0c4e8394-1c39-4fa1-8bd7-b05a93f5abda	⚙️	29 - Réunion 2 - 1er Etage (Ecran; Webcam)	29-Reunion-2@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	G042638ba8c2d47ddac9889d423c9d063@elyade.com	c396a3cd-81a7-43b7-b768-dbc041372c71	t	2026-07-22 18:03:59.550799+00
1aac23c4-5ed0-45b8-88e3-589cada3c0ca	⚙️	23 - Salle de Réunion - RDC - Contentieux (Ecran; Webcam)	23RDCcotesupport@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	G36561716dfe0412491522caa6188b3d9@elyade.com	c580651d-813c-491f-ac69-7f4eb23edd59	t	2026-07-22 18:03:59.550799+00
7c0b45d6-6461-4a3d-a6cf-cf44e5c3d051	⚙️	29 - Réunion 1 - 1er Etage (Ecran; Webcam)	29-reunion-1@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	G43739b82af794b288d5495ca9026a7fe@elyade.com	202f9d3e-9549-4273-ae88-67fdfc8cbf2a	t	2026-07-22 18:03:59.550799+00
13147d11-01b9-4db6-b6fc-e44482740f92	⚙️	23 - Salle de Réunion - RDC - Accueil (8P ; Ecran)	23RDCcoteaccueil@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	G9a2aab44a2ea4a81bb76b7c00797bd00@elyade.com	48b37719-3b98-4709-a7cc-fba0e3735668	t	2026-07-22 18:03:59.550799+00
e730a694-84e1-4100-8fa6-024f0d49d80f	📞	29 - Phone Box - RDC (2P ; Pas d'écran)	29PhoneBox@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Gd9798b46ba7d48a09fe634ac8454ff01@elyade.com	47c7466f-3509-4668-ac5b-52b894682c8b	t	2026-07-22 18:03:59.550799+00
3ee22ac9-0477-4511-86b9-0f2490ad3efd	Guylaine	DROUOT	gdrouot@elyade.com	\N	\N	\N	\N	Responsable Commercial Location	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	gdrouot@elyade.com	adde6626-c5b2-433c-b2f4-0711d4edf3a3	t	2026-07-22 18:03:59.550799+00
9ea98db0-6dda-4cc9-88b6-972621dfeb6a	gestion	ESI	gestesi@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	gestesi@teamselyade.onmicrosoft.com	17957f84-6d90-46ad-b0e7-00c214c8b239	t	2026-07-22 18:03:59.550799+00
3f8179b7-3d3d-4898-a193-46774315cf03	Gestion	Sinistres	gestionsinistres@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	gestionsinistres@elyade.com	30ca53a6-ca1e-40bd-92b8-ce7d48fcc700	f	2026-07-22 18:03:59.550799+00
8cbf8986-f776-466a-9a14-7456728627b0	Grégoire	MASSAT	gmassat@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	gmassat@elyade.com	dcdf10fc-eb50-4022-8930-c8c44230d6b6	t	2026-07-22 18:03:59.550799+00
b84d3799-66d1-4735-87cf-61cfc45de54b	_GPA		gpa@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	gpa@elyade.com	d7cb3c77-b7c4-427a-8e6e-38c7bf69b4a1	f	2026-07-22 18:03:59.550799+00
f5b6270f-a7ad-48e2-a344-05b8569c558d	Guylaine	DROUOT	GuylaineDROUOT@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	GuylaineDROUOT@elyade.com	b8300a11-a3e1-4c69-9382-749ce192f9f4	t	2026-07-22 18:03:59.550799+00
f924a33d-9e33-4ac2-bf9c-610260528a75	Hugo	DURAND	hdurand@elyade.com	\N	\N	\N	\N	Responsable de site / Responsable copropriétés Aquitaine	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	hdurand@elyade.com	9f7804ab-2c0f-4cc4-9677-e3c75eeb2243	f	2026-07-22 18:03:59.550799+00
59340902-ba8e-4f8b-a339-21c801ad33c2	HERLINGER	Esther	HERLINGEREsther@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	HERLINGEREsther@elyade.com	8374f461-5ec4-4283-9ed7-9d35f3492ef8	t	2026-07-22 18:03:59.550799+00
ce6db93c-5f0f-4613-b4af-a7008aeb4f2d	Hugo	NAKACHE	hnakache@elyade.com	\N	\N	\N	\N	Directeur des gestionnaires in situ	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	hnakache@elyade.com	264cbe39-ac2a-469b-aa9c-82209a35c0b7	t	2026-07-22 18:03:59.550799+00
b4c59353-93b4-4b09-88b8-1c9b010a79be	Hugo	QUINTANE	hquintane@elyade.com	\N	\N	\N	\N	Superviseur administratif et comptable gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	hquintane@elyade.com	36ca46e3-a9a8-42e0-abb2-832de6051f32	t	2026-07-22 18:03:59.550799+00
4a71bda8-9df5-4c7c-9ad8-c3cc194c5720	HUGO	NAKACHE	HUGONAKACHE@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	HUGONAKACHE@elyade.com	39af1cf4-2416-46ac-be44-0aeef5384107	t	2026-07-22 18:03:59.550799+00
403ee375-2ed9-4c38-bd4f-e29abe0b1059	Isabelle	BERTHEAS	ibertheas@elyade.com	\N	\N	\N	\N	Comptable Gérance	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ibertheas@elyade.com	a66b74bd-4d33-481d-910c-2b8dc3574e31	f	2026-07-22 18:03:59.550799+00
cb4a5878-c8d8-4286-8724-00424889e052	identifiant-fiscal		identifiantfiscal@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	identifiantfiscal@elyade.com	7ddbaf8d-5d6c-4ef4-843a-96253d5d47ad	t	2026-07-22 18:03:59.550799+00
6c3af917-5865-43d6-b48b-a92c0574e292	impersonation		impersonation@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	impersonation@elyade.com	15504b22-fbb2-4ab5-8083-51d9b4036e9d	t	2026-07-22 18:03:59.550799+00
86482f9a-6c28-4827-b91c-8e2735fb3483	Service	Informatique	informatique@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	informatique@elyade.com	53fec89e-a25e-4325-a5b0-e22585406b4f	t	2026-07-22 18:03:59.550799+00
53789f87-a283-4262-962d-a4959f7b189e	Lecteur	Chèque	interim2@teamselyade.onmicrosoft.com	\N	\N	\N	\N	Lecteur de Chèque	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	interim2@teamselyade.onmicrosoft.com	86aee12e-1ff2-4306-8d39-6348e282c097	t	2026-07-22 18:03:59.550799+00
36fd2e0f-5bcb-4022-aa08-f1cdaed0ecbe	Isaure	ODIAU-LAMISET	iodiau-lamiset@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	iodiau-lamiset@elyade.com	78f90473-13d6-4d38-b7df-7a422d82fa4d	t	2026-07-22 18:03:59.550799+00
b86967a8-4cb9-42e2-8fea-8be928fb012c	Compte	Invité Internet	IUSR_WIN-LIKDWC56Q4I@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	IUSR_WIN-LIKDWC56Q4I@teamselyade.onmicrosoft.com	237ceccd-584c-4812-990c-d4e835df596e	t	2026-07-22 18:03:59.550799+00
e143e82d-f0a6-437e-9151-76f6ca279a06	Julien	BALANANT	jbalanant@elyade.com	\N	\N	\N	\N	Assistant comptabilité et contrôle de gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jbalanant@elyade.com	0b30e430-4971-4a98-95c8-c2d268af7819	f	2026-07-22 18:03:59.550799+00
c1f31f22-5966-46e4-9487-6f6fdc24007a	Juline	BIBAS	jbibas@elyade.com	\N	\N	\N	\N	Chargée de relation partenaires	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jbibas@elyade.com	e2f4238b-e247-497d-90eb-d11e15ba4c8b	t	2026-07-22 18:03:59.550799+00
50a2daac-e8dd-4452-871d-25195225675f	Julien	CHARBONNEL	jcharbonnel@elyade.com	\N	\N	\N	\N	Superviseur Comptable	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jcharbonnel@elyade.com	46a15230-0167-481f-9333-c16619906d9a	f	2026-07-22 18:03:59.550799+00
d24749d5-70a3-4096-a707-9dc0fe11b3db	Joe	CLEMENTE	jclemente@elyade.com	\N	\N	\N	\N	Assistante pôle neuf	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jclemente@elyade.com	6107b108-b69e-4d17-9905-b5c9528a62f3	t	2026-07-22 18:03:59.550799+00
9799327d-781f-4c43-a284-08528389e366	Jennifer	CLOSTRES	jclostres@elyade.com	\N	\N	\N	\N	Gestionnaire sinistres	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jclostres@elyade.com	7daa0b28-815a-427f-9295-561c3df47843	f	2026-07-22 18:03:59.550799+00
0a7d08d8-d7a1-4510-8a6f-dd7c6ea30f99	Jean-Christophe	RAYNAUD	jcraynaud@elyade.com	\N	\N	\N	\N	Directeur administratif et financier	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jcraynaud@elyade.com	f7c0f1a9-412a-4be3-b2cb-2b8b0d7baefd	t	2026-07-22 18:03:59.550799+00
2072bfae-71ea-4931-b9f7-b35f96aec16c	Jeanne	DORCHIES	jdorchies@elyade.com	\N	\N	\N	\N	Assistant administratif et comptable	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jdorchies@elyade.com	374efbc2-b477-44dc-b9ec-76e32cb16896	t	2026-07-22 18:03:59.550799+00
b651b723-1d84-4f6b-b59e-62ded0251782	Jerome	DUVAL	jduval@elyade.com	\N	\N	\N	\N	Directeur commercial prescription	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jduval@elyade.com	0da1a77a-3ec9-434d-a5e8-902c580092a1	t	2026-07-22 18:03:59.550799+00
2fb8e5c5-afa8-4103-b324-f045e2fc0ed0	Jennifer	ESTIRADO	jestirado@elyade.com	\N	\N	\N	\N	Responsable back office Transaction	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jestirado@elyade.com	6e407b79-80e3-44f3-bc23-3d381e80ffa8	t	2026-07-22 18:03:59.550799+00
835e058d-b2fe-4387-8c6a-2434f5a40065	Jade	GUICHARD	jguichard@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jguichard@elyade.com	05216620-cd4c-415b-b165-f6f277ea337a	t	2026-07-22 18:03:59.550799+00
7b830831-6b84-4f8c-b6b2-bed2e07c2502	Johanna	JULIEN	jjulien@elyade.com	\N	\N	\N	\N	Responsable sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jjulien@elyade.com	a3520908-63fe-45ad-b27a-bc89271116a7	t	2026-07-22 18:03:59.550799+00
1d64afa0-46c7-4add-9402-f81fe8c9db9b	Justine	LOPES	jlopes@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jlopes@elyade.com	3439fa48-4256-46ec-b6d8-c5e4f217c146	t	2026-07-22 18:03:59.550799+00
8fbc705d-45a7-40d2-8349-fb5e3e3c9e02	Julie	MIRANNE	jmiranne@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jmiranne@elyade.com	134a557d-d00e-4547-ba5a-9ec450d39adb	f	2026-07-22 18:03:59.550799+00
9065235a-5dbe-42c0-9bbb-3557592c5e2a	Justine	MONACHON	jmonachon@elyade.com	\N	\N	\N	\N	Chargé.e communication et marketing	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jmonachon@elyade.com	68de962b-6733-4c0d-a1e3-f856c30b0c34	t	2026-07-22 18:03:59.550799+00
fe3c5188-90e6-42c8-9838-9fb267611852	Jonathan	NINEUIL	jnineuil@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jnineuil@elyade.com	1efbdd52-e8da-422d-a9ae-8e052cfac1e2	t	2026-07-22 18:03:59.550799+00
2b67753a-e872-408d-a2a6-b1e970334a2b	Jean Pierre	RODRIGUEZ	jprodriguez@elyade.com	\N	\N	\N	\N	Directeur Location	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	jprodriguez@elyade.com	0aebf181-7b50-40e1-b6dd-106b9023457e	t	2026-07-22 18:03:59.550799+00
a9e23803-2214-4a37-aedc-1a55f65a3698	Karim	MIALHE	KarimMIALHE@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	KarimMIALHE@elyade.com	d6b6def5-7806-45d0-b158-d925c8b25933	t	2026-07-22 18:03:59.550799+00
a45742a5-894a-4a32-83b8-0b3cf7cfb970	Karim	MIALHE	kmialhe@elyade.com	\N	\N	\N	\N	Responsable relation client Syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	kmialhe@elyade.com	d59867ca-f34f-4da8-878c-ef17e3d70b80	t	2026-07-22 18:03:59.550799+00
7c678469-22f7-465e-905e-9696f3fd9754	Karine	MOURET	kmouret@elyade.com	\N	\N	\N	\N	Chargée montage dossier	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	kmouret@elyade.com	11c5d235-58c5-4bfd-b155-1d7f1eaf1700	t	2026-07-22 18:03:59.550799+00
6bd4d90a-fb4e-4ded-ad05-62efba5bb299	Kelly	N'DOYE	kndoye@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	kndoye@elyade.com	611259fe-71d7-4f95-8d0b-6b50032cae47	t	2026-07-22 18:03:59.550799+00
e4747311-008a-4453-ae5b-68d4e08fc0ce	Sophos	konica	konica@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	konica@teamselyade.onmicrosoft.com	15918d66-ce36-4ae5-b1e6-9430de8b7bac	t	2026-07-22 18:03:59.550799+00
82d8b958-67ff-43fb-b72a-c661b81a4291	Laëtitia	BADIBANGA	LaetitiaBADIBANGA@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	LaetitiaBADIBANGA@elyade.com	5b8e4e20-98cf-4372-aae1-bc8b7a58e4f5	t	2026-07-22 18:03:59.550799+00
8430ec7e-4df7-4405-8a12-cc99b5c9b805	Léa	Leuger	LaLeuger@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	LaLeuger@elyade.com	c390b302-7157-4ff7-9cce-6ac0b0575d7f	t	2026-07-22 18:03:59.550799+00
063f61a2-c779-40ed-96d8-7e83d5a64105	Laurence	Clairefond	laurenceclairefond@elyade.com	\N	\N	\N	\N	Responsable pôle sinistre	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	laurenceclairefond@elyade.com	441d1fdd-6b1a-494a-ae0d-aee8761f9f47	f	2026-07-22 18:03:59.550799+00
0dce424d-c1a8-4fe4-8ec9-3ff08e35a631	Laura	AVERSAING	laversaing@elyade.com	\N	\N	\N	\N	Responsable Ressources Humaines	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	laversaing@elyade.com	7eeee111-411b-4231-ab88-4be52fc79e05	t	2026-07-22 18:03:59.550799+00
e47b7fac-fc2a-473f-a536-f3e366d83887	Laetitia	BADIBANGA	lbadibanga@elyade.com	\N	\N	\N	\N	Responsable Clientèle Gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lbadibanga@elyade.com	c1a3717e-5eac-4f85-8b9a-c31b8f51d596	t	2026-07-22 18:03:59.550799+00
d0f3989d-81cb-48f8-afdd-e926c6d53ebe	Laetitia	CHARLES	lcharles@elyade.com	\N	\N	\N	\N	Animateur Reseaux & Revenue Manager	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lcharles@elyade.com	e5d409f5-65eb-4fc5-a3ed-bb5f6824ad7a	t	2026-07-22 18:03:59.550799+00
7ac248ca-bb6a-46db-b293-98122e9ad5b6	Ludovic	CHAUBET	lchaubet@elyade.com	\N	\N	\N	\N	Business developer	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lchaubet@elyade.com	99974475-981d-440d-beb9-71f842939004	t	2026-07-22 18:03:59.550799+00
b4d9e800-cb35-44dc-80ab-81721a88cfa6	Laetitia	COUZINIER	lcouzinier@elyade.com	\N	\N	\N	\N	Superviseur Comptable	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lcouzinier@elyade.com	16ee620a-7945-4566-a86c-5949e4fd17b2	t	2026-07-22 18:03:59.550799+00
7db6ecd1-1749-4fce-9fbc-e537a6dbca1f	ledouze		ledouze@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ledouze@elyade.com	5b159bb1-3d28-43ec-93aa-e7a5bbfc98bc	f	2026-07-22 18:03:59.550799+00
8b1a90a9-1974-48a0-abfd-06cc552fade5	Lou	EIDELVEIN-KEMAJOU	leidelvein-kemajou@elyade.com	\N	\N	\N	\N	Assistant.e comptable	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	leidelvein-kemajou@elyade.com	8f684c08-a673-4a17-ae5f-7bbba936b2fa	t	2026-07-22 18:03:59.550799+00
125ed49d-4a83-46f1-a3f4-abd1380b639f	Louis-Henri	CAPEL	lhcapel@elyade.com	\N	\N	\N	\N	Directeur développement	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lhcapel@elyade.com	a65af21f-5701-4c11-8885-410ec5e2d470	t	2026-07-22 18:03:59.550799+00
011fd794-af58-48a7-bffd-e7c71af42a2d	Laurine	KARDIFA	lkardifa@elyade.com	\N	\N	\N	\N	Juriste ESI	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lkardifa@elyade.com	9913c9e0-0410-48d2-8726-52ad3da0751e	t	2026-07-22 18:03:59.550799+00
8bc894ba-63e8-4902-9cb2-96eb0ca1b713	Léa	LEUGER	lleuger@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lleuger@elyade.com	576e62c5-9ca9-48e7-a4c1-4404db546acc	t	2026-07-22 18:03:59.550799+00
81a1386e-b4aa-40c6-8238-a7b2c767ad32	Lauren	MARTIN	lmartin@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lmartin@elyade.com	d6d70c0f-682e-4406-a40d-e349d79c072c	f	2026-07-22 18:03:59.550799+00
4bd56618-dece-43fd-8fc9-fe98d930c922	lmartzel		lmartzel@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lmartzel@elyade.com	41e183ca-9ace-4b54-9ef7-006340eb16b1	f	2026-07-22 18:03:59.550799+00
af21baf0-247d-486c-84ee-5f01f048deea	Lise	MENANTEAU	lmenanteau@elyade.com	\N	\N	\N	\N	Assistant.e Syndic et chargé.e d'accueil	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lmenanteau@elyade.com	4e791c1a-8911-4a2c-af06-3ad2a09be5fe	t	2026-07-22 18:03:59.550799+00
2f1cd9e8-bf77-4034-9916-e561985cf453	local	professionnel	localprofessionnel@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	localprofessionnel@elyade.com	a701ec37-11db-41ae-b8d1-224b533199d7	t	2026-07-22 18:03:59.550799+00
6b3cc55d-6ef7-4c35-8fcb-540f3dbce1f1	Location		location@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	location@elyade.com	dc2aabcf-015e-4316-a388-e976f0443e3d	t	2026-07-22 18:03:59.550799+00
524d136a-891f-4adb-8d13-75b16eaa2914	Laura	PHAN	lphan@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lphan@elyade.com	321fd17d-29c8-482c-bb40-4aacb9696c80	f	2026-07-22 18:03:59.550799+00
a0b88af2-3d82-4c94-bf8d-fc03338446a9	Laure	POVREAU BADALUCCO	lpovreau@elyade.com	\N	\N	\N	\N	Directrice ressources humaines	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lpovreau@elyade.com	0c932814-7dd3-4113-b4ff-45a21c41d355	f	2026-07-22 18:03:59.550799+00
fe8c58a3-d528-4e12-a5b6-4a9c222a07f8	lre		lre@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lre@elyade.com	dc5cc67a-9bed-42d8-be91-7a1dc76f3a7a	t	2026-07-22 18:03:59.550799+00
114f8ba5-5564-42c4-9034-2e01a493c713	Lydie	RODRIGUEZ	lrodriguez@elyade.com	\N	\N	\N	\N	Présidente	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lrodriguez@elyade.com	049e2441-1eb2-40de-b127-7f1677aece48	t	2026-07-22 18:03:59.550799+00
7820cd30-66f1-48d6-b409-605b0bb1feca	Lisa	SALMERON	lsalmeron@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lsalmeron@elyade.com	bf481090-df61-45bd-9e40-d02228cc7968	f	2026-07-22 18:03:59.550799+00
ca071ca7-de86-41a1-bdd8-b1dbf0860682	Lionel	VIGNAUX	lvignaux@elyade.com	\N	\N	\N	\N	Responsable Clientèle Gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	lvignaux@elyade.com	fb037077-c8a8-447e-83ac-17fc74f0660d	t	2026-07-22 18:03:59.550799+00
94946c82-3397-4a16-95d4-8937e9fdbeea	Morgane	ALCINA	malcina@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	malcina@elyade.com	32ee2f64-fd6c-41cf-81a2-364959acbe93	t	2026-07-22 18:03:59.550799+00
75236855-38a0-40a2-a12a-6bed1751cfbe	Mandats		mandats@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mandats@elyade.com	bf8bfca8-0c08-4882-a4c6-8480a054fc64	f	2026-07-22 18:03:59.550799+00
30aab8db-291e-4f6d-b8ae-7751846612be	Marie	ANTON	manton@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriétés	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	manton@elyade.com	c32d0274-8e2f-4a32-8914-f57090f71200	f	2026-07-22 18:03:59.550799+00
2b04b0db-afec-492a-9f85-dafd283971b1	Margaux	DE AGUIRRE	MargauxDEAGUIRRE@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	MargauxDEAGUIRRE@elyade.com	01f8c03b-7310-41c7-b6fe-711f54a884a0	t	2026-07-22 18:03:59.550799+00
eaea539b-d76b-467d-a0f4-722da8fb8dbc	📅	Maud HARASYMCZUK	MaudHARASYMCZUK@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	MaudHARASYMCZUK@elyade.com	fe132777-a0f7-4cce-93c6-3a92aa957135	t	2026-07-22 18:03:59.550799+00
927488a7-380f-4c11-b5ae-861a355c6e7c	Margaux	AUJOULAT	maujoulat@elyade.com	\N	\N	\N	\N	Gestionnaire contentieux	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	maujoulat@elyade.com	fa3cac15-3df8-44f0-8a7d-2ae444ad9127	t	2026-07-22 18:03:59.550799+00
24a89787-8f1e-4a0d-854c-460a63bb7c46	Myriam	BENYESSAAD	mbenyessaad@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mbenyessaad@elyade.com	0df40988-7d02-4fa4-9e57-5e92dc3cbb22	f	2026-07-22 18:03:59.550799+00
c8486efb-2791-46a7-862b-a033d4c7218d	Marina	BORDIGNON	mbordignon@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mbordignon@elyade.com	c5a1c5d2-233b-4411-82bc-d0a55eb4f6cb	t	2026-07-22 18:03:59.550799+00
c390c330-806a-4eb9-a910-1c5887fed2cc	Marianne	BOSC-ANDRIEU	mbosc-andrieu@elyade.com	\N	\N	\N	\N	Responsable communication et marketing	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mbosc-andrieu@elyade.com	449f6aa1-dbd3-4cb6-b673-bf32d4a3c8d2	t	2026-07-22 18:03:59.550799+00
fd56b9f8-82d8-4a7f-be09-e3cddb5a7a17	Maxime	BOUYER	mbouyer@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mbouyer@elyade.com	b6f7b6be-ad71-426a-bd78-923dc3164e30	t	2026-07-22 18:03:59.550799+00
6e5256c5-869a-42a3-b1bd-f316c085dec9	Méline	CHANGEUR	mchangeur@elyade.com	\N	\N	\N	\N	Responsable Ressources Humaines	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mchangeur@elyade.com	0883994f-e547-479c-9d1c-ade8a1c83a60	t	2026-07-22 18:03:59.550799+00
c64b1a5f-f7f8-4966-b5be-57e7d35a7b9f	Mylène	DARDEVET	mdardevet@elyade.com	\N	\N	\N	\N	Attachée clientèle location	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mdardevet@elyade.com	6b44f610-5aca-45bd-b491-8c631e1a68dd	t	2026-07-22 18:03:59.550799+00
093bf052-2c9e-4c20-bf8e-6c218eca2a55	Margaux	DE AGUIRRE	mdeaguirre@elyade.com	\N	\N	\N	\N	Chargée montage immobilier neuf	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mdeaguirre@elyade.com	e88de114-c9b0-4f39-9e06-83261b81f60f	t	2026-07-22 18:03:59.550799+00
4759c448-dd61-400c-b21f-f0864cf40f9a	Mathilde	DE TONI	mdetoni@elyade.com	\N	\N	\N	\N	Attachée commerciale	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mdetoni@elyade.com	425a79b2-8013-44f0-a352-2cab075c1de0	t	2026-07-22 18:03:59.550799+00
0d15c9cd-6825-4027-9637-c4808db041ef	Margaux	FAURE	mfaure@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mfaure@elyade.com	23a87678-c86f-4dd7-b728-4c3d140a21a6	t	2026-07-22 18:03:59.550799+00
f8c1bb1c-66f9-4840-bb67-45736910e1ca	Marine	FORESTIER	mforestier@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mforestier@elyade.com	18b6cf40-cb20-45f6-97bf-9c38b16a2b8d	t	2026-07-22 18:03:59.550799+00
18b3115e-4da9-46bf-b134-836f62e83a0d	Maud	HARASYMCZUK	mharasymczuk@elyade.com	\N	\N	\N	\N	Manager équipe contentieux	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mharasymczuk@elyade.com	85bdb46a-e5e3-4ffd-af83-3343672d9cb2	t	2026-07-22 18:03:59.550799+00
6eb4c137-1cdb-4a96-aed3-5ea19e378e95	Mina	HACHT	MinaHACHT@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	MinaHACHT@elyade.com	c218158a-9535-4f34-a0ae-b0b195911d11	t	2026-07-22 18:03:59.550799+00
67a15374-4fb2-45b7-b17b-d92803dda093	Manon	LANGE	mlange@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mlange@elyade.com	295a6c41-176c-456e-aa57-21d36b121ff8	t	2026-07-22 18:03:59.550799+00
5655e1b6-ff1e-4dc6-a7aa-43dd1bfc690d	Mélanie	MARESTANG	mmarestang@elyade.com	\N	\N	\N	\N	Hôtesse d'accueil / Standardiste	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mmarestang@elyade.com	569fd40f-9e19-4b0a-a650-b44ba1520ce0	t	2026-07-22 18:03:59.550799+00
0ac0bb8e-f4ee-4573-b5dc-1de86a728e1c	Marie-Morgane	PORTE	mmporte@elyade.com	\N	\N	\N	\N	Gestionnaire Pole Technique	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mmporte@elyade.com	062e7dc7-1182-4262-bb5b-2460adcd3ae4	t	2026-07-22 18:03:59.550799+00
949c8129-c894-46dc-9fe4-85d8a55bad96	Mathieu	MUSCAT	mmuscat@elyade.com	\N	\N	\N	\N	Comptable Syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mmuscat@elyade.com	37094fb7-7f98-4066-b252-a337327a1b26	t	2026-07-22 18:03:59.550799+00
690d99b6-c9bd-4fa6-bb8e-5c28874e0762	Marjorie	NOVARESE	mnovarese@elyade.com	\N	\N	\N	\N	Responsable qualité	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mnovarese@elyade.com	2f8bdff8-ae6c-4061-baec-53084be58bae	t	2026-07-22 18:03:59.550799+00
5027181d-b736-4199-ae12-b407eea5631d	Marie	OEUVRARD	moeuvrard@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	moeuvrard@elyade.com	40acc276-a4eb-4fea-92b8-6fbd7eab2179	t	2026-07-22 18:03:59.550799+00
f892aacf-ef89-4c70-a6c8-2a055c411548	Mon conseiller	Elyade	monconseiller@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	monconseiller@elyade.com	8f7d56da-c2e0-4ef9-ad02-3c7d548ed304	t	2026-07-22 18:03:59.550799+00
a210f51a-b54e-4c2f-89dd-24ed02d001cc	Monconseiller_gestion02		monconseiller_gestion02@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	monconseiller_gestion02@elyade.com	41a6fb5b-196a-4a52-8e43-7fb618583bbb	f	2026-07-22 18:03:59.550799+00
3e9f72ed-9e03-4f98-b613-d6cbde38f395	monconseiller_gestion03		monconseiller_gestion03@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	monconseiller_gestion03@elyade.com	b0426ad6-7ffa-45f6-9484-b8a6b25ccf09	f	2026-07-22 18:03:59.550799+00
f51a2cd0-71bd-48ed-b2f8-df10f00cfd92	monconseiller_gestion04		monconseiller_gestion04@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	monconseiller_gestion04@elyade.com	70a87739-712e-4005-bb0b-51677120af2c	f	2026-07-22 18:03:59.550799+00
813de121-7b64-40d4-ab8a-f2ec7efcd351	Monday		monday@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	monday@elyade.com	448e70d7-ba98-4fdc-b275-d1b1cd3b6fef	t	2026-07-22 18:03:59.550799+00
eed45b7a-db67-4adc-882d-72144ae5d617	mondiag		mondiag@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mondiag@elyade.com	66507c58-fecf-4762-b41c-174f0a6f52e8	f	2026-07-22 18:03:59.550799+00
3551ce9d-933c-4627-bc19-5d8dd7aa210d	monprojetanah		monprojetanah@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	monprojetanah@elyade.com	80c2b399-e1ac-4614-8ba2-085f679b4c7b	t	2026-07-22 18:03:59.550799+00
c383abf2-84b1-481c-ba9d-2eab84ee49ca	Morgane	ALCINA	MorganeALCINA@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	MorganeALCINA@elyade.com	63ff8580-45f6-4598-8c82-94ffc9ee4544	t	2026-07-22 18:03:59.550799+00
38b36da7-b0d1-4662-be52-b6ee57aca061	Morgane	OSTAN LE GAC	mostanlegac@elyade.com	\N	\N	\N	\N	Comptable gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mostanlegac@elyade.com	adf0477a-e5d7-4ea8-8766-40989f41f1fd	t	2026-07-22 18:03:59.550799+00
b8b97be0-abe4-47ff-8151-c2e77caddc27	Moyens Generaux	Generaux	moyensgeneraux@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	moyensgeneraux@elyade.com	374010c0-36af-4408-a19f-7e62cadd8651	t	2026-07-22 18:03:59.550799+00
315594f9-9756-4e72-a1e4-7c16f735cab2	Maurice	PETIT	mpetit@elyade.com	\N	\N	\N	\N	Gestionnaire sinistre	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mpetit@elyade.com	e0d16945-5224-4069-8956-4c09c68c2b73	f	2026-07-22 18:03:59.550799+00
d72ad9ae-253e-4a5f-9fb0-5478cf511525	Marylene	PINCHON	mpinchon@elyade.com	\N	\N	\N	\N	Manager commercial BtoC	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mpinchon@elyade.com	e54f12c7-8755-43b1-8e02-26f36bc6488b	t	2026-07-22 18:03:59.550799+00
3232f69a-6582-4e8f-8a16-078b6d1e3983	Manon	PLAISANT	mplaisant@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mplaisant@elyade.com	8b4d16fb-388d-4428-a32e-0f444f885598	f	2026-07-22 18:03:59.550799+00
1758e62e-2ca5-4996-862c-7e4a016121ca	Mélissa	PRIZZON	mprizzon@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mprizzon@elyade.com	b1650240-3421-4c85-b16f-6f165b036187	t	2026-07-22 18:03:59.550799+00
f2cb2c15-2ec4-46e7-af22-329e368bb83b	Marie	RAUZY	mrauzy@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mrauzy@elyade.com	f3659978-f441-46ea-a271-3679507e19df	t	2026-07-22 18:03:59.550799+00
b105ce36-6d29-4330-ba4d-9665487af08e	MRH		mrh@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mrh@elyade.com	d9d57c11-783f-4324-813a-5a1c876332af	f	2026-07-22 18:03:59.550799+00
45fca3e8-eda9-4639-bce2-7ee307d0609f	Manon	RODRIGUEZ	mrodriguez@elyade.com	\N	\N	\N	\N	Assistant Gestionnaire Contentieux	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mrodriguez@elyade.com	abf123be-bc3f-47f9-b7e5-b32bccd0b63e	t	2026-07-22 18:03:59.550799+00
ac1e61ff-8759-467b-b90f-07705b747949	Manon	SANTOS	msantos@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	msantos@elyade.com	9fa63265-724f-4a3f-a8d8-2e3055d748d2	t	2026-07-22 18:03:59.550799+00
50a795dc-676c-4aa9-8127-8b29465b38ce	Marion	SAYSSAC	msayssac@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	msayssac@elyade.com	b6566c56-9a46-49f2-a184-358b31e3f955	f	2026-07-22 18:03:59.550799+00
c79f6259-fd29-43d8-9711-259796f7bcfc	Marie	TOLVE	mtolve@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mtolve@elyade.com	1cbc19cb-4330-407a-8d11-0d240dcb2f70	f	2026-07-22 18:03:59.550799+00
79d59a7e-d32c-4723-a9e3-80a370d4ed60	Marina	TUNEZ	mtunez@elyade.com	\N	\N	\N	\N	Success manager	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mtunez@elyade.com	15499925-c2fe-4e16-b5f4-fa3980db1160	t	2026-07-22 18:03:59.550799+00
332e4560-d344-482f-a585-9840f287e29c	Mélanie	VACHER	mvacher@elyade.com	\N	\N	\N	\N	Attachée clientèle location	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mvacher@elyade.com	4ec913bc-5feb-42ce-8384-bbf1823ab436	t	2026-07-22 18:03:59.550799+00
444e04c7-6655-4235-b260-54051ac6a617	Marylise	VEAUTE	mveaute@elyade.com	\N	\N	\N	\N	Juriste - gestionnaire contentieux	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mveaute@elyade.com	1640a956-85c2-477a-a22b-54567a7e30da	t	2026-07-22 18:03:59.550799+00
9c0f5e5d-f131-45ec-a47a-d181dc46d00b	Malisa	VERVIALLE	mvervialle@elyade.com	\N	\N	\N	\N	Responsable animation Commerciale	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mvervialle@elyade.com	a72ffbae-86c5-403d-8cb9-3142ed9b6ed0	f	2026-07-22 18:03:59.550799+00
dac6b804-7dd0-44aa-9eef-151b056591db	Marjorie	ZUCCHETTI	mzucchetti@elyade.com	\N	\N	\N	\N	Responsable produit	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	mzucchetti@elyade.com	32f7aefc-afcf-4a4a-865a-12d6cc800ad2	t	2026-07-22 18:03:59.550799+00
aac653bf-37ba-4cc1-b91e-220b8be7c496	Nicolas	BONNEAU	nbonneau@elyade.com	\N	\N	\N	\N	Comptable syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	nbonneau@elyade.com	795017bf-4244-4feb-a194-5a877929ce48	t	2026-07-22 18:03:59.550799+00
50d16e11-55eb-491a-bbef-750e1180d91f	Nicolas	DAUTEL	ndautel@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ndautel@elyade.com	68eb63c8-1f2f-4c23-b62a-51a8e135ec3b	t	2026-07-22 18:03:59.550799+00
e8ee2211-2079-4c3e-8eec-6c67f4ef71ad	Nicolas	DOS SANTOS	ndossantos@elyade.com	\N	\N	\N	\N	Superviseur comptable syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ndossantos@elyade.com	30accbf8-3e0e-475b-a704-4d3e8babb84d	t	2026-07-22 18:03:59.550799+00
66d4dd7a-0f21-49f2-a341-2ef5c714ea39	Nathalie	DOUMERG	ndoumerg@elyade.com	\N	\N	\N	\N	Responsable Administrative et Comptable Gérance	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ndoumerg@elyade.com	6a81f1ac-6034-4c2e-8d71-8e19fd8d73b1	f	2026-07-22 18:03:59.550799+00
089fa072-87d5-4d87-beb9-c3d9a34b0d73	Nicolas	DREUX	ndreux@elyade.com	\N	\N	\N	\N	Business developer	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ndreux@elyade.com	77bd87e8-f09e-4516-9d68-a82083f9c351	t	2026-07-22 18:03:59.550799+00
3a509087-ce70-4e56-a60e-61fd26f2cf6c	Ne pas	répondre	ne-pas-repondre@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ne-pas-repondre@elyade.com	4f4e616e-8dbb-4b91-84c7-ca04396d07b4	t	2026-07-22 18:03:59.550799+00
60f48644-b294-4680-abfb-89d41a2115c9	Ne	pas répondre Elyade	nepasrepondre@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	nepasrepondre@elyade.com	4ce8bd6e-0ed7-4394-961a-f9c96cb67c94	t	2026-07-22 18:03:59.550799+00
a8a50ec1-c99b-497d-ab41-23609e72b695	Nicolas	MILAN	nmilan@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	nmilan@elyade.com	0118338c-9ea1-4936-b960-f37d363564a5	f	2026-07-22 18:03:59.550799+00
54ee94fc-76ff-4567-a9bb-920b4b15c0e2	NOVARESE		NOVARESE@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	NOVARESE@elyade.com	7fe0c80a-ca3e-45c2-a68d-50202437d98d	t	2026-07-22 18:03:59.550799+00
8c5242ea-0582-4bed-86f1-39658b43048a	Noémie	SAMYCHETTY	nsamychetty@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	nsamychetty@elyade.com	62b63cb1-0b33-455a-99d2-d23d639d745a	t	2026-07-22 18:03:59.550799+00
60dd1daa-9636-4017-8182-74bc53fb122d	Nathalie	SOLANES	nsolanes@elyade.com	\N	\N	\N	\N	Chargée de livraison	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	nsolanes@elyade.com	4b0b1fd2-91e0-470a-bf70-54171eb718f9	t	2026-07-22 18:03:59.550799+00
9f7a3bfa-189c-4f4d-8c45-0bfcddf19456	Nathan	WILSON	nwilson@elyade.com	\N	\N	\N	\N	Conseillier de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	nwilson@elyade.com	d2abbc63-98bf-4944-8a71-c7b0c535e182	f	2026-07-22 18:03:59.550799+00
4b1abe45-669a-4c9f-bb9e-eecbda56240d	Ophélie	DELCUSE	odelcuse@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriétés	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	odelcuse@elyade.com	9b88716c-6ee2-4e77-be7e-3aa44e1a51d8	t	2026-07-22 18:03:59.550799+00
101b53e9-b554-478a-9e95-3a2c2d44c9f1	Olivier	LESTARPE	olestarpe@elyade.com	\N	\N	\N	\N	Directeur.trice comptable	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	olestarpe@elyade.com	4562fd77-319a-4a5b-80a3-27ffde6d9fb0	t	2026-07-22 18:03:59.550799+00
ac93458f-7a43-45a1-b163-67f5769e55f8	Océane	ORQUIN	oorquin@elyade.com	\N	\N	\N	\N	Chargée montage immobilier neuf	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	oorquin@elyade.com	3730a885-977f-45b3-8a45-11d6f48dc434	t	2026-07-22 18:03:59.550799+00
9940abdc-e864-4c64-85bf-83ec644b3809	Olivia	ROUSSILLE	oroussille@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriété	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	oroussille@elyade.com	3f44fb87-eaf4-431e-8230-3da3bbfb1f54	t	2026-07-22 18:03:59.550799+00
40163fa3-b4bb-497a-874c-d72682ffc535	Paul	MIANE	pmiane@elyade.com	\N	\N	\N	\N	Assistant comptabilité et contrôle de gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	pmiane@elyade.com	8c0010c1-ef41-48cd-8c2d-c35ad0548672	t	2026-07-22 18:03:59.550799+00
304ad137-6619-4dde-8e30-d2533d7ad1c7	Paul	NEGRE-JUNYENT	pnegre-junyent@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	pnegrejunyent@elyade.com	0c85d3f5-6d8a-4979-bf2f-137f2973faf1	t	2026-07-22 18:03:59.550799+00
3bcfd263-0757-4744-b255-2e215cf24699	Pole	Sinistre	polesinistre@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	polesinistre@elyade.com	d2154569-9348-40b6-b846-1f42a92f3cca	f	2026-07-22 18:03:59.550799+00
a4789fce-a568-4646-81c2-b75360aaa0cf	Print		Print@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Print@teamselyade.onmicrosoft.com	022f8003-be31-4976-a5f6-02145acff8dd	t	2026-07-22 18:03:59.550799+00
5aeb030d-1a20-4162-b6ec-0912ea44547e	Paul	SEN	psen@elyade.com	\N	\N	\N	\N	Comptable syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	psen@elyade.com	57b10c8f-9416-499d-be3a-ac127f660507	t	2026-07-22 18:03:59.550799+00
000945e1-51d6-45d4-bdf2-91a65126cfc9	Quentin	MOLINIER	qmolinier@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	qmolinier@elyade.com	9f65288e-a68a-4fd6-9065-deb2ee17a630	t	2026-07-22 18:03:59.550799+00
104e4cb6-7184-449b-a716-3c5783de7623	Support	Qualite	qualite@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	qualite@elyade.com	57f9d1a2-3d5f-495b-86f3-0ad0b18632be	t	2026-07-22 18:03:59.550799+00
da8e62e6-c132-49ed-9441-03201f5ab0e8	r740r128		r740r128@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	r740r128@elyade.com	2d334800-3c7a-477a-bccd-769d492ab2b8	f	2026-07-22 18:03:59.550799+00
9502cd7f-f7d4-4e80-8843-e3fc637ace14	Raphael	ABEILLE	rabeille@elyade.com	\N	\N	\N	\N	Attaché.e clientèle gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	rabeille@elyade.com	4b3fcaea-cd81-44b6-942d-625f122d4e36	t	2026-07-22 18:03:59.550799+00
8a3cae01-f152-423d-9a56-31a4fbcda459	Rémi	BIONDO	rbiondo@elyade.com	\N	\N	\N	\N	Assistant administratif et comptable	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	rbiondo@elyade.com	f3c858d2-5071-40d2-8da0-1d5e4a3e6619	t	2026-07-22 18:03:59.550799+00
b392a972-6e22-4f58-9d72-b1ffca625444	RC	Gestion AAO	RCgestionAAO@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	RCgestionAAO@elyade.com	bf4055f0-368a-4f25-a6a4-e0e40e8a3006	f	2026-07-22 18:03:59.550799+00
796e6a0d-5764-487f-854c-0f3bf461e341	RC	Gestion JJN	RCgestionJJN@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	RCgestionJJN@elyade.com	86d67d70-5c9d-4187-9aee-736bce754368	t	2026-07-22 18:03:59.550799+00
38236eb7-dc2a-4094-ad41-233a09b62bf1	RC	Gestion LBA	RCgestionLBA@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	RCgestionLBA@elyade.com	29e7902a-bdb4-429d-95ea-f9bc0083975d	f	2026-07-22 18:03:59.550799+00
53ee4db0-8140-4844-95a1-8cfacee27590	RC	Gestion LVX	RCgestionLVX@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	RCgestionLVX@elyade.com	92e7cb1a-8454-4ffe-8aad-af7fd3ee9345	t	2026-07-22 18:03:59.550799+00
15c8b5ac-cdd6-4005-885c-22fcd9394d02	RC	Gestion RESP	RCgestionRESP@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	RCgestionRESP@elyade.com	2aedf7ad-32a7-4583-8b99-862fec9876c5	f	2026-07-22 18:03:59.550799+00
51010d4d-980b-46b6-888c-ff2b02eca86d	Rachel	CONSTANS	rconstans@elyade.com	\N	\N	\N	\N	Responsable Pôle neuf Syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	rconstans@elyade.com	541a1a18-433d-4706-9c9b-70cf91bb3abb	t	2026-07-22 18:03:59.550799+00
82f95c7e-e98f-4047-a95c-5108f8aab567	RDV	CONTROLE DE RESERVES	RDVCONTROLEDERESERVES@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	RDVCONTROLEDERESERVES@elyade.com	82f3c85b-c293-4da4-bed6-ebe894a4dc95	t	2026-07-22 18:03:59.550799+00
593a27a0-063b-4a13-b44e-a94de7ba0205	rdv	qualifiés	rdvqualifies@teamtoleadly.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	rdvqualifies@teamtoleadly.com	b948bfbe-ab20-4e53-88b7-4e8501ccadf9	t	2026-07-22 18:03:59.550799+00
a7296f5b-4685-4cd9-8226-13abbc080581	reclamations		reclamations@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	reclamations@elyade.com	a7830a39-705e-4cb8-9d68-fc3aaf799069	t	2026-07-22 18:03:59.550799+00
2c1fc639-376e-44af-9409-a6657889a169	Relation	Conseiller	relationconseiller@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	relationconseiller@elyade.com	2139fa5f-7ded-44b3-8194-dc0716a38943	t	2026-07-22 18:03:59.550799+00
8b0a92b1-a168-4e6d-b61b-bd6672e30026	Relation	conseiller	Relationconseiller1@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Relationconseiller1@elyade.com	cfbd73c8-2efb-4e44-a16b-23a38ce5ab0f	t	2026-07-22 18:03:59.550799+00
a629e423-8cf9-4398-8eb7-294f665de031	Relations	Fournisseurs	relationsfournisseurs@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	relationsfournisseurs@elyade.com	6a8f9ded-9893-411c-a84e-1b5adfb8c820	t	2026-07-22 18:03:59.550799+00
3b02eb93-37b0-413d-be7e-3069d0d6ac8b	Retour	Bail	retourbail@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	retourbail@elyade.com	3ba134d2-43a8-49e3-b402-8915d355046d	f	2026-07-22 18:03:59.550799+00
7a0824ae-2296-44d5-8e32-669745de4c12	Romain	HEDJAL	rhedjal@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriété	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	rhedjal@elyade.com	fc0890e9-459f-4427-86f6-1681e72dd204	t	2026-07-22 18:03:59.550799+00
a8f1d966-970f-4526-8e93-523ecafd6c48	Rose-Marie	DANDRAU	rmdandrau@elyade.com	\N	\N	\N	\N	Superviseur administratif et comptable gérance	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	rmdandrau@elyade.com	5e58188a-9d7a-446d-95b9-09282b5b875d	f	2026-07-22 18:03:59.550799+00
155f99b4-ddc3-411d-8757-f251ae51d815	ROUSSILLE-BOUCAYS	Olivia	ROUSSILLEBOUCAYSOlivia@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ROUSSILLEBOUCAYSOlivia@elyade.com	9981877e-a257-4e5b-8412-eac5acae1804	t	2026-07-22 18:03:59.550799+00
5e1d6ebd-7745-450c-bbc1-7b4d44af24c2	Romane	POUJADE	rpoujade@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	rpoujade@elyade.com	900e8c6d-05c0-49be-bb4d-62c16ebcac82	f	2026-07-22 18:03:59.550799+00
6a9efc5f-0e7b-4eb8-bb35-480567ff175f	Résidence	Equinoxe	RsidenceEquinox@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	RsidenceEquinox@elyade.com	c757b7de-6724-49f4-bc77-2c922b97d1d1	t	2026-07-22 18:03:59.550799+00
6961bee7-3b72-4871-bd39-5bbc58e09615	Sonia	ABBA	sabba@elyade.com	\N	\N	\N	\N	gestionnaire sinistre	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	sabba@elyade.com	316a0083-0d88-434a-ade7-17855eeabb63	f	2026-07-22 18:03:59.550799+00
f5509f28-5d95-4659-9d72-e61ac963e824	Séverine	AMIEL	samiel@elyade.com	\N	\N	\N	\N	Responsable assistant.es Syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	samiel@elyade.com	2f7cd205-89c6-4613-bab2-9357f3fc8ea7	t	2026-07-22 18:03:59.550799+00
fed7ae60-6b89-49c2-b2eb-a472b1789ca0	Sandra	BERMOND	sbermond@elyade.com	\N	\N	\N	\N	Chargée montage immobilier neuf	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	sbermond@elyade.com	57b404eb-d62b-41a3-adbb-fdcca28f95b7	t	2026-07-22 18:03:59.550799+00
27887fe1-ff59-406c-aac4-120ef66e1f05	SBSMonAcct		SBSMonAcct@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	SBSMonAcct@teamselyade.onmicrosoft.com	55f2a130-d943-4b1a-909c-1c2632770624	f	2026-07-22 18:03:59.550799+00
553a73d3-854d-4f2d-ae5a-64abbe1afa2f	scanner	scanner	scanner@elyade.com	\N	\N	\N	\N	Scanner	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	scanner@elyade.com	5955ad35-8443-42b4-85ce-74be16e0a775	t	2026-07-22 18:03:59.550799+00
d2d8d59b-d86d-4485-bd98-3086eda03728	Stephane	COULON	scoulon@elyade.com	\N	\N	\N	\N	Responsable de site / Responsable copropriétés Aquitaine	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	scoulon@elyade.com	76077c6a-7d4a-41c4-98a7-596d3fef63c2	t	2026-07-22 18:03:59.550799+00
eebd0b93-b853-4497-81c3-417686db6d6b	Sylvain	DUTRELOT	sdutrelot@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriété junior	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	sdutrelot@elyade.com	ad7cffe7-e6de-445e-ad67-f1cb0360ded3	t	2026-07-22 18:03:59.550799+00
17b27cd2-575d-4d51-b91c-00c52aa7d060	Sofiane	EL AMRI	selamri@elyade.com	\N	\N	\N	\N	Success manager	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	selamri@elyade.com	9e1da9f8-da37-4d44-b424-ed00325a6900	t	2026-07-22 18:03:59.550799+00
35a66425-2cdf-4836-bee0-cd76ed021f48	Selection	Logements Anciens	selection.logementsanciens@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	selection.logementsanciens@elyade.com	b1b97124-1ea0-4817-92c9-c420c08c7304	f	2026-07-22 18:03:59.550799+00
61286d58-d9e8-43e5-8e21-3579c4016523	Selection	Logements Neufs	selection.logementsneufs@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	selection.logementsneufs@elyade.com	321fd810-ce66-402e-b0e5-da2f71d8f4de	f	2026-07-22 18:03:59.550799+00
1edd8fa5-fcc3-49de-8183-eeb1954f7bd6	service-projet		service-projet@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	service-projet@elyade.com	3194f135-2fa9-4ed6-b10c-8f79712e0b25	f	2026-07-22 18:03:59.550799+00
fb3de6cb-e8b6-49e7-be3f-c29bef189bbd	Service_Syndic		Service_Syndic@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Service_Syndic@elyade.com	c6b10bc8-d0d6-4b48-9984-2c851cf522f1	f	2026-07-22 18:03:59.550799+00
b879539a-de37-4fc7-9151-0c5566faad30	Sabrina	GAYRAUD	sgayraud@elyade.com	\N	\N	\N	\N	Comptable gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	sgayraud@elyade.com	5cd3d3d7-1a8f-4103-bc14-e2ce7cdcc985	t	2026-07-22 18:03:59.550799+00
41bc86f4-b749-436e-b2d4-6acc57903fcd	Soumia	GRASSAUD	sgrassaud@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	sgrassaud@elyade.com	f57e8221-f3f5-4e2c-b550-607f1fb6436f	t	2026-07-22 18:03:59.550799+00
4efac293-84a5-40b1-b82e-044ef50720ee	Sonia	HESNARD COURET	shesnard-couret@elyade.com	\N	\N	\N	\N	Chargée relations partenaires	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	shesnard@elyade.com	89e07109-857d-48e7-9dfd-eb4f5a3fb3b8	t	2026-07-22 18:03:59.550799+00
d599617a-9ad6-4407-bf89-40ff581f9e06	Suheda	LEKESIZ	slekesiz@elyade.com	\N	\N	\N	\N	Hôtesse d'accueil / Standardiste	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	slekesiz@elyade.com	dccca8e9-dd39-41c8-874d-bd2f6ac25428	t	2026-07-22 18:03:59.550799+00
d76138d8-2d01-45a2-a025-bde2ea8f3819	Samia	MAHJOUB	smahjoub@elyade.com	\N	\N	\N	\N	Success manager	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	smahjoub@elyade.com	d7e65417-8dbd-43eb-92a1-798183667a01	t	2026-07-22 18:03:59.550799+00
ac51fd68-5eaa-4066-b39e-88a5a6b3034d	Stéphane	NAKACHE	snakache@elyade.com	\N	\N	\N	\N	Directeur général	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	snakache@elyade.com	9fe2de19-1102-497f-af5a-ef5de4a45516	t	2026-07-22 18:03:59.550799+00
0d46e2d5-243e-4c8d-8267-11a8bd84a46a	sophos	sophos	sophos@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	sophos@teamselyade.onmicrosoft.com	c744f080-3ae4-4513-b7ab-50778cebcf4c	t	2026-07-22 18:03:59.550799+00
92225a85-e142-40fa-aaef-c30329e879c5	SophosPureMessage		SophosPureMessage@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	SophosPureMessage@teamselyade.onmicrosoft.com	d67f1be0-1b43-486d-afdf-2fee3ca500ce	f	2026-07-22 18:03:59.550799+00
d285fb75-5788-4701-ace3-14e15a052e46	Sylvie	CASSAGNE	scassagne@elyade.com	\N	\N	\N	\N	Directrice Transaction France	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	spolicand@elyade.com	1fa60613-73fc-4f1b-9023-22ee07a88d1c	f	2026-07-22 18:03:59.550799+00
9b58f99e-1706-40f6-bcc1-d9b65223d834	Sarah	RODRIGUEZ	srodriguez@elyade.com	\N	\N	\N	\N	Superviseur Comptable	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	srodriguez@elyade.com	0cb05112-6e96-4f90-b4d5-22f3f048fc73	f	2026-07-22 18:03:59.550799+00
0d928b24-8ab0-4219-a53d-c5418e64a43d	sso		sso@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	sso@teamselyade.onmicrosoft.com	7bfa625d-ceb2-4155-bcba-dce7467d3b8d	t	2026-07-22 18:03:59.550799+00
26b2c2b5-b6fe-4201-a854-3c872a98b6ec	Stéphane	NAKACHE (com2023)	Stephane.nakache@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Stephane.nakache@elyade.com	0f01f4af-a2c3-4097-a731-9957f5d4e7c7	t	2026-07-22 18:03:59.550799+00
0b0b9e6e-7a8f-48a5-a80b-0aac21d13158	Sana	TOUMI	stoumi@elyade.com	\N	\N	\N	\N	Attachée commerciale	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	stoumi@elyade.com	a8c74833-52b6-4806-914f-b5dbcf3dc3a5	t	2026-07-22 18:03:59.550799+00
e13d015c-568c-4a72-be1a-c456d1ef7ab4	Support	Applications	support-applications@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	support-applications@elyade.com	a52e75b5-4cf7-453b-9a8b-392f01a4dd69	t	2026-07-22 18:03:59.550799+00
f2343456-e576-4609-9559-57a253116438	Support		support@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	support@elyade.com	b7bc8fc9-f97d-4beb-8367-7ed0561a6a37	t	2026-07-22 18:03:59.550799+00
ad113ac8-2812-4641-9910-8fbb2488920d	surveyvisio		surveyvisio@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	surveyvisio@elyade.com	382dfeee-b0ba-485d-a62d-ba5cea13fb70	t	2026-07-22 18:03:59.550799+00
9ee12755-95e0-4443-bcb3-b1587457b19a	On-Premises	Directory Synchronization Service Account	Sync_SRVADSYNCH01_88a0a54a5863@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Sync_SRVADSYNCH01_88a0a54a5863@teamselyade.onmicrosoft.com	34f13226-45d2-4cca-b71d-bbffefba200e	t	2026-07-22 18:03:59.550799+00
4e13f1e1-ab7b-496a-acc5-cd5e70f21792	Synchro	GLPI	syncGLPI@teamselyade.onmicrosoft.com	\N	\N	\N	\N	Synchro Users avec GLPI	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	syncGLPI@teamselyade.onmicrosoft.com	6787af31-5877-4a1a-9a40-efe66cdd9116	t	2026-07-22 18:03:59.550799+00
84dafc04-aebc-4b5f-bf51-2182e24b4a29	[Compte	de service] Synchro AD	synchroad.serviceacc@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	synchroad.serviceacc@teamselyade.onmicrosoft.com	c5178ebf-49e0-4b1b-a93f-4445bddb6e98	t	2026-07-22 18:03:59.550799+00
875ba57f-ca27-469e-a4b3-a0248aac71bd	_Taxes	Foncières 2025	taxesfoncieres2025@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	taxesfonciere2025@elyade.com	fa5293be-35c3-4f8b-8ac2-00f1bb8e892c	f	2026-07-22 18:03:59.550799+00
316d4fd8-5e77-4b3f-b3a7-b2d2bbb47539	Taxes	Foncieres	taxesfoncieres@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	taxesfoncieres@elyade.com	9be3927d-65b5-4111-9723-8488b24e4901	f	2026-07-22 18:03:59.550799+00
62d06322-8057-4756-9750-fb595d22f5e8	Thomas	DIDRICHE	tdidriche@elyade.com	\N	\N	\N	\N	Responsable des Systèmes d'Information	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	tdidriche@elyade.com	e862925b-6e2b-465a-a7e9-699a26ea0d27	t	2026-07-22 18:03:59.550799+00
06c1cad4-cf8c-48a3-a98b-29eee9a56828	Admin	Teams	teams@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	teams@elyade.com	4ca4f7cd-bf64-489a-8fc5-4de41f904751	t	2026-07-22 18:03:59.550799+00
a5a6872a-ebe1-4401-9e04-036f29764adf	Thomas	FILLETTE	tfillette@elyade.com	\N	\N	\N	\N	Technicien informatique support et exploitation	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	tfillette@elyade.com	8d230bd7-b36a-4c12-bf5d-35dcec959ce8	t	2026-07-22 18:03:59.550799+00
b057d075-1301-4c23-9f35-6909da0a4e82	Tolve	Marie	TolveMarie@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	TolveMarie@elyade.com	6fe6e22d-3528-4c07-91cf-45a11c892ced	t	2026-07-22 18:03:59.550799+00
a0c0e609-3488-482f-b518-cf726119cd3d	Thibault	PIAZZOLI	tpiazzoli@elyade.com	\N	\N	\N	\N	Comptable syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	tpiazzoli@elyade.com	baec5c70-e5ee-4a39-8af7-8fc1d4c19c25	t	2026-07-22 18:03:59.550799+00
ebf984fc-0393-4b15-91d4-34f6fe1974d8	transaction		transaction@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	transaction@elyade.com	9a098fe2-94cb-4ad2-9f24-9bd33b2af87f	t	2026-07-22 18:03:59.550799+00
77585bd0-85b2-4a34-99e1-5c966ac09a3d	Travaux		Travaux@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Travaux@elyade.com	69286d37-7c30-41df-94a9-2df60badaa11	t	2026-07-22 18:03:59.550799+00
4b274cd8-4dc7-455c-93aa-1a603dc9051d	Compte Urgence	1	Urgence1@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Urgence1@teamselyade.onmicrosoft.com	c16d1468-43a6-4b13-b56e-67542b1a7351	t	2026-07-22 18:03:59.550799+00
04c017aa-66e4-4d34-a1af-634088e37b9d	Ugo	THIEBAUT	uthiebaut@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriété Grand Ouest	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	uthiebaut@elyade.com	0db0b652-7bec-4dbd-b1d5-6e640cfda6d9	t	2026-07-22 18:03:59.550799+00
0f5fb7e3-7049-419f-a2c8-3033cba63816	Utilisateur	standard	Utilisateur_std@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	Utilisateur_std@teamselyade.onmicrosoft.com	69a5823a-3319-4e0d-8205-8a06a510b6b6	f	2026-07-22 18:03:59.550799+00
362cc88a-d2fb-4d96-99bd-07e07a83d7b8	Valentin	MARAVAL	ValentinMARAVAL@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ValentinMARAVAL@elyade.com	cb62d5a7-8370-49c0-9cfc-03fc6f9e6663	t	2026-07-22 18:03:59.550799+00
379cccaa-e70b-4dd8-a6af-b8002a72c0cf	Volha	BLONDEAU	vblondeau@elyade.com	\N	\N	\N	\N	Comptable gérance	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	vblondeau@elyade.com	e524a8e8-f525-4f9c-a987-b98820e9a3c4	t	2026-07-22 18:03:59.550799+00
27fd1784-c0c8-4669-bba2-19a68cba8a26	Vanessa	BOUCHAREYSSAS	vbouchareyssas@elyade.com	\N	\N	\N	\N	Attachée commerciale	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	vbouchareyssas@elyade.com	f362ff54-ab15-4919-9d7d-c9a028a7359e	t	2026-07-22 18:03:59.550799+00
175c2958-e560-498c-aca9-c161ca123d3c	⚙️	Véhicules de Service	vehicule@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	vehicule@elyade.com	553e00d3-faf9-483d-b84e-1dfc55673147	t	2026-07-22 18:03:59.550799+00
af477549-4032-4bc5-a340-ef63921d1a65	Victor	TRILHA	vi.trilha@elyade.com	\N	\N	\N	\N	Attaché commercial	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	vi.trilha@elyade.com	5d085184-916d-4d3d-9c98-6c7c27ddaf61	t	2026-07-22 18:03:59.550799+00
c7e3300a-fe49-4b28-aafe-c2402982831b	Virginie	ICART	vicart@elyade.com	\N	\N	\N	\N	Comptable syndic	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	vicart@elyade.com	dc44d8bc-55c5-4494-96d3-0fb796679222	t	2026-07-22 18:03:59.550799+00
606123e6-5b6b-4de1-bd3e-ce91eb4a9ecc	visale@elyade.com		visale@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	visale@elyade.com	6e5ad675-9ec9-488f-8598-2c2abb4725e3	f	2026-07-22 18:03:59.550799+00
32fda97f-4cf9-485a-82be-e93ef5070597	Vaitea	LEGENS	vlegens@elyade.com	\N	\N	\N	\N	Conseillère de Gestion	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	vlegens@elyade.com	0857af0d-f74b-40cb-b4b3-b43e0b34b276	f	2026-07-22 18:03:59.550799+00
cdbd094b-2737-408d-8a1b-84d04221564e	Valentin	MARAVAL	vmaraval@elyade.com	\N	\N	\N	\N	Gestionnaire technique immobilier neuf	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	vmaraval@elyade.com	ad3197e6-afcc-4ac3-a051-10000df15279	t	2026-07-22 18:03:59.550799+00
7a0c6e20-cc0e-4d27-9e4e-46ef784836fe	Volodia	MINIEJEW	vminiejew@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriété junior	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	vminiejew@elyade.com	25eac7fe-26c9-41df-9983-55b4f28c328c	t	2026-07-22 18:03:59.550799+00
675b9e2b-f58e-44b9-aac2-21338a0601f2	votesagBayonne		votesag.agencebayonne@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	votesag.agencebayonne@elyade.com	472e4371-8325-4eeb-b801-8836c3c8c861	t	2026-07-22 18:03:59.550799+00
ef1cd83b-2fd4-4e14-a3ba-f2fa2526f09f	votesagBordeaux		votesag.agencebordeaux@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	votesag.agencebordeaux@elyade.com	4acfbfde-2c6b-45d1-8a14-b9c94bdad95a	t	2026-07-22 18:03:59.550799+00
a7475b9f-15c7-46c0-ae6f-e9e755d6cb1a	votesagMontpellier		votesag.agencemontpellier@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	votesag.agencemontpellier@elyade.com	8ba22081-947f-41bd-9039-e8dd86e2ee3d	t	2026-07-22 18:03:59.550799+00
1abcfa7c-719f-4e97-b723-9adafc59c307	votesagToulouse		votesag.agencetoulouse@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	votesag.agencetoulouse@elyade.com	5db38c6b-f592-4c44-990d-70946c30a2ce	t	2026-07-22 18:03:59.550799+00
168dfea6-da52-4168-a06d-5c052f2909d1	Web	Developpement	web-developpement@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	web-developpement@elyade.com	13e31d3f-eb72-4c4b-9011-2170a147393d	f	2026-07-22 18:03:59.550799+00
d83b4097-04d1-42f0-8087-bb9daa7289c4	Web	Estimation Transac	web-estimation-transac@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	web-estimation-transac@elyade.com	26bac7f5-48ca-4ce0-8432-9da667a21d06	f	2026-07-22 18:03:59.550799+00
4d3908ce-bb18-49e2-81db-b7dd309517a4	Web	fournisseurs	web-fournisseurs@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	web-fournisseurs@elyade.com	ce81f4f9-95ed-4522-80a8-673cb2712f29	f	2026-07-22 18:03:59.550799+00
ad98fba4-2147-4e2d-85af-abdc5e6017af	Web	Parrainage	web-parrainage@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	web-parrainage@elyade.com	83d2c62a-6677-49de-bbdb-df272c2a5941	f	2026-07-22 18:03:59.550799+00
4ddfde55-6c7b-4e6d-9887-289d7e6621e4	Web	Patrimoine	web-patrimoine@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	web-patrimoine@elyade.com	80e44be7-de28-4f7c-9055-26ee08f86470	f	2026-07-22 18:03:59.550799+00
b96c16b3-d7dc-4887-83bc-6e9c3adc5512	web-service-client		web-service-client@elyade.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	web-service-client@teamselyade.onmicrosoft.com	c35f780d-aa2b-4998-acb2-5746ce1f89c0	t	2026-07-22 18:03:59.550799+00
f87ea3bb-8beb-4bdd-a0dd-04ad8b074541	Web	Syndic	web-syndic@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	web-syndic@elyade.com	fc4fe7cf-f07f-4fb1-b41f-6317b4e55b25	f	2026-07-22 18:03:59.550799+00
df27b314-7f6d-47f6-ab7a-7dd44e204d7b	Web	Transaction	web-transaction@elyade.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	web-transaction@elyade.com	6453db7d-44ad-4224-a8f2-a22bcee28987	f	2026-07-22 18:03:59.550799+00
4f555fde-08dd-4d45-8cce-503dc93530d4	Utilisateur	standard avec liens d'administration	WebWorkplaceTools@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	WebWorkplaceTools@teamselyade.onmicrosoft.com	def341dc-6ff7-4291-becc-7ed54f9ec9ec	f	2026-07-22 18:03:59.550799+00
cb9ac39b-040a-4e38-bb2b-4bc99e8f68ec	Xefi		xefi@teamselyade.onmicrosoft.com	\N	\N	\N	\N	\N	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	xefi@teamselyade.onmicrosoft.com	463921b4-7b0d-4ecb-ae04-15aa4b9aa35e	t	2026-07-22 18:03:59.550799+00
9827c486-176e-4c49-bbbf-42d538c778f6	Yannis	DELMAS	ydelmas@elyade.com	\N	\N	\N	\N	Gestionnaire clientèle copropriétés	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ydelmas@elyade.com	e3cafe37-ff96-4ff2-af58-b766190b7c3b	t	2026-07-22 18:03:59.550799+00
96299e2e-e7d0-402c-a3e6-665298949a39	Yosra	LAJILI	ylajili@elyade.com	\N	\N	\N	\N	Assistante Syndic	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	ylajili@elyade.com	ec07695d-dcdd-4b56-bbf6-b1ef0b91c565	f	2026-07-22 18:03:59.550799+00
56cec5e0-aee5-4f42-b08c-02c0f743453a	Ylan	VINCENT-DAGOBERT	yvincent-dagobert@elyade.com	\N	\N	\N	\N	Business developer	t	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	yvincent-dagobert@elyade.com	9859bea2-a8a8-44f9-95f3-1e880ed33b84	t	2026-07-22 18:03:59.550799+00
8802d233-66c3-43a4-9f4d-d92756e501bf	Zina	FERGUI	zfergui@elyade.com	\N	\N	\N	\N	Superviseur administratif et comptable gérance	f	2026-07-22 18:03:59.550799+00	2026-07-22 18:03:59.550799+00	zfergui@elyade.com	73886bd9-0524-4ca7-af97-df8153bc461d	f	2026-07-22 18:03:59.550799+00
cdcdb6aa-634c-43d8-a053-35f9c6285ea8	test	test	\N	\N	\N	\N	Thomas DIDRICHE	test	t	2026-07-29 16:13:09.253461+00	2026-07-29 16:13:09.253461+00	\N	\N	\N	\N
6691355d-ea0c-4b91-9ee8-8101697e3f05	maurice	Poisson	\N	\N	\N	\N	Thomas DIDRICHE	kjghkljh	t	2026-07-29 16:16:07.001416+00	2026-07-29 16:16:07.001416+00	\N	\N	\N	\N
a4e879e2-7e22-45f3-a75f-bc00d652198e	srghfj	dehwxrjkv	\N	\N	\N	\N	Thomas DIDRICHE	wsdxftgjyuh	t	2026-07-30 06:58:20.679863+00	2026-07-30 06:58:20.679863+00	\N	\N	\N	\N
a760e3d2-88e4-4884-8d19-1889a862c1c4	qsgs<g	svg<s<s	\N	\N	\N	\N	Thomas DIDRICHE	svgfs<vgf	t	2026-07-30 07:06:13.03858+00	2026-07-30 07:06:13.03858+00	\N	\N	\N	\N
bcb23b56-60f9-4e6e-8b5d-ca2b7acf3378	test	test	\N	\N	\N	\N	Thomas DIDRICHE	test	t	2026-07-30 10:15:04.046137+00	2026-07-30 10:15:04.046137+00	\N	\N	\N	\N
2f1fd062-8860-4869-aeda-8f671935c0ea	jean	Michel	\N	\N	\N	\N	Thomas DIDRICHE	à peut près	t	2026-07-30 12:35:32.903509+00	2026-07-30 12:35:32.903509+00	\N	\N	\N	\N
3a434a21-51f1-4086-803e-1a3bb61a8558	dfjlhjhjlklmkhlhljkkhkl	mlkhjlmjkhlmhlmkjlmkhjlmkh	\N	\N	\N	\N	Thomas DIDRICHE	lkhmlhkmlhmlhlmhmlh	t	2026-07-30 12:43:32.668054+00	2026-07-30 12:43:32.668054+00	\N	\N	\N	\N
0a8657cc-4819-48d1-a11e-b840e7d91ced	Jean	AIMARE	\N	\N	\N	\N	Thomas DIDRICHE	Syndicaliste	t	2026-07-30 13:08:41.546011+00	2026-07-30 13:08:41.546011+00	\N	\N	\N	\N
db3c5e00-b3d0-4667-ad5e-aed47b6e7129	Michel	Drucker	\N	\N	\N	\N	Thomas DIDRICHE	Présentateur TV	t	2026-07-30 13:39:15.823801+00	2026-07-30 13:39:15.823801+00	\N	\N	\N	\N
3d7eb1dc-873f-45d1-a26f-51e7d1f0e7a1	Maurice	POISSON	\N	\N	\N	\N	Thomas DIDRICHE	Mangeur de danette chocolat	t	2026-07-30 14:42:01.254566+00	2026-07-30 14:42:01.254566+00	\N	\N	\N	\N
ab288e7b-6393-4315-8b09-26410514fb7a	Jean	Bonbeurre	\N	\N	\N	\N	Thomas DIDRICHE	Sandwicheur	t	2026-07-30 15:59:44.257566+00	2026-07-30 15:59:44.257566+00	\N	\N	\N	\N
70a0cc86-c612-486c-a100-74001a9ff631	Alain	Prost	\N	\N	\N	\N	Thomas DIDRICHE	Chauffeur	t	2026-07-31 14:01:15.675655+00	2026-07-31 14:01:15.675655+00	\N	\N	\N	\N
e3258fea-12a4-477e-aec1-afb092a94e9d	Turlututu	chapeau pointu	\N	\N	\N	\N	Thomas DIDRICHE	\N	t	2026-07-31 14:16:26.467844+00	2026-07-31 14:16:26.467844+00	\N	\N	\N	\N
18a1512b-eab8-4594-99fb-9b254688c6c6	Youpi	Houra	\N	\N	\N	\N	Thomas DIDRICHE	\N	t	2026-07-31 14:24:36.940674+00	2026-07-31 14:24:36.940674+00	\N	\N	\N	\N
543e1412-60f4-4182-bac8-1aaab1417197	Airton	SENA	\N	\N	\N	\N	Thomas DIDRICHE	Chauffeur	t	2026-07-31 14:29:28.712363+00	2026-07-31 14:29:28.712363+00	\N	\N	\N	\N
c7c5fec0-367f-41d1-a08a-5a293558072e	Flash	McQueen	\N	\N	\N	\N	Thomas DIDRICHE	Pilote	t	2026-07-31 14:38:35.523272+00	2026-07-31 14:38:35.523272+00	\N	\N	\N	\N
31a1c6f6-61f8-40ea-8377-abc57055d253	Martin	Mister	\N	\N	\N	\N	Thomas DIDRICHE	Enqueteur	t	2026-07-31 14:58:17.840371+00	2026-07-31 14:58:17.840371+00	\N	\N	\N	\N
90e0b1f7-bd5c-422a-9ff2-a2f6776be765	Franklin	Tortue	\N	\N	\N	\N	Thomas DIDRICHE	\N	t	2026-07-31 15:22:58.006993+00	2026-07-31 15:22:58.006993+00	\N	\N	\N	\N
\.


--
-- Data for Name: hardware_assignments; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.hardware_assignments (id, hardware_item_id, employee_id, group_name, assigned_at, returned_at) FROM stdin;
\.


--
-- Data for Name: hardware_categories; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.hardware_categories (id, code, label, tracked_for_person, managed_by, sort_order, requestable_for_onboarding) FROM stdin;
ecbb7592-3ba0-4bbc-9205-a67aaf32f902	KEYBOARD	Clavier	f	\N	8	f
64331598-f9a2-4bac-9535-edf99b11945a	MOUSE	Souris	f	\N	9	f
3ab36349-b101-4fe4-9cd2-33f5ee8270a0	PC	PC portable	t	Intune	1	t
591e509f-b8f4-4b8c-ae1c-174b8f513139	PHONE	Téléphone	t	Intune	2	t
0202aa13-5afb-42a4-9ca2-9c09967c79bb	HEADSET	Casque	t	\N	3	t
9b8de84b-c049-47f2-b0f0-414f33d68b90	TABLET	Tablette	t	Intune	4	t
de5d066d-4c5a-4eab-861e-9bb5eca739bf	SIGNATURE_PAD	Pad de signature	t	\N	6	t
36706406-92f9-4f4b-bd43-91097152cc1a	SPEAKER	Enceinte	t	\N	5	t
3981e88a-85b7-4a12-9342-dca750713f52	SCREEN	Écran	f	\N	7	f
d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	DESKTOP	PC fixe	t	\N	0	f
bb95ff6b-0e80-45e2-9407-369056d35357	CONVERTIBLE	Convertible	t	\N	0	f
1f38f1dd-bed2-457e-9e48-79a86c6bc8af	KEYBOARD_MOUSE	Clavier/Souris	t	\N	0	f
ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	PHONE_LINE	Ligne téléphonique	t	\N	0	f
65314b61-d114-4281-8df3-9b63ef981da3	DOCK	Station d'accueil	t	\N	0	f
56d8fb3e-65f9-4bee-8c50-69cc4de9d3ec	CAMERA	Caméra	t	\N	0	f
c620d117-4e2a-40a7-88a6-59356c8a7522	VMWARE	VMware	t	\N	0	f
\.


--
-- Data for Name: hardware_groups; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.hardware_groups (id, name) FROM stdin;
257103d3-b643-4f84-97d3-c1b2c470ac7d	Pôle Gestion
8e2a645f-ed43-4ee0-8b46-ebc848d28e0d	Pôle Syndic
365fb873-87e6-43b7-a8a7-ce457cd1e87d	Comptabilité
f4e69fd9-6ae1-42b3-8472-ee3a57e52b35	Service Informatique
8f50d504-e3c6-48d2-a6d9-1dd5e1a7d0cd	Direction
b3dd1cb9-0f0e-45a0-8a01-b90bc192b365	Accueil
\.


--
-- Data for Name: hardware_items; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.hardware_items (id, category_id, reference, serial_number, brand, model, status, intune_device_id, atera_ticket_id, purchase_date, notes, created_at, updated_at, title, os_id, processor_id, memory_id, size_id, hdmi, displayport, invoice_number, purchase_value, supplier_id, budget_id, warranty_expiration_date, asset_number, usbc) FROM stdin;
504cd49c-5767-441c-85fc-b7e6f44752f2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440WM	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:51.562143+00	2026-08-27 13:52:51.571121+00	PORT2306-1440WM	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
bb2c445f-6918-4ca0-a2d4-7d914a5e5741	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009128	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	PORT1808-009128\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.574511+00	2026-08-27 13:52:51.574511+00	PCLCLSC	\N	\N	\N	\N	f	f	F1808163-03676	870.00	\N	\N	2021-03-08	ESI0067	f
83de2b8f-24ce-4bab-973d-354fddb50d24	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009996	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009996	2026-08-27 13:52:51.577657+00	2026-08-27 13:52:51.581835+00	PORT2108-00996	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
a19db296-4e0d-4d54-97d0-1c2d49787180	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE139357	Fujitsu	ESPRIMO P558	retired	\N	\N	2019-01-08	\N	2026-08-27 13:52:51.583201+00	2026-08-27 13:52:51.583201+00	PC1908-139357	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-08	ELY0128	f
e2bd998b-cbe0-426b-bb5a-ca8a5e7cefee	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE063156	Fujitsu	ESPRIMO P558	assigned	\N	\N	2021-01-10	PC1903-063156	2026-08-27 13:52:51.58745+00	2026-08-27 13:52:51.591317+00	PC1801-063156	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ELY0129	f
3dba9baa-79c0-4ef4-b79b-68677cecdfa6	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD010743	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-04-09	PORT1808-010743\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.59385+00	2026-08-27 13:52:51.59385+00	PCP2-CBOIVIN	\N	\N	\N	\N	f	f	F1809165-04158	870.00	\N	\N	2021-04-09	ELY0112	f
6eef27c2-4a3e-4f0b-8462-cb2ff18a9c16	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSBX005767	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK U749	assigned	\N	\N	1900-01-22	PORT1910-005767\nAffectation importée non résolue : Usager="illiet" ; Utilisateur="-"	2026-08-27 13:52:51.595943+00	2026-08-27 13:52:51.595943+00	PORT1910-005767	\N	\N	\N	\N	f	f	F1910350-05629	1142.00	\N	\N	1900-01-22	ELY0127	f
2e287485-a401-4daf-be75-7864ca816924	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD073677	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-27	PORT2104-073677	2026-08-27 13:52:51.598953+00	2026-08-27 13:52:51.602735+00	PORT2110-073677	\N	\N	\N	\N	f	f	F21050397 - 03330	929.00	\N	\N	1900-01-27	ESI0120	f
5f4cc620-9767-475a-ab9b-2107aaff29c3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD077437	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-24	PORT2104-077437	2026-08-27 13:52:51.60623+00	2026-08-27 13:52:51.611466+00	PORT2101-077437	\N	\N	\N	\N	f	f	F21060388 - 04069	929.00	\N	\N	1900-01-24	ESI0120	f
26d31eec-d990-4eff-bc0e-9a316f049945	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009995	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	\N	2026-08-27 13:52:51.614336+00	2026-08-27 13:52:51.623027+00	PORT2108-009995	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
5ab2f8a4-d338-49b1-9196-8bcad9b32967	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021782	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2020-12-11	PORT2011-021782	2026-08-27 13:52:51.626391+00	2026-08-27 13:52:51.630543+00	PORT2011-021782	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI0110	f
8afa3cb8-b8fb-42ea-9b8b-921e454a0b45	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV107017	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-24	PORT2301-107017	2026-08-27 13:52:51.634625+00	2026-08-27 13:52:51.639022+00	PORT2212-107017	\N	\N	\N	\N	f	f	0097532246	880.00	\N	\N	1900-01-24	ELY0189	f
be94d2a7-e11c-42ed-9e30-23ecbe350fc9	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD005167	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2009-005167	2026-08-27 13:52:51.641831+00	2026-08-27 13:52:51.645457+00	PORT2009-005167	\N	\N	\N	\N	f	f	F2011424 - 06614	929.00	\N	\N	1900-01-23	ELY0148	f
b04eb105-e7e5-413e-97df-e55b0d1e7062	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029583	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	2021-01-10	PORT2110-029583	2026-08-27 13:52:51.648072+00	2026-08-27 13:52:51.651752+00	PORT2110-029583	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0173	f
9bedd242-f0a1-4c02-b780-814f54247ac3	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE139382	Fujitsu	ESPRIMO P558	retired	\N	\N	2019-01-08	\N	2026-08-27 13:52:51.653417+00	2026-08-27 13:52:51.653417+00	PC1908-139382	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-08	ESI0139	f
c58c54ed-e678-4194-b02b-93903ffb8e91	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK092563	Fujitsu	ESPRIMO D538	assigned	\N	\N	1900-01-21	\N	2026-08-27 13:52:51.656595+00	2026-08-27 13:52:51.660208+00	PC2004-092563	\N	\N	\N	\N	f	f	F2007320 - 03912	627.00	\N	\N	1900-01-21	ESI0114	f
ae685279-e184-48b2-8b9e-58e2020a0290	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3212JK7	HP	HP EliteBook 640 14 inch G9 Notebook PC	assigned	\N	\N	2023-07-07	\N	2026-08-27 13:52:51.662768+00	2026-08-27 13:52:51.665775+00	PORT2307-212JK7	\N	\N	\N	\N	f	f	\N	886.47	\N	\N	2024-07-07	ESI0175	f
cc942cf3-2a5f-45cc-876c-b63eb445fe20	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD077247	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:51.668272+00	2026-08-27 13:52:51.671825+00	PORT2104-077247	\N	\N	\N	\N	f	f	\N	929.00	\N	\N	1900-01-26	ESI0120	f
d1b83a78-67d8-428d-83cc-0bf40dfb6927	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE026473	Fujitsu	ESPRIMO P558	retired	\N	\N	1900-01-28	PC1812-026473\nAffectation importée non résolue : Usager="dayari@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.674062+00	2026-08-27 13:52:51.674062+00	PC1812-026473	\N	\N	\N	\N	f	f	F1811529-05613	660.00	\N	\N	1900-01-28	ELY0119	f
386c2382-8ae8-429d-9a29-8160770e22fa	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009997	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009997	2026-08-27 13:52:51.676331+00	2026-08-27 13:52:51.679012+00	PC-DSFV009997	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
cc9d93fe-d9e3-48b5-a364-b1ee6d0ca286	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD073773	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	PORT2104-073773	2026-08-27 13:52:51.680973+00	2026-08-27 13:52:51.683613+00	PORT2104-073773	\N	\N	\N	\N	f	f	F21040370 - 02563	929.00	\N	\N	1900-01-26	ELY0160	f
672c11e3-2a69-4af3-8c2b-9a03ef928156	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029594	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	2021-01-10	PORT2110-029594	2026-08-27 13:52:51.68578+00	2026-08-27 13:52:51.688178+00	PORT2110-029594	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0173	f
6db552fa-496a-4877-b659-2150c7d3e6f5	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE064845	Fujitsu	ESPRIMO P558	retired	\N	\N	2021-01-10	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.690582+00	2026-08-27 13:52:51.690582+00	PC1903-064845	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0143	f
980f7af8-d36c-4890-bc1e-e861d13d5b58	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSGJ005129	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5512	in_stock	\N	\N	2022-05-12	PORT2212-005129\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.693248+00	2026-08-27 13:52:51.693248+00	PORT2212-005129	\N	\N	\N	\N	f	f	0097449332	985.00	\N	\N	2023-05-12	ELY0188	f
039bfe89-85f9-4b8e-be6e-d092c5cc3d7a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3046022	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	2023-09-03	\N	2026-08-27 13:52:51.695892+00	2026-08-27 13:52:51.698589+00	PORT2302-046022	\N	\N	\N	\N	f	f	FA00004996	1153.72	\N	\N	2024-09-03	ELY0191	f
29f92fef-938f-45f1-9750-67d286074970	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK057905	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-12	\N	2026-08-27 13:52:51.699466+00	2026-08-27 13:52:51.699466+00	PC1910-057905	\N	\N	\N	\N	f	f	F1912281-06793	589.00	\N	\N	1900-01-12	ESI0084	f
3c4e603f-c440-4ddf-9948-2d34787f6072	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMEA046733	Fujitsu	ESPRIMO P556/2	retired	\N	\N	2017-01-08	PC1708-046733	2026-08-27 13:52:51.701018+00	2026-08-27 13:52:51.701018+00	PCGEOLE	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2020-01-08	ESI0053	f
19f0ea05-2bbd-4532-a6a7-d6be6f18982f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFS012281	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK U7411	assigned	\N	\N	1900-01-15	PORT2109-012281	2026-08-27 13:52:51.703787+00	2026-08-27 13:52:51.707852+00	PC-DSFS012281	\N	\N	\N	\N	f	f	F22020326 - 01121	1228.00	\N	\N	1900-01-15	ELY0170	f
852c81f3-8774-4f40-b642-da829a3d8721	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE154401	Fujitsu	ESPRIMO P558	retired	\N	\N	1900-01-19	\N	2026-08-27 13:52:51.709734+00	2026-08-27 13:52:51.709734+00	DESKTOP-KOJULER	\N	\N	\N	\N	f	f	F1911287-06187	616.00	\N	\N	1900-01-19	ESI0074	f
11b315f9-cd73-48bf-9cb2-b3771cba8f66	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	3SV6SQ3	Dell Inc.	XPS 15 9520	assigned	\N	\N	2022-05-12	\N	2026-08-27 13:52:51.712403+00	2026-08-27 13:52:51.715075+00	PORT2212-SV6SQ3	\N	\N	\N	\N	f	f	0097449332	2344.00	\N	\N	2023-05-12	ELY0188	f
c3aed48f-bbbd-4793-8848-449aa3a45e0c	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMEA057227	Fujitsu	ESPRIMO P556/2	assigned	\N	\N	2017-01-09	PC1709-057227	2026-08-27 13:52:51.717313+00	2026-08-27 13:52:51.720308+00	PCGECFC	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2020-01-09	ESI0135	f
d60a8487-2d1c-4b38-91ca-04b030083124	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009994	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-27	\N	2026-08-27 13:52:51.721354+00	2026-08-27 13:52:51.721354+00	PORT2108-009994	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
20372b95-ecf9-457c-9431-8d19616a322e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD058980	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	1900-01-26	PORT2103-058980	2026-08-27 13:52:51.723097+00	2026-08-27 13:52:51.723097+00	PORT2103-058980	\N	\N	\N	\N	f	f	F21040369 - 02562	929.00	\N	\N	1900-01-26	ELY0159	f
2b95e275-3aa5-480f-bafd-5bf363aba77f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFW001036	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q7311	assigned	\N	\N	1900-01-27	TABLET2108-001036	2026-08-27 13:52:51.725946+00	2026-08-27 13:52:51.729318+00	PORT2108-001036	\N	\N	\N	\N	f	f	\N	1253.00	\N	\N	1900-01-27	ESI0122	f
ac6b03ec-7d46-4664-9585-a62f7932698e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD8513NBW	HP	HP ProBook 470 G5	retired	\N	\N	1900-01-14	Affectation importée non résolue : Usager="iabsi@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.731426+00	2026-08-27 13:52:51.731426+00	DESKTOP-EHS8D13	\N	\N	\N	\N	f	f	F1903260-01378	1139.00	\N	\N	1900-01-14	ESI0093	f
9cade59a-2203-459d-988a-2127582c8796	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK071985	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-12	PC1912-071985\nAffectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.738552+00	2026-08-27 13:52:51.738552+00	PC-YMLK071985	\N	\N	\N	\N	f	f	F1912281-06793	589.00	\N	\N	1900-01-12	ESI0083	f
46cfb42e-a9ee-4835-9a57-fbd5c1216723	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029574	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-30	PORT2110-029574	2026-08-27 13:52:51.744993+00	2026-08-27 13:52:51.749188+00	PORT2110-029574	\N	\N	\N	\N	f	f	F22010429 - 00429	855.00	\N	\N	1900-01-30	ESI0171	f
9e5d0753-73b1-40d5-9b9f-44297b3050ef	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	YMLK055870	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-12	PC1910-055870	2026-08-27 13:52:51.750493+00	2026-08-27 13:52:51.750493+00	PC-YMLK055870	\N	\N	\N	\N	f	f	F1912281-06793	589.00	\N	\N	1900-01-12	ESI0085	f
5d842835-3e44-40dc-937d-7f41395a0ca2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021790	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	retired	\N	\N	2020-12-11	PORT2011-021790	2026-08-27 13:52:51.752331+00	2026-08-27 13:52:51.752331+00	PORT2011-021790	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI00108	f
3285b855-b2b1-4b1d-bf78-c702c7fd2f09	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE139375	Fujitsu	ESPRIMO P558	retired	\N	\N	2019-01-08	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.755831+00	2026-08-27 13:52:51.755831+00	PC1908-139375	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-08	ESI0144	f
1e70e6a4-7515-4272-86e5-e105e506abf1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021786	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2020-12-11	PORT2011-021786	2026-08-27 13:52:51.76002+00	2026-08-27 13:52:51.763584+00	PORT2011-021786	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI0109	f
8f87e689-6e33-4dea-911b-c1895c5b83ba	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224TTN	HP	HP ProBook 450 15.6 inch G10 Notebook PC	assigned	\N	\N	1900-01-29	\N	2026-08-27 13:52:51.766161+00	2026-08-27 13:52:51.770974+00	PORT2308-224TTN	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
aaa981f0-a1a0-460b-9b75-963a3e789ab5	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD005177	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	retired	\N	\N	1900-01-23	PORT2009-005177	2026-08-27 13:52:51.772214+00	2026-08-27 13:52:51.772214+00	PC-DSFD005177	\N	\N	\N	\N	f	f	F2011424 - 06614	929.00	\N	\N	1900-01-23	ELY0147	f
02daac82-863d-4b41-8733-12c4b3fb35fa	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF29D31Y	LENOVO	81RG	assigned	\N	\N	1900-01-24	Affectation importée non résolue : Usager="-" ; Utilisateur="Marion SAYSSAC"	2026-08-27 13:52:51.774316+00	2026-08-27 13:52:51.774316+00	PORT2006-29D31Y	\N	\N	\N	\N	f	f	F2006297 - 03243	832.00	\N	\N	1900-01-24	ELY0138A	f
f4bebdba-1f47-45c7-b83f-b05af0635920	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE064885	Fujitsu	ESPRIMO P558	retired	\N	\N	2021-01-10	PC1903-064885\nAffectation importée non résolue : Usager="cdellavalle@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.779133+00	2026-08-27 13:52:51.779133+00	PC-YMLE064885	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0149	f
b7c54d47-fbd0-49b7-9327-c1b52af883d3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31441WT	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:51.782857+00	2026-08-27 13:52:51.79581+00	PORT2306-1441WT	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
606d34d6-84cc-4075-84fe-e93f257b24bd	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE063162	Fujitsu	ESPRIMO P558	retired	\N	\N	2021-01-10	Affectation importée non résolue : Usager="mvignau@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.800895+00	2026-08-27 13:52:51.800895+00	PC1805-063162	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0150	f
a8f5ff19-bc26-40da-830c-86db72189df0	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE064822	Fujitsu	ESPRIMO P558	retired	\N	\N	2021-01-10	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.806397+00	2026-08-27 13:52:51.806397+00	PC1903-064822	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0151	f
891caa1b-9c42-48f6-8b99-7b325f361cea	bb95ff6b-0e80-45e2-9407-369056d35357	\N	0F004HN23073BF	Microsoft Corporation	Surface Pro 9	assigned	\N	\N	1900-01-15	Affectation importée non résolue : Usager="-" ; Utilisateur="Dorine VINCENT"	2026-08-27 13:52:51.809378+00	2026-08-27 13:52:51.809378+00	PORT2306-0738F	\N	\N	\N	\N	f	f	FA00005169	\N	\N	\N	1900-01-15	ELY0192	f
3e836a03-7c1b-468e-9f99-bcabc647eb14	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029573	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	2021-01-10	PORT2110-029573	2026-08-27 13:52:51.815175+00	2026-08-27 13:52:51.819046+00	PORT2110-029573	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0173	f
4d617e82-a6b4-45b2-9760-8af581999015	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021804	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2011-021804	2026-08-27 13:52:51.821859+00	2026-08-27 13:52:51.824855+00	PC-DSFD021804	\N	\N	\N	\N	f	f	F2011423-06613	929.00	\N	\N	1900-01-23	ESI0160	f
40a4953b-1888-4650-bc5f-7c47c41aac10	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK092671	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-21	Affectation importée non résolue : Usager="comptageneral@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.826987+00	2026-08-27 13:52:51.826987+00	PC2004-092671	\N	\N	\N	\N	f	f	F2007320 - 03912	627.00	\N	\N	1900-01-21	ESI0113	f
b4f8999e-d8a1-4666-bc3c-83e1e76b770a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049321	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049321\nAffectation importée non résolue : Usager="-" ; Utilisateur="Camille BALLIN"	2026-08-27 13:52:51.829108+00	2026-08-27 13:52:51.829108+00	PORT2102-049321	\N	\N	\N	\N	f	f	F2102274 - 00947	929.00	\N	\N	2024-09-02	ESI0117	f
1ca32205-43e0-437d-bf37-bb81e4604b84	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE154403	Fujitsu	ESPRIMO P558	retired	\N	\N	1900-01-19	PC1910-154403\nAffectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.832534+00	2026-08-27 13:52:51.832534+00	PC-YMLE154403	\N	\N	\N	\N	f	f	F1911287-06187	616.00	\N	\N	1900-01-19	ESI0075	f
2fc321d2-e6f8-4333-83ee-c1425ce9d5e7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF2DJ1LM	LENOVO	81RG	assigned	\N	\N	2020-09-09	\N	2026-08-27 13:52:51.835656+00	2026-08-27 13:52:51.838615+00	PORT2006-NT3456	\N	\N	\N	\N	f	f	F2009220 - 05050	832.00	\N	\N	2023-09-09	ELY0142	f
a5986267-7e47-4eda-9e1e-899746c99d06	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK092995	Fujitsu	ESPRIMO D538	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:52:51.840959+00	2026-08-27 13:52:51.844035+00	PC2005-057910	\N	\N	\N	\N	f	f	F2006297 - 03243	640.00	\N	\N	1900-01-24	ELY0138	f
f55391ba-9e07-4c0f-8b04-c4d6af867a38	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31441WQ	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:51.84598+00	2026-08-27 13:52:51.849083+00	PORT2306-1441WQ	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
d9d8a3ff-3e7f-48be-a2c0-ef747fc67a8b	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE064809	Fujitsu	ESPRIMO P558	retired	\N	\N	1900-01-28	\N	2026-08-27 13:52:51.850638+00	2026-08-27 13:52:51.850638+00	PC1903-064809	\N	\N	\N	\N	f	f	F1903379-01497	654.00	\N	\N	1900-01-28	ELY0121	f
b80e1754-1bdc-4878-84a3-53c0016e2143	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049315	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049315	2026-08-27 13:52:51.85465+00	2026-08-27 13:52:51.85845+00	PORT2102-049315	\N	\N	\N	\N	f	f	F2102276 - 00949	929.00	\N	\N	2024-09-02	ELY0153	f
444851e3-2ed8-4b50-ba16-f2a9088ffa4a	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YM4X005937	Fujitsu	ESPRIMO P556/E85+	retired	\N	\N	2021-01-09	\N	2026-08-27 13:52:51.85979+00	2026-08-27 13:52:51.85979+00	PCMGPL02	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-09	ESI0134	f
1bd90f40-abba-4947-aebb-4c6ada82e26a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440X5	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:51.864006+00	2026-08-27 13:52:51.868148+00	PORT2306-1440X5	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
0ac9d268-39b9-4623-8f00-010fcb193e46	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK071960	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-12	PC1912-071960\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.871649+00	2026-08-27 13:52:51.871649+00	PC-YMLK071960	\N	\N	\N	\N	f	f	F1912282-06794	589.00	\N	\N	1900-01-12	ESI0082	f
fa935ab1-2441-4a7d-9519-d8425c075c6b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021731	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2020-12-11	PORT2011-021731\nAffectation importée non résolue : Usager="-" ; Utilisateur="Maud HARASYMCZUK"	2026-08-27 13:52:51.873791+00	2026-08-27 13:52:51.873791+00	PORT2011-021731	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI0112	f
69dbb3a1-4dbb-46ab-8f65-c7aa1dabaddf	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE063148	Fujitsu	ESPRIMO P558	assigned	\N	\N	2021-01-10	PC1903-063148	2026-08-27 13:52:51.87672+00	2026-08-27 13:52:51.879219+00	PC-YMLE063148	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0152	f
c93e091c-1f71-4c64-a768-ad5bfdfc23d4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021837	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2011-021837	2026-08-27 13:52:51.880881+00	2026-08-27 13:52:51.88382+00	PORT2011-021837	\N	\N	\N	\N	f	f	F2011424 - 06614	929.00	\N	\N	1900-01-23	ELY0146	f
199a7413-03f5-44bb-90bd-03b62a5f898a	bb95ff6b-0e80-45e2-9407-369056d35357	\N	0F0125T214701J	Microsoft Corporation	Surface Pro 8	assigned	\N	\N	2022-10-06	TABLET2206-T214701	2026-08-27 13:52:51.886614+00	2026-08-27 13:52:51.889739+00	TABLET-4O4IB02F	\N	\N	\N	\N	f	f	F22060337 - 04387	\N	\N	\N	2025-10-06	ELY0175	f
5ca238b4-e8be-4e60-8033-b02c27c515e1	bb95ff6b-0e80-45e2-9407-369056d35357	\N	726743-02R9200205	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	TABLET1904-200205\nAffectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.892144+00	2026-08-27 13:52:51.892144+00	PC-02R9200205	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-04	\N	f
5037a231-994f-4461-9d0a-e4ad26d0bb7c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049316	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049316	2026-08-27 13:52:51.895077+00	2026-08-27 13:52:51.898601+00	PC-DSFD049316	\N	\N	\N	\N	f	f	F2102276 - 00949	939.00	\N	\N	2024-09-02	ELY0154	f
792d9c94-8ac6-4097-988e-fc2b4778e0ce	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049361	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049361	2026-08-27 13:52:51.900838+00	2026-08-27 13:52:51.90446+00	PORT2102-049361	\N	\N	\N	\N	f	f	F2102275-00948	929.00	\N	\N	2024-09-02	ESI0163	f
ad8a6a80-518a-4e32-b6c6-3d768ef7672c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440NS	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:51.907612+00	2026-08-27 13:52:51.910853+00	PORT2306-1440NS	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
7007dd57-e443-4191-bb49-10e83aeacab6	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE139593	Fujitsu	ESPRIMO P558	retired	\N	\N	2019-01-08	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.913365+00	2026-08-27 13:52:51.913365+00	PC1908-SRVWEB-TEST	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-08	\N	f
ce8bf15b-23e7-495d-a684-47f0c4377442	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009127	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.916679+00	2026-08-27 13:52:51.916679+00	PORT1808-D00912	\N	\N	\N	\N	f	f	F1808163-03676	870.00	\N	\N	2021-03-08	ELY0110	f
10d92acb-1af2-46ae-aba7-829024611c39	bb95ff6b-0e80-45e2-9407-369056d35357	\N	DSAX001834	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q7310	assigned	\N	\N	1900-01-23	TABLET2012-001834	2026-08-27 13:52:51.919914+00	2026-08-27 13:52:51.923445+00	PC-DSAX001834	\N	\N	\N	\N	f	f	F2011425 - 06615	1212.00	\N	\N	1900-01-23	ELY0149	f
c08a6135-efa5-4801-bee0-ab237d8381f4	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE166183	Fujitsu	ESPRIMO P558	retired	\N	\N	1900-01-19	PC1911-166183\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.926066+00	2026-08-27 13:52:51.926066+00	PC1911-166183	\N	\N	\N	\N	f	f	F1911287-06187	616.00	\N	\N	1900-01-19	ESI0073	f
f1d876bb-c999-41bb-bf9b-f620f6b462c3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009678	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:52:51.929918+00	2026-08-27 13:52:51.933064+00	PORT2202-009678	\N	\N	\N	\N	f	f	F22050452 - 03659	737.00	\N	\N	1900-01-24	ELY0174	f
dea0bbd7-1290-4f11-a971-aa1319ab2c92	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE036071	Fujitsu	ESPRIMO P558	retired	\N	\N	1900-01-26	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.935135+00	2026-08-27 13:52:51.935135+00	PC1901-036071	\N	\N	\N	\N	f	f	F1903336-01454	654.00	\N	\N	1900-01-26	ESI0078	f
8e9aa9dd-6138-42fc-ac6d-74f74186f1c1	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	J9MSCG0000LN	ASUSTeK COMPUTER INC.	PB60	assigned	\N	\N	1900-01-14	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:51.937914+00	2026-08-27 13:52:51.937914+00	PC2107-Surv23	\N	\N	\N	\N	f	f	FV201900225319	566.02	\N	\N	1900-01-14	ESI0070	f
b94bb2fa-a749-4967-8a4a-971da8152d40	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021845	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	retired	\N	\N	1900-01-23	PORT2211-021845\nAffectation importée non résolue : Usager="Marie TOLVE" ; Utilisateur="-"	2026-08-27 13:52:51.939843+00	2026-08-27 13:52:51.939843+00	PORT2011-021845	\N	\N	\N	\N	f	f	F2011423-06613	929.00	\N	\N	1900-01-23	ESI0160	f
efbec61d-63d5-4ff6-81ff-6097ae8d00cb	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049269	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-01-02	PORT2102-049269	2026-08-27 13:52:51.944712+00	2026-08-27 13:52:51.947854+00	PC-DSFD049269	\N	\N	\N	\N	f	f	F2102196-00869	929.00	\N	\N	2024-01-02	ESI0161	f
f6002513-b20d-4915-93ef-23ff8d710304	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK057910	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-12	\N	2026-08-27 13:52:51.949338+00	2026-08-27 13:52:51.949338+00	PC2004-092995	\N	\N	\N	\N	f	f	F1912281-06793	589.00	\N	\N	1900-01-12	ESI0082	f
6410e2a0-1356-47cf-b37c-834966bd2be8	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009724	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	retired	\N	\N	1900-01-27	PORT2108-009724	2026-08-27 13:52:51.951001+00	2026-08-27 13:52:51.951001+00	PORT2108-009724	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
5e49fba4-a303-476c-8041-82d2cdb5e482	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE139598	Fujitsu	ESPRIMO P558	assigned	\N	\N	2019-01-08	PC1908-139598	2026-08-27 13:52:51.954274+00	2026-08-27 13:52:51.957576+00	PC-YMLE139598	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-08	\N	f
3b7c0f55-01fa-42e4-99e0-e9020404c945	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD077384	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-24	PORT2104-077384	2026-08-27 13:52:51.959602+00	2026-08-27 13:52:51.962059+00	PORT2104-077384	\N	\N	\N	\N	f	f	F21060389 - 04070	929.00	\N	\N	1900-01-24	ELY0165	f
6b61a653-8659-435c-be37-33f4084705d3	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE157413	Fujitsu	ESPRIMO P558	assigned	\N	\N	1900-01-19	PC1910-157413	2026-08-27 13:52:51.963918+00	2026-08-27 13:52:51.966533+00	PC-YMLE157413	\N	\N	\N	\N	f	f	F1911287-06187	616.00	\N	\N	1900-01-19	ESI0076	f
31f21015-6900-4c8a-b563-06315df91bff	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049260	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-01-02	\N	2026-08-27 13:52:51.968246+00	2026-08-27 13:52:51.970899+00	PORT2102-049260	\N	\N	\N	\N	f	f	F2102196-00869	929.00	\N	\N	2024-01-02	ESI0161	f
14e4af3d-fb74-44c8-be08-97dba4cca479	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD022069	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2020-12-11	PORT2011-022069	2026-08-27 13:52:51.973056+00	2026-08-27 13:52:51.975883+00	PORT2011-022069	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI0111	f
c89a262d-5f48-46d4-88e2-be1a4c9e79ef	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009126	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	PORT1808-009126	2026-08-27 13:52:51.976909+00	2026-08-27 13:52:51.976909+00	Port1808-009126	\N	\N	\N	\N	f	f	F1808164-03677	870.00	\N	\N	2021-03-08	ESI0067	f
5736ba96-5024-495a-a416-02c06a45bfb3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440WR	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	Affectation importée non résolue : Usager="-" ; Utilisateur="Joe CLEMENTE"	2026-08-27 13:52:51.97819+00	2026-08-27 13:52:51.97819+00	PORT2306-1440WR	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
a691d8cf-5b12-4ea3-ae5d-98abf2205060	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021805	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2011-021805	2026-08-27 13:52:51.980732+00	2026-08-27 13:52:51.98317+00	PORT2011-021805	\N	\N	\N	\N	f	f	F2011424 - 06614	929.00	\N	\N	1900-01-23	ELY0145	f
54413157-435c-41cf-818c-b9c776460dcf	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029591	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	2021-01-10	PORT2110-029591	2026-08-27 13:52:51.984801+00	2026-08-27 13:52:51.986964+00	PORT2110-029591	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0173	f
e3b9a878-d04c-4eb8-b34c-f59ad4aae656	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224SW8	HP	HP ProBook 450 15.6 inch G10 Notebook PC	assigned	\N	\N	1900-01-29	\N	2026-08-27 13:52:51.988854+00	2026-08-27 13:52:51.991526+00	PORT2309-224SW8	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
4ecb8aa3-2ab4-4cef-9ed8-40426cef5b44	bb95ff6b-0e80-45e2-9407-369056d35357	\N	0F015EJ214701J	Microsoft Corporation	Surface Pro 8	assigned	\N	\N	2022-10-06	TABLET2206-14701J	2026-08-27 13:52:51.99375+00	2026-08-27 13:52:51.996858+00	PORT2308-14701J	\N	\N	\N	\N	f	f	F22060337 - 04387	1140.00	\N	\N	2025-10-06	ELY0175	f
61096722-ef9c-43d6-a3ab-5612feb94f47	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSGJ005131	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5512	assigned	\N	\N	2023-05-12	\N	2026-08-27 13:52:51.998926+00	2026-08-27 13:52:52.003028+00	PORT2212-005131	\N	\N	\N	\N	f	f	0097449332	985.00	\N	\N	2024-05-12	ELY0188	f
ceb16e59-ec61-4a29-abcf-61f730097f8b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029577	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:52.006724+00	2026-08-27 13:52:52.012747+00	PORT2110-029577	\N	\N	\N	\N	f	f	F22010429 - 00429	855.00	\N	\N	1900-01-30	ESI0171	f
b00dbea4-8038-4123-9bdc-f47c14da1d88	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMHA005051	Fujitsu	CELSIUS J580	retired	\N	\N	2019-01-11	\N	2026-08-27 13:52:52.014376+00	2026-08-27 13:52:52.014376+00	PC1911-005051	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-11	ELY0130	f
618a8198-60e4-47c8-bb13-396bd887fb39	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31442J8	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.017102+00	2026-08-27 13:52:52.019671+00	PORT2306-1442J8	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
cae136d6-b1db-4c70-8ef1-ac869d9dd885	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD077383	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	1900-01-24	\N	2026-08-27 13:52:52.020736+00	2026-08-27 13:52:52.020736+00	PORT2104-077383	\N	\N	\N	\N	f	f	F21060389 - 04070	929.00	\N	\N	1900-01-24	ELY0165	f
6b1e5aa3-903d-4fa8-8676-179480fa5c27	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE036075	Fujitsu	ESPRIMO P558	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.022894+00	2026-08-27 13:52:52.025293+00	PC1901-0360751	\N	\N	\N	\N	f	f	F1903336-01454	654.00	\N	\N	1900-01-26	ESI0077	f
f1c6176c-0dbc-4453-a8a3-435249b892b4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049404	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	2021-09-02	PORT2102-049404	2026-08-27 13:52:52.026248+00	2026-08-27 13:52:52.026248+00	PORT2102-049404	\N	\N	\N	\N	f	f	F2102274 - 00947	929.00	\N	\N	2024-09-02	ESI0118	f
9baa9980-08a0-40bb-a411-8efe7abf37ca	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE064823	Fujitsu	ESPRIMO P558	assigned	\N	\N	2021-01-10	PC1903-064823\nAffectation importée non résolue : Usager="interim2@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.029128+00	2026-08-27 13:52:52.029128+00	PC-YMLE064823	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	\N	f
2e9169b5-fcb7-45ce-bb51-4982b95a4806	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK091350	Fujitsu	ESPRIMO D538	assigned	\N	\N	1900-01-21	\N	2026-08-27 13:52:52.107309+00	2026-08-27 13:52:52.110138+00	PC2004-0913501	\N	\N	\N	\N	f	f	F2007320 - 03912	627.00	\N	\N	1900-01-21	ESI0115	f
b5c14b5f-4194-4d5f-b492-ed00fdfb21a8	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE139369	Fujitsu	ESPRIMO P558	retired	\N	\N	2019-01-08	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.210285+00	2026-08-27 13:52:52.210285+00	PC1908-139369	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-08	\N	f
41cbf0ca-0940-4971-b98a-ed0b89fc3040	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009709	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009709\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Amandine DUMAS"	2026-08-27 13:52:52.112611+00	2026-08-27 13:52:52.112611+00	PORT2108-009709	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
c42b03b8-0d64-4605-8fed-b27ee3f8e115	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	G2YL3T3	Dell Inc.	XPS 15 9520	assigned	\N	\N	2022-05-12	PORT2212-2YL3T3	2026-08-27 13:52:52.115569+00	2026-08-27 13:52:52.118075+00	PORT2212-202212	\N	\N	\N	\N	f	f	0097449332	2344.00	\N	\N	2023-05-12	ELY0188	f
c4b7c913-cc02-41a1-a5b7-b786890b7f08	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF29CW5L	LENOVO	81RG	retired	\N	\N	1900-01-24	\N	2026-08-27 13:52:52.119115+00	2026-08-27 13:52:52.119115+00	PORT2006-29CW5L	\N	\N	\N	\N	f	f	F2006296 - 03242	832.00	\N	\N	1900-01-24	ELY0137	f
55fbe128-eb3f-4e55-9596-94282160b105	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV010018	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	\N	2026-08-27 13:52:52.121963+00	2026-08-27 13:52:52.124942+00	PORT2108-010018	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
37e1c97a-2aed-4ce9-9977-cfefebdc39ea	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMEA066650	Fujitsu	ESPRIMO P556/2	retired	\N	\N	1900-01-19	PC1710-066650	2026-08-27 13:52:52.126098+00	2026-08-27 13:52:52.126098+00	PCGELRZ	\N	\N	\N	\N	f	f	F1709234-03685	694.00	\N	\N	1900-01-19	ESI0101	f
49f9a078-e085-40f6-9590-09df40a850f0	bb95ff6b-0e80-45e2-9407-369056d35357	\N	DSAP007337	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q739	assigned	\N	\N	2020-11-03	TABLET2003-007337	2026-08-27 13:52:52.128663+00	2026-08-27 13:52:52.1314+00	PORT2104-007337	\N	\N	\N	\N	f	f	\N	1780.00	\N	\N	2023-11-03	ESI0097	f
d87510ac-398f-4083-bb46-4426226e0d91	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMGK080357	Fujitsu	ESPRIMO P557	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:52.133272+00	2026-08-27 13:52:52.135835+00	PC1806-ComptaESI	\N	\N	\N	\N	f	f	F1805318-02344	624.00	\N	\N	1900-01-30	ESI0062	f
8ebb3621-fc89-429f-a05b-521908fda9c3	bb95ff6b-0e80-45e2-9407-369056d35357	\N	726743-02R9200244	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-12	\N	2026-08-27 13:52:52.136825+00	2026-08-27 13:52:52.136825+00	PORT1912-200244	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-12	\N	f
bf74ec47-f9f1-4fbf-ad07-9e30962b95dd	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK088934	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-30	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.139409+00	2026-08-27 13:52:52.139409+00	PC2001-088934	\N	\N	\N	\N	f	f	F2003556-01777	617.00	\N	\N	1900-01-30	ESI0099	f
464501ce-35cc-4687-9eee-2355d17bb43b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3142PB7	HP	HP EliteBook 640 14 inch G9 Notebook PC	assigned	\N	\N	1900-01-20	\N	2026-08-27 13:52:52.142794+00	2026-08-27 13:52:52.146271+00	PORT2306-142PB7	\N	\N	\N	\N	f	f	FA00005184	879.00	\N	\N	1900-01-20	ELY0195	f
b9b0bad0-53dc-4d76-a91c-c31609b47948	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029590	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-30	PORT2110-029590	2026-08-27 13:52:52.148759+00	2026-08-27 13:52:52.152104+00	PORT2110-029590	\N	\N	\N	\N	f	f	F22010429 - 00429	855.00	\N	\N	1900-01-30	ESI0171	f
5f9902db-8114-46df-8260-499b1cd8e3d7	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE064831	Fujitsu	ESPRIMO P558	retired	\N	\N	2021-01-10	\N	2026-08-27 13:52:52.15309+00	2026-08-27 13:52:52.15309+00	PC1903-064831	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	\N	f
71fcbe7d-2ae9-4796-b443-d14ba678b873	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009725	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009725	2026-08-27 13:52:52.155315+00	2026-08-27 13:52:52.157532+00	PORT2108-009725	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
f4094efc-fa21-4573-9550-3e7c49957647	bb95ff6b-0e80-45e2-9407-369056d35357	\N	DSFW001033	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q7311	in_stock	\N	\N	1900-01-27	TABLET2108-001033	2026-08-27 13:52:52.158535+00	2026-08-27 13:52:52.158535+00	PC-DSFW001033	\N	\N	\N	\N	f	f	\N	1253.00	\N	\N	1900-01-27	ESI0122	f
640cea75-8d82-4ac6-967e-004d64ddd89c	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMGK080353	Fujitsu	ESPRIMO P557	retired	\N	\N	1900-01-30	PC1806-080353\nAffectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.161454+00	2026-08-27 13:52:52.161454+00	PC1806-080353	\N	\N	\N	\N	f	f	F1805318-02344	624.00	\N	\N	1900-01-30	ESI0063	f
43ebbb29-8b26-49bc-ba10-6ec56880918d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224TMT	HP	HP ProBook 450 15.6 inch G10 Notebook PC	assigned	\N	\N	1900-01-29	Affectation importée non résolue : Usager="-" ; Utilisateur="Marie-Morgane PORTE"	2026-08-27 13:52:52.163115+00	2026-08-27 13:52:52.163115+00	PORT2308-224TMT	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
17874ce1-2629-4bbe-972e-89986f6dd67b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009138	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	\N	2026-08-27 13:52:52.164256+00	2026-08-27 13:52:52.164256+00	PORT1808-009138	\N	\N	\N	\N	f	f	F1808163-03676	870.00	\N	\N	2021-03-08	ELY0108	f
0955487a-03bf-4da7-8bc0-2d56bf245286	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440XR	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	Affectation importée non résolue : Usager="-" ; Utilisateur="Fayza NAJI"	2026-08-27 13:52:52.165422+00	2026-08-27 13:52:52.165422+00	PORT2306-1440XR	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
ccc31b33-543a-4089-9476-b05127e1f7b3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029589	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-30	\N	2026-08-27 13:52:52.166669+00	2026-08-27 13:52:52.166669+00	PORT2110-029589	\N	\N	\N	\N	f	f	F22010431 - 00431	855.00	\N	\N	1900-01-30	ELY0169	f
eb419c86-8ea3-44e9-b82f-a028f930a33b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD058979	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.169037+00	2026-08-27 13:52:52.171207+00	PORT2103-058979	\N	\N	\N	\N	f	f	F21040370 - 02563	929.00	\N	\N	1900-01-26	ELY0160	f
f451aa21-9f05-44ed-ad94-1edd41803427	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224SSP	HP	HP ProBook 450 15.6 inch G10 Notebook PC	in_stock	\N	\N	1900-01-29	Affectation importée non résolue : Usager="Clara Mages" ; Utilisateur="-"	2026-08-27 13:52:52.172103+00	2026-08-27 13:52:52.172103+00	PORT2309-224SSP	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
f886d183-8f94-476c-9138-d61c7748b459	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD010770	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-04-09	PORT1808-010770	2026-08-27 13:52:52.173322+00	2026-08-27 13:52:52.173322+00	PORT1808-010770	\N	\N	\N	\N	f	f	F1809165-04158	870.00	\N	\N	2021-04-09	ELY0113	f
a4f7cc7e-2f41-4043-b198-7b1014d64ccf	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	J9MSCG0000HR	ASUSTeK COMPUTER INC.	PB60	retired	\N	\N	1900-01-14	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.176012+00	2026-08-27 13:52:52.176012+00	PC2107-TV-RDC	\N	\N	\N	\N	f	f	FV201300225319	566.02	\N	\N	1900-01-14	ESI0069	f
114ca650-cf35-49b1-8d5a-1e1343a0f22b	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMGK079552	Fujitsu	ESPRIMO P557	retired	\N	\N	2018-09-05	PC1805-079552	2026-08-27 13:52:52.177847+00	2026-08-27 13:52:52.177847+00	DESKTOP-AJE2O8K	\N	\N	\N	\N	f	f	F1805191-02217	624.00	\N	\N	2021-09-05	ESI0138	f
6e0e9c64-b7af-4810-aba3-0878e77b0d08	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSGJ005130	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5512	assigned	\N	\N	2022-05-12	\N	2026-08-27 13:52:52.180707+00	2026-08-27 13:52:52.183926+00	PORT2212-005130	\N	\N	\N	\N	f	f	0097449332	985.00	\N	\N	2023-05-12	ELY0188	f
46c4ea87-4908-49fe-9e89-281c8b7db380	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD046638	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	PORT2102-046638\nAffectation importée non résolue : Usager="-" ; Utilisateur="Noémie SAMYCHETTY"	2026-08-27 13:52:52.184911+00	2026-08-27 13:52:52.184911+00	PORT2102-046638	\N	\N	\N	\N	f	f	F21040371-02564	929.00	\N	\N	1900-01-26	ESI0164	f
e1ed3fff-4f0c-4a8e-a89b-7e986977471b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31442FZ	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	Affectation importée non résolue : Usager="-" ; Utilisateur="Marine FORESTIER"	2026-08-27 13:52:52.186424+00	2026-08-27 13:52:52.186424+00	PORT2306-1442FZ	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
fb32886e-78d2-430a-af2c-9a21b3c37831	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009119	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	PORT1808-009119	2026-08-27 13:52:52.18769+00	2026-08-27 13:52:52.18769+00	PCNSE	\N	\N	\N	\N	f	f	F1808163-03676	870.00	\N	\N	2021-03-08	ELY0109	f
ba79337b-2ceb-494a-aecf-7a24d33f3d96	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF1460D4	LENOVO	81RG	retired	\N	\N	1900-01-19	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.192416+00	2026-08-27 13:52:52.192416+00	PORT1906-1460D4	\N	\N	\N	\N	f	f	F1911287-06187	836.00	\N	\N	1900-01-19	ESI0153	f
b4f0ce9f-f7aa-4cf4-aa88-4dd6f0c4cdd3	bb95ff6b-0e80-45e2-9407-369056d35357	\N	0F014J3222301J	Microsoft Corporation	Surface Pro 8	assigned	\N	\N	2023-05-12	\N	2026-08-27 13:52:52.195896+00	2026-08-27 13:52:52.197959+00	PORT2312-22301J	\N	\N	\N	\N	f	f	0097449332	999.00	\N	\N	2024-05-12	ELY0152	f
a8841aa5-7911-4237-9dd4-d06d71927588	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFS050184	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK U7411	assigned	\N	\N	1900-01-28	PORT2208-050184	2026-08-27 13:52:52.199487+00	2026-08-27 13:52:52.201564+00	PORT2208-050184	\N	\N	\N	\N	f	f	F22070907 - 05795	1264.00	\N	\N	1900-01-28	ELY0180	f
f47ae662-b814-4e53-bc37-821e2430b39e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD8513NHT	HP	HP ProBook 470 G5	assigned	\N	\N	1900-01-14	\N	2026-08-27 13:52:52.203041+00	2026-08-27 13:52:52.205576+00	DESKTOP-1L2M2B8	\N	\N	\N	\N	f	f	F1903259-01377	1139.00	\N	\N	1900-01-14	ESI0093	f
df1bd158-4d20-4259-86be-2df0fb262dd9	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE139595	Fujitsu	ESPRIMO P558	retired	\N	\N	2019-01-08	\N	2026-08-27 13:52:52.206596+00	2026-08-27 13:52:52.206596+00	PC1908-139595	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-08	\N	f
efd1cc20-7509-4047-9c43-24435fbfedc6	bb95ff6b-0e80-45e2-9407-369056d35357	\N	0F011W7214701J	Microsoft Corporation	Surface Pro 8	retired	\N	\N	2022-10-06	TABLET2206-721470	2026-08-27 13:52:52.208064+00	2026-08-27 13:52:52.208064+00	PORT2211-VQK4CDJF	\N	\N	\N	\N	f	f	F22060337 - 04387	1140.00	\N	\N	2025-10-06	ELY0175	f
c6661739-ca2d-4b37-9074-ecbb7caf04d3	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMGK080617	Fujitsu	ESPRIMO P557	retired	\N	\N	1900-01-30	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.212457+00	2026-08-27 13:52:52.212457+00	PC1806-080617	\N	\N	\N	\N	f	f	F1805318-02344	624.00	\N	\N	1900-01-30	ESI0064	f
4c99897d-2c85-4b0a-8909-b75925519659	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD90715P4	HP	HP ProBook 470 G5	assigned	\N	\N	1900-01-14	\N	2026-08-27 13:52:52.215421+00	2026-08-27 13:52:52.218006+00	PORT1903-0715P4	\N	\N	\N	\N	f	f	F1903260-01378	1139.00	\N	\N	1900-01-14	ESI0093	f
bccd9d04-246e-46fe-a3af-3e6b5fecc632	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLK089996	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-19	\N	2026-08-27 13:52:52.218933+00	2026-08-27 13:52:52.218933+00	PC2011-089996	\N	\N	\N	\N	f	f	F2008275 - 04507	627.00	\N	\N	1900-01-19	ELY0140	f
e95ed0bd-9f4e-4e01-9294-d0999d60f57c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF1KEH8M	LENOVO	81RG	assigned	\N	\N	1900-01-28	\N	2026-08-27 13:52:52.221303+00	2026-08-27 13:52:52.224085+00	PORT2006-NT3712	\N	\N	\N	\N	f	f	F1908291-04438	832.00	\N	\N	1900-01-28	ESI0145	f
88599aca-f4e3-4672-8b2f-fd3b122d94c6	bb95ff6b-0e80-45e2-9407-369056d35357	\N	726743-02R9200247	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.22672+00	2026-08-27 13:52:52.22672+00	TABLET1904-9200247	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-04	\N	f
d605e023-b0c8-4aca-8841-0eda4002ffc6	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31441YR	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.229508+00	2026-08-27 13:52:52.233118+00	PORT2307-3144YR	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
c385d20a-7411-41fd-be0e-71342850a981	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD8513NK4	HP	HP ProBook 470 G5	assigned	\N	\N	2021-01-10	\N	2026-08-27 13:52:52.234727+00	2026-08-27 13:52:52.237+00	PORT1903-513NK4	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0146	f
ec5ad266-7f07-43af-a688-20b1590fd0a2	bb95ff6b-0e80-45e2-9407-369056d35357	\N	726743-02R9400351	Fujitsu	STYLISTIC R727	retired	\N	\N	1900-01-12	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.239222+00	2026-08-27 13:52:52.239222+00	DESKTOP-44351F8	\N	\N	\N	\N	f	f	F1912281-06793	1266.00	\N	\N	1900-01-12	ESI0081	f
495bc8f0-6579-4c22-bf44-7fe5e3241908	bb95ff6b-0e80-45e2-9407-369056d35357	\N	023305172053	Microsoft Corporation	Surface Pro	retired	\N	\N	1900-01-18	\N	2026-08-27 13:52:52.241069+00	2026-08-27 13:52:52.241069+00	SURFACELRZ	\N	\N	\N	\N	f	f	0094308601	1199.00	\N	\N	1900-01-18	ELY0100	f
f129352a-cc5d-445e-b4db-758a8fe41d51	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMEA054002	Fujitsu	ESPRIMO P556/2	retired	\N	\N	2017-07-09	PC1709-054002	2026-08-27 13:52:52.243122+00	2026-08-27 13:52:52.243122+00	PCGEHNE	\N	\N	\N	\N	f	f	F1709167-03618	552.00	\N	\N	2020-07-09	ELY0098	f
94f5d077-c26c-46bb-83fa-f9607bbe30fd	bb95ff6b-0e80-45e2-9407-369056d35357	\N	726743-02R9200030	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.246773+00	2026-08-27 13:52:52.246773+00	PC-02R9200030	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-04	\N	f
062b0b80-1619-4cc2-a299-d20dd56e18b5	bb95ff6b-0e80-45e2-9407-369056d35357	\N	DSAP007778	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q739	assigned	\N	\N	2020-10-06	TABLET2006-007778	2026-08-27 13:52:52.250573+00	2026-08-27 13:52:52.254283+00	PORT2006-007778	\N	\N	\N	\N	f	f	\N	1211.00	\N	\N	2023-10-06	ESI0102	f
eeffbc87-280e-4798-a011-cca16b26e103	bb95ff6b-0e80-45e2-9407-369056d35357	\N	726743-02R9200181	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	TABLET1904-200181	2026-08-27 13:52:52.255314+00	2026-08-27 13:52:52.255314+00	PC-02R9200181	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-04	\N	f
74a8b22c-0cd4-49e7-87f6-4721e71e2797	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD058981	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.257855+00	2026-08-27 13:52:52.260869+00	PORT2103-058981	\N	\N	\N	\N	f	f	F21040372 - 02565	929.00	\N	\N	1900-01-26	ESI0119	f
c71d60cd-c2c0-4cc9-9e52-ae6ad4af6381	bb95ff6b-0e80-45e2-9407-369056d35357	\N	726743-02R9200266	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	TABLET1904-200266\nAffectation importée non résolue : Usager="amteixeira@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.263558+00	2026-08-27 13:52:52.263558+00	DESKTOP-SM1TPSO	\N	\N	\N	\N	f	f	Credit Bail StarLease	0.00	\N	\N	2022-01-04	ESI0176	f
6f95d156-7293-4323-873a-be9eace5538c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV010285	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-24	PORT2202-010285	2026-08-27 13:52:52.265487+00	2026-08-27 13:52:52.265487+00	PORT2202-010285	\N	\N	\N	\N	f	f	F22050452 - 03659	737.00	\N	\N	1900-01-24	ELY0174	f
55257ab9-0497-4bec-95e1-62f5808025b1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049272	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049272	2026-08-27 13:52:52.269577+00	2026-08-27 13:52:52.273072+00	PORT2102-049272	\N	\N	\N	\N	f	f	F2102274 - 00947	0.00	\N	\N	2024-09-02	ESI0116	f
a44fe3a3-b93a-4560-8dba-46651cfa9bf8	bb95ff6b-0e80-45e2-9407-369056d35357	\N	726743-02R9500024	Fujitsu	STYLISTIC R727	retired	\N	\N	1900-01-12	TABLET1912-500024	2026-08-27 13:52:52.274254+00	2026-08-27 13:52:52.274254+00	DESKTOP-QTBS0JN	\N	\N	\N	\N	f	f	F1912284-06793	1266.00	\N	\N	1900-01-12	ESI0080	f
a4c1d217-2e35-42ac-9c86-79e31292ec42	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009723	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009723	2026-08-27 13:52:52.276765+00	2026-08-27 13:52:52.278891+00	PORT2108-009723	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
2bed3b9f-46db-4e64-9783-89fce001fc40	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD2236FCX	HP	HP EliteBook 640 14 inch G9 Notebook PC	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:52:52.280325+00	2026-08-27 13:52:52.282456+00	PORT2304-5CD2236FCX	\N	\N	\N	\N	f	f	\N	1007.49	\N	\N	1900-01-24	ESI0174	f
8c10445c-5ce9-4934-abd5-9cbc633cad4f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224TW4	HP	HP ProBook 450 15.6 inch G10 Notebook PC	assigned	\N	\N	1900-01-29	\N	2026-08-27 13:52:52.28409+00	2026-08-27 13:52:52.286155+00	PORT2309-224TW4	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
753c2761-e170-4677-9217-c84fb9f43a33	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021765	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2011-021765	2026-08-27 13:52:52.288102+00	2026-08-27 13:52:52.290418+00	PORT2011-021765	\N	\N	\N	\N	f	f	F2011423-06613	929.00	\N	\N	1900-01-23	ESI160	f
b4f2f2ff-b987-4df0-94ee-6fac4b3f86bc	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3212JK8	HP	HP EliteBook 640 14 inch G9 Notebook PC	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:52.292201+00	2026-08-27 13:52:52.294235+00	PORT2306-212JK8	\N	\N	\N	\N	f	f	FA00005189	879.00	\N	\N	1900-01-22	ELY0194	f
dedaffd5-d6b4-4a06-8d77-84d77af32499	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029587	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-30	PORT2110-029587\nAffectation importée non résolue : Usager="-" ; Utilisateur="Hugo NAKACHE"	2026-08-27 13:52:52.295198+00	2026-08-27 13:52:52.295198+00	PC-DSFV029587	\N	\N	\N	\N	f	f	F22010431 - 00431	855.00	\N	\N	1900-01-30	ELY0169	f
9a2eb5b9-16bc-4818-a1ed-c8471cafdcb8	bb95ff6b-0e80-45e2-9407-369056d35357	\N	DSAX005095	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q7310	in_stock	\N	\N	1900-01-20	\N	2026-08-27 13:52:52.296516+00	2026-08-27 13:52:52.296516+00	PORT2106-005095	\N	\N	\N	\N	f	f	F21050339 - 03272	1253.00	\N	\N	1900-01-20	ELY0164	f
bb739450-ae9a-4ae4-a6d6-f3c8de1b6c79	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009353	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	Affectation importée non résolue : Usager="-" ; Utilisateur="Clara GRANGER"	2026-08-27 13:52:52.297535+00	2026-08-27 13:52:52.297535+00	PORT2108-009353	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
94fa9a99-595c-4185-923d-67ae126d7bfc	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7FQF	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:52.298792+00	2026-08-27 13:52:52.298792+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
387e9d63-22fb-4bb0-8d90-1a7badda97bd	bb95ff6b-0e80-45e2-9407-369056d35357	\N	DSAP012214	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q739	in_stock	\N	\N	1900-01-21	TABLET2006-007778	2026-08-27 13:52:52.300131+00	2026-08-27 13:52:52.300131+00	PC-DSAP012214	\N	\N	\N	\N	f	f	F2007321-03913	1211.00	\N	\N	1900-01-21	ESI0158	f
c2e27d53-96ad-4b40-bd5a-ba4f1ffb3a22	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7606999	Wortmann_AG	FR1220785;1470505	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.302489+00	2026-08-27 13:52:52.304726+00	PORT2401-606999	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
3afb6cd9-3622-423c-945f-105fc3efd933	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677188	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	Affectation importée non résolue : Usager="-" ; Utilisateur="Andy Touré"	2026-08-27 13:52:52.305545+00	2026-08-27 13:52:52.305545+00	PORT2401-677188	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
fa4f6c78-1265-4f49-a5e4-dfe930bd1166	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677124	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	Affectation importée non résolue : Usager="-" ; Utilisateur="Suheda LEKESIZ"	2026-08-27 13:52:52.308299+00	2026-08-27 13:52:52.308299+00	PORT2401-677124	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
e2e4c3a2-5bc6-4bc0-b7ae-af3a299b8d62	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677191	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.310975+00	2026-08-27 13:52:52.313959+00	PORT2401-677191	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
44707ad9-f9f7-47a4-a4c9-9854fe30de53	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677186	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.3158+00	2026-08-27 13:52:52.318275+00	PORT2401-677186	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
1b25cf14-ad60-4877-92ae-e4c91753f68b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677247	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.320245+00	2026-08-27 13:52:52.322894+00	PORT2401-677247	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
6c4b1765-cace-42e3-80bc-78d719251158	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677205	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.324651+00	2026-08-27 13:52:52.327215+00	PORT2401-677205	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
408d1420-c53c-49c2-acff-5fbd5b85ba51	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677194	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.329058+00	2026-08-27 13:52:52.331614+00	Port2401-677194	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
b81f912f-afe4-4e4f-b459-37e1e1ca885c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677213	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.33292+00	2026-08-27 13:52:52.334677+00	PORT2401-677213	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
66c0fc17-776a-4fe9-8a88-10a88c5b9321	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677217	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.33634+00	2026-08-27 13:52:52.339174+00	PORT2401-677217	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
77f2e45e-268e-4ca4-b699-4a3705f89c38	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677198	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.341317+00	2026-08-27 13:52:52.344128+00	PORT2401-677199	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
6f02a407-07df-4c93-8b59-41309c136fdc	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	YMLE064889	Fujitsu	ESPRIMO P558	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.345688+00	2026-08-27 13:52:52.348215+00	PC-YMLE064889	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a088fc33-9349-4c6b-9871-3a80ca62bf99	bb95ff6b-0e80-45e2-9407-369056d35357	\N	DSAP012214	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q739	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.350098+00	2026-08-27 13:52:52.352595+00	PORT2008-012214	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
237576c5-f79a-4834-a63f-762032dd31f4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7796999	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.35471+00	2026-08-27 13:52:52.357229+00	PORT2406-220781	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
5c5bc088-1f4c-452c-a524-ac6adb3b938b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7796941	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.35877+00	2026-08-27 13:52:52.360516+00	PORT2406-796941	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
ac3423eb-09d5-496d-b118-5677a45175bd	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7797057	Wortmann_AG	FR1220781;1470608	in_stock	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.361201+00	2026-08-27 13:52:52.361201+00	PORT2406-797057	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
8acbbb09-4818-4dec-8bcc-345b59f4b67d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7796939	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.362778+00	2026-08-27 13:52:52.364778+00	PORT2406-779693	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
ac0d185a-6836-42cc-afba-a1ee31480167	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7797012	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.366317+00	2026-08-27 13:52:52.368484+00	PORT2406-797012	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
78c97c4f-054f-449d-a6b4-72b6f5dcbe74	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7797059	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	Affectation importée non résolue : Usager="ldellaccio@ELYADE" ; Utilisateur="Margaux AUJOULAT"	2026-08-27 13:52:52.370238+00	2026-08-27 13:52:52.370238+00	PORT2406-797059	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
407d9c93-0af3-4ddd-8f90-aafd7d3d4c2f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7797118	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:52.372185+00	2026-08-27 13:52:52.3743+00	PORT2406-797118	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
b2353066-a349-45cc-92ce-46b5a629c97f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7796993	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Emmeline FLORENTIN"	2026-08-27 13:52:52.375876+00	2026-08-27 13:52:52.375876+00	PORT2406-796993	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
dd5e764f-a804-4dab-99e9-d574a65947a6	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029551	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-30	Affectation importée non résolue : Usager="-" ; Utilisateur="Elodie DE BIASI"	2026-08-27 13:52:52.376942+00	2026-08-27 13:52:52.376942+00	PORT2110-029551	\N	\N	\N	\N	f	f	F22010429 - 00429	855.00	\N	\N	1900-01-30	ESI0171	f
ccaea36a-e26b-4cd0-a6a0-8542e33c0717	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7831796	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.378894+00	2026-08-27 13:52:52.380679+00	PORT2407-831796	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
325bf443-a67b-47dd-89b4-29a51bb8566c	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7831802	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.381996+00	2026-08-27 13:52:52.383899+00	PORT2407-831802	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
69d2dcf9-97fc-4ca7-a289-e1c631bc94cb	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7928836	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.387523+00	2026-08-27 13:52:52.390569+00	PORT2410-928836	\N	\N	\N	\N	f	f	FA2410-9486	730.55	\N	\N	1900-01-23	\N	f
44e6bf26-881c-4026-b223-d4f18ad56692	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890114	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.392248+00	2026-08-27 13:52:52.394625+00	PORT2410-890110	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
3c8290f5-da9d-4d9d-9ecc-24a7ebe9d198	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7928826	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.396347+00	2026-08-27 13:52:52.398227+00	PORT2410-928826	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
a6e23e07-d016-45d5-bc09-6a83ada9e4b4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890102	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.399832+00	2026-08-27 13:52:52.401862+00	PORT2410-890102	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
3bef5c8e-75cd-481f-b4bf-71d7e9855c1f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890136	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.403637+00	2026-08-27 13:52:52.405747+00	PORT2410-890136	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
28503f39-4b58-474d-9d90-a890cb6d4298	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890116	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.407212+00	2026-08-27 13:52:52.409543+00	PORT2410-890116	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
14f4afbc-187c-4d93-9c74-d2c6441c8e35	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890019	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.411833+00	2026-08-27 13:52:52.41517+00	PORT2410-890019	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
c14ac38c-c1dd-41bd-bbf3-b36f9359262c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890115	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:52:52.418015+00	2026-08-27 13:52:52.421344+00	PORT2410-890115	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
3174a146-794b-47cf-bc6f-e24699f2bf73	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021268	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Raphael ABEILLE"	2026-08-27 13:52:52.425512+00	2026-08-27 13:52:52.425512+00	PORT2502-021268	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
9c01634e-7a4e-484e-abe3-cdfc2c87d405	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021278	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.429594+00	2026-08-27 13:52:52.433088+00	PORT2502-021278	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
60818c0a-2db2-448d-bea6-1f7b2bd24a7b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021288	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.435771+00	2026-08-27 13:52:52.438981+00	PORT2502-021288	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
d8de54ea-ac31-4a43-9526-6396232ba18b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021290	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.441162+00	2026-08-27 13:52:52.444182+00	PORT2502-021290	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
7ac3e90b-f2fd-462b-9a8b-7911398867c4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021203	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.502627+00	2026-08-27 13:52:52.506329+00	PORT2502-021203	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
c5bb0233-ab70-498e-b157-c4aa0157592d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021280	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.508413+00	2026-08-27 13:52:52.511115+00	PORT2502-021280	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
a1e8ffa9-cdfb-468c-a8dd-9f0bf36f43c8	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7992500	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.512759+00	2026-08-27 13:52:52.515513+00	PORT2502-992500	\N	\N	\N	\N	f	f	FA2502-09996	769.00	\N	\N	2027-04-02	\N	f
62b707cf-5bb6-4b89-a9aa-6185eb1bdbb7	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7992501	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.519898+00	2026-08-27 13:52:52.523781+00	PORT2502-992501	\N	\N	\N	\N	f	f	FA2502-09996	769.00	\N	\N	2027-04-02	\N	f
ba73d2b0-14a5-405a-b818-b1e4a6de0c7d	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7992484	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.526591+00	2026-08-27 13:52:52.529572+00	PORT2502-992484	\N	\N	\N	\N	f	f	FA2502-09996	769.00	\N	\N	2027-04-02	\N	f
eac493d0-f097-427e-bee7-1ef988523654	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021285	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.531106+00	2026-08-27 13:52:52.53402+00	PORT2504-021285	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
1dcf0c6a-edff-4e76-99f5-41a31b5d68b1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021279	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.535817+00	2026-08-27 13:52:52.53852+00	PORT2502-021279	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
471b2e75-11bc-44db-ba71-c87c6f53043d	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R7992623	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:52:52.540993+00	2026-08-27 13:52:52.544534+00	PORT2502-992623	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
2e33fcae-85bc-4b2c-bd3f-ae9470c5b027	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R8060603	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-11-04	Affectation importée non résolue : Usager="-" ; Utilisateur="Jerome DUVAL"	2026-08-27 13:52:52.545804+00	2026-08-27 13:52:52.545804+00	PORT2504-060603	\N	\N	\N	\N	f	f	\N	769.00	\N	\N	2027-11-04	\N	f
40981cfa-4c42-4a87-9744-6fc1fe5662ce	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R8060609	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-11-04	\N	2026-08-27 13:52:52.548786+00	2026-08-27 13:52:52.552359+00	PORT2504-060609	\N	\N	\N	\N	f	f	\N	769.00	\N	\N	2027-11-04	\N	f
a7263e14-acbb-403a-a4c0-e33ff1fbb106	3981e88a-85b7-4a12-9342-dca750713f52	\N	GMBKCHA140743	AOC International (USA) Ltd.	24P1X	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.716071+00	2026-08-27 13:52:52.720034+00	24P1X	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a0f79bdc-9aa9-4690-ba85-973cb11e7d1e	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	PQHC4RXQT5	Apple Inc.	Mac16,10	assigned	\N	\N	1900-01-13	arm64/1702\nAffectation importée non résolue : Usager="dalyllreguia" ; Utilisateur="-"	2026-08-27 13:52:52.553847+00	2026-08-27 13:52:52.553847+00	Mac mini	\N	\N	\N	\N	f	f	3929/FR-LAB	547.70	\N	\N	1900-01-13	\N	f
03ff6d2c-7286-4d8b-9423-35d1cb856e6b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8081344	Wortmann_AG	FR1220829;1470878	in_stock	\N	\N	2025-11-04	\N	2026-08-27 13:52:52.55586+00	2026-08-27 13:52:52.55586+00	PORT2504-081344	\N	\N	\N	\N	f	f	\N	739.00	\N	\N	2027-11-04	\N	f
54195c87-6b75-4c01-b4d6-e359dbc0b01f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8081499	Wortmann_AG	FR1220829;1470878	assigned	\N	\N	2025-11-04	\N	2026-08-27 13:52:52.558131+00	2026-08-27 13:52:52.560826+00	PORT2504-081499	\N	\N	\N	\N	f	f	\N	739.00	\N	\N	2027-11-04	\N	f
73552151-386d-4f81-be6a-d5284e4f1ecb	d3d61f08-b7ab-4bd8-9815-b84e9c0dc057	\N	ISOPSI5EH8X225P0019	EasyHub	OPS I5 EH.8+	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.56265+00	2026-08-27 13:52:52.565229+00	TV2505-0019	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c9489d5e-9c99-45a9-b734-4bc555d6b701	c620d117-4e2a-40a7-88a6-59356c8a7522	\N	VMware-42 37 06 5b fe b2 21 f3-95 13 c5 e9 0a b5 24 97	VMware, Inc.	VMware Virtual Platform	assigned	\N	\N	\N	SRVAD (ELYADE)\nAffectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.567446+00	2026-08-27 13:52:52.567446+00	SRVAD	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5d1c31a5-3834-493f-8e57-dda8feec7eaa	c620d117-4e2a-40a7-88a6-59356c8a7522	\N	VMware-42 37 68 1d ba 92 35 95-de 23 2e fa dd f5 d4 e7	VMware, Inc.	VMware Virtual Platform	assigned	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@SRVAPP" ; Utilisateur="-"	2026-08-27 13:52:52.569843+00	2026-08-27 13:52:52.569843+00	SRVAPP	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d6dd2963-c2ea-42c2-8b57-77d00305043f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8204608	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.571871+00	2026-08-27 13:52:52.574149+00	PORT2506-204608	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8c7f1ef1-d20b-40b2-ba6c-586f030ac422	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8204615	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.576305+00	2026-08-27 13:52:52.578542+00	PORT2506-204615	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9eb2d449-b561-4f18-bb5e-9f5b66c7a9aa	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8204527	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.581722+00	2026-08-27 13:52:52.584423+00	PORT2506-204527	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
db6a32cf-c7b9-4907-88b1-d0811640c541	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8204533	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.585949+00	2026-08-27 13:52:52.587903+00	PORT2506-204533	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cdb8c2c5-28b0-46f7-b7a3-19b986e06d01	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R8190643	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.589726+00	2026-08-27 13:52:52.594438+00	PORT2506-190643	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c62cb68f-3da1-4a44-93bd-5e0635029242	bb95ff6b-0e80-45e2-9407-369056d35357	\N	WM36013UV2000166	Wortmann_AG	Terra mobile 360-13U v2	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.597547+00	2026-08-27 13:52:52.600167+00	PORT2506-606999	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
504309be-c3c5-447d-b2f3-909d607fd815	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R8190651	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.601891+00	2026-08-27 13:52:52.604206+00	PORT2506-190651	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8a408b20-7f08-4404-b227-215f0b3d1635	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277162	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.606153+00	2026-08-27 13:52:52.608798+00	PORT2508-277162	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e3e6e43f-58fb-4bee-9119-ecf78836f569	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277188	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.610675+00	2026-08-27 13:52:52.613544+00	PORT2508-277188	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
374693f8-d6c5-4d7d-8ad9-8c4379dd881f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277184	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.615724+00	2026-08-27 13:52:52.618417+00	PORT2508-277184	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7970f3a2-38db-402e-bd1d-1198302aa45e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277189	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.620436+00	2026-08-27 13:52:52.622863+00	PORT2508-277189	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7eee1aff-c151-45f3-b529-656ccc6712ab	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277200	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.624767+00	2026-08-27 13:52:52.627198+00	PORT2508-277200	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
18721009-def0-4c4b-9ba1-a87efd48a3be	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R8226155	Wortmann_AG	FR1220852;1470935	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.628865+00	2026-08-27 13:52:52.63112+00	PORT2508-226155	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1ba28d18-0a35-4a13-a7e7-f2caf8bbdfc8	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277201	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.633088+00	2026-08-27 13:52:52.635672+00	PORT2508-277201	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8b51f6ca-9bc1-4732-bd3b-605a40329413	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R8226112	Wortmann_AG	FR1220852;1470935	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.637595+00	2026-08-27 13:52:52.640251+00	PORT2508-226112	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
93d4e9a9-412a-40ab-b33c-833ae19f8719	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R8226133	Wortmann_AG	FR1220852;1470935	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.642432+00	2026-08-27 13:52:52.645291+00	PORT2508-226133	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d57058af-2bf3-4a40-8710-3d7773ee0dbb	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277190	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.647168+00	2026-08-27 13:52:52.649373+00	PORT2508-277190	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2a977f8e-2ee4-4875-9df3-de51d42f4496	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380475	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Paul MIANE"	2026-08-27 13:52:52.651777+00	2026-08-27 13:52:52.651777+00	PORT2511-380475	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e59824ae-d9f9-4973-b19d-0b330a014bd9	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380481	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	Affectation importée non résolue : Usager="fcatourze@ELYADE" ; Utilisateur="Grégoire MASSAT"	2026-08-27 13:52:52.654252+00	2026-08-27 13:52:52.654252+00	PORT2511-380481	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1b9e3f6a-18a0-4c91-95dd-addcb4f4feb2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380519	Wortmann_AG	FR1220831;1470889	in_stock	\N	\N	\N	\N	2026-08-27 13:52:52.655481+00	2026-08-27 13:52:52.655481+00	PORT2511-380519	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c8f99c13-bc7d-4ca8-ac63-823af817eb21	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380528	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.657405+00	2026-08-27 13:52:52.660456+00	PORT2511-380528	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
471c10b4-5dc7-4677-8b77-70a5112bdfe0	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380483	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.662573+00	2026-08-27 13:52:52.664305+00	PORT2511-380483	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
682dac50-adf9-486d-b992-7ee3f407634d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380485	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.665502+00	2026-08-27 13:52:52.667213+00	PORT2511-380485	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
695e0165-536f-49fd-9117-f199e4ef2e7b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380474	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.668822+00	2026-08-27 13:52:52.670625+00	PORT2511-380474	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
41fb5167-73d4-447c-bc95-2e0be34de0fa	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380489	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.671857+00	2026-08-27 13:52:52.673506+00	PORT2511-380489	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
066f2f9d-8414-4529-a84d-228ed49ae5df	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380525	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.67502+00	2026-08-27 13:52:52.676876+00	PORT2511-380525	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
be017b54-2b49-4018-a400-ed45eb464142	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380488	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.6782+00	2026-08-27 13:52:52.679856+00	PORT2511-380488	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
de3ac08c-fbc0-4533-9302-87c86521d69b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380463	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	Affectation importée non résolue : Usager="Quizz@PORT2511-380463" ; Utilisateur="Laetitia COUZINIER"	2026-08-27 13:52:52.681296+00	2026-08-27 13:52:52.681296+00	PORT2511-380463	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
31d1b026-51b4-4afa-ac36-69f79816a3b4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380520	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.682962+00	2026-08-27 13:52:52.684454+00	PORT2511-380520	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bc15c5ff-b792-4fcd-b23f-2ec2fdb48550	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380482	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.68546+00	2026-08-27 13:52:52.686894+00	PORT2511-380482	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6d1aa29a-fdc3-4909-8e22-a8ecf0a56d19	bb95ff6b-0e80-45e2-9407-369056d35357	\N	R8226104	Wortmann_AG	FR1220852;1470935	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.687978+00	2026-08-27 13:52:52.689518+00	PORT2508-226104	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
872d4e47-adaf-4a7e-8b01-d9f9f8cc24a0	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380473	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.690713+00	2026-08-27 13:52:52.692599+00	PORT2511-380473	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
c42ceec7-30f4-4cdd-8ce2-3ca31552c51a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380490	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.694497+00	2026-08-27 13:52:52.697253+00	PORT2511-380490	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
a305f92e-560d-41ea-9ac9-bc539af58712	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7321	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:52:52.69894+00	2026-08-27 13:52:52.701516+00	PL2492H	\N	\N	\N	\N	f	f	F2102276 - 00949	152.00	\N	\N	2022-09-02	ELY0154	f
f7be1298-9bd0-4d42-b82a-ac7e6d40bd8d	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187723630817	Iiyama North America	PL2493H	assigned	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Grégoire MASSAT"	2026-08-27 13:52:52.704568+00	2026-08-27 13:52:52.704568+00	PL2493H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ec79cce6-4b27-4296-a744-4f022ab849df	3981e88a-85b7-4a12-9342-dca750713f52	\N	11673JMA00519	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.706018+00	2026-08-27 13:52:52.708092+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f302655e-e370-422f-ba84-b1db64d42526	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4463	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.709019+00	2026-08-27 13:52:52.710899+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
b781387c-cf77-422f-aa8f-ec925a1543fa	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1017	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:52:52.711673+00	2026-08-27 13:52:52.713814+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
9a7eb301-33b1-4c9e-b9fe-8a0922374736	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067060	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.721425+00	2026-08-27 13:52:52.724677+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
629b46cf-8b32-4264-b401-3e3d0da3f329	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6943	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:52:52.726365+00	2026-08-27 13:52:52.728484+00	PL2492H	\N	\N	\N	\N	f	f	F21050250-03183	158.00	\N	\N	2022-11-05	ESI0165	f
2c2f6031-9c95-4126-a501-8442a836b0e6	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN43022L0Z	HPN	HP E24 G5	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.729923+00	2026-08-27 13:52:52.732207+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b9824ff6-4b2e-4b12-8314-0915868a5ac2	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T848782	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.734416+00	2026-08-27 13:52:52.736857+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
accabaed-6f4d-4813-a22f-dd213c46682d	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1698	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.738614+00	2026-08-27 13:52:52.740781+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
48644a59-3778-4ce8-b0a4-1ef1ca3a6a87	3981e88a-85b7-4a12-9342-dca750713f52	\N	RH81R92K11HI	Dell Inc.	DELL P2217H	in_stock	\N	\N	\N	\N	2026-08-27 13:52:52.741714+00	2026-08-27 13:52:52.741714+00	DELL P2217H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
758e7a12-b573-48a5-a815-4f8f3a13c87d	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1682	Iiyama North America	PL2492H	in_stock	\N	\N	\N	\N	2026-08-27 13:52:52.74296+00	2026-08-27 13:52:52.74296+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
173d8164-6448-4540-b14d-e09d87a2b15b	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T830126	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.745054+00	2026-08-27 13:52:52.747379+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8cbdeae8-2fa6-4693-b309-76551e05860d	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE004873	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.749353+00	2026-08-27 13:52:52.751661+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
24b7ad5d-fe51-443f-875f-5cfb56a93dec	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1016	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:52:52.752656+00	2026-08-27 13:52:52.754846+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-01	ESI0124	f
9c1528e8-762a-4660-8b64-e38a10b5ecc0	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE024307	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:52.756796+00	2026-08-27 13:52:52.758958+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1805318-02344	176.00	\N	\N	1900-01-30	ESI0064	f
b1e7c366-4de4-4389-9db0-a1eb6b1207ac	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T805642	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.760525+00	2026-08-27 13:52:52.762601+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
031aab57-9222-48f0-963e-c79e0a3a7bd3	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V167154	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.763793+00	2026-08-27 13:52:52.765665+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
864a1241-ff49-4453-a6da-712386e1f80b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4478	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.76643+00	2026-08-27 13:52:52.768244+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
771bc21e-4ba5-4f65-8233-7189e0fb0d99	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7309	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:52:52.769268+00	2026-08-27 13:52:52.771122+00	PL2492H	\N	\N	\N	\N	f	f	F2102274 - 00947	152.00	\N	\N	2022-09-02	ESI0116	f
4d900e14-5a7b-4618-90e3-affd49e66302	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C4010	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:52:52.772687+00	2026-08-27 13:52:52.774668+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0111	f
58f2f11b-0ee0-4200-a8ab-c7d496275fac	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C7007	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:52:52.776191+00	2026-08-27 13:52:52.778159+00	PL2492H	\N	\N	\N	\N	f	f	F21050247 - 03180	158.00	\N	\N	2022-11-05	ELY0161	f
1612d463-d72d-491c-a856-3a2e28fa35e1	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4477	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.77948+00	2026-08-27 13:52:52.781401+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
2aed4e95-25a1-450e-8f83-cbc84bad3625	3981e88a-85b7-4a12-9342-dca750713f52	\N	V0VCM1CM111S	Dell Inc.	DELL P2212H	retired	\N	\N	\N	\N	2026-08-27 13:52:52.782085+00	2026-08-27 13:52:52.782085+00	DELL P2212H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4f8c310e-0313-4e22-abef-ded83114eb5a	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T808176	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:52:52.783575+00	2026-08-27 13:52:52.785366+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1911287-06187	168.00	\N	\N	1900-01-19	ESI0074	f
bd2fba6c-2a34-459b-af96-ea6426545223	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7314	Iiyama North America	PL2492H	in_stock	\N	\N	2021-09-02	Affectation importée non résolue : Usager="fcatourze@ELYADE" ; Utilisateur="Frédéric CATOURZE"	2026-08-27 13:52:52.787803+00	2026-08-27 13:52:52.787803+00	PL2492H	\N	\N	\N	\N	f	f	F2102276 - 00949	152.00	\N	\N	2022-09-02	ELY0153	f
bdff1f10-ef19-47fe-8598-c96400e06ff0	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T830125	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:52:52.790531+00	2026-08-27 13:52:52.793455+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1911287-06187	168.00	\N	\N	1900-01-19	ESI0075	f
2ee2e1e1-6694-4219-98d7-f5ba78dd1f7e	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187714704538	Iiyama North America	PL2493H	assigned	\N	\N	2022-10-06	\N	2026-08-27 13:52:52.796184+00	2026-08-27 13:52:52.799368+00	PL2493H	\N	\N	\N	\N	f	f	F22060338 - 04388	181.00	\N	\N	2023-10-06	ELY0176	f
6404fdcb-ec82-40c0-8f95-643d720a5c88	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE024280	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:52.801274+00	2026-08-27 13:52:52.80372+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1805318-2344	176.00	\N	\N	1900-01-30	ESI0062	f
f051a158-9d6d-4670-8962-9c8b9d3942e5	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V115843	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.805891+00	2026-08-27 13:52:52.80864+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d717829f-01e0-4116-8c8e-18e55ce0914e	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066908	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-28	\N	2026-08-27 13:52:52.810879+00	2026-08-27 13:52:52.814064+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903379-01497	155.00	\N	\N	1900-01-28	ELY0120	f
defc356d-bc00-4ba6-8af1-906353eaf601	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC631326	Fujitsu Siemens Computers GmbH	B24-9 TS	assigned	\N	\N	1900-01-14	\N	2026-08-27 13:52:52.816619+00	2026-08-27 13:52:52.819253+00	B24-9 TS	\N	\N	\N	\N	f	f	F22060363 - 04413	224.00	\N	\N	1900-01-14	ESI0169	f
8500bf05-c1dd-4590-9ca6-cb051170aebd	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511153D2300	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:52:52.821168+00	2026-08-27 13:52:52.824565+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
60c06f87-3f50-4a9f-8684-58a18288cfe3	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T870628	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	in_stock	\N	\N	1900-01-28	\N	2026-08-27 13:52:52.825999+00	2026-08-27 13:52:52.825999+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F2006326-03272	180.00	\N	\N	1900-01-28	ESI0156	f
19cdc4ba-85d7-4d3d-b906-6d2303e5b8ff	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC607974	Fujitsu Siemens Computers GmbH	B24-9 TS	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:52:52.827955+00	2026-08-27 13:52:52.831537+00	B24-9 TS	\N	\N	\N	\N	f	f	F2008275 - 04507	180.00	\N	\N	1900-01-19	ELY0140	f
642229c4-b688-4835-9653-d71fbe2a3f66	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00273	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.833643+00	2026-08-27 13:52:52.836686+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c6ae6f1f-32a1-4dab-bb3d-6062f2bb7a73	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00855	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.838466+00	2026-08-27 13:52:52.841405+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
72e3c162-7447-473e-a2d3-dacc1b9b4c8a	3981e88a-85b7-4a12-9342-dca750713f52	\N	CNC2390F58	HPN	HP E24m G4	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.843351+00	2026-08-27 13:52:52.845776+00	HP E24m G4	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e3fcb5fd-0078-4215-9a1f-cdfa5c799c28	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889207	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:52.846623+00	2026-08-27 13:52:52.848585+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F22010431 - 00431	224.00	\N	\N	1900-01-30	ELY0169	f
0e27c974-5c41-410c-9b77-34f88ce5c26a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6938	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:52:52.850167+00	2026-08-27 13:52:52.852653+00	PL2492H	\N	\N	\N	\N	f	f	F21050251 - 03184	158.00	\N	\N	2022-11-05	ELY0162	f
e99d0525-8c32-45a7-b101-e3be2a611b11	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C7014	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.854323+00	2026-08-27 13:52:52.856982+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
36bbaf39-67c3-44d6-9ef4-f2553ba94dda	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511201D1865	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.858895+00	2026-08-27 13:52:52.861041+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e1d10124-49bb-46b6-b225-4ffe7f761947	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829992	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:52.862538+00	2026-08-27 13:52:52.864672+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0090	f
08dcff25-6af8-4da2-8c15-c0178dcfe5da	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T361611	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.866382+00	2026-08-27 13:52:52.868585+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c886de43-f4b0-4f37-b61b-8c6e28a7ee83	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807804	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.870601+00	2026-08-27 13:52:52.873071+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6e88752c-8a00-4118-94b9-e32955abf8ad	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4460	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.874923+00	2026-08-27 13:52:52.877283+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
f8395b0b-f039-4dd9-81fb-f4cd30bab28b	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829985	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:52.878996+00	2026-08-27 13:52:52.881137+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0088	f
75fad8a4-7f91-4511-9e7a-75f4a09fc416	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1014	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:52:52.882741+00	2026-08-27 13:52:52.884746+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
1f21eddb-4b2e-4144-b707-a18189791a6e	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511150D2358	Iiyama North America	PL2492H	in_stock	\N	\N	1900-01-12	\N	2026-08-27 13:52:52.885522+00	2026-08-27 13:52:52.885522+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
a08f1082-b427-4239-8429-1296c20f6625	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4465	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.887482+00	2026-08-27 13:52:52.889418+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
f65daf67-7b73-40c0-bfc8-128610e4f502	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C3995	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:52:52.943258+00	2026-08-27 13:52:52.946145+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0109	f
99e9a205-de2d-455f-b3d0-865b4a8f35e2	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00854	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.947064+00	2026-08-27 13:52:52.949281+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
90e35969-063f-4166-8560-9bd240c6cbf1	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T361618	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.951185+00	2026-08-27 13:52:52.953818+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6c1c69c4-3202-4fa2-8a1c-68fae009177b	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T405525	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-21	\N	2026-08-27 13:52:52.954732+00	2026-08-27 13:52:52.956848+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F2007320 - 03912	180.00	\N	\N	1900-01-21	ESI0113	f
b90de252-7cfe-440c-9e41-f478d848c2e8	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4470	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.959009+00	2026-08-27 13:52:52.961256+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
02977d1f-66d1-475c-bcbb-6cc1f0c9b602	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4391	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.963014+00	2026-08-27 13:52:52.965425+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
e8c20401-ce1b-4737-bc64-af0f7e134e80	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4461	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:52.967311+00	2026-08-27 13:52:52.969843+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
e3d6078f-e93b-433d-844a-c356edcbbdd4	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V122283	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.971541+00	2026-08-27 13:52:52.973852+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
81dda35c-f120-4ce5-8e53-296f7355e7d4	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066956	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.975614+00	2026-08-27 13:52:52.97801+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f93c4730-ca90-4d64-9e21-dde17cedc018	3981e88a-85b7-4a12-9342-dca750713f52	\N	2RK1Y4AK4H0B	Dell Inc.	DELL E2214H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.97999+00	2026-08-27 13:52:52.97999+00	DELL E2214H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a4d14608-e97b-4090-a9d9-e548a5351d41	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066963	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.984694+00	2026-08-27 13:52:52.987903+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
733dc0eb-fc54-4e8a-a9b4-595207a519f0	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1677	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.989715+00	2026-08-27 13:52:52.992125+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cdd1a2e1-c253-4bca-96ab-7a693ba6e3ef	3981e88a-85b7-4a12-9342-dca750713f52	\N	100003a1	LG Display	LGD_MP1.1_ LP129WT2-SPA6	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:52.994575+00	2026-08-27 13:52:52.994575+00	LGD_MP1.1_ LP129WT2-SPA6	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e33907c6-353f-44a1-8e51-d625ae566d12	3981e88a-85b7-4a12-9342-dca750713f52	\N	H1J01251019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:52:52.997303+00	2026-08-27 13:52:53.000366+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8bde2d36-3cd5-41ae-85cc-4cf4b9e30df9	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C3996	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:52:53.002036+00	2026-08-27 13:52:53.003805+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0108	f
876c4e22-5076-4b3c-8728-d185631144bd	3981e88a-85b7-4a12-9342-dca750713f52	\N	4P09M49NASXU	Dell Inc.	DELL E2414H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.00539+00	2026-08-27 13:52:53.006958+00	DELL E2414H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9d195e8d-5a98-48f8-ac22-326542d7c4fe	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1011	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:52:53.008421+00	2026-08-27 13:52:53.010023+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
e4ca18f9-33f3-4ce6-9b78-7254310f953e	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1687	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.011468+00	2026-08-27 13:52:53.01326+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e973db32-69d4-42ff-9073-058f8c1f5780	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T890735	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.014804+00	2026-08-27 13:52:53.016508+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
82dd34c7-8b30-45dc-b80d-ad6f642ec50c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066952	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-28	\N	2026-08-27 13:52:53.017349+00	2026-08-27 13:52:53.017349+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903379-01497	155.00	\N	\N	1900-01-28	ELY0121	f
69abe379-1ce3-4125-92e4-c1fed50f6310	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V115857	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.019261+00	2026-08-27 13:52:53.020946+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
efbea799-1918-4093-a216-6ed31808d540	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511150D2357	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:52:53.022325+00	2026-08-27 13:52:53.024312+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
8ed20b7f-ef2d-4251-b578-373516669447	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1679	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.026096+00	2026-08-27 13:52:53.027884+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
64b6e03b-a62a-4b30-a5d8-e6f7ff0e2f90	3981e88a-85b7-4a12-9342-dca750713f52	\N	1169213813269	Iiyama North America	PL2294H	assigned	\N	\N	2021-04-12	\N	2026-08-27 13:52:53.02926+00	2026-08-27 13:52:53.030979+00	PL2294H	\N	\N	\N	\N	f	f	FR1121HE4AEUI	136.54	\N	\N	2022-04-12	ESI0126	f
7cff8e86-09a3-4ec8-af7d-5a445176a411	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T808547	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.032529+00	2026-08-27 13:52:53.034213+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b41895e2-897a-4a0c-a175-c888bbd440b4	3981e88a-85b7-4a12-9342-dca750713f52	\N	4P09M49NAT0U	Dell Inc.	DELL E2414H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.035797+00	2026-08-27 13:52:53.035797+00	DELL E2414H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e7af77d9-55cd-4b30-a1bd-94e080f617e8	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE044676	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-29	\N	2026-08-27 13:52:53.036972+00	2026-08-27 13:52:53.036972+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1811529-05613	0.00	\N	\N	1900-01-29	ELY0119	f
a6a5f866-54b4-46d7-80aa-b50b3439a633	3981e88a-85b7-4a12-9342-dca750713f52	\N	29C295C85KCB	Dell Inc.	DELL P2214H	retired	\N	\N	\N	\N	2026-08-27 13:52:53.038218+00	2026-08-27 13:52:53.038218+00	DELL P2214H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
024e764a-98ef-4b75-ab80-14cc62ce24a3	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T808548	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.040308+00	2026-08-27 13:52:53.042302+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
016f2c5b-3c84-4f49-8306-a350d8dccde4	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T890738	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.043621+00	2026-08-27 13:52:53.04552+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
da76d859-afc0-4d91-8d64-49b01b2e0c9b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00265	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.047124+00	2026-08-27 13:52:53.049082+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f7438fa6-eee5-4323-8bad-cde143ffa645	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067068	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.050878+00	2026-08-27 13:52:53.053063+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
48271fa9-1065-4a7d-a26d-0db849056378	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066968	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.054982+00	2026-08-27 13:52:53.056987+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fb9ec0ae-4be5-496d-9b21-0093ccb4d470	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511125C3311	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:52:53.058575+00	2026-08-27 13:52:53.060567+00	PL2492H	\N	\N	\N	\N	f	f	F22040361 - 02807	183.00	\N	\N	1900-01-19	ELY0172	f
eea84635-5af1-4458-94ba-4dfae3d1e68a	3981e88a-85b7-4a12-9342-dca750713f52	\N	000002bb	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.062089+00	2026-08-27 13:52:53.064001+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
42783e57-9826-4a11-9769-b5e408a8070f	3981e88a-85b7-4a12-9342-dca750713f52	\N	12122244F3952	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:52:53.06544+00	2026-08-27 13:52:53.06723+00	PL2492H	\N	\N	\N	\N	f	f	0097532246	149.00	\N	\N	1900-01-24	ELY0189	f
4ce7cd82-4ac7-486d-94ef-4f08064d313d	3981e88a-85b7-4a12-9342-dca750713f52	\N	002127a1	LG Display	LGD_MP1.1_ LP129WT212166	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.068685+00	2026-08-27 13:52:53.070766+00	LGD_MP1.1_ LP129WT212166	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e6c5d23c-ee14-429d-a78b-6802bfbe5ab3	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187714704549	Iiyama North America	PL2493H	assigned	\N	\N	2022-10-06	\N	2026-08-27 13:52:53.072096+00	2026-08-27 13:52:53.073957+00	PL2493H	\N	\N	\N	\N	f	f	F22060338 - 04388	181.00	\N	\N	2023-10-06	ELY0176	f
e7a2ee99-d1b9-4c6a-b5fc-b318b9b6008a	3981e88a-85b7-4a12-9342-dca750713f52	\N	2RK1Y3BR5J2M	Dell Inc.	DELL E2214H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="administrateur@ELYADE/ggonendji@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.075494+00	2026-08-27 13:52:53.075494+00	DELL E2214H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d67aa5b5-4dcf-4ef6-9c65-53c8d04b3116	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7335	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:52:53.077184+00	2026-08-27 13:52:53.078946+00	PL2492H	\N	\N	\N	\N	f	f	F2102275-00948	929.00	\N	\N	2022-09-02	ESI0163	f
5a0aa1c6-b337-43eb-9254-06dbfdca657a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4466	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.080427+00	2026-08-27 13:52:53.082249+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
fb798749-172a-4c6a-b6df-85ee0b4cea06	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4474	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.083501+00	2026-08-27 13:52:53.085234+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
6d611e9c-c401-403a-bbe2-2be06a540b7f	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1709	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.086328+00	2026-08-27 13:52:53.087863+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d1c488f3-e6c6-4f40-a4fd-ebc4e5ac6f41	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889124	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.089869+00	2026-08-27 13:52:53.092333+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F22010431 - 00431	224.00	\N	\N	1900-01-30	ELY0169	f
9e43363b-f489-4127-aad4-25e046aa5de8	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE004872	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.094146+00	2026-08-27 13:52:53.096651+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a5dd26f2-e4ef-4972-b956-769b2b46daab	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN430221CH	HPN	HP E24 G5	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.0985+00	2026-08-27 13:52:53.100836+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
294d8e6c-0ac3-4327-b88e-22b1cecfbe7e	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V167139	Fujitsu Siemens Computers GmbH	B22T-7 Pro	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.102496+00	2026-08-27 13:52:53.102496+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c431e21e-095b-4bd6-aa4f-53db8c3b61cd	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6948	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.104201+00	2026-08-27 13:52:53.105935+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
eaf30617-6c9a-4668-a285-3ad142b8d548	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4464	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.107484+00	2026-08-27 13:52:53.109767+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
729778ef-8cd4-4964-b600-e01222de9127	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889170	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.111334+00	2026-08-27 13:52:53.113334+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	224.00	\N	\N	1900-01-30	ESI0171	f
43fac690-c7a5-4c01-92bc-3831176f6bce	3981e88a-85b7-4a12-9342-dca750713f52	\N	H1AK500000	Samsung Electric Company	SyncMaster	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.114981+00	2026-08-27 13:52:53.117415+00	SyncMaster	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
352d0a2b-f2ef-48c9-a44f-89fb354e9612	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4469	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.118791+00	2026-08-27 13:52:53.121502+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
90fe5efa-ceb6-40f6-ac55-1c247f0e9bec	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066962	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.122462+00	2026-08-27 13:52:53.12436+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
25a5b7d5-5ec3-4e40-8422-2d70d4eef5bb	3981e88a-85b7-4a12-9342-dca750713f52	\N	W7WH7283B9DS	Dell Inc.	DELL P2012H	retired	\N	\N	\N	\N	2026-08-27 13:52:53.125208+00	2026-08-27 13:52:53.125208+00	DELL P2012H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
991c7b13-5322-44ca-a5cf-f7abd7aaa536	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187720600697	Iiyama North America	PL2493H	assigned	\N	\N	2022-10-06	\N	2026-08-27 13:52:53.127397+00	2026-08-27 13:52:53.129369+00	PL2493H	\N	\N	\N	\N	f	f	F22060338 - 04388	181.00	\N	\N	2023-10-06	ELY0176	f
f5cc819a-800a-44a3-9b42-472d13eefe0f	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4476	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.130947+00	2026-08-27 13:52:53.132856+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
f12dfa98-eb40-41b5-bde7-f2f51a771c4b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1012	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:52:53.134383+00	2026-08-27 13:52:53.136104+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
9960b2a2-b047-4f7a-a690-0a2476b4707d	3981e88a-85b7-4a12-9342-dca750713f52	\N	RH81R92K108I	Dell Inc.	DELL P2217H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.137823+00	2026-08-27 13:52:53.13973+00	DELL P2217H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9332a7a3-83e8-4451-a691-bddeafce0bae	3981e88a-85b7-4a12-9342-dca750713f52	\N	INF.0	Iiyama North America	PL2492H	assigned	\N	\N	2022-11-05	\N	2026-08-27 13:52:53.14049+00	2026-08-27 13:52:53.14049+00	PL2492H	\N	\N	\N	\N	f	f	0097118425	175.00	\N	\N	2023-11-05	ESI0130	f
4fd7a203-1e49-4fbd-87d3-dc442e96dd69	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4459	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.141525+00	2026-08-27 13:52:53.143293+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
176a1449-68c3-4255-86d5-a8991e1ad44a	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807807	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.14483+00	2026-08-27 13:52:53.146715+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fb85c4cd-6e19-439f-b1be-92ec091840ee	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4471	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.148138+00	2026-08-27 13:52:53.149986+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
6905a37f-bec4-45bc-9740-9bfaaeba534d	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC608160	Fujitsu Siemens Computers GmbH	B24-9 TS	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:52:53.151375+00	2026-08-27 13:52:53.153316+00	B24-9 TS	\N	\N	\N	\N	f	f	F2008275 - 04507	180.00	\N	\N	1900-01-19	ELY0140	f
4b7e9678-87fa-41d6-a1e4-64ff465408e8	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511209E4514	Iiyama North America	PL2492H	assigned	\N	\N	2022-11-05	\N	2026-08-27 13:52:53.154103+00	2026-08-27 13:52:53.155628+00	PL2492H	\N	\N	\N	\N	f	f	0097118425	175.00	\N	\N	2023-11-05	ESI0130	f
ec38bcd7-5083-4dde-8944-d2d24e54a60f	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1005	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:52:53.157055+00	2026-08-27 13:52:53.158738+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
2a2a0138-8713-4135-ab74-04399ffc186f	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T890367	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.160245+00	2026-08-27 13:52:53.162079+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fce847d5-14be-4fc0-af9f-37a5428ec5dd	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN43022L02	HPN	HP E24 G5	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.163613+00	2026-08-27 13:52:53.165243+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e81a5bb6-50f8-448c-b449-755c6c178784	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T890757	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Nicolas DAUTEL"	2026-08-27 13:52:53.166125+00	2026-08-27 13:52:53.166125+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0bd3e746-0045-42fc-bc22-3fba1aa56ee7	3981e88a-85b7-4a12-9342-dca750713f52	\N	00000000SL0	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.168488+00	2026-08-27 13:52:53.171211+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ec533695-2763-428d-ba7e-c8cd388df400	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187723632378	Iiyama North America	PL2493H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="ldellaccio@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.173416+00	2026-08-27 13:52:53.173416+00	PL2493H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
544d0585-8b70-4507-878e-775838c320c8	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066847	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:53.176112+00	2026-08-27 13:52:53.178641+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903336-01454	155.00	\N	\N	1900-01-26	ESI0077	f
e076278e-0392-4c0e-95aa-9b3d8207ec44	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187723632381	Iiyama North America	PL2493H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.180689+00	2026-08-27 13:52:53.183651+00	PL2493H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
88134a96-263c-4858-a1e0-d8ebb6e1f578	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1013	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:52:53.185726+00	2026-08-27 13:52:53.187834+00	PL2492H	\N	\N	\N	\N	f	f	00968506235	171.31	\N	\N	2022-09-11	ESI0124	f
e3fac7b5-b383-4b1c-87f9-e3eff35361c1	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V122278	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.189173+00	2026-08-27 13:52:53.19096+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b13cda54-20a7-4e3a-8bd0-4f9db8634169	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7330	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:52:53.191796+00	2026-08-27 13:52:53.191796+00	PL2492H	\N	\N	\N	\N	f	f	F2102274 - 00947	152.00	\N	\N	2022-09-02	ESI0117	f
e4d67c02-ac03-4cf3-ab3e-7fee468267de	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBC023520	Fujitsu Siemens Computers GmbH	E22-8 TS Pro	retired	\N	\N	\N	\N	2026-08-27 13:52:53.192904+00	2026-08-27 13:52:53.192904+00	E22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
32fb8a8b-a93d-4732-98a3-07cb1f247f0c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067073	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-28	\N	2026-08-27 13:52:53.194628+00	2026-08-27 13:52:53.196318+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903379-01497	155.00	\N	\N	1900-01-28	ELY0119	f
214845ed-0d1d-42b5-8156-68065149a68a	3981e88a-85b7-4a12-9342-dca750713f52	\N	H1J01223019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.197453+00	2026-08-27 13:52:53.199153+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
01e6c80e-8d39-47be-a1d7-992527474221	3981e88a-85b7-4a12-9342-dca750713f52	\N	RH81R92K10GI	Dell Inc.	DELL P2217H	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.199949+00	2026-08-27 13:52:53.199949+00	DELL P2217H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
515dbf3e-ddbd-4108-94e9-6bc859d5142a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C4023	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:52:53.202374+00	2026-08-27 13:52:53.20501+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0112	f
35cd1782-5f72-494c-9911-3a856ffc77d9	3981e88a-85b7-4a12-9342-dca750713f52	\N	MCN01511019	BenQ Corporation	BenQ PD2705U	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.206782+00	2026-08-27 13:52:53.209284+00	BenQ PD2705U	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b5666646-b63b-4620-956f-d9bf11f83dc6	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C3997	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:52:53.211113+00	2026-08-27 13:52:53.213242+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0110	f
4e0c0323-e37a-4673-95f3-a9357b5f32ef	3981e88a-85b7-4a12-9342-dca750713f52	\N	INF.0	Iiyama North America	PL2492H	assigned	\N	\N	2022-11-05	\N	2026-08-27 13:52:53.214769+00	2026-08-27 13:52:53.216635+00	PL2492H	\N	\N	\N	\N	f	f	0097118425	175.00	\N	\N	2023-11-05	ESI0130	f
564b0676-a350-403f-9a37-b5a07f75aa37	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067069	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.217954+00	2026-08-27 13:52:53.219863+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e786df17-e6cf-4a51-a13f-fe77ff1a7bc3	3981e88a-85b7-4a12-9342-dca750713f52	\N	0000020c	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.221279+00	2026-08-27 13:52:53.223335+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ad5d7b93-0ec5-4d63-af1b-5555229d088a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511113C2835	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:52:53.22501+00	2026-08-27 13:52:53.226706+00	PL2492H	\N	\N	\N	\N	f	f	F21060389 - 04070	180.00	\N	\N	1900-01-24	ELY0165	f
53703171-b862-491d-9bd5-455afed32205	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4458	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.2279+00	2026-08-27 13:52:53.229922+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
cf0ca725-eb8f-480e-ba1a-16f10f7b02bc	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE200677	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:53.231494+00	2026-08-27 13:52:53.233834+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1910350-05629	146.00	\N	\N	1900-01-22	ELY0127	f
e123b65c-bedd-46b2-9352-8b298666f279	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE069037	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.234772+00	2026-08-27 13:52:53.236731+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d6c6d691-c28f-4722-8565-542ede62cc35	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807814	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.238095+00	2026-08-27 13:52:53.240061+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fe39ca45-df5b-437e-bd61-415b5ba0ca86	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6927	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:52:53.24185+00	2026-08-27 13:52:53.244043+00	PL2492H	\N	\N	\N	\N	f	f	F21050251 - 03184	158.00	\N	\N	2022-11-05	ELY0162	f
b88f6afc-a910-465f-882d-d41a1142e598	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6935	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:52:53.246148+00	2026-08-27 13:52:53.248369+00	PL2492H	\N	\N	\N	\N	f	f	F21050251 - 03184	0.00	\N	\N	2022-11-05	ELY0162	f
31c4888c-ccef-4d2c-8ea0-9f2bfd51717e	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4479	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.249986+00	2026-08-27 13:52:53.251962+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
a3a20549-42e9-4aa2-bc84-57f1359d0782	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T862725	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.25353+00	2026-08-27 13:52:53.255448+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
847e8eff-7afb-4722-b6f0-5f60d5941b39	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4462	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.25727+00	2026-08-27 13:52:53.259386+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
04e478f8-c944-4cc9-903d-e56600bc69af	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066955	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.260999+00	2026-08-27 13:52:53.263175+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4c0c8543-bae8-4851-929e-49bcc6b2c748	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC012372	Fujitsu Siemens Computers GmbH	B24-9 TS	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.264741+00	2026-08-27 13:52:53.266711+00	B24-9 TS	\N	\N	\N	\N	f	f	F2003556-01777	180.00	\N	\N	1900-01-30	ESI0099	f
0f537940-a2a3-4fed-97b3-1fb219e92bff	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T805595	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.268182+00	2026-08-27 13:52:53.269927+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
345d7b38-8723-4b8e-a2ee-2ecfe0d18eac	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V134217	Fujitsu Siemens Computers GmbH	B22T-7 Pro	in_stock	\N	\N	2017-05-05	Affectation importée non résolue : Usager="mgamboa-mathieu@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.271421+00	2026-08-27 13:52:53.271421+00	B22T-7 Pro	\N	\N	\N	\N	f	f	F1705156-01891	186.00	\N	\N	2018-05-05	\N	f
7b0fddbf-613b-47ab-83ee-30f1163e40bf	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807457	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:52:53.273132+00	2026-08-27 13:52:53.274781+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1911287-06187	168.00	\N	\N	1900-01-19	ESI0073	f
c6d65b19-16f6-4040-9c07-be8989f5c88b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511047C1640	Iiyama North America	PL2492H	assigned	\N	\N	2021-01-02	\N	2026-08-27 13:52:53.329216+00	2026-08-27 13:52:53.332646+00	PL2492H	\N	\N	\N	\N	f	f	F2102196-00869	149.00	\N	\N	2022-01-02	ESI0161	f
e7457b2a-6fd9-4a85-9f40-c6221fe390f2	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V115842	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.333827+00	2026-08-27 13:52:53.335921+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f6774f67-fa04-4448-9ecd-3c981e85e45b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4483	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.337879+00	2026-08-27 13:52:53.340069+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
70130e3a-7450-4d47-a2fd-76cdd89f75a2	3981e88a-85b7-4a12-9342-dca750713f52	\N	8130c155	Acer Technologies	Acer VG270	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.341683+00	2026-08-27 13:52:53.344017+00	Acer VG270	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3c15d1f1-55b6-45aa-862d-bc959789b082	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829966	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.34574+00	2026-08-27 13:52:53.34767+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cff76dce-addf-43de-9779-8268897f1c07	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1006	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:52:53.349447+00	2026-08-27 13:52:53.351398+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
32fe786e-2edd-4a38-9764-1232e0fdb0d3	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807451	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:52:53.35214+00	2026-08-27 13:52:53.353943+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1911287-06187	168.00	\N	\N	1900-01-19	ESI0076	f
c218b437-835c-4519-bf7a-66755d92458a	3981e88a-85b7-4a12-9342-dca750713f52	\N	H1J01254019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.355455+00	2026-08-27 13:52:53.357448+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a58a8dd6-41d8-4e0a-a8ab-baa0ce6f61d7	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4473	Iiyama North America	PL2492H	retired	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.3582+00	2026-08-27 13:52:53.3582+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
b0abd3e7-068c-430b-8e56-7e90f20c3999	3981e88a-85b7-4a12-9342-dca750713f52	\N	CNK02609Q1	Hewlett Packard	HP LE2201w	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.359634+00	2026-08-27 13:52:53.361259+00	HP LE2201w	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f5462a5c-4a0a-4336-89bc-105679f73d5c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE024872	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-13	\N	2026-08-27 13:52:53.362025+00	2026-08-27 13:52:53.362025+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1805202-02228	176.00	\N	\N	1900-01-13	ELY0107	f
55cdfb5f-d5c8-4218-93e0-bfb975d0a97c	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6976	Iiyama North America	PL2492H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Yannis DELMAS"	2026-08-27 13:52:53.36298+00	2026-08-27 13:52:53.36298+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2f1622c1-fe12-4b77-84b7-43ff33a2ecc6	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511150D2365	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:52:53.36476+00	2026-08-27 13:52:53.366749+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
41fd22c5-8471-4227-b245-28ce4afad6e0	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1707	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.368178+00	2026-08-27 13:52:53.370078+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fbdafd89-9925-4b3b-9082-27783b602f2b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00271	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.371632+00	2026-08-27 13:52:53.373689+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7ea8daa5-42b8-45b2-8c79-ad045833ef48	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4472	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.375243+00	2026-08-27 13:52:53.377292+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
a7d127fd-99f6-4bac-94e1-c5b493654d09	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511150D2366	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:52:53.378743+00	2026-08-27 13:52:53.380652+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
81ac6b1c-02da-40d7-9042-e725b6e92214	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511209E5057	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-28	\N	2026-08-27 13:52:53.38215+00	2026-08-27 13:52:53.384174+00	PL2492H	\N	\N	\N	\N	f	f	F22070907 - 05795	192.00	\N	\N	1900-01-28	ELY0180	f
8b4c9d48-660b-4928-bbb1-edd9efcc22a6	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829986	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:53.38506+00	2026-08-27 13:52:53.386964+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0089	f
2ae0fbb7-5c60-4a19-8e0d-ad3452a0db37	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511153D2333	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:52:53.387821+00	2026-08-27 13:52:53.389547+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
2a88168b-a333-4ed0-9747-20ba1a9a865b	3981e88a-85b7-4a12-9342-dca750713f52	\N	RH81R92K159I	Dell Inc.	DELL P2217H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="gestesi@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.39115+00	2026-08-27 13:52:53.39115+00	DELL P2217H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b4ea54f5-36b2-4db7-aea7-1a625eb07ef5	3981e88a-85b7-4a12-9342-dca750713f52	\N	0000003b	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.393098+00	2026-08-27 13:52:53.395066+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
89dc1624-cb93-4888-8087-0c7bd45927af	3981e88a-85b7-4a12-9342-dca750713f52	\N	11673JMA00307	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.396777+00	2026-08-27 13:52:53.398737+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e7412f06-6f50-4de9-90a6-d95b84386b6a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1672	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.400154+00	2026-08-27 13:52:53.402258+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
393fb8e0-890b-45b7-9285-a183668bab7e	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7320	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:52:53.403669+00	2026-08-27 13:52:53.405925+00	PL2492H	\N	\N	\N	\N	f	f	F2102274 - 00947	152.00	\N	\N	2022-09-02	ESI0118	f
75e267be-e52f-45b8-9754-0b68b6fd2dc1	3981e88a-85b7-4a12-9342-dca750713f52	\N	830000DC7800	Acer Technologies	AT2245	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.407676+00	2026-08-27 13:52:53.410001+00	AT2245	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
11a2e325-f7aa-4c87-b995-cd09b0e27d39	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V164428	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	2017-07-09	\N	2026-08-27 13:52:53.410879+00	2026-08-27 13:52:53.413588+00	B22T-7 Pro	\N	\N	\N	\N	f	f	F1709167-03618	186.00	\N	\N	2020-07-09	ELY0098	f
28c5e785-358d-4c30-9bf6-e7bb1e452f4b	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829994	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:53.415668+00	2026-08-27 13:52:53.41828+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0091	f
12170ac3-ec36-4e1e-9e6e-1d1a46d3ce97	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889129	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.41935+00	2026-08-27 13:52:53.421947+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F22010429 - 00429	224.00	\N	\N	1900-01-30	ESI0171	f
fb98bffb-c309-43f3-a0c1-0d0d5c9ebe13	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187714704563	Iiyama North America	PL2493H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:52:53.422872+00	2026-08-27 13:52:53.425565+00	PL2493H	\N	\N	\N	\N	f	f	F22050452 - 03659	181.00	\N	\N	1900-01-24	ELY0174	f
c350bc72-2edb-43ef-b1fe-135e68e46e32	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889128	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.427808+00	2026-08-27 13:52:53.430585+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F22010429 - 00429	224.00	\N	\N	1900-01-30	ESI0171	f
ed3bff67-c19f-4411-8d57-b0719d735357	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4475	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:52:53.432417+00	2026-08-27 13:52:53.435017+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
7f41329d-939b-460b-a00d-59265ec21e88	3981e88a-85b7-4a12-9342-dca750713f52	\N	4P09M49NAT5U	Dell Inc.	DELL E2414H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="epoeydomenge@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.437504+00	2026-08-27 13:52:53.437504+00	DELL E2414H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bb858bb7-cfdf-49cd-9d6f-79c8284703ce	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067076	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.439084+00	2026-08-27 13:52:53.441341+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dc4362fb-3265-47d3-b674-99d33d55828d	3981e88a-85b7-4a12-9342-dca750713f52	\N	H4ZR800114	Samsung Electric Company	U32R59x	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.443583+00	2026-08-27 13:52:53.446606+00	U32R59x	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dd8b3900-e91e-434b-94dd-7f8c22bce4ce	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN430221CD	HPN	HP E24 G5	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.448854+00	2026-08-27 13:52:53.453328+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
54d4a57c-0ad4-4790-8322-0781fa6c816f	3981e88a-85b7-4a12-9342-dca750713f52	\N	0C2MHNFN900290	Samsung	QE50T	in_stock	\N	\N	1900-01-26	\N	2026-08-27 13:52:53.455033+00	2026-08-27 13:52:53.455033+00	Samsung QE50T	\N	\N	\N	\N	f	f	F21040369 - 02562	792.00	\N	\N	1900-01-26	ELY0159	f
56d6d1b6-56d4-4c09-950e-df30d76459af	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511113C2824	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:52:53.458722+00	2026-08-27 13:52:53.463323+00	PL2492H	\N	\N	\N	\N	f	f	F21060389 - 04070	180.00	\N	\N	1900-01-24	ELY0165	f
d3aef508-787c-4987-b17f-d348faa5472a	3981e88a-85b7-4a12-9342-dca750713f52	\N	0681HNFM200347	Samsung Electric Company	DC49J	in_stock	\N	\N	2021-09-04	\N	2026-08-27 13:52:53.46497+00	2026-08-27 13:52:53.46497+00	Samsung DC49J	\N	\N	\N	\N	f	f	F1904259 - 01968	739.00	\N	\N	2022-09-04	ELY0152	f
b6b6ccef-8821-43be-ae88-1ec7dfd86684	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T406060	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-21	\N	2026-08-27 13:52:53.46751+00	2026-08-27 13:52:53.471247+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F2007320 - 03912	180.00	\N	\N	1900-01-21	ESI0115	f
2f38463b-42c7-42f1-86a5-51c8ef520cc2	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889139	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	in_stock	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.472303+00	2026-08-27 13:52:53.472303+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	224.00	\N	\N	1900-01-30	ESI0171	f
22de5b61-cc1c-4275-a52a-35947197ebbe	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511113C2820	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:52:53.473838+00	2026-08-27 13:52:53.475954+00	PL2492H	\N	\N	\N	\N	f	f	F21060388 - 04069	180.00	\N	\N	1900-01-24	ESI0121	f
c3c8d440-483e-44e2-9fd2-f1c9bee8d01b	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T406059	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-21	\N	2026-08-27 13:52:53.476929+00	2026-08-27 13:52:53.476929+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F2007320 - 03912	180.00	\N	\N	1900-01-21	ESI0114	f
532e0b09-4fea-4bbf-afed-10807a9e978a	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829984	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:53.478889+00	2026-08-27 13:52:53.481263+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0086	f
1dd71e5e-c3bb-4978-98bd-082742310a77	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187720600693	Iiyama North America	PL2493H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.483184+00	2026-08-27 13:52:53.485472+00	PL2493H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d5758bed-4ff6-4389-a758-9c54427454c4	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829995	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:53.486581+00	2026-08-27 13:52:53.486581+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0092	f
3c59b936-272f-4f7a-b2c7-10c5335f826c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE019706	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.487958+00	2026-08-27 13:52:53.487958+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
184f5e54-8b56-4ea4-9ccf-9de79bee4315	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066953	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.49067+00	2026-08-27 13:52:53.49067+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5a178539-6728-4297-8a97-a730c2cdeeb6	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE024322	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	retired	\N	\N	\N	\N	2026-08-27 13:52:53.492274+00	2026-08-27 13:52:53.492274+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a1460931-6267-4c4e-a1b5-debdf873ec37	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE028916	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.494294+00	2026-08-27 13:52:53.494294+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1805318-2344	176.00	\N	\N	1900-01-30	ESI0063	f
0cb85c66-54d3-4333-ae63-1878612100e1	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC012349	Fujitsu Siemens Computers GmbH	B24-9 TS	in_stock	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.495854+00	2026-08-27 13:52:53.495854+00	B24-9 TS	\N	\N	\N	\N	f	f	F2003556-01777	180.00	\N	\N	1900-01-30	ESI0099	f
705ac6d3-5214-406b-8532-6e43fc34a0a8	3981e88a-85b7-4a12-9342-dca750713f52	\N	0681HNFN100125	Samsung Electric Company	DC49J	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:52:53.497371+00	2026-08-27 13:52:53.49975+00	Samsung DC49J	\N	\N	\N	\N	f	f	F2003593-01814	739.00	\N	\N	1900-01-30	ESI0100	f
c81bfb90-10ee-42f7-9cab-0f32feebf613	3981e88a-85b7-4a12-9342-dca750713f52	\N	0681HNFMB00187	Samsung Electric Company	DC49J	in_stock	\N	\N	2020-06-10	\N	2026-08-27 13:52:53.500753+00	2026-08-27 13:52:53.500753+00	Samsung DC49J	\N	\N	\N	\N	f	f	0096075058	559.00	\N	\N	2021-06-10	ESI0107	f
1cb896ca-7481-44f1-b36e-e993f5787c7f	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829984	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:52:53.502204+00	2026-08-27 13:52:53.50479+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0087	f
d1f40047-c41b-4e6d-8225-d922909b9067	3981e88a-85b7-4a12-9342-dca750713f52	\N	01AJHNFM400516	Samsung Electric Company	DC55E	in_stock	\N	\N	1900-01-22	\N	2026-08-27 13:52:53.50588+00	2026-08-27 13:52:53.50588+00	Samsung DC55E	\N	\N	\N	\N	f	f	F1910351-05630	834.00	\N	\N	1900-01-22	ESI155	f
e68b453d-2d17-4230-9d45-6a804cd11900	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066920	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:52:53.507505+00	2026-08-27 13:52:53.507505+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903336-01454	155.00	\N	\N	1900-01-26	ESI0078	f
9413e14d-2a03-428c-a08c-9c46eaffbdfc	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C8343	Iiyama North America	PL2492H	assigned	\N	\N	2021-01-02	\N	2026-08-27 13:52:53.509241+00	2026-08-27 13:52:53.511548+00	PL2492H	\N	\N	\N	\N	f	f	F2102196-00869	149.00	\N	\N	2022-01-02	ESI0161	f
0d6e90e7-f0a9-42ff-867a-7ea70f0f4883	3981e88a-85b7-4a12-9342-dca750713f52	\N	LWAEE0188563	Acer Technologies	G246HL	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.513349+00	2026-08-27 13:52:53.515122+00	G246HL	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9fed90dd-f022-43d9-a772-d14126529c99	3981e88a-85b7-4a12-9342-dca750713f52	\N	ETV9P02365SL0	BenQ Corporation	BenQ PD2706U	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.516429+00	2026-08-27 13:52:53.518378+00	BenQ PD2706U	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
664ccc2b-cac1-40e7-b223-b9d07bf34444	3981e88a-85b7-4a12-9342-dca750713f52	\N	1165190802269	Iiyama North America	PL2730H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.519946+00	2026-08-27 13:52:53.522064+00	PL2730H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4ce36569-3836-4395-bde1-5d2bddec54d8	3981e88a-85b7-4a12-9342-dca750713f52	\N	29C295C85L6B	Dell Inc.	DELL P2214H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.523691+00	2026-08-27 13:52:53.525904+00	DELL P2214H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f4ded520-d5a3-4e4e-9ee2-318886f380c0	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511125C3309	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.528097+00	2026-08-27 13:52:53.531603+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0aa0ca79-86e7-4240-b68d-6d0507674257	3981e88a-85b7-4a12-9342-dca750713f52	\N	G9L01360SL0	BenQ Corporation	ZOWIE XL LCD	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.533907+00	2026-08-27 13:52:53.536429+00	ZOWIE XL LCD	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dc724d87-37dc-495e-b0fd-9c034ab88706	3981e88a-85b7-4a12-9342-dca750713f52	\N	A5LMTF081365	Ancor Communications Inc	ASUS VH242	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.538643+00	2026-08-27 13:52:53.541465+00	ASUS VH242	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5a648d50-2412-4e9b-9120-c0a2517b8fa2	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN430221C5	HPN	HP E24 G5	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.542887+00	2026-08-27 13:52:53.542887+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
66c7a4fa-69e0-4e7c-8d5e-5892c7b8fc0e	3981e88a-85b7-4a12-9342-dca750713f52	\N	00016c25	AOC International (USA) Ltd.	Q27G2WG4	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.546641+00	2026-08-27 13:52:53.553289+00	Q27G2WG4	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3efa309d-8a46-4b64-9087-6b2d99ded2f0	3981e88a-85b7-4a12-9342-dca750713f52	\N	000c54f0	Fujitsu Siemens Computers GmbH	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.55578+00	2026-08-27 13:52:53.559324+00	16/2019	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1d1d99c7-ec79-43dc-ac04-a841fb250066	3981e88a-85b7-4a12-9342-dca750713f52	\N	CNC1351NRP	HPN	HP 32 Display	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.561592+00	2026-08-27 13:52:53.564971+00	HP 32 Display	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c9d44038-4880-45c2-a9bb-ef3ac741474c	3981e88a-85b7-4a12-9342-dca750713f52	\N	000001e1	Microstep	MSI MP2412C	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.567492+00	2026-08-27 13:52:53.571911+00	MSI MP2412C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
96240e29-2392-4c75-b0fb-0b17505853b4	3981e88a-85b7-4a12-9342-dca750713f52	\N	H4ZM603547	Samsung Electric Company	U28E590	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.574424+00	2026-08-27 13:52:53.577115+00	U28E590	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5f8b6668-b759-43be-8629-13951b8c5bea	3981e88a-85b7-4a12-9342-dca750713f52	\N	01000e00	Samsung Electric Company	SAMSUNG	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.579305+00	2026-08-27 13:52:53.581874+00	SAMSUNG	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
04bd12bc-f7a6-41b2-84a7-b3111bb56c77	3981e88a-85b7-4a12-9342-dca750713f52	\N	LBLMDW008069	AUS	VZ279HEG1R	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="pdasilva@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.583969+00	2026-08-27 13:52:53.583969+00	VZ279HEG1R	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fa12c69b-215c-456a-8ccd-ecc3369a8cd7	3981e88a-85b7-4a12-9342-dca750713f52	\N	LBLMDW008053	AUS	VZ279HEG1R	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="pdasilva@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.586709+00	2026-08-27 13:52:53.586709+00	VZ279HEG1R	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
97cb824a-5378-439f-a716-8083c3905482	3981e88a-85b7-4a12-9342-dca750713f52	\N	000d9129	Fujitsu Siemens Computers GmbH	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.589165+00	2026-08-27 13:52:53.591186+00	22/2021	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f9f2b649-6a9c-47a2-8347-6137aacc4bbe	3981e88a-85b7-4a12-9342-dca750713f52	\N	309TFXX1P066	Goldstar Company Ltd	LG FHD	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.592818+00	2026-08-27 13:52:53.594885+00	LG FHD	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5cb68c16-f2c4-4875-ad96-1db6b6f822ce	3981e88a-85b7-4a12-9342-dca750713f52	\N	1214144620745	Iiyama North America	PL3494WQ	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.596306+00	2026-08-27 13:52:53.598223+00	PL3494WQ	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
74245c03-c9dc-48c8-8f2f-7675bb70a333	3981e88a-85b7-4a12-9342-dca750713f52	\N	11673JMA00059	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.599696+00	2026-08-27 13:52:53.601942+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
75eb0f9a-33a2-42c5-a564-52d990d571c5	3981e88a-85b7-4a12-9342-dca750713f52	\N	1214145220010	Iiyama North America	PL3494WQ	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.604185+00	2026-08-27 13:52:53.606555+00	PL3494WQ	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d2ab5b17-5a18-4118-a563-00becb735928	3981e88a-85b7-4a12-9342-dca750713f52	\N	CNC9302PKM	HPN	HP E223	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.608716+00	2026-08-27 13:52:53.612812+00	HP E223	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c0c84983-cf6b-46d1-922d-7afe8d4799bc	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829980	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.615458+00	2026-08-27 13:52:53.618572+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c0d789de-f290-425e-b681-78b4079ea1f7	3981e88a-85b7-4a12-9342-dca750713f52	\N	6CM5140ZM1	Hewlett Packard	HP E201	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.624542+00	2026-08-27 13:52:53.630266+00	HP E201	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
245e41ef-21ea-4d7f-91d0-bb307c01ca6f	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352612779	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.635285+00	2026-08-27 13:52:53.64001+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c4ce777d-f7b9-4a31-bbf8-2f299e255f3d	3981e88a-85b7-4a12-9342-dca750713f52	\N	00000133	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.643752+00	2026-08-27 13:52:53.648433+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dd7c2ba2-7e03-481c-aab1-afd7d4eb74af	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511407	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.652078+00	2026-08-27 13:52:53.656423+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5a110a5f-bfb1-4da8-bd28-f727d7f496ef	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513439	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.659143+00	2026-08-27 13:52:53.665811+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8b23c6a0-a239-4b63-ac0d-710e4ccf5b00	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511074	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.669778+00	2026-08-27 13:52:53.674755+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1c3dab3e-77b4-4ef6-96d5-ed7d94e0d266	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511403	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.677677+00	2026-08-27 13:52:53.681928+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cb1d49d8-bb1c-46e7-a4f9-632e54a9f4d8	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511410	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.683511+00	2026-08-27 13:52:53.687486+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
41928a28-2d13-49b8-845d-4f25f0b9149b	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513322	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.690694+00	2026-08-27 13:52:53.695561+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
59f0f77b-15e0-4642-a8ce-2cfd7e18e829	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511404	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.699271+00	2026-08-27 13:52:53.703938+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9179b9a7-4f41-4db9-a7a7-0a786617e8c7	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511071	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.707673+00	2026-08-27 13:52:53.712765+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
15832213-cb29-441a-98a6-6a6b5d8438c3	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511394	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.720061+00	2026-08-27 13:52:53.722663+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d1f4d1b2-09e3-4a97-aaaf-55c2c66de3e3	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511390	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.724101+00	2026-08-27 13:52:53.726246+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4cbfcc9a-cd7e-4106-ba27-fe79b5ca118d	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511412	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.727803+00	2026-08-27 13:52:53.729778+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
008628d6-e55c-45c8-b428-902947d54b1e	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511077	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.731009+00	2026-08-27 13:52:53.732669+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bf04a170-8f66-4dba-9a5c-9be85258ddb3	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511413	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.733975+00	2026-08-27 13:52:53.738688+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f443171c-0b54-4c4e-b4fb-3914a2091978	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511395	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.745398+00	2026-08-27 13:52:53.748091+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9110e06c-f9e6-4224-91a0-5076f0d94833	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513424	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.74967+00	2026-08-27 13:52:53.751956+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e678c8bf-3c62-4a3f-9b86-bea30eb080c3	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511132	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.753584+00	2026-08-27 13:52:53.756314+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5d2187d0-51ad-434e-91c0-d6a03c6844d2	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513423	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.758199+00	2026-08-27 13:52:53.760262+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
254573c3-e9b4-438e-bf91-3ba83b95e9ac	3981e88a-85b7-4a12-9342-dca750713f52	\N	00000207	Iiyama North America	PL2595W	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.814918+00	2026-08-27 13:52:53.814918+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3d5c7f32-536d-4347-ba51-0a389dbccd5b	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511076	Iiyama North America	PL2497H	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.817083+00	2026-08-27 13:52:53.817083+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7a08093b-1495-4bf9-add8-3c7277969478	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513442	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.81939+00	2026-08-27 13:52:53.822473+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
de719553-79a7-4c33-981a-7d2c37e77fa7	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511417	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.824695+00	2026-08-27 13:52:53.827351+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
abeddb0a-9a03-43a2-a92c-4712a63c2350	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V164429	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.829102+00	2026-08-27 13:52:53.832222+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
27c88ade-78b2-43d5-bf8f-b89cbb1e5877	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511420	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.834556+00	2026-08-27 13:52:53.837327+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
85a8a166-5520-47bd-a51d-bcb733e51506	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V167138	Fujitsu Siemens Computers GmbH	B22T-7 Pro	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:52:53.839905+00	2026-08-27 13:52:53.839905+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8d672151-9329-4986-98a7-0aef2a6ab9a9	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513422	Iiyama North America	PL2497H	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.842071+00	2026-08-27 13:52:53.842071+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c4bbf0df-504f-4e0d-a3ce-9bd041c168ff	3981e88a-85b7-4a12-9342-dca750713f52	\N	NALMQS027212	AUS	VG27A	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.845226+00	2026-08-27 13:52:53.849137+00	VG27A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
88e35168-489e-442e-aa0a-2e74b2a1d081	3981e88a-85b7-4a12-9342-dca750713f52	\N	H4PT305198	Samsung Electric Company	LS24AG30x	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.851235+00	2026-08-27 13:52:53.855857+00	LS24AG30x	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
af58d9fb-ee20-4c0b-85b5-0f37c7082777	3981e88a-85b7-4a12-9342-dca750713f52	\N	SN-000000001	Mars-Tech Corporation	MON-SIS289	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.858778+00	2026-08-27 13:52:53.862157+00	MON-SIS289	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
5e160da2-3b10-46b4-911a-257cd10f83dd	3981e88a-85b7-4a12-9342-dca750713f52	\N	H9XS308029	Samsung Electric Company	SyncMaster	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.86503+00	2026-08-27 13:52:53.86861+00	SyncMaster	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
e9cb2078-c1dd-40d4-8950-fd44343c9387	3981e88a-85b7-4a12-9342-dca750713f52	\N	ETH1J01251019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.870878+00	2026-08-27 13:52:53.874422+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
a4d3a47c-d2c5-4aa8-a871-d4c1fe357f28	3981e88a-85b7-4a12-9342-dca750713f52	\N	ETH1J01254019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.877091+00	2026-08-27 13:52:53.880634+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
7136d1f2-c5db-4939-b639-42e5a5943630	3981e88a-85b7-4a12-9342-dca750713f52	\N	0004a04c	Goldstar Company Ltd	LG HDR 4K	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.882595+00	2026-08-27 13:52:53.884828+00	LG HDR 4K	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
92316360-32b7-4ae8-97a8-a49b14f598fe	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR018858	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.885801+00	2026-08-27 13:52:53.885801+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
32df79e4-77c5-4088-869e-5ce30577b0dd	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR018868	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.88713+00	2026-08-27 13:52:53.88713+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a5ebbd4e-b631-4b45-9b90-1b5dcac43fb2	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR018878	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.888374+00	2026-08-27 13:52:53.888374+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
373e4feb-5593-4628-9b0b-0e2fb22a5a52	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR018888	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.889651+00	2026-08-27 13:52:53.889651+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4a1cee07-7792-429e-a9b4-1a81200d0700	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR018818	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.890766+00	2026-08-27 13:52:53.890766+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
26b8472b-7ef9-4245-889c-a4ceb665d39a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR018828	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.892194+00	2026-08-27 13:52:53.892194+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6e9ab2bc-82bf-4641-ab6a-e5eaab2dba86	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR018838	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.895174+00	2026-08-27 13:52:53.895174+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2813ef64-6bf5-4ae0-bf94-97a3e206a2ae	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR018848	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.897478+00	2026-08-27 13:52:53.897478+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ae156a6a-5c63-48db-8f10-5b65dc2b2853	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR01A218	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.899684+00	2026-08-27 13:52:53.899684+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5edc9bbb-3171-41f3-a494-db9ae461184b	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2336MR019028	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.90155+00	2026-08-27 13:52:53.90155+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
664a701b-524d-4cd2-9e99-c404263915a2	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308MR014AD8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.903724+00	2026-08-27 13:52:53.903724+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c75f903a-5483-445f-a7cd-9d807085246e	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2236MR011A48	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.905582+00	2026-08-27 13:52:53.905582+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ccca7fcb-4f7f-4fdb-9b7f-f5a252ad86e7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2236MR011A38	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.907262+00	2026-08-27 13:52:53.907262+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
574ac6a9-cd95-4c91-88ef-84c5ca4c2897	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2136MR3C8BF8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.90951+00	2026-08-27 13:52:53.90951+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
008af8f1-d19d-4eb7-b89f-779b4382402b	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM014AA8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.91153+00	2026-08-27 13:52:53.91153+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0e5fdc8e-d306-43d8-af4d-d7fd825f9dfe	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR0135E8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.913752+00	2026-08-27 13:52:53.913752+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8bcd9315-0971-432d-aa2a-891bd57dfc94	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2204MR099CC8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.915967+00	2026-08-27 13:52:53.915967+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fde3b95e-4b76-4255-b151-dd93718236e9	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR0135F8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.918745+00	2026-08-27 13:52:53.918745+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
78ed380f-2856-4c1a-8fd5-decc3986ec44	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2136MR3C8C28	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.923771+00	2026-08-27 13:52:53.923771+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5ba38516-59f7-4529-b0df-96668da10b5e	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2334MR063808	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.927087+00	2026-08-27 13:52:53.927087+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ffc65759-0fa0-4dde-97d8-e85ad8bb7e3f	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2216MR01CBA8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.929882+00	2026-08-27 13:52:53.929882+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c042e921-e001-4f15-9278-895026a88e55	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308MR014AC8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.932362+00	2026-08-27 13:52:53.932362+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1258269c-e469-42c6-9f13-7a5c240168d4	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR00FC98	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.934692+00	2026-08-27 13:52:53.934692+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9b4ff84c-ea22-4a03-a1d8-4444edac111d	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2216MR01CBC8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.937211+00	2026-08-27 13:52:53.937211+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0e6c1c24-d1ba-45a0-ba70-cfbe6a0bbf5b	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR00FCD8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.939169+00	2026-08-27 13:52:53.939169+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6a450729-3b99-4f88-98ad-e4bb66096ae1	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2136MR3C8C48	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.941015+00	2026-08-27 13:52:53.941015+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
525d5110-3242-4cd8-ad58-71fe89dbe65d	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2219MR036A08	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="Marie RAUZY" ; Utilisateur="-"	2026-08-27 13:52:53.944913+00	2026-08-27 13:52:53.944913+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7e29d409-eec5-4449-ae80-4bf427852f13	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2136MR3C8C38	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.947048+00	2026-08-27 13:52:53.947048+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8e46e6f2-bc01-4d73-93eb-c7dc80de7d11	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR00FCB8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.948955+00	2026-08-27 13:52:53.948955+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
76e5295e-767d-494e-bbc3-212a0bc3ecf7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22D058	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.950999+00	2026-08-27 13:52:53.950999+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
178cc9de-3fd9-450c-9e98-b7c2a134d029	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22D0A8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.952907+00	2026-08-27 13:52:53.952907+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
39f37467-7af0-4ecc-9396-07d9869ff579	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22D068	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.95485+00	2026-08-27 13:52:53.95485+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cf1cd268-94a0-40f2-bba7-da1a80aa3e8b	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22D078	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.95672+00	2026-08-27 13:52:53.95672+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6287575e-9472-478c-8287-9e006fecfc11	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22D088	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.958661+00	2026-08-27 13:52:53.958661+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cf4fd09d-4c4d-4d67-8a25-d83c70d30f15	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22D098	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.960298+00	2026-08-27 13:52:53.960298+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5413f30c-93ef-424c-b0f9-969a3560de5c	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22D0B8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.961702+00	2026-08-27 13:52:53.961702+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7e8b546b-2bed-4629-b2e6-4e22affc7754	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22C738	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.96305+00	2026-08-27 13:52:53.96305+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0284f027-1852-4399-97d9-bf13a7d64473	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22D0C8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.964483+00	2026-08-27 13:52:53.964483+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7eaa51dd-aaed-4356-9c20-e882b79cfdf5	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22C6F8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.965968+00	2026-08-27 13:52:53.965968+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3c90d82f-bdd8-4d3c-8ec4-0bd47078b334	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22C748	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.967412+00	2026-08-27 13:52:53.967412+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1806d420-560b-416a-993b-69e8ea25afd2	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22C6D8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.968791+00	2026-08-27 13:52:53.968791+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a1cf9053-6940-4b87-a1c5-4d23a4499a4c	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22C6E8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.970364+00	2026-08-27 13:52:53.970364+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
951d3809-470e-45bd-8403-4725f4486b93	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22C718	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:53.971728+00	2026-08-27 13:52:53.971728+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6cf87928-30d2-4c54-b201-49270c3a0688	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2401MR22C708	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.973073+00	2026-08-27 13:52:53.973073+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0e6f6aeb-d4a8-4ec1-99be-76409202401a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2204MR09A8C8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.974355+00	2026-08-27 13:52:53.974355+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b74bd52a-0674-494c-8bd3-818636fc5ae9	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2236MR011A68	Logitech	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:53.975493+00	2026-08-27 13:52:53.975493+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0ab6c4a9-49f3-4bf2-808c-7a6d899918cb	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM014AE8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.976986+00	2026-08-27 13:52:53.976986+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b719842b-45e8-46e7-b0b5-9744fc52116f	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR013938	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.978463+00	2026-08-27 13:52:53.978463+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5787af0c-016d-4d95-9892-d8c18d408c8d	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308MR014A98	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.979847+00	2026-08-27 13:52:53.979847+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
69ceb6cd-9f29-4389-87c1-72120e700165	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR0135B8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.980989+00	2026-08-27 13:52:53.980989+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0bb3d222-98d7-4d82-8373-6e6548e60eb0	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM014B08	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.982257+00	2026-08-27 13:52:53.982257+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
01830078-968b-4a9e-9c76-c04cf5129b22	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2219MR0369E8	Logitech	\N	assigned	\N	\N	\N	0033\nAffectation importée non résolue : Usager="-" ; Utilisateur="Ludovic CHAUBET"	2026-08-27 13:52:53.983641+00	2026-08-27 13:52:53.983641+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6815371d-b7c3-44f0-84a5-5f58e688ee4a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2216MR01B768	Logitech	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:53.985084+00	2026-08-27 13:52:53.985084+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
37af637a-a59b-4524-84fc-545d77227600	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR013FC8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.986518+00	2026-08-27 13:52:53.986518+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2b4ba731-7e2b-4e36-98e7-309f665141fd	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM014AF8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.987725+00	2026-08-27 13:52:53.987725+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f249763e-f02a-4cba-86ae-9ef82c549e30	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2219MR0369F8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.989025+00	2026-08-27 13:52:53.989025+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1022b302-3785-40a9-8b34-03daa12a4520	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2219MR0369EA8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.990607+00	2026-08-27 13:52:53.990607+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0e8195df-2245-49ff-afac-649b9a020fcf	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM014BC8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:53.998818+00	2026-08-27 13:52:53.998818+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dc5a1f78-647f-48f2-a252-0dbe9e9ea675	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2216MR01B778	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.001169+00	2026-08-27 13:52:54.001169+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
06a0e9f4-279b-4756-80b3-5e337a7e0c65	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2136MR3C84E8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.003912+00	2026-08-27 13:52:54.003912+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c4e815ab-a61b-45ff-8a3b-a8aa50abcbe5	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR00FCA8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.006632+00	2026-08-27 13:52:54.006632+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c455cb02-3e35-4744-89f6-1dd8c20c5562	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2334MR0637F8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.009121+00	2026-08-27 13:52:54.009121+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f5da5e9f-f21d-42d2-bd56-efeb1892ee44	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM014AAB8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.02182+00	2026-08-27 13:52:54.02182+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e33573c4-d363-4d07-9a46-44367def4949	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2334MR0637A8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.028789+00	2026-08-27 13:52:54.028789+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f62f91c9-3f5c-4be7-9ab9-a1978fc108b6	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2204MR09A878	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.034702+00	2026-08-27 13:52:54.034702+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0798f247-3fec-4e10-85b6-5e3da46107a6	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2236MR011A18	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.03774+00	2026-08-27 13:52:54.03774+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f9c79638-1e05-46f1-bdf3-77ec651ea2f1	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM00A8D8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.043056+00	2026-08-27 13:52:54.043056+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
425a73da-7a77-4b89-9a42-b4820d9e1ebb	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM0125C8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.045832+00	2026-08-27 13:52:54.045832+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
05131027-b95e-4387-8989-becc985e5215	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2334MR0637E8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.048603+00	2026-08-27 13:52:54.048603+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e33c70ea-aa47-4388-bc76-9b2278df5f98	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM00A8F8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.053252+00	2026-08-27 13:52:54.053252+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
46857321-cce9-4c40-af1d-d648ecb5b9af	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM0125B8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.055952+00	2026-08-27 13:52:54.055952+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
838e620b-3321-4bc7-a916-435545a979c5	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM00A908	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.058647+00	2026-08-27 13:52:54.058647+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
76459bcf-59c6-4971-b20b-ef7faa0a0cdd	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2236MR011A28	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.061835+00	2026-08-27 13:52:54.061835+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5097a30c-b9af-4bfc-b4cc-bea61c1148fe	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2216MR01B788	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.063651+00	2026-08-27 13:52:54.063651+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
98ef2680-8afa-416b-bc42-08ebb038f939	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2308RM00A8E8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.065151+00	2026-08-27 13:52:54.065151+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f85a19ff-ab61-4cd4-ba55-8b01b2ef4638	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2253MR0135D8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.066544+00	2026-08-27 13:52:54.066544+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fa85469d-660b-4e3c-90a0-6d07c32b0fd7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2204MR09A8A8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.067972+00	2026-08-27 13:52:54.067972+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
477ee7bc-79e9-45cc-88b9-fdb77d790685	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2216MR01B758	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.070226+00	2026-08-27 13:52:54.070226+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7bf7b7d5-4f03-4088-bdc5-a201e30d972e	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR141C98	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.072081+00	2026-08-27 13:52:54.072081+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9ce044b6-506a-4eb8-b48f-1c28499eb4d0	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR141CA8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.073424+00	2026-08-27 13:52:54.073424+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3dd8d66b-d641-41c8-9459-82cea328cd56	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR141CC8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.075029+00	2026-08-27 13:52:54.075029+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f19a4fce-5eb1-4ee7-b7cd-e2bfa69e10cf	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR141CB8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.076103+00	2026-08-27 13:52:54.076103+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2ee825f4-c4c2-4783-96c0-808391335d08	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR141CD8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.077334+00	2026-08-27 13:52:54.077334+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7484d879-9c0a-47bf-b0e2-19bae3922b4b	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR141CF8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.078592+00	2026-08-27 13:52:54.078592+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1df32cf9-b498-4ab3-8325-9891f540a688	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR141D08	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.079769+00	2026-08-27 13:52:54.079769+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0e8a68e1-80f4-4510-bb19-9e5d3f30b7e3	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR141CE8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.139921+00	2026-08-27 13:52:54.139921+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
448df3df-8b7b-44ba-a822-14bc379933bd	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR13DF18	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.14379+00	2026-08-27 13:52:54.14379+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
576c7582-b918-47dc-964c-04db403f8e0b	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2423MR13DF28	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.147982+00	2026-08-27 13:52:54.147982+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
547b7248-67f2-46b6-8ddb-e8471171bc7d	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2424LVC2E3E9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.150687+00	2026-08-27 13:52:54.150687+00	Logitech Lift - Vertical Droite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f8c50066-06c8-472b-8212-f35ee46718b8	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2433LVP1KTA9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.153002+00	2026-08-27 13:52:54.153002+00	Logitech Lift - Vertical Droite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
13707bfc-d989-4f77-bd57-3b0e770e31b2	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2147SC800X29	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.155953+00	2026-08-27 13:52:54.155953+00	Clavier Logitech ERGO K860 For Business	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4724bdb4-0455-402d-bde3-2e520a5ae09c	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2603C8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.161503+00	2026-08-27 13:52:54.161503+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cf83cc54-3f33-491c-8615-7216102720b1	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2603E8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.163542+00	2026-08-27 13:52:54.163542+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2a7599f7-c472-4640-a196-f5519aaff378	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR260378	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.165029+00	2026-08-27 13:52:54.165029+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bd890e2d-75bb-4a99-8545-30394eacbdb8	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR260198	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.169407+00	2026-08-27 13:52:54.169407+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
93d5d211-ab7f-48bd-beba-164f81042693	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR260188	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.174166+00	2026-08-27 13:52:54.174166+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0b8e819b-aa09-44c6-aca3-6bd4a2442df0	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2603B8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.176015+00	2026-08-27 13:52:54.176015+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
01c10788-6fdf-4d3c-ad1a-63ca4b7d9723	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR260388	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.177435+00	2026-08-27 13:52:54.177435+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4e3d1b34-9bd1-42a7-91f8-43c7797470f7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2603A8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.178959+00	2026-08-27 13:52:54.178959+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3286ae3b-add7-4fbc-b309-9d6cd6a643b4	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2603D8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.180571+00	2026-08-27 13:52:54.180571+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5d07ad2f-b0cf-4444-9d95-1a4918e0b217	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2601E8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.182455+00	2026-08-27 13:52:54.182455+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
89102b35-c798-4ef8-884a-f8d1231194ba	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2601A8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.184289+00	2026-08-27 13:52:54.184289+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
82d3dbe9-4b25-4d70-92a8-e9c2d94fa4e8	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2601D8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.185921+00	2026-08-27 13:52:54.185921+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bd5dfa1a-f5e2-4fda-ad2f-a16427d74802	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2601B8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.187664+00	2026-08-27 13:52:54.187664+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
177ab941-ff6e-4c92-a02e-9adcb4fee190	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2411MR2601C8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.189721+00	2026-08-27 13:52:54.189721+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b3700ec9-83c1-4a24-bdd1-cedc4b6c31c8	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa524b03304	XP-PEN	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.191431+00	2026-08-27 13:52:54.191431+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
70a2c978-1c80-4be5-92e0-868cb13f334d	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa524b03260	XP-PEN	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.193963+00	2026-08-27 13:52:54.193963+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
af1d02f1-b4fc-4e64-8453-05e368481a02	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa524b03271	XP-PEN	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.196253+00	2026-08-27 13:52:54.196253+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
32a78183-b8e3-48a3-8cc4-a8994fddaa06	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa524b03257	XP-PEN	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.198162+00	2026-08-27 13:52:54.198162+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6bbde0c5-24ca-46dd-81fe-79bbe70b1bcc	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa524b03272	XP-PEN	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Sylvain DUTRELOT"	2026-08-27 13:52:54.19996+00	2026-08-27 13:52:54.19996+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
675506cc-cc98-4542-8016-e424921fa9bb	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa524b03286	XP-PEN	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.201966+00	2026-08-27 13:52:54.201966+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
adeba258-427f-4d30-8201-410dea7ba824	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa524b03273	XP-PEN	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.204211+00	2026-08-27 13:52:54.204211+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1879e689-73c6-4d2b-aeaf-d1a056c359b0	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03093	XP-PEN	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.206581+00	2026-08-27 13:52:54.206581+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e9e3b255-0a54-402c-92b9-9d100dc65e62	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03080	XP-PEN	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.209232+00	2026-08-27 13:52:54.209232+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
43fbee14-59a5-4ad7-8e06-08f096c848df	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03082	XP-PEN	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.211587+00	2026-08-27 13:52:54.211587+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
074df277-801d-4672-a150-ed84b6c111fa	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03096	XP-PEN	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.213762+00	2026-08-27 13:52:54.213762+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
41ad7c88-36ef-4ab4-9ca8-31d75de765c9	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03084	XP-PEN	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.215886+00	2026-08-27 13:52:54.215886+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3aea09b9-452c-4a27-bff2-0a1da7108d69	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03081	XP-PEN	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.217797+00	2026-08-27 13:52:54.217797+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c61acf4d-d30d-4507-818b-edc25ac8a222	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03076	XP-PEN	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.219581+00	2026-08-27 13:52:54.219581+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
10501764-014b-4a56-b71a-599e58f199fd	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03094	XP-PEN	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.221865+00	2026-08-27 13:52:54.221865+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d6cf68e8-5ea3-4cfc-a55a-8742d816a39b	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	xb0401nwa324c03077	XP-PEN	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.223786+00	2026-08-27 13:52:54.223786+00	Star G430S	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
57fc29f6-a85c-4ed9-b0ea-1654d41d2456	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MRX436Y9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.225744+00	2026-08-27 13:52:54.225744+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a947b14a-9115-4058-bee4-679d313f40fa	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MRY43159	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.227633+00	2026-08-27 13:52:54.227633+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0752755d-e005-4be4-8ce5-913a55d5e022	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MRB43149	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.230336+00	2026-08-27 13:52:54.230336+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ae3869f8-043d-40cf-ad3e-3600a8489677	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MRT43179	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.232447+00	2026-08-27 13:52:54.232447+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f06ab254-71e5-4b06-abcb-eb887f8da3fe	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MRH43169	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.234638+00	2026-08-27 13:52:54.234638+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ba8d6611-d06b-4d9a-adc6-31b9a3d97e32	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MR143199	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.236658+00	2026-08-27 13:52:54.236658+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fae55f8e-6c85-45b0-b80d-7e7da523a5c3	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MR643189	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.238887+00	2026-08-27 13:52:54.238887+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
456f8d5b-2ead-4e85-b240-9c7f69cf10ff	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MR2431C9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.240966+00	2026-08-27 13:52:54.240966+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
01f5299d-298e-438b-85c9-159dfd6340b8	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MRM436V9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.24261+00	2026-08-27 13:52:54.24261+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8f113b12-6fee-4f6a-8d31-82040e4db3d1	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2446MRB43139	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.24397+00	2026-08-27 13:52:54.24397+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ebac9df0-cc09-43d7-80f2-b9fb4f91e98e	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	0908615467924	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.245422+00	2026-08-27 13:52:54.245422+00	clavier + souris microsoft 850	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2b5caec4-87c6-4970-8171-f3a7abeb7071	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	0908614976136	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.246872+00	2026-08-27 13:52:54.246872+00	clavier + souris microsoft 850	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4b52bab1-9597-4850-8f2c-4dc0853bb04a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2516MR72DJH8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.248372+00	2026-08-27 13:52:54.248372+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
62875637-c0b0-4964-9171-a3550503f847	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2516MR12DKD9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.250376+00	2026-08-27 13:52:54.250376+00	Logitech MK235(copie 7)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7129ce3c-bb81-4616-bb30-3d47ebc3606f	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2516MR52LG89	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.251814+00	2026-08-27 13:52:54.251814+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3f66f2cd-3eb4-432f-a98c-08044b1dec1a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2516MR72DJH8	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.253248+00	2026-08-27 13:52:54.253248+00	Logitech MK235(copie 9)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6bf75b92-be25-4582-9a4d-77a75aa25c6c	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2516MRL2DL58	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.254894+00	2026-08-27 13:52:54.254894+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cec579da-64ed-49e3-ac33-69a833e774a1	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2516MR92EX09	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.257574+00	2026-08-27 13:52:54.257574+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0f2f4b45-d16f-4bd9-b20c-b4c8b4d8dc60	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2516MRG2DJV9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.259699+00	2026-08-27 13:52:54.259699+00	Logitech MK235(copie 12)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bbb5378b-5d62-4c54-9b7e-d46c2b96bd82	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MRP1S478	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.261533+00	2026-08-27 13:52:54.261533+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
15dfe258-2ef2-4ebf-857f-5e3cfe2f0059	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MR71S4A8	Logitech	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:54.263789+00	2026-08-27 13:52:54.263789+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e8c55693-a825-4e0d-8b3c-3c939bcebab7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MRP1S458	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.265946+00	2026-08-27 13:52:54.265946+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ee84a258-a4c2-4295-954f-eb9d108fc360	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MR71SB28	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.267621+00	2026-08-27 13:52:54.267621+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f896f0b7-d74b-4a83-8fce-4fb4ed9da764	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MRE1S488	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.269119+00	2026-08-27 13:52:54.269119+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fa87e124-0e6f-4ced-968e-08f88444c6cb	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MR81S4D8	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.270532+00	2026-08-27 13:52:54.270532+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7c8fad28-808b-4a0a-8fbe-c5e9f43f848a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MRX1SB08	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.271934+00	2026-08-27 13:52:54.271934+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7b06eb26-aa6d-4b10-abf5-87b079b09a2d	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MRR1SB68	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.272948+00	2026-08-27 13:52:54.272948+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e1d0dd81-eac9-4dd7-8727-068aa1ce49b0	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MRT1S468	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.276248+00	2026-08-27 13:52:54.276248+00	Logitech MK235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fadc328e-b734-4004-a9e0-7bf38595b840	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2536MRT1SB48	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.278504+00	2026-08-27 13:52:54.278504+00	Logitech MK235(copie 18)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
11feb457-a099-4d44-9778-aa044bf6345f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	308052E060002196	Yealink	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.28019+00	2026-08-27 13:52:54.28019+00	BH72 Lite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
feb97804-127c-4be5-9d48-44644508848e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	308052E060002196	Yealink	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.281772+00	2026-08-27 13:52:54.281772+00	BH72 Lite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3f447bf0-1947-4185-baa7-06fe532a808d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	308052E060002196	Yealink	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.283083+00	2026-08-27 13:52:54.283083+00	BH72 Lite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5cceef16-d618-443d-a7e4-8bb9f22acd0e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	308052E060002196	Yealink	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.284574+00	2026-08-27 13:52:54.284574+00	BH72 Lite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8512cb9a-5862-4e64-a35e-44fbcb292194	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250321	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.28604+00	2026-08-27 13:52:54.28604+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bb650e12-1881-4989-b2df-f8b4bdbded7e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250435	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.287361+00	2026-08-27 13:52:54.287361+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1440c2c0-77fe-4543-b04b-f62fdd4b6be8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250121	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.28859+00	2026-08-27 13:52:54.28859+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
80e7820d-40bb-4eaa-8300-b660e9a42ad7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250122	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.289997+00	2026-08-27 13:52:54.289997+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
db97a31e-119e-49e7-afe5-2995a8b6465d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250449	Jabra	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:54.291555+00	2026-08-27 13:52:54.291555+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4327fd68-fb3c-45fe-9723-c9569513c0c9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250134	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.293334+00	2026-08-27 13:52:54.293334+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7cc42f1b-de2b-43ae-865d-c4f2e3dc20cc	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250427	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.295461+00	2026-08-27 13:52:54.295461+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
49fec3e6-689d-48a0-98f9-21d22cfd4e71	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250430	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.297388+00	2026-08-27 13:52:54.297388+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
93bbfa26-50c5-4aac-84d6-f67e6048dbb8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250323	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.299167+00	2026-08-27 13:52:54.299167+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fdd172af-d2fd-4b5c-9743-bd6af083241d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250128	Jabra	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.300487+00	2026-08-27 13:52:54.300487+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
46168aa8-2b25-4044-97ae-68487177df94	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.302101+00	2026-08-27 13:52:54.302101+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e6e15807-7705-480d-9228-61ab962a706e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:54.303768+00	2026-08-27 13:52:54.303768+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1bd51f6b-f442-4570-b1cd-b62fabb33fa1	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.305207+00	2026-08-27 13:52:54.305207+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ed1e5c31-9c23-455c-9831-fec3a9c9ab02	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.307445+00	2026-08-27 13:52:54.307445+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ad4a489e-4264-4a39-b841-958454d9df4a	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.309101+00	2026-08-27 13:52:54.309101+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5b2f35cf-44c1-4c92-b192-23a9101449a9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.310554+00	2026-08-27 13:52:54.310554+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
094c0558-b333-4e22-b245-6aedf02581e1	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.312075+00	2026-08-27 13:52:54.312075+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f7eccdce-ddf6-4de4-b56b-fee4a796cc56	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.313531+00	2026-08-27 13:52:54.313531+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2135b492-4225-4dd6-a82d-7903a9e5dc7e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.315023+00	2026-08-27 13:52:54.315023+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
42e46e4e-32b3-488f-825a-523abe01aeb7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.317721+00	2026-08-27 13:52:54.317721+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e65f8904-fa9b-4205-a4fc-b8b0cea64d4c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXALM	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.320664+00	2026-08-27 13:52:54.320664+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
27e06f61-e512-4a14-8fcd-9443cdb0baf9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXE7X	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.322922+00	2026-08-27 13:52:54.322922+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
45044d5b-b244-4a99-8d9c-c7230269ee24	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXBBC	POLY	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Laetitia BADIBANGA"	2026-08-27 13:52:54.324335+00	2026-08-27 13:52:54.324335+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
53d40e98-32dd-4aa5-8c99-0475e6996d30	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXC4D	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.325756+00	2026-08-27 13:52:54.325756+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4adb4468-daab-41ec-854c-5acdc3ad7648	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXE7X	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.327393+00	2026-08-27 13:52:54.327393+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
62f1b844-eb31-40e3-9104-9766ae96bf9a	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXC4D	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.330355+00	2026-08-27 13:52:54.330355+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
49b5f17d-e97c-4a40-ba62-fb163a3ded21	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXACP	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:54.332748+00	2026-08-27 13:52:54.332748+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bd339b3e-de47-4657-814f-fafb8ba797e0	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXAYB	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.334771+00	2026-08-27 13:52:54.334771+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
33e55a03-1a0d-437b-bad2-08c8710b779f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJWY4A	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.336353+00	2026-08-27 13:52:54.336353+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
67cc147a-8853-48a4-8617-826e107f25eb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXAEN	POLY	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="Elsa BERNEGE" ; Utilisateur="Elsa BERNEGE"	2026-08-27 13:52:54.338109+00	2026-08-27 13:52:54.338109+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5e952766-d350-4cda-99d8-f10b06eda3f0	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXCLV	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.339661+00	2026-08-27 13:52:54.339661+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f2b78c21-d8ad-43c5-a39b-640e940c4d09	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXC5K	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.377232+00	2026-08-27 13:52:54.377232+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e37e345a-c461-435d-b10a-5972882727a8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDEB	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.379755+00	2026-08-27 13:52:54.379755+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ecdadfb5-affe-4273-875b-3793ed27b2c8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDDM	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:54.384746+00	2026-08-27 13:52:54.384746+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9a57ec4a-917c-45a5-9405-7174de2b1fe4	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDD4	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.387327+00	2026-08-27 13:52:54.387327+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ea3d94bd-b6a2-4e70-a0cf-dc81490ce33d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDDN	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.389524+00	2026-08-27 13:52:54.389524+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f9cf43cd-3cd0-47ff-9d37-c963aa437911	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDAX	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.391521+00	2026-08-27 13:52:54.391521+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
beef2c27-6ced-4ae0-ae47-6dacfe813d28	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDDH	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.393149+00	2026-08-27 13:52:54.393149+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4d909d0b-e9c9-4b6e-9347-fcafa112ad07	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDE3	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.39489+00	2026-08-27 13:52:54.39489+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
018e0a6b-0091-4348-a87b-42500989726e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3DYY	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.39643+00	2026-08-27 13:52:54.39643+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
69177829-2387-4588-b54f-88d32fe3778b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3EC1	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.400162+00	2026-08-27 13:52:54.400162+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
be2aae5a-0e57-4a71-a398-50655bab9e46	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3E91	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.402565+00	2026-08-27 13:52:54.402565+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5cd41d61-6f9a-4962-9301-4ca282e9eac1	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3DHG	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:54.404362+00	2026-08-27 13:52:54.404362+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8e65e169-75f4-4790-a87e-51299bf28ed9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3EA6	POLY	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Anna DUPUY"	2026-08-27 13:52:54.406118+00	2026-08-27 13:52:54.406118+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0b904bfc-09bb-4867-afaf-f3bc03826cbb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3EAC	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.407795+00	2026-08-27 13:52:54.407795+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2a326b80-8ec0-472e-80a5-ff55b0267488	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3E5K	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:52:54.410222+00	2026-08-27 13:52:54.410222+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
eebf1320-7cd0-437d-b07f-a67609108f89	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3E63	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.42108+00	2026-08-27 13:52:54.42108+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
26d1b8d5-5c04-4bd0-8bd6-d9edf397545d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3EC0	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.42388+00	2026-08-27 13:52:54.42388+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
eeb08506-31fc-4399-8e3c-60ab7e0cd9ef	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3E73	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.426055+00	2026-08-27 13:52:54.426055+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e6511d7b-9f6b-4a31-afb0-0e0c6bb4dbc9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	a002340212200690	epos	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.427858+00	2026-08-27 13:52:54.427858+00	EPOS SP30	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
26087c96-67a8-4e87-928d-32474e0cbc0f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	epos	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.429577+00	2026-08-27 13:52:54.429577+00	EPOS SP30	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2bb778f7-5f2c-47ea-9377-07c7d9662ca5	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0094000496	epos	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.431543+00	2026-08-27 13:52:54.431543+00	EPOS SP30	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
24cb72ef-0a24-472c-b44a-a2b84676773f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0094000413	epos	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.433166+00	2026-08-27 13:52:54.433166+00	EPOS SP30	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c6447231-1bf9-49d7-be77-33f6b649d3e0	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E8F	POLY	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Alizée POULIN-PLAZANET"	2026-08-27 13:52:54.434976+00	2026-08-27 13:52:54.434976+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2b2dabc0-b1de-4ce0-8571-105d7c2f2034	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7DDL	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.436567+00	2026-08-27 13:52:54.436567+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9bd67baf-f7aa-41bf-a525-334f6d58fb24	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E4B	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.438563+00	2026-08-27 13:52:54.438563+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9fc217e5-dd67-470d-94fe-f3a0559f13b9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E81	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.44171+00	2026-08-27 13:52:54.44171+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cbfee3c0-0108-4032-be75-368ed0ade3b3	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7CH2	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.445496+00	2026-08-27 13:52:54.445496+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2d2db136-f76f-4bbe-802d-e127406d8a56	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E8D	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.447911+00	2026-08-27 13:52:54.447911+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
39783204-4937-4d5a-a64c-3f1e5a813fb6	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E8E	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.449982+00	2026-08-27 13:52:54.449982+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7f709228-201a-4744-8bb1-e05bd2f9dd2e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7DCU	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.451748+00	2026-08-27 13:52:54.451748+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
63c161ae-66a5-4326-b375-f387302f2565	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E3P	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.45357+00	2026-08-27 13:52:54.45357+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bbcff000-dce4-4013-868c-9da8ad1df9a6	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E0A	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.455476+00	2026-08-27 13:52:54.455476+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
11ef028a-215f-4d16-90bf-0cb2c448fdd0	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	3BMGM7	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.457223+00	2026-08-27 13:52:54.457223+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ec9db03f-661e-45a5-8466-42ed040ecfcf	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	39DF2N	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.45951+00	2026-08-27 13:52:54.45951+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dda15cbb-272b-422a-b047-e3522be05673	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK1NU9	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.461694+00	2026-08-27 13:52:54.461694+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9aa0ca45-f868-4bc2-8204-105c504e7882	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FKAYED	POLY	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Joe CLEMENTE"	2026-08-27 13:52:54.46388+00	2026-08-27 13:52:54.46388+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2d9f44a9-5c85-402c-bd5e-06bee9895ec9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FKAYF6	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.46596+00	2026-08-27 13:52:54.46596+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f0cd6773-00f9-4b4e-b654-b7da8c3d73df	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK1NJH	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.467948+00	2026-08-27 13:52:54.467948+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b4a9c67a-3fab-4828-a774-ff95b0e207cb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPWE	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.469712+00	2026-08-27 13:52:54.469712+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3e0139de-6577-43c0-bb75-b9d7e8329ce3	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJP64	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.471474+00	2026-08-27 13:52:54.471474+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0c31b18f-eb8f-4bf6-bd5d-36427ba3994b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPV7	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.47313+00	2026-08-27 13:52:54.47313+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b9e467b7-4d1b-4131-8236-b442618bcdf2	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPV8	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.475121+00	2026-08-27 13:52:54.475121+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ea3bb5bc-a73b-4705-a0d3-4ca139fa5051	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPCG	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.477338+00	2026-08-27 13:52:54.477338+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
495bbe25-f747-48f9-b487-d6c1d8e708d7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPPD	POLY	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.48145+00	2026-08-27 13:52:54.48145+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d40b9361-bdec-4664-8752-52086350ad48	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MET29XW9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.483852+00	2026-08-27 13:52:54.483852+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
695ddf1a-5847-46be-afef-cbfd3b80c35a	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MES2A6G9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.486086+00	2026-08-27 13:52:54.486086+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f0aa2f55-d86c-442a-9a10-bd2205f644a4	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MEZ29TG9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.487713+00	2026-08-27 13:52:54.487713+00	Logitech Zone vibe(copie 2)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
aeb4f651-6e5a-4d1a-8862-0b996f96d6cc	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502ME529SB9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.489347+00	2026-08-27 13:52:54.489347+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a9bb247a-9b57-4643-bca6-44bf6b6ff887	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502ME92AB49	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.490761+00	2026-08-27 13:52:54.490761+00	Logitech Zone vibe(copie 4)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4a95f247-3c41-4d1f-b444-0a27ed898f98	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MEF2A969	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.492334+00	2026-08-27 13:52:54.492334+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
189d81fe-3f80-4c0a-8223-09205d04be53	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MEG29S99	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.494487+00	2026-08-27 13:52:54.494487+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2bc762c5-225f-4a7e-95da-9fe80886e3bb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MH105WG9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.496535+00	2026-08-27 13:52:54.496535+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6bb86253-18af-4e10-90b0-d62b0c1e24f7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MH106S89	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.49837+00	2026-08-27 13:52:54.49837+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3a4a1154-82b8-4f47-ac1f-9fe402e00817	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHP0AR39	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.500314+00	2026-08-27 13:52:54.500314+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
86f7af7e-51c5-4655-8dae-c4f747e2d0bc	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHP0AMS9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.502248+00	2026-08-27 13:52:54.502248+00	Zone 305(copie 3)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
37e7ff10-338b-4a5e-9eac-a4d18e7929bb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHK06NG9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.503954+00	2026-08-27 13:52:54.503954+00	Zone 305(copie 4)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
45aa6f82-4897-4316-898b-26e2994fff7f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHD06CW9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.506075+00	2026-08-27 13:52:54.506075+00	Zone 305(copie 5)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2c349e9e-857c-48cf-8a1b-db59b88eff34	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHB06419	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.507955+00	2026-08-27 13:52:54.507955+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6dc40ed9-e241-4af1-914e-dc74d69b0b39	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHH0B289	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.510373+00	2026-08-27 13:52:54.510373+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b33e41a0-f44d-4bbc-867e-f362add11b55	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHR06NJ9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.512495+00	2026-08-27 13:52:54.512495+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ffc31a32-3c6e-4ef7-9515-67c08b93f26f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHT05YF9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.514874+00	2026-08-27 13:52:54.514874+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a9cd594a-870b-4269-9a41-ca07c90b5471	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MH106RZ9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Noémie SAMYCHETTY"	2026-08-27 13:52:54.517522+00	2026-08-27 13:52:54.517522+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f5fdc6f9-f625-4e84-a207-21dfaee774fc	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHB06K9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.520764+00	2026-08-27 13:52:54.520764+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
97236892-39fd-42d5-9f7f-5af4c32d4b9c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MH306HX9	Logitech	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.52386+00	2026-08-27 13:52:54.52386+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ed3813f6-4a39-45ba-984c-1dd3c4e4618b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHZ0ATZ9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.526941+00	2026-08-27 13:52:54.526941+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3d0e7d4c-55d7-4159-8dbf-b03a2b21b3cf	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHR0B0U9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.529218+00	2026-08-27 13:52:54.529218+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b2eb2212-7326-4b66-bd5e-878491fe44bd	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW50LXEET	Samsung	SM-X205	in_stock	\N	\N	1900-01-14	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.531546+00	2026-08-27 13:52:54.531546+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	0097888483	249.00	\N	\N	1900-01-14	\N	f
1fa9a7e7-1a48-444c-82db-77d144cfc084	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7GAW	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.533408+00	2026-08-27 13:52:54.533408+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1e5c2ad1-235a-4345-a169-fb2c882958b8	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	XNF9PDY633	Apple Inc.	iPhone 13 Pro Max	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Jean Pierre RODRIGUEZ"	2026-08-27 13:52:54.535038+00	2026-08-27 13:52:54.535038+00	iPhone 13 Pro Max	\N	\N	\N	\N	f	f	\N	678.00	\N	\N	\N	\N	f
de4702bd-b87c-4f79-8dc1-7c68ccfe33f4	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R9PW500KF4X	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.536726+00	2026-08-27 13:52:54.536726+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3eafe07a-ce91-43ce-82f9-6832f535193d	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	KXM73QW1WT	Apple Inc.	iPhone 13	assigned	\N	\N	2024-04-03	IMEI: 354489174755386\nAffectation importée non résolue : Usager="-" ; Utilisateur="Ugo THIEBAUT"	2026-08-27 13:52:54.538498+00	2026-08-27 13:52:54.538498+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	2026-04-03	\N	f
359a632a-5880-4078-9cc8-303697840baf	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	M72P24PMGH	Apple Inc.	iPad 10e gen	assigned	\N	\N	1900-01-19	Affectation importée non résolue : Usager="-" ; Utilisateur="Elisa CLAVEL"	2026-08-27 13:52:54.540162+00	2026-08-27 13:52:54.540162+00	iPad 10	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	1900-01-20	\N	f
1b960234-1db4-40cd-b74b-7c4c7a335983	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	X7H4X7G35C	Apple Inc.	iPad 10e gen	assigned	\N	\N	1900-01-19	Affectation importée non résolue : Usager="-" ; Utilisateur="Nathalie SOLANES"	2026-08-27 13:52:54.542586+00	2026-08-27 13:52:54.542586+00	iPad 10	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	1900-01-20	\N	f
363f8ae9-198f-4c40-9094-c69fc2918aba	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20YZZQK	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.54502+00	2026-08-27 13:52:54.54502+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
02c2e233-566f-4d7b-8cf2-398897c179c2	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7FRY	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.54795+00	2026-08-27 13:52:54.54795+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
f0e3c663-f4c8-4418-983d-3f5150b8c027	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7B2A	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.550403+00	2026-08-27 13:52:54.550403+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
f8c4d8ba-b33c-4adb-a39e-d20bd61678ec	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7BZY	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.552277+00	2026-08-27 13:52:54.552277+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
2a64755e-6fb0-456c-b656-72fcbebf6851	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X79DT	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.555259+00	2026-08-27 13:52:54.555259+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
fd804015-242f-41ff-8200-5308b876ed13	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7F9K	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.558248+00	2026-08-27 13:52:54.558248+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
4e20758b-ff6d-44d4-930c-cf41a7b038f1	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7G4B	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.560102+00	2026-08-27 13:52:54.560102+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
2ceb99bf-369c-45ad-94d2-7807c4a2df42	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW50LXEJP	Samsung	SM-X205	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.562117+00	2026-08-27 13:52:54.562117+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
419f5897-6328-493f-8fe1-36979fdfbb6a	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20YZYDB	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.564635+00	2026-08-27 13:52:54.564635+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
d0f6777d-a789-43db-ad73-55a0f9876d94	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20Z01BD	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.566504+00	2026-08-27 13:52:54.566504+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
dab82102-2798-4139-ad52-b415aeaad49a	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20YZYEH	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.570812+00	2026-08-27 13:52:54.570812+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
615bd999-bf1c-4488-a829-aa4028f1c531	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20Z00AR	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.573401+00	2026-08-27 13:52:54.573401+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
6d4c8952-92c9-4507-a1de-605a4e108056	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20Z01DR	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.575367+00	2026-08-27 13:52:54.575367+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
6a27ff8a-c494-43e3-a365-5ab091272f1f	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20Z005N	Samsung	SM-X200	assigned	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:52:54.577552+00	2026-08-27 13:52:54.577552+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
0ecce6cf-f5e4-4ba5-aab5-b018735ebe6d	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HCG9Y47254	Apple Inc.	iPhone 13	assigned	\N	\N	2024-04-03	Affectation importée non résolue : Usager="-" ; Utilisateur="Emilie KOEHL"	2026-08-27 13:52:54.579823+00	2026-08-27 13:52:54.579823+00	iPhone 13	\N	\N	\N	\N	f	f	\N	429.00	\N	\N	2026-04-03	\N	f
64031764-a2e6-4902-849b-a9e78134c596	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979217\nAffectation importée non résolue : Usager="-" ; Utilisateur="Olivia ROUSSILLE"	2026-08-27 13:52:54.582899+00	2026-08-27 13:52:54.582899+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3ef347b2-5600-4509-831b-4ca702b5fe56	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979530\nAffectation importée non résolue : Usager="-" ; Utilisateur="Thomas FILLETTE"	2026-08-27 13:52:54.584864+00	2026-08-27 13:52:54.584864+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ebeb2db4-93d1-4f95-9cbb-bd25b37788ea	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958444912571\nAffectation importée non résolue : Usager="-" ; Utilisateur="Emilie ROUZOUL"	2026-08-27 13:52:54.586733+00	2026-08-27 13:52:54.586733+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1616fa0f-5314-4dbb-b90a-a927f16475b6	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958444912712\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marylene PINCHON"	2026-08-27 13:52:54.588728+00	2026-08-27 13:52:54.588728+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dd22dd9b-fa5e-4f83-a2ae-a1784cb13a69	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443978854\nAffectation importée non résolue : Usager="-" ; Utilisateur="Romain HEDJAL"	2026-08-27 13:52:54.590915+00	2026-08-27 13:52:54.590915+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0e7ae8fc-cb53-4753-90ae-00edf64e39d4	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979373\nAffectation importée non résolue : Usager="-" ; Utilisateur="Cédric FIRMIN"	2026-08-27 13:52:54.596464+00	2026-08-27 13:52:54.596464+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e248c71d-31a2-4d87-b20c-f9467330ed32	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958444912878\nAffectation importée non résolue : Usager="-" ; Utilisateur="Sylvain DUTRELOT"	2026-08-27 13:52:54.599156+00	2026-08-27 13:52:54.599156+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f8616add-ad99-46d3-8ecc-bc0e1deb093c	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979597\nAffectation importée non résolue : Usager="-" ; Utilisateur="Laetitia CHARLES"	2026-08-27 13:52:54.601776+00	2026-08-27 13:52:54.601776+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
54c845e9-022f-44f5-8c92-f061d9088b39	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958444912498\nAffectation importée non résolue : Usager="-" ; Utilisateur="Vanessa BOUCHAREYSSAS"	2026-08-27 13:52:54.605032+00	2026-08-27 13:52:54.605032+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a99b8328-965b-43be-ae7b-a616edaf0620	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443978797\nAffectation importée non résolue : Usager="-" ; Utilisateur="Anissa BENHAMOU"	2026-08-27 13:52:54.607309+00	2026-08-27 13:52:54.607309+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7bae3b4b-ce21-4c70-bfb0-5ad4a063a97a	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1848301DP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958444912035\nAffectation importée non résolue : Usager="-" ; Utilisateur="Antonin BARTHAS"	2026-08-27 13:52:54.609284+00	2026-08-27 13:52:54.609284+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2a4f7ca7-772e-493f-8825-d23b93d8b08f	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979035\nAffectation importée non résolue : Usager="-" ; Utilisateur="Nathalie SOLANES"	2026-08-27 13:52:54.611309+00	2026-08-27 13:52:54.611309+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4c454385-5ec5-4735-a71c-dbeabd02f09d	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443978698\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marjorie ZUCCHETTI"	2026-08-27 13:52:54.649936+00	2026-08-27 13:52:54.649936+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
440b2005-4865-4ae9-87c3-c5cdbde035d3	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979654\nAffectation importée non résolue : Usager="-" ; Utilisateur="Sonia HESNARD COURET"	2026-08-27 13:52:54.653186+00	2026-08-27 13:52:54.653186+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b688be90-386b-4f78-888d-7d6ef080a197	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	\N	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443978938\nAffectation importée non résolue : Usager="-" ; Utilisateur="Rachel CONSTANS"	2026-08-27 13:52:54.661035+00	2026-08-27 13:52:54.661035+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2695dd66-2bf6-4035-af7e-fc0c58b7ef25	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 35495844911953\nAffectation importée non résolue : Usager="-" ; Utilisateur="Olivier LESTARPE"	2026-08-27 13:52:54.664135+00	2026-08-27 13:52:54.664135+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4278d634-5bcd-40ae-b954-04e9d41ea3f1	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979191\nAffectation importée non résolue : Usager="-" ; Utilisateur="Christelle PAYSSE"	2026-08-27 13:52:54.666898+00	2026-08-27 13:52:54.666898+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dd9ba469-def7-44e1-ac4b-3e808b03a273	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979706\nAffectation importée non résolue : Usager="-" ; Utilisateur="Samia MAHJOUB"	2026-08-27 13:52:54.67089+00	2026-08-27 13:52:54.67089+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2eb54c85-c886-4f3a-9f64-fae98e10855d	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443979795\nAffectation importée non résolue : Usager="-" ; Utilisateur="Stephane COULON"	2026-08-27 13:52:54.674035+00	2026-08-27 13:52:54.674035+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b65d85ce-05f4-4b2f-832d-42eae237e820	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1848301DP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958444912811\nAffectation importée non résolue : Usager="-" ; Utilisateur="Dalyll REGUIA"	2026-08-27 13:52:54.677281+00	2026-08-27 13:52:54.677281+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f9e4653a-669f-47bf-ace5-5dd08ed69054	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	assigned	\N	\N	\N	IMEI : 354958443978870\nAffectation importée non résolue : Usager="-" ; Utilisateur="Victor TRILHA"	2026-08-27 13:52:54.683141+00	2026-08-27 13:52:54.683141+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
474900fb-21f7-41dc-8dc7-7651d646692d	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DG3FX470PW	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 357584542986544\nAffectation importée non résolue : Usager="-" ; Utilisateur="Elisa CLAVEL"	2026-08-27 13:52:54.686631+00	2026-08-27 13:52:54.686631+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9608b649-ecdc-4178-bfa3-72bac2c0ac42	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	J56NV9YT4X	Apple	iPhone 16	in_stock	\N	\N	\N	IMEI : 354614892039827	2026-08-27 13:52:54.689872+00	2026-08-27 13:52:54.689872+00	iPhone 16	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b838e961-73c9-425a-9fce-169dec5ee959	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JOWGP73FWK	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 357584542694890\nAffectation importée non résolue : Usager="-" ; Utilisateur="Brice CHAMAYOU"	2026-08-27 13:52:54.693439+00	2026-08-27 13:52:54.693439+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
89a2f0c7-942c-48ec-b041-ce8332ac4945	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	KR4LN2GQCD	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 350340392327058 - Allo Lily\nAffectation importée non résolue : Usager="-" ; Utilisateur="_Allolily"	2026-08-27 13:52:54.69655+00	2026-08-27 13:52:54.69655+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
744490ea-1a23-4a74-8d3b-a5dde0ba8d2d	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	FQ375L4NLF	Apple	iPhone 16	assigned	\N	\N	\N	IMEI : 352904893302098\nAffectation importée non résolue : Usager="-" ; Utilisateur="Louis-Henri CAPEL"	2026-08-27 13:52:54.700101+00	2026-08-27 13:52:54.700101+00	iPhone 16	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
10e96ca4-c227-4852-b5ed-aa39ee96f774	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HQKWFHH7NV	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 354489174569787\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marina TUNEZ"	2026-08-27 13:52:54.703218+00	2026-08-27 13:52:54.703218+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
47bde07f-b5c7-460c-ba68-b1b3f9f4df47	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	MQM2GM0WDG	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 350340392431066\nAffectation importée non résolue : Usager="-" ; Utilisateur="Karim MIALHE"	2026-08-27 13:52:54.706523+00	2026-08-27 13:52:54.706523+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8fb747ed-8abb-46c4-b6b7-936d1397b96d	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HWMWDV2QL5	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 350340391328115	2026-08-27 13:52:54.710472+00	2026-08-27 13:52:54.710472+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
382b463d-7e4d-474b-8662-2639fa2e95e3	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	MCQNWDJ36J	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 354489174898145\nAffectation importée non résolue : Usager="-" ; Utilisateur="Ophélie DELCUSE"	2026-08-27 13:52:54.713663+00	2026-08-27 13:52:54.713663+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7326f35a-e948-4c18-bd7b-c7388b50ade7	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JHH3HJ2RPC	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 359461434548344\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marianne BOSC-ANDRIEU"	2026-08-27 13:52:54.716831+00	2026-08-27 13:52:54.716831+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5ecea37e-30bb-4bad-9ce3-d8579a6e30b0	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	GTHG6660TY	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 357584542646593\nAffectation importée non résolue : Usager="-" ; Utilisateur="Hugo NAKACHE"	2026-08-27 13:52:54.72002+00	2026-08-27 13:52:54.72002+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
92329a50-b87b-4a9e-988b-94cd4377c089	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DWVX9DP41W	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 354489174579281\nAffectation importée non résolue : Usager="-" ; Utilisateur="Guylaine DROUOT"	2026-08-27 13:52:54.723701+00	2026-08-27 13:52:54.723701+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0bcf0fbb-0f08-4363-8849-ce2dbef68c11	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	MDJPDF6Q1G	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 357584542527975\nAffectation importée non résolue : Usager="-" ; Utilisateur="Corinne FRAYSSINES"	2026-08-27 13:52:54.726614+00	2026-08-27 13:52:54.726614+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8ff0b396-b1e1-4c28-a2d5-b120acb8ca5c	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HWPXYL4KFX	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 357584542505021\nAffectation importée non résolue : Usager="-" ; Utilisateur="Emilie LAUTIER-VINEL"	2026-08-27 13:52:54.729969+00	2026-08-27 13:52:54.729969+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
76f26ff5-86a9-4df3-b38f-516da184491b	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DN4H399Y64	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 351212584270462\nAffectation importée non résolue : Usager="-" ; Utilisateur="Mathilde DE TONI"	2026-08-27 13:52:54.73322+00	2026-08-27 13:52:54.73322+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f1ceea39-5bf3-4d0f-95e4-9b4c8d92910c	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	KPD633FKWF	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 359461434793718\nAffectation importée non résolue : Usager="-" ; Utilisateur="Dorine VINCENT"	2026-08-27 13:52:54.736246+00	2026-08-27 13:52:54.736246+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7f0e14ca-50ed-44b9-8e76-c07af22d441c	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DHVVXGT2F1	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 359461434695236\nAffectation importée non résolue : Usager="-" ; Utilisateur="Corinne VIGNAU"	2026-08-27 13:52:54.739273+00	2026-08-27 13:52:54.739273+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ba8b424a-f100-4395-be20-c3ffd4050e9c	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JX2K1JFGWR	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 359461434501038\nAffectation importée non résolue : Usager="-" ; Utilisateur="Aurelie PALUDETTO"	2026-08-27 13:52:54.742434+00	2026-08-27 13:52:54.742434+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
24482d65-541f-4abe-bbc7-b66a019a2c8b	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DYCY7T9140	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 3575845421175563\nAffectation importée non résolue : Usager="-" ; Utilisateur="Cédric COCOLO"	2026-08-27 13:52:54.745437+00	2026-08-27 13:52:54.745437+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a21e2aee-dd9b-4cce-9bab-2b819dc73d8a	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	D5QXFN9DXM	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 359461434840584\nAffectation importée non résolue : Usager="-" ; Utilisateur="Sana TOUMI"	2026-08-27 13:52:54.74832+00	2026-08-27 13:52:54.74832+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ff9019cc-4896-4933-aab1-f64535d271a5	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	RFCX80HKMBK	Samsung	Galaxy S24	assigned	\N	\N	\N	IMEI : 350176952376741\nAffectation importée non résolue : Usager="-" ; Utilisateur="Jean-Christophe RAYNAUD"	2026-08-27 13:52:54.751216+00	2026-08-27 13:52:54.751216+00	Galaxy S24	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9b83bd10-fce1-40dc-b8b8-ba2f92fa6f98	65314b61-d114-4281-8df3-9b63ef981da3	\N	K23-00195334	Wortmann_AG	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.753684+00	2026-08-27 13:52:54.753684+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7d9df888-f79f-4676-a3fa-3cc1a44142c8	65314b61-d114-4281-8df3-9b63ef981da3	\N	K24-00061521	Wortmann_AG	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.756214+00	2026-08-27 13:52:54.756214+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
035f7f70-c5ab-40d7-810a-eaed9954a3cb	65314b61-d114-4281-8df3-9b63ef981da3	\N	K24-00061541	Wortmann_AG	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.759109+00	2026-08-27 13:52:54.759109+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8508692d-7925-48bb-aaea-98eb09f85384	65314b61-d114-4281-8df3-9b63ef981da3	\N	K24-00161009	Wortmann_AG	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.76201+00	2026-08-27 13:52:54.76201+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7a977c73-72aa-4bda-8e53-ece269d5a60d	65314b61-d114-4281-8df3-9b63ef981da3	\N	K24-00161008	Wortmann_AG	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.764887+00	2026-08-27 13:52:54.764887+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
24616f2c-e3f7-43ca-965b-a4fbc556f6c5	65314b61-d114-4281-8df3-9b63ef981da3	\N	K24-00243754	Wortmann_AG	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.767664+00	2026-08-27 13:52:54.772453+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f56afab3-7a6d-464d-8623-6b8160a89483	65314b61-d114-4281-8df3-9b63ef981da3	\N	K24-00243748	Wortmann_AG	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.775981+00	2026-08-27 13:52:54.775981+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5d8d5296-fcbd-4bd0-a662-cfef2542c814	65314b61-d114-4281-8df3-9b63ef981da3	\N	K24-00197013	Wortmann_AG	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.778216+00	2026-08-27 13:52:54.778216+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
74b5c473-4907-4cd8-bdc0-f8ea8a5401e0	65314b61-d114-4281-8df3-9b63ef981da3	\N	K24-00197015	Wortmann_AG	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.780326+00	2026-08-27 13:52:54.780326+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2a2db605-db2a-49d6-a875-bd07c23f978b	65314b61-d114-4281-8df3-9b63ef981da3	\N	K25-00099319	Wortmann_AG	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.783184+00	2026-08-27 13:52:54.783184+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
070a9f1d-9a7f-4c3e-9e9c-277bcbefef81	65314b61-d114-4281-8df3-9b63ef981da3	\N	K25-0010246	Wortmann_AG	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.786107+00	2026-08-27 13:52:54.786107+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c547f0db-f0af-45c2-89e3-659757bff2dd	65314b61-d114-4281-8df3-9b63ef981da3	\N	K25-00099316	Wortmann_AG	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.789077+00	2026-08-27 13:52:54.789077+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
df354c35-5476-423a-96e8-dd9761ae42ce	65314b61-d114-4281-8df3-9b63ef981da3	\N	K25-00102050	Wortmann_AG	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.792111+00	2026-08-27 13:52:54.792111+00	STATION D'ACCUEL TERRA MOBILE 800 USB-C/A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
45c3b019-054e-42d5-b8c8-407e35a5cbf9	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	FJVJ3Q30MW	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 350340392403032\nAffectation importée non résolue : Usager="-" ; Utilisateur="Yannis DELMAS"	2026-08-27 13:52:54.795117+00	2026-08-27 13:52:54.795117+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ea453c76-5740-477a-a5e9-ffd74a1b3d4a	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JK37V3719X	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 357584542656303\nAffectation importée non résolue : Usager="-" ; Utilisateur="Nicolas DREUX"	2026-08-27 13:52:54.797842+00	2026-08-27 13:52:54.797842+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fbb639a7-2367-4f90-a8be-03e6fecdb8ce	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JLHPDQ9G35	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 351212584090100\nAffectation importée non résolue : Usager="-" ; Utilisateur="Adeline OSBINI"	2026-08-27 13:52:54.800736+00	2026-08-27 13:52:54.800736+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6b475846-6623-4a82-a74e-c8b7d9edb518	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HQKWFHH7NV	Apple	iPhone 13	assigned	\N	\N	\N	IMEI : 354489174569787\nAffectation importée non résolue : Usager="-" ; Utilisateur="Volodia MINIEJEW"	2026-08-27 13:52:54.803391+00	2026-08-27 13:52:54.803391+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
98b565f1-39fe-4007-bae8-033038663e03	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	GXYP9K0C4X	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 350340391730781	2026-08-27 13:52:54.806153+00	2026-08-27 13:52:54.806153+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
48fb2fdd-50f3-41ef-8b1b-93ec739d94b4	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	TT67HKGVJ2	Apple	iPhone 13	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Laura AVERSAING"	2026-08-27 13:52:54.80907+00	2026-08-27 13:52:54.80907+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f46ed41c-bab0-49ed-b3de-5885e1335751	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	J7M64127TN	Apple	iPhone 13	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Elodie TRANTOUL"	2026-08-27 13:52:54.812127+00	2026-08-27 13:52:54.812127+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
616231f6-ca24-4152-ae74-849781cd946f	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	T6DXLTQ7LG	Apple	iPhone 13	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Ylan VINCENT-DAGOBERT"	2026-08-27 13:52:54.815112+00	2026-08-27 13:52:54.815112+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7d42d9db-c3b8-4c4b-bebb-9be08b2d8219	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HWJNFPDQ9R	Apple	iPhone 14 Plus	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Cécile BOIVIN"	2026-08-27 13:52:54.818073+00	2026-08-27 13:52:54.818073+00	iPhone 14 Plus	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0a153457-1a16-41e3-ba7a-fef7076bdc3b	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	W14KCJXDWY	Apple	iPhone 14 Plus	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Stéphane NAKACHE"	2026-08-27 13:52:54.82111+00	2026-08-27 13:52:54.82111+00	iPhone 14 Plus	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
48c69721-4fca-407e-8a7a-3e9d6b500959	bb95ff6b-0e80-45e2-9407-369056d35357	\N	0F34VXX26043KV	Microsoft	Surface Pro, Copilot+ PC, 13 pouces	assigned	\N	\N	2026-04-07	Clavier avec stylet Slim Pen + Surface Pro, Copilot+ PC, 13 pouces + Bloc d’alimentation 65 W\nAffectation importée non résolue : Usager="-" ; Utilisateur="Lydie RODRIGUEZ"	2026-08-27 13:52:54.824128+00	2026-08-27 13:52:54.824128+00	PORT2604-6043KV	\N	\N	\N	\N	f	f	6391125878085269170	1669.99	\N	\N	2027-04-07	\N	f
2065f34a-841e-4e17-afc7-2fca6ad22df0	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215433	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	Affectation importée non résolue : Usager="-" ; Utilisateur="Alizée POULIN-PLAZANET"	2026-08-27 13:52:54.827352+00	2026-08-27 13:52:54.827352+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
acf1f22d-3a4f-4206-8fa6-8cc21476f9d5	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215530	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.830323+00	2026-08-27 13:52:54.83581+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
29e29a9f-3070-4471-8c18-622e88baa212	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215531	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.83806+00	2026-08-27 13:52:54.843137+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
af414a20-ec0e-4471-b41f-c33853c80c39	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215532	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.845093+00	2026-08-27 13:52:54.849858+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
99916e00-56e4-4b35-a5fd-909eef8f2704	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215533	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.851643+00	2026-08-27 13:52:54.856493+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
31f4836f-58f0-431d-8ba4-389daeb11a10	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215534	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.858633+00	2026-08-27 13:52:54.863897+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
a3259189-c703-4940-8404-8216f546557d	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215535	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.86618+00	2026-08-27 13:52:54.871164+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
16db4f74-7777-40b9-a7e4-265063ca0519	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215536	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	Affectation importée non résolue : Usager="-" ; Utilisateur="Emilie PARPAIOLA"	2026-08-27 13:52:54.873491+00	2026-08-27 13:52:54.873491+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
b4897fcf-c25a-4b0b-9131-7da8f9e4cac4	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215537	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.876315+00	2026-08-27 13:52:54.881292+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
d47e97a5-1e0c-4ebd-aefa-7afcf7d09c38	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215637	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	HS	2026-08-27 13:52:54.883274+00	2026-08-27 13:52:54.883274+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
720cdc7e-9037-4f3c-bf27-377ad9e8b8a9	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215639	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.886222+00	2026-08-27 13:52:54.891377+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
ee4cd3c5-b326-4871-ab48-c6b848f418a4	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215641	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.893894+00	2026-08-27 13:52:54.899301+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
7a356650-2056-4b05-9fb9-128b803ab218	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215642	IIYAMA	XUB2497HSN-B2	in_stock	\N	\N	2026-04-17	HS	2026-08-27 13:52:54.901379+00	2026-08-27 13:52:54.901379+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
70d3b172-2c31-4ce3-9cbf-395fa145c20d	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215904	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.904037+00	2026-08-27 13:52:54.909364+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
2aa09086-0e15-44b5-a018-ad5523399af3	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215905	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.911837+00	2026-08-27 13:52:54.917142+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
d8e1443a-229c-432d-838a-30dee4c41851	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215910	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.919356+00	2026-08-27 13:52:54.924362+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
84fff1e7-4f57-4de1-a3b2-ae57c91a6ef3	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215914	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.926426+00	2026-08-27 13:52:54.931417+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
48b47d4c-36bc-4b03-a6a1-bf20f39a5f9f	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215916	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.933726+00	2026-08-27 13:52:54.938047+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
3e190b28-2fdb-478b-8cc0-97e6b33c7ca4	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215917	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.940003+00	2026-08-27 13:52:54.945423+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
369810dc-e6bc-4877-b331-641c31b131c1	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215918	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:52:54.947751+00	2026-08-27 13:52:54.952845+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
9abcb552-a7f8-4435-ad11-65209bfc5ff1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	BK33K8X26133KV	Microsoft	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Lydie RODRIGUEZ"	2026-08-27 13:52:54.954587+00	2026-08-27 13:52:54.954587+00	PORT2604-6133KV	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2bfae808-19fd-4837-a820-4fa3db5c740b	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354613812	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	\N	\N	2026-08-27 13:52:54.956887+00	2026-08-27 13:52:54.961306+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b6f3d594-41b0-4edb-8c4b-1ac71fde16a8	56d8fb3e-65f9-4bee-8c50-69cc4de9d3ec	\N	2502ZBX3K0K9	logitech	\N	assigned	\N	\N	\N	Salle réunion 2 étage 29	2026-08-27 13:52:54.963376+00	2026-08-27 13:52:54.963376+00	MEETUP	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a608684e-7ba5-4713-9664-8becbe818520	56d8fb3e-65f9-4bee-8c50-69cc4de9d3ec	\N	2502ZBT3K109	Logitech	\N	assigned	\N	\N	\N	Salle réunion 23 côté Brice	2026-08-27 13:52:54.966134+00	2026-08-27 13:52:54.966134+00	MEETUP	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
28340173-be78-449a-bab2-435b199b64de	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647610	Wortmann_AG	FR1220873;1470967	assigned	\N	\N	2026-05-11	Affectation importée non résolue : Usager="-" ; Utilisateur="Volodia MINIEJEW"	2026-08-27 13:52:54.968934+00	2026-08-27 13:52:54.968934+00	PORT2605-647610	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f0347bbd-c27d-4db6-80af-6b16fbf32bb9	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647607	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:52:54.971733+00	2026-08-27 13:52:54.971733+00	PORT2605-647607	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
690385d4-fbcb-4926-a29c-4c408ce9df6c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647606	Wortmann_AG	FR1220873;1470967	assigned	\N	\N	2026-05-11	Affectation importée non résolue : Usager="-" ; Utilisateur="Mathieu MUSCAT"	2026-08-27 13:52:54.97461+00	2026-08-27 13:52:54.97461+00	PORT2605-647606	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4cf58d61-57f9-48df-be6c-bcae517dc412	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647611	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:52:54.977412+00	2026-08-27 13:52:54.977412+00	PORT2605-647611	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5c309df2-07d6-4de1-958a-06e1f30660b2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647604	Wortmann_AG	FR1220873-1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:52:54.980205+00	2026-08-27 13:52:54.980205+00	PORT2605-647604	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b7e5ffc1-efef-46b7-b115-e954ad9da842	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647602	Wortmann_AG	FR1220873	in_stock	\N	\N	2026-05-11	Affectation importée non résolue : Usager="-" ; Utilisateur="Ylan VINCENT-DAGOBERT"	2026-08-27 13:52:54.983028+00	2026-08-27 13:52:54.983028+00	PORT2605-647602	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b54b1cc5-0cd1-4cb9-9edc-991bf85f04dd	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647605	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:52:54.98585+00	2026-08-27 13:52:54.98585+00	PORT2605-647605	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
55c8a38f-6d06-4eea-92a8-745a63d15c5f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647603	Wortmann_AG	FR1220873;1470967	assigned	\N	\N	2026-05-11	Affectation importée non résolue : Usager="-" ; Utilisateur="Séverine AMIEL"	2026-08-27 13:52:54.988635+00	2026-08-27 13:52:54.988635+00	PORT2605-647603	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
13d8a3c9-0692-4138-9b5d-c00f0fc9b50f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647609	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:52:54.991423+00	2026-08-27 13:52:54.991423+00	PORT2605-647611	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
356d48f1-3044-4d7d-ba1e-4c50cf81bdfb	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647608	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:52:54.994226+00	2026-08-27 13:52:54.994226+00	PORT2605-647608	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
722b04e1-0850-4fe8-b99e-c5acb7984ad1	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	\N	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:54.997158+00	2026-08-27 13:52:54.997158+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e19cb163-be00-441b-b990-91445de7e0b0	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHA0GEB9	Logitech	M235	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Laurine KARDIFA"	2026-08-27 13:52:55.000002+00	2026-08-27 13:52:55.000002+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
150e6275-fa9b-4c7e-8762-ef961df0baf1	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHDOGQX9	Logitech	M235	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Paul NEGRE-JUNYENT"	2026-08-27 13:52:55.002678+00	2026-08-27 13:52:55.002678+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
59197dc7-471e-4f6d-aaea-1b692bb557ff	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHZ0GMK9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Marylise VEAUTE"	2026-08-27 13:52:55.005328+00	2026-08-27 13:52:55.005328+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
718c867d-a474-4798-89f3-18173125ccf3	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH00FY29	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Marina BORDIGNON"	2026-08-27 13:52:55.008129+00	2026-08-27 13:52:55.008129+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f5d7998c-923d-4151-8244-c1746d3b388a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH90G289	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Alexandra ARNAUD"	2026-08-27 13:52:55.01159+00	2026-08-27 13:52:55.01159+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7afbb543-051a-40fb-8c50-08a15c9f5c49	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHL0GT09	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Johanna JULIEN"	2026-08-27 13:52:55.014824+00	2026-08-27 13:52:55.014824+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ff440e32-c982-4262-a6af-3264adc6a623	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHH0G3H9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Emilie PARPAIOLA"	2026-08-27 13:52:55.017884+00	2026-08-27 13:52:55.017884+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
346a62ed-4f93-4f88-b015-05fdcec48283	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHA05YR9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.020722+00	2026-08-27 13:52:55.020722+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5e7f21da-8c34-452e-8057-92dd34c5064c	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHK0G369	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.023521+00	2026-08-27 13:52:55.023521+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0ec5495d-d687-4d80-be55-32bd045b0144	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH70JJV9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.026292+00	2026-08-27 13:52:55.026292+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
179721d2-6bf3-4099-96f1-f527b31647a7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHP0G8D9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.028735+00	2026-08-27 13:52:55.028735+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
be67fcb6-38f0-44d5-8c92-f213af0a0a1c	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHK062Y9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.068066+00	2026-08-27 13:52:55.068066+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6bd1db21-6aa8-4eb6-8687-f09b411e3c3a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHE0GJT9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.07122+00	2026-08-27 13:52:55.07122+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9d5ef727-8802-4667-ad4e-668628ea0f56	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHU05K49	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Maud HARASYMCZUK"	2026-08-27 13:52:55.074078+00	2026-08-27 13:52:55.074078+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
653a7f8f-694e-4bef-ac8f-04447175fa5f	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHN05PV9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.076696+00	2026-08-27 13:52:55.076696+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
71ed5d91-cf9a-458b-bf6d-6ffaeabf65b6	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHM0G8P9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.079286+00	2026-08-27 13:52:55.079286+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5e53d7f6-f4f2-43f2-9392-0153bd0e07f5	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHU05LU9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.082036+00	2026-08-27 13:52:55.082036+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5158fe56-fb90-4e67-9e14-30df8fcde4f7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH70G1G9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.084663+00	2026-08-27 13:52:55.084663+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
032e1830-7235-4c95-87e3-d636de7c7c7d	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHX0FS59	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Enya SARDA"	2026-08-27 13:52:55.087458+00	2026-08-27 13:52:55.087458+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
955b70f9-15eb-4603-a98e-48e75bc9c9a4	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHJ0G1D9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.090318+00	2026-08-27 13:52:55.090318+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
90a194c3-9119-4466-ae59-34f16eb85801	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH10GYQ9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.092959+00	2026-08-27 13:52:55.092959+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
adde9e2c-c72b-4314-8eb8-5a83ed5b5e7a	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH7063W9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Camille BOURNIQUEL"	2026-08-27 13:52:55.095728+00	2026-08-27 13:52:55.095728+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7914fb3e-da10-42ed-a272-badd70e54ab4	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH30GNB9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Célia SEPTIER"	2026-08-27 13:52:55.098686+00	2026-08-27 13:52:55.098686+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a3034847-90b4-4ccc-8ea8-124b75aed6e7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH906489	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.10167+00	2026-08-27 13:52:55.10167+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3f3e7846-fdfa-4381-a7f9-aa7699f45e1d	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH90G2U9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Rachel CONSTANS"	2026-08-27 13:52:55.104772+00	2026-08-27 13:52:55.104772+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
94d69075-9c62-487e-a3de-c1e366fb41f5	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHA0FV09	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.107825+00	2026-08-27 13:52:55.107825+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4231323a-2b03-4deb-9ac5-19922713a9fe	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHC0GYG9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.110843+00	2026-08-27 13:52:55.110843+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
07007f66-b79e-4010-9820-0973702dbc9e	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHA0FWZ9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Isaure ODIAU-LAMISET"	2026-08-27 13:52:55.113739+00	2026-08-27 13:52:55.113739+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
126a2f5b-54ca-4718-b6b3-bde2712a3b56	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHP0JGN9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.11641+00	2026-08-27 13:52:55.11641+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
912cbc44-838a-4db3-8221-34a5baba1e65	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHA0G0U9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.11917+00	2026-08-27 13:52:55.11917+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4fcec411-d5ee-4689-874c-4d8b5c04d36f	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHF0GEK9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.121972+00	2026-08-27 13:52:55.121972+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f0855d49-7f43-41c1-b8e9-46927e77f7a0	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHN0GQM9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.124672+00	2026-08-27 13:52:55.124672+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
faab358d-eea8-4f19-a0bd-254d9dc8101c	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHK0G8T9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.127386+00	2026-08-27 13:52:55.127386+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8f3857a6-49cf-432c-91b2-d38267bc5659	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH40JUM9	Logiech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Manon SANTOS"	2026-08-27 13:52:55.130003+00	2026-08-27 13:52:55.130003+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
39d0f5f2-8158-4b64-8645-c43821971f99	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHR0FSE9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Karine MOURET"	2026-08-27 13:52:55.133033+00	2026-08-27 13:52:55.133033+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ede9f322-ec21-4f73-962b-0c8cbfd797d7	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHY05GY9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Mylène DARDEVET"	2026-08-27 13:52:55.136003+00	2026-08-27 13:52:55.136003+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bc3532b6-fc20-40bb-adbe-a9681e6c84ea	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZH60GRF9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Adrien ABADIE"	2026-08-27 13:52:55.138927+00	2026-08-27 13:52:55.138927+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f092e955-0f0b-4ea7-bc53-900a43db7a51	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHP0GF59	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Elsa BERNEGE"	2026-08-27 13:52:55.141704+00	2026-08-27 13:52:55.141704+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5ceeeea2-9a23-45d0-b840-3225c06a30c8	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHE0H0L9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Morgane ALCINA"	2026-08-27 13:52:55.144369+00	2026-08-27 13:52:55.144369+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6bec7841-413e-4b28-935d-67f348d2aec5	1f38f1dd-bed2-457e-9e48-79a86c6bc8af	\N	2435ZHB0GMF9	Logitech	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Mélanie VACHER"	2026-08-27 13:52:55.14706+00	2026-08-27 13:52:55.14706+00	Logitech M235	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8b34e070-b73f-4008-8832-4b2502ef9342	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M2F	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Laetitia BADIBANGA"	2026-08-27 13:52:55.149657+00	2026-08-27 13:52:55.149657+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
52ddd774-f5d2-429d-aa80-16a1f14311ac	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M51	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Marine FORESTIER"	2026-08-27 13:52:55.152279+00	2026-08-27 13:52:55.152279+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b80d2c2d-0324-4a38-b79f-bbe0952a0239	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205LZZ	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Romain HEDJAL"	2026-08-27 13:52:55.155016+00	2026-08-27 13:52:55.155016+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a016a881-bc77-403e-943b-31d364aad106	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M3C	Lenovo	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.158942+00	2026-08-27 13:52:55.158942+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c07776a3-64bb-47ca-abe9-1be004d8ff8a	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205KH2	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Jonathan NINEUIL"	2026-08-27 13:52:55.161744+00	2026-08-27 13:52:55.161744+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ce447f5c-b4f9-4370-8218-0b1e780b0aa9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205K9F	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Olivia ROUSSILLE"	2026-08-27 13:52:55.163991+00	2026-08-27 13:52:55.163991+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
031dc6d8-af65-4f81-b593-a52742cd030b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205LYC	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Antonin BARTHAS"	2026-08-27 13:52:55.166046+00	2026-08-27 13:52:55.166046+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
02678621-b8a6-40df-8eaf-8596daf0e3e7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205LW1	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Nicolas DAUTEL"	2026-08-27 13:52:55.167767+00	2026-08-27 13:52:55.167767+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c70e9aa0-1e9e-4079-8447-75c95e9eceef	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205MA2	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Volodia MINIEJEW"	2026-08-27 13:52:55.169421+00	2026-08-27 13:52:55.169421+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
badec9ef-a240-496b-aafa-8dfe933cab6e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M10	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Manon SANTOS"	2026-08-27 13:52:55.171039+00	2026-08-27 13:52:55.171039+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
220fd661-e04b-4ddc-971a-18aadaf84513	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205MA1	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Manon RODRIGUEZ"	2026-08-27 13:52:55.172788+00	2026-08-27 13:52:55.172788+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
80aed30f-bbeb-4d92-b3ef-c7547db7c04c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M9Q	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Karim MIALHE"	2026-08-27 13:52:55.174426+00	2026-08-27 13:52:55.174426+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7d8f8d8b-c428-4ecb-9081-a6ef42850715	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205LZV	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Stephane COULON"	2026-08-27 13:52:55.175926+00	2026-08-27 13:52:55.175926+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
eefc401f-2531-4ebd-a551-7b60279bc1c4	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205KCH	Lenovo	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:52:55.177442+00	2026-08-27 13:52:55.177442+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0490a7ae-2f51-4eea-b093-7906c5d17dd7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M1N	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Andy Touré"	2026-08-27 13:52:55.178901+00	2026-08-27 13:52:55.178901+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
07982c4d-3323-4fcd-ad87-dfd3d7b3b720	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M06	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Soumia GRASSAUD"	2026-08-27 13:52:55.180373+00	2026-08-27 13:52:55.180373+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e1e81eeb-830e-457e-b008-7d6ffcf8eab4	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M4P	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Enya SARDA"	2026-08-27 13:52:55.182003+00	2026-08-27 13:52:55.182003+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
653bab47-d7a9-4acb-8c8a-5099a621ff35	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M3W	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Aurélie COMBES"	2026-08-27 13:52:55.183646+00	2026-08-27 13:52:55.183646+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a282749a-7fcb-46df-bdeb-229e737fee28	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205MOR	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Marie-Morgane PORTE"	2026-08-27 13:52:55.185566+00	2026-08-27 13:52:55.185566+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
23a16033-9478-4d8e-924b-d0817a1d0475	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M41	Lenovo	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Grégoire MASSAT"	2026-08-27 13:52:55.187486+00	2026-08-27 13:52:55.187486+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cec544ca-6480-4ee5-ba7c-9c861beec2bf	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRKYG	\N	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Elsa BARASCUD"	2026-08-27 13:52:55.189353+00	2026-08-27 13:52:55.189353+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e10574ff-3444-4d9d-aac6-dbffcdc9884b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRL5F	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.193142+00	2026-08-27 13:52:55.193142+00	Poly 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
769573d3-5601-4923-8fa8-cd26cef8cd37	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN-ORHS1R	Dell	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Mélanie MARESTANG"	2026-08-27 13:52:55.195261+00	2026-08-27 13:52:55.195261+00	Dell	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a0ddd0f0-753b-4e2c-b0de-701c2f2bd8c7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRL6W	Poly	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.196882+00	2026-08-27 13:52:55.196882+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d087701f-8be7-489f-acd0-193e84a1ade5	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRL57	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.19841+00	2026-08-27 13:52:55.19841+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
667feb96-feb2-494d-babb-379dbb4ba2e2	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511937A2153	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.199737+00	2026-08-27 13:52:55.202219+00	iiyama	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
30a5d154-c832-485c-9fe7-e41e65e2d4c8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.203239+00	2026-08-27 13:52:55.203239+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6987226f-ec30-40d5-b0f8-83b9a715030e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJAUXB	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.20453+00	2026-08-27 13:52:55.20453+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
393fa0ce-2520-4048-9811-406b796ff26c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE004687	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.205889+00	2026-08-27 13:52:55.208537+00	Fujitsu	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
92d97f2a-29e8-44a0-802e-0b7675e6e4c5	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE004886	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.209427+00	2026-08-27 13:52:55.211374+00	Fujitsu	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
441e49b3-b6fc-4388-bf28-12f564600968	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066912	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.21224+00	2026-08-27 13:52:55.214362+00	Fujitsu	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0d19c6af-a7d8-452b-8051-7f15623c57cb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	39FRMG	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.215063+00	2026-08-27 13:52:55.215063+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0157054d-2d79-4a99-8164-51492a6dddd9	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE003037	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.216022+00	2026-08-27 13:52:55.217615+00	Futjitsu	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9ce0a426-717d-48e0-b5c2-b411da531739	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511209E2732	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.218315+00	2026-08-27 13:52:55.219872+00	IIYAMA	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
829f9001-2cb7-4ed9-9f09-48d9b097db32	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLPC6	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.220569+00	2026-08-27 13:52:55.220569+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dd93e1d2-ff2d-4858-ac04-a72b78a864a1	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511209E2728	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.221408+00	2026-08-27 13:52:55.223196+00	IIYAMA	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9375e75a-e2ad-468a-a9b3-afcd9832d87f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRLJ2	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.223969+00	2026-08-27 13:52:55.223969+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9ac17716-0b8e-43b6-b54e-8a9ab31dbac3	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E4B	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.225119+00	2026-08-27 13:52:55.225119+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b303ecb1-79b0-496a-8bc3-cfdb201d5564	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRL60	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:52:55.226076+00	2026-08-27 13:52:55.226076+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e22b29f4-f9b2-4a62-8420-5f9b3ccf3afb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHR0B0U8	\N	\N	assigned	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Mathieu MUSCAT"	2026-08-27 13:52:55.227165+00	2026-08-27 13:52:55.227165+00	LOGI	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
925604ac-f4c6-4957-b988-b3025c3dbad4	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 25357667\nAffectation importée non résolue : Usager="-" ; Utilisateur="Sonia HESNARD COURET"	2026-08-27 13:52:55.22817+00	2026-08-27 13:52:55.22817+00	0760700979	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fb184a9e-c344-465f-99db-49f838cc5943	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 16199102\nAffectation importée non résolue : Usager="-" ; Utilisateur="Karim MIALHE"	2026-08-27 13:52:55.229268+00	2026-08-27 13:52:55.229268+00	0760701059	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
99b81b2d-e354-456e-87db-3584c2f62eb3	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 57808104\nAffectation importée non résolue : Usager="-" ; Utilisateur="Ophélie DELCUSE"	2026-08-27 13:52:55.230328+00	2026-08-27 13:52:55.230328+00	0611232473	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
47167d24-4017-4ef2-80bd-2b8311dfb41e	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 95550554\nAffectation importée non résolue : Usager="-" ; Utilisateur="Louis-Henri CAPEL"	2026-08-27 13:52:55.231289+00	2026-08-27 13:52:55.231289+00	0618430037	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8823c495-1a46-4397-8262-c8f9eceeb20f	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 79021086\nAffectation importée non résolue : Usager="-" ; Utilisateur="Ugo THIEBAUT"	2026-08-27 13:52:55.232343+00	2026-08-27 13:52:55.232343+00	0623610014	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a7875488-b7ff-49ed-833d-55f7108fc157	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 74314342\nAffectation importée non résolue : Usager="-" ; Utilisateur="Emilie ROUZOUL"	2026-08-27 13:52:55.233526+00	2026-08-27 13:52:55.233526+00	0610195122	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f4639782-dd41-49f5-b8e5-17cf120f2fdc	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 08292245\nAffectation importée non résolue : Usager="-" ; Utilisateur="Jean Pierre RODRIGUEZ"	2026-08-27 13:52:55.23474+00	2026-08-27 13:52:55.23474+00	0609317708	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0a89845b-69da-4d3e-889b-485896fc5ae4	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 19143771\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marjorie ZUCCHETTI"	2026-08-27 13:52:55.235805+00	2026-08-27 13:52:55.235805+00	0621573601	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a25d46f3-f164-434f-af32-6b5b91f8301b	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK: 33116458\nAffectation importée non résolue : Usager="-" ; Utilisateur="Aurelie PALUDETTO"	2026-08-27 13:52:55.236862+00	2026-08-27 13:52:55.236862+00	0761545421	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
06fa5a6e-533d-41af-890c-bfd0d975364a	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 15348935\nAffectation importée non résolue : Usager="-" ; Utilisateur="Guylaine DROUOT"	2026-08-27 13:52:55.237918+00	2026-08-27 13:52:55.237918+00	0761539691	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
72cdeaa2-8915-43eb-aa58-11f81b06e902	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 79145485\nAffectation importée non résolue : Usager="-" ; Utilisateur="Olivier LESTARPE"	2026-08-27 13:52:55.238949+00	2026-08-27 13:52:55.238949+00	0761937906	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
929a7f16-341e-43d7-acc1-6e5c69944d84	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 02076986\nAffectation importée non résolue : Usager="-" ; Utilisateur="Stephane COULON"	2026-08-27 13:52:55.240058+00	2026-08-27 13:52:55.240058+00	0625607609	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
58e2c8cd-77a7-48ab-958b-40a1d46166cf	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	Puk : 14725146\nAffectation importée non résolue : Usager="-" ; Utilisateur="Corinne VIGNAU"	2026-08-27 13:52:55.241049+00	2026-08-27 13:52:55.241049+00	0603630114	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c2c8d80f-ca12-46a1-9a14-3d1b33485e2c	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 96315508\nAffectation importée non résolue : Usager="-" ; Utilisateur="Emilie KOEHL"	2026-08-27 13:52:55.242107+00	2026-08-27 13:52:55.242107+00	0698576913	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
86eadd8f-5e76-492e-be1a-1a3d490f3336	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK: 25240324\nAffectation importée non résolue : Usager="-" ; Utilisateur="Stéphane NAKACHE"	2026-08-27 13:52:55.243157+00	2026-08-27 13:52:55.243157+00	624908951	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
19ed5b98-f477-441f-b2cf-fb1ef7d652a6	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 38210230\nAffectation importée non résolue : Usager="-" ; Utilisateur="Laetitia CHARLES"	2026-08-27 13:52:55.244078+00	2026-08-27 13:52:55.244078+00	0614356692	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ab0de04d-8395-4799-a15d-d70e65f2a877	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 46369339\nAffectation importée non résolue : Usager="-" ; Utilisateur="Samia MAHJOUB"	2026-08-27 13:52:55.245281+00	2026-08-27 13:52:55.245281+00	0616017212	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c113414a-e7fd-4080-9700-6b87092a0184	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 49870946\nAffectation importée non résolue : Usager="-" ; Utilisateur="Rachel CONSTANS"	2026-08-27 13:52:55.246174+00	2026-08-27 13:52:55.246174+00	0646361895	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4ff11352-17c2-46fa-b4fa-44d7f305babf	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 54104628\nAffectation importée non résolue : Usager="-" ; Utilisateur="Vanessa BOUCHAREYSSAS"	2026-08-27 13:52:55.247006+00	2026-08-27 13:52:55.247006+00	0603920240	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a21a99cb-cc46-4251-9c5c-e1298187522b	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK: 92550958\nAffectation importée non résolue : Usager="-" ; Utilisateur="_Allolily"	2026-08-27 13:52:55.24791+00	2026-08-27 13:52:55.24791+00	0778692759	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0556aa7a-aa22-451e-aa4a-01e0831a23af	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 38713986\nAffectation importée non résolue : Usager="-" ; Utilisateur="Brice CHAMAYOU"	2026-08-27 13:52:55.249076+00	2026-08-27 13:52:55.249076+00	0615951480	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b430e581-3dfc-4497-b1d5-8e00dfa2f4c0	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 50730331\nAffectation importée non résolue : Usager="-" ; Utilisateur="Anissa BENHAMOU"	2026-08-27 13:52:55.250323+00	2026-08-27 13:52:55.250323+00	0646631834	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7687f5a7-9ca3-4bdf-bf08-45a4158f0aaf	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 01048729\nAffectation importée non résolue : Usager="-" ; Utilisateur="Nathalie SOLANES"	2026-08-27 13:52:55.251458+00	2026-08-27 13:52:55.251458+00	0646151705	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
be99958a-1fce-4194-bf00-47aa3384b058	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 95260465	2026-08-27 13:52:55.252618+00	2026-08-27 13:52:55.252618+00	0762684270	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ebdb2a7b-bda7-4839-b1a9-72471aa842dc	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 70945664\nAffectation importée non résolue : Usager="-" ; Utilisateur="Elisa CLAVEL"	2026-08-27 13:52:55.253705+00	2026-08-27 13:52:55.253705+00	0762684316	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
74480184-80ce-4e54-9131-4c8f3a5b0cea	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 55324764\nAffectation importée non résolue : Usager="-" ; Utilisateur="Cécile BOIVIN"	2026-08-27 13:52:55.25483+00	2026-08-27 13:52:55.25483+00	0622258065	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ab267bfc-d09d-4d12-985f-29caf6d9191e	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 42608562	2026-08-27 13:52:55.255804+00	2026-08-27 13:52:55.255804+00	0609514947	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
29bd9689-45c8-48af-8c98-9a8483ac9386	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 46566860	2026-08-27 13:52:55.256997+00	2026-08-27 13:52:55.256997+00	617377207	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1e819d31-e324-4c24-8d0a-cb29226b1fae	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 66553524\nAffectation importée non résolue : Usager="-" ; Utilisateur="Volodia MINIEJEW"	2026-08-27 13:52:55.258111+00	2026-08-27 13:52:55.258111+00	0623240644	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
865394f3-f1ed-423d-8486-28451c22854a	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 09613615\nAffectation importée non résolue : Usager="-" ; Utilisateur="Victor TRILHA"	2026-08-27 13:52:55.259194+00	2026-08-27 13:52:55.259194+00	0625599439	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b775f2bd-2284-4b60-b4ce-68298427f5fc	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 56774589\nAffectation importée non résolue : Usager="-" ; Utilisateur="Christelle PAYSSE"	2026-08-27 13:52:55.260142+00	2026-08-27 13:52:55.260142+00	0619254005	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
692d7e15-9703-4412-808b-5e6381f5e9d8	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 20562059	2026-08-27 13:52:55.291419+00	2026-08-27 13:52:55.291419+00	0646709961	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
51b32eb0-fa9d-44a8-9ade-10b5b56c2c24	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 96452359	2026-08-27 13:52:55.293478+00	2026-08-27 13:52:55.293478+00	0624766910	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3ffbc133-a946-45e1-b7fd-0aabc93e19d3	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 30083119\nAffectation importée non résolue : Usager="-" ; Utilisateur="Romain HEDJAL"	2026-08-27 13:52:55.294969+00	2026-08-27 13:52:55.294969+00	0659580502	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7edec2cc-00e3-4c8e-85a4-f15f1e0b72f2	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	Puk: 56437789	2026-08-27 13:52:55.296145+00	2026-08-27 13:52:55.296145+00	0764760535	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1171617e-6552-4833-9b6f-6e16f430a178	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	Puk : 64191209\nAffectation importée non résolue : Usager="-" ; Utilisateur="Cédric FIRMIN"	2026-08-27 13:52:55.297528+00	2026-08-27 13:52:55.297528+00	0764760539	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
658bbfa0-7300-4755-b2b8-5785c6076c89	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 29002627	2026-08-27 13:52:55.29904+00	2026-08-27 13:52:55.29904+00	0661810253	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4cce166a-a083-4245-abc7-4463451ad4fd	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 17897672\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marianne BOSC-ANDRIEU"	2026-08-27 13:52:55.300421+00	2026-08-27 13:52:55.300421+00	0761904620	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c0101b7e-9963-4aca-a2f6-90fe71ad614b	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 31771624	2026-08-27 13:52:55.301891+00	2026-08-27 13:52:55.301891+00	0625548756	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8dd33675-af54-4d01-8cd1-98bea0d714a0	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 98095046\nAffectation importée non résolue : Usager="-" ; Utilisateur="Adeline OSBINI"	2026-08-27 13:52:55.303345+00	2026-08-27 13:52:55.303345+00	0623342359	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f0dfa3cb-3862-4804-82e0-93420ddf5ad8	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 51772012\nAffectation importée non résolue : Usager="-" ; Utilisateur="Cédric COCOLO"	2026-08-27 13:52:55.304768+00	2026-08-27 13:52:55.304768+00	0779447166	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a60dc6a7-1225-40f3-b54e-1125403c4ab6	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 45207411\nAffectation importée non résolue : Usager="-" ; Utilisateur="Emilie LAUTIER-VINEL"	2026-08-27 13:52:55.306072+00	2026-08-27 13:52:55.306072+00	0627246958	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
084533b7-f20a-439f-996c-d4f1ebfadcd1	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 34283798\nAffectation importée non résolue : Usager="-" ; Utilisateur="Olivia ROUSSILLE"	2026-08-27 13:52:55.307582+00	2026-08-27 13:52:55.307582+00	0611232491	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
34eef125-eea0-48ac-8863-def318c8c081	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 31457187	2026-08-27 13:52:55.308838+00	2026-08-27 13:52:55.308838+00	0778251651	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1bea344e-4069-4751-9e8a-6699f367411e	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 60223382\nAffectation importée non résolue : Usager="-" ; Utilisateur="Jean-Christophe RAYNAUD"	2026-08-27 13:52:55.309853+00	2026-08-27 13:52:55.309853+00	0609378685	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d7bdcf41-2ffb-4175-aef6-9c495334becd	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 65864108\nAffectation importée non résolue : Usager="-" ; Utilisateur="Laura AVERSAING"	2026-08-27 13:52:55.310756+00	2026-08-27 13:52:55.310756+00	0612731759	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5b8431b8-3e4b-4a2b-8ce5-7fb76f53e5b6	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 52858167\nAffectation importée non résolue : Usager="-" ; Utilisateur="Nicolas DREUX"	2026-08-27 13:52:55.311849+00	2026-08-27 13:52:55.311849+00	0779372341	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ef42fccd-b1f4-45dc-810b-fdb27f13f959	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 29324052	2026-08-27 13:52:55.31324+00	2026-08-27 13:52:55.31324+00	0750157265	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
450cf2a3-ba5c-444e-8b31-15977db01957	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 77882678\nAffectation importée non résolue : Usager="-" ; Utilisateur="Antonin BARTHAS"	2026-08-27 13:52:55.314242+00	2026-08-27 13:52:55.314242+00	0628111821	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
64446bb5-b0af-4da3-b398-1e34bfa934aa	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	Puk : 18038845	2026-08-27 13:52:55.315421+00	2026-08-27 13:52:55.315421+00	0617086759	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f944825c-0f4f-4f65-858c-43c23638c351	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 73768755\nAffectation importée non résolue : Usager="-" ; Utilisateur="Sana TOUMI"	2026-08-27 13:52:55.316275+00	2026-08-27 13:52:55.316275+00	0618484021	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
69519b45-0380-4e8b-b813-f41beb9449d7	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 18051120\nAffectation importée non résolue : Usager="-" ; Utilisateur="Thomas FILLETTE"	2026-08-27 13:52:55.317138+00	2026-08-27 13:52:55.317138+00	0658820265	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f705ec14-e612-49eb-811b-d4ae82ae8138	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	Puk : 66847938\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marina TUNEZ"	2026-08-27 13:52:55.318051+00	2026-08-27 13:52:55.318051+00	0772458991	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5c55ad69-d4e9-4711-8ae9-9d1d78f657c4	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	puk: 17382597\nAffectation importée non résolue : Usager="-" ; Utilisateur="Yannis DELMAS"	2026-08-27 13:52:55.319096+00	2026-08-27 13:52:55.319096+00	0626547661	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5e255a49-cefe-4364-a727-d6396712b446	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	assigned	\N	\N	\N	PUK : 42932269\nAffectation importée non résolue : Usager="-" ; Utilisateur="Corinne FRAYSSINES"	2026-08-27 13:52:55.321353+00	2026-08-27 15:33:33.166562+00	0671747379	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4e8da17e-2a97-4f19-a10d-6d43062f1c23	ea7161f9-b2f3-4513-96b9-86cdd48a1cf2	\N	\N	\N	\N	in_stock	\N	\N	\N	PUK : 92557298\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marylene PINCHON"	2026-08-27 13:52:55.320179+00	2026-08-27 13:52:55.320179+00	0632872162	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
\.


--
-- Data for Name: inventory_brands; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.inventory_brands (id, label, sort_order, created_at) FROM stdin;
85208eee-be9f-4b30-ade3-c3b22d7a5e42	Dell	0	2026-07-29 07:29:47.6543+00
ab10f5c1-0903-4864-a12b-cb42ac9040e1	HP	0	2026-07-29 07:29:47.6543+00
3437c78e-e65a-4171-b582-613405a32607	Lenovo	0	2026-07-29 07:29:47.6543+00
a6114474-31d5-491d-90d8-48fe45debc28	Apple	0	2026-07-29 07:29:47.6543+00
217ab842-abc7-4d44-964e-0c104db06cd8	Samsung	0	2026-07-29 07:29:47.6543+00
28abd8d6-ba71-469a-88f7-e0bf3a5b1251	Motorola	0	2026-07-29 07:29:47.6543+00
83d3f70b-75ae-4b94-bbf0-17d08379e518	Microsoft	0	2026-07-29 07:29:47.6543+00
\.


--
-- Data for Name: inventory_budgets; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.inventory_budgets (id, label, sort_order, created_at) FROM stdin;
29a49c0d-b5f6-4927-ae9d-5b543ed59488	2026-2027 - Ordinateurs	0	2026-07-29 08:29:14.025716+00
85de2e91-5137-4216-b99c-df71269cfc09	2026-2027 - Ecrans	0	2026-07-29 08:29:25.342799+00
\.


--
-- Data for Name: inventory_memories; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.inventory_memories (id, label, sort_order, created_at) FROM stdin;
1fd8299e-26a2-433d-94f9-b22913f4579c	8 Go	0	2026-07-29 07:29:47.6543+00
d099f4f3-37cc-4b0c-a231-9971b89eea02	16 Go	0	2026-07-29 07:29:47.6543+00
62cda6ed-88b4-42aa-8a8e-becdecb7c6f4	32 Go	0	2026-07-29 07:29:47.6543+00
36212a50-110d-4328-b413-9ad9039e0eb0	64 Go	0	2026-07-29 07:29:47.6543+00
\.


--
-- Data for Name: inventory_operating_systems; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.inventory_operating_systems (id, label, sort_order, created_at) FROM stdin;
e7bc04ac-6c21-46a1-9144-5b5ee32302a6	Windows 11	0	2026-07-29 07:29:47.6543+00
a1dc2dc0-5080-4f9d-a2f5-5c380cb21c84	Windows 10	0	2026-07-29 07:29:47.6543+00
0b975a08-f8c1-4d9f-b6af-59ba4fdac023	macOS	0	2026-07-29 07:29:47.6543+00
620bd328-2be5-4f56-bb79-62395360efee	Android	0	2026-07-29 07:29:47.6543+00
9b3ebb46-67dd-4987-89e2-36ab661707ac	iOS	0	2026-07-29 07:29:47.6543+00
c958e602-6aee-407d-abaf-e81ac67e0d03	Linux	0	2026-07-29 08:28:31.689232+00
\.


--
-- Data for Name: inventory_processors; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.inventory_processors (id, label, sort_order, created_at) FROM stdin;
61dc21b8-7127-48e0-8bf2-cb24fbce5a09	i3	0	2026-07-29 07:29:47.6543+00
2cebc701-4011-4dfc-bc35-fa723bc26188	i5	0	2026-07-29 07:29:47.6543+00
560fca87-a5b7-45bd-b731-aa1e05bfad8c	i7	0	2026-07-29 07:29:47.6543+00
b9b7522e-5c3c-40d5-be0d-ad898a6b5ebc	i9	0	2026-07-29 07:29:47.6543+00
\.


--
-- Data for Name: inventory_sizes; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.inventory_sizes (id, label, sort_order, created_at) FROM stdin;
37e4e7fc-c1b9-400c-83b2-49e8b18b8383	13"	0	2026-07-29 07:29:47.6543+00
693296f2-996c-422a-b619-17c832ae54e9	15"	0	2026-07-29 07:29:47.6543+00
8b7ee720-6c2b-4f44-a592-ff4ce3efb019	16"	0	2026-07-29 07:29:47.6543+00
bf5eb655-e214-4849-a730-7f4cfd98f174	17"	0	2026-07-29 07:29:47.6543+00
373adcbf-5dea-43ec-884f-f22953bb4001	22"	0	2026-07-29 07:29:47.6543+00
b2b11934-1afd-4390-a144-b59925ee4342	24"	0	2026-07-29 07:29:47.6543+00
d0798f08-229d-436a-8a9f-5182c485336e	27"	0	2026-07-29 07:29:47.6543+00
d0bd3c55-f78d-4fb3-9cd5-5ea42bddd012	32"	0	2026-07-29 07:29:47.6543+00
\.


--
-- Data for Name: inventory_statuses; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.inventory_statuses (id, label, sort_order, created_at) FROM stdin;
49092763-498b-4c77-bdfe-a2d4c9597cf2	En stock	0	2026-07-29 07:29:47.6543+00
acec76a6-0350-42b1-bc5d-c0f3226111c5	Attribué	0	2026-07-29 07:29:47.6543+00
4de95164-3be6-4330-8b10-a94ea38fcf64	En réinstallation	0	2026-07-29 07:29:47.6543+00
6295c2a3-2e03-42bb-bba4-837128a1c1fa	Défectueux	0	2026-07-29 07:29:47.6543+00
6548965c-7570-4833-8661-a293dc25c698	Réformé	0	2026-07-29 07:29:47.6543+00
\.


--
-- Data for Name: inventory_suppliers; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.inventory_suppliers (id, label, sort_order, created_at) FROM stdin;
10e027d2-851b-4605-a2d8-e479cb0a2207	DataServices	0	2026-07-29 08:28:52.92987+00
efdf0d2f-b67b-4b43-8fb7-2e98219a0b73	Scipline	0	2026-07-29 08:28:58.570382+00
\.


--
-- Data for Name: license_types; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.license_types (id, code, label, total_seats, has_expiration, default_renewal_notice_days, notes, created_at, updated_at, requestable_for_onboarding) FROM stdin;
5a94f564-3165-43e9-b435-257276cd0e0d	SEIITRA	Seiitra	0	t	30	\N	2026-07-20 13:11:53.942292+00	2026-07-20 13:11:53.942292+00	t
1b6cd60e-564b-4130-a6a3-b840db88b342	POWER_BI_PRO	Power BI Pro	8	f	30	\N	2026-07-22 09:25:18.102423+00	2026-07-22 10:41:26.795176+00	t
158f8d30-9ac4-4f04-af38-e0a307be4ec8	Microsoft_365_Copilot	Microsoft 365 Copilot	85	f	30	\N	2026-07-22 09:25:18.115198+00	2026-07-22 10:41:26.8051+00	t
ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	SPB	Microsoft 365 Business Premium	78	f	30	\N	2026-07-22 09:26:38.746075+00	2026-07-22 10:41:26.839128+00	f
1d3219cf-77b1-4fcd-960f-6e30f8e9fb85	O365_BUSINESS_PREMIUM	Microsoft 365 Business Standard	105	f	30	\N	2026-07-22 09:25:18.160847+00	2026-07-22 10:41:26.846905+00	f
\.


--
-- Data for Name: licenses; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.licenses (id, license_type_id, seat_key, status, assigned_employee_id, assigned_at, expiration_date, renewal_notice_days, notes, created_at, updated_at) FROM stdin;
7d4d4252-5592-469d-8c26-a6cf5f4720b9	5a94f564-3165-43e9-b435-257276cd0e0d	TEST-LICENCE-001	assigned	1e4c6d30-2665-479f-a16b-803bf285a11f	2026-07-22	\N	\N	Test migration PostgreSQL	2026-07-20 14:30:51.230287+00	2026-07-22 11:06:26.526171+00
5a76c99c-ad5f-4469-9576-2b8a03e24c11	5a94f564-3165-43e9-b435-257276cd0e0d	\N	available	\N	\N	\N	\N	\N	2026-07-22 16:22:56.179345+00	2026-07-22 16:22:56.179345+00
24b164ac-150e-4c5e-b025-80208fb59145	5a94f564-3165-43e9-b435-257276cd0e0d	R740R120-001	available	\N	\N	\N	\N	\N	2026-07-22 16:51:26.746209+00	2026-07-22 16:51:26.746209+00
4dd3dcf5-53a1-472c-b26c-ce9dd687aa58	5a94f564-3165-43e9-b435-257276cd0e0d	R740R125	available	\N	\N	\N	\N	\N	2026-07-22 17:03:50.515329+00	2026-07-22 17:03:50.515329+00
\.


--
-- Data for Name: microsoft_license_filters; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.microsoft_license_filters (sku_part_number, enabled) FROM stdin;
POWER_BI_PRO	t
Microsoft_365_Copilot	t
SPZA_IW	f
WINDOWS_STORE	f
FLOW_FREE	f
CCIBOTS_PRIVPREV_VIRAL	f
SPB	t
POWERAPPS_VIRAL	f
EXCHANGESTANDARD	f
O365_BUSINESS_PREMIUM	t
POWER_BI_STANDARD	f
PBI_PREMIUM_PER_USER	f
Power_Pages_vTrial_for_Makers	f
RMSBASIC	f
Teams_Premium_(for_Departments)	f
RIGHTSMANAGEMENT_ADHOC	f
POWERAPPS_DEV	f
\.


--
-- Data for Name: movement_actions; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.movement_actions (id, movement_id, action_type, label, due_date, done_at, notes, sort_order, created_at) FROM stdin;
9ef979fa-f744-4f03-ab9b-c27922ec1bc1	d1839fd9-a603-4c8d-97c0-702d9fd5b040	account	test	\N	\N	\N	1	2026-07-30 10:15:04.046137+00
770b72ef-f1da-4a3e-8ba3-9e81a9291b4b	d1839fd9-a603-4c8d-97c0-702d9fd5b040	account	Création compte Entra ID	\N	\N	\N	20	2026-07-30 10:15:04.046137+00
9a85a30a-e6ff-4ed6-ae1d-1132b03d7ab7	0b6740ee-5ad0-4dbd-8c56-1137933137f6	other	test	\N	2026-07-22 15:15:59.964+00	\N	99	2026-07-22 15:15:07.861577+00
57f0ad24-0b17-425f-af12-ce5c9b5488a1	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	account	Créer le compte AD	\N	\N	\N	5	2026-07-22 15:21:46.540959+00
5e2dc888-0557-44d4-a299-c15197b9b9cd	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	account	Déclencher la synchronisation Entra ID	\N	\N	\N	20	2026-07-22 15:21:46.540959+00
ce03b95f-73d2-4f6d-92e2-00910f4f704e	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-22 15:21:46.540959+00
557cfa81-5acf-47fc-8765-8a177c9098f5	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-22 15:21:46.540959+00
3a322c8b-f3ee-4de6-94a1-8de7783405a3	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-22 15:21:46.540959+00
ac8ae8bf-e39f-4052-9e30-9a0ca2eb2d56	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-22 15:21:46.540959+00
b6a836d1-a0f6-48d9-b045-4d35a246e414	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	telephony	Créer le compte 3CX	\N	2026-07-28 09:33:51.021+00	\N	60	2026-07-22 15:21:46.540959+00
480df30f-91ad-4a18-b643-b5cc25aa4ca9	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	printing	Créer le compte PaperCut	\N	2026-07-28 09:33:56.901+00	\N	70	2026-07-22 15:21:46.540959+00
c35ec05b-66bf-4511-ab8c-808f9fdca2ca	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	account	test	\N	\N	\N	1	2026-07-29 16:13:09.253461+00
f89fb909-44f2-444d-8046-16d16ff21b77	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	account	Création compte Entra ID	\N	\N	\N	20	2026-07-29 16:13:09.253461+00
a83e4962-a6fe-4e8d-8319-148b53764d42	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-29 16:13:09.253461+00
8a0792cb-9a19-443a-b72c-b9fcc08e61c2	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-29 16:13:09.253461+00
b46a8109-083c-4d82-8245-66d88d829b76	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-29 16:13:09.253461+00
7144cb58-67a0-4505-ae97-039f9c34fd1e	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-29 16:13:09.253461+00
3aece0c9-7d8d-453c-88c7-308343508aea	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-29 16:13:09.253461+00
ebc2a0a3-bfd0-44af-bd5f-30629b5e275a	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-29 16:13:09.253461+00
70dbf73f-f921-438a-baef-e42f4c61ce6a	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	other	test	\N	\N	\N	90	2026-07-29 16:13:09.253461+00
0fcd3af1-6315-4a03-89d7-792196fe6258	4b0c9fe6-96ed-4d89-801a-c17c673889f8	account	test	\N	\N	\N	1	2026-07-29 16:16:07.001416+00
862de14f-f75c-4557-9e89-832fb65bea17	4b0c9fe6-96ed-4d89-801a-c17c673889f8	account	Création compte Entra ID	\N	\N	\N	20	2026-07-29 16:16:07.001416+00
d4a2096c-d0d2-4bfc-802c-12c601c30017	4b0c9fe6-96ed-4d89-801a-c17c673889f8	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-29 16:16:07.001416+00
8b78d318-cf48-4925-8e5c-9c8042290100	4b0c9fe6-96ed-4d89-801a-c17c673889f8	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-29 16:16:07.001416+00
aff55103-997b-432c-8b5f-34b7ef4cb039	4b0c9fe6-96ed-4d89-801a-c17c673889f8	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-29 16:16:07.001416+00
a17aee98-73bd-4cf4-80fe-2afdcdbafbd8	4b0c9fe6-96ed-4d89-801a-c17c673889f8	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-29 16:16:07.001416+00
9c821f0a-549f-405d-bd37-d9cb1e7120c6	4b0c9fe6-96ed-4d89-801a-c17c673889f8	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-29 16:16:07.001416+00
f91b2dba-1d5d-43ed-9138-7a25223e9933	4b0c9fe6-96ed-4d89-801a-c17c673889f8	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-29 16:16:07.001416+00
e466ccb4-3ede-48e2-8673-6debcab4bb25	4b0c9fe6-96ed-4d89-801a-c17c673889f8	other	test	\N	\N	\N	90	2026-07-29 16:16:07.001416+00
d253715e-bb9d-4bb5-964a-9b21a2c77412	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	account	test	\N	\N	\N	1	2026-07-30 07:06:13.03858+00
fcdfaa76-3a11-4716-ba03-3ad49e402687	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	account	Création compte Entra ID	\N	\N	\N	20	2026-07-30 07:06:13.03858+00
f5f797ad-e7e0-4fd0-b2d0-d5d3b65542fb	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-30 07:06:13.03858+00
1bcc4515-9c6e-4401-a94b-5e9f10389a7b	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-30 07:06:13.03858+00
7abc16af-b692-4321-90ea-6198fd0856f1	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-30 07:06:13.03858+00
ac96871d-9946-406e-b721-fd02522db1fb	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-30 07:06:13.03858+00
f9e40732-7897-4d70-80e6-5a146d1abd87	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-30 07:06:13.03858+00
059d7c1e-e2c0-4c15-b751-67b8ae6ae132	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-30 07:06:13.03858+00
fbfcf438-eb2e-4e1e-acfe-1c5814ad03ce	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	other	test	\N	\N	\N	90	2026-07-30 07:06:13.03858+00
3cc5d2ad-eaf4-43bb-901b-4fa57ec76188	d1839fd9-a603-4c8d-97c0-702d9fd5b040	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-30 10:15:04.046137+00
2267642b-a24e-4536-8f5e-75600195e23f	d1839fd9-a603-4c8d-97c0-702d9fd5b040	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-30 10:15:04.046137+00
f61edd0c-3737-4b9d-a816-104147a2c2aa	d1839fd9-a603-4c8d-97c0-702d9fd5b040	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-30 10:15:04.046137+00
1ee02d68-c7f3-49a9-b6dc-ed5e025ade9a	d1839fd9-a603-4c8d-97c0-702d9fd5b040	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-30 10:15:04.046137+00
4ddf3938-c7a6-41e5-ad22-69e082d4bfee	d1839fd9-a603-4c8d-97c0-702d9fd5b040	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-30 10:15:04.046137+00
6488a8f1-22e5-4bd8-af14-248985eddb5d	d1839fd9-a603-4c8d-97c0-702d9fd5b040	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-30 10:15:04.046137+00
0282d8aa-361c-4059-873e-0b0025b80b39	d1839fd9-a603-4c8d-97c0-702d9fd5b040	other	test	\N	\N	\N	90	2026-07-30 10:15:04.046137+00
de75b102-8a58-431d-bc46-353eb0084a0e	a123f0f9-90a9-4e74-80f0-1155bbd64729	account	test	\N	\N	\N	1	2026-07-30 12:35:32.903509+00
d8469b2a-2a75-4c7d-893f-a72c8fcff1fb	a123f0f9-90a9-4e74-80f0-1155bbd64729	account	Création compte Entra ID	\N	\N	\N	20	2026-07-30 12:35:32.903509+00
b5dd9143-f0f2-432b-9618-6e196d795f4e	a123f0f9-90a9-4e74-80f0-1155bbd64729	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-30 12:35:32.903509+00
ea43404f-fcf2-4167-8e36-96ae9b9051ff	a123f0f9-90a9-4e74-80f0-1155bbd64729	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-30 12:35:32.903509+00
cb78b7c1-36d8-4363-b23e-5552b1773d0e	a123f0f9-90a9-4e74-80f0-1155bbd64729	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-30 12:35:32.903509+00
3de8a494-7d2e-4f1c-b315-63115ab9cbff	a123f0f9-90a9-4e74-80f0-1155bbd64729	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-30 12:35:32.903509+00
4adbbf11-959f-4964-9435-ed7ef25555fa	a123f0f9-90a9-4e74-80f0-1155bbd64729	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-30 12:35:32.903509+00
21dbceaf-bc7b-47ec-898a-9dcdef5dfac4	a123f0f9-90a9-4e74-80f0-1155bbd64729	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-30 12:35:32.903509+00
d3134f9f-181d-4e58-99f7-2edd0d8b0eee	a123f0f9-90a9-4e74-80f0-1155bbd64729	other	test	\N	\N	\N	90	2026-07-30 12:35:32.903509+00
17abd7cc-c529-4813-9663-1aaef0f10ba3	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	account	test	\N	\N	\N	1	2026-07-30 12:43:32.668054+00
7a6ca4e4-b1f0-4c58-9ae9-d07be24245f8	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	account	Création compte Entra ID	\N	\N	\N	20	2026-07-30 12:43:32.668054+00
93c0071d-38ef-4dc3-957b-05e11bba106e	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-30 12:43:32.668054+00
e9af4015-4833-40e4-a28f-22b10a50a69c	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-30 12:43:32.668054+00
1c3bcdc4-2b0c-4144-98e0-b65f2e53ae07	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-30 12:43:32.668054+00
717425de-1008-4aaf-b3ca-2e765244758a	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-30 12:43:32.668054+00
319ead1d-bc21-4df7-a05f-c0a4eed04b8f	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-30 12:43:32.668054+00
77f41633-d0e5-4064-9f82-0dcf33174750	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-30 12:43:32.668054+00
7eed0f9a-65be-40cb-a3f3-e3bc36f6e9d6	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	other	test	\N	\N	\N	90	2026-07-30 12:43:32.668054+00
f489af2a-a990-4f24-a461-ba6793a1f2de	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	account	test	\N	\N	\N	1	2026-07-30 14:42:01.254566+00
e8ff9f03-8fa2-4ce2-9658-6952bfd36f94	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	account	Création compte Entra ID	\N	\N	\N	20	2026-07-30 14:42:01.254566+00
21cc55f7-de40-463e-929d-8e9425e01f9d	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-30 14:42:01.254566+00
fb7a0e01-634c-45d0-bf0b-50209390806e	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-30 14:42:01.254566+00
dec8bb4d-e457-4d2c-906b-46663c89df4d	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-30 14:42:01.254566+00
14e4ebf9-6f05-431c-a8b3-b392e2275c28	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-30 14:42:01.254566+00
3c24ca19-6ec3-4168-ad36-925d41f0b50e	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-30 14:42:01.254566+00
fc5cfd94-cd4b-4f00-ad11-bbe27c7b9f4c	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-30 14:42:01.254566+00
b770a361-055d-4cdb-a43b-6e0602095d06	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	other	test	\N	\N	\N	90	2026-07-30 14:42:01.254566+00
7a582920-1198-45a8-b4cd-fcd719aa536a	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	account	test	\N	\N	\N	1	2026-07-30 15:59:44.257566+00
daae66eb-5b6b-4d08-ab5c-648bc79fb476	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	account	Création compte Entra ID	\N	\N	\N	20	2026-07-30 15:59:44.257566+00
3c6e1fd0-a385-45bc-aa8a-fcf91ac90b04	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-30 15:59:44.257566+00
87f61b0e-dfa9-420f-9270-f0bb02867b22	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-30 15:59:44.257566+00
d1589cdd-24c7-4ec5-a9e8-8e38c8b463e5	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-30 15:59:44.257566+00
b4f53a92-9d38-45c9-bb5e-87d345d97ee9	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-30 15:59:44.257566+00
971a1f2b-4cb9-45aa-8a8c-dc699447cd4c	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-30 15:59:44.257566+00
41c84eca-cd67-4064-8cf8-faf2f6db1ec2	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-30 15:59:44.257566+00
92224d3c-11f9-4311-8f5d-0a08cb74bb0d	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	other	test	\N	\N	\N	90	2026-07-30 15:59:44.257566+00
dd8a39f7-8ec7-40c6-aa08-e47b26165b1e	6c72dd2c-f583-42fd-9865-35a78dd1b478	account	test	\N	\N	\N	1	2026-07-31 14:01:15.675655+00
e024296f-ef9e-4870-b94d-af615de9f807	6c72dd2c-f583-42fd-9865-35a78dd1b478	account	Création compte Entra ID	\N	\N	\N	20	2026-07-31 14:01:15.675655+00
9ea3c06f-42f7-4d50-a7e3-3f1f5303eacf	6c72dd2c-f583-42fd-9865-35a78dd1b478	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-31 14:01:15.675655+00
72420772-cd1a-4fdd-a3f7-b9783667a4dc	6c72dd2c-f583-42fd-9865-35a78dd1b478	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-31 14:01:15.675655+00
c4efbc04-ca21-4c61-b885-a4e547552de3	6c72dd2c-f583-42fd-9865-35a78dd1b478	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-31 14:01:15.675655+00
b79681d9-046b-4759-98ca-de30d5a1d14d	6c72dd2c-f583-42fd-9865-35a78dd1b478	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-31 14:01:15.675655+00
67f2a653-c547-49dc-8eab-9c1e7fae6715	6c72dd2c-f583-42fd-9865-35a78dd1b478	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-31 14:01:15.675655+00
545bf66f-ea68-4d9b-83a1-1ca50c5cf620	6c72dd2c-f583-42fd-9865-35a78dd1b478	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-31 14:01:15.675655+00
f5c4b361-e1f2-4bf2-beb7-b8cfe4edc335	6c72dd2c-f583-42fd-9865-35a78dd1b478	other	test	\N	\N	\N	90	2026-07-31 14:01:15.675655+00
e606fe5b-539d-4f67-844e-f09ba1502c8f	499e9466-0f33-444e-9576-0b9114f8c115	account	test	\N	\N	\N	1	2026-07-31 14:16:26.467844+00
2277bc20-f6e0-42de-b9ef-fba5f6222f59	499e9466-0f33-444e-9576-0b9114f8c115	account	Création compte Entra ID	\N	\N	\N	20	2026-07-31 14:16:26.467844+00
07179d0b-ff11-4b8d-ad22-0a96eff0fb83	499e9466-0f33-444e-9576-0b9114f8c115	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-31 14:16:26.467844+00
35ce2112-8993-40b4-8919-efc0b5eaf398	499e9466-0f33-444e-9576-0b9114f8c115	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-31 14:16:26.467844+00
213ade38-8495-4c89-b5ca-d71b422627a4	499e9466-0f33-444e-9576-0b9114f8c115	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-31 14:16:26.467844+00
c0797421-f6fb-4164-aa80-ad85595ab409	499e9466-0f33-444e-9576-0b9114f8c115	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-31 14:16:26.467844+00
40d1acc8-d126-4f4a-a535-11fa23f50a9f	499e9466-0f33-444e-9576-0b9114f8c115	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-31 14:16:26.467844+00
4022f134-60cb-4efe-be0f-a3c56db954dc	499e9466-0f33-444e-9576-0b9114f8c115	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-31 14:16:26.467844+00
974ea222-687b-47ff-a1b9-2c6c5173b6b4	499e9466-0f33-444e-9576-0b9114f8c115	other	test	\N	\N	\N	90	2026-07-31 14:16:26.467844+00
dc412154-4206-40dc-8de2-54aecab2a8d0	150669ed-4cf2-461e-b96e-28527ae36507	account	test	\N	\N	\N	1	2026-07-31 14:24:36.940674+00
01316726-a16a-44ff-919b-129381ad8ab0	150669ed-4cf2-461e-b96e-28527ae36507	account	Création compte Entra ID	\N	\N	\N	20	2026-07-31 14:24:36.940674+00
9049c482-4bd7-4bc0-a881-75b023973d63	150669ed-4cf2-461e-b96e-28527ae36507	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-31 14:24:36.940674+00
f05bd1ef-ee24-4807-9a88-c89dc983ed0f	150669ed-4cf2-461e-b96e-28527ae36507	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-31 14:24:36.940674+00
a576a153-7a4c-48a4-b8d0-29402a594719	150669ed-4cf2-461e-b96e-28527ae36507	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-31 14:24:36.940674+00
5f8d8bad-5d68-40fc-a2f5-51c9552daee2	150669ed-4cf2-461e-b96e-28527ae36507	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-31 14:24:36.940674+00
1f1ce39a-b428-42c2-9f53-cefc10d14629	150669ed-4cf2-461e-b96e-28527ae36507	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-31 14:24:36.940674+00
e65d373e-67d5-4d6c-b789-d510a1aa6175	150669ed-4cf2-461e-b96e-28527ae36507	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-31 14:24:36.940674+00
f78e3192-9bf0-44db-82f9-dd14ce5abebd	150669ed-4cf2-461e-b96e-28527ae36507	other	test	\N	\N	\N	90	2026-07-31 14:24:36.940674+00
e73448c1-1d0a-4b9c-8c54-9a81958039bd	20916465-e099-43f4-8b12-27cd7fb5f085	account	test	\N	\N	\N	1	2026-07-31 14:29:28.712363+00
a9ef5a8c-02b9-4565-8f19-cacdff118900	20916465-e099-43f4-8b12-27cd7fb5f085	account	Création compte Entra ID	\N	\N	\N	20	2026-07-31 14:29:28.712363+00
0a662d74-a86d-4434-a7e2-26e765be563f	20916465-e099-43f4-8b12-27cd7fb5f085	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-31 14:29:28.712363+00
0cccfb97-2c33-41ab-8b79-57da31b2e14e	20916465-e099-43f4-8b12-27cd7fb5f085	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-31 14:29:28.712363+00
0740ff02-bdf4-4b7b-b41d-e8789a239033	20916465-e099-43f4-8b12-27cd7fb5f085	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-31 14:29:28.712363+00
fb544e53-4797-4f31-b2ea-a56b6f5d1d37	20916465-e099-43f4-8b12-27cd7fb5f085	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-31 14:29:28.712363+00
bdb08a66-2d56-41eb-b044-36a4cc381c8a	20916465-e099-43f4-8b12-27cd7fb5f085	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-31 14:29:28.712363+00
fc1b0c70-737a-4d62-beb1-c86bfb92e152	20916465-e099-43f4-8b12-27cd7fb5f085	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-31 14:29:28.712363+00
af00002c-435f-413f-a531-2f1b5b42012f	20916465-e099-43f4-8b12-27cd7fb5f085	other	test	\N	\N	\N	90	2026-07-31 14:29:28.712363+00
c3ae2420-c8c3-4011-bb9d-82457969288a	e8bc38ba-fc34-4789-92b7-a31ef0482b58	account	test	\N	\N	\N	1	2026-07-31 14:38:35.523272+00
e4c7bcb6-52dc-4903-b97a-ffe61c48a7fb	e8bc38ba-fc34-4789-92b7-a31ef0482b58	account	Création compte Entra ID	\N	\N	\N	20	2026-07-31 14:38:35.523272+00
8e6ab95a-94f9-4b25-9f59-869f19f9c93e	e8bc38ba-fc34-4789-92b7-a31ef0482b58	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-31 14:38:35.523272+00
f4399c5a-c55f-40e3-ac05-6ee8099aa32f	e8bc38ba-fc34-4789-92b7-a31ef0482b58	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-31 14:38:35.523272+00
810d8a25-630d-4052-96ed-e424f396cc99	e8bc38ba-fc34-4789-92b7-a31ef0482b58	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-31 14:38:35.523272+00
1d3d67ae-46ca-4dbd-8bd4-5b488c053b04	e8bc38ba-fc34-4789-92b7-a31ef0482b58	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-31 14:38:35.523272+00
d7b8c775-1fef-4bc5-aba3-236be5ef6832	e8bc38ba-fc34-4789-92b7-a31ef0482b58	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-31 14:38:35.523272+00
48dba67d-4d28-4810-98b2-8c7fac05cf6d	e8bc38ba-fc34-4789-92b7-a31ef0482b58	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-31 14:38:35.523272+00
5119073b-0313-465a-b725-2d8d2ac2222b	e8bc38ba-fc34-4789-92b7-a31ef0482b58	other	test	\N	\N	\N	90	2026-07-31 14:38:35.523272+00
af0e7d84-d350-4edb-9be6-1eea0537ef04	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	account	test	\N	\N	\N	1	2026-07-31 14:58:17.840371+00
bee9fa38-4edc-47e3-aef7-d45318110cb4	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	account	Création compte Entra ID	\N	\N	\N	20	2026-07-31 14:58:17.840371+00
7b3a4719-f161-4905-88a6-f11650f8f5bc	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-31 14:58:17.840371+00
5441c2b2-febf-4ab9-bb49-2688107ad697	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-31 14:58:17.840371+00
91a90565-8db9-464f-87fc-c48ecb4b644e	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-31 14:58:17.840371+00
e0d1e682-fbba-4355-8959-6f33b3b159d7	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-31 14:58:17.840371+00
aab71592-0464-446a-bd66-f775410acb0c	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-31 14:58:17.840371+00
ec2bec93-efcb-4a72-9a15-f0cc5c487641	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-31 14:58:17.840371+00
d96750f4-069d-468f-bffa-961c1a6bc3b2	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	other	test	\N	\N	\N	90	2026-07-31 14:58:17.840371+00
8a1b5d7e-98b2-48cd-ad45-6626986ed41a	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	account	test	\N	\N	\N	1	2026-07-31 15:22:58.006993+00
6c2af92d-3bd1-4b2b-af58-26e7525b8526	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	account	Création compte Entra ID	\N	\N	\N	20	2026-07-31 15:22:58.006993+00
c4ade18c-9055-4ddd-aa20-2688808bfa21	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	groups	Affecter les groupes Microsoft demandés	\N	\N	\N	30	2026-07-31 15:22:58.006993+00
12db36c5-c531-42d7-bfeb-8aa1c0d0ff02	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	license	Attribuer les licences demandées	\N	\N	\N	40	2026-07-31 15:22:58.006993+00
55db3186-c50f-4903-9434-243f72405712	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	hardware	Préparer et attribuer le matériel	\N	\N	\N	50	2026-07-31 15:22:58.006993+00
d073ac2f-27bc-4334-9869-34cce344825b	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	telephony	Créer le compte 3CX	\N	\N	\N	60	2026-07-31 15:22:58.006993+00
77ec79aa-9e94-4cf7-9717-483c9d27baaa	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	printing	Créer le compte PaperCut	\N	\N	\N	70	2026-07-31 15:22:58.006993+00
94a1e93f-6580-44bc-9711-3bae4f52d1ee	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	communication	Envoyer les identifiants au manager	\N	\N	\N	80	2026-07-31 15:22:58.006993+00
0da61f0f-449d-4a8d-b050-6f7270b68167	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	other	test	\N	\N	\N	90	2026-07-31 15:22:58.006993+00
\.


--
-- Data for Name: movement_items; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.movement_items (id, movement_id, category_id, hardware_item_id, status, notes, created_at) FROM stdin;
\.


--
-- Data for Name: movement_licenses; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.movement_licenses (id, movement_id, license_type_id, license_id, status, notes, created_at) FROM stdin;
e9c6c6de-5966-46e2-b258-58cca9bfef9a	0b6740ee-5ad0-4dbd-8c56-1137933137f6	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	requested	\N	2026-07-22 11:04:08.282709+00
739310b6-3df8-43bf-9be8-b3b9ad0d4803	0b6740ee-5ad0-4dbd-8c56-1137933137f6	5a94f564-3165-43e9-b435-257276cd0e0d	7d4d4252-5592-469d-8c26-a6cf5f4720b9	assigned	\N	2026-07-22 11:04:08.282709+00
14336cdd-71f8-4de8-b2e7-fbb4ff7ce700	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	requested	\N	2026-07-22 15:21:46.540959+00
661ebfca-f807-4c43-97f6-206234bbf056	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	5a94f564-3165-43e9-b435-257276cd0e0d	\N	requested	\N	2026-07-22 15:21:46.540959+00
b1d90408-afdc-43d2-89cb-6e314b551ac7	892fad26-a73f-4582-aa75-d616e44a3a2a	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-22 11:04:52.290399+00
2e6619fc-f68b-4dd2-a5ea-ea9f350659be	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-29 16:13:09.253461+00
b16383da-768b-474c-a819-99d5e3e6aac5	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	5a94f564-3165-43e9-b435-257276cd0e0d	\N	requested	\N	2026-07-29 16:13:09.253461+00
4e9fa3b2-6a2e-4c99-a3af-fd9f56cc369f	4b0c9fe6-96ed-4d89-801a-c17c673889f8	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-29 16:16:07.001416+00
b04a9007-ad2e-4103-98d6-5813ce20f518	4b0c9fe6-96ed-4d89-801a-c17c673889f8	5a94f564-3165-43e9-b435-257276cd0e0d	\N	requested	\N	2026-07-29 16:16:07.001416+00
f8f3b7d1-9597-4de5-a3aa-6fc8b05c4822	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-30 07:06:13.03858+00
3da11c64-428b-4517-843d-81839358337b	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	5a94f564-3165-43e9-b435-257276cd0e0d	\N	requested	\N	2026-07-30 07:06:13.03858+00
be4cb397-7be1-4418-8c46-d7f95d5b0682	d1839fd9-a603-4c8d-97c0-702d9fd5b040	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-30 10:15:04.046137+00
6e3407f6-e555-40cb-a23b-18f28ca1198b	d1839fd9-a603-4c8d-97c0-702d9fd5b040	5a94f564-3165-43e9-b435-257276cd0e0d	\N	requested	\N	2026-07-30 10:15:04.046137+00
4742134c-f5ce-434d-b43c-fcb80bb70ee7	a123f0f9-90a9-4e74-80f0-1155bbd64729	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-30 12:35:32.903509+00
e54fdfc8-2436-4a6a-9972-9e2ca57605cd	a123f0f9-90a9-4e74-80f0-1155bbd64729	5a94f564-3165-43e9-b435-257276cd0e0d	\N	requested	\N	2026-07-30 12:35:32.903509+00
51553424-473e-4ae9-8c6d-8e30ecbb0d9c	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-30 12:43:32.668054+00
9f16756b-55ae-490f-88a6-8fea3313042c	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-30 14:42:01.254566+00
d4eeb853-bbe0-45fa-b0b3-46b40c93a8b8	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-30 15:59:44.257566+00
89bde1e0-325f-4769-85a5-4c1fa59dde0b	6c72dd2c-f583-42fd-9865-35a78dd1b478	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-31 14:01:15.675655+00
e4ea9432-935c-4a4d-8374-ba349b5fd3d8	499e9466-0f33-444e-9576-0b9114f8c115	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-31 14:16:26.467844+00
1597870a-40a9-4484-bdc1-07e5350a7e85	150669ed-4cf2-461e-b96e-28527ae36507	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-31 14:24:36.940674+00
7981abcd-31c7-4c8c-9ec5-888223bafe7a	20916465-e099-43f4-8b12-27cd7fb5f085	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-31 14:29:28.712363+00
ccab614d-b162-44a8-900e-1ca8acc6a31e	e8bc38ba-fc34-4789-92b7-a31ef0482b58	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-31 14:38:35.523272+00
cddf2530-63b7-48b2-8539-b9c4698d9236	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-31 14:58:17.840371+00
5be26454-cc2e-4b5c-addc-2b2b954c537b	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	ea9154b1-8145-4f3b-bd6b-31d0392dc6d1	\N	assigned	\N	2026-07-31 15:22:58.006993+00
\.


--
-- Data for Name: movement_service_groups; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.movement_service_groups (id, movement_id, group_id, group_name, group_mail, created_at) FROM stdin;
16a7dde9-41cc-4e45-bd0a-3faad77c1236	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	4d25f374-a4e9-40e2-8cde-d407b75eec9f	🏢 Pole Gestionnaires Insitu	pole_gestionnaires_insitu@elyade.com	2026-07-22 15:21:46.540959+00
be3ee4c9-2a5e-4ee4-9148-25a7103ce238	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	7f784b73-7e79-4d63-949d-85b2978349d1	🏢 Pole Neuf	pole_neuf@elyade.com	2026-07-29 16:13:09.253461+00
f5f385d6-7298-4461-9271-77472f4e324e	4b0c9fe6-96ed-4d89-801a-c17c673889f8	b913fa89-7bd0-4643-bf50-4ee59c458ad8	🏢 Pole Relations Promoteurs	pole_relations_promoteurs@elyade.com	2026-07-29 16:16:07.001416+00
a53c193a-e3fc-45d9-b0a6-c30f203b223d	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	35205c28-7968-4f59-beb1-eee96691c003	🏢 Pole Sinistre	sinistre@elyade.com	2026-07-30 07:06:13.03858+00
fdf0eef2-e987-425c-b06f-30559e7b1700	d1839fd9-a603-4c8d-97c0-702d9fd5b040	48c11426-857b-41ef-94f5-9494265ac9c9	🏢 Pole Gestion	pole_gestion@elyade.com	2026-07-30 10:15:04.046137+00
0388eb0d-9760-49b5-bfd3-37886ea0ef3c	a123f0f9-90a9-4e74-80f0-1155bbd64729	7f784b73-7e79-4d63-949d-85b2978349d1	🏢 Pole Neuf	pole_neuf@elyade.com	2026-07-30 12:35:32.903509+00
b96a659e-9ba9-48d5-93d4-a1af5e42783a	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	78a00eb7-3ea3-4102-a6d4-fe8750935824	🏢 Pole Relations Fournisseurs	pole_relations_fournisseurs@elyade.com	2026-07-30 12:43:32.668054+00
8441013c-7d52-4a0c-8d6a-52f2c2a8e0d7	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	00eebbea-7a72-4a53-875d-726c84bc213d	🏢 Pole Qualite	pole_qualite@elyade.com	2026-07-30 14:42:01.254566+00
b53c1471-430a-41fb-8fd9-29064577825b	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	7f784b73-7e79-4d63-949d-85b2978349d1	🏢 Pole Neuf	pole_neuf@elyade.com	2026-07-30 15:59:44.257566+00
f5c99e17-30f4-408a-8d76-c0dcb13e1344	6c72dd2c-f583-42fd-9865-35a78dd1b478	48c11426-857b-41ef-94f5-9494265ac9c9	🏢 Pole Gestion	pole_gestion@elyade.com	2026-07-31 14:01:15.675655+00
79c71bd7-371d-4bee-b7b0-463ea1b07e0d	499e9466-0f33-444e-9576-0b9114f8c115	a2448f7c-78fc-4afd-87e8-52ae0f5a76b6	🏢 Pole Développement CGP	pole_developpement_cgp@elyade.com	2026-07-31 14:16:26.467844+00
cb8b5466-60c8-4d48-8d48-cd7116035899	150669ed-4cf2-461e-b96e-28527ae36507	4d25f374-a4e9-40e2-8cde-d407b75eec9f	🏢 Pole Gestionnaires Insitu	pole_gestionnaires_insitu@elyade.com	2026-07-31 14:24:36.940674+00
05142ee7-e007-4732-afe7-70554e5f44e8	20916465-e099-43f4-8b12-27cd7fb5f085	b913fa89-7bd0-4643-bf50-4ee59c458ad8	🏢 Pole Relations Promoteurs	pole_relations_promoteurs@elyade.com	2026-07-31 14:29:28.712363+00
12cb218b-c9a5-4702-99ec-46a3d33d22ab	e8bc38ba-fc34-4789-92b7-a31ef0482b58	00eebbea-7a72-4a53-875d-726c84bc213d	🏢 Pole Qualite	pole_qualite@elyade.com	2026-07-31 14:38:35.523272+00
998deb4a-6d15-4696-9566-90731b6e9f1b	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	aa41d964-783f-483b-ac5b-64c1d660314e	🏢 Pole Phoning Location	pole_phoning_location@elyade.com	2026-07-31 14:58:17.840371+00
687aab18-3b43-4fae-80dc-e8242cc35e2b	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	35205c28-7968-4f59-beb1-eee96691c003	🏢 Pole Sinistre	sinistre@elyade.com	2026-07-31 15:22:58.006993+00
\.


--
-- Data for Name: movements; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.movements (id, type, employee_id, service_id, contract_type_id, contract_end_date, effective_date, source, manager_name, job_title, notes, status, calendar_event_ids, created_at, updated_at, manager_email, microsoft_service_group_id, microsoft_service_group_name, microsoft_service_group_mail) FROM stdin;
aff6ae75-6da1-4c9c-8a6c-2d7384100259	offboarding	b057d075-1301-4c23-9f35-6909da0a4e82	\N	\N	\N	2026-06-21	lucca_email	\N	TolveMarie@elyade.com	Créé automatiquement depuis le mail LUCCA : TR: 1 tâche à réaliser pour l'offboarding de TOLVE Marie	done	\N	2026-07-28 15:22:05.294855+00	2026-07-28 15:47:08.994735+00	\N	\N	\N	\N
0b6740ee-5ad0-4dbd-8c56-1137933137f6	onboarding	1e4c6d30-2665-479f-a16b-803bf285a11f	\N	\N	\N	2026-07-24	manager_form	Thomas DIDRICHE	dff	Demande créée depuis le formulaire manager.	done	\N	2026-07-22 11:04:08.282709+00	2026-07-28 15:47:17.82111+00	tdidriche@elyade.com	7f784b73-7e79-4d63-949d-85b2978349d1	🏢 Pole Neuf	pole_neuf@elyade.com
e8bc38ba-fc34-4789-92b7-a31ef0482b58	onboarding	c7c5fec0-367f-41d1-a08a-5a293558072e	\N	\N	\N	2026-07-31	manager_form	Thomas DIDRICHE	Pilote	Demande créée depuis le formulaire manager.	non_embauche	\N	2026-07-31 14:38:35.523272+00	2026-07-31 14:38:35.523272+00	tdidriche@elyade.com	\N	\N	\N
f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	onboarding	62d06322-8057-4756-9750-fb595d22f5e8	\N	\N	\N	2026-08-18	manager_form	Thomas DIDRICHE	test	Demande créée depuis le formulaire manager.	envoye	\N	2026-07-29 16:13:09.253461+00	2026-08-26 14:29:59.320741+00	tdidriche@elyade.com	\N	\N	\N
4b0c9fe6-96ed-4d89-801a-c17c673889f8	onboarding	62d06322-8057-4756-9750-fb595d22f5e8	\N	\N	\N	2026-08-18	manager_form	Thomas DIDRICHE	kjghkljh	Demande créée depuis le formulaire manager.	envoye	\N	2026-07-29 16:16:07.001416+00	2026-08-26 14:32:35.706987+00	tdidriche@elyade.com	\N	\N	\N
a2fbdce4-c944-48bc-8a8f-f763a9199ae8	onboarding	ab288e7b-6393-4315-8b09-26410514fb7a	\N	\N	\N	2026-12-01	manager_form	Thomas DIDRICHE	Sandwicheur	Demande créée depuis le formulaire manager.	envoye	\N	2026-07-30 15:59:44.257566+00	2026-07-30 15:59:44.257566+00	tdidriche@elyade.com	\N	\N	\N
892fad26-a73f-4582-aa75-d616e44a3a2a	onboarding	62d06322-8057-4756-9750-fb595d22f5e8	\N	\N	\N	2026-07-31	manager_form	Thomas DIDRICHE	qvsb d	Demande créée depuis le formulaire manager.	envoye	\N	2026-07-22 11:04:52.290399+00	2026-07-29 14:12:52.506684+00	tdidriche@elyade.com	b913fa89-7bd0-4643-bf50-4ee59c458ad8	🏢 Pole Relations Promoteurs	pole_relations_promoteurs@elyade.com
aa8a22e0-06f5-46c7-8ff0-536e0434bde3	onboarding	a760e3d2-88e4-4884-8d19-1889a862c1c4	\N	\N	\N	2026-08-08	manager_form	Thomas DIDRICHE	svgfs<vgf	Demande créée depuis le formulaire manager.\n\nBoîtes partagées demandées :\ndFQFQFQFQFQFQFQFQFQF	envoye	\N	2026-07-30 07:06:13.03858+00	2026-07-30 07:06:13.03858+00	tdidriche@elyade.com	\N	\N	\N
d1839fd9-a603-4c8d-97c0-702d9fd5b040	onboarding	bcb23b56-60f9-4e6e-8b5d-ca2b7acf3378	\N	\N	\N	2026-08-06	manager_form	Thomas DIDRICHE	test	Demande créée depuis le formulaire manager.\n\nBoîtes partagées demandées :\ntest	envoye	\N	2026-07-30 10:15:04.046137+00	2026-07-30 10:15:04.046137+00	tdidriche@elyade.com	\N	\N	\N
a123f0f9-90a9-4e74-80f0-1155bbd64729	onboarding	2f1fd062-8860-4869-aeda-8f671935c0ea	\N	\N	\N	2026-07-31	manager_form	Thomas DIDRICHE	à peut près	Demande créée depuis le formulaire manager.\n\nBoîtes partagées demandées :\ntest	envoye	\N	2026-07-30 12:35:32.903509+00	2026-07-30 12:35:32.903509+00	tdidriche@elyade.com	\N	\N	\N
0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	onboarding	3a434a21-51f1-4086-803e-1a3bb61a8558	\N	\N	\N	2026-07-30	manager_form	Thomas DIDRICHE	lkhmlhkmlhmlhlmhmlh	Demande créée depuis le formulaire manager.\n\nBoîtes partagées demandées :\naef	envoye	\N	2026-07-30 12:43:32.668054+00	2026-07-30 12:43:32.668054+00	tdidriche@elyade.com	\N	\N	\N
3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	onboarding	62d06322-8057-4756-9750-fb595d22f5e8	\N	\N	\N	2026-07-24	manager_form	Thomas DIDRICHE	qestry	Demande créée depuis le formulaire manager.	envoye	\N	2026-07-22 15:21:46.540959+00	2026-07-29 14:31:33.493372+00	tdidriche@elyade.com	\N	\N	\N
80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	onboarding	90e0b1f7-bd5c-422a-9ff2-a2f6776be765	\N	\N	\N	2026-08-07	manager_form	Thomas DIDRICHE	\N	Demande créée depuis le formulaire manager.	envoye	\N	2026-07-31 15:22:58.006993+00	2026-07-31 15:22:58.006993+00	tdidriche@elyade.com	\N	\N	\N
6eab0a46-4b49-481c-99ab-54dd2f812916	offboarding	45fca3e8-eda9-4639-bce2-7ee307d0609f	\N	\N	\N	2026-08-31	lucca_email	\N	mrodriguez@elyade.com	Créé automatiquement depuis le mail LUCCA : TR : 1 tâche à réaliser pour l'offboarding de RODRIGUEZ Manon	pending	\N	2026-08-07 07:13:13.780456+00	2026-08-07 07:13:13.780456+00	\N	\N	\N	\N
ad6b15ab-b14b-4b36-b3bf-513d5a6b265e	offboarding	7ac248ca-bb6a-46db-b293-98122e9ad5b6	\N	\N	\N	2026-08-07	lucca_email	\N	lchaubet@elyade.com	Créé automatiquement depuis le mail LUCCA : OffBoarding CHAUBET Ludovic - Pole développement CGP	pending	\N	2026-08-07 13:17:22.506859+00	2026-08-07 13:17:22.506859+00	\N	\N	\N	\N
cceaf7ef-e141-4967-a5ed-21aba1a5f39e	onboarding	3d7eb1dc-873f-45d1-a26f-51e7d1f0e7a1	\N	\N	\N	2026-10-01	manager_form	Thomas DIDRICHE	Mangeur de danette chocolat	Demande créée depuis le formulaire manager.	non_embauche	\N	2026-07-30 14:42:01.254566+00	2026-07-30 14:42:01.254566+00	tdidriche@elyade.com	\N	\N	\N
6c72dd2c-f583-42fd-9865-35a78dd1b478	onboarding	70a0cc86-c612-486c-a100-74001a9ff631	\N	\N	\N	2026-11-01	manager_form	Thomas DIDRICHE	Chauffeur	Demande créée depuis le formulaire manager.	non_embauche	\N	2026-07-31 14:01:15.675655+00	2026-07-31 14:01:15.675655+00	tdidriche@elyade.com	\N	\N	\N
499e9466-0f33-444e-9576-0b9114f8c115	onboarding	e3258fea-12a4-477e-aec1-afb092a94e9d	\N	\N	\N	2026-08-08	manager_form	Thomas DIDRICHE	\N	Demande créée depuis le formulaire manager.	non_embauche	\N	2026-07-31 14:16:26.467844+00	2026-07-31 14:16:26.467844+00	tdidriche@elyade.com	\N	\N	\N
150669ed-4cf2-461e-b96e-28527ae36507	onboarding	18a1512b-eab8-4594-99fb-9b254688c6c6	\N	\N	\N	2026-08-01	manager_form	Thomas DIDRICHE	\N	Demande créée depuis le formulaire manager.	non_embauche	\N	2026-07-31 14:24:36.940674+00	2026-07-31 14:24:36.940674+00	tdidriche@elyade.com	\N	\N	\N
20916465-e099-43f4-8b12-27cd7fb5f085	onboarding	543e1412-60f4-4182-bac8-1aaab1417197	\N	\N	\N	2026-07-31	manager_form	Thomas DIDRICHE	Chauffeur	Demande créée depuis le formulaire manager.	non_embauche	\N	2026-07-31 14:29:28.712363+00	2026-07-31 14:29:28.712363+00	tdidriche@elyade.com	\N	\N	\N
3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	onboarding	62d06322-8057-4756-9750-fb595d22f5e8	\N	\N	\N	2027-01-01	manager_form	Thomas DIDRICHE	Enqueteur	Demande créée depuis le formulaire manager.	in_progress	\N	2026-07-31 14:58:17.840371+00	2026-08-26 14:19:00.304345+00	tdidriche@elyade.com	\N	\N	\N
\.


--
-- Data for Name: onboarding_action_templates; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.onboarding_action_templates (id, action_type, label, sort_order, is_active, created_at, updated_at) FROM stdin;
61668a1e-dcbf-4c39-95e1-6e8cc5cc1590	license	Attribuer les licences demandées	40	t	2026-07-22 13:11:19.465868+00	2026-07-22 15:11:19.020012+00
41d8906b-877c-402d-8df8-3da3ae8f7645	hardware	Préparer et attribuer le matériel	50	t	2026-07-22 13:11:19.465868+00	2026-07-22 15:11:19.020012+00
2d7a0385-9574-487e-b174-9acfd354a1fa	telephony	Créer le compte 3CX	60	t	2026-07-22 13:11:19.465868+00	2026-07-22 15:11:19.020012+00
1a7cf510-d748-48c8-9613-888c286e6214	printing	Créer le compte PaperCut	70	t	2026-07-22 13:11:19.465868+00	2026-07-22 15:11:19.020012+00
2353423c-2541-41e1-bc89-3bec292badf1	communication	Envoyer les identifiants au manager	80	t	2026-07-22 13:11:19.465868+00	2026-07-22 15:11:19.020012+00
afb2ea4d-f1ea-438f-bfb3-a6fffc280ce0	other	test	90	t	2026-07-22 15:43:28.351232+00	2026-07-22 15:43:28.351232+00
c5704b56-c58d-4df7-8e98-09813fd6ca60	groups	Affecter les groupes Microsoft demandés	30	t	2026-07-22 13:11:19.465868+00	2026-07-22 15:47:24.34051+00
e87a65a4-c0a7-4c69-a422-0a5c272e85a4	account	Création compte Entra ID	20	t	2026-07-22 13:11:19.465868+00	2026-07-22 15:47:24.384407+00
e74f2d93-5aaf-4dc1-bf4b-fc3aa85be11a	account	test	1	t	2026-07-22 15:52:50.951376+00	2026-07-22 15:52:50.951376+00
\.


--
-- Data for Name: onboarding_details; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.onboarding_details (id, movement_id, contract_type, employee_status, employee_level, gross_annual_salary, variable_bonus, contract_reason, school, internship_mission, referral, referral_employee, cv_file_name, cv_file_path, created_at, company_car, pdf_file_path) FROM stdin;
86c149a4-d773-4e08-96ee-48c7ec0428c8	d1839fd9-a603-4c8d-97c0-702d9fd5b040	CDI	Employé	E2	222222	\N	\N	\N	\N	f	\N	\N	\N	2026-07-30 10:15:04.046137+00	f	\N
944456b7-1190-45d7-81b7-2664a5b389fc	a123f0f9-90a9-4e74-80f0-1155bbd64729	CDI	Employé	E2	200000	\N	\N	\N	\N	t	a5a6872a-ebe1-4401-9e04-036f29764adf	Amazon.fr Panier.pdf	public/uploads/cv/1785414932879-689024285-Amazon.fr Panier.pdf	2026-07-30 12:35:32.903509+00	f	\N
32f8e438-1721-4851-862c-cad86fb1f408	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	CDI	Employé	E1	56465465	\N	\N	\N	\N	t	a5a6872a-ebe1-4401-9e04-036f29764adf	Amazon.fr Panier 1.pdf	public/uploads/cv/1785415412646-677024998-Amazon.fr Panier 1.pdf	2026-07-30 12:43:32.668054+00	f	\N
07b5db23-4481-4916-83e6-38817a750190	cceaf7ef-e141-4967-a5ed-21aba1a5f39e	CDI	Agent de maîtrise	AM2	12354	102587	\N	\N	\N	t	62d06322-8057-4756-9750-fb595d22f5e8	Amazon.fr Panier 1.pdf	public/uploads/cv/1785422521231-944955235-Amazon.fr Panier 1.pdf	2026-07-30 14:42:01.254566+00	f	\N
c71c6554-3ff8-4c46-90e0-de0a71d51852	a2fbdce4-c944-48bc-8a8f-f763a9199ae8	CDI	Cadre	C3	123456789	456789	\N	\N	\N	t	9c8b043d-a01c-4089-af23-294d15b8b655	\N	\N	2026-07-30 15:59:44.257566+00	f	\N
58efb479-2109-4079-94fe-4a275b122e18	6c72dd2c-f583-42fd-9865-35a78dd1b478	CDI	Employé	E2	123456	21	\N	\N	\N	f	\N	\N	\N	2026-07-31 14:01:15.675655+00	t	\N
1f72f7a5-e007-400d-bedc-9d584ef576fd	499e9466-0f33-444e-9576-0b9114f8c115	CDI	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	2026-07-31 14:16:26.467844+00	t	\N
99e195dd-892a-4592-880f-403e762a2c70	150669ed-4cf2-461e-b96e-28527ae36507	CDI	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	2026-07-31 14:24:36.940674+00	t	\N
f922e647-a6fe-42e9-a1d0-5e6bafe9a6ca	20916465-e099-43f4-8b12-27cd7fb5f085	CDI	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	2026-07-31 14:29:28.712363+00	t	\N
5ca79666-ffb8-448d-8f4e-0d266692a777	e8bc38ba-fc34-4789-92b7-a31ef0482b58	CDI	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	2026-07-31 14:38:35.523272+00	t	\N
f0dc7404-d16d-4922-9433-f477e31fae0d	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	CDI	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	2026-07-31 14:58:17.840371+00	f	/app/storage/onboarding/Onboarding_1785509897864.pdf
b903f242-b74d-424f-91ef-b23b0bae28c3	80a8c5bf-3ab4-4e94-8605-e4c2af7e1138	CDI	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	2026-07-31 15:22:58.006993+00	f	/app/storage/onboarding/Onboarding_1785511378022.pdf
\.


--
-- Data for Name: processed_offboarding_emails; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.processed_offboarding_emails (message_id, processed_at) FROM stdin;
AAMkADAyOTZmZjhkLTJjOGUtNDgwMC04ZjgzLTgwOTA5NWViYzU5YgBGAAAAAAC7j_5mEPBNT4Ndlsx0P2J9BwCNSWkWVt6KR6D6EJcyD1fMAAAAAAEMAACNSWkWVt6KR6D6EJcyD1fMAAKGrVhdAAA=	2026-07-28 14:46:40.056697+00
AAMkADAyOTZmZjhkLTJjOGUtNDgwMC04ZjgzLTgwOTA5NWViYzU5YgBGAAAAAAC7j_5mEPBNT4Ndlsx0P2J9BwCNSWkWVt6KR6D6EJcyD1fMAAAAAAEMAACNSWkWVt6KR6D6EJcyD1fMAAKGrVheAAA=	2026-07-28 14:51:39.930234+00
AAMkADAyOTZmZjhkLTJjOGUtNDgwMC04ZjgzLTgwOTA5NWViYzU5YgBGAAAAAAC7j_5mEPBNT4Ndlsx0P2J9BwCNSWkWVt6KR6D6EJcyD1fMAAAAAAEMAACNSWkWVt6KR6D6EJcyD1fMAAKGrVhfAAA=	2026-07-28 15:07:49.959855+00
AAMkADAyOTZmZjhkLTJjOGUtNDgwMC04ZjgzLTgwOTA5NWViYzU5YgBGAAAAAAC7j_5mEPBNT4Ndlsx0P2J9BwCNSWkWVt6KR6D6EJcyD1fMAAAAAAEMAACNSWkWVt6KR6D6EJcyD1fMAAKGrVhgAAA=	2026-07-28 15:14:00.880447+00
AAMkADAyOTZmZjhkLTJjOGUtNDgwMC04ZjgzLTgwOTA5NWViYzU5YgBGAAAAAAC7j_5mEPBNT4Ndlsx0P2J9BwCNSWkWVt6KR6D6EJcyD1fMAAAAAAEMAACNSWkWVt6KR6D6EJcyD1fMAAKGrVhhAAA=	2026-07-28 15:22:05.294855+00
AAMkADAyOTZmZjhkLTJjOGUtNDgwMC04ZjgzLTgwOTA5NWViYzU5YgBGAAAAAAC7j_5mEPBNT4Ndlsx0P2J9BwCNSWkWVt6KR6D6EJcyD1fMAAAAAAEMAACNSWkWVt6KR6D6EJcyD1fMAAKNQeHyAAA=	2026-08-07 07:13:13.780456+00
AAMkADAyOTZmZjhkLTJjOGUtNDgwMC04ZjgzLTgwOTA5NWViYzU5YgBGAAAAAAC7j_5mEPBNT4Ndlsx0P2J9BwCNSWkWVt6KR6D6EJcyD1fMAAAAAAEMAACNSWkWVt6KR6D6EJcyD1fMAAKNQeH1AAA=	2026-08-07 13:17:22.506859+00
\.


--
-- Data for Name: service_peripherals; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.service_peripherals (id, service_id, category_id, quantity, created_at) FROM stdin;
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.services (id, name, created_at) FROM stdin;
92ce48b1-34ac-4c92-9964-6b66118e3bbe	Direction	2026-07-20 12:33:12.255758+00
bf6fbcee-d4b6-41c4-8ed9-e58664417c36	Comptabilité	2026-07-20 12:33:12.255758+00
0eb92292-6457-474e-838a-f3e1ca2e6b55	Ressources Humaines	2026-07-20 12:33:12.255758+00
3efa982c-c60f-4142-a503-ef9687685735	Commercial	2026-07-20 12:33:12.255758+00
dbe5fe2b-4d11-4fa5-b9c4-bdb1f467a70f	Gestion Locative	2026-07-20 12:33:12.255758+00
bf57aaf8-da1c-4b70-b533-37b3e3cf0d87	Syndic	2026-07-20 12:33:12.255758+00
63e879be-8f7f-45a1-812d-47cac2a71dda	Transaction	2026-07-20 12:33:12.255758+00
cdb2780a-1434-4cce-a165-798ca311338a	Neuf	2026-07-20 12:33:12.255758+00
f73a88b5-f436-487a-9dac-55bd1abd9f2f	Informatique	2026-07-20 12:33:12.255758+00
\.


--
-- Data for Name: signed_documents; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.signed_documents (id, movement_id, doc_type, signer_name, signer_email, signed_at, status, content_snapshot, created_at, signature_data, pdf_path, pdf_generated_at, email_sent_at, email_error) FROM stdin;
bc33ecb3-9de7-4b00-bb2e-786fdade2fd3	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	assignment	thomas DIDRICHE	tdidriche@elyade.com	2026-07-28 09:34:55.98+00	signed	{"items": [{"serial": "qsfqsefqsefqsefseqfsfssefff", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf"}], "employee": "Thomas DIDRICHE", "licenses": [], "movement_type": "onboarding", "effective_date": "2026-07-24T00:00:00.000Z"}	2026-07-28 09:34:56.902166+00	data:image/png;base64,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wCySvtoWAREQARFYPAFZsJIEJGBW8rLJaBEQAREQARHYbAISMJt9/dV7ERCBxROQBSIgAlMQkICZApqKiIAIiIAIiIAILJaABMxi+at1EVg8AVkgAiIgAitIQAJmBS+aTBYBERABERCBTScgAbPpn4DF918WiIAIiIAIiMDEBCRgJkamAiIgAiIgAiIgAosmIAGz6Cug9kVABERABERABCYmIAEzMTIVEAEREAEREAERWDQBCZhFXwG1LwIiIAIiIAIiMDEBCZiJkamACIiACIjA4gnIgk0nIAGz6Z8A9V8EREAEREAEVpCABMwKXjSZLAIisHgCskAERGCxBCRgFstfrYuACIiACIiACExBQAJmCmgqIgKLJyALREAERGCzCUjAbPb1V+9FQAREQAREYCUJSMCs5GVbvNGyQAREQAREQAQWSUACZpH01bYIiIAIiIAIiMBUBFZUwEzVVxUSAREQAREQARFYEwISMGtyIdUNERABERABEbiUwBqdIAGzRhdTXREBERABERCBTSEgAbMpV1r9FAEREIHFE5AFIjAzAhIwM0OpikRABERABERABK6LgATMdZFWOyIgAosnIAtEQATWhoAEzNpcSnVEBERABERABDaHgATM5lxr9XTxBGSBCIiACIjAjAhIwMwIpKoRAREQAREQARG4PgISMNfHevEtyQIREAEREAERWBMCEjBrciHVDREQAREQARHYJALXKWA2iav6KgIiIAIiIAIiMEcCEjBzhKuqRUAEREAERODqBFTDKAISMKOoaJ8IiIAIiIAIiMBSE5CAWerLI+NEQAREYPEEZIEILCMBCZhlvCqySQREQAREQARE4EICEjAX4tFBERCBxROQBSIgAiJwloAEzFkm2iMCIiACIiACIrDkBCRglvwCybzFE5AFIiACIiACy0dAAmb5roksEgEREAEREAERuISABMwlgBZ/WBaIgAiIgAiIgAgME5CAGSaibREQAREQAREQgaUncKmAWfoeyEAREAEREAEREIGNI/D/AQAA///41LTnAAAABklEQVQDAJjulTEwAiHqAAAAAElFTkSuQmCC	storage/documents/Attribution_Thomas_DIDRICHE_20260728_bc33ecb3.pdf	2026-07-28 11:58:59.666914+00	\N	\N
fa6239ac-bd33-43e1-a249-85ea4dbc01da	892fad26-a73f-4582-aa75-d616e44a3a2a	assignment	didriche	tdidriche@elyade.com	2026-07-28 12:00:24.806+00	signed	{"items": [{"serial": null, "category": "PC portable", "reference": "TEST-MIGRATION-001"}], "employee": "NOVARESE ", "licenses": [], "movement_type": "onboarding", "effective_date": "2026-07-31T00:00:00.000Z"}	2026-07-28 12:00:25.421322+00	data:image/png;base64,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/Zk51Mt34s7P7SQdxRUBESgmAQmYYtarSiUCuSAwi9qBQSMoDI+qOFHORSGUSREQgZEQkIAZCXYluj8EdFYREAEREIFJISABMyk1rXKKgAiIgAiIQIEISMDsYWXqVCIgAiIgAiIgAsMhIAEzHM5KRQREQAREQAREYDCBXYVKwOwKmw4SAREQAREQAREYJQEJmFHSV9oiIAIiIAKjJ6Ac5JKABEwuq02ZFgEREAEREIHJJiABM9n1r9KLgAiMnoByIAIisAsCEjC7gKZDREAEREAEREAERktAAma0/JW6CIyegHIgAiIgAjkkIAGTw0pTlkVABERABERg0glIwEz6FTD68isHIiACIiACIrBjAhIwO0amA0RABERABERABEZNQAJm1DWg9EVABERABERABHZMQAJmx8h0gAiIgAiIgAiIwKgJSMCMugaUvgiIgAiIgAiIwI4JSMDsGJkOEAEREAERGD0B5WDSCUjATPoVoPKLgAiIgAiIQA4JSMDksNKUZREQgdETUA5EQARGS0ACZrT8lboIiIAIiIAIiMAuCEjA7AKaDhGB0RNQDkRABERgsglIwEx2/av0IiACIiACIpBLAhIwuay20WdaORABERABERCBURKQgBklfaUtAiIgAiIgAiKwKwI5FTC7KqsOEgEREAEREAERKAgBCZiCVKSKIQIiIAIiIAJbEihQBAmYAlWmiiICIiACIiACk0JAAmZSalrlFAEREIHRE1AORGDPCEjA7BlKnUgEREAEREAERGBYBCRghkVa6YiACIyegHIgAiJQGAISMIWpShVEBERABERABCaHgATM5NS1Sjp6AsqBCIiACIjAHhGQgNkjkDqNCIiACIiACIjA8AhIwAyP9ehTUg5EQAREQAREoCAEJGAKUpEqhgiIgAiIgAhMEoFhCphJ4qqyioAIiIAIiIAI7CMBCZh9hKtTi4AIiIAIiMC1E9AZBhGQgBlERWEiIAIiIAIiIAJjTUACZqyrR5kTAREQgdETUA5EYBwJSMCMY60oTyIgAiIgAiIgAlclIAFzVTzaKQIiMHoCyoEIiIAIbCQgAbORiUJEQAREQAREQATGnIAEzJhXkLI3egLKgQiIgAiIwPgRkIAZvzpRjkRABERABERABLYgIAGzBaDR71YOREAEREAEREAEriQgAXMlEW2LgAiIgAiIgAiMPYEtBczYl0AZFAEREAEREAERmDgCfwUAAP//kmdcEQAAAAZJREFUAwA5jN5AugmXoAAAAABJRU5ErkJggg==	storage/documents/Attribution_NOVARESE_20260728_fa6239ac.pdf	2026-07-28 12:00:25.504505+00	\N	Erreur envoi mail Microsoft Graph : {"error":{"code":"ErrorAccessDenied","message":"Access is denied. Check credentials and try again."}}
a6007dea-0c40-46da-bbfd-ffc2580feee3	892fad26-a73f-4582-aa75-d616e44a3a2a	assignment	didriche	tdidriche@elyade.com	2026-07-28 12:03:48.647+00	signed	{"items": [{"serial": null, "category": "PC portable", "reference": "TEST-MIGRATION-001"}], "employee": "NOVARESE ", "licenses": [], "movement_type": "onboarding", "effective_date": "2026-07-31T00:00:00.000Z"}	2026-07-28 12:03:49.474561+00	data:image/png;base64,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	storage/documents/Attribution_NOVARESE_20260728_a6007dea.pdf	2026-07-28 12:03:49.547886+00	2026-07-28 12:03:50.138889+00	\N
031a3418-b2a6-4564-9792-6e97a31b6e03	\N	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-07-29 13:41:25.830545+00	signed	{"items": [{"brand": "HP", "model": null, "title": "tetst", "serial": null, "status": "assigned", "category": "PC portable", "reference": null, "assigned_at": "2026-07-29T13:41:25.830Z", "serial_number": null}], "title": "Mise à jour de la fiche d’affectation matériel", "reason": "Réaffectation de matériel depuis l’inventaire", "employee": "Thomas DIDRICHE", "licenses": [], "generated_at": "2026-07-29T13:41:25.866Z", "document_type": "hardware_reassignment", "movement_type": "onboarding", "reassignments": [{"old_status": "in_stock", "new_hardware_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e", "old_hardware_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a"}], "effective_date": null, "employee_email": "tdidriche@elyade.com"}	2026-07-29 13:41:25.830545+00	\N	storage/documents/Attribution_Thomas_DIDRICHE_20260729_031a3418.pdf	2026-07-29 13:41:25.99698+00	2026-07-29 13:41:26.396355+00	\N
7661e3c1-ed46-4441-beb3-599db1e8ab71	892fad26-a73f-4582-aa75-d616e44a3a2a	assignment	didriche	tdidriche@elyade.com	2026-07-28 12:06:03.204+00	signed	{"items": [{"serial": null, "category": "PC portable", "reference": "TEST-MIGRATION-001"}], "employee": "NOVARESE ", "licenses": [], "movement_type": "onboarding", "effective_date": "2026-07-31T00:00:00.000Z"}	2026-07-28 12:06:04.051356+00	data:image/png;base64,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	storage/documents/Attribution_NOVARESE_20260728_7661e3c1.pdf	2026-07-28 12:06:04.159041+00	2026-07-28 12:06:04.557964+00	\N
c0b47729-eed0-4fc3-8ba0-6622021312ee	\N	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-07-29 13:34:32.257046+00	signed	{"title": "Mise à jour de la fiche d’affectation matériel", "reason": "Réaffectation de matériel depuis l’inventaire", "employee": "Thomas DIDRICHE", "generated_at": "2026-07-29T13:34:32.295Z", "document_type": "hardware_reassignment", "employee_email": "tdidriche@elyade.com", "changed_hardware_ids": ["04d2e68c-364b-45c3-bb11-9449dbc7571a"], "current_assigned_hardware": [{"brand": null, "model": null, "title": null, "status": "assigned", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf", "assigned_at": "2026-07-29T13:34:32.257Z", "serial_number": "qsfqsefqsefqsefseqfsfssefff"}]}	2026-07-29 13:34:32.257046+00	\N	storage/documents/Attribution_Thomas_DIDRICHE_20260729_c0b47729.pdf	2026-07-29 13:34:32.420615+00	2026-07-29 13:34:32.931166+00	\N
439b8709-adce-40b8-8a1e-05b2e6bcac49	\N	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-07-29 14:05:42.726394+00	signed	{"items": [{"brand": null, "model": null, "title": null, "serial": "qsfqsefqsefqsefseqfsfssefff", "status": "assigned", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf", "assigned_at": "2026-07-29T14:05:42.726Z", "serial_number": "qsfqsefqsefqsefseqfsfssefff"}], "title": "Mise à jour de la fiche d’affectation matériel", "reason": "Réaffectation de matériel depuis l’inventaire", "employee": "Thomas DIDRICHE", "licenses": [], "generated_at": "2026-07-29T14:05:42.757Z", "document_type": "hardware_reassignment", "movement_type": "onboarding", "reassignments": [{"old_status": "in_stock", "new_hardware_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a", "old_hardware_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e"}], "effective_date": null, "employee_email": "tdidriche@elyade.com"}	2026-07-29 14:05:42.726394+00	\N	\N	\N	\N	doc is not defined
20f540cd-b28b-4749-bff7-3c5ff71746b0	\N	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-07-29 14:12:35.337794+00	signed	{"items": [{"brand": "HP", "model": null, "title": "tetst", "serial": null, "status": "assigned", "category": "PC portable", "reference": null, "assigned_at": "2026-07-29T14:12:35.337Z", "serial_number": null}], "title": "Mise à jour de la fiche d’affectation matériel", "reason": "Réaffectation de matériel depuis l’inventaire", "employee": "Thomas DIDRICHE", "licenses": [], "generated_at": "2026-07-29T14:12:35.373Z", "document_type": "hardware_reassignment", "movement_type": "onboarding", "reassignments": [{"old_status": "in_stock", "new_hardware_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e", "old_hardware_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a"}], "effective_date": null, "employee_email": "tdidriche@elyade.com"}	2026-07-29 14:12:35.337794+00	\N	\N	\N	\N	ENOENT: no such file or directory, open '/app/public/assets/logo-elyade.png'
a7c3563a-50fe-4709-8be0-04d1f51d436e	892fad26-a73f-4582-aa75-d616e44a3a2a	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-07-29 14:13:39.802+00	signed	{"items": [{"serial": null, "category": "PC portable", "reference": "TEST-MIGRATION-001"}], "employee": "Thomas DIDRICHE", "licenses": [{"type": "Microsoft 365 Business Premium"}], "movement_type": "onboarding", "effective_date": "2026-07-31T00:00:00.000Z"}	2026-07-29 14:13:40.762061+00	data:image/png;base64,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	\N	\N	\N	ENOENT: no such file or directory, open '/app/public/assets/logo-elyade.png'
0daa47ee-fb99-4c6f-84cd-dcb48aeb66f9	892fad26-a73f-4582-aa75-d616e44a3a2a	assignment	thomas didriche	tdidriche@elyade.com	2026-07-29 14:19:58.732+00	signed	{"items": [{"serial": null, "category": "PC portable", "reference": "TEST-MIGRATION-001"}], "employee": "Thomas DIDRICHE", "licenses": [{"type": "Microsoft 365 Business Premium"}], "movement_type": "onboarding", "effective_date": "2026-07-31T00:00:00.000Z"}	2026-07-29 14:19:59.668475+00	data:image/png;base64,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	storage/documents/Attribution_Thomas_DIDRICHE_20260729_0daa47ee.pdf	2026-07-29 14:19:59.80337+00	2026-07-29 14:20:00.270329+00	\N
bbb920e5-f652-4dc7-bf43-b084224942e6	892fad26-a73f-4582-aa75-d616e44a3a2a	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-07-29 14:20:19.094496+00	signed	{"items": [{"brand": null, "model": null, "title": null, "serial": "qsfqsefqsefqsefseqfsfssefff", "status": "assigned", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf", "assigned_at": "2026-07-29T14:20:19.094Z", "serial_number": "qsfqsefqsefqsefseqfsfssefff"}], "title": "Mise à jour de la fiche d’affectation matériel", "reason": "Réaffectation de matériel depuis l’inventaire", "employee": "Thomas DIDRICHE", "licenses": [{"seat": null, "type": "Microsoft 365 Business Premium"}], "generated_at": "2026-07-29T14:20:19.139Z", "document_type": "hardware_reassignment", "movement_type": "onboarding", "reassignments": [{"old_status": "in_stock", "new_hardware_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a", "old_hardware_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e"}], "effective_date": null, "employee_email": "tdidriche@elyade.com"}	2026-07-29 14:20:19.094496+00	\N	storage/documents/Attribution_Thomas_DIDRICHE_20260729_bbb920e5.pdf	2026-07-29 14:20:19.207446+00	2026-07-29 14:20:19.647781+00	\N
15ed3f98-823d-46c2-90af-47c1b4b295ad	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	assignment	thomas didriche	tdidriche@elyade.com	2026-07-29 14:31:56.984+00	signed	{"items": [{"serial": "qsfqsefqsefqsefseqfsfssefff", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf"}], "employee": "Thomas DIDRICHE", "licenses": [], "movement_type": "onboarding", "effective_date": "2026-07-24T00:00:00.000Z"}	2026-07-29 14:31:57.933373+00	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAjAAAACgCAYAAAASCFYFAAAQAElEQVR4AeydD5RbV33nv/dJM2M7jh2nCSSQQLOJvW2zmMQeSZPQliTAbsLZw9ndQqBhS/rn7G53A7uExCNpHNIJxJY0Nk27pO1yym5bdmmLQ7fL2bOFnNL8WQi29MYmAUKLA2lKAkmAgON/mfGM3u33PkkzmvH470h6T9L3zbvv3nfffff+7uc+vfvV70kaD1pEQAREQAREQAREoMsISMB02YDJXBEQAREQgTgQkA1RE5CAiXoE1L4IiIAIiIAIiMAZE5CAOWNkOkEEREAEoicgC0Sg3wlIwPT7FaD+i4AIiIAIiEAXEpCA6cJBk8kiED0BWSACIiAC0RKQgImWv1oXAREQAREQARE4CwISMGcBTadET0AWiIAIiIAI9DcBCZj+Hn/1XgREQAREQAS6koAEzFkNm04SAREQAREQARGIkoAETJT01bYIiIAIiIAI9BOBFvZVAqaFMFWVCIiACIiACIhAZwhIwHSGs1oRAREQARGInoAs6CECEjA9NJjqigiIgAiIgAj0CwEJmH4ZafVTBEQgegKyQAREoGUEJGBahlIViYAIiIAIiIAIdIqABEynSKsdEYiegCwQAREQgZ4hIAHTM0OpjoiACIiACIhA/xCQgOmfsY6+p7JABERABERABFpEQAKmRSBVjQiIgAiIgAiIQOcI9JOA6RxVtSQCIiACIiACItBWAhIwbcWrykVABERABESg2wnE034JmHiOi6wSAREQAREQARE4CQEJmJPA0SEREAEREIHoCcgCEViKgATMUlSUJwIiIAIiIAIiEGsCEjCxHh4ZJwIiED0BWSACIhBHAhIwcRwV2SQCIiACIiACInBSAhIwJ8WjgyIQPQFZIAIiIAIicDwBCZjjmShHBERABERABEQg5gQkYGI+QNGbJwtEQAREQAREIH4EJGDiNyaySAREQAREQARE4BQEYi9gTmG/DouACIiACIiACPQhAQmYPhx0dVkEREAERKDnCfR8ByVgen6I1UEREAEREAER6D0CEjC9N6bqkQiIgAhET0AWiECbCUjAtBmwqhcBERABERABEWg9AQmY1jNVjSIgAtETkAUiIAI9TkACpscHWN0TAREQAREQgV4kIAHTi6OqPkVPQBaIAAk8iFs3V1CqVlAMyijaMgot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	storage/documents/Attribution_Thomas_DIDRICHE_20260729_15ed3f98.pdf	2026-07-29 14:31:58.2184+00	2026-07-29 14:31:58.974754+00	\N
c08bdc12-272a-4afb-afd2-5459fb523f67	892fad26-a73f-4582-aa75-d616e44a3a2a	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-07-29 14:32:18.449848+00	signed	{"items": [{"brand": "HP", "model": null, "title": "tetst", "serial": null, "status": "assigned", "category": "PC portable", "reference": null, "assigned_at": "2026-07-29T14:32:18.449Z", "serial_number": null}], "title": "Mise à jour de la fiche d’affectation matériel", "reason": "Réaffectation de matériel depuis l’inventaire", "employee": "Thomas DIDRICHE", "licenses": [{"seat": null, "type": "Microsoft 365 Business Premium"}], "generated_at": "2026-07-29T14:32:18.496Z", "document_type": "hardware_reassignment", "movement_type": "onboarding", "reassignments": [{"old_status": "in_stock", "new_hardware_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e", "old_hardware_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a"}], "effective_date": null, "employee_email": "tdidriche@elyade.com"}	2026-07-29 14:32:18.449848+00	\N	storage/documents/Attribution_Thomas_DIDRICHE_20260729_c08bdc12.pdf	2026-07-29 14:32:18.645585+00	2026-07-29 14:32:19.018864+00	\N
5d8fc0cc-85f6-4df6-bc9d-abec4e817d52	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-08-26 15:11:01.001707+00	signed	{"items": [{"brand": "HP", "model": null, "title": "tetst", "serial": null, "status": "assigned", "category": "PC portable", "reference": null, "assigned_at": "2026-07-29T14:32:18.449Z", "serial_number": null}, {"brand": "HP", "model": null, "title": "tetst", "serial": null, "status": "assigned", "category": "PC portable", "reference": null, "assigned_at": "2026-08-26T14:19:20.229Z", "serial_number": null}, {"brand": "HP", "model": null, "title": "tetst", "serial": null, "status": "assigned", "category": "PC portable", "reference": null, "assigned_at": "2026-08-26T15:11:01.001Z", "serial_number": null}, {"brand": null, "model": null, "title": null, "serial": "qsfqsefqsefqsefseqfsfssefff", "status": "in_stock", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf", "assigned_at": "2026-08-26T14:30:08.242Z", "serial_number": "qsfqsefqsefqsefseqfsfssefff"}, {"brand": null, "model": null, "title": null, "serial": "qdfqfqfqfqqf", "status": "assigned", "category": "Téléphone", "reference": "dqf", "assigned_at": "2026-08-26T14:57:03.317Z", "serial_number": "qdfqfqfqfqqf"}], "title": "Mise à jour de la fiche d’affectation matériel", "reason": "Réaffectation de matériel depuis l’inventaire", "employee": "Thomas DIDRICHE", "licenses": [{"seat": null, "type": "Microsoft 365 Business Premium"}], "generated_at": "2026-08-26T15:11:01.055Z", "document_type": "hardware_reassignment", "movement_type": "onboarding", "reassignments": [{"old_status": "in_stock", "new_hardware_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e", "old_hardware_id": "3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c"}], "effective_date": null, "employee_email": "tdidriche@elyade.com"}	2026-08-26 15:11:01.001707+00	\N	\N	\N	\N	formattedDate is not defined
b8086b9b-2347-496e-92b2-72e2f045e846	3e4ff0c1-b5ad-4e29-9a4a-6262d0cf951f	assignment	Thomas DIDRICHE	tdidriche@elyade.com	2026-08-26 15:12:22.141129+00	signed	{"items": [{"brand": null, "model": null, "title": null, "serial": "qsfqsefqsefqsefseqfsfssefff", "status": "assigned", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf", "assigned_at": "2026-08-26T14:30:08.242Z", "serial_number": "qsfqsefqsefqsefseqfsfssefff"}, {"brand": null, "model": null, "title": null, "serial": "qsfqsefqsefqsefseqfsfssefff", "status": "assigned", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf", "assigned_at": "2026-08-26T15:12:22.141Z", "serial_number": "qsfqsefqsefqsefseqfsfssefff"}, {"brand": null, "model": null, "title": null, "serial": "qdfqfqfqfqqf", "status": "assigned", "category": "Téléphone", "reference": "dqf", "assigned_at": "2026-08-26T14:57:03.317Z", "serial_number": "qdfqfqfqfqqf"}], "title": "Mise à jour de la fiche d’affectation matériel", "reason": "Réaffectation de matériel depuis l’inventaire", "employee": "Thomas DIDRICHE", "licenses": [{"seat": null, "type": "Microsoft 365 Business Premium"}], "generated_at": "2026-08-26T15:12:22.162Z", "document_type": "hardware_reassignment", "movement_type": "onboarding", "reassignments": [{"old_status": "in_stock", "new_hardware_id": "04d2e68c-364b-45c3-bb11-9449dbc7571a", "old_hardware_id": "b270d931-f4fe-477b-83dd-2d4195b8b28e"}], "effective_date": null, "employee_email": "tdidriche@elyade.com"}	2026-08-26 15:12:22.141129+00	\N	\N	\N	\N	formattedDate is not defined
\.


--
-- Data for Name: subscribed_skus; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.subscribed_skus (id, sku_id, display_name, applies_to, enabled_units, consumed_units, prepaid_units, synced_at) FROM stdin;
68b18bab-e19b-4e86-86ef-c0dcaec707a7	f8a1db68-be16-40ed-86d5-cb42ce701560	POWER_BI_PRO	User	8	8	8	2026-07-22 10:41:26.779516+00
d06b94b3-9d80-416a-854c-f7c26b2e85e8	639dec6b-bb19-468b-871c-c5c441c4b0cb	Microsoft_365_Copilot	User	85	81	85	2026-07-22 10:41:26.799858+00
d99e3199-882e-498c-92c3-b5e46066aead	8f0c5670-4e56-4892-b06d-91c085d7004f	SPZA_IW	User	10000	0	10000	2026-07-22 10:41:26.80791+00
ad9f2339-cc3f-4529-b604-c830299170bc	6470687e-a428-4b7a-bef2-8a291ad947c9	WINDOWS_STORE	Company	0	0	0	2026-07-22 10:41:26.82078+00
c1758f01-f4b2-4ff9-9cb4-0ecfd25742fe	f30db892-07e9-47e9-837c-80727f46fd3d	FLOW_FREE	User	10000	103	10000	2026-07-22 10:41:26.826976+00
7ab12197-afde-42e6-9331-9e98ab488771	606b54a9-78d8-4298-ad8b-df6ef4481c80	CCIBOTS_PRIVPREV_VIRAL	User	10000	2	10000	2026-07-22 10:41:26.831105+00
16ff801f-ca1b-4a30-92a7-6330074e8c04	cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46	SPB	User	78	59	78	2026-07-22 10:41:26.836326+00
2540a03c-74e5-4424-b9f6-77d6142dd506	dcb1a3ae-b33f-4487-846a-a640262fadf4	POWERAPPS_VIRAL	User	10000	1	10000	2026-07-22 10:41:26.839888+00
fca35b26-cf13-4440-b54d-50f61caa274d	4b9405b0-7788-4568-add1-99614e613b69	EXCHANGESTANDARD	User	13	13	13	2026-07-22 10:41:26.842281+00
491fa68f-d447-4fbb-a322-9567328de30f	f245ecc8-75af-4f8e-b61f-27d8114de5f3	O365_BUSINESS_PREMIUM	User	105	101	105	2026-07-22 10:41:26.844857+00
a041f3a6-4e07-4bf4-b263-c68014451767	a403ebcc-fae0-4ca2-8c8c-7a907fd6c235	POWER_BI_STANDARD	User	1000000	15	1000000	2026-07-22 10:41:26.847789+00
b29741bb-7406-4a3d-95ce-cc917fae68b9	c1d032e0-5619-4761-9b5c-75b6831e1711	PBI_PREMIUM_PER_USER	User	5	5	5	2026-07-22 10:41:26.851005+00
6c1f5f68-2528-4ee2-ad02-5f1555535006	3f9f06f5-3c31-472c-985f-62d9c10ec167	Power_Pages_vTrial_for_Makers	User	10000	2	10000	2026-07-22 10:41:26.854342+00
bb2a908b-bd0b-4b1b-a148-83badcdab180	093e8d14-a334-43d9-93e3-30589a8b47d0	RMSBASIC	Company	1	0	1	2026-07-22 10:41:26.861201+00
37f3360a-cf3b-419a-b995-2f5a4ce3d35a	52ea0e27-ae73-4983-a08f-13561ebdb823	Teams_Premium_(for_Departments)	User	0	0	0	2026-07-22 10:41:26.867054+00
6b85e5f3-3975-43de-9fae-95e35f77d233	8c4ce438-32a7-4ac5-91a6-e22ae08d9c8b	RIGHTSMANAGEMENT_ADHOC	User	50000	0	50000	2026-07-22 10:41:26.87029+00
6b5021ab-7923-4e72-8e44-899d11e404f2	5b631642-bd26-49fe-bd20-1daaa972ef80	POWERAPPS_DEV	User	10000	4	10000	2026-07-22 10:41:26.875221+00
\.


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: contract_types contract_types_code_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.contract_types
    ADD CONSTRAINT contract_types_code_key UNIQUE (code);


--
-- Name: contract_types contract_types_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.contract_types
    ADD CONSTRAINT contract_types_pkey PRIMARY KEY (id);


--
-- Name: dashboard_widgets dashboard_widgets_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.dashboard_widgets
    ADD CONSTRAINT dashboard_widgets_pkey PRIMARY KEY (id);


--
-- Name: dashboard_widgets dashboard_widgets_user_id_widget_key_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.dashboard_widgets
    ADD CONSTRAINT dashboard_widgets_user_id_widget_key_key UNIQUE (user_id, widget_key);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: hardware_assignments hardware_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_assignments
    ADD CONSTRAINT hardware_assignments_pkey PRIMARY KEY (id);


--
-- Name: hardware_categories hardware_categories_code_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_categories
    ADD CONSTRAINT hardware_categories_code_key UNIQUE (code);


--
-- Name: hardware_categories hardware_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_categories
    ADD CONSTRAINT hardware_categories_pkey PRIMARY KEY (id);


--
-- Name: hardware_groups hardware_groups_name_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_groups
    ADD CONSTRAINT hardware_groups_name_key UNIQUE (name);


--
-- Name: hardware_groups hardware_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_groups
    ADD CONSTRAINT hardware_groups_pkey PRIMARY KEY (id);


--
-- Name: hardware_items hardware_items_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_items
    ADD CONSTRAINT hardware_items_pkey PRIMARY KEY (id);


--
-- Name: inventory_brands inventory_brands_label_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_brands
    ADD CONSTRAINT inventory_brands_label_key UNIQUE (label);


--
-- Name: inventory_brands inventory_brands_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_brands
    ADD CONSTRAINT inventory_brands_pkey PRIMARY KEY (id);


--
-- Name: inventory_budgets inventory_budgets_label_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_budgets
    ADD CONSTRAINT inventory_budgets_label_key UNIQUE (label);


--
-- Name: inventory_budgets inventory_budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_budgets
    ADD CONSTRAINT inventory_budgets_pkey PRIMARY KEY (id);


--
-- Name: inventory_memories inventory_memories_label_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_memories
    ADD CONSTRAINT inventory_memories_label_key UNIQUE (label);


--
-- Name: inventory_memories inventory_memories_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_memories
    ADD CONSTRAINT inventory_memories_pkey PRIMARY KEY (id);


--
-- Name: inventory_operating_systems inventory_operating_systems_label_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_operating_systems
    ADD CONSTRAINT inventory_operating_systems_label_key UNIQUE (label);


--
-- Name: inventory_operating_systems inventory_operating_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_operating_systems
    ADD CONSTRAINT inventory_operating_systems_pkey PRIMARY KEY (id);


--
-- Name: inventory_processors inventory_processors_label_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_processors
    ADD CONSTRAINT inventory_processors_label_key UNIQUE (label);


--
-- Name: inventory_processors inventory_processors_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_processors
    ADD CONSTRAINT inventory_processors_pkey PRIMARY KEY (id);


--
-- Name: inventory_sizes inventory_sizes_label_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_sizes
    ADD CONSTRAINT inventory_sizes_label_key UNIQUE (label);


--
-- Name: inventory_sizes inventory_sizes_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_sizes
    ADD CONSTRAINT inventory_sizes_pkey PRIMARY KEY (id);


--
-- Name: inventory_statuses inventory_statuses_label_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_statuses
    ADD CONSTRAINT inventory_statuses_label_key UNIQUE (label);


--
-- Name: inventory_statuses inventory_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_statuses
    ADD CONSTRAINT inventory_statuses_pkey PRIMARY KEY (id);


--
-- Name: inventory_suppliers inventory_suppliers_label_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_suppliers
    ADD CONSTRAINT inventory_suppliers_label_key UNIQUE (label);


--
-- Name: inventory_suppliers inventory_suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.inventory_suppliers
    ADD CONSTRAINT inventory_suppliers_pkey PRIMARY KEY (id);


--
-- Name: license_types license_types_code_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.license_types
    ADD CONSTRAINT license_types_code_key UNIQUE (code);


--
-- Name: license_types license_types_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.license_types
    ADD CONSTRAINT license_types_pkey PRIMARY KEY (id);


--
-- Name: licenses licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);


--
-- Name: microsoft_license_filters microsoft_license_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.microsoft_license_filters
    ADD CONSTRAINT microsoft_license_filters_pkey PRIMARY KEY (sku_part_number);


--
-- Name: movement_actions movement_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_actions
    ADD CONSTRAINT movement_actions_pkey PRIMARY KEY (id);


--
-- Name: movement_items movement_items_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_items
    ADD CONSTRAINT movement_items_pkey PRIMARY KEY (id);


--
-- Name: movement_licenses movement_licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_licenses
    ADD CONSTRAINT movement_licenses_pkey PRIMARY KEY (id);


--
-- Name: movement_service_groups movement_service_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_service_groups
    ADD CONSTRAINT movement_service_groups_pkey PRIMARY KEY (id);


--
-- Name: movements movements_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_pkey PRIMARY KEY (id);


--
-- Name: onboarding_action_templates onboarding_action_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.onboarding_action_templates
    ADD CONSTRAINT onboarding_action_templates_pkey PRIMARY KEY (id);


--
-- Name: onboarding_details onboarding_details_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.onboarding_details
    ADD CONSTRAINT onboarding_details_pkey PRIMARY KEY (id);


--
-- Name: processed_offboarding_emails processed_offboarding_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.processed_offboarding_emails
    ADD CONSTRAINT processed_offboarding_emails_pkey PRIMARY KEY (message_id);


--
-- Name: service_peripherals service_peripherals_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.service_peripherals
    ADD CONSTRAINT service_peripherals_pkey PRIMARY KEY (id);


--
-- Name: services services_name_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_name_key UNIQUE (name);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: signed_documents signed_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.signed_documents
    ADD CONSTRAINT signed_documents_pkey PRIMARY KEY (id);


--
-- Name: subscribed_skus subscribed_skus_pkey; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.subscribed_skus
    ADD CONSTRAINT subscribed_skus_pkey PRIMARY KEY (id);


--
-- Name: subscribed_skus subscribed_skus_sku_id_key; Type: CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.subscribed_skus
    ADD CONSTRAINT subscribed_skus_sku_id_key UNIQUE (sku_id);


--
-- Name: idx_employees_microsoft_object_id; Type: INDEX; Schema: public; Owner: gestion_it
--

CREATE INDEX idx_employees_microsoft_object_id ON public.employees USING btree (microsoft_object_id);


--
-- Name: idx_employees_microsoft_upn; Type: INDEX; Schema: public; Owner: gestion_it
--

CREATE INDEX idx_employees_microsoft_upn ON public.employees USING btree (lower(microsoft_upn));


--
-- Name: assignments assignments_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: assignments assignments_hardware_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_hardware_item_id_fkey FOREIGN KEY (hardware_item_id) REFERENCES public.hardware_items(id);


--
-- Name: employees employees_contract_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_contract_type_id_fkey FOREIGN KEY (contract_type_id) REFERENCES public.contract_types(id);


--
-- Name: employees employees_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: hardware_assignments hardware_assignments_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_assignments
    ADD CONSTRAINT hardware_assignments_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: hardware_assignments hardware_assignments_hardware_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_assignments
    ADD CONSTRAINT hardware_assignments_hardware_item_id_fkey FOREIGN KEY (hardware_item_id) REFERENCES public.hardware_items(id);


--
-- Name: hardware_items hardware_items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.hardware_items
    ADD CONSTRAINT hardware_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.hardware_categories(id);


--
-- Name: licenses licenses_assigned_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_assigned_employee_id_fkey FOREIGN KEY (assigned_employee_id) REFERENCES public.employees(id);


--
-- Name: licenses licenses_license_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.licenses
    ADD CONSTRAINT licenses_license_type_id_fkey FOREIGN KEY (license_type_id) REFERENCES public.license_types(id);


--
-- Name: movement_actions movement_actions_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_actions
    ADD CONSTRAINT movement_actions_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.movements(id);


--
-- Name: movement_items movement_items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_items
    ADD CONSTRAINT movement_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.hardware_categories(id);


--
-- Name: movement_items movement_items_hardware_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_items
    ADD CONSTRAINT movement_items_hardware_item_id_fkey FOREIGN KEY (hardware_item_id) REFERENCES public.hardware_items(id);


--
-- Name: movement_items movement_items_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_items
    ADD CONSTRAINT movement_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.movements(id);


--
-- Name: movement_licenses movement_licenses_license_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_licenses
    ADD CONSTRAINT movement_licenses_license_id_fkey FOREIGN KEY (license_id) REFERENCES public.licenses(id);


--
-- Name: movement_licenses movement_licenses_license_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_licenses
    ADD CONSTRAINT movement_licenses_license_type_id_fkey FOREIGN KEY (license_type_id) REFERENCES public.license_types(id);


--
-- Name: movement_licenses movement_licenses_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_licenses
    ADD CONSTRAINT movement_licenses_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.movements(id);


--
-- Name: movement_service_groups movement_service_groups_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movement_service_groups
    ADD CONSTRAINT movement_service_groups_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.movements(id) ON DELETE CASCADE;


--
-- Name: movements movements_contract_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_contract_type_id_fkey FOREIGN KEY (contract_type_id) REFERENCES public.contract_types(id);


--
-- Name: movements movements_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: movements movements_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.movements
    ADD CONSTRAINT movements_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: onboarding_details onboarding_details_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.onboarding_details
    ADD CONSTRAINT onboarding_details_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.movements(id) ON DELETE CASCADE;


--
-- Name: service_peripherals service_peripherals_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.service_peripherals
    ADD CONSTRAINT service_peripherals_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.hardware_categories(id);


--
-- Name: service_peripherals service_peripherals_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.service_peripherals
    ADD CONSTRAINT service_peripherals_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: signed_documents signed_documents_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gestion_it
--

ALTER TABLE ONLY public.signed_documents
    ADD CONSTRAINT signed_documents_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.movements(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 0REjESXUk3ucDeisodJSbigmrbaKL63ZtbDYRfZEbsVgHv0mIJJAWZwedIvmWZu

