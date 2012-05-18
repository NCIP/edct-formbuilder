--first, create new table form_element 

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

---secondly, rename the old question table to question_old
alter table "FormBuilder".question rename to question_old;

--thirdly, create the new table question
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

---since question renamed to question_old, now, drop the old foreign key in answer table pointing to the question_old table
ALTER TABLE "FormBuilder".answer
DROP CONSTRAINT fb_answer_question_fk;

--fourth, create a copy of answer
create table "FormBuilder".answer_old as select * from "FormBuilder".answer;

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

	FOR q IN SELECT * FROM question_old  LOOP
                 
	-- insert form_element, the form_element is actually the old question table
      
        
		   --get the element_type
		 if q.type like '%_ANSWER' then
           e_type := 'question';
           elsif q.type ='CONTENT' then
           e_type :=  'content';
           elsif q.type like '%_TABLE'  then
           e_type := 'table';	
	   else continue;
	   end if; 
         ---  else if q.link_id is Not null and q.link_source='Local'  then
         ---  e_type := 'link';
         ---  else if q.cadsr_public_id is NOT null then 			
         ---  e_type := 'external';
         ---  end if;		   
           
		  
		   --get link source
		   -- lk_source :=q.link_source;
           --if q.cadsr_public_id is NOT null and q.link_source is NULL then
		   -- lk_source := 'CA_DSR';
		   --end if;	
 
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
			q.is_visible,
			e_type
           );		   
		
	         
	   	
		 
	END LOOP;

	--commit;

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
begin
	
	delete from question;

	FOR a IN SELECT * FROM answer  LOOP
                 
	-- insert new question table
           
		  ---get the new Id
		  new_id := nextval('"GENERIC_ID_SEQ"');
          
		  ---get the type
		  select type into q_type from question_old where id = a.question_id;
		  
		  
          insert into question 
		  (id, description, uuid, ord, short_name, parent_id, question_type, type)
           values 
           (new_id,
		    a.description,
		    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'http://www.heathcit.com/FormBuilder/' || new_id),
			a.ord,
			a.group_name,
			a.question_id,
			'tableQuestion',			
			q_type
           );		   
		
	    -- update answer table with thte new question id
        update answer set question_id = new_id where id= a.id;        
		
		 
	END LOOP;

	--commit;

	RETURN true;
end
$BODY$
  LANGUAGE 'plpgsql' VOLATILE;

select convert_answer_question();

--add the foreign key back to the answer table which point to the new question table
ALTER TABLE "FormBuilder".answer
  ADD CONSTRAINT fb_answer_question_fk FOREIGN KEY (question_id)
      REFERENCES "FormBuilder".question (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;


drop function convert_form_element();

drop function convert_answer_question();




  
