/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

SELECT * INTO "FormBuilder".question_orig FROM "FormBuilder".question;

ALTER TABLE "FormBuilder".answer DROP CONSTRAINT "fb_answer_question_fk";

ALTER TABLE "FormBuilder".question_categries DROP CONSTRAINT "fk_questionId_question_categories";

DROP VIEW "FormBuilder".skip_pattern_answer_value_vw;

DROP TABLE "FormBuilder".question;

CREATE TABLE "FormBuilder".form_element
(
  id bigint NOT NULL,
  description character varying(2000),
  form_id bigint,
  ord bigint,
  learn_more character varying(4000),
  is_required boolean,
  ts_data tsvector,
  uuid character(36),
  link_id character varying(255),
  link_source character varying(30),
  external_id bigint,
  is_visible boolean,
  element_type character varying(40),
  CONSTRAINT form_element_pkey PRIMARY KEY (id),
  CONSTRAINT fb_form_element_form_fk FOREIGN KEY (form_id)
      REFERENCES "FormBuilder".form (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

-- create indexes existed in old 'question' table
CREATE INDEX fki_fb_question_form_fk
  ON "FormBuilder".form_element
  USING btree
  (form_id);

CREATE INDEX question_ts_data_idx
  ON "FormBuilder".form_element
  USING gin
  (ts_data);

-- Change 'form_element' table owner
ALTER TABLE "FormBuilder".form_element OWNER TO fbdev;

-- add unique identifier for answers
ALTER TABLE "FormBuilder".answer ADD COLUMN uuid character varying(40);

CREATE TABLE "FormBuilder".question
(
  id bigint NOT NULL,
  uuid character(36) NOT NULL,
  short_name character varying(250),
  parent_id bigint NOT NULL,
  ord bigint,
  description character varying(2000),
  question_type character varying(40),
  "type" character varying(30),
  CONSTRAINT question_pkey PRIMARY KEY (id),
  CONSTRAINT fb_question_form_fk FOREIGN KEY (parent_id)
      REFERENCES "FormBuilder".form_element (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

ALTER TABLE "FormBuilder".question OWNER TO fbdev;

CREATE OR REPLACE FUNCTION "FormBuilder".convert_form_element()
  RETURNS boolean AS
$BODY$  
DECLARE 

    q RECORD;
    f RECORD;
    fe RECORD;
	e_type varchar;
	lk_source varchar;
   
begin
	
	delete from form_element;

	FOR q IN SELECT * FROM question_orig  LOOP
        
		   --get the element_type
		 if q.type like '%_ANSWER' then
           e_type := 'question';
           elsif q.type ='CONTENT' then
           e_type :=  'content';
           elsif q.type like '%_TABLE'  then
           e_type := 'table';	
	   else continue;
	   end if; 
 
          insert into form_element 
		  (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, link_id, link_source, external_id, is_visible, element_type)
           values 
           (q.id,
	    q.description,
            q.form_id,
			q.ord,
			q.learn_more,
			q.is_required,
			q.ts_data,
			q.uuid,  
			q.link_id,
			lk_source,
			q.cadsr_public_id,
			true,
			e_type
           );	 
	END LOOP;
	RETURN true;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
  
select convert_form_element();

CREATE OR REPLACE FUNCTION "FormBuilder".convert_answer_question()
  RETURNS boolean AS
$BODY$
DECLARE
    q RECORD;
    a RECORD;
    q_type varchar;
    new_id bigint;
    fe_type varchar;
    e_type varchar;
begin
	
	delete from question;

	FOR a IN SELECT * FROM answer  LOOP
                 
	-- insert new question table
           
		  ---get the new Id
		  new_id := nextval('"GENERIC_ID_SEQ"');
          
		  ---get the type
		  select type into q_type from question_orig where id = a.question_id;
		  
		  select element_type into fe_type from form_element where id=a.question_id;
		  
		  if fe_type = 'question' then
           e_type := 'question';
           elsif fe_type ='content' then
           e_type :=  'content';
           elsif fe_type = 'table'  then
           e_type := 'tableQuestion';	
	   	   else continue;
	   	  end if;
		  
          insert into question 
		  (id, description, uuid, ord, short_name, parent_id, question_type, type)
           values 
           (new_id,
		    a.description,
		    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://www.heathcit.com/FormBuilder/' || new_id),
			a.ord,
			a.group_name,
			a.question_id,
			e_type,			
			q_type
           );		   
		
	    -- update answer table with thte new question id
        update answer set question_id = new_id where id= a.id;        
        update answer set uuid = nextval('"GENERIC_ID_SEQ"') where id= a.id;
		 
	END LOOP;

	--commit;

	RETURN true;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

select convert_answer_question();

ALTER TABLE "FormBuilder".question_categries ADD CONSTRAINT "fk_questionId_question_categories" FOREIGN KEY (question_id)
      REFERENCES "FormBuilder".form_element (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE "FormBuilder".answer ADD CONSTRAINT "fb_answer_question_fk" FOREIGN KEY (question_id)
      REFERENCES "FormBuilder".question (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

-- Add 'has_been_modified' column to 'form_element' table
ALTER TABLE "FormBuilder".form_element ADD COLUMN has_been_modified boolean;

-- Add 'ord' column to 'answer' table to define answers order
ALTER TABLE "FormBuilder".answer ALTER COLUMN ord DROP NOT NULL;

-- Update 'form_element' table data with correct element types
--update form_element set element_type='question';
--update form_element set element_type='table' where id in (select id from question_orig q where  q.type like '%TABLE');
--update form_element set element_type='content' where id in (select id from question_orig q where  q.type like 'CONTENT');

-- Update question type
update question set type = 'SINGLE_ANSWER' where type = 'SINGLE_ANSWER_TABLE';

------------ Replace view for skips
CREATE OR REPLACE VIEW "FormBuilder".skip_pattern_answer_value_vw AS 
 SELECT s.id, 
        CASE s.parent_type
            WHEN 'questionSkip'::text THEN s.parent_id
            ELSE NULL::bigint
        END AS form_element_id, 
        CASE s.parent_type
            WHEN 'formSkip'::text THEN s.parent_id
            ELSE NULL::bigint
        END AS form_id, a.question_id AS skip_item_question, fe.form_id AS skip_item_form
   FROM skip_pattern s, skip_pattern_parts sp, answer_value av, answer a, question q, form_element fe
  WHERE sp.answer_value_id::bpchar = av.permanent_id AND av.answer_id = a.id AND q.id = a.question_id AND q.parent_id = fe.id AND s.id = sp.parent_id
  GROUP BY s.id, s.parent_type, s.parent_id, a.question_id, fe.form_id;

ALTER TABLE "FormBuilder".skip_pattern_answer_value_vw OWNER TO fbdev;


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
