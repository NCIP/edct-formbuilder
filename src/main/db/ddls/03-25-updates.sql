/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

CREATE TABLE "FormBuilder".skip_rule
(
  id bigint NOT NULL,
  parent_id bigint NOT NULL,
  logical_op character varying(3),
  parent_type character varying(15),
  CONSTRAINT skip_rule_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "FormBuilder".skip_rule OWNER TO fbdev;

ALTER table skip_pattern rename to question_skip_rule;
ALTER table skip_pattern_parts rename to answer_skip_rule;


CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS 
 SELECT s.id, 
        CASE r.parent_type
            WHEN 'formElementSkip'::text THEN r.parent_id
            ELSE NULL::bigint
        END AS form_element_id, 
        CASE r.parent_type
            WHEN 'formSkip'::text THEN r.parent_id
            ELSE NULL::bigint
        END AS form_id,
         a.question_id AS skip_item_question, vw.link_form_id AS skip_item_form
   FROM skip_rule r, question_skip_rule s, answer_skip_rule sp, answer_value av, answer a, question q, form_element fe, form f, answer_value_form_id_vw vw
  WHERE sp.answer_value_id::bpchar = vw.av_uuid 
        AND sp.form_id = vw.link_form_id 
        AND vw.av_id = av.id 
        AND av.answer_id = a.id 
        AND q.id = a.question_id 
        AND q.parent_id = fe.id 
        AND s.id = sp.parent_id
        AND s.parent_id = r.id
  GROUP BY s.id, r.parent_type, r.parent_id, a.question_id, fe.form_id, vw.link_form_id;

ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;


alter table question_skip_rule drop column parent_Type;



