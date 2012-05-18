--
-- PostgreSQL database dump
--

-- Started on 2010-09-23 11:48:35

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 10 (class 2615 OID 24989)
-- Name: FormBuilder; Type: SCHEMA; Schema: -; Owner: fbdev
--

CREATE SCHEMA "FormBuilder";


ALTER SCHEMA "FormBuilder" OWNER TO fbdev;

SET search_path = "FormBuilder", pg_catalog;

--
-- TOC entry 36 (class 1255 OID 24990)
-- Dependencies: 464 10
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
-- TOC entry 37 (class 1255 OID 24991)
-- Dependencies: 464 10
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
-- TOC entry 38 (class 1255 OID 24992)
-- Dependencies: 10 464
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
	SELECT * INTO q FROM "FormBuilder".question WHERE id = qid;

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

	UPDATE "FormBuilder".question set ts_data = data WHERE id = q.id;

	RETURN q.id;
end
$$;


ALTER FUNCTION "FormBuilder".refresh_question_ts_data(qid integer) OWNER TO fbdev;

--
-- TOC entry 39 (class 1255 OID 24993)
-- Dependencies: 10 464
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
-- TOC entry 1321 (class 3602 OID 24994)
-- Dependencies: 1289 10
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
-- TOC entry 1710 (class 1259 OID 24995)
-- Dependencies: 10
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
-- TOC entry 2057 (class 0 OID 0)
-- Dependencies: 1710
-- Name: GENERIC_ID_SEQ; Type: SEQUENCE SET; Schema: FormBuilder; Owner: fbdev
--

SELECT pg_catalog.setval('"GENERIC_ID_SEQ"', 3356, true);


--
-- TOC entry 1711 (class 1259 OID 24997)
-- Dependencies: 10
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
-- TOC entry 2058 (class 0 OID 0)
-- Dependencies: 1711
-- Name: RPT_USERS_SEQ; Type: SEQUENCE SET; Schema: FormBuilder; Owner: fbdev
--

SELECT pg_catalog.setval('"RPT_USERS_SEQ"', 17, true);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1712 (class 1259 OID 24999)
-- Dependencies: 10
-- Name: answer; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE answer (
    id bigint NOT NULL,
    type character varying(10) NOT NULL,
    description character varying(500),
    group_name character varying(25),
    question_id bigint NOT NULL,
    ord bigint NOT NULL,
    answer_column_heading character varying(200),
    display_style character varying(200),
    value_constraint character varying(100)
);


ALTER TABLE "FormBuilder".answer OWNER TO fbdev;

--
-- TOC entry 1713 (class 1259 OID 25005)
-- Dependencies: 10
-- Name: answer_value; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE answer_value (
    id bigint NOT NULL,
    short_name character varying(250) NOT NULL,
    value character varying(250) NOT NULL,
    answer_id bigint NOT NULL,
    description character varying(500),
    ord bigint NOT NULL,
    permanent_id character(36) NOT NULL
);


ALTER TABLE "FormBuilder".answer_value OWNER TO fbdev;

--
-- TOC entry 1714 (class 1259 OID 25008)
-- Dependencies: 10
-- Name: category; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE category (
    id bigint NOT NULL,
    name character varying(50),
    description character varying(300)
);


ALTER TABLE "FormBuilder".category OWNER TO fbdev;

--
-- TOC entry 1715 (class 1259 OID 25011)
-- Dependencies: 10
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
    last_updated_by_user_id bigint
);


ALTER TABLE "FormBuilder".form OWNER TO fbdev;

--
-- TOC entry 1716 (class 1259 OID 25014)
-- Dependencies: 2005 10
-- Name: module; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE module (
    id bigint NOT NULL,
    description character varying(100),
    release_date date,
    comments character varying(200),
    update_date timestamp with time zone NOT NULL,
    author_user_id bigint NOT NULL,
    status character varying(30) DEFAULT 'IN_PROGRESS'::character varying NOT NULL
);


ALTER TABLE "FormBuilder".module OWNER TO fbdev;

--
-- TOC entry 1717 (class 1259 OID 25018)
-- Dependencies: 10
-- Name: question; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question (
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
    cadsr_public_id bigint
);


ALTER TABLE "FormBuilder".question OWNER TO fbdev;

--
-- TOC entry 1718 (class 1259 OID 25024)
-- Dependencies: 10
-- Name: question_categries; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE question_categries (
    category_id bigint NOT NULL,
    question_id bigint NOT NULL
);


ALTER TABLE "FormBuilder".question_categries OWNER TO fbdev;

--
-- TOC entry 1719 (class 1259 OID 25027)
-- Dependencies: 10
-- Name: roles; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE roles (
    id bigint NOT NULL,
    name character varying(20)
);


ALTER TABLE "FormBuilder".roles OWNER TO fbdev;

--
-- TOC entry 1720 (class 1259 OID 25030)
-- Dependencies: 10
-- Name: rpt_users; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE rpt_users (
    id bigint NOT NULL,
    username character varying(25),
    password character varying(130),
    created_date date,
    email_addr character varying(25)
);


ALTER TABLE "FormBuilder".rpt_users OWNER TO fbdev;

--
-- TOC entry 1721 (class 1259 OID 25033)
-- Dependencies: 10
-- Name: skip_pattern; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE skip_pattern (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    rule_value character varying(50) NOT NULL,
    description character varying(2000) NOT NULL,
    parent_type character varying(20) NOT NULL,
    answer_value_id character(36) NOT NULL
);


ALTER TABLE "FormBuilder".skip_pattern OWNER TO fbdev;

--
-- TOC entry 1723 (class 1259 OID 25242)
-- Dependencies: 1813 10
-- Name: skip_pattern_answer_value_vw; Type: VIEW; Schema: FormBuilder; Owner: fbdev
--

CREATE VIEW skip_pattern_answer_value_vw AS
    SELECT s.id, CASE s.parent_type WHEN 'questionSkip'::text THEN s.parent_id ELSE NULL::bigint END AS question_id, CASE s.parent_type WHEN 'formSkip'::text THEN s.parent_id ELSE NULL::bigint END AS form_id, s.answer_value_id AS skip_item, av.value AS skip_item_value, a.question_id AS skip_item_question, q.form_id AS skip_item_form FROM skip_pattern s, answer_value av, answer a, question q WHERE (((s.answer_value_id = av.permanent_id) AND (av.answer_id = a.id)) AND (q.id = a.question_id));


ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;

--
-- TOC entry 1722 (class 1259 OID 25040)
-- Dependencies: 10
-- Name: user_roles; Type: TABLE; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE TABLE user_roles (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL
);


ALTER TABLE "FormBuilder".user_roles OWNER TO fbdev;

--
-- TOC entry 2043 (class 0 OID 24999)
-- Dependencies: 1712
-- Data for Name: answer; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58326, 'RADIO', 'Less than 2.0 centimeters', '', 58269, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58779, 'RADIO', 'Yes', '', 58724, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69292, 'TEXT', 'Email:', '', 69236, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57854, 'TEXT', 'First Name:', '', 57806, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61915, 'TEXT', 'Street Address:', '', 60841, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58783, 'DROPDOWN', 'Select One', '', 58728, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7685, 'DROPDOWN', 'Select select your state ', '', 1536, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7688, 'TEXT', 'Email:', '', 1545, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69282, 'TEXT', 'Please specify "Other Race"', '', 69225, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57860, 'DROPDOWN', 'Select One', '', 57812, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57856, 'RADIO', 'Less than high school', '', 57808, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57855, 'RADIO', 'Female', '', 57807, 1, '', 'Horizontal', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57861, 'TEXT', 'Please Specify "Other" occupation :', '', 57813, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69287, 'TEXT', 'Last Name:', '', 69231, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16085, 'RADIO', 'Activity', 'Activity', 3216, 0, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69297, 'RADIO', 'Family member', '', 69241, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58781, 'RADIO', 'Yes', '', 58726, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57863, 'TEXT', 'Other Asian', '', 57815, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58765, 'RADIO', 'Yes', '', 58710, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58773, 'RADIO', 'Yes', '', 58718, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58768, 'RADIO', 'Yes', '', 58713, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58769, 'DROPDOWN', 'Select One', '', 58714, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58784, 'RADIO', 'yes', '', 58729, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57412, 'RADIO', 'I have never had a period', '', 57365, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58771, 'DROPDOWN', 'Select One', '', 58716, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58766, 'RADIO', 'Yes', '', 58711, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58772, 'RADIO', 'Yes', '', 58717, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58767, 'RADIO', 'FISH', '', 58712, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58777, 'RADIO', 'Less than 1 year', '', 58722, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58778, 'RADIO', 'Yes', '', 58723, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58786, 'TEXT', 'Please enter year(YYYY)', '', 58731, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58788, 'RADIO', 'My periods stopped naturally.', '', 58733, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58780, 'RADIO', 'Yes', '', 58725, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58785, 'RADIO', 'I have regular menstrual periods (I am premenopausal).', '', 58730, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58789, 'TEXT', 'Please specity reason', '', 58734, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58787, 'RADIO', 'Yes', '', 58732, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58790, 'RADIO', 'Yes, I have taken menopausal hormone therapy in the past, but no longer do', '', 58735, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58796, 'RADIO', 'Yes, I had a surgery to remove part of my uterus.', '', 58741, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58795, 'RADIO', 'I have taken an estrogen.', '', 58740, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59601, 'TEXT', 'Please enter year (YYYY)', '', 58746, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58798, 'TEXT', 'Please enter year (YYYY)', '', 58743, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59600, 'RADIO', 'Yes', '', 58745, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58799, 'RADIO', 'Yes, I have had surgery to remove part of an ovary.', '', 58744, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58797, 'RADIO', 'yes', '', 58742, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61922, 'DROPDOWN', 'Select select your state ', '', 60848, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69283, 'RADIO', 'No, not Spanish, Hispanic, Latino', '', 69226, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61916, 'TEXT', 'City:', '', 60842, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61919, 'TEXT', 'Email Address:', '', 60845, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69288, 'TEXT', 'Middle Initial:', '', 69232, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59906, 'DROPDOWN', 'Height:Feet:', '', 59856, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69293, 'TEXT', 'Street Address:', '', 69237, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59909, 'RADIO', 'Yes', '', 59859, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12096, 'RADIO', 'Just About anytime', '', 2401, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59908, 'RADIO', 'Yes, previously ', '', 59858, 1, '', 'Horizontal', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69298, 'TEXT', 'Other Specify:', '', 69242, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59915, 'CHECKBOX', 'Red meat', '', 59861, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59917, 'RADIO', 'Yes', '', 59863, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59918, 'RADIO', 'Heterosexual', '', 59864, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59916, 'RADIO', '1', '', 59862, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59907, 'DROPDOWN', '82', '', 59857, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58301, 'RADIO', 'In Situ (DCIS)', '', 58253, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61920, 'NUMBER', 'Zip:', '', 60846, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61923, 'NUMBER', 'Fax Number (Optional)( XXX-XXX-XXXX e.g. 978-902-5321) :', '', 60849, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69289, 'TEXT', 'Phone :', '', 69233, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69294, 'TEXT', 'City:', '', 69238, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69299, 'DROPDOWN', 'Please select state:', '', 69243, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69284, 'TEXT', 'Specify "Other Spanish, Hispanic, Latino"', '', 69227, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58761, 'CHECKBOX', 'In Situ (DCIS)', '', 58706, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12170, 'TEXT', 'Nodes are positive:', '', 2433, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16086, 'RADIO', 'Vigorous activities, such as running, lifting heavy objects, participating in strenuous sports', 'Vigorous', 3216, 1, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58763, 'RADIO', 'Yes', '', 58708, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58762, 'RADIO', 'Yes', '', 58707, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58776, 'RADIO', 'Yes, I used birth control pills in the past', '', 58721, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58782, 'RADIO', '1', '', 58727, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12279, 'RADIO', '1', '', 2462, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9524, 'RADIO', 'Caramel', '12', 1901, 11, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57864, 'RADIO', 'Much better than a year ago', '', 57817, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59939, 'RADIO', 'Yes', '', 59866, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7633, 'TEXT', 'Last Name:', '', 1534, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7686, 'NUMBER', 'Zip:', '', 1543, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58310, 'RADIO', 'Activity', 'Activity', 58259, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58320, 'RADIO', 'Bathing and dressing yourself', 'Bathing', 58259, 10, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12191, 'CHECKBOX', 'Spine', '', 2439, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7632, 'TEXT', 'First Name:', '', 1533, 1, '', 'Short', '');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57853, 'TEXT', 'Last Name:', '', 57805, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58300, 'TEXT', 'MM/DD/YYYY :', '', 58251, 0, '', 'Short', '');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69285, 'TEXT', 'Title (optional):', '', 69229, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61914, 'TEXT', 'Middle Initial:', '', 60840, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (70000, 'DROPDOWN', 'Height-Inches:', '', 69245, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69290, 'TEXT', 'Fax (Optional):', '', 69234, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59910, 'RADIO', 'Liquor', 'liq', 59860, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59911, 'RADIO', 'Bear(Cans/ Bottles)', 'bear', 59860, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59912, 'RADIO', 'Wine (Glasses)', 'wine', 59860, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59913, 'RADIO', 'Hard Liquor (ounces  )', 'liquor', 59860, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59914, 'RADIO', 'Other alcoholic beverage /week', 'other', 59860, 5, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7955, 'TEXT', 'Frequency', '', 1590, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59919, 'RADIO', 'Additional Concerns', 'concerns', 59865, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59920, 'RADIO', 'I have hot flashes', 'hot flashes', 59865, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59921, 'RADIO', 'I have cold sweats.', 'cold sweats', 59865, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60586, 'RADIO', 'Yes', '', 59869, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59922, 'RADIO', 'I have night sweats.', 'night sweats', 59865, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59923, 'RADIO', 'I have vaginal discharge.', 'vaginal discharge', 59865, 5, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59924, 'RADIO', 'I have vaginal itching/irritation.', 'vaginal itching/', 59865, 6, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59925, 'RADIO', 'I have vaginal bleeding or spotting.', 'vaginal bleeding ', 59865, 7, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59926, 'RADIO', 'I have vaginal dryness.', 'vaginal dryness', 59865, 8, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59940, 'RADIO', 'Bee Pollen', 'BP', 59867, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (10863, 'TEXT', 'Other toppings', '', 2186, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16087, 'RADIO', 'Moderate activities, such as moving a table, pushing a vacuum cleaner, bowling or golf', 'Moderate', 3216, 2, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59927, 'RADIO', 'I have pain or discomfort with intercourse.', ' pain ', 59865, 9, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59928, 'RADIO', 'I have lost interest in sex.', ' lost interest ', 59865, 10, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59929, 'RADIO', 'I have gained weight.', 'gained weight', 59865, 11, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59930, 'RADIO', 'I feel light headed and dizzy.  	', 'light headed ', 59865, 12, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59934, 'RADIO', 'I feel bloated.', 'bloated.', 59865, 16, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59935, 'RADIO', 'I have breast sensitivity/tenderness.', 'breast sensitivity', 59865, 17, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59931, 'RADIO', 'I have been vomiting.', 'vomiting', 59865, 13, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59932, 'RADIO', 'I have diarrhea.', 'diarrhea.', 59865, 14, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59933, 'RADIO', 'I get headaches.', 'headaches.', 59865, 15, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59936, 'RADIO', 'I have mood swings.', 'mood swings', 59865, 18, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59937, 'RADIO', 'I am irritable.', 'irritable.', 59865, 19, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59938, 'RADIO', 'I have pain in my joints', 'joints pain', 59865, 20, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69286, 'TEXT', 'First Name:', '', 69230, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69291, 'TEXT', 'Institution Name (Optional):', '', 69235, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69296, 'TEXT', 'Zip:', '', 69240, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (69281, 'TEXT', 'Please enter "Other Pacific Islander"', '', 69224, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16088, 'RADIO', 'Lifting or carrying groceries', 'Lifting', 3216, 3, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16089, 'RADIO', 'Climbing several flights of stairs', 'some Stairs', 3216, 4, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12320, 'RADIO', 'Yes, I have had surgery to remove part of an ovary.', '', 2463, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59941, 'RADIO', 'Black Cohosh', 'BC', 59867, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59942, 'RADIO', 'Blue Cohosh', 'BCo', 59867, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59943, 'RADIO', 'Chaste Berries (Vitex Agnus Cactii)', 'CB', 59867, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16100, 'RADIO', 'Climbing one flight of stairs', 'Climbing Stairs', 3216, 5, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16101, 'RADIO', 'Bending, kneeling, stooping', 'Stooping', 3216, 6, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16102, 'RADIO', 'Walking more than one mile', 'More then 1 mile', 3216, 7, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16103, 'RADIO', 'Walking several blocks', 'Several Blocks', 3216, 8, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16104, 'RADIO', 'Walking one block', 'Walking', 3216, 9, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16115, 'RADIO', 'Bathing and dressing yourself', 'Bathing', 3216, 10, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (11912, 'RADIO', 'qqq', '', 2385, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7634, 'TEXT', 'Street Address:', '', 1535, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60553, 'RADIO', 'Lachesis', 'Las', 59867, 13, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7630, 'TEXT', 'Please specify "Other":', '', 1525, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7589, 'CHECKBOX', 'African-American, Black', '', 1524, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (8783, 'RADIO', 'On your back ', '', 1762, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7347, 'DROPDOWN', 'Don''t know', '', 1474, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7349, 'DROPDOWN', 'Don''t know', '', 1485, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12193, 'RADIO', 'Yes, I have taken menopausal hormone therapy in the past, but no longer do', '', 2451, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12277, 'RADIO', 'I have never had a period', '', 2458, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60554, 'RADIO', 'Licorice Root', 'LR', 59867, 14, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60555, 'RADIO', 'Mother Wort', 'MW', 59867, 15, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7474, 'DROPDOWN', 'Female', '', 1515, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7585, 'TEXT', 'Age:', '', 1516, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7586, 'TEXT', 'City:', '', 1518, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7588, 'TEXT', 'Country:', '', 1520, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57862, 'CHECKBOX', 'White / Caucasian', '', 57814, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58313, 'RADIO', 'Lifting or carrying groceries', 'Lifting', 58259, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12418, 'RADIO', 'Yes', '', 2493, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (10861, 'RADIO', 'No', '', 2140, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60585, 'TEXT', 'Please specify', '', 59868, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12171, 'RADIO', 'Estrogen receptor Positive', 'ER', 2435, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12172, 'RADIO', 'Progesterone receptor', 'PR', 2435, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12173, 'RADIO', 'HER2/neu', 'HER2', 2435, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12174, 'RADIO', 'eGFR', 'eGFR', 2435, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7346, 'TEXT', 'Please specify "Other"', '', 1472, 0, '', 'Short', '');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61924, 'DATE', 'Date of Birth (mm/dd/yyyy e.g. 07/22/1950):', '', 62250, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (61921, 'NUMBER', 'Phone Number (XXX-XXX-XXXX e.g. 978-902-5321)', '', 60847, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12097, 'RADIO', 'Just About anytime', '', 2399, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (11171, 'TEXT', 'test', '', 2236, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60556, 'RADIO', 'Nux Vomica', 'NV', 59867, 16, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7345, 'CHECKBOX', 'Breast cancer patient or survivor', '', 1468, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (11480, 'RADIO', 'Just About anytime', '', 2222, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (7631, 'DROPDOWN', 'Grade 1 through 8', '', 1527, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60557, 'RADIO', 'Progesterone Topical Cream (Wild Mexican Yam)', 'PTC', 59867, 17, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60558, 'RADIO', 'Pulsatilla', 'Pul', 59867, 18, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60559, 'RADIO', 'Royal Jelly', 'RJ', 59867, 19, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60577, 'RADIO', 'Sage Tea', 'ST', 59867, 20, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60578, 'RADIO', 'Sarsaparilla', 'Sar', 59867, 21, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60579, 'RADIO', 'Sepia', 'Sep', 59867, 22, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60580, 'RADIO', 'St. John''s Wort ', 'St. JW', 59867, 23, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12321, 'TEXT', 'Please enter year (YYYY)', '', 2466, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59944, 'RADIO', 'Chickweed Tincture', 'CT', 59867, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59945, 'RADIO', 'Dong Quai ((Tong Kwai or Chinese Angelica)', 'DQ', 59867, 5, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59946, 'RADIO', 'Echinacea', 'Ech', 59867, 6, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59947, 'RADIO', 'Evening Primrose Oil', 'EPO', 59867, 7, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59948, 'RADIO', 'False Unicorn', 'FU', 59867, 8, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (59949, 'RADIO', 'Garlic', 'Gr', 59867, 9, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60550, 'RADIO', 'Gingko Biloba', 'GB', 59867, 10, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60551, 'RADIO', 'Ginseng', 'Gin', 59867, 11, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60552, 'RADIO', 'Herbal Tea used as a Remedy', 'HT', 59867, 12, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60581, 'RADIO', 'Valeriana', 'Val', 59867, 24, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60582, 'RADIO', 'Wild Yam Root', 'WYR', 59867, 25, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60583, 'RADIO', 'Shark Cartilage', 'SC', 59867, 26, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (8784, 'DROPDOWN', 'Please select one:', '', 1764, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (60584, 'RADIO', 'Other', 'Oth', 59867, 27, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (8835, 'RADIO', 'was it in your Left breast', '', 1766, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (8836, 'DROPDOWN', 'Please Select one:', '', 1769, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (8837, 'RADIO', 'was it in your Left breast ', '', 1771, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (11652, 'RADIO', 'Any brand is OK', '', 2332, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (8838, 'TEXT', '"Year":', '', 1773, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9408, 'RADIO', 'Chocolate - dark', '1', 1901, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12099, 'RADIO', 'Chocolate - dark', '1', 2404, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12125, 'RADIO', 'Vanilla', '2', 2404, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12126, 'RADIO', 'Chocolate swirl', '3', 2404, 2, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12127, 'RADIO', 'Peppermint', '4', 2404, 3, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12128, 'RADIO', 'Rocky road', '5', 2404, 4, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12129, 'RADIO', 'Fruity flavors', '6', 2404, 5, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12135, 'RADIO', 'Peanut flavors', '7', 2404, 6, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12136, 'RADIO', 'Chocolate - light', '8', 2404, 7, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12137, 'RADIO', 'French vanilla', '9', 2404, 8, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12138, 'RADIO', 'Chocolate chip', '10', 2404, 9, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12139, 'RADIO', 'Strawberry', '11', 2404, 10, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12145, 'RADIO', 'Caramel', '12', 2404, 11, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12146, 'RADIO', 'Pistachio', '13', 2404, 12, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12147, 'RADIO', 'Most flavors with nuts', '14', 2404, 13, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12148, 'RADIO', 'Other Flavors', '99', 2404, 14, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12278, 'RADIO', 'Yes', '', 2460, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9409, 'RADIO', 'Vanilla', '2', 1901, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9510, 'RADIO', 'Chocolate swirl', '3', 1901, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12190, 'RADIO', 'Yes', '', 2437, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9511, 'RADIO', 'Peppermint', '4', 1901, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (11096, 'RADIO', 'Just About anytime', '', 2221, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13203, 'RADIO', 'Yes', '', 2648, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (10718, 'CHECKBOX', 'Hot chocolate', '', 2147, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (10864, 'RADIO', 'Any brand is OK', '', 2189, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12632, 'CHECKBOX', 'In Situ (DCIS)', '', 2528, 1, NULL, 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12633, 'RADIO', 'Yes', '', 2530, 1, NULL, 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12634, 'RADIO', 'Yes', '', 2531, 1, NULL, 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (70001, 'DROPDOWN', 'Age of Diagnosis', '', 69246, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13349, 'CHECKBOX', 'Testing', '', 2685, 2, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13625, 'CHECKBOX', 'Infertility Etiology Type', NULL, 2724, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58319, 'RADIO', 'Walking one block', 'Walking', 58259, 9, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13265, 'NUMBER', 'If you had this blood test, fill in Number of Times', '', 2652, 0, '', '', 'min:1;max:50');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13770, 'DROPDOWN', 'No', '', 2753, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13662, 'CHECKBOX', 'In Situ (DCIS)', '', 2738, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (10684, 'DROPDOWN', 'testing', '', 2141, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9512, 'RADIO', 'Rocky road', '5', 1901, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9513, 'RADIO', 'Fruity flavors', '6', 1901, 5, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9514, 'RADIO', 'Peanut flavors', '7', 1901, 6, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9520, 'RADIO', 'Chocolate - light', '8', 1901, 7, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9521, 'RADIO', 'French vanilla', '9', 1901, 8, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14309, 'TEXT', 'Weight Diet History Questionnaire Descriptive Text', NULL, 2878, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9522, 'RADIO', 'Chocolate chip', '10', 1901, 9, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9523, 'RADIO', 'Strawberry', '11', 1901, 10, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15722, 'RADIO', '1-2 times per week', '', 3146, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14855, 'TEXT', 'Infertility Treatment Descriptive Text', NULL, 2970, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14857, 'RADIO', 'Common Toxicity Criteria Adverse Event Infertility Grade', NULL, 2974, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15060, 'TEXT', 'Infertility Treatment Descriptive Text', NULL, 3011, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15061, 'RADIO', 'Common Toxicity Criteria Adverse Event Infertility Grade', NULL, 3014, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12098, 'RADIO', 'Just About anytime', '', 2323, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13574, 'RADIO', 'Ovarian tissue banking', '', 2722, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14306, 'RADIO', 'Person Dietary Supplements Use Frequency Number', NULL, 2875, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15062, 'TEXT', 'Person Known Infertility Reason Assessment Description Text', NULL, 3015, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15279, 'RADIO', 'Yes', '', 3059, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15457, 'RADIO', 'aaa', '', 3111, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58311, 'RADIO', 'Vigorous activities, such as running, lifting heavy objects, participating in strenuous sports', 'Vigorous', 58259, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58312, 'RADIO', 'Moderate activities, such as moving a table, pushing a vacuum cleaner, bowling or golf', 'Moderate', 58259, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58314, 'RADIO', 'Climbing several flights of stairs', 'some Stairs', 58259, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (57865, 'TEXT', 'Breast Cancer cause', '', 57822, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58315, 'RADIO', 'Climbing one flight of stairs', 'Climbing Stairs', 58259, 5, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58316, 'RADIO', 'Bending, kneeling, stooping', 'Stooping', 58259, 6, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58317, 'RADIO', 'Walking more than one mile', 'More then 1 mile', 58259, 7, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58318, 'RADIO', 'Walking several blocks', 'Several Blocks', 58259, 8, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13032, 'RADIO', 'Yes', '', 2609, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15458, 'RADIO', 'sss', '', 3111, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13033, 'RADIO', 'No', '', 2610, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15459, 'RADIO', 'ddd', '', 3111, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (12948, 'RADIO', 'Endometriosis', '', 2594, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13807, 'RADIO', '2', '', 2768, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14166, 'RADIO', 'Special Diet Ind', NULL, 2837, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15306, 'RADIO', 'Any brand is OK', '', 3063, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13809, 'TEXT', 'answer', '', 2781, 1, '', 'Short', '5');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13915, 'TEXT', 'Answer', '', 2782, 1, '', 'Short', '5');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15305, 'RADIO', 'Yes', '', 3060, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15307, 'TEXT', 'Please specify other:-', '', 3067, 1, '', 'Short', '12');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15308, 'TEXT', 'Local Ice-cream flavor:-', '', 3069, 1, '', 'Long', '13');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15570, 'RADIO', 'fff', '', 3111, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14167, 'RADIO', '100= Full diet (no restrictions)', '', 2839, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15456, 'RADIO', 'test 1', '', 3110, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15385, 'CHECKBOX', 'Treatment History', '', 3076, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14307, 'DATE', 'Diet Restart Date', NULL, 2876, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14308, 'RADIO', 'Dental Therapy Patient Diet Dissatisfaction Oral Health Impact Profile Physical Examination Scale', NULL, 2877, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14400, 'RADIO', 'RTOG Diet Intake Performance Scale', NULL, 2879, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14401, 'DATE', 'Special Diet Stop Date', NULL, 2882, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (14402, 'RADIO', 'Special Diet Start Date', NULL, 2884, 1, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15404, 'CHECKBOX', 'Testing', '', 3089, 0, NULL, 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (13771, 'CHECKBOX', 'In vitro fertilization', '', 2756, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15455, 'TEXT', 'test', '', 3090, 1, '', 'Short', '');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15572, 'RADIO', '1', '', 3121, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15723, 'RADIO', 'Walking', '', 3150, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15724, 'RADIO', 'Running', '', 3150, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15760, 'RADIO', 'Yoga', '', 3150, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15761, 'RADIO', 'Biking', '', 3150, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15790, 'RADIO', 'Any brand is OK', '', 3157, 1, NULL, 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15403, 'MONTHYEAR', 'enter here', '', 3085, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15815, 'DATE', 'Date', '', 3162, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16036, 'RADIO', 'yes', 'y', 3208, 1, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16037, 'RADIO', 'no', 'n', 3208, 2, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16038, 'DROPDOWN', 'search question', '', 3209, 1, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15832, 'RADIO', 'yes', 'y', 3204, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15833, 'RADIO', 'no', 'n', 3204, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (15834, 'DROPDOWN', 'search question', '', 3205, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9530, 'RADIO', 'Pistachio', '13', 1901, 12, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9531, 'RADIO', 'Most flavors with nuts', '14', 1901, 13, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (9532, 'RADIO', 'Other Flavors', '99', 1901, 14, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16567, 'TEXT', 'MM/DD/YYYY :', '', 3319, 0, NULL, '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16568, 'RADIO', 'Yes', '', 3322, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16172, 'RADIO', 'None', '', 3239, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16173, 'RADIO', 'None', '', 3240, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16640, 'RADIO', 'None', '', 3327, 1, NULL, 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16641, 'RADIO', 'No', '', 3330, 1, NULL, 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16642, 'RADIO', 'I sometimes (1-2 times last week) did physical things in my free time (e.g. played sports, went running, swimming, bike riding, did aerobics). ', '', 3331, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16643, 'RADIO', 'Male', '', 3335, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16220, 'RADIO', 'All or most of my free time was spent doing things that involve little physical effort.', '', 3243, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16566, 'RADIO', 'None', '', 3315, 1, NULL, 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16644, 'DROPDOWN', 'Country', '', 3337, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16221, 'RADIO', 'No', '', 3245, 1, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16222, 'TEXT', 'If Yes, what prevented you?', '', 3247, 0, '', 'Short', '12');
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16569, 'CHECKBOX', 'No Treatment', '', 3323, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (58329, 'RADIO', 'yes', '', 58268, 0, '', 'Vertical', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16725, 'RADIO', 'Diabetes Mellitus History Ind-3', NULL, 3344, 0, NULL, NULL, NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16726, 'RADIO', 'Rock Climbing', '1', 3349, 0, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16727, 'RADIO', 'Rowing/canoeing', '2', 3349, 1, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16728, 'RADIO', 'Tennis/squash', '3', 3349, 2, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16729, 'RADIO', 'Stair climber (or other similar equipment)', '4', 3349, 3, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16760, 'RADIO', 'Walking for exercise', '5', 3349, 4, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16761, 'RADIO', 'Heavy yard work', '6', 3349, 5, '', '', NULL);
INSERT INTO answer (id, type, description, group_name, question_id, ord, answer_column_heading, display_style, value_constraint) VALUES (16780, 'RADIO', 'v', '', 3355, 0, '', '', NULL);


--
-- TOC entry 2044 (class 0 OID 25005)
-- Dependencies: 1713
-- Data for Name: answer_value; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71946, '', '', 57853, 'Last Name:', 1, 'd453f312-b1cc-487c-8153-1566c85b7968');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72498, '', 'feet', 59906, 'Height:Feet:', 1, '656084dc-6c39-45eb-a55c-82c67ff381a8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72499, '', '3', 59906, '3', 2, 'c5b8b425-7931-44ae-9edc-b6957075e758');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60129, '', 'meat', 59915, 'Red meat', 1, '7c168ffa-700b-48a8-8eba-63afb639a6fc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60130, '', 'poultry', 59915, 'Poultry', 2, '3c81b039-5ac7-4715-914f-7aa79e330cef');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59185, '', 'yes', 58772, 'Yes', 1, '6559a6ee-ed5a-4b2c-8ee9-3fa7822e368e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59186, '', 'no', 58772, 'No', 2, '238286ca-916f-49cc-bdce-1ad034b728c8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (58594, '', '2.0 cm', 58326, 'Less than 2.0 centimeters', 1, '3f2b1926-9900-475c-ab69-810b58314973');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (58595, '', '2.0-5.0', 58326, '2.0-5.0 centimeters', 2, '682b6867-61b3-41a3-8726-ceb3b240a490');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (58596, '', '5.0>', 58326, 'Over 5.0 centimeters', 3, '6c4183e8-6c1e-4df3-98f8-a955bc590e78');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (58597, '', 'no surgery', 58326, 'I haven''t had surgery yet', 4, '9413c849-ed11-4193-9352-1703be3ba55b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (58598, '', 'not remember', 58326, 'I don''t know/I can''t remember', 5, '34db7610-e8bb-4b34-bd52-81a72b4f48c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72550, '', '4', 59906, '4', 3, '025e0f06-81e2-460e-8fa0-5827eb4777ea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (58599, '', 'n/a', 58326, 'I''d rather not say', 6, 'ebc2fb28-441b-45f3-a395-697b1b5d1306');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59187, '', 'DR', 58772, 'I don''t know/I can''t remember', 3, '50d64ee9-1e2a-473a-af31-e3bf8839e5e4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59188, '', 'n/a', 58772, ' I''d rather not say', 4, 'fde4e823-9798-4788-8bca-075ebd8284de');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60131, '', 'fish', 59915, 'Fish/Shellfish', 3, '2bd43158-a83e-4111-a2fe-9b4224b98335');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17852, '', 'back', 8783, 'On your back ', 1, '1b31103c-e655-4336-a1ed-af980f22108b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17853, '', 'front', 8783, 'On your front ', 2, '59b8df17-05e3-45fa-80fa-a7a2030ecb68');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17854, '', 'left side', 8783, 'On your left side', 3, 'fb921254-05b3-4d08-be04-144e0c210bf5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17855, '', 'right side', 8783, 'On your right side', 4, 'ee10a68b-cb5b-46da-944b-0aff262635cf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60132, '', 'pork', 59915, 'Pork', 4, '9ad3db62-b687-435c-93a1-990b47f9de90');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60133, '', 'eggs', 59915, 'Eggs', 5, '1e21f7a8-87b6-416f-b5b4-c84462d88579');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60134, '', 'dairy', 59915, 'Milk, cheese and other dairy products', 6, 'f1f39ec5-6146-4f2a-9aef-f3cbae887cb5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60135, '', 'veg', 59915, 'Vegetables', 7, '9e2a021b-98e3-49ee-981d-592cb24c8031');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70932, '', '81', 59907, '81', 100, '8c64007a-cfa4-4906-8ed9-370e4385ab5a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70933, '', '82', 59907, '82', 101, '783bcce3-7ded-4a0f-b06e-6ffba37ab147');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70934, '', '83', 59907, '83', 102, '45eaa1e8-2d03-4153-b85f-4f70da40da3d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70935, '', '84', 59907, '84', 103, '23dd3469-2739-4afa-bfff-5f77f539c2d4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70936, '', '85', 59907, '85', 104, '6133ecf9-3817-4aa3-a713-102acb723bde');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70937, '', '86', 59907, '86', 105, '6eba9e9a-7d89-4a76-a24a-6cf4616ba176');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69839, '', '', 69284, 'Specify "Other Spanish, Hispanic, Latino"', 1, 'a595534d-dab9-4740-acdc-3e00c3f6af4d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72551, '', '5', 59906, '5', 4, 'bd5c2a71-b389-4416-8f2b-e0b2ad61fc11');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72552, '', '6', 59906, '6', 5, '9f83b362-554a-4817-84ef-7f6c16233381');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70938, '', '87', 59907, '87', 106, '083f4f2c-dc45-4cc5-8214-e3000c93428e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72553, '', '7', 59906, '7', 6, 'c3984491-94ba-40d0-b5bd-b70f308e8dc7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72554, '', 'NR', 59906, 'Not Reported', 7, '4f6d3ee9-d487-49d9-9d4f-53808fc5c08b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17856, '', '999', 8783, ' I''m not sure ', 5, '199992e5-bd1c-4066-ab99-48fe44e74d1d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71947, '', '', 57854, 'First Name:', 1, '8450e6c0-a0d2-41e7-9fd9-f6ea910aabfa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70939, '', '88', 59907, '88', 107, '1eb5e2a2-5925-4fc3-8333-7a8a2706c886');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70940, '', '89', 59907, '89', 108, '7da1e6ed-675c-4940-93eb-21f48ae508af');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59346, '', 'never', 57412, 'I have never had a period', 1, 'e5f33195-8276-4344-bec8-70f051fbd4c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23313, '', '1', 11652, 'Any brand is OK', 1, '6efb0547-9bab-42d5-857d-0ca86b3e0737');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70941, '', '90', 59907, '90', 109, '9d4cb4a5-1032-406c-94bb-e8d2dfb5bfcd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72485, '', 'inch', 70000, 'Height-Inches:', 1, '0f620fec-a4a8-4c7c-9ce5-a78377fb4cd0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59347, '', '<10', 57412, 'Under age 10', 2, '380b9b31-cb34-48d6-9400-74974ed07bcf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59348, '', '10', 57412, '10', 3, 'f5b43c62-d38a-47ce-8a39-f77902c39df0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60136, '', 'fruits', 59915, 'Fruits', 8, 'a1b19fc6-24d6-4012-9fd5-65281838e88e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60137, '', 'n/a', 59915, 'I''d rather not say', 9, '134bfdcb-41b7-4697-aea5-c09163a840eb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70942, '', '91', 59907, '91', 110, '21ac6979-bf5c-438c-b666-0657b315046d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70943, '', '92', 59907, '92', 111, '5f2d2344-3d50-4057-b932-0444ba58bb36');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70944, '', '93', 59907, '93', 112, '68ad44cd-f7ef-40ec-b4c5-ee2f26cf5e70');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70945, '', '94', 59907, '94', 113, '509149dc-6214-41b0-a6cc-4e5e3d8e23f8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70946, '', '95', 59907, '95', 114, '4c5a50c0-d80a-4e3c-bdad-b91a5dbcc559');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72486, '', '1', 70000, '1', 2, '773a784a-8f4f-4b95-a31e-49bc50992450');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72487, '', '2', 70000, '2', 3, '7dbe63ec-6bf8-4ae7-84b9-91b0737af6a4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72488, '', '3', 70000, '3', 4, '35b5e472-8c10-4bd6-82ff-94b8ab3cd91c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72489, '', '4', 70000, '4', 5, 'b560d8f7-c96d-4d41-bfc1-2f85fc7b92fa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23314, '', '2', 11652, 'Breyers', 2, '3d2fcdac-1359-4c0e-8c3c-b3e228ae67e3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72490, '', '5', 70000, '5', 6, '76b1c9fd-61dd-45ea-99d7-8190235fcb0b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (58169, '', '', 57865, 'Breast Cancer cause', 1, 'c4ca20c7-cfce-4e43-ad0b-8e0710529c56');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72491, '', '6', 70000, '6', 7, 'dbac5421-e892-4ec6-a4b5-ed578578bf43');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72492, '', '7', 70000, '7', 8, '0a0e3e0b-0641-4305-a9a6-df64a25e2e28');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72493, '', '8', 70000, '8', 9, '13655d19-3524-4a18-b385-fb844049807d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15315, '', '', 7633, 'Last Name:', 1, '56fc4fa2-47cd-4015-83ca-850b7dbdd5d6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70947, '', '96', 59907, '96', 115, '8092f324-c380-4e64-a710-1be0c2aac581');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70948, '', '97', 59907, '97', 116, '5dd2a20f-1a6c-471d-83f9-d57f09c630ae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72494, '', '9', 70000, '9', 10, '2acc3da2-2fc3-40c7-bae7-9f9e3ab37cfa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72495, '', '10', 70000, '10', 11, 'dbd5a64a-861f-497d-9d99-ebbf682a44e3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72496, '', '11', 70000, '11', 12, '8c6fef8b-0854-4e66-af72-85b2b86f7976');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72497, '', 'nr', 70000, 'Not reported', 13, '033c4327-0943-4cdb-9555-5489e71bc17b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (70949, '', '98', 59907, '98', 117, '98e4a68b-8774-4a72-a79c-a5bcd374d785');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71400, '', '99', 59907, '99', 118, '0d3d25c7-a2f2-40b6-b12b-208177684a02');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71401, '', '100', 59907, '100', 119, '7c134666-b991-402c-a9ba-1e86a4b0107e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59349, '', '11', 57412, '11', 4, '6d66ed2b-d7c2-489f-a4a9-794b2e6c53d7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59066, '', 'yes', 58766, 'Yes', 1, 'c5caae0d-5dbf-49b4-8ad6-b7e3ced43ed9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59067, '', 'no', 58766, 'No', 2, '3cfb3693-d614-40d7-a8bd-f8e4e3140021');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59068, '', 'n tested', 58766, 'Not Tested', 3, 'f2259aa2-2bb1-427d-9e47-6bb344e20a9a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59350, '', '12', 57412, '12', 5, '52b62d96-863a-4444-b8cd-a12fc74e6bec');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59351, '', '13', 57412, '13', 6, '2e1beb44-3762-42b8-9a65-69975e52c05f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59352, '', '14', 57412, '14', 7, '4baa6a5a-5489-4d31-9a7f-c42c0e036037');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59353, '', '15', 57412, '15', 8, 'cc457bcf-f587-485d-9437-788fc98beba5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59354, '', '16', 57412, '16', 9, '0a5c299d-53d3-4e3f-a7d4-18fb32355a0f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59355, '', '17>', 57412, '17 years old or older', 10, 'e1e19b16-a0c8-4b27-9b44-68af840dbc55');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71402, '', '101', 59907, '101', 120, '6d759145-bd39-49c9-b3e3-81fff75e6a56');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59069, '', 'dont know', 58766, 'I don''t know/I can''t remember', 4, 'c33fa3d5-5256-4fa2-974a-f7f2b411b42b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59070, '', 'n/a', 58766, 'I''d rather not say', 5, '93002104-6730-4bc6-aa18-a83201741aae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59157, '', 'selection', 58771, 'Select One', 1, '0d318f5a-1681-4ec4-8b35-71d1143986ca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59158, '', '1', 58771, '1', 2, '4f3eb616-a0c5-4aed-b080-8c5d6fbeba4a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59159, '', '2', 58771, '2', 3, '9ac1db08-7a55-4cd4-9d0b-de220b7d8bf0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71403, '', '102', 59907, '102', 121, 'cae6219d-6dba-4eab-8f15-fce39cc94357');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59160, '', '3', 58771, '3', 4, 'c6306b69-91f4-4b2e-a820-1bb4ebd69f79');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59161, '', '4', 58771, '4', 5, 'ac531cb2-4bcc-48be-999b-2b43c6615165');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71948, '', '', 61914, 'Middle Initial:', 1, '981fd944-2861-451a-8834-ed5f5f0efffc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23315, '', '3', 11652, 'Bart''s Homemade', 3, '47f57e23-5456-4d9b-8128-8af2492aa614');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23316, '', '4', 11652, 'Cadbury', 4, 'd71d58d8-6430-4ecb-b01a-6a54987fad67');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23317, '', '5', 11652, 'Deans', 5, '1d4fe2cf-b7cf-4e2e-93fd-f4b3fc12e50d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23318, '', '6', 11652, 'Hershey''s', 6, '22706d75-27cb-445f-a805-9aa96c7064d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23319, '', '7', 11652, 'Blue Bunny', 7, 'fff47a3a-f764-4483-bbe7-84f3612c264f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23330, '', '8', 11652, 'Ben & Jerry''s', 8, '6a1eb248-44b6-4ab0-8d86-7a2334d420ae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23331, '', '9', 11652, 'Dreyer''s Grand', 9, 'a212d13d-d8f0-45b5-afcf-a192e7367c77');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23332, '', '10', 11652, 'Haagen Dazs', 10, '56174e0e-76b8-4826-86f5-64a37146608b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23333, '', '11', 11652, 'Walgreens', 11, '75437054-fbea-4b98-807d-7e4f4a389822');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23334, '', '12', 11652, 'Store brand', 12, '7435a7de-b74b-4ae0-ba82-2b9840ba4224');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23335, '', '000', 11652, 'Other brands', 13, '7347d2df-046d-49c2-a040-8c5ac6e9a517');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24598, '', 'yes', 12278, 'Yes', 1, 'c81fb69b-3b14-4795-9f19-b238dadb49e1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24599, '', 'no', 12278, 'No', 2, '8b1b403c-1b8e-4435-8b91-89d111f2ad26');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24610, '', 'cant remember', 12278, 'I don''t know/I can''t remember', 3, '3c16d517-95a2-4094-887b-f72983568b61');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24611, '', 'n/a', 12278, 'I''d rather not say', 4, 'e2799dfd-b53c-4886-a25e-38bf827985b2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31258, '', '1', 15572, '1', 1, '16c5e7b5-469d-432d-82ab-c625789a60ec');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31259, '', '2', 15572, '2', 2, 'df4a7c90-b22a-43e9-842b-09fecfd8da1f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31260, '', '3', 15572, '3', 3, '082ea78e-aa02-4155-a3b3-a8f0521057c4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24245, '', '2', 12099, 'Yes', 0, '015d0b19-11f5-4c00-a88d-22864dead330');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24246, '', '1', 12099, 'No', 0, '604a6838-2fb9-425d-83ff-3e6d56282710');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24247, '', '2', 12125, 'Yes', 0, '92175bf7-6c26-4492-a8a8-9bf228c2b17b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24248, '', '1', 12125, 'No', 0, 'e6294161-32ff-4909-8a57-39cfd3bee10c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24249, '', '2', 12126, 'Yes', 0, '6de0a883-96a1-4893-baa0-7b0918e71e37');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24260, '', '1', 12126, 'No', 0, '4c773840-0e48-420f-a5ad-dc0cbb0ff235');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24261, '', '2', 12127, 'Yes', 0, '7f35ebb1-9b19-40f6-93fb-fe19a6da3ed3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24262, '', '1', 12127, 'No', 0, 'b536fd21-4f38-4952-8ec7-6a154ab9fb32');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24263, '', '2', 12128, 'Yes', 0, '1207a070-1a43-4054-b4a1-e4a66a1e80b4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24612, '', '1', 12279, '1', 1, 'e3c6892a-f775-48ee-a0a3-f922275c368f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24613, '', '2', 12279, '2', 2, '8ab0ba87-9f06-4af5-9636-15b2b0cd9d3c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24614, '', '3', 12279, '3', 3, '6296c1b9-59ee-4e91-b23a-06501ac8516b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23841, '', '1', 11912, 'qqq', 1, 'f73601fd-7e94-4be1-b2f9-d75f12517ede');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23842, '', '2', 11912, 'www', 2, '558371fe-2f4c-4805-9beb-e2ec45cd9b5c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23843, '', '3', 11912, 'sada', 3, '6ba5c638-c5c1-4c75-bc27-daaf988acd49');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24615, '', '4>', 12279, '4 or more', 4, '7a424651-ad9b-4ed5-8916-269a2f3ec2a6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24616, '', 'cant remember', 12279, 'I don''t know/I can''t remember.', 5, '5c86b573-9dec-4cff-bf84-2f9ae444a662');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24617, '', 'n/a', 12279, 'I''d rather not say.', 6, '2156ed3c-a4f3-4147-8844-7a29452867a9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31261, '', '4', 15572, '4', 4, 'c6091135-9179-430b-b90a-e2c96bd9217a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31262, '', 'Bothered very much', 15572, 'Bothered very much', 5, '4f195022-a1b6-4422-b032-8e2e7b1df393');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24264, '', '1', 12128, 'No', 0, 'a49ce2c3-7637-43e6-a431-29f8c62038fe');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24265, '', '2', 12129, 'Yes', 0, '0af2d239-5609-4ecb-a9ba-c0d07e7b8993');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24266, '', '1', 12129, 'No', 0, '81d8aa51-9c02-4cd4-a009-dcea889c2436');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24267, '', '2', 12135, 'Yes', 0, '565ff6d1-1356-4b26-8249-c3d2d1b58924');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24268, '', '1', 12135, 'No', 0, '41c58102-6212-4518-ace0-8a987df719fe');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59071, '', 'FISH', 58767, 'FISH', 1, 'd2afc25f-abd8-486d-b1d1-5bfd942e22a9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59072, '', 'Immuno', 58767, ' Immunohistochemistry', 2, '7c28db84-deef-4c22-b112-f484971a6fd0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59073, '', 'dont know', 58767, 'I don''t know/I can''t remember', 3, 'e2bbc05f-111b-44cc-ba7a-87eee31cac7e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59074, '', 'n/a', 58767, 'Does not apply', 4, 'c56369e0-cf4d-417b-8f7d-8397de4c1262');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59075, '', 'not say', 58767, 'I''d rather not say', 5, 'b7da3540-2af4-4a29-aa53-452f939d1301');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24269, '', '2', 12136, 'Yes', 0, '176e87e6-34f8-4aa5-9d06-9074191bd573');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60475, '', 'yes', 59939, 'Yes', 1, '1320bba5-aa1a-477b-b04f-855a578d921c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60476, '', 'no', 59939, 'No', 2, 'e363ded9-8066-4225-81cb-e5c96415a85b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60477, '', 'n/a', 59939, 'I''d rather not say', 3, '2521d01f-fe56-45ea-bf59-e8a70d104bad');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67547, '', '1', 59910, '1', 0, '663f4c8c-64e3-452f-a9ce-be5b5653b230');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67548, '', '2', 59910, '2', 0, '33840ead-f784-4a0e-b6eb-6b523286fb9f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67549, '', '>3', 59910, '3-5', 0, '9a2e2697-a71a-4d61-ad3a-f8daec7db5c1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71949, '', '', 61915, 'Street Address:', 1, '49837636-71a1-4d64-b62b-1ca021baca60');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59162, '', '5', 58771, '5', 6, '78baa07f-9721-4033-8c0c-2cb6a3a6aa4c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59163, '', '6', 58771, '6', 7, '7d6fd3d0-4b0e-4cd7-81c0-c05d029b9db5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59164, '', '7', 58771, '7', 8, 'fa43e72c-1794-486d-8bf4-97bbcff75143');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59165, '', '8', 58771, '8', 9, '0db59da8-b603-49c5-87ba-b30e8b768386');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59166, '', '9', 58771, '9', 10, '084bc85c-fbce-4551-9037-8364ae0e2fdc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59167, '', '10', 58771, '10', 11, '855c43d1-d330-4ee1-bc9a-e10c45507b66');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59168, '', '11', 58771, '11', 12, '57f8b612-9caf-4e9a-9295-a6bc513a40c8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59169, '', '12', 58771, '12', 13, 'd3220c32-872c-4d6d-b54e-c65028eb81ae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59170, '', '13', 58771, '13', 14, 'c189100e-723d-402c-9cfc-68d7a3ef1cd2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59171, '', '14', 58771, '14', 15, 'ceca3589-bc0d-43bb-987a-ce43473cdbd1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59172, '', '15', 58771, '15', 16, 'fb2fe2b1-c0b3-4ad1-9b6a-750ed22da9aa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59173, '', '16', 58771, '16', 17, '6420002c-4dfb-40de-be17-073a00060a68');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59174, '', '17', 58771, '17', 18, '94ea6698-0dd1-493b-b794-a0204d2673cc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59175, '', '18', 58771, '18', 19, 'e6153c48-1b9b-4455-8226-450fe8aa6942');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59176, '', '19', 58771, '19', 20, 'fceefdba-caf0-41ba-aadf-26e23789cb96');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59177, '', '20', 58771, '20', 21, 'ca973d07-a97e-4ac0-a93d-9e022c138552');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59178, '', '>20', 58771, '>20', 22, '51905619-20cd-4b9a-a6e8-62ed4e21d1b6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59179, '', 'd/n', 58771, 'I don''t know/I can''t remember', 23, '04a5690c-4813-4557-b686-0f0780e7e7b4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59180, '', 'N R', 58771, 'Not Reported', 24, '2c5fd996-d2fd-4453-9a17-be90f082671b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59193, '', 'yes', 58773, 'Yes', 1, '39196a26-12c5-4879-b9e0-2b2900ab0bda');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59194, '', 'no', 58773, 'No', 2, 'c00c313e-7697-4c4f-8087-c49f2c72d672');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59195, '', 'DR', 58773, 'I don''t know/I can''t remember', 3, 'ec12a68e-3ea6-47c6-89c9-e75e67862076');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59196, '', 'd/n', 58773, 'I''d rather not say', 4, '45261606-6967-4b70-9265-62631833fcac');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59356, '', 'dont remember', 57412, 'I don''t know/I can''t remember', 11, '0bdf17a8-a0ba-4e1e-84b8-5bdaa53bcadc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59357, '', 'n/a', 57412, 'I''d rather not say', 12, 'ec2986cc-223c-4880-9507-94f7f00d13bc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59076, '', 'yes', 58768, 'Yes', 1, '2e52f948-581a-4816-999c-8cf3994e3309');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59077, '', 'no', 58768, 'No', 2, 'b6e530be-1d3a-4772-99c9-4ea7beab73e2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59078, '', 'not tested', 58768, 'Not Tested', 3, 'c850aabe-e708-4b46-ad16-a31cec7f2773');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59079, '', 'd/n', 58768, 'I don''t know/I can''t remember', 4, 'a204ee45-94ae-4690-a373-9b487be4ecb1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59080, '', 'not say', 58768, 'I''d rather not say', 5, 'ca83c988-5054-4ecf-a964-4339b7adb1b4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59370, '', 'yes', 58778, 'Yes', 1, '1005f8a4-55af-4fa5-83d9-41c216303d4a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59371, '', 'no', 58778, 'No', 2, '335a61e0-0dc9-4cf7-a61f-a2a84ab63a03');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59372, '', 'cant remember', 58778, 'I don''t know/I can''t remember', 3, '248d4c93-7e48-433e-bb12-f8ff55540d6f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59373, '', 'n/a', 58778, 'I''d rather not say', 4, '53d35551-87c7-45ea-817f-ecd400f823c0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59753, '', 'part of overy', 58799, 'Yes, I have had surgery to remove part of an ovary.', 1, 'b047fcb2-3d9a-429a-bf86-702aae58f3ea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24280, '', '1', 12136, 'No', 0, '14693321-cf03-433c-9c01-0ee58f22ee49');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24281, '', '2', 12137, 'Yes', 0, '653ea5b3-a943-4bcd-b7e3-12a679337703');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59754, '', 'one overy', 58799, 'Yes, I have had surgery to remove one ovary, but not both ovaries.', 2, '4ff50827-c3c7-4eb4-b0f0-fa6e2825648b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59755, '', 'both overies', 58799, 'Yes, I have had surgery to remove both ovaries.', 3, '7ad96e9b-8877-4f57-8ab3-526cf214e693');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59756, '', 'none', 58799, 'No, I have never had a surgery to remove any part of an ovary.', 4, 'c6e904d8-86b8-4c54-a119-cd7b44921b5b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59757, '', 'dont remember', 58799, 'I don''t know/I can''t remember.', 5, 'fcc6ee8b-11a4-4b41-bdc0-26f9c7ca1518');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59758, '', 'n/a', 58799, 'I''d rather not say', 6, '76533758-7134-4873-b0bc-267950eb4b49');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67550, '', '>6', 59910, '6-8', 0, '62956d23-31ac-4d63-b5ac-f74e21c10903');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67551, '', '>9', 59910, '9-11', 0, '9d43792f-6d50-4996-ad14-c2a477e6ff7a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67552, '', '>12', 59910, '12 or more', 0, '44277945-8f70-4350-9c5a-9f62ee077c55');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67553, '', '>1', 59910, 'Less then 1', 0, '3960b67d-d8b7-4779-9a9a-106d942a84a8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67554, '', '1', 59911, '1', 0, '48d202c8-f93f-4942-bdf7-f7acff1cae6c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67555, '', '2', 59911, '2', 0, 'e2400307-9e43-427f-b0b9-c40a066edf99');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67556, '', '>3', 59911, '3-5', 0, '044dac3b-ef9f-49c1-850d-8ce651223dc7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67557, '', '>6', 59911, '6-8', 0, '55808649-56b3-445d-8a2f-297b4a0a83ab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67558, '', '>9', 59911, '9-11', 0, '01caa6f1-c2ef-44f9-af95-9c396078fa78');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67559, '', '>12', 59911, '12 or more', 0, '11638c44-f0d2-403e-93bc-0eaa6431a2d9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67560, '', '>1', 59911, 'Less then 1', 0, '00d90229-a3bb-4e9c-bd49-7dd2ff2c8067');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67561, '', '1', 59912, '1', 0, 'dee16b0f-e605-4a2e-a13a-9b470d0c667f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67562, '', '2', 59912, '2', 0, 'a61fe44a-0cac-4e82-9c96-b5ff057f2670');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67563, '', '>3', 59912, '3-5', 0, '1a283276-a619-47b1-854b-f5e8345ed675');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67564, '', '>6', 59912, '6-8', 0, '61e8e89b-24b1-4109-90e5-bb98a3b5ac33');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67565, '', '>9', 59912, '9-11', 0, '789c5da6-0fa6-417b-8a36-b9129c20d41b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59129, '', 'selection', 58769, 'Select One', 1, '0eda1eed-1d3f-4b59-90ed-af90866faea2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59130, '', '1', 58769, '1', 2, '4159594b-21f0-415d-a2f3-642667ff0901');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59131, '', '2', 58769, '2', 3, 'fda96516-59f9-421b-94e6-64d3c82f20dd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59132, '', '3', 58769, '3', 4, '7611350b-1098-4c68-b05b-fbd968280928');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59133, '', '4', 58769, '4', 5, '9e5147b7-2682-4778-b993-3a01e025ebd8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59134, '', '5', 58769, '5', 6, '78399c58-6b29-4683-997d-bef9bc661888');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59135, '', '6', 58769, '6', 7, 'aa326567-175a-4a6b-a723-70424dddb825');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59136, '', '7', 58769, '7', 8, 'e0932c24-b684-45f0-ad6f-f55e2928c166');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59137, '', '8', 58769, '8', 9, '57fb068f-b30e-496e-a9ce-ae1846e3d50e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59138, '', '9', 58769, '9', 10, '12aa0144-e574-4eff-ab58-a941f7d32e20');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59139, '', '10', 58769, '10', 11, 'a33ef5fe-b084-414a-9590-499de1ef882c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59140, '', '11', 58769, '11', 12, '3092567c-b481-4bf2-ad23-00b5b0da8d7b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59141, '', '12', 58769, '12', 13, '1bc0d621-7ee6-48dc-94b3-69bc57acae89');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59142, '', '13', 58769, '13', 14, 'afcf0ae8-9db4-4e0d-8b5e-dc01bd4739fc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59143, '', '14', 58769, '14', 15, '853bbe3f-e283-49dc-b240-06e4ccf5b1f8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59144, '', '15', 58769, '15', 16, '7636155f-1816-4f04-8004-5cd19b4df8e4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59145, '', '16', 58769, '16', 17, '5dcf2bf0-a66e-46bc-9bee-98bb47a4dbf4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59146, '', '17', 58769, '17', 18, '9fcd9c4a-738c-459c-862a-8230b753d55b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59147, '', '18', 58769, '18', 19, 'ff6ece74-37d3-434a-9060-d41ea0e5037f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59148, '', '19', 58769, '19', 20, '0759f9c8-719e-4a92-a2f3-8367d93e3700');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59149, '', '20', 58769, '20', 21, '05df073c-f965-4970-a8f9-cb0c9972818e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59150, '', '>20', 58769, '>20', 22, 'c30a4730-824d-4702-88fe-83212554aa6f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59151, '', 'dont know', 58769, 'I don''t know/I can''t remember', 23, '85231375-64a5-45aa-acd5-9a0aec6d588b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59152, '', 'N R', 58769, 'Not reported', 24, '6673d6b4-51f9-4a74-ac7f-5931ecb96ec0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59374, '', 'yes', 58779, 'Yes', 1, '6f885de7-e068-45c5-b7c9-09f72036adb4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59375, '', 'no', 58779, 'No', 2, 'bda4236a-6a2e-4502-a45f-32d33b176812');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59376, '', 'cant remember', 58779, 'I don''t know/I can''t remember', 3, 'acd4661a-9261-4a0d-9909-d661e17f75d0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59377, '', 'n/a', 58779, 'I''d rather not say', 4, 'c9e51467-e960-444c-9edc-65d125a73773');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71950, '', '', 61916, 'City:', 1, '09ab568d-e3e3-460d-ab94-285b8cf2fadd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15316, '', '', 7634, 'Street Address:', 1, '6a8411e2-d362-45fc-9be9-5b88b8a935d7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67566, '', '>12', 59912, '12 or more', 0, 'ce67d950-77a6-4c9d-a8ec-7ed7fb6dbb33');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67567, '', '>1', 59912, 'Less then 1', 0, '59fe272f-2d45-40f6-ac6f-7f13b5822207');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67568, '', '1', 59913, '1', 0, '0ecf5632-6cfb-4597-afd0-1dde7cbf08ff');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67569, '', '2', 59913, '2', 0, '9dd20224-4627-4b8e-846a-6eaa1dc21a9e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67570, '', '>3', 59913, '3-5', 0, '7c726a5e-a262-46a7-b9bc-1b1bc23730e4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67571, '', '>6', 59913, '6-8', 0, 'f4f85779-744e-4bf0-884a-ef97e3504560');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67572, '', '>9', 59913, '9-11', 0, 'f6034470-6c23-4717-9bfc-82d9d683d320');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67573, '', '>12', 59913, '12 or more', 0, '2f4b6f2c-055a-40da-a16b-4c79d9348208');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67574, '', '>1', 59913, 'Less then 1', 0, '6db581ec-5f94-41db-bc98-093b1d82ca43');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67575, '', '1', 59914, '1', 0, '38cc2afa-b8ab-450e-a34d-58dc00097062');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67576, '', '2', 59914, '2', 0, 'a9432d32-6d02-489b-a801-2ddf63a60f86');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67577, '', '>3', 59914, '3-5', 0, '94990184-4819-461e-a2ce-3e3e6f78dfae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67578, '', '>6', 59914, '6-8', 0, '76db55fc-531c-4c55-a50c-12360ca26f8e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67579, '', '>9', 59914, '9-11', 0, '792040f4-71ac-443a-aa38-b44b5ae2f016');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67580, '', '>12', 59914, '12 or more', 0, 'c1a82f6d-0d5b-4dd7-ba78-3487cfa4af0d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67581, '', '>1', 59914, 'Less then 1', 0, '58101ca5-5830-4465-b992-cc35f2ba9d54');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71404, '', '103', 59907, '103', 122, '7fcfc1d3-0365-45c2-a31a-ef426fcbe23e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71405, '', '104', 59907, '104', 123, '8749eabe-5196-4ef0-8249-9b195fc2867d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59759, '', 'yes', 58797, 'yes', 1, '526786f9-be6d-456c-8f1e-820e86b10b2f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59760, '', 'not sure', 58797, ' I don''t know/I''m not sure ', 2, 'e3e046b4-aae3-4f11-8283-74e91b9b8ebc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71406, '', '105', 59907, '105', 124, '748ffeb7-9d9f-468d-92de-aa98e4705821');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71407, '', '106', 59907, '106', 125, 'f03dca7e-fd43-446c-b1b6-49aae3274319');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71408, '', '107', 59907, '107', 126, '9b70b280-b529-4074-b2ed-23a841266597');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71409, '', '108', 59907, '108', 127, '84937815-abaf-4928-a5d1-92ee06d9bf75');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71410, '', '109', 59907, '109', 128, 'c21d326a-c6bc-4d3a-ad47-1312b3dfe345');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71411, '', '110', 59907, '110', 129, 'f1c0128f-be8b-49c5-adfb-020a3bd0b50d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71412, '', '111', 59907, '111', 130, '3b7ab30b-9875-4912-b21b-b1b41427c3a6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59461, '', 'y', 58780, 'Yes', 1, '142db007-b36f-4285-876e-2cdc3ba66958');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59462, '', 'n', 58780, 'No', 2, '58d05b35-7886-4175-b634-21e92433014c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59463, '', 'n/a', 58780, 'I''d rather not say', 3, '4e0f2c2e-2518-4300-b1f2-16d88784d5cc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59464, '', 'cant say', 58780, 'I don''t know/ I can''t say', 4, 'aae2e6ab-4e61-4013-93b7-a7f99db33172');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59465, '', 'y', 58781, 'Yes', 1, '9ef72990-64dc-4d32-90f0-b4f4fae04419');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59466, '', 'n', 58781, 'No', 2, '8f5758b7-0568-43b1-86c2-0d43d6e07503');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59467, '', 'n/a', 58781, 'I don''t know/ I can''t say', 3, 'ed6385aa-3f50-4446-b526-1afac1de0f84');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59468, '', 'dont say', 58781, 'I''d rather not say', 4, 'fdb63bc0-a42c-4f20-b61b-37bdc6dc26e2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59469, '', 'y', 58784, 'yes', 1, 'dea7006e-0546-4723-ba3d-4bc602cf669a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59470, '', 'n', 58784, 'no', 2, '0eb47425-eb4c-4edc-8a98-a65f873a57b8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59471, '', 'd/n', 58784, 'I don''t know', 3, '8675fffd-17c7-4ddf-b274-e64ce48c4859');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59472, '', 'not say', 58784, 'I''d rather not say.', 4, '3575f609-4f16-4639-9a0e-d9a6344a007b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71413, '', '112', 59907, '112', 131, 'f154c563-90fd-45c7-996e-5d1b75fbb4b2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59474, '', 'reqular', 58785, 'I have regular menstrual periods (I am premenopausal).', 1, '38eabdae-0153-460b-bfb3-ab9eceab7ee4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59475, '', 'nursing/preg', 58785, 'I do not have regular menstrual periods because I am currently pregnant or nursing. ', 2, 'f3a66790-97a0-4a8d-9c02-f83f3f904b89');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59476, '', 'stopped', 58785, 'My menstrual periods are irregular but have not stopped. ', 3, '5670333b-2cdc-44f6-905d-1fe91a864889');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59477, '', 'menopause', 58785, 'I no longer have regular menstrual periods (menopause).', 4, 'b6d53ad0-d693-4614-86ad-02a45edbe911');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59478, '', 'dont say', 58785, 'I don''t know/I''m not sure', 5, '200b60d7-130c-4c19-9431-6ed296dd4867');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59479, '', 'n/a', 58785, 'I''d rather not say.', 6, '9a9d0d02-5b15-497b-b553-937bf9cdc77d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71951, '', '', 61920, 'Zip:', 1, '45e7f992-a828-4b6f-bff7-85cae248cd32');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15317, '', 'selection', 7685, 'Select select your state ', 1, '0d7273a2-654c-4682-9264-be3172c2de48');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59483, '', 'yes', 58787, 'Yes', 1, 'af18a2db-a522-4fae-9f90-81ef47256388');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59484, '', 'not sure', 58787, 'I don''t know/I''m not sure', 2, '352f1509-6071-4176-bd58-dd106765949e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59485, '', 'not say', 58787, 'I''d rather not say', 3, '5b7bfe47-7808-4282-8452-1164bfe1d122');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59486, '', '', 58786, 'Please enter year(YYYY)', 1, 'b5579311-b609-4514-a438-9b1e53c83e83');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59487, '', 'naturally', 58788, 'My periods stopped naturally.', 1, 'a5102d84-655a-429a-b784-77bf2c238192');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59488, '', 'removed uterus', 58788, 'My periods stopped because I had a surgery to remove my uterus (hysterectomy), but at least part of one ovary is intact. ', 2, 'a4af5056-dfd4-496c-a7b0-2a7ab415fd45');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59489, '', 'removed ovaries and utreus', 58788, 'My periods stopped because I had a surgery to remove my uterus (hysterectomy), and both of my ovaries have been removed.', 3, '0f6b918f-ba7a-41e1-a75e-59257a56e527');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59490, '', 'removed overies', 58788, 'My periods stopped because although I have a uterus, I had both of my ovaries removed.', 4, '0ff085f6-a017-4607-ad1b-f9367200f13d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59491, '', 'medication', 58788, 'My periods stopped because of medication or chemotherapy.', 5, '3c4c8345-fce4-4430-bb84-12e2a63e1d0d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59492, '', 'dony know', 58788, 'I don''t know why my periods stopped.', 6, '77f5e08c-d5f9-4068-a8b4-ec172066a06f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59493, '', 'other', 58788, 'My periods stopped due to another reason', 7, 'd2dba9b8-e5b0-4de1-a119-ce03e77493f4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59494, '', '', 58789, 'Please specity reason', 1, '958ffe51-cc4e-4206-b92c-c040fc2804c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59499, '', 'no longer ', 58790, 'Yes, I have taken menopausal hormone therapy in the past, but no longer do', 1, 'c1462b09-3ebe-4a1b-8bc3-fd8d1aea438a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59550, '', 'currently', 58790, 'Yes, I am currently taking menopausal hormone therapy.', 2, 'ee6b3ce1-3188-489c-9cae-6205b2adf427');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59551, '', 'never', 58790, 'No, I have never taken menopausal hormone therapy.', 3, 'e384e531-66ab-4d11-82b1-cddacd865a6a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59552, '', 'dont know', 58790, 'I don''t know whether I have taken menopausal hormone therapy.', 4, 'e2837638-80e8-47bd-bc46-2da892ab3e39');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59571, '', 'estrogen', 58795, 'I have taken an estrogen.', 1, '38202bd6-f861-4f92-a45d-bb93b97394a3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59572, '', 'combination of E & P', 58795, 'I have taken a combination pill with both estrogen and progestin', 2, '548c0b79-004d-4236-8e59-361949b3c1ee');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71442, '', '141', 59907, '141', 160, 'd8101e1b-76ab-4d3f-beb8-f54d40b49f5c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59573, '', 'combination of E&T', 58795, 'I  have taken a combination pill with both estrogen and testosterone.', 3, '21b06a03-4f15-4934-af92-8f4d2c85c3c8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59574, '', 'seperate pills', 58795, 'I have taken estrogen and progestin as separate pills.', 4, 'ec639e5c-4445-4f50-9fc1-df319da60520');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59575, '', 'hormones', 58795, 'I have taken bioidenticals or hormones from a compounding pharmacy', 5, '38faa40a-757c-4aec-90ab-76c8ca711a0a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59576, '', 'dont know', 58795, 'I don''t know what formulation(s) of menopausal hormone therapy I used.', 6, '04683458-b2f9-46d4-a987-11eb6e8b68f7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59577, '', 'partial', 58796, 'Yes, I had a surgery to remove part of my uterus.', 1, 'cbe6d14c-b0a7-4813-9c89-cf5916bc657b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59578, '', 'whole', 58796, 'Yes, I had a surgery to remove my entire uterus', 2, '1ce0292b-f385-4419-91af-c7124e747c35');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59579, '', 'No', 58796, 'No, I have never had a surgery to remove part or all of my uterus.', 3, '0651f688-743c-439f-808e-87ee9f63e71f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59580, '', 'not sure', 58796, 'I don''t know/I''m not sure', 4, 'a0fbc8ac-5d63-4d2c-94b5-a1b17a095f82');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59581, '', 'n/a', 58796, 'I''d rather not say', 5, '8dafab38-746f-4b82-8585-61441e6ca48c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59585, '', '', 58798, 'Please enter year (YYYY)', 1, 'a40f8ad1-242b-4d9e-be9b-901c363ff672');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60148, '', 'y', 59917, 'Yes', 1, '634b82ad-0855-40dd-b18b-12600f9379a4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60149, '', 'n', 59917, 'No', 2, '4fcb78ee-b716-48f7-b182-6b6330703c3a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60150, '', 'n/a', 59917, 'I''d rather not say', 3, 'f31b1344-d145-4f60-b9ee-33a5c48f6127');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71414, '', '113', 59907, '113', 132, 'cc2a4a41-50ef-4b98-95b5-d304c28663ea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71415, '', '114', 59907, '114', 133, 'db5e7a27-4369-40f4-8bfc-b0969f74cfbf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59595, '', '', 59601, 'Please enter year (YYYY)', 1, 'dd59de4f-2b64-454b-a759-92ae13536208');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59750, '', 'Yes', 59600, 'Yes', 1, '8bc1e82a-2c04-4206-8a56-d9178e5c7f9a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59751, '', 'dont know', 59600, 'I don''t know/I''m not sure ', 2, '7a99aac7-51c1-464e-92cc-5238cd4a497d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59752, '', 'n/a', 59600, 'I''d rather not say', 3, '5c09abc0-7257-44fa-aff6-c9000787615f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59761, '', 'n/a', 58797, 'I''d rather not say', 3, '81d1553a-6edb-4bf8-b53f-14a6f8f06022');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71416, '', '115', 59907, '115', 134, '4bbd9eeb-0acc-46aa-a1a0-7e7a53cae812');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71417, '', '116', 59907, '116', 135, '91f1d58b-59e8-4308-990a-c7f74cbe7064');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71418, '', '117', 59907, '117', 136, '9c974468-c447-4e33-b2b6-f54f3459dd0f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71419, '', '118', 59907, '118', 137, '69b34cbc-6f33-4536-b137-5899fe85c8a1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71420, '', '119', 59907, '119', 138, 'c6966171-c218-4688-b483-3ff53ee1a839');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71421, '', '120', 59907, '120', 139, '51acff71-5877-4153-8a2c-1af9b87a059b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71422, '', '121', 59907, '121', 140, 'b16c05cb-86da-495c-9a95-f96c8fe04827');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71423, '', '122', 59907, '122', 141, 'ddf11d67-fe03-4a40-8b3d-a7f21a3b3c66');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71424, '', '123', 59907, '123', 142, 'e5bb8adf-d982-4774-af78-030e723aed9b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71425, '', '124', 59907, '124', 143, '43ca272f-ee43-4566-ae1f-1e167de80ba7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71426, '', '125', 59907, '125', 144, 'd584ceac-472f-4970-9554-5da74dc42770');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71427, '', '126', 59907, '126', 145, 'e3fcb073-3251-4cdc-889b-cc3b94a1c76d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71428, '', '127', 59907, '127', 146, '0606a2d1-2bdd-41b2-ba7c-0324e672c5be');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59783, '', ' better', 57864, 'Much better than a year ago', 1, '5ba7ea65-cbae-419d-9694-5b399ced01e3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59784, '', 'somewhat', 57864, 'Somewhat better now than one year ago', 2, '848c0fd6-a9a3-40b0-85c4-c400517dd19c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59785, '', 'same', 57864, 'About the same', 3, 'e85111c3-e020-40d2-b969-aaba7b764a11');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59786, '', 'worse', 57864, 'Somewhat worse now than a year ago', 4, '3f6a7ace-a4c1-4df8-9360-36b77de81ce1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59787, '', 'more worse', 57864, 'Much worse than a year ago', 5, 'cb0c6917-972e-42f3-9dfb-7b0e834dfd2c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59788, '', 'n/a', 57864, 'I''d rather not say', 6, '14b28fd8-b5a8-422c-880a-6874dd8def2c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71429, '', '128', 59907, '128', 147, '2f68e733-a92c-428d-87e1-2b6c909be7b4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71430, '', '129', 59907, '129', 148, 'd24202db-c08e-4e4a-ab46-25962249e72c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71431, '', '130', 59907, '130', 149, 'cbdbf675-5906-47c6-87f7-e9d453aa4c5c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71432, '', '131', 59907, '131', 150, '4a66bfc7-657b-4c46-b5b1-71272f67bd24');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71433, '', '132', 59907, '132', 151, '1ffac35b-44c0-4b78-ba95-ec1b4f477ee3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71434, '', '133', 59907, '133', 152, '013b2054-ce73-44b6-88d6-519aef83e572');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71435, '', '134', 59907, '134', 153, 'a73fcc8e-402e-43c6-a773-0225e8907a6a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71436, '', '135', 59907, '135', 154, '72cddf20-32e0-46ea-81eb-9cc75003e8e2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59962, '', 'Previously', 59908, 'Yes, previously ', 1, '936714cb-37c6-4db9-ba18-ac6667e48bb3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59963, '', 'Currently', 59908, 'Yes, currently', 2, 'c284d06e-aed7-4d31-a959-809a09b2e2d7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59964, '', 'No', 59908, 'No', 3, '48a025f3-099b-4f5b-a7f3-4afffb26eae4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (59965, '', 'n/a', 59908, 'I''d rather not say', 4, '5e6810ac-e392-41e9-beec-fabff54e8b6a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71437, '', '136', 59907, '136', 155, '9d94901a-8e50-4944-8a22-84fa23a9f9e5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33329, '', 'm', 16643, 'Male', 1, '81e63a84-81e1-43d8-85ac-af0d625ab0b3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33360, '', 'f', 16643, 'Female', 2, '39c52a80-d77e-4052-b39f-718b50dece67');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60151, '', 'hetro', 59918, 'Heterosexual', 1, '11c54f30-c6b0-49b7-aefe-55b34c99ca7f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60152, '', 'bisex', 59918, 'Bisexual', 2, '24af4e6c-9f55-4e92-be8a-c004460fb708');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60153, '', 'homo', 59918, 'Homosexual', 3, '57e28421-5de1-49f3-b7ad-e81d5578fa07');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60154, '', 'other', 59918, 'Other', 4, '0bfa46e2-9abf-4b67-be5f-8c3a3e693a05');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60155, '', 'n/a', 59918, 'I''d rather not say', 5, '64119587-a674-4fa1-8627-6a2612ae20bc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69808, '', '', 57863, 'Other Asian', 1, '62557b68-0d80-4977-9154-ea50e9d4c602');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71438, '', '137', 59907, '137', 156, '2e56c983-543c-49f4-bcd4-c6a2851d501f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71439, '', '138', 59907, '138', 157, '820c5fc2-24ae-4e85-8d14-2e0072d8db1a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71953, '', '', 61919, 'Email Address:', 1, 'eaf5f1a6-b929-4f7d-af20-ed6c435f11f4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71440, '', '139', 59907, '139', 158, '80eebde9-fb1d-4128-8943-2a0209471e69');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71441, '', '140', 59907, '140', 159, 'c6e43de7-9dd3-4536-8e4b-4020b3c4706c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71443, '', '142', 59907, '142', 161, 'b4a81abb-7345-48d2-bf7d-6233b02ec7c8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71444, '', '143', 59907, '143', 162, '2f81dcb2-6f39-4e9a-ace6-d590313ee223');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71445, '', '144', 59907, '144', 163, '14aeb7da-3389-4ea7-b4bc-12e948ab1c47');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71446, '', '145', 59907, '145', 164, 'e536bd4c-986e-4d9c-9b0e-28f5e5212325');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71447, '', '146', 59907, '146', 165, 'fa6d6bb7-5f6e-4753-9bb4-4985120cf75d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60710, '', '', 60585, 'Please specify', 1, '453234b9-0874-46b8-8123-a7e9d7b40583');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71448, '', '147', 59907, '147', 166, '20567e18-f2a4-4be0-a22a-5cd57d52371a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71449, '', '148', 59907, '148', 167, 'c7709436-357b-4206-8151-9fb4fd01d8bc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71450, '', '149', 59907, '149', 168, 'ac78e269-0056-4542-b87c-997a6805b788');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71451, '', '150', 59907, '150', 169, '8f3d4343-6a50-480b-b33b-e940e494199d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71452, '', '151', 59907, '151', 170, '542f2b47-cff4-41ad-96c9-7f323a82b535');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71453, '', '152', 59907, '152', 171, 'be98dd5b-131d-4d88-baee-86a97ef82067');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71454, '', '153', 59907, '153', 172, '9b3d77dd-3252-472d-b0e1-a8cb029935d8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71455, '', '154', 59907, '154', 173, 'ad5b0f9d-0438-4c67-825d-b7ac169d7815');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71456, '', '155', 59907, '155', 174, '102ed07a-5784-4591-a471-438f8eda8791');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71457, '', '156', 59907, '156', 175, '16724cb4-0f0a-4b2b-8cba-e558e0574e98');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71458, '', '157', 59907, '157', 176, '89635a6d-7833-4ca1-915f-708663ad257e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71459, '', '158', 59907, '158', 177, 'd0498270-b968-404c-b2f2-aa6151dfae50');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71460, '', '159', 59907, '159', 178, '03bc71b7-0f52-426f-a7be-5b804a6e896d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71461, '', '160', 59907, '160', 179, 'c6b6c451-5853-41bc-9a52-67680c82f767');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71462, '', '161', 59907, '161', 180, '229bc03a-f216-4579-9a86-f52edca7e4be');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71463, '', '162', 59907, '162', 181, '7022b0fe-51ab-4126-a100-41cb750387b8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71464, '', '163', 59907, '163', 182, '650847d9-4c4d-40ad-ba7e-d0b3b16b0b05');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71465, '', '164', 59907, '164', 183, '619e0f36-7e6e-4efb-a9cc-ff88cd270638');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71466, '', '165', 59907, '165', 184, 'cd851c3a-9902-4eb0-9492-aac15b6deae3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71467, '', '166', 59907, '166', 185, '42fd072e-b923-4230-9a04-2800f4f8d1c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71468, '', '167', 59907, '167', 186, 'c3b5310b-c7e2-4453-b979-c6f2714ee939');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71469, '', '168', 59907, '168', 187, '3d869ae8-b567-4491-8efa-a4bc3382c71c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71470, '', '169', 59907, '169', 188, '8a184dac-71f2-4542-a82f-e2dbd899f167');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71471, '', '170', 59907, '170', 189, 'b8498a2d-6ced-40e6-8f72-05b5b761ebed');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71472, '', '171', 59907, '171', 190, 'ac3ec52d-b730-473f-a194-d7bd65f1af86');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71473, '', '172', 59907, '172', 191, 'eba7d13f-7ccb-49da-9621-f5736a521ad1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69809, '', '', 69281, 'Please enter "Other Pacific Islander"', 1, 'babfecb6-493b-4d72-890c-2fbfe18de92e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69842, '', '', 69287, 'Last Name:', 1, '46288539-f70d-467e-9ab5-0244c2ce08dc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71474, '', '173', 59907, '173', 192, '41fe4ac3-0ab4-4173-a686-5c6f3b8d07f7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71475, '', '174', 59907, '174', 193, '1395f823-4675-4f86-88fe-8fce433968ba');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71476, '', '175', 59907, '175', 194, '738e3ab5-275f-4967-8def-1aad1c11c009');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71477, '', '176', 59907, '176', 195, '13823348-75ef-459f-b2e8-59b175e386d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71478, '', '177', 59907, '177', 196, '7ca3f192-6f8f-4b72-92da-d10e69fbfd4b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71479, '', '178', 59907, '178', 197, 'c4aaf7ac-104b-419b-8628-9db4cc71e551');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71480, '', '179', 59907, '179', 198, 'c25c1eb4-b55a-41f0-b0ce-e6963f9b21c9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71481, '', '180', 59907, '180', 199, '12b97287-f6ca-4f1d-b7e2-3abeefc46b5a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71482, '', '181', 59907, '181', 200, 'd9fca279-8ca5-45fc-a904-1c0997e7b1d0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71483, '', '182', 59907, '182', 201, 'fb9297bd-be7b-47ca-8a5c-752545163fcd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71484, '', '183', 59907, '183', 202, '7c595081-29eb-43fb-a331-8cabaddcf471');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71485, '', '184', 59907, '184', 203, 'ff6db7c0-cccd-458d-8f77-5ee99999770d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71486, '', '185', 59907, '185', 204, '1bf5ab2a-d242-4018-8a61-df446b2aab0a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71487, '', '186', 59907, '186', 205, '08130eee-3716-494b-8d7f-2c90837f4d0b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71488, '', '187', 59907, '187', 206, '9a588911-c82e-4ee4-bad7-d4b951e464b0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71489, '', '188', 59907, '188', 207, '2bd88d95-b50d-4834-b909-77b3e30b4584');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71490, '', '189', 59907, '189', 208, '7bce07c7-627e-44d2-b215-793dec795d3f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62246, '', 'dcis', 58301, 'In Situ (DCIS)', 1, '81ac688e-d16f-4200-80e0-e8e796c08cf9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62247, '', 'lcis', 58301, 'In Situ (LCIS)', 2, '76508234-6fa7-47bf-8952-e7da2f541468');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62248, '', '1', 58301, 'Stage1', 3, '53650eb3-9aef-42c6-9635-bf4c8f68a66d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62249, '', '2', 58301, 'Stage II', 4, '53650eb3-9aef-42c6-9635-bf4c8f68a66d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62300, '', '3', 58301, 'Stage III', 5, '53650eb3-9aef-42c6-9635-bf4c8f68a66d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62301, '', '4', 58301, 'Stage IV', 6, '53650eb3-9aef-42c6-9635-bf4c8f68a66d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62302, '', 'dont know', 58301, 'I don''t know/I can''t remember', 7, '53650eb3-9aef-42c6-9635-bf4c8f68a66d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62303, '', 'n/a', 58301, 'I''d rather not say', 8, '53650eb3-9aef-42c6-9635-bf4c8f68a66d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71491, '', '190', 59907, '190', 209, 'b6e412b0-0c48-4469-9c96-7e62b5b49c13');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71492, '', '191', 59907, '191', 210, '64922cb1-fdff-479f-a3fd-5d99f3049b14');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60711, '', 'y', 60586, 'Yes', 1, '4cfb10a1-57ed-40fe-b8e0-db5f1169cee3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60712, '', 'n', 60586, 'No', 2, 'da87ea31-81bd-4b7a-a195-e0bef9cef67d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60713, '', 'n/a', 60586, 'I''d rather not say', 3, '8682c6fe-710c-4726-b2cd-94d3bf07502c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71493, '', '192', 59907, '192', 211, '186eba9f-792a-4325-b859-0e9e27e96a06');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71494, '', '193', 59907, '193', 212, '4ea279f9-2bd8-473f-a523-fea4e0e073a5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71495, '', '194', 59907, '194', 213, 'd0f40255-1230-4e4e-ab13-e85bed367ee0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71496, '', '195', 59907, '195', 214, '8baf6c49-e1f7-460f-93e1-9488a993ec8b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71497, '', '196', 59907, '196', 215, '0c774a84-e80f-4147-9e37-248f3754f10e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71498, '', '197', 59907, '197', 216, '289a82eb-18bd-4f86-807b-588890b2be42');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71499, '', '198', 59907, '198', 217, '9622aa93-cfcc-445b-84cd-82e8b589ba81');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71500, '', '199', 59907, '199', 218, '46d26ee3-b3cc-4a1d-86a1-6063e5c9168a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71501, '', '200', 59907, '200', 219, '2d8997b1-c65c-4a87-b9de-a9dc3a61a85b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71502, '', '201', 59907, '201', 220, 'cce5f4a0-c994-4f07-bba7-a2c25d8f033f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71503, '', '202', 59907, '202', 221, 'f21f0f8a-6962-45db-bf50-02719882bac2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71504, '', '203', 59907, '203', 222, 'df649c89-868e-46de-9989-28e424403355');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15318, '', 'AL', 7685, 'Alabama ', 2, '3c42363d-0d78-48be-a29e-8485f3f310a9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15319, '', 'AK', 7685, ' Alaska', 3, '3b8bf1a3-4366-4f2b-bcf1-b2656b2de726');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15380, '', 'AZ', 7685, ' Arizona', 4, 'e162c8bb-90bf-4817-b425-be5a814173b6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15381, '', 'AR', 7685, 'Arkansas', 5, '20384640-998f-439f-8673-874f037e90d9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15382, '', 'CA', 7685, ' California', 6, '26926132-af0c-4abb-882b-afc4d570942c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15383, '', 'CO', 7685, 'Colorado', 7, '07d6b045-77f8-45d6-a007-7d887b2fa9a6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15384, '', 'CT', 7685, ' Connecticut', 8, 'f4ed0335-1c08-4b4a-b786-97f874f50b1f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15385, '', 'DE', 7685, ' Delaware', 9, '8c6acd14-2d14-43d5-b22d-89acbcb19328');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60332, '', 'not at all', 59919, 'Not at all', 0, '9e87780d-2adc-402b-8cf8-c2eb9368300a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60333, '', 'little', 59919, 'A little bit', 0, 'a2f037bd-7c88-4d77-825f-b0fcacdb7a11');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60334, '', 'somewhat1', 59919, 'Somewhat', 0, 'd8b0e305-2fdf-4345-ac96-08d340ae7419');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60335, '', 'quite', 59919, 'Quite a bit', 0, '1ee95d1d-98a8-4ce3-bcae-7b707559e882');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60336, '', 'very much', 59919, 'Very much', 0, 'c6bda2c2-5699-47c1-8afa-f9d6d6552ed4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60337, '', 'NA', 59919, 'Not applicable', 0, '0eef6361-a99d-49d9-98d0-f4473b3cf914');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60338, '', 'n/a', 59919, 'I''d rather not say', 0, '90d60754-fcfd-4f87-9614-71c7ab1b1768');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60339, '', 'not at all', 59920, 'Not at all', 0, 'a0aba5e0-8341-4e6a-9284-b7250d4d42e0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60340, '', 'little', 59920, 'A little bit', 0, '8c81e08b-c1e2-4c93-b6b0-a599ddc957f9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60341, '', 'somewhat1', 59920, 'Somewhat', 0, '5cf02686-e62d-402b-9277-ba465086c2d5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60342, '', 'quite', 59920, 'Quite a bit', 0, '50498877-5a2d-421e-ba6e-6ea405e7af07');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60343, '', 'very much', 59920, 'Very much', 0, '3e6d0ba4-847b-4f9f-b4b7-e2cf9022214f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60344, '', 'NA', 59920, 'Not applicable', 0, '21d59412-5e9b-425d-97ef-c11ed0e58071');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60345, '', 'n/a', 59920, 'I''d rather not say', 0, '59792dcd-01ee-4e5a-bf78-70f21451fd4b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60346, '', 'not at all', 59921, 'Not at all', 0, 'da34c1bd-043e-4119-a5d4-ce9cf3b83c70');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60347, '', 'little', 59921, 'A little bit', 0, 'c4e7460b-fa72-4579-aded-eb3b48ff45f1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60348, '', 'somewhat1', 59921, 'Somewhat', 0, 'b3ac84b9-3a58-4238-8fa7-a418553c8dfc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60349, '', 'quite', 59921, 'Quite a bit', 0, '8a81f60b-176a-4add-81e3-9fb6d9b4fde6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60350, '', 'very much', 59921, 'Very much', 0, '5847c588-93c4-4f3e-aca9-8665e608c80b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60351, '', 'NA', 59921, 'Not applicable', 0, '8f824939-0e65-4a1f-b413-e58655545588');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60352, '', 'n/a', 59921, 'I''d rather not say', 0, '279bfce9-b1db-4e95-b98c-b102c14489de');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60353, '', 'not at all', 59922, 'Not at all', 0, '04a1b31f-b631-4530-9579-add963c9c5a9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60354, '', 'little', 59922, 'A little bit', 0, '479e6520-3b58-452c-a077-e86a43380422');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60355, '', 'somewhat1', 59922, 'Somewhat', 0, '4940e6da-3db8-43b5-a050-734fe05e1636');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60356, '', 'quite', 59922, 'Quite a bit', 0, '14a0c07a-8a89-4861-a150-50ad46af548e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60357, '', 'very much', 59922, 'Very much', 0, '6ad61091-7d91-4bb4-bd7d-f4c430527721');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60358, '', 'NA', 59922, 'Not applicable', 0, '42aeaae1-57e1-41fa-b897-12661532f6fc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60359, '', 'n/a', 59922, 'I''d rather not say', 0, '07667e95-8803-4af5-bb33-26cd399e28a9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60360, '', 'not at all', 59923, 'Not at all', 0, '3efd09f0-0094-4253-8d50-49d1909bf853');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60361, '', 'little', 59923, 'A little bit', 0, 'c935e997-1245-4ef9-8866-6889caddcd6b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60362, '', 'somewhat1', 59923, 'Somewhat', 0, '6e4b1306-19e4-42d5-b8d1-c215af34f2eb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60363, '', 'quite', 59923, 'Quite a bit', 0, '815a6277-a90b-447a-9d46-92321ebd01e1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60364, '', 'very much', 59923, 'Very much', 0, '98514df0-e48a-4256-b017-8d1c93257fb5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60365, '', 'NA', 59923, 'Not applicable', 0, 'ff7f5591-258c-463a-84a0-30e922fd78f1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60366, '', 'n/a', 59923, 'I''d rather not say', 0, '2da60a06-0a77-42b1-abd0-c4e9dc71b6d9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60367, '', 'not at all', 59924, 'Not at all', 0, '88abacac-9d22-44e5-aef4-a28d459c69d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60368, '', 'little', 59924, 'A little bit', 0, 'd8f05e78-b687-4436-a7bd-fdf738151bf2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60369, '', 'somewhat1', 59924, 'Somewhat', 0, 'c7bb1e88-0c3a-458e-bdfc-1f991a1077c2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60370, '', 'quite', 59924, 'Quite a bit', 0, '769c34be-5e29-413b-975f-5da7e88b653b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60371, '', 'very much', 59924, 'Very much', 0, '907fcfbc-7fc8-4dcd-8921-826f053004f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60372, '', 'NA', 59924, 'Not applicable', 0, 'c9e20888-98d2-4e85-b081-a7af784f0cab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60373, '', 'n/a', 59924, 'I''d rather not say', 0, '8a757232-6a88-4884-9ebf-3a7d60be0ac4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60374, '', 'not at all', 59925, 'Not at all', 0, '22cd5b4a-bdfb-4f16-af78-95fb8b9f6f9b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60375, '', 'little', 59925, 'A little bit', 0, 'a55f8abb-6754-47c6-bfff-c119ed4ba97f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60376, '', 'somewhat1', 59925, 'Somewhat', 0, '0d99762f-a56f-4503-8307-755afae2ab37');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60377, '', 'quite', 59925, 'Quite a bit', 0, 'cff7de92-e945-45c6-88c4-707b7690ad14');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60378, '', 'very much', 59925, 'Very much', 0, 'd931f9d1-dc8f-473e-a79e-9aa7fc52a3d8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60379, '', 'NA', 59925, 'Not applicable', 0, '663a1263-1de0-4f90-859c-88d45e1b0f93');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60380, '', 'n/a', 59925, 'I''d rather not say', 0, '8f71475c-418a-4fbe-b961-8596f6623d0d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60381, '', 'not at all', 59926, 'Not at all', 0, '468199cf-cb4a-4a56-a498-1e3c7aa095d6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60382, '', 'little', 59926, 'A little bit', 0, '35b46125-365c-4436-82d1-cfef8b17629f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60383, '', 'somewhat1', 59926, 'Somewhat', 0, 'd8a7b629-6665-494b-a114-c95db255b0c2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60384, '', 'quite', 59926, 'Quite a bit', 0, '585e3eb7-8220-410a-ab6e-16b592f0c264');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60385, '', 'very much', 59926, 'Very much', 0, '32208f82-26cc-456d-9350-92cafdd0b1bd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60386, '', 'NA', 59926, 'Not applicable', 0, '24317d33-23ec-4862-aa44-b70f37e1459a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60387, '', 'n/a', 59926, 'I''d rather not say', 0, 'd884077c-cca8-404a-954d-b9ff6519bae1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15386, '', 'FL', 7685, ' Florida', 10, 'd686037d-58bf-46e4-9d2f-5a093e239b45');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60388, '', 'not at all', 59927, 'Not at all', 0, '74968b90-58ff-49e4-83da-41b55ac55f89');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60389, '', 'little', 59927, 'A little bit', 0, 'a69a8dd3-a0ca-4519-8ab8-bfc082c889f8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60390, '', 'somewhat1', 59927, 'Somewhat', 0, '1fff53d5-a97e-4187-8361-4c94952dcf58');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60391, '', 'quite', 59927, 'Quite a bit', 0, '3da93006-aba3-4958-b624-819ce3f77663');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60392, '', 'very much', 59927, 'Very much', 0, '41d1522b-eb5d-42e6-a98e-8638ac179337');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60393, '', 'NA', 59927, 'Not applicable', 0, '57e09c3c-6288-4e00-ab88-07481399b91f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60394, '', 'n/a', 59927, 'I''d rather not say', 0, 'ac980e01-5434-47d2-ac2e-7d2076783e40');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60395, '', 'not at all', 59928, 'Not at all', 0, '82e72995-edd6-4093-a588-df6324f2f140');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60396, '', 'little', 59928, 'A little bit', 0, '43055f03-2175-41d3-b5f4-abb5b49bfcc4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60397, '', 'somewhat1', 59928, 'Somewhat', 0, '8f580e04-05b2-4010-b059-b871df4bfcf8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60398, '', 'quite', 59928, 'Quite a bit', 0, '7b0b2e62-9fcb-40b4-b4c2-a1691c892fc9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60399, '', 'very much', 59928, 'Very much', 0, '716b0f70-964c-4586-9009-27c656cd386a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60400, '', 'NA', 59928, 'Not applicable', 0, '509baca9-31c4-4ac4-bb36-9e3bf1f2e1e7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60401, '', 'n/a', 59928, 'I''d rather not say', 0, '3a1b3c56-9c3d-4351-a7ae-0dc0d87ae578');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60402, '', 'not at all', 59929, 'Not at all', 0, '48f0004d-e491-472c-a3a9-6826caae502c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60403, '', 'little', 59929, 'A little bit', 0, 'fb545d61-230d-4dac-b94a-0198fd7411de');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60404, '', 'somewhat1', 59929, 'Somewhat', 0, 'f7411e7f-bab7-42df-b547-ddfc794c592f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60405, '', 'quite', 59929, 'Quite a bit', 0, 'a182988e-7004-447e-aea7-ff003ca7d05f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60406, '', 'very much', 59929, 'Very much', 0, 'cef5e340-d885-46d7-a31e-dc5c44bcd191');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60407, '', 'NA', 59929, 'Not applicable', 0, '98473b17-a85e-480d-8eb2-3ed466dcbb4f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60408, '', 'n/a', 59929, 'I''d rather not say', 0, '852563ff-d7f6-4217-b2ce-5acf235f5994');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60409, '', 'not at all', 59930, 'Not at all', 0, '178f90b4-a5e0-4603-8876-610341364d65');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60410, '', 'little', 59930, 'A little bit', 0, '27df01dd-5762-4328-a1a1-457cd7a4c931');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60411, '', 'somewhat1', 59930, 'Somewhat', 0, 'd1e95680-5944-4740-89bf-f9e3955d2c4a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60412, '', 'quite', 59930, 'Quite a bit', 0, 'c43fe181-961b-428f-bb28-14cb10921dd1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60413, '', 'very much', 59930, 'Very much', 0, 'e93dde09-87fb-4b93-adce-edebc9f5d0f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60414, '', 'NA', 59930, 'Not applicable', 0, '1ce01a10-51cc-48b1-9948-6f879bcb3c77');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60415, '', 'n/a', 59930, 'I''d rather not say', 0, '6493a868-46e2-421b-ad45-c26bc869a8c1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60416, '', 'not at all', 59931, 'Not at all', 0, 'b4b2e5a6-097d-4f67-9944-e6d9eb5a22b6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60417, '', 'little', 59931, 'A little bit', 0, 'ca0fc39c-72f0-41c3-bf1c-a4ff71f080e2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60418, '', 'somewhat1', 59931, 'Somewhat', 0, 'c295a046-893c-4c11-b015-b0892ee8741e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60419, '', 'quite', 59931, 'Quite a bit', 0, '865401a5-d48b-4a63-ba5b-a87c78561597');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60420, '', 'very much', 59931, 'Very much', 0, 'a5163053-761a-4914-b02a-8cc9ab0e3e8f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60421, '', 'NA', 59931, 'Not applicable', 0, 'c950ea7e-438b-478f-a1d0-c1ecddbad716');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60422, '', 'n/a', 59931, 'I''d rather not say', 0, '0b15b99a-cbca-4779-aef4-d52664dc9d12');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60423, '', 'not at all', 59932, 'Not at all', 0, '74ce6b1d-940c-4d43-b62f-686d5b01f3d8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60424, '', 'little', 59932, 'A little bit', 0, '00f68595-83b0-417f-92fc-8c93469284fc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60425, '', 'somewhat1', 59932, 'Somewhat', 0, 'a287491a-1a0f-433a-970b-9cb89ef7560d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60426, '', 'quite', 59932, 'Quite a bit', 0, '716b052e-cafb-4e36-9c5e-ee884b9168bd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60427, '', 'very much', 59932, 'Very much', 0, '52095575-42e6-4d37-b448-b785128d8858');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60428, '', 'NA', 59932, 'Not applicable', 0, 'adea8ee8-4381-4ac4-b2df-a8d2e69d724b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60429, '', 'n/a', 59932, 'I''d rather not say', 0, 'e9bc4696-c0ca-4b52-a6d0-b126986338bb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60430, '', 'not at all', 59933, 'Not at all', 0, '25f23731-874a-4311-8c77-38272324308e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60431, '', 'little', 59933, 'A little bit', 0, '465410e7-fa75-406c-ba3c-13dda93925e0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60432, '', 'somewhat1', 59933, 'Somewhat', 0, 'e13206f1-cdbf-465f-b6e2-2a618e2956f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60433, '', 'quite', 59933, 'Quite a bit', 0, 'fa2e6e68-f33a-4e57-bebf-1a098e058de7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60434, '', 'very much', 59933, 'Very much', 0, 'd27c915d-44da-43f1-8605-6e007316b11c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60435, '', 'NA', 59933, 'Not applicable', 0, '8a2517c1-445c-47b3-9063-c696a659b885');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60436, '', 'n/a', 59933, 'I''d rather not say', 0, '35624871-25e2-461e-910b-bd714432801a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60437, '', 'not at all', 59934, 'Not at all', 0, '154b0853-4c58-4c48-a930-2a2f6b28b6d5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60438, '', 'little', 59934, 'A little bit', 0, 'd48778f4-729e-4d36-b35b-e0ae9ff31a9b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60439, '', 'somewhat1', 59934, 'Somewhat', 0, '646aff95-c8a9-4315-a74b-665fc5e086db');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60440, '', 'quite', 59934, 'Quite a bit', 0, '7303bf30-abcb-4ac6-9a9b-26b3706cab31');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60441, '', 'very much', 59934, 'Very much', 0, '1c0d59f8-d2af-45e3-93a7-bea62e30715a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60442, '', 'NA', 59934, 'Not applicable', 0, '6c5b516a-fb9e-461b-a033-ca27aa6abb1c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60443, '', 'n/a', 59934, 'I''d rather not say', 0, 'a62ae84c-4d21-4726-8343-a090b8f081e9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60444, '', 'not at all', 59935, 'Not at all', 0, 'af28f6d0-ab18-41da-9138-f59b9c6c0baf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60445, '', 'little', 59935, 'A little bit', 0, 'd5f33103-e7bb-43ea-9d4a-66c520f1a873');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60446, '', 'somewhat1', 59935, 'Somewhat', 0, '6debba51-6769-43dc-8ead-1dd4d6fd474f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60447, '', 'quite', 59935, 'Quite a bit', 0, '6297a005-d5e7-460a-aadc-0e1631531a15');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60448, '', 'very much', 59935, 'Very much', 0, '9d9b5b66-2d83-4dd7-9159-64f15d3272c3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60449, '', 'NA', 59935, 'Not applicable', 0, '5171a91e-a61c-44e1-9b92-f9024094f359');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60450, '', 'n/a', 59935, 'I''d rather not say', 0, '545b2b2f-47d0-4171-9965-6e1ff8ec6348');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60451, '', 'not at all', 59936, 'Not at all', 0, 'f98045d4-037c-4800-95f5-0fd6c5e85928');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60452, '', 'little', 59936, 'A little bit', 0, 'c19a3295-0d0b-43ec-a441-9d1b21e6af2f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60453, '', 'somewhat1', 59936, 'Somewhat', 0, 'c8819881-441b-404e-9221-aa37a9d6d7fc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60454, '', 'quite', 59936, 'Quite a bit', 0, '7f4c2837-e448-4c70-8bea-ceb3e3a36fb5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60455, '', 'very much', 59936, 'Very much', 0, 'eb363f8d-a223-4a5c-82dd-2d097864677b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60456, '', 'NA', 59936, 'Not applicable', 0, 'b1406f45-e630-4dd6-afe9-bbc43ab069a4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60457, '', 'n/a', 59936, 'I''d rather not say', 0, '257fd60c-25c3-4b12-b136-9eb3e6de6de8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60458, '', 'not at all', 59937, 'Not at all', 0, '7b2295da-d244-4a0d-9763-38c361db26f6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60459, '', 'little', 59937, 'A little bit', 0, '5a93d23e-ce4e-4044-84c5-6fb113d6e551');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60460, '', 'somewhat1', 59937, 'Somewhat', 0, '1f795f17-1add-4d2d-ac8d-e457752057c6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60461, '', 'quite', 59937, 'Quite a bit', 0, 'e6877904-247b-4fb4-b7f6-d7f3aa5b1434');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60462, '', 'very much', 59937, 'Very much', 0, '3e1f7eb1-113d-4a20-8485-76102794ff05');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60463, '', 'NA', 59937, 'Not applicable', 0, 'd35cb071-efdb-4044-963b-352ff5ceb294');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60464, '', 'n/a', 59937, 'I''d rather not say', 0, '5807b3de-91c0-4ad8-8909-225834422d53');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60465, '', 'not at all', 59938, 'Not at all', 0, '9c7c9067-3b45-4de1-9d03-8f25d01bc7c8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60466, '', 'little', 59938, 'A little bit', 0, '8d33b9c5-024f-4fad-829e-9c4523605466');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60467, '', 'somewhat1', 59938, 'Somewhat', 0, '294c5c08-5e57-41e1-92ae-42d1d312c7bf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60468, '', 'quite', 59938, 'Quite a bit', 0, '63751e4d-55d8-41aa-9e38-b17e7dfa3983');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60469, '', 'very much', 59938, 'Very much', 0, '1b467d1b-3f46-4a45-9eb1-0aac262a4fce');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60470, '', 'NA', 59938, 'Not applicable', 0, 'd35ab646-e247-4128-ae5e-bb12581cdd1c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (60471, '', 'n/a', 59938, 'I''d rather not say', 0, 'dfe150c1-9557-415e-a0d9-f9d0d1b56f16');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15387, '', 'GA', 7685, ' Georgia', 11, '4052b6a2-9e89-4cc3-98e1-82b28fc94a3a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15388, '', 'HI', 7685, ' Hawaii', 12, 'b062af74-1758-4922-a0c5-a852f054b19b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15389, '', 'ID', 7685, ' Idaho', 13, '5eaa2163-f2be-435c-b018-946dd207daee');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15390, '', 'IL', 7685, ' Illinois', 14, '786efcad-107c-44fa-aa25-3f2f606de90e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15391, '', 'IN', 7685, 'Indiana', 15, '0c31a8f8-becd-40cc-a407-acd216f6cb46');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71956, '', '', 61924, 'Date of Birth (mm/dd/yyyy e.g. 07/22/1950):', 1, '45afae76-fd6f-4892-b496-d97fdff5b56d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15392, '', 'IA', 7685, ' Iowa', 16, '13f5ed72-0580-4c12-bf3e-490c2aef41f9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15393, '', 'KS', 7685, 'Kansas', 17, 'fa8315fb-5349-40e8-a0a6-29fc6d4ae8de');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15394, '', 'KY', 7685, ' Kentucky', 18, '2dbfddf0-7b79-4912-8cee-cdfe03b7481e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15395, '', 'LA', 7685, 'Louisiana', 19, '77242af4-cb32-49ae-b6c6-504dde6e9097');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15396, '', 'ME', 7685, ' Maine', 20, 'db0924e8-385a-46f1-993e-0c28f649f5d0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15397, '', 'MD', 7685, ' Maryland', 21, 'a57ecf4c-0a3e-48ff-a955-f83a3df8b8b5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71957, '', 'selection', 61922, 'Select select your state ', 1, '370896ef-4de8-42f8-893b-a5ea65a40c91');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71958, '', 'AL', 61922, 'Alabama ', 2, '0182e0ae-068b-43c0-82fd-166f034f9e77');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71959, '', 'AK', 61922, ' Alaska', 3, '6211dd73-e04d-48e9-b2bf-f0c9179d4e9b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71960, '', 'AZ', 61922, ' Arizona', 4, 'c70e0a69-43d0-4347-b00a-217f79765389');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71961, '', 'AR', 61922, 'Arkansas', 5, '1383eba7-e102-45fb-8a6c-85375963648a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71962, '', 'CA', 61922, ' California', 6, '1718d471-f560-41f8-8bfd-68d5519034cb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71963, '', 'CO', 61922, 'Colorado', 7, '8fcd4a38-b105-4b3f-81e8-cb3e5bfb6b49');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71964, '', 'CT', 61922, ' Connecticut', 8, 'f8afbf82-fc3d-4d20-8922-598428016448');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71965, '', 'DE', 61922, ' Delaware', 9, '67ced59a-9955-4562-aca1-466f01641458');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71966, '', 'FL', 61922, ' Florida', 10, 'e4d1a37c-8f07-4b9c-9d86-e3e236cf13df');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71967, '', 'GA', 61922, ' Georgia', 11, 'f0b33dbe-5538-490e-bd22-f2e5e562ea3c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71968, '', 'HI', 61922, ' Hawaii', 12, '23c184c4-78f7-47c0-98ff-fd423cac87c9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71969, '', 'ID', 61922, ' Idaho', 13, '99a2898a-8c99-4bb0-99eb-52574a838f88');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71970, '', 'IL', 61922, ' Illinois', 14, '78ffcfaf-0e81-4808-81ea-b9a4e175b9a7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71971, '', 'IN', 61922, 'Indiana', 15, 'f49a9d5c-ca81-46a9-9fd8-c4b15c5fb6f8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71972, '', 'IA', 61922, ' Iowa', 16, 'ca5f5846-dfc2-434b-87b6-174153144d2b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71973, '', 'KS', 61922, 'Kansas', 17, 'acd6597c-7518-429f-8f39-146deea1f970');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71974, '', 'KY', 61922, ' Kentucky', 18, '4d54cb95-f764-4d08-b861-fe7edc698c68');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71975, '', 'LA', 61922, 'Louisiana', 19, '4edb0e3b-0624-44f8-8154-65a1c5736d27');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71976, '', 'ME', 61922, ' Maine', 20, '505db018-28f4-42c5-921c-25031b26c354');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71977, '', 'MD', 61922, ' Maryland', 21, '927ed9e6-0094-4503-b409-a192a4d86699');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71978, '', 'MA', 61922, 'Massachusetts', 22, '70e97cc7-8cc3-40bb-bda5-b3b73ce76438');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71979, '', 'MI', 61922, ' Michigan', 23, 'f32b73bd-19bb-47f0-abf2-5914103915cb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71980, '', 'MN', 61922, ' Minnesota', 24, 'b2e3b7fb-7c6a-48a2-b640-24a72565ac26');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71981, '', 'MS', 61922, ' Mississippi', 25, '77e123ac-120f-4dbe-8e54-f9e184957453');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71982, '', 'MO', 61922, 'Missouri', 26, 'b46ff7e2-60a3-44ff-91b5-38d6d66192bb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71983, '', 'MT', 61922, 'Montana', 27, 'beb1b99e-bb23-4114-a606-4e19475fbd1a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71984, '', 'NE', 61922, 'Nebraska', 28, '68843044-a38c-4abd-b273-b4519937fba5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71985, '', 'NV', 61922, ' Nevada', 29, '927aa77d-cfff-425f-ba04-1eaf593f930c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71986, '', 'NH', 61922, ' New Hampshire', 30, '9def2c4a-ebed-4527-aae1-5eff8105ad7e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71987, '', 'NJ', 61922, ' New Jersey', 31, '1aba80e0-2b74-4d04-8b75-422b56025290');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71988, '', 'NM', 61922, ' New Mexico', 32, 'ba2bacd1-ea77-436a-a31a-ca4548442a01');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71989, '', 'NY', 61922, ' New York', 33, '408ce2b4-0a00-42b7-9c3a-be3d37bdcc2d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71990, '', 'NC', 61922, 'North Carolina', 34, '4efbb896-c1e7-409e-970e-10cb65088cca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71991, '', 'ND', 61922, ' North Dakota', 35, '137c5d20-00f9-480f-a7f2-74d2834dd119');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71992, '', 'OH', 61922, ' Ohio', 36, '4603aa77-5098-499b-815d-e9add14fff27');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71993, '', 'OK', 61922, ' Oklahoma', 37, '1943f6d4-b95d-4a3b-887b-2310c2ec6547');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71994, '', 'OR', 61922, 'Oregon', 38, '856f68e3-e91f-42e5-8307-a2384df71a56');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71995, '', 'PA', 61922, ' Pennsylvania', 39, '22b54d77-b411-4279-99e0-280e118bd92c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71996, '', 'RI', 61922, ' Rhode Island', 40, '606622f8-02ae-4e17-88a3-95070a104276');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71997, '', 'SC', 61922, 'South Carolina', 41, '9e14ff79-644f-4520-b1cc-63bd8d241517');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71998, '', 'SD', 61922, 'South Dakota ', 42, 'dffee144-06bd-4bb8-be72-2d6685aa2a4d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71999, '', 'TN', 61922, 'Tennessee', 43, 'e46f4a53-8fb9-475a-8260-a2bc725157a5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72000, '', 'TX', 61922, ' Texas', 44, '6bf0733e-b888-42aa-8e59-295a3e35a993');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72001, '', 'UT', 61922, ' Utah ', 45, '6f5c9259-f691-4a71-a5b6-0809c7cd1c57');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72002, '', 'VT', 61922, ' Vermont', 46, 'de06c351-519b-4487-917f-b3bab2e85e09');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72003, '', 'VA', 61922, ' Virginia', 47, '93019be2-9a78-4fd7-82ef-b006e3c36c17');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72004, '', 'WA', 61922, 'Washington', 48, '812c04cc-bde6-42b2-989e-272f1d491910');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72005, '', 'VA', 61922, ' West Virginia', 49, '58ab0bf8-e45d-4e36-b3df-f077ee125d41');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72006, '', 'WI', 61922, 'Wisconsin', 50, '68095098-b97d-4b4f-8cd4-9e4caee8c604');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72007, '', 'WY', 61922, 'Wyoming', 51, 'f5194268-cf00-488a-8bb8-b38c77338009');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15398, '', 'MA', 7685, 'Massachusetts', 22, '161a1367-657b-4f92-8db8-a6a596519bc7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15399, '', 'MI', 7685, ' Michigan', 23, '76378db6-7348-4f7f-9b2a-85b2ff6c2628');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15400, '', 'MN', 7685, ' Minnesota', 24, 'b73e86dd-a9b3-4b5f-b08f-db37de30b405');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15401, '', 'MS', 7685, ' Mississippi', 25, 'd649040a-90ac-43b0-bc3d-f8ebe8ae32ac');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15402, '', 'MO', 7685, 'Missouri', 26, '9c5ff9f2-3cfd-4744-9505-a6ba87c624bd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15403, '', 'MT', 7685, 'Montana', 27, '61227e09-ee1f-448f-a2d7-17c9f17000a3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15404, '', 'NE', 7685, 'Nebraska', 28, '8bfc1ca5-c781-48f3-93df-8fa73d3868a1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15405, '', 'NV', 7685, ' Nevada', 29, 'c8847eeb-e4e3-449b-92be-f04015f4c41b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15406, '', 'NH', 7685, ' New Hampshire', 30, 'f3c85eba-2757-4912-a72e-f2c68ae2a0e4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15407, '', 'NJ', 7685, ' New Jersey', 31, 'afe5da07-996c-492e-8055-5a15c9b9affb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15408, '', 'NM', 7685, ' New Mexico', 32, 'ee9debf6-988c-403d-a60f-0367afa5902a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72008, '', '', 61921, 'Phone Number (XXX-XXX-XXXX e.g. 978-902-5321)', 1, 'dea92828-5170-46f1-b8b8-748d7efac1bd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72009, '', '', 61923, 'Fax Number (Optional)( XXX-XXX-XXXX e.g. 978-902-5321) :', 1, 'bf405a93-4352-4614-be14-86511c67e6eb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15409, '', 'NY', 7685, ' New York', 33, '152f6a07-9688-4f47-bdc2-18cfde654933');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71505, '', '204', 59907, '204', 223, '359d2a94-fda9-4466-a918-1facb7d35639');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15410, '', 'NC', 7685, 'North Carolina', 34, '7bcc397c-6b8a-416a-85df-6a73b46573da');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71506, '', '205', 59907, '205', 224, 'fc28b565-5def-42fd-90df-231018a0595a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71507, '', '206', 59907, '206', 225, 'fba525b2-0a5e-4f36-b48f-e599d8fdd853');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15411, '', 'ND', 7685, ' North Dakota', 35, '9c8d2e9c-d56a-472d-af24-e5a64b75fff2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15412, '', 'OH', 7685, ' Ohio', 36, '08955b21-a6bd-4040-a71a-94bd7c7f9eea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15413, '', 'OK', 7685, ' Oklahoma', 37, 'b473ed8a-5ed5-4e06-9188-a3ae1ed5a7bb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15414, '', 'OR', 7685, 'Oregon', 38, 'f625165d-3428-4ba1-8b6c-d7fae2fb5874');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15415, '', 'PA', 7685, ' Pennsylvania', 39, '1a80f4c9-10ad-4239-8e90-9c3975130c18');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15416, '', 'RI', 7685, ' Rhode Island', 40, 'fbc102b5-5d2e-49d7-a401-b6d98082f818');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15417, '', 'SC', 7685, 'South Carolina', 41, 'd3b13952-a751-4608-a9fd-9c11a5da0994');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15418, '', 'SD', 7685, 'South Dakota ', 42, '9968e7f7-e86d-487d-b51d-222fada05970');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15419, '', 'TN', 7685, 'Tennessee', 43, '45f91684-1a17-46a4-a86b-14d3690fd76b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15420, '', 'TX', 7685, ' Texas', 44, '45bbaac7-f684-4bd7-aacb-b9faf04dd491');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15421, '', 'UT', 7685, ' Utah ', 45, 'a30c2cd8-22c6-496c-8c30-949bf4a77c75');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15422, '', 'VT', 7685, ' Vermont', 46, 'b3a1f956-abbb-4253-97b9-0bcebf7b7c8b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15423, '', 'VA', 7685, ' Virginia', 47, '5db0a53c-9fbd-4c72-bf45-e3933b352954');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15424, '', 'WA', 7685, 'Washington', 48, 'd152137c-1940-426f-98e6-691c2dd5e9a2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15425, '', 'VA', 7685, ' West Virginia', 49, 'b0f854b1-33b8-4722-990d-58088b085077');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15426, '', 'WI', 7685, 'Wisconsin', 50, 'e4058df4-6570-46c8-a9a4-720dd8babba4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15427, '', 'WY', 7685, 'Wyoming', 51, '5d213df0-40c9-496c-9e95-35199381627f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72012, '', '', 69286, 'First Name:', 1, 'c52db0fe-b40d-457f-afee-b3e11c9e4bf7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72013, '', '', 69292, 'Email:', 1, '018c3366-18bc-46f6-9bce-c3c57fd7fcbd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72014, '', '', 69290, 'Fax (Optional):', 1, '116ca3d1-e6b1-464d-9c67-284b1d1b5402');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62991, '', 'selection', 58783, 'Select One', 1, '3686352f-07ad-40e8-bc06-08faf50a187b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62992, '', '<10', 58783, '<10', 2, '6c778d97-5707-421d-ae3a-236d99d23a84');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62993, '', '10', 58783, '10', 3, '4ce1141d-8abf-40ae-9e02-3d4f257a35ca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62994, '', '11', 58783, '11', 4, 'cee3e25a-27b5-4131-ba42-f66ea06d8b5c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62995, '', '12', 58783, '12', 5, '31555d0b-9d9d-4fcd-9ed0-eb933ff21db1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62996, '', '13', 58783, '13', 6, 'e783fccb-8700-4725-86ed-376fcbf753c1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62997, '', '14', 58783, '14', 7, 'bc537dd1-73c3-4dbf-9981-5ab485589c58');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62998, '', '15', 58783, '15', 8, '72f9a461-fdd9-41d2-8e07-5900b70b2641');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (62999, '', '16', 58783, '16', 9, '2834683d-6d5d-4341-be44-15db1051b35f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63000, '', '17', 58783, '17', 10, '0dddc196-31b3-4da6-b838-b63114d1bf61');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63001, '', '18', 58783, '18', 11, 'fe4da8f2-1bae-461f-b51d-05e1f303f9d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63002, '', '19', 58783, '19', 12, '5fdb2d15-ae9d-499a-8080-d5b6e6dcc13c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63003, '', '20', 58783, '20', 13, '6035d559-a90b-4674-a760-cf115a15698b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63004, '', '21', 58783, '21', 14, 'b85bf425-b95f-472d-9ae5-fe4b0090310a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31263, '', 'Bothered quite a bit', 15572, 'Bothered quite a bit', 6, '9158e89f-2426-4839-b2bd-2db9cc9e2070');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24282, '', '1', 12137, 'No', 0, '26a31c72-e936-4e66-a24d-a2998249f0cd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24283, '', '2', 12138, 'Yes', 0, '2f0c6d26-5f2e-47e4-a1cb-82a546d7074f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24284, '', '1', 12138, 'No', 0, 'b01d3654-2f6e-4e34-a29d-966a5b623b19');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24285, '', '2', 12139, 'Yes', 0, '10e4d1d7-b4bb-4153-8488-33fd83b2a8f4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24286, '', '1', 12139, 'No', 0, '913ed42d-0729-4085-b78d-5f8a59bd098a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24287, '', '2', 12145, 'Yes', 0, '16969c4f-35a8-4a07-90fa-9659146cc475');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24288, '', '1', 12145, 'No', 0, '2ff14c48-78bb-4cab-8473-d0215e56cde5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24289, '', '2', 12146, 'Yes', 0, '806a03e0-a114-4808-8ea1-6b84014a401d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63005, '', '22', 58783, '22', 15, '3043b3e7-0dc2-4ed0-9a4c-779c7c922bc7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63006, '', '23', 58783, '23', 16, 'd2f45508-037e-4b7a-bb7d-977b6f565c28');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63007, '', '24', 58783, '24', 17, '6c6ceec6-098a-452a-b072-51d451c0fe27');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63008, '', '25', 58783, '25', 18, 'dc1a7a30-e603-4894-a0f2-9f9cdf3d87ad');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63009, '', '26', 58783, '26', 19, 'c2919ac0-66b6-4e83-9376-fcfb4fec1a54');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63010, '', '27', 58783, '27', 20, '3f6a1c0e-183c-46c7-ac69-b81b08ac1759');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63011, '', '28', 58783, '28', 21, '611a86fb-1011-4a54-b0c9-cba64c9d4c69');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63012, '', '29', 58783, '29', 22, '940738ff-7283-4d3c-be97-5e721b5751d0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63013, '', '30', 58783, '30', 23, '77934b90-3c20-4843-8857-9c273d8d6e17');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63014, '', '31', 58783, '31', 24, '82d74dbd-f6eb-4061-9979-7af660c97e9f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63015, '', '32', 58783, '32', 25, 'f7bab1de-5073-4f93-b80f-cda4df0cdd97');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63016, '', '33', 58783, '33', 26, '6a20b505-290a-4016-b15d-a865e0554bf2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63017, '', '34', 58783, '34', 27, '79cda943-ae95-491b-ae52-79d2f6cb2687');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63018, '', '35', 58783, '35', 28, '3172b841-832e-4a95-8ec1-0305413b33fe');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63019, '', '36', 58783, '36', 29, '57294efd-97dc-4cb1-865b-5799fc7d9e55');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63020, '', '37', 58783, '37', 30, 'd332345d-66ae-4b6f-9839-ee20644fdcc8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63021, '', '38', 58783, '38', 31, '55f1a561-bba8-4661-91ed-3469d81f8071');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63022, '', '39', 58783, '39', 32, 'a57ad48f-5a60-4a0e-b9b5-31d7a5d75346');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63023, '', '40', 58783, '40', 33, '72c64557-e39f-46d0-9429-92d37da7562c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63024, '', '41', 58783, '41', 34, 'dd954c55-fab3-4015-8570-0c4ac746a674');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63025, '', '42', 58783, '42', 35, 'eb3b0586-5c11-49eb-a4d4-6f2127e52aa4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63026, '', '43', 58783, '43', 36, '568d45e6-685e-407c-9a5e-331731935563');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63027, '', '44', 58783, '44', 37, '7810f71c-4f0c-4887-8b0c-62e836f2a5da');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63028, '', '45', 58783, '45', 38, 'b309af67-c68b-4990-8890-9fb28d218d3e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63029, '', '46', 58783, '46', 39, 'b781243c-9530-4212-9d95-33d91de25d22');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63030, '', '47', 58783, '47', 40, '419fd4be-07e9-467b-a7fe-9fe33f761d7f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63031, '', '48', 58783, '48', 41, 'd4c63124-4458-4dce-befb-8bda35493c7b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63032, '', '49', 58783, '49', 42, 'a2661184-0943-4377-ad58-161ce74b129a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63033, '', '50', 58783, '50', 43, '1d1b4965-817e-4fe4-8c72-955d6f3ccb1a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63034, '', '51', 58783, '51', 44, 'b22d5ada-d6aa-42f8-9775-e19cd2b0a424');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63035, '', '52', 58783, '52', 45, 'eaef03af-3185-4170-abcf-d69a6bfcc316');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63036, '', '53', 58783, '53', 46, '9925843d-277a-4704-97bc-68bea33764c4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63037, '', '54', 58783, '54', 47, '80eafdc4-a598-4b4a-ab70-2c84f8491c48');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63038, '', '55', 58783, '55', 48, '8ab2451c-1544-4049-8da3-b1c3b77dc730');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63039, '', '56', 58783, '56', 49, 'd33cfe20-605a-438a-8250-924ad387ae7b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63040, '', '57', 58783, '57', 50, '3b7e596b-90c5-4219-bb9a-100d0fc07ec9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63041, '', '58', 58783, '58', 51, '6fd6a4b4-89a5-4df8-966d-ba61589d73fa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63042, '', '59', 58783, '59', 52, '634da0f7-dc96-4d11-8d41-ce816445f64e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63043, '', '60', 58783, '60', 53, '34dd82c4-6734-4740-9ba0-b2ba45901756');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (63044, '', '60>', 58783, 'Over 60', 54, 'e4d78ef4-de3d-4aa5-b3ed-62e341fe481a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15428, '', '', 7686, 'Zip:', 1, '7e823cd7-2e2b-404b-a6fe-78b6ee427d5a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15516, '', 'Female', 57855, 'Female', 1, '9b8490fe-fc09-47aa-9795-02f91fdbba3c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15517, '', 'Male', 57855, 'Male', 2, '97f69955-6089-4fe9-a766-78ae3747c578');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31264, '', 'Somewhat bothered', 15572, 'Somewhat bothered', 7, 'b128d7f9-e403-40a6-ac5b-2ada12aeeb15');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31265, '', 'Bothered a little bit', 15572, 'Bothered a little bit', 8, 'd8661f17-9cc2-4536-80a4-d5b11b85f96e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31266, '', 'Not at all bothered', 15572, 'Not at all bothered with it', 9, '46e239ca-299b-4fb4-95a8-11712a18b473');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31267, '', 'Not at all', 15572, 'Not at all', 10, 'd1aca366-2ce2-435e-bb51-c13edd331d38');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31268, '', 'A little bit', 15572, 'A little bit', 11, '92c0600a-3900-4384-bf73-cff9a3624f6f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31269, '', 'Somewhat', 15572, 'Somewhat', 12, 'ddc52b82-14b2-4d56-b052-ceb7dbc90517');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72015, '', '', 69288, 'Middle Initial:', 1, '4413cc2f-a5c2-45e6-9031-0c1e1525c244');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31270, '', 'Quite a bit', 15572, 'Quite a bit', 13, '5e6bb488-d68f-4152-824c-f4f0f359f2cd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31271, '', 'Very much', 15572, 'Very much', 14, '85f8f286-7e69-479a-b1f9-735f33e8ac88');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69852, '', 'family', 69297, 'Family member', 1, 'e942799c-956c-41bb-a1f0-14bdaa0ecaa3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69853, '', 'friend', 69297, 'Friend', 2, '8114d03e-db99-4255-b99c-b5bd73360536');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17633, '', 'select one', 8784, 'Please select one:', 1, 'aa6e8b5f-761e-468a-9607-3ac56b1caeb6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17634, '', '1', 8784, 'No', 2, '12f29ecf-f5bd-4e3b-8ed2-85547a767301');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17635, '', '2', 8784, 'Yes', 3, '04134faf-2d9d-4c94-9f79-4e29772a5746');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69854, '', 'doctor', 69297, 'Doctor or Nurse', 3, '290f9e46-d935-4368-a377-735b7de4b262');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69855, '', 'n/d', 69297, 'I''d rather not say ', 4, '381769b8-bedb-41b3-b3e5-a4d61ef7fa31');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69856, '', 'other', 69297, 'Other specify', 5, '24fbbb82-0166-4f75-be51-801668637bdc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69969, '', 'yes', 58765, 'Yes', 1, '46157233-c4d0-40e8-80ca-32a782bd3967');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69970, '', 'no', 58765, 'No', 2, '963463e4-d46d-4a2d-8543-6d3c10ce7a5b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69971, '', 'not tested', 58765, 'Not Tested', 3, 'ebf617a3-8ed2-4d13-8109-1c36e266ae77');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69972, '', 'dont know', 58765, 'I don''t know/I can''t remember', 4, '60847865-f119-47de-92fe-119cc2b7736c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69973, '', 'n/a', 58765, 'I''d rather not say', 5, 'a04e37d1-abb2-42e4-b749-38e078511b3c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72016, '', '', 69289, 'Phone :', 1, '38a01423-6131-42d3-a255-83f9c9aecf13');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71508, '', '207', 59907, '207', 226, '68b3e5df-1390-43c0-adf1-a00aa7b26b22');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71509, '', '208', 59907, '208', 227, '09c60304-5820-47d0-a289-c65dc6eaf684');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71510, '', '209', 59907, '209', 228, '51d6551c-dcc4-4c69-a1e3-722ed151ffbb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71511, '', '210', 59907, '210', 229, '0cb27c7b-44f1-4570-9401-64369c10f6c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71512, '', '211', 59907, '211', 230, '39ca365a-8f62-4004-8549-d1b60271439c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67406, '', 'y', 59940, 'Yes', 0, '652daafe-fec5-46ae-a695-065409bd9d0d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67407, '', 'n', 59940, 'No', 0, '2f08c592-53be-4e15-8cff-ad4d2d19dd53');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67408, '', 'y', 59941, 'Yes', 0, 'a7a0c398-6909-4c9c-876f-3b23e85022c8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67409, '', 'n', 59941, 'No', 0, '7a09d3f6-e955-4b70-96e4-b18779f8733a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67410, '', 'y', 59942, 'Yes', 0, '043de0f7-eead-47b3-8422-721bd735044f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67411, '', 'n', 59942, 'No', 0, 'b6054fdb-fdd9-4e29-903c-3b46a333870d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67412, '', 'y', 59943, 'Yes', 0, '20c28e91-4a26-4c1a-a1ce-e4a8cbd38119');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67413, '', 'n', 59943, 'No', 0, '2791f201-0328-4e02-b9e4-9ce259d1ae6d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67414, '', 'y', 59944, 'Yes', 0, 'e1b4f149-3260-416c-9e01-8a8404329877');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67415, '', 'n', 59944, 'No', 0, 'b46135ee-309c-4b96-a7d4-ae8e59657656');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67416, '', 'y', 59945, 'Yes', 0, 'c30d709d-641c-4fba-b409-95f8ff74e7c9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67417, '', 'n', 59945, 'No', 0, '6ded025a-69c4-4a11-baf9-b76a523281db');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67418, '', 'y', 59946, 'Yes', 0, '3f548483-4d97-4288-828c-819f6954bed8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67419, '', 'n', 59946, 'No', 0, '85ac8fd2-80d5-4144-a519-ebb0f1db5eac');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67420, '', 'y', 59947, 'Yes', 0, '4489a244-0bd4-4671-a898-427740401e0a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67421, '', 'n', 59947, 'No', 0, '50db191a-e518-4e59-9c43-4cf0bfb078bd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67422, '', 'y', 59948, 'Yes', 0, 'fb203f4a-79e5-42aa-b857-263f7a642ac6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67423, '', 'n', 59948, 'No', 0, '8bc4cd2f-791b-4d7f-8342-b81ed575ffb1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67424, '', 'y', 59949, 'Yes', 0, 'c2bf6758-4ac0-43ee-9760-3ebb82db7a35');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67425, '', 'n', 59949, 'No', 0, 'a8722555-f40a-4eda-9197-be288225e9c3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67426, '', 'y', 60550, 'Yes', 0, '8cbcd3df-2b84-4de2-aee7-1f443e69f4fb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67427, '', 'n', 60550, 'No', 0, 'ace8531e-e3fe-44e5-ae28-566311e49a38');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67428, '', 'y', 60551, 'Yes', 0, '170b13d2-91f0-47a9-88b7-7b4a9e1a27ef');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67429, '', 'n', 60551, 'No', 0, '45ec78aa-0308-485b-8485-cedd06d8fac8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67430, '', 'y', 60552, 'Yes', 0, '8c764615-e9bd-49ce-8c25-c907645073d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67431, '', 'n', 60552, 'No', 0, 'fb9bd502-bfd2-4183-89cd-d21f444a114c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67432, '', 'y', 60553, 'Yes', 0, '70340f9f-d9f7-49c6-b053-da048f4e11c6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67433, '', 'n', 60553, 'No', 0, 'cae12acf-ac23-44d9-8047-e2f435c18e81');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67434, '', 'y', 60554, 'Yes', 0, '344ff2c0-15a0-4cc4-88e3-8c8522efca6d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67435, '', 'n', 60554, 'No', 0, 'e365de9f-1480-4c22-92a3-7cf1158139aa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67436, '', 'y', 60555, 'Yes', 0, '5b8e2316-1178-412e-94de-bcbb3cb27e17');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67437, '', 'n', 60555, 'No', 0, '34361805-3a2b-487d-b5b8-35208031a278');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67438, '', 'y', 60556, 'Yes', 0, '32957b3b-a64f-4906-9ab9-9bb2c14f4273');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67439, '', 'n', 60556, 'No', 0, '274c6675-8465-4a1b-af6e-cac18817c9cf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67440, '', 'y', 60557, 'Yes', 0, '0ff7be9f-b6be-46cf-9cb2-1199988b6279');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67441, '', 'n', 60557, 'No', 0, 'dff03c03-cb2f-4afe-ae58-8e877edb804a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67442, '', 'y', 60558, 'Yes', 0, '11db5b0c-2b3d-4eee-8828-7bffa7fa5625');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67443, '', 'n', 60558, 'No', 0, '43fd1b5f-3741-4cc4-9a7f-23492f47c185');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67444, '', 'y', 60559, 'Yes', 0, 'c03e6089-9ef4-4e02-9cb2-4ed44bdec146');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67445, '', 'n', 60559, 'No', 0, '9a5345b1-36bb-4355-9481-c04bcc7a6086');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67446, '', 'y', 60577, 'Yes', 0, 'b35e162e-71d7-48b2-a5db-2e0ac762cefb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67447, '', 'n', 60577, 'No', 0, 'aaec7771-47cf-427c-bd6c-a72cf42c4d79');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67448, '', 'y', 60578, 'Yes', 0, 'ec2bebbd-7db1-4ab1-a9f5-99103bd8a7f2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67449, '', 'n', 60578, 'No', 0, '325b7eb6-2561-473f-b7f3-40e43445c504');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67500, '', 'y', 60579, 'Yes', 0, '1e517847-7448-4a7e-bb42-244d01dbd406');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67501, '', 'n', 60579, 'No', 0, '3eb9a62e-469d-4190-92f0-5196b7a9a8e7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67502, '', 'y', 60580, 'Yes', 0, '88d8212a-6ee3-4d81-ac91-7386247f7ce9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67503, '', 'n', 60580, 'No', 0, '90db287e-fc2f-4a22-ad60-a3cb8d8b7372');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67504, '', 'y', 60581, 'Yes', 0, 'a77c9322-204a-4175-8943-0601b088eeae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67505, '', 'n', 60581, 'No', 0, '43732ba9-d61d-47dc-86c7-c946e30be016');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67506, '', 'y', 60582, 'Yes', 0, 'bcc6e108-9aeb-4337-96ce-9d2203d52cd1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67507, '', 'n', 60582, 'No', 0, 'c4323569-0d32-42f8-ad32-c86b5ec0e172');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67508, '', 'y', 60583, 'Yes', 0, '848c7c2f-3e81-4ca3-ae2b-e7ee33327652');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67509, '', 'n', 60583, 'No', 0, '63625c6b-09f2-4b2a-a17e-e2a9de68ffd6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67510, '', 'y', 60584, 'Yes', 0, '66f5c3f7-ca9f-4f80-aa76-1c360cd1113d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (67511, '', 'n', 60584, 'No', 0, 'd75ae92d-782e-46d7-b4f4-e70b123ab4d6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71513, '', '212', 59907, '212', 231, 'cdcbd352-c43c-49a6-8f86-14ec5efff7a5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69858, '', '', 69298, 'Other Specify:', 1, 'b28691e2-52f7-4373-98fc-7663532fea68');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71514, '', '213', 59907, '213', 232, 'a045d3b7-b5ed-4bd3-a36c-f3c3155b3f23');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71515, '', '214', 59907, '214', 233, '2812130b-a26e-40a0-912f-edb48b1aeadd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71516, '', '215', 59907, '215', 234, '7896265e-b896-4861-807a-259e1ec280ee');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71517, '', '216', 59907, '216', 235, '29cf0c7b-ee8c-4456-a5ba-03f56108cedb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71518, '', '217', 59907, '217', 236, '68d81d8c-4aa6-4cbc-a215-ab0c33a164d7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15460, '', '', 7688, 'Email:', 1, '94952aae-8b86-4f47-b784-06c939fd3c1b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72017, '', '', 69291, 'Institution Name (Optional):', 1, 'e3aea173-e93a-477f-a15f-4ae6fa0bab46');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15518, '', 'Less HS', 57856, 'Less than high school', 1, '96ed0f16-6bbf-4e9c-b4dd-037293bcce5c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15519, '', 'Vov Sch', 57856, 'Vocational school', 2, '0d42792d-5a25-4041-85e7-9fb95fbadfe4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15520, '', 'HS', 57856, 'High school             ', 3, '4316caab-cdfd-4056-8546-a38c59fe41b8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15521, '', 'SColl', 57856, 'Some college', 4, 'e51dfdc8-dcf9-4e18-86ba-f4dc4f74ab4c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15522, '', '4 year', 57856, ' 4-year college', 5, '276756af-dc72-47cc-97a6-118b9ffbb291');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71519, '', '218', 59907, '218', 237, 'f00e77aa-a07c-4b30-ac9d-d1870ee37ef1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71520, '', '219', 59907, '219', 238, 'f6e0ec40-d0b2-4a91-8220-6239df12c47a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71521, '', '220', 59907, '220', 239, '3ec0cd8c-8e94-4533-897f-69cdbe16b2df');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71522, '', '221', 59907, '221', 240, 'b2a3bb20-64b1-436d-85ee-cadb427b6822');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71523, '', '222', 59907, '222', 241, 'be58287b-6a63-4dbe-8d84-1c54630dbfdd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71524, '', '223', 59907, '223', 242, '197f393c-d9b2-4207-b355-5832b341634c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72018, '', '', 69293, 'Street Address:', 1, '5d584aa6-9541-4635-bfde-caf53553e411');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69833, '', '', 69282, 'Please specify "Other Race"', 1, 'a0747121-8b2d-4377-becf-a13401ebe08e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71525, '', '224', 59907, '224', 243, 'f01a94c6-f649-48e9-93f6-f670e6afe321');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71526, '', '225', 59907, '225', 244, '1b25ce32-883d-4a3d-9dcb-67a855098859');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71527, '', '226', 59907, '226', 245, '3f2678a5-6301-4188-a519-d102f2680021');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71528, '', '227', 59907, '227', 246, 'd2bdfce3-1414-498a-afd4-34205bc9bcd0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71529, '', '228', 59907, '228', 247, '2b1b972e-3493-4f03-bbc3-baaa67aadc81');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71530, '', '229', 59907, '229', 248, '80229244-09a5-40a4-affa-1b5c07d5a516');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71531, '', '230', 59907, '230', 249, '984147b9-ef46-4149-a481-cae65a84c0bc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71532, '', '231', 59907, '231', 250, 'd05a8ad2-5e06-4022-a3c5-f6b64bd56f96');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71533, '', '232', 59907, '232', 251, '9b35d5c5-2bf1-40a4-92f0-65a7d7122ed4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71534, '', '233', 59907, '233', 252, 'd11b2a2e-1bda-4116-856a-1952a998b5eb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71535, '', '234', 59907, '234', 253, 'dabbb0b2-09e9-4980-87dd-949a96bf2f32');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71536, '', '235', 59907, '235', 254, 'a8d289b4-b7c1-46bd-bb2a-814363009048');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71537, '', '236', 59907, '236', 255, 'dbc51a96-7eb6-4f49-bc9b-625165685f8f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71538, '', '237', 59907, '237', 256, '0c6759d1-d19b-4a0b-8e51-03b004db857c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71539, '', '238', 59907, '238', 257, '7bc08eea-bf1d-40f8-b670-2b2caf21c72e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71540, '', '239', 59907, '239', 258, 'ad476a80-a41f-41d2-a568-ebd31b01523e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71541, '', '240', 59907, '240', 259, '0fa31e6e-a10b-49ac-8f85-0b59f667bc4b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71542, '', '241', 59907, '241', 260, '3800c055-b728-4a07-8f1f-b1fc84a89cca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71543, '', '242', 59907, '242', 261, 'eb15b8bb-131e-43b1-bfae-95eb6df5edc1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71544, '', '243', 59907, '243', 262, 'c9cade11-c781-4754-9b67-0e36a8aef2db');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71545, '', '244', 59907, '244', 263, 'aa4757a0-eaf5-4ce5-9313-86a0563c5d3e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71546, '', '245', 59907, '245', 264, 'b428716e-21d1-40a8-9a3e-1429b3e33d7d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71547, '', '246', 59907, '246', 265, 'e5ba6edb-723b-49c8-aadf-c6f4ffd2ec3c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71548, '', '247', 59907, '247', 266, '4eb56394-373c-4fff-ab03-e3c8990d3a23');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71549, '', '248', 59907, '248', 267, 'dc3da12c-9594-4a76-8519-e7a9855adc6a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71550, '', '249', 59907, '249', 268, 'c75e2512-7e83-4ce2-b4c1-2b6b2596b958');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71551, '', '250', 59907, '250', 269, 'db7e0de1-ca10-42bd-a490-96cb9309f6a1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71552, '', '251', 59907, '251', 270, 'd59b24e5-1b26-4443-8a9d-95ad54ab6830');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71553, '', '252', 59907, '252', 271, '721404a8-ca47-43d7-bcc1-c7f1112f68b5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71554, '', '253', 59907, '253', 272, 'a22e1878-c854-4d3e-93ce-911a3d269796');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71555, '', '254', 59907, '254', 273, 'c7aebcc3-f748-4655-852a-078a9100b324');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71556, '', '255', 59907, '255', 274, '2476465b-94b0-4f5e-9880-539e6e93c454');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71557, '', '256', 59907, '256', 275, 'b94b6989-8c05-4121-b236-b427e050870c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71558, '', '257', 59907, '257', 276, '2a20745f-d994-4c22-805a-32132d6bd107');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71559, '', '258', 59907, '258', 277, '98b4b8b4-53e6-4990-8416-caa79f56166d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71560, '', '259', 59907, '259', 278, 'd6943e99-f8a8-4d0f-bc60-51ca7fdedb75');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71561, '', '260', 59907, '260', 279, '2d421d2c-17d1-46b9-a244-831468440d06');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71562, '', '261', 59907, '261', 280, 'bd66bd01-1f9a-4dc8-980e-64dbecd293a6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71563, '', '262', 59907, '262', 281, '27f8ab6e-082b-4d19-a306-0455a9282070');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71564, '', '263', 59907, '263', 282, 'd7ae776f-55cb-48ad-9eae-38a49acbc6dd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71565, '', '264', 59907, '264', 283, 'c0482ec4-f553-4c3e-8e16-9e8252cadfb4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71566, '', '265', 59907, '265', 284, 'b8f65206-51a4-4451-a96f-01aade4b0f5d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71567, '', '266', 59907, '266', 285, '1718ca18-c5b4-4c3e-9824-b7a9100c0617');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71568, '', '267', 59907, '267', 286, 'd00c08f9-98e5-4252-86a4-ef5eae377244');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71569, '', '268', 59907, '268', 287, '1fde468f-2f4e-449a-8237-bdb2fb7554a4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71570, '', '269', 59907, '269', 288, '4a593051-4677-407c-ac8b-aacc30e6cb1e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71571, '', '270', 59907, '270', 289, 'f4d61d3a-9381-4063-b687-7355f98a39f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71572, '', '271', 59907, '271', 290, '59e6f27b-0092-4937-8fe5-76cdde8ade8d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71573, '', '272', 59907, '272', 291, '3974fde0-13e7-443c-816b-fd6ae0ea805e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71574, '', '273', 59907, '273', 292, '38dad143-bc94-47d3-99fa-2bc7ed648826');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71575, '', '274', 59907, '274', 293, '5c517335-c213-485a-bf41-2b6ad41b36ce');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71576, '', '275', 59907, '275', 294, '8d8c9d6d-5340-4126-8064-1804b18334ab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71577, '', '276', 59907, '276', 295, '0f9f9c74-04e1-4f98-9490-04f6fd915e4c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71578, '', '277', 59907, '277', 296, '4deef6e8-1e7d-4b5b-828a-a26e6a688f3d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71579, '', '278', 59907, '278', 297, 'a6830d64-4dc6-4a93-a466-0632567414a4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71580, '', '279', 59907, '279', 298, '0e4ccf9b-1db4-405b-b2e5-ef4a241464c3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71581, '', '280', 59907, '280', 299, 'b9714897-a459-4d10-8b33-cd6163edea96');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71582, '', '281', 59907, '281', 300, 'dee04c57-e6c9-4b02-a4f3-e74a3fb676da');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71583, '', '282', 59907, '282', 301, 'f7c04b94-43cc-4094-b4bc-088d2d2b535a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71584, '', '283', 59907, '283', 302, '63cba696-ec36-4d0e-950e-3a255e422178');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71585, '', '284', 59907, '284', 303, '66da58e4-f74d-48ad-bce7-0cb959208a6d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69834, '', 'no', 69283, 'No, not Spanish, Hispanic, Latino', 1, '2002c62a-718d-46fe-bfbc-6766564773f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69835, '', 'yes', 69283, 'Yes, Mexican, Mexican American, Chicano', 2, '9082d722-b518-4f5d-80c4-152700e51903');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69836, '', 'Puerto Rican', 69283, 'Yes, Puerto Rican', 3, 'd55ae743-c776-4fb4-8564-983748035477');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69837, '', 'Cuban', 69283, 'Yes, Cuban', 4, 'c705dba0-c65e-45a3-981e-cb3bc53ca9ab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69838, '', 'other', 69283, 'Yes, other Spanish, Hispanic, Latino', 5, '4254afb8-c60e-4b88-8835-c90e5abda8a7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71586, '', '285', 59907, '285', 304, '39b99dfe-3aa9-4f02-b72e-6e2619cab6bb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71587, '', '286', 59907, '286', 305, 'c2305a92-71f9-49a4-acd8-5b0d9793bc78');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69989, '', '1', 59916, '1', 1, 'd72cb08d-2cfd-4ca9-9747-0aeb22a64d91');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69990, '', '2', 59916, '1-2', 2, '2d15ae07-6572-49da-bbfe-23387ebb64c2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69991, '', '4', 59916, '3-4', 3, 'd9fd7558-cbe5-4a6d-8d6d-39fce650a6c2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69992, '', '5', 59916, '>=5', 4, '058705cb-195a-417a-8b33-9aaf501641ae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (69993, '', 'n/a', 59916, 'I''d rather not say', 5, '7ff76c83-f4d5-49a7-bb50-b097039386ae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71588, '', '287', 59907, '287', 306, '7160138a-e1ba-4b39-a61b-bb3305d764f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71589, '', '288', 59907, '288', 307, '31c298ee-1d72-4410-91dd-7e09304e025b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71590, '', '289', 59907, '289', 308, '42e9c5a0-629f-4179-96f2-9f817f4242db');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71591, '', '290', 59907, '290', 309, '558e95e2-cedb-4804-b37c-eb1fd311637b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71592, '', '291', 59907, '291', 310, '5a957183-32ab-4a14-ba5b-e49f182bea15');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71593, '', '292', 59907, '292', 311, '70b2fdb3-82a3-494a-bd95-df9cac0d8705');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71594, '', '293', 59907, '293', 312, 'b50b2379-6009-44e7-8cbf-2fa20cf1318d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71595, '', '294', 59907, '294', 313, '597dd20e-f973-4f9b-8d64-ee45de9fba40');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71596, '', '295', 59907, '295', 314, '86fa9877-2b13-4ed1-8e19-218888d704a2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71597, '', '296', 59907, '296', 315, 'fe5e5be8-9aeb-4e4a-a585-eaecce766fea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71598, '', '297', 59907, '297', 316, 'e1f61671-26f6-4c52-9ab5-735975e2bd87');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71599, '', '298', 59907, '298', 317, 'ba951563-c6b2-4f79-b2e5-7088ef2b19fa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71600, '', '299', 59907, '299', 318, 'bc8f2d66-b77e-4f0b-9a3e-dbd276766b4b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71601, '', '300', 59907, '300', 319, 'd426381b-af43-4ad0-a2b3-6a68936fece4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71602, '', '301', 59907, '301', 320, '0638756a-3df0-4ca2-a463-df584b22ca11');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71603, '', '302', 59907, '302', 321, '43203275-bd6e-4760-bef8-e20a4916f477');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71604, '', '303', 59907, '303', 322, 'c27e146b-f9c3-41b8-b3c7-ec38360d3530');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71605, '', '304', 59907, '304', 323, '43d61513-7185-41ff-9e46-5a64ee90bf4c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71606, '', '305', 59907, '305', 324, 'dbf8b6c9-a583-4bba-ab3d-279397b34a10');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71607, '', '306', 59907, '306', 325, 'ac074d49-c629-449e-8089-f3c2701b02b2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71608, '', '307', 59907, '307', 326, 'd184e906-cdcd-47ec-b6fc-798097c0b89c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71609, '', '308', 59907, '308', 327, 'ae158f98-497e-443b-aac6-260446cef49a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71610, '', '309', 59907, '309', 328, '06a8402e-379d-46f8-80a5-3290945ce128');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71611, '', '310', 59907, '310', 329, '44362bb5-ed77-409a-8d13-5b8f75bb89ea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71612, '', '311', 59907, '311', 330, '9fa763ef-dda3-497d-9378-24d5f28d0d6c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71613, '', '312', 59907, '312', 331, 'b3daf988-8a98-42e8-8864-9a059a4ca206');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71614, '', '313', 59907, '313', 332, 'bc2896d3-85cb-4905-80be-7db52d28a380');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71615, '', '314', 59907, '314', 333, '3a3d3a8d-50c6-45ba-9020-11113bae58bb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71616, '', '315', 59907, '315', 334, '4936c677-d5ab-4f25-9384-608b7cdbc6a5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71617, '', '316', 59907, '316', 335, '0cec159a-bfdc-4c32-a55c-2c8717fc914e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71618, '', '317', 59907, '317', 336, 'b54ee721-52c7-41ad-8d6b-81a42846a075');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71619, '', '318', 59907, '318', 337, '999df4fe-f169-469d-acf2-d520480d2b10');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71620, '', '319', 59907, '319', 338, 'b9bca6db-1778-49e7-9251-ce6036b19bbd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71621, '', '320', 59907, '320', 339, '789cefe5-577f-43a7-83a9-51db1c907443');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71622, '', '321', 59907, '321', 340, '008ac0d8-7130-4dc2-9fcb-fb0c1c5255f5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71623, '', '322', 59907, '322', 341, '9073d31f-529d-4831-9dcc-ea1330a01011');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71624, '', '323', 59907, '323', 342, '986c2d83-4b5c-41cf-9076-efe8cf0e4f78');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71625, '', '324', 59907, '324', 343, '50d84956-5087-4632-a013-fb2413099ef1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71626, '', '325', 59907, '325', 344, '3c2ffcc5-2729-4868-bdf1-9f890c8f0e53');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71627, '', '326', 59907, '326', 345, '366a01e6-9b1f-4d6f-ac1a-4f4ad7430f3b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71628, '', '327', 59907, '327', 346, 'c1920a5f-b2de-4ba3-b2bf-55e2653a409f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71629, '', '328', 59907, '328', 347, 'e06f28fb-07f1-460f-be98-5cd17820781e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71630, '', '329', 59907, '329', 348, '7c161264-71eb-437f-ab82-d1ff37035355');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71631, '', '330', 59907, '330', 349, '8256462f-d7a3-451c-8ec2-d4432f765eca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71632, '', '331', 59907, '331', 350, '12169cf2-11cd-4bf4-a345-2d3eb61d21f8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71633, '', '332', 59907, '332', 351, '75461cd6-2e62-44cd-9b75-77b648102455');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71634, '', '333', 59907, '333', 352, 'b6e74038-2e14-4440-b4a8-9640876b5fcd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71635, '', '334', 59907, '334', 353, '08b1085a-e384-415a-87d7-1a8d73e662ee');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71636, '', '335', 59907, '335', 354, 'e25ccf87-e131-4e32-8386-98c2847eb1a9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71637, '', '336', 59907, '336', 355, 'f17e4a6f-dc78-45a2-9c8c-0fa14d7fefa2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71638, '', '337', 59907, '337', 356, 'aba8ae0f-850f-4b15-8a18-39d5e4035935');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71639, '', '338', 59907, '338', 357, '55af7904-d79b-4dee-9ea8-4441c96bacf9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71640, '', '339', 59907, '339', 358, '1c8ebb97-7d27-4227-8112-bc391adefd89');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71641, '', '340', 59907, '340', 359, '7f367785-5281-417f-a9bb-f17f9f68dafd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71642, '', '341', 59907, '341', 360, '50cba0b9-37a2-41f5-846d-671199ca66ff');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71643, '', '342', 59907, '342', 361, '201cedc9-35b9-471b-9368-9bf034583181');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71644, '', '343', 59907, '343', 362, '78cc1989-18cd-4641-bbc6-a23141887b41');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71645, '', '344', 59907, '344', 363, 'a93c5b1f-8ceb-4bc0-92f3-a8d51ced8db0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71646, '', '345', 59907, '345', 364, 'f288667d-17c4-464e-be8b-1ec324dc7963');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71647, '', '346', 59907, '346', 365, '1ed423b8-886a-41d2-a626-22b14a6cf506');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71648, '', '347', 59907, '347', 366, '1d11b39e-6a88-4907-b9b9-e12e7fc82ad5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71649, '', '348', 59907, '348', 367, 'b1e35e94-cde0-4150-a214-01853c46a7c9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71650, '', '349', 59907, '349', 368, '0cc8720f-db14-4bac-ba86-3b5579de48b0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71651, '', '350', 59907, '350', 369, '6dc26414-e284-41b4-b28b-b85f00dbf09a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71652, '', '351', 59907, '351', 370, 'aab0bbf3-3785-4fe8-8d67-6533b72613a4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71653, '', '352', 59907, '352', 371, 'c4a12c37-1f55-4094-926c-8ade59d106c5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71654, '', '353', 59907, '353', 372, 'ba23d32e-a305-4d2a-bbcf-ff61a1ffb7c1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71655, '', '354', 59907, '354', 373, '9eb1aeb3-b595-4707-95cc-099bab83fd30');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71656, '', '355', 59907, '355', 374, '2b6f2430-b13b-49e5-9a92-c596c445d553');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71657, '', '356', 59907, '356', 375, 'dcb4cfc4-7e3b-45c3-98de-e12488b3179b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71658, '', '357', 59907, '357', 376, 'd4f30476-07a5-484b-8af3-e8e7c8056a82');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71659, '', '358', 59907, '358', 377, 'c38e930c-2475-41e5-96ac-d76a8f771833');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71660, '', '359', 59907, '359', 378, '7310b730-481b-4742-987d-43dfb6e78a89');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71661, '', '360', 59907, '360', 379, '683e1414-2cb1-4d29-b6e9-59910a54bafd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71662, '', '361', 59907, '361', 380, 'fb25eb61-586d-43b6-965d-d6088c728bd6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71663, '', '362', 59907, '362', 381, '5562c3b7-1879-4197-8dfb-3f6fe8030fc2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71664, '', '363', 59907, '363', 382, 'b59da136-2986-4fbb-94b3-0c31766a7fb2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71665, '', '364', 59907, '364', 383, '8021c0f0-926f-46ee-b72a-6a4fc76ad2c6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71666, '', '365', 59907, '365', 384, '2a4d2c32-8953-4e9e-8e5b-b05e5ccbef1c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71667, '', '366', 59907, '366', 385, '5e56cd9b-8e1d-4fa2-b24e-b2dfe577b16c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71668, '', '367', 59907, '367', 386, '804558ab-bbc3-4103-ab17-59dabf18fae9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71669, '', '368', 59907, '368', 387, 'b4093a67-e3ab-4dc4-80a2-8348d395fc1c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71670, '', '369', 59907, '369', 388, '1769ac58-87a7-4a19-b95d-af972754a7a5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71671, '', '370', 59907, '370', 389, 'd04959ba-0a84-4a71-85b7-1b85ecfeb308');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71672, '', '371', 59907, '371', 390, '39837de3-5f9a-4a7f-a1ea-aa38af470b82');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71673, '', '372', 59907, '372', 391, '0d09d871-c8be-48f6-af9c-73881b63d6f7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71674, '', '373', 59907, '373', 392, 'bc042285-ed15-46ee-a5b4-f40e6026fe4f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71675, '', '374', 59907, '374', 393, '5c97bbf6-5705-47fa-85c5-e54fc7328698');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71676, '', '375', 59907, '375', 394, '13901211-92fe-489c-9984-01c6130af4a5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71677, '', '376', 59907, '376', 395, '3eb3b3c9-6cbf-4f4e-8c70-32a4172459d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71678, '', '377', 59907, '377', 396, '45659632-868e-4fc8-8ad3-d35ec9755b81');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71679, '', '378', 59907, '378', 397, 'c2539dce-e415-46e0-8517-67af33018b9a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71680, '', '379', 59907, '379', 398, 'e867d319-7eb4-48d4-b5ec-c1520702cd67');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71681, '', '380', 59907, '380', 399, 'ef0f7658-8fae-4eda-b3b7-7dd053d504e4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71682, '', '381', 59907, '381', 400, '9e512be6-ee33-43f6-a751-a8cbab13e24a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71683, '', '382', 59907, '382', 401, '72fc2659-414d-4972-823a-1e969612197a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71684, '', '383', 59907, '383', 402, 'e6b7ba63-dedb-4fc3-a1bc-88c471af49ea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71685, '', '384', 59907, '384', 403, '062fa841-7b44-4759-9380-4243a167a9f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71686, '', '385', 59907, '385', 404, '98b6c102-6fe8-4cb8-b85c-7151b514eb8a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71687, '', '386', 59907, '386', 405, '73315451-ad88-43ca-bf63-7cbccddf8994');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71688, '', '387', 59907, '387', 406, '76af5a1d-db53-4716-bc08-1940f04990d5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71689, '', '388', 59907, '388', 407, '39c57320-212a-49c5-b799-b6d2579a26da');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71690, '', '389', 59907, '389', 408, '27bf1d0c-5703-48a0-8e95-dc27672f17d9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71691, '', '390', 59907, '390', 409, 'bae19e01-c568-47ac-a870-c46258c83d6e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71692, '', '391', 59907, '391', 410, '53b5ee62-6d73-45b3-8979-841bc19fe74b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71693, '', '392', 59907, '392', 411, '8264767d-fa54-43fa-ae71-00388621ecb9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71694, '', '393', 59907, '393', 412, 'cd818a58-ca18-46c5-aff8-84385bb0527b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71695, '', '394', 59907, '394', 413, '11958211-d17d-4713-ac5c-a6d9f4532844');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71696, '', '395', 59907, '395', 414, '110e9a69-ed17-43ef-b00d-e4c552fbaddd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71697, '', '396', 59907, '396', 415, 'eb9f8a3d-f4fc-4e5f-8b96-e6b3cb842ea9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71698, '', '397', 59907, '397', 416, 'd58f7fe3-d0c7-4941-ab44-04ff2d08505c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71699, '', '398', 59907, '398', 417, 'd3703d36-1911-4c11-89cf-a6bcc9b25232');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71700, '', '399', 59907, '399', 418, 'e1e4e3a4-058d-4c87-acc7-ea27359f5e55');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71701, '', '400', 59907, '400', 419, '017029d7-6495-4c3b-b9d3-e1cd5c4814ba');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71702, '', '401', 59907, '401', 420, '278af9cb-e336-43be-aa38-f1b16a7f7767');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71703, '', '402', 59907, '402', 421, '1e788848-1e2a-42b1-954d-b1092d0ceb59');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71704, '', '403', 59907, '403', 422, 'b28ab456-8bac-4561-98e6-b38d960529bb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71705, '', '404', 59907, '404', 423, '17cfc9e8-fcd4-472c-a415-49f001e1dbcd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71706, '', '405', 59907, '405', 424, '46169577-be12-4cf8-a97e-993d2d2f09ad');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71707, '', '406', 59907, '406', 425, '71a0e30b-3aa7-48b1-b020-00fc430c2892');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71708, '', '407', 59907, '407', 426, '035a0abf-5942-4bbe-b528-bab45de91132');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71709, '', '408', 59907, '408', 427, 'e77cc2bd-f969-4c0f-a9a3-6a7c01debf0e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71710, '', '409', 59907, '409', 428, '069c8f50-34ee-42b3-92e7-db8dc234f4aa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71711, '', '410', 59907, '410', 429, '20b7f6c0-ac5b-44e3-a911-7ea824e2b75a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71712, '', '411', 59907, '411', 430, '77444f04-a6e2-4932-bbe5-c26045ac6bbb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71713, '', '412', 59907, '412', 431, '23b77220-ae99-4f0d-8a04-576708eac52f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71714, '', '413', 59907, '413', 432, 'ba86ea5e-de16-47bb-b105-f43b0ac6f293');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71715, '', '414', 59907, '414', 433, '083aed38-dfe2-4c99-8fa6-b798c52fd3bb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71716, '', '415', 59907, '415', 434, '32a5ad6c-e407-411f-b078-7f6d726d32e6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71717, '', '416', 59907, '416', 435, 'ed076fdf-bc11-4f43-9c01-22d166d5c5b2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71718, '', '417', 59907, '417', 436, '80b3d973-59a7-48e2-a937-f178f86ed411');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71719, '', '418', 59907, '418', 437, '82202350-1648-4fea-8aca-3b30732cf569');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71720, '', '419', 59907, '419', 438, '012259eb-394d-4696-9e94-ca0e020cceaf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71721, '', '420', 59907, '420', 439, '52aad224-a62f-41c0-b48b-64953cd92842');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71722, '', '421', 59907, '421', 440, '155df46c-cf99-4257-a3b7-08d708250fc0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71723, '', '422', 59907, '422', 441, '592ea3e4-94a5-4c7b-83c4-8d1866d2a991');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71724, '', '423', 59907, '423', 442, '1c646444-33d9-4ac4-a0a0-dccf5f93e4ae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71725, '', '424', 59907, '424', 443, '60295af9-92ba-4d6f-832a-327f71912c0f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71726, '', '425', 59907, '425', 444, '19c770a8-ef2b-4190-95d3-c5f2b4ce2ecf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71727, '', '426', 59907, '426', 445, '35b6924a-88b5-480c-9dcf-bbfd75a30ebd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71728, '', '427', 59907, '427', 446, '6c7288ad-474f-4ef8-b7eb-5fd8b722945a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71729, '', '428', 59907, '428', 447, '527de8c1-ef0a-4613-8012-afd8ec7db2d8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71730, '', '429', 59907, '429', 448, '983f2f36-38ce-4f11-a76c-4e6f59d018aa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71731, '', '430', 59907, '430', 449, '8922278e-0153-4fd2-a4f6-2b0f3d1e3552');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71732, '', '431', 59907, '431', 450, '0800a818-1aac-4b1c-a2bc-d7fdb78901d4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71733, '', '432', 59907, '432', 451, '2970bdca-417c-4aaf-89b6-26d13f529f91');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71734, '', '433', 59907, '433', 452, '95b44f8e-6712-4301-915c-f13ad6b4fd80');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71735, '', '434', 59907, '434', 453, '51b7f3d1-ef3a-4a9d-9059-c0875b5729ec');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71736, '', '435', 59907, '435', 454, '0a00484e-75ce-4a22-9376-6c65c2cd2007');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71737, '', '436', 59907, '436', 455, '00cb9d5b-947d-432b-94dd-d06824d890ab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71738, '', '437', 59907, '437', 456, 'f7c6772f-a2f9-4059-b945-c13fff1d03b8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71739, '', '438', 59907, '438', 457, '5bf19f53-7ef0-4cb7-a865-e1e7a12caa0a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71740, '', '439', 59907, '439', 458, 'eb0c631a-8347-41ec-bfd4-8f0df6ccac31');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71741, '', '440', 59907, '440', 459, '2fb80e9f-3db7-47e6-9e77-b305f15344fd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71742, '', '441', 59907, '441', 460, 'b4f7ec5e-fa07-4b64-9088-a93f7d0b2ac5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71743, '', '442', 59907, '442', 461, '28244d9d-2948-4fb1-9138-061d63c718cb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71744, '', '443', 59907, '443', 462, 'b5fa97da-8bd3-49bd-bbba-027a9ef329f9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71745, '', '444', 59907, '444', 463, '64e7c717-11d8-4c1d-8378-f7dbd8f862c8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71746, '', '445', 59907, '445', 464, '9b4b73ab-2154-4725-9b16-4caee448a303');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71747, '', '446', 59907, '446', 465, '2dd8b6a0-3248-402b-a355-78efc9c307ac');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71748, '', '447', 59907, '447', 466, '2e40a2b2-fdfa-48e6-9400-e0ff44f289a7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71749, '', '448', 59907, '448', 467, '0988a01b-3dd0-4aa0-ac93-17a1786f1bfc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71750, '', '449', 59907, '449', 468, '6445896d-7426-47e3-acdb-25d9a7a1f9ec');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71751, '', '450', 59907, '450', 469, 'ab08e1c1-648e-4a03-9d2c-8b0f44709e46');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71752, '', '451', 59907, '451', 470, 'dd884476-4695-47eb-a7a8-2a08663dff83');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71753, '', '452', 59907, '452', 471, '06b53043-be7e-431f-bc88-519542eedeb5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71754, '', '453', 59907, '453', 472, '76454c87-0acd-47ea-bf31-0755ace53cea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71755, '', '454', 59907, '454', 473, 'f9facb2e-6c81-4d07-aa92-b5b9e46c0d44');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71756, '', '455', 59907, '455', 474, '9f405148-1bf6-4b69-8fd2-e9f1e49bb05e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71757, '', '456', 59907, '456', 475, '46a442b9-a475-4013-83f1-75685f4a2902');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71758, '', '457', 59907, '457', 476, 'a0e80076-1912-4f6b-ae08-ba89e0762298');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71759, '', '458', 59907, '458', 477, '4d5475f8-12ca-42f0-bd76-0f0879bbd203');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71760, '', '459', 59907, '459', 478, '6f8cb12c-faee-4c48-97df-2b087987924c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71761, '', '460', 59907, '460', 479, '60c094e5-61d9-479e-b9e2-4237804a923c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71762, '', '461', 59907, '461', 480, 'a1fc0d29-d049-4562-9ded-0f9838fdc79d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71763, '', '462', 59907, '462', 481, 'e743a781-29df-4089-935f-50b2043b36b3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71764, '', '463', 59907, '463', 482, '37718adb-5734-49bf-8fcb-bf639cb4fb9c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71765, '', '464', 59907, '464', 483, 'a2be924d-d462-4152-9244-c8f16e318b7e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71766, '', '465', 59907, '465', 484, '26dafe93-3881-4735-aea6-4419ccb0bcdd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71767, '', '466', 59907, '466', 485, '514054e5-a31d-4260-a07f-40e8b244632d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71768, '', '467', 59907, '467', 486, '5ba3ba70-3166-4c69-918a-75f31963c665');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71769, '', '468', 59907, '468', 487, '1047e5ed-3f16-45d0-bb7e-2bad0e2a9dd9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71770, '', '469', 59907, '469', 488, '3a210be3-d485-44d8-8129-8b70e80ce3c2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71771, '', '470', 59907, '470', 489, '05846f0f-554a-4803-a4e7-552b23c34346');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71772, '', '471', 59907, '471', 490, '3dd23009-da0c-4434-bc1c-bccfe12f111d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71773, '', '472', 59907, '472', 491, '58e3311a-ff13-48ae-85e5-b7e4eedf134e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71774, '', '473', 59907, '473', 492, '7b30a710-49b3-4b45-b3aa-3e339f8ac2a3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71775, '', '474', 59907, '474', 493, '67565c99-d4f0-4a49-8bca-55a09f24a278');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71776, '', '475', 59907, '475', 494, '788f06ac-f19e-4eff-8989-7f7e8ee51551');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71777, '', '476', 59907, '476', 495, 'ac2428f8-237a-4f59-b014-b8df5624c99d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71778, '', '477', 59907, '477', 496, 'fbcc691f-5f3c-4f4f-88f5-ca6771a061b2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71779, '', '478', 59907, '478', 497, '3ef41bad-7efd-4ab8-af60-aa884207325f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71780, '', '479', 59907, '479', 498, 'ac5379ba-40f5-4883-913d-3c6b45f1e38b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71781, '', '480', 59907, '480', 499, '018e3da8-daf7-497b-87a9-4fa639d8b467');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71782, '', '481', 59907, '481', 500, '8b652cdc-e618-449a-90eb-60effd401623');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71783, '', '482', 59907, '482', 501, '19b2ab36-4faf-4fac-8f7f-d26594a87dc0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71784, '', '483', 59907, '483', 502, 'a9f6303c-b0ff-4cc7-afc3-28640622b02d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71785, '', '484', 59907, '484', 503, '82284e19-81dc-4295-8892-f448bc5548ca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71786, '', '485', 59907, '485', 504, '79696cc9-5f2f-4554-8236-83ec5224e395');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71787, '', '486', 59907, '486', 505, '83f38def-235e-4faa-807d-57a72775365b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71788, '', '487', 59907, '487', 506, '4c97147c-9594-4111-883c-aa1826bfc333');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71789, '', '488', 59907, '488', 507, '08470241-fa38-4908-97a4-b920bc640129');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71790, '', '489', 59907, '489', 508, '86394b47-b0a8-4b22-9138-a5927325cb54');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71791, '', '490', 59907, '490', 509, 'f7a0f2b3-13f2-4bbb-8da1-d3530362787c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71792, '', '491', 59907, '491', 510, '0eca6c5a-d708-41b6-91bd-db8577d214ca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71793, '', '492', 59907, '492', 511, 'c8337aeb-aca8-4f43-b717-fd3eaafb902d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71794, '', '493', 59907, '493', 512, '91ae69cf-370c-4e99-a4b6-6ee11a48b969');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71795, '', '494', 59907, '494', 513, '874f6dea-0a1c-4103-b77f-9d9450bc9635');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71796, '', '495', 59907, '495', 514, '4ee61430-ee99-4c6e-b375-e495435ff819');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71797, '', '496', 59907, '496', 515, 'aa483ef3-be08-4798-a15a-f08ae247dac5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71798, '', '497', 59907, '497', 516, '904f4c32-39ee-498c-a37c-8583d5ec2646');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71799, '', '498', 59907, '498', 517, 'd4b90be5-998b-4499-9f53-d31ece176cc1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71800, '', '499', 59907, '499', 518, '3f9df035-064b-405c-8f09-8beb660f0012');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71801, '', '500', 59907, '500', 519, 'bb1371fe-764f-4cd0-ac37-e7d53ce79085');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72019, '', '', 69294, 'City:', 1, 'a0d9c684-87e6-4ab4-aa23-e068cc0c2c7b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71802, '', '>500', 59907, '>500', 520, 'd37006cf-13ec-4db2-8753-20ce64d0fe0e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26847, '', '3', 13349, 'Testing', 2, '9f43e81f-07e1-4f1a-809b-f6e73e4e6904');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26848, '', '1', 13349, 'Test', 1, '24495f1e-b5f0-48dd-9563-eb12dc99f72f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26849, '', '2', 13349, 'ReTest', 3, '004ac78e-a75f-4fb3-beb2-a4ce720a9da1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15461, '', 'Select', 57860, 'Select One', 1, '55362e9d-6e8c-4996-abc1-3516b9b13268');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72020, '', 'selection', 69299, 'Please select state:', 1, '1d33faac-18e7-44a6-9624-225cba95ec93');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72021, '', 'AL', 69299, 'Alabama ', 2, 'e02201d6-5ddd-4265-863b-dcfc550fdc07');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72022, '', 'AK', 69299, ' Alaska', 3, '7ba6ce2f-317a-492d-8505-c1573a03b5d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72023, '', 'AZ', 69299, ' Arizona', 4, '4970e170-ccf8-4680-b1a7-36f140e21a2d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72024, '', 'AR', 69299, 'Arkansas', 5, '8272ffc0-3f33-469b-a277-a5190f828bdd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72025, '', 'CA', 69299, ' California', 6, '53aabfdd-d27e-416e-ac84-7a7a0394a153');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72026, '', 'CO', 69299, 'Colorado', 7, '722f32d4-4cd6-4fdc-9af7-072c7d58290b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72027, '', 'CT', 69299, ' Connecticut', 8, '6a70a9f5-1ac0-44a3-b1eb-803e5d0254ef');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72028, '', 'DE', 69299, ' Delaware', 9, '4c17f254-242e-4013-92ba-29fa470a45bb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72029, '', 'FL', 69299, ' Florida', 10, '7b7a81eb-2e3d-4a06-8426-714479d4acb7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72030, '', 'GA', 69299, ' Georgia', 11, 'bf7744c7-ee2a-4a87-9864-4b65048b0b3f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72031, '', 'HI', 69299, ' Hawaii', 12, 'f46eff1a-7d8e-4637-97fc-bdd3da08c5b9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72032, '', 'ID', 69299, ' Idaho', 13, 'ef27596e-8b31-46e2-9b59-addddf592df2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72033, '', 'IL', 69299, ' Illinois', 14, '4ae08b63-6265-4361-a3a5-7becd7cf4888');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72034, '', 'IN', 69299, 'Indiana', 15, '87d3a83b-72b3-4de6-91c4-1122e5d7b1a6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72035, '', 'IA', 69299, ' Iowa', 16, '9a59d0eb-d54b-4fa1-b047-b052be67031a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72036, '', 'KS', 69299, 'Kansas', 17, '380c2964-8970-47c9-bf01-82e6d96b49ce');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72037, '', 'KY', 69299, ' Kentucky', 18, '42044436-f067-4534-aa35-c19a8fcda87c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72038, '', 'LA', 69299, 'Louisiana', 19, '4fd853d0-ac2a-483a-b125-3487ddc3f919');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72039, '', 'ME', 69299, ' Maine', 20, '81170fb1-0008-47fa-8feb-178d9303e628');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72040, '', 'MD', 69299, ' Maryland', 21, '95aecaff-4c7d-4e17-86c9-4f005b8c7694');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72041, '', 'MA', 69299, 'Massachusetts', 22, '08ee8f81-30a1-413e-86bd-03dc9de4556f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72042, '', 'MI', 69299, ' Michigan', 23, '7ab8ba85-52fd-4efd-bb3d-0290c58981fb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72043, '', 'MN', 69299, ' Minnesota', 24, '7daccb48-61f3-4a8a-ba77-e6404c16eddd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72044, '', 'MS', 69299, ' Mississippi', 25, '24ca0156-0b19-48d1-8afe-5e29e100ef74');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72045, '', 'MO', 69299, 'Missouri', 26, '93dbefb3-d193-4f19-b133-ff5a7c9544b5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72046, '', 'MT', 69299, 'Montana', 27, '164aaec8-4c37-4779-ad0f-865249fc8305');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72047, '', 'NE', 69299, 'Nebraska', 28, '1cb1e065-62e9-4e30-b798-9f6bc290545b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72048, '', 'NV', 69299, ' Nevada', 29, '07a95d04-719b-495b-bd3e-b9754dd56a41');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72049, '', 'NH', 69299, ' New Hampshire', 30, '5f76b898-f114-4237-966a-6ce1b9a27d0c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72050, '', 'NJ', 69299, ' New Jersey', 31, 'dfc01b36-4c7d-49e5-87a7-e9bd4fcc7345');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72051, '', 'NM', 69299, ' New Mexico', 32, 'b8bd8562-00e7-4ddc-a55d-cc5337445951');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72052, '', 'NY', 69299, ' New York', 33, '3ad77c65-636f-463b-916f-a7407c77c65d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72053, '', 'NC', 69299, 'North Carolina', 34, '93c2ec98-eab6-4ec9-a7a5-9082dc4d804d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72054, '', 'ND', 69299, ' North Dakota', 35, '7d569de9-29d4-4cad-ab3f-f08cf0474fd9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72055, '', 'OH', 69299, ' Ohio', 36, 'f8f965e8-b662-49c6-9ae2-aae7022190e6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72056, '', 'OK', 69299, ' Oklahoma', 37, 'aa7a6fab-9bcb-451d-969a-c368994b2a5f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72057, '', 'OR', 69299, 'Oregon', 38, '5e3c67e8-68fd-442f-a242-06d0aefd9381');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72058, '', 'PA', 69299, ' Pennsylvania', 39, 'ce753757-681e-486e-b354-7144d7aa20d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72059, '', 'RI', 69299, ' Rhode Island', 40, '1174da1f-a1da-45bd-b27d-4813c2c31a60');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72060, '', 'SC', 69299, 'South Carolina', 41, '30a36d2d-a830-4bdc-830d-51434fef03ce');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72061, '', 'SD', 69299, 'South Dakota ', 42, '8d6ac7d6-471d-4d1b-983e-0bee7f129307');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72062, '', 'TN', 69299, 'Tennessee', 43, '0ffef5b4-4de0-48a1-a887-d77f52fa8d2e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72063, '', 'TX', 69299, ' Texas', 44, '4809c501-e4bb-413b-b72a-9af01c268ebb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72064, '', 'UT', 69299, ' Utah ', 45, '6dca09c7-af17-4b81-8c88-e15b18c03e12');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72065, '', 'VT', 69299, ' Vermont', 46, '9b120eca-9e40-4aeb-89ab-8bd946a17f8d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72066, '', 'VA', 69299, ' Virginia', 47, 'd01b8ae2-6999-482d-9f01-cee2bcaf9930');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72067, '', 'WA', 69299, 'Washington', 48, '6a8c4b70-a820-46b9-94d3-6f5e385979c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72068, '', 'VA', 69299, ' West Virginia', 49, '35420014-9739-4496-b95e-ab889552cfa4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72069, '', 'WI', 69299, 'Wisconsin', 50, '68fb40ae-9360-44ed-948e-8a0416498f01');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72070, '', 'WY', 69299, 'Wyoming', 51, 'a3df4883-a452-4f4d-9cc7-a3e759b408a3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15462, '', 'Eng', 57860, 'Architecture and Engineering', 2, '60327be8-b178-4867-8385-6fc0e578bc73');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15463, '', 'Arts', 57860, 'Arts, Design, Entertainment, Sports, and Media', 3, '4f7892b6-1f1e-40ea-b2d2-a9b656296bbd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (72071, '', '', 69296, 'Zip:', 1, '4c5a89f6-d37a-43f8-8b13-6003d8b9663c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71945, '', '', 69285, 'Title (optional):', 1, '775f8716-6a24-4d74-b33e-85dd5f6f6c32');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71036, '', 'weight', 59907, 'Weight: Pounds', 98, 'c33939a2-3c41-40ce-949a-0c59ac644f52');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (71037, '', '80', 59907, '80', 99, 'e6303464-d90a-4547-a31f-cf336ccb685a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27292, '', 'Ovarian tissue banking', 13574, 'Ovarian tissue banking', 2, '4592d6e6-8828-4735-a96d-4a6bce37bd92');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27293, '', 'Surgical ovarian transposition', 13574, 'Surgical ovarian transposition', 1, '768bdfc4-5653-4fcc-891a-682b3a234af7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27294, '', 'Oocyte cryopreservation', 13574, 'Oocyte cryopreservation', 3, '38c9a29e-fb46-4473-8c55-4e5e420d029a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27295, '', 'Embryo cryopreservation', 13574, 'Embryo cryopreservation', 4, 'd3cb4afa-b679-4f07-9331-b35ac31cdc14');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27296, '', 'In vitro fertilization', 13574, 'In vitro fertilization', 5, '241bf67b-c40b-47a8-af36-947226cd6409');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27297, '', 'GnRH agonists such as Lupron', 13574, 'GnRH agonists such as Lupron', 6, 'c048fea1-6920-40b7-98d2-504a507bbb9a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27298, '', 'Not applicable', 13574, 'Not applicable', 7, 'ca531680-aa4a-44f2-9aee-92ea1ad1d914');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27299, '', 'Missing', 13574, 'Missing', 8, 'f2634bae-0be8-4c94-8c25-2f1e1cfaabbd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27300, '', 'Other (Please specify)', 13574, 'Other (Please specify)', 9, 'a9138cf2-0926-44ce-971c-de8b7b098c41');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27301, '', 'Surgical oophorpexy', 13574, 'Surgical oophorpexy', 10, '1efdd701-dde9-422a-9ba9-b2dc7d161767');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27473, '', 'No', 13033, 'No', 2, 'a5132d71-b586-42ff-9a89-62e99b1c2fa5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27474, '', 'Yes', 13033, 'Yes', 1, '8f3eef49-10a2-4e1e-97a0-7a353a87e325');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27475, '', 'Unknown', 13033, 'Unknown', 3, '1cc9f790-40c3-4e82-b0c0-7aa18cce2a22');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31272, '', 'A little', 15572, 'A little', 15, '8b4a788a-7f7a-4ed4-8a13-2ca0ff2f7880');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31273, '', 'Moderately', 15572, 'Moderately', 16, '8d2e3421-76cf-422c-b8a3-28734b8f5a87');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31274, '', 'Extremely', 15572, 'Extremely', 17, '61d6371b-a754-4bba-b327-c9e8089862c6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27679, '', '2', 13807, '2', 1, '0e52c382-8d5d-4dec-a628-ab44f63145ad');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27690, '', '3', 13807, '3', 2, '26d552dd-9c5d-4323-8eda-2cfa7efab2f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27691, '', '1', 13807, '1', 3, '987b732b-e8f8-4517-b00e-dff5c23fd7c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27840, '', '', 13809, 'answer', 1, 'bb98553c-c2d9-4664-9da0-966ded2c22b2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31275, '', 'No', 15572, 'No', 18, '8edc9b28-2aa3-4ce8-9b26-eee37c56f5f6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31276, '', 'Yes', 15572, 'Yes', 19, '911be1bf-a885-4508-9207-04fb5bb32dfd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14580, '', '<1', 58777, 'Less than 1 year', 1, 'a93a4cee-692b-4fd3-8e17-6f578c21061d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14581, '', '1-2', 58777, '1-2 years', 2, '559e5c5b-2c85-47af-b4f5-3eabb198c942');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14582, '', '3-4', 58777, '3-4 years', 3, 'c9557d94-2840-4bd7-8369-342054481be1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14583, '', '5-9', 58777, '5-9 years', 4, 'b8a36c0c-cef7-415f-a28b-369ddb2d710e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14584, '', '10-14', 58777, '10-14 years', 5, 'c9422e04-34aa-4211-ae04-1b5a1029c197');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14585, '', '15>', 58777, '15 years or more', 6, '6e04a6a2-d453-4068-b480-28b232b3ea08');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14586, '', 'n/a', 58777, 'I don''t know/I can''t remember', 7, 'a89789b9-8907-4e21-b9f2-f2004133aa37');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15464, '', 'Building', 57860, 'Building and Grounds Cleaning and Maintenance', 4, 'b535328e-cbd7-4a5a-ae35-f503bd8f6925');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15465, '', 'Financial', 57860, 'Business and Financial Operations', 5, '90453d5b-ab64-4d33-9876-6d70c8230968');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15466, '', 'Social Service', 57860, 'Community and Social Services', 6, 'c4e2b755-0015-4e10-a101-035f3425edde');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15467, '', 'IT', 57860, 'Computer and Mathematical', 7, 'ebceffc9-06bb-4c2d-b93d-66176b0c64d8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15468, '', 'Construction', 57860, 'Construction and Extraction', 8, '7fe165e2-67ac-419a-acbc-68fbf94cb36d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15469, '', 'Edu', 57860, 'Education, Training, and Library', 9, '7f43b2b4-a5a3-467f-8429-f09b3b2a6a49');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15480, '', 'Farming', 57860, 'Farming, Fishing, and Forestry', 10, '7bc39eaa-0d99-4f4e-9600-be151895f4cd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15481, '', 'Food Prep.', 57860, 'Food Preparation and Serving Related', 11, '1c5b57d8-bb22-4c63-86c6-afde725f15bd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15482, '', 'Health care', 57860, 'Healthcare Support', 12, '1ed6ed51-0075-47b3-8157-132975d45018');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15483, '', 'Homemaker', 57860, 'Homemaker', 13, '474fa2ef-a474-4af6-ad67-9f364d8844d8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15484, '', 'Repair', 57860, 'Installation, Maintenance, and Repair', 14, '6c945c46-9b76-4a25-89aa-4833be544df4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15485, '', 'Legal', 57860, 'Legal', 15, '64959ca4-18d7-4eaa-8491-1e29ad8124c0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15486, '', 'SS', 57860, 'Life, Physical, and Social Science', 16, 'a0360aac-2312-4918-81b7-900cf072caa0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15487, '', 'Mang.', 57860, 'Management', 17, '3c804761-87f1-486e-9b3b-df60aa96c70c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15488, '', 'Military', 57860, 'Military Specific', 18, '0a68f4bf-fcf0-4dd8-92aa-bd9cb3aaf638');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15489, '', 'Admin', 57860, 'Office and Administrative Support', 19, 'e1a51cce-3875-4175-b830-d97651e4eb80');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15490, '', 'Personal care', 57860, 'Personal Care and Service', 20, 'a9f81b1d-3f57-41cd-acd7-93500a8858ef');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15491, '', 'Produ.', 57860, 'Production', 21, '0a06fda3-29af-4929-8584-1cdfce4f3fe6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15492, '', 'Protective', 57860, 'Protective Service', 22, 'c5c662a3-d840-418c-ad7a-6e2135feb5f2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15493, '', 'Sales', 57860, 'Sales and Related', 23, 'ce062485-4b52-403f-a39c-edbdeaf92100');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15494, '', 'Student', 57860, 'Student', 24, '1af9aad7-aeb6-405c-8cbb-eebdcc594139');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15495, '', 'Trans.', 57860, 'Transportation and Material Moving', 25, '426de157-7b50-43d4-92aa-a571de54ad81');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15496, '', 'Retired', 57860, 'Retired', 26, '995d8e97-de59-4c1a-abfd-970b9f0eaa7b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15497, '', 'dontwork', 57860, 'DonÃ‚Â’t Work', 27, 'ea927e16-bd78-4bd1-a0af-9914db3db6b7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15498, '', 'other', 57860, 'Other', 28, '0ae30d4f-cc65-49f6-a3af-0381ca3708bf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24473, '', 'DCIS', 58761, 'In Situ (DCIS)', 1, 'eeef88b8-1213-4639-af96-3cf107f7d4e5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15523, '', 'Prof', 57856, 'Graduate/professional school', 6, '0a890da8-9684-4f54-a3e0-0f885a747dc8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15524, '', 'N/A', 57856, 'I''d rather not say', 7, 'c34a1422-82d8-46da-ae60-c7b216056a0f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24474, '', 'LCIS', 58761, 'In Situ (LCIS)', 2, '6cd757a7-d438-488d-b687-af767c466634');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24475, '', 'DUctal', 58761, 'Ductal carcinoma (invasive or infiltrating)', 3, '9c686e81-9e3a-4ff2-a1f4-56626be5b973');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24476, '', 'Lobular', 58761, 'Lobular carcinoma (invasive or infiltrating)', 4, '271c7644-dea0-49e3-a783-1680bfd492db');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24477, '', 'Other', 58761, 'Other (invasive or infiltrating)', 5, '47c4d983-4072-49cf-b97e-6bc0e7c288df');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24478, '', 'dont know', 58761, 'I don''t know/I can''t remember', 6, '803ee3dd-4035-43b6-a64a-d088dfb1a71a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24479, '', 'n/a', 58761, 'I''d rather not say', 7, '7c651f23-a816-43f9-8d71-612e6b72c3c9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14765, '', '1', 7347, 'Don''t know', 1, 'f6e88a1d-dccd-463e-95a0-8f2834f3074e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14766, '', '2', 7347, 'Yes', 2, '017db677-07f8-4c1a-b0d6-92455fc8a5ba');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (14767, '', '3', 7347, 'No', 3, '46f912ff-1572-4503-9233-e2e70617ae76');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31277, '', 'Not relevant', 15572, 'Not relevant', 20, 'b51cc680-d471-4669-b907-f06cb84b8c16');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24480, '', 'Yes', 58762, 'Yes', 1, '7b9f6c87-a737-4942-a14b-591159536ad2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24481, '', 'No', 58762, 'No', 2, '23634d46-7976-4bcc-93ae-2614a9ca9659');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24482, '', 'dont know', 58762, 'I don''t know/I can''t remember', 3, '44c3f19d-14a6-4edc-8669-bc8c204e3cd1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24483, '', 'N/A', 58762, 'I''d rather not say', 4, 'db03e7db-7b42-44da-b322-1edde267ea10');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21731, '', '1', 10861, 'No', 1, '6247eabc-2989-4ddd-ae0b-3cae512b7cc4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24300, '', '1', 12146, 'No', 0, '455c4d28-3e9b-4134-a8b8-cb473342a063');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24301, '', '2', 12147, 'Yes', 0, '47580f60-96d3-4dd3-8fe2-5859e8ec0413');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24302, '', '1', 12147, 'No', 0, 'eaa46731-ca41-414d-ba9a-83cf6b5cfa8b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24303, '', '2', 12148, 'Yes', 0, 'd962233b-6531-4364-abe9-5be1d657fac0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15740, '', 'aa', 7589, 'African-American, Black', 1, '47e0625b-5127-4e95-9bbf-0d05ef5c96f2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15741, '', 'eskimo', 7589, 'Aleutian, Eskimo', 2, 'e6dc43b6-4117-48f4-8ea6-045df30df7de');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15742, '', 'american indian', 7589, 'American Indian', 3, '5adba429-79a7-4c59-bcca-3cd8d8ca2cec');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15743, '', 'asian', 7589, 'Asian or Pacific Islander', 4, '2f15687d-bb51-479a-a606-07557f335c60');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15744, '', 'white', 7589, 'White, Caucasian', 5, 'ef094adc-e03e-4235-a746-08f8e83ad3bf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15745, '', 'hispanic', 7589, 'Hispanic', 6, '1230d1fa-c137-482d-b958-354884c82b15');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15746, '', 'other', 7589, 'Other', 7, '77ff1a71-df95-4980-bdd9-b720278d8ad7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15747, '', '1', 7589, 'Don''t know', 8, 'df783ea8-4ee5-4104-b75b-60dfc6e9209f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24304, '', '1', 12148, 'No', 0, '7cb6938e-4469-409d-98fb-ed99e393f846');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24484, '', 'yes', 58763, 'Yes', 1, 'd75315ea-8e6a-4f38-bbdc-da8e3084e02b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24485, '', 'no', 58763, 'No', 2, 'a09d76e7-523c-492b-9d0d-2c86672bf2b7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24486, '', 'not tested', 58763, 'Not Tested', 3, '471fc455-a7af-42da-98b5-ea4c9fd9097d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24487, '', 'dont know', 58763, 'I don''t know/I can''t remember', 4, '511b07a5-66a5-486e-b75c-16a249533b6f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24488, '', 'n/a', 58763, ' I''d rather not say', 5, '0b4c01d1-7a11-45c4-8575-f3562848b1e6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24893, '', '2', 12190, 'Yes', 1, '6da828b9-e701-4bce-8cc0-d9ab0a58a055');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21394, '', '', 10684, 'testing', 1, 'f1b4ee82-e9f3-40d3-a48f-61a697cd7af4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24894, '', '1', 12190, 'No', 2, '316028d3-41e2-457b-bf88-ee8b54bc5550');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21937, '', 'Limited', 58310, 'Yes, limited a lot', 0, '5aaf8eed-1306-4f51-b001-e4cd07a0b4da');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21938, '', 'Little Limited', 58310, 'Yes, limited a little', 0, '604c18ba-1472-4ea2-b3db-9ed9a3346f44');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21939, '', 'Not Limited', 58310, 'No, not limited at all', 0, '5c7a2601-76fa-4b90-a4b8-9c91a32cdf2d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21960, '', 'N/A', 58310, 'I''d rather not say ', 0, '5b849f9f-a90b-4c19-b3f4-44f1020e39f8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21961, '', 'Limited', 58311, 'Yes, limited a lot', 0, '9d76d0c4-2ef6-4c04-9cd9-815520cfc6c4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21962, '', 'Little Limited', 58311, 'Yes, limited a little', 0, '4a91ac34-5405-4c4f-a939-0ae44d1ad1dc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21963, '', 'Not Limited', 58311, 'No, not limited at all', 0, '4e73f64f-c78b-4cb4-be1c-ba370aa8c96c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21964, '', 'N/A', 58311, 'I''d rather not say ', 0, '39d69b58-10f2-42ff-8ad7-fad0dc778bda');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21965, '', 'Limited', 58312, 'Yes, limited a lot', 0, '15e8f59f-2f7e-4782-88dd-38a4806c7b28');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21966, '', 'Little Limited', 58312, 'Yes, limited a little', 0, '9d23e3e6-de3e-49f0-a38f-9c43dc993447');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21967, '', 'Not Limited', 58312, 'No, not limited at all', 0, '68a98214-fa06-4d5f-9680-728aa8286866');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21968, '', 'N/A', 58312, 'I''d rather not say ', 0, 'dce8eb9a-7111-4a50-b8b7-854a293249c4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21969, '', 'Limited', 58313, 'Yes, limited a lot', 0, 'bb9f7628-4963-4438-8f9a-16a1e33066de');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21970, '', 'Little Limited', 58313, 'Yes, limited a little', 0, '25fd3e22-15bc-453b-9277-b6e452781cfe');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21971, '', 'Not Limited', 58313, 'No, not limited at all', 0, '6f619368-a1e3-4ae3-9756-b9a71a8574c1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (18973, '', '1', 7349, 'Don''t know', 1, '44c9b0c0-fb24-4085-8174-2bf119e8c847');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (18974, '', '2', 7349, 'Yes', 2, '4601a7aa-4c2e-478a-9082-a4ab60845fb4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (18975, '', '3', 7349, 'No', 3, '4e9264fd-18ca-47c6-9a9d-c523565b521a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21972, '', 'N/A', 58313, 'I''d rather not say ', 0, '5d034970-fefe-41aa-9f43-325b51d496f4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21973, '', 'Limited', 58314, 'Yes, limited a lot', 0, 'feeac538-967d-4216-a17d-2ec57676f62b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21974, '', 'Little Limited', 58314, 'Yes, limited a little', 0, '14acda1e-ab4d-48d5-a8e7-fd097177d5f6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21975, '', 'Not Limited', 58314, 'No, not limited at all', 0, 'bf78d082-95d4-4d6f-8815-1625d0535331');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21976, '', 'N/A', 58314, 'I''d rather not say ', 0, 'b1330d1c-542d-4e9e-8d5c-4b37c6191d12');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21977, '', 'Limited', 58315, 'Yes, limited a lot', 0, '3ba6c7e6-2518-467e-87b2-c92a4e03abe8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21978, '', 'Little Limited', 58315, 'Yes, limited a little', 0, 'c032abcf-5fcb-4ea6-92b9-7aa18194fb20');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21979, '', 'Not Limited', 58315, 'No, not limited at all', 0, '4f48b9b2-de35-4f5f-9a2a-1f11dda1cc70');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21980, '', 'N/A', 58315, 'I''d rather not say ', 0, '951bfcf6-d98a-41f0-8af8-327929d7316c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21981, '', 'Limited', 58316, 'Yes, limited a lot', 0, 'b8b635c2-d23d-4a6b-9337-b9889a5089f1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21982, '', 'Little Limited', 58316, 'Yes, limited a little', 0, 'e191efea-7ebb-424c-82c3-bfb88f8e6bdf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21983, '', 'Not Limited', 58316, 'No, not limited at all', 0, '60840d05-7ecf-4955-b383-8ebae2140d87');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21984, '', 'N/A', 58316, 'I''d rather not say ', 0, '6c18b7d8-e059-410d-a535-0d2d2a763814');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21985, '', 'Limited', 58317, 'Yes, limited a lot', 0, '00bd020a-a794-4b4f-a61e-9e5b4e573e1e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21986, '', 'Little Limited', 58317, 'Yes, limited a little', 0, '7ad6d8a9-dcde-4e03-b96a-7a476225aee3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21987, '', 'Not Limited', 58317, 'No, not limited at all', 0, '7a81f106-a5ea-4e61-949e-fe9921f010e0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21988, '', 'N/A', 58317, 'I''d rather not say ', 0, 'c6a895cf-1c4a-4fb4-a4f2-78d61bf07c28');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21989, '', 'Limited', 58318, 'Yes, limited a lot', 0, '0a203ad3-4b57-43c0-a718-6c78e973e17b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21990, '', 'Little Limited', 58318, 'Yes, limited a little', 0, '883ddc9d-e2c3-4585-80df-545713784dcb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21991, '', 'Not Limited', 58318, 'No, not limited at all', 0, 'e78582be-55b7-4120-a43d-fe1fc23de55f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21992, '', 'N/A', 58318, 'I''d rather not say ', 0, '3679654e-08c8-43c7-aaa5-14a582d340db');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21993, '', 'Limited', 58319, 'Yes, limited a lot', 0, '58573172-9df5-40e3-bad3-86fb4aac4d22');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21994, '', 'Little Limited', 58319, 'Yes, limited a little', 0, 'e5d8662a-1ee6-4e76-802c-c9fe68c1c129');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21995, '', 'Not Limited', 58319, 'No, not limited at all', 0, '8c611451-e033-489b-9069-603b35c8c08b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21996, '', 'N/A', 58319, 'I''d rather not say ', 0, '581a08e9-f4ff-42c9-85c9-f59f76c3e14e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21997, '', 'Limited', 58320, 'Yes, limited a lot', 0, '48ea1a31-6721-4f0c-aa60-7f71b2427fd6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21998, '', 'Little Limited', 58320, 'Yes, limited a little', 0, 'efdd6a7f-1c28-4b46-a727-fc0dac58a113');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21999, '', 'Not Limited', 58320, 'No, not limited at all', 0, 'b3079c94-151e-4344-a1c1-60c3d2712167');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (22000, '', 'N/A', 58320, 'I''d rather not say ', 0, 'fc8376fc-2acc-41e9-a9be-44312ed3a0ca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24489, '', 'past', 58776, 'Yes, I used birth control pills in the past', 1, '9ee3ede5-d377-4f79-99dc-6ef957fffed3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24490, '', 'currently', 58776, 'Yes, I am currently using birth control pills', 2, '8623c24e-5008-4458-a2da-ed13476fc741');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24491, '', 'No', 58776, 'No', 3, '6e468516-9768-4fdf-ac7a-9d35239506a4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15527, '', '', 57861, 'Please Specify "Other" occupation :', 1, '729efe37-501e-4977-8186-eddbceb775ee');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24492, '', 'cant remember', 58776, 'I don''t know/I can''t remember', 4, '3b9a262b-fb21-4408-a61a-0d8429286145');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24493, '', 'n/a', 58776, 'I''d rather not say', 5, '33c6986b-7400-4955-8024-f8a2ea123cd5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15921, '', '', 7955, 'Frequency', 1, 'e73aa0d0-ddfa-47e9-add7-70383274aeaf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33362, '', '', 16644, 'Country', 1, 'fd888377-fb65-4903-82a4-ae3c9ec76f2a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24310, '', '', 7630, 'Please specify "Other":', 1, '27df37eb-d8a1-4d60-8ead-9fa54893a5d9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15115, '', 'female', 7474, 'Female', 1, 'b07eef3b-a4bd-4866-ade4-aeccb7b87c78');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15116, '', 'male', 7474, 'Male', 2, '7b4036aa-9644-4342-b96e-f93a17dd69d4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15117, '', '', 7585, 'Age:', 1, '97888545-be94-4817-ac9f-5c86ffabf67f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15118, '', '', 7586, 'City:', 1, 'c67aadd5-abe6-437e-ac73-855b3d3d0537');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15210, '', '', 7588, 'Country:', 1, 'e2ecfa53-ecfd-4d5d-b90a-541dbb500aeb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15216, '', 'White', 57862, 'White / Caucasian', 1, 'd121d337-426d-4508-a52d-9f98377680a9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15217, '', 'B.AA', 57862, 'Black, African American ', 2, 'dbdc6704-b415-4524-b68f-74dddec0eae1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15218, '', 'Native', 57862, 'American Indian or Alaska Native ', 3, '1b7640a0-cb3c-4273-a0d7-108f9ae97248');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15219, '', 'Asian', 57862, 'Asian/East Indian  ', 4, '3d4795a5-ef7f-4d0a-a65d-af72a289e78c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15220, '', 'Chinese', 57862, 'Chinese', 5, 'e62cee56-ee3c-497a-b736-faca2d56372f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15221, '', 'Flipino', 57862, 'Filipino', 6, '16d57f2d-526a-4702-ad85-6aba71c8d0f6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15222, '', 'Japanese', 57862, 'Japanese', 7, '220cead1-3cae-4fbd-84f1-aada4e8e2ff2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15223, '', 'Korean', 57862, 'Korean', 8, 'a0adf816-d2ac-4032-9fa0-45046a50b92d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15224, '', 'Vietnamese', 57862, 'Vietnamese', 9, '887be398-bcc7-41b1-9ebb-dc777de26d5b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15225, '', 'Other Asian', 57862, 'Other Asian', 10, '49c1a9e3-44a0-475c-8fd4-a5592d3f4eb4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33363, '', '', 16644, 'United States', 2, 'f989eac2-0f42-46a5-b5fa-a7b97fae0632');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33364, '', '', 16644, 'Canada', 3, '27f14c9e-dcc0-4ecc-8c0b-cd0218605357');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15226, '', 'Native Hawaiian', 57862, 'Native Hawaiian', 11, '7440cc8c-700f-46e2-988b-27947d88fdb2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15227, '', 'Guamanian or Chamorro', 57862, 'Guamanian or Chamorro', 12, 'e364299d-9aac-4547-945e-5f2152478a69');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15228, '', 'Samoan', 57862, 'Samoan', 13, '4f14e5ff-449c-488f-9191-85aa4a402ba6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15229, '', 'Other Pacific Islande', 57862, 'Other Pacific Islander', 14, '7c8efeed-1e70-4f85-a607-8bed0f3dddae');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15230, '', 'Other Race', 57862, 'Other Race', 15, '7d7e7627-090d-4112-a904-a8f1ee444563');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17636, '', 'left', 8835, 'was it in your Left breast', 1, 'c644d855-0ef5-482c-9cf0-77ef024664cc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17637, '', 'right', 8835, 'Right breast ', 2, '44075db7-60ce-4668-a442-0161606b4427');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17638, '', 'both', 8835, ' or Both breasts ', 3, '77785744-a85b-49b9-a641-706fa640c503');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17702, '', 'Left Breast', 8837, 'was it in your Left breast ', 1, '0af8efbc-bb17-4139-9e49-3ad9daf779e2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17703, '', 'Right Breast', 8837, 'Right breast ', 2, 'efacf6fa-9718-4bcf-997f-3c3ae939ea41');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17704, '', 'Both Breast', 8837, 'or Both breasts', 3, '2f340604-2070-472d-9c9d-158247b5ef4f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24494, '', '1', 58782, '1', 1, 'f0dbb965-3165-44ab-882a-12dda194771d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15306, '', 'grade 1-8', 7631, 'Grade 1 through 8', 1, '4d00fd61-6bf2-4abf-abec-8b0567017ecd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15307, '', 'grade 9-11', 7631, 'Grade 9 through 11', 2, '0be8205b-2672-4f4a-ad10-237714aa2815');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15308, '', 'grade 12', 7631, 'Grade 12 or GED', 3, '66e2b327-c74a-464a-84eb-85c65e617cc6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15309, '', 'junior college', 7631, 'Junior college or vocational school', 4, '98d78db8-06b7-447e-9ca6-a9fe2b499cbc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15310, '', 'college 1-3 year', 7631, 'College 1 year to 3 years, or no degree', 5, '76030ec5-791f-401a-9893-fe03cf7fe956');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15311, '', 'college 4 years', 7631, 'College 4 years or more, or received degree', 6, '12af237b-d3e9-4b91-8212-27b2598148ed');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15312, '', 'graduate', 7631, 'Graduate or professional school', 7, 'f1b03d14-8d54-4672-b36c-214925d30dc6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (15313, '', '1', 7631, 'Don''t know', 8, '1b7d897e-b440-4ec1-bc6d-efdf1c4805c9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24495, '', '2', 58782, '2', 2, '00601940-8488-4f89-a32b-c1dadfc95482');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24496, '', '3', 58782, '3', 3, 'd324f13e-5756-4f01-8895-adff643a6281');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24497, '', '4>', 58782, '4 or more', 4, '1b508f41-09d5-4df7-a8f1-3003d5c07593');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24498, '', 'cant remember', 58782, 'I don''t know/I can''t remember.', 5, '3e5dd5bc-71a0-489b-b313-203904004b03');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24499, '', 'n/a', 58782, 'I''d rather not say.', 6, 'c8a656b0-3749-48d6-9a85-2a1e866d256f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24896, '', '2', 12418, 'Yes', 1, '68a7f4cf-29bd-4f05-87c9-2f415475158c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24897, '', '1', 12418, 'No', 2, 'b7c39fae-d648-4739-9791-16bd0499cb0f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (22201, '', '', 11096, 'Just About anytime', 1, 'e6f9baa6-5f43-4205-a71f-b30dcc0c99c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (22202, '', '', 11096, 'Only once in a while', 2, '2f9e3b20-7031-48a2-8457-14816664bce1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (22203, '', '', 11096, 'Occasionally', 3, 'bef0d9bd-fce9-4723-997e-5a38dadeeeb1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (22204, '', '', 11096, 'When It''s hot out', 4, '97f91179-8e76-4cf2-99f6-2ffbd93e8a5b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (22205, '', '', 11096, 'No I don''t. I never eat ice cream.', 5, 'a5275edb-e13e-4d3f-86d8-ec557e3a189b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17639, '', 'select one', 8836, 'Please Select one:', 1, '20483643-b0e3-483f-9725-cfecf4bbc083');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17700, '', '1', 8836, 'No', 2, 'e6e46089-4a7b-470d-99c8-127526438ea6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17701, '', '2', 8836, 'Yes', 3, '804427ec-6983-404d-8e69-e46d34721005');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (17705, '', '', 8838, '"Year":', 1, 'a6fdc5ce-7ba7-4cb1-8b57-a0e4cc3fa07d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23183, '', '1', 10864, 'Any brand is OK', 1, '09196ebc-3abd-4e1c-a328-418467e8a349');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23184, '', '2', 10864, 'Breyers', 2, '8a6d9f7c-7e09-4e19-a2eb-93518b65d10a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23185, '', '3', 10864, 'Bart''s Homemade', 3, 'bb5bdd9b-f2ab-49fc-8ca0-1cb1ad9d382c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23186, '', '4', 10864, 'Cadbury', 4, '79648164-6f6f-4c90-8ada-fda80e155bb8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23187, '', '5', 10864, 'Deans', 5, '5bb90c38-766c-4480-b288-e6e8aca0a44b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23188, '', '6', 10864, 'Hershey''s', 6, '3b78d028-19e3-4ef2-a032-5e110986cf7d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23189, '', '7', 10864, 'Blue Bunny', 7, 'e76f3e17-218e-4e54-adbe-bef81a633806');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24520, '', 'no longer ', 12193, 'Yes, I have taken menopausal hormone therapy in the past, but no longer do', 1, 'ea5af876-c760-43b9-aa3a-4ae2b1fccaed');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24521, '', 'currently', 12193, 'Yes, I am currently taking menopausal hormone therapy.', 2, '9bbf86bf-ca1a-432c-b376-76d2e4918f1f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23200, '', '8', 10864, 'Ben & Jerry''s', 8, 'f75f1cf3-0276-427b-ba38-31550be3751d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23201, '', '9', 10864, 'Dreyer''s Grand', 9, '84b06d84-7ed9-45c7-8b2c-a7357eb21499');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23202, '', '10', 10864, 'Haagen Dazs', 10, '43a987e9-7f37-4d92-9f94-51a29fba83f2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23203, '', '11', 10864, 'Walgreens', 11, 'bf7ced30-0214-4786-a4db-531ce3af56c3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23204, '', '12', 10864, 'Store brand', 12, '017e105f-391b-46f6-aa5d-bd18eb89e834');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23205, '', '000', 10864, 'Other brands', 13, '628871ac-b6bb-48c2-8810-47016cb052fd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24522, '', 'never', 12193, 'No, I have never taken menopausal hormone therapy.', 3, '19858515-7692-40ab-b9ce-b0b7824ede71');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31278, '', 'A lot', 15572, 'A lot', 21, '5e98ff8c-504a-4f02-9c05-a92cb9a4900d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24523, '', 'dont know', 12193, 'I don''t know whether I have taken menopausal hormone therapy.', 4, '9eff65e8-c83a-4a55-a6b3-67485be42ac3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31279, '', 'Yes, more than once', 15572, 'Yes, more than once', 22, '6d961fb4-03f3-4945-891a-bed2562e427a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31280, '', 'Yes, once', 15572, 'Yes, once', 23, '61a252d7-d23a-4e3d-9841-13d78783c01f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24898, '', '', 12170, 'Nodes are positive:', 1, '53b0523e-ee05-4ce5-bb32-326b24627913');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24200, '', '', 12096, 'Just About anytime', 1, '6e0000db-026d-4409-8194-39fdc98cbf77');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24201, '', '', 12096, 'Only once in a while', 2, '8d5c9afa-28ce-4445-bb0e-bb1032c5d083');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24202, '', '', 12096, 'Occasionally', 3, 'dab75917-dd71-4e47-80da-ba360dfce0de');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24203, '', '', 12096, 'When It''s hot out', 4, '22b737eb-7aed-46e3-bf92-08f3a401894d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24204, '', '', 12096, 'No I don''t. I never eat ice cream.', 5, '42ed55b1-a8da-486d-b89d-75a3b9255481');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31425, '', '1', 15722, '1-2 times per week', 1, 'f6de04cb-0ffc-489e-8a11-6eedc2ec2848');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31426, '', '2', 15722, '2-3 times per week', 2, 'dbd00ff5-77d5-4f3a-a536-75be34063d75');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31427, '', '3', 15722, '3-4 times per week', 3, 'f0609282-8610-4f9e-9ee8-6a21daf2be7d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31428, '', '4', 15722, 'More than 4 times per week', 4, 'c8f5f427-3d0e-4d20-b59e-1357148b02d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31429, '', '0', 15722, 'Do not exercise', 5, '978e3088-53f6-4219-917d-8f740067a19c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31590, '', '1', 15790, 'Any brand is OK', 1, 'd409cf76-5ff8-4263-a435-36e5ada78335');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31591, '', '2', 15790, 'Breyers', 2, 'fc922ba6-c009-4c53-820a-646e129ed5a7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24899, '', 'part of overy', 12320, 'Yes, I have had surgery to remove part of an ovary.', 1, 'a3a260ed-82f1-49ba-8dd6-54ee4f461bde');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24950, '', 'one overy', 12320, 'Yes, I have had surgery to remove one ovary, but not both ovaries.', 2, '2cf288f7-97cf-49a2-8b10-39bc2398c075');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24951, '', 'both overies', 12320, 'Yes, I have had surgery to remove both ovaries.', 3, '6fd21a39-6787-46fd-afc0-e1a1a812cc78');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24952, '', 'none', 12320, 'No, I have never had a surgery to remove any part of an ovary.', 4, 'a9fc5e99-1575-4d25-8550-9dcc811fba00');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24953, '', 'dont remember', 12320, 'I don''t know/I can''t remember.', 5, 'b5491d8d-8e1d-404b-b5b7-f37cf354468b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24954, '', 'n/a', 12320, 'I''d rather not say', 6, 'ff424fd8-1ecd-40d6-815e-351cc3745bda');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (23207, '', '', 10863, 'Other toppings', 1, 'a7230f4d-1e92-4895-9398-c3246660c759');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24205, '', '', 12097, 'Just About anytime', 1, 'ef2560b5-ed53-4a32-97ef-918234de9c3b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24206, '', '', 12097, 'Only once in a while', 2, 'c457d7f1-caf6-4096-b874-6fb4bcd1d951');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24207, '', '', 12097, 'Occasionally', 3, '5e7147fd-a014-4080-b569-82b3b63d633f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24208, '', '', 12097, 'When It''s hot out', 4, '94bc0f91-c62a-4b2f-8d48-ed2fadff7d5a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24209, '', '', 12097, 'No I don''t. I never eat ice cream.', 5, '524a4256-495c-46a7-a26a-8f764542d7d0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31592, '', '3', 15790, 'Bart''s Homemade', 3, 'b7f9bbdb-5bf1-45a8-9d43-3d59098fb407');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24956, '', '', 12321, 'Please enter year (YYYY)', 1, 'de1ed6b8-4e0e-42a9-b8b4-0d5e4d968170');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21702, '', 'cancer patient', 7345, 'Breast cancer patient or survivor', 1, 'edc7cbf6-7868-4095-89d1-058cd4961b78');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21703, '', 'friend of patient', 7345, 'Family member or friend of a breast cancer patient', 2, 'e012ad8c-bd78-4175-89ad-28214a9ed56f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21704, '', 'healthcare provider', 7345, 'Health care provider', 3, 'eadb545f-a8e7-476c-a38a-4ea283f63a0c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21705, '', 'researcher', 7345, 'Researcher', 4, 'a2e9dff2-db25-4dc8-a573-55b562b34a3f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (21706, '', 'other', 7345, 'Other', 5, '6e0482bf-e26f-40f1-9e45-e5cddb66a528');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (22315, '', '', 11171, 'test', 1, 'd6bbb9dc-8ffe-432b-92b4-69b28f99343b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24210, '', '', 12098, 'Just About anytime', 1, 'f4275f84-4d83-4b0d-b7a3-b272f930be2e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24211, '', '', 12098, 'Only once in a while', 2, 'dda4e8a5-335f-4fa3-9f60-d539c76df994');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24212, '', '', 12098, 'Occasionally', 3, '42bb3580-846d-4f5c-975a-141728aa0da9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24213, '', '', 12098, 'When It''s hot out', 4, '56e0b86b-81ff-43bb-afb0-f22c2fd7ff10');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24214, '', '', 12098, 'No I don''t. I never eat ice cream.', 5, 'dcf0eedf-6c8c-40c9-ba6d-23338c3c7f92');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24566, '', 'never', 12277, 'I have never had a period', 1, '687d47c5-b339-4fa4-81f1-8ec1e0234a5f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24567, '', '<10', 12277, 'Under age 10', 2, 'a8d28501-a12b-4d5e-891f-808f93a9cd10');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24568, '', '10', 12277, '10', 3, 'c7b03de1-93e4-4ff6-9b87-a212efbd2ecd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24569, '', '11', 12277, '11', 4, 'da7095bd-9554-427e-8d56-4fee5a723f8b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24590, '', '12', 12277, '12', 5, '55a2a12a-5272-4990-9a99-a941070ceb30');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24591, '', '13', 12277, '13', 6, '3cf5302f-82de-41bf-a30b-df85a7dbfe88');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24592, '', '14', 12277, '14', 7, '08230c8c-a10d-4740-9190-61f1408073fe');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24593, '', '15', 12277, '15', 8, '837b9393-d283-4c38-9afb-5550b6c12fa3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24594, '', '16', 12277, '16', 9, 'eb8053b5-f940-4a51-95c8-32361a15fa1b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24595, '', '17>', 12277, '17 years old or older', 10, '0f779a16-206e-4eca-8fad-4d7d3dd7158f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24215, '', '2', 9408, 'Yes', 0, 'c5ef0fb8-e505-4151-b4c8-97204a927281');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24216, '', '1', 9408, 'No', 0, '49a09364-f970-46d6-acdc-08e6fd436511');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24217, '', '2', 9409, 'Yes', 0, '7b66f9af-483c-4709-b9e7-f37f59f49155');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24218, '', '1', 9409, 'No', 0, 'a5600df5-220c-4042-b989-3772b7f5d0ec');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24219, '', '2', 9510, 'Yes', 0, '263bbdb4-8bf5-488c-a3cd-e812dc315661');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24220, '', '1', 9510, 'No', 0, '73062e04-6eff-44a6-a5a1-a8b67e9d2c50');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24221, '', '2', 9511, 'Yes', 0, 'a200f598-e233-4d40-bf47-feb860a24fef');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24222, '', '1', 9511, 'No', 0, '3678ac7d-ffd1-48e2-bcd0-0e028d9f6b69');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24223, '', '2', 9512, 'Yes', 0, '3fd1f46d-261a-4eaa-9fee-477c5e9d1ea9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24224, '', '1', 9512, 'No', 0, 'be16239b-e1ff-453b-ba85-6d8401e4a912');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24225, '', '2', 9513, 'Yes', 0, '1388fe69-072d-4bb8-bb90-beed6dcde9a8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24226, '', '1', 9513, 'No', 0, '1d3ea378-2229-4849-9a7d-046c0ad5dee4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24227, '', '2', 9514, 'Yes', 0, '173de571-c514-4705-9eed-2c268d9e125c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24228, '', '1', 9514, 'No', 0, 'eb83dbd5-6c95-447c-8190-f431f37d16e0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24229, '', '2', 9520, 'Yes', 0, '5e32a555-9509-47b8-b7a2-fe6251fe397a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24230, '', '1', 9520, 'No', 0, '395c971d-88e1-41c0-8834-2cab42147425');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24231, '', '2', 9521, 'Yes', 0, '67cc899a-10e5-48b9-b9a1-30b22fab40ce');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31593, '', '4', 15790, 'Cadbury', 4, '93bb914e-6051-46c3-be7b-b2a2af26bbc8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31594, '', '5', 15790, 'Deans', 5, 'c0a534d9-7ebe-4aee-88b7-1bb2d1d52579');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31595, '', '6', 15790, 'Hershey''s', 6, '7e13faad-b8e9-4204-b7a5-0c0c56f9cf61');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31596, '', '7', 15790, 'Blue Bunny', 7, 'b1a2e182-0e6c-44b9-83ba-99ce894faf18');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31597, '', '8', 15790, 'Ben & Jerry''s', 8, '0d8fef23-cd12-4ec0-b07c-3797d71be283');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24232, '', '1', 9521, 'No', 0, '2a866bef-68bf-45b0-9284-7514f240af99');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24233, '', '2', 9522, 'Yes', 0, '2a9edf4e-ad51-4234-b269-11a0d22d13b3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24234, '', '1', 9522, 'No', 0, 'f33e5f04-c50a-4682-87a6-25a3be7acbaa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24596, '', 'dont remember', 12277, 'I don''t know/I can''t remember', 11, '55713478-75fb-4461-8b3a-371a12d04d97');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24597, '', 'n/a', 12277, 'I''d rather not say', 12, 'ef18f31f-6aa5-4ee5-9b3f-fc6b3dd126fc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33143, '', '1', 16220, 'All or most of my free time was spent doing things that involve little physical effort.', 1, '0f4d2ecf-4212-44d4-9376-85cb5fc5c282');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33144, '', '2', 16220, 'I sometimes (1-2 times last week) did physical things in my free time (e.g. played sports, went running, swimming, bike riding, did aerobics). ', 2, '06450792-725b-49b0-b8f4-c838931a0ab1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24235, '', '2', 9523, 'Yes', 0, '627ff605-3254-4450-b927-e69e3346becd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24236, '', '1', 9523, 'No', 0, '1310e608-e226-4b50-a1b9-930a20d02e6b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24237, '', '2', 9524, 'Yes', 0, 'e704b714-3ba6-4a03-95d1-a3393f951ba8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24238, '', '1', 9524, 'No', 0, 'ea3ababa-1c87-4c8f-83c2-a364378f9a40');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24239, '', '2', 9530, 'Yes', 0, 'b01d71d9-875c-45ce-a1de-5d7c2c27425d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24240, '', '1', 9530, 'No', 0, 'c79574e1-adc2-45ef-86cd-b880653078a0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24241, '', '2', 9531, 'Yes', 0, 'cae21d44-e48e-410d-8229-0c0026a6a316');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24242, '', '1', 9531, 'No', 0, 'feac1b31-bbea-4fc2-8238-0cee44dc6692');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24243, '', '2', 9532, 'Yes', 0, 'cfe27f42-982f-4e49-9132-11f06f715ba0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (24244, '', '1', 9532, 'No', 0, '88ba88a3-aaf1-4873-9e5d-5c9053797890');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33145, '', '3', 16220, 'I often (3-4 times last week) did physical things in my free time. ', 3, '816db1e4-8d59-41cb-888b-7cff84279c10');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31510, '', 'Y', 15723, 'Yes', 1, '05607d07-eabc-4c2b-8c6d-20bdcd16fc44');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31511, '', 'N', 15723, 'No', 2, '264cc61e-192a-48fc-a664-5b510cd0bc67');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31512, '', 'Y', 15724, 'Yes', 3, 'a6fd73f3-18ba-413a-b90e-d493edff91a1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31513, '', 'N', 15724, 'No', 4, 'e9f5902e-f424-4601-a3e9-d910ed16c0c4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31514, '', 'Y', 15760, 'Yes', 5, '7f1067d4-3656-42ff-86ce-673b56967ea3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25237, '', 'DCIS', 12632, 'In Situ (DCIS)', 1, '6023ec4a-a4e1-4184-9f09-661658579ba6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25238, '', 'LCIS', 12632, 'In Situ (LCIS)', 2, 'e9827f9d-4dc1-4d2a-8f69-62afaa18e1fd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25239, '', 'DUctal', 12632, 'Ductal carcinoma (invasive or infiltrating)', 3, '84741507-19c2-4ef1-b377-adfecb07eb96');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25290, '', 'Lobular', 12632, 'Lobular carcinoma (invasive or infiltrating)', 4, 'c4c9642c-e991-4191-b4c3-c1b61110563e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25291, '', 'Other', 12632, 'Other (invasive or infiltrating)', 5, '7dcb30a9-43f8-4cbe-8e89-ecd1e46ae4ac');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25292, '', 'dont know', 12632, 'I don''t know/I can''t remember', 6, '655fbb1a-e148-46fa-ac21-7e0c719d4ee4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25293, '', 'n/a', 12632, 'I''d rather not say', 7, '79161efa-e9cb-419a-8a84-932c80f151f3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25294, '', 'yes', 12633, 'Yes', 1, '11fb941c-1d65-4b43-b766-9d7346949337');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25295, '', 'no', 12633, 'No', 2, '33b6eb2c-51ad-440d-8221-3c23faa11352');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25296, '', 'not tested', 12633, 'Not Tested', 3, 'f2d65657-c112-4a7b-8de2-61dad28bd0df');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25297, '', 'd/n', 12633, 'I don''t know/I can''t remember', 4, 'f860969e-9d54-4c6f-ba88-fe6958bb82cc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25298, '', 'not say', 12633, 'I''d rather not say', 5, '4a2f9d72-f5d2-40a8-ab66-ace569a927b2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25299, '', 'Yes', 12634, 'Yes', 1, '0d3f90cc-1226-4610-9d26-1a454ee76f1d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25320, '', 'No', 12634, 'No', 2, 'c7cf126e-df86-43e0-9e14-fd55792253e7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25321, '', 'dont know', 12634, 'I don''t know/I can''t remember', 3, '5758fa88-d44b-4105-80e0-2e1fb0cc0ea6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (25322, '', 'N/A', 12634, 'I''d rather not say', 4, '09b41f71-8980-470f-96e0-7a6630b5c745');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31515, '', 'N', 15760, 'No', 6, '3146cd3c-d736-4bee-9ef7-8a32d60c6fd9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31516, '', 'Y', 15761, 'Yes', 7, '663da21d-e2a4-4fed-8c20-72d89131770d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27841, '', '', 13915, 'Answer', 1, '23b562bf-39f6-4795-99ed-1c0a73cd4ae4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31517, '', 'N', 15761, 'No', 8, 'b3e6ceb4-f3be-46a6-bc63-e118d186516c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31598, '', '9', 15790, 'Dreyer''s Grand', 9, '162dc871-0100-46d1-a7fd-02d10d1fef17');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31599, '', '10', 15790, 'Haagen Dazs', 10, '36c0b170-c6f1-45c2-9843-30e9c82f1ad0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31600, '', '11', 15790, 'Walgreens', 11, 'c6e43181-a1e8-4921-962f-f83944fe46bf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31601, '', '12', 15790, 'Store brand', 12, '02686bf0-fb3d-4a27-83a4-8576854278ca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31602, '', '000', 15790, 'Other brands', 13, '880cf712-6f07-4eeb-a0ef-9a1290c1c583');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31673, '', '111', 15832, 'search question', 1, 'cf5e1be1-5e8c-4cd4-b4dd-4e390cf97009');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31674, '', '111', 15833, 'search question', 2, '42328f2d-c00f-4aa6-aeb1-90304e23b13c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33146, '', '4', 16220, 'I quite often (4-5 times last week) did physical things in my free time. ', 4, '3797bbf3-a8ce-4702-99aa-64f2b4f0aabb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33147, '', '5', 16220, 'I very often (7 or more times last week) did physical things in my free time. ', 5, 'bf7d6833-8e86-4e11-bb48-5f07fa6e3b8d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33148, '', '0', 16566, 'None', 1, 'e4b09da1-93cd-4429-861c-84e8d2177b4d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33149, '', '1', 16566, '1 time last week', 2, '193634a5-5a0a-4ba2-8931-18a30ccd96b3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33160, '', '2', 16566, '2 or 3 times last week', 3, '0e1e7a14-69de-41d9-9a31-dd3111149604');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33161, '', '3', 16566, '4 or 5 times last week', 4, 'd5d41a55-bb6c-49be-ba61-bab5e798df9c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33162, '', '4', 16566, '6 or 7 times last week', 5, '9da09f1b-4332-4e43-9e90-ccf2e33d3cab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27236, 'Other', 'Other', 13625, 'Other', 1, '04885aaa-2b3f-45b9-861d-f86604904710');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27237, 'Decreased ovarian reserve', 'Decreased ovarian reserve', 13625, 'Decreased ovarian reserve', 2, '0e7a6ce6-46b0-4f13-91d2-8a3eb9b532b5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27238, 'Endometriosis', 'Endometriosis', 13625, 'Endometriosis', 3, 'b6d60f29-a214-47c1-b748-d86144167b90');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27239, 'Ovulation problem', 'Ovulation problem', 13625, 'Ovulation problem', 4, 'cbb4d124-42c6-46b8-bf94-93bd5043d720');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27260, 'Male Factor', 'Male Factor', 13625, 'Male Factor', 5, 'affc7352-1cea-49a3-a706-868973d05b18');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (27261, 'Tubal Factor', 'Tubal Factor', 13625, 'Tubal Factor', 6, 'ab1a3393-b9de-4367-990b-db7228f3c9aa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33420, '', 'yes', 58329, 'yes', 1, '217a6b83-6e1a-4a4f-8c28-07d96f049974');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33421, '', 'no', 58329, 'no', 2, '1a6bb734-4d71-47c8-8790-09be0881ae52');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31530, '', '', 11480, 'Just About anytime', 1, 'abcbd370-c48b-457a-b9a2-5ed1fe15a3e3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31531, '', '', 11480, 'Only once in a while', 2, '4ce39bf5-7bfe-46cf-88bf-d53e56e12fda');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31532, '', '', 11480, 'Occasionally', 3, 'c47fa900-8d8d-401b-baab-c80be02040eb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31533, '', '', 11480, 'When It''s hot out', 4, '80c18b79-c830-4e92-aff2-196680fbde1e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31534, '', '', 11480, 'No I don''t. I never eat ice cream.', 5, '58491658-72ed-461c-9946-f080ff9b3182');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31610, '', '1', 15385, 'Treatment History', 1, '6dd3f759-a4b1-4ea8-a8e3-0e1a5af181c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31611, '', '2', 15385, 'Biopsy Results', 2, '9c82922a-a4b4-44a7-ad0e-58bb6c038aef');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31612, '', '3', 15385, 'Reproductive History', 3, '9d910406-5d48-4d34-819d-7a6ad4ec04e5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31675, '', '12', 15834, 'search question', 1, '44b96365-0a41-4c20-9754-c0bc77638f43');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26602, '', '', 13265, 'If you had this blood test, fill in Number of Times', 1, '5fae1d63-b43d-4534-bc78-e32ffad3c08b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26673, '', 'age', 70001, 'Age of Diagnosis', 1, 'd0b465ac-42ed-441c-a6c9-d64ce9d1593f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26674, '', '<20', 70001, '<20', 2, '2d128a53-54ec-442f-8d82-87869ce8f65d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26675, '', '21', 70001, '21', 3, 'ec00736b-84f5-4638-84ce-0ff3ba55630a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26676, '', '22', 70001, '22', 4, '46a3c765-5c3a-4bd2-acec-45c02d2db81a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26677, '', '23', 70001, '23', 5, '2e6f304b-e124-4185-9797-053b2de27384');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26678, '', '24', 70001, '24', 6, 'f7c249d0-4ffa-4d9e-8244-a6c449ab820d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26679, '', '25', 70001, '25', 7, 'ee44ca19-7ef0-431c-9101-608859ccb484');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26700, '', '26', 70001, '26', 8, 'ed0d0320-d938-4a25-a762-6c812ad83074');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26701, '', '27', 70001, '27', 9, '6cfe1e2f-b7df-49ed-b779-09da787b261a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26702, '', '28', 70001, '28', 10, 'c5bf47b9-59d8-4d71-8931-9d453c3a3907');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26703, '', '29', 70001, '29', 11, 'e5ac6314-6432-4dff-b174-7e90e04ac62d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26704, '', '30', 70001, '30', 12, '91b0e8e3-8feb-4f59-bdfb-a76c81e0d348');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26705, '', '31', 70001, '31', 13, 'a5998d52-3a48-42f5-9505-965d5ca2edb6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26706, '', '32', 70001, '32', 14, '5c02a83e-35bf-45e6-a2fc-81b08bd6f944');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26707, '', '33', 70001, '33', 15, 'f73c6d38-f687-4678-ae17-3bc6a216b79e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26708, '', '34', 70001, '34', 16, '2d585a79-6c93-4d65-8fbd-f39180fcb487');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26709, '', '35', 70001, '35', 17, 'e10338a0-6aef-47d8-99e3-04f49d942f6e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26710, '', '36', 70001, '36', 18, 'eb354d57-82b5-4216-915a-8896ed997855');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26711, '', '37', 70001, '37', 19, '3b730508-02f4-4505-855a-b7e2f6adda5f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26712, '', '38', 70001, '38', 20, 'd114ee71-ba53-4ffb-8b7b-b7a4b7216b5b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26713, '', '39', 70001, '39', 21, '42f6eb6d-b9b0-4e4b-b2fa-9e3f0a365706');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26714, '', '40', 70001, '40', 22, '6d5ecabc-8c3c-48f7-b5fb-c2b959560fa5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26715, '', '41', 70001, '41', 23, '801f4999-1416-4b03-85b1-cac7208bc496');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26716, '', '42', 70001, '42', 24, 'd376e9c1-d915-47a9-ae8f-a2cfaf85d56d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26717, '', '43', 70001, '43', 25, 'e6eda4ac-cd18-4292-8e4c-a9855f26534c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26718, '', '44', 70001, '44', 26, '0c707a97-4b24-40e5-9b44-a5d6bfd8998d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32104, '', 'yes', 59909, 'Yes', 1, 'c53ad187-9638-47de-8b49-3f18e98c3f99');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32105, '', 'no', 59909, 'No', 2, '97e2af3f-abcf-4405-a019-e791f116334a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32106, '', 'na', 59909, 'I''d rather not say', 3, 'bff52bff-efaf-4fbb-bc1b-c3a64c49fdc5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26719, '', '45', 70001, '45', 27, '211dab2e-2049-4617-aa9b-1b58aaa9b72d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26720, '', '46', 70001, '46', 28, '87ddc945-5451-4690-867c-36af49f435a2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26721, '', '47', 70001, '47', 29, '63e68379-bfad-478d-8dff-51788d7c1732');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26722, '', '48', 70001, '48', 30, '8b902c5a-d086-4678-8d6b-3cda1380e118');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26723, '', '49', 70001, '49', 31, 'd99838e0-f264-4229-b87d-e84393652239');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26724, '', '50', 70001, '50', 32, '57a97923-0736-4cbd-80f7-8c767d658965');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26725, '', '51', 70001, '51', 33, 'fecc7ff9-a7fe-462b-b0b3-fc8d9d5edf7a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26726, '', '52', 70001, '52', 34, '6f92d65d-afc0-47bb-8d57-edd213cabcf2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26727, '', '53', 70001, '53', 35, '40173658-7eb0-46ed-8e98-fc1e7d193125');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26728, '', '54', 70001, '54', 36, 'e30882e7-c34a-4993-bc27-8e7461d4d29f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26729, '', '55', 70001, '55', 37, 'f74a60b2-4de2-4025-88f4-72ce656825ce');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26730, '', '56', 70001, '56', 38, '5278a90b-24f7-4f90-b2d1-8ee25e74321d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26731, '', '57', 70001, '57', 39, 'fdecf2f0-da58-495e-814f-a2e57d7cf58d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26732, '', '58', 70001, '58', 40, 'c11569d3-90ef-4112-991e-8c6c14e6e9dd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26733, '', '59', 70001, '59', 41, '7e4f7c4b-7a3e-433e-be29-2238ce64b752');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26734, '', '60', 70001, '60', 42, '80b40f63-0274-4066-9b5b-d4c6b07d2c20');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26735, '', '61', 70001, '61', 43, '3a9cce7f-a734-4b01-ac2e-c95b596b61a2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26736, '', '62', 70001, '62', 44, 'f07f4e64-8323-4be5-8cd8-17f358948916');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26737, '', '63', 70001, '63', 45, 'be0eab1f-0e68-4bcc-87ff-ab888a0e8e67');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26738, '', '64', 70001, '64', 46, '0380d6c9-d2fc-43a7-9176-8850fedd7254');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26739, '', '65', 70001, '65', 47, 'e5a6179a-e81d-4d45-ad64-31b716ebf2ee');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26740, '', '66', 70001, '66', 48, 'c2e51a91-bb19-444b-9c82-8c62297124e7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26741, '', '67', 70001, '67', 49, 'bd7742bd-a038-4d5b-9b79-8ba5c79b78be');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26742, '', '68', 70001, '68', 50, '1e8942f7-6f7e-4e93-9388-691017dd3f99');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26743, '', '69', 70001, '69', 51, '29583800-d4da-42b5-98f3-97a98befa84f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26744, '', '70', 70001, '70', 52, 'f82aafdd-01ea-4a01-80ea-aaa060e447e8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26745, '', '71', 70001, '71', 53, 'ae1b4687-c764-4e43-85cd-7da3b5d41c25');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26746, '', '72', 70001, '72', 54, '2be16579-796e-438a-9a7d-b227cbdf2cce');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26747, '', '73', 70001, '73', 55, 'c0ef134f-be69-468e-bda0-9d787192797e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26748, '', '74', 70001, '74', 56, 'a05dc2b1-173a-44b4-afc6-25a44a7571f5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26749, '', '75', 70001, '75', 57, '5b353a79-cf86-4a21-a99e-18b68bc9d409');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26750, '', '76', 70001, '76', 58, '062785bb-b264-4a2b-89a6-88357b6b4b29');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26751, '', '77', 70001, '77', 59, 'b4edf79b-319e-4573-82df-a3eb9ea110c3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26752, '', '78', 70001, '78', 60, '8423e3ad-295c-4c1e-b1c2-478c477010b1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26753, '', '79', 70001, '79', 61, '9fb425aa-95d0-43ac-b697-c34596b7b1e4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26754, '', '80', 70001, '80', 62, 'a26896de-7feb-4a6f-a999-151369165996');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26755, '', '81', 70001, '81', 63, '6dd8a54e-5e69-4707-be44-85ef0fc80ef0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26756, '', '82', 70001, '82', 64, 'fc1072bd-71cc-40e5-a2b5-4f113e9537b5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26757, '', '83', 70001, '83', 65, 'e671e391-b651-4bf3-96f5-950e9e690a5e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26758, '', '84', 70001, '84', 66, 'dd337655-b719-448a-9ab3-fe04f795bf26');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26759, '', '85', 70001, '85', 67, '059517c2-6290-4ab1-8e10-a0772d17106f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26760, '', '86', 70001, '86', 68, '6d39de1a-34df-4707-9132-a65f2d46b5b5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26761, '', '87', 70001, '87', 69, '21e5d66a-1c5c-480e-8c3f-5e9264e16afc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26762, '', '88', 70001, '88', 70, '7f216e1b-26ad-4684-9d64-519122a58a69');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26763, '', '89', 70001, '89', 71, '919764de-0504-45af-8d8e-59d8cdaa0075');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26764, '', '90', 70001, '90', 72, '6b829ce5-9b8e-4624-99c6-bba43c39961c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26765, '', '91', 70001, '91', 73, 'f45bc11b-382a-47c5-8ddd-816489433445');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26766, '', '92', 70001, '92', 74, '7fbb7ca9-0517-43f8-bb51-6d3b35386625');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26767, '', '93', 70001, '93', 75, 'feeea875-7641-4c1a-a934-445757ae568a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26768, '', '94', 70001, '94', 76, '41eeeaef-df8d-4324-b3f2-54b3ce86e681');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26769, '', '95', 70001, '95', 77, 'dffe7319-8d11-4cd4-97bf-a7f1252c36cd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26770, '', '96', 70001, '96', 78, '9b684103-2e1a-4b4e-8da9-0ac0588d6016');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26771, '', '97', 70001, '97', 79, '707e06af-a02b-410c-9eab-79f3a8486504');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26772, '', '98', 70001, '98', 80, 'c216c273-3925-468a-80ec-c650574ee43c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26773, '', '99', 70001, '99', 81, 'decd07f2-d840-4cc5-9516-bcf2a484ac84');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26774, '', '100', 70001, '100', 82, '5e6bdae3-def0-4c38-a78d-d69f2f9e3b24');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (26775, '', '>100', 70001, '>100', 83, '640e52b1-d4a0-47c1-81df-6530b20e6590');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33163, '', '', 16222, 'If Yes, what prevented you?', 1, '54091541-68a0-45a4-a124-afe55bf8138b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28349, 'YES', 'YES', 14166, 'YES', 1, 'c819e226-23c2-46bd-910c-5b816fe4e011');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28380, 'NO', 'NO', 14166, 'NO', 2, 'cf020a9a-5c65-4339-9451-80d6c0089665');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31540, '', '2', 13203, 'Yes', 1, '06c7db65-ca71-4524-a3cc-331e567322a3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31541, '', '1', 13203, 'No', 2, 'f237e3f7-09d9-40dd-8225-301ed6c789c5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31640, '', '', 15815, 'Date', 1, 'aea27dd7-8f5a-4fa1-9610-a3e322ffa5fb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31677, '', '111', 16036, 'search question', 1, '1d1d5e66-5ef2-4e7a-9b20-10a052caef45');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31678, '', '111', 16037, 'search question', 2, '1e94c4d2-3391-4129-bbb3-4200de5c25cc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31679, '', '12', 16038, 'search question', 1, '0dd663cb-c2e1-4163-b03b-42398eac16ea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32107, '', 'Limited', 16085, 'Yes, limited a lot', 0, '4ea268a5-30d1-4f79-bab9-82336df5f6c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32108, '', 'Little Limited', 16085, 'Yes, limited a little', 0, '80d87a39-af1c-4ecd-b59d-50c51b3e1f46');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32109, '', 'Not Limited', 16085, 'No, not limited at all', 0, '30a2017e-f5ba-4194-93cd-a4d8fe89cc88');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32180, '', 'N/A', 16085, 'I''d rather not say ', 0, '24a4ecbf-dc99-45b1-9839-b60bda9098f6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32181, '', 'Limited', 16086, 'Yes, limited a lot', 0, '4408cfdc-0e42-4710-bae4-78d30daf172a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28450, '', '100= Full diet (no restrictions)', 14167, '100= Full diet (no restrictions)', 1, 'c71c790a-c6a5-453e-b160-5dd9ac230df2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28451, '', '90= Peanuts', 14167, '90= Peanuts', 2, '1f264e27-1a5d-4bbb-8712-5d8284961c35');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28452, '', '80= All meat', 14167, '80= All meat', 3, '1439b505-7fd9-4512-a3c2-1f61ced8b709');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28453, '', '70= Carrots, celery', 14167, '70= Carrots, celery', 4, '77d9f843-bd90-484d-93c2-a54eb874107a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28454, '', '60= Dry bread and crackers', 14167, '60= Dry bread and crackers', 5, 'e62da251-2c39-4574-92f0-d02c33c4c963');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28455, '', '50= Soft, chewable foods (e.g., macaroni, canned/soft fruits, cooked vegetables, fish, hamburger, small pieces of meat)', 14167, '50= Soft, chewable foods (e.g., macaroni, canned/soft fruits, cooked vegetables, fish, hamburger, small pieces of meat)', 6, 'd6e863ba-fc37-4e2c-b674-63c24f92e499');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28456, '', '40= Soft foods requiring no chewing (e.g., mashed potatoes, apple sauce, pudding)', 14167, '40= Soft foods requiring no chewing (e.g., mashed potatoes, apple sauce, pudding)', 7, '0d3bba71-cfe8-4fc8-9663-b27ed03fa6e9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28457, '', '30= Pureed foods (in blender)', 14167, '30= Pureed foods (in blender)', 8, '3522a22f-d9ec-4cf8-8abd-75781d39cfd3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28458, '', '20= Warm liquids', 14167, '20= Warm liquids', 9, 'f7a2c17c-a170-469e-9cb4-c2d87f57b1be');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28459, '', '10= Cold liquids', 14167, '10= Cold liquids', 10, '6d0ef33d-5a1a-46db-9442-89c61bb3d6c7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28460, '', '0= Non-oral feeding (tube fed)', 14167, '0= Non-oral feeding (tube fed)', 11, 'ad179086-55f4-46ed-8c14-94c5ca7094a6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32182, '', 'Little Limited', 16086, 'Yes, limited a little', 0, '37c1e0b8-f3a4-4ff4-8c51-84b42123e669');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32183, '', 'Not Limited', 16086, 'No, not limited at all', 0, 'ea2e1624-7a87-492d-a16e-5c05a839398e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32184, '', 'N/A', 16086, 'I''d rather not say ', 0, '7f2042f5-7ad9-4a73-8f88-6465bcc22627');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32185, '', 'Limited', 16087, 'Yes, limited a lot', 0, '8f0a323a-60be-42b5-840d-4f0ed79207b0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32186, '', 'Little Limited', 16087, 'Yes, limited a little', 0, '0be12f14-f446-42c9-853f-c11beffae17e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32187, '', 'Not Limited', 16087, 'No, not limited at all', 0, 'c850394a-3b09-4725-bb71-1a58037e946c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32188, '', 'N/A', 16087, 'I''d rather not say ', 0, 'f14a9713-69f3-4c79-85e1-c97395aec3ee');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32189, '', 'Limited', 16088, 'Yes, limited a lot', 0, '3160ffcd-e413-4653-9f16-6ec8c50fdab8');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32190, '', 'Little Limited', 16088, 'Yes, limited a little', 0, 'c785bd36-6005-4352-89e4-07213220b6fa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32191, '', 'Not Limited', 16088, 'No, not limited at all', 0, '6e953133-086c-423f-a9f4-5c159af719fd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32192, '', 'N/A', 16088, 'I''d rather not say ', 0, 'e72a5468-3c7e-4eda-a161-768a015752ab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32193, '', 'Limited', 16089, 'Yes, limited a lot', 0, '3f48f839-691d-435d-a627-7f4cef977f47');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32194, '', 'Little Limited', 16089, 'Yes, limited a little', 0, '1a40a663-3b97-4ab3-94b4-6ab16d60687c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32195, '', 'Not Limited', 16089, 'No, not limited at all', 0, '59cad090-9f75-4e63-90e9-2364aafccb60');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32196, '', 'N/A', 16089, 'I''d rather not say ', 0, '4f6eb853-7cf2-4e19-b9b4-4cc14d5d0f8a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32197, '', 'Limited', 16100, 'Yes, limited a lot', 0, '663e92f9-7874-4bd6-be8f-9932aad7af12');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32198, '', 'Little Limited', 16100, 'Yes, limited a little', 0, '0980d212-565e-463e-8720-fb37d3e8a0bf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32199, '', 'Not Limited', 16100, 'No, not limited at all', 0, 'c83a877c-58ce-4709-94c0-c365dd3b6770');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32210, '', 'N/A', 16100, 'I''d rather not say ', 0, '282126ec-12f6-43ca-a3fe-1d922697059d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32211, '', 'Limited', 16101, 'Yes, limited a lot', 0, '8ad4ed64-76dc-4708-8777-84dddbc2acea');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32212, '', 'Little Limited', 16101, 'Yes, limited a little', 0, '4016eef4-4523-45c7-9cf7-bdd1fdb8656e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32213, '', 'Not Limited', 16101, 'No, not limited at all', 0, 'f5701a7a-0e3b-4e88-81e6-289a93d11686');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33166, '', '2', 16221, 'No', 1, 'a12b0de2-a931-471a-b76e-693cf0824299');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33167, '', '1', 16221, 'Yes', 2, '8c9c6516-6dc0-4ff1-9607-0eae993c7959');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33168, '', '', 16221, 'may be', 3, '7f1a9c12-30ac-417e-8e3c-d2e37e08212b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33460, 'Unknown', 'Unknown', 16725, 'Unknown', 1, '637a79f2-cac6-451c-af35-04a3b9a927f2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33461, 'Yes', 'Yes', 16725, 'Yes', 2, '5a58d344-38d4-426d-9550-666765dfbad1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33462, 'No', 'No', 16725, 'No', 3, '597192c9-0d91-45f0-92a5-0ea54df6ad53');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32214, '', 'N/A', 16101, 'I''d rather not say ', 0, '32a5c6fa-91f0-4e20-9a50-8f449b5ab5f5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32215, '', 'Limited', 16102, 'Yes, limited a lot', 0, '9e906c34-43fd-4f41-aa9e-4c1294de5212');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32216, '', 'Little Limited', 16102, 'Yes, limited a little', 0, '8d4fdcc6-cef8-4afa-98c0-76312b04ab0f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28631, 'Person Dietary Supplements Use Frequency Number', 'Person Dietary Supplements Use Frequency Number', 14306, 'Person Dietary Supplements Use Frequency Number', 1, '70eb7418-1c31-4b02-ab29-3c3dd0bcc771');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28632, 'Diet Restart Date', 'Diet Restart Date', 14307, 'Diet Restart Date', 1, '15e2a2f1-23b8-43cd-82e4-3b89b9cf8fc9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28633, 'Not at all', 'Not at all', 14308, 'Not at all', 1, 'b3dd85ac-801b-42c4-8132-42c6ba9dff79');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28634, 'Hardly ever', 'Hardly ever', 14308, 'Hardly ever', 2, '15920b68-ea8f-4e9b-8eca-672a2fedef55');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28635, 'Occasionally', 'Occasionally', 14308, 'Occasionally', 3, '9e0529a5-fb05-4aaa-9127-3d3004feb994');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28636, 'Fairly often', 'Fairly often', 14308, 'Fairly often', 4, '56a00f31-2227-42e3-8ee3-c9927f009617');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28637, 'Very often', 'Very often', 14308, 'Very often', 5, 'c775d617-10cf-4812-8b73-92c644c33c28');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33508, '', '1', 16729, 'No', 16, '0a63be79-1a81-4e0e-a18a-8463c2213cc9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28638, 'Weight Diet History Questionnaire Descriptive Text', 'Weight Diet History Questionnaire Descriptive Text', 14309, 'Weight Diet History Questionnaire Descriptive Text', 1, 'a3ce170a-4fd0-40e4-bea8-67359bef10e5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28639, '100= Full diet (no restrictions)', '100= Full diet (no restrictions)', 14400, '100= Full diet (no restrictions)', 1, '9740c6f0-547d-452f-8681-374453c3c500');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28810, '90= Peanuts', '90= Peanuts', 14400, '90= Peanuts', 2, 'ae0ce88e-b270-48a9-8105-e484d458754f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28811, '80= All meat', '80= All meat', 14400, '80= All meat', 3, '7e930061-3efe-49ef-8b19-b950adcac924');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28812, '70= Carrots, celery', '70= Carrots, celery', 14400, '70= Carrots, celery', 4, '5c7f7599-6bda-4d66-a5d2-5deec02e6814');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28813, '60= Dry bread and crackers', '60= Dry bread and crackers', 14400, '60= Dry bread and crackers', 5, '685227cb-6aa1-4b21-90e9-f0537fbfbb37');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28814, '50= Soft, chewable foods (e.g., macaroni, canned/soft fruits, cooked vegetables, fish, hamburger, small pieces of meat)', '50= Soft, chewable foods (e.g., macaroni, canned/soft fruits, cooked vegetables, fish, hamburger, small pieces of meat)', 14400, '50= Soft, chewable foods (e.g., macaroni, canned/soft fruits, cooked vegetables, fish, hamburger, small pieces of meat)', 6, '23aea2cb-4d40-4826-ab01-44d5041bbd65');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28815, '40= Soft foods requiring no chewing (e.g., mashed potatoes, apple sauce, pudding)', '40= Soft foods requiring no chewing (e.g., mashed potatoes, apple sauce, pudding)', 14400, '40= Soft foods requiring no chewing (e.g., mashed potatoes, apple sauce, pudding)', 7, 'a6f6917a-8f00-486b-8c3f-2093b5aab743');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28816, '30= Pureed foods (in blender)', '30= Pureed foods (in blender)', 14400, '30= Pureed foods (in blender)', 8, '88471146-856c-4977-aba3-d8c200e554e1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28817, '20= Warm liquids', '20= Warm liquids', 14400, '20= Warm liquids', 9, '05c3cdd1-99c3-4eca-a9ef-503de9bad928');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28818, '10= Cold liquids', '10= Cold liquids', 14400, '10= Cold liquids', 10, 'c465e36a-dbb9-494d-8ace-61524cfadbee');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28819, '0= Non-oral feeding (tube fed)', '0= Non-oral feeding (tube fed)', 14400, '0= Non-oral feeding (tube fed)', 11, '6a6d3d96-6740-4f7e-a4a2-d10eef8dbdce');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28830, 'Special Diet Stop Date', 'Special Diet Stop Date', 14401, 'Special Diet Stop Date', 1, '9f206e7d-1903-4265-99ad-fe3058c30b0a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (28831, 'Special Diet Start Date', 'Special Diet Start Date', 14402, 'Special Diet Start Date', 1, 'eef6a38d-6a9c-4e0d-a560-86ba59d80de7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32217, '', 'Not Limited', 16102, 'No, not limited at all', 0, '2d9a331c-1c59-4bb2-8265-9b3c36a82b57');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32218, '', 'N/A', 16102, 'I''d rather not say ', 0, 'e649757e-9dd8-4d39-b559-9acce5585ded');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32219, '', 'Limited', 16103, 'Yes, limited a lot', 0, 'ce11ee0a-a513-491e-b834-f5631ddc9c80');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32220, '', 'Little Limited', 16103, 'Yes, limited a little', 0, 'c602f51f-0304-4033-9527-27fb61e7ca26');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32221, '', 'Not Limited', 16103, 'No, not limited at all', 0, '166be494-0e6c-4e2f-9db1-3af2cddac9e2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32222, '', 'N/A', 16103, 'I''d rather not say ', 0, 'cc4cdd21-09b1-4544-8e09-28961a63cc91');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32223, '', 'Limited', 16104, 'Yes, limited a lot', 0, '31690b5d-5c58-47b5-a749-ce40771bb4d0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32224, '', 'Little Limited', 16104, 'Yes, limited a little', 0, '4939ba84-564b-425c-968f-ea072b7aa243');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32225, '', 'Not Limited', 16104, 'No, not limited at all', 0, '2d3b3156-0c76-4701-bea7-e706b57244cf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32226, '', 'N/A', 16104, 'I''d rather not say ', 0, '80fed2c9-ec98-4ea3-b12c-18b9772a4d7d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32227, '', 'Limited', 16115, 'Yes, limited a lot', 0, '2e7a567b-4c97-49a1-9d8f-c3eb26c24720');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32228, '', 'Little Limited', 16115, 'Yes, limited a little', 0, '063faf12-41ce-4e36-9c12-246d3a1fc974');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32229, '', 'Not Limited', 16115, 'No, not limited at all', 0, '7cf47040-aaf4-43e6-8a5e-3eae024ac2f4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32240, '', 'N/A', 16115, 'I''d rather not say ', 0, 'e34353d8-94c7-4bcf-9e92-0203ea67d3df');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32364, '', '0', 16172, 'None', 1, '6cf5132d-be5f-4771-83cc-64242e91c03e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32365, '', '1', 16172, '1 time last week', 2, '5b474c79-1538-4260-bb29-3969d77dd8ca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32366, '', '2', 16172, '2 or 3 times last week', 3, '64cae62d-c773-4765-9bf9-30522178cefd');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32367, '', '3', 16172, '4 or 5 times last week', 4, '3e76580d-0c8b-4dff-a650-d21004ca090c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32368, '', '4', 16172, '6 or 7 times last week', 5, '1ae4e50d-eac5-4e74-b0ac-689ff71652e2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33463, '', '1', 16726, 'No', 1, 'fe3fab85-a902-4a33-8535-3cd9260f4d9c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33464, '', '2', 16726, '1-2', 2, '3721950d-60cb-49c4-aac4-c64e46a07617');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33465, '', '3', 16726, '3-4', 3, 'd06ff40e-2622-4503-b9a4-c22552a940fe');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33466, '', '4', 16726, '5-6', 4, '43e7f23b-bcd6-4bf0-a275-0440b5ad46d1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31544, '', '', 7632, 'First Name:', 1, '75a0cccb-ba69-4eb9-adbf-bc14c3b8a4c9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33467, '', '5', 16726, '7 Times or more', 5, '469c7e40-c655-4327-aacc-deb0727068ac');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33468, '', '1', 16727, 'No', 6, '3359967c-ddd8-47a9-b224-f1eeccbaabe9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32250, '', 'Hot chocolate', 10718, 'Hot chocolate', 1, '8cf538b1-92f8-44ba-bef7-1ba4e652772c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32251, '', 'Marshmallow', 10718, 'Marshmallow', 2, '66fae805-86a0-4244-aa6a-5daeecfebc0e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32252, '', 'Butterscotch', 10718, 'Butterscotch', 3, '335e154c-33e3-4e33-987d-2dc2b20d4d9f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32253, '', 'Nuts', 10718, 'Nuts', 4, '45039538-5ee3-498e-8047-cfb016634554');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32254, '', 'Other', 10718, 'Other toppings:', 5, 'a1853ef2-d789-4757-98bc-2cc777bfd28b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32255, '', '', 10718, 'I usually eat ice cream without any toppings.', 6, '3330447f-b2f6-4ca8-8248-263389ee2edf');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32369, '', '1', 16173, 'None', 1, 'f1a711b7-e4cd-4208-91f3-a7ec1b476b45');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32410, '', '2', 16173, '1 Time last week', 2, '82066330-f53c-4a82-b39d-84a4035ae510');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (32411, '', '3', 16173, '2 or 3 times last week', 3, '5b5d260a-d6d8-4e6b-89bc-56c5fe9d782a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33469, '', '2', 16727, '1-2', 7, '60c79a51-9aaa-4cb7-9cf6-56456fefbf81');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33500, '', '3', 16727, '3-4', 8, 'c246ba56-c011-4263-887f-fd357dffe968');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33501, '', '4', 16727, '5-6', 9, '599051ae-c90b-4e12-9d6e-c197b36c334e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33502, '', '5', 16727, '7 Times or more', 10, '559cb453-5b0c-4b2b-acd3-03dee9397bc9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33503, '', '1', 16728, 'No', 11, 'e410ea3f-bf4c-46ac-8a2a-95f72cdb9842');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33504, '', '2', 16728, '1-2', 12, 'c65c18d4-3e3f-4ca3-90b2-31e1bdaa5dc7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33505, '', '3', 16728, '3-4', 13, 'a631a75d-3319-4977-bdf2-da782d46e527');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33506, '', '4', 16728, '5-6', 14, '16832947-926e-4d22-b5b1-6145be7dff6d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33507, '', '5', 16728, '7 Times or more', 15, 'a59d641e-446b-4ff0-9483-95eccc071511');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33509, '', '2', 16729, '1-2', 17, '36ef9e6d-2e28-4ecd-ab86-fa5cc67bade6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33510, '', '3', 16729, '3-4', 18, '3ebe0ee6-07eb-455c-a17e-3663fa716b2e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33511, '', '4', 16729, '5-6', 19, 'd0f7d692-d26e-47b3-9835-753f98923423');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33512, '', '5', 16729, '7 Times or more', 20, '955e75d5-f840-4e7c-8813-07b379731b90');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33513, '', '1', 16760, 'No', 21, '9a2a4af4-aec3-40df-a4e2-b0fef545b13b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33514, '', '2', 16760, '1-2', 22, '1403f7d7-5c58-4dea-923c-ecf066fb651d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33515, '', '3', 16760, '3-4', 23, '3c7b2628-ec90-41d2-97e1-959a33032951');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33516, '', '4', 16760, '5-6', 24, '40649b78-50d6-4da0-99bb-ee4cbb46c685');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33517, '', '5', 16760, '7 Times or more', 25, '0778b729-2f9d-4e24-b67e-d97245debbe5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33518, '', '1', 16761, 'No', 26, '84636c0c-5ba7-498b-b011-91d919da93d7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33519, '', '2', 16761, '1-2', 27, '3188663e-7803-4ffc-b63a-d9a790273124');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33530, '', '3', 16761, '3-4', 28, 'f51ccfa4-e104-4e41-b755-65609540dd40');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33531, '', '4', 16761, '5-6', 29, '18e34c0e-50ea-40d4-94e5-970d4c8fe263');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33532, '', '5', 16761, '7 Times or more', 30, 'e4072e62-4b5f-4a69-9fc6-32defa569810');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31163, '', '', 15570, '3', 18, '32f0c358-2ede-4073-b35f-4aaf245c77b1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31164, '', '', 15570, '4', 19, '911c1191-69cf-433d-9210-6d16576dfbd4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31165, '', '', 15570, '5', 20, 'a34f4259-2303-4598-b49e-26fedddc14b0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33539, '', '', 16780, 'a.STRENUOUS EXERCISE (HEART BEATS RAPIDLY)', 1, '42f8d3de-7a4a-4d9a-8a3f-71c636bee329');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (29720, 'Infertility Treatment Descriptive Text', 'Infertility Treatment Descriptive Text', 14855, 'Infertility Treatment Descriptive Text', 1, '338ead01-c259-4919-bda9-c3ea956e5891');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (29722, '2', '2', 14857, '2', 1, '2b5a4cb1-4d2f-486e-85a4-09dfb6f96dc6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (29723, '3', '3', 14857, '3', 2, 'ee20b7b1-258e-4c1b-b95a-3de7ee9d52b5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30130, 'Infertility Treatment Descriptive Text', 'Infertility Treatment Descriptive Text', 15060, 'Infertility Treatment Descriptive Text', 1, '98aa401a-a266-44cc-ab44-3544ce55da97');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30131, '2', '2', 15061, '2', 1, '6a15ce6a-be75-4dea-9975-ef49e6a9fd91');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30132, '3', '3', 15061, '3', 2, '41b6ad2d-7965-46c8-8e81-a042f415146c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30133, 'Person Known Infertility Reason Assessment Description Text', 'Person Known Infertility Reason Assessment Description Text', 15062, 'Person Known Infertility Reason Assessment Description Text', 1, 'ddcc087a-5290-4b31-a17d-9c514a1ea7ab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30325, '', 'Endometriosis', 12948, 'Endometriosis', 1, 'd2ee7b42-ec16-47f4-8521-249b48a2370a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30326, '', 'Decreased ovarian reserve', 12948, 'Decreased ovarian reserve', 2, 'c12bccec-c2c8-45d2-a275-4f2211170e67');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30327, '', 'Ovulation problem', 12948, 'Ovulation problem', 3, 'cff1d7df-3670-4bd4-ba47-c80e9787a0ad');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30328, '', 'Male Factor', 12948, 'Male Factor', 4, '087e4639-4f73-4b2f-9f6a-a9d9d9b0e6c6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30329, '', 'Tubal Factor', 12948, 'Tubal Factor', 5, '02f994d6-922e-4a4a-9ae6-150bfa7901d9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30390, '', 'Other', 12948, 'Other', 6, 'd92e2551-dafa-46d2-8d95-e6f44968206e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30391, '', 'Yes', 13032, 'Yes', 1, '8673be59-7fb2-4f0c-957a-2a8c61d40621');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30392, '', 'No', 13032, 'No', 2, 'af8afb3a-c0c2-4707-b4b5-f5f0d47e092e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30393, '', 'Unknown', 13032, 'Unknown', 3, 'fd157865-7193-4296-af12-bfe1ea2b8e58');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30396, '', 'No', 13770, 'No', 1, '10859106-d816-405b-9c3e-66b10e03e989');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30397, '', 'Yes', 13770, 'Yes', 2, 'd53af3e3-231d-4243-a69b-6849d79a4d0f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30398, '', 'In vitro fertilization', 13771, 'In vitro fertilization', 1, 'e8f045ec-6c1b-413a-9929-52362f92e21d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30399, '', 'Ovarian tissue banking', 13771, 'Ovarian tissue banking', 2, '8088f6b9-ac44-40f0-8049-31b9f3ce7825');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30400, '', 'Surgical ovarian transposition', 13771, 'Surgical ovarian transposition', 3, 'c15914ca-ba6d-4328-b6a1-fd6e3f510f59');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30401, '', 'Oocyte cryopreservation', 13771, 'Oocyte cryopreservation', 4, '944ec023-5381-4a02-8c7b-d3edbfbb45e5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30402, '', 'Embryo cryopreservation', 13771, 'Embryo cryopreservation', 5, '9a6e9a09-5478-43b7-bb63-c43773aab947');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30403, '', 'GnRH agonists such as Lupron', 13771, 'GnRH agonists such as Lupron', 6, '6a3d0831-5fe6-4a95-a78f-adbcae29741f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30404, '', 'Not applicable', 13771, 'Not applicable', 7, 'cbe43e66-656f-4e00-8cea-30567c729cb6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30405, '', 'Surgical oophorpexy', 13771, 'Surgical oophorpexy', 8, 'cd8679ac-d382-4e4c-869a-4a9058dc8abb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30406, '', 'Missing', 13771, 'Missing', 9, '81a3193a-07e5-421c-a1aa-9324fc1ce873');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30407, '', 'Other (Please specify)', 13771, 'Other (Please specify)', 10, '65524648-0583-42f8-a398-1a44ab1feaa3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30416, '', 'DCIS', 13662, 'In Situ (DCIS)', 1, 'af80586f-688d-4d12-a454-c33dc4b67bf0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30417, '', 'LCIS', 13662, 'In Situ (LCIS)', 2, '6cc9e9be-fd56-4abc-8af0-666cb04f0cdb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30418, '', 'DUctal', 13662, 'Ductal carcinoma (invasive or infiltrating)', 3, '481ab3dd-f83a-42fd-a2cd-76af3d2a4933');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30419, '', 'Lobular', 13662, 'Lobular carcinoma (invasive or infiltrating)', 4, 'f7ddb0b0-6eab-4359-9726-1dbb7ba70f14');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30420, '', 'Other', 13662, 'Other (invasive or infiltrating)', 5, '6eb59b61-c5e3-4118-b88f-5fd7efb85acb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30421, '', 'dont know', 13662, 'I don''t know/I can''t remember', 6, '7d48dcfd-8716-4be0-85d9-e64547af28d6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30422, '', 'n/a', 13662, 'I''d rather not say', 7, '5b46907f-b5ef-4575-bb76-0393b21e99d9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31152, '', '', 15458, '2', 7, '8def3484-18dc-4441-bab4-059252f10ac5');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31153, '', '', 15458, '3', 8, '89120e6f-ec85-4503-8e75-16fe422a66b9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31154, '', '', 15458, '4', 9, 'debb8e8a-312b-4923-b586-e2223fe95933');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31155, '', '', 15458, '5', 10, 'd7d64386-7325-4a97-95f3-3204153c9117');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31156, '', '', 15459, '1', 11, 'a7bb4715-6b56-4651-93fd-914b33a2266e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31157, '', '', 15459, '2', 12, '88550512-e195-48b2-915c-150c586f62a2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31158, '', '', 15459, '3', 13, 'd64d8472-8b57-4690-b1f2-1d86971c1021');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31159, '', '', 15459, '4', 14, '0b268542-19ea-415a-9363-d07a2e398ddb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31160, '', '', 15459, '5', 15, 'c52b4ef0-b4b6-4aa0-9f57-f85e33420632');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31161, '', '', 15570, '1', 16, 'ac600d95-873f-4317-91a9-025522fd5873');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31162, '', '', 15570, '2', 17, 'f9017ea6-6022-4cf2-80f7-a11ffe6d00bc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30507, '', '1', 15279, 'Yes', 1, 'd9be1691-0801-4a1d-833b-ea261878ea9b');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30508, '', '2', 15279, 'No', 2, '41aa86c8-4ad2-49df-9ee5-077cc7b8b033');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30509, '', '1', 15305, 'Yes', 1, '37d69d49-a64b-4433-b24e-a32e20522259');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30620, '', '2', 15305, 'No', 2, 'a592702b-0e48-40b4-ab3c-9fd6c4f4bd00');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30644, '', '1', 15306, 'Any brand is OK', 1, 'fcd95535-a8ea-439f-aa8b-e8caa5af7a66');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30645, '', '2', 15306, 'Breyers', 2, '8d12883d-ebd1-44b8-8357-53268057e77c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30646, '', '3', 15306, 'Bart''s Homemade', 3, '90236d1a-f5fa-4751-a733-ee16ccd19376');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30647, '', '4', 15306, 'Cadbury', 4, 'b6e1b1d4-e24f-4466-bd55-0f9b1903c20e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30648, '', '5', 15306, 'Deans', 5, '25017995-710a-411e-912d-1b2190983c47');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30649, '', '6', 15306, 'Hershey''s', 6, '90d8f847-f051-41fb-91f7-36ef54cbe808');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30650, '', '7', 15306, 'Blue Bunny', 7, '9519645c-8732-4518-b41e-db74bd8d4231');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30651, '', '8', 15306, 'Ben & Jerry''s', 8, 'a47087c5-adb2-477d-80bf-b1d24053e4a4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30652, '', '9', 15306, 'Dreyer''s Grand', 9, 'da9b88da-c60e-470e-b5be-21db4d212bab');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30653, '', '10', 15306, 'Haagen Dazs', 10, '1909ff16-79f6-418f-8455-4afb9f36adad');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30654, '', '11', 15306, 'Walgreens', 11, 'd3d24be9-47ca-428d-ab53-aec794b779d4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30655, '', '12', 15306, 'Store brand', 12, 'ddd813a3-a8c6-4aa2-9dba-b6b5cf478d0d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30656, '', '000', 15306, 'Other brands', 13, 'c1c8de74-c0a1-4969-b3b2-d6a6f6515748');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30657, '', '', 15307, 'Please specify other:-', 1, 'cdbe8e0d-626f-4762-b0f9-33e2276a9867');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30658, '', '', 15308, 'Local Ice-cream flavor:-', 1, 'f9dcffdb-a25a-417e-b79d-0147dde2f517');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30815, '', '', 15403, 'enter here', 1, '700a44a1-d4bf-42f4-94e9-5a79b0fab9a0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30816, '', '1', 12191, 'Spine', 1, '5f7f1f0b-5089-4fc7-aa92-b89a3b8f4bf4');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30817, '', '2', 12191, 'Other Bones', 2, 'c4b101d4-53c1-4fb1-b275-79e83c2d6741');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30818, '', '3', 12191, 'Liver', 3, '1772af4e-6513-4849-bbe8-8aec9834e2a6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30819, '', '4', 12191, 'Lymph Nodes', 4, 'd6760621-c4c9-4d38-89d5-b0e5b778e839');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30860, '', '5', 12191, 'Lung', 5, 'e3c18449-c5f2-4605-9372-2dd3c7bd89a2');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30861, '', '6', 12191, 'Brain', 6, 'aa45044b-1895-4270-b04e-a23ad8c8da62');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30862, '', '2', 12171, 'Yes', 1, '6776a178-572e-48a3-9e0e-a44717640c6f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30863, '', '1', 12171, 'No', 2, 'c046cec0-21e7-47e8-a348-3f05b267b521');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30864, '', '3', 12171, 'Don''t Know', 3, '39bd9fdc-8aca-49ae-9016-a6c5af6e0cdc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30865, '', '2', 12172, 'Yes', 4, '7f1c06db-0b3c-48b5-a1ec-43652c14dbc6');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30866, '', '1', 12172, 'No', 5, 'd50baf4e-453c-4180-8b8d-c36ee170b300');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30867, '', '3', 12172, 'Don''t Know', 6, 'f02b5165-b80a-4327-8e86-61453568820e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30868, '', '2', 12173, 'Yes', 7, '1aae804b-48f5-4580-9428-38fb9a288a34');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30869, '', '1', 12173, 'No', 8, 'ef280f0b-003c-4e6a-bd00-c785d3a8201f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30880, '', '3', 12173, 'Don''t Know', 9, '24fe6318-9f8e-4d75-b86b-164a5d24b630');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30881, '', '2', 12174, 'Yes', 10, 'f2af684c-1a2f-4130-8e3e-8dc5b5c03b66');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30882, '', '1', 12174, 'No', 11, 'e6f5fc40-7045-44fa-ba06-7adab409d971');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30883, '', '3', 12174, 'Don''t Know', 12, 'bdb010a0-7d57-4451-a27c-181152f451f9');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30884, '', '1', 15404, 'Test', 1, '59391fe0-bab0-46f0-b5ec-5c93ceed0daa');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30885, '', '3', 15404, 'Testing', 2, '3bac7d1d-b4f4-455f-9715-b073304d0ccb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30886, '', '2', 15404, 'ReTest', 3, '875a04c5-5554-43a0-89dd-8abff9d04236');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (30992, '', '', 15455, 'test', 1, '26ced4c7-a8fd-45a7-8310-23e734758af3');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31136, '', '', 15457, '1', 1, 'e2bde49c-df68-4fc3-9b29-0c63c3ae21cc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31137, '', '', 15457, '2', 2, '723fe032-9d50-4e3e-ac13-9c7ec844f440');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31138, '', '', 15457, '3', 3, 'de98757f-02f5-4f18-bfcc-9cbd5a79536d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31139, '', '', 15457, '4', 4, '586e8cdd-2018-460d-aaea-4081bc3ac84e');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31150, '', '', 15457, '5', 5, 'e522f79d-c8bd-43e3-a919-14c7f6889ceb');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31151, '', '', 15458, '1', 6, 'b7c3c7d0-33f9-4af5-9fa1-95a4c4ceef57');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31166, '', '', 15456, 'test 1', 1, 'f282337d-43c3-4407-8069-4c973ac772bc');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31167, '', '', 15456, 'test 2', 2, '3f9eb63f-24cd-4fef-b856-f2ef925d977f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31168, '', '', 15456, 'test 3', 3, '7c35394b-ff1d-43fe-ac3c-9377cd950eb7');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33186, '', '', 16567, 'MM/DD/YYYY :', 1, '4ccab1ca-26b0-4037-96bc-cc9774e671f0');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (31545, '', '', 7346, 'Please specify "Other"', 1, 'c2cce747-f7cd-4450-8a68-d7601e89faa1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33187, '', '', 58300, 'MM/DD/YYYY :', 1, 'fd31a075-18d5-402f-8f7d-d745895d6611');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33188, '', '1', 16568, 'Yes', 1, '2d1815da-76fc-4e78-91b0-510ecf313456');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33189, '', '2', 16568, 'No', 2, 'fcc1a76f-fb85-4fbd-a9db-9376018192ed');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33240, '', '1', 16569, 'No Treatment', 1, '8498abba-17a7-4bd0-8875-b9d1ab4d2c56');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33241, '', '2', 16569, 'Asprin', 2, 'fecf88a1-12ad-4b0a-b6c7-a8562936ed2f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33242, '', '3', 16569, 'Other medicines, tablets, or pills (including sublingual spray)', 3, '676f66c6-dac0-4596-90c8-cea815986787');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33243, '', '4', 16569, 'Diet', 4, '1a50ee1b-db44-4ed4-ba4f-a74880951829');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33244, '', '5', 16569, 'Exercise', 5, 'aa74c0d4-791b-49cb-8086-e45a7559756f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33245, '', '6', 16569, 'Other', 6, '0a85fc4a-f266-4f5d-940e-372789f7df3a');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33246, '', '0', 16640, 'None', 1, '502dd64e-f451-4eb6-b07f-ba8f0685e91d');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33247, '', '1', 16640, '1 time last week', 2, 'b15cd3bf-1f49-405e-b1d8-68f31173d296');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33248, '', '2', 16640, '2 or 3 times last week', 3, 'c2a7e02e-c67d-40d7-8949-d15097cdef02');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33249, '', '3', 16640, '4 or 5 times last week', 4, '808e43bb-5f87-4bd2-b632-b77518ff8f8f');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33290, '', '4', 16640, '6 or 7 times last week', 5, 'ffb3177f-1b82-427b-ae9a-1b42ce9e07f1');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33291, '', '2', 16641, 'No', 1, '2dbd73ef-c425-4476-8200-b3594b1ea691');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33292, '', '1', 16641, 'Yes', 2, 'a020b0a2-3f2c-4033-94a8-f46e45c81842');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33293, '', '', 16641, 'may be', 3, '31d35514-d7c6-4051-871d-ab779e65a3ec');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33324, '', '2', 16642, 'I sometimes (1-2 times last week) did physical things in my free time (e.g. played sports, went running, swimming, bike riding, did aerobics). ', 1, '55f31faa-4d26-4fae-9ac8-389f0cf7fd99');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33325, '', '1', 16642, 'All or most of my free time was spent doing things that involve little physical effort.', 2, '78115411-c5fe-49d2-8c31-8e85efafd56c');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33326, '', '3', 16642, 'I often (3-4 times last week) did physical things in my free time. ', 3, '69de0c9f-9b61-4c69-b62f-b31727a523ca');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33327, '', '4', 16642, 'I quite often (4-5 times last week) did physical things in my free time. ', 4, '7eaa2758-cd6b-4b79-8091-4c322579ee11');
INSERT INTO answer_value (id, short_name, value, answer_id, description, ord, permanent_id) VALUES (33328, '', '5', 16642, 'I very often (7 or more times last week) did physical things in my free time.', 5, 'f858a6f1-765e-494b-9525-d05409eb5263');


--
-- TOC entry 2045 (class 0 OID 25008)
-- Dependencies: 1714
-- Data for Name: category; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO category (id, name, description) VALUES (55750, 'test category', 'testting it');
INSERT INTO category (id, name, description) VALUES (55751, 'personal info', '');
INSERT INTO category (id, name, description) VALUES (58050, 'About Me', 'Patient Demographic');
INSERT INTO category (id, name, description) VALUES (58051, 'Health Questions', 'My health as of today');
INSERT INTO category (id, name, description) VALUES (58052, 'Activities', '');
INSERT INTO category (id, name, description) VALUES (58054, 'Cancer', '');
INSERT INTO category (id, name, description) VALUES (59250, 'Reproductive Health', '');
INSERT INTO category (id, name, description) VALUES (60000, 'Tobacco Products', '');
INSERT INTO category (id, name, description) VALUES (60001, 'Diet', '');
INSERT INTO category (id, name, description) VALUES (60002, 'Fruits', '');
INSERT INTO category (id, name, description) VALUES (60003, 'Herbal Remedies', '');
INSERT INTO category (id, name, description) VALUES (69450, 'Heart Disease', '');
INSERT INTO category (id, name, description) VALUES (69451, 'CHRONIC DISEASES', '');
INSERT INTO category (id, name, description) VALUES (69452, 'Alternate Contact', '');
INSERT INTO category (id, name, description) VALUES (2940, 'Breast Cancer', 'breast cancer');
INSERT INTO category (id, name, description) VALUES (5028, 'Testing', 'Test Questions');
INSERT INTO category (id, name, description) VALUES (6296, 'Exercise', '');


--
-- TOC entry 2046 (class 0 OID 25011)
-- Dependencies: 1715
-- Data for Name: form; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (58200, NULL, NULL, NULL, NULL, NULL, ' My Breast Cancer', 57254, 6, 'IN_PROGRESS', '2010-09-20 11:56:07.711-04', 1, 'e4e8e495-9197-37ae-b8c8-b564b790ce40', 1, 1);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (58000, NULL, NULL, NULL, NULL, NULL, 'About Me', 57254, 1, 'APPROVED', '2010-09-20 15:41:14.554-04', 1, '0a8f0127-c0d3-3270-ace9-c4ec1927d70b', NULL, NULL);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (3074, NULL, NULL, NULL, NULL, NULL, 'START HERE - Introduction and Checklist', 57254, 3, 'IN_PROGRESS', '2010-09-20 15:41:19.442-04', 1, 'f712000e-9be8-4c21-bf2d-641ad78068ef', 1, 1);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (1465, NULL, NULL, NULL, NULL, NULL, 'Demographics/Health Behavior', 1463, 1, 'IN_PROGRESS', '2010-09-20 14:09:01.055-04', 13, '2904f391-9d61-4684-bf5d-933c23e9c4e6', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (3338, NULL, NULL, NULL, NULL, NULL, 'Social Issues in American Society', 3320, 5, 'IN_PROGRESS', '2010-09-22 16:39:12.84-04', 13, '5535e75f-4bc4-4a70-9b1a-71f6e8a2d36f', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (3333, NULL, NULL, NULL, NULL, NULL, 'Fitness and Exercise Survey', 3320, 4, 'IN_PROGRESS', '2010-09-22 16:20:29.403-04', 13, '432c1775-cbe9-4fd3-95ac-9b63c733e8ab', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (2534, NULL, NULL, NULL, NULL, NULL, 'A Survey About Your Diabetes Care', 2511, 2, 'IN_PROGRESS', '2010-09-21 09:04:20.071-04', 13, '26d93044-c9c6-4243-9c05-aa012e9a806f', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (1774, NULL, NULL, NULL, NULL, NULL, 'For Testing', 1463, 4, 'IN_PROGRESS', '2010-09-21 09:10:04.135-04', 13, '9daa1510-1291-4eec-a28b-cc670acb3950', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (1464, NULL, NULL, NULL, NULL, NULL, 'Breast Cancer Survey', 1463, 3, 'IN_PROGRESS', '2010-09-21 09:10:00.506-04', 13, 'b87d7b9d-95a8-4b05-93fb-6ed759cb64c4', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (3325, NULL, NULL, NULL, NULL, NULL, 'Physical Activity Questionnaire ', 3320, 1, 'IN_PROGRESS', '2010-09-22 16:16:49.291-04', 13, '7443e2ba-87a3-456f-9def-7e3d252b7073', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (2442, NULL, NULL, NULL, NULL, NULL, 'Test', 1463, 2, 'IN_PROGRESS', '2010-09-10 15:50:23.714-04', 14, '287e8b2e-0eb8-402e-9579-77668bdfe126', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (2116, NULL, NULL, NULL, NULL, NULL, 'Test "Import Question" functionality ', 1824, 4, 'IN_PROGRESS', '2010-09-20 15:49:16.378-04', 13, 'e10915f3-2876-46da-b506-9741820415bc', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (3321, NULL, NULL, NULL, NULL, NULL, 'HEART DISEASE', 3320, 3, 'IN_PROGRESS', '2010-09-22 16:13:05.876-04', 13, 'b39c883e-1710-44a2-bb7d-d547f3baf2c7', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (2512, NULL, NULL, NULL, NULL, NULL, 'Test Module ', 2511, 5, 'IN_PROGRESS', '2010-09-23 11:29:06.134-04', 14, '21a889d7-be62-4798-afe3-c6cdfcc1bd92', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (1833, NULL, NULL, NULL, NULL, NULL, 'Testing', 1824, 3, 'IN_PROGRESS', '2010-09-20 12:35:39.711-04', 13, 'c3174f7e-8253-4450-84e7-346df3ac8713', 1, 1);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (57303, NULL, NULL, NULL, NULL, NULL, 'My Reproductive Health', 57254, 2, 'IN_PROGRESS', '2010-09-23 11:29:23.366-04', 1, 'd5fff3c4-dd06-34c1-9bec-0ca8b55d291e', NULL, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (3038, NULL, NULL, NULL, NULL, NULL, 'Ice Cream Survey -2', 1824, 1, 'IN_PROGRESS', '2010-09-15 09:55:14.08-04', 13, 'ec143155-0b62-4eca-8188-80388531363c', NULL, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (1825, NULL, NULL, NULL, NULL, NULL, 'Ice Cream Survey', 1824, 2, 'IN_PROGRESS', '2010-09-22 14:54:27.313-04', 13, '4525cb37-3219-4ec1-903a-e5eb72ceaed8', 13, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (57304, NULL, NULL, NULL, NULL, NULL, 'Health As of Today', 57254, 5, 'IN_PROGRESS', '2010-09-23 11:29:26.047-04', 1, 'ccf6475d-cdbc-3ac0-b7a0-a4f22227d1e9', NULL, 13);
INSERT INTO form (id, sequence, location, system_id, version, type, name, module_id, ord, status, update_date, author_user_id, uuid, locked_by_user_id, last_updated_by_user_id) VALUES (3037, NULL, NULL, NULL, NULL, NULL, 'Physical Activity Questionnaire ', 2511, 4, 'IN_PROGRESS', '2010-09-23 11:30:06.653-04', 13, 'ccf0c806-97dd-4824-93e2-dda5421edb5d', 13, 13);


--
-- TOC entry 2047 (class 0 OID 25014)
-- Dependencies: 1716
-- Data for Name: module; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO module (id, description, release_date, comments, update_date, author_user_id, status) VALUES (1463, 'Breast Cancer Survey', NULL, 'Breast Cancer Online Baseline Evaluation Survey ', '2010-08-02 13:17:20.239-04', 13, 'IN_PROGRESS');
INSERT INTO module (id, description, release_date, comments, update_date, author_user_id, status) VALUES (1824, 'Ice Cream Survey', NULL, 'Ice cream', '2010-08-04 10:05:27.291-04', 13, 'IN_PROGRESS');
INSERT INTO module (id, description, release_date, comments, update_date, author_user_id, status) VALUES (57254, 'The Health of Women Study', NULL, 'HOW', '2010-08-04 12:12:19.302-04', 1, 'IN_PROGRESS');
INSERT INTO module (id, description, release_date, comments, update_date, author_user_id, status) VALUES (3320, 'HEALTH SURVEY MODULE', NULL, 'Module about about chronic diseases or illnesses', '2010-09-22 16:12:20.692-04', 13, 'IN_PROGRESS');
INSERT INTO module (id, description, release_date, comments, update_date, author_user_id, status) VALUES (2511, 'Testing Module', NULL, 'Test Questions', '2010-09-23 11:28:19.406-04', 14, 'IN_PROGRESS');


--
-- TOC entry 2048 (class 0 OID 25018)
-- Dependencies: 1717
-- Data for Name: question; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69224, 'SINGLE_ANSWER', 'Please enter your "Other Pacific Islander".', 58000, 'Other Pacific Islander', 20, '', true, '''enter'':5B,11C,16C ''island'':3A,9B,14C,19C ''pacif'':2A,8B,13C,18C ''pleas'':4B,10C,15C', '66f6e29b-a979-3265-a6e2-509742d0a0d6', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69229, 'SINGLE_ANSWER', ' 	', 58000, 'Title', 28, '', false, '''option'':3C,5C ''titl'':1A,2C,4C', '166fd8b5-f286-3a91-a5ea-9b2e6b024513', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57805, 'SINGLE_ANSWER', '', 58000, 'Last Name', 3, '', false, '''last'':1A,3C,5C ''name'':2A,4C,6C', 'ca8568ec-fe99-3dee-991f-7f9c847a381e', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57806, 'SINGLE_ANSWER', '', 58000, 'First Name', 4, '', false, '''first'':1A,3C,5C ''name'':2A,4C,6C', '3092aa4e-b9c3-31c4-a8cd-d615bec6d636', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60840, 'SINGLE_ANSWER', '', 58000, 'middle initial', 5, '', false, '''initi'':2A,4C,6C ''middl'':1A,3C,5C', '87255d3f-48c3-396a-8c7c-56eb78cd05f3', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60842, 'SINGLE_ANSWER', '', 58000, 'city', 7, '', true, '''citi'':1A,2C,3C', 'd2178173-7756-3ede-bcfe-87d2b156ed17', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60849, 'SINGLE_ANSWER', '', 58000, 'fax', 12, '', false, '''-5321'':12C,23C ''-902'':11C,22C ''978'':10C,21C ''e.g'':9C,20C ''fax'':1A,2C,13C ''number'':3C,14C ''option'':4C,15C ''xxx'':6C,7C,17C,18C ''xxx-xxx-xxxx'':5C,16C ''xxxx'':8C,19C', '9f843914-1522-3b0c-a880-3a62bdc15068', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59866, 'SINGLE_ANSWER', 'During the past 6 months, have you taken any herbal or alternative remedies?', 57304, 'herbal remedy', 22, '', true, '''6'':6B ''altern'':14B ''d'':19C ''herbal'':1A,12B ''month'':7B ''past'':5B ''rather'':20C ''remedi'':2A,15B ''say'':22C ''taken'':10B ''yes'':16C,17C', '6535dc52-d523-393d-9508-8b166287237e', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60848, 'SINGLE_ANSWER', '', 58000, 'state', 8, '', true, '''alabama'':10C ''alaska'':11C ''arizona'':12C ''arkansa'':13C ''california'':14C ''carolina'':47C,57C ''colorado'':15C ''connecticut'':16C ''dakota'':49C,59C ''delawar'':17C ''florida'':18C ''georgia'':19C ''hampshir'':39C ''hawaii'':20C ''idaho'':21C ''illinoi'':22C ''indiana'':23C ''iowa'':24C ''island'':55C ''jersey'':41C ''kansa'':25C ''kentucki'':26C ''louisiana'':27C ''main'':28C ''maryland'':29C ''massachusett'':30C ''mexico'':43C ''michigan'':31C ''minnesota'':32C ''mississippi'':33C ''missouri'':34C ''montana'':35C ''nebraska'':36C ''nevada'':37C ''new'':38C,40C,42C,44C ''north'':46C,48C ''ohio'':50C ''oklahoma'':51C ''oregon'':52C ''pennsylvania'':53C ''rhode'':54C ''select'':2C,3C,6C,7C ''south'':56C,58C ''state'':1A,5C,9C ''tennesse'':60C ''texa'':61C ''utah'':62C ''vermont'':63C ''virginia'':64C,67C ''washington'':65C ''west'':66C ''wisconsin'':68C ''wyom'':69C ''york'':45C', '2409e3fc-6dc2-3259-964e-38d03f643ea3', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58716, 'SINGLE_ANSWER', 'How many nodes were sampled?', 58200, 'Positive Node Sampled', 16, '', false, '''1'':13C ''10'':22C ''11'':23C ''12'':24C ''13'':25C ''14'':26C ''15'':27C ''16'':28C ''17'':29C ''18'':30C ''19'':31C ''2'':14C ''20'':32C,33C ''3'':15C ''4'':16C ''5'':17C ''6'':18C ''7'':19C ''8'':20C ''9'':21C ''know/i'':37C ''mani'':5B ''node'':2A,6B ''one'':10C,12C ''posit'':1A ''rememb'':40C ''report'':42C ''sampl'':3A,8B ''select'':9C,11C', '7681b3db-5cf4-37ed-a8d2-d039fa08338a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69230, 'SINGLE_ANSWER', '', 58000, 'fn', 26, '', false, '''first'':2C,4C ''fn'':1A ''name'':3C,5C', 'cd0822d3-9fd3-3616-8333-83d66f401e66', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69225, 'SINGLE_ANSWER', 'Please specify your "Other Race"?', 58000, 'Other Race', 21, '', false, '''pleas'':3B,8C,12C ''race'':2A,7B,11C,15C ''specifi'':4B,9C,13C', 'c6ddc742-94e3-32bb-9ffa-ff633c20de60', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57812, 'SINGLE_ANSWER', 'What is your occupation today?  ', 58000, 'Occupation', 16, '', false, '''administr'':71C ''architectur'':11C ''art'':14C ''build'':20C ''busi'':26C ''care'':74C ''clean'':23C ''communiti'':30C ''comput'':34C ''construct'':37C ''design'':15C ''donÃ¢'':89C ''educ'':40C ''engin'':13C ''entertain'':16C ''extract'':39C ''farm'':44C ''financi'':28C ''fish'':45C ''food'':48C ''forestri'':47C ''ground'':22C ''healthcar'':53C ''homemak'':55C ''instal'':56C ''legal'':60C ''librari'':43C ''life'':61C ''mainten'':25C,57C ''manag'':66C ''materi'':86C ''mathemat'':36C ''media'':19C ''militari'':67C ''move'':87C ''occup'':1A,5B ''offic'':69C ''one'':8C,10C ''oper'':29C ''person'':73C ''physic'':62C ''prepar'':49C ''product'':77C ''protect'':78C ''relat'':52C,82C ''repair'':59C ''retir'':88C ''sale'':80C ''scienc'':65C ''select'':7C,9C ''serv'':51C ''servic'':33C,76C,79C ''social'':32C,64C ''specif'':68C ''sport'':17C ''student'':83C ''support'':54C,72C ''today'':6B ''train'':41C ''transport'':84C ''work'':91C', '99055104-41d8-36b0-942a-ed9a7e752661', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58726, 'SINGLE_ANSWER', 'Were any of your pregnancies the result of taking fertility drugs?', 57303, 'Preg result of Infertility drugs', 9, '', true, '''d'':28C ''drug'':5A,16B ''fertil'':15B ''infertil'':4A ''know'':22C ''preg'':1A ''pregnanc'':10B ''rather'':29C ''result'':2A,12B ''say'':26C,31C ''take'':14B ''yes'':17C,18C', '5a17b1b4-b6d3-349c-97a3-058f0b7c6e14', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58731, 'SINGLE_ANSWER', 'Please enter the year  you experience your last menstrual period? ', 57303, 'last menstrual', 16, '', false, '''enter'':4B,14C,18C ''experi'':8B ''last'':1A,10B ''menstrual'':2A,11B ''period'':12B ''pleas'':3B,13C,17C ''year'':6B,15C,19C ''yyyi'':16C,20C', '846a77cd-0343-31ac-b341-c11fce3a036f', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3208, 'SINGLE_ANSWER_TABLE', 'This is a table question in search question screen', 1774, '', 17, '', false, NULL, '70ea9e57-a6c4-4a6e-8c1a-fa0308a209a6', '56941260-a380-4de6-b46e-92f752b7fa83', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57807, 'SINGLE_ANSWER', 'Please select your sex?', 58000, 'Sex', 14, '', true, '''femal'':6C,7C ''male'':8C ''pleas'':2B ''select'':3B ''sex'':1A,5B', 'd345c682-731e-3be5-8a0f-d27eee392a1c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57813, 'SINGLE_ANSWER', '', 58000, 'other', 17, '', false, '''occup'':4C,8C ''pleas'':1C,5C ''specifi'':2C,6C', '93d4b8a0-2610-37ba-813c-3c4095236f74', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58743, 'SINGLE_ANSWER', 'Please enter the year did you experience your uterine surgery (hysterectomy)?', 57303, 'year of surgery', 23, '', true, '''enter'':5B,16C,20C ''experi'':10B ''hysterectomi'':14B ''pleas'':4B,15C,19C ''surgeri'':3A,13B ''uterin'':12B ''year'':1A,7B,17C,21C ''yyyi'':18C,22C', '206b4688-2bc3-389e-8cbc-b94821045a2b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3209, 'SINGLE_ANSWER', 'test search question', 1774, '', 18, '', false, NULL, 'e496eb2c-1569-452b-8a16-2d2b0859bcd2', '3ed40a51-9fa2-4222-b1eb-e0ce345db0e9', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59857, 'SINGLE_ANSWER', 'Please select your weight?', 57304, 'weight', 13, '', true, '''100'':26C ''101'':27C ''102'':28C ''103'':29C ''104'':30C ''105'':31C ''106'':32C ''107'':33C ''108'':34C ''109'':35C ''110'':36C ''111'':37C ''112'':38C ''113'':39C ''114'':40C ''115'':41C ''116'':42C ''117'':43C ''118'':44C ''119'':45C ''120'':46C ''121'':47C ''122'':48C ''123'':49C ''124'':50C ''125'':51C ''126'':52C ''127'':53C ''128'':54C ''129'':55C ''130'':56C ''131'':57C ''132'':58C ''133'':59C ''134'':60C ''135'':61C ''136'':62C ''137'':63C ''138'':64C ''139'':65C ''140'':66C ''141'':67C ''142'':68C ''143'':69C ''144'':70C ''145'':71C ''146'':72C ''147'':73C ''148'':74C ''149'':75C ''150'':76C ''151'':77C ''152'':78C ''153'':79C ''154'':80C ''155'':81C ''156'':82C ''157'':83C ''158'':84C ''159'':85C ''160'':86C ''161'':87C ''162'':88C ''163'':89C ''164'':90C ''165'':91C ''166'':92C ''167'':93C ''168'':94C ''169'':95C ''170'':96C ''171'':97C ''172'':98C ''173'':99C ''174'':100C ''175'':101C ''176'':102C ''177'':103C ''178'':104C ''179'':105C ''180'':106C ''181'':107C ''182'':108C ''183'':109C ''184'':110C ''185'':111C ''186'':112C ''187'':113C ''188'':114C ''189'':115C ''190'':116C ''191'':117C ''192'':118C ''193'':119C ''194'':120C ''195'':121C ''196'':122C ''197'':123C ''198'':124C ''199'':125C ''200'':126C ''201'':127C ''202'':128C ''203'':129C ''204'':130C ''205'':131C ''206'':132C ''207'':133C ''208'':134C ''209'':135C ''210'':136C ''211'':137C ''212'':138C ''213'':139C ''214'':140C ''215'':141C ''216'':142C ''217'':143C ''218'':144C ''219'':145C ''220'':146C ''221'':147C ''222'':148C ''223'':149C ''224'':150C ''225'':151C ''226'':152C ''227'':153C ''228'':154C ''229'':155C ''230'':156C ''231'':157C ''232'':158C ''233'':159C ''234'':160C ''235'':161C ''236'':162C ''237'':163C ''238'':164C ''239'':165C ''240'':166C ''241'':167C ''242'':168C ''243'':169C ''244'':170C ''245'':171C ''246'':172C ''247'':173C ''248'':174C ''249'':175C ''250'':176C ''251'':177C ''252'':178C ''253'':179C ''254'':180C ''255'':181C ''256'':182C ''257'':183C ''258'':184C ''259'':185C ''260'':186C ''261'':187C ''262'':188C ''263'':189C ''264'':190C ''265'':191C ''266'':192C ''267'':193C ''268'':194C ''269'':195C ''270'':196C ''271'':197C ''272'':198C ''273'':199C ''274'':200C ''275'':201C ''276'':202C ''277'':203C ''278'':204C ''279'':205C ''280'':206C ''281'':207C ''282'':208C ''283'':209C ''284'':210C ''285'':211C ''286'':212C ''287'':213C ''288'':214C ''289'':215C ''290'':216C ''291'':217C ''292'':218C ''293'':219C ''294'':220C ''295'':221C ''296'':222C ''297'':223C ''298'':224C ''299'':225C ''300'':226C ''301'':227C ''302'':228C ''303'':229C ''304'':230C ''305'':231C ''306'':232C ''307'':233C ''308'':234C ''309'':235C ''310'':236C ''311'':237C ''312'':238C ''313'':239C ''314'':240C ''315'':241C ''316'':242C ''317'':243C ''318'':244C ''319'':245C ''320'':246C ''321'':247C ''322'':248C ''323'':249C ''324'':250C ''325'':251C ''326'':252C ''327'':253C ''328'':254C ''329'':255C ''330'':256C ''331'':257C ''332'':258C ''333'':259C ''334'':260C ''335'':261C ''336'':262C ''337'':263C ''338'':264C ''339'':265C ''340'':266C ''341'':267C ''342'':268C ''343'':269C ''344'':270C ''345'':271C ''346'':272C ''347'':273C ''348'':274C ''349'':275C ''350'':276C ''351'':277C ''352'':278C ''353'':279C ''354'':280C ''355'':281C ''356'':282C ''357'':283C ''358'':284C ''359'':285C ''360'':286C ''361'':287C ''362'':288C ''363'':289C ''364'':290C ''365'':291C ''366'':292C ''367'':293C ''368'':294C ''369'':295C ''370'':296C ''371'':297C ''372'':298C ''373'':299C ''374'':300C ''375'':301C ''376'':302C ''377'':303C ''378'':304C ''379'':305C ''380'':306C ''381'':307C ''382'':308C ''383'':309C ''384'':310C ''385'':311C ''386'':312C ''387'':313C ''388'':314C ''389'':315C ''390'':316C ''391'':317C ''392'':318C ''393'':319C ''394'':320C ''395'':321C ''396'':322C ''397'':323C ''398'':324C ''399'':325C ''400'':326C ''401'':327C ''402'':328C ''403'':329C ''404'':330C ''405'':331C ''406'':332C ''407'':333C ''408'':334C ''409'':335C ''410'':336C ''411'':337C ''412'':338C ''413'':339C ''414'':340C ''415'':341C ''416'':342C ''417'':343C ''418'':344C ''419'':345C ''420'':346C ''421'':347C ''422'':348C ''423'':349C ''424'':350C ''425'':351C ''426'':352C ''427'':353C ''428'':354C ''429'':355C ''430'':356C ''431'':357C ''432'':358C ''433'':359C ''434'':360C ''435'':361C ''436'':362C ''437'':363C ''438'':364C ''439'':365C ''440'':366C ''441'':367C ''442'':368C ''443'':369C ''444'':370C ''445'':371C ''446'':372C ''447'':373C ''448'':374C ''449'':375C ''450'':376C ''451'':377C ''452'':378C ''453'':379C ''454'':380C ''455'':381C ''456'':382C ''457'':383C ''458'':384C ''459'':385C ''460'':386C ''461'':387C ''462'':388C ''463'':389C ''464'':390C ''465'':391C ''466'':392C ''467'':393C ''468'':394C ''469'':395C ''470'':396C ''471'':397C ''472'':398C ''473'':399C ''474'':400C ''475'':401C ''476'':402C ''477'':403C ''478'':404C ''479'':405C ''480'':406C ''481'':407C ''482'':408C ''483'':409C ''484'':410C ''485'':411C ''486'':412C ''487'':413C ''488'':414C ''489'':415C ''490'':416C ''491'':417C ''492'':418C ''493'':419C ''494'':420C ''495'':421C ''496'':422C ''497'':423C ''498'':424C ''499'':425C ''500'':426C,427C ''80'':430C ''81'':7C ''82'':6C,8C ''83'':9C ''84'':10C ''85'':11C ''86'':12C ''87'':13C ''88'':14C ''89'':15C ''90'':16C ''91'':17C ''92'':18C ''93'':19C ''94'':20C ''95'':21C ''96'':22C ''97'':23C ''98'':24C ''99'':25C ''pleas'':2B ''pound'':429C ''select'':3B ''weight'':1A,5B,428C', '5f95f2ea-b2e1-34a8-9e3e-c55dfb585f8f', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59858, 'SINGLE_ANSWER', 'Have you ever used any tobacco products?', 57304, 'Used Tobacco', 14, '', true, '''current'':15C ''d'':17C ''ever'':5B ''previous'':11C,13C ''product'':9B ''rather'':18C ''say'':20C ''tobacco'':2A,8B ''use'':1A,6B ''yes'':10C,12C,14C', '6bf273d8-585b-3b65-ad00-79716b9400ae', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59859, 'SINGLE_ANSWER', 'Do you ever drink beer, wine or liquor?', 57304, 'Loquor', 12, '', true, '''beer'':6B ''d'':13C ''drink'':5B ''ever'':4B ''liquor'':9B ''loquor'':1A ''rather'':14C ''say'':16C ''wine'':7B ''yes'':10C,11C', '312610ac-eb83-37f8-a8bb-31e51ec3315a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3337, 'SINGLE_ANSWER', 'Please selecy your country', 3333, '', 3, '', false, '''canada'':9C ''countri'':4B,5C,6C ''pleas'':1B ''seleci'':2B ''state'':8C ''unit'':7C', '5862ea6b-2369-45a4-a7ba-61e0bd334292', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58250, 'CONTENT', 'Please note we will be asking more detailed questions related to this topic in future modules.', 58200, 'TEXT-CONTENT', 1, NULL, false, '''ask'':9B ''content'':3A ''detail'':11B ''futur'':18B ''modul'':19B ''note'':5B ''pleas'':4B ''question'':12B ''relat'':13B ''text'':2A ''text-cont'':1A ''topic'':16B', 'bb9eacb1-f441-3148-a5cf-a462d6ba1acd', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58741, 'SINGLE_ANSWER', 'Have you ever had a surgery to remove part or all of your uterus?', 57303, 'utreus surgery', 21, '', true, '''d'':72C ''entir'':47C ''ever'':5B ''know/i'':67C ''m'':68C ''never'':52C ''part'':11B,24C,35C,58C ''rather'':73C ''remov'':10B,23C,34C,45C,57C ''say'':75C ''sure'':70C ''surgeri'':2A,8B,21C,32C,43C,55C ''uterus'':16B,27C,38C,48C,63C ''utreus'':1A ''yes'':17C,28C,39C', '8f95b074-6d64-385f-91fe-9782753a3014', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58252, 'CONTENT', 'If you have been diagnosed with breast cancer more than once (recurrence or new diagnosis), please answer the following questions in relation to your FIRST breast cancer diagnosis. Questions related to subsequent diagnoses will come in future modules.', 58200, 'TEXT-CONTENT', 4, NULL, false, '''answer'':20B ''breast'':10B,29B ''cancer'':11B,30B ''come'':38B ''content'':3A ''diagnos'':8B,36B ''diagnosi'':18B,31B ''first'':28B ''follow'':22B ''futur'':40B ''modul'':41B ''new'':17B ''pleas'':19B ''question'':23B,32B ''recurr'':15B ''relat'':25B,33B ''subsequ'':35B ''text'':2A ''text-cont'':1A', 'eaa3de95-b77d-3269-a3c6-60acbc71965a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60841, 'SINGLE_ANSWER', '', 58000, 'Street Address', 6, '', true, '''address'':2A,4C,6C ''street'':1A,3C,5C', '3f02d218-2a82-390f-9570-b6315fea9307', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60845, 'SINGLE_ANSWER', '', 58000, 'email', 11, '', false, '''address'':3C,5C ''email'':1A,2C,4C', '8d0a21d9-dd2a-3f3b-82fe-8f19eaa446ed', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (62250, 'SINGLE_ANSWER', '', 58000, 'dob', 13, '', true, '''07/22/1950'':7C,13C ''birth'':4C,10C ''date'':2C,8C ''dob'':1A ''e.g'':6C,12C ''mm/dd/yyyy'':5C,11C', '9f683d2d-8a48-356b-b865-b208b3528799', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2385, 'SINGLE_ANSWER', 'this question is for test', 1833, 'aaaaa', 4, '', false, NULL, '51d5acb1-3570-4df7-9153-5f15b65cc556', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57365, 'SINGLE_ANSWER', 'How old were you when you had your first menstrual period?', 57303, 'age', 4, '', false, '''10'':27C,28C ''11'':29C ''12'':30C ''13'':31C ''14'':32C ''15'':33C ''16'':34C ''17'':35C ''age'':1A,26C ''d'':48C ''first'':10B ''know/i'':43C ''menstrual'':11B ''never'':15C,21C ''old'':3B,37C ''older'':39C ''period'':12B,18C,24C ''rather'':49C ''rememb'':46C ''say'':51C ''year'':36C', 'a82155f1-4f1a-338d-86ca-c430a678c52e', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2466, 'SINGLE_ANSWER', 'Please enter the year you experience your ovarian surgery (oophorectomy)? (YYYY) ', 1774, 'Ovarian surgery year', 14, '', true, '''enter'':5B,16C,20C ''experi'':9B ''oophorectomi'':13B ''ovarian'':1A,11B ''pleas'':4B,15C,19C ''surgeri'':2A,12B ''year'':3A,7B,17C,21C ''yyyi'':14B,18C,22C', '8c7b7d5d-87f5-493d-a489-8ca6cb29d7f7', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58728, 'SINGLE_ANSWER', 'How old were you the first time you gave birth?', 57303, 'How old first gave birth', 12, '', true, '''10'':20C,21C ''11'':22C ''12'':23C ''13'':24C ''14'':25C ''15'':26C ''16'':27C ''17'':28C ''18'':29C ''19'':30C ''20'':31C ''21'':32C ''22'':33C ''23'':34C ''24'':35C ''25'':36C ''26'':37C ''27'':38C ''28'':39C ''29'':40C ''30'':41C ''31'':42C ''32'':43C ''33'':44C ''34'':45C ''35'':46C ''36'':47C ''37'':48C ''38'':49C ''39'':50C ''40'':51C ''41'':52C ''42'':53C ''43'':54C ''44'':55C ''45'':56C ''46'':57C ''47'':58C ''48'':59C ''49'':60C ''50'':61C ''51'':62C ''52'':63C ''53'':64C ''54'':65C ''55'':66C ''56'':67C ''57'':68C ''58'':69C ''59'':70C ''60'':71C,73C ''birth'':5A,15B ''first'':3A,11B ''gave'':4A,14B ''old'':2A,7B ''one'':17C,19C ''select'':16C,18C ''time'':12B', '48050181-ff72-3592-b545-c0d30ef23530', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58733, 'SINGLE_ANSWER', 'Why did your periods stop?', 57303, 'why Periods stop', 17, '', true, '''although'':64C ''anoth'':97C ''chemotherapi'':83C ''due'':95C ''hysterectomi'':29C,51C ''intact'':38C ''know'':87C ''least'':32C ''medic'':81C ''natur'':12C,16C ''one'':35C ''ovari'':36C,56C,74C ''part'':33C ''period'':2A,7B,10C,14C,18C,40C,61C,77C,90C,93C ''reason'':98C ''remov'':26C,48C,59C,75C ''stop'':3A,8B,11C,15C,19C,41C,62C,78C,91C,94C ''surgeri'':24C,46C ''uterus'':28C,50C,68C', '8dd91587-7dd5-35e3-bed8-06620f008637', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58251, 'SINGLE_ANSWER', 'When were you first diagnosed with breast cancer?', 58200, 'Date', 3, '', true, '''breast'':8B ''cancer'':9B ''date'':1A ''diagnos'':6B ''first'':5B ''mm/dd/yyyy'':10C,11C', 'fe8185f4-7f2d-3b59-8472-863807b1662d', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58746, 'SINGLE_ANSWER', 'Please enter the year you experience your ovarian surgery (oophorectomy)? (YYYY) ', 57303, 'year', 26, '', true, '''enter'':3B,14C,18C ''experi'':7B ''oophorectomi'':11B ''ovarian'':9B ''pleas'':2B,13C,17C ''surgeri'':10B ''year'':1A,5B,15C,19C ''yyyi'':12B,16C,20C', '0d9f3187-2d3f-3c5a-8f14-5e5c74737b9f', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2451, 'SINGLE_ANSWER', 'Have you ever taken menopausal hormone therapy?', 1774, '', 8, '<b>Question : Have you ever taken menopausal hormone therapy?</b>
<br/>
<br/> 
<b>What does this mean : </b>Menopausal hormone therapy is often referred to as hormonal replacement therapy <i>(HRT)</i>. Bioidentical hormones are a form of menopausal hormone therapy. Hormone therapy is used to treat menopausal symptoms, like hot flashes. Menopausal hormone therapy can come in a pill or patch or gel/cream form. Some women take estrogen and a progestogen. Some take estrogen and testosterone, and some take only estrogen. 
<br/>
<br/>
Menopausal hormone therapy can come in a pill or patch or gel/cream form. Some women take estrogen and a progestogen. Some take estrogen and testosterone, and some take only estrogen. 
<br/>
<br/>

 
 
 
', true, NULL, 'a3697edd-172a-49d1-b60b-d55dcc597877', 'e6992fe1-e80a-33ba-bae0-316ab1d36814', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3121, 'SINGLE_ANSWER', 'I have difficulty swallowing solid foods', 57304, 'Patient Solid Food Assessment Scale', 35, 'the assessment scale of a patient''s ability to eat solid food.', false, '''1'':24C,25C ''2'':26C ''3'':27C ''4'':28C ''abil'':19C ''assess'':4A,13C ''bit'':35C,41C,48C,52C ''bother'':29C,32C,37C,38C,45C ''difficulti'':8B ''eat'':21C ''extrem'':58C ''food'':3A,11B,23C ''littl'':40C,47C,56C ''lot'':63C ''moder'':57C ''much'':31C,54C ''patient'':1A,17C ''quit'':33C,50C ''relev'':61C ''scale'':5A,14C ''solid'':2A,10B,22C ''somewhat'':36C,49C ''swallow'':9B ''yes'':59C,64C,65C', 'EB4CBF86-107B-5BD3-E034-0003BA3F9857', NULL, NULL, 2194237);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3076, 'MULTI_ANSWER', 'If possible, gather the following information before you start this questionnaire:', 3074, '', 2, '', false, '''biopsi'':16C ''follow'':5B ''gather'':3B ''histori'':13C,15C,19C ''inform'':6B ''possibl'':2B ''questionnair'':11B ''reproduct'':18C ''result'':17C ''start'':9B ''treatment'':12C,14C', '5270e55b-14ce-4e4f-bc6f-a80c1091a4ac', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3339, 'CONTENT', 'Demographic Questionnaire
<br/>
<br/>', 3338, 'TEXT-CONTENT', 1, NULL, false, '''content'':3A ''demograph'':4B ''questionnair'':5B ''text'':2A ''text-cont'':1A', 'bd056c4b-0072-4dd5-821e-b6f9a7b1be15', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58268, 'SINGLE_ANSWER', 'Have you ever diagnosed with breast cancer?', 58200, 'Breast Cancer', 2, '', false, '''breast'':1A,8B ''cancer'':2A,9B ''diagnos'':6B ''ever'':5B ''yes'':10C,11C', 'e5d8d814-a079-3c25-bc20-2a6d851c6c27', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58712, 'SINGLE_ANSWER', 'If you were tested for HER2/neu, what method was used to test for it?', 58200, 'HER2 Test Method', 13, '<b>Question : If you were positive for the HER2/neu, what method was used to test for it?</b> 
<br/>
<br/>
<b>What does this mean :</b> FISH (Fluorescent In Situ Hybridization) is a laboratory test that uses DNA tagged with a fluorescent dye to detect the HER2/neu cancer gene in tissue samples under a microscope.
<br/>
<br/>

Immunohistochemistry (IHC) is a laboratory test that uses antibodies against the HER2/neu protein to identify cells that are producing the HER2/neu protein in excessive amounts. It is an indirect way of evaluating whether tumor cells have multiple copies of the HER2/neu gene since the gene directs the production of the protein. If this test is not clear, FISH is recommended.
<br/>
<br/>

If you were tested by FISH and Immunohistochemistry, FISH should be your selected option.
<br/>
<br/>
 
<b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other healthcare professional.
<br/>
<br/>
 
 
 
', true, '''although'':145C ''amount'':89C ''antibodi'':73C ''appli'':192C ''ask'':173C ''cancer'':57C ''cell'':80C,99C ''clear'':121C ''complet'':159C ''copi'':102C ''d'':194C ''detect'':54C ''direct'':110C ''dna'':47C ''dye'':52C ''evalu'':96C ''excess'':88C ''find'':142C ''fish'':36C,122C,130C,133C,180C,181C ''fluoresc'':37C,51C ''found'':166C ''gene'':58C,106C,109C ''healthcar'':178C ''her2'':1A ''her2/neu'':9B,23C,56C,76C,85C,105C ''hybrid'':40C ''identifi'':79C ''ihc'':66C ''immunohistochemistri'':65C,132C,182C ''indirect'':93C ''inform'':144C,154C,163C ''know/i'':186C ''laboratori'':43C,69C ''mean'':35C ''method'':3A,11B,25C ''microscop'':64C ''multipl'':101C ''obtain'':152C ''oncologist'':175C ''option'':138C ''patholog'':169C ''posit'':20C ''produc'':83C ''product'':112C ''profession'':179C ''protein'':77C,86C,115C ''purpos'':157C ''question'':16C ''rather'':195C ''recommend'':124C ''rememb'':189C ''report'':170C ''requir'':149C ''sampl'':61C ''say'':197C ''select'':137C ''sinc'':107C ''situ'':39C ''survey'':161C ''tag'':48C ''test'':2A,7B,15B,29C,44C,70C,118C,128C ''tissu'':60C ''tumor'':98C ''use'':13B,27C,46C,72C ''way'':94C ''whether'':97C', 'e5711eb7-93a9-32ce-a600-aa49ea0497bc', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58732, 'SINGLE_ANSWER', 'Do you want to tell in what year did you experience your last menstrual period?', 57303, 'Year', 15, '', true, '''d'':27C ''experi'':12B ''know/i'':22C ''last'':14B ''m'':23C ''menstrual'':15B ''period'':16B ''rather'':28C ''say'':30C ''sure'':25C ''tell'':6B ''want'':4B ''year'':1A,9B ''yes'':17C,18C', 'a77bfb83-7e24-399a-bddc-bdd32fe3997a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58742, 'SINGLE_ANSWER', 'Do you know the year you experience your uterine surgery (hysterectomy)?', 57303, 'year', 22, '', false, '''d'':23C ''experi'':8B ''hysterectomi'':12B ''know'':4B ''know/i'':18C ''m'':19C ''rather'':24C ''say'':26C ''sure'':21C ''surgeri'':11B ''uterin'':10B ''year'':1A,6B ''yes'':13C,14C', '1335ea9a-033f-35db-90b4-9aa47a4d0db4', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59856, 'SINGLE_ANSWER', 'Select your height in feet ?', 57304, 'Height', 10, '', true, '''3'':11C ''4'':12C ''5'':13C ''6'':14C ''7'':15C ''feet'':6B,8C,10C ''height'':1A,4B,7C,9C ''report'':17C ''select'':2B', '25e2f930-8229-3c0c-a750-90a5c9510bc3', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69231, 'SINGLE_ANSWER', 'Please enter your alternate contact person "Last Name"?', 58000, 'LN', 25, '', false, '''altern'':5B ''contact'':6B ''enter'':3B ''last'':8B,10C,12C ''ln'':1A ''name'':9B,11C,13C ''person'':7B ''pleas'':2B', '21c3ab62-90ab-32ee-b9f9-24de26da9483', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69237, 'SINGLE_ANSWER', '', 58000, 'sa', 30, '', false, '''address'':3C,5C ''sa'':1A ''street'':2C,4C', '23f13a9c-146c-3378-8235-665b84c5e33b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69234, 'SINGLE_ANSWER', '', 58000, 'fax no', 35, '', false, '''fax'':1A,2C,4C ''option'':3C,5C', '5cb1f39a-fad5-3e3d-a416-330eeb22fbf6', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2401, 'SINGLE_ANSWER', ' I enjoy eating ice cream so much that I eat it:', 1833, 'Enjoy ice cream', 5, '', false, NULL, '69f2b3a1-b592-4651-b762-2c7ca351ced0', 'bf5decce-0553-4f9e-a90a-32b6c86a8e3d', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57804, 'CONTENT', 'We are inviting you to be part of the HOW Study because you have signed up to be part of the Love/Avon Army of Women and are eager to help us understand the cause of breast cancer and how to prevent it. ', 58000, 'TEXT-CONTENT', 1, NULL, false, '''armi'':26B ''breast'':39B ''cancer'':40B ''caus'':37B ''content'':3A ''eager'':31B ''help'':33B ''invit'':6B ''love/avon'':25B ''part'':10B,22B ''prevent'':44B ''sign'':18B ''studi'':14B ''text'':2A ''text-cont'':1A ''understand'':35B ''us'':34B ''women'':28B', '7053fd92-68b7-3367-8d9e-ca39ef1906df', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59867, 'SINGLE_ANSWER_TABLE', 'Have you taken any of the following herbal or alternative remedies?', 57304, 'diff herbal remedi', 23, '', false, '''agnus'':65C ''altern'':13B ''angelica'':25C ''bc'':56 ''bco'':60 ''bee'':50C ''berri'':63C ''biloba'':44C ''black'':54C ''blue'':58C ''bp'':52 ''cactii'':66C ''cartilag'':133C ''cb'':67 ''chast'':62C ''chickwe'':15C ''chines'':24C ''cohosh'':55C,59C ''cream'':94C ''ct'':17 ''diff'':1A ''dong'':19C ''dq'':26 ''ech'':29 ''echinacea'':28C ''epo'':34 ''even'':31C ''fals'':36C ''follow'':10B ''fu'':38 ''garlic'':40C ''gb'':45 ''gin'':48 ''gingko'':43C ''ginseng'':47C ''gr'':41 ''herbal'':2A,11B,69C ''ht'':75 ''jelli'':104C ''john'':118C ''jw'':122 ''kwai'':22C ''lachesi'':77C ''las'':78 ''licoric'':80C ''lr'':82 ''mexican'':96C ''mother'':84C ''mw'':86 ''nux'':88C ''nv'':90 ''oil'':33C ''oth'':136 ''pollen'':51C ''primros'':32C ''progesteron'':92C ''ptc'':98 ''pul'':101 ''pulsatilla'':100C ''quai'':20C ''remedi'':3A,14B,74C ''rj'':105 ''root'':81C,129C ''royal'':103C ''sage'':107C ''sar'':112 ''sarsaparilla'':111C ''sc'':134 ''sep'':115 ''sepia'':114C ''shark'':132C ''st'':109,117C,121 ''taken'':6B ''tea'':70C,108C ''tinctur'':16C ''tong'':21C ''topic'':93C ''unicorn'':37C ''use'':71C ''val'':125 ''valeriana'':124C ''vitex'':64C ''vomica'':89C ''wild'':95C,127C ''wort'':85C,120C ''wyr'':130 ''yam'':97C,128C ''yes'':18C,27C,30C,35C,39C,42C,46C,49C,53C,57C,61C,68C,76C,79C,83C,87C,91C,99C,102C,106C,110C,113C,116C,123C,126C,131C,135C,137C', '5223aee5-a696-3db9-a897-bc79f44c922c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59861, 'MULTI_ANSWER', 'Indicate the types of foods that are included in your diet (check all that apply)', 57304, 'food', 16, '', true, '''appli'':16B ''check'':13B ''chees'':26C ''d'':34C ''dairi'':29C ''diet'':12B ''egg'':24C ''fish/shellfish'':22C ''food'':1A,6B ''fruit'':32C ''includ'':9B ''indic'':2B ''meat'':18C,20C ''milk'':25C ''pork'':23C ''poultri'':21C ''product'':30C ''rather'':35C ''red'':17C,19C ''say'':37C ''type'':4B ''veget'':31C', '1944726a-5e52-3e1c-8260-410158788a30', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69226, 'SINGLE_ANSWER', 'Are you Spanish/Hispanic/Latino?', 58000, 'Spanish/Hispanic/Latino', 22, '', true, '''american'':18C ''chicano'':19C ''cuban'':24C ''hispan'':8C,13C,28C ''latino'':9C,14C,29C ''mexican'':16C,17C ''puerto'':21C ''rican'':22C ''spanish'':7C,12C,27C ''spanish/hispanic/latino'':1A,4B ''yes'':15C,20C,23C,25C', 'a03e756d-1a15-3b35-b672-e2a71e7edf5a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58727, 'SINGLE_ANSWER', 'How many full-term pregnancies have you had? ', 57303, 'no of preg.', 11, '', true, '''1'':10C,11C ''2'':12C ''3'':13C ''4'':14C ''d'':23C ''full'':7B ''full-term'':6B ''know/i'':18C ''mani'':5B ''preg'':3A ''pregnanc'':9B ''rather'':24C ''rememb'':21C ''say'':26C ''term'':8B', '9ab1cba1-3657-3a53-9742-581a155edb1f', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58723, 'SINGLE_ANSWER', 'Have you ever taken fertility drugs?', 57303, 'Fertility Drugs', 7, '', true, '''d'':19C ''drug'':2A,8B ''ever'':5B ''fertil'':1A,7B ''know/i'':14C ''rather'':20C ''rememb'':17C ''say'':22C ''taken'':6B ''yes'':9C,10C', '5a013066-5b10-3a25-acc9-6c8747612c38', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69245, 'SINGLE_ANSWER', 'Height in Inch:', 57304, 'inch', 11, '', true, '''1'':11C ''10'':20C ''11'':21C ''2'':12C ''3'':13C ''4'':14C ''5'':15C ''6'':16C ''7'':17C ''8'':18C ''9'':19C ''height'':2B,6C,9C ''height-inch'':5C,8C ''inch'':1A,4B,7C,10C ''report'':23C', '9caa7210-ca17-3d35-8271-2fe196785bfc', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60839, 'CONTENT', ' <b>Complete your information:-</b>
 
<br/>
<br/>
   * Answer all questions as best you can but do not guess.<br/>
<br/>
    * Select "I don''t know" as little as possible.
<br/>
<br/>
    * If you need HELP, use HOW support. <i>LEARN MORE</i>
<br/>
<br/>

<i>Please enter your  information below.As you create and modify your information, your Personal Home Page will be updated with the new information.</i>
<br/> ', 58000, 'TEXT-CONTENT', 2, NULL, false, '''answer'':7B ''below.as'':40B ''best'':11B ''complet'':4B ''content'':3A ''creat'':42B ''enter'':37B ''guess'':17B ''help'':30B ''home'':49B ''inform'':6B,39B,46B,57B ''know'':22B ''learn'':34B ''littl'':24B ''modifi'':44B ''need'':29B ''new'':56B ''page'':50B ''person'':48B ''pleas'':36B ''possibl'':26B ''question'':9B ''select'':18B ''support'':33B ''text'':2A ''text-cont'':1A ''updat'':53B ''use'':31B', 'f7906e9f-03d9-30c1-b452-8fbb69e0a0c9', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60846, 'SINGLE_ANSWER', '', 58000, 'zip', 9, '', true, '''zip'':1A,2C,3C', 'ba16f0b4-9cb8-3f11-a37d-cbd9baf7a441', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2221, 'SINGLE_ANSWER', ' I enjoy eating ice cream so much that I eat it:', 2116, 'Enjoy ice cream', 8, '', false, NULL, 'c96bc3ab-993f-4baa-9e83-8573bafcdf8d', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69238, 'SINGLE_ANSWER', '', 58000, 'city', 31, '', false, '''citi'':1A,2C,3C', '914cb06f-1b51-37fe-9422-01416b67ee44', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58269, 'SINGLE_ANSWER', 'What was your tumor size, as determined by surgery?', 58200, 'Tumor Size', 7, '', true, '''-5.0'':21C ''2.0'':14C,18C,20C ''5.0'':24C ''centimet'':15C,19C,22C,25C ''d'':40C ''determin'':9B ''haven'':27C ''know/i'':35C ''less'':12C,16C ''rather'':41C ''rememb'':38C ''say'':43C ''size'':2A,7B ''surgeri'':11B,30C ''tumor'':1A,6B ''yet'':31C', '6fbe30c6-1393-36eb-a899-ca6c9177fd7f', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69232, 'SINGLE_ANSWER', '', 58000, 'mi', 27, '', false, '''initi'':3C,5C ''mi'':1A ''middl'':2C,4C', '67fce240-62c3-3b28-aece-bbae2f4e0b56', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58724, 'SINGLE_ANSWER', 'Have you ever been pregnant?', 57303, 'Pregnant', 8, '', true, '''d'':17C ''ever'':4B ''know/i'':12C ''pregnant'':1A,6B ''rather'':18C ''rememb'':15C ''say'':20C ''yes'':7C,8C', 'a4a7e0f1-6c06-3074-931c-f477acfd29fe', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58729, 'SINGLE_ANSWER', 'Are you currently pregnant or nursing?', 57303, 'preg or nursing', 13, '', true, '''current'':6B ''d'':17C ''know'':15C ''nurs'':3A,9B ''preg'':1A ''pregnant'':7B ''rather'':18C ''say'':20C ''yes'':10C,11C', '31c05993-a6d1-3b27-9583-27877781d5cc', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58734, 'SINGLE_ANSWER', 'Please specify the reason your periods stop?', 57303, 'reason', 18, '', true, '''period'':7B ''pleas'':2B,9C,12C ''reason'':1A,5B,11C,14C ''specifi'':3B ''speciti'':10C,13C ''stop'':8B', '259226c0-7754-3c07-a3d2-69a4815a4b79', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58744, 'SINGLE_ANSWER', 'Have you ever had a surgery to remove part of an ovary or both ovaries?', 57303, 'ovarien surgery', 24, '', true, '''d'':84C ''ever'':5B ''know/i'':79C ''never'':65C ''one'':47C ''ovari'':14B,17B,28C,39C,48C,52C,61C,75C ''ovarien'':1A ''part'':11B,25C,36C,72C ''rather'':85C ''rememb'':82C ''remov'':10B,24C,35C,46C,59C,70C ''say'':87C ''surgeri'':2A,8B,22C,33C,44C,57C,68C ''yes'':18C,29C,40C,53C', 'e7a0c2c6-3d51-38d6-82e4-93faa783c132', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58714, 'SINGLE_ANSWER', 'How many nodes were positive?   ', 58200, 'Positive Node Sample', 15, '', true, '''1'':13C ''10'':22C ''11'':23C ''12'':24C ''13'':25C ''14'':26C ''15'':27C ''16'':28C ''17'':29C ''18'':30C ''19'':31C ''2'':14C ''20'':32C,33C ''3'':15C ''4'':16C ''5'':17C ''6'':18C ''7'':19C ''8'':20C ''9'':21C ''know/i'':37C ''mani'':5B ''node'':2A,6B ''one'':10C,12C ''posit'':1A,8B ''rememb'':40C ''report'':42C ''sampl'':3A ''select'':9C,11C', 'a9e102cd-8c62-374a-92f7-27a81b5d4094', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69227, 'SINGLE_ANSWER', 'Please specify your "Other Spanish, Hispanic, Latino" ethnicity?', 58000, 'other spanish', 23, '', true, '''ethnic'':10B ''hispan'':8B,14C,19C ''latino'':9B,15C,20C ''pleas'':3B ''spanish'':2A,7B,13C,18C ''specifi'':4B,11C,16C', 'd552ea5a-13ab-3490-a574-2a5d5ae95ebb', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69235, 'SINGLE_ANSWER', '', 58000, 'Institution name', 29, '', false, '''institut'':1A,3C,6C ''name'':2A,4C,7C ''option'':5C,8C', 'ffb4c0c0-1ab3-337e-9829-849651ceae28', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59869, 'SINGLE_ANSWER', 'Have you ever had breast cancer?', 57304, 'breast canser', 24, '', true, '''breast'':1A,7B ''cancer'':8B ''canser'':2A ''d'':12C ''ever'':5B ''rather'':13C ''say'':15C ''yes'':9C,10C', '31a8b4c1-14df-32e4-99a5-57999dacd73d', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2404, 'SINGLE_ANSWER_TABLE', ' My favorite ice cream flavor is:', 1833, 'Ice Cream Flavor', 6, '', true, NULL, '1b33ffd1-f372-4990-9d88-21b6932feb89', 'e7516610-6655-4d1d-820c-0308f8d2e97c', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59864, 'SINGLE_ANSWER', 'Please indicate how you primarily self-identify with respect to sexual orientation?', 57304, 'sexual orientation', 20, '', true, '''bisexu'':18C ''d'':21C ''heterosexu'':16C,17C ''homosexu'':19C ''identifi'':10B ''indic'':4B ''orient'':2A,15B ''pleas'':3B ''primarili'':7B ''rather'':22C ''respect'':12B ''say'':24C ''self'':9B ''self-identifi'':8B ''sexual'':1A,14B', '28465717-fed5-3f64-beaf-6d892ae09ecb', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (60847, 'SINGLE_ANSWER', '', 58000, 'phone', 10, '', true, '''-5321'':11C,21C ''-902'':10C,20C ''978'':9C,19C ''e.g'':8C,18C ''number'':3C,13C ''phone'':1A,2C,12C ''xxx'':5C,6C,15C,16C ''xxx-xxx-xxxx'':4C,14C ''xxxx'':7C,17C', '1683af7f-b687-33ea-b847-0293d356292c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57815, 'SINGLE_ANSWER', 'Please enter your "Other  Asian"ethnicity?', 58000, 'Other', 19, '', false, '''asian'':5B,8C,10C ''enter'':2B ''ethnic'':6B ''pleas'':1B', '73010d7e-e6d6-31aa-8879-7f85870b0574', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58725, 'SINGLE_ANSWER', 'Have you ever had a full-term pregnancy?', 57303, 'Pregnancy', 10, '<b>Question : Have you ever had a full-term pregnancy? </b>
<br/>
<br/>
<b>What does this mean :</b> Full term pregnancy may have ended in a live birth or a still birth. 
<br/>
<br/>
 
', true, '''birth'':34C,38C ''d'':42C ''end'':30C ''ever'':4B,14C ''full'':8B,18C,25C ''full-term'':7B,17C ''know'':49C ''live'':33C ''may'':28C ''mean'':24C ''pregnanc'':1A,10B,20C,27C ''question'':11C ''rather'':43C ''say'':45C,53C ''still'':37C ''term'':9B,19C,26C ''yes'':39C,40C', '9d384252-4bf0-3bed-a062-7b2a682f78ef', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58730, 'SINGLE_ANSWER', 'Do you currently have menstrual periods? ', 57303, 'manupausal status', 14, '', true, '''current'':5B,35C ''d'':64C ''irregular'':43C ''know/i'':59C ''longer'':50C ''m'':60C ''manupaus'':1A ''menopaus'':55C ''menstrual'':7B,12C,20C,30C,40C,53C ''nurs'':38C ''period'':8B,13C,21C,31C,41C,54C ''pregnant'':36C ''premenopaus'':16C,24C ''rather'':65C ''regular'':11C,19C,29C,52C ''say'':67C ''status'':2A ''stop'':47C ''sure'':62C', '3303a992-81c7-34c2-8135-6ec49f1cfed4', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1474, 'SINGLE_ANSWER', 'Have you ever brought up the topic of breast cancer clinical trials with a health care professional?', 1465, 'topic brought up', 5, '', true, '''breast'':11B ''brought'':2A,6B ''cancer'':12B ''care'':18B ''clinic'':13B ''ever'':5B ''health'':17B ''know'':22C,25C ''profession'':19B ''topic'':1A,9B ''trial'':14B ''yes'':26C', '510c1062-a5aa-49f4-9186-f900f52c0118', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1536, 'SINGLE_ANSWER', '', 1465, 'state', 17, '', true, NULL, '8665f7c9-4598-4689-9703-0cc7e8856833', '2409e3fc-6dc2-3259-964e-38d03f643ea3', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3344, 'SINGLE_ANSWER', 'Diabetes (without complications)', 2534, 'Diabetes Mellitus History Ind-3', 7, 'the yes/no indicator whether or not the patient has a history of diabetes mellitus.', false, NULL, 'D8F91E61-DD7D-474D-E034-0003BA12F5E7', '2183380', 'CA_DSR', 2183380);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2768, 'SINGLE_ANSWER', '', 2534, '', 3, '', false, '''1'':4C ''2'':1C,2C ''3'':3C', '3f40acff-a182-4460-a8c0-3b38117ce100', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58735, 'SINGLE_ANSWER', 'Have you ever taken menopausal hormone therapy?', 57303, '', 19, '<b>Question : Have you ever taken menopausal hormone therapy?</b>
<br/>
<br/> 
<b>What does this mean : </b>Menopausal hormone therapy is often referred to as hormonal replacement therapy <i>(HRT)</i>. Bioidentical hormones are a form of menopausal hormone therapy. Hormone therapy is used to treat menopausal symptoms, like hot flashes. Menopausal hormone therapy can come in a pill or patch or gel/cream form. Some women take estrogen and a progestogen. Some take estrogen and testosterone, and some take only estrogen. 
<br/>
<br/>
Menopausal hormone therapy can come in a pill or patch or gel/cream form. Some women take estrogen and a progestogen. Some take estrogen and testosterone, and some take only estrogen. 
<br/>
<br/>

 
 
 
', true, '''bioident'':32C ''come'':56C,86C ''current'':141C ''estrogen'':68C,74C,81C,98C,104C,111C ''ever'':3B,11C ''flash'':51C ''form'':36C,64C,94C ''gel/cream'':63C,93C ''hormon'':6B,14C,21C,28C,33C,39C,41C,53C,83C,117C,130C,144C,152C,163C ''hot'':50C ''hrt'':31C ''know'':157C ''like'':49C ''longer'':124C,137C ''mean'':19C ''menopaus'':5B,13C,20C,38C,47C,52C,82C,116C,129C,143C,151C,162C ''never'':149C ''often'':24C ''past'':121C,134C ''patch'':61C,91C ''pill'':59C,89C ''progestogen'':71C,101C ''question'':8C ''refer'':25C ''replac'':29C ''symptom'':48C ''take'':67C,73C,79C,97C,103C,109C,142C ''taken'':4B,12C,115C,128C,150C,161C ''testosteron'':76C,106C ''therapi'':7B,15C,22C,30C,40C,42C,54C,84C,118C,131C,145C,153C,164C ''treat'':46C ''use'':44C ''whether'':158C ''women'':66C,96C ''yes'':112C,125C,138C', 'e6992fe1-e80a-33ba-bae0-316ab1d36814', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58740, 'SINGLE_ANSWER', 'What formulation (types) of menopausal hormone therapy have you taken?', 57303, 'Formulation', 20, '<b>Question : What formulation (types) of menopausal hormone therapy have you taken? </b>
<br/>
<br/>
<b>What does this mean : </b>Menopausal hormone therapy can come in a pill or patch or gel/cream form. Some women take estrogen and a progesterone. Some take estrogen and testosterone, and some take only estrogen. 

 <br/>
<br/>
', true, '''bioident'':101C ''combin'':71C,82C ''come'':31C ''compound'':106C ''estrogen'':43C,49C,56C,61C,66C,75C,86C,92C ''form'':39C ''formul'':1A,3B,14C,113C ''gel/cream'':38C ''hormon'':7B,18C,28C,103C,117C ''know'':111C ''mean'':26C ''menopaus'':6B,17C,27C,116C ''patch'':36C ''pharmaci'':107C ''pill'':34C,72C,83C,97C ''progesteron'':46C ''progestin'':77C,94C ''question'':12C ''separ'':96C ''take'':42C,48C,54C ''taken'':11B,22C,59C,64C,69C,80C,91C,100C ''testosteron'':51C,88C ''therapi'':8B,19C,29C,118C ''type'':4B,15C ''use'':120C ''women'':41C', 'c309820a-b4bd-39c0-a319-7a98b2dfcad5', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69228, 'CONTENT', 'Provide an alternate contact in the event that we are unable to reach you for future follow-up-
<br/>
<br/>', 58000, 'TEXT-CONTENT', 24, NULL, false, '''altern'':6B ''contact'':7B ''content'':3A ''event'':10B ''follow'':21B ''follow-up'':20B ''futur'':19B ''provid'':4B ''reach'':16B ''text'':2A ''text-cont'':1A ''unabl'':14B', '96d67dd3-9b5a-3aaa-9e1f-358a5aae71e4', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57808, 'SINGLE_ANSWER', 'Check the box that best describes your highest level of completed schooling: ', 58000, 'Edu', 15, '', false, '''4'':28C ''best'':6B ''box'':4B ''check'':2B ''colleg'':27C,30C ''complet'':12B ''d'':34C ''describ'':7B ''edu'':1A ''graduate/professional'':31C ''high'':16C,20C,24C ''highest'':9B ''less'':14C,18C ''level'':10B ''rather'':35C ''say'':37C ''school'':13B,17C,21C,23C,25C,32C ''vocat'':22C ''year'':29C', '12a53b6d-f04d-3eb6-873b-1a0a3585250b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2399, 'SINGLE_ANSWER', ' I enjoy eating ice cream so much that I eat it:', 2116, 'Enjoy ice cream', 9, '', false, NULL, '9f983300-e238-43df-a079-b75825084815', 'bf5decce-0553-4f9e-a90a-32b6c86a8e3d', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1535, 'SINGLE_ANSWER', '', 1465, 'Street Address', 12, '', true, NULL, '0af39359-ce96-4e04-af7b-0aa50c4eda6e', '3f02d218-2a82-390f-9570-b6315fea9307', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69244, 'CONTENT', 'Please select your height in feet and inches from below drop down box?', 57304, 'TEXT-CONTENT', 8, NULL, false, '''box'':16B ''content'':3A ''drop'':14B ''feet'':9B ''height'':7B ''inch'':11B ''pleas'':4B ''select'':5B ''text'':2A ''text-cont'':1A', '24f1e86c-b0d2-3454-a535-f437a6807af2', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69242, 'SINGLE_ANSWER', 'Please specify other relationship with your contact?', 58000, 'other', 39, '', false, '''contact'':7B ''pleas'':1B ''relationship'':4B ''specifi'':2B,9C,11C', '176f859b-af3f-31d9-a71a-69c5d8050f92', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69241, 'SINGLE_ANSWER', 'Select the term that best describes the relationship for this contact:?', 58000, 'relation', 38, '', false, '''best'':6B ''contact'':12B ''d'':22C ''describ'':7B ''doctor'':18C ''famili'':13C,15C ''friend'':17C ''member'':14C,16C ''nurs'':20C ''rather'':23C ''relat'':1A ''relationship'':9B ''say'':25C ''select'':2B ''specifi'':27C ''term'':4B', '3b370239-0d37-33f7-a87a-8bc61bf9961f', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69243, 'SINGLE_ANSWER', '', 58000, 'state', 32, '', true, '''alabama'':8C ''alaska'':9C ''arizona'':10C ''arkansa'':11C ''california'':12C ''carolina'':45C,55C ''colorado'':13C ''connecticut'':14C ''dakota'':47C,57C ''delawar'':15C ''florida'':16C ''georgia'':17C ''hampshir'':37C ''hawaii'':18C ''idaho'':19C ''illinoi'':20C ''indiana'':21C ''iowa'':22C ''island'':53C ''jersey'':39C ''kansa'':23C ''kentucki'':24C ''louisiana'':25C ''main'':26C ''maryland'':27C ''massachusett'':28C ''mexico'':41C ''michigan'':29C ''minnesota'':30C ''mississippi'':31C ''missouri'':32C ''montana'':33C ''nebraska'':34C ''nevada'':35C ''new'':36C,38C,40C,42C ''north'':44C,46C ''ohio'':48C ''oklahoma'':49C ''oregon'':50C ''pennsylvania'':51C ''pleas'':2C,5C ''rhode'':52C ''select'':3C,6C ''south'':54C,56C ''state'':1A,4C,7C ''tennesse'':58C ''texa'':59C ''utah'':60C ''vermont'':61C ''virginia'':62C,65C ''washington'':63C ''west'':64C ''wisconsin'':66C ''wyom'':67C ''york'':43C', '0f31c901-473d-3611-ade9-8f59b39e1b2a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69236, 'SINGLE_ANSWER', '', 58000, 'email', 37, '', false, '''email'':1A,2C,3C', '327c3a79-e53c-3243-9c30-8e214cbec0fb', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69240, 'SINGLE_ANSWER', '', 58000, 'zip', 33, '', false, '''zip'':1A,2C,3C', 'ea9bc038-b95a-3dc7-8e8d-69cf5eb0a83b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69233, 'SINGLE_ANSWER', '', 58000, 'pn', 34, '', false, '''phone'':2C,3C ''pn'':1A', '125671d9-a9fd-3436-93f2-8368f849ce5e', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1769, 'SINGLE_ANSWER', 'B. ...cysts (liquid or solid) or lumps ?', 1464, 'cyst', 6, '', true, '''b'':2B ''cyst'':1A,3B ''liquid'':4B ''lump'':8B ''one'':11C,14C ''pleas'':9C,12C ''select'':10C,13C ''solid'':6B ''yes'':15C', 'dcc4e51a-1ac0-4aec-93e5-c70e276eb630', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58745, 'SINGLE_ANSWER', 'Do you want to tell the  year did you experience your ovarian surgery (oophorectomy)?', 57303, 'year of overy surgery', 25, '', true, '''d'':29C ''experi'':14B ''know/i'':24C ''m'':25C ''oophorectomi'':18B ''ovarian'':16B ''overi'':3A ''rather'':30C ''say'':32C ''sure'':27C ''surgeri'':4A,17B ''tell'':9B ''want'':7B ''year'':1A,11B ''yes'':19C,20C', '0d899144-8a5a-304d-8ed2-04d10167524e', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2222, 'SINGLE_ANSWER', ' I enjoy eating ice cream so much that I eat it:', 1825, 'Enjoy ice cream', 3, '', false, '''anytim'':16C,19C ''cream'':3A,8B,33C ''eat'':6B,13B,31C ''enjoy'':1A,5B ''hot'':24C ''ice'':2A,7B,32C ''much'':10B ''never'':30C ''occasion'':20C', 'bf5decce-0553-4f9e-a90a-32b6c86a8e3d', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1516, 'SINGLE_ANSWER', 'What is your age?', 1465, 'age', 8, '', true, '''age'':1A,5B,6C,7C', '7bcc720d-eea6-42cd-a008-3ce026391752', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59865, 'SINGLE_ANSWER_TABLE', 'Instructions: By checking one box per line, please indicate how true each statement has been for you during the past 7 days', 57304, 'concerns', 21, '', true, '''7'':22B ''addit'':24C ''applic'':37C,59C,81C,103C,125C,147C,171C,193C,217C,241C,263C,287C,307C,329C,350C,370C,390C,412C,432C,456C ''bit'':29C,33C,51C,55C,73C,77C,95C,99C,117C,121C,139C,143C,163C,167C,185C,189C,209C,213C,233C,237C,255C,259C,279C,283C,299C,303C,321C,325C,342C,346C,362C,366C,382C,386C,404C,408C,424C,428C,448C,452C ''bleed'':156C,160 ''bloat'':295C,296 ''box'':6B ''breast'':315C,317 ''check'':4B ''cold'':67C,69 ''concern'':1A,25C,26 ''d'':39C,61C,83C,105C,127C,149C,173C,195C,219C,243C,265C,289C,309C,331C,352C,372C,392C,414C,434C,458C ''day'':23B ''diarrhea'':358C,359 ''discharg'':112C,114 ''discomfort'':203C ''dizzi'':274C ''dryness'':180C,182 ''feel'':270C,294C ''flash'':46C,48 ''gain'':249C,251 ''get'':377C ''head'':272C,276 ''headach'':378C,379 ''hot'':45C,47 ''indic'':10B ''instruct'':2B ''intercours'':205C ''interest'':226C,230 ''irrit'':420C,421 ''itch'':136 ''itching/irritation'':134C ''joint'':443C,444 ''light'':271C,275 ''line'':8B ''littl'':28C,50C,72C,94C,116C,138C,162C,184C,208C,232C,254C,278C,298C,320C,341C,361C,381C,403C,423C,447C ''lost'':225C,229 ''mood'':398C,400 ''much'':35C,57C,79C,101C,123C,145C,169C,191C,215C,239C,261C,285C,305C,327C,348C,368C,388C,410C,430C,454C ''night'':89C,91 ''one'':5B ''pain'':201C,206,440C,445 ''past'':21B ''per'':7B ''pleas'':9B ''quit'':31C,53C,75C,97C,119C,141C,165C,187C,211C,235C,257C,281C,301C,323C,344C,364C,384C,406C,426C,450C ''rather'':40C,62C,84C,106C,128C,150C,174C,196C,220C,244C,266C,290C,310C,332C,353C,373C,393C,415C,435C,459C ''say'':42C,64C,86C,108C,130C,152C,176C,198C,222C,246C,268C,292C,312C,334C,355C,375C,395C,417C,437C,461C ''sensit'':318 ''sensitivity/tenderness'':316C ''sex'':228C ''somewhat'':30C,52C,74C,96C,118C,140C,164C,186C,210C,234C,256C,280C,300C,322C,343C,363C,383C,405C,425C,449C ''spot'':158C ''statement'':14B ''sweat'':68C,70,90C,92 ''swing'':399C,401 ''true'':12B ''vagin'':111C,113,133C,135,155C,159,179C,181 ''vomit'':338C,339 ''weight'':250C,252', '5b20bb1f-f1e7-3398-8449-87200e7bb32a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59863, 'SINGLE_ANSWER', 'Are you sexually active?', 57304, 'Sexcully active', 18, '', true, '''activ'':2A,6B ''d'':10C ''rather'':11C ''say'':13C ''sexculli'':1A ''sexual'':5B ''yes'':7C,8C', '2a6a4c13-10c8-31a2-beca-b5a86aaac8c7', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59862, 'SINGLE_ANSWER', 'On average how many servings of fruits and vegetables do you consume each day?', 57304, 'fruits', 17, '<b>Question : On average how many servings of fruits and vegetables do you consume each day?</b>
<br/>
<br/>
<b>What does this mean :</b> One serving is:<br/>

<ul>
<li>1/2 cup of fruit</li><br/>

<li>1 medium piece of fruit</li><br/>

<li>1/4 cup of dried fruit</li><br/>

<li>3/4 cup (6 ounces) of 100% fruit or vegetable juice</li><br/>

<li>1 cup of leafy vegetables</li>
<br/>
<li>1/2 cup of cooked or raw vegetables</li>
</ul>
<br/>
<br/>', true, '''-2'':77C ''-4'':79C ''1'':42C,62C,74C,75C,76C ''1/2'':38C,67C ''1/4'':47C ''100'':57C ''3'':78C ''3/4'':52C ''5'':80C ''6'':54C ''averag'':3B,18C ''consum'':13B,28C ''cook'':70C ''cup'':39C,48C,53C,63C,68C ''d'':82C ''day'':15B,30C ''dri'':50C ''fruit'':1A,8B,23C,41C,46C,51C,58C ''juic'':61C ''leafi'':65C ''mani'':5B,20C ''mean'':34C ''medium'':43C ''one'':35C ''ounc'':55C ''piec'':44C ''question'':16C ''rather'':83C ''raw'':72C ''say'':85C ''serv'':6B,21C,36C ''veget'':10B,25C,60C,66C,73C', '660d0aaa-203f-3185-902d-3188ddd35f04', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1762, 'SINGLE_ANSWER', 'During the five to ten years before you were first diagnosed, what most accurately describes your favorite sleeping position:', 1464, 'sleeping position', 2, '', true, '''accur'':16B ''back'':24C,27C ''describ'':17B ''diagnos'':13B ''favorit'':19B ''first'':12B ''five'':5B ''front'':30C ''left'':33C ''m'':40C ''posit'':2A,21B ''right'':37C ''side'':34C,38C ''sleep'':1A,20B ''sure'':42C ''ten'':7B ''year'':8B', '6e6a71d3-2fa1-4782-a7fe-08b0e2382c86', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59868, 'SINGLE_ANSWER', 'Please specity what other  herbal or alternative remedies you are taking?', 57304, 'other herbal remedy', 25, '', true, '''altern'':10B ''herbal'':2A,8B ''pleas'':4B,15C,17C ''remedi'':3A,11B ''specifi'':16C,18C ''speciti'':5B ''take'':14B', '685aff7a-9b4e-3746-97ac-239a2079149c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57822, 'SINGLE_ANSWER', 'What do YOU think causes breast cancer?   ', 57304, 'BC Cause', 26, '', false, '''bc'':1A ''breast'':8B,10C,13C ''cancer'':9B,11C,14C ''caus'':2A,7B,12C,15C ''think'':6B', '0744ce17-a1e9-350d-816b-805c45c95d34', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3216, 'SINGLE_ANSWER_TABLE', 'Does your health limit you in these activities? If so, how much? (Select one response for each item.)', 2512, 'activity', 40, '', false, NULL, '26b8b33a-143a-47ea-9e5b-4de97224be34', 'bbf87c1f-d18c-304c-b9da-e5b1c2aadcc6', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57803, 'CONTENT', 'Please note we will be asking more detailed questions related to this topic in future modules.', 57303, 'TEXT-CONTENT', 3, NULL, false, '''ask'':9B ''content'':3A ''detail'':11B ''futur'':18B ''modul'':19B ''note'':5B ''pleas'':4B ''question'':12B ''relat'':13B ''text'':2A ''text-cont'':1A ''topic'':16B', 'e211205b-1dce-3f4c-b563-73c1275ab072', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2186, 'SINGLE_ANSWER', '', 1825, '', 7, '', false, '''top'':2C,4C', '15f3c445-2645-45d9-be4d-701d5d400e61', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (59860, 'SINGLE_ANSWER_TABLE', 'How many alcoholic beverages do you currently consume in an average week?', 57304, 'How many', 15, '<b>Question : How many alcoholic beverages do you currently consume in an average week?</b>
<br/>
<br/>
<b>What does this mean : </b> <br/>Beer: 1 can or bottle = 12oz. <br/>Wine: 1 glass of wine = 4oz. <br/>hard liquor: 1 shot = 1.5oz
<br/>
<br/>', true, '''-11'':59C,75C,90C,106C,122C ''-5'':55C,71C,86C,102C,118C ''-8'':57C,73C,88C,104C,120C ''/week'':114C ''1'':33C,39C,46C,52C,63C,68C,79C,83C,94C,99C,110C,115C,126C ''1.5'':48C ''12'':60C,76C,91C,107C,123C ''12oz'':37C ''2'':53C,69C,84C,100C,116C ''3'':54C,70C,85C,101C,117C ''4oz'':43C ''6'':56C,72C,87C,103C,119C ''9'':58C,74C,89C,105C,121C ''alcohol'':5B,18C,112C ''averag'':13B,26C ''bear'':64C,67 ''beer'':32C ''beverag'':6B,19C,113C ''bottl'':36C,66C ''can'':65C ''consum'':10B,23C ''current'':9B,22C ''glass'':40C,81C ''hard'':44C,95C ''less'':61C,77C,92C,108C,124C ''liq'':51 ''liquor'':45C,50C,96C,98 ''mani'':2A,4B,17C ''mean'':31C ''ounc'':97C ''oz'':49C ''question'':15C ''shot'':47C ''week'':14B,27C ''wine'':38C,42C,80C,82', '18198db0-eb2e-3edc-a9e6-51dff779b4c5', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58718, 'SINGLE_ANSWER', 'Are tissue samples from your breast cancer available for further testing? ', 58200, 'Tissue Available', 18, '<b>Question : Are tissue samples from your breast cancer available for further testing? </b>
<br/>
<br/>
<b>What does this mean :</b> In order to obtain information about your cancer , pathologists prepare samples of the breast tumor on slides for microscopic examination. Some institutions have the capacity to store tumor samples. This allows them to apply diagnostic tests that become available at a later date.
<br/>
<br/>
 
<b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other healthcare professional.
 <br/>
<br/>
 
 
', true, '''allow'':60C ''although'':79C ''appli'':63C ''ask'':107C ''avail'':2A,10B,22C,68C ''becom'':67C ''breast'':8B,20C,43C ''cancer'':9B,21C,37C ''capac'':54C ''complet'':93C ''d'':124C ''date'':72C ''diagnost'':64C ''examin'':49C ''find'':76C ''found'':100C ''healthcar'':112C ''inform'':34C,78C,88C,97C ''institut'':51C ''know/i'':119C ''later'':71C ''mean'':29C ''microscop'':48C ''obtain'':33C,86C ''oncologist'':109C ''order'':31C ''patholog'':103C ''pathologist'':38C ''prepar'':39C ''profession'':113C ''purpos'':91C ''question'':14C ''rather'':125C ''rememb'':122C ''report'':104C ''requir'':83C ''sampl'':5B,17C,40C,58C ''say'':127C ''slide'':46C ''store'':56C ''survey'':95C ''test'':13B,25C,65C ''tissu'':1A,4B,16C ''tumor'':44C,57C ''yes'':114C,115C', '5730e794-d47a-3cef-a5a6-daeb18fd7376', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2140, 'SINGLE_ANSWER', 'Do you like ice creams?', 2116, 'Like Icecreams', 5, '', true, NULL, '02af103d-ee4d-420b-9b0c-31bfa8530a98', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1543, 'SINGLE_ANSWER', '', 1465, 'zip', 16, '', true, NULL, 'fe603ab3-6052-4232-95c6-2e64a703c413', 'ba16f0b4-9cb8-3f11-a37d-cbd9baf7a441', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1533, 'SINGLE_ANSWER', '', 1465, 'First Name', 11, '', false, '''first'':1A,3C,5C ''name'':2A,4C,6C', '0d726a1e-2cc3-42f7-b311-53fda4918012', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58717, 'SINGLE_ANSWER', 'Did you have a sentinel node biopsy?', 58200, 'Senital Biopsy', 17, '<b>Question : Did you have a sentinel node biopsy? </b>
<br/>
<br/>
<b>What does this mean :</b> The sentinel node biopsy is a technique surgeons use to determine if the cancer has spread outside the breast tissue. Cancer typically spreads to the lymph system by first moving through one or two sentinel nodes. This is the node, or nodes, that the tumor drains into, which means they are the first place cancer cells would appear in the lymphatic system. The sentinel node is examined very carefully for cancer. If it contains cancer cells, the surgeon will remove additional axillary nodes.
<br/>
<br/>
 
<b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other healthcare professional.
 
 
 
', true, '''addit'':102C ''although'':111C ''appear'':79C ''ask'':139C ''axillari'':103C ''biopsi'':2A,9B,17C,25C ''breast'':40C ''cancer'':35C,42C,76C,92C,96C ''care'':90C ''cell'':77C,97C ''complet'':125C ''contain'':95C ''d'':156C ''determin'':32C ''drain'':67C ''examin'':88C ''find'':108C ''first'':50C,74C ''found'':132C ''healthcar'':144C ''inform'':110C,120C,129C ''know/i'':151C ''lymph'':47C ''lymphat'':82C ''mean'':21C,70C ''move'':51C ''node'':8B,16C,24C,57C,61C,63C,86C,104C ''obtain'':118C ''oncologist'':141C ''one'':53C ''outsid'':38C ''patholog'':135C ''place'':75C ''profession'':145C ''purpos'':123C ''question'':10C ''rather'':157C ''rememb'':154C ''remov'':101C ''report'':136C ''requir'':115C ''say'':159C ''senit'':1A ''sentinel'':7B,15C,23C,56C,85C ''spread'':37C,44C ''surgeon'':29C,99C ''survey'':127C ''system'':48C,83C ''techniqu'':28C ''tissu'':41C ''tumor'':66C ''two'':55C ''typic'':43C ''use'':30C ''would'':78C ''yes'':146C,147C', '68a90401-8c56-301d-807c-59960902b2cc', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58713, 'SINGLE_ANSWER', 'Was cancer found in the lymph nodes of your armpit at diagnosis?', 58200, 'ca in Lymph Nodes', 14, '<b>Question : Was cancer found in the lymph nodes of your armpit at diagnosis?</b>
<br/>
<br/>
 
<b>What does this mean :</b> The axillary lymph nodes are the lymph nodes in your armpit. When breast cancer spreads, these nodes are usually the first place it will go. In the past, surgeons would always dissect and remove the axillary nodes to examine them for signs of cancer. Now most surgeons perform a sentinel node biopsy (see below), and then only further dissect the axillary nodes if cancer cells were found in the sentinel node. If cancer WAS found in your axillary lymph nodes, your breast cancer will have been staged as a II or III. If your lymph nodes were negative (no cancer), your stage could have been 0, I, or II depending on the size of the tumor.
<br/>
<br/>

 
<b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other healthcare professional.
 <br/>
<br/>
 
 
', true, '''0'':139C ''although'':156C ''alway'':64C ''armpit'':14B,27C,44C ''ask'':184C ''axillari'':35C,69C,94C,111C ''biopsi'':85C ''breast'':46C,115C ''ca'':1A ''cancer'':6B,19C,47C,77C,97C,106C,116C,133C ''cell'':98C ''complet'':170C ''could'':136C ''d'':203C ''depend'':143C ''diagnosi'':16B,29C ''dissect'':65C,92C ''examin'':72C ''find'':153C ''first'':54C ''found'':7B,20C,100C,108C,177C ''go'':58C ''healthcar'':189C ''ii'':123C,142C ''iii'':125C ''inform'':155C,165C,174C ''know/i'':198C ''lymph'':3A,10B,23C,36C,40C,112C,128C ''mean'':33C ''negat'':131C ''node'':4A,11B,24C,37C,41C,50C,70C,84C,95C,104C,113C,129C ''obtain'':163C ''oncologist'':186C ''past'':61C ''patholog'':180C ''perform'':81C ''place'':55C ''profession'':190C ''purpos'':168C ''question'':17C ''rather'':204C ''rememb'':201C ''remov'':67C ''report'':181C ''requir'':160C ''say'':206C ''see'':86C ''sentinel'':83C,103C ''sign'':75C ''size'':146C ''spread'':48C ''stage'':120C,135C ''surgeon'':62C,80C ''survey'':172C ''test'':194C ''tumor'':149C ''usual'':52C ''would'':63C ''yes'':191C,192C', '721cef08-eb70-30c1-8895-b7c7f361eafa', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1764, 'SINGLE_ANSWER', 'A. ...tenderness in your breast that lasted for more than a month each time? ', 1464, 'tenderness', 4, '', true, '''breast'':6B ''last'':8B ''month'':13B ''one'':18C,21C ''pleas'':16C,19C ''select'':17C,20C ''tender'':1A,3B ''time'':15B ''yes'':22C', 'c62a1586-ef7d-4af5-8103-40713218e71a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58710, 'SINGLE_ANSWER', 'Was your tumor positive for progesterone receptors (PR positive)? ', 58200, 'Progesterone Recptors status', 11, '<b>Question : Was your tumor positive for progesterone receptors (PR positive)?</b>
<br/>
<br/> 
<b>What does this mean : </b>Progesterone is a hormone produced by the ovaries. Some breast tumors also have progesterone receptors on their cells. When these receptors are present, the tumor is referred to as progesterone positive or PR positive (PR+). When they are absent, the tumor is referred to as progesterone negative or PR negative (PR-). ER+ and/or PR+ cancers are more likely to respond to hormonal therapy. 
<br/>
<br/>
 Estrogen is a hormone produced primarily by the ovaries before monopause. Some breast tumors have proteins on their cells that bind to estrogen. Those proteins are called estrogen receptors. Breast cancer cells that grow in response to estrogrn are reffered to as esteogen positive or (ER+). Breast cancer cells that are not stimulated by estrogen are reffered to as a estrogen receptor negative or (ER-).
<br/>
<br/>
<b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other healthcare professional.
 <br/>
<br/>
 
 
', true, '''absent'':65C ''also'':38C ''although'':161C ''and/or'':79C ''ask'':189C ''bind'':110C ''breast'':36C,102C,119C,136C ''call'':116C ''cancer'':81C,120C,137C ''cell'':44C,108C,121C,138C ''complet'':175C ''d'':208C ''er'':78C,135C,154C ''esteogen'':132C ''estrogen'':90C,112C,117C,144C,150C ''estrogrn'':127C ''find'':158C ''found'':182C ''grow'':123C ''healthcar'':194C ''hormon'':30C,88C,93C ''inform'':160C,170C,179C ''know/i'':203C ''like'':84C ''mean'':26C ''monopaus'':100C ''negat'':73C,76C,152C ''obtain'':168C ''oncologist'':191C ''ovari'':34C,98C ''patholog'':185C ''posit'':7B,12B,17C,22C,57C,60C,133C ''pr'':11B,21C,59C,61C,75C,77C,80C ''present'':49C ''primarili'':95C ''produc'':31C,94C ''profession'':195C ''progesteron'':1A,9B,19C,27C,40C,56C,72C ''protein'':105C,114C ''purpos'':173C ''question'':13C ''rather'':209C ''receptor'':10B,20C,41C,47C,118C,151C ''recptor'':2A ''refer'':53C,69C ''reffer'':129C,146C ''rememb'':206C ''report'':186C ''requir'':165C ''respond'':86C ''respons'':125C ''say'':211C ''status'':3A ''stimul'':142C ''survey'':177C ''test'':199C ''therapi'':89C ''tumor'':6B,16C,37C,51C,67C,103C ''yes'':196C,197C', '77e02f51-43d1-3b77-8737-ede8abee800a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58711, 'SINGLE_ANSWER', 'Was your tumor positive for the HER2/neu tumor marker?', 58200, 'HER2 Status', 12, '<b>Question : Was your tumor positive for the HER2/neu tumor marker?</b> 
<br/>
<br/>
<b>What does this mean : </b>The HER2 gene helps cells grow, divide, and repair themselves. Normally, there are two copies of the HER2 gene inside every cell. When breast cancer develops, this gene may start to make too many copies of itself. These extra genes result in there being too many HER2 protein receptors on the cancer cell''s surface. These receptors pick up more grow-and-divide messages than a cell should normally get, fueling the cancer''s growth. About 25% - 30% percent of all invasive breast cancers have too many copies of the HER2 gene and too many HER2 receptors. These cancers are referred to as HER2-positive. HerceptinÃ‚Â® is a targeted therapy that is used to treat tumors that are HER2-positive.
<br/>
<br/>
 
<b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other healthcare professional.
 
 
 
', true, '''25'':103C ''30'':104C ''although'':155C ''ask'':183C ''breast'':49C,109C ''cancer'':50C,77C,99C,110C,125C ''cell'':30C,47C,78C,93C ''complet'':169C ''copi'':40C,60C,114C ''d'':202C ''develop'':51C ''divid'':32C,89C ''everi'':46C ''extra'':64C ''find'':152C ''found'':176C ''fuel'':97C ''gene'':28C,44C,53C,65C,118C ''get'':96C ''grow'':31C,87C ''grow-and-divid'':86C ''growth'':101C ''healthcar'':188C ''help'':29C ''her2'':1A,27C,43C,72C,117C,122C,131C,147C ''her2-positive'':130C,146C ''her2/neu'':9B,19C ''herceptinÃ¢'':133C ''inform'':154C,164C,173C ''insid'':45C ''invas'':108C ''know/i'':197C ''make'':57C ''mani'':59C,71C,113C,121C ''marker'':11B,21C ''may'':54C ''mean'':25C ''messag'':90C ''normal'':36C,95C ''obtain'':162C ''oncologist'':185C ''patholog'':179C ''percent'':105C ''pick'':83C ''posit'':6B,16C,132C,148C ''profession'':189C ''protein'':73C ''purpos'':167C ''question'':12C ''rather'':203C ''receptor'':74C,82C,123C ''refer'':127C ''rememb'':200C ''repair'':34C ''report'':180C ''requir'':159C ''result'':66C ''say'':205C ''start'':55C ''status'':2A ''surfac'':80C ''survey'':171C ''target'':136C ''test'':193C ''therapi'':137C ''treat'':142C ''tumor'':5B,10B,15C,20C,143C ''two'':39C ''use'':140C ''yes'':190C,191C', '9cb85f93-0612-3ee3-82a8-ce72a1ff286a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2435, 'SINGLE_ANSWER_TABLE', 'Were the tumor cells:', 1774, 'tumor cells', 6, '', true, '''cell'':2A,6B ''egfr'':28C,29 ''er'':10 ''estrogen'':7C ''her2'':23 ''her2/neu'':22C ''know'':14C,21C,27C,33C ''posit'':9C ''pr'':17 ''progesteron'':15C ''receptor'':8C,16C ''tumor'':1A,5B ''yes'':11C,18C,24C,30C', 'e70200df-c882-4a88-836c-03dc0f4943b5', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58253, 'SINGLE_ANSWER', 'What was the stage of your cancer on pathology?', 58200, '', 6, '<b>Question : What was the stage of your cancer at diagnosis?</b><br>
<br/><b>What does this mean :</b>Stage is a term used by doctors to describe the size of a tumor at diagnosis and whether or not it has spread beyond your breast. Doctors consider stage when determining treatment. <br>


<br/><b>There are four breast cancer stages:</b>

<br/><b>Stage 0 - DCIS (Ductal Carcinoma-in-situ).</b> Abnormal breast cells that are confined within the milk ducts of the breast. Because the cells are still confined to the duct, DCIS is sometimes referred to as a pre-cancer.

<br/><b>&nbsp;Stage 0 - LCIS (Lobular Carcinoma-in-situ)</b> Abnormal breast cells that are confined within the lobules of the breast.

<br/><b>Stage I -</b> A breast tumor that is no larger than 2 cm (about an inch), with cells that have spread beyond the milk ducts into the surrounding breast tissue, but has not spread to any lymph nodes.

<br/><b>Stage II - </b>A breast tumor that is smaller than 5 cm (about 2 inches) and has spread to the axillary nodes (lymph nodes under the arm) or a breast tumor that is 2 cm (about an inch) or larger and has not spread to the axillary nodes. <br>

<br/><b>Stage III -</b> A breast tumor that is smaller than 5 cm (about 2 inches) and has spread to and causes axillary nodes to attach to each other or other structures or a breast tumor that is larger than 5 cm and has simply spread to the axillary nodes. <br/><b>Stage III</b> breast tumors also includes tumors that have spread to the skin or chest wall near the breast or to lymph nodes inside the chest wall.<br>

<br/><b>Stage IV -</b> A breast tumor that has spread its cells to distant organs, such as bone, brain, liver or lung.<br>

<br/><b>How can you find this information :</b>Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other healthcare professional.', false, '''0'':63C,103C ''2'':132C,171C,191C,218C ''5'':168C,215C,244C ''abnorm'':70C,110C ''also'':258C ''although'':307C ''arm'':184C ''ask'':335C ''attach'':229C ''axillari'':178C,204C,226C,252C ''beyond'':47C,142C ''bone'':296C ''brain'':297C ''breast'':49C,59C,71C,82C,111C,121C,125C,149C,162C,187C,209C,238C,256C,272C,284C ''cancer'':7B,17C,60C,101C ''carcinoma'':67C,107C ''carcinoma-in-situ'':66C,106C ''caus'':225C ''cell'':72C,85C,112C,138C,290C ''chest'':268C,279C ''cm'':133C,169C,192C,216C,245C ''complet'':321C ''confin'':75C,88C,115C ''consid'':51C ''d'':366C ''dcis'':64C,92C,344C,347C ''describ'':32C ''determin'':54C ''diagnosi'':19C,39C ''distant'':292C ''doctor'':30C,50C ''duct'':79C,91C,145C ''ductal'':65C ''find'':304C ''found'':328C ''four'':58C ''healthcar'':340C ''ii'':160C,353C ''iii'':207C,255C,355C ''inch'':136C,172C,195C,219C ''includ'':259C ''inform'':306C,316C,325C ''insid'':277C ''iv'':282C,357C ''know/i'':361C ''larger'':130C,197C,242C ''lcis'':104C,350C ''liver'':298C ''lobul'':118C ''lobular'':105C ''lung'':300C ''lymph'':157C,180C,275C ''mean'':23C ''milk'':78C,144C ''near'':270C ''node'':158C,179C,181C,205C,227C,253C,276C ''obtain'':314C ''oncologist'':337C ''organ'':293C ''patholog'':9B,331C ''pre'':100C ''pre-canc'':99C ''profession'':341C ''purpos'':319C ''question'':10C ''rather'':367C ''refer'':95C ''rememb'':364C ''report'':332C ''requir'':311C ''say'':369C ''simpli'':248C ''situ'':69C,109C,343C,346C,349C ''size'':34C ''skin'':266C ''smaller'':166C,213C ''sometim'':94C ''spread'':46C,141C,154C,175C,201C,222C,249C,263C,288C ''stage'':4B,14C,24C,52C,61C,62C,102C,122C,159C,206C,254C,281C,352C,354C,356C ''stage1'':351C ''still'':87C ''structur'':235C ''surround'':148C ''survey'':323C ''term'':27C ''tissu'':150C ''treatment'':55C ''tumor'':37C,126C,163C,188C,210C,239C,257C,260C,285C ''use'':28C ''wall'':269C,280C ''whether'':41C ''within'':76C,116C', '3c120506-430d-3ca5-bfda-6e78d0d802df', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1765, 'CONTENT', 'Before being first diagnosed for breast cancer, did you experience:
<br/>
<br/>', 1464, 'TEXT-CONTENT', 3, NULL, false, '''breast'':9B ''cancer'':10B ''content'':3A ''diagnos'':7B ''experi'':13B ''first'':6B ''text'':2A ''text-cont'':1A', '711f4674-6aca-4a71-8189-ef1ead0cead4', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2437, 'SINGLE_ANSWER', 'When you were first diagnosed, was the cancer in other organs (metastatic) ?', 1774, 'Other Organs', 7, 'What does that mean', true, '''cancer'':10B ''diagnos'':7B ''first'':6B ''mean'':18C ''metastat'':14B ''organ'':2A,13B ''yes'':19C,20C', '49366863-96da-4a49-8f4f-18c50fb4e616', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1524, 'MULTI_ANSWER', 'Which of the following best describe(s) you? (Check all that apply)', 1465, 'ethnicity', 20, '', true, '''african'':15C,19C ''african-american'':14C,18C ''aleutian'':22C ''american'':16C,20C,24C ''appli'':13B ''asian'':26C ''best'':6B ''black'':17C,21C ''caucasian'':31C ''check'':10B ''describ'':7B ''eskimo'':23C ''ethnic'':1A ''follow'':5B ''hispan'':32C ''indian'':25C ''island'':29C ''know'':35C ''pacif'':28C ''white'':30C', 'fc7c392f-5d5c-4ad0-9d1d-4a11b1362972', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1590, 'SINGLE_ANSWER', 'Do you eat red meat often?', 57304, '', 27, '', false, '''eat'':3B ''frequenc'':7C,8C ''meat'':5B ''often'':6B ''red'':4B', 'b00b45ec-43d5-4d39-9006-afe05d17fc50', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1525, 'SINGLE_ANSWER', '', 1465, '', 21, '', false, '''pleas'':1C,3C ''specifi'':2C,4C', 'd9e246c6-8e27-4081-b7d9-1384d864edb5', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1766, 'SINGLE_ANSWER', ' If "yes" ', 1464, 'Left Breast', 5, '', true, '''breast'':2A,10C,16C,18C,21C ''left'':1A,9C,15C ''right'':17C ''yes'':4B', '387819da-5427-4b91-948b-703054530cd5', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1485, 'SINGLE_ANSWER', 'Has a health care professional ever brought up the topic of breast cancer clinical trials with you?', 1465, 'topic of breast cancer clinical trials ', 6, '', true, '''breast'':3A,18B ''brought'':13B ''cancer'':4A,19B ''care'':10B ''clinic'':5A,20B ''ever'':12B ''health'':9B ''know'':24C,27C ''profession'':11B ''topic'':1A,16B ''trial'':6A,21B ''yes'':28C', '0279419c-b806-41e3-8b30-353350f37147', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57814, 'MULTI_ANSWER', 'What is your ethnic background? Check all that apply?', 58000, 'Ethnicity', 18, '<b>Question : What is your ethnic background?</b>
<br/>
<br/>
<b>What does this mean :</b> Please choose the race that best describes you. If you do not see an appropriate category, choose Other Race and enter your race in the text box. The next question asks about your ethnicity as it relates to being Spanish/Hispanic/Latino. The categories available in this list are those used by the U.S. Census. More details regarding race and ethnicity will be asked in future modules.
<br/>
<br/>', true, '''african'':91C ''alaska'':96C ''american'':92C,93C ''appli'':10B ''appropri'':35C ''asian'':106C ''asian/east'':98C ''ask'':51C,82C ''avail'':63C ''background'':6B,16C ''best'':26C ''black'':90C ''box'':47C ''categori'':36C,62C ''caucasian'':87C,89C ''census'':73C ''chamorro'':111C ''check'':7B ''chines'':100C ''choos'':22C,37C ''describ'':27C ''detail'':75C ''enter'':41C ''ethnic'':1A,5B,15C,54C,79C ''filipino'':101C ''futur'':84C ''guamanian'':109C ''hawaiian'':108C ''indian'':94C,99C ''island'':115C ''japanes'':102C ''korean'':103C ''list'':66C ''mean'':20C ''modul'':85C ''nativ'':97C,107C ''next'':49C ''pacif'':114C ''pleas'':21C ''question'':11C,50C ''race'':24C,39C,43C,77C,117C ''regard'':76C ''relat'':57C ''samoan'':112C ''see'':33C ''spanish/hispanic/latino'':60C ''text'':46C ''u.s'':72C ''use'':69C ''vietnames'':104C ''white'':86C,88C', '68e4a456-ff4f-3c1c-8308-994274c9fa9b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1468, 'MULTI_ANSWER', 'Please check any of the following items that best describe(s) you: (Check all that apply).', 1465, 'about you', 2, '', true, '''appli'':16B ''best'':9B ''breast'':17C,22C,33C ''cancer'':18C,23C,34C ''care'':37C ''check'':2B,13B ''describ'':10B ''famili'':27C ''follow'':6B ''friend'':30C ''health'':36C ''item'':7B ''member'':28C ''patient'':19C,24C,35C ''pleas'':1B ''provid'':38C ''research'':39C ''survivor'':21C,26C', '2933e1c6-0011-45c6-b0de-b750c3d72c00', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1545, 'SINGLE_ANSWER', '', 1465, 'email', 14, '', false, NULL, '68a0e1a7-56dc-4001-bcbc-d99e80545f62', '327c3a79-e53c-3243-9c30-8e214cbec0fb', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1520, 'SINGLE_ANSWER', '', 1465, '', 19, '', false, '''countri'':1C,2C', '92936b01-d793-46cb-8266-9c7cb681f56b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2189, 'SINGLE_ANSWER', 'My single most favorite brand is:', 1825, 'Favorite Brand', 8, '', true, '''bart'':17C ''ben'':25C ''blue'':23C ''brand'':2A,7B,9C,13C,34C,36C ''breyer'':16C ''bunni'':24C ''cadburi'':20C ''daz'':31C ''dean'':21C ''dreyer'':27C ''favorit'':1A,6B ''grand'':29C ''haagen'':30C ''hershey'':22C ''homemad'':19C ''jerri'':26C ''ok'':11C,15C ''singl'':4B ''store'':33C ''walgreen'':32C', '7dd2bd05-c4fc-4acb-9032-62d5c59cc61d', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3204, 'SINGLE_ANSWER_TABLE', 'This is a table question in search question screen', 2442, '', 2, '', false, '''n'':14 ''question'':5B,8B,13C,16C ''screen'':9B ''search'':7B,12C,15C ''tabl'':4B ''y'':11 ''yes'':10C', '56941260-a380-4de6-b46e-92f752b7fa83', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2439, 'MULTI_ANSWER', 'If yes, please mark which below:', 1774, 'cancer in organs', 9, '', true, '''bone'':11C ''brain'':16C ''cancer'':1A ''liver'':12C ''lung'':15C ''lymph'':13C ''mark'':7B ''node'':14C ''organ'':3A ''pleas'':6B ''spine'':8C,9C ''yes'':5B', '668d9d5d-4b48-461c-b258-aa31165a6258', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1518, 'SINGLE_ANSWER', 'Where do you live?', 1465, 'live', 15, '', true, '''citi'':6C,7C ''live'':1A,5B', 'a0188c25-2048-4fd4-aca6-d874ad882f08', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1515, 'SINGLE_ANSWER', 'What is your sex? ', 1465, 'sex', 7, '', true, '''femal'':6C,7C ''male'':8C ''sex'':1A,5B', '06a4e39f-04e2-40c2-b627-4e5a8b720372', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58259, 'SINGLE_ANSWER_TABLE', 'Does your health limit you in these activities? If so, how much? (Select one response for each item.)', 57304, 'activity', 4, '', false, '''1'':212 ''activ'':1A,9B,20C,21,39C,88C ''bath'':67C,70 ''bend'':185C ''block'':232C,234,253C ''bowl'':98C ''carri'':120C ''cleaner'':97C ''climb'':139C,162C,167 ''d'':34C,63C,83C,114C,135C,158C,181C,201C,226C,247C,267C ''dress'':69C ''flight'':141C,164C ''golf'':100C ''groceri'':121C ''health'':4B ''heavi'':44C ''item'':19B ''kneel'':186C ''lift'':43C,118C,122 ''limit'':5B,23C,27C,32C,52C,56C,61C,72C,76C,81C,103C,107C,112C,124C,128C,133C,147C,151C,156C,170C,174C,179C,190C,194C,199C,215C,219C,224C,236C,240C,245C,256C,260C,265C ''littl'':29C,58C,78C,109C,130C,153C,176C,196C,221C,242C,262C ''lot'':25C,54C,74C,105C,126C,149C,172C,192C,217C,238C,258C ''mile'':209C,213 ''moder'':87C,101 ''move'':91C ''much'':13B ''object'':45C ''one'':15B,163C,208C,252C ''particip'':46C ''push'':94C ''rather'':35C,64C,84C,115C,136C,159C,182C,202C,227C,248C,268C ''respons'':16B ''run'':42C ''say'':37C,66C,86C,117C,138C,161C,184C,204C,229C,250C,270C ''select'':14B ''sever'':140C,231C,233 ''sport'':49C ''stair'':143C,145,166C,168 ''stoop'':187C,188 ''strenuous'':48C ''tabl'':93C ''vacuum'':96C ''vigor'':38C,50 ''walk'':205C,230C,251C,254 ''yes'':22C,26C,51C,55C,71C,75C,102C,106C,123C,127C,146C,150C,169C,173C,189C,193C,214C,218C,235C,239C,255C,259C', 'bbf87c1f-d18c-304c-b9da-e5b1c2aadcc6', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1527, 'SINGLE_ANSWER', 'What is the highest grade or year of school you completed? ', 1465, 'education', 9, '', true, '''1'':14C,18C,35C ''11'':24C ''12'':26C ''3'':38C ''4'':44C ''8'':16C,20C ''9'':22C ''colleg'':30C,34C,43C ''complet'':12B ''degre'':42C,50C ''educ'':1A ''ged'':28C ''grade'':6B,13C,17C,21C,25C ''graduat'':51C ''highest'':5B ''junior'':29C ''know'':57C ''profession'':53C ''receiv'':49C ''school'':10B,33C,54C ''vocat'':32C ''year'':8B,36C,39C,45C', 'ed1ca05c-45bc-4fa7-b02f-436dcf204c4c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2323, 'SINGLE_ANSWER', ' I enjoy eating ice cream so much that I eat it:', 1833, 'Enjoy ice cream', 1, '', false, NULL, 'ed9a238d-72fa-458d-979b-84e73ff5f1c4', 'bf5decce-0553-4f9e-a90a-32b6c86a8e3d', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3075, 'CONTENT', 'Welcome to the General Health Module.

In this module, you will be presented with 4 sections related to your general health and cancer history.

This set of questionnaires deal with......', 3074, 'TEXT-CONTENT', 1, NULL, false, '''4'':18B ''cancer'':26B ''content'':3A ''deal'':32B ''general'':7B,23B ''health'':8B,24B ''histori'':27B ''modul'':9B,12B ''present'':16B ''questionnair'':31B ''relat'':20B ''section'':19B ''set'':29B ''text'':2A ''text-cont'':1A ''welcom'':4B', '744223aa-d84d-4081-b315-3d9794fcd1b3', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1771, 'SINGLE_ANSWER', 'If "Yes" ', 1464, '', 7, '', false, '''breast'':8C,14C,16C,19C ''left'':7C,13C ''right'':15C ''yes'':2B', '34008152-91ed-4f13-9b2c-aee95659f45c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1901, 'SINGLE_ANSWER_TABLE', ' My favorite ice cream flavor is:', 1825, 'Ice Cream Flavor', 5, '', true, '''1'':11 ''10'':45 ''11'':48 ''12'':51 ''13'':54 ''14'':60 ''2'':14 ''3'':18 ''4'':21 ''5'':25 ''6'':29 ''7'':33 ''8'':37 ''9'':41 ''99'':64 ''caramel'':50C ''chip'':44C ''chocol'':9C,16C,35C,43C ''cream'':2A,7B ''dark'':10C ''favorit'':5B ''flavor'':3A,8B,28C,32C,57C,63C ''french'':39C ''fruiti'':27C ''ice'':1A,6B ''light'':36C ''nut'':59C ''peanut'':31C ''peppermint'':20C ''pistachio'':53C ''road'':24C ''rocki'':23C ''strawberri'':47C ''swirl'':17C ''vanilla'':13C,40C ''yes'':12C,15C,19C,22C,26C,30C,34C,38C,42C,46C,49C,52C,55C,61C,65C', 'e7516610-6655-4d1d-820c-0308f8d2e97c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1467, 'CONTENT', 'This survey is strictly confidential and voluntary. All of your responses to this survey will only be reported as a summary in combination with the responses from other website users. Your name, address, and email address will be separated from survey responses and will not be identified in project files or in reports. None of the information will be used or released in any way that would identify you. If there are any questions which you do not wish to answer, please feel free to skip them. Completing this survey will benefit both the Breast Cancer Answers Project in evaluating this website and the many breast cancer survivors who rely on the Internet for health information. Breast Cancer Answers staff will use the survey results to improve continually the quality of the treatment and support information provided on the website. 

<br/>
<br/>', 1465, 'TEXT-CONTENT', 1, NULL, false, '''address'':36B,39B ''answer'':84B,100B,122B ''benefit'':95B ''breast'':98B,109B,120B ''cancer'':99B,110B,121B ''combin'':26B ''complet'':91B ''confidenti'':8B ''content'':3A ''continu'':131B ''email'':38B ''evalu'':103B ''feel'':86B ''file'':53B ''free'':87B ''health'':118B ''identifi'':50B,71B ''improv'':130B ''inform'':60B,119B,139B ''internet'':116B ''mani'':108B ''name'':35B ''none'':57B ''pleas'':85B ''project'':52B,101B ''provid'':140B ''qualiti'':133B ''question'':77B ''releas'':65B ''reli'':113B ''report'':21B,56B ''respons'':14B,29B,45B ''result'':128B ''separ'':42B ''skip'':89B ''staff'':123B ''strict'':7B ''summari'':24B ''support'':138B ''survey'':5B,17B,44B,93B,127B ''survivor'':111B ''text'':2A ''text-cont'':1A ''treatment'':136B ''use'':63B,125B ''user'':33B ''voluntari'':10B ''way'':68B ''websit'':32B,105B,143B ''wish'':82B ''would'':70B', '69b8e1e0-851d-4d55-bf66-7fd72d66db4a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3238, 'CONTENT', 'We are trying to find out about your level of physical activity from the last 7 days (in the last week).  This includes activities that make you sweat, make your legs feel tired, or make you breathe hard, such as team sports, running, strenuous occupational activities, and others. ', 3037, 'TEXT-CONTENT', 1, NULL, false, '''7'':19B ''activ'':15B,27B,49B ''breath'':40B ''content'':3A ''day'':20B ''feel'':35B ''find'':8B ''hard'':41B ''includ'':26B ''last'':18B,23B ''leg'':34B ''level'':12B ''make'':29B,32B,38B ''occup'':48B ''other'':51B ''physic'':14B ''run'':46B ''sport'':45B ''strenuous'':47B ''sweat'':31B ''team'':44B ''text'':2A ''text-cont'':1A ''tire'':36B ''tri'':6B ''week'':24B', '7eff3493-fa3b-4306-8ad9-e5f8e0448996', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2458, 'SINGLE_ANSWER', 'How old were you when you had your first menstrual period?', 1774, 'age', 10, '', false, NULL, 'ccefeb2a-d770-40dc-b9fb-572a89b3a60d', 'a82155f1-4f1a-338d-86ca-c430a678c52e', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1773, 'SINGLE_ANSWER', 'In what year were you born?', 1464, 'born', 8, '', true, '''born'':1A,7B ''year'':4B,8C,9C', '1016b2a2-32c5-4753-b2e9-7313d3f09777', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2332, 'SINGLE_ANSWER', 'My single most favorite brand is:', 1833, 'Favorite Brand', 3, '', true, NULL, 'e48a7bbc-c448-4bab-91c3-3643ff79d6db', '7dd2bd05-c4fc-4acb-9032-62d5c59cc61d', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3243, 'SINGLE_ANSWER', 'Which one of the following describes you best for the last 7 days?  Read all five statements before deciding on the one answer that describes you. ', 3037, 'describe your best', 4, '', false, '''-2'':64C ''-4'':88C ''-5'':103C ''1'':63C ''3'':87C ''4'':102C ''7'':15B,117C ''aerob'':84C ''answer'':26B ''best'':3A,11B ''bike'':81C ''day'':16B ''decid'':22B ''describ'':1A,9B,28B ''e.g'':75C ''effort'':44C,60C ''five'':19B ''follow'':8B ''free'':34C,50C,73C,97C,112C,128C ''involv'':41C,57C ''last'':14B,66C,90C,105C,121C ''littl'':42C,58C ''often'':86C,101C,116C ''one'':5B,25B ''physic'':43C,59C,69C,93C,108C,124C ''play'':76C ''quit'':100C ''read'':17B ''ride'':82C ''run'':79C ''sometim'':62C ''spent'':37C,53C ''sport'':77C ''statement'':20B ''swim'':80C ''thing'':39C,55C,70C,94C,109C,125C ''time'':35C,51C,65C,74C,89C,98C,104C,113C,120C,129C ''week'':67C,91C,106C,122C ''went'':78C', 'c44033dc-9cc3-4d31-b145-bfbefb4c69b8', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2493, 'SINGLE_ANSWER', 'Do you have cancer?', 1774, 'cancer', 5, '', false, '''cancer'':1A,5B ''yes'':6C,7C', 'c58949d9-c0e8-4dcc-ab4f-b7968bb7ea93', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1534, 'SINGLE_ANSWER', '', 1465, 'Last Name', 13, '', false, NULL, '19d83a83-4e6d-49c6-8bdc-ddcacedd40dd', 'ca8568ec-fe99-3dee-991f-7f9c847a381e', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2236, 'SINGLE_ANSWER', 'testing', 2116, '', 7, '', false, NULL, '771013dc-bb06-4ea2-8791-79eb37bcfa13', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3205, 'SINGLE_ANSWER', 'test search question', 2442, '', 3, '', false, '''question'':3B,5C,7C ''search'':2B,4C,6C ''test'':1B', '3ed40a51-9fa2-4222-b1eb-e0ce345db0e9', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1532, 'CONTENT', 'In order to evaluate the Breast Cancer Answers web site over time, we would like to send you a follow-up survey in a few months. If you would be willing to complete another survey for us, please enter your name and address below. 

', 1465, 'TEXT-CONTENT', 10, NULL, false, '''address'':47B ''anoth'':38B ''answer'':11B ''breast'':9B ''cancer'':10B ''complet'':37B ''content'':3A ''enter'':43B ''evalu'':7B ''follow'':24B ''follow-up'':23B ''like'':18B ''month'':30B ''name'':45B ''order'':5B ''pleas'':42B ''send'':20B ''site'':13B ''survey'':26B,39B ''text'':2A ''text-cont'':1A ''time'':15B ''us'':41B ''web'':12B ''will'':35B ''would'':17B,33B', '767898c8-5a58-4b31-801b-5b5ad61d3240', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58706, 'MULTI_ANSWER', 'How did your physician describe your cancer on pathology (check all that apply)? ', 58200, 'Cancer Category', 8, '<b>Question : How did your physician describe your cancer at diagnosis?</b> <br/> 
<br/><b>What does this mean :</b> Ductal carcinoma-in-situ (DCIS) consists of abnormal cells that are confined within the milk ducts of the breast. Lobular carcinoma-in-situ (LCIS) consists of abnormal cells that are confined within the lobules of the breast. <br/>

<br/>Invasive ductal carcinoma accounts for about 80% of all breast cancers. Ductal carcinoma arises from cells that line the milk ducts of the breast. These tumors have "invaded" the surrounding breast tissue and, depending upon their stage, may have spread beyond the breast to the lymph nodes or other organs. <br/>

<br/>Invasive lobular carcinoma accounts for about 10%-15% of all breast cancers. Lobular carcinoma arises from cells that produce breast milk. These tumors have "invaded" the surrounding breast tissue and, depending upon their stage, may have spread beyond the breast. <br/>

 
<br/><b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other health care professional.
<br/>
<br/>
 
 
 
', true, '''-15'':126C ''10'':125C ''80'':75C ''abnorm'':38C,58C ''account'':72C,122C ''although'':165C ''appli'':15B ''aris'':82C,133C ''ask'':193C ''beyond'':109C,156C ''breast'':49C,68C,78C,92C,99C,111C,129C,138C,146C,158C ''cancer'':1A,9B,23C,79C,130C ''carcinoma'':32C,52C,71C,81C,121C,132C,211C,216C ''carcinoma-in-situ'':31C,51C ''care'':199C ''categori'':2A ''cell'':39C,59C,84C,135C ''check'':12B ''complet'':179C ''confin'':42C,62C ''consist'':36C,56C ''d'':232C ''dcis'':35C,203C,206C ''depend'':102C,149C ''describ'':7B,21C ''diagnosi'':25C ''duct'':46C,89C ''ductal'':30C,70C,80C,210C ''find'':162C ''found'':186C ''health'':198C ''infiltr'':214C,219C,223C ''inform'':164C,174C,183C ''invad'':96C,143C ''invas'':69C,119C,212C,217C,221C ''know/i'':227C ''lcis'':55C,209C ''line'':86C ''lobul'':65C ''lobular'':50C,120C,131C,215C ''lymph'':114C ''may'':106C,153C ''mean'':29C ''milk'':45C,88C,139C ''node'':115C ''obtain'':172C ''oncologist'':195C ''organ'':118C ''patholog'':11B,189C ''physician'':6B,20C ''produc'':137C ''profession'':200C ''purpos'':177C ''question'':16C ''rather'':233C ''rememb'':230C ''report'':190C ''requir'':169C ''say'':235C ''situ'':34C,54C,202C,205C,208C ''spread'':108C,155C ''stage'':105C,152C ''surround'':98C,145C ''survey'':181C ''tissu'':100C,147C ''tumor'':94C,141C ''upon'':103C,150C ''within'':43C,63C', 'db8936df-ba6a-3831-bc25-0a9cf11b1284', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1775, 'CONTENT', 'This process is relatively easy to do:
Move down onto the questionnaire and on each question click on the appropriate choice. 
<br/>
<br/>
Some answers may more easily be determined if you speak with your partner or spouse (if you have been together since before your first breast cancer diagnosis). <br/><br/>

When you finish, click on "Submit Query." <br/>

Also, after you submit your responses you will see an abbreviated form on your screen that lists all of your responses. 
<br/>
<br/>
If you see an obvious error, feel free to return to the questionnaire, respond correctly to just the incorrectly answered question, place the same initials on question #13, and "Submit Query" again. 

<br/>
<br/>', 1774, 'TEXT-CONTENT', 3, NULL, false, '''13'':107B ''abbrevi'':69B ''also'':59B ''answer'':26B,99B ''appropri'':23B ''breast'':49B ''cancer'':50B ''choic'':24B ''click'':20B,55B ''content'':3A ''correct'':94B ''determin'':31B ''diagnosi'':51B ''easi'':8B ''easili'':29B ''error'':85B ''feel'':86B ''finish'':54B ''first'':48B ''form'':70B ''free'':87B ''incorrect'':98B ''initi'':104B ''list'':75B ''may'':27B ''move'':11B ''obvious'':84B ''onto'':13B ''partner'':37B ''place'':101B ''process'':5B ''queri'':58B,110B ''question'':19B,100B,106B ''questionnair'':15B,92B ''relat'':7B ''respond'':93B ''respons'':64B,79B ''return'':89B ''screen'':73B ''see'':67B,82B ''sinc'':45B ''speak'':34B ''spous'':39B ''submit'':57B,62B,109B ''text'':2A ''text-cont'':1A ''togeth'':44B', '7e0859bd-52d4-483b-af58-0225f3b02b83', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2460, 'SINGLE_ANSWER', 'Have you ever taken fertility drugs?', 1774, 'Fertility Drugs', 11, '', true, NULL, '82f9a68b-a0d6-4dfa-b3d9-03c7faa40db0', '5a013066-5b10-3a25-acc9-6c8747612c38', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3239, 'SINGLE_ANSWER', 'On the last weekend, how often were you very active (for example: playing sports, exercise classes, strenuous occupational activity, strenuous household or child rearing tasks)? (Check one only.) ', 3037, 'Physical activity', 2, '', true, '''1'':32C ''2'':36C ''3'':38C ''4'':42C ''5'':44C ''6'':48C ''7'':50C ''activ'':2A,12B,21B ''check'':28B ''child'':25B ''class'':18B ''exampl'':14B ''exercis'':17B ''household'':23B ''last'':5B,34C,40C,46C,52C ''none'':30C,31C ''occup'':20B ''often'':8B ''one'':29B ''physic'':1A ''play'':15B ''rear'':26B ''sport'':16B ''strenuous'':19B,22B ''task'':27B ''time'':33C,39C,45C,51C ''week'':35C,41C,47C,53C ''weekend'':6B', '299caff5-67b2-479c-9214-841a8f3befe6', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58707, 'SINGLE_ANSWER', 'Did your physician use the term "inflammatory breast cancer" to describe your cancer?', 58200, 'Inflammatory Status', 9, '<b>Question : Did your physician use the term "inflammatory breast cancer" to describe your cancer?</b><br/> 
<br/><b>What does this mean :</b> A rare form of breast cancer in which breast cancer cells block the lymph vessels in the skin of the breast. 

 
', true, '''block'':45C ''breast'':10B,24C,38C,42C,54C ''cancer'':11B,15B,25C,29C,39C,43C ''cell'':44C ''d'':65C ''describ'':13B,27C ''form'':36C ''inflammatori'':1A,9B,23C ''know/i'':60C ''lymph'':47C ''mean'':33C ''physician'':5B,19C ''question'':16C ''rare'':35C ''rather'':66C ''rememb'':63C ''say'':68C ''skin'':51C ''status'':2A ''term'':8B,22C ''use'':6B,20C ''vessel'':48C ''yes'':55C,56C', '5dd3acbe-1bf0-369e-b303-ab78d17e3cd8', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2462, 'SINGLE_ANSWER', 'How many full-term pregnancies have you had? ', 1774, 'no of preg.', 12, '', true, NULL, 'ea1b4b99-9d5e-47fe-a41b-f3b3b3b7702d', '9ab1cba1-3657-3a53-9742-581a155edb1f', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3315, 'SINGLE_ANSWER', 'On the last weekend, how often were you very active (for example: playing sports, exercise classes, strenuous occupational activity, strenuous household or child rearing tasks)? (Check one only.) ', 3037, 'Physical activity', 8, '', true, NULL, '29bfcf70-30ee-4646-96a3-77a619f72b5d', '299caff5-67b2-479c-9214-841a8f3befe6', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3349, 'SINGLE_ANSWER_TABLE', '1.Physical activity in your spare time: Have you done any of the following activities in the past 7 days (last week)?  If yes, how many times? (Mark only one circle per row.) ', 3325, 'Daily activity', 5, '', true, '''-2'':39C,49C,59C,74C,86C,98C ''-4'':41C,51C,61C,76C,88C,100C ''-6'':43C,53C,63C,78C,90C,102C ''1'':37,38C,48C,58C,73C,85C,97C ''1.physical'':3B ''2'':47 ''3'':40C,50C,57,60C,75C,87C,99C ''4'':72 ''5'':42C,52C,62C,77C,84,89C,101C ''6'':96 ''7'':20B,44C,54C,64C,79C,91C,103C ''activ'':2A,4B,16B ''circl'':32B ''climb'':36C ''climber'':67C ''daili'':1A ''day'':21B ''done'':11B ''equip'':71C ''exercis'':83C ''follow'':15B ''heavi'':93C ''last'':22B ''mani'':27B ''mark'':29B ''one'':31B ''past'':19B ''per'':33B ''rock'':35C ''row'':34B ''rowing/canoeing'':46C ''similar'':70C ''spare'':7B ''stair'':66C ''tennis/squash'':56C ''time'':8B,28B,45C,55C,65C,80C,92C,104C ''walk'':81C ''week'':23B ''work'':95C ''yard'':94C ''yes'':25B', '17c229db-4bb2-42d9-82a5-11d0a17eb79b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58708, 'SINGLE_ANSWER', 'Was your tumor positive for estrogen receptors (ER positive)? ', 58200, 'estrogen receptors status', 10, '<b>Question : Was your tumor positive for estrogen receptors (ER positive)? </b><br/>
<br/><b>What does this mean :</b> Estrogen is a hormone produced primarily by the ovaries before menopause. Some breast tumors have proteins on their cells that bind to estrogen. These proteins are called estrogen receptors. Breast cancer cells that grow in response to estrogen are referred to as estrogen receptor positive or ER positive (ER+). Breast cancer cells that are not stimulated by estrogen are referred to as estrogen receptor negative or ER negative (ER-). ER+ and/or PR+ cancers are more likely to respond to hormonal therapy. <br/>

 
<br/><b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking  
', true, '''although'':114C ''and/or'':97C ''ask'':142C ''bind'':47C ''breast'':39C,56C,76C ''call'':53C ''cancer'':57C,77C,99C ''cell'':45C,58C,78C ''complet'':128C ''d'':155C ''er'':11B,21C,73C,75C,93C,95C,96C ''estrogen'':1A,9B,19C,27C,49C,54C,64C,69C,84C,89C ''find'':111C ''found'':135C ''grow'':60C ''hormon'':30C,106C ''inform'':113C,123C,132C ''know/i'':150C ''like'':102C ''mean'':26C ''menopaus'':37C ''negat'':91C,94C ''obtain'':121C ''ovari'':35C ''patholog'':138C ''posit'':7B,12B,17C,22C,71C,74C ''pr'':98C ''primarili'':32C ''produc'':31C ''protein'':42C,51C ''purpos'':126C ''question'':13C ''rather'':156C ''receptor'':2A,10B,20C,55C,70C,90C ''refer'':66C,86C ''rememb'':153C ''report'':139C ''requir'':118C ''respond'':104C ''respons'':62C ''say'':158C ''status'':3A ''stimul'':82C ''survey'':130C ''test'':146C ''therapi'':107C ''tumor'':6B,16C,40C ''yes'':143C,144C', '55cf47a1-2b15-3518-80f8-71e4a6c34f89', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1547, 'CONTENT', 'Thank You for helping with this major health issue. 
<br/>
<br/>
<u>What are we doing?</u> The following questionnaire was developed by medical anthropologists examining the lifestyle causes of breast cancer and lymphedema.  We are gathering preliminary data to determine if further research with other breast cancer survivors is warranted.
<br/>
<br/>
<u>Who may participate in the questionnaire?</u>  We are seeking real information and experiences from women who have had breast cancer.  If you are currently in treatment for breast cancer, or if you have completed your therapy and treatment, your experiences will be very helpful to us.
<br/>
<br/>
 


', 1464, 'TEXT-CONTENT', 1, NULL, false, '''anthropologist'':24B ''breast'':30B,46B,69B,78B ''cancer'':31B,47B,70B,79B ''caus'':28B ''complet'':84B ''content'':3A ''current'':74B ''data'':38B ''determin'':40B ''develop'':21B ''examin'':25B ''experi'':63B,90B ''follow'':18B ''gather'':36B ''health'':11B ''help'':7B,94B ''inform'':61B ''issu'':12B ''lifestyl'':27B ''lymphedema'':33B ''major'':10B ''may'':52B ''medic'':23B ''particip'':53B ''preliminari'':37B ''questionnair'':19B,56B ''real'':60B ''research'':43B ''seek'':59B ''survivor'':48B ''text'':2A ''text-cont'':1A ''thank'':4B ''therapi'':86B ''treatment'':76B,88B ''us'':96B ''warrant'':50B ''women'':65B', '6fc7a883-82fa-47f8-8f28-c1feaad32964', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3058, 'CONTENT', 'Your participation in this study is completely voluntary. It is very important for us to learn your opinions.

Your survey responses and information will be kept strictly confidential.
</br> </br>Thank you very much for your time and support. Please start  <with the survey now by scrolling down.</br> </br>

', 3038, 'TEXT-CONTENT', 1, NULL, false, '''complet'':10B ''confidenti'':31B ''content'':3A ''import'':15B ''inform'':26B ''kept'':29B ''learn'':19B ''much'':35B ''opinion'':21B ''particip'':5B ''pleas'':41B ''respons'':24B ''scroll'':48B ''start'':42B ''strict'':30B ''studi'':8B ''support'':40B ''survey'':23B,45B ''text'':2A ''text-cont'':1A ''thank'':32B ''time'':38B ''us'':17B ''voluntari'':11B', '905b7166-9434-4d6b-8c2e-a97f791a7d5a', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2463, 'SINGLE_ANSWER', 'Have you ever had a surgery to remove part of an ovary or both ovaries?', 1774, 'ovarien surgery', 13, '', true, '''d'':84C ''ever'':5B ''know/i'':79C ''never'':65C ''one'':47C ''ovari'':14B,17B,28C,39C,48C,52C,61C,75C ''ovarien'':1A ''part'':11B,25C,36C,72C ''rather'':85C ''rememb'':82C ''remov'':10B,24C,35C,46C,59C,70C ''say'':87C ''surgeri'':2A,8B,22C,33C,44C,57C,68C ''yes'':18C,29C,40C,53C', 'f9b02281-1bd4-4c0c-b65c-81a87e05df99', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58721, 'SINGLE_ANSWER', 'Have you ever taken birth control pills (oral contraceptives) for one month or longer? ', 57303, 'Taken Oral Contraceptives', 6, '', true, '''birth'':8B,21C,30C,41C ''contracept'':3A,12B ''control'':9B,22C,31C,42C ''current'':39C ''d'':52C ''ever'':6B ''know/i'':47C ''longer'':17B ''month'':15B ''one'':14B ''oral'':2A,11B ''past'':26C,35C ''pill'':10B,23C,32C,43C ''rather'':53C ''rememb'':50C ''say'':55C ''taken'':1A,7B ''use'':20C,29C,40C ''yes'':18C,27C,36C', '82f5fedd-a89f-30d4-844c-57c60202917b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (58722, 'SINGLE_ANSWER', 'How many years in TOTAL have you used birth control pills?', 57303, 'Total years', 5, '', true, '''-14'':32C ''-2'':23C ''-4'':26C ''-9'':29C ''1'':16C,20C,22C ''10'':31C ''15'':34C ''3'':25C ''5'':28C ''birth'':11B ''control'':12B ''know/i'':39C ''less'':14C,18C ''mani'':4B ''pill'':13B ''rememb'':42C ''total'':1A,7B ''use'':10B ''year'':2A,5B,17C,21C,24C,27C,30C,33C,35C', 'a928e1df-c174-3c0a-b40a-83b6ae54fe0b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2147, 'MULTI_ANSWER', 'My favorite toppings are:', 1825, 'Toppings', 6, '', true, '''butterscotch'':10C ''chocol'':6C,8C ''cream'':18C ''eat'':16C ''favorit'':3B ''hot'':5C,7C ''ice'':17C ''marshmallow'':9C ''nut'':11C ''top'':1A,4B,13C,21C ''usual'':15C ''without'':19C', 'e9388445-3eed-42a8-ae47-f84506ed81a4', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3319, 'SINGLE_ANSWER', 'When were you first diagnosed with breast cancer?', 3074, 'Date', 4, '', true, NULL, '92ce638c-1ed5-4f74-aaa4-e3fa112d706f', 'fe8185f4-7f2d-3b59-8472-863807b1662d', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3146, 'SINGLE_ANSWER', 'How many times do you exercise in a week?', 57304, 'exercise', 36, 'This question refers to how many times a week do you engage in physical activity', true, '''-2'':27C,32C ''-3'':37C ''-4'':42C ''1'':26C,31C ''2'':36C ''3'':41C ''4'':48C ''activ'':25C ''engag'':22C ''exercis'':1A,7B,54C ''mani'':3B,16C ''per'':29C,34C,39C,44C,50C ''physic'':24C ''question'':12C ''refer'':13C ''time'':4B,17C,28C,33C,38C,43C,49C ''week'':10B,19C,30C,35C,40C,45C,51C', '40670292-068a-4b09-9863-96a534df912a', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2724, 'MULTI_ANSWER', 'What was the cause of your infertility?', 58200, 'Infertility Etiology Type', 20, 'Text reason for infertility. [Manually-curated]', false, NULL, '4477DC16-D1A0-6A27-E044-0003BA3F9857', '2725004', 'CA_DSR', 2725004);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2648, 'SINGLE_ANSWER', 'Have you ever been told by a doctor or other health professional that you have diabetes or sugar diabetes? (SELECT ONE)', 2534, 'ever have a diabetes', 4, '', true, '''diabet'':4A,20B,23B ''doctor'':12B ''ever'':1A,7B ''health'':15B ''one'':25B ''profession'':16B ''select'':24B ''sugar'':22B ''told'':9B ''yes'':26C,27C', '5197b77f-e364-4130-8d89-fdf07b4c6764', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3059, 'SINGLE_ANSWER', 'Do you buy ice creams?', 3038, 'buy ice creams', 2, '', false, '''buy'':1A,6B ''cream'':3A,8B ''ice'':2A,7B ''yes'':9C,10C', '36680fea-faae-4f9f-a970-1268e86da607', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2647, 'CONTENT', 'The care of people with diabetes is an important concern of the U.S. Department of Health and Human Services. Please take a few minutes to answer the following questions on the care you received for your diabetes. Your participation is voluntary and all of your answers will be kept confidential.
<br/>
<br/>', 2534, 'TEXT-CONTENT', 1, NULL, false, '''answer'':29B,49B ''care'':5B,35B ''concern'':13B ''confidenti'':53B ''content'':3A ''depart'':17B ''diabet'':9B,40B ''follow'':31B ''health'':19B ''human'':21B ''import'':12B ''kept'':52B ''minut'':27B ''particip'':42B ''peopl'':7B ''pleas'':23B ''question'':32B ''receiv'':37B ''servic'':22B ''take'':24B ''text'':2A ''text-cont'':1A ''u.s'':16B ''voluntari'':44B', '0b1202ec-2577-457b-a4a4-7746a3584740', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3085, 'SINGLE_ANSWER', 'test mm-yyyy', 3074, 'sdfsdfsd', 3, '', true, '''enter'':6C,7C ''mm'':4B ''mm-yyyy'':3B ''sdfsdfsd'':1A ''test'':2B ''yyyi'':5B', '51bcd076-b806-4902-a302-5d4b42afa2d1', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2685, 'MULTI_ANSWER', 'Skip test for radio button', 1774, '', 15, '', false, '''button'':5B ''radio'':4B ''retest'':9C ''skip'':1B ''test'':2B,6C,7C,8C', '6a0ee397-2a4b-4d76-a1da-d4fa857bc97a', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3149, 'CONTENT', 'This is where you will enter text that will be displayed on the screen', 57304, 'TEXT-CONTENT', 37, NULL, false, '''content'':3A ''display'':14B ''enter'':9B ''screen'':17B ''text'':2A,10B ''text-cont'':1A', '94a345dc-ecfb-455b-93bc-f897256f3ef6', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3322, 'SINGLE_ANSWER', 'Have you ever been told by a doctor that you have heart disease, such as heartattack, angina, abnormal heart rhythm. Please exclude high blood pressure, high blood cholesterol, or heart failure. We a ', 3321, 'Chronic Desea', 1, '', false, '''abnorm'':20B ''angina'':19B ''blood'':26B,29B ''cholesterol'':30B ''chronic'':1A ''desea'':2A ''diseas'':15B ''doctor'':10B ''ever'':5B ''exclud'':24B ''failur'':33B ''heart'':14B,21B,32B ''heartattack'':18B ''high'':25B,28B ''pleas'':23B ''pressur'':27B ''rhythm'':22B ''told'':7B ''yes'':34C,35C', 'ea047cac-e2a5-48b1-aa03-7bf6ae330c03', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2530, 'SINGLE_ANSWER', 'Was cancer found in the lymph nodes of your armpit at diagnosis?', 1465, 'ca in Lymph Nodes', 24, '<b>Question : Was cancer found in the lymph nodes of your armpit at diagnosis?</b>
<br/>
<br/>
 
<b>What does this mean :</b> The axillary lymph nodes are the lymph nodes in your armpit. When breast cancer spreads, these nodes are usually the first place it will go. In the past, surgeons would always dissect and remove the axillary nodes to examine them for signs of cancer. Now most surgeons perform a sentinel node biopsy (see below), and then only further dissect the axillary nodes if cancer cells were found in the sentinel node. If cancer WAS found in your axillary lymph nodes, your breast cancer will have been staged as a II or III. If your lymph nodes were negative (no cancer), your stage could have been 0, I, or II depending on the size of the tumor.
<br/>
<br/>

 
<b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other healthcare professional.
 <br/>
<br/>
 
 
', true, NULL, 'c545b012-5fff-4d3a-8cf3-c84339a39dd8', '721cef08-eb70-30c1-8895-b7c7f361eafa', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3355, 'SINGLE_ANSWER_TABLE', '', 3325, '', 6, '', false, '''a.strenuous'':2C ''beat'':5C ''exercis'':3C ''heart'':4C ''rapid'':6C ''v'':1C', '08d8ae32-368b-46b0-b5a6-8efb02f56d27', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2531, 'SINGLE_ANSWER', 'Did your physician use the term "inflammatory breast cancer" to describe your cancer?', 1465, 'Inflammatory Status', 22, '<b>Question : Did your physician use the term "inflammatory breast cancer" to describe your cancer?</b><br/> 
<br/><b>What does this mean :</b> A rare form of breast cancer in which breast cancer cells block the lymph vessels in the skin of the breast. 

 
', true, NULL, '124debd2-ec4a-49eb-a202-0aed13be37a8', '5dd3acbe-1bf0-369e-b303-ab78d17e3cd8', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3060, 'SINGLE_ANSWER', 'Is it for personal consumption?', 3038, 'personal consumption', 3, '', false, '''consumpt'':2A,7B ''person'':1A,6B ''yes'':8C,9C', '5bc4491b-d42f-4406-945c-9f992ecb931a', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2722, 'SINGLE_ANSWER', 'Have you undertaken any of the following fertility preservation methods? (mark all applicable method)', 58200, 'Fertility Preservation Method Use Name', 21, 'Text term(s) to identify fertility preservation method(s) a person has actually used. [Manually-curated]', false, '''actual'':32C ''agonist'':54C ''applic'':18B,59C ''bank'':39C,42C ''cryopreserv'':47C,49C ''curat'':36C ''embryo'':48C ''fertil'':1A,13B,25C,52C ''follow'':12B ''gnrh'':53C ''identifi'':24C ''lupron'':57C ''manual'':35C ''manually-cur'':34C ''mark'':16B ''method'':3A,15B,19B,27C ''miss'':60C ''name'':5A ''oocyt'':46C ''oophorpexi'':65C ''ovarian'':37C,40C,44C ''person'':30C ''pleas'':62C ''preserv'':2A,14B,26C ''specifi'':63C ''surgic'':43C,64C ''term'':21C ''text'':20C ''tissu'':38C,41C ''transposit'':45C ''undertaken'':8B ''use'':4A,33C ''vitro'':51C', '3FFE11CD-B6DD-086B-E044-0003BA3F9857', NULL, NULL, 2698322);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2658, 'CONTENT', 'This survey is part of the Medical Expenditure Panel Survey, conducted by the U.S. Department of Health and Human Services. This survey
is authorized under Section 902(a) of the Public Health Service Act [42 U.S.C. 299a]. The confidentiality of personal information is protected
by Federal Statutes, Section 924(c) and Section 308(d) of the Public Health Service Act [42 U.S.C. 299c-3(c) and 242m(d)]. This law prohibits
release of personal information outside the public health agencies sponsoring the survey or their contractors without first obtaining
permission from the person who gave the information. The Federal government requires that all persons asked to respond to one of its
surveys be given the following information: Public reporting burden for this collection of information is estimated to average
5 minutes
per interview, the estimated time required to complete the A Survey About Your Diabetes Care. Send comments regarding this burden
estimate or any other aspect of this collection of information, including suggestions for reducing this burden, to:', 2534, 'TEXT-CONTENT', 2, NULL, false, '''-3'':67B ''242m'':70B ''299a'':40B ''299c'':66B ''308'':56B ''42'':38B,64B ''5'':133B ''902'':30B ''924'':52B ''act'':37B,63B ''agenc'':83B ''ask'':108B ''aspect'':159B ''author'':27B ''averag'':132B ''burden'':123B,154B,170B ''c'':53B,68B ''care'':149B ''collect'':126B,162B ''comment'':151B ''complet'':142B ''conduct'':14B ''confidenti'':42B ''content'':3A ''contractor'':89B ''d'':57B,71B ''depart'':18B ''diabet'':148B ''estim'':130B,138B,155B ''expenditur'':11B ''feder'':49B,102B ''first'':91B ''follow'':119B ''gave'':98B ''given'':117B ''govern'':103B ''health'':20B,35B,61B,82B ''human'':22B ''includ'':165B ''inform'':45B,78B,100B,120B,128B,164B ''interview'':136B ''law'':73B ''medic'':10B ''minut'':134B ''obtain'':92B ''one'':112B ''outsid'':79B ''panel'':12B ''part'':7B ''per'':135B ''permiss'':93B ''person'':44B,77B,96B,107B ''prohibit'':74B ''protect'':47B ''public'':34B,60B,81B,121B ''reduc'':168B ''regard'':152B ''releas'':75B ''report'':122B ''requir'':104B,140B ''respond'':110B ''section'':29B,51B,55B ''send'':150B ''servic'':23B,36B,62B ''sponsor'':84B ''statut'':50B ''suggest'':166B ''survey'':5B,13B,25B,86B,115B,145B ''text'':2A ''text-cont'':1A ''time'':139B ''u.s'':17B ''u.s.c'':39B,65B ''without'':90B', '318be1a9-cde1-49f4-a0b1-a01f00bd38d3', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3089, 'MULTI_ANSWER', 'Skip test for radio button', 2512, '', 34, '', false, NULL, '75421c6f-9d6b-47ef-887e-174c453f9859', '6a0ee397-2a4b-4d76-a1da-d4fa857bc97a', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3323, 'MULTI_ANSWER', 'What treatments do you now have for heart disease?', 3321, 'Treatment', 2, '', false, '''asprin'':15C ''diet'':24C ''diseas'':10B ''exercis'':25C ''heart'':9B ''includ'':21C ''medicin'':17C ''pill'':20C ''spray'':23C ''sublingu'':22C ''tablet'':18C ''treatment'':1A,3B,12C,14C', 'cb4b62c0-141b-4ba9-ba66-4b77ef93ced1', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3150, 'SINGLE_ANSWER_TABLE', 'What types of exercise do you engage in?', 57304, 'exerciseperweek', 38, '', true, '''bike'':15C ''engag'':8B ''exercis'':5B ''exerciseperweek'':1A ''run'':11C ''type'':3B ''walk'':9C ''yes'':10C,12C,14C,16C ''yoga'':13C', '5b68914f-7381-4a3c-998c-6248d7494bc5', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3011, 'SINGLE_ANSWER', 'Other infertility preservation treatment', 57304, 'Infertility Treatment Descriptive Text', 32, 'Text to describe an action or administration of therapeutic agents to produce an effect intended to alter a woman''s inability to produce children.', false, NULL, '06F397CB-4A74-08F1-E044-0003BA3F9857', '2436698', 'CA_DSR', 2436698);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3014, 'SINGLE_ANSWER', 'CTC Adverse Event Infertility/sterility Grade', 57304, 'Common Toxicity Criteria Adverse Event Infertility Grade', 33, 'in CTC category Sexual/Reproductive Function, assessment of the severity of an infertility or sterility adverse event using a graded scale.', false, NULL, 'C43DE41E-7857-0BFD-E034-0003BA12F5E7', '2005551', 'CA_DSR', 2005551);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3015, 'SINGLE_ANSWER', 'Questions to assess participant¿s experience with infertility', 57304, 'Person Known Infertility Reason Assessment Description Text', 34, 'Person; a human being._Recognized, familiar, or within the scope of knowledge._The inability to produce children._An explanation of the cause of some phenomenon or action._The final result of a determination of the value, significance, or extent of._A written or verbal account, representation, statement, or explanation of something._The words of something written.', false, NULL, '7EF56612-A047-CC80-E040-BB89AD4343FA', '3007421', 'CA_DSR', 3007421);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2652, 'SINGLE_ANSWER', 'During 2007, how many times did a doctor, nurse, or other health profecional check your blood or sugar diabetes? (SELECT ONE)', 2534, 'check blood  sugar', 6, '<i><b>A1C</b> is a blood test that is primarily done to monitor the glucose level of diabetics. Please note that this is a blood test which has to be done in a lab, hospital,or doctor''s office; this is not a test which you can perform at home.</i>
<BR/>
<br/>', false, '''2007'':5B ''a1c'':25C ''blood'':2A,19B,28C,47C,77C,88C ''check'':1A,17B ''diabet'':22B,40C ''doctor'':11B,59C ''done'':33C,53C ''fill'':79C,90C ''glucos'':37C ''health'':15B ''home'':72C ''hospit'':57C ''lab'':56C ''level'':38C ''mani'':7B ''monitor'':35C ''note'':42C ''number'':81C,92C ''nurs'':12B ''offic'':61C ''one'':24B ''perform'':70C ''pleas'':41C ''primarili'':32C ''profecion'':16B ''select'':23B ''sugar'':3A,21B ''test'':29C,48C,66C,78C,89C ''time'':8B,83C,94C', 'ffd7d07f-94fc-4178-ad33-1680d919a69f', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3063, 'SINGLE_ANSWER', 'My single most favorite brand is:', 3038, 'Favorite Brand', 4, '', true, '''bart'':17C ''ben'':25C ''blue'':23C ''brand'':2A,7B,9C,13C,34C,36C ''breyer'':16C ''bunni'':24C ''cadburi'':20C ''daz'':31C ''dean'':21C ''dreyer'':27C ''favorit'':1A,6B ''grand'':29C ''haagen'':30C ''hershey'':22C ''homemad'':19C ''jerri'':26C ''ok'':11C,15C ''singl'':4B ''store'':33C ''walgreen'':32C', '1d60b6bc-26c2-4833-b9de-485cbe7ea476', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3240, 'SINGLE_ANSWER', 'In the last 7 days during the morning, how often were you very active (for example: playing sports, exercise classes, strenuous occupational activity, strenuous household or child rearing ttasks)? (Ch', 3037, 'morning activity', 3, '', false, '''1'':35C ''2'':39C ''3'':41C ''7'':6B ''activ'':2A,16B,25B ''ch'':32B ''child'':29B ''class'':22B ''day'':7B ''exampl'':18B ''exercis'':21B ''household'':27B ''last'':5B,37C,43C ''morn'':1A,10B ''none'':33C,34C ''occup'':24B ''often'':12B ''play'':19B ''rear'':30B ''sport'':20B ''strenuous'':23B,26B ''time'':36C,42C ''ttask'':31B ''week'':38C,44C', 'ab50c10e-9b74-4711-ad98-0a2f22419301', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (1472, 'SINGLE_ANSWER', '', 1465, '', 4, '', false, '''pleas'':1C,3C ''specifi'':2C,4C', '6044cbc8-ba43-4e88-9fff-ce0c75206bec', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2837, 'SINGLE_ANSWER', 'Are you currently on a special diet?', 57304, 'Special Diet Ind', 30, 'Indicates whether the foods the participant is eating are part of a special diet.', false, NULL, '99BA9DC8-338A-4E69-E034-080020C9C0E0', '5282', 'CA_DSR', 5282);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3326, 'CONTENT', 'We are trying to find out about your level of physical activity from the last 7 days (in the last week).  This includes activities that make you sweat, make your legs feel tired, or make you breathe hard, such as team sports, running, strenuous occupational activities, and others. ', 3325, 'TEXT-CONTENT', 1, NULL, false, '''7'':19B ''activ'':15B,27B,49B ''breath'':40B ''content'':3A ''day'':20B ''feel'':35B ''find'':8B ''hard'':41B ''includ'':26B ''last'':18B,23B ''leg'':34B ''level'':12B ''make'':29B,32B,38B ''occup'':48B ''other'':51B ''physic'':14B ''run'':46B ''sport'':45B ''strenuous'':47B ''sweat'':31B ''team'':44B ''text'':2A ''text-cont'':1A ''tire'':36B ''tri'':6B ''week'':24B', 'b19a509b-b52d-4444-8abc-840e6dbac9a3', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2839, 'SINGLE_ANSWER', 'Normalcy of Diet Rating', 57304, 'RTOG Diet Intake Performance Scale', 31, 'an RTOG assessment of the variety and content of the diet of a cancer patient using a scale. (this is an earlier version of the published validated scale by List, Ritter-Sterr and Lansky.)', false, '''0'':107C ''10'':104C ''100'':45C,50C ''20'':101C ''30'':96C ''40'':84C ''50'':68C ''60'':63C ''70'':60C ''80'':57C ''90'':55C ''appl'':93C ''assess'':12C ''blender'':100C ''bread'':65C ''cancer'':23C ''canned/soft'':74C ''carrot'':61C ''celeri'':62C ''chew'':89C ''chewabl'':70C ''cold'':105C ''content'':17C ''cook'':76C ''cracker'':67C ''diet'':2A,8B,20C,47C,52C ''dri'':64C ''e.g'':72C,90C ''earlier'':31C ''fed'':113C ''feed'':111C ''fish'':78C ''food'':71C,86C,98C ''fruit'':75C ''full'':46C,51C ''hamburg'':79C ''intak'':3A ''lanski'':44C ''liquid'':103C,106C ''list'':39C ''macaroni'':73C ''mash'':91C ''meat'':59C,83C ''non'':109C ''non-or'':108C ''normalci'':6B ''oral'':110C ''patient'':24C ''peanut'':56C ''perform'':4A ''piec'':81C ''potato'':92C ''publish'':35C ''pud'':95C ''pure'':97C ''rate'':9B ''requir'':87C ''restrict'':49C,54C ''ritter'':41C ''ritter-sterr'':40C ''rtog'':1A,11C ''sauc'':94C ''scale'':5A,27C,37C ''small'':80C ''soft'':69C,85C ''sterr'':42C ''tube'':112C ''use'':25C ''valid'':36C ''varieti'':15C ''veget'':77C ''version'':32C ''warm'':102C', 'EF49C2E7-802E-4ACC-E034-0003BA3F9857', NULL, NULL, 2199510);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2970, 'SINGLE_ANSWER', 'Other infertility preservation treatment', 2512, 'Infertility Treatment Descriptive Text', 25, 'Text to describe an action or administration of therapeutic agents to produce an effect intended to alter a woman''s inability to produce children.', false, NULL, '06F397CB-4A74-08F1-E044-0003BA3F9857', '2436698', 'CA_DSR', 2436698);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2974, 'SINGLE_ANSWER', 'CTC Adverse Event Infertility/sterility Grade', 2512, 'Common Toxicity Criteria Adverse Event Infertility Grade', 32, 'in CTC category Sexual/Reproductive Function, assessment of the severity of an infertility or sterility adverse event using a graded scale.', false, NULL, 'C43DE41E-7857-0BFD-E034-0003BA12F5E7', '2005551', 'CA_DSR', 2005551);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3327, 'SINGLE_ANSWER', 'On the last weekend, how often were you very active (for example: playing sports, exercise classes, strenuous occupational activity, strenuous household or child rearing tasks)? (Check one only.) ', 3325, 'Physical activity', 2, '', true, NULL, '54f980cd-861c-4aee-8892-17ec65f9ed98', '299caff5-67b2-479c-9214-841a8f3befe6', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2781, 'SINGLE_ANSWER', 'test with lower case letter', 2512, 'Testing', 30, '', false, '''answer'':7C,8C ''case'':5B ''letter'':6B ''lower'':4B ''test'':1A,2B', '22c2fb90-cfa1-463d-8af3-49c9a1e28d9f', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3330, 'SINGLE_ANSWER', 'Were you sick last week, or did anything prevent you from doing your normal physical activities? (Check one.) ', 3325, 'physical activity', 3, '', true, NULL, '9b5c1065-8355-4285-833e-f9bb1b79754f', '8467cf41-854a-4d2a-aed6-4c6b3b5be795', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3067, 'SINGLE_ANSWER', '', 3038, 'other', 5, '', false, '''pleas'':1C,3C ''specifi'':2C,4C', '612c7450-c50e-4ea9-b2b0-490a29fab907', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2594, 'SINGLE_ANSWER', 'What was the cause of your infertility?', 2512, 'Infertility Etiology Type', 21, 'Text reason for infertility. [Manually-curated]', false, '''caus'':7B ''curat'':17C ''decreas'':20C ''endometriosi'':18C,19C ''etiolog'':2A ''factor'':26C,28C ''infertil'':1A,10B,14C ''male'':25C ''manual'':16C ''manually-cur'':15C ''ovarian'':21C ''ovul'':23C ''problem'':24C ''reason'':12C ''reserv'':22C ''text'':11C ''tubal'':27C ''type'':3A', '4477DC16-D1A0-6A27-E044-0003BA3F9857', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2738, 'MULTI_ANSWER', 'How did your physician describe your cancer on pathology (check all that apply)? ', 2512, 'Cancer Category', 20, '<b>Question : How did your physician describe your cancer at diagnosis?</b> <br/> 
<br/><b>What does this mean :</b> Ductal carcinoma-in-situ (DCIS) consists of abnormal cells that are confined within the milk ducts of the breast. Lobular carcinoma-in-situ (LCIS) consists of abnormal cells that are confined within the lobules of the breast. <br/>

<br/>Invasive ductal carcinoma accounts for about 80% of all breast cancers. Ductal carcinoma arises from cells that line the milk ducts of the breast. These tumors have "invaded" the surrounding breast tissue and, depending upon their stage, may have spread beyond the breast to the lymph nodes or other organs. <br/>

<br/>Invasive lobular carcinoma accounts for about 10%-15% of all breast cancers. Lobular carcinoma arises from cells that produce breast milk. These tumors have "invaded" the surrounding breast tissue and, depending upon their stage, may have spread beyond the breast. <br/>

 
<br/><b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other health care professional.
<br/>
<br/>
 
 
 
', true, '''-15'':126C ''10'':125C ''80'':75C ''abnorm'':38C,58C ''account'':72C,122C ''although'':165C ''appli'':15B ''aris'':82C,133C ''ask'':193C ''beyond'':109C,156C ''breast'':49C,68C,78C,92C,99C,111C,129C,138C,146C,158C ''cancer'':1A,9B,23C,79C,130C ''carcinoma'':32C,52C,71C,81C,121C,132C,211C,216C ''carcinoma-in-situ'':31C,51C ''care'':199C ''categori'':2A ''cell'':39C,59C,84C,135C ''check'':12B ''complet'':179C ''confin'':42C,62C ''consist'':36C,56C ''d'':232C ''dcis'':35C,203C,206C ''depend'':102C,149C ''describ'':7B,21C ''diagnosi'':25C ''duct'':46C,89C ''ductal'':30C,70C,80C,210C ''find'':162C ''found'':186C ''health'':198C ''infiltr'':214C,219C,223C ''inform'':164C,174C,183C ''invad'':96C,143C ''invas'':69C,119C,212C,217C,221C ''know/i'':227C ''lcis'':55C,209C ''line'':86C ''lobul'':65C ''lobular'':50C,120C,131C,215C ''lymph'':114C ''may'':106C,153C ''mean'':29C ''milk'':45C,88C,139C ''node'':115C ''obtain'':172C ''oncologist'':195C ''organ'':118C ''patholog'':11B,189C ''physician'':6B,20C ''produc'':137C ''profession'':200C ''purpos'':177C ''question'':16C ''rather'':233C ''rememb'':230C ''report'':190C ''requir'':169C ''say'':235C ''situ'':34C,54C,202C,205C,208C ''spread'':108C,155C ''stage'':105C,152C ''surround'':98C,145C ''survey'':181C ''tissu'':100C,147C ''tumor'':94C,141C ''upon'':103C,150C ''within'':43C,63C', '76a9b2af-6538-437a-b3fe-85744991ba7c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2141, 'SINGLE_ANSWER', '', 2116, '', 4, '', false, '''test'':1C,2C', '66694eb1-7b0e-4048-9da3-d79540824599', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2528, 'MULTI_ANSWER', 'How did your physician describe your cancer on pathology (check all that apply)? ', 1465, 'Cancer Category', 23, '<b>Question : How did your physician describe your cancer at diagnosis?</b> <br/> 
<br/><b>What does this mean :</b> Ductal carcinoma-in-situ (DCIS) consists of abnormal cells that are confined within the milk ducts of the breast. Lobular carcinoma-in-situ (LCIS) consists of abnormal cells that are confined within the lobules of the breast. <br/>

<br/>Invasive ductal carcinoma accounts for about 80% of all breast cancers. Ductal carcinoma arises from cells that line the milk ducts of the breast. These tumors have "invaded" the surrounding breast tissue and, depending upon their stage, may have spread beyond the breast to the lymph nodes or other organs. <br/>

<br/>Invasive lobular carcinoma accounts for about 10%-15% of all breast cancers. Lobular carcinoma arises from cells that produce breast milk. These tumors have "invaded" the surrounding breast tissue and, depending upon their stage, may have spread beyond the breast. <br/>

 
<br/><b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other health care professional.
<br/>
<br/>
 
 
 
', true, NULL, '29901a05-7f62-483f-8e43-d1a35b99c705', 'db8936df-ba6a-3831-bc25-0a9cf11b1284', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3245, 'SINGLE_ANSWER', 'Were you sick last week, or did anything prevent you from doing your normal physical activities? (Check one.) ', 3037, 'physical activity', 5, '', true, '''activ'':2A,18B ''anyth'':10B ''check'':19B ''last'':6B ''may'':22C ''normal'':16B ''one'':20B ''physic'':1A,17B ''prevent'':11B ''sick'':5B ''week'':7B ''yes'':21C', '8467cf41-854a-4d2a-aed6-4c6b3b5be795', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2782, 'SINGLE_ANSWER', 'Test with Upper Case', 2512, 'Testing', 31, '', false, '''answer'':6C,7C ''case'':5B ''test'':1A,2B ''upper'':4B', '169af4d1-e785-4348-92f1-b2d2c4ec1ca7', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3069, 'SINGLE_ANSWER', ' Please state down the new local ice-cream flavour(s) that are currently not available in the market but you wish to have in the future.', 3038, 'flavor', 6, '', false, '''avail'':17B ''cream'':10B,32C,37C ''current'':15B ''flavor'':1A,33C,38C ''flavour'':11B ''futur'':28B ''ice'':9B,31C,36C ''ice-cream'':8B,30C,35C ''local'':7B,29C,34C ''market'':20B ''new'':6B ''pleas'':2B ''state'':3B ''wish'':23B', '22bbe897-bbbd-4e34-ab2b-829af99ba9d7', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2879, 'SINGLE_ANSWER', 'Normalcy of Diet Rating', 1833, 'RTOG Diet Intake Performance Scale', 11, 'an RTOG assessment of the variety and content of the diet of a cancer patient using a scale. (this is an earlier version of the published validated scale by List, Ritter-Sterr and Lansky.)', false, NULL, 'EF49C2E7-802E-4ACC-E034-0003BA3F9857', '2199510', 'CA_DSR', 2199510);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2609, 'SINGLE_ANSWER', 'Cancer Free?', 2512, 'Cancer free indicator', 24, 'A Yes/ No answer which indicates whether individual is cancer/ malignant disease free.', false, '''answer'':9C ''cancer'':1A,4B,15C ''diseas'':17C ''free'':2A,5B,18C ''indic'':3A,11C ''individu'':13C ''malign'':16C ''unknown'':21C ''whether'':12C ''yes'':7C,19C,20C', 'B80E4449-FCF7-6199-E034-0003BA12F5E7', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2882, 'SINGLE_ANSWER', 'Special Diet Stop Date', 1833, 'Special Diet Stop Date', 12, 'The year and month this diet stops. Use last day of month as default day.', false, NULL, '99BA9DC8-3390-4E69-E034-080020C9C0E0', '5284', 'CA_DSR', 5284);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2610, 'SINGLE_ANSWER', 'If Malignant Disease, was it Lung Cancer', 2512, 'Was death caused by lung cancer ?', 23, 'Yes/ No answer for if death was caused by lung cancer', false, '''answer'':16C ''cancer'':6A,13B,24C ''caus'':3A,21C ''death'':2A,19C ''diseas'':9B ''lung'':5A,12B,23C ''malign'':8B ''unknown'':26C ''yes'':14C,25C', 'B7A8F851-E70F-339B-E034-0003BA12F5E7', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3247, 'SINGLE_ANSWER', '', 3037, '', 6, '', false, '''prevent'':4C,8C ''yes'':2C,6C', '9fefa162-e32a-4b77-9088-c7ad137f5d54', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2875, 'SINGLE_ANSWER', 'A measure to quantify intake from commonly consumed dietary supplements (vitamins, minerals, herbs or other botanicals, or a concentrate, metabolite, constituent, extract, or combination of these ingredients).', 1833, 'Person Dietary Supplements Use Frequency Number', 7, 'Person; a human being._Products in capsule, tablet or liquid form that provide essential nutrients, such as a vitamin, an essential mineral, a protein, an herb, or similar nutritional substance. Nutritional supplements do not require FDA approval to be marketed. (NCI)_Use; put into service; make work or employ (something) for a particular purpose or for its inherent or natural purpose._The number of occurrences of something within a given time period. (NCI)_Number', false, NULL, '74A93321-F644-A17B-E040-BB89AD437426', '2947016', 'CA_DSR', 2947016);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2876, 'SINGLE_ANSWER', 'Date regular diet started', 1833, 'Diet Restart Date', 8, 'the date related to the regular course of eating and drinking adopted by a person or animal to begin anew.', false, NULL, '635FC5CC-4792-7F36-E040-BB89AD43799A', '2840110', 'CA_DSR', 2840110);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2884, 'SINGLE_ANSWER', 'If the foods you currently are eating are part of a special diet, please indicate the start and stop dates.', 1833, 'Special Diet Start Date', 13, 'The year and month this diet started. Use first day of month as default.', false, NULL, '99BA9DC8-338D-4E69-E034-080020C9C0E0', '5283', 'CA_DSR', 5283);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2877, 'SINGLE_ANSWER', 'Has your diet been unsatisfactory because of problems with your dental treatment', 1833, 'Dental Therapy Patient Diet Dissatisfaction Oral Health Impact Profile Physical Examination Scale', 9, 'a scaled index of the social impact of oral disorders which draws on a theoretical heirarchy of  oral health outcomes (Oral Health Impact Profile) for a measure of a person''s perceptions of the social impact of oral disorders on their well-being, of a patient''s lack of satisfaction in the things a person eats and drinks from dental treatment.', false, NULL, '4059790C-679D-4705-E044-0003BA3F9857', '2704935', 'CA_DSR', 2704935);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3110, 'SINGLE_ANSWER', 'Import question test', 2512, '', 36, '', false, '''1'':5C,7C ''2'':9C ''3'':11C ''import'':1B ''question'':2B ''test'':3B,4C,6C,8C,10C', '6690c939-f4d4-411c-9a22-7ec74733c21e', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2878, 'SINGLE_ANSWER', 'Other diet', 1833, 'Weight Diet History Questionnaire Descriptive Text', 10, 'Text to describe a diet that is beyond the list of choices captured in a questionnaire.', false, NULL, '2D477905-EAEA-2F7A-E044-0003BA3F9857', '2624168', 'CA_DSR', 2624168);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3157, 'SINGLE_ANSWER', 'My single most favorite brand is:', 2512, 'Favorite Brand', 39, '', true, NULL, '1d34ee39-3946-4f96-9ed9-663bf750d664', '7dd2bd05-c4fc-4acb-9032-62d5c59cc61d', 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (69246, 'SINGLE_ANSWER', 'What was your age when you were first diagnosed with cancer?', 58200, 'age', 5, '', true, '''100'':99C,100C ''20'':19C ''21'':20C ''22'':21C ''23'':22C ''24'':23C ''25'':24C ''26'':25C ''27'':26C ''28'':27C ''29'':28C ''30'':29C ''31'':30C ''32'':31C ''33'':32C ''34'':33C ''35'':34C ''36'':35C ''37'':36C ''38'':37C ''39'':38C ''40'':39C ''41'':40C ''42'':41C ''43'':42C ''44'':43C ''45'':44C ''46'':45C ''47'':46C ''48'':47C ''49'':48C ''50'':49C ''51'':50C ''52'':51C ''53'':52C ''54'':53C ''55'':54C ''56'':55C ''57'':56C ''58'':57C ''59'':58C ''60'':59C ''61'':60C ''62'':61C ''63'':62C ''64'':63C ''65'':64C ''66'':65C ''67'':66C ''68'':67C ''69'':68C ''70'':69C ''71'':70C ''72'':71C ''73'':72C ''74'':73C ''75'':74C ''76'':75C ''77'':76C ''78'':77C ''79'':78C ''80'':79C ''81'':80C ''82'':81C ''83'':82C ''84'':83C ''85'':84C ''86'':85C ''87'':86C ''88'':87C ''89'':88C ''90'':89C ''91'':90C ''92'':91C ''93'':92C ''94'':93C ''95'':94C ''96'':95C ''97'':96C ''98'':97C ''99'':98C ''age'':1A,5B,13C,16C ''cancer'':12B ''diagnos'':10B ''diagnosi'':15C,18C ''first'':9B', '866f0d97-cdb5-327c-9e47-d6370135dc69', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3331, 'SINGLE_ANSWER', '6.Which one of the following describes you best for the last 7 days?  Read all five statements before deciding on the one answer that describes you. ', 3325, 'Activity', 4, '', false, '''-2'':30C,54C ''-4'':94C ''-5'':109C ''1'':29C,53C ''3'':93C ''4'':108C ''6.which'':2B ''7'':13B,123C ''activ'':1A ''aerob'':50C,74C ''answer'':24B ''best'':9B ''bike'':47C,71C ''day'':14B ''decid'':20B ''describ'':7B,26B ''e.g'':41C,65C ''effort'':90C ''five'':17B ''follow'':6B ''free'':39C,63C,80C,103C,118C,134C ''involv'':87C ''last'':12B,32C,56C,96C,111C,127C ''littl'':88C ''often'':92C,107C,122C ''one'':3B,23B ''physic'':35C,59C,89C,99C,114C,130C ''play'':42C,66C ''quit'':106C ''read'':15B ''ride'':48C,72C ''run'':45C,69C ''sometim'':28C,52C ''spent'':83C ''sport'':43C,67C ''statement'':18B ''swim'':46C,70C ''thing'':36C,60C,85C,100C,115C,131C ''time'':31C,40C,55C,64C,81C,95C,104C,110C,119C,126C,135C ''week'':33C,57C,97C,112C,128C ''went'':44C,68C', 'a7112e81-906a-4d21-b130-cbc7c0d4271c', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57816, 'CONTENT', 'Please note we will be asking more detailed questions related to this topic in future modules .
 
', 57304, 'TEXT-CONTENT', 1, NULL, false, '''ask'':9B ''content'':3A ''detail'':11B ''futur'':18B ''modul'':19B ''note'':5B ''pleas'':4B ''question'':12B ''relat'':13B ''text'':2A ''text-cont'':1A ''topic'':16B', 'b871cdf3-de8e-36f8-a92e-011c715864b4', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (57817, 'SINGLE_ANSWER', 'Compared to a year ago, how would you rate your health, in general now? (Select only one.)', 57304, 'Health ', 2, '', true, '''ago'':6B,24C,30C,37C,44C,50C ''better'':20C,26C,32C ''compar'':2B ''d'':52C ''general'':14B ''health'':1A,12B ''much'':19C,25C,45C ''one'':18B,35C ''rate'':10B ''rather'':53C ''say'':55C ''select'':16B ''somewhat'':31C,38C ''wors'':39C,46C ''would'':8B ''year'':5B,23C,29C,36C,43C,49C', '7e60b462-bc7c-3730-bf93-d39102be2142', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2753, 'SINGLE_ANSWER', 'Have you ever been treated for infertility?', 2512, 'Infertility Treatment Indicator', 26, 'Text indicator to represent an action or administration of therapeutic agents to produce an effect that is intended to alter a woman''s inability to produce children.', false, '''action'':16C ''administr'':18C ''agent'':21C ''alter'':30C ''children'':37C ''effect'':25C ''ever'':6B ''inabl'':34C ''indic'':3A,12C ''infertil'':1A,10B ''intend'':28C ''produc'':23C,36C ''repres'':14C ''text'':11C ''therapeut'':20C ''treat'':8B ''treatment'':2A ''woman'':32C ''yes'':38C', '06F397CB-47A3-08F1-E044-0003BA3F9857', NULL, NULL, 2436696);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2756, 'MULTI_ANSWER', 'Which fertility preservation methods have you considered using? (mark all that apply)', 2512, 'Preservation Fertility Method Name', 27, 'Text term(s) to identify fertility preservation method(s) a person has considered using. [Manually-curated]', false, '''agonist'':51C ''appli'':16B ''applic'':56C ''bank'':42C ''consid'':11B,29C ''cryopreserv'':47C,49C ''curat'':33C ''embryo'':48C ''fertil'':2A,6B,22C,36C,39C ''gnrh'':50C ''identifi'':21C ''lupron'':54C ''manual'':32C ''manually-cur'':31C ''mark'':13B ''method'':3A,8B,24C ''miss'':59C ''name'':4A ''oocyt'':46C ''oophorpexi'':58C ''ovarian'':40C,44C ''person'':27C ''pleas'':61C ''preserv'':1A,7B,23C ''specifi'':62C ''surgic'':43C,57C ''term'':18C ''text'':17C ''tissu'':41C ''transposit'':45C ''use'':12B,30C ''vitro'':35C,38C', '3FFCB53E-87FC-716A-E044-0003BA3F9857', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3111, 'SINGLE_ANSWER_TABLE', 'test import table question', 2512, '', 37, '', false, '''1'':6C,16C,18C,27C ''2'':7C,12C,19C,28C ''3'':8C,13C,20C,24C ''4'':9C,14C,21C,25C ''5'':10C,15C,22C,26C ''aaa'':5C ''ddd'':17C ''fff'':23C ''import'':2B ''question'':4B ''sss'':11C ''tabl'':3B ''test'':1B', '802fca75-e806-4759-ada2-1e4a780cd7b3', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3162, 'SINGLE_ANSWER', 'New Date Question', 1464, '', 9, '', false, '''date'':2B,4C,5C ''new'':1B ''question'':3B', 'f0562009-1735-4dda-ab85-f5f022262eea', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3334, 'CONTENT', 'Fitness and exercise survey that''s quick, easy to fill and will help us provide you with a better service.
<br/>
You want the very best information, tips and advice, right? On things like:
<ul>
<li>Exercise</li>
<li>Fitness</li>
<li>Diet</li>
<li>Injury</li>
<li>Equipment</li>
</UL>
The best part is that you don''t even need to supply your name or email address. Simply scroll down and fill in the survey and that''s it, you''re done. <br/><br/>

We''ve put your responses into action.
<br/>
<br/>

', 3333, 'TEXT-CONTENT', 1, NULL, false, '''action'':80B ''address'':58B ''advic'':32B ''best'':28B,43B ''better'':22B ''content'':3A ''diet'':39B ''done'':73B ''easi'':11B ''email'':57B ''equip'':41B ''even'':50B ''exercis'':6B,37B ''fill'':13B,63B ''fit'':4B,38B ''help'':16B ''inform'':29B ''injuri'':40B ''like'':36B ''name'':55B ''need'':51B ''part'':44B ''provid'':18B ''put'':76B ''quick'':10B ''re'':72B ''respons'':78B ''right'':33B ''scroll'':60B ''servic'':23B ''simpli'':59B ''suppli'':53B ''survey'':7B,66B ''text'':2A ''text-cont'':1A ''thing'':35B ''tip'':30B ''us'':17B ''ve'':75B ''want'':25B', 'b394d450-37a3-4aa1-801a-e4c775db7b1b', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3090, 'SINGLE_ANSWER', 'test question', 2512, '', 35, 'This survey is strictly confidential and voluntary. All of your responses to this survey will only be reported as a summary in combination with the responses from other website users. Your name, address, and email address will be separated from survey responses and will not be identified in project files or in reports. None of the information will be used or released in any way that would identify you. If there are any questions which you do not wish to answer, please feel free to skip them. Completing this survey will benefit both the Breast Cancer Answers Project in evaluating this website and the many breast cancer survivors who rely on the Internet for health information. Breast Cancer Answers staff will use the survey results to improve continually the quality of the treatment and support information provided on the website.<br/><br/>', false, '''address'':35C,38C ''answer'':83C,99C,121C ''benefit'':94C ''breast'':97C,108C,119C ''cancer'':98C,109C,120C ''combin'':25C ''complet'':90C ''confidenti'':7C ''continu'':130C ''email'':37C ''evalu'':102C ''feel'':85C ''file'':52C ''free'':86C ''health'':117C ''identifi'':49C,70C ''improv'':129C ''inform'':59C,118C,138C ''internet'':115C ''mani'':107C ''name'':34C ''none'':56C ''pleas'':84C ''project'':51C,100C ''provid'':139C ''qualiti'':132C ''question'':2B,76C ''releas'':64C ''reli'':112C ''report'':20C,55C ''respons'':13C,28C,44C ''result'':127C ''separ'':41C ''skip'':88C ''staff'':122C ''strict'':6C ''summari'':23C ''support'':137C ''survey'':4C,16C,43C,92C,126C ''survivor'':110C ''test'':1B,143C,144C ''treatment'':135C ''use'':62C,124C ''user'':32C ''voluntari'':9C ''way'':67C ''websit'':31C,104C,142C ''wish'':81C ''would'':69C', '22d19e54-b7d4-43e6-b3db-315884d1cdf0', NULL, 'LOCAL', NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (2433, 'SINGLE_ANSWER', 'How many lymph nodes were positive for cancer?', 1774, 'Lymph nodes', 4, '<b>Question : How did your physician describe your cancer at diagnosis?</b> <br/> 
<br/><b>What does this mean :</b> Ductal carcinoma-in-situ (DCIS) consists of abnormal cells that are confined within the milk ducts of the breast. Lobular carcinoma-in-situ (LCIS) consists of abnormal cells that are confined within the lobules of the breast. <br/>

<br/>Invasive ductal carcinoma accounts for about 80% of all breast cancers. Ductal carcinoma arises from cells that line the milk ducts of the breast. These tumors have "invaded" the surrounding breast tissue and, depending upon their stage, may have spread beyond the breast to the lymph nodes or other organs. <br/>

<br/>Invasive lobular carcinoma accounts for about 10%-15% of all breast cancers. Lobular carcinoma arises from cells that produce breast milk. These tumors have "invaded" the surrounding breast tissue and, depending upon their stage, may have spread beyond the breast. <br/>

 
<br/><b>How can you find this information :</b> Although it is not required that you obtain this information for the purposes of completing this survey, this information can be found on your pathology report or by asking your oncologist or other health care professional.
<br/>
<br/>', true, '''-15'':121C ''10'':120C ''80'':70C ''abnorm'':33C,53C ''account'':67C,117C ''although'':160C ''aris'':77C,128C ''ask'':188C ''beyond'':104C,151C ''breast'':44C,63C,73C,87C,94C,106C,124C,133C,141C,153C ''cancer'':10B,18C,74C,125C ''carcinoma'':27C,47C,66C,76C,116C,127C ''carcinoma-in-situ'':26C,46C ''care'':194C ''cell'':34C,54C,79C,130C ''complet'':174C ''confin'':37C,57C ''consist'':31C,51C ''dcis'':30C ''depend'':97C,144C ''describ'':16C ''diagnosi'':20C ''duct'':41C,84C ''ductal'':25C,65C,75C ''find'':157C ''found'':181C ''health'':193C ''inform'':159C,169C,178C ''invad'':91C,138C ''invas'':64C,114C ''lcis'':50C ''line'':81C ''lobul'':60C ''lobular'':45C,115C,126C ''lymph'':1A,5B,109C ''mani'':4B ''may'':101C,148C ''mean'':24C ''milk'':40C,83C,134C ''node'':2A,6B,110C,196C,199C ''obtain'':167C ''oncologist'':190C ''organ'':113C ''patholog'':184C ''physician'':15C ''posit'':8B,198C,201C ''produc'':132C ''profession'':195C ''purpos'':172C ''question'':11C ''report'':185C ''requir'':164C ''situ'':29C,49C ''spread'':103C,150C ''stage'':100C,147C ''surround'':93C,140C ''survey'':176C ''tissu'':95C,142C ''tumor'':89C,136C ''upon'':98C,145C ''within'':38C,58C', '8779e60a-1be3-4cf8-91cb-e4462e8ebda9', NULL, NULL, NULL);
INSERT INTO question (id, type, description, form_id, short_name, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id) VALUES (3335, 'SINGLE_ANSWER', 'Are you male or female?', 3333, 'Sex', 2, '', false, '''femal'':6B,9C ''male'':4B,7C,8C ''sex'':1A', '332e7a68-7d51-4010-a06f-729d30426f37', NULL, NULL, NULL);


--
-- TOC entry 2049 (class 0 OID 25024)
-- Dependencies: 1718
-- Data for Name: question_categries; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58728);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 57805);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58714);
INSERT INTO question_categries (category_id, question_id) VALUES (55751, 58716);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58717);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58718);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 57806);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2493);
INSERT INTO question_categries (category_id, question_id) VALUES (60003, 59867);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 60840);
INSERT INTO question_categries (category_id, question_id) VALUES (60000, 59860);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 60841);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 60842);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 60846);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 60845);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 62250);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 57822);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 60848);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 60847);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 60849);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 57365);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58723);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58724);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 2433);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 57815);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 69224);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 2463);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69230);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69236);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 69225);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58725);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69234);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58726);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58729);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 69227);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69232);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58731);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58733);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58734);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69233);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58735);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58741);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69231);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58743);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58746);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58745);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58744);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58742);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69237);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69238);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 69243);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69240);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 2466);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1468);
INSERT INTO question_categries (category_id, question_id) VALUES (58051, 57817);
INSERT INTO question_categries (category_id, question_id) VALUES (58051, 69245);
INSERT INTO question_categries (category_id, question_id) VALUES (60000, 59858);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58711);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58712);
INSERT INTO question_categries (category_id, question_id) VALUES (60001, 59861);
INSERT INTO question_categries (category_id, question_id) VALUES (55751, 59856);
INSERT INTO question_categries (category_id, question_id) VALUES (58051, 59863);
INSERT INTO question_categries (category_id, question_id) VALUES (58051, 59864);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69241);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69242);
INSERT INTO question_categries (category_id, question_id) VALUES (58051, 59865);
INSERT INTO question_categries (category_id, question_id) VALUES (60003, 59866);
INSERT INTO question_categries (category_id, question_id) VALUES (60003, 59868);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 59869);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58710);
INSERT INTO question_categries (category_id, question_id) VALUES (60002, 59862);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58253);
INSERT INTO question_categries (category_id, question_id) VALUES (55751, 59857);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 69229);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1485);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2140);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1474);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 58259);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2385);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2221);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1515);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1516);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1518);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1520);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 57814);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2236);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1527);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1534);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1535);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1536);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1543);
INSERT INTO question_categries (category_id, question_id) VALUES (69452, 1545);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 57812);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 57807);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 57808);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1764);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 57813);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1524);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1766);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1769);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1771);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1762);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2401);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2399);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2323);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 1901);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2404);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1525);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58706);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58707);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2189);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58721);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2186);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 58727);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 2451);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2332);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 2458);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 2460);
INSERT INTO question_categries (category_id, question_id) VALUES (59250, 2462);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2437);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 2437);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 2528);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 2531);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 2738);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3059);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3060);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3063);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3067);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3069);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2439);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 2439);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 2435);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3089);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3111);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3110);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3146);
INSERT INTO question_categries (category_id, question_id) VALUES (6296, 3146);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2222);
INSERT INTO question_categries (category_id, question_id) VALUES (58051, 2648);
INSERT INTO question_categries (category_id, question_id) VALUES (58050, 1533);
INSERT INTO question_categries (category_id, question_id) VALUES (2940, 1472);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3157);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3204);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3205);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3208);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3209);
INSERT INTO question_categries (category_id, question_id) VALUES (60000, 59859);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3216);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2147);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3239);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3240);
INSERT INTO question_categries (category_id, question_id) VALUES (58051, 2652);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 69246);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 2685);
INSERT INTO question_categries (category_id, question_id) VALUES (55750, 3243);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3315);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3247);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3245);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 3319);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58251);
INSERT INTO question_categries (category_id, question_id) VALUES (69451, 3322);
INSERT INTO question_categries (category_id, question_id) VALUES (69451, 3323);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3327);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3330);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3331);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3335);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3337);
INSERT INTO question_categries (category_id, question_id) VALUES (58054, 58268);
INSERT INTO question_categries (category_id, question_id) VALUES (58052, 3349);


--
-- TOC entry 2050 (class 0 OID 25027)
-- Dependencies: 1719
-- Data for Name: roles; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO roles (id, name) VALUES (10, 'ROLE_AUTHOR');
INSERT INTO roles (id, name) VALUES (30, 'ROLE_APPROVER');
INSERT INTO roles (id, name) VALUES (20, 'ROLE_DEPLOYER');
INSERT INTO roles (id, name) VALUES (999, 'ROLE_ADMIN');


--
-- TOC entry 2051 (class 0 OID 25030)
-- Dependencies: 1720
-- Data for Name: rpt_users; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (2, 'test', '9ddc44f3f7f78da5781d6cab571b2fc5', '2010-04-19', NULL);
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (9, 'test1', 'a564de63c2d0da68cf47586ee05984d7', '2010-04-29', '');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (10, 'nsykes', '65d15fe9156f9c4bbffd98085992a44e', '2010-04-29', '');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (11, 'khenderson', '22b5c9accc6e1ba628cedc63a72d57f8', '2010-04-29', '');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (12, 'dolson', '65d15fe9156f9c4bbffd98085992a44e', '2010-04-29', '');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (1, 'lkagan', 'a564de63c2d0da68cf47586ee05984d7', '2010-04-19', 'lkagan@healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (14, 'testing', '22b5c9accc6e1ba628cedc63a72d57f8', '2010-08-04', 'pgupta@healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (16, 'GuestUser', '084e0343a0486ff05530df6c705c8bb4', '2010-08-12', 'howard.shang@duke.edu');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (13, 'pgupta', 'a564de63c2d0da68cf47586ee05984d7', '2010-04-29', 'gupta@healthcit.com');
INSERT INTO rpt_users (id, username, password, created_date, email_addr) VALUES (17, 'test123', '22b5c9accc6e1ba628cedc63a72d57f8', '2010-09-02', 'pgupta@healthcit.com');


--
-- TOC entry 2052 (class 0 OID 25033)
-- Dependencies: 1721
-- Data for Name: skip_pattern; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (58885, 58712, 'show', 'Show this question when Answer: Yes for Question 11: Was your tumor positive for the HER2/neu tumor marker? is selected.', 'questionSkip', 'c5caae0d-5dbf-49b4-8ad6-b7e3ced43ed9');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (58887, 58714, 'show', 'Show this question when Answer: Yes for Question 13: Was cancer found in the lymph nodes of your armpit at diagnosis? is selected.', 'questionSkip', '2e52f948-581a-4816-999c-8cf3994e3309');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (58888, 58716, 'show', 'Show this question when Answer: Yes for Question 13: Was cancer found in the lymph nodes of your armpit at diagnosis? is selected.', 'questionSkip', '2e52f948-581a-4816-999c-8cf3994e3309');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (69175, 57815, 'show', 'Show this question when Answer: Other for Question 19: What is your ethnic background? Check all that apply? is selected.', 'questionSkip', '220cead1-3cae-4fbd-84f1-aada4e8e2ff2');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (69176, 69224, 'show', 'Show this question when Answer: Other Pacific Islande for Question 18: What is your ethnic background? Check all that apply? is selected.', 'questionSkip', '7c8efeed-1e70-4f85-a607-8bed0f3dddae');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59501, 58725, 'show', 'Show this question when Answer: No for Question 7: Have you ever taken fertility drugs? is selected.', 'questionSkip', '335a61e0-0dc9-4cf7-a61f-a2a84ab63a03');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59502, 58725, 'show', 'Show this question when Answer: Yes for Question 8: Have you ever been pregnant? is selected.', 'questionSkip', '6f885de7-e068-45c5-b7c9-09f72036adb4');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59503, 58726, 'show', 'Show this question when Answer: Yes for Question 7: Have you ever taken fertility drugs? is selected.', 'questionSkip', '1005f8a4-55af-4fa5-83d9-41c216303d4a');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59504, 58726, 'show', 'Show this question when Answer: Yes for Question 8: Have you ever been pregnant? is selected.', 'questionSkip', '6f885de7-e068-45c5-b7c9-09f72036adb4');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59505, 58729, 'show', 'Show this question when Answer: Yes for Question 10: Have you ever had a full-term pregnancy? is selected.', 'questionSkip', '142db007-b36f-4285-876e-2cdc3ba66958');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (69179, 69225, 'show', 'Show this question when Answer: Other Race for Question 18: What is your ethnic background? Check all that apply? is selected.', 'questionSkip', '7d7e7627-090d-4112-a904-a8f1ee444563');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (69180, 69227, 'show', 'Show this question when Answer: Yes, other Spanish, Hispanic, Latino for Question 22: Are you Spanish/Hispanic/Latino? is selected.', 'questionSkip', '4254afb8-c60e-4b88-8835-c90e5abda8a7');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59508, 58730, 'show', 'Show this question when Answer: I''d rather not say for Question 8: Have you ever been pregnant? is selected.', 'questionSkip', 'c9e51467-e960-444c-9edc-65d125a73773');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59509, 58730, 'show', 'Show this question when Answer: I don''t know/I can''t remember for Question 8: Have you ever been pregnant? is selected.', 'questionSkip', 'acd4661a-9261-4a0d-9909-d661e17f75d0');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59513, 58732, 'show', 'Show this question when Answer: I no longer have regular menstrual periods (menopause). for Question 14: Do you currently have menstrual periods?  is selected.', 'questionSkip', 'b6d53ad0-d693-4614-86ad-02a45edbe911');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59514, 58731, 'show', 'Show this question when Answer: Yes for Question 15: Do you want to tell in what year did you experience your last menstrual period? is selected.', 'questionSkip', 'af18a2db-a522-4fae-9f90-81ef47256388');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59515, 58731, 'show', 'Show this question when Answer: I no longer have regular menstrual periods (menopause). for Question 14: Do you currently have menstrual periods?  is selected.', 'questionSkip', 'b6d53ad0-d693-4614-86ad-02a45edbe911');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59516, 58733, 'show', 'Show this question when Answer: Yes for Question 15: Do you want to tell in what year did you experience your last menstrual period? is selected.', 'questionSkip', 'af18a2db-a522-4fae-9f90-81ef47256388');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59517, 58733, 'show', 'Show this question when Answer: I no longer have regular menstrual periods (menopause). for Question 14: Do you currently have menstrual periods?  is selected.', 'questionSkip', 'b6d53ad0-d693-4614-86ad-02a45edbe911');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59518, 58734, 'show', 'Show this question when Answer: My periods stopped due to another reason for Question 17: Why did your periods stop? is selected.', 'questionSkip', 'd2dba9b8-e5b0-4de1-a119-ce03e77493f4');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59520, 58735, 'show', 'Show this question when Answer: I no longer have regular menstrual periods (menopause). for Question 14: Do you currently have menstrual periods?  is selected.', 'questionSkip', 'b6d53ad0-d693-4614-86ad-02a45edbe911');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59523, 58740, 'show', 'Show this question when Answer: Yes, I have taken menopausal hormone therapy in the past, but no longer do for Question 19: Have you ever taken menopausal hormone therapy? is selected.', 'questionSkip', 'c1462b09-3ebe-4a1b-8bc3-fd8d1aea438a');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59524, 58740, 'show', 'Show this question when Answer: Yes, I am currently taking menopausal hormone therapy. for Question 19: Have you ever taken menopausal hormone therapy? is selected.', 'questionSkip', 'ee6b3ce1-3188-489c-9cae-6205b2adf427');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59527, 58743, 'show', 'Show this question when Answer: yes for Question 22: Do you know the year you experience your uterine surgery (hysterectomy)? is selected.', 'questionSkip', '526786f9-be6d-456c-8f1e-820e86b10b2f');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59531, 58746, 'show', 'Show this question when Answer: Yes for Question 25: Do you want to tell the  year did you experience your ovarian surgery (oophorectomy)? is selected.', 'questionSkip', '8bc1e82a-2c04-4206-8a56-d9178e5c7f9a');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59800, 58745, 'show', 'Show this question when Answer: Yes, I have had surgery to remove one ovary, but not both ovaries. for Question 24: Have you ever had a surgery to remove part of an ovary or both ovaries? is selected.', 'questionSkip', '4ff50827-c3c7-4eb4-b0f0-fa6e2825648b');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59801, 58745, 'show', 'Show this question when Answer: Yes, I have had surgery to remove both ovaries. for Question 24: Have you ever had a surgery to remove part of an ovary or both ovaries? is selected.', 'questionSkip', '7ad96e9b-8877-4f57-8ab3-526cf214e693');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59802, 58745, 'show', 'Show this question when Answer: Yes, I have had surgery to remove part of an ovary. for Question 24: Have you ever had a surgery to remove part of an ovary or both ovaries? is selected.', 'questionSkip', 'b047fcb2-3d9a-429a-bf86-702aae58f3ea');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59803, 58742, 'show', 'Show this question when Answer: Yes, I had a surgery to remove my entire uterus for Question 21: Have you ever had a surgery to remove part or all of your uterus? is selected.', 'questionSkip', '1ce0292b-f385-4419-91af-c7124e747c35');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59804, 58742, 'show', 'Show this question when Answer: Yes, I had a surgery to remove part of my uterus. for Question 21: Have you ever had a surgery to remove part or all of your uterus? is selected.', 'questionSkip', 'cbe6d14c-b0a7-4813-9c89-cf5916bc657b');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (59812, 59868, 'show', 'Show this question when Answer: Other with value Yes for Question 22: Have you taken any of the following herbal or alternative remedies? is selected.', 'questionSkip', '66f5c3f7-ca9f-4f80-aa76-1c360cd1113d');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (61328, 58253, 'show', 'Show this question when Answer: Female for Question 4: Please enter your sex? is selected.', 'questionSkip', '9b8490fe-fc09-47aa-9795-02f91fdbba3c');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (62705, 58728, 'show', 'Show this question when Answer: Yes for Question 10: Have you ever had a full-term pregnancy? is selected.', 'questionSkip', '142db007-b36f-4285-876e-2cdc3ba66958');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (67451, 59867, 'show', 'Show this question when Answer: Yes for Question 21: During the past 6 months, have you taken any herbal or alternative remedies? is selected.', 'questionSkip', '1320bba5-aa1a-477b-b04f-855a578d921c');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (67453, 59860, 'show', 'Show this question when Answer: Yes for Question 14: Do you ever drink beer, wine or liquor? is selected.', 'questionSkip', 'c53ad187-9638-47de-8b49-3f18e98c3f99');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (69181, 69242, 'show', 'Show this question when Answer: Other specify for Question 37: Select the term that best describes the relationship for this contact:? is selected.', 'questionSkip', '24fbbb82-0166-4f75-be51-801668637bdc');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (1459, 58722, 'show', 'Show this question when Answer: Yes, I am currently using birth control pills for Question 5: Have you ever taken birth control pills (oral contraceptives) for one month or longer?  is selected.', 'questionSkip', '8623c24e-5008-4458-a2da-ed13476fc741');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (1460, 58722, 'show', 'Show this question when Answer: Yes, I used birth control pills in the past for Question 5: Have you ever taken birth control pills (oral contraceptives) for one month or longer?  is selected.', 'questionSkip', '9ee3ede5-d377-4f79-99dc-6ef957fffed3');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (1479, 1474, 'show', 'Show this question when Answer: Breast cancer patient or survivor for Question 2: Please check any of the following items that best describe(s) you: (Check all that apply). is selected.', 'questionSkip', 'edc7cbf6-7868-4095-89d1-058cd4961b78');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (1480, 1474, 'show', 'Show this question when Answer: Family member or friend of a breast cancer patient for Question 2: Please check any of the following items that best describe(s) you: (Check all that apply). is selected.', 'questionSkip', 'e012ad8c-bd78-4175-89ad-28214a9ed56f');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3317, 3247, 'show', 'Show this question when Answer: "Yes" for Question: "8.Were you sick last week, or did anything prevent you from doing your normal physical activities? (Check one.) " is selected.', 'questionSkip', '8c9c6516-6dc0-4ff1-9607-0eae993c7959');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (1555, 57813, 'show', 'Show this question when Answer: Other for Question 16: What is your occupation today?   is selected.', 'questionSkip', '0ae30d4f-cc65-49f6-a3af-0381ca3708bf');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (1593, 1590, 'show', 'Show this question when Answer: Red meat for Question 16: Indicate the types of foods that are included in your diet (check all that apply) is selected.', 'questionSkip', '7c168ffa-700b-48a8-8eba-63afb639a6fc');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (1768, 1766, 'show', 'Show this question when Answer: Yes for Question 4: A. ...tenderness in your breast that lasted for more than a month each time?  is selected.', 'questionSkip', '04134faf-2d9d-4c94-9f79-4e29772a5746');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (1772, 1771, 'show', 'Show this question when Answer: Yes for Question 6: B. ...cysts (liquid or solid) or lumps ? is selected.', 'questionSkip', '804427ec-6983-404d-8e69-e46d34721005');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (2322, 2186, 'show', 'Show this question when Answer: Other toppings: for Question 5: My favorite toppings are: is selected.', 'questionSkip', 'a1853ef2-d789-4757-98bc-2cc777bfd28b');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (2432, 1525, 'show', 'Show this question when Answer: Other for Question 20: Which of the following best describe(s) you? (Check all that apply) is selected.', 'questionSkip', '77ff1a71-df95-4980-bdd9-b720278d8ad7');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (2450, 58727, 'show', 'Show this question when Answer: Yes for Question 10: Have you ever had a full-term pregnancy? is selected.', 'questionSkip', '142db007-b36f-4285-876e-2cdc3ba66958');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (2494, 2433, 'show', 'Show this question when Answer: Yes for Question 4: Do you have cancer? is selected.', 'questionSkip', '68a7f4cf-29bd-4f05-87c9-2f415475158c');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (2497, 2466, 'show', 'Show this question when Answer: Yes, I have had surgery to remove one ovary, but not both ovaries. for Question 12: Have you ever had a surgery to remove part of an ovary or both ovaries? is selected.', 'questionSkip', '2cf288f7-97cf-49a2-8b10-39bc2398c075');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (2498, 2466, 'show', 'Show this question when Answer: Yes, I have had surgery to remove part of an ovary. for Question 13: Have you ever had a surgery to remove part of an ovary or both ovaries? is selected.', 'questionSkip', 'a3a260ed-82f1-49ba-8dd6-54ee4f461bde');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (2663, 2652, 'show', 'Show this question when Answer: "Yes" for Question: "Have you ever been told by a doctor or other health professional that you have diabetes or sugar diabetes? (SELECT ONE)" is selected.', 'questionSkip', '06c7db65-ca71-4524-a3cc-331e567322a3');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (2678, 69246, 'show', 'Show this question when Answer: "yes" for Question: "Have you ever diagnosed with breast cancer?" is selected.', 'questionSkip', '217a6b83-6e1a-4a4f-8c28-07d96f049974');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3023, 1774, 'show', 'Show this section when Answer: "Breast cancer patient or survivor" for Question: "Please check any of the following items that best describe(s) you: (Check all that apply)." is selected.', 'formSkip', 'edc7cbf6-7868-4095-89d1-058cd4961b78');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3022, 1774, 'show', 'Show this section when Answer: "Don''t know" for Question: "Has a health care professional ever brought up the topic of breast cancer clinical trials with you?" is selected.', 'formSkip', '44c9b0c0-fb24-4085-8174-2bf119e8c847');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3028, 1464, 'show', 'Show this section when Answer: "Don''t know" for Question: "Has a health care professional ever brought up the topic of breast cancer clinical trials with you?" is selected.', 'formSkip', '44c9b0c0-fb24-4085-8174-2bf119e8c847');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3029, 1464, 'show', 'Show this section when Answer: "Breast cancer patient or survivor" for Question: "Please check any of the following items that best describe(s) you: (Check all that apply)." is selected.', 'formSkip', 'edc7cbf6-7868-4095-89d1-058cd4961b78');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3027, 1464, 'show', 'Show this section when Answer: "Female" for Question: "What is your sex? " is selected.', 'formSkip', 'b07eef3b-a4bd-4866-ade4-aeccb7b87c78');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3066, 3063, 'show', 'Show this question when Answer: "Yes" for Question: "Is it for personal consumption?" is selected.', 'questionSkip', '37d69d49-a64b-4433-b24e-a32e20522259');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3068, 3067, 'show', 'Show this question when Answer: "Other brands" for Question: "My single most favorite brand is:" is selected.', 'questionSkip', 'c1c8de74-c0a1-4969-b3b2-d6a6f6515748');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3343, 58268, 'show', 'Show this question when Answer: "Female" for Question: "Please select your sex?" is selected.', 'questionSkip', '9b8490fe-fc09-47aa-9795-02f91fdbba3c');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3087, 2439, 'show', 'Show this question when Answer: Yes for Question 6: When you were first diagnosed, was the cancer in other organs (metastatic) ? is selected.', 'questionSkip', '6da828b9-e701-4bce-8cc0-d9ab0a58a055');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3147, 3146, 'show', 'Show this question when Answer: "YES" for Question: "Are you currently on a special diet?" is selected.', 'questionSkip', 'c819e226-23c2-46bd-910c-5b816fe4e011');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3155, 1472, 'show', 'Show this question when Answer: Other for Question 2: Please check any of the following items that best describe(s) you: (Check all that apply). is selected.', 'questionSkip', '6e0482bf-e26f-40f1-9e45-e5cddb66a528');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3347, 3037, 'show', 'Show this section when Answer: "Yes" for Question: "Diabetes (without complications)" is selected.', 'formSkip', '5a58d344-38d4-426d-9550-666765dfbad1');
INSERT INTO skip_pattern (id, parent_id, rule_value, description, parent_type, answer_value_id) VALUES (3348, 3037, 'show', 'Show this section when Answer: "Yes" for Question: "Have you ever been told by a doctor or other health professional that you have diabetes or sugar diabetes? (SELECT ONE)" is selected.', 'formSkip', '06c7db65-ca71-4524-a3cc-331e567322a3');


--
-- TOC entry 2053 (class 0 OID 25040)
-- Dependencies: 1722
-- Data for Name: user_roles; Type: TABLE DATA; Schema: FormBuilder; Owner: fbdev
--

INSERT INTO user_roles (user_id, role_id) VALUES (9, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (10, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (11, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (12, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 999);
INSERT INTO user_roles (user_id, role_id) VALUES (1, 20);
INSERT INTO user_roles (user_id, role_id) VALUES (14, 999);
INSERT INTO user_roles (user_id, role_id) VALUES (14, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (14, 20);
INSERT INTO user_roles (user_id, role_id) VALUES (14, 30);
INSERT INTO user_roles (user_id, role_id) VALUES (13, 10);
INSERT INTO user_roles (user_id, role_id) VALUES (16, 999);
INSERT INTO user_roles (user_id, role_id) VALUES (17, 30);


--
-- TOC entry 2010 (class 2606 OID 25055)
-- Dependencies: 1713 1713
-- Name: answerValuePK; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer_value
    ADD CONSTRAINT "answerValuePK" PRIMARY KEY (id);


--
-- TOC entry 2007 (class 2606 OID 25057)
-- Dependencies: 1712 1712
-- Name: answer_label_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_label_pkey PRIMARY KEY (id);


--
-- TOC entry 2015 (class 2606 OID 25059)
-- Dependencies: 1715 1715
-- Name: form_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY form
    ADD CONSTRAINT form_pkey PRIMARY KEY (id);


--
-- TOC entry 2017 (class 2606 OID 25061)
-- Dependencies: 1716 1716
-- Name: module_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY module
    ADD CONSTRAINT module_pkey PRIMARY KEY (id);


--
-- TOC entry 2012 (class 2606 OID 25063)
-- Dependencies: 1714 1714
-- Name: pk_categoryId; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT "pk_categoryId" PRIMARY KEY (id);


--
-- TOC entry 2020 (class 2606 OID 25065)
-- Dependencies: 1717 1717
-- Name: question_new_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_new_pkey PRIMARY KEY (id);


--
-- TOC entry 2023 (class 2606 OID 25067)
-- Dependencies: 1719 1719
-- Name: roles_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 2031 (class 2606 OID 25069)
-- Dependencies: 1721 1721
-- Name: skip_pattern_pkey; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY skip_pattern
    ADD CONSTRAINT skip_pattern_pkey PRIMARY KEY (id);


--
-- TOC entry 2025 (class 2606 OID 25073)
-- Dependencies: 1720 1720
-- Name: unique_username; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY rpt_users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- TOC entry 2027 (class 2606 OID 25075)
-- Dependencies: 1720 1720
-- Name: users_pri_key; Type: CONSTRAINT; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

ALTER TABLE ONLY rpt_users
    ADD CONSTRAINT users_pri_key PRIMARY KEY (id);


--
-- TOC entry 2008 (class 1259 OID 25076)
-- Dependencies: 1712
-- Name: fki_fb_answer_question_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_answer_question_fk ON answer USING btree (question_id);


--
-- TOC entry 2013 (class 1259 OID 25077)
-- Dependencies: 1715
-- Name: fki_fb_form_module_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_form_module_fk ON form USING btree (module_id);


--
-- TOC entry 2018 (class 1259 OID 25078)
-- Dependencies: 1717
-- Name: fki_fb_question_form_fk; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX fki_fb_question_form_fk ON question USING btree (form_id);


--
-- TOC entry 2021 (class 1259 OID 25079)
-- Dependencies: 1717
-- Name: question_ts_data_idx; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX question_ts_data_idx ON question USING gin (ts_data);


--
-- TOC entry 2028 (class 1259 OID 25080)
-- Dependencies: 1721
-- Name: skip_pattern_av_id_index; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX skip_pattern_av_id_index ON skip_pattern USING btree (answer_value_id);


--
-- TOC entry 2029 (class 1259 OID 25081)
-- Dependencies: 1721 1721
-- Name: skip_pattern_parent_idx; Type: INDEX; Schema: FormBuilder; Owner: fbdev; Tablespace: 
--

CREATE INDEX skip_pattern_parent_idx ON skip_pattern USING btree (parent_id, parent_type);


--
-- TOC entry 2032 (class 2606 OID 25082)
-- Dependencies: 2019 1712 1717
-- Name: fb_answer_question_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT fb_answer_question_fk FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE;


--
-- TOC entry 2033 (class 2606 OID 25087)
-- Dependencies: 1720 2026 1715
-- Name: fb_form_author_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_author_user_fk FOREIGN KEY (author_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 2036 (class 2606 OID 25145)
-- Dependencies: 1715 2026 1720
-- Name: fb_form_last_updated_by_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_last_updated_by_user_fk FOREIGN KEY (last_updated_by_user_id) REFERENCES rpt_users(id) ON DELETE RESTRICT;


--
-- TOC entry 2034 (class 2606 OID 25092)
-- Dependencies: 2026 1720 1715
-- Name: fb_form_locked_by_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_locked_by_fk FOREIGN KEY (locked_by_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 2035 (class 2606 OID 25097)
-- Dependencies: 2016 1715 1716
-- Name: fb_form_module_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY form
    ADD CONSTRAINT fb_form_module_fk FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE CASCADE;


--
-- TOC entry 2037 (class 2606 OID 25102)
-- Dependencies: 2026 1720 1716
-- Name: fb_module_author_user_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY module
    ADD CONSTRAINT fb_module_author_user_fk FOREIGN KEY (author_user_id) REFERENCES rpt_users(id);


--
-- TOC entry 2038 (class 2606 OID 25107)
-- Dependencies: 2014 1715 1717
-- Name: fb_question_form_fk; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question
    ADD CONSTRAINT fb_question_form_fk FOREIGN KEY (form_id) REFERENCES form(id) ON DELETE CASCADE;


--
-- TOC entry 2039 (class 2606 OID 25112)
-- Dependencies: 1714 1718 2011
-- Name: fk_categoryId_question_categories; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_categries
    ADD CONSTRAINT "fk_categoryId_question_categories" FOREIGN KEY (category_id) REFERENCES category(id);
    
ALTER TABLE "FormBuilder".answer_value ADD COLUMN cadsr_public_id bigint;


--
-- TOC entry 2040 (class 2606 OID 25117)
-- Dependencies: 1717 2019 1718
-- Name: fk_questionId_question_categories; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY question_categries
    ADD CONSTRAINT "fk_questionId_question_categories" FOREIGN KEY (question_id) REFERENCES question(id);


--
-- TOC entry 2041 (class 2606 OID 25122)
-- Dependencies: 2022 1722 1719
-- Name: fk_roleId_user_roles; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT "fk_roleId_user_roles" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;


--
-- TOC entry 2042 (class 2606 OID 25127)
-- Dependencies: 1722 1720 2026
-- Name: fk_userId_user_roles; Type: FK CONSTRAINT; Schema: FormBuilder; Owner: fbdev
--

ALTER TABLE ONLY user_roles
    ADD CONSTRAINT "fk_userId_user_roles" FOREIGN KEY (user_id) REFERENCES rpt_users(id) ON DELETE CASCADE;


--
-- TOC entry 2056 (class 0 OID 0)
-- Dependencies: 10
-- Name: FormBuilder; Type: ACL; Schema: -; Owner: fbdev
--

REVOKE ALL ON SCHEMA "FormBuilder" FROM PUBLIC;
REVOKE ALL ON SCHEMA "FormBuilder" FROM fbdev;
GRANT ALL ON SCHEMA "FormBuilder" TO fbdev;
GRANT ALL ON SCHEMA "FormBuilder" TO PUBLIC;


-- Completed on 2010-09-23 11:48:36

--
-- PostgreSQL database dump complete
--

