/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

--
-- PostgreSQL database dump
--

-- Dumped from database version 8.4.4
-- Dumped by pg_dump version 9.0.4
-- Started on 2011-07-28 12:00:42

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 7 (class 2615 OID 58663)
-- Name: FormBuilder; Type: SCHEMA; Schema: -; Owner: fbdev
--

CREATE SCHEMA "FormBuilder";


ALTER SCHEMA "FormBuilder" OWNER TO fbdev;

SET search_path = "FormBuilder", pg_catalog;

--
-- TOC entry 26 (class 1255 OID 58664)
-- Dependencies: 412 7
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
-- TOC entry 27 (class 1255 OID 58665)
-- Dependencies: 412 7
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
-- TOC entry 28 (class 1255 OID 58666)
-- Dependencies: 412 7
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
-- TOC entry 29 (class 1255 OID 58667)
-- Dependencies: 412 7
-- Name: refresh_question_ts_data(); Type: FUNCTION; Schema: FormBuilder; Owner: fbdev
--

CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data()
  RETURNS integer AS
$BODY$
DECLARE
	fid INTEGER;
	count INTEGER := 0;
begin
	FOR fid IN SELECT id FROM "FormBuilder".form_element LOOP
		PERFORM "FormBuilder".refresh_question_ts_data(fid);
		count := count + 1;
	END LOOP;

	RETURN count;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "FormBuilder".refresh_question_ts_data() OWNER TO fbdev;

--
-- TOC entry 30 (class 1255 OID 58668)
-- Dependencies: 412 7
-- Name: refresh_question_ts_data(integer); Type: FUNCTION; Schema: FormBuilder; Owner: fbdev
--

CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data(fid integer)
  RETURNS integer AS
$BODY$
DECLARE
    q RECORD;
    a RECORD;
    av RECORD;
    data TSVECTOR;
	count INTEGER := 0;
begin

	data = ''::tsvector;
	
	FOR q IN SELECT qe.id as id, qe.short_name as short_name, fe.description as description, fe.learn_more as learn_more FROM "FormBuilder".form_element fe inner join "FormBuilder".question qe on fe.id = qe.parent_id inner join "FormBuilder".form frm on fe.form_id=frm.id WHERE fe.id = fid LOOP
		data = data ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.short_name,'')), 'A') ||
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
					
				count := count + 1;
	
			END LOOP;

		END LOOP;
	
	END LOOP;
	
	UPDATE "FormBuilder".form_element set ts_data = data WHERE id = fid;
	
	RETURN count;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "FormBuilder".refresh_question_ts_data(integer) OWNER TO fbdev;

-- Function: "FormBuilder".generate_metadata_for_table_question(character varying)

-- DROP FUNCTION "FormBuilder".generate_metadata_for_table_question(character varying);

CREATE OR REPLACE FUNCTION "FormBuilder".generate_metadata_for_table_question(table_question_id character varying)
  RETURNS text AS
$BODY$
 DECLARE _record record;
 DECLARE table_text character varying(2000);
 DECLARE column_header character varying(500);
 DECLARE question_id character(36);
 DECLARE table_type character varying(15);
 DECLARE table_short_name character varying(250);
 DECLARE table_question_is_identifying boolean;
 DECLARE metadata text;
 DECLARE column_data text;
 DECLARE column_ctr bigint;

BEGIN
 metadata := '';
 column_data := '';
 column_ctr := 0;
 FOR _record IN 
 select q.uuid,
	fe.description,
	av.description as "description2",
	fe.table_type,
	fe.table_short_name,
	q.is_identifying
	from form f, module m, form_element fe, question q, answer a, answer_value av
	where f.module_id = m.id 
	and fe.form_id = f.id
	and q.parent_id = fe.id
	and q.id = a.question_id
	and a.id = av.answer_id
	and fe.element_type = 'table'
	and fe.uuid=table_question_id
	order by q.uuid,av.value
 LOOP
	 table_text := _record.description;
	 column_header := _record.description2;
	 question_id := _record.uuid;
	 table_type := _record.table_type;
	 table_short_name := _record.table_short_name;
	 table_question_is_identifying := _record.is_identifying;

	 /*****************************************************************/
	 /* SIMPLE TABLE QUESTIONS 			                  */
	 /*****************************************************************/
	 IF table_type = 'SIMPLE' THEN
		-- Set up column headers
		IF column_header IS NOT NULL THEN
			EXIT WHEN position(column_header in column_data) > 0;
			column_ctr := column_ctr + 1;
			IF column_ctr > 1 THEN
				column_data := column_data || ',';
			END IF;
			column_data := column_data || '"' || column_header || '"';
		END IF;
	 END IF;
	 /*****************************************************************/
	 /* END processing SIMPLE TABLE QUESTIONS			  */
	 /*****************************************************************/
 
 END LOOP;

-- set up metadata

 /*****************************************************************/
 /* SIMPLE TABLE QUESTIONS 			                  */
 /*****************************************************************/
 IF table_type = 'SIMPLE' THEN
	metadata := '"table_text":"' || table_text || '", "short_name":"' || table_short_name || '"';
	metadata := metadata || ', "metadata": {' || metadata ||  ',"column_headers":[' || column_data || ']}';
 END IF;
 /*****************************************************************/
 /* END processing SIMPLE TABLE QUESTIONS			  */
 /*****************************************************************/
		

 RETURN metadata;
 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "FormBuilder".generate_metadata_for_table_question(character varying) OWNER TO fbdev;

--
-- TOC entry 1267 (class 3602 OID 58669)
-- Dependencies: 7 1237
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
-- TOC entry 1624 (class 1259 OID 58670)
-- Dependencies: 7
-- Name: GENERIC_ID_SEQ; Type: SEQUENCE; Schema: FormBuilder; Owner: fbdev
--

CREATE SEQUENCE "GENERIC_ID_SEQ"
    START WITH 1001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "FormBuilder"."GENERIC_ID_SEQ" OWNER TO fbdev;

--
-- TOC entry 2002 (class 0 OID 0)
-- Dependencies: 1624
-- Name: GENERIC_ID_SEQ; Type: SEQUENCE SET; Schema: FormBuilder; Owner: fbdev
--

SELECT pg_catalog.setval('"GENERIC_ID_SEQ"', 1001, false);


--
-- TOC entry 1625 (class 1259 OID 58672)
-- Dependencies: 7
-- Name: RPT_USERS_SEQ; Type: SEQUENCE; Schema: FormBuilder; Owner: fbdev
--

CREATE SEQUENCE "RPT_USERS_SEQ"
    START WITH 6
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "FormBuilder"."RPT_USERS_SEQ" OWNER TO fbdev;

--
-- TOC entry 2003 (class 0 OID 0)
-- Dependencies: 1625
-- Name: RPT_USERS_SEQ; Type: SEQUENCE SET; Schema: FormBuilder; Owner: fbdev
--

SELECT pg_catalog.setval('"RPT_USERS_SEQ"', 6, false);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1626 (class 1259 OID 58674)
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
-- TOC entry 1627 (class 1259 OID 58680)
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
-- TOC entry 1628 (class 1259 OID 58683)
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
-- TOC entry 1629 (class 1259 OID 58689)
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
-- TOC entry 1630 (class 1259 OID 58692)
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
    table_type character varying(15),
    table_short_name character varying(250)
);


ALTER TABLE "FormBuilder".form_element OWNER TO fbdev;

--
-- TOC entry 1631 (class 1259 OID 58698)
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
-- TOC entry 1632 (class 1259 OID 58704)
-- Dependencies: 1737 7
-- Name: answer_value_form_id_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW answer_value_form_id_vw AS
    SELECT link_fe.form_id AS link_form_id, av.permanent_id AS av_uuid, av.id AS av_id, 'link' FROM form_element lib_fe, form_element link_fe, answer_value av, answer a, question q WHERE (((((link_fe.link_id)::bpchar = lib_fe.uuid) AND (q.parent_id = lib_fe.id)) AND (a.question_id = q.id)) AND (av.answer_id = a.id)) UNION SELECT f.id AS link_form_id, av.permanent_id AS av_uuid, av.id AS av_id, 'not' FROM answer_value av, answer a, question q, form_element fe, form f WHERE (((((av.answer_id = a.id) AND (a.question_id = q.id)) AND (q.parent_id = fe.id)) AND (fe.form_id = f.id)) AND ((f.form_type)::text = 'questionnaireForm'::text));


ALTER TABLE "FormBuilder".answer_value_form_id_vw OWNER TO fbdev;

--
-- TOC entry 1633 (class 1259 OID 58709)
-- Dependencies: 7
-- Name: category; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE category (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(300)
);


ALTER TABLE "FormBuilder".category OWNER TO fbdev;

--
-- TOC entry 1644 (class 1259 OID 58864)
-- Dependencies: 1740 7
-- Name: fe_approved_links_count_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW fe_approved_links_count_vw AS
    SELECT fe.id, fc.cnt FROM form_element fe, form_element link, (SELECT frm1.id, (SELECT count(frm2.*) AS count FROM form frm2 WHERE (((frm2.status)::text = 'APPROVED'::text) AND (frm2.id = frm1.id))) AS cnt FROM form frm1) fc WHERE ((((fe.element_type)::text <> 'link'::text) AND ((link.link_id)::bpchar = fe.uuid)) AND (fc.id = link.form_id)) GROUP BY fe.id, fc.cnt;


ALTER TABLE "FormBuilder".fe_approved_links_count_vw OWNER TO fbdev;

--
-- TOC entry 1645 (class 1259 OID 58868)
-- Dependencies: 1741 7
-- Name: form_element_links_count_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW form_element_links_count_vw AS
    SELECT fe.id, count(fe.id) AS count FROM form_element fe, form_element link WHERE (((fe.element_type)::text <> 'link'::text) AND ((link.link_id)::bpchar = fe.uuid)) GROUP BY fe.id;


ALTER TABLE "FormBuilder".form_element_links_count_vw OWNER TO fbdev;

--
-- TOC entry 1634 (class 1259 OID 58712)
-- Dependencies: 1933 7
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
-- TOC entry 1635 (class 1259 OID 58719)
-- Dependencies: 7
-- Name: question_categries; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question_categries (
    category_id bigint NOT NULL,
    question_id bigint NOT NULL
);


ALTER TABLE "FormBuilder".question_categries OWNER TO fbdev;

--
-- TOC entry 1636 (class 1259 OID 58722)
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
-- TOC entry 1637 (class 1259 OID 58728)
-- Dependencies: 7
-- Name: question_skip_rule; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question_skip_rule (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    rule_value character varying(50) NOT NULL,
    logical_op character varying(3),
    identifying_answer_value_uuid character(36)
);


ALTER TABLE "FormBuilder".question_skip_rule OWNER TO fbdev;

--
-- TOC entry 1638 (class 1259 OID 58731)
-- Dependencies: 7
-- Name: roles; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE roles (
    id bigint NOT NULL,
    name character varying(20)
);


ALTER TABLE "FormBuilder".roles OWNER TO fbdev;

--
-- TOC entry 1639 (class 1259 OID 58734)
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
-- TOC entry 1640 (class 1259 OID 58737)
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
-- TOC entry 1641 (class 1259 OID 58740)
-- Dependencies: 1738 7
-- Name: skip_pattern_answer_value_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW skip_pattern_answer_value_vw AS
    SELECT s.id, CASE r.parent_type WHEN 'formElementSkip'::text THEN r.parent_id ELSE NULL::bigint END AS form_element_id, CASE r.parent_type WHEN 'formSkip'::text THEN r.parent_id ELSE NULL::bigint END AS form_id, a.question_id AS skip_item_question, vw.link_form_id AS skip_item_form FROM skip_rule r, question_skip_rule s, answer_skip_rule sp, answer_value av, answer a, question q, form_element fe, form f, answer_value_form_id_vw vw WHERE (((((((((sp.answer_value_id)::bpchar = vw.av_uuid) AND (sp.form_id = vw.link_form_id)) AND (vw.av_id = av.id)) AND (av.answer_id = a.id)) AND (q.id = a.question_id)) AND (q.parent_id = fe.id)) AND (s.id = sp.parent_id)) AND (s.parent_id = r.id)) GROUP BY s.id, r.parent_type, r.parent_id, a.question_id, fe.form_id, vw.link_form_id;


ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;

--
-- TOC entry 1642 (class 1259 OID 58745)
-- Dependencies: 1739 7
-- Name: table_columns_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW table_columns_vw AS
    SELECT av.id, av.description AS heading, av.value, av.ord, q.parent_id AS table_id, q.id AS question_id FROM answer_value av, answer a, question q WHERE (((av.answer_id = a.id) AND (a.question_id = q.id)) AND (q.id IN (SELECT question.id FROM question WHERE (((question.question_type)::text = 'tableQuestion'::text) AND (question.ord = 1)))));


ALTER TABLE "FormBuilder".table_columns_vw OWNER TO fbdev;

--
-- TOC entry 1643 (class 1259 OID 58749)
-- Dependencies: 7
-- Name: user_roles; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE "FormBuilder".user_roles OWNER TO fbdev;

--
-- TOC entry 1984 (class 0 OID 58674)
-- Dependencies: 1626
-- Data for Name: answer; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1985 (class 0 OID 58680)
-- Dependencies: 1627
-- Data for Name: answer_skip_rule; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1986 (class 0 OID 58683)
-- Dependencies: 1628
-- Data for Name: answer_value; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1990 (class 0 OID 58709)
-- Dependencies: 1633
-- Data for Name: category; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO category VALUES (58050, 'About Me', 'Patient Demographic');


--
-- TOC entry 1987 (class 0 OID 58689)
-- Dependencies: 1629
-- Data for Name: form; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO form VALUES (1, NULL, NULL, NULL, NULL, NULL, 'Question Form', 1, 1, 'QUESTION_LIBRARY', '2011-05-20 09:55:08.171-04', 1, '2eb81d8c-8587-43f7-b324-a78f1780634e', NULL, 1, 'questionLibraryForm');


--
-- TOC entry 1988 (class 0 OID 58692)
-- Dependencies: 1630
-- Data for Name: form_element; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1991 (class 0 OID 58712)
-- Dependencies: 1634
-- Data for Name: module; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO module VALUES (1, 'Question Library', NULL, NULL, '2011-05-20 09:55:08.171-04', 1, 'QUESTION_LIBRARY', true, 'questionLibrary', NULL);
INSERT INTO module VALUES (2, 'Form Library', NULL, NULL, '2011-05-20 09:55:08.171-04', 1, 'FORM_LIBRARY', true, 'formLibrary', NULL);


--
-- TOC entry 1989 (class 0 OID 58698)
-- Dependencies: 1631
-- Data for Name: question; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1992 (class 0 OID 58719)
-- Dependencies: 1635
-- Data for Name: question_categries; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1993 (class 0 OID 58722)
-- Dependencies: 1636
-- Data for Name: question_orig; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1994 (class 0 OID 58728)
-- Dependencies: 1637
-- Data for Name: question_skip_rule; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1995 (class 0 OID 58731)
-- Dependencies: 1638
-- Data for Name: roles; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO roles VALUES (10, 'ROLE_AUTHOR');
INSERT INTO roles VALUES (30, 'ROLE_APPROVER');
INSERT INTO roles VALUES (20, 'ROLE_DEPLOYER');
INSERT INTO roles VALUES (999, 'ROLE_ADMIN');
INSERT INTO roles VALUES (40, 'ROLE_LIBRARIAN');


--
-- TOC entry 1996 (class 0 OID 58734)
-- Dependencies: 1639
-- Data for Name: rpt_users; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO rpt_users VALUES (2, 'test', '9ddc44f3f7f78da5781d6cab571b2fc5', '2010-04-19', NULL);
INSERT INTO rpt_users VALUES (3, 'dolson', '65d15fe9156f9c4bbffd98085992a44e', '2010-04-29', '');
INSERT INTO rpt_users VALUES (1, 'lkagan', 'a564de63c2d0da68cf47586ee05984d7', '2010-04-19', 'lkagan@healthcit.com');
INSERT INTO rpt_users VALUES (4, 'GuestUser', '084e0343a0486ff05530df6c705c8bb4', '2010-08-12', 'howard.shang@duke.edu');
INSERT INTO rpt_users VALUES (5, 'pgupta', 'a564de63c2d0da68cf47586ee05984d7', '2010-04-29', 'gupta@healthcit.com');


--
-- TOC entry 1997 (class 0 OID 58737)
-- Dependencies: 1640
-- Data for Name: skip_rule; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--



--
-- TOC entry 1998 (class 0 OID 58749)
-- Dependencies: 1643
-- Data for Name: user_roles; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO user_roles VALUES (3, 10);
INSERT INTO user_roles VALUES (1, 10);
INSERT INTO user_roles VALUES (1, 999);
INSERT INTO user_roles VALUES (1, 20);
INSERT INTO user_roles VALUES (5, 10);
INSERT INTO user_roles VALUES (4, 999);


--
-- TOC entry 1940 (class 2606 OID 58753)
-- Dependencies: 1628 1628
-- Name: answerValuePK; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer_value
    ADD CONSTRAINT "answerValuePK" PRIMARY KEY (id);


--
-- TOC entry 1935 (class 2606 OID 58755)
-- Dependencies: 1626 1626
-- Name: answer_label_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_label_pkey PRIMARY KEY (id);


--
-- TOC entry 1947 (class 2606 OID 58757)
-- Dependencies: 1630 1630
-- Name: form_element_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY form_element
    ADD CONSTRAINT form_element_pkey PRIMARY KEY (id);


--
-- TOC entry 1944 (class 2606 OID 58759)
-- Dependencies: 1629 1629
-- Name: form_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY form
    ADD CONSTRAINT form_pkey PRIMARY KEY (id);


--
-- TOC entry 1954 (class 2606 OID 58761)
-- Dependencies: 1634 1634
-- Name: module_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY module
    ADD CONSTRAINT module_pkey PRIMARY KEY (id);


--
-- TOC entry 1952 (class 2606 OID 58763)
-- Dependencies: 1633 1633
-- Name: pk_categoryId; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT "pk_categoryId" PRIMARY KEY (id);


--
-- TOC entry 1957 (class 2606 OID 58765)
-- Dependencies: 1636 1636
-- Name: question_new_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question_orig
    ADD CONSTRAINT question_new_pkey PRIMARY KEY (id);


--
-- TOC entry 1950 (class 2606 OID 58767)
-- Dependencies: 1631 1631
-- Name: question_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_pkey PRIMARY KEY (id);


--
-- TOC entry 1962 (class 2606 OID 58769)
-- Dependencies: 1638 1638
-- Name: roles_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 1938 (class 2606 OID 58771)
-- Dependencies: 1627 1627
-- Name: skip_pattern_parts_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer_skip_rule
    ADD CONSTRAINT skip_pattern_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 1960 (class 2606 OID 58773)
-- Dependencies: 1637 1637
-- Name: skip_pattern_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question_skip_rule
    ADD CONSTRAINT skip_pattern_pkey PRIMARY KEY (id);


--
-- TOC entry 1968 (class 2606 OID 58780)
-- Dependencies: 1640 1640
-- Name: skip_rule_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY skip_rule
    ADD CONSTRAINT skip_rule_pkey PRIMARY KEY (id);


--
-- TOC entry 1964 (class 2606 OID 58782)
-- Dependencies: 1639 1639
-- Name: unique_username; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY rpt_users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- TOC entry 1966 (class 2606 OID 58784)
-- Dependencies: 1639 1639
-- Name: users_pri_key; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY rpt_users
    ADD CONSTRAINT users_pri_key PRIMARY KEY (id);


--
-- TOC entry 1936 (class 1259 OID 58785)
-- Dependencies: 1626
-- Name: fki_fb_answer_question_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_answer_question_fk ON answer USING btree (question_id);


--
-- TOC entry 1941 (class 1259 OID 58786)
-- Dependencies: 1628
-- Name: fki_fb_answer_value_answer_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_answer_value_answer_fk ON answer_value USING btree (answer_id);


--
-- TOC entry 1945 (class 1259 OID 58787)
-- Dependencies: 1630
-- Name: fki_fb_form_element_form_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_form_element_form_fk ON form_element USING btree (form_id);


--
-- TOC entry 1942 (class 1259 OID 58788)
-- Dependencies: 1629
-- Name: fki_fb_form_module_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_form_module_fk ON form USING btree (module_id);


--
-- TOC entry 1955 (class 1259 OID 58789)
-- Dependencies: 1636
-- Name: fki_fb_question_form_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_question_form_fk ON question_orig USING btree (form_id);


--
-- TOC entry 1948 (class 1259 OID 58790)
-- Dependencies: 1631
-- Name: fki_fb_question_parent_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_question_parent_fk ON question USING btree (parent_id);


--
-- TOC entry 1958 (class 1259 OID 58791)
-- Dependencies: 1636
-- Name: question_ts_data_idx; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX question_ts_data_idx ON question_orig USING gin (ts_data);


--
-- TOC entry 1969 (class 2606 OID 58792)
-- Dependencies: 1631 1949 1626
-- Name: fb_answer_question_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT fb_answer_question_fk FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE;


--
-- TOC entry 1970 (class 2606 OID 58797)
-- Dependencies: 1934 1628 1626
-- Name: fb_answer_value_answer_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY answer_value
    ADD CONSTRAINT fb_answer_value_answer_fk FOREIGN KEY (answer_id) REFERENCES answer(id) ON DELETE CASCADE;


--
-- TOC entry 1971 (class 2606 OID 58802)
-- Dependencies: 1639 1965 1629
-- Name: fb_form_author_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_author_user_fk FOREIGN KEY (author_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1975 (class 2606 OID 58807)
-- Dependencies: 1629 1630 1943
-- Name: fb_form_element_form_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form_element
    ADD CONSTRAINT fb_form_element_form_fk FOREIGN KEY (form_id) REFERENCES form(id) ON DELETE CASCADE;


--
-- TOC entry 1972 (class 2606 OID 58812)
-- Dependencies: 1629 1965 1639
-- Name: fb_form_last_updated_by_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_last_updated_by_user_fk FOREIGN KEY (last_updated_by_user_id) REFERENCES rpt_users(id) ON DELETE RESTRICT;


--
-- TOC entry 1973 (class 2606 OID 58817)
-- Dependencies: 1965 1629 1639
-- Name: fb_form_locked_by_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_locked_by_fk FOREIGN KEY (locked_by_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1974 (class 2606 OID 58822)
-- Dependencies: 1629 1953 1634
-- Name: fb_form_module_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_module_fk FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE CASCADE;


--
-- TOC entry 1977 (class 2606 OID 58827)
-- Dependencies: 1965 1634 1639
-- Name: fb_module_author_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY module
    ADD CONSTRAINT fb_module_author_user_fk FOREIGN KEY (author_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1976 (class 2606 OID 58832)
-- Dependencies: 1631 1946 1630
-- Name: fb_question_form_element_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fb_question_form_element_fk FOREIGN KEY (parent_id) REFERENCES form_element(id) ON DELETE CASCADE;


--
-- TOC entry 1980 (class 2606 OID 58837)
-- Dependencies: 1629 1636 1943
-- Name: fb_question_form_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_orig
    ADD CONSTRAINT fb_question_form_fk FOREIGN KEY (form_id) REFERENCES form(id) ON DELETE CASCADE;


--
-- TOC entry 1981 (class 2606 OID 58774)
-- Dependencies: 1939 1637 1628
-- Name: fb_question_skip_rule_answer_value_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

alter table "FormBuilder".answer_value add constraint unique_answer_value_permanent_id UNIQUE (permanent_id);
alter table "FormBuilder".question_skip_rule
    add constraint fb_question_skip_rule_answer_value_fk foreign key (identifying_answer_value_uuid) references "FormBuilder".answer_value(permanent_id) on update cascade on delete cascade;


--
-- TOC entry 1978 (class 2606 OID 58842)
-- Dependencies: 1635 1633 1951
-- Name: fk_categoryId_question_categories; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_categries
    ADD CONSTRAINT "fk_categoryId_question_categories" FOREIGN KEY (category_id) REFERENCES category(id);


--
-- TOC entry 1979 (class 2606 OID 58847)
-- Dependencies: 1946 1630 1635
-- Name: fk_questionId_form_element_categories; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_categries
    ADD CONSTRAINT "fk_questionId_form_element_categories" FOREIGN KEY (question_id) REFERENCES form_element(id);


--
-- TOC entry 1982 (class 2606 OID 58852)
-- Dependencies: 1643 1961 1638
-- Name: fk_roleId_user_roles; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT "fk_roleId_user_roles" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;


--
-- TOC entry 1983 (class 2606 OID 58857)
-- Dependencies: 1639 1643 1965
-- Name: fk_userId_user_roles; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT "fk_userId_user_roles" FOREIGN KEY (user_id) REFERENCES rpt_users(id) ON DELETE CASCADE;


--
-- TOC entry 2001 (class 0 OID 0)
-- Dependencies: 7
-- Name: FormBuilder; Type: ACL; Schema: -; Owner: fbdev
--

REVOKE ALL ON SCHEMA "FormBuilder" FROM PUBLIC;
REVOKE ALL ON SCHEMA "FormBuilder" FROM fbdev;
GRANT ALL ON SCHEMA "FormBuilder" TO fbdev;
GRANT ALL ON SCHEMA "FormBuilder" TO PUBLIC;


-- Completed on 2011-07-28 12:00:48

--
-- PostgreSQL database dump complete
--

