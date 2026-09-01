--
-- PostgreSQL database dump
--

\restrict vxvaNs008rtzV23KTPUfawrTGlpuwk1wVBllFBC6Xwy2mSz2Ne3cvmSK9bmLGux

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
    returned_at timestamp with time zone
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

COPY public.assignments (id, employee_id, hardware_item_id, assigned_at, returned_at) FROM stdin;
dfd6d526-f0b4-4c5c-ba7c-bace9c9162c7	62d06322-8057-4756-9750-fb595d22f5e8	04d2e68c-364b-45c3-bb11-9449dbc7571a	2026-07-28 09:28:22.916854+00	2026-07-29 13:11:53.746315+00
07fcaa55-58a7-4015-ba77-c776728b5918	62d06322-8057-4756-9750-fb595d22f5e8	b270d931-f4fe-477b-83dd-2d4195b8b28e	2026-07-29 13:11:53.746315+00	2026-07-29 13:34:32.257046+00
d19eb396-9364-4a76-8fea-d44eada25bf5	62d06322-8057-4756-9750-fb595d22f5e8	04d2e68c-364b-45c3-bb11-9449dbc7571a	2026-07-29 13:34:32.257046+00	2026-07-29 13:41:25.830545+00
37ada675-0cab-4efd-9a08-6174b9f1cbdc	62d06322-8057-4756-9750-fb595d22f5e8	b270d931-f4fe-477b-83dd-2d4195b8b28e	2026-07-29 13:41:25.830545+00	2026-07-29 14:05:42.726394+00
973ad1d5-4220-4d55-8e17-5c9f59fa873f	62d06322-8057-4756-9750-fb595d22f5e8	04d2e68c-364b-45c3-bb11-9449dbc7571a	2026-07-29 14:05:42.726394+00	2026-07-29 14:12:35.337794+00
9ba51333-b564-4e32-ae13-d412736f7839	62d06322-8057-4756-9750-fb595d22f5e8	b270d931-f4fe-477b-83dd-2d4195b8b28e	2026-07-29 14:12:35.337794+00	2026-07-29 14:20:19.094496+00
dc18e19b-cffd-4e8f-bcfc-9e382cc0dac0	62d06322-8057-4756-9750-fb595d22f5e8	04d2e68c-364b-45c3-bb11-9449dbc7571a	2026-07-29 14:20:19.094496+00	2026-07-29 14:32:18.449848+00
25b7f890-3fcb-4ecd-b4f7-3593f8dcedd6	62d06322-8057-4756-9750-fb595d22f5e8	04d2e68c-364b-45c3-bb11-9449dbc7571a	2026-08-26 14:30:08.24218+00	\N
3c18bbb3-a750-44eb-8594-02e53ddc4b30	62d06322-8057-4756-9750-fb595d22f5e8	9f039fb1-e061-48b1-8521-870e9466efe9	2026-08-26 14:57:03.317306+00	\N
71466bc0-5aaf-471b-8309-94ef3e1a4d02	62d06322-8057-4756-9750-fb595d22f5e8	3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c	2026-08-26 14:32:40.737637+00	2026-08-26 15:11:01.001707+00
512edbe2-a376-47ce-a782-d10f054c830b	62d06322-8057-4756-9750-fb595d22f5e8	b270d931-f4fe-477b-83dd-2d4195b8b28e	2026-07-29 14:32:18.449848+00	2026-08-26 15:12:22.141129+00
bc7095ed-39b8-4fe7-b60f-bbd53b12d86b	62d06322-8057-4756-9750-fb595d22f5e8	b270d931-f4fe-477b-83dd-2d4195b8b28e	2026-08-26 14:19:20.229387+00	2026-08-26 15:12:22.141129+00
a0ecc9dc-c710-4a29-9ed5-6857db775a56	9c8b043d-a01c-4089-af23-294d15b8b655	b270d931-f4fe-477b-83dd-2d4195b8b28e	2026-08-26 14:20:31.86864+00	2026-08-26 15:12:22.141129+00
128efd8e-b59f-48ac-b4b6-dd4cdb83b000	db3c5e00-b3d0-4667-ad5e-aed47b6e7129	b270d931-f4fe-477b-83dd-2d4195b8b28e	2026-08-26 14:27:47.861419+00	2026-08-26 15:12:22.141129+00
50257457-d06c-4fb7-9637-072b313d525d	62d06322-8057-4756-9750-fb595d22f5e8	b270d931-f4fe-477b-83dd-2d4195b8b28e	2026-08-26 15:11:01.001707+00	2026-08-26 15:12:22.141129+00
65078af9-66b5-4790-98af-98e112d2588e	62d06322-8057-4756-9750-fb595d22f5e8	04d2e68c-364b-45c3-bb11-9449dbc7571a	2026-08-26 15:12:22.141129+00	\N
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
\.


--
-- Data for Name: hardware_items; Type: TABLE DATA; Schema: public; Owner: gestion_it
--

COPY public.hardware_items (id, category_id, reference, serial_number, brand, model, status, intune_device_id, atera_ticket_id, purchase_date, notes, created_at, updated_at, title, os_id, processor_id, memory_id, size_id, hdmi, displayport, invoice_number, purchase_value, supplier_id, budget_id, warranty_expiration_date, asset_number, usbc) FROM stdin;
b270d931-f4fe-477b-83dd-2d4195b8b28e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	\N	HP	\N	in_stock	\N	\N	\N	\N	2026-07-29 13:00:11.835662+00	2026-08-26 15:12:22.141129+00	tetst	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
04d2e68c-364b-45c3-bb11-9449dbc7571a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	dazfqsgfsegfgfqsf	qsfqsefqsefqsefseqfsfssefff	\N	\N	assigned	\N	\N	\N	\N	2026-07-28 09:27:49.158551+00	2026-08-26 15:12:22.141129+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9dcc9c11-96f4-4c49-b0a7-23bc4421c80c	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X7FQF	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:04.178316+00	2026-08-26 16:02:04.178316+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8099a90d-293f-42f1-a650-38ab65994ae0	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X7FQF	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.034115+00	2026-08-26 16:02:20.034115+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9558bb52-db57-4b48-93b7-42aa9bd37555	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW50LXEET	Samsung	SM-X205	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.038784+00	2026-08-26 16:02:20.038784+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ffc8ccf9-64af-4a39-9f8e-cec29f8ef996	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X7GAW	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.040056+00	2026-08-26 16:02:20.040056+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bc50d307-5707-4241-aba2-441279acfa1b	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R9PW500KF4X	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.041447+00	2026-08-26 16:02:20.041447+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
64ccdc17-cd78-4dbd-90a3-f44e7c60c487	9b8de84b-c049-47f2-b0f0-414f33d68b90	iPad 10	M72P24PMGH	Apple Inc.	iPad 10e gen	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.043021+00	2026-08-26 16:02:20.043021+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8cea045a-6cae-4b06-bca7-e81eb48a11e8	9b8de84b-c049-47f2-b0f0-414f33d68b90	iPad 10	X7H4X7G35C	Apple Inc.	iPad 10e gen	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.044554+00	2026-08-26 16:02:20.044554+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
32b95052-898e-45f4-94a0-79d86ecfa79c	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20YZZQK	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.04592+00	2026-08-26 16:02:20.04592+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7a12824a-f0e8-4b93-98d5-2c0426d3b4ba	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X7FRY	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.047229+00	2026-08-26 16:02:20.047229+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
05ac0de3-dc56-465d-b853-44ef44f1750f	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X7B2A	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.048549+00	2026-08-26 16:02:20.048549+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ceb933e1-bb44-4adb-8304-e464421ac7f2	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X7BZY	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.049723+00	2026-08-26 16:02:20.049723+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5153d77e-f4d2-45a5-8f3b-a133ff8b2ed6	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X79DT	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.050909+00	2026-08-26 16:02:20.050909+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d484d8a4-c156-47f5-b04f-c942ba07f53f	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X7F9K	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.052326+00	2026-08-26 16:02:20.052326+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6f495d71-46ac-4a69-93f5-5faf199c630b	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20X7G4B	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.054205+00	2026-08-26 16:02:20.054205+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b07d8a2a-8a78-4259-b232-deee0ae988e2	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW50LXEJP	Samsung	SM-X205	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.055465+00	2026-08-26 16:02:20.055465+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
40bd2a53-e532-4868-bbd8-6e7bfc3e89c8	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20YZYDB	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.05712+00	2026-08-26 16:02:20.05712+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1dd3f65c-7d80-4a16-bb78-dc1c6439e983	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20Z01BD	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.058915+00	2026-08-26 16:02:20.058915+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
06bb64c2-3954-4cea-9a83-b12e1a8f9e8a	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20YZYEH	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.060356+00	2026-08-26 16:02:20.060356+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5c2f858f-df46-48e4-967f-26ea6eeeeb50	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20Z00AR	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.061666+00	2026-08-26 16:02:20.061666+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2fbbd31b-5bea-4e70-b111-6eeedb03d5da	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20Z01DR	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.062725+00	2026-08-26 16:02:20.062725+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
53f24b83-1ae6-478d-ab6d-def2438d5f0a	9b8de84b-c049-47f2-b0f0-414f33d68b90	Galaxy Tab A8	R8YW20Z005N	Samsung	SM-X200	in_stock	\N	\N	\N	\N	2026-08-26 16:02:20.06377+00	2026-08-26 16:02:20.06377+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9f039fb1-e061-48b1-8521-870e9466efe9	591e509f-b8f4-4b8c-ae1c-174b8f513139	dqf	qdfqfqfqfqqf	\N	\N	assigned	\N	\N	\N	\N	2026-07-22 10:33:21.688524+00	2026-08-26 14:57:03.267293+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	TEST-MIGRATION-001	\N	Test	Migration	in_stock	\N	\N	\N	\N	2026-07-20 13:55:23.904055+00	2026-08-26 15:11:01.001707+00	\N	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
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
6ff3efc2-f0d6-409e-91ab-2c5d320feb1b	0b6740ee-5ad0-4dbd-8c56-1137933137f6	de5d066d-4c5a-4eab-861e-9bb5eca739bf	\N	requested	\N	2026-07-22 11:04:08.282709+00
08c4a0e1-a93c-4e96-abe2-a432f1c61131	0b6740ee-5ad0-4dbd-8c56-1137933137f6	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	requested	\N	2026-07-22 11:04:08.282709+00
a6f5888e-7602-4dcc-ad34-b7bde0c096a9	0b6740ee-5ad0-4dbd-8c56-1137933137f6	3981e88a-85b7-4a12-9342-dca750713f52	\N	requested	\N	2026-07-22 11:04:08.282709+00
6b128b98-7bda-4b9b-af65-9371719a397d	892fad26-a73f-4582-aa75-d616e44a3a2a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	3d6e35fd-03ad-4d9f-8bc7-9d2c8f5ea02c	assigned	\N	2026-07-22 11:04:52.290399+00
b2866a1a-99ee-4cc3-b942-5100f1fc4b1f	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	requested	\N	2026-07-22 15:21:46.540959+00
86bbfbad-20a2-45ad-a238-6d9b3caa10e9	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	04d2e68c-364b-45c3-bb11-9449dbc7571a	assigned	\N	2026-07-22 15:21:46.540959+00
387f393d-a382-4f54-8fc5-f13fe65ef24c	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	requested	\N	2026-07-29 16:13:09.253461+00
6f37a95f-a50c-4a7e-9df5-10f39567146b	4b0c9fe6-96ed-4d89-801a-c17c673889f8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	requested	\N	2026-07-29 16:16:07.001416+00
e5425afa-7810-4010-bf60-747044643cc3	4b0c9fe6-96ed-4d89-801a-c17c673889f8	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	requested	\N	2026-07-29 16:16:07.001416+00
6e13b310-9821-4f49-877b-1008d988456b	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	requested	\N	2026-07-30 07:06:13.03858+00
77cdeb00-9ce1-45eb-a244-df37eb2c47c5	aa8a22e0-06f5-46c7-8ff0-536e0434bde3	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	requested	\N	2026-07-30 07:06:13.03858+00
3aa17811-8ec6-48ef-bfbc-6eb08c02a354	d1839fd9-a603-4c8d-97c0-702d9fd5b040	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	requested	\N	2026-07-30 10:15:04.046137+00
d33c885f-e543-465a-a2a3-d42fda0e893b	a123f0f9-90a9-4e74-80f0-1155bbd64729	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	requested	\N	2026-07-30 12:35:32.903509+00
9af6998b-7acf-4cd0-9148-9852861bddb2	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	requested	\N	2026-07-30 12:43:32.668054+00
75cf7997-6ee7-4e13-a598-d8efe1292444	0f4b9dcf-aef8-4f1a-86e2-ee84b7bedf82	de5d066d-4c5a-4eab-861e-9bb5eca739bf	\N	requested	\N	2026-07-30 12:43:32.668054+00
c7592bac-1ece-4c43-b67a-ecaedb91576c	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	591e509f-b8f4-4b8c-ae1c-174b8f513139	9f039fb1-e061-48b1-8521-870e9466efe9	assigned	\N	2026-07-29 16:13:09.253461+00
43aa9286-5020-41db-8a30-96899d04da54	4b0c9fe6-96ed-4d89-801a-c17c673889f8	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	b270d931-f4fe-477b-83dd-2d4195b8b28e	assigned	\N	2026-07-29 16:16:07.001416+00
9e105ae0-2d5b-420d-834a-545ac24990f5	f9f3ef26-0aa0-4aa4-ba4c-5f7f6e5917ef	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	04d2e68c-364b-45c3-bb11-9449dbc7571a	assigned	\N	2026-07-29 16:13:09.253461+00
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
15ed3f98-823d-46c2-90af-47c1b4b295ad	3fa92b71-50aa-4c3c-9780-1e103c8cc4d7	assignment	thomas didriche	tdidriche@elyade.com	2026-07-29 14:31:56.984+00	signed	{"items": [{"serial": "qsfqsefqsefqsefseqfsfssefff", "category": "PC portable", "reference": "dazfqsgfsegfgfqsf"}], "employee": "Thomas DIDRICHE", "licenses": [], "movement_type": "onboarding", "effective_date": "2026-07-24T00:00:00.000Z"}	2026-07-29 14:31:57.933373+00	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAjAAAACgCAYAAAASCFYFAAAQAElEQVR4AeydD5RbV33nv/dJM2M7jh2nCSSQQLOJvW2zmMQeSZPQliTAbsLZw9ndQqBhS/rn7G53A7uExCNpHNIJxJY0Nk27pO1yym5bdmmLQ7fL2bOFnNL8WQi29MYmAUKLA2lKAkmAgON/mfGM3u33PkkzmvH470h6T9L3zbvv3nfffff+7uc+vfvV70kaD1pEQAREQAREQAREoMsISMB02YDJXBEQAREQgTgQkA1RE5CAiXoE1L4IiIAIiIAIiMAZE5CAOWNkOkEEREAEoicgC0Sg3wlIwPT7FaD+i4AIiIAIiEAXEpCA6cJBk8kiED0BWSACIiAC0RKQgImWv1oXAREQAREQARE4CwISMGcBTadET0AWiIAIiIAI9DcBCZj+Hn/1XgREQAREQAS6koAEzFkNm04SAREQAREQARGIkoAETJT01bYIiIAIiIAI9BOBFvZVAqaFMFWVCIiACIiACIhAZwhIwHSGs1oRAREQARGInoAs6CECEjA9NJjqigiIgAiIgAj0CwEJmH4ZafVTBEQgegKyQAREoGUEJGBahlIViYAIiIAIiIAIdIqABEynSKsdEYiegCwQAREQgZ4hIAHTM0OpjoiACIiACIhA/xCQgOmfsY6+p7JABERABERABFpEQAKmRSBVjQiIgAiIgAiIQOcI9JOA6RxVtSQCIiACIiACItBWAhIwbcWrykVABERABESg2wnE034JmHiOi6wSAREQAREQARE4CQEJmJPA0SEREAEREIHoCcgCEViKgATMUlSUJwIiIAIiIAIiEGsCEjCxHh4ZJwIiED0BWSACIhBHAhIwcRwV2SQCIiACIiACInBSAhIwJ8WjgyIQPQFZIAIiIAIicDwBCZjjmShHBERABERABEQg5gQkYGI+QNGbJwtEQAREQAREIH4EJGDiNyaySAREQAREQARE4BQEYi9gTmG/DouACIiACIiACPQhAQmYPhx0dVkEREAERKDnCfR8ByVgen6I1UEREAEREAER6D0CEjC9N6bqkQiIgAhET0AWiECbCUjAtBmwqhcBERABERABEWg9AQmY1jNVjSIgAtETkAUiIAI9TkACpscHWN0TAREQAREQgV4kIAHTi6OqPkVPQBaIAAk8iFs3V1CqVlAMyijaMgotC6zT+igGPkrBHsbcZzul2X0oPmsxvoHNaxWBniYgAdPTw6vOiYAIdILAI7j7tydDoVIKhQrFhHVhHX52ErDuPmsMDTFo3R+rgwWMhTVswABgZBOzwCU+VnyrglJogxNOFRTD9HxcYjGeoVUEupgAL/gutl6mn4iA8kVABNpA4DF87P9SENDTUQxqYqAQCoNVWHV7ACdUbChUFjdtmOECxQZaFSiMWOvJVsobHnbtMlq02kTN/lLwMMaTiw5qVwS6goDXFVbKSBEQARHoIIEKduzzUawyUKgU+Nin5sEYwMy/pCBw901GzqB65JJzwTo/C9VMEAxi6s/TyJlUPWSQN60KadaVZr1LhQRWvxvwXjLwqgmYwMDQnlrAgsWac7BixkcpmMTOCxYc0o4IxJyAeyG23kTVKAIiIAJdRGASBXpVat4U55kAqldbwGMwcHIExy/Ok2JqwiBg+QfnhUSegiXrDWMscRXGf/n4M9ufsxnv35XG6AUpjCY3I5tIwdlTC85O2l5ttoL7JsDsD30Kmb3Y8cPmY0qLQFwJSMDEdWRklwiIQFsJ/CVuuYpihR6Wog3Q+BjJ8U1aWCdhnAeDnozqo04AuOA8KXVhkEhj643HnxnfnAzySdeHGcw+70RYw1L21VRRvYBc7G7smGrkK+4cAbV0+gQkYE6flUqKgAj0AIEKJg76KAavxcavsjuGYW419KhQrgRVJPa5Cd4FTvZ1j4rzZGy9bq5wDyTehLte40TYUVz1i2bRh2oSqA71QBfVhR4mIAHTw4OrromACMwTKPPxiPMsAMG5FnSqoLYwTR9LcMSJFTeZZ5BNXIMtm2tH+2N7HW78Ugo5L42csRRxjV5XyKyRViwCcSMgARO3EZE9IiACLSPwJIp3V+htYbAGXJtqNpyoLS69OYOcyWBsddOhvk5mkPUMYGsQrNmFXRfW0tqKQLwISMDEazxkjQj0NYFWdd5HaaqMoj0C3MM6OR9zO7cam6ZoqXlb3vvAXLYScwSG8KorGjuX4e9fbKQVi0CcCEjAxGk0ZIsIiMCyCNDTEn4o18IOLVItSMJMO+GSpodhWY30wckb8etPezCB6ypZGgrCaZdWEIE4EfDiZIxsEYFoCaj1biSwG+Of9FEMhQvtX6BbuGOrGMo64bIJ2RU8rvU0CQwjm7D1shbBYD2pSARiQ0ACJjZDIUNEQATOhICPwgw9LjaBFb/BiZZapXa2Sxg0HhPlvGtw+0TtiLZnToBkeVJty4RWEYgRAQmYGA2GTBEBETg1AYqW0NtiYZLNpQ13ZlGdTdU/38JdrSIgAj1MQAKmhwdXXROBXiHwRYxPVlAKhQv75LQKo9pq6G05jFf+wgmXa7F1oJar7XIJ7MOOWbJdbjU6XwTaRqBJwLStDVUsAiIgAmdFYC8mZty3idZgxWZg4degQeGSrntbbsA974SWlhFw4oXerESjwgEkF/zrgUa+YhGIkoAXZeNqWwREQASWIrCn/qHcKoKkWVQgATPrhIu+TbQITAt3N2ELH8/ZsMYEvGptP9zVZikCyouEgBdJq2pUBERABJYgUEapWkbR8sa0QLcYeltmkfCdcNmMrB4TLcGu1Vlp5E0SiepmjFLMtLp21ScCyyfA+8TyK1ENIiACIrAcAj4fFVUoXAysZxZU1Pg2Uda7FlvS0LIUgbblbQo9MW2rXhWLwLIISMAsC59OFgERWA6BCj56zAkXy0dFzfUYelzSyBk9JmqmorQIiEAzAQmYZhpKi4AInDmBszjDx8TL7lERMDDQfLqtCxf3M//N+UqLgAiIwGIC3uIM7YuACIhAuwg8jm3PVFCy9LisMU2NMG1TmFqbQVb3pCYuSoqACJyYgG4WJ2ajI91BQFZ2AQF6W75QQTE4hsTrARta7LZOuKzDwPtTyHkG4wfDA9qIgAiIwGkQkIA5DUgqIgIicHYE9uO+D/gULjz7XzBQr3DL1fBREaMHnXBZjzt+j2mtIiACInBGBCRgzgjXEoWVJQIicBwBi/E1TrgcwPR/pafFmLkSBoMInnGfcckgd+NcthIiIAIicIYEvDMsr+IiIAIicFICZZQCHytedsKluaCBdzCNrLkKY5dBiwiIQN8TWC4ACZjlEtT5IiACIQGfwqWCojXgGuY0Pu0yM+O+Ep3C6Np6tiIREAERWDYBCZhlI1QFItDfBChaAgZrm4RLjYhX5WMik8aHB2v72opAnAjIlm4nIAHT7SMo+0UgIgL0uMw64cLmDUO4UsTAwgTO45LWT9CHTLQRARFoDwEJmPZwVa0i0LMEJlE46IQLxUpivpMWAZ8YZZA3GWSb8udLKLWQgPZEQASWR0ACZnn8dLYI9A2BPSg9XkbRBjDnLuq0TVO4jCCn+8kiMNoVARFoHwHdcNrHVjWLQIwJnL5p+3HvL/koBR7sG+eeFfF0pm0K2RVpCRfS0CoCItBpAhIwnSau9kSgSwg8iV0X+SgGB5D8rMX8N4sAY19B6k3uR+gMzDS0iIAIiEAEBCRgIoCuJgExiC+BSXxioEKPyxE8/bwFDOYXO4CBB9LIem/GW74yn62UCIiACHSegARM55mrRRGILYEKClWLnxxDk8fFKRiD2e+4R0VX446bY2u8DBMBEegrAn0qYPpqjNVZETglgTLuna6g6BwuHjf18pbul+QhPioyKdx1RT1TkQiIgAjEgoAETCyGQUaIQDQE9uDeHfS6WIPkgh+bMwhm08hTuNy5JhrL1KoIiEAsCcTIKAmYGA2GTBGBThLYjXt/4CF5J+hnwdxiqmnkKFzGBuaylBABERCBGBKQgInhoMgkEWg3gTKK1QSSFzbaMfCsEy5pZJPQIgLxJSDLRGCOgATMHAolRKA/CJRRCAww99qfRnUyhdFwv4wdv1HB9r+uoPR9H6WpCorHKii4z8cwXTrqY+JwBaWDPHbAR/HHPko/9FF43kfx2UkUn96Dwv49KH2jjNI+trOb8UMMny+j+ICPiT9h3sf3obTdx/bRvdj+H/bivn/zFD7y5v4gr16KgAi0kkB402plhapLBEQgvgR8lChejGlYyBvAsSEkN5dRsBUUrUH1k4D3VsBebGGHWG4AMO7zMUzblRbBOTx2roVda4F1jC+wMBdZ4JIAuMyDWe/BXmlgrzYwI4yvZ7jRAO+0CN5nYN4/C5u38EpVeP+tium/+AkGH3Ftn1koWGczhVFodyNeqg4fxaAWSgHPcf94sspy1TJKs8yfmURxykfpee4/9lXs/C842aJjIiACsSHgxcYSGSICItAyAnux414fxQrDjysoHfMpXCooWtv09WjXWABQnFhDYeF2QSESxhQpjN3e2YZGDY3zWV1LV2exC7VKTS1acksLTC2E/XRF3X3Po7BKMD9JBkPkchH3r53B7O84To1QJrMK2fn0RPnY/pNJFJ7Yg+J9u7ArsWRjyhQBEegYAfdC7lhjakgERGBZBBacXMHE/T4nVE6yBxnoTSg570LokaiiutUCKYZ1lBIDnKDdxL3gfObzMKYYf68K+/kk7C0Z5EztszB5xssJOePqyqBRR471nX5Yh2PXJTD0SwkEv2kQZJMwBfbhfgPvUzT6sxbmCwwPM28P468a2K8HsE9Z4Bl29DmGFw3MjzyYnzB+mccPG3hH2Ff2F+7Xg48BmGE+9QtzubPUasJMa1gvGXrnBTAbPeCDP42nZ8k8ZF2hyKFnx3mEOAbFwz5K396H4p+Fp2ojAiLQNgJ8LbatblUsAiKwDAJ7sPPnJrH90xQpTzEcqqDgHn3MTZpAcJvlhMpJ9lwGehMso1M1WPuWUV2keIxXppG/5Brk374J+dhMuutx96Obcfv/3oyxT6QwNrEJ2bEM8h9IYfTWDHLvyiB7E8MNGeSvYbwphfzGEeQ3ZJC7LIXcpQwXpZC9cBjZ8xmfl0L+3BRGV7Ov7G/O/f+moTRyg8xPMA7FlotdWIHE2yiGPg/YZwHzCoCq5Wbx2gzbIPzjGOAciqrLZ4H3VChsXGgWOhxHProqvFLG9ucmUXzoS9j264vr1b4IiMDpEZCAOT1OKuUIKLScwGO49xcpTD7no/QMJ7qjPopzIsXD7JMBvFsszBUMqwFzgterDQzsYR5/KqCHIkDySjcRu4CmxaJ6WN8yagJyguRGbPkixdDb08i/jrxWpZFLUhgd50FKwPt0APvtADjMUDVUPOG6qF7mz+VYjqGBWWHgvZbnXD+ExH93IqcWap9DqvCRVRmlbz2M8SS0iIAInJCAd8IjOiACItASAmVsex/fcX++guL3yihOlTlBMR16UgaQfBQw7+C79tcbYKXF/LeDUF8M21QeMwAAEABJREFUjPvsivMCHGLW1wHv9zipNk2o+USKHgZOthtG6KEYwZ3fZDm4NlxcC4mdGWw9t5bWthUENmP0344gv34EuXMZkink6NHKN41LzlCk/I4H+zWD4IABZhCOJU6wsER4xBoDu2EVVsxMojTNa2dDmK2NCIjAAgLegr1478g6EYg1gTLGN0zysUAFhaMUD+4bL6FIMUj8iYF3I4DXcIoa4uTEiHtNq+HExnfvs4wPBAj2eqiW0vXPo6SQ9TLIOy/AGuZtTGP0/U2nLpl0IqlxgKKomsaWLY19xZ0jQGFz+zDyb0xhbB0FzmA6HMuFnwXyEGzhNbHbAC9QyLrP5oQGch8B7KCB9y1eT3YSO/4ftIiACMwRkICZQ6GECJw5gUkU/ohi4aUK3NeTV3wrAK4HzEoAfBftpiDUFwtDkcIX3DEDvMRyZQ+JMSdOKEpMLc4PMF43grHhYWzN1U8848hHiY8zLJupnZpBLllLaRtHAsMY25lC/toUchdnkHefzTGzwH0cQNtsb4Dq2yso2jKKh76JbRc3H1NaBE5OoDeP8n7amx1Tr0SgHQR2o5SlQHiGE8ksgw1gfpXvns+n98Q0tTfNvBctvIcHYG5zAiWNfChShpEb4kR1wQhyI8PYUjAUNU3nLTu5Fzs/Z2HnXtdpenGWXakq6DiBa5H7EK8TL8DUWl5LR5uVjAFWH0bi+z6K1UmUPtZx49SgCMSEwNyNLib2yAwRiBWBL+Nj11Oo7ONkMV1GwSZgixQIr6eRCYb6avmG2fu7AMl3OcHAsCKF/EUZjN5wNbK/Xy/U9oh2DVVRfUejoSOYurSRVtydBEYwfpDX0jkZClGDxP9vFjJMU+DYD/H6tJPY/hxivMg0EWgHAQmYdlBVnV1L4Fn8wWsr2PZXk3TTO8EyiJmH2JmrOVkMGj4EYppbE1iYF/jOeEeaE0sa+YE0Rn92BHd+1h2PKvgoTdETVG+++sr1GNekVqfRC1EKW97shMwg8G72Z5Zhbg3g8botWB/FmX0o/crcASVEoIcJeD3cN3VNBE5JgF6L5F5M3F9G8QcVlILn8TIn/cRNAbDaUKo0KrDAIYPg/5yDqYtTyCYyyDLOjzaORx37tH3eBmPT2Lpqfr/fU73V/6uQ25VGjqI5Z3j9Pj/fOwNep8lZ2E/xera8nh+bP6aUCPQeAQmY3htT9egUBMoo3VpB8dtlFGc58c9UEdxmgAvpvWA0d7L7HIvvITGSppclg9yaFMb+9ZUYf2GuREwSFGAznMjmbE8jq9d1TMam3WZkkH+Nuz6BxB8YXsCN9phm0l5b4WPPCkpH9+IPNzJDqwj0FAHd6HpqONWZpQhMYkemjMKeCgpTFRQt36f+Mctdzpt8gnF9NVWL4B882H/nJgQG9zmW9DC2lOsFzjpq94kUYMlGG7Sb3WrsKe4XAmls+U8p5DwPU+cg/PVg+mLgFnc52JVVvPQEr39bxsT/crkKItALBCRgemEU1YfjCPjY/pc+Ci/Ty2IDVPcYmAxghlBfTO3d6o+4+4du0qfXIpnB2E8PI/9J5nXlalr8jaauhNDnRg9j/Civ5VVp5N3X+B9zMsaFGhZeIQje64TMbpRiL8xrNmsrAicmIAFzYjY9cqQ/ukGh8tv0srzAR0LhT/FbeP/Kwqwx9e7bMDZHLIK/MRi63L1bTSN3IcO/Dw/1wMYgqHWzB/qiLiyfQArZn8/w8ecAvFsMTHW+RoMEbJqvF10v0NLNBLxuNl629y+BPdj5zkkU95dRCn+PxQC3G5hXW8z/BooBjpnwZ9zt29yNnO9MV2cw9tYUbn+6V8hZjL9qvi82dp/PmbdNqagIbMLon1HMJNMUM7ThRYZwNTCo8JHqpL6CHfLQpvsItF3AdB8SWRxHAo9iYr2P4gM+CofcTdfD7AMBsJ4CpelzLAgM8Bwv6t9yN+tU+KNx7mfc81+MY59aYdMkhh5v1LMZx/S7Lw0YipckwNfFRQx8meBgo0AQfgW7aMvYcU0jT7EIdAMB3uu7wUzZ2G8EnsT4+T6238/n9c9SsMyuRLDfAu+0MKvnWRhrYA5YBH/6DP7JubwxJ1LIXTqM3Efmy/R6yry60UODcWq6xp5iETgxAb5W1q7EwHsWlpj9yh6UXlqYp70ICajpUxCQgDkFIB3uHIEKJu6mWPnbCkrHjmDFSxbebYC5BOAje25Q+5Dqjw3Ml8/H1BvSyHp0ja/LYOy9N+Pmw+jLxZi+7LY6vWwCb8Adn0nXHit911Vm+EjJgz2/wsdKX0bpHS5PQQTiTEACJs6j0+O27cbEr/Jm6VdQcv+92QLBPezyzwB2gLH7US5Glq5u74sBkr/gBAtvuD9F0fILV2D8GzzY96sFnVAhBeILY21E4MwI8DX1+stQfQ0FzNxFNAj7uTIKR86sJpUWgc4SkIDpLO++bm0Pdv48vSx/XUHxZQabQPBHBDJMwbKScbjyDvoK930D3Jrhu8M08mvTGH3bCO78clhAmyUJGHhEBy0icFYELsTW5/nGwPOQfJivP7jFwKxyr9Mn8LH/7PYVRCBuBLy4GSR7eofAXpRGfGz/YBnF/RWUAg+zXwKCt7KHaxjqq5kxwN8amLvSFCwULe43LNIp5D5VL6DoNAiY3vsK9Wn0WkVaTWAYd96QRt6w3oAhXKcx87sVFGfCHW1EIEYEJGBiNBjdbMoT2PGqCgp37EHReVhe8FGsVmF3W3j38W64HnOPOlAFzLMG3sfTFCxpZAcpVn4uhew2aDlrApxdnj3rk3WiCCwiwNdmoorq7zdlJyli7OMofKQpT0kRiJSABEyk+Lu38UnsuIU3tM8w7PdRmppG9UXA7OQF5Twsr7YAk8wBXg5gvs7Un5+Hqct5Y0xStLwuhdF4u6UR/8XHhN+wcg2mNzTSikWgFQSuwdbb+Ho1BuZoo75jMB9upBWLQNQEwkkmaiPUfvwI+ChcV0ZhvDlUUPwrH8UDjN3P83+aVt/MsN7CDjHmaqYtzFNM7AISv+JufvSunDeC7EaKll/egPGe+QE59jEGa7CpYcSVGD/WSCsWgVYSSCF7zgCqo406fZSmG2nFIhAlAQmYKOmfuO3IjwTAdQbmt5oDgJsssJYxV1M1wPeZeJAC5kNJBK+iSFmRQXYDhcu709iifxpHOO1cLfjmuJ0NqG4RqBO4Glt3WIC3BYCv98EKSr9WP6RIBCIjIAETGfp4N8wL4xHeqO5ZFO63MCUDu4liJUnvymspVm7MIH/fJoz9MN496kXrGl+h7sW+qU9xI5BBLuHki7OL94X/4WIFEYiSAOepJZpXVt8TSCH/SAb58UXhAxlkczz21b4HFAsANhZWyIj+IWCQ+AK40PuKSWz/AZNaRSAyAhIwkaFXwyKwPALV8MPRtTro0g/d+7U9bUWgPQRSGL0JMKFyDuBd+DDG3S9lQ8s8AaU6R0ACpnOs1ZIItJTANchttA2fPqzxse2RljagykRgCQJH8MrrGtmrMPRsI61YBDpNQAKm08TVngi0kEAGOb6GnUPfKZnEm1tYtarqSgLtN/p6jD/nwfuOa8nAwEdhn0sriECnCfDm1+km1Z4IiEArCZwD87uN+nwU9SipAUNx2wgMY/SKRuUW5upGWrEIdJKABEwnaastEWgDgSsx+kEDa13V3PBRUuGAS0cR1Gb/EFiDqZsavZ1EsdpIKxaBThGQgOkUabUjAm0kkEJ+7rVsYda2sSlVLQIhgZ/B+BcsEP7Harr9PB8Tu8ID2ohAhwjM3fQ61J6aEYE2Eujvqmcx8KYGgQqKnFsae4pFoF0EghcaNVsE72qkFYtAJwhIwHSCstoQgQ4QuBZ3fMXCzjaaKqMw00grFoFWE/BRqhp4l6O+BDjW/M8f67mKRKB9BCRgWshWVYlA1AQyyA9QxIRmGJjkQ/jw5nBHGxFoEYHv4ONvcB4+C1ufPyyfI01dOoK7b2tRE6pGBE6LQP0CPK2yKiQCItAFBI5i+tKGmatxzmQjrVgElktgEoUHf4QjX2vU48EEaeTN9Rh/rpGnWATOgsBZneKd1Vk6SQREILYE3GRi4YUfrnRGlqGvVjsOCssj4KMwFcD8c1Ovhh6YF4eRTdR3FYlAxwlIwHQcuRoUgfYTyGB0NVsJP8jLCcf4KAUV7HT/PZzZWkXgzAiUUbAWZqhxVgJD7v+kXYReWdSPriQgAdOVwyajReDUBNLhr/TWyvHdMnXM7MXuswv1EJQxMeelqZXSVgTmCfwdSudSuByjB88amPoBC15XZjNuv6eeoUgEIiMgARMZejUsAu0nkITZ71qhgHFRczAGwSonZnwULUPgo3SsuYDSHSMQm4YmMb7KiRZ3XRyEPWhgBkzdOgvMppFv7NZzFYlAdAQkYKJjr5ZFoO0ENiH7T9PImQwnHg/e05x9OA8tbNZlMBiKnAE3cc2HbdVvYsc/W1hae71G4EmMD+5BIfS0BFhxxFC0LO6jB+87GeQGFudrXwSiJCABEyV9tS0CHSQwjNHLU3ys5ASNCwZHPhUgsDihDQnvMKpfd4KmTC9NBYXgcUzcdcLiOtA1BD6HP32187i5sT2CFdMeRYtZZD33q/Tgvc9dK7x25v730aJi2hWByAh4kbWshkVABCIlkMJHbx3BmOcmqEYw8GY4cdEhgwUL87hvzDEEH3WTHsUMHzsV+NjJhdKRJ3Dv37CA1hgTmMTEpI9CtYyCvRjffcF53ObNrQ15AFC0BFe664FiN7kJ2f85X0YpEYgXAQmYeI1HP1qjPseIQAqjg6kmL42H4IABny4dZ6OBheEBF+yqaSRvqAmbom2OfRRDkTOJ7dMVbP/GD3Cd+3bUcbUpo7UEHsVH1+9B8agffvusNib0tm3mmHkcz7nGLFMB7OwhnHeJEy0jyFG0jH2T2VpFIPYEJGBiP0QyUASiIzCMsXUpZOe8NAESD9lQ0JjTMsrCFTYmgDcIeFc+gxsPzQucAsVOgZ6cYsBHVAylmb2Y+O4T2LYJWs6IAJnu9lEIGJNpya7EwH7e3FdaWHN8RcyFnUlhamUGOTOC/MBb8B+/d3w55YhAvAnwGo+3gW23Tg2IgAicNoERbHlLJhQ0WePesTcHzpSfsPTYeEBgqFtcsCet2fCo8+TQlQMXbLKK4NJpJPbWJuKa58ClfXpyGNObU5zdg9KPvoaJe9CnC8XeG31sP+I3eVeIYsQ6hEwANtw2NoZjEcC8MojZ99TGK28yyA8ajE81yigWgW4kwHtNN5otm0VABOJGIIXcb2bosRlGLuG8Ni5k+A4/3RQOYSrjwXsO8GY5zXL1GE7dExYyLMVHVkh4sD81heBuChp6G+ZFTgUF6z7f0auh0V+CeNzCW2VxvHeFeSCfAPAebXB34zCC7KqrcNdnyFCrCLSMQNQVScBEPQJqXwT6iMBbMF4ZxuilaYwOUNx4jBlyx3lzOAM/zol4mv4Zp10YTgeSQS//nYCAtQgOplB7zJdB3gcDI5AAAAKiSURBVAwjnyDX605QXtki0DMEJGB6ZijVERHoHQIjyF3NiXhFCnkKnNrknG7y5Li0RfKzFDqHGJwrgiLHopf/OLrso1f1UP1j1/968DIYW0vhxmMs0VerOtvvBCRg+v0KUP9FoEsJZHDnuyh01jB4KeQodPLGeSB6NaTDPo4mh7H117p0yGS2CLSUgARMS3GqMhEQgX4hoH6KgAhES0ACJlr+al0EREAEREAEROAsCEjAnAU0nSIC0ROQBSIgAiLQ3wQkYPp7/NV7ERABERABEehKAhIwXTls0RstC0RABERABEQgSgISMFHSV9siIAIiIAIiIAJnRaBLBcxZ9VUniYAIiIAIiIAI9AgBCZgeGUh1QwREQAREQAROSaCHCkjA9NBgqisiIAIiIAIi0C8EJGD6ZaTVTxEQARGInoAsEIGWEZCAaRlKVSQCIiACIiACItApAhIwnSKtdkRABKInIAtEQAR6hoAETM8MpToiAiIgAiIgAv1DQAKmf8ZaPY2egCwQAREQARFoEQEJmBaBVDUiIAIiIAIiIAKdIyAB0znW0bckC0RABERABESgRwhIwPTIQKobIiACIiACItBPBDopYPqJq/oqAiIgAiIgAiLQRgISMG2Eq6pFQAREQAREYPkEVMNSBCRglqKiPBEQAREQAREQgVgTkICJ9fDIOBEQARGInoAsEIE4EpCAieOoyCYREAEREAEREIGTEpCAOSkeHRQBEYiegCwQAREQgeMJSMAcz0Q5IiACIiACIiACMScgARPzAZJ50ROQBSIgAiIgAvEjIAETvzGRRSIgAiIgAiIgAqcgIAFzCkDRH5YFIiACIiACIiACiwlIwCwmon0REAEREAEREIHYEzilgIl9D2SgCIiACIiACIhA3xH4RwAAAP//JWba2wAAAAZJREFUAwD2KOXXGI91kwAAAABJRU5ErkJggg==	storage/documents/Attribution_Thomas_DIDRICHE_20260729_15ed3f98.pdf	2026-07-29 14:31:58.2184+00	2026-07-29 14:31:58.974754+00	\N
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

\unrestrict vxvaNs008rtzV23KTPUfawrTGlpuwk1wVBllFBC6Xwy2mSz2Ne3cvmSK9bmLGux

