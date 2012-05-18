ALTER TABLE "FormBuilder".form ADD COLUMN last_updated_by_user_id bigint;

ALTER TABLE "FormBuilder".form
    ADD CONSTRAINT fb_form_last_updated_by_user_fk FOREIGN KEY (last_updated_by_user_id)
      REFERENCES "FormBuilder".rpt_users (id)
	ON UPDATE NO ACTION ON DELETE RESTRICT;

ALTER TABLE "FormBuilder".skip_pattern ALTER description TYPE character varying(2000);

ALTER TABLE "FormBuilder".answer_value ALTER short_name TYPE character varying(250);

alter table answer add column value_constraint character varying(100);

DROP VIEW "FormBuilder".skip_pattern_answer_value_vw;
ALTER TABLE "FormBuilder".answer_value ALTER "value" TYPE character varying(250);
CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS
 SELECT s.id,
        CASE s.parent_type
            WHEN 'questionSkip'::text THEN s.parent_id
            ELSE NULL::bigint
        END AS question_id,
        CASE s.parent_type
            WHEN 'formSkip'::text THEN s.parent_id
            ELSE NULL::bigint
        END AS form_id, s.answer_value_id AS skip_item, av.value AS skip_item_value, a.question_id AS skip_item_question, q.form_id AS skip_item_form
   FROM skip_pattern s, answer_value av, answer a, question q
  WHERE s.answer_value_id = av.permanent_id AND av.answer_id = a.id AND q.id = a.question_id;
ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;

ALTER TABLE "FormBuilder".question ADD COLUMN cadsr_public_id bigint;
ALTER TABLE "FormBuilder".question ALTER short_name TYPE character varying(250);
ALTER TABLE "FormBuilder".form DROP CONSTRAINT "uniqueFormOrd";
ALTER TABLE "FormBuilder".answer_value ALTER description TYPE character varying(500);
ALTER TABLE "FormBuilder".answer ALTER description TYPE character varying(500);
ALTER TABLE "FormBuilder".skip_pattern ADD CONSTRAINT skip_redundancy_constraint UNIQUE (parent_id, answer_value_id);
ALTER TABLE "FormBuilder".rpt_users ALTER email_addr TYPE character varying(100);
