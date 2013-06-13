/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE QUESTION RENAME TO QUESTION_ORIG;

--CREATE TABLE "FormBuilder".form_element
--(
--  id bigint NOT NULL,
--  description character varying(2000) NOT NULL,
--  form_id bigint NOT NULL,
--  ord bigint NOT NULL,
--  learn_more character varying(2000),
--  is_required boolean,
--  ts_data tsvector,
--  uuid character(36) NOT NULL,
--  link_id character varying(255),
--  link_source character varying(30),
--  external_id bigint,
--  has_been_modified boolean,
--  is_visible boolean NOT NULL,
--  element_type character varying(40),
--  CONSTRAINT form_element_new_pkey PRIMARY KEY (id),
--  CONSTRAINT fb_form_element_form_fk FOREIGN KEY (form_id)
--      REFERENCES "FormBuilder".form (id) MATCH SIMPLE
--      ON UPDATE NO ACTION ON DELETE CASCADE
--)
--WITH (
--  OIDS=FALSE
--);

CREATE TABLE QUESTION(
  id bigint NOT NULL,
  uuid character(36) NOT NULL,
  short_name character varying(250),
  parent_id bigint NOT NULL,
  ord bigint,
  description character varying(2000),
  question_type character varying(40)
);
ALTER TABLE "FormBuilder".question OWNER TO fbdev;

ALTER TABLE "FormBuilder".question ADD COLUMN "type" character varying(30);

SELECT id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, cadsr_public_id AS external_id, is_visible INTO form_element  FROM question_orig;
ALTER TABLE "FormBuilder".form_element OWNER TO fbdev;
ALTER TABLE "FormBuilder".form_element ADD COLUMN element_type character varying(40);
ALTER TABLE "FormBuilder".form_element ADD COLUMN has_been_modified boolean;
ALTER TABLE ONLY "FormBuilder".form_element ADD CONSTRAINT form_element_pkey PRIMARY KEY (id);
ALTER TABLE "FormBuilder".form_element ADD CONSTRAINT fb_form_element_form_fk FOREIGN KEY (form_id) REFERENCES "FormBuilder".form (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE ONLY question ADD CONSTRAINT question_pkey PRIMARY KEY (id);
ALTER TABLE "FormBuilder".question ADD CONSTRAINT fb_question_form_fk FOREIGN KEY (parent_id) REFERENCES "FormBuilder".form_element (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;
ALTER TABLE "FormBuilder".answer ALTER COLUMN ord DROP NOT NULL;
ALTER TABLE ONLY "FormBuilder".answer DROP CONSTRAINT fb_answer_question_fk;




----------------- do this after new questions in questions table were create and question_id column has been updated to reflect new values;
ALTER TABLE ONLY "FormBuilder".answer ADD CONSTRAINT fb_answer_question_fk FOREIGN KEY (question_id) REFERENCES "FormBuilder".question (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE CASCADE;

update form_element set element_type='question';
update form_element set element_type='table' where id in (select id from question_orig q where  q.type like '%TABLE');
update form_element set element_type='content' where id in (select id from question_orig q where  q.type like 'CONTENT');

--changes done on 12/7/10
------------ Replace view for skips
--CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS 
-- SELECT s.id, 
--        CASE s.parent_type
--            WHEN 'questionSkip'::text THEN s.parent_id
--            ELSE NULL::bigint
 --       END AS form_element_id, 
--        CASE s.parent_type
--            WHEN 'formSkip'::text THEN s.parent_id
--            ELSE NULL::bigint
--        END AS form_id, a.question_id AS skip_item_question, fe.form_id AS skip_item_form
--   FROM skip_pattern s, skip_pattern_parts sp, answer_value av, answer a, question q, form_element fe
--  WHERE sp.answer_value_id::bpchar = av.permanent_id AND av.answer_id = a.id AND q.id = a.question_id AND q.parent_id = fe.id AND s.id = sp.parent_id
--  GROUP BY s.id, s.parent_type, s.parent_id, a.question_id, fe.form_id;

-- ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;

-- CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS 
 -- SELECT s.id, 
--         CASE s.parent_type
--             WHEN 'questionSkip'::text THEN s.parent_id
--             ELSE NULL::bigint
--         END AS form_element_id, 
--         CASE s.parent_type
--             WHEN 'formSkip'::text THEN s.parent_id
--             ELSE NULL::bigint
--         END AS form_id, a.question_id AS skip_item_question, fe.form_id AS skip_item_form
--    FROM skip_pattern s, skip_pattern_parts sp, answer_value av, answer a, question q, form_element fe, form f
--   WHERE sp.answer_value_id::bpchar = av.permanent_id AND av.answer_id = a.id AND q.id = a.question_id AND q.parent_id = fe.id AND s.id = sp.parent_id AND fe.form_id = f.id AND sp.form_uuid::bpchar = f.uuid
--   GROUP BY s.id, s.parent_type, s.parent_id, a.question_id, fe.form_id;

 


CREATE OR REPLACE VIEW "FormBuilder".table_columns_vw AS 
SELECT av.id, av.description as heading, av.value, av.ord, q.parent_id as table_id, q.id as question_id from answer_value av, answer a, question q
WHERE av.answer_id = a.id and a.question_id = q.id and q.id in (select id from question where question_type ='tableQuestion' and ord =1);
ALTER TABLE "FormBuilder".table_columns_vw OWNER TO fbdev;

alter table module add column is_library boolean;

alter table module add column module_type character varying(30);
alter table form add column form_type character varying(30);
update module set module_type='module';
update form set form_type='questionnaireForm';
update module set is_library = false;

--- change type for external_id column
alter table form_element add column external_id_new character varying(36);
update form_element set external_id_new = external_id;
alter table form_element drop column external_id;
alter table form_element rename column external_id_new to external_id;


----Changes to skip_pattern_parts
--alter table skip_pattern_parts add column form_uuid character varying(36);
--alter table skip_pattern_parts add column question_uuid character varying(36);
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
