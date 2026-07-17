--
-- PostgreSQL database dump
--

\restrict vNC6p48MEOjb0L9tA1tvIf2zBUOwlsbCwdKPxw0tDff5NrjH6DtWQa0AtSDTJjk

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

ALTER TABLE ONLY public.work_groups DROP CONSTRAINT work_groups_created_by_fkey;
ALTER TABLE ONLY public.work_group_members DROP CONSTRAINT work_group_members_work_group_id_fkey;
ALTER TABLE ONLY public.work_group_members DROP CONSTRAINT work_group_members_project_user_id_fkey;
ALTER TABLE ONLY public.work_group_members DROP CONSTRAINT work_group_members_added_by_fkey;
ALTER TABLE ONLY public.reviews DROP CONSTRAINT reviews_assignment_id_fkey;
ALTER TABLE ONLY public.prompt_templates DROP CONSTRAINT prompt_templates_project_id_fkey;
ALTER TABLE ONLY public.projects DROP CONSTRAINT projects_created_by_fkey;
ALTER TABLE ONLY public.project_users DROP CONSTRAINT project_users_user_id_fkey;
ALTER TABLE ONLY public.project_users DROP CONSTRAINT project_users_project_id_fkey;
ALTER TABLE ONLY public.form_schemas DROP CONSTRAINT form_schemas_project_id_fkey;
ALTER TABLE ONLY public.form_schemas DROP CONSTRAINT form_schemas_created_by_fkey;
ALTER TABLE ONLY public.project_work_groups DROP CONSTRAINT fk_work_group;
ALTER TABLE ONLY public.project_work_groups DROP CONSTRAINT fk_project;
ALTER TABLE ONLY public.documents DROP CONSTRAINT documents_project_id_fkey;
ALTER TABLE ONLY public.conflicts DROP CONSTRAINT conflicts_review2_id_fkey;
ALTER TABLE ONLY public.conflicts DROP CONSTRAINT conflicts_review1_id_fkey;
ALTER TABLE ONLY public.conflicts DROP CONSTRAINT conflicts_document_id_fkey;
ALTER TABLE ONLY public.conflicts DROP CONSTRAINT conflicts_arbiter_id_fkey;
ALTER TABLE ONLY public.audit_log DROP CONSTRAINT audit_log_user_id_fkey;
ALTER TABLE ONLY public.assignments DROP CONSTRAINT assignments_reviewer_id_fkey;
ALTER TABLE ONLY public.assignments DROP CONSTRAINT assignments_form_schema_id_fkey;
ALTER TABLE ONLY public.assignments DROP CONSTRAINT assignments_document_id_fkey;
ALTER TABLE ONLY public.assignments DROP CONSTRAINT assignments_assigned_by_fkey;
ALTER TABLE ONLY public.ai_requests DROP CONSTRAINT ai_requests_user_id_fkey;
ALTER TABLE ONLY public.ai_requests DROP CONSTRAINT ai_requests_prompt_template_id_fkey;
ALTER TABLE ONLY public.ai_requests DROP CONSTRAINT ai_requests_project_id_fkey;
DROP TRIGGER trg_work_groups_updated_at ON public.work_groups;
DROP INDEX public.ix_users_email;
DROP INDEX public.idx_wgm_project_user;
DROP INDEX public.idx_wgm_group;
ALTER TABLE ONLY public.work_groups DROP CONSTRAINT work_groups_pkey;
ALTER TABLE ONLY public.work_group_members DROP CONSTRAINT work_group_members_pkey;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
ALTER TABLE ONLY public.work_group_members DROP CONSTRAINT uq_group_member;
ALTER TABLE ONLY public.reviews DROP CONSTRAINT reviews_pkey;
ALTER TABLE ONLY public.reviews DROP CONSTRAINT reviews_assignment_id_key;
ALTER TABLE ONLY public.prompt_templates DROP CONSTRAINT prompt_templates_pkey;
ALTER TABLE ONLY public.projects DROP CONSTRAINT projects_pkey;
ALTER TABLE ONLY public.project_work_groups DROP CONSTRAINT project_work_groups_pkey;
ALTER TABLE ONLY public.project_users DROP CONSTRAINT project_users_pkey;
ALTER TABLE ONLY public.form_schemas DROP CONSTRAINT form_schemas_pkey;
ALTER TABLE ONLY public.documents DROP CONSTRAINT documents_pkey;
ALTER TABLE ONLY public.conflicts DROP CONSTRAINT conflicts_pkey;
ALTER TABLE ONLY public.audit_log DROP CONSTRAINT audit_log_pkey;
ALTER TABLE ONLY public.assignments DROP CONSTRAINT assignments_pkey;
ALTER TABLE ONLY public.alembic_version DROP CONSTRAINT alembic_version_pkc;
ALTER TABLE ONLY public.ai_requests DROP CONSTRAINT ai_requests_pkey;
DROP TABLE public.work_groups;
DROP TABLE public.work_group_members;
DROP TABLE public.users;
DROP TABLE public.reviews;
DROP TABLE public.prompt_templates;
DROP TABLE public.projects;
DROP TABLE public.project_work_groups;
DROP TABLE public.project_users;
DROP TABLE public.form_schemas;
DROP TABLE public.documents;
DROP TABLE public.conflicts;
DROP TABLE public.audit_log;
DROP TABLE public.assignments;
DROP TABLE public.alembic_version;
DROP TABLE public.ai_requests;
DROP FUNCTION public.set_updated_at();
DROP TYPE public.submissionstatus;
DROP TYPE public.reviewmode;
DROP TYPE public.projecttype;
DROP TYPE public.projectstatus;
DROP TYPE public.projectrole;
DROP TYPE public.fieldgroup;
DROP TYPE public.documentphase;
DROP TYPE public.decision;
DROP TYPE public.conflictstatus;
DROP TYPE public.assignmentstatus;
DROP TYPE public.assignmentrole;
DROP TYPE public.assignmentmethod;
--
-- Name: assignmentmethod; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.assignmentmethod AS ENUM (
    'manual',
    'random',
    'rule',
    'ai'
);


ALTER TYPE public.assignmentmethod OWNER TO sysrev_user;

--
-- Name: assignmentrole; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.assignmentrole AS ENUM (
    'reviewer1',
    'reviewer2',
    'arbiter'
);


ALTER TYPE public.assignmentrole OWNER TO sysrev_user;

--
-- Name: assignmentstatus; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.assignmentstatus AS ENUM (
    'pending',
    'in_progress',
    'completed'
);


ALTER TYPE public.assignmentstatus OWNER TO sysrev_user;

--
-- Name: conflictstatus; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.conflictstatus AS ENUM (
    'open',
    'escalated',
    'resolved'
);


ALTER TYPE public.conflictstatus OWNER TO sysrev_user;

--
-- Name: decision; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.decision AS ENUM (
    'include',
    'exclude',
    'unsure'
);


ALTER TYPE public.decision OWNER TO sysrev_user;

--
-- Name: documentphase; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.documentphase AS ENUM (
    'identification',
    'screening',
    'eligibility',
    'included',
    'excluded',
    'gt2_registered',
    'gt2_coded'
);


ALTER TYPE public.documentphase OWNER TO sysrev_user;

--
-- Name: fieldgroup; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.fieldgroup AS ENUM (
    'identification',
    'characterization',
    'analytical',
    'reviewer_metadata'
);


ALTER TYPE public.fieldgroup OWNER TO sysrev_user;

--
-- Name: projectrole; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.projectrole AS ENUM (
    'admin',
    'reviewer',
    'arbiter'
);


ALTER TYPE public.projectrole OWNER TO sysrev_user;

--
-- Name: projectstatus; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.projectstatus AS ENUM (
    'planning',
    'in_progress',
    'completed'
);


ALTER TYPE public.projectstatus OWNER TO sysrev_user;

--
-- Name: projecttype; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.projecttype AS ENUM (
    'scientific',
    'technical'
);


ALTER TYPE public.projecttype OWNER TO sysrev_user;

--
-- Name: reviewmode; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.reviewmode AS ENUM (
    'collaborative',
    'double',
    'mixed'
);


ALTER TYPE public.reviewmode OWNER TO sysrev_user;

--
-- Name: submissionstatus; Type: TYPE; Schema: public; Owner: sysrev_user
--

CREATE TYPE public.submissionstatus AS ENUM (
    'registered',
    'in_review',
    'completed',
    'archived'
);


ALTER TYPE public.submissionstatus OWNER TO sysrev_user;

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: sysrev_user
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$;


ALTER FUNCTION public.set_updated_at() OWNER TO sysrev_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_requests; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.ai_requests (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    prompt_template_id uuid,
    input_hash character varying(255),
    response json,
    suggestion character varying(50),
    user_action character varying(50),
    user_id uuid,
    created_at timestamp without time zone
);


ALTER TABLE public.ai_requests OWNER TO sysrev_user;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO sysrev_user;

--
-- Name: assignments; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.assignments (
    id uuid NOT NULL,
    document_id uuid NOT NULL,
    reviewer_id uuid NOT NULL,
    form_schema_id uuid,
    role public.assignmentrole,
    method public.assignmentmethod,
    status public.assignmentstatus,
    deadline timestamp without time zone,
    assigned_by uuid,
    created_at timestamp without time zone
);


ALTER TABLE public.assignments OWNER TO sysrev_user;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.audit_log (
    id uuid NOT NULL,
    user_id uuid,
    action character varying(100) NOT NULL,
    entity character varying(100) NOT NULL,
    entity_id character varying(100),
    data_before json,
    data_after json,
    created_at timestamp without time zone
);


ALTER TABLE public.audit_log OWNER TO sysrev_user;

--
-- Name: conflicts; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.conflicts (
    id uuid NOT NULL,
    document_id uuid NOT NULL,
    review1_id uuid,
    review2_id uuid,
    status public.conflictstatus,
    arbiter_id uuid,
    final_decision public.decision,
    arbiter_justification text,
    created_at timestamp without time zone,
    resolved_at timestamp without time zone
);


ALTER TABLE public.conflicts OWNER TO sysrev_user;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.documents (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    title character varying(500) NOT NULL,
    source_type character varying(100),
    file_url character varying(1000),
    external_reference character varying(1000),
    copyright_status character varying(50),
    access_restriction character varying(50),
    language character varying(10),
    country_region character varying(100),
    submission_status public.submissionstatus,
    duplicate_flag boolean,
    phase public.documentphase,
    extra_metadata json,
    created_at timestamp without time zone
);


ALTER TABLE public.documents OWNER TO sysrev_user;

--
-- Name: form_schemas; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.form_schemas (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    protocol public.projecttype NOT NULL,
    "group" public.fieldgroup NOT NULL,
    version integer,
    name character varying(255) NOT NULL,
    fields_json json NOT NULL,
    active boolean,
    created_by uuid,
    created_at timestamp without time zone
);


ALTER TABLE public.form_schemas OWNER TO sysrev_user;

--
-- Name: project_users; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.project_users (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role public.projectrole NOT NULL,
    invited_at timestamp without time zone,
    accepted boolean
);


ALTER TABLE public.project_users OWNER TO sysrev_user;

--
-- Name: project_work_groups; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.project_work_groups (
    project_id uuid NOT NULL,
    work_group_id uuid NOT NULL,
    associated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.project_work_groups OWNER TO sysrev_user;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.projects (
    id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    type public.projecttype NOT NULL,
    lead_institution character varying(255),
    countries character varying[],
    languages character varying[],
    review_mode public.reviewmode,
    status public.projectstatus,
    created_by uuid,
    created_at timestamp without time zone
);


ALTER TABLE public.projects OWNER TO sysrev_user;

--
-- Name: prompt_templates; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.prompt_templates (
    id uuid NOT NULL,
    project_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    purpose character varying(50),
    prompt_text text NOT NULL,
    active boolean
);


ALTER TABLE public.prompt_templates OWNER TO sysrev_user;

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.reviews (
    id uuid NOT NULL,
    assignment_id uuid NOT NULL,
    answers_json json,
    decision public.decision,
    exclusion_reason text,
    confidence integer,
    review_round integer,
    finalized boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.reviews OWNER TO sysrev_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255),
    active boolean,
    preferred_language character varying(10),
    created_at timestamp without time zone,
    country character varying(255),
    institution character varying(255),
    is_active boolean
);


ALTER TABLE public.users OWNER TO sysrev_user;

--
-- Name: work_group_members; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.work_group_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    work_group_id uuid NOT NULL,
    project_user_id uuid NOT NULL,
    role character varying(50),
    added_at timestamp with time zone DEFAULT now() NOT NULL,
    added_by uuid
);


ALTER TABLE public.work_group_members OWNER TO sysrev_user;

--
-- Name: work_groups; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.work_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.work_groups OWNER TO sysrev_user;

--
-- Data for Name: ai_requests; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.ai_requests (id, project_id, prompt_template_id, input_hash, response, suggestion, user_action, user_id, created_at) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.alembic_version (version_num) FROM stdin;
a1b2c3d4e5f6
\.


--
-- Data for Name: assignments; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.assignments (id, document_id, reviewer_id, form_schema_id, role, method, status, deadline, assigned_by, created_at) FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.audit_log (id, user_id, action, entity, entity_id, data_before, data_after, created_at) FROM stdin;
640ee787-38a3-4225-ace7-48a576d125a0	d536a1ea-4c05-486d-af09-8deb3f3b5baa	create	project	8c5f10a5-e1e5-4441-92d0-64e6a83a798d	null	{"title": "test", "description": "test", "type": "scientific", "lead_institution": null, "countries": [], "working_group": null, "languages": [], "review_mode": "collaborative"}	2026-07-15 16:32:56.696953
a79a25d5-41b1-48b3-8f33-5c7bbf6df7e6	d536a1ea-4c05-486d-af09-8deb3f3b5baa	create	project	290803ba-24a8-4c07-b712-646e7bfc5cad	null	{"title": "test title", "description": "test description", "type": "scientific", "lead_institution": null, "countries": [], "languages": [], "review_mode": "collaborative", "work_group_ids": null}	2026-07-15 22:11:57.817868
\.


--
-- Data for Name: conflicts; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.conflicts (id, document_id, review1_id, review2_id, status, arbiter_id, final_decision, arbiter_justification, created_at, resolved_at) FROM stdin;
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.documents (id, project_id, title, source_type, file_url, external_reference, copyright_status, access_restriction, language, country_region, submission_status, duplicate_flag, phase, extra_metadata, created_at) FROM stdin;
\.


--
-- Data for Name: form_schemas; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.form_schemas (id, project_id, protocol, "group", version, name, fields_json, active, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: project_users; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.project_users (id, project_id, user_id, role, invited_at, accepted) FROM stdin;
956bbb4f-31ca-47fd-aeac-d32e14e452a8	8c5f10a5-e1e5-4441-92d0-64e6a83a798d	d536a1ea-4c05-486d-af09-8deb3f3b5baa	admin	2026-07-15 16:32:56.699881	t
78e76a02-4391-4227-af5e-b20dbb8a0ae5	290803ba-24a8-4c07-b712-646e7bfc5cad	d536a1ea-4c05-486d-af09-8deb3f3b5baa	admin	2026-07-15 22:11:57.823512	t
\.


--
-- Data for Name: project_work_groups; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.project_work_groups (project_id, work_group_id, associated_at) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.projects (id, title, description, type, lead_institution, countries, languages, review_mode, status, created_by, created_at) FROM stdin;
8c5f10a5-e1e5-4441-92d0-64e6a83a798d	test	test	scientific	\N	{}	{}	collaborative	planning	d536a1ea-4c05-486d-af09-8deb3f3b5baa	2026-07-15 16:32:56.685618
290803ba-24a8-4c07-b712-646e7bfc5cad	test title	test description	scientific	\N	{}	{}	collaborative	planning	d536a1ea-4c05-486d-af09-8deb3f3b5baa	2026-07-15 22:11:57.80608
\.


--
-- Data for Name: prompt_templates; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.prompt_templates (id, project_id, name, purpose, prompt_text, active) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.reviews (id, assignment_id, answers_json, decision, exclusion_reason, confidence, review_round, finalized, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.users (id, name, email, password_hash, active, preferred_language, created_at, country, institution, is_active) FROM stdin;
d536a1ea-4c05-486d-af09-8deb3f3b5baa	admin	admin@sysrev.com	$2b$12$LkeItroHLRXgdbpi5oo/9urpAYW/JWUp/VVcclhTgkeyagPFlFTyq	t	pt-BR	2026-07-14 22:42:32.152984	\N	\N	\N
c74ba631-e77c-4ce6-b424-020fc08b3f51	Eralda GJIKA (DHAMO)	eraldagjika@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	Universiteti Metropolitan Tirana	\N
d129202e-9fef-4c7e-87b5-56c3054b997d	Rezarta SHKURTI (PERRI)	rezartaperri@feut.edu.al	\N	t	\N	2026-07-15 19:17:59.600542	Albania	University of Tirana	\N
bb1402a4-e034-4dec-92e2-4f33bce4ecf9	An-Sofie CLAEYS	ansofie.claeys@ugent.be	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	Ghent University	\N
9d103e53-67a6-4140-959e-2e9fc0554a96	Nerma HALILOVIĆ-KIBRIĆ	nhalilovic@fkn.unsa.ba	\N	t	\N	2026-07-15 19:17:59.600542	Bosnia & Herzegovina	University of Sarajevo - Faculty of Criminal Justice and Security Studies	\N
1108d537-ab14-4052-876b-6bb58d6d95b6	Ivan GANCHEV	igantchev@hotmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	Plovdivski Universitet Paisiy Hilendarski	\N
e9328a28-8eda-49a3-8d64-fd8afacd535c	Georgi TSOCHEV	gtsochev@tu-sofia.bg	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	Technical University Of Sofia	\N
52dfff01-7588-4b25-bfcb-322e1fecdedc	Hrvoje JAKOPOVIĆ	hrvoje.jakopovic@fpzg.hr	\N	t	\N	2026-07-15 19:17:59.600542	Croatia	University of Zagreb, Faculty of Political Science	\N
c76d5b42-2fbd-44b4-bc10-f6844e35c411	Lambros LAMBRINOS	lambros.lambrinos@cut.ac.cy	\N	t	\N	2026-07-15 19:17:59.600542	Cyprus	Cyprus University of Technology	\N
936f54bb-02e3-4982-bbb2-e4cec7f46ebe	Premysl ROSULEK	rosulek@ff.zcu.cz	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	University of West Bohemia	\N
211cfcf9-5089-4c69-86e1-b2dd7d6e9cb1	Jan SVETLIK	jan.svetlik@mendelu.cz	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	Mendel university in Brno - Mendel University in Brno	\N
40325ca8-0503-44bb-97e2-65b3de4b6546	Sunniva SANDBUKT	suns@itu.dk	\N	t	\N	2026-07-15 19:17:59.600542	Denmark	IT University of Copenhagen	\N
821f0c3f-6f95-47d6-9e30-5816ec19b002	Sten TORPAN	sten.torpan@ut.ee	\N	t	\N	2026-07-15 19:17:59.600542	Estonia	University of Tartu	\N
26eacb0d-5b79-436c-9279-5ad0ccd4e10d	Heini RUOHONEN	heini.ruohonen@abo.fi	\N	t	\N	2026-07-15 19:17:59.600542	Finland	Abo Akademi University	\N
f718ff07-cc36-4d66-8614-b44cefe54415	Minttu TIKKA	minttu.mt.tikka@helsinki.fi	\N	t	\N	2026-07-15 19:17:59.600542	Finland	Finnish Institute for Health and Welfare	\N
99af1276-c6fb-4d00-a51b-361cbf7fdbdf	Romain Michel Louis-Marie HUET	rhhuet@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	France	Université Rennes 2	\N
04dc221f-d68f-4c84-bf56-2748b2e7d816	Sylvia BACH	sbach@uni-wuppertal.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Bergische Universitaet  Wuppertal	\N
6dfe26d9-7b15-4cb6-85b8-fd5be33c4057	Andreas SCHWARZ	andreas.schwarz@tu-ilmenau.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Technische Universitaet Ilmenau	\N
1e8ec142-738a-48ce-b069-87e7445194fe	Giannis ADAMOS	adamos.giannis@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Greece	Aristotle University of Thessaloniki	\N
8af673e6-edb8-4461-bd32-a99df4d84aa1	Neofytos ASPRIADIS	asprto@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Greece	Hellenic Parliament	\N
83b95ab5-7017-4dd8-b217-caaa1913efb1	Douglas CUBIE	d.cubie@ucc.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	University College Cork	\N
81f310dc-3513-4138-a6c3-eda24c09da83	Krishnendu GUHA	kguha@ucc.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	University College Cork	\N
f8ab43d1-01a5-4fa7-8821-84e36bf758d5	Christian ESPOSITO	esposito@unisa.it	\N	t	\N	2026-07-15 19:17:59.600542	Italy	University of Salerno	\N
3a6a81e4-2939-4d95-b9b5-adf9e29e538c	Valentina GRASSO	valentina.grasso@cnr.it	\N	t	\N	2026-07-15 19:17:59.600542	Italy	Consiglio Nazionale delle Ricerche	\N
79063b2c-f72a-4a67-8980-d68bfbe25d10	Lasma SKESTERE	lasma.skestere@rsu.lv	\N	t	\N	2026-07-15 19:17:59.600542	Latvia	Riga Stradins University	\N
a309413d-62a5-43d0-8b78-03e77a125af0	Renata MATKEVIČIENĖ	renata.matkeviciene@kf.vu.lt	\N	t	\N	2026-07-15 19:17:59.600542	Lithuania	Vilnius University	\N
9df36a52-ffbe-46ad-bb3a-d3fbd4110204	Nina ROSCOVAN	ninaroscovan@yahoo.com	\N	t	\N	2026-07-15 19:17:59.600542	Moldova	Academy of Economic Studies of Moldova	\N
716875db-6d40-4f4f-96cc-13b94103bf58	Srna Sudar	srna.sudar@ntpark.me	\N	t	\N	2026-07-15 19:17:59.600542	Montenegro	Naucno - Tehnoloski Park Crne Gore	\N
fc42831e-e523-4286-b1f9-b526b9fe2935	Yijing WANG	y.wang@eshcc.eur.nl	\N	t	\N	2026-07-15 19:17:59.600542	Netherlands	Erasmus University Rotterdam	\N
91d07dd5-27f6-46d9-b266-4b4c0aa7dddf	Toshiyuki WATANABE	twd1977jp@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Netherlands	Weather Plus Communication Design	\N
32de7d22-f03a-44c6-ae1f-8824d5a50716	Aleksandar IVANOV	aleksandar.ivanov@uklo.edu.mk	\N	t	\N	2026-07-15 19:17:59.600542	North Macedonia	University St Kliment Ohridski Bitola	\N
3deb6858-3e1a-488c-8771-eb5e3ed37a38	Natasha SARAFOVA	natasa.sarafova@ugd.edu.mk	\N	t	\N	2026-07-15 19:17:59.600542	North Macedonia	Faculty of Philology, Goce Delcev University, Stip, North Macedonia	\N
43f88929-25dc-41fd-94ed-194b004314dd	Oyvind IHLEN	oyvind.ihlen@media.uio.no	\N	t	\N	2026-07-15 19:17:59.600542	Norway	University of Oslo	\N
cff7d746-2482-4313-883a-2b6222659683	Åshild KOLÅS	ashild@prio.org	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Institutt For Fredsforskning	\N
6b5b1952-16d6-4fd7-95ff-ec21646ce24e	Dariusz WIECEK	d.wiecek@il-pib.pl	\N	t	\N	2026-07-15 19:17:59.600542	Poland	National Institute of Telecommunications	\N
5e49fd4f-4827-4d99-a8c4-1a6e2979e54f	Malgorzata WINIARSKA-BRODOWSKA	malgorzata.brodowska@uj.edu.pl	\N	t	\N	2026-07-15 19:17:59.600542	Poland	Jagiellonian University	\N
5b1e8a6c-8006-4d44-bbc6-62d41f68d1fa	Mariana CASAL-RIBEIRO	mariana.ribeiro2@edu.ulisboa.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Instituto de Geografia e Ordenamento do Território da Universidade de Lisboa	\N
803fa92b-979c-4bab-bda5-a8c642800c0c	Gisela GONÇALVES	gisela@ubi.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade Da Beira Interior	\N
8740934e-16e6-46ed-8176-d2692214ee30	Camelia CMECIU	camelia.cmeciu@fjsc.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	University of Bucharest	\N
3d39ed21-d1bd-4542-8817-c5dbd41466a8	Corina DABA-BUZOIANU	corina.buzoianu@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	\N
6ae345ed-ce06-4eb7-b88b-86b72a6b3097	Vladimir CVETKOVIĆ	vladimirkpa@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Univeristet U Beogradu,fakultet Bezbednosti	\N
fe149854-182e-482a-9603-5cb2820156a0	Snežana ŽIVKOVIĆ	snezana.zivkovic@znrfak.ni.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Faculty of Occupational Safety, University of Nis	\N
9cfba57c-2438-40d0-947f-de48e9c00d2a	Veronika MICHVOCÍKOVÁ	veronika.michvocikova@ucm.sk	\N	t	\N	2026-07-15 19:17:59.600542	Slovakia	University of Ss. Cyril and Methodius in Trnava	\N
54692b52-4742-4c65-949c-010935eec26c	Denis TRČEK	denis.trcek@guest.arnes.si	\N	t	\N	2026-07-15 19:17:59.600542	Slovenia	University of Ljubljana	\N
d8fbd7e5-609f-477b-880e-883ae38f0516	Jose Manuel NOGUERA VIVO	jmnoguera@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad Católica San Antonio de Murcia	\N
294e5037-490b-46b7-ac30-53d21c24eb1e	Guadalupe ORTIZ	guadalupe.ortiz@ua.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad de Alicante	\N
1416724f-825f-41f1-9da7-b35b902e641e	Bengt JOHANSSON	bengt.johansson@jmg.gu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	University of Gothenburg	\N
7ab3fe95-67b7-4777-bf53-334b4bd41d5d	Henrik OLINDER	henrik.olinder@msb.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Swedish Civil Contingencies Agency (MSB) - Henrik Olinder	\N
5ebf041c-893d-431c-b9f2-0b7b4cd4c579	Albena BJÖRCK	bjoe@zhaw.ch	\N	t	\N	2026-07-15 19:17:59.600542	Switzerland	Zurich University of Applied Sciences	\N
1aaba79f-c26b-4c00-889e-2947663f234c	Daniel VOGLER	daniel.vogler@foeg.uzh.ch	\N	t	\N	2026-07-15 19:17:59.600542	Switzerland	University of Zurich	\N
b7c9fc07-a247-4c86-a517-10113882c9b1	Altug AKIN	altugakin@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Izmir Ekonomi Universitesi	\N
8cb1df1e-09d7-4c9f-b04c-a9f9a38cfee1	Ebru KAYAALP JURICH	ebru.kayaalp@yeditepe.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Yeditepe University Vakif	\N
12c923ce-6874-4b31-8c98-735d5d3e7918	Dariya Orlova	dasha.orlova@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Ukraine	National University Of Kyiv-mohyla Academy	\N
5a2601f9-1037-488f-adfa-f2062be4d0a6	Daria Taradai	daria.taradai@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Ukraine	National University Of Kyiv-mohyla Academy	\N
503fe4af-db72-44fa-9fba-7e90009e7733	Galena PISONI	g.pisoni@yorksj.ac.uk	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	York St John University	\N
2d4a6b7c-9f11-4c91-b56f-bb2645e45deb	Florian Meissner	florian.meissner@h-da.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Hochschule Darmstadt (university Of Applied Sciences H-da)	\N
bb741d67-1540-4bbf-bb9e-3375eefd7e74	Angelo Basteris	angelo.basteris@cost.eu	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	COST Association	\N
08859ec9-d769-4c76-a801-4867ec6ec428	Ekaterina Zemlyankina	ekaterina.zemlyankina@cost.eu	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	COST Association	\N
6698ef9a-1566-4350-896d-37b40e244bb0	Monica BIRA	monica.bira@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	\N
ee37c43b-d3e6-4d74-ae02-2870560ab7b4	Fuzel Ahamed SHAIK	fuzel.shaik@oulu.fi	\N	t	\N	2026-07-15 19:17:59.600542	Finland	University of Oulu	\N
d8e75128-dab0-45f9-9018-fc91bfa0cb27	Bianca PERSICI TONIOLO	bianca.toniolo@ubi.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade Da Beira Interior	\N
fe4ecb11-91ef-46a9-ac7b-71578c2c7eec	Roberta RĂDUCU	roberta.raducu@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	\N
9d2b715d-32c4-4e37-baee-b442dd99a9dd	Pavel RODIN	pr.rodin@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	University of Gothenburg	\N
52f5b0e0-ad6d-4ce4-9dc1-8112addbfb12	Lauren TRACZYKOWSKI	l.traczykowski@aston.ac.uk	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	Aston University	\N
a9aa2bd8-a650-4c7f-bfbf-75f2b0996659	Amalia TRIANTAFILLIDOU	atriantafylidou@uowm.gr	\N	t	\N	2026-07-15 19:17:59.600542	Greece	University of Western Macedonia	\N
34da3bfe-a60c-4492-ba08-fa4e0e054c08	Catalin DINU	catalin-adrian.dinu@fjsc.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	University of Bucharest	\N
cb54cb6d-8fe7-4789-bcac-59a2bed658c3	Francis ALPERS	francis.alpers@tu-ilmenau.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Technische Universitaet Ilmenau	\N
1c524749-3a38-4487-bdbe-847b0cba31e6	Junwen GUO	junwen.guo@umu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Umea University	\N
a0e8b93a-8a04-403f-ab16-a145a3c819cd	Jurgen MECAJ	jurgenmecaj96@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	Mediterranean University of Albania	\N
e73a6695-01b8-4196-affd-87ef356db2e8	Michael WALLENGREN LYNCH	michael.wallengren-lynch@mau.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Malmö Universitet	\N
46e3d654-c6b0-432d-908e-12c302497160	Mourad OUSSALAH	mourad.oussalah@oulu.fi	\N	t	\N	2026-07-15 19:17:59.600542	Finland	University of Oulu	\N
07f0f5d5-4461-4281-ad89-1e120b47d4a0	Mónica RODRIGUES	masanrodrigues@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade de Coimbra	\N
5f169236-d61c-4526-aabd-6adcf21298a0	Pao-lin BEUSELINCK	paolin.beuselinck@nccn.fgov.be	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	National Crisis Center	\N
ca26c2f5-6e89-4f96-834f-5a58fe081b65	Rui TEIXEIRA	rui.teixeira@tcd.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	The Provost, Fellows, Foundation Scholars, and the other members of Board, of the College of the Holy and Undivided Trinity of Queen Elizabeth near Dublin	\N
02914380-dffd-4dfd-804b-5006d8a7b3c5	Sofia JOHANSSON	sofia.johansson@jmg.gu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	University of Gothenburg	\N
a68d2993-5368-45c4-b168-da532ca08643	Tatjana GOLUBOVIC	tatjana.golubovic@znrfak.ni.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Faculty of Occupational Safety, University of Nis	\N
112d3493-b6ab-4d0a-9b42-b47e07c6250a	Vanja ROKVIC	vanjarokvic@fb.bg.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Univerzitet U Beogradu	\N
daa08613-6cc4-4934-adbe-70fb6e85dbe8	Dejan VASOVIĆ	dejan.vasovic@znrfak.ni.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Faculty of Occupational Safety, University of Nis	\N
81ae3066-d4c6-4fdb-b6ac-8e2b6236b736	Karen DA COSTA	karen.da.costa@gu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	University of Gothenburg	\N
4367b9cd-2b9a-4aff-8fcb-2fa7a29e65b4	Avelina HEILMAIER	avelina.heilmaier@lfbk.rlp.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Landesamt für Brand- und Katastrophenschutz Rheinland-Pfalz	\N
12e7dcf5-7b0e-4f6a-ad0e-190f617c859e	Alexander FEKETE	alexander.fekete@th-koeln.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Technische Hochschule Koln	\N
4377639e-1c7f-4574-82a2-6f8ce076261d	Samuel TOMCZYK	samuel.tomczyk@uni-greifswald.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Universitaet Greifswald	\N
cf91f3af-57f4-49a7-b1b6-09c493a674fb	Vesela IVANOVA	veivanova@abv.bg	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	South-west University Neofit Rilski	\N
8ee9f996-89c4-428f-bf4f-3cd6df536222	Ayça DAĞLI	aycadagli10@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Istinye University	\N
a20e909b-171b-4689-8ff0-02cc72b23dbc	Aizhana DZHUMALIEVA	dzhumalieva_a@auca.kg	\N	t	\N	2026-07-15 19:17:59.600542	Kyrgyzstan	American University of Central Asia (AUCA)	\N
1c60f815-cac4-45f8-8bce-671c7d521aca	Steven VENETTE	danger.venette@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	United States	The University of Southern Mississippi	\N
c2561bf4-e126-47eb-a144-71447879ad79	Hatice OZ PEKTAS	haticeoz@haticeoz.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Istinye University	\N
e8139189-9424-4b62-a488-bb48cda96c2a	Joel IVERSON	joel.iverson@umontana.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	University of Montana	\N
d13635d7-79db-4640-bc2c-441dd6da9859	Audra DIERS-LAWSON	audra.diers-lawson@kristiania.no	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Hoyskolen Kristiania - Ernst G. Mortensens Stiftelse	\N
ef9b9940-ced6-47d0-b122-3cb98d174a07	Hamilton BEAN	hamilton.bean@ucdenver.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	University of Colorado Denver	\N
929c2731-5e5e-449b-a96c-cefcb0908fb6	METEHAN ATAY	metehanatay1@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Hasan Kalyoncu University	\N
4a178b83-8e4f-4daf-933c-1cb895eb0804	VINCENZA CONTE	enza.conte10@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Italy	University of Salerno	\N
e8e9f0e6-0ea3-4b6e-9b67-4cb431eb10f7	Ewa GLOWIENKA	eglo@agh.edu.pl	\N	t	\N	2026-07-15 19:17:59.600542	Poland	AGH University of Krakow	\N
d6aa7baa-41a8-416b-b1a1-f1ce0d26b707	Marie ARONSSON-STORRIER	maronsson-storrier@ucc.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	University College Cork	\N
cb42b2fa-daa8-430e-b47f-6be9575501d2	Jaroslav DVORAK	jaroslav.dvorak@ku.lt	\N	t	\N	2026-07-15 19:17:59.600542	Lithuania	Klaipeda University	\N
cbb4ff94-b4a0-4c39-a60b-c2fa55248ced	Michiel SCHEERLINCK	michiel.scheerlinck@nccn.fgov.be	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	Nationaal Crisiscentrum	\N
0149a56a-9632-474b-b09e-f3564b2db028	Evelien BURGERS	evelien.burgers@ugent.be	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	Ghent University	\N
99486640-9102-452d-96d8-43595ef63c59	Juliana ALCANTARA	alc.juli@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Netherlands	Erasmus University Rotterdam	\N
8c524bad-b62d-4714-8bf6-7a1e9e3bec6a	Tănase TASENȚE	tanase.tasente@365.univ-ovidius.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Universitatea Ovidius Din Constanta	\N
73b6fc2b-25af-4444-9f67-6b1de9c790be	Fatih CICEK	cicekfatihh@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Manisa Celal Bayar University	\N
234a5fd3-1e52-4816-9c4e-67ee34af38a1	Gisiela KLEIN	gisiela@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade de Coimbra	\N
d661c376-1a5f-4801-9ecb-2561bcb614c1	İhsan Tarık ÇELIK	ihsantarikcelik@eskisehir.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Eskisehir Technical University	\N
5a00af31-6d81-48a2-a3ec-c2cf42b18d26	Miroslav PLUNDRICH	plundrim@ff.zcu.cz	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	University of West Bohemia	\N
b409fd62-949c-471c-89f0-11cbd6c54865	Bodo ERHARDT	bodo.erhardt@dwd.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Deutscher Wetterdienst	\N
044cb460-641f-425d-8832-2acb0f3525bd	Lazar PENDOV	lpendov@uni-plovdiv.bg	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	Plovdiv University "Paisii Hilendarski"	\N
1ab7ae9a-29c8-458d-bf23-807630827f2e	Elifnur TERZIOĞLU YURTSAL	elifnur.terzioglu@mku.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Hatay Mustafa Kemal University	\N
3d43f941-105f-468d-9eb9-032fc1606720	Alexandra CIOTIR	alexandra.ciotir@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	\N
742893f5-91c4-4c86-ae9a-8e178b4ad6e7	Ömer Faruk KARAKÖSE	omerfaruk.karakose@erdogan.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Recep Tayyip Erdogan University	\N
06ab1219-9664-49fc-92c6-bb839b8611de	Sakir ESITTI	sakir.esitti@comu.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Çanakkale Onsekiz Mart University	\N
2d67d927-b688-447a-944d-592aff5100e8	Roy JACOBSEN	royaulie.jacobsen@kristiania.no	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Hoyskolen Kristiania - Ernst G. Mortensens Stiftelse	\N
cd9c47b6-eb10-4812-9cb9-7ca16edae55c	A. Elisabeth HASSELSTRÖM	elisabeth.hasselstrom@kristiania.no	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Hoyskolen Kristiania - Ernst G. Mortensens Stiftelse	\N
0e3d08ae-92cc-474d-9c4f-83edb6ba6c66	Helene Liisi KEIS	helene.liisi.keis@ut.ee	\N	t	\N	2026-07-15 19:17:59.600542	Estonia	University of Tartu	\N
37edcf41-b9fa-4178-876e-8f93c5872148	Kelley DE POLT	kdepolt@bgc-jena.mpg.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Max Planck Institute for Biogeochemistry	\N
e93eac36-42ff-4f26-a02d-1f41f930affc	Péter PÁNTYA	pantya.peter@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Hungary	University of Publis Service	\N
2eb3d7ee-1b19-4801-b8d3-b016bd68592f	Panagiotis PREVENTIS	ppreventis1@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Greece	University of Western Macedonia	\N
2a143c5c-02e4-45c1-9de3-25e9d959e255	Ling YANG	ly3n24@soton.ac.uk	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	University of Southampton	\N
3507b72e-d374-42f3-918d-7e242a6f4d9d	Ezgi ATALAY	ezgiatalay@ibu.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	BOLU ABANT IZZET BAYSAL UNIVERSITY	\N
5dc88f64-6e17-40d1-84e1-f5776a12783c	Gamil GAMAL	gamil.gamal@cu.edu.eg	\N	t	\N	2026-07-15 19:17:59.600542	Egypt	Cairo University	\N
daceffb2-16a3-4bab-ad9d-eb98d600f759	Carina FEARNLEY	c.fearnley@ucl.ac.uk	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	University College London	\N
bd785fa5-b689-4880-a71c-b4cd8cc71212	Gisele BORGES	giseborges@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	France	Laboratory of Information and Communication Sciences	\N
f2ceb828-fea9-46e5-9bb3-6c0871ab8823	Erkan SAKA	sakaerka@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Istanbul Bilgi University	\N
eee19910-73e0-4328-8a65-d5177f4cd1e9	Klorenta PASHAJ	klorenta.pashaj@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	National Authority for Cyber Security	\N
d93b2475-4766-48ba-82c9-9f7ba8f9fb50	Maik ELSTER	maik.elster@swr.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Südwestrundfunk	\N
f20820f6-ec3d-4be9-834b-ba68b1e8526d	Marlis PRINZING	m.prinzing@macromedia.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Macromedia University of Applied Sciences	\N
dac3a347-18e4-494d-90da-1db27fff2837	Michael KLAFFT	michael.klafft@jade-hs.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Jade Hochschule Wilhelmshaven/oldenburg/elsfleth	\N
693ede3b-8b3f-40aa-9922-b22955e8d0bb	Patricia M. SCHUETTE	patricia.schuette@hspv.nrw.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	University of Applied Sciences for Police and Public Administration in North Rhine-Westphalia	\N
4786a44a-03f8-420e-910d-ab48c8471881	Ramadan ÇIPURI	rcipuri16@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	University of Tirana	\N
40b91973-ceea-46b2-9721-49c44839ebd3	Renate RENNER	renate.renner@unileoben.ac.at	\N	t	\N	2026-07-15 19:17:59.600542	Austria	Montanuniversitaet Leoben	\N
02affa09-6d87-4398-91f9-64e1ead5c73f	Rūta KUPETYTĖ	ruta.kupetyte@kf.vu.lt	\N	t	\N	2026-07-15 19:17:59.600542	Lithuania	Vilnius University	\N
741637a5-141b-44b6-95c6-38c279f492e9	Michele ROTH-DUEHRKOOP	michele.roth-duehrkoop@bbk.bund.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Federal Office of Civil Protection and Disaster Assistance	\N
43e5f4d1-08cf-46d9-99ee-dd9e876b5286	Antonio ALEDO	antonio.aledo@ua.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad de Alicante	\N
81bf4bf4-0f66-4846-a519-7cb3f14d4aba	Florian STALLKAMP	florian.stallkamp@lfbk.rlp.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Landesamt für Brand- und Katastrophenschutz Rheinland-Pfalz	\N
1045cc40-6ff0-47b1-b7b5-bc2f5b1466c3	Elise RUETER	elise.rueter@bbk.bund.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Federal Office of Civil Protection and Disaster Assistance	\N
5fb3173c-0e93-43f1-a26a-dd12f6fc5c17	Jose Carlos LOSADA	jclosada@hotmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Spain	University of Murcia	\N
eaac3c9e-9860-4293-ba05-0a66c3ab3c9c	David BOGATAJ	david.bogataj@almamater.si	\N	t	\N	2026-07-15 19:17:59.600542	Slovenia	Univerza Alma Mater Europaea	\N
3d987bb5-6822-4d91-9df7-4894fb5f7e6e	Raimon ALLMUCA	rai_mono@hotmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	Drejtoria e Pergjithshme e Objekteve Publike, Bashkia Tirane	\N
781f75a4-5c7b-476b-b8b0-cf5f18e1d4d1	Benjamin DUNCAN	info@alert-not-alarmed.com	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	Alert Not Alarmed Enterprises Ltd	\N
f1f6e4a1-11e8-467a-b3e5-bd507c9d4ed6	Matthew SEEGER	matthew.seeger@wayne.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	Wayne State University	\N
4bbb3943-3177-4c96-9949-41f9ee51e811	Juan-Andres RINCON-GONZALEZ	jrincon@up.edu.mx	\N	t	\N	2026-07-15 19:17:59.600542	Mexico	Centros Culturales de Mexico A.C. - Universidad Panamericana	\N
b663d43a-e384-4e6e-ab18-0415ecafc4bb	Deanna SELLNOW	dsellno@clemson.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	Clemson University	\N
4f619497-c561-4ffb-b84d-74b8e4b0c5c2	Ngoc-Son LE	ngocsonle@greatway.vn	\N	t	\N	2026-07-15 19:17:59.600542	Vietnam	Mekong University	\N
234df429-085d-49b6-ae9b-179a8dcad305	Mikael ASHORN	mikael.ashorn@umu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Umea Universitet	\N
7f54516f-81f4-435a-a276-dab779389d8c	Timothy SELLNOW	tsellno@clemson.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	Clemson University	\N
27792ac2-804c-466f-937b-3933b8d1e382	Arbresha MEHA	arbresha.meha@ushaf.net	\N	t	\N	2026-07-15 19:17:59.600542	Kosovo*	University of Applied Sciences in Ferizaj	\N
eccd9d6a-5911-47f3-96d8-3321e59219ee	Esra BOZKANAT	esra.bozkanat@klu.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Kirklareli University	\N
fd2ef43c-0933-4da3-9fa7-0b37b6dde6e9	FARRUKH SHAHZAD	farrukh1999@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Pakistan	Bahria University	\N
1f441b58-3e14-4094-95e4-9b771688443a	Jesus Antonio ARROYAVE CABRERA	jarroyav@uninorte.edu.co	\N	t	\N	2026-07-15 19:17:59.600542	Colombia	Universidad del Norte	\N
b7769976-7ef3-41ff-8f9a-1977b1ee32bc	Angella NAPAKOL	angella.napakol@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Uganda	Uganda Christian University	\N
fe57af03-a9d1-46fa-a065-0ba70c4b822c	Pierre GEHL	p.gehl@brgm.fr	\N	t	\N	2026-07-15 19:17:59.600542	France	Bureau De Recherches Geologiques Et Minieres	\N
192f42ba-ca40-40d2-974a-5d8136237945	Julia GERSTER	gerster-damerow.julia.e1@tohoku.ac.jp	\N	t	\N	2026-07-15 19:17:59.600542	Japan	National University Corporation Tohoku University	\N
2f66f9de-4eee-4384-9e51-2b037317a2f0	Sebastien BORET	boret.sebastien.a4@tohoku.ac.jp	\N	t	\N	2026-07-15 19:17:59.600542	Japan	Tohoku University	\N
2ef3b465-92b0-4447-bdce-9982e1ff5b8a	Jaroslav VALUCH	j.valuch@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	Ministry Of The Interior Of The Czech Republic	\N
c820b443-6eac-4c0d-8845-3b34ed1f9f28	Blas SUBIELA	blas.subiela@urjc.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad Rey Juan Carlos	\N
5c4c2753-2eb2-40b5-94e8-1a5822fc99b7	Salih APAYDIN	salih.apaydin@istinye.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Istinye University	\N
047b9858-bfdf-4bb0-a9dc-ed7480661390	HATİCE ÇEŞME	h.cesme@atauni.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Ataturk University	\N
85ee96e8-cb62-4323-976b-380157e22b69	Oguz Han SIMSEK	oguzhansimsek@sakarya.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Sakarya University	\N
e870e8e1-8a63-42f3-895c-956422c9dfc9	Beatriz CORREYERO RUIZ	bcorreyero@ucam.edu	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad Católica de Murcia (UCAM)	\N
73b47fc1-66c0-44ef-a7ef-aad8382da7c2	Dinah Kristin RODE	dinah-kristin.rode@dwd.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Deutscher Wetterdienst	\N
d0ff126f-0531-415e-8c8f-ea2a21d857ae	Murat SEYFI	seyfi.murat@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Tokat Gaziosmanpasa Universitesi	\N
86ba9b8e-a89c-4975-85a4-a1d39f652406	Lars RADEMACHER	lars.rademacher@h-da.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Hochschule Darmstadt (university Of Applied Sciences H-da)	\N
ce52cd07-feb7-4cac-b199-9d0a5412209c	Anni CARLSSON	anni.carlsson@fhs.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Swedish Defence University	\N
ba31be22-1bcf-4c4d-a99e-84297b46e746	Diogo Miguel PINTO	dspinto@letras.up.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade do Porto	\N
a14255db-de70-4392-a078-06f49e4ae25b	Muhammad Auwal AHMAD	auwal@sakarya.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Sakarya University	\N
a402ad83-076d-4b85-9046-db9d4b54dde0	Ylvije KRAJA	ylvije.kraja@unishk.edu.al	\N	t	\N	2026-07-15 19:17:59.600542	Albania	University of Shkoder "Luigj Gurakuqi"	\N
91f15544-f2c9-40b7-9a77-6bb7c2131736	Salih BALCI	slhbalci@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Tokat Gaziosmanpasa Universitesi	\N
be4f0f15-1a26-40d3-a6b4-83068732c145	Zafer KIYAN	zkiyan@media.ankara.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Ankara Universitesi	\N
d6174363-f64c-4023-b2f2-f38a3161718c	HELENA MARTÍNEZ	helena1260@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Spain	University of Murcia	\N
eb68a954-6dbf-4c03-9762-1770eefb6e6b	elizabeth REDDY	reddy@mines.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	Colorado School Of Mines	\N
b617f0dc-5771-4d0c-9bcf-7e0ecdf45a13	Cari GUITTARD	cguittard@smcgov.org	\N	t	\N	2026-07-15 19:17:59.600542	United States	San Mateo County Emergency Management	\N
d3d6f700-c3fc-438c-b837-dfeaf721d2ce	Fatih ERTAM	fatih.ertam@firat.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Firat University	\N
9bb8fe4a-93a9-4572-ba5b-b53f15839ec6	Lacin Idil OZTIG	lacinidiltr@yahoo.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Yildiz Technical University	\N
b647e462-2308-4dfb-afb5-cb1fa8349e53	Dilek NAM	dnam@sakarya.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Sakarya University	\N
b123d708-6d8f-46d0-b672-ac226eaf72e3	Lydia CUMISKEY	lcumiskey@ucc.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	MaREI, University College Cork - MaREI, Environment Research Institute	\N
24844912-86b7-496a-a13f-186c02a2cf2e	Stine BERGERSEN	stiber@prio.org	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Peace Research Institute Oslo (PRIO)	\N
d5d801d1-2286-4b98-a9dc-ebb7d5d708cf	Elisa LAHCENE	e.lahcene@brgm.fr	\N	t	\N	2026-07-15 19:17:59.600542	France	BRGM - French Geological Survey	\N
13dbcdaf-b53f-47b1-9330-e37f72025c11	Ali Alpcan OFLUOĞLU	alpcanofluoglu@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Karadeniz Teknik Universitesi	\N
82150693-5c7d-4723-9235-8149f28f3271	Manuel PARDO RIOS	mpardo@ucam.edu	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad Católica San Antonio de Murcia	\N
689d9c3a-2383-4cf2-a77a-a956e24eea98	Håkon STRAUME	haakon.straume@everbridge.com	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Everbridge Norway As	\N
dab1d081-68b7-45c1-b016-99d7aa51fb03	Anna KIEBER-WALSER	anna.walser@regierung.li	\N	t	\N	2026-07-15 19:17:59.600542	Liechtenstein	Government of the Principality of Liechtenstein	\N
ad66a489-fd0f-472e-9f55-ae40d3d45dc9	Muammer ALBAYRAK	m.albayrak@ktu.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Karadeniz Teknik Universitesi	\N
0535c69b-e2d2-4efd-898e-e5dfd733781f	Tutana KVARATSKHELIA	t.kvaratskhelia@weg.ge	\N	t	\N	2026-07-15 19:17:59.600542	Georgia	World Experience for Georgia	\N
5e88dcb9-4616-46a0-a959-97a08efa8025	Lucia PETROVIČOVÁ	lucia.petrovicova.lp@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	Faculty of Forestry and Wood Technology,  Mendel University, Brno	\N
d275e033-b513-436f-af30-d7080e067ed5	Altin IDRIZI	altin.idrizi@uniel.edu.al	\N	t	\N	2026-07-15 19:17:59.600542	Albania	Universiteti Aleksander Xhuvani	\N
92f70ef4-4145-4574-844d-55b2b4b3cd31	Anisia BOANTA	anisia.boanta@mai.gov.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Department for Emergency Situations	\N
a4b0d222-6899-478f-8561-7d9f5316912e	Elena IDRIZI	helena-12.12@hotmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	University Of National And World Economy	\N
4950c028-b0e8-4440-8d27-1de890045ad3	Tamara RAĐENOVIĆ	tamara.radjenovic@znrfak.ni.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Faculty of Occupational Safety, University of Nis	\N
7d08051f-356b-4600-a439-1dfc644a1558	franco CASULA	francocasula@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Italy	Corpo Forestale e di Vigilanza Ambientale Regione Sardegna (Italy)	\N
2a090287-aba8-4722-841e-2e0ad67e1525	Mar GRANDIO	mgrandio@um.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	University of Murcia	\N
d66d93ec-6461-468d-9333-0f471d5358cf	Diana CEUSAN	diana.ceusan@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	\N
186dca2c-3a3e-4b88-aa3e-2e8bfa56b80b	Lucian BARBACARU	lucian.barbacaru@student.uaic.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Universitatea Alexandru Ioan Cuza Din Iasi	\N
9f285184-fb26-4976-aeaa-daa7fec222f0	Elif KUTUKOGLU	elifkutukoglu@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Gümüşhane University, Faculty of Communication	\N
ac2b8471-1982-4e62-aec8-288ca46e1af9	Rafael CASTRO-DELGADO	castrorafael@uniovi.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad de Oviedo	\N
51615209-0e00-4c97-823b-0a64e21c230a	ROCIO ZAMORA	rzamoramedina@um.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	University of Murcia	\N
ec304188-bd07-41f0-865a-5d55c1478a7a	Shahira S FAHMY	shahira.fahmy@fulbrightmail.org	\N	t	\N	2026-07-15 19:17:59.600542	Egypt	The American University In Cairo	\N
3c7e54c9-7a79-4832-990e-6f1d858fc35b	Vera ANTUNES	vantunes@ubi.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade Da Beira Interior	\N
38125c04-dc52-4d41-b16d-ce77b7a0a299	Teresa CASTELEIRO	teresamc@ubi.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade Da Beira Interior	\N
09abda04-1779-4ecb-9eca-41b29876d39e	Tuğçe AYDOĞAN KILIÇ	tggceaydgn@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Gümüşhane University, Faculty of Communication	\N
\.


--
-- Data for Name: work_group_members; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.work_group_members (id, work_group_id, project_user_id, role, added_at, added_by) FROM stdin;
\.


--
-- Data for Name: work_groups; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.work_groups (id, name, description, created_by, created_at, updated_at, is_active) FROM stdin;
8a0eb1a1-6ab1-4c80-88be-7dc76a283c8c	WG 1	Mapping extant data and research on disaster communication/warning systems in Europe	1416724f-825f-41f1-9da7-b35b902e641e	2026-07-15 19:39:54.30405+00	2026-07-15 19:39:54.30405+00	t
16df90b8-aa49-4974-8eb7-004c701c220d	WG 2	Mapping challenges of implementing effective warning communication	fc42831e-e523-4286-b1f9-b526b9fe2935	2026-07-15 19:43:14.506547+00	2026-07-15 19:43:14.506547+00	t
70578703-c8b9-46dc-a70e-c07c8848b029	WG 3	Developing open-access knowledge platform for communication disaster and warning systems across Europe	cff7d746-2482-4313-883a-2b6222659683	2026-07-15 19:44:12.173+00	2026-07-15 19:44:12.173+00	t
d723f427-5e4f-484d-97f6-e9bb46550961	WG 4	Disseminating knowledge of best practices in Europe	a309413d-62a5-43d0-8b78-03e77a125af0	2026-07-15 19:45:20.319464+00	2026-07-15 19:45:20.319464+00	t
\.


--
-- Name: ai_requests ai_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.ai_requests
    ADD CONSTRAINT ai_requests_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: conflicts conflicts_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.conflicts
    ADD CONSTRAINT conflicts_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: form_schemas form_schemas_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.form_schemas
    ADD CONSTRAINT form_schemas_pkey PRIMARY KEY (id);


--
-- Name: project_users project_users_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_pkey PRIMARY KEY (id);


--
-- Name: project_work_groups project_work_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_work_groups
    ADD CONSTRAINT project_work_groups_pkey PRIMARY KEY (project_id, work_group_id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: prompt_templates prompt_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.prompt_templates
    ADD CONSTRAINT prompt_templates_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_assignment_id_key; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_assignment_id_key UNIQUE (assignment_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: work_group_members uq_group_member; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.work_group_members
    ADD CONSTRAINT uq_group_member UNIQUE (work_group_id, project_user_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: work_group_members work_group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.work_group_members
    ADD CONSTRAINT work_group_members_pkey PRIMARY KEY (id);


--
-- Name: work_groups work_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.work_groups
    ADD CONSTRAINT work_groups_pkey PRIMARY KEY (id);


--
-- Name: idx_wgm_group; Type: INDEX; Schema: public; Owner: sysrev_user
--

CREATE INDEX idx_wgm_group ON public.work_group_members USING btree (work_group_id);


--
-- Name: idx_wgm_project_user; Type: INDEX; Schema: public; Owner: sysrev_user
--

CREATE INDEX idx_wgm_project_user ON public.work_group_members USING btree (project_user_id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: sysrev_user
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: work_groups trg_work_groups_updated_at; Type: TRIGGER; Schema: public; Owner: sysrev_user
--

CREATE TRIGGER trg_work_groups_updated_at BEFORE UPDATE ON public.work_groups FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: ai_requests ai_requests_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.ai_requests
    ADD CONSTRAINT ai_requests_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: ai_requests ai_requests_prompt_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.ai_requests
    ADD CONSTRAINT ai_requests_prompt_template_id_fkey FOREIGN KEY (prompt_template_id) REFERENCES public.prompt_templates(id);


--
-- Name: ai_requests ai_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.ai_requests
    ADD CONSTRAINT ai_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: assignments assignments_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- Name: assignments assignments_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: assignments assignments_form_schema_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_form_schema_id_fkey FOREIGN KEY (form_schema_id) REFERENCES public.form_schemas(id);


--
-- Name: assignments assignments_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.users(id);


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: conflicts conflicts_arbiter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.conflicts
    ADD CONSTRAINT conflicts_arbiter_id_fkey FOREIGN KEY (arbiter_id) REFERENCES public.users(id);


--
-- Name: conflicts conflicts_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.conflicts
    ADD CONSTRAINT conflicts_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: conflicts conflicts_review1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.conflicts
    ADD CONSTRAINT conflicts_review1_id_fkey FOREIGN KEY (review1_id) REFERENCES public.reviews(id);


--
-- Name: conflicts conflicts_review2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.conflicts
    ADD CONSTRAINT conflicts_review2_id_fkey FOREIGN KEY (review2_id) REFERENCES public.reviews(id);


--
-- Name: documents documents_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_work_groups fk_project; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_work_groups
    ADD CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_work_groups fk_work_group; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_work_groups
    ADD CONSTRAINT fk_work_group FOREIGN KEY (work_group_id) REFERENCES public.work_groups(id) ON DELETE CASCADE;


--
-- Name: form_schemas form_schemas_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.form_schemas
    ADD CONSTRAINT form_schemas_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: form_schemas form_schemas_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.form_schemas
    ADD CONSTRAINT form_schemas_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_users project_users_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: project_users project_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_users
    ADD CONSTRAINT project_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: projects projects_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: prompt_templates prompt_templates_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.prompt_templates
    ADD CONSTRAINT prompt_templates_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: reviews reviews_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id);


--
-- Name: work_group_members work_group_members_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.work_group_members
    ADD CONSTRAINT work_group_members_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: work_group_members work_group_members_project_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.work_group_members
    ADD CONSTRAINT work_group_members_project_user_id_fkey FOREIGN KEY (project_user_id) REFERENCES public.project_users(id) ON DELETE CASCADE;


--
-- Name: work_group_members work_group_members_work_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.work_group_members
    ADD CONSTRAINT work_group_members_work_group_id_fkey FOREIGN KEY (work_group_id) REFERENCES public.work_groups(id) ON DELETE CASCADE;


--
-- Name: work_groups work_groups_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.work_groups
    ADD CONSTRAINT work_groups_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict vNC6p48MEOjb0L9tA1tvIf2zBUOwlsbCwdKPxw0tDff5NrjH6DtWQa0AtSDTJjk

