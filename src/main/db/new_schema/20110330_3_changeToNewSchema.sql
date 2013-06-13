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
	  (id, description, form_id, ord, learn_more, is_required, ts_data, uuid, external_id, is_visible, element_type)
       values 
       (q.id,
    q.description,
        q.form_id,
		q.ord,
		q.learn_more,
		q.is_required,
		q.ts_data,
		q.uuid,  
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
        update answer set uuid = generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://www.heathcit.com/FormBuilder/' || id) where id= a.id;
		 
	END LOOP;

	--commit;

	RETURN true;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

select convert_answer_question();

ALTER TABLE "FormBuilder".answer ADD CONSTRAINT "fb_answer_question_fk" FOREIGN KEY (question_id)
      REFERENCES "FormBuilder".question (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

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

--- skip_pattern_parts ---
alter table skip_pattern_parts add column form_id bigint;
update skip_pattern_parts spp set form_id = 
(select f.id from form f
inner join form_element fe on fe.form_id = f.id
inner join question q on q.parent_id = fe.id
inner join answer a on a.question_id = q.id
inner join answer_value av on av.answer_id = a.id
where av.permanent_id = spp.answer_value_id);

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

 ALTER TABLE "FormBuilder".answer_value_form_id_vw OWNER TO fbdev;
 
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
--=============================================================================
alter table answer_value add column external_id character varying(40);
alter table form_element add column external_uuid character varying(40);
--=============================================================================
ALTER TABLE "FormBuilder".question_categries
  ADD CONSTRAINT "fk_questionId_form_element_categories" FOREIGN KEY (question_id)
      REFERENCES "FormBuilder".form_element (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION;
--=============================================================================
--
-- TOC entry 30 (class 1255 OID 41812)
-- Dependencies: 8 393
-- Name: refresh_question_ts_data(); Type: FUNCTION; Schema: FormBuilder; Owner: fbdev
--

CREATE OR REPLACE FUNCTION refresh_question_ts_data() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	qid INTEGER;
	count INTEGER := 0;
begin
	FOR qid IN SELECT * FROM "FormBuilder".question LOOP
		PERFORM "FormBuilder".refresh_question_ts_data(qid);
		count := count + 1;
	END LOOP;

	RETURN count;
end
$$;


ALTER FUNCTION "FormBuilder".refresh_question_ts_data() OWNER TO fbdev;

-- Function: "FormBuilder".refresh_question_ts_data(integer)

-- DROP FUNCTION "FormBuilder".refresh_question_ts_data(integer);

CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data(qid integer)
  RETURNS integer AS
$BODY$
DECLARE
    f RECORD;
    q RECORD;
    a RECORD;
    av RECORD;
    data TSVECTOR;
begin
	SELECT fe.id as id, fe.description as description, fe.learn_more as learn_more INTO f FROM "FormBuilder".form_element fe inner join "FormBuilder".form frm on fe.form_id=frm.id WHERE frm.form_type='questionLibraryForm' AND fe.id = qid;

	if (f is NULL) then
		RETURN qid;
	end if;

	data = setweight(to_tsvector('"FormBuilder".ts_config', coalesce(f.description,'')), 'A') ||
		setweight(to_tsvector('"FormBuilder".ts_config', coalesce(f.learn_more,'')), 'C');
		
	FOR q IN SELECT * FROM "FormBuilder".question WHERE parent_id = f.id LOOP
		data = data ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.short_name,'')), 'A') ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.description,'')), 'C') ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.short_name,'')), 'D');

	FOR a IN SELECT * FROM "FormBuilder".answer WHERE question_id = q.id LOOP

		data = data ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(a.description,'')), 'C') ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(a.group_name,'')), 'D');

		FOR av IN SELECT * FROM "FormBuilder".answer_value WHERE answer_id = a.id LOOP

			data = data ||
				setweight(to_tsvector('"FormBuilder".ts_config', coalesce(av.description,'')), 'C') ||
				setweight(to_tsvector('"FormBuilder".ts_config', coalesce(av.short_name,'')), 'D');

		END LOOP;

	END LOOP;
	END LOOP;
	UPDATE "FormBuilder".form_element set ts_data = data WHERE id = f.id;

	RETURN q.id;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "FormBuilder".refresh_question_ts_data(integer) OWNER TO fbdev;

INSERT INTO module(id, description, release_date, comments, update_date, author_user_id, status, is_library, module_type, completiontime)
VALUES (1, 'Question Library', NULL, NULL, clock_timestamp(), 1, 'QUESTION_LIBRARY', TRUE, 'questionLibrary', NULL);
INSERT INTO module(id, description, release_date, comments, update_date, author_user_id, status, is_library, module_type, completiontime)
VALUES (2, 'Form Library', NULL, NULL, clock_timestamp(), 1, 'FORM_LIBRARY', TRUE, 'formLibrary', NULL);

INSERT INTO form(id, "name", module_id, ord, status, update_date, author_user_id, uuid, last_updated_by_user_id, form_type)
VALUES (1, 'Question Form', 1, 1, 'QUESTION_LIBRARY', clock_timestamp(), 1, '2eb81d8c-8587-43f7-b324-a78f1780634e', 1, 'questionLibraryForm');

----------
alter table skip_pattern drop column description;
alter table skip_pattern_parts drop column dtype;

CREATE INDEX fki_fb_answer_value_answer_fk ON answer_value USING btree (answer_id);

ALTER TABLE "FormBuilder".answer_value
  ADD CONSTRAINT fb_answer_value_answer_fk FOREIGN KEY (answer_id)
      REFERENCES "FormBuilder".answer (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;
      
CREATE INDEX fki_fb_question_parent_fk ON question USING btree (parent_id);