/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

alter table question_skip_rule add column identifying_answer_value_id bigint;
alter table question_skip_rule
    add constraint fb_question_skip_rule_answer_value_fk foreign key (identifying_answer_value_id) references answer_value(id) on update cascade on delete cascade;