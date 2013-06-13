/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

--
-- PostgreSQL database dump
--

-- Started on 2011-03-08 10:42:35

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 8 (class 2615 OID 41808)
-- Name: FormBuilder; Type: SCHEMA; Schema: -; Owner: fbdev
--

CREATE SCHEMA "FormBuilder";


ALTER SCHEMA "FormBuilder" OWNER TO fbdev;

SET search_path = "FormBuilder", pg_catalog;

--
-- TOC entry 27 (class 1255 OID 41809)
-- Dependencies: 8 393
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
-- TOC entry 28 (class 1255 OID 41810)
-- Dependencies: 393 8
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
-- TOC entry 29 (class 1255 OID 41811)
-- Dependencies: 8 393
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
-- TOC entry 30 (class 1255 OID 41812)
-- Dependencies: 8 393
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
-- TOC entry 31 (class 1255 OID 41813)
-- Dependencies: 8 393
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
-- TOC entry 1248 (class 3602 OID 41814)
-- Dependencies: 1218 8
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
-- TOC entry 1597 (class 1259 OID 41815)
-- Dependencies: 8
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
-- TOC entry 1598 (class 1259 OID 41817)
-- Dependencies: 8
-- Name: RPT_USERS_SEQ; Type: SEQUENCE; Schema: FormBuilder; Owner: fbdev
--

CREATE SEQUENCE "RPT_USERS_SEQ"
    START WITH 5
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE "FormBuilder"."RPT_USERS_SEQ" OWNER TO fbdev;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1599 (class 1259 OID 41819)
-- Dependencies: 8
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
-- TOC entry 1600 (class 1259 OID 41825)
-- Dependencies: 8
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
-- TOC entry 1601 (class 1259 OID 41831)
-- Dependencies: 8
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
-- TOC entry 1602 (class 1259 OID 41834)
-- Dependencies: 8
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
    external_uuid character varying(40)
);


ALTER TABLE "FormBuilder".form_element OWNER TO fbdev;

--
-- TOC entry 1603 (class 1259 OID 41840)
-- Dependencies: 8
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
    type character varying(30)
);


ALTER TABLE "FormBuilder".question OWNER TO fbdev;

--
-- TOC entry 1604 (class 1259 OID 41846)
-- Dependencies: 1704 8
-- Name: answer_value_form_id_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW answer_value_form_id_vw AS
    SELECT link_fe.form_id AS link_form_id, av.permanent_id AS av_uuid, av.id AS av_id, 'link' FROM form_element lib_fe, form_element link_fe, answer_value av, answer a, question q WHERE (((((link_fe.link_id)::bpchar = lib_fe.uuid) AND (q.parent_id = lib_fe.id)) AND (a.question_id = q.id)) AND (av.answer_id = a.id)) UNION SELECT f.id AS link_form_id, av.permanent_id AS av_uuid, av.id AS av_id, 'not' FROM answer_value av, answer a, question q, form_element fe, form f WHERE (((((av.answer_id = a.id) AND (a.question_id = q.id)) AND (q.parent_id = fe.id)) AND (fe.form_id = f.id)) AND ((f.form_type)::text = 'questionnaireForm'::text));


ALTER TABLE "FormBuilder".answer_value_form_id_vw OWNER TO fbdev;

--
-- TOC entry 1605 (class 1259 OID 41851)
-- Dependencies: 8
-- Name: category; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE category (
    id bigint NOT NULL,
    name character varying(50),
    description character varying(300)
);


ALTER TABLE "FormBuilder".category OWNER TO fbdev;

--
-- TOC entry 1606 (class 1259 OID 41854)
-- Dependencies: 1898 8
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
-- TOC entry 1607 (class 1259 OID 41858)
-- Dependencies: 8
-- Name: question_categries; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question_categries (
    category_id bigint NOT NULL,
    question_id bigint NOT NULL
);


ALTER TABLE "FormBuilder".question_categries OWNER TO fbdev;

--
-- TOC entry 1608 (class 1259 OID 41861)
-- Dependencies: 8
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
-- TOC entry 1609 (class 1259 OID 41867)
-- Dependencies: 8
-- Name: roles; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE roles (
    id bigint NOT NULL,
    name character varying(20)
);


ALTER TABLE "FormBuilder".roles OWNER TO fbdev;

--
-- TOC entry 1610 (class 1259 OID 41870)
-- Dependencies: 8
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
-- TOC entry 1611 (class 1259 OID 41873)
-- Dependencies: 8
-- Name: skip_pattern; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE skip_pattern (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    rule_value character varying(50) NOT NULL,
    description character varying(2000) NOT NULL,
    parent_type character varying(20) NOT NULL,
    logical_op character varying(3)
);


ALTER TABLE "FormBuilder".skip_pattern OWNER TO fbdev;

--
-- TOC entry 1612 (class 1259 OID 41879)
-- Dependencies: 8
-- Name: skip_pattern_parts; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE skip_pattern_parts (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    answer_value_id character varying(150) NOT NULL,
    dtype character varying(50),
    form_uuid character varying(36),
    question_uuid character varying(36),
    form_id bigint
);


ALTER TABLE "FormBuilder".skip_pattern_parts OWNER TO fbdev;

--
-- TOC entry 1613 (class 1259 OID 41882)
-- Dependencies: 1705 8
-- Name: skip_pattern_answer_value_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW skip_pattern_answer_value_vw AS
    SELECT s.id, CASE s.parent_type WHEN 'questionSkip'::text THEN s.parent_id ELSE NULL::bigint END AS form_element_id, CASE s.parent_type WHEN 'formSkip'::text THEN s.parent_id ELSE NULL::bigint END AS form_id, a.question_id AS skip_item_question, vw.link_form_id AS skip_item_form FROM skip_pattern s, skip_pattern_parts sp, answer_value av, answer a, question q, form_element fe, form f, answer_value_form_id_vw vw WHERE ((((((((sp.answer_value_id)::bpchar = vw.av_uuid) AND (sp.form_id = vw.link_form_id)) AND (vw.av_id = av.id)) AND (av.answer_id = a.id)) AND (q.id = a.question_id)) AND (q.parent_id = fe.id)) AND (s.id = sp.parent_id)) GROUP BY s.id, s.parent_type, s.parent_id, a.question_id, fe.form_id, vw.link_form_id;


ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;

--
-- TOC entry 1614 (class 1259 OID 41887)
-- Dependencies: 1706 8
-- Name: table_columns_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW table_columns_vw AS
    SELECT av.id, av.description AS heading, av.value, av.ord, q.parent_id AS table_id, q.id AS question_id FROM answer_value av, answer a, question q WHERE (((av.answer_id = a.id) AND (a.question_id = q.id)) AND (q.id IN (SELECT question.id FROM question WHERE (((question.question_type)::text = 'tableQuestion'::text) AND (question.ord = 1)))));


ALTER TABLE "FormBuilder".table_columns_vw OWNER TO fbdev;

--
-- TOC entry 1615 (class 1259 OID 41891)
-- Dependencies: 8
-- Name: test; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE test (
    uuid character varying(36)
);


ALTER TABLE "FormBuilder".test OWNER TO fbdev;

--
-- TOC entry 1616 (class 1259 OID 41894)
-- Dependencies: 8
-- Name: user_roles; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE "FormBuilder".user_roles OWNER TO fbdev;

--
-- TOC entry 1903 (class 2606 OID 41898)
-- Dependencies: 1600 1600
-- Name: answerValuePK; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer_value
    ADD CONSTRAINT "answerValuePK" PRIMARY KEY (id);


--
-- TOC entry 1900 (class 2606 OID 41900)
-- Dependencies: 1599 1599
-- Name: answer_label_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_label_pkey PRIMARY KEY (id);


--
-- TOC entry 1908 (class 2606 OID 41902)
-- Dependencies: 1602 1602
-- Name: form_element_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY form_element
    ADD CONSTRAINT form_element_pkey PRIMARY KEY (id);


--
-- TOC entry 1906 (class 2606 OID 41904)
-- Dependencies: 1601 1601
-- Name: form_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY form
    ADD CONSTRAINT form_pkey PRIMARY KEY (id);


--
-- TOC entry 1914 (class 2606 OID 41906)
-- Dependencies: 1606 1606
-- Name: module_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY module
    ADD CONSTRAINT module_pkey PRIMARY KEY (id);


--
-- TOC entry 1912 (class 2606 OID 41908)
-- Dependencies: 1605 1605
-- Name: pk_categoryId; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT "pk_categoryId" PRIMARY KEY (id);


--
-- TOC entry 1917 (class 2606 OID 41910)
-- Dependencies: 1608 1608
-- Name: question_new_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question_orig
    ADD CONSTRAINT question_new_pkey PRIMARY KEY (id);


--
-- TOC entry 1910 (class 2606 OID 41912)
-- Dependencies: 1603 1603
-- Name: question_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_pkey PRIMARY KEY (id);


--
-- TOC entry 1920 (class 2606 OID 41914)
-- Dependencies: 1609 1609
-- Name: roles_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 1929 (class 2606 OID 41916)
-- Dependencies: 1612 1612
-- Name: skip_pattern_parts_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY skip_pattern_parts
    ADD CONSTRAINT skip_pattern_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 1927 (class 2606 OID 41918)
-- Dependencies: 1611 1611
-- Name: skip_pattern_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY skip_pattern
    ADD CONSTRAINT skip_pattern_pkey PRIMARY KEY (id);


--
-- TOC entry 1922 (class 2606 OID 41920)
-- Dependencies: 1610 1610
-- Name: unique_username; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY rpt_users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- TOC entry 1924 (class 2606 OID 41922)
-- Dependencies: 1610 1610
-- Name: users_pri_key; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY rpt_users
    ADD CONSTRAINT users_pri_key PRIMARY KEY (id);


--
-- TOC entry 1901 (class 1259 OID 41923)
-- Dependencies: 1599
-- Name: fki_fb_answer_question_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_answer_question_fk ON answer USING btree (question_id);


--
-- TOC entry 1904 (class 1259 OID 41924)
-- Dependencies: 1601
-- Name: fki_fb_form_module_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_form_module_fk ON form USING btree (module_id);


--
-- TOC entry 1915 (class 1259 OID 41925)
-- Dependencies: 1608
-- Name: fki_fb_question_form_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_question_form_fk ON question_orig USING btree (form_id);


--
-- TOC entry 1918 (class 1259 OID 41926)
-- Dependencies: 1608
-- Name: question_ts_data_idx; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX question_ts_data_idx ON question_orig USING gin (ts_data);


--
-- TOC entry 1925 (class 1259 OID 41927)
-- Dependencies: 1611 1611
-- Name: skip_pattern_parent_idx; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX skip_pattern_parent_idx ON skip_pattern USING btree (parent_id, parent_type);


--
-- TOC entry 1930 (class 2606 OID 41928)
-- Dependencies: 1610 1923 1601
-- Name: fb_form_author_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_author_user_fk FOREIGN KEY (author_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1934 (class 2606 OID 41933)
-- Dependencies: 1905 1601 1602
-- Name: fb_form_element_form_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form_element
    ADD CONSTRAINT fb_form_element_form_fk FOREIGN KEY (form_id) REFERENCES form(id) ON DELETE CASCADE;


--
-- TOC entry 1931 (class 2606 OID 41938)
-- Dependencies: 1923 1610 1601
-- Name: fb_form_last_updated_by_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_last_updated_by_user_fk FOREIGN KEY (last_updated_by_user_id) REFERENCES rpt_users(id) ON DELETE RESTRICT;


--
-- TOC entry 1932 (class 2606 OID 41943)
-- Dependencies: 1610 1601 1923
-- Name: fb_form_locked_by_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_locked_by_fk FOREIGN KEY (locked_by_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1933 (class 2606 OID 41948)
-- Dependencies: 1601 1913 1606
-- Name: fb_form_module_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_module_fk FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE CASCADE;


--
-- TOC entry 1935 (class 2606 OID 41953)
-- Dependencies: 1606 1923 1610
-- Name: fb_module_author_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY module
    ADD CONSTRAINT fb_module_author_user_fk FOREIGN KEY (author_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 1938 (class 2606 OID 41958)
-- Dependencies: 1905 1608 1601
-- Name: fb_question_form_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_orig
    ADD CONSTRAINT fb_question_form_fk FOREIGN KEY (form_id) REFERENCES form(id) ON DELETE CASCADE;


--
-- TOC entry 1936 (class 2606 OID 41963)
-- Dependencies: 1607 1605 1911
-- Name: fk_categoryId_question_categories; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_categries
    ADD CONSTRAINT "fk_categoryId_question_categories" FOREIGN KEY (category_id) REFERENCES category(id);


--
-- TOC entry 1937 (class 2606 OID 41988)
-- Dependencies: 1607 1907 1602
-- Name: fk_questionId_form_element_categories; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_categries
    ADD CONSTRAINT "fk_questionId_form_element_categories" FOREIGN KEY (question_id) REFERENCES form_element(id);


--
-- TOC entry 1939 (class 2606 OID 41973)
-- Dependencies: 1609 1919 1616
-- Name: fk_roleId_user_roles; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT "fk_roleId_user_roles" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;


--
-- TOC entry 1940 (class 2606 OID 41978)
-- Dependencies: 1610 1923 1616
-- Name: fk_userId_user_roles; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT "fk_userId_user_roles" FOREIGN KEY (user_id) REFERENCES rpt_users(id) ON DELETE CASCADE;


--
-- TOC entry 1943 (class 0 OID 0)
-- Dependencies: 8
-- Name: FormBuilder; Type: ACL; Schema: -; Owner: fbdev
--

REVOKE ALL ON SCHEMA "FormBuilder" FROM PUBLIC;
REVOKE ALL ON SCHEMA "FormBuilder" FROM fbdev;
GRANT ALL ON SCHEMA "FormBuilder" TO fbdev;
GRANT ALL ON SCHEMA "FormBuilder" TO PUBLIC;


-- Completed on 2011-03-08 10:42:36

--
-- PostgreSQL database dump complete
--

