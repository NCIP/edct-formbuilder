DROP VIEW "FormBuilder".skip_pattern_answer_value_vw;
DROP VIEW "FormBuilder".answer_value_form_id_vw;
 
CREATE OR REPLACE VIEW "FormBuilder".answer_value_form_id_vw AS 
         SELECT link_fe.form_id AS link_form_id, link_fe.id as feid, av.permanent_id AS av_uuid, av.id AS av_id, 'link'
           FROM "FormBuilder".form_element lib_fe, "FormBuilder".form_element link_fe, "FormBuilder".answer_value av, "FormBuilder".answer a, "FormBuilder".question q
          WHERE link_fe.link_id::bpchar = lib_fe.uuid AND q.parent_id = lib_fe.id AND a.question_id = q.id AND av.answer_id = a.id
UNION 
         SELECT f.id AS link_form_id, fe.id as feid, av.permanent_id AS av_uuid, av.id AS av_id, 'not'
           FROM "FormBuilder".answer_value av, "FormBuilder".answer a, "FormBuilder".question q, "FormBuilder".form_element fe, "FormBuilder".form f
          WHERE av.answer_id = a.id AND a.question_id = q.id AND q.parent_id = fe.id AND fe.form_id = f.id AND f.form_type::text = 'questionnaireForm'::text;

ALTER TABLE "FormBuilder".answer_value_form_id_vw OWNER TO fbdev;

CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS 
 SELECT s.id, 
        CASE r.parent_type
            WHEN 'formElementSkip'::text THEN r.parent_id
            ELSE NULL::bigint
        END AS form_element_id, 
        CASE r.parent_type
            WHEN 'formSkip'::text THEN r.parent_id
            ELSE NULL::bigint
        END AS form_id, a.question_id AS skip_item_question, vw.link_form_id AS skip_item_form
   FROM "FormBuilder".skip_rule r, "FormBuilder".question_skip_rule s, "FormBuilder".answer_skip_rule sp, "FormBuilder".answer_value av, "FormBuilder".answer a, "FormBuilder".question q, "FormBuilder".form_element fe, "FormBuilder".form f, "FormBuilder".answer_value_form_id_vw vw
  WHERE sp.answer_value_id::bpchar = vw.av_uuid AND sp.form_id = vw.link_form_id AND vw.av_id = av.id AND av.answer_id = a.id AND q.id = a.question_id AND q.parent_id = fe.id AND s.id = sp.parent_id AND s.parent_id = r.id
  GROUP BY s.id, r.parent_type, r.parent_id, a.question_id, fe.form_id, vw.link_form_id;

ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;