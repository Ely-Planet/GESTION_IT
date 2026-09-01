--
-- PostgreSQL database dump
--

\restrict uV5UAFXi4V0kktJVUlDXq9ADiUZYH8aC06jXhobkWkpaa1Hq2GPPbqSX2u5QZAh

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

COPY public.assignments (id, employee_id, hardware_item_id, assigned_at, returned_at, group_id, group_name) FROM stdin;
1d41534e-c01e-4418-9eca-f3fb2a45a2e0	67a15374-4fb2-45b7-b17b-d92803dda093	ec51bb45-a1b5-4502-a281-c124720be1cf	2026-08-27 13:34:52.775101+00	\N	\N	\N
54046f25-d640-4055-b9f0-a09c5da62228	62825a56-d294-42b1-9488-cc41ba7af2e3	477a08e2-67f4-4ed2-adc3-a6201e055ce1	2026-08-27 13:34:52.785652+00	\N	\N	\N
450e1fab-d6ad-48c5-82bf-c69d05e49c73	444e04c7-6655-4235-b260-54051ac6a617	30dbc3f5-1583-40ad-9162-55628f32288e	2026-08-27 13:34:52.799038+00	\N	\N	\N
d5007129-adce-47ce-8ec8-f4b826db2b15	353a3cb6-3af1-4d2a-88fb-414dcd089eb4	ac97c97b-e375-4359-a3f8-29f45d6bfa10	2026-08-27 13:34:52.805306+00	\N	\N	\N
89d66bad-9251-4977-ab71-66390dc36b00	ca071ca7-de86-41a1-bdd8-b1dbf0860682	dd58c0ba-ee5d-43e2-8e9e-ddc0b994aea2	2026-08-27 13:34:52.811556+00	\N	\N	\N
ae1d9a09-3ab2-4e44-bdf9-fb1c6d432c39	b879539a-de37-4fc7-9151-0c5566faad30	6d2c6d66-d430-4348-9035-28812a3bce59	2026-08-27 13:34:52.81626+00	\N	\N	\N
1e62a3b5-dc9c-4e36-bbc6-cf2d849055a6	c7e3300a-fe49-4b28-aafe-c2402982831b	fcd63b34-6e69-4605-95e3-5cbc340b4d0c	2026-08-27 13:34:52.821338+00	\N	\N	\N
3e96286a-fc05-4fba-a8e5-11e4d5f557b0	d0f3989d-81cb-48f8-afdd-e926c6d53ebe	e553bce6-9139-4290-97db-a18c8e107ae5	2026-08-27 13:34:52.825738+00	\N	\N	\N
f700cc67-f12b-411f-ad32-1575464993d6	0d15c9cd-6825-4027-9637-c4808db041ef	6f063b9c-e4e1-4ff6-bff3-3756bb4ab461	2026-08-27 13:34:52.830312+00	\N	\N	\N
8b6eaa5c-a5be-457f-b405-7bbed862000e	0b0b9e6e-7a8f-48a5-a80b-0aac21d13158	4a610262-2a5d-4e81-8d39-222ccb3d4684	2026-08-27 13:34:52.836365+00	\N	\N	\N
31a326c7-160a-4d2e-9ff3-43d710943a45	f5509f28-5d95-4659-9d72-e61ac963e824	1127ea8a-0ab2-4294-86d1-3d4858699afb	2026-08-27 13:34:52.840843+00	\N	\N	\N
6d73f409-18f1-412b-a829-59a04e970d14	ddd7b7c7-e9a5-4884-bca2-f911d16dc496	88a46cf8-22e9-4951-96e6-7fe492f66c39	2026-08-27 13:34:52.844438+00	\N	\N	\N
0e75d9e8-808c-4319-8e51-5aaf795f7ece	5027181d-b736-4199-ae12-b407eea5631d	a0e2f1a2-f00a-44b6-ad81-088aed3c59d5	2026-08-27 13:34:52.848594+00	\N	\N	\N
eb7400fc-305c-4f3a-9bf7-b435ae42cb7e	089fa072-87d5-4d87-beb9-c3d9a34b0d73	5a24c099-eea9-4da1-80af-9249a9494d57	2026-08-27 13:34:52.852039+00	\N	\N	\N
8b0f6af6-2ada-40f9-a15a-10d8cdade5b6	e143e82d-f0a6-437e-9151-76f6ca279a06	edb4a14e-7980-4d3d-aab3-5df3b3724f96	2026-08-27 13:34:52.858666+00	\N	\N	\N
07b3a7af-cf08-4afb-8bbf-33265097d2a4	a5a6872a-ebe1-4401-9e04-036f29764adf	54717f20-800a-45ff-a582-9f5881a76bc9	2026-08-27 13:34:52.863209+00	\N	\N	\N
3289acd7-e969-43cb-aed8-2ae9bee9c2d9	9065235a-5dbe-42c0-9bbb-3557592c5e2a	8101b1f3-e4cc-4620-9f1f-669f9ff5af71	2026-08-27 13:34:52.867248+00	\N	\N	\N
cde07e23-437c-4a86-a4ab-26eb4909ac65	3ee22ac9-0477-4511-86b9-0f2490ad3efd	6d8490c6-f475-49a6-ab8b-8525184d6d9f	2026-08-27 13:34:52.874889+00	\N	\N	\N
d4deb720-0ae2-45f1-ac85-68019dad0008	1758e62e-2ca5-4996-862c-7e4a016121ca	5c1a32b4-87fa-4173-89bc-2c5587c108e3	2026-08-27 13:34:52.88266+00	\N	\N	\N
dbf9a00a-9782-45e6-b810-7010f536ad76	d599617a-9ad6-4407-bf89-40ff581f9e06	e2a8b135-6b25-4af1-8b27-c4ae9112b951	2026-08-27 13:34:52.89225+00	\N	\N	\N
d3982211-0c52-4370-a2ae-b4521e257609	eebd0b93-b853-4497-81c3-417686db6d6b	1de840d2-6629-47de-9f0f-7472ad0438db	2026-08-27 13:34:52.897305+00	\N	\N	\N
95ba30db-7912-4fa2-a2a7-e336aaaef456	06add6f1-e7a4-4a8c-a6a9-e1065db303c8	8bd66d1d-9978-4642-9d6a-53b89ce8843a	2026-08-27 13:34:52.920229+00	\N	\N	\N
97200a1a-45ed-44b6-87ba-d1825b3839ed	dac6b804-7dd0-44aa-9eef-151b056591db	b53e1d9b-16dc-4fef-b9bf-767e5d0e0501	2026-08-27 13:34:52.943286+00	\N	\N	\N
c012efbd-450c-46bb-b8ee-9cd22c793648	4b1abe45-669a-4c9f-bb9e-eecbda56240d	79eee6cf-c158-4535-8793-69fea037b51c	2026-08-27 13:34:52.948018+00	\N	\N	\N
ad72863a-5d6b-4e4f-a9c6-b2c89bdf6daa	c8486efb-2791-46a7-862b-a033d4c7218d	fe6856b0-1849-4398-ae59-ad764b021ca2	2026-08-27 13:34:52.955666+00	\N	\N	\N
dd3dad0a-e2d4-40e9-9ba9-00a81b897efa	f56a985e-06ae-44b7-a5dd-a3c87dae0dee	6f748778-0842-4d84-bc3a-9b760d8723a6	2026-08-27 13:34:52.960999+00	\N	\N	\N
b791747c-cdfc-403f-8450-6c9d3006823a	5aeb030d-1a20-4162-b6ec-0912ea44547e	9d1a98ed-f64d-4f91-9aac-2376a2bbd581	2026-08-27 13:34:52.966545+00	\N	\N	\N
3ce1ff4c-ae3a-42bc-9052-c31686ae39de	3df0dec0-7d7b-42e1-be5b-3befb44ae276	037068e9-deb1-4fbe-b2ef-7f6411822549	2026-08-27 13:34:52.971413+00	\N	\N	\N
27aafd86-a742-4f0f-9675-e676db2eac5f	1b558fb2-b0dc-409d-9c82-bcebfa448a08	6d24978e-a850-4553-8495-e99363e9e188	2026-08-27 13:34:52.978181+00	\N	\N	\N
ad5f5c3b-d7be-497e-acfb-0b0e07bf97ff	6e7662ae-3bbe-4f61-8b32-dad4b1417fce	39c971e0-3bd5-4331-af5a-b4e0ef427bbf	2026-08-27 13:34:52.983729+00	\N	\N	\N
6dc9f40d-1802-4a0d-b4b9-8c5bd6a4d0b3	4efac293-84a5-40b1-b82e-044ef50720ee	522a1b49-abc5-4450-ad50-12b01a55aec0	2026-08-27 13:34:52.992153+00	\N	\N	\N
89968598-96e5-417b-b076-2aafbb68deb4	47d649ea-5c0a-40a0-8338-b3c7e0697f1d	af266de1-1b7c-4650-8b16-cd2b38c0ea6a	2026-08-27 13:34:52.997997+00	\N	\N	\N
e27bb105-9d16-4171-bfb4-f861e5a559ed	c1f31f22-5966-46e4-9487-6f6fdc24007a	eece7d3f-d56e-4372-97a2-66a1a302fc4f	2026-08-27 13:34:53.002179+00	\N	\N	\N
1262721b-c3a8-425c-93a4-294607954f48	ac51fd68-5eaa-4066-b39e-88a5a6b3034d	1d5911a4-c616-4704-b429-05ad29a83a59	2026-08-27 13:34:53.00925+00	\N	\N	\N
96e31b23-f2b7-43e6-bf54-f94a055294b1	0dce424d-c1a8-4fe4-8ec9-3ff08e35a631	43db6a8b-8ae8-4227-9972-a8821798c7aa	2026-08-27 13:34:53.013289+00	\N	\N	\N
ddc2eec0-be81-44c2-a2f6-91fc2b074c81	94946c82-3397-4a16-95d4-8937e9fdbeea	e65a99f9-f4fb-49f7-b656-9d6c4877d150	2026-08-27 13:34:53.019904+00	\N	\N	\N
2b515cd4-b788-4e00-b903-03b678770e3a	1bc9c89b-a771-442a-8921-26e105e8fb23	f14c5914-9608-4ea8-93b7-9fd1d7939093	2026-08-27 13:34:53.025944+00	\N	\N	\N
6bd505af-0742-434d-b129-ad5c823f9c8b	7c678469-22f7-465e-905e-9696f3fd9754	678b79e4-fa8c-4ec3-a082-9dc485ecf7f1	2026-08-27 13:34:53.030764+00	\N	\N	\N
a74bfe8c-eda5-443c-a1f7-03c364fa7f7a	2072bfae-71ea-4931-b9f7-b35f96aec16c	1bb95ef1-0d8a-49b2-a86f-dc17e78b29b9	2026-08-27 13:34:53.03561+00	\N	\N	\N
7d69a5ca-7fdb-4720-b716-d859bc46247d	835e058d-b2fe-4387-8c6a-2434f5a40065	2af7878e-e2b2-4481-a24f-09c2a2036f35	2026-08-27 13:34:53.044476+00	\N	\N	\N
d60960b2-195a-411c-be64-4a240e27c412	d332732c-b65e-4733-9d07-bacff5667d34	b63b79e4-2984-48b4-9e7f-5b9fc6eec3e6	2026-08-27 13:34:53.050451+00	\N	\N	\N
dbb5879e-2ba4-44d3-b699-35f4f86d7ff0	af21baf0-247d-486c-84ee-5f01f048deea	e605805d-e7a7-442c-9e2e-6eaaa0eff96c	2026-08-27 13:34:53.062174+00	\N	\N	\N
778f8e20-705b-41ee-98fe-d86013db9250	624b8afa-d057-4c18-b7f1-e165bb81895e	af1285bf-c332-42e9-9af3-3b6eab8a0a08	2026-08-27 13:34:53.070944+00	\N	\N	\N
db5c10f0-65f7-4af1-a00a-e8798f0d9a45	28cbe8e0-28d1-4d4d-9747-6ee4f3cfb79a	1c14832d-a537-4b7a-b6a0-420fbcd500e3	2026-08-27 13:34:53.07803+00	\N	\N	\N
48129e06-9a4b-4ff7-b477-ae8515ac1b56	011fd794-af58-48a7-bffd-e7c71af42a2d	a3305385-bb19-4933-9f6e-22d5f03a516f	2026-08-27 13:34:53.087037+00	\N	\N	\N
6e15ba9c-2d2b-40d9-bde1-af0337a4804b	a2f07f8e-0b1e-4ea9-aa51-30d9b0f0269b	f86cf8a2-6e34-4aee-981e-cd8e5cfde182	2026-08-27 13:34:53.094413+00	\N	\N	\N
47293e0a-3e27-48d2-9b6d-f5c2f13b32d7	c390c330-806a-4eb9-a910-1c5887fed2cc	b5f9e9b0-1f59-46e5-a2ac-4022f9e096f1	2026-08-27 13:34:53.107548+00	\N	\N	\N
ba99262f-2966-4801-b872-a2dfba7ec213	011fd794-af58-48a7-bffd-e7c71af42a2d	50aa0f87-800d-4cf1-9518-330edbb0e518	2026-08-27 13:34:53.114758+00	\N	\N	\N
deb93f84-c353-4515-abee-aa7c8a7f20aa	1bc9c89b-a771-442a-8921-26e105e8fb23	78583dc7-0c9b-4c80-bfa1-337fa7ebb00f	2026-08-27 13:34:53.121187+00	\N	\N	\N
be6c0213-904e-4510-ab7a-e50c4854d747	cdbd094b-2737-408d-8a1b-84d04221564e	24dddf52-34fb-4249-8e93-ea4d2383ea26	2026-08-27 13:34:53.134525+00	\N	\N	\N
b924d26d-43dc-4952-931d-f125a6d4abe5	379cccaa-e70b-4dd8-a6af-b8002a72c0cf	1219a818-ef0b-4898-ba13-5c86f6287f07	2026-08-27 13:34:53.140994+00	\N	\N	\N
927ee12d-47f8-4624-9a66-a553d51b1106	12b792db-ddc9-4cbe-b2b7-40a050a6aab2	4170c613-ca50-4d1b-9acf-3d818820ad97	2026-08-27 13:34:53.146028+00	\N	\N	\N
b3f8f683-0d6c-424a-b4e3-80b4a183d0c3	38b36da7-b0d1-4662-be52-b6ee57aca061	9461d053-3df0-445f-b29f-1577b218b82e	2026-08-27 13:34:53.167865+00	\N	\N	\N
945e0eeb-b04e-40d5-a04a-325991fc9b06	332e4560-d344-482f-a585-9840f287e29c	002f5e2a-5ebc-4801-b65d-302f83a5bd6c	2026-08-27 13:34:53.17983+00	\N	\N	\N
098d0661-b890-4114-b9b1-c72273599d93	b6edb5ed-b618-4d73-91f2-baab882280c5	fc2205e2-a6f2-4818-9035-3e0476267029	2026-08-27 13:34:53.20035+00	\N	\N	\N
a68817a3-3b04-434d-89b2-3747e36b7e62	d2d8d59b-d86d-4485-bd98-3086eda03728	8e8da746-0646-45d1-8fec-6b489324bdc1	2026-08-27 13:34:53.205471+00	\N	\N	\N
eb57d273-1d05-4238-82b9-727ff549918b	f924a33d-9e33-4ac2-bf9c-610260528a75	3c159178-24cf-49d0-a176-168cc7ac8e82	2026-08-27 13:34:53.214004+00	\N	\N	\N
4f22ecbe-0a31-4e2e-990c-e8039598d550	379cccaa-e70b-4dd8-a6af-b8002a72c0cf	ce4138c1-9489-4500-a1ec-493e459f41d3	2026-08-27 13:34:53.219867+00	\N	\N	\N
88440f7f-649d-448a-a85c-fc97ff82b26f	2fb8e5c5-afa8-4103-b324-f045e2fc0ed0	efcf8f14-0165-4861-9052-23d27746895e	2026-08-27 13:34:53.229904+00	\N	\N	\N
7a98ed76-4b21-4bea-82e2-2c2ec25e371d	b034df7e-e084-4199-a48b-77d2012c816d	fcd434c9-3df9-4df6-9d27-6d8a28758dcb	2026-08-27 13:34:53.237255+00	\N	\N	\N
4f44dd50-3f5b-4d1b-ac77-f91d7684015a	f97bf5d9-114d-466a-b855-d17caee3e260	00457995-5d74-42b5-947b-2d0e9740f548	2026-08-27 13:34:53.242213+00	\N	\N	\N
bd6d0a9b-a3c2-423a-9d6c-9adf6643d670	b19c168d-5d4b-4a65-983e-e9b0b7ab5105	32bb0082-e93f-4972-a53d-b2ea790ee35d	2026-08-27 13:34:53.343001+00	\N	\N	\N
f92122b4-50c0-47d4-8eae-b763dfc9b59a	55b21729-5058-4fad-b7c1-c455a5485274	3577a01d-0c99-4d80-8a2e-b5045e74eb17	2026-08-27 13:34:53.349727+00	\N	\N	\N
51302a9d-5f8b-4f52-8932-b057b5b4a5ef	b5066669-f502-40ba-a6c3-815ed0c04b1e	6e0224c9-b431-4710-89be-0703ae58c278	2026-08-27 13:34:53.365374+00	\N	\N	\N
38233687-e554-48fe-86d1-dfedcbe72aa5	533716fc-b5c3-4565-b5c9-2e520a37b4b8	b19e9411-a4bd-41e1-850c-f3f2c6700c48	2026-08-27 13:34:53.373132+00	\N	\N	\N
9132b0d8-8635-4167-9c17-a9375cf84760	9974a641-06b3-4a2a-b2be-323cc17f7a21	9eafdef3-e61a-4db7-9845-4fcc9e6992ce	2026-08-27 13:34:53.377058+00	\N	\N	\N
531a4612-0b40-47dc-9742-de4fceb1cf42	e47b7fac-fc2a-473f-a536-f3e366d83887	e33b2872-d39e-48c8-8a15-a1c603ae3755	2026-08-27 13:34:53.391882+00	\N	\N	\N
572dfa27-fc08-4871-a974-b8ae241111e0	6bd4d90a-fb4e-4ded-ad05-62efba5bb299	46f70a91-d12f-43d8-9420-12b5af5bfb13	2026-08-27 13:34:53.399033+00	\N	\N	\N
988941d9-857c-4952-b6e1-9a8292602e18	27fd1784-c0c8-4669-bba2-19a68cba8a26	8337a713-3f9a-4ac3-8849-ee1492216162	2026-08-27 13:34:53.417382+00	\N	\N	\N
120b16ba-d44b-4093-a716-f508f2d8a5ce	0a7d08d8-d7a1-4510-8a6f-dd7c6ea30f99	b6adc1cd-7875-454b-8a0e-4f4c33014566	2026-08-27 13:34:53.431232+00	\N	\N	\N
37d0a070-a03d-43fa-bc4b-66f1acdbc1bf	8bc894ba-63e8-4902-9cb2-96eb0ca1b713	516dd723-56df-43d4-b197-22ee090116fc	2026-08-27 13:34:53.444699+00	\N	\N	\N
cfe6ba57-d0f1-4cd6-9806-c7945a9c385c	f7acd69e-21af-4923-8371-a465df0e0006	e0801194-7e94-4547-8d66-8f6c2bd667eb	2026-08-27 13:34:53.450312+00	\N	\N	\N
be3671fe-375c-49b0-8f6b-b86b341ac2a0	41bc86f4-b749-436e-b2d4-6acc57903fcd	a4d4e8dd-b9a9-4055-a6b8-b9ad3f35ecac	2026-08-27 13:34:53.455946+00	\N	\N	\N
68a67f0b-1141-4aa9-b116-5b9d1a65f029	f97bf5d9-114d-466a-b855-d17caee3e260	5c8becb4-845f-451d-bb68-0979aaca1f7f	2026-08-27 13:34:53.460263+00	\N	\N	\N
7ea94e23-4f01-43d7-b8e3-feae62c26e6d	b4c59353-93b4-4b09-88b8-1c9b010a79be	143cb44d-ef7c-4a0d-b09d-435efae0be9e	2026-08-27 13:34:53.470449+00	\N	\N	\N
5412d3fa-47b7-492d-bfef-9cce253081a0	d2db7239-1ca7-49b3-bc43-86c0cb25a825	ff7ba96b-d25b-413b-a4fb-cae2d0ea9a21	2026-08-27 13:34:53.475495+00	\N	\N	\N
284fa7d7-321e-4587-9c9e-026a51d23b3d	e8ee2211-2079-4c3e-8eec-6c67f4ef71ad	8645c53b-95f9-40d1-ad0b-9be9ae13740a	2026-08-27 13:34:53.479864+00	\N	\N	\N
465d6d36-e376-48b8-b2fc-0a6c95d32fcb	c64b1a5f-f7f8-4966-b5be-57e7d35a7b9f	def9abee-b726-4bdf-a932-72b5adec9a25	2026-08-27 13:34:53.484168+00	\N	\N	\N
c7b6362a-3c63-4b5c-8d05-308a28bad1fa	c1f31f22-5966-46e4-9487-6f6fdc24007a	f35ed7a2-8cdc-44ab-b345-562144e94b10	2026-08-27 13:34:53.488368+00	\N	\N	\N
fd3d48a6-bd69-4444-a98e-f7bec9172d06	32fda97f-4cf9-485a-82be-e93ef5070597	daa845a3-7511-487e-af14-c8e35b323905	2026-08-27 13:34:53.493114+00	\N	\N	\N
42ec05a6-f6b7-42cb-a7f1-f385a8106f1a	60dd1daa-9636-4017-8182-74bc53fb122d	bdf1401b-712d-4ea2-a225-31d04b36e8fd	2026-08-27 13:34:53.499868+00	\N	\N	\N
fca365f7-6867-4a9a-807e-717192789f15	e062c123-edff-4312-8f10-26b8d1846bd5	55d32f7e-3b10-4d21-a2d3-59252245b1a4	2026-08-27 13:34:53.505945+00	\N	\N	\N
ce66e979-d965-40e5-88b9-4b4f5662fd4c	40b4e542-806e-491e-9218-e7eae5547492	60af633c-0ab1-45a7-aee6-28d40d571c8d	2026-08-27 13:34:53.510194+00	\N	\N	\N
a9fb825a-567d-449b-939e-b8da84d3648f	093bf052-2c9e-4c20-bf8e-6c218eca2a55	31191980-0dcd-4582-ad84-715326f8014f	2026-08-27 13:34:53.519415+00	\N	\N	\N
81fd4ee4-2911-4acb-87d3-278e0026b45e	79d59a7e-d32c-4723-a9e3-80a370d4ed60	d69da791-bfc6-4fc5-865b-5199fba7f1e1	2026-08-27 13:34:53.530147+00	\N	\N	\N
f17671ee-e106-448b-8eb5-e841fc63a050	56b096de-5526-435e-8ad6-183e9e9c7d84	42610d67-e0b2-4acc-b6e6-726a9680930c	2026-08-27 13:34:53.535778+00	\N	\N	\N
5dd518bb-9e21-4e0e-98ce-b31091006bf4	62d06322-8057-4756-9750-fb595d22f5e8	51dd2ab7-d2fb-487d-ac43-4645752170a4	2026-08-27 13:34:53.550302+00	\N	\N	\N
9ee53213-37fa-4823-99f0-2c087c0570c8	8f444a89-57da-4701-a844-496667163785	9134feee-bfab-49ba-9e2a-3fdfcc7ce99a	2026-08-27 13:34:53.556481+00	\N	\N	\N
bdc10a77-a3e2-4be2-a55d-05649926ac5d	17b27cd2-575d-4d51-b91c-00c52aa7d060	58bbc3cf-3b06-481b-ba46-9e7fa81df80d	2026-08-27 13:34:53.562396+00	\N	\N	\N
6984ae42-32ba-4770-9d50-b9cf5a5e3bde	a0c0e609-3488-482f-b518-cf726119cd3d	ff8f3f58-9541-4fb8-a452-1a8f488cd897	2026-08-27 13:34:53.569004+00	\N	\N	\N
3c514374-6c9d-4947-8cb7-8d47c71443af	56cec5e0-aee5-4f42-b08c-02c0f743453a	34707b2e-f021-4532-8a02-707af3f75b5b	2026-08-27 13:34:53.576536+00	\N	\N	\N
8962c5cd-1afa-434e-bfad-66c71f808c88	835e058d-b2fe-4387-8c6a-2434f5a40065	2332c644-63a5-493c-9085-3072d27fb2e8	2026-08-27 13:34:53.581755+00	\N	\N	\N
9df30e3c-529d-4312-abb6-309d58f6d738	6e5256c5-869a-42a3-b1bd-f316c085dec9	320305cd-317b-4514-bc3d-ef0513519072	2026-08-27 13:34:53.586788+00	\N	\N	\N
2ba74d4c-9c86-42da-bb88-e20f3d41745a	a45742a5-894a-4a32-83b8-0b3cf7cfb970	65e3c11a-63d3-4de2-8015-34641eb2449d	2026-08-27 13:34:53.591617+00	\N	\N	\N
4f639dce-ba11-48c0-a591-b4ac8f0c0fe8	85cc63ff-7df5-4fe8-ae5b-96f55bd68811	d20f53f2-0732-4a87-93ef-198426e5ceb7	2026-08-27 13:34:53.598764+00	\N	\N	\N
bbffd3c6-2fa6-4552-b625-63c43a5dd731	fed7ae60-6b89-49c2-b2eb-a472b1789ca0	b1b790c0-3575-4962-a78d-2f9ff5ca0f50	2026-08-27 13:34:53.603606+00	\N	\N	\N
af8938ed-97e6-4393-936d-972ce51481fc	7a0824ae-2296-44d5-8e32-669745de4c12	54e31116-b850-4e93-a223-9e37e45e6c10	2026-08-27 13:34:53.609132+00	\N	\N	\N
d9268d5c-6f89-4309-98e3-6558e71bcaea	7b830831-6b84-4f8c-b6b2-bed2e07c2502	13f1b5ee-a856-4976-9f6e-8a778d91895e	2026-08-27 13:34:53.619863+00	\N	\N	\N
7b84c918-f9e0-4e79-8bdf-bcf996735a0c	f3b2032f-00f9-43fb-951f-4e9596848dc3	a7f14800-6acb-43c3-89b1-588908ee1d4d	2026-08-27 13:34:53.642165+00	\N	\N	\N
49b4219c-a439-4436-9094-399d0d013b97	9974a641-06b3-4a2a-b2be-323cc17f7a21	9be269a5-41d6-4743-b727-3dcb3a5de764	2026-08-27 13:34:53.647372+00	\N	\N	\N
ad30b663-6d0f-4c9c-a78f-4ca6ce5d85b0	af477549-4032-4bc5-a340-ef63921d1a65	2e889df1-9268-4d06-b700-689a7c7e48b4	2026-08-27 13:34:53.653016+00	\N	\N	\N
cb8e83a3-e9ad-4eac-8648-fa5919a91814	d76138d8-2d01-45a2-a025-bde2ea8f3819	6b33507b-4a3e-4bc7-a66d-906be4df5722	2026-08-27 13:34:53.657875+00	\N	\N	\N
46439698-851b-44fc-b0d9-557545a79bde	df94363a-8e80-45ce-a78a-e91ea33fb6ee	34464df0-afcb-48d2-ab3b-fc2af7f93636	2026-08-27 13:34:53.662216+00	\N	\N	\N
3e7836ed-db1c-4b87-8844-9f7ec7374f0c	bafcbdde-b731-4ed8-a334-2202d4cf4d98	2245c41c-f393-45d6-9ab0-325231c89370	2026-08-27 13:34:53.666799+00	\N	\N	\N
f1596574-4d0a-4629-8a2d-ede08a1f999a	04c017aa-66e4-4d34-a1af-634088e37b9d	f147b454-3547-4867-8047-b2ba0c19f7ce	2026-08-27 13:34:53.690601+00	\N	\N	\N
7d7a6294-aeb1-4c17-8ad0-2e9040282011	0a7d08d8-d7a1-4510-8a6f-dd7c6ea30f99	66787249-6176-48f7-a721-1efdd217b5a2	2026-08-27 13:34:53.702245+00	\N	\N	\N
d9eaea05-a735-4b58-ba97-11dec04fc61b	f9e5949c-1359-4820-928e-2bb57723ccd5	88087761-37b8-4b5e-a28a-2cab423a40e1	2026-08-27 13:34:53.71123+00	\N	\N	\N
89b0b15e-34bf-45c9-9d1d-7b420e3c7140	3ee22ac9-0477-4511-86b9-0f2490ad3efd	f1f2e731-adf7-4cec-b5e6-312a09eb5307	2026-08-27 13:34:53.717319+00	\N	\N	\N
78b609d2-a62d-4493-8ca6-7b82622072c6	ac93458f-7a43-45a1-b163-67f5769e55f8	a7c516d4-bb58-420d-9ff7-3e85a4c7286e	2026-08-27 13:34:53.723766+00	\N	\N	\N
22ef8681-dc81-476d-ae17-3e42f340261f	1d64afa0-46c7-4add-9402-f81fe8c9db9b	5f89463c-d26d-4e63-9f21-76f4ee33f07f	2026-08-27 13:34:53.729888+00	\N	\N	\N
f92ccac0-ecd5-4745-9bee-2421585b3dad	6a300cbe-f185-4dea-833c-3e73e3278d14	1881b9ec-f2ea-44f0-8a5b-005b93555383	2026-08-27 13:34:53.734612+00	\N	\N	\N
76a3d0a8-c801-4ede-826f-fc3156a57f06	125ed49d-4a83-46f1-a3f4-abd1380b639f	33541b62-4d5a-4922-a706-8ad5612d89fa	2026-08-27 13:34:53.739905+00	\N	\N	\N
bcdfa6e1-b673-4c64-b3d5-64b8270064c6	690d99b6-c9bd-4fa6-bb8e-5c28874e0762	401dceaa-05e5-4ba1-96e9-bd39de241a78	2026-08-27 13:34:53.743899+00	\N	\N	\N
1317ae3e-9529-4681-9b7f-84c8c89b6cdc	2b67753a-e872-408d-a2a6-b1e970334a2b	b9a9f710-b4a8-4772-ad54-d407d377144a	2026-08-27 13:34:53.748091+00	\N	\N	\N
fd6999ab-1e8c-4cdb-b1e3-a87f6dd957a6	c8486efb-2791-46a7-862b-a033d4c7218d	f78a8520-629e-4bf9-b864-357108320be3	2026-08-27 13:34:53.754025+00	\N	\N	\N
ff8452ff-3a5d-4110-b25e-4fa7a78daa18	ac55a2c1-d471-4e28-9e74-bd89845f2904	ecab88aa-b8b4-410c-8dfb-9b386f97ef0b	2026-08-27 13:34:53.758571+00	\N	\N	\N
16d30e6d-100f-4303-88cf-d8cf6939da84	b425a749-eddf-4991-951b-045fae50c701	640736ff-5468-4a75-97de-2da70bc803f3	2026-08-27 13:34:53.768146+00	\N	\N	\N
90b3b8ce-98b3-44aa-aeff-a99d0c5f5464	8b1a90a9-1974-48a0-abfd-06cc552fade5	0ce67e89-0384-4f12-a98d-ce64ce41a306	2026-08-27 13:34:53.774756+00	\N	\N	\N
08c14ed8-cafe-4281-ba1c-3f035723a1a1	101b53e9-b554-478a-9e95-3a2c2d44c9f1	93a664d8-97e1-452e-8a4a-d438b4cdb461	2026-08-27 13:34:53.786383+00	\N	\N	\N
0ecfed38-1e6a-4464-81de-ca73cebbf231	4759c448-dd61-400c-b21f-f0864cf40f9a	32bf73cd-7aca-4ef9-a653-3d4717fb134c	2026-08-27 13:34:53.790878+00	\N	\N	\N
a91bd6ed-2b04-45bf-9fca-b68c900c6afc	36fd2e0f-5bcb-4022-aa08-f1cdaed0ecbe	05453c21-2298-435e-b9f4-6abb052fff50	2026-08-27 13:34:53.79668+00	\N	\N	\N
4eea154b-5e2b-4232-89bc-76ccbf25e968	9c8b043d-a01c-4089-af23-294d15b8b655	46c35970-2a38-4d0a-8b9b-a3c8efd1811a	2026-08-27 13:34:53.802952+00	\N	\N	\N
103fa452-5f2b-4e40-ab4d-e37ed56b34b4	b651b723-1d84-4f6b-b59e-62ded0251782	5532b069-c6c7-41a4-b113-0a5cda517633	2026-08-27 13:34:53.807996+00	\N	\N	\N
c58292ba-43d0-4d8b-93da-d35b6d1762cf	d72ad9ae-253e-4a5f-9fb0-5478cf511525	f80b1d8d-9889-4071-8def-1b064133395b	2026-08-27 13:34:53.813131+00	\N	\N	\N
8e87bbda-17ce-43b5-972b-12c5efbd3f16	ac1e61ff-8759-467b-b90f-07705b747949	60f697cd-70f9-41fd-9057-037a2d9cb85d	2026-08-27 13:34:53.855532+00	\N	\N	\N
82ad8211-8802-4cbe-b454-b9746744ae86	5027181d-b736-4199-ae12-b407eea5631d	44a2b8b4-f347-4e6d-b203-710bc54530c7	2026-08-27 13:34:53.865707+00	\N	\N	\N
9c961f33-4425-4603-8b64-78999e122bb0	7c165005-a800-432f-b1fe-0b613e7ae8d6	11ba9471-b5d3-40be-966b-14cd08383bc7	2026-08-27 13:34:53.883322+00	\N	\N	\N
8dd8e6a6-9da4-4dc0-a1fe-dc7796d05029	304ad137-6619-4dde-8e30-d2533d7ad1c7	271e7b6b-c778-4fbd-95b4-87b32ef48237	2026-08-27 13:34:53.902894+00	\N	\N	\N
764660f7-a1a7-48eb-bd7a-087cd57b172c	12f03f63-55d3-4301-a7f9-e522fee49feb	8aea5165-c34e-4678-8342-db8dd03fc5b1	2026-08-27 13:34:53.910512+00	\N	\N	\N
e00a8833-3f03-4a0a-a8ac-a90c2ac73efc	000945e1-51d6-45d4-bdf2-91a65126cfc9	acdc08f6-9f1f-41b2-bc2f-081a3f75dfe3	2026-08-27 13:34:53.921242+00	\N	\N	\N
9baeedb0-4827-4602-aa4c-a8216399c30e	48060b50-0791-4e4e-ac10-b67e84b373ad	245140ec-b622-4764-a504-dac09b233ba5	2026-08-27 13:34:53.939759+00	\N	\N	\N
8d596bf2-3196-40dc-b29a-fb204d0b89a3	aac653bf-37ba-4cc1-b91e-220b8be7c496	56ad9ab8-c2ae-4272-ae22-60fd206b27c1	2026-08-27 13:34:53.954303+00	\N	\N	\N
76ca5a4a-2f48-4cb7-b493-80116482391d	743c37c3-f9a6-4596-9bc8-de61ed772a9b	79a5c594-0ec3-4307-be00-d237235bf88a	2026-08-27 13:34:53.96365+00	\N	\N	\N
1bd456b4-5323-4acd-a23b-9646923919ad	fa8430fb-b1ad-4515-9cc4-f9ebeaec8581	4b9bd32c-4879-4e7d-9554-b610b119de9d	2026-08-27 13:34:53.972861+00	\N	\N	\N
8bdbd407-27fc-40b5-8003-aaae6b55049a	ce5c22dd-4ad4-406e-8cba-e2367519bdd6	4b8a4316-a387-4c08-a375-16e282b6c1ea	2026-08-27 13:34:53.981422+00	\N	\N	\N
7b13a903-f45e-4d4d-ad04-c66e0fc22f36	f2cb2c15-2ec4-46e7-af22-329e368bb83b	1f4f7815-5780-4e28-9d4f-c26b47b041e7	2026-08-27 13:34:53.99156+00	\N	\N	\N
7aca86a8-1d77-43d8-a133-318c84a531a2	093bf052-2c9e-4c20-bf8e-6c218eca2a55	d7feb6a1-8c20-437e-b3c3-6279300efdec	2026-08-27 13:34:54.00542+00	\N	\N	\N
af357312-ce89-4904-9fff-05c7d1ea2dc0	\N	4a95adbf-48b4-4c1b-8ca9-d89d401c670f	2026-08-27 13:34:54.100091+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
8edacdda-d8ab-4a30-b1c7-e0207909c8f4	\N	5f6189b9-2d15-4e37-8ca1-1add87fa4bd9	2026-08-27 13:34:54.110147+00	\N	\N	🏢 Pole Comptabilite Syndic - Membres
7bb086c0-c197-4716-8033-98fdf0b607a0	\N	aee1488d-8595-4d20-a339-bb6062cb8ccd	2026-08-27 13:34:54.11666+00	\N	\N	🏢 Pole Sinistre - Membres
2bc9a89c-d035-4e94-889a-395e93f5e716	f3b2032f-00f9-43fb-951f-4e9596848dc3	2eb60f2f-b602-467a-a632-60018ef6f76f	2026-08-27 13:34:54.124904+00	\N	\N	\N
17aaba4e-751d-495e-bf8e-e2933b221eb5	\N	9c836810-6026-4f9d-acdb-52bebf345f82	2026-08-27 13:34:54.130975+00	\N	\N	🏢 Pole Syndic - Membres
f73c1508-c8b0-444b-867b-297f6c4fff20	8f444a89-57da-4701-a844-496667163785	78a4baf2-9ba0-4261-89bd-b086139288ec	2026-08-27 13:34:54.149865+00	\N	\N	\N
e475669a-1828-4f5b-a474-f5467f02d6d0	7c165005-a800-432f-b1fe-0b613e7ae8d6	29e4c2a2-6c7a-4f1c-999d-af679646ba85	2026-08-27 13:34:54.156286+00	\N	\N	\N
9ede1835-ecec-4150-b373-2f28f714a54c	d332732c-b65e-4733-9d07-bacff5667d34	674718a5-74c0-422e-9117-c1ba1622591e	2026-08-27 13:34:54.159866+00	\N	\N	\N
64edbf94-af9d-4b8a-9c0e-9e9e424ca72b	624b8afa-d057-4c18-b7f1-e165bb81895e	863bab11-442e-4180-8d59-d5a2f07a5942	2026-08-27 13:34:54.163896+00	\N	\N	\N
c7b4ccd1-a763-4a10-991b-092bcabcc1aa	f7acd69e-21af-4923-8371-a465df0e0006	d44c88f9-27e9-46b0-b419-e62d5f256702	2026-08-27 13:34:54.169347+00	\N	\N	\N
238926b0-e6ab-4daa-b898-b631b94c5014	62d06322-8057-4756-9750-fb595d22f5e8	7d967657-7e3e-4bac-8b54-f14a4df8c46d	2026-08-27 13:34:54.175043+00	\N	\N	\N
c9c0292f-caa3-47b5-b9f2-7f7c34487a1c	\N	eb634718-dfef-4fd4-9a1e-55b7a389ebcf	2026-08-27 13:34:54.182115+00	\N	\N	🏢 Pole Gestion - Membres
e422fc51-b179-4332-b4a2-db784f233bf7	0d15c9cd-6825-4027-9637-c4808db041ef	1e6c0dd0-2c22-4e25-98a1-88eeabe577e8	2026-08-27 13:34:54.187138+00	\N	\N	\N
754d604a-c0f9-4bd6-ad88-f1127acbcd3f	0b0b9e6e-7a8f-48a5-a80b-0aac21d13158	ae879cf9-8457-4209-9f6f-42701968fbce	2026-08-27 13:34:54.194108+00	\N	\N	\N
533531dc-9a1e-4f58-a06b-95f07c0393ef	a2f07f8e-0b1e-4ea9-aa51-30d9b0f0269b	d1018d75-0da4-4d25-aa2f-1ddfa9a66051	2026-08-27 13:34:54.19966+00	\N	\N	\N
b9120732-8a33-4f4a-a2a9-ed37267407d5	\N	f80e365d-b76e-4e2f-8560-ece799aa4d0f	2026-08-27 13:34:54.20391+00	\N	\N	🏢 Pole Gestion - Membres
f4ea0add-5bb3-4ae5-baf3-a9cb6bd24493	\N	8dcb2885-3e74-4c4f-b3b0-3241dbc0cb43	2026-08-27 13:34:54.208184+00	\N	\N	🏢 Pole Transaction - Membres
95d6f2ff-433c-4bf8-b87b-47bc660cc49e	6bd4d90a-fb4e-4ded-ad05-62efba5bb299	c8f27913-d90a-412a-ba7a-85875dab9d69	2026-08-27 13:34:54.2136+00	\N	\N	\N
8809c385-8068-4fe0-a876-46b8f0d05faa	85cc63ff-7df5-4fe8-ae5b-96f55bd68811	8e09d9b2-1a17-420c-8e43-7473e83dbe72	2026-08-27 13:34:54.21928+00	\N	\N	\N
e412c2f9-6a42-4551-8978-540ae827fb7b	7b830831-6b84-4f8c-b6b2-bed2e07c2502	79e5466d-8771-4719-8c93-805ff47690e4	2026-08-27 13:34:54.223898+00	\N	\N	\N
335ad25a-d70c-473a-a449-d6430d003f5c	47d649ea-5c0a-40a0-8338-b3c7e0697f1d	d4febde3-7b0a-4634-b160-41a50bac29b5	2026-08-27 13:34:54.237671+00	\N	\N	\N
ef889f36-c575-4afe-b988-1a7a02add77a	2072bfae-71ea-4931-b9f7-b35f96aec16c	0e00b371-9a6b-4dda-86e6-70b7173a93c6	2026-08-27 13:34:54.267117+00	\N	\N	\N
d36a0c8c-0dc9-4cf4-8941-27269d1ca0db	093bf052-2c9e-4c20-bf8e-6c218eca2a55	04e6391b-35a3-4c2e-a405-a46d56513493	2026-08-27 13:34:54.277921+00	\N	\N	\N
d7ad4e75-dfad-499e-ac01-526c661aa82c	093bf052-2c9e-4c20-bf8e-6c218eca2a55	509d6068-210e-42a9-985c-404b20564105	2026-08-27 13:34:54.286928+00	\N	\N	\N
13db7683-7e84-4f98-a8c0-5ecf69b85bcc	8a3cae01-f152-423d-9a56-31a4fbcda459	d2112566-71a4-42e0-a7c7-fa0c476e581b	2026-08-27 13:34:54.302788+00	\N	\N	\N
d7d4268c-c7e0-4788-ae24-5645a5911134	8a3cae01-f152-423d-9a56-31a4fbcda459	951c8cb3-44a0-4a53-9ee6-c0f593f713bd	2026-08-27 13:34:54.312289+00	\N	\N	\N
3c8f9388-94c7-4624-9ecb-3251be6b22f8	\N	a3819038-14a8-4b5f-85a1-2e7e181c3a09	2026-08-27 13:34:54.321549+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
bd8c0f3f-2160-4258-9413-15e33fc305b4	ddd7b7c7-e9a5-4884-bca2-f911d16dc496	b0b49c3d-4ac7-4e83-82e3-732c1501e08d	2026-08-27 13:34:54.338144+00	\N	\N	\N
3bd42ac6-0059-4098-bb0b-515ff1071d46	\N	a9fd3f37-129e-4a44-82ad-43eb29419068	2026-08-27 13:34:54.350623+00	\N	\N	🏢 Pole Neuf - Membres
77462c49-768a-4e73-a12c-21e1484a3a90	9065235a-5dbe-42c0-9bbb-3557592c5e2a	fd3e8ac2-aab5-42be-a43d-d1ce5bd9824a	2026-08-27 13:34:54.362942+00	\N	\N	\N
2d08128e-50d2-4ed4-8a87-01f75fa1b3e3	ac55a2c1-d471-4e28-9e74-bd89845f2904	d1455b42-a3bf-4503-b3c5-8a64c447d763	2026-08-27 13:34:54.372136+00	\N	\N	\N
d92c881f-bf11-4a8e-89f4-8e500a2430c8	62d06322-8057-4756-9750-fb595d22f5e8	935fa874-4203-44b7-9084-ae3962fb0aea	2026-08-27 13:34:54.382107+00	\N	\N	\N
d69fe635-f0ea-493f-9108-74a45674d80a	\N	4d87c94b-6a18-42a3-b936-84846fceba68	2026-08-27 13:34:54.398479+00	\N	\N	🏢 Pole Syndic - Membres
a70dfa74-b4c7-48e3-ab04-1fe22ab9cd49	40b4e542-806e-491e-9218-e7eae5547492	24aa8bec-6ffc-4a7f-9029-6f564333eaa7	2026-08-27 13:34:54.41266+00	\N	\N	\N
f034f219-d579-4620-86fd-87e7793eb598	3ee22ac9-0477-4511-86b9-0f2490ad3efd	19eb9940-44aa-4f30-aee4-f6b1be10e2ba	2026-08-27 13:34:54.42268+00	\N	\N	\N
a16a29b8-9db2-4dbd-b98d-186444f924e1	dac6b804-7dd0-44aa-9eef-151b056591db	07eba368-54f6-4c37-b37a-7860f19bce50	2026-08-27 13:34:54.441038+00	\N	\N	\N
af68cd57-2e48-420a-9bec-39a4a49a30db	f56a985e-06ae-44b7-a5dd-a3c87dae0dee	4434303d-4b54-422b-9044-0813c8ef4257	2026-08-27 13:34:54.449371+00	\N	\N	\N
5f180a4f-d901-4322-a248-793199b82209	2072bfae-71ea-4931-b9f7-b35f96aec16c	d1aed294-0b36-423c-bd6a-fbaea1e6a839	2026-08-27 13:34:54.459463+00	\N	\N	\N
722cbf83-572a-434f-9fbc-3e772791861c	27fd1784-c0c8-4669-bba2-19a68cba8a26	3598c520-0833-429a-817b-fa5c57f15e15	2026-08-27 13:34:54.472124+00	\N	\N	\N
5d9d5ca5-def6-4cca-8caf-68ec7d0f8dce	0d15c9cd-6825-4027-9637-c4808db041ef	a6b3b21e-397b-4cf6-8e14-fbdb5fc77bc9	2026-08-27 13:34:54.482832+00	\N	\N	\N
0fd8d575-1231-477d-b5d8-f0a2f909671f	0d15c9cd-6825-4027-9637-c4808db041ef	5c242866-771f-41ba-a8cc-7dcae3998473	2026-08-27 13:34:54.491627+00	\N	\N	\N
a0bc4015-4c0a-480c-ae4b-e3b93304197a	3df0dec0-7d7b-42e1-be5b-3befb44ae276	e4f4d5ef-78bb-4a7d-808f-45315f9050d7	2026-08-27 13:34:54.499234+00	\N	\N	\N
3cd1b0e0-efc1-443f-b1de-f58ebd228ab4	1758e62e-2ca5-4996-862c-7e4a016121ca	9245acb8-e07a-4fbb-9755-0314b8b790ee	2026-08-27 13:34:54.514232+00	\N	\N	\N
c45421eb-b063-453a-89d0-be859b306ac4	4efac293-84a5-40b1-b82e-044ef50720ee	5e78e97a-263b-4c37-830c-f5ef536a197e	2026-08-27 13:34:54.526864+00	\N	\N	\N
49fd3386-bf10-40c2-af2f-222df0c27a5a	\N	8979dcc5-421d-45b0-b49d-8eb3df20cd3b	2026-08-27 13:34:54.534478+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
cec0e07f-32e6-434c-a1dd-c01b68249111	101b53e9-b554-478a-9e95-3a2c2d44c9f1	92cbeb8f-2d44-4e4d-a20a-52e98919e445	2026-08-27 13:34:54.543867+00	\N	\N	\N
6454aa6a-f3d6-440d-851c-c539bfa77121	\N	74737132-e94b-4e3e-8a3a-b058cd68451c	2026-08-27 13:34:54.554327+00	\N	\N	🏢 Service RH - Membres
ff593e13-425a-476e-8fde-0871bec01016	\N	e92b4eb6-7389-4895-9050-1bdfc6eac32b	2026-08-27 13:34:54.562312+00	\N	\N	🏢 Pole Service Relation clients - Membres
51fd4bef-da83-4475-9c4d-fab9b82d16af	57ad174b-600a-4156-ad48-e8ea11a03e15	baed4aee-f7da-489b-9463-60eec69fc1c5	2026-08-27 13:34:54.569543+00	\N	\N	\N
e4371790-3a01-40c4-ad15-bf1e0bfb0f0b	5027181d-b736-4199-ae12-b407eea5631d	3284008d-f1b8-43d1-8c30-b7050f816d30	2026-08-27 13:34:54.578926+00	\N	\N	\N
c11d58ea-e245-4544-8876-3a1f7e32c9eb	1bc9c89b-a771-442a-8921-26e105e8fb23	2f3772fb-9e0f-438c-9fc6-e58909356b9a	2026-08-27 13:34:54.594613+00	\N	\N	\N
f42cdaf9-5c6d-4f44-8343-0c14b1e7e324	55b21729-5058-4fad-b7c1-c455a5485274	4a78698d-507b-4d2c-9bdc-d4cc27b2b8fd	2026-08-27 13:34:54.604653+00	\N	\N	\N
ea41246c-15b7-4e0c-b25d-69bc36cb19e3	\N	c5ff4ccf-e849-4dc7-bc2a-26933747f9fe	2026-08-27 13:34:54.619755+00	\N	\N	🏢 Pole Sinistre - Membres
d6414230-91ae-4c92-b9fc-80d2de6e9975	55b21729-5058-4fad-b7c1-c455a5485274	79fd1701-f1fc-4f81-b60e-afc295f36434	2026-08-27 13:34:54.628918+00	\N	\N	\N
61f8564c-1aae-43da-b3fc-ccb7af4788a4	8a3cae01-f152-423d-9a56-31a4fbcda459	3624950e-f50e-484f-8f4f-ee7c960d41cc	2026-08-27 13:34:54.64572+00	\N	\N	\N
7ce4aca8-dc74-404d-8027-2569704342c7	55b21729-5058-4fad-b7c1-c455a5485274	87947e22-6aaa-49da-9a90-30133566785b	2026-08-27 13:34:54.66402+00	\N	\N	\N
25b13a60-d191-47ab-828c-c8bb93e07948	\N	2f5e39c4-1128-42e3-b034-b8103d2cca6a	2026-08-27 13:34:54.673053+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
87e3fbbf-b38b-4c31-aea6-edb3c099267e	a5a6872a-ebe1-4401-9e04-036f29764adf	a08142f1-1cfb-477d-b441-9b8616a3af3a	2026-08-27 13:34:54.680589+00	\N	\N	\N
c9143014-7505-496e-a690-843e8c7c71a4	56cec5e0-aee5-4f42-b08c-02c0f743453a	2036aef6-ec06-46e7-a6f0-75fcb1c6e818	2026-08-27 13:34:54.693638+00	\N	\N	\N
4a9da109-df6c-4d76-9dab-70b39feff572	cdbd094b-2737-408d-8a1b-84d04221564e	980ef897-fa0b-4be3-b874-16edbf7d75a3	2026-08-27 13:34:54.7098+00	\N	\N	\N
3ed16ba5-30c7-41e0-ad15-dffb68537c14	\N	03d2b293-b006-4c00-a4ae-eec5451fd1b4	2026-08-27 13:34:54.721042+00	\N	\N	🏢 Pole Développement CGP - Membres
4a36bbde-82e1-46f8-9689-63de4abec0a3	743c37c3-f9a6-4596-9bc8-de61ed772a9b	01a08073-4e07-4ab0-b6c8-ba13c3d22941	2026-08-27 13:34:54.726981+00	\N	\N	\N
b0d43f23-9e32-47e4-9b08-4c09100d18f1	a0c0e609-3488-482f-b518-cf726119cd3d	dc0aa447-2b41-4c8b-94ac-c87e43389198	2026-08-27 13:34:54.733841+00	\N	\N	\N
e690fa27-294a-4ab6-ba11-fcc141ecc66b	e143e82d-f0a6-437e-9151-76f6ca279a06	93f29670-b0e4-44cf-97d3-fd9a7846d22f	2026-08-27 13:34:54.742206+00	\N	\N	\N
3484f091-2dd6-4c2b-aab9-f36d6e8e1095	e8ee2211-2079-4c3e-8eec-6c67f4ef71ad	187e3543-6c3a-455c-8339-1d9e73d0d94f	2026-08-27 13:34:54.750237+00	\N	\N	\N
58827bbf-9776-41db-ae6d-5db29a42e53a	114f8ba5-5564-42c4-9034-2e01a493c713	34a95d0f-5435-4e3f-a385-99edb332fce9	2026-08-27 13:34:54.774663+00	\N	\N	\N
cd51c769-12b6-46e1-8b4b-700c28e0222e	a45742a5-894a-4a32-83b8-0b3cf7cfb970	008ac231-5627-4e54-b12a-47827dffd7a1	2026-08-27 13:34:54.782739+00	\N	\N	\N
1906319b-0010-485f-a5fd-2dc064729219	c7e3300a-fe49-4b28-aafe-c2402982831b	b20948cd-d72d-4065-9913-897e796d3ae1	2026-08-27 13:34:54.796911+00	\N	\N	\N
3980d777-e40c-4bec-b839-53cd70b3bfbe	2072bfae-71ea-4931-b9f7-b35f96aec16c	1abdd7a8-d9be-43a7-b4cd-7aea2fba309c	2026-08-27 13:34:54.805797+00	\N	\N	\N
d7c5f0c3-32cd-4ccc-adc7-179c94e10db9	af477549-4032-4bc5-a340-ef63921d1a65	91e7f108-71d4-4caa-9015-469a3c3e6e27	2026-08-27 13:34:54.83319+00	\N	\N	\N
cb0d7ee9-271b-46f4-a070-84274525b1c8	aac653bf-37ba-4cc1-b91e-220b8be7c496	a20634d9-0c2e-4f5c-9d97-2afcfd4ee650	2026-08-27 13:34:54.845815+00	\N	\N	\N
a2f9b96b-f75d-4385-a8a5-e63bc7e9cc18	690d99b6-c9bd-4fa6-bb8e-5c28874e0762	d2e72601-75ef-4002-8cdd-d91f6e9d4a35	2026-08-27 13:34:54.854257+00	\N	\N	\N
f21e4776-0191-4d40-a652-79a57f11520c	690d99b6-c9bd-4fa6-bb8e-5c28874e0762	a6ab197a-f086-4f94-8830-54bdb6e7213d	2026-08-27 13:34:54.866379+00	\N	\N	\N
52ca0338-dbaf-4e7b-b0aa-7fbfbd5c6fa4	624b8afa-d057-4c18-b7f1-e165bb81895e	27189046-9186-4554-9d85-27b7c2627e1b	2026-08-27 13:34:54.875314+00	\N	\N	\N
742374af-ac92-445c-bb98-75fc0033e7c9	6e7662ae-3bbe-4f61-8b32-dad4b1417fce	d725fa27-9ca4-412b-bba1-55f09200ffd5	2026-08-27 13:34:54.882916+00	\N	\N	\N
92e413d2-25e7-416c-b67d-f9530093db7b	2fb8e5c5-afa8-4103-b324-f045e2fc0ed0	b4b63cc6-3698-47b7-91cb-74dce5a7e9ef	2026-08-27 13:34:54.893032+00	\N	\N	\N
2a85a195-2180-463f-8626-95515ab5d64b	\N	5fe7acfc-5077-4142-88a7-c652eefe13bd	2026-08-27 13:34:54.912081+00	\N	\N	🏢 Pole Service Relation clients - Membres
32d88a49-09d9-456a-a1b5-f3b41b55c3ec	df94363a-8e80-45ce-a78a-e91ea33fb6ee	86100b61-3891-477c-a880-28f083e723c5	2026-08-27 13:34:54.923603+00	\N	\N	\N
58181cdc-6031-4e14-a338-558d94d9d710	12b792db-ddc9-4cbe-b2b7-40a050a6aab2	2509e0eb-5a27-4287-ab58-7ca9aeec9d92	2026-08-27 13:34:54.932002+00	\N	\N	\N
78fd20d7-dfc4-433c-9099-be5292cb65b1	79d59a7e-d32c-4723-a9e3-80a370d4ed60	fa6340de-8ef8-402d-b682-df4f46011642	2026-08-27 13:34:54.947362+00	\N	\N	\N
22152c33-4574-4df9-aee6-72c8def2f56f	4b1abe45-669a-4c9f-bb9e-eecbda56240d	01344ed0-dcd1-4b13-9d91-7672495f85d2	2026-08-27 13:34:54.954322+00	\N	\N	\N
bc6394c9-0781-4b6f-b708-68cf85e76e3b	114f8ba5-5564-42c4-9034-2e01a493c713	0f862f80-326b-4a8c-bebb-3d8bc6b80136	2026-08-27 13:34:54.960039+00	\N	\N	\N
47a0d97c-321f-4f8f-9a33-5d8790453017	7c678469-22f7-465e-905e-9696f3fd9754	eb1dc983-cbe4-4178-8bea-3ebea62f19c2	2026-08-27 13:34:54.979952+00	\N	\N	\N
aaaee1cc-3576-4830-9ef5-1e85d713d44e	6e5256c5-869a-42a3-b1bd-f316c085dec9	c9d674e4-0cd9-4eed-af62-a82206b3a8e4	2026-08-27 13:34:54.985972+00	\N	\N	\N
d5a4c6a5-a6bb-43e1-bea8-c9b25bf9e7e3	b425a749-eddf-4991-951b-045fae50c701	a68ea3fa-fb39-48b8-b4fb-295bab749f83	2026-08-27 13:34:54.99352+00	\N	\N	\N
3b6feeb5-232f-4318-979e-829636ec3985	62d06322-8057-4756-9750-fb595d22f5e8	a653a715-47cd-4a13-b331-8670b5c7ceed	2026-08-27 13:34:55.063954+00	\N	\N	\N
a646e253-63a8-471c-87ec-28884fa739d5	743c37c3-f9a6-4596-9bc8-de61ed772a9b	208cc532-c332-4320-9f4d-f1db421a494b	2026-08-27 13:34:55.078383+00	\N	\N	\N
0617f6d5-1559-4e1e-8d3a-eda10ad84cd5	\N	8daf93e7-5c50-40b1-80d7-977f3924a8c2	2026-08-27 13:34:55.085624+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
5bc115da-eb71-434b-9743-9c55c013a1c9	af477549-4032-4bc5-a340-ef63921d1a65	f27a8f84-51a3-4df4-91c4-4124084cc45c	2026-08-27 13:34:55.093113+00	\N	\N	\N
4b4f8b56-0806-49bc-b5e7-6f8003974635	b4c59353-93b4-4b09-88b8-1c9b010a79be	2933d465-ee8e-4542-94f9-6043f61b93ca	2026-08-27 13:34:55.098753+00	\N	\N	\N
2a55cb42-4aba-4532-8daf-fe913d8430dd	\N	fabc2a0d-29a8-4a09-b236-e2b8da58a789	2026-08-27 13:34:55.104146+00	\N	\N	🏢 Pole Gestion - Membres
b6894bef-4d8e-48f0-8c28-a9ed57f85734	f5509f28-5d95-4659-9d72-e61ac963e824	37799a12-5ab5-47ac-abbd-25fe32b12e89	2026-08-27 13:34:55.115703+00	\N	\N	\N
3dc08cc5-3615-446e-8e0a-bd5d4134502e	\N	7b3b55d6-c81f-4233-ab70-94aeb32c5cd4	2026-08-27 13:34:55.124077+00	\N	\N	🏢 Pole Syndic - Membres
c75f2465-fea2-46c3-a047-49e34e758bfd	36fd2e0f-5bcb-4022-aa08-f1cdaed0ecbe	424839f6-2601-4689-b03e-a65a873ff2a3	2026-08-27 13:34:55.12936+00	\N	\N	\N
bc4d1b23-9fcf-4bf1-905a-f70f520f3724	d2db7239-1ca7-49b3-bc43-86c0cb25a825	d057e35a-dde9-4eb6-86e0-4f3be7721d32	2026-08-27 13:34:55.134594+00	\N	\N	\N
7a9098ca-f6e4-4a54-b682-ee0d0c8ab29f	1d64afa0-46c7-4add-9402-f81fe8c9db9b	d7b6172f-359c-4fff-a36b-b452e104e82c	2026-08-27 13:34:55.140913+00	\N	\N	\N
619afd3a-0ec1-432f-9e2f-8a022dcf5383	\N	b00a93fa-6db2-4d39-b508-48d702fcecb9	2026-08-27 13:34:55.145549+00	\N	\N	🏢 Pole Comptabilite Syndic - Membres
a620945e-1e23-48a5-b9d8-ece16f7882d2	bafcbdde-b731-4ed8-a334-2202d4cf4d98	27d384f6-ea9a-49ca-bf83-d94fdb52eb0c	2026-08-27 13:34:55.155689+00	\N	\N	\N
b83162c7-02b0-4c78-a680-83b99e378be8	7a0c6e20-cc0e-4d27-9e4e-46ef784836fe	b4bff8a1-430f-4ebd-b99e-33d6462d81d2	2026-08-27 13:34:55.16518+00	\N	\N	\N
25dbe2c7-f4ab-4343-bc33-3ed58a9f19cb	125ed49d-4a83-46f1-a3f4-abd1380b639f	0696ed37-dce3-4b52-8dec-c7da866d8327	2026-08-27 13:34:55.176985+00	\N	\N	\N
c01740f4-690c-48c5-bcb1-1e5398997393	41bc86f4-b749-436e-b2d4-6acc57903fcd	6f419dd7-375a-42ab-8d81-15abe930859f	2026-08-27 13:34:55.187394+00	\N	\N	\N
935f23c2-b8a8-4fd0-be2b-4c14574eae2f	\N	f422efb8-dba7-4930-9803-26005d927c5d	2026-08-27 13:34:55.200865+00	\N	\N	🏢 Pole Sinistre - Membres
0948a179-0a72-4797-af4a-bc490d7870e9	ca071ca7-de86-41a1-bdd8-b1dbf0860682	1d0bc93a-5b13-4c3f-bb53-8b43bf397313	2026-08-27 13:34:55.206129+00	\N	\N	\N
50e8e615-a436-4d41-9574-c3b0dc33b894	38b36da7-b0d1-4662-be52-b6ee57aca061	b8f82a24-b058-491b-b17c-e77182c069e6	2026-08-27 13:34:55.218312+00	\N	\N	\N
d28e0399-d53c-4509-8bc4-a0dd974c54c0	b5066669-f502-40ba-a6c3-815ed0c04b1e	a7d75dc7-3292-4224-9d98-a90aaf38dfa0	2026-08-27 13:34:55.222999+00	\N	\N	\N
3d53bd20-fd18-45a8-9089-dc8821a7df6e	38b36da7-b0d1-4662-be52-b6ee57aca061	494f2f7f-7e92-4752-95c4-29944556fce3	2026-08-27 13:34:55.2319+00	\N	\N	\N
4d26dab3-1272-4b03-a3cc-70cacc684728	1b558fb2-b0dc-409d-9c82-bcebfa448a08	ba97062c-d09e-44e4-b058-114ddd753d3e	2026-08-27 13:34:55.244253+00	\N	\N	\N
139239d8-293f-46be-8649-b96278b6ac6b	c390c330-806a-4eb9-a910-1c5887fed2cc	c606e27d-622f-4ca5-9c09-31b6ff1c04f6	2026-08-27 13:34:55.256922+00	\N	\N	\N
cbee4b34-7400-49d1-85ec-4fd73beee4fd	c390c330-806a-4eb9-a910-1c5887fed2cc	22f890ea-e251-4218-923a-6075039150c8	2026-08-27 13:34:55.265491+00	\N	\N	\N
9758fb8d-af25-4076-8b7a-3664b88f690d	9940abdc-e864-4c64-85bf-83ec644b3809	4f431b25-0125-412b-835b-fb9958e55c08	2026-08-27 13:34:55.275245+00	\N	\N	\N
5aba587a-a924-42e0-a536-de2d909ce2b5	f97bf5d9-114d-466a-b855-d17caee3e260	9d8e4337-a9da-45af-a854-1747e31a4fc9	2026-08-27 13:34:55.283406+00	\N	\N	\N
6270c16e-b1e3-407e-afc6-73bd6258fe37	93022cf0-2102-454b-bece-f0f0f7fbb888	86c1f619-de92-4d1f-8660-a41e817624cc	2026-08-27 13:34:55.300157+00	\N	\N	\N
546106c8-426c-4bf0-9e84-b9b104aee565	9c8b043d-a01c-4089-af23-294d15b8b655	64fa4afb-fb86-4d9f-9ebc-bf4d74187201	2026-08-27 13:34:55.307358+00	\N	\N	\N
ad1ee6c2-b086-4229-83d5-11629e32ffa0	\N	0cb3090e-6498-401e-a68a-b3347c6a1e2c	2026-08-27 13:34:55.330219+00	\N	\N	🏢 Pole Gestion - Membres
ca8e3d3c-fd63-4c10-8efa-7b3e46246c76	d2db7239-1ca7-49b3-bc43-86c0cb25a825	52a2ace5-a420-4254-9a63-58876e51042a	2026-08-27 13:34:55.339178+00	\N	\N	\N
1478f970-1171-4ad8-af87-ed9ee9068a7d	e143e82d-f0a6-437e-9151-76f6ca279a06	9d4cda4c-9492-4480-aec2-04886aa57ccc	2026-08-27 13:34:55.34657+00	\N	\N	\N
af097796-6c7c-43b7-aaca-e52c591ebf2b	\N	bb5b556f-7471-4cca-b486-94166d835407	2026-08-27 13:34:55.356534+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
bb7a1cb8-ae1a-490b-82ad-1b24464a86a0	f9e5949c-1359-4820-928e-2bb57723ccd5	34fd4e57-3cc4-4468-a27a-7d6a47de55c1	2026-08-27 13:34:55.360939+00	\N	\N	\N
49130b73-68f7-4855-b469-334ef7158e58	d285fb75-5788-4701-ace3-14e15a052e46	16ed667f-6d9f-4d2e-953d-780f5eaae4e9	2026-08-27 13:34:55.366365+00	\N	\N	\N
9f588749-8287-4939-981c-f148e26c5ff7	32fda97f-4cf9-485a-82be-e93ef5070597	60b7a313-f55a-4bca-b445-088c50eef165	2026-08-27 13:34:55.371567+00	\N	\N	\N
c0fbdcab-5845-4e05-85e5-7fd9ddf1a099	38d9a85c-9a79-470f-8cd7-014914acf3c7	c1c20b9a-3b1d-45f9-bf86-e345b318393c	2026-08-27 13:34:55.383612+00	\N	\N	\N
29135023-da3e-4d11-93ee-759a027e1cde	8bc894ba-63e8-4902-9cb2-96eb0ca1b713	afb7a46a-2684-4d8a-b6d2-1d44c2eb43cd	2026-08-27 13:34:55.401921+00	\N	\N	\N
83864880-08d3-4f72-a6d2-dfbba886e6a5	c79f6259-fd29-43d8-9711-259796f7bcfc	c79c142e-7d09-406a-9b43-0ee0d20f9b68	2026-08-27 13:34:55.409368+00	\N	\N	\N
5e781548-676b-4c93-aa28-72e800a5190f	093bf052-2c9e-4c20-bf8e-6c218eca2a55	7f7eec29-7645-4cec-b6f7-902cfebf58ae	2026-08-27 13:34:55.414992+00	\N	\N	\N
87f3ef3b-075f-4bd7-ae65-1694b8a3e31c	2b67753a-e872-408d-a2a6-b1e970334a2b	dcf0261d-30b5-426d-8b3a-9da1e38d259a	2026-08-27 13:34:55.419795+00	\N	\N	\N
bf881c2b-3c4a-4388-b0c3-dcb1fb01a5c0	8bc894ba-63e8-4902-9cb2-96eb0ca1b713	52fffdff-d2fa-4f41-aba4-30ff1f655430	2026-08-27 13:34:55.42641+00	\N	\N	\N
7ca4c9e5-f30a-4b3d-843f-f25354d74720	ac1e61ff-8759-467b-b90f-07705b747949	a15d8f85-e535-4577-9d9d-941195d7f698	2026-08-27 13:34:55.433611+00	\N	\N	\N
948dc2d3-e58d-4a23-a482-21b4b09e2905	b879539a-de37-4fc7-9151-0c5566faad30	cbfb43e2-7a35-48f7-bc7a-e7af65c2a186	2026-08-27 13:34:55.437583+00	\N	\N	\N
09e55942-3028-480e-acf3-f1f324880a30	\N	a52298d2-dabd-4cfc-ab5d-c927b48a9730	2026-08-27 13:34:55.440326+00	\N	\N	🏢 Pole Développement CGP - Membres
008f4b5b-d142-45a1-91ef-113edcce9bc4	\N	f8b3086f-06e3-4209-ac79-33d9928e2aa1	2026-08-27 13:34:55.445071+00	\N	\N	🏢 Pole Gestion - Membres
6c32d8f7-76f3-43c3-80cc-980214248386	df94363a-8e80-45ce-a78a-e91ea33fb6ee	3ee8d390-7c52-467c-89a5-1798d3b5c5f3	2026-08-27 13:34:55.448795+00	\N	\N	\N
96570734-0341-4f84-ac08-d8ae01e8db22	55b21729-5058-4fad-b7c1-c455a5485274	9cdf834e-2d05-4db1-a81f-fde4c3013249	2026-08-27 13:34:55.453234+00	\N	\N	\N
b376031c-e441-4731-934c-fdf692dd40ee	\N	8e3c2e6c-e7ba-4fd8-af82-5b48ba93233a	2026-08-27 13:34:55.458264+00	\N	\N	🏢 Pole Phoning Location - Membres
5977d4f7-ae7b-4fd8-96d8-e2ba1f7193be	\N	b7ce9269-ad15-4251-84e0-47fb721de6be	2026-08-27 13:34:55.461856+00	\N	\N	🏢 Pole Technique Location - Membres
90d94bb9-5b9a-43dc-8b7e-360654f99714	8a3cae01-f152-423d-9a56-31a4fbcda459	edad1a87-acab-4f00-9990-6b30982d7635	2026-08-27 13:34:55.466474+00	\N	\N	\N
814f6c6b-7cc9-4088-90a1-dd8723e1e0d3	fb9500b3-29fa-4dbb-b740-f7b413e25399	63b6007e-6b88-48fd-bc0c-7c8086974cd8	2026-08-27 13:34:55.471863+00	\N	\N	\N
7bb61bb3-dbe2-4202-9b2f-b0cf8648260e	0dce424d-c1a8-4fe4-8ec9-3ff08e35a631	edbe7df6-3811-4791-84b1-7a19d41e0687	2026-08-27 13:34:55.479102+00	\N	\N	\N
e7410ec2-f2fb-4fab-bd5e-8ed7bb2410fc	ce5c22dd-4ad4-406e-8cba-e2367519bdd6	92875386-738e-423b-94ce-36ceceee1b24	2026-08-27 13:34:55.482312+00	\N	\N	\N
fe8fce41-7ca3-4497-8805-ebdbe6491395	ac93458f-7a43-45a1-b163-67f5769e55f8	5ebe22a8-f4ce-4267-8a01-e8261f659543	2026-08-27 13:34:55.486392+00	\N	\N	\N
9e5168ec-937a-4778-b982-971a6bf5114b	835e058d-b2fe-4387-8c6a-2434f5a40065	b23861ef-1980-4c50-a6dd-8d34691274ee	2026-08-27 13:34:55.490471+00	\N	\N	\N
7a2433b0-36e6-40ff-ac94-1b088200518b	304ad137-6619-4dde-8e30-d2533d7ad1c7	acb5b34f-2e65-4b95-82a8-e2d673a63b67	2026-08-27 13:34:55.495574+00	\N	\N	\N
2479d677-80c6-4758-be3b-4dd574f486e5	af21baf0-247d-486c-84ee-5f01f048deea	c08aaea0-f721-4ecb-948a-c8689be7c907	2026-08-27 13:34:55.499976+00	\N	\N	\N
204d7860-a894-47c9-98b1-014c4559f79d	\N	00c13f12-7064-47ef-9b29-d15f22308312	2026-08-27 13:34:55.504339+00	\N	\N	🏢 Pole Gestion - Membres
bf026de6-233b-4821-84a0-fcb28e0b0fa7	\N	385df68a-2a8c-4841-8432-9ada0c96197b	2026-08-27 13:34:55.507432+00	\N	\N	🏢 Pole Gestion - Membres
d30b6f8e-7f3b-4b13-8d72-caffc942e8c0	62d06322-8057-4756-9750-fb595d22f5e8	aedea92f-50b3-4662-8ad6-7420ea071cb3	2026-08-27 13:34:55.5158+00	\N	\N	\N
3a1c5ba0-733b-4a88-8bd5-699c65bba4df	a5a6872a-ebe1-4401-9e04-036f29764adf	18af2eb7-6ca6-411c-8379-d57ea9701d78	2026-08-27 13:34:55.520215+00	\N	\N	\N
2d9efeb9-cecf-444b-944e-cebf109afa8f	b6edb5ed-b618-4d73-91f2-baab882280c5	d4b29d74-7204-4c00-81f2-373b3b28f300	2026-08-27 13:34:55.525079+00	\N	\N	\N
ff45c36b-1b07-4ddf-b9f0-4b7e826b51d5	6a300cbe-f185-4dea-833c-3e73e3278d14	cbb1c464-1f63-42e4-80a2-3413f240b770	2026-08-27 13:34:55.52978+00	\N	\N	\N
7ecc5686-e3fd-4028-9e17-b9be7ef968ef	690d99b6-c9bd-4fa6-bb8e-5c28874e0762	4354c7b2-6e94-43de-b93c-f3a44e9cb051	2026-08-27 13:34:55.533393+00	\N	\N	\N
a2603ba2-d323-4353-9619-e5efe9ef9636	\N	00e32f2d-b25d-416b-ba9e-44a8a605e8fd	2026-08-27 13:34:55.536635+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
eef65d1d-3bfc-4521-a412-d7c90de02740	60dd1daa-9636-4017-8182-74bc53fb122d	d1dca87d-3284-4566-87c1-6634ee4805e1	2026-08-27 13:34:55.541132+00	\N	\N	\N
44ee8702-1612-4dba-9893-f994862b7353	\N	05e515d4-f11f-4b0b-8308-02f0dc028d77	2026-08-27 13:34:55.544223+00	\N	\N	🏢 Pole Technique Location - Membres
ddcd1ff8-e9da-4147-9759-3ecbc2057806	\N	eda9599e-d476-4842-a88d-dff98b713098	2026-08-27 13:34:55.548795+00	\N	\N	🏢 Pole Dossier Location - Membres
9d70163b-a5d5-44a5-ade0-9fc0a13f7729	533716fc-b5c3-4565-b5c9-2e520a37b4b8	90c17cd6-6cff-4ca9-b3e8-9843a8406280	2026-08-27 13:34:55.555354+00	\N	\N	\N
a7ddb0f1-27c1-4b23-b262-cb5e263091a2	12f03f63-55d3-4301-a7f9-e522fee49feb	ef8307a0-c5a7-44d4-b434-b7d4636a0a10	2026-08-27 13:34:55.560519+00	\N	\N	\N
9329db0b-063a-411b-b192-ce3dce674b1e	\N	1dcd3604-9d33-4007-a45e-f09e4caa9064	2026-08-27 13:34:55.566704+00	\N	\N	🏢 Pole Syndic - Membres
45babbcc-5058-4e99-98f5-7f29496e10a6	cdbd094b-2737-408d-8a1b-84d04221564e	bbe0b38a-e79c-4e11-bd32-3308fce6f3ef	2026-08-27 13:34:55.571024+00	\N	\N	\N
905ab2b6-3281-4f43-af6d-7b6e89fb22d7	62d06322-8057-4756-9750-fb595d22f5e8	e7523502-e638-4bf3-8c2b-110dc4f2d6bc	2026-08-27 13:34:55.577482+00	\N	\N	\N
3830e711-1677-4355-95ce-f748870de09e	\N	cbb352ad-4aba-41d9-bbcc-a5478ba9e101	2026-08-27 13:34:55.583981+00	\N	\N	🏢 Pole Commercial Location - Membres
6c442f61-6424-45b0-8f6b-02364077de74	\N	4e5cb271-1d25-48a5-85c3-914dee344547	2026-08-27 13:34:55.590873+00	\N	\N	🏢 Pole Technique Location - Membres
9933923b-c77a-4354-8c41-902c04b39f69	\N	767df4f7-8403-4a76-9116-ce5c589e3328	2026-08-27 13:34:55.59686+00	\N	\N	🏢 Pole Transaction - Membres
cfee19c1-0cb2-435a-8bd7-280a014870d8	06add6f1-e7a4-4a8c-a6a9-e1065db303c8	2e7d86c3-3a77-4306-9927-cf27b59a2911	2026-08-27 13:34:55.602717+00	\N	\N	\N
31fc5555-3c68-42c8-915e-e0068302d4ee	c1f31f22-5966-46e4-9487-6f6fdc24007a	d05ae9b8-5fbf-45e0-baf4-38511b8ed7dd	2026-08-27 13:34:55.606064+00	\N	\N	\N
57c48cbb-fc8a-4f84-8301-c1618a554d58	\N	de58ed5f-90e1-4854-bdc9-66734ce71558	2026-08-27 13:34:55.677705+00	\N	\N	🏢 Pole Comptabilite Gerance - Membres
ffe65a07-db7f-4ff3-8396-f1fce34a7698	\N	65c1bc27-d244-476a-9fa9-8a939c6357fb	2026-08-27 13:34:55.685196+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
e0b0905d-187b-43f1-a488-6573be8558ed	\N	cda13b03-27de-45fd-ad11-4232b8a4cc3e	2026-08-27 13:34:55.69225+00	\N	\N	🏢 Pole Développement CGP - Membres
3b091d32-8035-4da0-bea3-ec9b79d3c61e	101b53e9-b554-478a-9e95-3a2c2d44c9f1	1dd03f7f-5191-4e32-9104-86a83e75032a	2026-08-27 13:34:55.697335+00	\N	\N	\N
c5abdb6b-01ee-4fd6-95fc-8b8f085ea184	9065235a-5dbe-42c0-9bbb-3557592c5e2a	1798d260-19f0-42e2-9fd8-4d74eb4dc4b9	2026-08-27 13:34:55.702198+00	\N	\N	\N
f4eaeb6d-0571-4741-923c-c429df42832b	c7e3300a-fe49-4b28-aafe-c2402982831b	f8dc44ae-9de9-4f7e-a8fe-96ee369870b8	2026-08-27 13:34:55.706785+00	\N	\N	\N
32683ee9-2409-4441-af8c-1d966da44e2d	9799327d-781f-4c43-a284-08528389e366	f373ea0f-6e62-4bb3-ac45-18810132cde2	2026-08-27 13:34:55.711084+00	\N	\N	\N
45d09c20-e5be-44e4-bdd0-a0f7c64c9cad	8b1a90a9-1974-48a0-abfd-06cc552fade5	ba7da3b5-c3b8-4adf-935e-e77b5be7cba0	2026-08-27 13:34:55.717178+00	\N	\N	\N
0422a635-75c9-4f82-a9b6-b19a9ee0fe36	7a0824ae-2296-44d5-8e32-669745de4c12	def0043c-9088-4c93-984f-400bb1730e26	2026-08-27 13:34:55.722318+00	\N	\N	\N
841d8879-2ea0-49ad-9d9c-d4f0d92809dd	5027181d-b736-4199-ae12-b407eea5631d	209681a3-f609-4c02-a67a-6fd9432bc773	2026-08-27 13:34:55.727117+00	\N	\N	\N
403ea2fb-ee32-445f-8e28-120c6f51adf5	e143e82d-f0a6-437e-9151-76f6ca279a06	61900226-5008-431e-8701-9c5d7ed52e9e	2026-08-27 13:34:55.733967+00	\N	\N	\N
cec56b35-07ac-4f31-a906-3ed405c8fdd5	47d649ea-5c0a-40a0-8338-b3c7e0697f1d	08dea7a5-5eb5-4d2e-8025-2d4853ba7682	2026-08-27 13:34:55.738243+00	\N	\N	\N
95a3d6e1-806b-4139-8021-bcfc73f4992a	62d06322-8057-4756-9750-fb595d22f5e8	d5b9747b-8543-4a90-92a0-c4f984e4a8a1	2026-08-27 13:34:55.742751+00	\N	\N	\N
741a1857-811d-40f9-a641-c88bdd8a82cb	d285fb75-5788-4701-ace3-14e15a052e46	c0cb9fb0-6f14-4384-8541-70b2e4d50d7e	2026-08-27 13:34:55.747781+00	\N	\N	\N
8d548ee8-0d25-4868-bdbf-79a17713bc16	a45742a5-894a-4a32-83b8-0b3cf7cfb970	1f5652a3-2a8d-4425-adc1-2692fb23cdce	2026-08-27 13:34:55.753393+00	\N	\N	\N
5277d8a6-6973-4000-b1f6-c43ba5127c41	c390c330-806a-4eb9-a910-1c5887fed2cc	27679820-066f-4b65-ac8a-a3a1546636ee	2026-08-27 13:34:55.758458+00	\N	\N	\N
5d3606ed-92af-4b61-afa0-f2afda128dd1	4bd56618-dece-43fd-8fc9-fe98d930c922	15f97906-5781-420a-af38-7242c983c38d	2026-08-27 13:34:55.768021+00	\N	\N	\N
6549f6b5-8252-4880-9e71-d92387f3a34f	fed7ae60-6b89-49c2-b2eb-a472b1789ca0	7bac214a-d10d-49d9-bbf7-3ece0df1a722	2026-08-27 13:34:55.772086+00	\N	\N	\N
0e3ac953-ab2f-4b78-84b1-262bd55d7162	0a7d08d8-d7a1-4510-8a6f-dd7c6ea30f99	180439e0-c146-404c-b042-f7ee9d21eaf2	2026-08-27 13:34:55.776441+00	\N	\N	\N
e6a3df9c-c543-4b87-9d12-b30f41b21b2d	9c8b043d-a01c-4089-af23-294d15b8b655	ee9ec3f8-2663-4fd8-8f4a-6ef36fc8a015	2026-08-27 13:34:55.780789+00	\N	\N	\N
edf24c9b-1595-4ca9-9ffb-0544b4e61c1c	ac51fd68-5eaa-4066-b39e-88a5a6b3034d	8cef8030-0744-4ba8-b0c6-273bf2097a8d	2026-08-27 13:34:55.78568+00	\N	\N	\N
45e82102-1843-42de-b802-282fe0f3503d	743c37c3-f9a6-4596-9bc8-de61ed772a9b	38594d3d-2a0d-4af9-b36a-58db57dbbd57	2026-08-27 13:34:55.789531+00	\N	\N	\N
75ea36ed-5d14-4d1a-8063-b71b2f1dfd12	eebd0b93-b853-4497-81c3-417686db6d6b	2f29364e-8647-462e-9ac0-2e00dc8f7bb9	2026-08-27 13:34:55.793956+00	\N	\N	\N
5e3321aa-db77-4569-8520-991d836a58be	40b4e542-806e-491e-9218-e7eae5547492	30060012-6cbe-4b39-a7bb-545048655a5f	2026-08-27 13:34:55.798433+00	\N	\N	\N
b731f737-3cdb-44ee-a619-ebdf4b6460b3	3df0dec0-7d7b-42e1-be5b-3befb44ae276	c76dec61-f2d6-42bb-9611-5f4fc331451f	2026-08-27 13:34:55.801713+00	\N	\N	\N
c9e10e03-1d12-470a-a624-d68e40b125f3	a5a6872a-ebe1-4401-9e04-036f29764adf	fc49969c-1be3-4905-bb93-d7e4bb37c084	2026-08-27 13:34:55.806057+00	\N	\N	\N
696ceee3-d56a-4cab-ab90-6d4d68a576fe	6a300cbe-f185-4dea-833c-3e73e3278d14	f93be77a-e454-452d-94ce-b87da08f0dbf	2026-08-27 13:34:55.809682+00	\N	\N	\N
8963397b-2f0d-4259-b05b-796ad1342285	ac55a2c1-d471-4e28-9e74-bd89845f2904	831e60bc-6d79-49fe-850c-02791e4826c6	2026-08-27 13:34:55.814013+00	\N	\N	\N
5085b7ad-f63a-4a1a-b362-84c3a62761d0	0d15c9cd-6825-4027-9637-c4808db041ef	0632fd35-9b49-4626-92c9-e023c8ddc8f3	2026-08-27 13:34:55.818685+00	\N	\N	\N
91229593-944a-4d30-beae-3b4f54487aae	57ad174b-600a-4156-ad48-e8ea11a03e15	e08f9dd4-fa62-4789-87fe-f53b70e4ffce	2026-08-27 13:34:55.823687+00	\N	\N	\N
05ee89b9-d3b6-4f46-8513-45a320492e5f	\N	85e0beb0-5c78-4f20-b12f-79bee12144be	2026-08-27 13:34:55.827057+00	\N	\N	🏢 Pole Gestion - Membres
0353dd41-1c24-4525-aa1d-90f138bc7ae3	f5509f28-5d95-4659-9d72-e61ac963e824	3b74a41d-e07a-4320-98a6-873f93e65155	2026-08-27 13:34:55.831148+00	\N	\N	\N
135cbaaf-c78c-472f-8986-761088f07dea	e47b7fac-fc2a-473f-a536-f3e366d83887	028072f6-0f72-45fc-8f00-322c43f61b71	2026-08-27 13:34:55.835279+00	\N	\N	\N
7fc1d78b-76c7-4b83-a0ec-3324f96816c6	48060b50-0791-4e4e-ac10-b67e84b373ad	734456ea-1163-460c-8518-29926a65eea1	2026-08-27 13:34:55.840953+00	\N	\N	\N
83d032d7-2b5c-41cf-9581-11c5fdc5d910	af477549-4032-4bc5-a340-ef63921d1a65	a515c8bf-11b8-4ab8-8c91-8be78e6b5874	2026-08-27 13:34:55.845042+00	\N	\N	\N
72c6d721-e3fb-46f8-932d-75b982f2b08f	40b4e542-806e-491e-9218-e7eae5547492	929ee2d5-3b9a-4cac-88ec-6e37273793b8	2026-08-27 13:34:55.84898+00	\N	\N	\N
33d1a4ef-b0a8-48a6-9ceb-241dfab40aee	f3b2032f-00f9-43fb-951f-4e9596848dc3	9fbf27f0-b0ae-4d55-b6d4-8e2090f98869	2026-08-27 13:34:55.852844+00	\N	\N	\N
f00df812-dea0-4743-9be4-161b9a4de148	12b792db-ddc9-4cbe-b2b7-40a050a6aab2	1709f1d9-a92f-4ab9-bbca-8c49c055ec32	2026-08-27 13:34:55.856522+00	\N	\N	\N
c943c149-4855-4136-b2e2-85a1bdc009d7	d0f3989d-81cb-48f8-afdd-e926c6d53ebe	e89dddcc-35c0-441d-802a-461e65bfa538	2026-08-27 13:34:55.862076+00	\N	\N	\N
a1b81b21-6cb4-4275-ac69-1c785bbf3b4c	12f03f63-55d3-4301-a7f9-e522fee49feb	0b83da15-b3af-47f3-9bd8-6e72c66a1587	2026-08-27 13:34:55.866869+00	\N	\N	\N
ea428797-a553-4b62-8a7d-115ba08ff2c1	7c678469-22f7-465e-905e-9696f3fd9754	76f60eef-4eda-4a6c-b9f7-56d050490fa4	2026-08-27 13:34:55.871773+00	\N	\N	\N
1f242768-7db0-4ee1-9498-78ca9268af18	101b53e9-b554-478a-9e95-3a2c2d44c9f1	34f040dd-c474-4fb9-9de4-2a17cce07a42	2026-08-27 13:34:55.876219+00	\N	\N	\N
b280bc78-b683-4d4f-99da-3448348366ac	8b1a90a9-1974-48a0-abfd-06cc552fade5	f34b02da-3387-48d9-bc40-83299e4dd101	2026-08-27 13:34:55.881776+00	\N	\N	\N
55f4ec24-1247-4636-8a48-d8b7add42481	1b558fb2-b0dc-409d-9c82-bcebfa448a08	880f954b-27af-45c2-8f12-7ad8583725d1	2026-08-27 13:34:55.887814+00	\N	\N	\N
17ef18e4-1e67-4f5e-80a1-50910056da93	af21baf0-247d-486c-84ee-5f01f048deea	866f4985-b42e-43bb-b5fb-24c52b12bee0	2026-08-27 13:34:55.891098+00	\N	\N	\N
2761e379-cdc1-4f6a-9baa-0c685ae1190d	d2d8d59b-d86d-4485-bd98-3086eda03728	20f83eb9-dcec-483b-aa7e-0f06b61648d2	2026-08-27 13:34:55.894783+00	\N	\N	\N
7ff73d1a-4e86-413d-a13d-269c191b6dba	85cc63ff-7df5-4fe8-ae5b-96f55bd68811	712d5bd0-4d3b-46bb-8d57-6e0be1c72118	2026-08-27 13:34:55.903393+00	\N	\N	\N
9ff9955e-ff9f-4d9e-b8ea-1d050a2ab3d4	f9e5949c-1359-4820-928e-2bb57723ccd5	e676c7bc-36ad-49d5-b73e-a7ea80875cb2	2026-08-27 13:34:55.91592+00	\N	\N	\N
01467d81-3665-4a1c-b27a-127e237125ce	af477549-4032-4bc5-a340-ef63921d1a65	a8d44def-9b24-47ba-946d-11db5ea23ab7	2026-08-27 13:34:55.921714+00	\N	\N	\N
7ff180ce-2225-4118-9eb8-4e561fe2cc27	85cc63ff-7df5-4fe8-ae5b-96f55bd68811	8f37a045-5242-4219-a7eb-30653824de7a	2026-08-27 13:34:55.926395+00	\N	\N	\N
d0a6ae63-0537-4ef1-8814-649ff227bf40	5027181d-b736-4199-ae12-b407eea5631d	43b947f9-fef9-4c46-8bcc-742e619054ce	2026-08-27 13:34:55.931661+00	\N	\N	\N
c473e3c0-e185-4421-8ce5-274922d31b3c	8a3cae01-f152-423d-9a56-31a4fbcda459	eb31857c-e832-4908-a1e3-c85ee1d010c1	2026-08-27 13:34:55.937752+00	\N	\N	\N
9260f696-3fee-4c78-8041-edc602ea0b26	8a3cae01-f152-423d-9a56-31a4fbcda459	cd8d1f46-04e7-42e6-b943-827d07e83a8b	2026-08-27 13:34:55.943808+00	\N	\N	\N
d9702875-6417-427f-9eea-ff613ecfe92f	b651b723-1d84-4f6b-b59e-62ded0251782	f6f889d0-fa1f-4c1a-9965-f2018852c498	2026-08-27 13:34:55.950632+00	\N	\N	\N
c2e3bbc7-6618-484c-8078-2e54f5b211ed	\N	888d1252-e1fb-4c03-9226-8a7b354ab2bc	2026-08-27 13:34:56.570338+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
29d7c74c-4856-447f-8e7b-57ffd0000ecf	\N	c240b462-85df-4b93-b620-bae822b3b575	2026-08-27 13:34:56.581043+00	\N	\N	🏢 Pole Commercial Location - Membres
e41d21b7-8146-41cd-9257-229dbc246c17	\N	126b327c-4750-4a29-a5ec-3c06ca2bcf6b	2026-08-27 13:34:56.584655+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
d825c0f5-1543-469f-b12e-10ce6526d415	\N	c00859d2-5602-4b0f-8ebf-872d240cde19	2026-08-27 13:34:56.594555+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
dc1fecb8-02ca-4ef2-b0ab-922c195e8650	\N	24198579-88ba-4172-96a1-6690a6575add	2026-08-27 13:34:56.602692+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
0084e16d-b76f-4e64-9390-6031df93a7fd	\N	46f4cf4a-7cec-4d8b-a0b3-45d1e7cb3ca5	2026-08-27 13:34:56.608091+00	\N	\N	🏢 Pole Sinistre - Membres
b84380bc-8fd0-431e-bb34-2bd1d0de48ad	\N	12fbfd93-ad0f-4236-988c-47c4492d4c40	2026-08-27 13:34:56.618654+00	\N	\N	🏢 Pole Sinistre - Membres
91a318e3-d27c-43d9-aac8-277bf472dc60	\N	5deaf7a2-25cc-4805-8b11-8e9d87dc7d7e	2026-08-27 13:34:56.624727+00	\N	\N	🏢 Pole Sinistre - Membres
ddd05cc2-acc6-40dd-ad1e-a9c031b0f6cc	\N	34da41e9-01af-4bc5-a60f-3304bf342fe4	2026-08-27 13:34:56.628053+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
1efae51f-f31b-4902-a6f5-b364b61faf28	\N	30cfcb37-32f6-4eb3-9643-6f2037462b56	2026-08-27 13:34:56.633336+00	\N	\N	🏢 Pole Sinistre - Membres
fca02329-a8fa-4189-8036-9a62c00b1967	\N	989e02c0-5e25-4370-aced-6f491ff24730	2026-08-27 13:34:56.641+00	\N	\N	🏢 Pole Sinistre - Membres
e497cccf-b026-43fd-a204-28cc7df70346	\N	5c2d635c-9503-4271-9076-79ae3fe053d5	2026-08-27 13:34:56.645468+00	\N	\N	🏢 Pole Sinistre - Membres
1a229f22-2dac-4c9e-b12a-4b2873ea25e1	\N	af44c36f-07eb-42b0-9628-5531db198a57	2026-08-27 13:34:56.649185+00	\N	\N	🏢 Pole Sinistre - Membres
ffea8314-ea20-4188-a2d6-a415f1db55b5	\N	13de6f44-343e-4833-bdc3-df0f133bee50	2026-08-27 13:34:56.654491+00	\N	\N	🏢 Pole Sinistre - Membres
6a95fea3-5ab1-43ac-ae3d-2e92bfc7e6ec	\N	ed6ff1c2-2032-46c9-b101-44a05fe86d2d	2026-08-27 13:34:56.658855+00	\N	\N	🏢 Pole Sinistre - Membres
7c4d41db-d8fb-4791-bc6d-b0611cff3fb8	\N	33074271-c15f-4fbc-b07f-660d8c6fc016	2026-08-27 13:34:56.662289+00	\N	\N	🏢 Pole Sinistre - Membres
3fbf7222-119b-463e-bf4e-59c33200561d	\N	f8c07281-8c27-4136-ac08-fff9efedaf7d	2026-08-27 13:34:56.667237+00	\N	\N	🏢 Pole Commercial Location - Membres
7397f676-2468-42fa-bebc-973f7386555c	\N	f50091b2-0cf5-488d-84fb-4e74cdc89953	2026-08-27 13:34:56.740261+00	\N	\N	🏢 Pole Gestion - Membres
9ccdc31a-46f3-4923-bc5c-f9cd7345fa89	\N	8bdcab4c-a3d6-47b9-8dcd-72783e801d92	2026-08-27 13:34:56.823535+00	\N	\N	🏢 Pole Sinistre - Membres
a8f5707a-b06f-487f-adc4-430c8f2631d1	\N	1006fb43-00e7-41df-a3c7-071b956f6c3e	2026-08-27 13:34:56.828188+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
ad6f57cd-5384-41c9-9812-e3c4fa056f37	\N	eda58a47-c1e0-4538-81b5-b636341560cf	2026-08-27 13:34:56.833282+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
6f2eff0a-15d1-4b6f-8fd3-5195fc4aa6f4	\N	7a6142ca-ec06-49be-b097-ae5eb4a90b14	2026-08-27 13:34:56.841396+00	\N	\N	🏢 Pole Contentieux Juridique - Membres
ff28f481-1b00-4754-8a7e-2c1d3a38545e	\N	53bb3576-4cbc-4d39-bd8c-56995bfd8c91	2026-08-27 13:34:56.847073+00	\N	\N	🏢 Pole Sinistre - Membres
bd548b94-7518-4456-945d-5972e9d0184d	\N	b8acb55d-ae83-4101-81cc-5a44d0580db8	2026-08-27 13:34:56.855307+00	\N	\N	🏢 Pole Transaction - Membres
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
ec51bb45-a1b5-4502-a281-c124720be1cf	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440WM	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:52.770579+00	2026-08-27 13:34:52.779036+00	PORT2306-1440WM	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
f2018fca-ff93-4791-8de8-155293aad7b8	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009128	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	PORT1808-009128\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:52.78183+00	2026-08-27 13:34:52.78183+00	PCLCLSC	\N	\N	\N	\N	f	f	F1808163-03676	870.00	\N	\N	2021-03-08	ESI0067	f
477a08e2-67f4-4ed2-adc3-a6201e055ce1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009996	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009996	2026-08-27 13:34:52.784189+00	2026-08-27 13:34:52.786849+00	PORT2108-00996	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
e1260148-92e8-4612-8c97-2a8c3c992eae	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD010743	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-04-09	PORT1808-010743\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:52.788884+00	2026-08-27 13:34:52.788884+00	PCP2-CBOIVIN	\N	\N	\N	\N	f	f	F1809165-04158	870.00	\N	\N	2021-04-09	ELY0112	f
e456c2c1-e253-40ff-88ba-7a30ec30bcee	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSBX005767	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK U749	in_stock	\N	\N	1900-01-22	PORT1910-005767\nAffectation importée non résolue : Usager="illiet" ; Utilisateur="-"	2026-08-27 13:34:52.792204+00	2026-08-27 13:34:52.792204+00	PORT1910-005767	\N	\N	\N	\N	f	f	F1910350-05629	1142.00	\N	\N	1900-01-22	ELY0127	f
30dbc3f5-1583-40ad-9162-55628f32288e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD073677	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-27	PORT2104-073677	2026-08-27 13:34:52.796712+00	2026-08-27 13:34:52.800878+00	PORT2110-073677	\N	\N	\N	\N	f	f	F21050397 - 03330	929.00	\N	\N	1900-01-27	ESI0120	f
ac97c97b-e375-4359-a3f8-29f45d6bfa10	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD077437	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-24	PORT2104-077437	2026-08-27 13:34:52.803025+00	2026-08-27 13:34:52.807269+00	PORT2101-077437	\N	\N	\N	\N	f	f	F21060388 - 04069	929.00	\N	\N	1900-01-24	ESI0120	f
dd58c0ba-ee5d-43e2-8e9e-ddc0b994aea2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009995	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	\N	2026-08-27 13:34:52.810032+00	2026-08-27 13:34:52.812745+00	PORT2108-009995	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
6d2c6d66-d430-4348-9035-28812a3bce59	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021782	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2020-12-11	PORT2011-021782	2026-08-27 13:34:52.814801+00	2026-08-27 13:34:52.817736+00	PORT2011-021782	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI0110	f
fcd63b34-6e69-4605-95e3-5cbc340b4d0c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV107017	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-24	PORT2301-107017	2026-08-27 13:34:52.819864+00	2026-08-27 13:34:52.822338+00	PORT2212-107017	\N	\N	\N	\N	f	f	0097532246	880.00	\N	\N	1900-01-24	ELY0189	f
e553bce6-9139-4290-97db-a18c8e107ae5	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD005167	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2009-005167	2026-08-27 13:34:52.824284+00	2026-08-27 13:34:52.827163+00	PORT2009-005167	\N	\N	\N	\N	f	f	F2011424 - 06614	929.00	\N	\N	1900-01-23	ELY0148	f
6f063b9c-e4e1-4ff6-bff3-3756bb4ab461	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029583	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	2021-01-10	PORT2110-029583	2026-08-27 13:34:52.828749+00	2026-08-27 13:34:52.832138+00	PORT2110-029583	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0173	f
4a610262-2a5d-4e81-8d39-222ccb3d4684	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3212JK7	HP	HP EliteBook 640 14 inch G9 Notebook PC	assigned	\N	\N	2023-07-07	\N	2026-08-27 13:34:52.834863+00	2026-08-27 13:34:52.837848+00	PORT2307-212JK7	\N	\N	\N	\N	f	f	\N	886.47	\N	\N	2024-07-07	ESI0175	f
1127ea8a-0ab2-4294-86d1-3d4858699afb	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD077247	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:52.839555+00	2026-08-27 13:34:52.841863+00	PORT2104-077247	\N	\N	\N	\N	f	f	\N	929.00	\N	\N	1900-01-26	ESI0120	f
88a46cf8-22e9-4951-96e6-7fe492f66c39	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009997	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009997	2026-08-27 13:34:52.843249+00	2026-08-27 13:34:52.845265+00	PC-DSFV009997	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
a0e2f1a2-f00a-44b6-ad81-088aed3c59d5	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD073773	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	PORT2104-073773	2026-08-27 13:34:52.847273+00	2026-08-27 13:34:52.849347+00	PORT2104-073773	\N	\N	\N	\N	f	f	F21040370 - 02563	929.00	\N	\N	1900-01-26	ELY0160	f
5a24c099-eea9-4da1-80af-9249a9494d57	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029594	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	2021-01-10	PORT2110-029594	2026-08-27 13:34:52.850869+00	2026-08-27 13:34:52.852816+00	PORT2110-029594	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0173	f
861c4a85-6e97-4546-b21d-15371a575e62	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSGJ005129	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5512	in_stock	\N	\N	2022-05-12	PORT2212-005129\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:52.854787+00	2026-08-27 13:34:52.854787+00	PORT2212-005129	\N	\N	\N	\N	f	f	0097449332	985.00	\N	\N	2023-05-12	ELY0188	f
edb4a14e-7980-4d3d-aab3-5df3b3724f96	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3046022	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	2023-09-03	\N	2026-08-27 13:34:52.857063+00	2026-08-27 13:34:52.859629+00	PORT2302-046022	\N	\N	\N	\N	f	f	FA00004996	1153.72	\N	\N	2024-09-03	ELY0191	f
54717f20-800a-45ff-a582-9f5881a76bc9	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFS012281	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK U7411	assigned	\N	\N	1900-01-15	PORT2109-012281	2026-08-27 13:34:52.861731+00	2026-08-27 13:34:52.864088+00	PC-DSFS012281	\N	\N	\N	\N	f	f	F22020326 - 01121	1228.00	\N	\N	1900-01-15	ELY0170	f
8101b1f3-e4cc-4620-9f1f-669f9ff5af71	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	3SV6SQ3	Dell Inc.	XPS 15 9520	assigned	\N	\N	2022-05-12	\N	2026-08-27 13:34:52.865779+00	2026-08-27 13:34:52.868125+00	PORT2212-SV6SQ3	\N	\N	\N	\N	f	f	0097449332	2344.00	\N	\N	2023-05-12	ELY0188	f
3b913472-cb21-4e7c-9cbf-2005353c471b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009994	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-27	\N	2026-08-27 13:34:52.869114+00	2026-08-27 13:34:52.869114+00	PORT2108-009994	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
2b40961e-30fa-4fb5-b9a9-b1501a3dbf05	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD058980	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	1900-01-26	PORT2103-058980	2026-08-27 13:34:52.870617+00	2026-08-27 13:34:52.870617+00	PORT2103-058980	\N	\N	\N	\N	f	f	F21040369 - 02562	929.00	\N	\N	1900-01-26	ELY0159	f
6d8490c6-f475-49a6-ab8b-8525184d6d9f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFW001036	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q7311	assigned	\N	\N	1900-01-27	TABLET2108-001036	2026-08-27 13:34:52.873431+00	2026-08-27 13:34:52.876033+00	PORT2108-001036	\N	\N	\N	\N	f	f	\N	1253.00	\N	\N	1900-01-27	ESI0122	f
548744a1-dec0-49a2-a5f3-03c4b7d6467d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD8513NBW	HP	HP ProBook 470 G5	retired	\N	\N	1900-01-14	Affectation importée non résolue : Usager="iabsi@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:52.87828+00	2026-08-27 13:34:52.87828+00	DESKTOP-EHS8D13	\N	\N	\N	\N	f	f	F1903260-01378	1139.00	\N	\N	1900-01-14	ESI0093	f
5c1a32b4-87fa-4173-89bc-2c5587c108e3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029574	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-30	PORT2110-029574	2026-08-27 13:34:52.880985+00	2026-08-27 13:34:52.883839+00	PORT2110-029574	\N	\N	\N	\N	f	f	F22010429 - 00429	855.00	\N	\N	1900-01-30	ESI0171	f
a0a95a1e-6c75-44fa-8d27-00492062fc3a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	YMLK055870	Fujitsu	ESPRIMO D538	retired	\N	\N	1900-01-12	PC1910-055870	2026-08-27 13:34:52.884925+00	2026-08-27 13:34:52.884925+00	PC-YMLK055870	\N	\N	\N	\N	f	f	F1912281-06793	589.00	\N	\N	1900-01-12	ESI0085	f
61534d06-85ac-4621-81de-b205bd213668	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021790	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	retired	\N	\N	2020-12-11	PORT2011-021790	2026-08-27 13:34:52.886391+00	2026-08-27 13:34:52.886391+00	PORT2011-021790	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI00108	f
e2a8b135-6b25-4af1-8b27-c4ae9112b951	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021786	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2020-12-11	PORT2011-021786	2026-08-27 13:34:52.890492+00	2026-08-27 13:34:52.893377+00	PORT2011-021786	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI0109	f
1de840d2-6629-47de-9f0f-7472ad0438db	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224TTN	HP	HP ProBook 450 15.6 inch G10 Notebook PC	assigned	\N	\N	1900-01-29	\N	2026-08-27 13:34:52.895948+00	2026-08-27 13:34:52.898583+00	PORT2308-224TTN	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
a36b2cdd-045a-4a1f-8538-37f435a3e050	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD005177	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	retired	\N	\N	1900-01-23	PORT2009-005177	2026-08-27 13:34:52.899876+00	2026-08-27 13:34:52.899876+00	PC-DSFD005177	\N	\N	\N	\N	f	f	F2011424 - 06614	929.00	\N	\N	1900-01-23	ELY0147	f
06db22c5-2990-4689-91d0-528ba59fdcc4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF29D31Y	LENOVO	81RG	in_stock	\N	\N	1900-01-24	Affectation importée non résolue : Usager="-" ; Utilisateur="Marion SAYSSAC"	2026-08-27 13:34:52.906808+00	2026-08-27 13:34:52.906808+00	PORT2006-29D31Y	\N	\N	\N	\N	f	f	F2006297 - 03243	832.00	\N	\N	1900-01-24	ELY0138A	f
60af633c-0ab1-45a7-aee6-28d40d571c8d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7797012	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:53.508786+00	2026-08-27 13:34:53.511205+00	PORT2406-797012	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
32bf73cd-7aca-4ef9-a653-3d4717fb134c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8226155	Wortmann_AG	FR1220852;1470935	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.789241+00	2026-08-27 13:34:53.792028+00	PORT2508-226155	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
00147eda-9f87-499f-ba02-83ae4bf9ffd9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXAYB	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.023947+00	2026-08-27 13:34:56.023947+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d2193e0b-deba-4ddc-b01c-6783d67743ff	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJWY4A	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.026325+00	2026-08-27 13:34:56.026325+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8bd66d1d-9978-4642-9d6a-53b89ce8843a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31441WT	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:52.917915+00	2026-08-27 13:34:52.92159+00	PORT2306-1441WT	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
a5723762-ac2e-46a7-8f4c-ab35c5d7d3d3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	0F004HN23073BF	Microsoft Corporation	Surface Pro 9	in_stock	\N	\N	1900-01-15	Affectation importée non résolue : Usager="-" ; Utilisateur="Dorine VINCENT"	2026-08-27 13:34:52.923484+00	2026-08-27 13:34:52.923484+00	PORT2306-0738F	\N	\N	\N	\N	f	f	FA00005169	\N	\N	\N	1900-01-15	ELY0192	f
b53e1d9b-16dc-4fef-b9bf-767e5d0e0501	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029573	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	2021-01-10	PORT2110-029573	2026-08-27 13:34:52.941481+00	2026-08-27 13:34:52.944344+00	PORT2110-029573	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0173	f
79eee6cf-c158-4535-8793-69fea037b51c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021804	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2011-021804	2026-08-27 13:34:52.946468+00	2026-08-27 13:34:52.949115+00	PC-DSFD021804	\N	\N	\N	\N	f	f	F2011423-06613	929.00	\N	\N	1900-01-23	ESI0160	f
c58fa876-373a-45eb-bf69-4d52b6ffd257	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049321	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	2021-09-02	PORT2102-049321\nAffectation importée non résolue : Usager="-" ; Utilisateur="Camille BALLIN"	2026-08-27 13:34:52.949975+00	2026-08-27 13:34:52.949975+00	PORT2102-049321	\N	\N	\N	\N	f	f	F2102274 - 00947	929.00	\N	\N	2024-09-02	ESI0117	f
fe6856b0-1849-4398-ae59-ad764b021ca2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF2DJ1LM	LENOVO	81RG	assigned	\N	\N	2020-09-09	\N	2026-08-27 13:34:52.953256+00	2026-08-27 13:34:52.957172+00	PORT2006-NT3456	\N	\N	\N	\N	f	f	F2009220 - 05050	832.00	\N	\N	2023-09-09	ELY0142	f
6f748778-0842-4d84-bc3a-9b760d8723a6	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31441WQ	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:52.959204+00	2026-08-27 13:34:52.962439+00	PORT2306-1441WQ	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
9d1a98ed-f64d-4f91-9aac-2376a2bbd581	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049315	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049315	2026-08-27 13:34:52.964759+00	2026-08-27 13:34:52.967856+00	PORT2102-049315	\N	\N	\N	\N	f	f	F2102276 - 00949	929.00	\N	\N	2024-09-02	ELY0153	f
037068e9-deb1-4fbe-b2ef-7f6411822549	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440X5	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:52.969845+00	2026-08-27 13:34:52.972356+00	PORT2306-1440X5	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
cf8deb6b-8516-478d-9b38-d3246c8f2e04	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021731	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	2020-12-11	PORT2011-021731\nAffectation importée non résolue : Usager="-" ; Utilisateur="Maud HARASYMCZUK"	2026-08-27 13:34:52.973604+00	2026-08-27 13:34:52.973604+00	PORT2011-021731	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI0112	f
6d24978e-a850-4553-8495-e99363e9e188	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021837	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2011-021837	2026-08-27 13:34:52.975797+00	2026-08-27 13:34:52.979728+00	PORT2011-021837	\N	\N	\N	\N	f	f	F2011424 - 06614	929.00	\N	\N	1900-01-23	ELY0146	f
39c971e0-3bd5-4331-af5a-b4e0ef427bbf	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	0F0125T214701J	Microsoft Corporation	Surface Pro 8	assigned	\N	\N	2022-10-06	TABLET2206-T214701	2026-08-27 13:34:52.981972+00	2026-08-27 13:34:52.98479+00	TABLET-4O4IB02F	\N	\N	\N	\N	f	f	F22060337 - 04387	\N	\N	\N	2025-10-06	ELY0175	f
dd8ab4ed-8a2f-4f66-847e-afde756f91d6	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	726743-02R9200205	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	TABLET1904-200205\nAffectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:52.987094+00	2026-08-27 13:34:52.987094+00	PC-02R9200205	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-04	\N	f
522a1b49-abc5-4450-ad50-12b01a55aec0	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049316	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049316	2026-08-27 13:34:52.990274+00	2026-08-27 13:34:52.993857+00	PC-DSFD049316	\N	\N	\N	\N	f	f	F2102276 - 00949	939.00	\N	\N	2024-09-02	ELY0154	f
af266de1-1b7c-4650-8b16-cd2b38c0ea6a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049361	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049361	2026-08-27 13:34:52.995701+00	2026-08-27 13:34:52.999158+00	PORT2102-049361	\N	\N	\N	\N	f	f	F2102275-00948	929.00	\N	\N	2024-09-02	ESI0163	f
eece7d3f-d56e-4372-97a2-66a1a302fc4f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440NS	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:53.000889+00	2026-08-27 13:34:53.003006+00	PORT2306-1440NS	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
3e96ef10-35c3-4330-9e82-0e4c05846cbb	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009127	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:53.005203+00	2026-08-27 13:34:53.005203+00	PORT1808-D00912	\N	\N	\N	\N	f	f	F1808163-03676	870.00	\N	\N	2021-03-08	ELY0110	f
1d5911a4-c616-4704-b429-05ad29a83a59	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAX001834	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q7310	assigned	\N	\N	1900-01-23	TABLET2012-001834	2026-08-27 13:34:53.007885+00	2026-08-27 13:34:53.010117+00	PC-DSAX001834	\N	\N	\N	\N	f	f	F2011425 - 06615	1212.00	\N	\N	1900-01-23	ELY0149	f
43db6a8b-8ae8-4227-9972-a8821798c7aa	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009678	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:34:53.011762+00	2026-08-27 13:34:53.014303+00	PORT2202-009678	\N	\N	\N	\N	f	f	F22050452 - 03659	737.00	\N	\N	1900-01-24	ELY0174	f
181a91d3-4376-4cc5-8562-127d0276fab9	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021845	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	retired	\N	\N	1900-01-23	PORT2211-021845\nAffectation importée non résolue : Usager="Marie TOLVE" ; Utilisateur="-"	2026-08-27 13:34:53.015227+00	2026-08-27 13:34:53.015227+00	PORT2011-021845	\N	\N	\N	\N	f	f	F2011423-06613	929.00	\N	\N	1900-01-23	ESI0160	f
e65a99f9-f4fb-49f7-b656-9d6c4877d150	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049269	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-01-02	PORT2102-049269	2026-08-27 13:34:53.018165+00	2026-08-27 13:34:53.021122+00	PC-DSFD049269	\N	\N	\N	\N	f	f	F2102196-00869	929.00	\N	\N	2024-01-02	ESI0161	f
49086472-f6c6-41e6-b852-dd0ef0405d80	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009724	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	retired	\N	\N	1900-01-27	PORT2108-009724	2026-08-27 13:34:53.022298+00	2026-08-27 13:34:53.022298+00	PORT2108-009724	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
f14c5914-9608-4ea8-93b7-9fd1d7939093	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD077384	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-24	PORT2104-077384	2026-08-27 13:34:53.024505+00	2026-08-27 13:34:53.027109+00	PORT2104-077384	\N	\N	\N	\N	f	f	F21060389 - 04070	929.00	\N	\N	1900-01-24	ELY0165	f
678b79e4-fa8c-4ec3-a082-9dc485ecf7f1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049260	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-01-02	\N	2026-08-27 13:34:53.029045+00	2026-08-27 13:34:53.031746+00	PORT2102-049260	\N	\N	\N	\N	f	f	F2102196-00869	929.00	\N	\N	2024-01-02	ESI0161	f
1bb95ef1-0d8a-49b2-a86f-dc17e78b29b9	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD022069	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2020-12-11	PORT2011-022069	2026-08-27 13:34:53.033827+00	2026-08-27 13:34:53.036599+00	PORT2011-022069	\N	\N	\N	\N	f	f	F2011266-06456	929.00	\N	\N	2023-12-11	ESI0111	f
18a3859b-4d0e-4f0b-9948-5b298e855b20	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009126	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	PORT1808-009126	2026-08-27 13:34:53.037693+00	2026-08-27 13:34:53.037693+00	Port1808-009126	\N	\N	\N	\N	f	f	F1808164-03677	870.00	\N	\N	2021-03-08	ESI0067	f
55d0db34-9838-4ec0-9834-44b837e5bf3a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440WR	HP	HP ProBook 450 15.6 inch G9 Notebook PC	in_stock	\N	\N	1900-01-15	Affectation importée non résolue : Usager="-" ; Utilisateur="Joe CLEMENTE"	2026-08-27 13:34:53.039371+00	2026-08-27 13:34:53.039371+00	PORT2306-1440WR	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
2af7878e-e2b2-4481-a24f-09c2a2036f35	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021805	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2011-021805	2026-08-27 13:34:53.042246+00	2026-08-27 13:34:53.046565+00	PORT2011-021805	\N	\N	\N	\N	f	f	F2011424 - 06614	929.00	\N	\N	1900-01-23	ELY0145	f
b63b79e4-2984-48b4-9e7f-5b9fc6eec3e6	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029591	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	2021-01-10	PORT2110-029591	2026-08-27 13:34:53.048884+00	2026-08-27 13:34:53.051767+00	PORT2110-029591	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0173	f
e605805d-e7a7-442c-9e2e-6eaaa0eff96c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224SW8	HP	HP ProBook 450 15.6 inch G10 Notebook PC	assigned	\N	\N	1900-01-29	\N	2026-08-27 13:34:53.058193+00	2026-08-27 13:34:53.065335+00	PORT2309-224SW8	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
af1285bf-c332-42e9-9af3-3b6eab8a0a08	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	0F015EJ214701J	Microsoft Corporation	Surface Pro 8	assigned	\N	\N	2022-10-06	TABLET2206-14701J	2026-08-27 13:34:53.068561+00	2026-08-27 13:34:53.073063+00	PORT2308-14701J	\N	\N	\N	\N	f	f	F22060337 - 04387	1140.00	\N	\N	2025-10-06	ELY0175	f
1c14832d-a537-4b7a-b6a0-420fbcd500e3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSGJ005131	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5512	assigned	\N	\N	2023-05-12	\N	2026-08-27 13:34:53.075829+00	2026-08-27 13:34:53.079459+00	PORT2212-005131	\N	\N	\N	\N	f	f	0097449332	985.00	\N	\N	2024-05-12	ELY0188	f
a3305385-bb19-4933-9f6e-22d5f03a516f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029577	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:53.082042+00	2026-08-27 13:34:53.088971+00	PORT2110-029577	\N	\N	\N	\N	f	f	F22010429 - 00429	855.00	\N	\N	1900-01-30	ESI0171	f
f86cf8a2-6e34-4aee-981e-cd8e5cfde182	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31442J8	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:53.092315+00	2026-08-27 13:34:53.09554+00	PORT2306-1442J8	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
4f9c731c-3c4d-400e-8a03-44d73659ba2d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD077383	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	1900-01-24	\N	2026-08-27 13:34:53.096719+00	2026-08-27 13:34:53.096719+00	PORT2104-077383	\N	\N	\N	\N	f	f	F21060389 - 04070	929.00	\N	\N	1900-01-24	ELY0165	f
024a1a74-1fc3-47d8-91d3-6b4aad7ace3f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049404	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	2021-09-02	PORT2102-049404	2026-08-27 13:34:53.098393+00	2026-08-27 13:34:53.098393+00	PORT2102-049404	\N	\N	\N	\N	f	f	F2102274 - 00947	929.00	\N	\N	2024-09-02	ESI0118	f
152b0e83-880c-41b6-bd6a-7d08128910ad	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009709	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-27	PORT2108-009709\nAffectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Amandine DUMAS"	2026-08-27 13:34:53.10187+00	2026-08-27 13:34:53.10187+00	PORT2108-009709	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
b5f9e9b0-1f59-46e5-a2ac-4022f9e096f1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	G2YL3T3	Dell Inc.	XPS 15 9520	assigned	\N	\N	2022-05-12	PORT2212-2YL3T3	2026-08-27 13:34:53.105458+00	2026-08-27 13:34:53.109278+00	PORT2212-202212	\N	\N	\N	\N	f	f	0097449332	2344.00	\N	\N	2023-05-12	ELY0188	f
5465e0a0-bc30-486d-8aec-2d40d26b32f1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF29CW5L	LENOVO	81RG	retired	\N	\N	1900-01-24	\N	2026-08-27 13:34:53.110495+00	2026-08-27 13:34:53.110495+00	PORT2006-29CW5L	\N	\N	\N	\N	f	f	F2006296 - 03242	832.00	\N	\N	1900-01-24	ELY0137	f
50aa0f87-800d-4cf1-9518-330edbb0e518	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV010018	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	\N	2026-08-27 13:34:53.113141+00	2026-08-27 13:34:53.115807+00	PORT2108-010018	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
78583dc7-0c9b-4c80-bfa1-337fa7ebb00f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAP007337	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q739	assigned	\N	\N	2020-11-03	TABLET2003-007337	2026-08-27 13:34:53.118456+00	2026-08-27 13:34:53.123504+00	PORT2104-007337	\N	\N	\N	\N	f	f	\N	1780.00	\N	\N	2023-11-03	ESI0097	f
21757732-821e-41e8-a418-4dd154b530bf	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	726743-02R9200244	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-12	\N	2026-08-27 13:34:53.125954+00	2026-08-27 13:34:53.125954+00	PORT1912-200244	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-12	\N	f
24dddf52-34fb-4249-8e93-ea4d2383ea26	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3142PB7	HP	HP EliteBook 640 14 inch G9 Notebook PC	assigned	\N	\N	1900-01-20	\N	2026-08-27 13:34:53.131598+00	2026-08-27 13:34:53.136285+00	PORT2306-142PB7	\N	\N	\N	\N	f	f	FA00005184	879.00	\N	\N	1900-01-20	ELY0195	f
1219a818-ef0b-4898-ba13-5c86f6287f07	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029590	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-30	PORT2110-029590	2026-08-27 13:34:53.138778+00	2026-08-27 13:34:53.142403+00	PORT2110-029590	\N	\N	\N	\N	f	f	F22010429 - 00429	855.00	\N	\N	1900-01-30	ESI0171	f
4170c613-ca50-4d1b-9acf-3d818820ad97	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009725	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009725	2026-08-27 13:34:53.144262+00	2026-08-27 13:34:53.147854+00	PORT2108-009725	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
bbc398da-a59c-48b6-adb4-3a23343c4069	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFW001033	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q7311	in_stock	\N	\N	1900-01-27	TABLET2108-001033	2026-08-27 13:34:53.149195+00	2026-08-27 13:34:53.149195+00	PC-DSFW001033	\N	\N	\N	\N	f	f	\N	1253.00	\N	\N	1900-01-27	ESI0122	f
bb29bd81-7544-43e2-b883-685b20b1e3ee	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224TMT	HP	HP ProBook 450 15.6 inch G10 Notebook PC	in_stock	\N	\N	1900-01-29	Affectation importée non résolue : Usager="-" ; Utilisateur="Marie-Morgane PORTE"	2026-08-27 13:34:53.151393+00	2026-08-27 13:34:53.151393+00	PORT2308-224TMT	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
b08413cb-4d73-4ffc-872f-d8e12a0cd811	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009138	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	\N	2026-08-27 13:34:53.153936+00	2026-08-27 13:34:53.153936+00	PORT1808-009138	\N	\N	\N	\N	f	f	F1808163-03676	870.00	\N	\N	2021-03-08	ELY0108	f
88ddbf0d-a810-4039-9d47-ce998edd9521	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31440XR	HP	HP ProBook 450 15.6 inch G9 Notebook PC	in_stock	\N	\N	1900-01-15	Affectation importée non résolue : Usager="-" ; Utilisateur="Fayza NAJI"	2026-08-27 13:34:53.156102+00	2026-08-27 13:34:53.156102+00	PORT2306-1440XR	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
68f14ace-20c3-455a-b475-8c10e0f90df5	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029589	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-30	\N	2026-08-27 13:34:53.161744+00	2026-08-27 13:34:53.161744+00	PORT2110-029589	\N	\N	\N	\N	f	f	F22010431 - 00431	855.00	\N	\N	1900-01-30	ELY0169	f
9461d053-3df0-445f-b29f-1577b218b82e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD058979	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:53.165681+00	2026-08-27 13:34:53.169185+00	PORT2103-058979	\N	\N	\N	\N	f	f	F21040370 - 02563	929.00	\N	\N	1900-01-26	ELY0160	f
0a26dbe6-0851-42f8-a845-453b77cfb553	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224SSP	HP	HP ProBook 450 15.6 inch G10 Notebook PC	in_stock	\N	\N	1900-01-29	Affectation importée non résolue : Usager="Clara Mages" ; Utilisateur="-"	2026-08-27 13:34:53.17077+00	2026-08-27 13:34:53.17077+00	PORT2309-224SSP	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
3a688e2a-71e3-498f-ae5f-53a60c7820a2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD010770	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-04-09	PORT1808-010770	2026-08-27 13:34:53.173707+00	2026-08-27 13:34:53.173707+00	PORT1808-010770	\N	\N	\N	\N	f	f	F1809165-04158	870.00	\N	\N	2021-04-09	ELY0113	f
002f5e2a-5ebc-4801-b65d-302f83a5bd6c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSGJ005130	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5512	assigned	\N	\N	2022-05-12	\N	2026-08-27 13:34:53.177742+00	2026-08-27 13:34:53.181474+00	PORT2212-005130	\N	\N	\N	\N	f	f	0097449332	985.00	\N	\N	2023-05-12	ELY0188	f
81dfb95a-da97-41c4-b520-68bb0b08e0c2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD046638	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	in_stock	\N	\N	1900-01-26	PORT2102-046638\nAffectation importée non résolue : Usager="-" ; Utilisateur="Noémie SAMYCHETTY"	2026-08-27 13:34:53.182675+00	2026-08-27 13:34:53.182675+00	PORT2102-046638	\N	\N	\N	\N	f	f	F21040371-02564	929.00	\N	\N	1900-01-26	ESI0164	f
ebb7bbd0-41fa-4380-bd48-779e33c874ef	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31442FZ	HP	HP ProBook 450 15.6 inch G9 Notebook PC	in_stock	\N	\N	1900-01-15	Affectation importée non résolue : Usager="-" ; Utilisateur="Marine FORESTIER"	2026-08-27 13:34:53.18457+00	2026-08-27 13:34:53.18457+00	PORT2306-1442FZ	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
138bfd6a-95e6-47ea-ab0f-4197ef37b324	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAD009119	Fujitsu	LIFEBOOK E558	retired	\N	\N	2018-03-08	PORT1808-009119	2026-08-27 13:34:53.187495+00	2026-08-27 13:34:53.187495+00	PCNSE	\N	\N	\N	\N	f	f	F1808163-03676	870.00	\N	\N	2021-03-08	ELY0109	f
3cc5a77a-e73e-4b47-ad73-b50d425d158c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF1460D4	LENOVO	81RG	retired	\N	\N	1900-01-19	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:53.191307+00	2026-08-27 13:34:53.191307+00	PORT1906-1460D4	\N	\N	\N	\N	f	f	F1911287-06187	836.00	\N	\N	1900-01-19	ESI0153	f
fc2205e2-a6f2-4818-9035-3e0476267029	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	0F014J3222301J	Microsoft Corporation	Surface Pro 8	assigned	\N	\N	2023-05-12	\N	2026-08-27 13:34:53.198415+00	2026-08-27 13:34:53.201593+00	PORT2312-22301J	\N	\N	\N	\N	f	f	0097449332	999.00	\N	\N	2024-05-12	ELY0152	f
8e8da746-0646-45d1-8fec-6b489324bdc1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFS050184	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK U7411	assigned	\N	\N	1900-01-28	PORT2208-050184	2026-08-27 13:34:53.203833+00	2026-08-27 13:34:53.21034+00	PORT2208-050184	\N	\N	\N	\N	f	f	F22070907 - 05795	1264.00	\N	\N	1900-01-28	ELY0180	f
3c159178-24cf-49d0-a176-168cc7ac8e82	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD8513NHT	HP	HP ProBook 470 G5	assigned	\N	\N	1900-01-14	\N	2026-08-27 13:34:53.212544+00	2026-08-27 13:34:53.214993+00	DESKTOP-1L2M2B8	\N	\N	\N	\N	f	f	F1903259-01377	1139.00	\N	\N	1900-01-14	ESI0093	f
37dd8917-5863-4040-b447-8a7891a2cbf4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	0F011W7214701J	Microsoft Corporation	Surface Pro 8	retired	\N	\N	2022-10-06	TABLET2206-721470	2026-08-27 13:34:53.21589+00	2026-08-27 13:34:53.21589+00	PORT2211-VQK4CDJF	\N	\N	\N	\N	f	f	F22060337 - 04387	1140.00	\N	\N	2025-10-06	ELY0175	f
ce4138c1-9489-4500-a1ec-493e459f41d3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD90715P4	HP	HP ProBook 470 G5	assigned	\N	\N	1900-01-14	\N	2026-08-27 13:34:53.218248+00	2026-08-27 13:34:53.221058+00	PORT1903-0715P4	\N	\N	\N	\N	f	f	F1903260-01378	1139.00	\N	\N	1900-01-14	ESI0093	f
efcf8f14-0165-4861-9052-23d27746895e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	PF1KEH8M	LENOVO	81RG	assigned	\N	\N	1900-01-28	\N	2026-08-27 13:34:53.227981+00	2026-08-27 13:34:53.231107+00	PORT2006-NT3712	\N	\N	\N	\N	f	f	F1908291-04438	832.00	\N	\N	1900-01-28	ESI0145	f
f3114513-16c2-468b-87ce-40382530f2e5	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	726743-02R9200247	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:53.233212+00	2026-08-27 13:34:53.233212+00	TABLET1904-9200247	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-04	\N	f
fcd434c9-3df9-4df6-9d27-6d8a28758dcb	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD31441YR	HP	HP ProBook 450 15.6 inch G9 Notebook PC	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:53.235611+00	2026-08-27 13:34:53.238549+00	PORT2307-3144YR	\N	\N	\N	\N	f	f	FA00005171	739.00	\N	\N	1900-01-15	ELY0193	f
00457995-5d74-42b5-947b-2d0e9740f548	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD8513NK4	HP	HP ProBook 470 G5	assigned	\N	\N	2021-01-10	\N	2026-08-27 13:34:53.240406+00	2026-08-27 13:34:53.243472+00	PORT1903-513NK4	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2024-01-10	ESI0146	f
93a664d8-97e1-452e-8a4a-d438b4cdb461	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277200	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.784783+00	2026-08-27 13:34:53.787311+00	PORT2508-277200	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6e0871ac-b404-4ef0-9968-170cebd426e7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	726743-02R9400351	Fujitsu	STYLISTIC R727	retired	\N	\N	1900-01-12	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:53.245941+00	2026-08-27 13:34:53.245941+00	DESKTOP-44351F8	\N	\N	\N	\N	f	f	F1912281-06793	1266.00	\N	\N	1900-01-12	ESI0081	f
ef33e0ad-e212-4d07-94ea-145f2139e51e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	023305172053	Microsoft Corporation	Surface Pro	retired	\N	\N	1900-01-18	\N	2026-08-27 13:34:53.334162+00	2026-08-27 13:34:53.334162+00	SURFACELRZ	\N	\N	\N	\N	f	f	0094308601	1199.00	\N	\N	1900-01-18	ELY0100	f
83db4f4a-0924-45af-96ed-7ae3ab49d520	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	726743-02R9200030	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:53.338055+00	2026-08-27 13:34:53.338055+00	PC-02R9200030	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-04	\N	f
32bb0082-e93f-4972-a53d-b2ea790ee35d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAP007778	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q739	assigned	\N	\N	2020-10-06	TABLET2006-007778	2026-08-27 13:34:53.341225+00	2026-08-27 13:34:53.344767+00	PORT2006-007778	\N	\N	\N	\N	f	f	\N	1211.00	\N	\N	2023-10-06	ESI0102	f
7ffbea4b-5264-4e40-9e88-88008c26a458	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	726743-02R9200181	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	TABLET1904-200181	2026-08-27 13:34:53.345876+00	2026-08-27 13:34:53.345876+00	PC-02R9200181	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	2022-01-04	\N	f
3577a01d-0c99-4d80-8a2e-b5045e74eb17	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD058981	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:53.348242+00	2026-08-27 13:34:53.350731+00	PORT2103-058981	\N	\N	\N	\N	f	f	F21040372 - 02565	929.00	\N	\N	1900-01-26	ESI0119	f
5b746d1e-4e93-4c36-9e2f-cb886b53a917	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	726743-02R9200266	Fujitsu	STYLISTIC R727	retired	\N	\N	2019-01-04	TABLET1904-200266\nAffectation importée non résolue : Usager="amteixeira@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:53.357639+00	2026-08-27 13:34:53.357639+00	DESKTOP-SM1TPSO	\N	\N	\N	\N	f	f	Credit Bail StarLease	0.00	\N	\N	2022-01-04	ESI0176	f
65861362-3d13-4f8d-b50c-bbc6a6d59c0b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV010285	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-24	PORT2202-010285	2026-08-27 13:34:53.360214+00	2026-08-27 13:34:53.360214+00	PORT2202-010285	\N	\N	\N	\N	f	f	F22050452 - 03659	737.00	\N	\N	1900-01-24	ELY0174	f
6e0224c9-b431-4710-89be-0703ae58c278	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD049272	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	2021-09-02	PORT2102-049272	2026-08-27 13:34:53.363311+00	2026-08-27 13:34:53.366543+00	PORT2102-049272	\N	\N	\N	\N	f	f	F2102274 - 00947	0.00	\N	\N	2024-09-02	ESI0116	f
e40db4b7-8e1d-4991-aaac-7a9ee69eea76	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	726743-02R9500024	Fujitsu	STYLISTIC R727	retired	\N	\N	1900-01-12	TABLET1912-500024	2026-08-27 13:34:53.368603+00	2026-08-27 13:34:53.368603+00	DESKTOP-QTBS0JN	\N	\N	\N	\N	f	f	F1912284-06793	1266.00	\N	\N	1900-01-12	ESI0080	f
b19e9411-a4bd-41e1-850c-f3f2c6700c48	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009723	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	assigned	\N	\N	1900-01-27	PORT2108-009723	2026-08-27 13:34:53.371406+00	2026-08-27 13:34:53.374311+00	PORT2108-009723	\N	\N	\N	\N	f	f	F21090424-06263	919.00	\N	\N	1900-01-27	ESI0128	f
9eafdef3-e61a-4db7-9845-4fcc9e6992ce	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD2236FCX	HP	HP EliteBook 640 14 inch G9 Notebook PC	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:34:53.375844+00	2026-08-27 13:34:53.381741+00	PORT2304-5CD2236FCX	\N	\N	\N	\N	f	f	\N	1007.49	\N	\N	1900-01-24	ESI0174	f
e33b2872-d39e-48c8-8a15-a1c603ae3755	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3224TW4	HP	HP ProBook 450 15.6 inch G10 Notebook PC	assigned	\N	\N	1900-01-29	\N	2026-08-27 13:34:53.389944+00	2026-08-27 13:34:53.393052+00	PORT2309-224TW4	\N	\N	\N	\N	f	f	FA00005292	839.00	\N	\N	1900-01-29	ELY0196	f
46f70a91-d12f-43d8-9420-12b5af5bfb13	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFD021765	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5510	assigned	\N	\N	1900-01-23	PORT2011-021765	2026-08-27 13:34:53.396137+00	2026-08-27 13:34:53.405983+00	PORT2011-021765	\N	\N	\N	\N	f	f	F2011423-06613	929.00	\N	\N	1900-01-23	ESI160	f
8337a713-3f9a-4ac3-8849-ee1492216162	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	5CD3212JK8	HP	HP EliteBook 640 14 inch G9 Notebook PC	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:34:53.415331+00	2026-08-27 13:34:53.418769+00	PORT2306-212JK8	\N	\N	\N	\N	f	f	FA00005189	879.00	\N	\N	1900-01-22	ELY0194	f
77f318aa-c3a1-4077-95c0-71c0c7b81c12	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029587	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-30	PORT2110-029587\nAffectation importée non résolue : Usager="-" ; Utilisateur="Hugo NAKACHE"	2026-08-27 13:34:53.419756+00	2026-08-27 13:34:53.419756+00	PC-DSFV029587	\N	\N	\N	\N	f	f	F22010431 - 00431	855.00	\N	\N	1900-01-30	ELY0169	f
17e15325-02ac-475a-b59d-e8bd7b596c43	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAX005095	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q7310	in_stock	\N	\N	1900-01-20	\N	2026-08-27 13:34:53.421234+00	2026-08-27 13:34:53.421234+00	PORT2106-005095	\N	\N	\N	\N	f	f	F21050339 - 03272	1253.00	\N	\N	1900-01-20	ELY0164	f
5cae8788-9661-4b7e-bbcf-bdeccae33f88	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV009353	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-27	Affectation importée non résolue : Usager="-" ; Utilisateur="Clara GRANGER"	2026-08-27 13:34:53.422763+00	2026-08-27 13:34:53.422763+00	PORT2108-009353	\N	\N	\N	\N	f	f	F21090423 - 06262	919.00	\N	\N	1900-01-27	ELY0168	f
64443c29-213a-4bc5-9f8d-3331f07eda74	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7FQF	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:53.424322+00	2026-08-27 13:34:53.424322+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
c42e1ab1-6640-46f3-803e-d4e8d4f71606	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAP012214	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q739	in_stock	\N	\N	1900-01-21	TABLET2006-007778	2026-08-27 13:34:53.425964+00	2026-08-27 13:34:53.425964+00	PC-DSAP012214	\N	\N	\N	\N	f	f	F2007321-03913	1211.00	\N	\N	1900-01-21	ESI0158	f
b6adc1cd-7875-454b-8a0e-4f4c33014566	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7606999	Wortmann_AG	FR1220785;1470505	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.429077+00	2026-08-27 13:34:53.43331+00	PORT2401-606999	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
f514af8e-39c8-421f-95d7-574217b98dc7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677188	Wortmann_AG	FR1220781;1470458	in_stock	\N	\N	1900-01-23	Affectation importée non résolue : Usager="-" ; Utilisateur="Andy Touré"	2026-08-27 13:34:53.436627+00	2026-08-27 13:34:53.436627+00	PORT2401-677188	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
1d99dbd8-e4e5-45e6-9111-aad407d4474c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677124	Wortmann_AG	FR1220781;1470458	in_stock	\N	\N	1900-01-23	Affectation importée non résolue : Usager="-" ; Utilisateur="Suheda LEKESIZ"	2026-08-27 13:34:53.438815+00	2026-08-27 13:34:53.438815+00	PORT2401-677124	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
516dd723-56df-43d4-b197-22ee090116fc	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677191	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.442711+00	2026-08-27 13:34:53.446165+00	PORT2401-677191	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
e0801194-7e94-4547-8d66-8f6c2bd667eb	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677186	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.448449+00	2026-08-27 13:34:53.451579+00	PORT2401-677186	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
a4d4e8dd-b9a9-4055-a6b8-b9ad3f35ecac	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677247	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.454073+00	2026-08-27 13:34:53.457115+00	PORT2401-677247	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
5c8becb4-845f-451d-bb68-0979aaca1f7f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677205	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.458775+00	2026-08-27 13:34:53.461222+00	PORT2401-677205	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
143cb44d-ef7c-4a0d-b09d-435efae0be9e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677194	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.462891+00	2026-08-27 13:34:53.472057+00	Port2401-677194	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
ff7ba96b-d25b-413b-a4fb-cae2d0ea9a21	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677213	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.473899+00	2026-08-27 13:34:53.476499+00	PORT2401-677213	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
8645c53b-95f9-40d1-ad0b-9be9ae13740a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677217	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.47844+00	2026-08-27 13:34:53.480993+00	PORT2401-677217	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
def9abee-b726-4bdf-a932-72b5adec9a25	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7677198	Wortmann_AG	FR1220781;1470458	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.482781+00	2026-08-27 13:34:53.485087+00	PORT2401-677199	\N	\N	\N	\N	f	f	FA2401-8370	690.00	\N	\N	1900-01-23	\N	f
f35ed7a2-8cdc-44ab-b345-562144e94b10	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSAP012214	FUJITSU CLIENT COMPUTING LIMITED	STYLISTIC Q739	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.486889+00	2026-08-27 13:34:53.489359+00	PORT2008-012214	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
daa845a3-7511-487e-af14-c8e35b323905	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7796999	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:53.491674+00	2026-08-27 13:34:53.494194+00	PORT2406-220781	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
bdf1401b-712d-4ea2-a225-31d04b36e8fd	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7796941	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:53.498135+00	2026-08-27 13:34:53.500848+00	PORT2406-796941	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
95db9d80-28c0-478f-8f46-1b2c07bcf0cc	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7797057	Wortmann_AG	FR1220781;1470608	in_stock	\N	\N	1900-01-26	\N	2026-08-27 13:34:53.502026+00	2026-08-27 13:34:53.502026+00	PORT2406-797057	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
55d32f7e-3b10-4d21-a2d3-59252245b1a4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7796939	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:53.504225+00	2026-08-27 13:34:53.507053+00	PORT2406-779693	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
191c69b3-6497-4198-9514-beb198745fc4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7797059	Wortmann_AG	FR1220781;1470608	in_stock	\N	\N	1900-01-26	Affectation importée non résolue : Usager="ldellaccio@ELYADE" ; Utilisateur="Margaux AUJOULAT"	2026-08-27 13:34:53.513507+00	2026-08-27 13:34:53.513507+00	PORT2406-797059	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
31191980-0dcd-4582-ad84-715326f8014f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7797118	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:53.517323+00	2026-08-27 13:34:53.520565+00	PORT2406-797118	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
d9679bad-165b-4d03-bf22-481928570167	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7796993	Wortmann_AG	FR1220781;1470608	in_stock	\N	\N	1900-01-26	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Emmeline FLORENTIN"	2026-08-27 13:34:53.522826+00	2026-08-27 13:34:53.522826+00	PORT2406-796993	\N	\N	\N	\N	f	f	FA2406-8976	690.00	\N	\N	1900-01-26	\N	f
49cac870-d5c7-4f13-a78a-0a931964086e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	DSFV029551	FUJITSU CLIENT COMPUTING LIMITED	LIFEBOOK E5511	in_stock	\N	\N	1900-01-30	Affectation importée non résolue : Usager="-" ; Utilisateur="Elodie DE BIASI"	2026-08-27 13:34:53.524641+00	2026-08-27 13:34:53.524641+00	PORT2110-029551	\N	\N	\N	\N	f	f	F22010429 - 00429	855.00	\N	\N	1900-01-30	ESI0171	f
d69da791-bfc6-4fc5-865b-5199fba7f1e1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7831796	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.527265+00	2026-08-27 13:34:53.531429+00	PORT2407-831796	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
42610d67-e0b2-4acc-b6e6-726a9680930c	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7831802	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.533626+00	2026-08-27 13:34:53.542618+00	PORT2407-831802	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
51dd2ab7-d2fb-487d-ac43-4645752170a4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7928836	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.548263+00	2026-08-27 13:34:53.551595+00	PORT2410-928836	\N	\N	\N	\N	f	f	FA2410-9486	730.55	\N	\N	1900-01-23	\N	f
9134feee-bfab-49ba-9e2a-3fdfcc7ce99a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890114	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.554599+00	2026-08-27 13:34:53.557523+00	PORT2410-890110	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
58bbc3cf-3b06-481b-ba46-9e7fa81df80d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7928826	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.559657+00	2026-08-27 13:34:53.563741+00	PORT2410-928826	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
ff8f3f58-9541-4fb8-a452-1a8f488cd897	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890102	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.566197+00	2026-08-27 13:34:53.570747+00	PORT2410-890102	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
34707b2e-f021-4532-8a02-707af3f75b5b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890136	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.574756+00	2026-08-27 13:34:53.577544+00	PORT2410-890136	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
2332c644-63a5-493c-9085-3072d27fb2e8	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890116	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.579683+00	2026-08-27 13:34:53.583017+00	PORT2410-890116	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
320305cd-317b-4514-bc3d-ef0513519072	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890019	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.585122+00	2026-08-27 13:34:53.587877+00	PORT2410-890019	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
65e3c11a-63d3-4de2-8015-34641eb2449d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7890115	Wortmann_AG	FR1220781;1470693	assigned	\N	\N	1900-01-23	\N	2026-08-27 13:34:53.590033+00	2026-08-27 13:34:53.592702+00	PORT2410-890115	\N	\N	\N	\N	f	f	FA2410-9486	0.00	\N	\N	1900-01-23	\N	f
e2db242f-8a83-4e3d-9913-5abcbbe0e88a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021268	Wortmann_AG	FR1220781;1470608	in_stock	\N	\N	2025-04-02	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Raphael ABEILLE"	2026-08-27 13:34:53.594869+00	2026-08-27 13:34:53.594869+00	PORT2502-021268	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
d20f53f2-0732-4a87-93ef-198426e5ceb7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021278	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.597288+00	2026-08-27 13:34:53.599791+00	PORT2502-021278	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
b1b790c0-3575-4962-a78d-2f9ff5ca0f50	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021288	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.601971+00	2026-08-27 13:34:53.604727+00	PORT2502-021288	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
54e31116-b850-4e93-a223-9e37e45e6c10	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021290	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.607243+00	2026-08-27 13:34:53.611014+00	PORT2502-021290	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
13f1b5ee-a856-4976-9f6e-8a778d91895e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021203	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.617021+00	2026-08-27 13:34:53.636886+00	PORT2502-021203	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
a7f14800-6acb-43c3-89b1-588908ee1d4d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021280	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.640011+00	2026-08-27 13:34:53.643466+00	PORT2502-021280	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
9be269a5-41d6-4743-b727-3dcb3a5de764	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7992500	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.645629+00	2026-08-27 13:34:53.648863+00	PORT2502-992500	\N	\N	\N	\N	f	f	FA2502-09996	769.00	\N	\N	2027-04-02	\N	f
2e889df1-9268-4d06-b700-689a7c7e48b4	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7992501	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.651247+00	2026-08-27 13:34:53.65416+00	PORT2502-992501	\N	\N	\N	\N	f	f	FA2502-09996	769.00	\N	\N	2027-04-02	\N	f
6b33507b-4a3e-4bc7-a66d-906be4df5722	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7992484	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.656358+00	2026-08-27 13:34:53.658839+00	PORT2502-992484	\N	\N	\N	\N	f	f	FA2502-09996	769.00	\N	\N	2027-04-02	\N	f
34464df0-afcb-48d2-ab3b-fc2af7f93636	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021285	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.66048+00	2026-08-27 13:34:53.663398+00	PORT2504-021285	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
2245c41c-f393-45d6-9ab0-325231c89370	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8021279	Wortmann_AG	FR1220781;1470608	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.665339+00	2026-08-27 13:34:53.667785+00	PORT2502-021279	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
f147b454-3547-4867-8047-b2ba0c19f7ce	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R7992623	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-04-02	\N	2026-08-27 13:34:53.684221+00	2026-08-27 13:34:53.69363+00	PORT2502-992623	\N	\N	\N	\N	f	f	FA2502-09996	709.00	\N	\N	2027-04-02	\N	f
a70ccb6d-dacd-4a7a-8048-22640b59303e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8060603	Wortmann_AG	FR1220785;1470554	in_stock	\N	\N	2025-11-04	Affectation importée non résolue : Usager="-" ; Utilisateur="Jerome DUVAL"	2026-08-27 13:34:53.695482+00	2026-08-27 13:34:53.695482+00	PORT2504-060603	\N	\N	\N	\N	f	f	\N	769.00	\N	\N	2027-11-04	\N	f
66787249-6176-48f7-a721-1efdd217b5a2	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8060609	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	2025-11-04	\N	2026-08-27 13:34:53.700108+00	2026-08-27 13:34:53.704131+00	PORT2504-060609	\N	\N	\N	\N	f	f	\N	769.00	\N	\N	2027-11-04	\N	f
75df0e44-77fe-473f-8936-95f2aa5c4277	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8081344	Wortmann_AG	FR1220829;1470878	in_stock	\N	\N	2025-11-04	\N	2026-08-27 13:34:53.705597+00	2026-08-27 13:34:53.705597+00	PORT2504-081344	\N	\N	\N	\N	f	f	\N	739.00	\N	\N	2027-11-04	\N	f
88087761-37b8-4b5e-a28a-2cab423a40e1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8081499	Wortmann_AG	FR1220829;1470878	assigned	\N	\N	2025-11-04	\N	2026-08-27 13:34:53.708604+00	2026-08-27 13:34:53.712546+00	PORT2504-081499	\N	\N	\N	\N	f	f	\N	739.00	\N	\N	2027-11-04	\N	f
f1f2e731-adf7-4cec-b5e6-312a09eb5307	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8204608	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.715134+00	2026-08-27 13:34:53.718841+00	PORT2506-204608	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a7c516d4-bb58-420d-9ff7-3e85a4c7286e	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8204615	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.721954+00	2026-08-27 13:34:53.725042+00	PORT2506-204615	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5f89463c-d26d-4e63-9f21-76f4ee33f07f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8204527	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.728068+00	2026-08-27 13:34:53.730944+00	PORT2506-204527	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1881b9ec-f2ea-44f0-8a5b-005b93555383	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8204533	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.73292+00	2026-08-27 13:34:53.73567+00	PORT2506-204533	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
33541b62-4d5a-4922-a706-8ad5612d89fa	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8190643	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.738289+00	2026-08-27 13:34:53.740925+00	PORT2506-190643	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
401dceaa-05e5-4ba1-96e9-bd39de241a78	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	WM36013UV2000166	Wortmann_AG	Terra mobile 360-13U v2	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.7427+00	2026-08-27 13:34:53.744803+00	PORT2506-606999	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b9a9f710-b4a8-4772-ad54-d407d377144a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8190651	Wortmann_AG	FR1220785;1470554	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.746591+00	2026-08-27 13:34:53.749083+00	PORT2506-190651	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f78a8520-629e-4bf9-b864-357108320be3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277162	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.751761+00	2026-08-27 13:34:53.755212+00	PORT2508-277162	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ecab88aa-b8b4-410c-8dfb-9b386f97ef0b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277188	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.756865+00	2026-08-27 13:34:53.760576+00	PORT2508-277188	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
640736ff-5468-4a75-97de-2da70bc803f3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277184	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.766155+00	2026-08-27 13:34:53.769981+00	PORT2508-277184	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0ce67e89-0384-4f12-a98d-ce64ce41a306	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277189	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.772526+00	2026-08-27 13:34:53.781726+00	PORT2508-277189	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
456a5263-49df-43c3-9f40-d386ecde1805	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXC4D	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.012708+00	2026-08-27 13:34:56.012708+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5b6c25e7-c169-4ba7-be16-54fc5adafde8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXE7X	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.014581+00	2026-08-27 13:34:56.014581+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
05453c21-2298-435e-b9f4-6abb052fff50	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277201	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.794529+00	2026-08-27 13:34:53.798349+00	PORT2508-277201	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
46c35970-2a38-4d0a-8b9b-a3c8efd1811a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8226112	Wortmann_AG	FR1220852;1470935	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.800969+00	2026-08-27 13:34:53.804265+00	PORT2508-226112	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5532b069-c6c7-41a4-b113-0a5cda517633	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8226133	Wortmann_AG	FR1220852;1470935	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.806386+00	2026-08-27 13:34:53.809101+00	PORT2508-226133	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f80b1d8d-9889-4071-8def-1b064133395b	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8277190	Wortmann_AG	FR1220851;1470928	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.811467+00	2026-08-27 13:34:53.814743+00	PORT2508-277190	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
093587af-c04a-4805-9d77-1629c7e438a9	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380475	Wortmann_AG	FR1220831;1470889	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Paul MIANE"	2026-08-27 13:34:53.820965+00	2026-08-27 13:34:53.820965+00	PORT2511-380475	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ed4bd1a1-8960-48f9-ae03-e8210ca3761f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380481	Wortmann_AG	FR1220831;1470889	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="fcatourze@ELYADE" ; Utilisateur="Grégoire MASSAT"	2026-08-27 13:34:53.835955+00	2026-08-27 13:34:53.835955+00	PORT2511-380481	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
84a759a7-5a75-4bca-9c28-745be28f10b3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380519	Wortmann_AG	FR1220831;1470889	in_stock	\N	\N	\N	\N	2026-08-27 13:34:53.841762+00	2026-08-27 13:34:53.841762+00	PORT2511-380519	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
60f697cd-70f9-41fd-9057-037a2d9cb85d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380528	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.84637+00	2026-08-27 13:34:53.857973+00	PORT2511-380528	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
44a2b8b4-f347-4e6d-b203-710bc54530c7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380483	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.862634+00	2026-08-27 13:34:53.870226+00	PORT2511-380483	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
11ba9471-b5d3-40be-966b-14cd08383bc7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380485	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.878436+00	2026-08-27 13:34:53.888476+00	PORT2511-380485	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
271e7b6b-c778-4fbd-95b4-87b32ef48237	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380474	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.899616+00	2026-08-27 13:34:53.904826+00	PORT2511-380474	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8aea5165-c34e-4678-8342-db8dd03fc5b1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380489	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.907643+00	2026-08-27 13:34:53.913193+00	PORT2511-380489	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
acdc08f6-9f1f-41b2-bc2f-081a3f75dfe3	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380525	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.918523+00	2026-08-27 13:34:53.932162+00	PORT2511-380525	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
245140ec-b622-4764-a504-dac09b233ba5	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380488	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.935495+00	2026-08-27 13:34:53.942659+00	PORT2511-380488	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8fae0f30-6d42-48e3-97dc-6db44c40f971	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380463	Wortmann_AG	FR1220831;1470889	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Quizz@PORT2511-380463" ; Utilisateur="Laetitia COUZINIER"	2026-08-27 13:34:53.947903+00	2026-08-27 13:34:53.947903+00	PORT2511-380463	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
56ad9ab8-c2ae-4272-ae22-60fd206b27c1	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380520	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.951853+00	2026-08-27 13:34:53.957104+00	PORT2511-380520	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
79a5c594-0ec3-4307-be00-d237235bf88a	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380482	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.960712+00	2026-08-27 13:34:53.966155+00	PORT2511-380482	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4b9bd32c-4879-4e7d-9554-b610b119de9d	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8226104	Wortmann_AG	FR1220852;1470935	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.969731+00	2026-08-27 13:34:53.97508+00	PORT2508-226104	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4b8a4316-a387-4c08-a375-16e282b6c1ea	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380473	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.978545+00	2026-08-27 13:34:53.985001+00	PORT2511-380473	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
1f4f7815-5780-4e28-9d4f-c26b47b041e7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8380490	Wortmann_AG	FR1220831;1470889	assigned	\N	\N	\N	\N	2026-08-27 13:34:53.988635+00	2026-08-27 13:34:53.994747+00	PORT2511-380490	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
d7feb6a1-8c20-437e-b3c3-6279300efdec	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7321	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:34:53.998847+00	2026-08-27 13:34:54.008369+00	PL2492H	\N	\N	\N	\N	f	f	F2102276 - 00949	152.00	\N	\N	2022-09-02	ELY0154	f
c31eb2a7-50a5-4a84-8055-12f4341e05cb	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187723630817	Iiyama North America	PL2493H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="Grégoire MASSAT"	2026-08-27 13:34:54.084102+00	2026-08-27 13:34:54.084102+00	PL2493H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4a95adbf-48b4-4c1b-8ca9-d89d401c670f	3981e88a-85b7-4a12-9342-dca750713f52	\N	11673JMA00519	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.086497+00	2026-08-27 13:34:54.103508+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5f6189b9-2d15-4e37-8ca1-1add87fa4bd9	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4463	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.106774+00	2026-08-27 13:34:54.112186+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
aee1488d-8595-4d20-a339-bb6062cb8ccd	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1017	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:34:54.114032+00	2026-08-27 13:34:54.119012+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
2eb60f2f-b602-467a-a632-60018ef6f76f	3981e88a-85b7-4a12-9342-dca750713f52	\N	GMBKCHA140743	AOC International (USA) Ltd.	24P1X	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.122123+00	2026-08-27 13:34:54.126823+00	24P1X	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9c836810-6026-4f9d-acdb-52bebf345f82	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067060	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.128296+00	2026-08-27 13:34:54.132574+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
78a4baf2-9ba0-4261-89bd-b086139288ec	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6943	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:34:54.147002+00	2026-08-27 13:34:54.151816+00	PL2492H	\N	\N	\N	\N	f	f	F21050250-03183	158.00	\N	\N	2022-11-05	ESI0165	f
29e4c2a2-6c7a-4f1c-999d-af679646ba85	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN43022L0Z	HPN	HP E24 G5	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.154638+00	2026-08-27 13:34:54.1574+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
674718a5-74c0-422e-9117-c1ba1622591e	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T848782	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.158793+00	2026-08-27 13:34:54.16104+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
863bab11-442e-4180-8d59-d5a2f07a5942	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1698	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.16276+00	2026-08-27 13:34:54.164737+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0337860c-aa5c-4040-830b-a3fed4d7f5db	3981e88a-85b7-4a12-9342-dca750713f52	\N	RH81R92K11HI	Dell Inc.	DELL P2217H	in_stock	\N	\N	\N	\N	2026-08-27 13:34:54.165478+00	2026-08-27 13:34:54.165478+00	DELL P2217H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
233c84c7-829f-4d7e-a768-9e3deaa74f12	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1682	Iiyama North America	PL2492H	in_stock	\N	\N	\N	\N	2026-08-27 13:34:54.16651+00	2026-08-27 13:34:54.16651+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d44c88f9-27e9-46b0-b419-e62d5f256702	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T830126	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.168305+00	2026-08-27 13:34:54.170191+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7d967657-7e3e-4bac-8b54-f14a4df8c46d	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE004873	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.172924+00	2026-08-27 13:34:54.176311+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
eb634718-dfef-4fd4-9a1e-55b7a389ebcf	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1016	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:34:54.177275+00	2026-08-27 13:34:54.183542+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-01	ESI0124	f
1e6c0dd0-2c22-4e25-98a1-88eeabe577e8	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE024307	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:54.185388+00	2026-08-27 13:34:54.188761+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1805318-02344	176.00	\N	\N	1900-01-30	ESI0064	f
ae879cf9-8457-4209-9f6f-42701968fbce	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T805642	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.192156+00	2026-08-27 13:34:54.195613+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d1018d75-0da4-4d25-aa2f-1ddfa9a66051	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V167154	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.197833+00	2026-08-27 13:34:54.200783+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f80e365d-b76e-4e2f-8560-ece799aa4d0f	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4478	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.202081+00	2026-08-27 13:34:54.205024+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
8dcb2885-3e74-4c4f-b3b0-3241dbc0cb43	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7309	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:34:54.206403+00	2026-08-27 13:34:54.209254+00	PL2492H	\N	\N	\N	\N	f	f	F2102274 - 00947	152.00	\N	\N	2022-09-02	ESI0116	f
c8f27913-d90a-412a-ba7a-85875dab9d69	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C4010	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:34:54.211516+00	2026-08-27 13:34:54.215022+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0111	f
8e09d9b2-1a17-420c-8e43-7473e83dbe72	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C7007	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:34:54.217296+00	2026-08-27 13:34:54.220282+00	PL2492H	\N	\N	\N	\N	f	f	F21050247 - 03180	158.00	\N	\N	2022-11-05	ELY0161	f
79e5466d-8771-4719-8c93-805ff47690e4	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4477	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.222114+00	2026-08-27 13:34:54.225613+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
534ab566-d640-4ca6-8df1-80c337c72676	3981e88a-85b7-4a12-9342-dca750713f52	\N	V0VCM1CM111S	Dell Inc.	DELL P2212H	retired	\N	\N	\N	\N	2026-08-27 13:34:54.228066+00	2026-08-27 13:34:54.228066+00	DELL P2212H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d4febde3-7b0a-4634-b160-41a50bac29b5	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T808176	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:34:54.233993+00	2026-08-27 13:34:54.251154+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1911287-06187	168.00	\N	\N	1900-01-19	ESI0074	f
02b8aaf4-a1df-415c-87d0-395ce15ba605	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7314	Iiyama North America	PL2492H	in_stock	\N	\N	2021-09-02	Affectation importée non résolue : Usager="fcatourze@ELYADE" ; Utilisateur="Frédéric CATOURZE"	2026-08-27 13:34:54.255178+00	2026-08-27 13:34:54.255178+00	PL2492H	\N	\N	\N	\N	f	f	F2102276 - 00949	152.00	\N	\N	2022-09-02	ELY0153	f
0e00b371-9a6b-4dda-86e6-70b7173a93c6	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T830125	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:34:54.264099+00	2026-08-27 13:34:54.269365+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1911287-06187	168.00	\N	\N	1900-01-19	ESI0075	f
04e6391b-35a3-4c2e-a405-a46d56513493	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187714704538	Iiyama North America	PL2493H	assigned	\N	\N	2022-10-06	\N	2026-08-27 13:34:54.274576+00	2026-08-27 13:34:54.279909+00	PL2493H	\N	\N	\N	\N	f	f	F22060338 - 04388	181.00	\N	\N	2023-10-06	ELY0176	f
509d6068-210e-42a9-985c-404b20564105	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE024280	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:54.284033+00	2026-08-27 13:34:54.293297+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1805318-2344	176.00	\N	\N	1900-01-30	ESI0062	f
d2112566-71a4-42e0-a7c7-fa0c476e581b	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V115843	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.299891+00	2026-08-27 13:34:54.305186+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
951c8cb3-44a0-4a53-9ee6-c0f593f713bd	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066908	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-28	\N	2026-08-27 13:34:54.309287+00	2026-08-27 13:34:54.31473+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903379-01497	155.00	\N	\N	1900-01-28	ELY0120	f
a3819038-14a8-4b5f-85a1-2e7e181c3a09	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC631326	Fujitsu Siemens Computers GmbH	B24-9 TS	assigned	\N	\N	1900-01-14	\N	2026-08-27 13:34:54.318902+00	2026-08-27 13:34:54.32758+00	B24-9 TS	\N	\N	\N	\N	f	f	F22060363 - 04413	224.00	\N	\N	1900-01-14	ESI0169	f
b0b49c3d-4ac7-4e83-82e3-732c1501e08d	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511153D2300	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:34:54.330791+00	2026-08-27 13:34:54.341359+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
f20b5fbf-959a-4d50-ab2e-6f612924f273	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T870628	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	in_stock	\N	\N	1900-01-28	\N	2026-08-27 13:34:54.344045+00	2026-08-27 13:34:54.344045+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F2006326-03272	180.00	\N	\N	1900-01-28	ESI0156	f
a9fd3f37-129e-4a44-82ad-43eb29419068	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC607974	Fujitsu Siemens Computers GmbH	B24-9 TS	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:34:54.347512+00	2026-08-27 13:34:54.353735+00	B24-9 TS	\N	\N	\N	\N	f	f	F2008275 - 04507	180.00	\N	\N	1900-01-19	ELY0140	f
fd3e8ac2-aab5-42be-a43d-d1ce5bd9824a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00273	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.359291+00	2026-08-27 13:34:54.365458+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d1455b42-a3bf-4503-b3c5-8a64c447d763	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00855	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.369303+00	2026-08-27 13:34:54.374575+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
935fa874-4203-44b7-9084-ae3962fb0aea	3981e88a-85b7-4a12-9342-dca750713f52	\N	CNC2390F58	HPN	HP E24m G4	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.379231+00	2026-08-27 13:34:54.384478+00	HP E24m G4	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4d87c94b-6a18-42a3-b936-84846fceba68	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889207	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:54.391251+00	2026-08-27 13:34:54.405856+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F22010431 - 00431	224.00	\N	\N	1900-01-30	ELY0169	f
24aa8bec-6ffc-4a7f-9029-6f564333eaa7	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6938	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:34:54.40985+00	2026-08-27 13:34:54.415165+00	PL2492H	\N	\N	\N	\N	f	f	F21050251 - 03184	158.00	\N	\N	2022-11-05	ELY0162	f
19eb9940-44aa-4f30-aee4-f6b1be10e2ba	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C7014	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.41903+00	2026-08-27 13:34:54.433391+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
07eba368-54f6-4c37-b37a-7860f19bce50	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511201D1865	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.438046+00	2026-08-27 13:34:54.443227+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4434303d-4b54-422b-9044-0813c8ef4257	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829992	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:34:54.446658+00	2026-08-27 13:34:54.451884+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0090	f
d1aed294-0b36-423c-bd6a-fbaea1e6a839	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T361611	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.45604+00	2026-08-27 13:34:54.462037+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3598c520-0833-429a-817b-fa5c57f15e15	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807804	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.469357+00	2026-08-27 13:34:54.474693+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a6b3b21e-397b-4cf6-8e14-fbdb5fc77bc9	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4460	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.478774+00	2026-08-27 13:34:54.485182+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
5c242866-771f-41ba-a8cc-7dcae3998473	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829985	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:34:54.489103+00	2026-08-27 13:34:54.493601+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0088	f
e4f4d5ef-78bb-4a7d-808f-45315f9050d7	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1014	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:34:54.496966+00	2026-08-27 13:34:54.501218+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
1532cac9-259a-49a8-93a0-9d1976053829	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511150D2358	Iiyama North America	PL2492H	in_stock	\N	\N	1900-01-12	\N	2026-08-27 13:34:54.506311+00	2026-08-27 13:34:54.506311+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
9245acb8-e07a-4fbb-9755-0314b8b790ee	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4465	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.511371+00	2026-08-27 13:34:54.516732+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
5e78e97a-263b-4c37-830c-f5ef536a197e	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C3995	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:34:54.520653+00	2026-08-27 13:34:54.529492+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0109	f
8979dcc5-421d-45b0-b49d-8eb3df20cd3b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00854	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.531639+00	2026-08-27 13:34:54.537052+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
92cbeb8f-2d44-4e4d-a20a-52e98919e445	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T361618	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.541182+00	2026-08-27 13:34:54.546189+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
74737132-e94b-4e3e-8a3a-b058cd68451c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T405525	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-21	\N	2026-08-27 13:34:54.548177+00	2026-08-27 13:34:54.555673+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F2007320 - 03912	180.00	\N	\N	1900-01-21	ESI0113	f
e92b4eb6-7389-4895-9050-1bdfc6eac32b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4470	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.55772+00	2026-08-27 13:34:54.564107+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
baed4aee-f7da-489b-9463-60eec69fc1c5	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4391	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.566708+00	2026-08-27 13:34:54.571379+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
3284008d-f1b8-43d1-8c30-b7050f816d30	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4461	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.57554+00	2026-08-27 13:34:54.581132+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
2f3772fb-9e0f-438c-9fc6-e58909356b9a	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V122283	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.587326+00	2026-08-27 13:34:54.597133+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4a78698d-507b-4d2c-9bdc-d4cc27b2b8fd	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066956	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.601541+00	2026-08-27 13:34:54.607103+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
17723c85-134d-43fb-8117-b037336f559c	3981e88a-85b7-4a12-9342-dca750713f52	\N	2RK1Y4AK4H0B	Dell Inc.	DELL E2214H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:54.611389+00	2026-08-27 13:34:54.611389+00	DELL E2214H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c5ff4ccf-e849-4dc7-bc2a-26933747f9fe	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066963	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.616582+00	2026-08-27 13:34:54.62228+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
79fd1701-f1fc-4f81-b60e-afc295f36434	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1677	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.62618+00	2026-08-27 13:34:54.631727+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c9a4be67-6b41-4fea-b3f3-32d87c9afeef	3981e88a-85b7-4a12-9342-dca750713f52	\N	100003a1	LG Display	LGD_MP1.1_ LP129WT2-SPA6	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:54.636171+00	2026-08-27 13:34:54.636171+00	LGD_MP1.1_ LP129WT2-SPA6	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3624950e-f50e-484f-8f4f-ee7c960d41cc	3981e88a-85b7-4a12-9342-dca750713f52	\N	H1J01251019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.641131+00	2026-08-27 13:34:54.648264+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
87947e22-6aaa-49da-9a90-30133566785b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C3996	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:34:54.651998+00	2026-08-27 13:34:54.66651+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0108	f
2f5e39c4-1128-42e3-b034-b8103d2cca6a	3981e88a-85b7-4a12-9342-dca750713f52	\N	4P09M49NASXU	Dell Inc.	DELL E2414H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.670606+00	2026-08-27 13:34:54.674436+00	DELL E2414H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a08142f1-1cfb-477d-b441-9b8616a3af3a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1011	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:34:54.677195+00	2026-08-27 13:34:54.686271+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
2036aef6-ec06-46e7-a6f0-75fcb1c6e818	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1687	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.690678+00	2026-08-27 13:34:54.704017+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
980ef897-fa0b-4be3-b874-16edbf7d75a3	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T890735	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.707469+00	2026-08-27 13:34:54.712254+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9b0a94c0-c2e7-4335-a48e-78f2a6301571	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066952	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-28	\N	2026-08-27 13:34:54.714451+00	2026-08-27 13:34:54.714451+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903379-01497	155.00	\N	\N	1900-01-28	ELY0121	f
03d2b293-b006-4c00-a4ae-eec5451fd1b4	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V115857	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.718485+00	2026-08-27 13:34:54.722603+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
01a08073-4e07-4ab0-b6c8-ba13c3d22941	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511150D2357	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:34:54.724892+00	2026-08-27 13:34:54.728522+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
dc0aa447-2b41-4c8b-94ac-c87e43389198	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1679	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.731456+00	2026-08-27 13:34:54.73625+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
93f29670-b0e4-44cf-97d3-fd9a7846d22f	3981e88a-85b7-4a12-9342-dca750713f52	\N	1169213813269	Iiyama North America	PL2294H	assigned	\N	\N	2021-04-12	\N	2026-08-27 13:34:54.740024+00	2026-08-27 13:34:54.744087+00	PL2294H	\N	\N	\N	\N	f	f	FR1121HE4AEUI	136.54	\N	\N	2022-04-12	ESI0126	f
187e3543-6c3a-455c-8339-1d9e73d0d94f	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T808547	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.747748+00	2026-08-27 13:34:54.752366+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
eec7b129-d3c9-43b1-8e74-f562a4243a20	3981e88a-85b7-4a12-9342-dca750713f52	\N	4P09M49NAT0U	Dell Inc.	DELL E2414H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:54.762765+00	2026-08-27 13:34:54.762765+00	DELL E2414H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
47666314-1822-40f0-b406-3304c0284861	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE044676	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-29	\N	2026-08-27 13:34:54.765608+00	2026-08-27 13:34:54.765608+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1811529-05613	0.00	\N	\N	1900-01-29	ELY0119	f
da2ce8d9-0194-4dfa-b5c4-b22e89d0cb93	3981e88a-85b7-4a12-9342-dca750713f52	\N	29C295C85KCB	Dell Inc.	DELL P2214H	retired	\N	\N	\N	\N	2026-08-27 13:34:54.768236+00	2026-08-27 13:34:54.768236+00	DELL P2214H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
34a95d0f-5435-4e3f-a385-99edb332fce9	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T808548	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.772169+00	2026-08-27 13:34:54.776706+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
008ac231-5627-4e54-b12a-47827dffd7a1	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T890738	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.77988+00	2026-08-27 13:34:54.786318+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b20948cd-d72d-4065-9913-897e796d3ae1	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00265	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.79075+00	2026-08-27 13:34:54.79895+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1abdd7a8-d9be-43a7-b4cd-7aea2fba309c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067068	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.802997+00	2026-08-27 13:34:54.808032+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
91e7f108-71d4-4caa-9015-469a3c3e6e27	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066968	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.812012+00	2026-08-27 13:34:54.835782+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a20634d9-0c2e-4f5c-9d97-2afcfd4ee650	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511125C3311	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:34:54.841331+00	2026-08-27 13:34:54.847995+00	PL2492H	\N	\N	\N	\N	f	f	F22040361 - 02807	183.00	\N	\N	1900-01-19	ELY0172	f
d2e72601-75ef-4002-8cdd-d91f6e9d4a35	3981e88a-85b7-4a12-9342-dca750713f52	\N	000002bb	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.851456+00	2026-08-27 13:34:54.85672+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a6ab197a-f086-4f94-8830-54bdb6e7213d	3981e88a-85b7-4a12-9342-dca750713f52	\N	12122244F3952	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:34:54.861171+00	2026-08-27 13:34:54.870296+00	PL2492H	\N	\N	\N	\N	f	f	0097532246	149.00	\N	\N	1900-01-24	ELY0189	f
27189046-9186-4554-9d85-27b7c2627e1b	3981e88a-85b7-4a12-9342-dca750713f52	\N	002127a1	LG Display	LGD_MP1.1_ LP129WT212166	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.873398+00	2026-08-27 13:34:54.878063+00	LGD_MP1.1_ LP129WT212166	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d725fa27-9ca4-412b-bba1-55f09200ffd5	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187714704549	Iiyama North America	PL2493H	assigned	\N	\N	2022-10-06	\N	2026-08-27 13:34:54.880968+00	2026-08-27 13:34:54.884846+00	PL2493H	\N	\N	\N	\N	f	f	F22060338 - 04388	181.00	\N	\N	2023-10-06	ELY0176	f
ab6b815b-fb08-4265-a3b0-7e0e0bc5d584	3981e88a-85b7-4a12-9342-dca750713f52	\N	2RK1Y3BR5J2M	Dell Inc.	DELL E2214H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="administrateur@ELYADE/ggonendji@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:54.8878+00	2026-08-27 13:34:54.8878+00	DELL E2214H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b4b63cc6-3698-47b7-91cb-74dce5a7e9ef	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7335	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:34:54.891122+00	2026-08-27 13:34:54.895242+00	PL2492H	\N	\N	\N	\N	f	f	F2102275-00948	929.00	\N	\N	2022-09-02	ESI0163	f
5fe7acfc-5077-4142-88a7-c652eefe13bd	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4466	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.909798+00	2026-08-27 13:34:54.916855+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
86100b61-3891-477c-a880-28f083e723c5	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4474	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.919558+00	2026-08-27 13:34:54.926048+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
2509e0eb-5a27-4287-ab58-7ca9aeec9d92	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1709	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.929459+00	2026-08-27 13:34:54.934056+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fa6340de-8ef8-402d-b682-df4f46011642	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889124	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:54.938431+00	2026-08-27 13:34:54.949324+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F22010431 - 00431	224.00	\N	\N	1900-01-30	ELY0169	f
01344ed0-dcd1-4b13-9d91-7672495f85d2	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE004872	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.95231+00	2026-08-27 13:34:54.955725+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0f862f80-326b-4a8c-bebb-3d8bc6b80136	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN430221CH	HPN	HP E24 G5	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.958177+00	2026-08-27 13:34:54.961707+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e0e207ad-45e1-4a3a-bf3a-286f8c4e38d8	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V167139	Fujitsu Siemens Computers GmbH	B22T-7 Pro	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:54.964511+00	2026-08-27 13:34:54.964511+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
eb1dc983-cbe4-4178-8bea-3ebea62f19c2	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6948	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:54.977517+00	2026-08-27 13:34:54.981529+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c9d674e4-0cd9-4eed-af62-a82206b3a8e4	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4464	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:54.98384+00	2026-08-27 13:34:54.987867+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
a68ea3fa-fb39-48b8-b4fb-295bab749f83	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889170	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:54.990761+00	2026-08-27 13:34:54.996292+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	224.00	\N	\N	1900-01-30	ESI0171	f
a653a715-47cd-4a13-b331-8670b5c7ceed	3981e88a-85b7-4a12-9342-dca750713f52	\N	H1AK500000	Samsung Electric Company	SyncMaster	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.059822+00	2026-08-27 13:34:55.065882+00	SyncMaster	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
208cc532-c332-4320-9f4d-f1db421a494b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4469	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.074773+00	2026-08-27 13:34:55.081648+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
8daf93e7-5c50-40b1-80d7-977f3924a8c2	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066962	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.083141+00	2026-08-27 13:34:55.087082+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8503b5b0-f0f5-463e-8f82-20ab8f901502	3981e88a-85b7-4a12-9342-dca750713f52	\N	W7WH7283B9DS	Dell Inc.	DELL P2012H	retired	\N	\N	\N	\N	2026-08-27 13:34:55.088264+00	2026-08-27 13:34:55.088264+00	DELL P2012H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f27a8f84-51a3-4df4-91c4-4124084cc45c	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187720600697	Iiyama North America	PL2493H	assigned	\N	\N	2022-10-06	\N	2026-08-27 13:34:55.091332+00	2026-08-27 13:34:55.094519+00	PL2493H	\N	\N	\N	\N	f	f	F22060338 - 04388	181.00	\N	\N	2023-10-06	ELY0176	f
2933d465-ee8e-4542-94f9-6043f61b93ca	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4476	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.096885+00	2026-08-27 13:34:55.100019+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
fabc2a0d-29a8-4a09-b236-e2b8da58a789	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1012	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:34:55.102443+00	2026-08-27 13:34:55.105839+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
37799a12-5ab5-47ac-abbd-25fe32b12e89	3981e88a-85b7-4a12-9342-dca750713f52	\N	RH81R92K108I	Dell Inc.	DELL P2217H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.113794+00	2026-08-27 13:34:55.117623+00	DELL P2217H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7a39fca8-41e0-417f-aaec-c486a4636457	3981e88a-85b7-4a12-9342-dca750713f52	\N	INF.0	Iiyama North America	PL2492H	in_stock	\N	\N	2022-11-05	\N	2026-08-27 13:34:55.119218+00	2026-08-27 13:34:55.119218+00	PL2492H	\N	\N	\N	\N	f	f	0097118425	175.00	\N	\N	2023-11-05	ESI0130	f
7b3b55d6-c81f-4233-ab70-94aeb32c5cd4	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4459	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.122074+00	2026-08-27 13:34:55.125495+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
424839f6-2601-4689-b03e-a65a873ff2a3	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807807	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.127719+00	2026-08-27 13:34:55.130676+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d057e35a-dde9-4eb6-86e0-4f3be7721d32	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4471	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.13265+00	2026-08-27 13:34:55.136136+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
d7b6172f-359c-4fff-a36b-b452e104e82c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC608160	Fujitsu Siemens Computers GmbH	B24-9 TS	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:34:55.138789+00	2026-08-27 13:34:55.142412+00	B24-9 TS	\N	\N	\N	\N	f	f	F2008275 - 04507	180.00	\N	\N	1900-01-19	ELY0140	f
b00a93fa-6db2-4d39-b508-48d702fcecb9	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511209E4514	Iiyama North America	PL2492H	assigned	\N	\N	2022-11-05	\N	2026-08-27 13:34:55.143657+00	2026-08-27 13:34:55.14934+00	PL2492H	\N	\N	\N	\N	f	f	0097118425	175.00	\N	\N	2023-11-05	ESI0130	f
27d384f6-ea9a-49ca-bf83-d94fdb52eb0c	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1005	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:34:55.15324+00	2026-08-27 13:34:55.157756+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
b4bff8a1-430f-4ebd-b99e-33d6462d81d2	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T890367	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.162418+00	2026-08-27 13:34:55.170613+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0696ed37-dce3-4b52-8dec-c7da866d8327	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN43022L02	HPN	HP E24 G5	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.174426+00	2026-08-27 13:34:55.179047+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0c2791a0-aa5d-42c2-b8f7-7639f473c7b5	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T890757	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Nicolas DAUTEL"	2026-08-27 13:34:55.180964+00	2026-08-27 13:34:55.180964+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6f419dd7-375a-42ab-8d81-15abe930859f	3981e88a-85b7-4a12-9342-dca750713f52	\N	00000000SL0	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.185095+00	2026-08-27 13:34:55.18921+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
95ad58aa-0131-4ad8-9d27-55fec6efc12b	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187723632378	Iiyama North America	PL2493H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="ldellaccio@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:55.192706+00	2026-08-27 13:34:55.192706+00	PL2493H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f422efb8-dba7-4930-9803-26005d927c5d	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066847	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-26	\N	2026-08-27 13:34:55.198545+00	2026-08-27 13:34:55.202141+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903336-01454	155.00	\N	\N	1900-01-26	ESI0077	f
1d0bc93a-5b13-4c3f-bb53-8b43bf397313	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187723632381	Iiyama North America	PL2493H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.204437+00	2026-08-27 13:34:55.210974+00	PL2493H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b8f82a24-b058-491b-b17c-e77182c069e6	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1013	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:34:55.215232+00	2026-08-27 13:34:55.219785+00	PL2492H	\N	\N	\N	\N	f	f	00968506235	171.31	\N	\N	2022-09-11	ESI0124	f
a7d75dc7-3292-4224-9d98-a90aaf38dfa0	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V122278	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.221712+00	2026-08-27 13:34:55.224083+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d6554b7a-1ff5-440f-a47f-ff75caf181d3	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7330	Iiyama North America	PL2492H	in_stock	\N	\N	2021-09-02	\N	2026-08-27 13:34:55.22505+00	2026-08-27 13:34:55.22505+00	PL2492H	\N	\N	\N	\N	f	f	F2102274 - 00947	152.00	\N	\N	2022-09-02	ESI0117	f
07b76f19-d597-4675-9cf4-01e7beb6bdc4	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBC023520	Fujitsu Siemens Computers GmbH	E22-8 TS Pro	retired	\N	\N	\N	\N	2026-08-27 13:34:55.226406+00	2026-08-27 13:34:55.226406+00	E22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
494f2f7f-7e92-4752-95c4-29944556fce3	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067073	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-28	\N	2026-08-27 13:34:55.228594+00	2026-08-27 13:34:55.233618+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903379-01497	155.00	\N	\N	1900-01-28	ELY0119	f
ba97062c-d09e-44e4-b058-114ddd753d3e	3981e88a-85b7-4a12-9342-dca750713f52	\N	H1J01223019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.241578+00	2026-08-27 13:34:55.246366+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7601e178-765c-4a74-beda-c367586bb9f6	3981e88a-85b7-4a12-9342-dca750713f52	\N	RH81R92K10GI	Dell Inc.	DELL P2217H	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.248037+00	2026-08-27 13:34:55.248037+00	DELL P2217H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c606e27d-622f-4ca5-9c09-31b6ff1c04f6	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C4023	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:34:55.252736+00	2026-08-27 13:34:55.258947+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0112	f
22f890ea-e251-4218-923a-6075039150c8	3981e88a-85b7-4a12-9342-dca750713f52	\N	MCN01511019	BenQ Corporation	BenQ PD2705U	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.263285+00	2026-08-27 13:34:55.268149+00	BenQ PD2705U	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4f431b25-0125-412b-835b-fb9958e55c08	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511037C3997	Iiyama North America	PL2492H	assigned	\N	\N	2020-12-11	\N	2026-08-27 13:34:55.271838+00	2026-08-27 13:34:55.276996+00	PL2492H	\N	\N	\N	\N	f	f	F2011266-06456	149.00	\N	\N	2021-12-11	ESI0110	f
9d8e4337-a9da-45af-a854-1747e31a4fc9	3981e88a-85b7-4a12-9342-dca750713f52	\N	INF.0	Iiyama North America	PL2492H	assigned	\N	\N	2022-11-05	\N	2026-08-27 13:34:55.279341+00	2026-08-27 13:34:55.286054+00	PL2492H	\N	\N	\N	\N	f	f	0097118425	175.00	\N	\N	2023-11-05	ESI0130	f
86c1f619-de92-4d1f-8660-a41e817624cc	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067069	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.297724+00	2026-08-27 13:34:55.301867+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
64fa4afb-fb86-4d9f-9ebc-bf4d74187201	3981e88a-85b7-4a12-9342-dca750713f52	\N	0000020c	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.304368+00	2026-08-27 13:34:55.309867+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0cb3090e-6498-401e-a68a-b3347c6a1e2c	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511113C2835	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:34:55.319819+00	2026-08-27 13:34:55.333342+00	PL2492H	\N	\N	\N	\N	f	f	F21060389 - 04070	180.00	\N	\N	1900-01-24	ELY0165	f
52a2ace5-a420-4254-9a63-58876e51042a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4458	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.336783+00	2026-08-27 13:34:55.340988+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
9d4cda4c-9492-4480-aec2-04886aa57ccc	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE200677	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:34:55.34424+00	2026-08-27 13:34:55.347989+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1910350-05629	146.00	\N	\N	1900-01-22	ELY0127	f
bb5b556f-7471-4cca-b486-94166d835407	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE069037	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.354332+00	2026-08-27 13:34:55.357768+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
34fd4e57-3cc4-4468-a27a-7d6a47de55c1	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807814	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.359466+00	2026-08-27 13:34:55.36228+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
16ed667f-6d9f-4d2e-953d-780f5eaae4e9	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6927	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:34:55.364685+00	2026-08-27 13:34:55.367474+00	PL2492H	\N	\N	\N	\N	f	f	F21050251 - 03184	158.00	\N	\N	2022-11-05	ELY0162	f
60b7a313-f55a-4bca-b445-088c50eef165	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6935	Iiyama North America	PL2492H	assigned	\N	\N	2021-11-05	\N	2026-08-27 13:34:55.369839+00	2026-08-27 13:34:55.373392+00	PL2492H	\N	\N	\N	\N	f	f	F21050251 - 03184	0.00	\N	\N	2022-11-05	ELY0162	f
c1c20b9a-3b1d-45f9-bf86-e345b318393c	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4479	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.381311+00	2026-08-27 13:34:55.387602+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
afb7a46a-2684-4d8a-b6d2-1d44c2eb43cd	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T862725	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.399786+00	2026-08-27 13:34:55.404007+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c79c142e-7d09-406a-9b43-0ee0d20f9b68	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4462	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.407223+00	2026-08-27 13:34:55.411+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
7f7eec29-7645-4cec-b6f7-902cfebf58ae	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066955	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.413421+00	2026-08-27 13:34:55.416092+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dcf0261d-30b5-426d-8b3a-9da1e38d259a	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC012372	Fujitsu Siemens Computers GmbH	B24-9 TS	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:55.418293+00	2026-08-27 13:34:55.420971+00	B24-9 TS	\N	\N	\N	\N	f	f	F2003556-01777	180.00	\N	\N	1900-01-30	ESI0099	f
52fffdff-d2fa-4f41-aba4-30ff1f655430	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T805595	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.423334+00	2026-08-27 13:34:55.428216+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d250fff1-a457-453b-951b-bbfdd04b22c8	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V134217	Fujitsu Siemens Computers GmbH	B22T-7 Pro	in_stock	\N	\N	2017-05-05	Affectation importée non résolue : Usager="mgamboa-mathieu@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:55.430279+00	2026-08-27 13:34:55.430279+00	B22T-7 Pro	\N	\N	\N	\N	f	f	F1705156-01891	186.00	\N	\N	2018-05-05	\N	f
a15d8f85-e535-4577-9d9d-941195d7f698	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807457	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:34:55.432191+00	2026-08-27 13:34:55.434525+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1911287-06187	168.00	\N	\N	1900-01-19	ESI0073	f
cbfb43e2-7a35-48f7-bc7a-e7af65c2a186	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511047C1640	Iiyama North America	PL2492H	assigned	\N	\N	2021-01-02	\N	2026-08-27 13:34:55.436203+00	2026-08-27 13:34:55.438444+00	PL2492H	\N	\N	\N	\N	f	f	F2102196-00869	149.00	\N	\N	2022-01-02	ESI0161	f
a52298d2-dabd-4cfc-ab5d-c927b48a9730	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V115842	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.439254+00	2026-08-27 13:34:55.44183+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f8b3086f-06e3-4209-ac79-33d9928e2aa1	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4483	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.443677+00	2026-08-27 13:34:55.445837+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
3ee8d390-7c52-467c-89a5-1798d3b5c5f3	3981e88a-85b7-4a12-9342-dca750713f52	\N	8130c155	Acer Technologies	Acer VG270	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.447377+00	2026-08-27 13:34:55.449939+00	Acer VG270	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9cdf834e-2d05-4db1-a81f-fde4c3013249	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829966	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.451768+00	2026-08-27 13:34:55.454296+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8e3c2e6c-e7ba-4fd8-af82-5b48ba93233a	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511126C1006	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-11	\N	2026-08-27 13:34:55.456406+00	2026-08-27 13:34:55.45939+00	PL2492H	\N	\N	\N	\N	f	f	0096806235	171.31	\N	\N	2022-09-11	ESI0124	f
b7ce9269-ad15-4251-84e0-47fb721de6be	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T807451	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-19	\N	2026-08-27 13:34:55.460325+00	2026-08-27 13:34:55.462772+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1911287-06187	168.00	\N	\N	1900-01-19	ESI0076	f
edad1a87-acab-4f00-9990-6b30982d7635	3981e88a-85b7-4a12-9342-dca750713f52	\N	H1J01254019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.464988+00	2026-08-27 13:34:55.467399+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
176641f3-9848-4dc3-8165-85581913075d	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4473	Iiyama North America	PL2492H	retired	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.468308+00	2026-08-27 13:34:55.468308+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
63b6007e-6b88-48fd-bc0c-7c8086974cd8	3981e88a-85b7-4a12-9342-dca750713f52	\N	CNK02609Q1	Hewlett Packard	HP LE2201w	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.470503+00	2026-08-27 13:34:55.473091+00	HP LE2201w	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3a6e6543-26ea-4c16-aab3-12f8c0b297c5	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE024872	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-13	\N	2026-08-27 13:34:55.474057+00	2026-08-27 13:34:55.474057+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1805202-02228	176.00	\N	\N	1900-01-13	ELY0107	f
48f3b98f-1043-44ff-96f3-7a1b3cbd09f0	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511108C6976	Iiyama North America	PL2492H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Yannis DELMAS"	2026-08-27 13:34:55.475468+00	2026-08-27 13:34:55.475468+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
edbe7df6-3811-4791-84b1-7a19d41e0687	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511150D2365	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:34:55.47797+00	2026-08-27 13:34:55.479873+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
92875386-738e-423b-94ce-36ceceee1b24	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1707	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.481176+00	2026-08-27 13:34:55.483199+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5ebe22a8-f4ce-4267-8a01-e8261f659543	3981e88a-85b7-4a12-9342-dca750713f52	\N	11845JMA00271	Iiyama North America	PLX2490C	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.485047+00	2026-08-27 13:34:55.487329+00	PLX2490C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b23861ef-1980-4c50-a6dd-8d34691274ee	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4472	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.489075+00	2026-08-27 13:34:55.491662+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
acb5b34f-2e65-4b95-82a8-e2d673a63b67	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511150D2366	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:34:55.493979+00	2026-08-27 13:34:55.496656+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
c08aaea0-f721-4ecb-948a-c8689be7c907	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511209E5057	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-28	\N	2026-08-27 13:34:55.498655+00	2026-08-27 13:34:55.501404+00	PL2492H	\N	\N	\N	\N	f	f	F22070907 - 05795	192.00	\N	\N	1900-01-28	ELY0180	f
00c13f12-7064-47ef-9b29-d15f22308312	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829986	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:34:55.50295+00	2026-08-27 13:34:55.505413+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0089	f
385df68a-2a8c-4841-8432-9ada0c96197b	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511153D2333	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-12	\N	2026-08-27 13:34:55.506323+00	2026-08-27 13:34:55.509233+00	PL2492H	\N	\N	\N	\N	f	f	0097076456	175.00	\N	\N	1900-01-12	ESI0129	f
14b9b994-6de8-40a0-842c-f6cabc4d9d31	3981e88a-85b7-4a12-9342-dca750713f52	\N	RH81R92K159I	Dell Inc.	DELL P2217H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="gestesi@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:55.511347+00	2026-08-27 13:34:55.511347+00	DELL P2217H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
aedea92f-50b3-4662-8ad6-7420ea071cb3	3981e88a-85b7-4a12-9342-dca750713f52	\N	0000003b	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.514147+00	2026-08-27 13:34:55.516938+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
18af2eb7-6ca6-411c-8379-d57ea9701d78	3981e88a-85b7-4a12-9342-dca750713f52	\N	11673JMA00307	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.518919+00	2026-08-27 13:34:55.521441+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d4b29d74-7204-4c00-81f2-373b3b28f300	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511033C1672	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.523262+00	2026-08-27 13:34:55.526247+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cbb1c464-1f63-42e4-80a2-3413f240b770	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C7320	Iiyama North America	PL2492H	assigned	\N	\N	2021-09-02	\N	2026-08-27 13:34:55.52837+00	2026-08-27 13:34:55.530664+00	PL2492H	\N	\N	\N	\N	f	f	F2102274 - 00947	152.00	\N	\N	2022-09-02	ESI0118	f
4354c7b2-6e94-43de-b93c-f3a44e9cb051	3981e88a-85b7-4a12-9342-dca750713f52	\N	830000DC7800	Acer Technologies	AT2245	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.53214+00	2026-08-27 13:34:55.534536+00	AT2245	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
00e32f2d-b25d-416b-ba9e-44a8a605e8fd	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V164428	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	2017-07-09	\N	2026-08-27 13:34:55.535333+00	2026-08-27 13:34:55.537487+00	B22T-7 Pro	\N	\N	\N	\N	f	f	F1709167-03618	186.00	\N	\N	2020-07-09	ELY0098	f
d1dca87d-3284-4566-87c1-6634ee4805e1	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829994	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:34:55.539791+00	2026-08-27 13:34:55.542216+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0091	f
05e515d4-f11f-4b0b-8308-02f0dc028d77	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889129	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:55.543096+00	2026-08-27 13:34:55.545769+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F22010429 - 00429	224.00	\N	\N	1900-01-30	ESI0171	f
eda9599e-d476-4842-a88d-dff98b713098	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187714704563	Iiyama North America	PL2493H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:34:55.546733+00	2026-08-27 13:34:55.550655+00	PL2493H	\N	\N	\N	\N	f	f	F22050452 - 03659	181.00	\N	\N	1900-01-24	ELY0174	f
90c17cd6-6cff-4ca9-b3e8-9843a8406280	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889128	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:55.553735+00	2026-08-27 13:34:55.556336+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F22010429 - 00429	224.00	\N	\N	1900-01-30	ESI0171	f
ef8307a0-c5a7-44d4-b434-b7d4636a0a10	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511114C4475	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-15	\N	2026-08-27 13:34:55.558329+00	2026-08-27 13:34:55.561886+00	PL2492H	\N	\N	\N	\N	f	f	0096815055	171.00	\N	\N	1900-01-15	ESI0125	f
acd101c6-f688-49f9-93aa-58be58c5cb5f	3981e88a-85b7-4a12-9342-dca750713f52	\N	4P09M49NAT5U	Dell Inc.	DELL E2414H	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="epoeydomenge@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:55.563637+00	2026-08-27 13:34:55.563637+00	DELL E2414H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1dcd3604-9d33-4007-a45e-f09e4caa9064	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE067076	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.565198+00	2026-08-27 13:34:55.567475+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bbe0b38a-e79c-4e11-bd32-3308fce6f3ef	3981e88a-85b7-4a12-9342-dca750713f52	\N	H4ZR800114	Samsung Electric Company	U32R59x	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.569513+00	2026-08-27 13:34:55.572035+00	U32R59x	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e7523502-e638-4bf3-8c2b-110dc4f2d6bc	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN430221CD	HPN	HP E24 G5	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.575105+00	2026-08-27 13:34:55.579116+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
189439d3-fd34-4f4a-84c2-baa469c20d00	3981e88a-85b7-4a12-9342-dca750713f52	\N	0C2MHNFN900290	Samsung	QE50T	in_stock	\N	\N	1900-01-26	\N	2026-08-27 13:34:55.580366+00	2026-08-27 13:34:55.580366+00	Samsung QE50T	\N	\N	\N	\N	f	f	F21040369 - 02562	792.00	\N	\N	1900-01-26	ELY0159	f
cbb352ad-4aba-41d9-bbcc-a5478ba9e101	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511113C2824	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:34:55.582347+00	2026-08-27 13:34:55.585108+00	PL2492H	\N	\N	\N	\N	f	f	F21060389 - 04070	180.00	\N	\N	1900-01-24	ELY0165	f
8ae33d13-6ec0-43d7-908f-f954f9c0f6e9	3981e88a-85b7-4a12-9342-dca750713f52	\N	0681HNFM200347	Samsung Electric Company	DC49J	in_stock	\N	\N	2021-09-04	\N	2026-08-27 13:34:55.586786+00	2026-08-27 13:34:55.586786+00	Samsung DC49J	\N	\N	\N	\N	f	f	F1904259 - 01968	739.00	\N	\N	2022-09-04	ELY0152	f
4e5cb271-1d25-48a5-85c3-914dee344547	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T406060	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-21	\N	2026-08-27 13:34:55.588856+00	2026-08-27 13:34:55.59226+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F2007320 - 03912	180.00	\N	\N	1900-01-21	ESI0115	f
2bdd3c8d-5530-4dd2-880e-fa637ee5c171	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T889139	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	in_stock	\N	\N	1900-01-30	\N	2026-08-27 13:34:55.593493+00	2026-08-27 13:34:55.593493+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	224.00	\N	\N	1900-01-30	ESI0171	f
767df4f7-8403-4a76-9116-ce5c589e3328	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511113C2820	Iiyama North America	PL2492H	assigned	\N	\N	1900-01-24	\N	2026-08-27 13:34:55.595392+00	2026-08-27 13:34:55.598088+00	PL2492H	\N	\N	\N	\N	f	f	F21060388 - 04069	180.00	\N	\N	1900-01-24	ESI0121	f
25e1fb82-0db8-4ac7-82d2-d17ccffa21fd	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T406059	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	in_stock	\N	\N	1900-01-21	\N	2026-08-27 13:34:55.59912+00	2026-08-27 13:34:55.59912+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F2007320 - 03912	180.00	\N	\N	1900-01-21	ESI0114	f
2e7d86c3-3a77-4306-9927-cf27b59a2911	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829984	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:34:55.601102+00	2026-08-27 13:34:55.603567+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0086	f
d05ae9b8-5fbf-45e0-baf4-38511b8ed7dd	3981e88a-85b7-4a12-9342-dca750713f52	\N	1187720600693	Iiyama North America	PL2493H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.605045+00	2026-08-27 13:34:55.606904+00	PL2493H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
71011dba-480e-4736-83a5-c64b1b89079c	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829995	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	in_stock	\N	\N	1900-01-22	\N	2026-08-27 13:34:55.608811+00	2026-08-27 13:34:55.608811+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0092	f
8166a45f-44a6-4668-8e10-0e6d11e14bc8	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE019706	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.610021+00	2026-08-27 13:34:55.610021+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
06e59d9f-fa3d-48a5-aa02-5e9d292055a7	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066953	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.611382+00	2026-08-27 13:34:55.611382+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ce49adec-308a-4bc9-83cd-1aa4f62e51e2	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE024322	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	retired	\N	\N	\N	\N	2026-08-27 13:34:55.612872+00	2026-08-27 13:34:55.612872+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8e27a57f-4ae8-477b-9df4-c1c18b7f0c8e	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE028916	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-30	\N	2026-08-27 13:34:55.614136+00	2026-08-27 13:34:55.614136+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1805318-2344	176.00	\N	\N	1900-01-30	ESI0063	f
0e48cac8-41b5-4a00-a78a-59c67137d016	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVDC012349	Fujitsu Siemens Computers GmbH	B24-9 TS	in_stock	\N	\N	1900-01-30	\N	2026-08-27 13:34:55.672629+00	2026-08-27 13:34:55.672629+00	B24-9 TS	\N	\N	\N	\N	f	f	F2003556-01777	180.00	\N	\N	1900-01-30	ESI0099	f
de58ed5f-90e1-4854-bdc9-66734ce71558	3981e88a-85b7-4a12-9342-dca750713f52	\N	0681HNFN100125	Samsung Electric Company	DC49J	assigned	\N	\N	1900-01-30	\N	2026-08-27 13:34:55.675079+00	2026-08-27 13:34:55.679322+00	Samsung DC49J	\N	\N	\N	\N	f	f	F2003593-01814	739.00	\N	\N	1900-01-30	ESI0100	f
c12783c0-6fb0-494c-b6ac-fc317fb1335e	3981e88a-85b7-4a12-9342-dca750713f52	\N	0681HNFMB00187	Samsung Electric Company	DC49J	in_stock	\N	\N	2020-06-10	\N	2026-08-27 13:34:55.680767+00	2026-08-27 13:34:55.680767+00	Samsung DC49J	\N	\N	\N	\N	f	f	0096075058	559.00	\N	\N	2021-06-10	ESI0107	f
65c1bc27-d244-476a-9fa9-8a939c6357fb	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829984	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	1900-01-22	\N	2026-08-27 13:34:55.683171+00	2026-08-27 13:34:55.686409+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	F1912376-06888	168.00	\N	\N	1900-01-22	ESI0087	f
b234bc3b-151c-43c3-9be9-db563f90312a	3981e88a-85b7-4a12-9342-dca750713f52	\N	01AJHNFM400516	Samsung Electric Company	DC55E	in_stock	\N	\N	1900-01-22	\N	2026-08-27 13:34:55.687474+00	2026-08-27 13:34:55.687474+00	Samsung DC55E	\N	\N	\N	\N	f	f	F1910351-05630	834.00	\N	\N	1900-01-22	ESI155	f
79d1a1cb-693d-4c50-9d16-bb5c3ebe5759	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066920	Fujitsu Siemens Computers GmbH	B22-8 TS Pro	in_stock	\N	\N	1900-01-26	\N	2026-08-27 13:34:55.688978+00	2026-08-27 13:34:55.688978+00	B22-8 TS Pro	\N	\N	\N	\N	f	f	F1903336-01454	155.00	\N	\N	1900-01-26	ESI0078	f
cda13b03-27de-45fd-ad11-4232b8a4cc3e	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511048C8343	Iiyama North America	PL2492H	assigned	\N	\N	2021-01-02	\N	2026-08-27 13:34:55.690679+00	2026-08-27 13:34:55.693462+00	PL2492H	\N	\N	\N	\N	f	f	F2102196-00869	149.00	\N	\N	2022-01-02	ESI0161	f
1dd03f7f-5191-4e32-9104-86a83e75032a	3981e88a-85b7-4a12-9342-dca750713f52	\N	LWAEE0188563	Acer Technologies	G246HL	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.695571+00	2026-08-27 13:34:55.698638+00	G246HL	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1798d260-19f0-42e2-9fd8-4d74eb4dc4b9	3981e88a-85b7-4a12-9342-dca750713f52	\N	ETV9P02365SL0	BenQ Corporation	BenQ PD2706U	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.700703+00	2026-08-27 13:34:55.70324+00	BenQ PD2706U	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f8dc44ae-9de9-4f7e-a8fe-96ee369870b8	3981e88a-85b7-4a12-9342-dca750713f52	\N	1165190802269	Iiyama North America	PL2730H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.705303+00	2026-08-27 13:34:55.707868+00	PL2730H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f373ea0f-6e62-4bb3-ac45-18810132cde2	3981e88a-85b7-4a12-9342-dca750713f52	\N	29C295C85L6B	Dell Inc.	DELL P2214H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.709799+00	2026-08-27 13:34:55.712145+00	DELL P2214H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ba7da3b5-c3b8-4adf-935e-e77b5be7cba0	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511125C3309	Iiyama North America	PL2492H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.715564+00	2026-08-27 13:34:55.718387+00	PL2492H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
def0043c-9088-4c93-984f-400bb1730e26	3981e88a-85b7-4a12-9342-dca750713f52	\N	G9L01360SL0	BenQ Corporation	ZOWIE XL LCD	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.720299+00	2026-08-27 13:34:55.723684+00	ZOWIE XL LCD	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
209681a3-f609-4c02-a67a-6fd9432bc773	3981e88a-85b7-4a12-9342-dca750713f52	\N	A5LMTF081365	Ancor Communications Inc	ASUS VH242	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.725694+00	2026-08-27 13:34:55.728242+00	ASUS VH242	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
79f93f9f-7427-4ed1-9539-fe13487697e2	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN430221C5	HPN	HP E24 G5	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.729873+00	2026-08-27 13:34:55.729873+00	HP E24 G5	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
61900226-5008-431e-8701-9c5d7ed52e9e	3981e88a-85b7-4a12-9342-dca750713f52	\N	00016c25	AOC International (USA) Ltd.	Q27G2WG4	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.732509+00	2026-08-27 13:34:55.735046+00	Q27G2WG4	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
08dea7a5-5eb5-4d2e-8025-2d4853ba7682	3981e88a-85b7-4a12-9342-dca750713f52	\N	000c54f0	Fujitsu Siemens Computers GmbH	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.736902+00	2026-08-27 13:34:55.739217+00	16/2019	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d5b9747b-8543-4a90-92a0-c4f984e4a8a1	3981e88a-85b7-4a12-9342-dca750713f52	\N	CNC1351NRP	HPN	HP 32 Display	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.741234+00	2026-08-27 13:34:55.743765+00	HP 32 Display	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c0cb9fb0-6f14-4384-8541-70b2e4d50d7e	3981e88a-85b7-4a12-9342-dca750713f52	\N	000001e1	Microstep	MSI MP2412C	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.746268+00	2026-08-27 13:34:55.748804+00	MSI MP2412C	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1f5652a3-2a8d-4425-adc1-2692fb23cdce	3981e88a-85b7-4a12-9342-dca750713f52	\N	H4ZM603547	Samsung Electric Company	U28E590	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.751862+00	2026-08-27 13:34:55.754766+00	U28E590	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
27679820-066f-4b65-ac8a-a3a1546636ee	3981e88a-85b7-4a12-9342-dca750713f52	\N	01000e00	Samsung Electric Company	SAMSUNG	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.75695+00	2026-08-27 13:34:55.759458+00	SAMSUNG	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dd5f9a34-e83e-4763-b176-3370d96b5da4	3981e88a-85b7-4a12-9342-dca750713f52	\N	LBLMDW008069	AUS	VZ279HEG1R	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="pdasilva@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:55.761727+00	2026-08-27 13:34:55.761727+00	VZ279HEG1R	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cb3e993d-10df-4afc-bdb5-89470a963d74	3981e88a-85b7-4a12-9342-dca750713f52	\N	LBLMDW008053	AUS	VZ279HEG1R	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="pdasilva@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:55.764335+00	2026-08-27 13:34:55.764335+00	VZ279HEG1R	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
15f97906-5781-420a-af38-7242c983c38d	3981e88a-85b7-4a12-9342-dca750713f52	\N	000d9129	Fujitsu Siemens Computers GmbH	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.766633+00	2026-08-27 13:34:55.768924+00	22/2021	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7bac214a-d10d-49d9-bbf7-3ece0df1a722	3981e88a-85b7-4a12-9342-dca750713f52	\N	309TFXX1P066	Goldstar Company Ltd	LG FHD	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.77062+00	2026-08-27 13:34:55.773178+00	LG FHD	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
180439e0-c146-404c-b042-f7ee9d21eaf2	3981e88a-85b7-4a12-9342-dca750713f52	\N	1214144620745	Iiyama North America	PL3494WQ	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.774954+00	2026-08-27 13:34:55.77749+00	PL3494WQ	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ee9ec3f8-2663-4fd8-8f4a-6ef36fc8a015	3981e88a-85b7-4a12-9342-dca750713f52	\N	11673JMA00059	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.779483+00	2026-08-27 13:34:55.781859+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8cef8030-0744-4ba8-b0c6-273bf2097a8d	3981e88a-85b7-4a12-9342-dca750713f52	\N	1214145220010	Iiyama North America	PL3494WQ	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.783973+00	2026-08-27 13:34:55.786561+00	PL3494WQ	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
38594d3d-2a0d-4af9-b36a-58db57dbbd57	3981e88a-85b7-4a12-9342-dca750713f52	\N	CNC9302PKM	HPN	HP E223	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.788389+00	2026-08-27 13:34:55.790594+00	HP E223	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2f29364e-8647-462e-9ac0-2e00dc8f7bb9	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9T829980	Fujitsu Siemens Computers GmbH	B24-8 TS Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.792476+00	2026-08-27 13:34:55.795167+00	B24-8 TS Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
30060012-6cbe-4b39-a7bb-545048655a5f	3981e88a-85b7-4a12-9342-dca750713f52	\N	6CM5140ZM1	Hewlett Packard	HP E201	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.797182+00	2026-08-27 13:34:55.799235+00	HP E201	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c76dec61-f2d6-42bb-9611-5f4fc331451f	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352612779	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.800648+00	2026-08-27 13:34:55.802631+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fc49969c-1be3-4905-bb93-d7e4bb37c084	3981e88a-85b7-4a12-9342-dca750713f52	\N	00000133	Iiyama North America	PL2595W	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.804616+00	2026-08-27 13:34:55.806961+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f93be77a-e454-452d-94ce-b87da08f0dbf	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511407	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.808434+00	2026-08-27 13:34:55.810886+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
831e60bc-6d79-49fe-850c-02791e4826c6	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513439	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.81228+00	2026-08-27 13:34:55.815108+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0632fd35-9b49-4626-92c9-e023c8ddc8f3	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511074	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.817199+00	2026-08-27 13:34:55.819883+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e08f9dd4-fa62-4789-87fe-f53b70e4ffce	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511403	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.822184+00	2026-08-27 13:34:55.824701+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
85e0beb0-5c78-4f20-b12f-79bee12144be	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511410	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.825762+00	2026-08-27 13:34:55.828011+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3b74a41d-e07a-4320-98a6-873f93e65155	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513322	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.829854+00	2026-08-27 13:34:55.831999+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
43c72140-7eff-41bb-934f-03eeefc95b69	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXC4D	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.016668+00	2026-08-27 13:34:56.016668+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2f6bdc32-a59a-4c74-a911-eb4be820b2a8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXACP	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:34:56.019297+00	2026-08-27 13:34:56.019297+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
028072f6-0f72-45fc-8f00-322c43f61b71	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511404	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.833619+00	2026-08-27 13:34:55.836796+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
734456ea-1163-460c-8518-29926a65eea1	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511071	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.839704+00	2026-08-27 13:34:55.841886+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a515c8bf-11b8-4ab8-8c91-8be78e6b5874	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511394	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.843553+00	2026-08-27 13:34:55.84613+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
929ee2d5-3b9a-4cac-88ec-6e37273793b8	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511390	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.847725+00	2026-08-27 13:34:55.850232+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9fbf27f0-b0ae-4d55-b6d4-8e2090f98869	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511412	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.851634+00	2026-08-27 13:34:55.853841+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1709f1d9-a92f-4ab9-bbca-8c49c055ec32	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511077	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.855331+00	2026-08-27 13:34:55.858497+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e89dddcc-35c0-441d-802a-461e65bfa538	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511413	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.860508+00	2026-08-27 13:34:55.86314+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0b83da15-b3af-47f3-9bd8-6e72c66a1587	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511395	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.865289+00	2026-08-27 13:34:55.867937+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
76f60eef-4eda-4a6c-b9f7-56d050490fa4	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513424	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.87028+00	2026-08-27 13:34:55.872936+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
34f040dd-c474-4fb9-9de4-2a17cce07a42	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511132	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.875052+00	2026-08-27 13:34:55.877293+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f34b02da-3387-48d9-bc40-83299e4dd101	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513423	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.880161+00	2026-08-27 13:34:55.882883+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7004e6a7-4981-4a38-9ec2-7d8e4f85535c	3981e88a-85b7-4a12-9342-dca750713f52	\N	00000207	Iiyama North America	PL2595W	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.884111+00	2026-08-27 13:34:55.884111+00	PL2595W	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8a4c167a-fc79-4d82-9fe1-6201c1d67309	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511076	Iiyama North America	PL2497H	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.885366+00	2026-08-27 13:34:55.885366+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
880f954b-27af-45c2-8f12-7ad8583725d1	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513442	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.886941+00	2026-08-27 13:34:55.888722+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
866f4985-b42e-43bb-b5fb-24c52b12bee0	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511417	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.890139+00	2026-08-27 13:34:55.891854+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
20f83eb9-dcec-483b-aa7e-0f06b61648d2	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V164429	Fujitsu Siemens Computers GmbH	B22T-7 Pro	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.893396+00	2026-08-27 13:34:55.895953+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
712d5bd0-4d3b-46bb-8d57-6e0be1c72118	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352511420	Iiyama North America	PL2497H	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.898132+00	2026-08-27 13:34:55.905751+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e93bce04-49de-4ee4-a68e-845bc7879531	3981e88a-85b7-4a12-9342-dca750713f52	\N	YV9V167138	Fujitsu Siemens Computers GmbH	B22T-7 Pro	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Administrateur@ELYADE" ; Utilisateur="-"	2026-08-27 13:34:55.908246+00	2026-08-27 13:34:55.908246+00	B22T-7 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8d829f9c-bd39-4581-9e26-d5f3e57b5121	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249352513422	Iiyama North America	PL2497H	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.9101+00	2026-08-27 13:34:55.9101+00	PL2497H	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e676c7bc-36ad-49d5-b73e-a7ea80875cb2	3981e88a-85b7-4a12-9342-dca750713f52	\N	NALMQS027212	AUS	VG27A	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.914089+00	2026-08-27 13:34:55.917171+00	VG27A	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a8d44def-9b24-47ba-946d-11db5ea23ab7	3981e88a-85b7-4a12-9342-dca750713f52	\N	H4PT305198	Samsung Electric Company	LS24AG30x	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.919618+00	2026-08-27 13:34:55.922925+00	LS24AG30x	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
8f37a045-5242-4219-a7eb-30653824de7a	3981e88a-85b7-4a12-9342-dca750713f52	\N	SN-000000001	Mars-Tech Corporation	MON-SIS289	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.924739+00	2026-08-27 13:34:55.927755+00	MON-SIS289	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
43b947f9-fef9-4c46-8bcc-742e619054ce	3981e88a-85b7-4a12-9342-dca750713f52	\N	H9XS308029	Samsung Electric Company	SyncMaster	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.929935+00	2026-08-27 13:34:55.934078+00	SyncMaster	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
eb31857c-e832-4908-a1e3-c85ee1d010c1	3981e88a-85b7-4a12-9342-dca750713f52	\N	ETH1J01251019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.936186+00	2026-08-27 13:34:55.938672+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
cd8d1f46-04e7-42e6-b943-827d07e83a8b	3981e88a-85b7-4a12-9342-dca750713f52	\N	ETH1J01254019	BenQ Corporation	BenQ BL2411	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.940892+00	2026-08-27 13:34:55.945463+00	BenQ BL2411	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
f6f889d0-fa1f-4c1a-9965-f2018852c498	3981e88a-85b7-4a12-9342-dca750713f52	\N	0004a04c	Goldstar Company Ltd	LG HDR 4K	assigned	\N	\N	\N	\N	2026-08-27 13:34:55.948296+00	2026-08-27 13:34:55.952157+00	LG HDR 4K	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
213e4c28-8b9a-4ea2-8f59-fdb47d5ee41f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	308052E060002196	Yealink	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.953503+00	2026-08-27 13:34:55.953503+00	BH72 Lite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d883d979-0f0d-468d-a4ad-c98079cb6153	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	308052E060002196	Yealink	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.955294+00	2026-08-27 13:34:55.955294+00	BH72 Lite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cbc93773-b136-489e-98bc-115a6f161b0b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	308052E060002196	Yealink	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.956932+00	2026-08-27 13:34:55.956932+00	BH72 Lite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d1e32ea3-b7a5-444e-99a8-b30559375928	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	308052E060002196	Yealink	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.958763+00	2026-08-27 13:34:55.958763+00	BH72 Lite	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b5e584ed-7ae3-42a7-8983-aa99d04c486b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250321	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.961808+00	2026-08-27 13:34:55.961808+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5ec8b0a6-803e-4d73-b894-a2a18b71e604	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250435	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.96406+00	2026-08-27 13:34:55.96406+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8d34f299-e275-4545-98d0-1c3a8fbb4a89	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250121	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.965653+00	2026-08-27 13:34:55.965653+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
953cf2a2-e846-48f5-adbe-3fed1b277e8f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250122	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.967803+00	2026-08-27 13:34:55.967803+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
875edd57-d10e-4004-939b-99357c6286f7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250449	Jabra	\N	retired	\N	\N	\N	\N	2026-08-27 13:34:55.969314+00	2026-08-27 13:34:55.969314+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d54504b9-dd8c-4c97-81a8-97c3a8a1cd32	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250134	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.971096+00	2026-08-27 13:34:55.971096+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dff96c86-a183-4e3e-b928-5c4e866be049	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250427	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.972464+00	2026-08-27 13:34:55.972464+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5c56f4ac-1f4e-4776-8627-8315c8e1cb55	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250430	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.974123+00	2026-08-27 13:34:55.974123+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4c4ee80c-4d7f-44aa-a18b-0d6f95394fcb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250323	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.975357+00	2026-08-27 13:34:55.975357+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ee9ce797-f2c2-4d49-9ae2-01d3f8d1ba62	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0293250128	Jabra	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.977748+00	2026-08-27 13:34:55.977748+00	Jabra Evolve 65 SE MS Stereo	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2cbab819-429b-469d-8b60-6e5b5d3a0c19	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.979653+00	2026-08-27 13:34:55.979653+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c7e61170-1269-4699-92e8-b62e34afb027	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:34:55.982239+00	2026-08-27 13:34:55.982239+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2c90fa92-e54d-46a4-978f-9d8bf555519f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.98475+00	2026-08-27 13:34:55.98475+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
89a197c7-e472-466e-a241-9f6b58a3db21	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.98875+00	2026-08-27 13:34:55.98875+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
78a4e46b-a9fd-4cd5-a3d8-e2fced60b51c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.993325+00	2026-08-27 13:34:55.993325+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
040276f9-c835-4635-ba6c-cf3832ebabab	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.995655+00	2026-08-27 13:34:55.995655+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4adbaa65-25c5-4fe7-b343-cff51ca306f6	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.997905+00	2026-08-27 13:34:55.997905+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a5cd7261-e38f-4960-8ff1-8deafe86a27e	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:55.999709+00	2026-08-27 13:34:55.999709+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4675d5d6-581d-405f-ad4f-c66b87d69531	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.002094+00	2026-08-27 13:34:56.002094+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1d4d1ee4-6297-4fad-a755-5a365fa060a7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.004058+00	2026-08-27 13:34:56.004058+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b03c6fae-2b61-44f9-b891-a126aa164375	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXALM	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.006291+00	2026-08-27 13:34:56.006291+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c24cf3a7-d2ee-49ff-90d3-aa45bf6df134	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXE7X	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.008226+00	2026-08-27 13:34:56.008226+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4b5abc30-9692-4eca-b01b-711858fe9f58	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXBBC	POLY	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Laetitia BADIBANGA"	2026-08-27 13:34:56.010662+00	2026-08-27 13:34:56.010662+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7edd37a7-6464-4012-9746-9def3727e4f9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXAEN	POLY	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="Elsa BERNEGE" ; Utilisateur="Elsa BERNEGE"	2026-08-27 13:34:56.029295+00	2026-08-27 13:34:56.029295+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
93771a2b-3721-4ee3-849e-90f31423f592	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXCLV	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.031482+00	2026-08-27 13:34:56.031482+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c5be75f0-9a45-428f-b544-fd2aba118529	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXC5K	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.098107+00	2026-08-27 13:34:56.098107+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c3ecfb53-0d51-4812-a8ab-35693847737c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDEB	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.100759+00	2026-08-27 13:34:56.100759+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3bc27d0b-e05e-4866-80c2-c10db1c05921	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDDM	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:34:56.10232+00	2026-08-27 13:34:56.10232+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
03571565-068a-4722-8ada-db50e0e0ed78	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDD4	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.103713+00	2026-08-27 13:34:56.103713+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a0ee685d-2568-49b2-882d-95245ee893a6	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDDN	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.105139+00	2026-08-27 13:34:56.105139+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d67b325b-8fdd-4627-be3e-3c5aeb98fbed	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDAX	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.107361+00	2026-08-27 13:34:56.107361+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2f8ac339-fea1-4efb-bfd1-a954946797ac	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDDH	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.108566+00	2026-08-27 13:34:56.108566+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
707f046f-4d37-442d-916c-f03eac012770	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJXDE3	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.109887+00	2026-08-27 13:34:56.109887+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
28c45fae-8b2c-48a3-88d4-c7e879b33ecc	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3DYY	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.111061+00	2026-08-27 13:34:56.111061+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e38abd1f-b6c5-4426-90ac-5713aab76868	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3EC1	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.112094+00	2026-08-27 13:34:56.112094+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
90bccc76-a93f-4bcd-9c41-82d75134114c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3E91	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.11324+00	2026-08-27 13:34:56.11324+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
38d646cf-9221-4bcf-bf45-24ba499055c2	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3DHG	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:34:56.114623+00	2026-08-27 13:34:56.114623+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
18877724-0c96-4cea-8213-b8cf4e7e9910	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3EA6	POLY	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Anna DUPUY"	2026-08-27 13:34:56.115789+00	2026-08-27 13:34:56.115789+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fa730785-f10b-43b3-80ef-32c21964440d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3EAC	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.117073+00	2026-08-27 13:34:56.117073+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2f89d0a0-decf-4075-8f84-9e2e87ed58ad	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3E5K	POLY	\N	retired	\N	\N	\N	\N	2026-08-27 13:34:56.118338+00	2026-08-27 13:34:56.118338+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
390e1ea6-94a8-4705-9dbf-2ca9bddecaa3	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3E63	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.119608+00	2026-08-27 13:34:56.119608+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
827ab082-5f46-4f29-97d3-a7bf0913e3c4	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3EC0	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.120798+00	2026-08-27 13:34:56.120798+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2ff8bfd1-413c-42f4-9aa8-96d888ec91bf	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK3E73	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.122013+00	2026-08-27 13:34:56.122013+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
097e3103-9bb0-4758-ab62-f7f5c75c6ecc	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	a002340212200690	epos	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.12317+00	2026-08-27 13:34:56.12317+00	EPOS SP30	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ef1505bf-efbc-4671-bd49-e9e70a75e1c4	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	epos	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.124291+00	2026-08-27 13:34:56.124291+00	EPOS SP30	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e562ecb8-7fd7-4ec2-8fcb-3bee8d5bac36	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0094000496	epos	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.125546+00	2026-08-27 13:34:56.125546+00	EPOS SP30	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
dff01cc5-c935-4888-8758-96f16b8343ce	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	0094000413	epos	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.127027+00	2026-08-27 13:34:56.127027+00	EPOS SP30	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b09e8567-fedd-475f-b6bc-0e5e0e8735cb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E8F	POLY	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Alizée POULIN-PLAZANET"	2026-08-27 13:34:56.128229+00	2026-08-27 13:34:56.128229+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
be143819-8432-43ec-a1fd-481dc894ba9b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7DDL	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.129429+00	2026-08-27 13:34:56.129429+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
31f28e00-1acb-442d-ac00-a12af780337d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E4B	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.130518+00	2026-08-27 13:34:56.130518+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
67b44f06-ddf2-49b3-804e-7a8795fe5e5c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E81	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.131867+00	2026-08-27 13:34:56.131867+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
747e0d3b-6265-49c8-9c5b-12f15b17c89d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7CH2	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.13345+00	2026-08-27 13:34:56.13345+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
21868218-c34d-417b-a527-86b5458f26e8	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E8D	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.134956+00	2026-08-27 13:34:56.134956+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bb1244a2-ddae-4baf-829c-c7d3f6fa6def	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E8E	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.13634+00	2026-08-27 13:34:56.13634+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
be516e18-bb84-4a7c-b51a-44889b971844	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7DCU	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.137879+00	2026-08-27 13:34:56.137879+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c028de00-f490-43a9-8677-371b4d55abf5	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E3P	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.1394+00	2026-08-27 13:34:56.1394+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8464c30e-7a06-4203-8831-42415d46de3d	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E0A	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.140776+00	2026-08-27 13:34:56.140776+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
371c5b41-b0a7-44f7-be26-d6a61d987644	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	3BMGM7	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.142447+00	2026-08-27 13:34:56.142447+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
35b9f5bc-61cf-4935-b7db-be155476f332	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	39DF2N	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.143855+00	2026-08-27 13:34:56.143855+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
013289e5-fe05-4ea2-97c3-3ebb2f7cea02	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK1NU9	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.145129+00	2026-08-27 13:34:56.145129+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bf51f0a7-3f30-42e9-b385-d119f4dbd9e2	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FKAYED	POLY	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Joe CLEMENTE"	2026-08-27 13:34:56.146427+00	2026-08-27 13:34:56.146427+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
856e27f7-9bb4-4452-88de-d8dd0257577c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FKAYF6	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.147724+00	2026-08-27 13:34:56.147724+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5814c8a0-1fba-4793-bab0-435e198979e7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK1NJH	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.149264+00	2026-08-27 13:34:56.149264+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f0be3eb5-06de-4d0e-bb0c-0ef4aceb9281	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPWE	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.172515+00	2026-08-27 13:34:56.172515+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d7a6b1ed-1c06-4a79-92b3-f78c63170046	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJP64	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.175043+00	2026-08-27 13:34:56.175043+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
01fa3f20-ff80-4b9e-b1ef-1fd242f52bc9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPV7	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.177304+00	2026-08-27 13:34:56.177304+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
27fff8f9-7a24-41ec-83a6-c5cd280f0ee2	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPV8	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.1807+00	2026-08-27 13:34:56.1807+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9a45b99c-2b03-4b61-8127-97a6b2ee0dc5	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPCG	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.183072+00	2026-08-27 13:34:56.183072+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1c4f10fd-43bf-445d-907b-4d0203b39a8c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLJPPD	POLY	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.185646+00	2026-08-27 13:34:56.185646+00	Poly Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4b8976c5-eabe-4a4b-b13f-17d96f7460f4	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MET29XW9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.188269+00	2026-08-27 13:34:56.188269+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2bb7e851-c58b-4e1c-88b0-e8d9954f8f1b	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MES2A6G9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.193023+00	2026-08-27 13:34:56.193023+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
550e1d16-6420-4b2b-9ef6-23f17adc7906	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MEZ29TG9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.197822+00	2026-08-27 13:34:56.197822+00	Logitech Zone vibe(copie 2)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
46e9e1f6-648c-4133-8100-02d280fcd85c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502ME529SB9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.201466+00	2026-08-27 13:34:56.201466+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bb468693-8b71-429f-bb37-6ef2dc7a20b7	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502ME92AB49	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.203671+00	2026-08-27 13:34:56.203671+00	Logitech Zone vibe(copie 4)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
583e1844-7997-4575-8086-577c8ffece76	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MEF2A969	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.206449+00	2026-08-27 13:34:56.206449+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5a8ecfbe-da77-45ba-a5c7-ab9c00fb2550	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2502MEG29S99	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.208791+00	2026-08-27 13:34:56.208791+00	Logitech Zone vibe	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d64f2520-7576-4c46-97ad-1193dbb41cd9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MH105WG9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.211331+00	2026-08-27 13:34:56.211331+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8f108382-2055-46df-aaea-b4fecef3242c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MH106S89	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.213401+00	2026-08-27 13:34:56.213401+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
da6e6430-0cfb-4746-afac-27aedb95c873	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHP0AR39	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.21541+00	2026-08-27 13:34:56.21541+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
71a13c13-2b30-4c16-bc82-79cc01ff2151	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHP0AMS9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.217319+00	2026-08-27 13:34:56.217319+00	Zone 305(copie 3)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b8182088-e5a8-44ea-a915-876683684466	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHK06NG9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.218998+00	2026-08-27 13:34:56.218998+00	Zone 305(copie 4)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4d95d81f-7ed3-450c-9919-0f398e0ff5e2	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHD06CW9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.220532+00	2026-08-27 13:34:56.220532+00	Zone 305(copie 5)	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0bd7f3c1-bd5a-43b8-9cc0-a2c2cd4739d2	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHB06419	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.222047+00	2026-08-27 13:34:56.222047+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
608e5fc4-1917-42fe-8bbc-eea154cdc9b9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHH0B289	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.223346+00	2026-08-27 13:34:56.223346+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b07e0142-e742-448c-b6a9-96f689e800a9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHR06NJ9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.224731+00	2026-08-27 13:34:56.224731+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1b5102cd-ff4c-43b6-bd29-b0b8dd9bbf65	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHT05YF9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.226099+00	2026-08-27 13:34:56.226099+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e1016c55-20bd-4007-b320-87ba572cb677	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MH106RZ9	Logitech	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Noémie SAMYCHETTY"	2026-08-27 13:34:56.227753+00	2026-08-27 13:34:56.227753+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
de048914-d083-438a-a3a9-50bf9b017f45	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MHB06K9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.229491+00	2026-08-27 13:34:56.229491+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f229f43d-7309-414f-aac1-bd01146ad6f3	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2529MH306HX9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.230955+00	2026-08-27 13:34:56.230955+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
00a9e5ec-b86c-43d3-9703-5d95f569212c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHZ0ATZ9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.232285+00	2026-08-27 13:34:56.232285+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8bef460b-59e4-4024-9290-e5461e263942	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHR0B0U9	Logitech	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.234202+00	2026-08-27 13:34:56.234202+00	Zone 305	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
06561cae-4b67-4b46-b64b-9973c86ef2e6	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW50LXEET	Samsung	SM-X205	in_stock	\N	\N	1900-01-14	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.235834+00	2026-08-27 13:34:56.235834+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	0097888483	249.00	\N	\N	1900-01-14	\N	f
d02b2198-6f15-4b7c-9dae-a00a401a0df3	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7GAW	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.237713+00	2026-08-27 13:34:56.237713+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
9192ef26-742a-484e-9497-e79b0b831cbf	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	XNF9PDY633	Apple Inc.	iPhone 13 Pro Max	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Jean Pierre RODRIGUEZ"	2026-08-27 13:34:56.239779+00	2026-08-27 13:34:56.239779+00	iPhone 13 Pro Max	\N	\N	\N	\N	f	f	\N	678.00	\N	\N	\N	\N	f
f32c0b1c-e4df-43c6-8c2f-29fd36cfed57	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R9PW500KF4X	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.242183+00	2026-08-27 13:34:56.242183+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
341aae78-abdb-400f-ac95-4d3e21ed9ebd	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	KXM73QW1WT	Apple Inc.	iPhone 13	in_stock	\N	\N	2024-04-03	IMEI: 354489174755386\nAffectation importée non résolue : Usager="-" ; Utilisateur="Ugo THIEBAUT"	2026-08-27 13:34:56.244756+00	2026-08-27 13:34:56.244756+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	2026-04-03	\N	f
8c3d6d0b-1a79-408c-b072-7c7b3d11619b	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	M72P24PMGH	Apple Inc.	iPad 10e gen	in_stock	\N	\N	1900-01-19	Affectation importée non résolue : Usager="-" ; Utilisateur="Elisa CLAVEL"	2026-08-27 13:34:56.24692+00	2026-08-27 13:34:56.24692+00	iPad 10	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	1900-01-20	\N	f
2907da3c-59f7-4b43-88b1-7c35d6b4914c	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	X7H4X7G35C	Apple Inc.	iPad 10e gen	in_stock	\N	\N	1900-01-19	Affectation importée non résolue : Usager="-" ; Utilisateur="Nathalie SOLANES"	2026-08-27 13:34:56.248953+00	2026-08-27 13:34:56.248953+00	iPad 10	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	1900-01-20	\N	f
4160da78-26f3-419d-8f12-096b4018549c	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20YZZQK	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.25103+00	2026-08-27 13:34:56.25103+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
70d4bd40-ae26-4913-bad2-ddb0b009189d	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7FRY	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.252656+00	2026-08-27 13:34:56.252656+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
f0e1edb6-b52f-4b02-9268-38e070c4c251	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7B2A	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.254222+00	2026-08-27 13:34:56.254222+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
846250d9-39cc-4e9e-8e6b-d020f249df9b	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7BZY	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.255887+00	2026-08-27 13:34:56.255887+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
73b82fce-9bea-4a05-a5cb-ac16649c672e	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X79DT	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.259589+00	2026-08-27 13:34:56.259589+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
477a45b9-9ce3-4962-a83b-119b1cc24b6c	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7F9K	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.263555+00	2026-08-27 13:34:56.263555+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
05cd57b5-6005-4d1d-9b0d-bb1efaa92a9c	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20X7G4B	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.269274+00	2026-08-27 13:34:56.269274+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
4a91248e-6559-40f2-b8ac-eb89a987a10a	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW50LXEJP	Samsung	SM-X205	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.273696+00	2026-08-27 13:34:56.273696+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
ff28e1c3-45ab-459b-8ef6-4446e82c1fd4	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20YZYDB	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.277035+00	2026-08-27 13:34:56.277035+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
39461d26-5f51-419c-8ab6-be909c61f4f6	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20Z01BD	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.279575+00	2026-08-27 13:34:56.279575+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
f3f4f7de-a005-4726-ae42-7d3d7435a659	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20YZYEH	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.286673+00	2026-08-27 13:34:56.286673+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
6271c628-152f-4d81-9fa2-0fbd7458f399	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20Z00AR	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.290062+00	2026-08-27 13:34:56.290062+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
5c38b503-23f6-4069-8891-7805864c634c	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20Z01DR	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.292476+00	2026-08-27 13:34:56.292476+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
c6b83da1-cd32-48db-87c4-c0a481a1d6e9	9b8de84b-c049-47f2-b0f0-414f33d68b90	\N	R8YW20Z005N	Samsung	SM-X200	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="dpi" ; Utilisateur="-"	2026-08-27 13:34:56.294976+00	2026-08-27 13:34:56.294976+00	Galaxy Tab A8	\N	\N	\N	\N	f	f	\N	0.00	\N	\N	\N	\N	f
fd8b1484-4331-4170-a28b-ea28194ce954	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HCG9Y47254	Apple Inc.	iPhone 13	in_stock	\N	\N	2024-04-03	Affectation importée non résolue : Usager="-" ; Utilisateur="Emilie KOEHL"	2026-08-27 13:34:56.298373+00	2026-08-27 13:34:56.298373+00	iPhone 13	\N	\N	\N	\N	f	f	\N	429.00	\N	\N	2026-04-03	\N	f
446a7bb9-291a-4117-bb51-db8aadc7f220	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979217\nAffectation importée non résolue : Usager="-" ; Utilisateur="Olivia ROUSSILLE"	2026-08-27 13:34:56.301669+00	2026-08-27 13:34:56.301669+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bf9c8e34-764e-4104-8499-c16d33c638f4	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979530\nAffectation importée non résolue : Usager="-" ; Utilisateur="Thomas FILLETTE"	2026-08-27 13:34:56.306476+00	2026-08-27 13:34:56.306476+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6a827238-3b2e-43c6-8dd5-13f308a4d7ab	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958444912571\nAffectation importée non résolue : Usager="-" ; Utilisateur="Emilie ROUZOUL"	2026-08-27 13:34:56.308929+00	2026-08-27 13:34:56.308929+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d3fedefc-f7a3-4610-b397-ffdd244c4035	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958444912712\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marylene PINCHON"	2026-08-27 13:34:56.310854+00	2026-08-27 13:34:56.310854+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
82cb85fd-b992-4925-a03f-ca30d1fca403	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443978854\nAffectation importée non résolue : Usager="-" ; Utilisateur="Romain HEDJAL"	2026-08-27 13:34:56.313065+00	2026-08-27 13:34:56.313065+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5759aa01-a646-42ab-8e7c-87fdc4e95baf	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979373\nAffectation importée non résolue : Usager="-" ; Utilisateur="Cédric FIRMIN"	2026-08-27 13:34:56.316121+00	2026-08-27 13:34:56.316121+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d08da3b7-31e2-4ccf-814d-8727d1cc982f	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647611	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:34:56.675321+00	2026-08-27 13:34:56.675321+00	PORT2605-647611	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
409ffaff-26d2-4c2b-8916-e072c735c1c7	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958444912878\nAffectation importée non résolue : Usager="-" ; Utilisateur="Sylvain DUTRELOT"	2026-08-27 13:34:56.319459+00	2026-08-27 13:34:56.319459+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
39062b47-a812-4915-a1a2-60beba43c7cb	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979597\nAffectation importée non résolue : Usager="-" ; Utilisateur="Laetitia CHARLES"	2026-08-27 13:34:56.323225+00	2026-08-27 13:34:56.323225+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
abd5399c-5450-4afb-b35b-d41e869d3a99	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958444912498\nAffectation importée non résolue : Usager="-" ; Utilisateur="Vanessa BOUCHAREYSSAS"	2026-08-27 13:34:56.325499+00	2026-08-27 13:34:56.325499+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3021b436-6941-4597-916f-2275ace7c188	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443978797\nAffectation importée non résolue : Usager="-" ; Utilisateur="Anissa BENHAMOU"	2026-08-27 13:34:56.328037+00	2026-08-27 13:34:56.328037+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
59bf8b8e-bb46-4d0c-802f-2307b4315c41	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1848301DP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958444912035\nAffectation importée non résolue : Usager="-" ; Utilisateur="Antonin BARTHAS"	2026-08-27 13:34:56.331471+00	2026-08-27 13:34:56.331471+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
34847dcd-2f58-44d5-9851-c0c40e7cdb69	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979035\nAffectation importée non résolue : Usager="-" ; Utilisateur="Nathalie SOLANES"	2026-08-27 13:34:56.3387+00	2026-08-27 13:34:56.3387+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e0fc001f-0608-4e41-9d3c-30bc6e8d7c8b	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443978698\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marjorie ZUCCHETTI"	2026-08-27 13:34:56.407722+00	2026-08-27 13:34:56.407722+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0c36e414-1385-484c-b354-e5835fe09520	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979654\nAffectation importée non résolue : Usager="-" ; Utilisateur="Sonia HESNARD COURET"	2026-08-27 13:34:56.410475+00	2026-08-27 13:34:56.410475+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8b74b1a9-adf3-45cc-b461-02d1196de573	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	\N	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443978938\nAffectation importée non résolue : Usager="-" ; Utilisateur="Rachel CONSTANS"	2026-08-27 13:34:56.417814+00	2026-08-27 13:34:56.417814+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
03f35dcd-c812-472d-b821-9114646083cf	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 35495844911953\nAffectation importée non résolue : Usager="-" ; Utilisateur="Olivier LESTARPE"	2026-08-27 13:34:56.421807+00	2026-08-27 13:34:56.421807+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
37c102a5-3c04-40c2-9d8d-c105c433793e	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979191\nAffectation importée non résolue : Usager="-" ; Utilisateur="Christelle PAYSSE"	2026-08-27 13:34:56.424004+00	2026-08-27 13:34:56.424004+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
74b5f34d-2730-4987-8924-3e83029c7962	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979706\nAffectation importée non résolue : Usager="-" ; Utilisateur="Samia MAHJOUB"	2026-08-27 13:34:56.426661+00	2026-08-27 13:34:56.426661+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1767c51d-45d0-48f8-80a4-8028e091902f	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443979795\nAffectation importée non résolue : Usager="-" ; Utilisateur="Stephane COULON"	2026-08-27 13:34:56.428706+00	2026-08-27 13:34:56.428706+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
aa8e0335-28f6-4e08-bd94-f92714231f20	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1848301DP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958444912811\nAffectation importée non résolue : Usager="-" ; Utilisateur="Dalyll REGUIA"	2026-08-27 13:34:56.432428+00	2026-08-27 13:34:56.432428+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8787a3fa-5214-48f0-8e24-1399bf691761	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	YDM1847081YP	Motorola	Edge 50 Pro	in_stock	\N	\N	\N	IMEI : 354958443978870\nAffectation importée non résolue : Usager="-" ; Utilisateur="Victor TRILHA"	2026-08-27 13:34:56.434436+00	2026-08-27 13:34:56.434436+00	Motorola Edge 50 Pro	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
385ea9e8-579e-4f9e-a41b-b436585315ac	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DG3FX470PW	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 357584542986544\nAffectation importée non résolue : Usager="-" ; Utilisateur="Elisa CLAVEL"	2026-08-27 13:34:56.442331+00	2026-08-27 13:34:56.442331+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3537c693-9d8c-46e0-bbcd-05ea0a46d5da	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	J56NV9YT4X	Apple	iPhone 16	in_stock	\N	\N	\N	IMEI : 354614892039827	2026-08-27 13:34:56.451194+00	2026-08-27 13:34:56.451194+00	iPhone 16	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f674aa46-6091-4032-9687-2cf5bae068a6	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JOWGP73FWK	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 357584542694890\nAffectation importée non résolue : Usager="-" ; Utilisateur="Brice CHAMAYOU"	2026-08-27 13:34:56.46675+00	2026-08-27 13:34:56.46675+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c7cd8bce-6b2f-4232-85a8-56349b634b51	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	KR4LN2GQCD	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 350340392327058 - Allo Lily\nAffectation importée non résolue : Usager="-" ; Utilisateur="_Allolily"	2026-08-27 13:34:56.471917+00	2026-08-27 13:34:56.471917+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7c40b365-56de-4b5d-8ec0-caaa83ad4b55	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	FQ375L4NLF	Apple	iPhone 16	in_stock	\N	\N	\N	IMEI : 352904893302098\nAffectation importée non résolue : Usager="-" ; Utilisateur="Louis-Henri CAPEL"	2026-08-27 13:34:56.47595+00	2026-08-27 13:34:56.47595+00	iPhone 16	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7a9f34b1-832d-480c-a04b-c1dbd40972ac	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HQKWFHH7NV	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 354489174569787\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marina TUNEZ"	2026-08-27 13:34:56.486657+00	2026-08-27 13:34:56.486657+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8e97fc86-ffdb-47d4-8dec-e42b3512d522	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	MQM2GM0WDG	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 350340392431066\nAffectation importée non résolue : Usager="-" ; Utilisateur="Karim MIALHE"	2026-08-27 13:34:56.49038+00	2026-08-27 13:34:56.49038+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7350580e-228f-421c-b48b-e3ee28ba39aa	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HWMWDV2QL5	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 350340391328115	2026-08-27 13:34:56.493132+00	2026-08-27 13:34:56.493132+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fd0319d6-150b-4109-8f95-78966cc31648	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	MCQNWDJ36J	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 354489174898145\nAffectation importée non résolue : Usager="-" ; Utilisateur="Ophélie DELCUSE"	2026-08-27 13:34:56.495407+00	2026-08-27 13:34:56.495407+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5247afea-ce83-46a8-b096-9080ebc04522	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JHH3HJ2RPC	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 359461434548344\nAffectation importée non résolue : Usager="-" ; Utilisateur="Marianne BOSC-ANDRIEU"	2026-08-27 13:34:56.497789+00	2026-08-27 13:34:56.497789+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
5b8eb234-8ff9-4fc0-b9ef-d3891b5fb46b	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	GTHG6660TY	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 357584542646593\nAffectation importée non résolue : Usager="-" ; Utilisateur="Hugo NAKACHE"	2026-08-27 13:34:56.500735+00	2026-08-27 13:34:56.500735+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2a5edb7e-1663-4584-9990-e6c55be7baeb	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DWVX9DP41W	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 354489174579281\nAffectation importée non résolue : Usager="-" ; Utilisateur="Guylaine DROUOT"	2026-08-27 13:34:56.505105+00	2026-08-27 13:34:56.505105+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
fcda6aad-2d54-48b5-a37d-77112fd77619	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	MDJPDF6Q1G	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 357584542527975\nAffectation importée non résolue : Usager="-" ; Utilisateur="Corinne FRAYSSINES"	2026-08-27 13:34:56.507733+00	2026-08-27 13:34:56.507733+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
962b2567-e530-49e7-809b-6a18d2e7fc92	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HWPXYL4KFX	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 357584542505021\nAffectation importée non résolue : Usager="-" ; Utilisateur="Emilie LAUTIER-VINEL"	2026-08-27 13:34:56.510288+00	2026-08-27 13:34:56.510288+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e4bb1d61-2758-4b8f-a030-455d6966bb37	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DN4H399Y64	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 351212584270462\nAffectation importée non résolue : Usager="-" ; Utilisateur="Mathilde DE TONI"	2026-08-27 13:34:56.51347+00	2026-08-27 13:34:56.51347+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
76bf17a0-7fcb-4e7d-b55f-5058840e97ae	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	KPD633FKWF	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 359461434793718\nAffectation importée non résolue : Usager="-" ; Utilisateur="Dorine VINCENT"	2026-08-27 13:34:56.516254+00	2026-08-27 13:34:56.516254+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
23d10d30-5f4f-4886-959c-788dbcbc22d2	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DHVVXGT2F1	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 359461434695236\nAffectation importée non résolue : Usager="-" ; Utilisateur="Corinne VIGNAU"	2026-08-27 13:34:56.518673+00	2026-08-27 13:34:56.518673+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d523d812-f19e-411c-8373-d9b7ad49c5a2	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JX2K1JFGWR	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 359461434501038\nAffectation importée non résolue : Usager="-" ; Utilisateur="Aurelie PALUDETTO"	2026-08-27 13:34:56.520813+00	2026-08-27 13:34:56.520813+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
894322ed-f566-4e42-96a9-6d22b705b67d	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	DYCY7T9140	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 3575845421175563\nAffectation importée non résolue : Usager="-" ; Utilisateur="Cédric COCOLO"	2026-08-27 13:34:56.523298+00	2026-08-27 13:34:56.523298+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a6fc3c71-6f98-4a5c-a949-8e3abec19961	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	D5QXFN9DXM	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 359461434840584\nAffectation importée non résolue : Usager="-" ; Utilisateur="Sana TOUMI"	2026-08-27 13:34:56.525385+00	2026-08-27 13:34:56.525385+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c2216ac3-5b97-406e-9031-fcb60dcff5a7	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	RFCX80HKMBK	Samsung	Galaxy S24	in_stock	\N	\N	\N	IMEI : 350176952376741\nAffectation importée non résolue : Usager="-" ; Utilisateur="Jean-Christophe RAYNAUD"	2026-08-27 13:34:56.530041+00	2026-08-27 13:34:56.530041+00	Galaxy S24	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
847323f3-a16f-44b8-b83a-329ff7c36d2e	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	FJVJ3Q30MW	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 350340392403032\nAffectation importée non résolue : Usager="-" ; Utilisateur="Yannis DELMAS"	2026-08-27 13:34:56.532469+00	2026-08-27 13:34:56.532469+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
21871249-e95b-401b-9a6b-20a830a81bc6	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JK37V3719X	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 357584542656303\nAffectation importée non résolue : Usager="-" ; Utilisateur="Nicolas DREUX"	2026-08-27 13:34:56.534766+00	2026-08-27 13:34:56.534766+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
17ca19d4-7bde-4cb6-ab15-39625993c466	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	JLHPDQ9G35	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 351212584090100\nAffectation importée non résolue : Usager="-" ; Utilisateur="Adeline OSBINI"	2026-08-27 13:34:56.537075+00	2026-08-27 13:34:56.537075+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
57c82fbf-54a3-4238-b22e-50c490d5cd60	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HQKWFHH7NV	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 354489174569787\nAffectation importée non résolue : Usager="-" ; Utilisateur="Volodia MINIEJEW"	2026-08-27 13:34:56.539167+00	2026-08-27 13:34:56.539167+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6ee5ca76-87e7-451f-8fda-615ed5cad92a	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	GXYP9K0C4X	Apple	iPhone 13	in_stock	\N	\N	\N	IMEI : 350340391730781	2026-08-27 13:34:56.540932+00	2026-08-27 13:34:56.540932+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
bb09b2c5-a73a-48c2-9d18-c4859190af60	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	TT67HKGVJ2	Apple	iPhone 13	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Laura AVERSAING"	2026-08-27 13:34:56.543225+00	2026-08-27 13:34:56.543225+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ddd505ca-6df3-4d32-bb79-5e4597bd5158	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	J7M64127TN	Apple	iPhone 13	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Elodie TRANTOUL"	2026-08-27 13:34:56.5452+00	2026-08-27 13:34:56.5452+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
831dcdba-7962-4a8c-84ba-12ab1f5a5a52	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	T6DXLTQ7LG	Apple	iPhone 13	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Ylan VINCENT-DAGOBERT"	2026-08-27 13:34:56.547627+00	2026-08-27 13:34:56.547627+00	iPhone 13	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2831ab05-e0da-4e4b-b5da-bed8becc3dfe	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	HWJNFPDQ9R	Apple	iPhone 14 Plus	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Cécile BOIVIN"	2026-08-27 13:34:56.550244+00	2026-08-27 13:34:56.550244+00	iPhone 14 Plus	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e54eb403-495d-4f40-87e8-20d6f20739cc	591e509f-b8f4-4b8c-ae1c-174b8f513139	\N	W14KCJXDWY	Apple	iPhone 14 Plus	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Stéphane NAKACHE"	2026-08-27 13:34:56.551938+00	2026-08-27 13:34:56.551938+00	iPhone 14 Plus	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
de0ebd0e-e7f4-4e9a-bd9a-f87894eb7a55	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	0F34VXX26043KV	Microsoft	Surface Pro, Copilot+ PC, 13 pouces	in_stock	\N	\N	2026-04-07	Clavier avec stylet Slim Pen + Surface Pro, Copilot+ PC, 13 pouces + Bloc d’alimentation 65 W\nAffectation importée non résolue : Usager="-" ; Utilisateur="Lydie RODRIGUEZ"	2026-08-27 13:34:56.553718+00	2026-08-27 13:34:56.553718+00	PORT2604-6043KV	\N	\N	\N	\N	f	f	6391125878085269170	1669.99	\N	\N	2027-04-07	\N	f
c7ab21de-55f1-413a-bfd4-8c50d1caacea	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215433	IIYAMA	XUB2497HSN-B2	in_stock	\N	\N	2026-04-17	Affectation importée non résolue : Usager="-" ; Utilisateur="Alizée POULIN-PLAZANET"	2026-08-27 13:34:56.558956+00	2026-08-27 13:34:56.558956+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
888d1252-e1fb-4c03-9226-8a7b354ab2bc	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215530	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.566594+00	2026-08-27 13:34:56.573266+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
c240b462-85df-4b93-b620-bae822b3b575	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215531	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.578862+00	2026-08-27 13:34:56.582215+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
126b327c-4750-4a29-a5ec-3c06ca2bcf6b	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215532	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.583291+00	2026-08-27 13:34:56.58581+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
c00859d2-5602-4b0f-8ebf-872d240cde19	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215533	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.589013+00	2026-08-27 13:34:56.599523+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
24198579-88ba-4172-96a1-6690a6575add	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215534	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.601141+00	2026-08-27 13:34:56.60395+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
46f4cf4a-7cec-4d8b-a0b3-45d1e7cb3ca5	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215535	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.605426+00	2026-08-27 13:34:56.614366+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
91a9551d-b7cd-46e7-8205-5416e053175f	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215536	IIYAMA	XUB2497HSN-B2	in_stock	\N	\N	2026-04-17	Affectation importée non résolue : Usager="-" ; Utilisateur="Emilie PARPAIOLA"	2026-08-27 13:34:56.615605+00	2026-08-27 13:34:56.615605+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
12fbfd93-ad0f-4236-988c-47c4492d4c40	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215537	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.617116+00	2026-08-27 13:34:56.620268+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
5ae64231-c305-4f83-a6db-7e6c468f2087	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215637	IIYAMA	XUB2497HSN-B2	in_stock	\N	\N	2026-04-17	HS	2026-08-27 13:34:56.62165+00	2026-08-27 13:34:56.62165+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
5deaf7a2-25cc-4805-8b11-8e9d87dc7d7e	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215639	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.623209+00	2026-08-27 13:34:56.625727+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
34da41e9-01af-4bc5-a60f-3304bf342fe4	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215641	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.626684+00	2026-08-27 13:34:56.629135+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
c69186f5-f15c-4453-800b-5b9feffe2364	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215642	IIYAMA	XUB2497HSN-B2	in_stock	\N	\N	2026-04-17	HS	2026-08-27 13:34:56.630266+00	2026-08-27 13:34:56.630266+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
30cfcb37-32f6-4eb3-9643-6f2037462b56	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215904	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.631864+00	2026-08-27 13:34:56.63508+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
989e02c0-5e25-4370-aced-6f491ff24730	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215905	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.63607+00	2026-08-27 13:34:56.64284+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
5c2d635c-9503-4271-9076-79ae3fe053d5	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215910	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.643881+00	2026-08-27 13:34:56.646513+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
af44c36f-07eb-42b0-9628-5531db198a57	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215914	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.64748+00	2026-08-27 13:34:56.650497+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
13de6f44-343e-4833-bdc3-df0f133bee50	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215916	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.652488+00	2026-08-27 13:34:56.656039+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
ed6ff1c2-2032-46c9-b101-44a05fe86d2d	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215917	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.657356+00	2026-08-27 13:34:56.659843+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
33074271-c15f-4fbc-b07f-660d8c6fc016	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354215918	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	2026-04-17	\N	2026-08-27 13:34:56.660924+00	2026-08-27 13:34:56.663269+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	160.00	\N	\N	2031-04-17	\N	f
2b8ae264-1e10-4cbb-bfc1-1c6d78bd0beb	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	BK33K8X26133KV	Microsoft	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Lydie RODRIGUEZ"	2026-08-27 13:34:56.664352+00	2026-08-27 13:34:56.664352+00	PORT2604-6133KV	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f8c07281-8c27-4136-ac08-fff9efedaf7d	3981e88a-85b7-4a12-9342-dca750713f52	\N	1249354613812	IIYAMA	XUB2497HSN-B2	assigned	\N	\N	\N	\N	2026-08-27 13:34:56.665907+00	2026-08-27 13:34:56.668289+00	IIYAMA Station	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c48cc951-1018-44a9-b942-b8efb84be1ed	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647610	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	Affectation importée non résolue : Usager="-" ; Utilisateur="Volodia MINIEJEW"	2026-08-27 13:34:56.669381+00	2026-08-27 13:34:56.669381+00	PORT2605-647610	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
68c0b9cf-aa4a-41f1-aba9-ef252ae20593	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647607	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:34:56.671455+00	2026-08-27 13:34:56.671455+00	PORT2605-647607	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b6926a49-269b-4972-9c29-e707a25e8502	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647606	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	Affectation importée non résolue : Usager="-" ; Utilisateur="Mathieu MUSCAT"	2026-08-27 13:34:56.673164+00	2026-08-27 13:34:56.673164+00	PORT2605-647606	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
364b6fd1-4a36-4c80-8144-d6a192af5388	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647604	Wortmann_AG	FR1220873-1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:34:56.676784+00	2026-08-27 13:34:56.676784+00	PORT2605-647604	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f07e30ae-f85c-49a9-a1b6-8175a4a698a7	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647602	Wortmann_AG	FR1220873	in_stock	\N	\N	2026-05-11	Affectation importée non résolue : Usager="-" ; Utilisateur="Ylan VINCENT-DAGOBERT"	2026-08-27 13:34:56.678242+00	2026-08-27 13:34:56.678242+00	PORT2605-647602	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8c10981f-2f48-4678-93cb-19ad75836302	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647605	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:34:56.679687+00	2026-08-27 13:34:56.679687+00	PORT2605-647605	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1b68132e-383c-47b6-a5fb-69359de8bbaa	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647603	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	Affectation importée non résolue : Usager="-" ; Utilisateur="Séverine AMIEL"	2026-08-27 13:34:56.681315+00	2026-08-27 13:34:56.681315+00	PORT2605-647603	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e9dbc667-50d0-4663-937a-5934827154c5	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647609	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:34:56.690475+00	2026-08-27 13:34:56.690475+00	PORT2605-647611	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
4af717db-1d11-4ff4-b9db-53565993ba98	3ab36349-b101-4fe4-9cd2-33f5ee8270a0	\N	R8647608	Wortmann_AG	FR1220873;1470967	in_stock	\N	\N	2026-05-11	\N	2026-08-27 13:34:56.69285+00	2026-08-27 13:34:56.69285+00	PORT2605-647608	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
69e01549-8c4e-4341-afb3-ae89c26d983f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M2F	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Laetitia BADIBANGA"	2026-08-27 13:34:56.694874+00	2026-08-27 13:34:56.694874+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c6f4e0f2-01ad-46bf-94de-7f8c96efe180	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M51	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Marine FORESTIER"	2026-08-27 13:34:56.696563+00	2026-08-27 13:34:56.696563+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1206c32f-fb40-4a0a-a8c9-1af77bf2ef09	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205LZZ	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Romain HEDJAL"	2026-08-27 13:34:56.698136+00	2026-08-27 13:34:56.698136+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
c2c502f0-1d59-4511-a7f5-c20bd2ae91bd	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M3C	Lenovo	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.699851+00	2026-08-27 13:34:56.699851+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b34fc2e8-c6df-4d3b-85eb-289df5c9ddc0	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205KH2	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Jonathan NINEUIL"	2026-08-27 13:34:56.701373+00	2026-08-27 13:34:56.701373+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e8adb651-dd07-4b4e-b702-e93a56c3de16	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205K9F	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Olivia ROUSSILLE"	2026-08-27 13:34:56.702719+00	2026-08-27 13:34:56.702719+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
6a7f906e-5195-4be0-8d02-754fde0d789c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205LYC	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Antonin BARTHAS"	2026-08-27 13:34:56.703821+00	2026-08-27 13:34:56.703821+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0a673c5d-f12d-4c4b-b085-2596aff60155	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205LW1	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Nicolas DAUTEL"	2026-08-27 13:34:56.705024+00	2026-08-27 13:34:56.705024+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
17eade79-5028-4f54-a9f4-1522d9a5c960	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205MA2	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Volodia MINIEJEW"	2026-08-27 13:34:56.706439+00	2026-08-27 13:34:56.706439+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2f1a5240-03a0-44e8-8bef-d22f4f4f33ca	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M10	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Manon SANTOS"	2026-08-27 13:34:56.707854+00	2026-08-27 13:34:56.707854+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
195a8438-6603-4249-9ab7-c2530610bf26	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205MA1	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Manon RODRIGUEZ"	2026-08-27 13:34:56.709611+00	2026-08-27 13:34:56.709611+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3f5ed2cd-795e-4603-a2f5-3dfcbd5e7ad9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M9Q	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Karim MIALHE"	2026-08-27 13:34:56.711049+00	2026-08-27 13:34:56.711049+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3ab9564d-646f-4af3-b576-0c9c1842ffb9	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205LZV	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Stephane COULON"	2026-08-27 13:34:56.712498+00	2026-08-27 13:34:56.712498+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ee18cad3-dbb7-4c6b-96d5-2a7d179d9dab	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205KCH	Lenovo	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.714125+00	2026-08-27 13:34:56.714125+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
3e924594-ec8d-4929-9cb0-90de877e3355	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M1N	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Andy Touré"	2026-08-27 13:34:56.716021+00	2026-08-27 13:34:56.716021+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d438be4b-6f37-4c6c-9b1b-fac4047b39f1	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M06	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Soumia GRASSAUD"	2026-08-27 13:34:56.719971+00	2026-08-27 13:34:56.719971+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
cafad28f-bbb6-45c6-a064-2ac2638896af	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M4P	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Enya SARDA"	2026-08-27 13:34:56.722216+00	2026-08-27 13:34:56.722216+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
e3e75c95-ab9a-4e01-af6d-dc3cebe759d4	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M3W	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Aurélie COMBES"	2026-08-27 13:34:56.724093+00	2026-08-27 13:34:56.724093+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
2bbdad62-2794-4394-ad27-1c189f774888	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205MOR	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Marie-Morgane PORTE"	2026-08-27 13:34:56.726208+00	2026-08-27 13:34:56.726208+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
46c79da8-33ad-4465-8546-9d9072b751aa	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	AG205M41	Lenovo	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Grégoire MASSAT"	2026-08-27 13:34:56.727785+00	2026-08-27 13:34:56.727785+00	Lenovo wireless Volp headset	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
640baac1-5876-4ca2-a93a-42781371b43f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRKYG	\N	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Elsa BARASCUD"	2026-08-27 13:34:56.729478+00	2026-08-27 13:34:56.729478+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
a7069a6a-8281-454b-91a9-443eddaeec6f	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRL5F	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.73113+00	2026-08-27 13:34:56.73113+00	Poly 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f0054509-c316-40c0-afd3-c96c60742a6f	3981e88a-85b7-4a12-9342-dca750713f52	\N	CN-ORHS1R	Dell	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Mélanie MARESTANG"	2026-08-27 13:34:56.732757+00	2026-08-27 13:34:56.732757+00	Dell	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b953b561-9519-4df9-80c4-8884baaa5d55	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRL6W	Poly	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.7348+00	2026-08-27 13:34:56.7348+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
12be7cd6-16f5-43f7-9a44-f3c343e1e019	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRL57	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.736612+00	2026-08-27 13:34:56.736612+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
f50091b2-0cf5-488d-84fb-4e74cdc89953	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511937A2153	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:56.738459+00	2026-08-27 13:34:56.741853+00	iiyama	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
61d3464c-38fe-4d4f-8a5f-3fe85ebf6aeb	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	\N	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.743554+00	2026-08-27 13:34:56.743554+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
d44b0fe1-d588-4a7f-a45d-ca90a2781f19	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJAUXB	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.81725+00	2026-08-27 13:34:56.81725+00	Poly voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8bdcab4c-a3d6-47b9-8dcd-72783e801d92	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE004687	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:56.82135+00	2026-08-27 13:34:56.825107+00	Fujitsu	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
1006fb43-00e7-41df-a3c7-071b956f6c3e	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE004886	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:56.826455+00	2026-08-27 13:34:56.829505+00	Fujitsu	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
eda58a47-c1e0-4538-81b5-b636341560cf	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE066912	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:56.830891+00	2026-08-27 13:34:56.835071+00	Fujitsu	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
96684743-45e7-4a02-807e-6f89d0152954	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	39FRMG	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.836757+00	2026-08-27 13:34:56.836757+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
7a6142ca-ec06-49be-b097-ae5eb4a90b14	3981e88a-85b7-4a12-9342-dca750713f52	\N	YVBE003037	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:56.838971+00	2026-08-27 13:34:56.84338+00	Futjitsu	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
53bb3576-4cbc-4d39-bd8c-56995bfd8c91	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511209E2732	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:56.844974+00	2026-08-27 13:34:56.848638+00	IIYAMA	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
650e348d-76bc-4263-9353-495b0c42959c	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FLPC6	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.850188+00	2026-08-27 13:34:56.850188+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b8acb55d-ae83-4101-81cc-5a44d0580db8	3981e88a-85b7-4a12-9342-dca750713f52	\N	11511209E2728	\N	\N	assigned	\N	\N	\N	\N	2026-08-27 13:34:56.85227+00	2026-08-27 13:34:56.856703+00	IIYAMA	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
0922bd17-9bd5-4b04-96f7-7f25282bdd36	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRLJ2	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.858144+00	2026-08-27 13:34:56.858144+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
b12c5f0f-5c1e-49d5-b4da-3c07ab191391	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FK7E4B	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.859739+00	2026-08-27 13:34:56.859739+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
8dd86370-c460-46e6-a6d2-fb960421f7b1	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	FJRL60	\N	\N	in_stock	\N	\N	\N	\N	2026-08-27 13:34:56.861203+00	2026-08-27 13:34:56.861203+00	Voyager 4320	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
ac415096-c775-4e8a-9dab-47420148c598	0202aa13-5afb-42a4-9ca2-9c09967c79bb	\N	2527MHR0B0U8	\N	\N	in_stock	\N	\N	\N	Affectation importée non résolue : Usager="-" ; Utilisateur="Mathieu MUSCAT"	2026-08-27 13:34:56.86295+00	2026-08-27 13:34:56.86295+00	LOGI	\N	\N	\N	\N	f	f	\N	\N	\N	\N	\N	\N	f
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

\unrestrict uV5UAFXi4V0kktJVUlDXq9ADiUZYH8aC06jXhobkWkpaa1Hq2GPPbqSX2u5QZAh

