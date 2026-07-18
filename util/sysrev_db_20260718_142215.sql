--
-- PostgreSQL database dump
--

\restrict uZoiGv8REB2T3OgQgUzczN4JKf1iYyh93V9joh1wjuKtQvJZqbuRxiSskmS6PE6

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
ALTER TABLE ONLY public.project_languages DROP CONSTRAINT project_languages_project_id_fkey;
ALTER TABLE ONLY public.project_languages DROP CONSTRAINT project_languages_language_id_fkey;
ALTER TABLE ONLY public.project_countries DROP CONSTRAINT project_countries_project_id_fkey;
ALTER TABLE ONLY public.project_countries DROP CONSTRAINT project_countries_country_id_fkey;
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
DROP INDEX public.ix_languages_id;
DROP INDEX public.ix_countries_id;
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
ALTER TABLE ONLY public.project_languages DROP CONSTRAINT project_languages_pkey;
ALTER TABLE ONLY public.project_countries DROP CONSTRAINT project_countries_pkey;
ALTER TABLE ONLY public.languages DROP CONSTRAINT languages_pkey;
ALTER TABLE ONLY public.languages DROP CONSTRAINT languages_name_key;
ALTER TABLE ONLY public.form_schemas DROP CONSTRAINT form_schemas_pkey;
ALTER TABLE ONLY public.documents DROP CONSTRAINT documents_pkey;
ALTER TABLE ONLY public.countries DROP CONSTRAINT countries_pkey;
ALTER TABLE ONLY public.countries DROP CONSTRAINT countries_name_key;
ALTER TABLE ONLY public.conflicts DROP CONSTRAINT conflicts_pkey;
ALTER TABLE ONLY public.audit_log DROP CONSTRAINT audit_log_pkey;
ALTER TABLE ONLY public.assignments DROP CONSTRAINT assignments_pkey;
ALTER TABLE ONLY public.alembic_version DROP CONSTRAINT alembic_version_pkc;
ALTER TABLE ONLY public.ai_requests DROP CONSTRAINT ai_requests_pkey;
ALTER TABLE public.languages ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.countries ALTER COLUMN id DROP DEFAULT;
DROP TABLE public.work_groups;
DROP TABLE public.work_group_members;
DROP TABLE public.users;
DROP TABLE public.reviews;
DROP TABLE public.prompt_templates;
DROP TABLE public.projects;
DROP TABLE public.project_work_groups;
DROP TABLE public.project_users;
DROP TABLE public.project_languages;
DROP TABLE public.project_countries;
DROP SEQUENCE public.languages_id_seq;
DROP TABLE public.languages;
DROP TABLE public.form_schemas;
DROP TABLE public.documents;
DROP SEQUENCE public.countries_id_seq;
DROP TABLE public.countries;
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
-- Name: countries; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    code character varying(3)
);


ALTER TABLE public.countries OWNER TO sysrev_user;

--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: sysrev_user
--

CREATE SEQUENCE public.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.countries_id_seq OWNER TO sysrev_user;

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysrev_user
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


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
-- Name: languages; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.languages (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    code character varying(5)
);


ALTER TABLE public.languages OWNER TO sysrev_user;

--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: sysrev_user
--

CREATE SEQUENCE public.languages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.languages_id_seq OWNER TO sysrev_user;

--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: sysrev_user
--

ALTER SEQUENCE public.languages_id_seq OWNED BY public.languages.id;


--
-- Name: project_countries; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.project_countries (
    project_id uuid NOT NULL,
    country_id integer NOT NULL
);


ALTER TABLE public.project_countries OWNER TO sysrev_user;

--
-- Name: project_languages; Type: TABLE; Schema: public; Owner: sysrev_user
--

CREATE TABLE public.project_languages (
    project_id uuid NOT NULL,
    language_id integer NOT NULL
);


ALTER TABLE public.project_languages OWNER TO sysrev_user;

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
    is_active boolean,
    is_admin boolean DEFAULT false NOT NULL
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
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: languages id; Type: DEFAULT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.languages ALTER COLUMN id SET DEFAULT nextval('public.languages_id_seq'::regclass);


--
-- Data for Name: ai_requests; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.ai_requests (id, project_id, prompt_template_id, input_hash, response, suggestion, user_action, user_id, created_at) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.alembic_version (version_num) FROM stdin;
c4c8d7c6717d
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
2606cdf5-2361-4ee6-8881-186b5996e4f8	d536a1ea-4c05-486d-af09-8deb3f3b5baa	create	project	53bdc4d4-f11f-4c38-84da-dabce99051e8	null	{"title": "test 1", "description": "description test", "type": "technical", "lead_institution": "University of Tirana", "countries": [], "languages": [], "review_mode": "collaborative", "work_group_ids": [], "country_ids": [5], "language_ids": [39]}	2026-07-16 14:12:32.806775
36a04cf2-05c7-4710-8a76-c2d4a504070c	d536a1ea-4c05-486d-af09-8deb3f3b5baa	create	project	527fbd02-4cb0-4105-bff7-2181e5c83dcf	null	{"title": "projeto 1", "description": "description project 1", "type": "scientific", "lead_institution": "COST Association", "countries": [], "languages": [], "review_mode": "collaborative", "work_group_ids": [], "country_ids": [32, 109], "language_ids": [3, 8]}	2026-07-16 14:16:55.128868
04447788-4f43-4a60-b10a-73e8dcda4277	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	527fbd02-4cb0-4105-bff7-2181e5c83dcf	null	{"user_email": "gisiela@gmail.com", "role": "reviewer"}	2026-07-16 14:28:02.307855
b06e28cb-e459-4363-84f0-97933017ae18	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	527fbd02-4cb0-4105-bff7-2181e5c83dcf	null	{"user_email": "bjoe@zhaw.ch", "role": "reviewer"}	2026-07-16 14:28:33.034458
3089e6ca-9691-4cd5-a02e-c701efd76aec	d536a1ea-4c05-486d-af09-8deb3f3b5baa	create	project	53207cc4-8f3b-477d-9f7a-be2c4fb3581b	null	{"title": "test title project 2", "description": "description project 2", "type": "scientific", "lead_institution": "Department for Emergency Situations", "countries": [], "languages": [], "review_mode": "collaborative", "work_group_ids": [], "country_ids": [32, 109], "language_ids": [18, 19]}	2026-07-16 14:42:26.75315
387ec658-0ec1-49dc-8388-fe9b794ed943	d536a1ea-4c05-486d-af09-8deb3f3b5baa	delete	project	8c5f10a5-e1e5-4441-92d0-64e6a83a798d	null	null	2026-07-16 18:15:22.194028
8af767a5-77d6-446f-b2e7-c576968b488a	d536a1ea-4c05-486d-af09-8deb3f3b5baa	delete	project	290803ba-24a8-4c07-b712-646e7bfc5cad	null	null	2026-07-16 18:15:27.670676
7bbae46d-2d39-41ce-816f-253b30bd8011	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	53207cc4-8f3b-477d-9f7a-be2c4fb3581b	{"title": "test title project 2", "status": "planning"}	null	2026-07-16 18:27:50.924215
d3522288-ec3c-45f8-996a-c3c1ca98031d	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	53207cc4-8f3b-477d-9f7a-be2c4fb3581b	{"title": "test title project 23", "status": "planning"}	null	2026-07-16 18:28:07.178681
951874b8-7864-468e-b2d8-60eef027e978	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	53bdc4d4-f11f-4c38-84da-dabce99051e8	{"title": "test 1", "status": "planning"}	null	2026-07-16 18:37:28.397081
a0714fe3-243b-4df7-a9ec-baeb4abdb0e1	d536a1ea-4c05-486d-af09-8deb3f3b5baa	delete	project	53bdc4d4-f11f-4c38-84da-dabce99051e8	null	null	2026-07-16 18:37:52.485275
b9c31d6e-4cc6-465b-b345-83e9b6076c8e	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	527fbd02-4cb0-4105-bff7-2181e5c83dcf	{"title": "projeto 1", "status": "planning"}	null	2026-07-16 18:39:00.816584
e3b39bad-d9b4-4464-a0a1-3cb186b60c42	d536a1ea-4c05-486d-af09-8deb3f3b5baa	delete	project	527fbd02-4cb0-4105-bff7-2181e5c83dcf	null	null	2026-07-16 18:39:07.622155
62f10a07-00e4-4dd4-b143-6146bdd8d65b	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	53207cc4-8f3b-477d-9f7a-be2c4fb3581b	{"title": "test title project 23", "status": "planning"}	null	2026-07-16 18:48:02.108748
de527f25-d1ca-46c6-ae44-c71a530b6e59	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	53207cc4-8f3b-477d-9f7a-be2c4fb3581b	null	{"user_email": "elisabeth.hasselstrom@kristiania.no", "role": "reviewer"}	2026-07-16 18:48:14.504183
b71e94ef-8d5c-4fb1-9ca2-cca349606f37	d536a1ea-4c05-486d-af09-8deb3f3b5baa	delete	project	53207cc4-8f3b-477d-9f7a-be2c4fb3581b	null	null	2026-07-16 18:48:22.582258
2d6d194d-64d2-40ba-aa28-584396758142	d536a1ea-4c05-486d-af09-8deb3f3b5baa	create	project	35bf3e26-d7a6-4878-8c04-413514e88e88	null	{"title": "test project 1", "description": "Description test project 1", "type": "scientific", "lead_institution": "Uganda Christian University", "countries": [], "languages": [], "review_mode": "collaborative", "work_group_ids": [], "country_ids": [32], "language_ids": [2]}	2026-07-16 19:13:53.151833
daa3eb7f-a11d-4e1a-b0aa-f6f4012d91f8	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-16 19:41:22.34446
d74cf4bd-c879-475e-80fa-51cff7b066c1	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-16 19:41:27.985229
2d65a397-d06a-4698-a7d8-b765c9ee57ef	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-16 19:41:30.006958
edec41b0-86a4-4326-9dfd-db9f7b2d884d	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-16 19:41:32.452959
72d2912f-f4d4-4bae-a217-27078aeb7d4e	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 12:57:01.781798
17ad8591-9e58-4005-857d-fe581aa54b3a	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 12:57:04.10851
bd04e6e3-b494-4169-b904-4149dc7b05ab	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 13:11:36.031274
3ec359ce-8e2a-44ff-b28c-8d7ffd439ad5	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 13:11:39.577584
d05626a2-46b0-4170-86ee-ab1996fcb191	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	35bf3e26-d7a6-4878-8c04-413514e88e88	null	{"user_email": "bjoe@zhaw.ch", "role": "reviewer"}	2026-07-17 13:15:31.632751
7eeaed20-f41c-48d8-9f62-ceba7f0f86c3	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 13:18:36.93441
ea188843-a681-4551-bc75-b1ac253698d2	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 13:18:45.083581
9a4df654-6dd2-42b4-848b-eb3d9490ee59	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 13:18:55.134551
ea03153b-3b39-4add-8ac1-de544c0b9ca2	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 13:22:13.894367
c1f944d1-cc31-4f2e-bebb-a0527b329ace	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 13:22:23.923953
f6b85982-340a-41fd-9c79-01970c9ab70e	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	35bf3e26-d7a6-4878-8c04-413514e88e88	null	{"user_email": "dzhumalieva_a@auca.kg", "role": "reviewer"}	2026-07-17 13:23:56.375933
a65dab92-1d2d-4483-a193-93619e25f022	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 13:24:09.138142
a5aa3fee-7990-4759-8f4a-5af5fef497eb	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 14:26:33.926937
01990eb0-42eb-4d9a-9246-6e2f7637898d	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 14:26:42.854703
8efca20e-dad9-4013-8502-d21dc68b6a94	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 14:26:43.714474
85f273c5-5f8b-41d5-bbfd-5df075892b7f	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 14:26:51.414576
8db758fd-8f84-4626-a970-6dde81e963c1	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 14:57:16.018351
95a54387-5daa-41d2-bd78-78b16adc7323	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 15:11:14.132003
245fdf40-d4d1-4272-bb40-1ea322a671be	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 15:11:19.629063
47d03653-fad6-45e3-aa3e-f12774945782	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 15:12:52.917623
d45bf577-96bc-4ab2-85b2-836ed193d0ed	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 15:31:15.873433
cbc6ff44-30c2-42f5-89e0-b067e2b9e8bf	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 15:31:17.969903
42b31dd1-8e62-4043-a525-999a9227b5c5	d536a1ea-4c05-486d-af09-8deb3f3b5baa	remove_member	project_user	35bf3e26-d7a6-4878-8c04-413514e88e88	{"removed_user_id": "d536a1ea-4c05-486d-af09-8deb3f3b5baa"}	null	2026-07-17 15:39:22.932352
22c4ab4d-6e67-4329-b9a4-601d3f052958	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 16:52:30.451098
e584f124-6763-4bf1-a416-8481e43d7971	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 17:08:30.943003
06eec0c9-2ade-4ea8-95f2-0cd98ccbb3f1	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 17:16:55.111137
be876919-e260-4826-8f5a-2697155e4f23	d536a1ea-4c05-486d-af09-8deb3f3b5baa	remove_member	project_user	35bf3e26-d7a6-4878-8c04-413514e88e88	{"removed_user_id": "a20e909b-171b-4689-8ff0-02cc72b23dbc"}	null	2026-07-17 17:17:01.525699
d1276805-339c-4b0b-900a-0adf3ca99774	d536a1ea-4c05-486d-af09-8deb3f3b5baa	remove_member	project_user	35bf3e26-d7a6-4878-8c04-413514e88e88	{"removed_user_id": "5ebf041c-893d-431c-b9f2-0b7b4cd4c579"}	null	2026-07-17 17:17:05.655315
5ea91416-27fb-46a8-b3f0-7cd3247dc2f2	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	35bf3e26-d7a6-4878-8c04-413514e88e88	null	{"user_email": "gisiela@gmail.com", "role": "reviewer"}	2026-07-17 17:26:02.322037
e3b35034-1cd1-4c94-8015-187c4d64ad82	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	35bf3e26-d7a6-4878-8c04-413514e88e88	null	{"user_email": "c.fearnley@ucl.ac.uk", "role": "reviewer"}	2026-07-17 17:26:19.862428
d999d05f-8992-43ae-aaee-9db372615499	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 17:26:29.902797
a6c2426e-78fa-4675-911c-7b786562f515	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 17:37:15.237602
6b5eae9e-5058-4c44-a845-50c3d0391ef2	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	35bf3e26-d7a6-4878-8c04-413514e88e88	{"title": "test project 1", "status": "planning"}	null	2026-07-17 17:57:01.385112
fb766096-8a44-4e70-8061-c568a851514f	d536a1ea-4c05-486d-af09-8deb3f3b5baa	delete	project	35bf3e26-d7a6-4878-8c04-413514e88e88	null	null	2026-07-17 17:57:24.666452
8747bfb1-f7d6-4953-a7e4-9ee36f6d4985	d536a1ea-4c05-486d-af09-8deb3f3b5baa	create	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	null	{"title": "Project 1", "description": "description", "type": "scientific", "lead_institution": "Ghent University", "countries": [], "languages": [], "review_mode": "collaborative", "work_group_ids": [], "country_ids": [73, 32], "language_ids": [2, 3], "members": []}	2026-07-17 17:58:19.193699
f10e2058-9ab2-4f28-a4f6-bee58121b968	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 17:58:21.522883
fab388ee-b79a-4424-b70c-209446abe7aa	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 17:58:22.584087
cc4d9cc2-12f8-49c3-a35f-e40b4b7906cf	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	null	{"user_email": "atriantafylidou@uowm.gr", "role": "reviewer"}	2026-07-17 17:58:27.823146
35322594-5f3f-4032-9409-90d6937069d7	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	null	{"user_email": "bjoe@zhaw.ch", "role": "reviewer"}	2026-07-17 17:58:30.938547
c4b5f3a8-66b3-48bc-a707-43c8ec56540d	d536a1ea-4c05-486d-af09-8deb3f3b5baa	remove_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"removed_user_id": "d536a1ea-4c05-486d-af09-8deb3f3b5baa"}	null	2026-07-17 17:58:41.902204
f64b839b-1a56-4e6b-a6c0-35f671b84689	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 17:58:59.238866
91ea6fba-159f-418a-9ab3-c1b987bf59bd	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 17:59:47.474221
2c949d8d-bf7e-4596-a763-2e8849af241f	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 17:59:53.904142
56c126d2-32a1-4cc1-9b23-e5cdebfdd313	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:04:39.013241
5d220009-8277-47c2-846e-23b0c7c17be4	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:08:29.690336
c710ccbe-b567-4433-bc5e-d5232ef5e59d	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:12:14.879841
696de3e7-7f73-4afd-8919-76055696e8a4	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:12:27.891867
3637a899-1764-4587-9b76-b27f530785a6	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:12:42.3098
72de651f-92ac-46ac-9599-85c393fec526	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:16:46.588194
455cffba-df00-4bf9-80b1-a932e728a2f7	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:18:35.750142
b717dd5c-7ba2-4d35-8cea-9745a23afec3	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:28:11.300158
7c162821-bebc-4df4-8018-9f5e60f982ae	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:28:17.729545
967751fd-823c-41a1-b45b-2b595a8dc8bd	d536a1ea-4c05-486d-af09-8deb3f3b5baa	remove_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"removed_user_id": "d536a1ea-4c05-486d-af09-8deb3f3b5baa"}	null	2026-07-17 18:28:21.561287
221366a7-8dd5-49b0-8999-28b726559e0c	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	null	{"user_email": "bjoe@zhaw.ch", "role": "reviewer"}	2026-07-17 18:28:23.311901
15f6f09c-1c8b-4065-9c7b-2e60e90802db	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 18:28:29.278642
8d0758f4-efaa-405b-9f47-588adc5572e7	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 19:41:19.942141
200f3076-327b-470e-8b8c-72e821112b80	d536a1ea-4c05-486d-af09-8deb3f3b5baa	remove_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"removed_user_id": "5ebf041c-893d-431c-b9f2-0b7b4cd4c579"}	null	2026-07-17 19:41:25.404416
8046b039-967f-4ec2-91cd-5af440ba3431	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	null	{"user_email": "dzhumalieva_a@auca.kg", "role": "reviewer"}	2026-07-17 19:41:27.561946
7304fac1-a0f8-438e-97fa-6c7f04f6141e	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 19:41:31.087004
0d97a9d6-6453-432f-b192-3b2eec36c9f6	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 19:41:31.960901
244d1d6a-0ece-4e0d-aee0-5cccf7b55564	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 19:41:54.846356
33b6e16a-1be9-453e-a7c6-4b84fb9a7378	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 19:41:37.29813
b21641bb-97b4-432a-bf9f-deb1f66699ff	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 19:41:46.509569
8dda9b91-ded5-4d34-af9a-3a5186acd896	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 20:11:40.173813
17c77acb-cb83-4544-ac1f-95dd7481632e	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 20:11:42.441855
236f21ca-f5a6-4baa-9827-4be7781194d2	d536a1ea-4c05-486d-af09-8deb3f3b5baa	remove_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"removed_user_id": "d536a1ea-4c05-486d-af09-8deb3f3b5baa"}	null	2026-07-17 20:11:48.250463
ec9ffbab-b485-48a2-ba1d-23adef0a2658	d536a1ea-4c05-486d-af09-8deb3f3b5baa	add_member	project_user	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	null	{"user_email": "aleksandar.ivanov@uklo.edu.mk", "role": "reviewer"}	2026-07-17 20:11:50.714188
18fa19e4-ac56-4ef3-b696-0b5ecc3d5f94	d536a1ea-4c05-486d-af09-8deb3f3b5baa	update	project	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	{"title": "Project 1", "status": "planning"}	null	2026-07-17 20:11:58.407992
\.


--
-- Data for Name: conflicts; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.conflicts (id, document_id, review1_id, review2_id, status, arbiter_id, final_decision, arbiter_justification, created_at, resolved_at) FROM stdin;
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.countries (id, name, code) FROM stdin;
1	Argentina	ARG
2	Bolivia	BOL
3	Brazil	BRA
4	Chile	CHL
5	Colombia	COL
6	Ecuador	ECU
7	Guyana	GUY
8	Paraguay	PRY
9	Peru	PER
10	Suriname	SUR
11	Uruguay	URY
12	Venezuela	VEN
13	Belize	BLZ
14	Costa Rica	CRI
15	Cuba	CUB
16	Dominica	DMA
17	Dominican Republic	DOM
18	El Salvador	SLV
19	Grenada	GRD
20	Guatemala	GTM
21	Haiti	HTI
22	Honduras	HND
23	Jamaica	JAM
24	Nicaragua	NIC
25	Panama	PAN
26	Puerto Rico	PRI
27	Bahamas	BHS
28	Barbados	BRB
29	Canada	CAN
30	Mexico	MEX
31	United States	USA
32	Albania	ALB
33	Andorra	AND
34	Austria	AUT
35	Belgium	BEL
36	Bosnia and Herzegovina	BIH
37	Bulgaria	BGR
38	Croatia	HRV
39	Cyprus	CYP
40	Czech Republic	CZE
41	Denmark	DNK
42	Estonia	EST
43	Finland	FIN
44	France	FRA
45	Georgia	GEO
46	Germany	DEU
47	Greece	GRC
48	Hungary	HUN
49	Iceland	ISL
50	Ireland	IRL
51	Italy	ITA
52	Latvia	LVA
53	Liechtenstein	LIE
54	Lithuania	LTU
55	Luxembourg	LUX
56	Malta	MLT
57	Monaco	MCO
58	Montenegro	MNE
59	Netherlands	NLD
60	Norway	NOR
61	Poland	POL
62	Portugal	PRT
63	Romania	ROU
64	Russia	RUS
65	Serbia	SRB
66	Slovakia	SVK
67	Slovenia	SVN
68	Spain	ESP
69	Sweden	SWE
70	Switzerland	CHE
71	Ukraine	UKR
72	United Kingdom	GBR
73	Afghanistan	AFG
74	Armenia	ARM
75	Azerbaijan	AZE
76	Bahrain	BHR
77	Bangladesh	BGD
78	Cambodia	KHM
79	China	CHN
80	India	IND
81	Indonesia	IDN
82	Iran	IRN
83	Iraq	IRQ
84	Israel	ISR
85	Japan	JPN
86	Jordan	JOR
87	Kazakhstan	KAZ
88	South Korea	KOR
89	Kuwait	KWT
90	Lebanon	LBN
91	Malaysia	MYS
92	Maldives	MDV
93	Mongolia	MNG
94	Nepal	NPL
95	Oman	OMN
96	Pakistan	PAK
97	Philippines	PHL
98	Qatar	QAT
99	Saudi Arabia	SAU
100	Singapore	SGP
101	Sri Lanka	LKA
102	Syria	SYR
103	Taiwan	TWN
104	Thailand	THA
105	Turkey	TUR
106	United Arab Emirates	ARE
107	Uzbekistan	UZB
108	Vietnam	VNM
109	Algeria	DZA
110	Angola	AGO
111	Benin	BEN
112	Botswana	BWA
113	Cameroon	CMR
114	Egypt	EGY
115	Ethiopia	ETH
116	Ghana	GHA
117	Kenya	KEN
118	Libya	LBY
119	Madagascar	MDG
120	Morocco	MAR
121	Mozambique	MOZ
122	Nigeria	NGA
123	Senegal	SEN
124	South Africa	ZAF
125	Tunisia	TUN
126	Zimbabwe	ZWE
127	Australia	AUS
128	New Zealand	NZL
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
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.languages (id, name, code) FROM stdin;
1	Arabic	ar
2	Bengali	bn
3	Bulgarian	bg
4	Catalan	ca
5	Chinese (Simplified)	zh-CN
6	Chinese (Traditional)	zh-TW
7	Croatian	hr
8	Czech	cs
9	Danish	da
10	Dutch	nl
11	English	en
12	Estonian	et
13	Finnish	fi
14	French	fr
15	German	de
16	Greek	el
17	Hebrew	he
18	Hindi	hi
19	Hungarian	hu
20	Indonesian	id
21	Italian	it
22	Japanese	ja
23	Korean	ko
24	Latvian	lv
25	Lithuanian	lt
26	Malay	ms
27	Norwegian	no
28	Persian	fa
29	Polish	pl
30	Portuguese	pt
31	Romanian	ro
32	Russian	ru
33	Slovak	sk
34	Slovenian	sl
35	Spanish	es
36	Swedish	sv
37	Thai	th
38	Turkish	tr
39	Ukrainian	uk
40	Vietnamese	vi
\.


--
-- Data for Name: project_countries; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.project_countries (project_id, country_id) FROM stdin;
4657fc34-a8bb-4ed9-a194-bd8c1714a45b	32
\.


--
-- Data for Name: project_languages; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.project_languages (project_id, language_id) FROM stdin;
4657fc34-a8bb-4ed9-a194-bd8c1714a45b	2
\.


--
-- Data for Name: project_users; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.project_users (id, project_id, user_id, role, invited_at, accepted) FROM stdin;
a131cd99-b764-42a3-980d-13178cee5b85	4657fc34-a8bb-4ed9-a194-bd8c1714a45b	32de7d22-f03a-44c6-ae1f-8824d5a50716	reviewer	2026-07-17 20:11:50.719035	t
\.


--
-- Data for Name: project_work_groups; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.project_work_groups (project_id, work_group_id, associated_at) FROM stdin;
4657fc34-a8bb-4ed9-a194-bd8c1714a45b	8a0eb1a1-6ab1-4c80-88be-7dc76a283c8c	2026-07-17 17:58:21.527299+00
4657fc34-a8bb-4ed9-a194-bd8c1714a45b	16df90b8-aa49-4974-8eb7-004c701c220d	2026-07-17 19:41:31.091101+00
4657fc34-a8bb-4ed9-a194-bd8c1714a45b	70578703-c8b9-46dc-a70e-c07c8848b029	2026-07-17 20:11:42.443204+00
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: sysrev_user
--

COPY public.projects (id, title, description, type, lead_institution, review_mode, status, created_by, created_at) FROM stdin;
4657fc34-a8bb-4ed9-a194-bd8c1714a45b	Project 1	description	scientific	Ghent University	collaborative	planning	d536a1ea-4c05-486d-af09-8deb3f3b5baa	2026-07-17 17:58:19.189335
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

COPY public.users (id, name, email, password_hash, active, preferred_language, created_at, country, institution, is_active, is_admin) FROM stdin;
40325ca8-0503-44bb-97e2-65b3de4b6546	Sunniva SANDBUKT	suns@itu.dk	\N	t	\N	2026-07-15 19:17:59.600542	Denmark	IT University of Copenhagen	t	f
1e8ec142-738a-48ce-b069-87e7445194fe	Giannis ADAMOS	adamos.giannis@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Greece	Aristotle University of Thessaloniki	t	f
8af673e6-edb8-4461-bd32-a99df4d84aa1	Neofytos ASPRIADIS	asprto@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Greece	Hellenic Parliament	t	f
83b95ab5-7017-4dd8-b217-caaa1913efb1	Douglas CUBIE	d.cubie@ucc.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	University College Cork	t	f
81f310dc-3513-4138-a6c3-eda24c09da83	Krishnendu GUHA	kguha@ucc.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	University College Cork	t	f
f8ab43d1-01a5-4fa7-8821-84e36bf758d5	Christian ESPOSITO	esposito@unisa.it	\N	t	\N	2026-07-15 19:17:59.600542	Italy	University of Salerno	t	f
3a6a81e4-2939-4d95-b9b5-adf9e29e538c	Valentina GRASSO	valentina.grasso@cnr.it	\N	t	\N	2026-07-15 19:17:59.600542	Italy	Consiglio Nazionale delle Ricerche	t	f
79063b2c-f72a-4a67-8980-d68bfbe25d10	Lasma SKESTERE	lasma.skestere@rsu.lv	\N	t	\N	2026-07-15 19:17:59.600542	Latvia	Riga Stradins University	t	f
a309413d-62a5-43d0-8b78-03e77a125af0	Renata MATKEVIČIENĖ	renata.matkeviciene@kf.vu.lt	\N	t	\N	2026-07-15 19:17:59.600542	Lithuania	Vilnius University	t	f
9df36a52-ffbe-46ad-bb3a-d3fbd4110204	Nina ROSCOVAN	ninaroscovan@yahoo.com	\N	t	\N	2026-07-15 19:17:59.600542	Moldova	Academy of Economic Studies of Moldova	t	f
716875db-6d40-4f4f-96cc-13b94103bf58	Srna Sudar	srna.sudar@ntpark.me	\N	t	\N	2026-07-15 19:17:59.600542	Montenegro	Naucno - Tehnoloski Park Crne Gore	t	f
fc42831e-e523-4286-b1f9-b526b9fe2935	Yijing WANG	y.wang@eshcc.eur.nl	\N	t	\N	2026-07-15 19:17:59.600542	Netherlands	Erasmus University Rotterdam	t	f
91d07dd5-27f6-46d9-b266-4b4c0aa7dddf	Toshiyuki WATANABE	twd1977jp@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Netherlands	Weather Plus Communication Design	t	f
32de7d22-f03a-44c6-ae1f-8824d5a50716	Aleksandar IVANOV	aleksandar.ivanov@uklo.edu.mk	\N	t	\N	2026-07-15 19:17:59.600542	North Macedonia	University St Kliment Ohridski Bitola	t	f
3deb6858-3e1a-488c-8771-eb5e3ed37a38	Natasha SARAFOVA	natasa.sarafova@ugd.edu.mk	\N	t	\N	2026-07-15 19:17:59.600542	North Macedonia	Faculty of Philology, Goce Delcev University, Stip, North Macedonia	t	f
43f88929-25dc-41fd-94ed-194b004314dd	Oyvind IHLEN	oyvind.ihlen@media.uio.no	\N	t	\N	2026-07-15 19:17:59.600542	Norway	University of Oslo	t	f
cff7d746-2482-4313-883a-2b6222659683	Åshild KOLÅS	ashild@prio.org	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Institutt For Fredsforskning	t	f
6b5b1952-16d6-4fd7-95ff-ec21646ce24e	Dariusz WIECEK	d.wiecek@il-pib.pl	\N	t	\N	2026-07-15 19:17:59.600542	Poland	National Institute of Telecommunications	t	f
5e49fd4f-4827-4d99-a8c4-1a6e2979e54f	Malgorzata WINIARSKA-BRODOWSKA	malgorzata.brodowska@uj.edu.pl	\N	t	\N	2026-07-15 19:17:59.600542	Poland	Jagiellonian University	t	f
5b1e8a6c-8006-4d44-bbc6-62d41f68d1fa	Mariana CASAL-RIBEIRO	mariana.ribeiro2@edu.ulisboa.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Instituto de Geografia e Ordenamento do Território da Universidade de Lisboa	t	f
803fa92b-979c-4bab-bda5-a8c642800c0c	Gisela GONÇALVES	gisela@ubi.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade Da Beira Interior	t	f
8740934e-16e6-46ed-8176-d2692214ee30	Camelia CMECIU	camelia.cmeciu@fjsc.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	University of Bucharest	t	f
3d39ed21-d1bd-4542-8817-c5dbd41466a8	Corina DABA-BUZOIANU	corina.buzoianu@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	t	f
6ae345ed-ce06-4eb7-b88b-86b72a6b3097	Vladimir CVETKOVIĆ	vladimirkpa@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Univeristet U Beogradu,fakultet Bezbednosti	t	f
fe149854-182e-482a-9603-5cb2820156a0	Snežana ŽIVKOVIĆ	snezana.zivkovic@znrfak.ni.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Faculty of Occupational Safety, University of Nis	t	f
9cfba57c-2438-40d0-947f-de48e9c00d2a	Veronika MICHVOCÍKOVÁ	veronika.michvocikova@ucm.sk	\N	t	\N	2026-07-15 19:17:59.600542	Slovakia	University of Ss. Cyril and Methodius in Trnava	t	f
54692b52-4742-4c65-949c-010935eec26c	Denis TRČEK	denis.trcek@guest.arnes.si	\N	t	\N	2026-07-15 19:17:59.600542	Slovenia	University of Ljubljana	t	f
d8fbd7e5-609f-477b-880e-883ae38f0516	Jose Manuel NOGUERA VIVO	jmnoguera@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad Católica San Antonio de Murcia	t	f
294e5037-490b-46b7-ac30-53d21c24eb1e	Guadalupe ORTIZ	guadalupe.ortiz@ua.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad de Alicante	t	f
1416724f-825f-41f1-9da7-b35b902e641e	Bengt JOHANSSON	bengt.johansson@jmg.gu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	University of Gothenburg	t	f
7ab3fe95-67b7-4777-bf53-334b4bd41d5d	Henrik OLINDER	henrik.olinder@msb.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Swedish Civil Contingencies Agency (MSB) - Henrik Olinder	t	f
5ebf041c-893d-431c-b9f2-0b7b4cd4c579	Albena BJÖRCK	bjoe@zhaw.ch	\N	t	\N	2026-07-15 19:17:59.600542	Switzerland	Zurich University of Applied Sciences	t	f
1aaba79f-c26b-4c00-889e-2947663f234c	Daniel VOGLER	daniel.vogler@foeg.uzh.ch	\N	t	\N	2026-07-15 19:17:59.600542	Switzerland	University of Zurich	t	f
b7c9fc07-a247-4c86-a517-10113882c9b1	Altug AKIN	altugakin@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Izmir Ekonomi Universitesi	t	f
8cb1df1e-09d7-4c9f-b04c-a9f9a38cfee1	Ebru KAYAALP JURICH	ebru.kayaalp@yeditepe.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Yeditepe University Vakif	t	f
12c923ce-6874-4b31-8c98-735d5d3e7918	Dariya Orlova	dasha.orlova@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Ukraine	National University Of Kyiv-mohyla Academy	t	f
5a2601f9-1037-488f-adfa-f2062be4d0a6	Daria Taradai	daria.taradai@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Ukraine	National University Of Kyiv-mohyla Academy	t	f
503fe4af-db72-44fa-9fba-7e90009e7733	Galena PISONI	g.pisoni@yorksj.ac.uk	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	York St John University	t	f
2d4a6b7c-9f11-4c91-b56f-bb2645e45deb	Florian Meissner	florian.meissner@h-da.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Hochschule Darmstadt (university Of Applied Sciences H-da)	t	f
bb741d67-1540-4bbf-bb9e-3375eefd7e74	Angelo Basteris	angelo.basteris@cost.eu	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	COST Association	t	f
08859ec9-d769-4c76-a801-4867ec6ec428	Ekaterina Zemlyankina	ekaterina.zemlyankina@cost.eu	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	COST Association	t	f
6698ef9a-1566-4350-896d-37b40e244bb0	Monica BIRA	monica.bira@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	t	f
ee37c43b-d3e6-4d74-ae02-2870560ab7b4	Fuzel Ahamed SHAIK	fuzel.shaik@oulu.fi	\N	t	\N	2026-07-15 19:17:59.600542	Finland	University of Oulu	t	f
d8e75128-dab0-45f9-9018-fc91bfa0cb27	Bianca PERSICI TONIOLO	bianca.toniolo@ubi.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade Da Beira Interior	t	f
fe4ecb11-91ef-46a9-ac7b-71578c2c7eec	Roberta RĂDUCU	roberta.raducu@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	t	f
9d2b715d-32c4-4e37-baee-b442dd99a9dd	Pavel RODIN	pr.rodin@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	University of Gothenburg	t	f
52f5b0e0-ad6d-4ce4-9dc1-8112addbfb12	Lauren TRACZYKOWSKI	l.traczykowski@aston.ac.uk	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	Aston University	t	f
a9aa2bd8-a650-4c7f-bfbf-75f2b0996659	Amalia TRIANTAFILLIDOU	atriantafylidou@uowm.gr	\N	t	\N	2026-07-15 19:17:59.600542	Greece	University of Western Macedonia	t	f
34da3bfe-a60c-4492-ba08-fa4e0e054c08	Catalin DINU	catalin-adrian.dinu@fjsc.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	University of Bucharest	t	f
cb54cb6d-8fe7-4789-bcac-59a2bed658c3	Francis ALPERS	francis.alpers@tu-ilmenau.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Technische Universitaet Ilmenau	t	f
a0e8b93a-8a04-403f-ab16-a145a3c819cd	Jurgen MECAJ	jurgenmecaj96@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	Mediterranean University of Albania	t	f
e73a6695-01b8-4196-affd-87ef356db2e8	Michael WALLENGREN LYNCH	michael.wallengren-lynch@mau.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Malmö Universitet	t	f
46e3d654-c6b0-432d-908e-12c302497160	Mourad OUSSALAH	mourad.oussalah@oulu.fi	\N	t	\N	2026-07-15 19:17:59.600542	Finland	University of Oulu	t	f
07f0f5d5-4461-4281-ad89-1e120b47d4a0	Mónica RODRIGUES	masanrodrigues@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade de Coimbra	t	f
5f169236-d61c-4526-aabd-6adcf21298a0	Pao-lin BEUSELINCK	paolin.beuselinck@nccn.fgov.be	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	National Crisis Center	t	f
ca26c2f5-6e89-4f96-834f-5a58fe081b65	Rui TEIXEIRA	rui.teixeira@tcd.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	The Provost, Fellows, Foundation Scholars, and the other members of Board, of the College of the Holy and Undivided Trinity of Queen Elizabeth near Dublin	t	f
02914380-dffd-4dfd-804b-5006d8a7b3c5	Sofia JOHANSSON	sofia.johansson@jmg.gu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	University of Gothenburg	t	f
a68d2993-5368-45c4-b168-da532ca08643	Tatjana GOLUBOVIC	tatjana.golubovic@znrfak.ni.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Faculty of Occupational Safety, University of Nis	t	f
112d3493-b6ab-4d0a-9b42-b47e07c6250a	Vanja ROKVIC	vanjarokvic@fb.bg.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Univerzitet U Beogradu	t	f
daa08613-6cc4-4934-adbe-70fb6e85dbe8	Dejan VASOVIĆ	dejan.vasovic@znrfak.ni.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Faculty of Occupational Safety, University of Nis	t	f
81ae3066-d4c6-4fdb-b6ac-8e2b6236b736	Karen DA COSTA	karen.da.costa@gu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	University of Gothenburg	t	f
4367b9cd-2b9a-4aff-8fcb-2fa7a29e65b4	Avelina HEILMAIER	avelina.heilmaier@lfbk.rlp.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Landesamt für Brand- und Katastrophenschutz Rheinland-Pfalz	t	f
12e7dcf5-7b0e-4f6a-ad0e-190f617c859e	Alexander FEKETE	alexander.fekete@th-koeln.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Technische Hochschule Koln	t	f
4377639e-1c7f-4574-82a2-6f8ce076261d	Samuel TOMCZYK	samuel.tomczyk@uni-greifswald.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Universitaet Greifswald	t	f
cf91f3af-57f4-49a7-b1b6-09c493a674fb	Vesela IVANOVA	veivanova@abv.bg	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	South-west University Neofit Rilski	t	f
8ee9f996-89c4-428f-bf4f-3cd6df536222	Ayça DAĞLI	aycadagli10@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Istinye University	t	f
a20e909b-171b-4689-8ff0-02cc72b23dbc	Aizhana DZHUMALIEVA	dzhumalieva_a@auca.kg	\N	t	\N	2026-07-15 19:17:59.600542	Kyrgyzstan	American University of Central Asia (AUCA)	t	f
1c60f815-cac4-45f8-8bce-671c7d521aca	Steven VENETTE	danger.venette@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	United States	The University of Southern Mississippi	t	f
c2561bf4-e126-47eb-a144-71447879ad79	Hatice OZ PEKTAS	haticeoz@haticeoz.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Istinye University	t	f
e8139189-9424-4b62-a488-bb48cda96c2a	Joel IVERSON	joel.iverson@umontana.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	University of Montana	t	f
d13635d7-79db-4640-bc2c-441dd6da9859	Audra DIERS-LAWSON	audra.diers-lawson@kristiania.no	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Hoyskolen Kristiania - Ernst G. Mortensens Stiftelse	t	f
ef9b9940-ced6-47d0-b122-3cb98d174a07	Hamilton BEAN	hamilton.bean@ucdenver.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	University of Colorado Denver	t	f
929c2731-5e5e-449b-a96c-cefcb0908fb6	METEHAN ATAY	metehanatay1@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Hasan Kalyoncu University	t	f
4a178b83-8e4f-4daf-933c-1cb895eb0804	VINCENZA CONTE	enza.conte10@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Italy	University of Salerno	t	f
e8e9f0e6-0ea3-4b6e-9b67-4cb431eb10f7	Ewa GLOWIENKA	eglo@agh.edu.pl	\N	t	\N	2026-07-15 19:17:59.600542	Poland	AGH University of Krakow	t	f
d6aa7baa-41a8-416b-b1a1-f1ce0d26b707	Marie ARONSSON-STORRIER	maronsson-storrier@ucc.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	University College Cork	t	f
cb42b2fa-daa8-430e-b47f-6be9575501d2	Jaroslav DVORAK	jaroslav.dvorak@ku.lt	\N	t	\N	2026-07-15 19:17:59.600542	Lithuania	Klaipeda University	t	f
cbb4ff94-b4a0-4c39-a60b-c2fa55248ced	Michiel SCHEERLINCK	michiel.scheerlinck@nccn.fgov.be	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	Nationaal Crisiscentrum	t	f
0149a56a-9632-474b-b09e-f3564b2db028	Evelien BURGERS	evelien.burgers@ugent.be	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	Ghent University	t	f
99486640-9102-452d-96d8-43595ef63c59	Juliana ALCANTARA	alc.juli@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Netherlands	Erasmus University Rotterdam	t	f
8c524bad-b62d-4714-8bf6-7a1e9e3bec6a	Tănase TASENȚE	tanase.tasente@365.univ-ovidius.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Universitatea Ovidius Din Constanta	t	f
73b6fc2b-25af-4444-9f67-6b1de9c790be	Fatih CICEK	cicekfatihh@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Manisa Celal Bayar University	t	f
234a5fd3-1e52-4816-9c4e-67ee34af38a1	Gisiela KLEIN	gisiela@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade de Coimbra	t	f
d661c376-1a5f-4801-9ecb-2561bcb614c1	İhsan Tarık ÇELIK	ihsantarikcelik@eskisehir.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Eskisehir Technical University	t	f
5a00af31-6d81-48a2-a3ec-c2cf42b18d26	Miroslav PLUNDRICH	plundrim@ff.zcu.cz	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	University of West Bohemia	t	f
b409fd62-949c-471c-89f0-11cbd6c54865	Bodo ERHARDT	bodo.erhardt@dwd.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Deutscher Wetterdienst	t	f
044cb460-641f-425d-8832-2acb0f3525bd	Lazar PENDOV	lpendov@uni-plovdiv.bg	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	Plovdiv University "Paisii Hilendarski"	t	f
1ab7ae9a-29c8-458d-bf23-807630827f2e	Elifnur TERZIOĞLU YURTSAL	elifnur.terzioglu@mku.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Hatay Mustafa Kemal University	t	f
3d43f941-105f-468d-9eb9-032fc1606720	Alexandra CIOTIR	alexandra.ciotir@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	t	f
742893f5-91c4-4c86-ae9a-8e178b4ad6e7	Ömer Faruk KARAKÖSE	omerfaruk.karakose@erdogan.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Recep Tayyip Erdogan University	t	f
06ab1219-9664-49fc-92c6-bb839b8611de	Sakir ESITTI	sakir.esitti@comu.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Çanakkale Onsekiz Mart University	t	f
2d67d927-b688-447a-944d-592aff5100e8	Roy JACOBSEN	royaulie.jacobsen@kristiania.no	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Hoyskolen Kristiania - Ernst G. Mortensens Stiftelse	t	f
cd9c47b6-eb10-4812-9cb9-7ca16edae55c	A. Elisabeth HASSELSTRÖM	elisabeth.hasselstrom@kristiania.no	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Hoyskolen Kristiania - Ernst G. Mortensens Stiftelse	t	f
0e3d08ae-92cc-474d-9c4f-83edb6ba6c66	Helene Liisi KEIS	helene.liisi.keis@ut.ee	\N	t	\N	2026-07-15 19:17:59.600542	Estonia	University of Tartu	t	f
37edcf41-b9fa-4178-876e-8f93c5872148	Kelley DE POLT	kdepolt@bgc-jena.mpg.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Max Planck Institute for Biogeochemistry	t	f
e93eac36-42ff-4f26-a02d-1f41f930affc	Péter PÁNTYA	pantya.peter@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Hungary	University of Publis Service	t	f
2eb3d7ee-1b19-4801-b8d3-b016bd68592f	Panagiotis PREVENTIS	ppreventis1@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Greece	University of Western Macedonia	t	f
2a143c5c-02e4-45c1-9de3-25e9d959e255	Ling YANG	ly3n24@soton.ac.uk	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	University of Southampton	t	f
3507b72e-d374-42f3-918d-7e242a6f4d9d	Ezgi ATALAY	ezgiatalay@ibu.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	BOLU ABANT IZZET BAYSAL UNIVERSITY	t	f
5dc88f64-6e17-40d1-84e1-f5776a12783c	Gamil GAMAL	gamil.gamal@cu.edu.eg	\N	t	\N	2026-07-15 19:17:59.600542	Egypt	Cairo University	t	f
daceffb2-16a3-4bab-ad9d-eb98d600f759	Carina FEARNLEY	c.fearnley@ucl.ac.uk	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	University College London	t	f
bd785fa5-b689-4880-a71c-b4cd8cc71212	Gisele BORGES	giseborges@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	France	Laboratory of Information and Communication Sciences	t	f
f2ceb828-fea9-46e5-9bb3-6c0871ab8823	Erkan SAKA	sakaerka@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Istanbul Bilgi University	t	f
eee19910-73e0-4328-8a65-d5177f4cd1e9	Klorenta PASHAJ	klorenta.pashaj@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	National Authority for Cyber Security	t	f
d93b2475-4766-48ba-82c9-9f7ba8f9fb50	Maik ELSTER	maik.elster@swr.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Südwestrundfunk	t	f
f20820f6-ec3d-4be9-834b-ba68b1e8526d	Marlis PRINZING	m.prinzing@macromedia.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Macromedia University of Applied Sciences	t	f
dac3a347-18e4-494d-90da-1db27fff2837	Michael KLAFFT	michael.klafft@jade-hs.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Jade Hochschule Wilhelmshaven/oldenburg/elsfleth	t	f
693ede3b-8b3f-40aa-9922-b22955e8d0bb	Patricia M. SCHUETTE	patricia.schuette@hspv.nrw.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	University of Applied Sciences for Police and Public Administration in North Rhine-Westphalia	t	f
4786a44a-03f8-420e-910d-ab48c8471881	Ramadan ÇIPURI	rcipuri16@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	University of Tirana	t	f
40b91973-ceea-46b2-9721-49c44839ebd3	Renate RENNER	renate.renner@unileoben.ac.at	\N	t	\N	2026-07-15 19:17:59.600542	Austria	Montanuniversitaet Leoben	t	f
02affa09-6d87-4398-91f9-64e1ead5c73f	Rūta KUPETYTĖ	ruta.kupetyte@kf.vu.lt	\N	t	\N	2026-07-15 19:17:59.600542	Lithuania	Vilnius University	t	f
741637a5-141b-44b6-95c6-38c279f492e9	Michele ROTH-DUEHRKOOP	michele.roth-duehrkoop@bbk.bund.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Federal Office of Civil Protection and Disaster Assistance	t	f
43e5f4d1-08cf-46d9-99ee-dd9e876b5286	Antonio ALEDO	antonio.aledo@ua.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad de Alicante	t	f
81bf4bf4-0f66-4846-a519-7cb3f14d4aba	Florian STALLKAMP	florian.stallkamp@lfbk.rlp.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Landesamt für Brand- und Katastrophenschutz Rheinland-Pfalz	t	f
1045cc40-6ff0-47b1-b7b5-bc2f5b1466c3	Elise RUETER	elise.rueter@bbk.bund.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Federal Office of Civil Protection and Disaster Assistance	t	f
5fb3173c-0e93-43f1-a26a-dd12f6fc5c17	Jose Carlos LOSADA	jclosada@hotmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Spain	University of Murcia	t	f
eaac3c9e-9860-4293-ba05-0a66c3ab3c9c	David BOGATAJ	david.bogataj@almamater.si	\N	t	\N	2026-07-15 19:17:59.600542	Slovenia	Univerza Alma Mater Europaea	t	f
3d987bb5-6822-4d91-9df7-4894fb5f7e6e	Raimon ALLMUCA	rai_mono@hotmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	Drejtoria e Pergjithshme e Objekteve Publike, Bashkia Tirane	t	f
781f75a4-5c7b-476b-b8b0-cf5f18e1d4d1	Benjamin DUNCAN	info@alert-not-alarmed.com	\N	t	\N	2026-07-15 19:17:59.600542	United Kingdom	Alert Not Alarmed Enterprises Ltd	t	f
f1f6e4a1-11e8-467a-b3e5-bd507c9d4ed6	Matthew SEEGER	matthew.seeger@wayne.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	Wayne State University	t	f
4bbb3943-3177-4c96-9949-41f9ee51e811	Juan-Andres RINCON-GONZALEZ	jrincon@up.edu.mx	\N	t	\N	2026-07-15 19:17:59.600542	Mexico	Centros Culturales de Mexico A.C. - Universidad Panamericana	t	f
b663d43a-e384-4e6e-ab18-0415ecafc4bb	Deanna SELLNOW	dsellno@clemson.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	Clemson University	t	f
4f619497-c561-4ffb-b84d-74b8e4b0c5c2	Ngoc-Son LE	ngocsonle@greatway.vn	\N	t	\N	2026-07-15 19:17:59.600542	Vietnam	Mekong University	t	f
234df429-085d-49b6-ae9b-179a8dcad305	Mikael ASHORN	mikael.ashorn@umu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Umea Universitet	t	f
7f54516f-81f4-435a-a276-dab779389d8c	Timothy SELLNOW	tsellno@clemson.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	Clemson University	t	f
27792ac2-804c-466f-937b-3933b8d1e382	Arbresha MEHA	arbresha.meha@ushaf.net	\N	t	\N	2026-07-15 19:17:59.600542	Kosovo*	University of Applied Sciences in Ferizaj	t	f
eccd9d6a-5911-47f3-96d8-3321e59219ee	Esra BOZKANAT	esra.bozkanat@klu.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Kirklareli University	t	f
fd2ef43c-0933-4da3-9fa7-0b37b6dde6e9	FARRUKH SHAHZAD	farrukh1999@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Pakistan	Bahria University	t	f
1f441b58-3e14-4094-95e4-9b771688443a	Jesus Antonio ARROYAVE CABRERA	jarroyav@uninorte.edu.co	\N	t	\N	2026-07-15 19:17:59.600542	Colombia	Universidad del Norte	t	f
b7769976-7ef3-41ff-8f9a-1977b1ee32bc	Angella NAPAKOL	angella.napakol@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Uganda	Uganda Christian University	t	f
fe57af03-a9d1-46fa-a065-0ba70c4b822c	Pierre GEHL	p.gehl@brgm.fr	\N	t	\N	2026-07-15 19:17:59.600542	France	Bureau De Recherches Geologiques Et Minieres	t	f
192f42ba-ca40-40d2-974a-5d8136237945	Julia GERSTER	gerster-damerow.julia.e1@tohoku.ac.jp	\N	t	\N	2026-07-15 19:17:59.600542	Japan	National University Corporation Tohoku University	t	f
2f66f9de-4eee-4384-9e51-2b037317a2f0	Sebastien BORET	boret.sebastien.a4@tohoku.ac.jp	\N	t	\N	2026-07-15 19:17:59.600542	Japan	Tohoku University	t	f
2ef3b465-92b0-4447-bdce-9982e1ff5b8a	Jaroslav VALUCH	j.valuch@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	Ministry Of The Interior Of The Czech Republic	t	f
c820b443-6eac-4c0d-8845-3b34ed1f9f28	Blas SUBIELA	blas.subiela@urjc.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad Rey Juan Carlos	t	f
5c4c2753-2eb2-40b5-94e8-1a5822fc99b7	Salih APAYDIN	salih.apaydin@istinye.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Istinye University	t	f
047b9858-bfdf-4bb0-a9dc-ed7480661390	HATİCE ÇEŞME	h.cesme@atauni.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Ataturk University	t	f
85ee96e8-cb62-4323-976b-380157e22b69	Oguz Han SIMSEK	oguzhansimsek@sakarya.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Sakarya University	t	f
e870e8e1-8a63-42f3-895c-956422c9dfc9	Beatriz CORREYERO RUIZ	bcorreyero@ucam.edu	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad Católica de Murcia (UCAM)	t	f
73b47fc1-66c0-44ef-a7ef-aad8382da7c2	Dinah Kristin RODE	dinah-kristin.rode@dwd.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Deutscher Wetterdienst	t	f
d0ff126f-0531-415e-8c8f-ea2a21d857ae	Murat SEYFI	seyfi.murat@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Tokat Gaziosmanpasa Universitesi	t	f
86ba9b8e-a89c-4975-85a4-a1d39f652406	Lars RADEMACHER	lars.rademacher@h-da.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Hochschule Darmstadt (university Of Applied Sciences H-da)	t	f
ce52cd07-feb7-4cac-b199-9d0a5412209c	Anni CARLSSON	anni.carlsson@fhs.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Swedish Defence University	t	f
ba31be22-1bcf-4c4d-a99e-84297b46e746	Diogo Miguel PINTO	dspinto@letras.up.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade do Porto	t	f
a14255db-de70-4392-a078-06f49e4ae25b	Muhammad Auwal AHMAD	auwal@sakarya.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Sakarya University	t	f
a402ad83-076d-4b85-9046-db9d4b54dde0	Ylvije KRAJA	ylvije.kraja@unishk.edu.al	\N	t	\N	2026-07-15 19:17:59.600542	Albania	University of Shkoder "Luigj Gurakuqi"	t	f
91f15544-f2c9-40b7-9a77-6bb7c2131736	Salih BALCI	slhbalci@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Tokat Gaziosmanpasa Universitesi	t	f
be4f0f15-1a26-40d3-a6b4-83068732c145	Zafer KIYAN	zkiyan@media.ankara.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Ankara Universitesi	t	f
d6174363-f64c-4023-b2f2-f38a3161718c	HELENA MARTÍNEZ	helena1260@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Spain	University of Murcia	t	f
eb68a954-6dbf-4c03-9762-1770eefb6e6b	elizabeth REDDY	reddy@mines.edu	\N	t	\N	2026-07-15 19:17:59.600542	United States	Colorado School Of Mines	t	f
b617f0dc-5771-4d0c-9bcf-7e0ecdf45a13	Cari GUITTARD	cguittard@smcgov.org	\N	t	\N	2026-07-15 19:17:59.600542	United States	San Mateo County Emergency Management	t	f
d3d6f700-c3fc-438c-b837-dfeaf721d2ce	Fatih ERTAM	fatih.ertam@firat.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Firat University	t	f
9bb8fe4a-93a9-4572-ba5b-b53f15839ec6	Lacin Idil OZTIG	lacinidiltr@yahoo.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Yildiz Technical University	t	f
b647e462-2308-4dfb-afb5-cb1fa8349e53	Dilek NAM	dnam@sakarya.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Sakarya University	t	f
b123d708-6d8f-46d0-b672-ac226eaf72e3	Lydia CUMISKEY	lcumiskey@ucc.ie	\N	t	\N	2026-07-15 19:17:59.600542	Ireland	MaREI, University College Cork - MaREI, Environment Research Institute	t	f
24844912-86b7-496a-a13f-186c02a2cf2e	Stine BERGERSEN	stiber@prio.org	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Peace Research Institute Oslo (PRIO)	t	f
d5d801d1-2286-4b98-a9dc-ebb7d5d708cf	Elisa LAHCENE	e.lahcene@brgm.fr	\N	t	\N	2026-07-15 19:17:59.600542	France	BRGM - French Geological Survey	t	f
13dbcdaf-b53f-47b1-9330-e37f72025c11	Ali Alpcan OFLUOĞLU	alpcanofluoglu@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Karadeniz Teknik Universitesi	t	f
c74ba631-e77c-4ce6-b424-020fc08b3f51	Eralda GJIKA (DHAMO)	eraldagjika@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Albania	Universiteti Metropolitan Tirana	t	f
d129202e-9fef-4c7e-87b5-56c3054b997d	Rezarta SHKURTI (PERRI)	rezartaperri@feut.edu.al	\N	t	\N	2026-07-15 19:17:59.600542	Albania	University of Tirana	t	f
bb1402a4-e034-4dec-92e2-4f33bce4ecf9	An-Sofie CLAEYS	ansofie.claeys@ugent.be	\N	t	\N	2026-07-15 19:17:59.600542	Belgium	Ghent University	t	f
9d103e53-67a6-4140-959e-2e9fc0554a96	Nerma HALILOVIĆ-KIBRIĆ	nhalilovic@fkn.unsa.ba	\N	t	\N	2026-07-15 19:17:59.600542	Bosnia & Herzegovina	University of Sarajevo - Faculty of Criminal Justice and Security Studies	t	f
1108d537-ab14-4052-876b-6bb58d6d95b6	Ivan GANCHEV	igantchev@hotmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	Plovdivski Universitet Paisiy Hilendarski	t	f
e9328a28-8eda-49a3-8d64-fd8afacd535c	Georgi TSOCHEV	gtsochev@tu-sofia.bg	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	Technical University Of Sofia	t	f
52dfff01-7588-4b25-bfcb-322e1fecdedc	Hrvoje JAKOPOVIĆ	hrvoje.jakopovic@fpzg.hr	\N	t	\N	2026-07-15 19:17:59.600542	Croatia	University of Zagreb, Faculty of Political Science	t	f
c76d5b42-2fbd-44b4-bc10-f6844e35c411	Lambros LAMBRINOS	lambros.lambrinos@cut.ac.cy	\N	t	\N	2026-07-15 19:17:59.600542	Cyprus	Cyprus University of Technology	t	f
936f54bb-02e3-4982-bbb2-e4cec7f46ebe	Premysl ROSULEK	rosulek@ff.zcu.cz	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	University of West Bohemia	t	f
211cfcf9-5089-4c69-86e1-b2dd7d6e9cb1	Jan SVETLIK	jan.svetlik@mendelu.cz	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	Mendel university in Brno - Mendel University in Brno	t	f
821f0c3f-6f95-47d6-9e30-5816ec19b002	Sten TORPAN	sten.torpan@ut.ee	\N	t	\N	2026-07-15 19:17:59.600542	Estonia	University of Tartu	t	f
26eacb0d-5b79-436c-9279-5ad0ccd4e10d	Heini RUOHONEN	heini.ruohonen@abo.fi	\N	t	\N	2026-07-15 19:17:59.600542	Finland	Abo Akademi University	t	f
f718ff07-cc36-4d66-8614-b44cefe54415	Minttu TIKKA	minttu.mt.tikka@helsinki.fi	\N	t	\N	2026-07-15 19:17:59.600542	Finland	Finnish Institute for Health and Welfare	t	f
99af1276-c6fb-4d00-a51b-361cbf7fdbdf	Romain Michel Louis-Marie HUET	rhhuet@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	France	Université Rennes 2	t	f
04dc221f-d68f-4c84-bf56-2748b2e7d816	Sylvia BACH	sbach@uni-wuppertal.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Bergische Universitaet  Wuppertal	t	f
6dfe26d9-7b15-4cb6-85b8-fd5be33c4057	Andreas SCHWARZ	andreas.schwarz@tu-ilmenau.de	\N	t	\N	2026-07-15 19:17:59.600542	Germany	Technische Universitaet Ilmenau	t	f
82150693-5c7d-4723-9235-8149f28f3271	Manuel PARDO RIOS	mpardo@ucam.edu	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad Católica San Antonio de Murcia	t	f
689d9c3a-2383-4cf2-a77a-a956e24eea98	Håkon STRAUME	haakon.straume@everbridge.com	\N	t	\N	2026-07-15 19:17:59.600542	Norway	Everbridge Norway As	t	f
d536a1ea-4c05-486d-af09-8deb3f3b5baa	admin	admin@sysrev.com	$2b$12$LkeItroHLRXgdbpi5oo/9urpAYW/JWUp/VVcclhTgkeyagPFlFTyq	t	pt-BR	2026-07-14 22:42:32.152984	\N	\N	t	t
1c524749-3a38-4487-bdbe-847b0cba31e6	Junwen GUO	junwen.guo@umu.se	\N	t	\N	2026-07-15 19:17:59.600542	Sweden	Umea University	t	f
dab1d081-68b7-45c1-b016-99d7aa51fb03	Anna KIEBER-WALSER	anna.walser@regierung.li	\N	t	\N	2026-07-15 19:17:59.600542	Liechtenstein	Government of the Principality of Liechtenstein	t	f
ad66a489-fd0f-472e-9f55-ae40d3d45dc9	Muammer ALBAYRAK	m.albayrak@ktu.edu.tr	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Karadeniz Teknik Universitesi	t	f
0535c69b-e2d2-4efd-898e-e5dfd733781f	Tutana KVARATSKHELIA	t.kvaratskhelia@weg.ge	\N	t	\N	2026-07-15 19:17:59.600542	Georgia	World Experience for Georgia	t	f
5e88dcb9-4616-46a0-a959-97a08efa8025	Lucia PETROVIČOVÁ	lucia.petrovicova.lp@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Czechia	Faculty of Forestry and Wood Technology,  Mendel University, Brno	t	f
d275e033-b513-436f-af30-d7080e067ed5	Altin IDRIZI	altin.idrizi@uniel.edu.al	\N	t	\N	2026-07-15 19:17:59.600542	Albania	Universiteti Aleksander Xhuvani	t	f
92f70ef4-4145-4574-844d-55b2b4b3cd31	Anisia BOANTA	anisia.boanta@mai.gov.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Department for Emergency Situations	t	f
a4b0d222-6899-478f-8561-7d9f5316912e	Elena IDRIZI	helena-12.12@hotmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Bulgaria	University Of National And World Economy	t	f
4950c028-b0e8-4440-8d27-1de890045ad3	Tamara RAĐENOVIĆ	tamara.radjenovic@znrfak.ni.ac.rs	\N	t	\N	2026-07-15 19:17:59.600542	Serbia	Faculty of Occupational Safety, University of Nis	t	f
7d08051f-356b-4600-a439-1dfc644a1558	franco CASULA	francocasula@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Italy	Corpo Forestale e di Vigilanza Ambientale Regione Sardegna (Italy)	t	f
2a090287-aba8-4722-841e-2e0ad67e1525	Mar GRANDIO	mgrandio@um.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	University of Murcia	t	f
d66d93ec-6461-468d-9333-0f471d5358cf	Diana CEUSAN	diana.ceusan@comunicare.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Scoala Nationala De Studii Politice Si Administrative	t	f
186dca2c-3a3e-4b88-aa3e-2e8bfa56b80b	Lucian BARBACARU	lucian.barbacaru@student.uaic.ro	\N	t	\N	2026-07-15 19:17:59.600542	Romania	Universitatea Alexandru Ioan Cuza Din Iasi	t	f
9f285184-fb26-4976-aeaa-daa7fec222f0	Elif KUTUKOGLU	elifkutukoglu@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Gümüşhane University, Faculty of Communication	t	f
ac2b8471-1982-4e62-aec8-288ca46e1af9	Rafael CASTRO-DELGADO	castrorafael@uniovi.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	Universidad de Oviedo	t	f
51615209-0e00-4c97-823b-0a64e21c230a	ROCIO ZAMORA	rzamoramedina@um.es	\N	t	\N	2026-07-15 19:17:59.600542	Spain	University of Murcia	t	f
ec304188-bd07-41f0-865a-5d55c1478a7a	Shahira S FAHMY	shahira.fahmy@fulbrightmail.org	\N	t	\N	2026-07-15 19:17:59.600542	Egypt	The American University In Cairo	t	f
3c7e54c9-7a79-4832-990e-6f1d858fc35b	Vera ANTUNES	vantunes@ubi.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade Da Beira Interior	t	f
38125c04-dc52-4d41-b16d-ce77b7a0a299	Teresa CASTELEIRO	teresamc@ubi.pt	\N	t	\N	2026-07-15 19:17:59.600542	Portugal	Universidade Da Beira Interior	t	f
09abda04-1779-4ecb-9eca-41b29876d39e	Tuğçe AYDOĞAN KILIÇ	tggceaydgn@gmail.com	\N	t	\N	2026-07-15 19:17:59.600542	Türkiye	Gümüşhane University, Faculty of Communication	t	f
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
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysrev_user
--

SELECT pg_catalog.setval('public.countries_id_seq', 128, true);


--
-- Name: languages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: sysrev_user
--

SELECT pg_catalog.setval('public.languages_id_seq', 40, true);


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
-- Name: countries countries_name_key; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_name_key UNIQUE (name);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


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
-- Name: languages languages_name_key; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_name_key UNIQUE (name);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: project_countries project_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_countries
    ADD CONSTRAINT project_countries_pkey PRIMARY KEY (project_id, country_id);


--
-- Name: project_languages project_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_languages
    ADD CONSTRAINT project_languages_pkey PRIMARY KEY (project_id, language_id);


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
-- Name: ix_countries_id; Type: INDEX; Schema: public; Owner: sysrev_user
--

CREATE INDEX ix_countries_id ON public.countries USING btree (id);


--
-- Name: ix_languages_id; Type: INDEX; Schema: public; Owner: sysrev_user
--

CREATE INDEX ix_languages_id ON public.languages USING btree (id);


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
-- Name: project_countries project_countries_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_countries
    ADD CONSTRAINT project_countries_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE;


--
-- Name: project_countries project_countries_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_countries
    ADD CONSTRAINT project_countries_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: project_languages project_languages_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_languages
    ADD CONSTRAINT project_languages_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE;


--
-- Name: project_languages project_languages_project_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sysrev_user
--

ALTER TABLE ONLY public.project_languages
    ADD CONSTRAINT project_languages_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


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

\unrestrict uZoiGv8REB2T3OgQgUzczN4JKf1iYyh93V9joh1wjuKtQvJZqbuRxiSskmS6PE6

