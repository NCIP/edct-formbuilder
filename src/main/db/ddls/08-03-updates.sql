/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

alter table "FormBuilder".question_skip_rule add column identifying_answer_value_uuid character(36);
update "FormBuilder".question_skip_rule
set identifying_answer_value_uuid = (select av.permanent_id from "FormBuilder".answer_value av where av.id = identifying_answer_value_id)
where identifying_answer_value_id is not null;
alter table "FormBuilder".question_skip_rule drop constraint fb_question_skip_rule_answer_value_fk;
alter table "FormBuilder".question_skip_rule drop column identifying_answer_value_id;
alter table "FormBuilder".answer_value add constraint unique_answer_value_permanent_id UNIQUE (permanent_id);
alter table "FormBuilder".question_skip_rule
    add constraint fb_question_skip_rule_answer_value_fk foreign key (identifying_answer_value_uuid) references "FormBuilder".answer_value(permanent_id) on update cascade on delete cascade;