/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

--
-- PostgreSQL database dump
--

-- Started on 2011-05-20 16:55:35

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 7 (class 2615 OID 34103)
-- Name: FormBuilder; Type: SCHEMA; Schema: -; Owner: fbdev
--

CREATE SCHEMA "FormBuilder";


ALTER SCHEMA "FormBuilder" OWNER TO fbdev;

SET search_path = "FormBuilder", pg_catalog;

--
-- TOC entry 22 (class 1255 OID 34104)
-- Dependencies: 354 7
-- Name: convertskips(); Type: FUNCTION; Schema: FormBuilder; Owner: fbdev
--

CREATE FUNCTION convertskips() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    r skip_pattern%rowtype;
BEGIN
    FOR r IN SELECT * FROM skip_pattern
    LOOP
	insert into skip_pattern_parts (id, parent_id, answer_value_id, dtype)
		values (nextval('"GENERIC_ID_SEQ"'), r.id, r.answer_value_id,  'SkipPart');

    END LOOP;
    RETURN 1;
END
$$;


ALTER FUNCTION "FormBuilder".convertskips() OWNER TO fbdev;

--
-- TOC entry 23 (class 1255 OID 34105)
-- Dependencies: 7 354
-- Name: from_hex(text); Type: FUNCTION; Schema: FormBuilder; Owner: fbdev
--

CREATE FUNCTION from_hex(t text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN EXECUTE 'SELECT x'''||t||'''::integer AS hex' LOOP
        RETURN r.hex;
    END LOOP;
END
$$;


ALTER FUNCTION "FormBuilder".from_hex(t text) OWNER TO fbdev;

--
-- TOC entry 24 (class 1255 OID 34106)
-- Dependencies: 7 354
-- Name: generate_uuid_v3(character varying, character varying); Type: FUNCTION; Schema: FormBuilder; Owner: fbdev
--

CREATE FUNCTION generate_uuid_v3(namespace character varying, name character varying) RETURNS uuid
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    value varchar(36);
    bytes varchar;
BEGIN
    bytes = md5(decode(namespace, 'hex') || decode(name, 'escape'));
    value = substr(bytes, 1+0, 8);
    value = value || '-';
    value = value || substr(bytes, 1+2*4, 4);
    value = value || '-';
    value = value || lpad(to_hex((from_hex(substr(bytes, 1+2*6, 2)) & 15) | 48), 2, '0');
    value = value || substr(bytes, 1+2*7, 2);
    value = value || '-';
    value = value || lpad(to_hex((from_hex(substr(bytes, 1+2*8, 2)) & 63) | 128), 2, '0');
    value = value || substr(bytes, 1+2*9, 2);
    value = value || '-';
    value = value || substr(bytes, 1+2*10, 12);
    return value::uuid;
END;
$$;


ALTER FUNCTION "FormBuilder".generate_uuid_v3(namespace character varying, name character varying) OWNER TO fbdev;

--
-- TOC entry 20 (class 1255 OID 34107)
-- Dependencies: 354 7
-- Name: refresh_question_ts_data(); Type: FUNCTION; Schema: FormBuilder; Owner: fbdev
--

CREATE FUNCTION refresh_question_ts_data() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	qid INTEGER;
	count INTEGER := 0;
begin
	FOR qid IN SELECT * FROM "FormBuilder".question LOOP
		PERFORM "FormBuilder".refresh_question_ts_data(qid);
		count := count + 1;
	END LOOP;

	RETURN count;
end
$$;


ALTER FUNCTION "FormBuilder".refresh_question_ts_data() OWNER TO fbdev;

--
-- TOC entry 21 (class 1255 OID 34108)
-- Dependencies: 7 354
-- Name: refresh_question_ts_data(integer); Type: FUNCTION; Schema: FormBuilder; Owner: fbdev
--

CREATE FUNCTION refresh_question_ts_data(qid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    q RECORD;
    a RECORD;
    av RECORD;
    data TSVECTOR;
begin
	SELECT qe.id as id, qe.short_name as short_name, qe.description as description, fe.learn_more as learn_more, fe.id as fid INTO q FROM "FormBuilder".form_element fe inner join "FormBuilder".question qe on fe.id = qe.parent_id inner join "FormBuilder".form frm on fe.form_id=frm.id WHERE frm.form_type='questionLibraryForm' AND fe.id = qid;

	if (q is NULL) then
		RETURN qid;
	end if;

	data = setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.short_name,'')), 'A') ||
		setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.description,'')), 'B') ||
		setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.learn_more,'')), 'C');

	FOR a IN SELECT * FROM "FormBuilder".answer WHERE question_id = q.id LOOP

		data = data ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(a.description,'')), 'C') ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(a.group_name,'')), 'D');

		FOR av IN SELECT * FROM "FormBuilder".answer_value WHERE answer_id = a.id LOOP

			data = data ||
				setweight(to_tsvector('"FormBuilder".ts_config', coalesce(av.description,'')), 'C') ||
				setweight(to_tsvector('"FormBuilder".ts_config', coalesce(av.short_name,'')), 'D');

		END LOOP;

	END LOOP;

	UPDATE "FormBuilder".form_element set ts_data = data WHERE id = q.fid;

	RETURN q.id;
end
$$;


ALTER FUNCTION "FormBuilder".refresh_question_ts_data(qid integer) OWNER TO fbdev;

--
-- TOC entry 1208 (class 3602 OID 34109)
-- Dependencies: 7 1179
-- Name: ts_config; Type: TEXT SEARCH CONFIGURATION; Schema: FormBuilder; Owner: fbdev
--

CREATE TEXT SEARCH CONFIGURATION ts_config (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR asciiword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR word WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR hword_part WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR hword_asciipart WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR asciihword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR hword WITH english_stem;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION ts_config
    ADD MAPPING FOR uint WITH simple;


ALTER TEXT SEARCH CONFIGURATION "FormBuilder".ts_config OWNER TO fbdev;

--
-- TOC entry 1542 (class 1259 OID 34110)
-- Dependencies: 7
-- Name: GENERIC_ID_SEQ; Type: SEQUENCE; Schema: FormBuilder; Owner: fbdev
--

CREATE SEQUENCE "GENERIC_ID_SEQ"
    START WITH 1001
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE "FormBuilder"."GENERIC_ID_SEQ" OWNER TO fbdev;

--
-- TOC entry 1915 (class 0 OID 0)
-- Dependencies: 1542
-- Name: GENERIC_ID_SEQ; Type: SEQUENCE SET; Schema: FormBuilder; Owner: fbdev
--

SELECT pg_catalog.setval('"GENERIC_ID_SEQ"', 1001, false);


--
-- TOC entry 1543 (class 1259 OID 34112)
-- Dependencies: 7
-- Name: RPT_USERS_SEQ; Type: SEQUENCE; Schema: FormBuilder; Owner: fbdev
--

CREATE SEQUENCE "RPT_USERS_SEQ"
    START WITH 5
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE "FormBuilder"."RPT_USERS_SEQ" OWNER TO fbdev;

--
-- TOC entry 1916 (class 0 OID 0)
-- Dependencies: 1543
-- Name: RPT_USERS_SEQ; Type: SEQUENCE SET; Schema: FormBuilder; Owner: fbdev
--

SELECT pg_catalog.setval('"RPT_USERS_SEQ"', 5, false);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1544 (class 1259 OID 34114)
-- Dependencies: 7
-- Name: answer; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE answer (
    id bigint NOT NULL,
    type character varying(10) NOT NULL,
    description character varying(500),
    group_name character varying(100),
    question_id bigint NOT NULL,
    ord bigint,
    answer_column_heading character varying(200),
    display_style character varying(200),
    value_constraint character varying(100),
    uuid character varying(40)
);


ALTER TABLE "FormBuilder".answer OWNER TO fbdev;

--
-- TOC entry 1557 (class 1259 OID 34174)
-- Dependencies: 7
-- Name: answer_skip_rule; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE answer_skip_rule (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    answer_value_id character varying(150) NOT NULL,
    dtype character varying(50),
    form_uuid character varying(36),
    question_uuid character varying(36),
    form_id bigint
);


ALTER TABLE "FormBuilder".answer_skip_rule OWNER TO fbdev;

--
-- TOC entry 1545 (class 1259 OID 34120)
-- Dependencies: 7
-- Name: answer_value; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE answer_value (
    id bigint NOT NULL,
    short_name character varying(250) NOT NULL,
    value character varying(250) NOT NULL,
    answer_id bigint NOT NULL,
    description character varying(500),
    ord bigint NOT NULL,
    permanent_id character(36) NOT NULL,
    cadsr_public_id bigint,
    external_id character varying(40)
);


ALTER TABLE "FormBuilder".answer_value OWNER TO fbdev;

--
-- TOC entry 1546 (class 1259 OID 34126)
-- Dependencies: 7
-- Name: form; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE form (
    id bigint NOT NULL,
    sequence bigint,
    location character varying(100),
    system_id character varying(20),
    version bigint,
    type character varying(3),
    name character varying(100) NOT NULL,
    module_id bigint NOT NULL,
    ord bigint NOT NULL,
    status character varying(30) NOT NULL,
    update_date timestamp with time zone NOT NULL,
    author_user_id bigint NOT NULL,
    uuid character(36) NOT NULL,
    locked_by_user_id bigint,
    last_updated_by_user_id bigint,
    form_type character varying(30)
);


ALTER TABLE "FormBuilder".form OWNER TO fbdev;

--
-- TOC entry 1547 (class 1259 OID 34129)
-- Dependencies: 7
-- Name: form_element; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE form_element (
    id bigint NOT NULL,
    description character varying(2000),
    form_id bigint,
    ord bigint,
    learn_more character varying(2000),
    is_required boolean,
    ts_data tsvector,
    uuid character(36),
    link_id character varying(255),
    link_source character varying(30),
    is_visible boolean,
    element_type character varying(40),
    has_been_modified boolean,
    answer_type character varying(10),
    external_id character varying(36),
    external_uuid character varying(40),
    table_type character varying(15)
);


ALTER TABLE "FormBuilder".form_element OWNER TO fbdev;

--
-- TOC entry 1548 (class 1259 OID 34135)
-- Dependencies: 7
-- Name: question; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question (
    id bigint NOT NULL,
    uuid character(36) NOT NULL,
    short_name character varying(250),
    parent_id bigint NOT NULL,
    ord bigint,
    description character varying(2000),
    question_type character varying(40),
    type character varying(30),
    is_identifying boolean
);


ALTER TABLE "FormBuilder".question OWNER TO fbdev;

--
-- TOC entry 1549 (class 1259 OID 34141)
-- Dependencies: 1649 7
-- Name: answer_value_form_id_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW answer_value_form_id_vw AS
    SELECT link_fe.form_id AS link_form_id, av.permanent_id AS av_uuid, av.id AS av_id, 'link' FROM form_element lib_fe, form_element link_fe, answer_value av, answer a, question q WHERE (((((link_fe.link_id)::bpchar = lib_fe.uuid) AND (q.parent_id = lib_fe.id)) AND (a.question_id = q.id)) AND (av.answer_id = a.id)) UNION SELECT f.id AS link_form_id, av.permanent_id AS av_uuid, av.id AS av_id, 'not' FROM answer_value av, answer a, question q, form_element fe, form f WHERE (((((av.answer_id = a.id) AND (a.question_id = q.id)) AND (q.parent_id = fe.id)) AND (fe.form_id = f.id)) AND ((f.form_type)::text = 'questionnaireForm'::text));


ALTER TABLE "FormBuilder".answer_value_form_id_vw OWNER TO fbdev;

--
-- TOC entry 1550 (class 1259 OID 34146)
-- Dependencies: 7
-- Name: category; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE category (
    id bigint NOT NULL,
    name character varying(50),
    description character varying(300)
);


ALTER TABLE "FormBuilder".category OWNER TO fbdev;

--
-- TOC entry 1551 (class 1259 OID 34149)
-- Dependencies: 1843 7
-- Name: module; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE module (
    id bigint NOT NULL,
    description character varying(100),
    release_date date,
    comments character varying(200),
    update_date timestamp with time zone NOT NULL,
    author_user_id bigint NOT NULL,
    status character varying(30) DEFAULT 'IN_PROGRESS'::character varying NOT NULL,
    is_library boolean,
    module_type character varying(30),
    completiontime character varying
);


ALTER TABLE "FormBuilder".module OWNER TO fbdev;

--
-- TOC entry 1552 (class 1259 OID 34156)
-- Dependencies: 7
-- Name: question_categries; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question_categries (
    category_id bigint NOT NULL,
    question_id bigint NOT NULL
);


ALTER TABLE "FormBuilder".question_categries OWNER TO fbdev;

--
-- TOC entry 1553 (class 1259 OID 34159)
-- Dependencies: 7
-- Name: question_orig; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question_orig (
    id bigint NOT NULL,
    type character varying(30) NOT NULL,
    description character varying(2000) NOT NULL,
    form_id bigint NOT NULL,
    short_name character varying(250),
    ord bigint NOT NULL,
    learn_more character varying(2000),
    is_required boolean,
    ts_data tsvector,
    uuid character(36) NOT NULL,
    link_id character varying(255),
    link_source character varying(30),
    cadsr_public_id bigint,
    is_visible boolean NOT NULL,
    table_id bigint,
    question_type character varying(40),
    parent_id bigint,
    parent_type character varying(40)
);


ALTER TABLE "FormBuilder".question_orig OWNER TO fbdev;

--
-- TOC entry 1556 (class 1259 OID 34171)
-- Dependencies: 7
-- Name: question_skip_rule; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question_skip_rule (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    rule_value character varying(50) NOT NULL,
    logical_op character varying(3)
);


ALTER TABLE "FormBuilder".question_skip_rule OWNER TO fbdev;

--
-- TOC entry 1554 (class 1259 OID 34165)
-- Dependencies: 7
-- Name: roles; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE roles (
    id bigint NOT NULL,
    name character varying(20)
);


ALTER TABLE "FormBuilder".roles OWNER TO fbdev;

--
-- TOC entry 1555 (class 1259 OID 34168)
-- Dependencies: 7
-- Name: rpt_users; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE rpt_users (
    id bigint NOT NULL,
    username character varying(25),
    password character varying(130),
    created_date date,
    email_addr character varying(100)
);


ALTER TABLE "FormBuilder".rpt_users OWNER TO fbdev;

--
-- TOC entry 1562 (class 1259 OID 34296)
-- Dependencies: 7
-- Name: skip_rule; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE skip_rule (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    logical_op character varying(3),
    parent_type character varying(15)
);


ALTER TABLE "FormBuilder".skip_rule OWNER TO fbdev;

--
-- TOC entry 1558 (class 1259 OID 34177)
-- Dependencies: 1650 7
-- Name: skip_pattern_answer_value_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW skip_pattern_answer_value_vw AS
    SELECT s.id, CASE r.parent_type WHEN 'formElementSkip'::text THEN r.parent_id ELSE NULL::bigint END AS form_element_id, CASE r.parent_type WHEN 'formSkip'::text THEN r.parent_id ELSE NULL::bigint END AS form_id, a.question_id AS skip_item_question, vw.link_form_id AS skip_item_form FROM skip_rule r, question_skip_rule s, answer_skip_rule sp, answer_value av, answer a, question q, form_element fe, form f, answer_value_form_id_vw vw WHERE (((((((((sp.answer_value_id)::bpchar = vw.av_uuid) AND (sp.form_id = vw.link_form_id)) AND (vw.av_id = av.id)) AND (av.answer_id = a.id)) AND (q.id = a.question_id)) AND (q.parent_id = fe.id)) AND (s.id = sp.parent_id)) AND (s.parent_id = r.id)) GROUP BY s.id, r.parent_type, r.parent_id, a.question_id, fe.form_id, vw.link_form_id;


ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;

--
-- TOC entry 1559 (class 1259 OID 34182)
-- Dependencies: 1651 7
-- Name: table_columns_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW table_columns_vw AS
    SELECT av.id, av.description AS heading, av.value, av.ord, q.parent_id AS table_id, q.id AS question_id FROM answer_value av, answer a, question q WHERE (((av.answer_id = a.id) AND (a.question_id = q.id)) AND (q.id IN (SELECT question.id FROM question WHERE (((question.question_type)::text = 'tableQuestion'::text) AND (question.ord = 1)))));


ALTER TABLE "FormBuilder".table_columns_vw OWNER TO fbdev;

--
-- TOC entry 1560 (class 1259 OID 34186)
-- Dependencies: 7
-- Name: test; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE test (
    uuid character varying(36)
);


ALTER TABLE "FormBuilder".test OWNER TO fbdev;

--
-- TOC entry 1561 (class 1259 OID 34189)
-- Dependencies: 7
-- Name: user_roles; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE "FormBuilder".user_roles OWNER TO fbdev;

--
-- TOC entry 1893 (class 0 OID 34114)
-- Dependencies: 1544
-- Data for Name: answer; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1905 (class 0 OID 34174)
-- Dependencies: 1557
-- Data for Name: answer_skip_rule; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1894 (class 0 OID 34120)
-- Dependencies: 1545
-- Data for Name: answer_value; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1898 (class 0 OID 34146)
-- Dependencies: 1550
-- Data for Name: category; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO category (id, name, description) VALUES (58050, 'About Me', 'Patient Demographic');


--
-- TOC entry 1895 (class 0 OID 34126)
-- Dependencies: 1546
-- Data for Name: form; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id, form_type) VALUES (1, NULL, NULL, NULL, NULL, NULL, 'Question Form', 1, 1, 'QUESTION_LIBRARY', '2011-05-20 16:55:08.171+03', 1, '2eb81d8c-8587-43f7-b324-a78f1780634e', NULL, 1, 'questionLibraryForm');


--
-- TOC entry 1896 (class 0 OID 34129)
-- Dependencies: 1547
-- Data for Name: form_element; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1899 (class 0 OID 34149)
-- Dependencies: 1551
-- Data for Name: module; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO module (id, description, release_date, comments, update_date, author_user_id, status, is_library, module_type, completiontime) VALUES (1, 'Question Library', NULL, NULL, '2011-05-20 16:55:08.171+03', 1, 'QUESTION_LIBRARY', true, 'questionLibrary', NULL);
INSERT INTO module (id, description, release_date, comments, update_date, author_user_id, status, is_library, module_type, completiontime) VALUES (2, 'Form Library', NULL, NULL, '2011-05-20 16:55:08.171+03', 1, 'FORM_LIBRARY', true, 'formLibrary', NULL);


--
-- TOC entry 1897 (class 0 OID 34135)
-- Dependencies: 1548
-- Data for Name: question; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1900 (class 0 OID 34156)
-- Dependencies: 1552
-- Data for Name: question_categries; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1901 (class 0 OID 34159)
-- Dependencies: 1553
-- Data for Name: question_orig; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1904 (class 0 OID 34171)
-- Dependencies: 1556
-- Data for Name: question_skip_rule; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1902 (class 0 OID 34165)
-- Dependencies: 1554
-- Data for Name: roles; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO roles (id, name) VALUES (10, 'ROLE_AUTHOR');
INSERT INTO roles (id, name) VALUES (30, 'ROLE_APPROVER');
INSERT INTO roles (id, name) VALUES (20, 'ROLE_DEPLOYER');
INSERT INTO roles (id, name) VALUES (999, 'ROLE_ADMIN');
INSERT INTO roles (id, name) VALUES (40, 'ROLE_LIBRARIAN');


--
-- TOC entry 1903 (class 0 OID 34168)
-- Dependencies: 1555
-- Data for Name: rpt_users; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (2, 'test', '9ddc44f3f7f78da5781d6cab571b2fc5', '2010-04-19', NULL);
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (3, 'dolson', '65d15fe9156f9c4bbffd98085992a44e', '2010-04-29', '');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (1, 'lkagan', 'a564de63c2d0da68cf47586ee05984d7', '2010-04-19', 'lkagan@healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (4, 'GuestUser', '084e0343a0486ff05530df6c705c8bb4', '2010-08-12', 'howard.shang@duke.edu');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (5, 'pgupta', 'a564de63c2d0da68cf47586ee05984d7', '2010-04-29', 'gupta@healthcit.com');


--
-- TOC entry 1908 (class 0 OID 34296)
-- Dependencies: 1562
-- Data for Name: skip_rule; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1906 (class 0 OID 34186)
-- Dependencies: 1560
-- Data for Name: test; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1907 (class 0 OID 34189)
-- Dependencies: 1561
-- Data for Name: user_roles; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO user_roles (user_id, role_id) VALUES (3, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 999);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 20);
INSERT INTO user_roles (user_id, role_id) VALUES (5, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (4, 999);


--
-- TOC entry 1848 (class 2606 OID 34193)
-- Dependencies: 1545 1545
-- Name: answerValuePK; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer_value
    ADD CONSTRAINT "answerValuePK" PRIMARY KEY (id);


--
-- TOC entry 1845 (class 2606 OID 34195)
-- Dependencies: 1544 1544
-- Name: answer_label_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_label_pkey PRIMARY KEY (id);


--
-- TOC entry 1855 (class 2606 OID 34197)
-- Dependencies: 1547 1547
-- Name: form_element_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY form_element
    ADD CONSTRAINT form_element_pkey PRIMARY KEY (id);


--
-- TOC entry 1852 (class 2606 OID 34199)
-- Dependencies: 1546 1546
-- Name: form_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY form
    ADD CONSTRAINT form_pkey PRIMARY KEY (id);


--
-- TOC entry 1862 (class 2606 OID 34201)
-- Dependencies: 1551 1551
-- Name: module_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY module
    ADD CONSTRAINT module_pkey PRIMARY KEY (id);


--
-- TOC entry 1860 (class 2606 OID 34203)
-- Dependencies: 1550 1550
-- Name: pk_categoryId; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT "pk_categoryId" PRIMARY KEY (id);


--
-- TOC entry 1865 (class 2606 OID 34205)
-- Dependencies: 1553 1553
-- Name: question_new_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question_orig
    ADD CONSTRAINT question_new_pkey PRIMARY KEY (id);


--
-- TOC entry 1858 (class 2606 OID 34207)
-- Dependencies: 1548 1548
-- Name: question_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_pkey PRIMARY KEY (id);


--
-- TOC entry 1868 (class 2606 OID 34209)
-- Dependencies: 1554 1554
-- Name: roles_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 1876 (class 2606 OID 34211)
-- Dependencies: 1557 1557
-- Name: skip_pattern_parts_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer_skip_rule
    ADD CONSTRAINT skip_pattern_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 1874 (class 2606 OID 34213)
-- Dependencies: 1556 1556
-- Name: skip_pattern_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question_skip_rule
    ADD CONSTRAINT skip_pattern_pkey PRIMARY KEY (id);


--
-- TOC entry 1878 (class 2606 OID 34300)
-- Dependencies: 1562 1562
-- Name: skip_rule_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY skip_rule
    ADD CONSTRAINT skip_rule_pkey PRIMARY KEY (id);


--
-- TOC entry 1870 (class 2606 OID 34215)
-- Dependencies: 1555 1555
-- Name: unique_username; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY rpt_users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- TOC entry 1872 (class 2606 OID 34217)
-- Dependencies: 1555 1555
-- Name: users_pri_key; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY rpt_users
    ADD CONSTRAINT users_pri_key PRIMARY KEY (id);


--
-- TOC entry 1846 (class 1259 OID 34218)
-- Dependencies: 1544
-- Name: fki_fb_answer_question_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_answer_question_fk ON answer USING btree (question_id);


--
-- TOC entry 1849 (class 1259 OID 34278)
-- Dependencies: 1545
-- Name: fki_fb_answer_value_answer_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_answer_value_answer_fk ON answer_value USING btree (answer_id);


--
-- TOC entry 1853 (class 1259 OID 34295)
-- Dependencies: 1547
-- Name: fki_fb_form_element_form_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_form_element_form_fk ON form_element USING btree (form_id);


--
-- TOC entry 1850 (class 1259 OID 34219)
-- Dependencies: 1546
-- Name: fki_fb_form_module_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_form_module_fk ON form USING btree (module_id);


--
-- TOC entry 1863 (class 1259 OID 34220)
-- Dependencies: 1553
-- Name: fki_fb_question_form_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_question_form_fk ON question_orig USING btree (form_id);


--
-- TOC entry 1856 (class 1259 OID 34289)
-- Dependencies: 1548
-- Name: fki_fb_question_parent_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_question_parent_fk ON question USING btree (parent_id);


--
-- TOC entry 1866 (class 1259 OID 34221)
-- Dependencies: 1553
-- Name: question_ts_data_idx; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX question_ts_data_idx ON question_orig USING gin (ts_data);


--
-- TOC entry 1879 (class 2606 OID 34284)
-- Dependencies: 1548 1857 1544
-- Name: fb_answer_question_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT fb_answer_question_fk FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE;


--
-- TOC entry 1880 (class 2606 OID 34279)
-- Dependencies: 1545 1844 1544
-- Name: fb_answer_value_answer_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY answer_value
    ADD CONSTRAINT fb_answer_value_answer_fk FOREIGN KEY (answer_id) REFERENCES answer(id) ON DELETE CASCADE;


--
-- TOC entry 1881 (class 2606 OID 34223)
-- Dependencies: 1871 1555 1546
-- Name: fb_form_author_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_author_user_fk FOREIGN KEY (author_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1885 (class 2606 OID 34228)
-- Dependencies: 1546 1851 1547
-- Name: fb_form_element_form_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form_element
    ADD CONSTRAINT fb_form_element_form_fk FOREIGN KEY (form_id) REFERENCES form(id) ON DELETE CASCADE;


--
-- TOC entry 1882 (class 2606 OID 34233)
-- Dependencies: 1546 1555 1871
-- Name: fb_form_last_updated_by_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_last_updated_by_user_fk FOREIGN KEY (last_updated_by_user_id) REFERENCES rpt_users(id) ON DELETE RESTRICT;


--
-- TOC entry 1883 (class 2606 OID 34238)
-- Dependencies: 1555 1871 1546
-- Name: fb_form_locked_by_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_locked_by_fk FOREIGN KEY (locked_by_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1884 (class 2606 OID 34243)
-- Dependencies: 1861 1546 1551
-- Name: fb_form_module_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_module_fk FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE CASCADE;


--
-- TOC entry 1887 (class 2606 OID 34248)
-- Dependencies: 1871 1555 1551
-- Name: fb_module_author_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY module
    ADD CONSTRAINT fb_module_author_user_fk FOREIGN KEY (author_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1886 (class 2606 OID 34290)
-- Dependencies: 1547 1854 1548
-- Name: fb_question_form_element_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fb_question_form_element_fk FOREIGN KEY (parent_id) REFERENCES form_element(id) ON DELETE CASCADE;


--
-- TOC entry 1890 (class 2606 OID 34253)
-- Dependencies: 1553 1851 1546
-- Name: fb_question_form_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_orig
    ADD CONSTRAINT fb_question_form_fk FOREIGN KEY (form_id) REFERENCES form(id) ON DELETE CASCADE;


--
-- TOC entry 1888 (class 2606 OID 34258)
-- Dependencies: 1859 1550 1552
-- Name: fk_categoryId_question_categories; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_categries
    ADD CONSTRAINT "fk_categoryId_question_categories" FOREIGN KEY (category_id) REFERENCES category(id);


--
-- TOC entry 1889 (class 2606 OID 34263)
-- Dependencies: 1854 1547 1552
-- Name: fk_questionId_form_element_categories; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_categries
    ADD CONSTRAINT "fk_questionId_form_element_categories" FOREIGN KEY (question_id) REFERENCES form_element(id);


--
-- TOC entry 1891 (class 2606 OID 34268)
-- Dependencies: 1561 1867 1554
-- Name: fk_roleId_user_roles; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT "fk_roleId_user_roles" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;


--
-- TOC entry 1892 (class 2606 OID 34273)
-- Dependencies: 1871 1555 1561
-- Name: fk_userId_user_roles; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT "fk_userId_user_roles" FOREIGN KEY (user_id) REFERENCES rpt_users(id) ON DELETE CASCADE;


--
-- TOC entry 1912 (class 0 OID 0)
-- Dependencies: 7
-- Name: FormBuilder; Type: ACL; Schema: -; Owner: fbdev
--

REVOKE ALL ON SCHEMA "FormBuilder" FROM PUBLIC;
REVOKE ALL ON SCHEMA "FormBuilder" FROM fbdev;
GRANT ALL ON SCHEMA "FormBuilder" TO fbdev;
GRANT ALL ON SCHEMA "FormBuilder" TO PUBLIC;


--
-- TOC entry 1914 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2011-05-20 16:55:35

--
-- PostgreSQL database dump complete
--

