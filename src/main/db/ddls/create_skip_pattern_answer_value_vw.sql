CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS
select s.id "id", 
      (case s.parent_type when 'questionSkip' then s.parent_id else null end) "question_id", 
      (case s.parent_type when 'formSkip' then s.parent_id else null end) "form_id", 
       s.answer_value_id "skip_item", 
       av.value "skip_item_value", 
       a.question_id "skip_item_question",
       q.form_id "skip_item_form",
       a.id "skip_item_answer_id"
from skip_pattern s, answer_value av, answer a, question q
where s.answer_value_id = av.permanent_id and av.answer_id = a.id and q.id = a.question_id;
ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;
