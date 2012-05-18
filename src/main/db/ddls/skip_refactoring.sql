-- Table: "FormBuilder".skip_pattern

-- DROP TABLE "FormBuilder".skip_pattern;

CREATE TABLE "FormBuilder".skip_pattern_parts
(
  id bigint NOT NULL,
  parent_id bigint NOT NULL,
  answer_value_id character varying(150) NOT NULL,
  dtype character varying(50),
  CONSTRAINT skip_pattern_parts_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "FormBuilder".skip_pattern_parts OWNER TO fbdev;

ALTER TABLE skip_pattern ADD COLUMN logical_op character varying(3);

-- move data from skip_pattern to skip_pattern_parts
CREATE OR REPLACE FUNCTION "FormBuilder".convertSkips() returns integer as $$
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
$$ LANGUAGE 'plpgsql' ;

select convertSkips();


DROP VIEW skip_pattern_answer_value_vw;

ALTER TABLE skip_pattern DROP COLUMN answer_value_id;

CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS
 SELECT s.id,
        CASE s.parent_type
            WHEN 'questionSkip'::text THEN s.parent_id
            ELSE NULL::bigint
        END AS question_id,
        CASE s.parent_type
            WHEN 'formSkip'::text THEN s.parent_id
            ELSE NULL::bigint
        END AS form_id, a.question_id AS skip_item_question, q.form_id AS skip_item_form
   FROM skip_pattern s, skip_pattern_parts sp, answer_value av, answer a, question q
  WHERE sp.answer_value_id = av.permanent_id AND av.answer_id = a.id AND q.id = a.question_id AND s.id=sp.parent_id group by s.id, s.parent_type, s.parent_id, a.question_id, q.form_id;
ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;

