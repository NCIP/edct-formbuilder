/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

alter table skip_pattern_parts add column form_id bigint;
------------------
CREATE OR REPLACE VIEW "FormBuilder".answer_value_form_id_vw AS 
select link_fe.form_id as link_form_id, av.permanent_id as av_uuid, av.id as av_id, 'link'
from form_element lib_fe, form_element link_fe,  answer_value av, answer a, question q 
where link_fe.link_id = lib_fe.uuid and 
q.parent_id = lib_fe.id and a.question_id = q.id 
and av.answer_id = a.id
union
select  f.id as link_form_id, av.permanent_id as av_uuid, av.id as av_id, 'not' 
 from answer_value av, answer a, question q, form_element fe, form f 
 where av.answer_id = a.id and a.question_id = q.id and q.parent_id = fe.id and fe.form_id = f.id and f.form_type = 'questionnaireForm';
 ------------------------
-- has to be changed after the answer_value_form_id_vw is created
------
 
 CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS 
 SELECT s.id, 
        CASE s.parent_type
            WHEN 'questionSkip'::text THEN s.parent_id
            ELSE NULL::bigint
        END AS form_element_id, 
        CASE s.parent_type
            WHEN 'formSkip'::text THEN s.parent_id
            ELSE NULL::bigint
        END AS form_id, a.question_id AS skip_item_question, vw.link_form_id AS skip_item_form
   FROM skip_pattern s, skip_pattern_parts sp, answer_value av, answer a, question q, form_element fe, form f, answer_value_form_id_vw vw
  WHERE sp.answer_value_id::bpchar = vw.av_uuid and sp.form_id = vw.link_form_id and  vw.av_id = av.id AND av.answer_id = a.id AND q.id = a.question_id AND q.parent_id = fe.id AND s.id = sp.parent_id
  GROUP BY s.id, s.parent_type, s.parent_id, a.question_id, fe.form_id, vw.link_form_id;
ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;
