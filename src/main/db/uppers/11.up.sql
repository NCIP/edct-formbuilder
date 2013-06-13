/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE preferences ADD COLUMN insert_check_all_that_apply BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE module ADD COLUMN insert_check_all_that_apply BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE "FormBuilder".description
(
   id bigint NOT NULL,  
   source_description_text character varying(2000),
   CONSTRAINT question_description_pkey PRIMARY KEY (id)
) 
WITH (
  OIDS = FALSE
)
;
ALTER TABLE "FormBuilder".description OWNER TO fbdev;

CREATE SEQUENCE "FormBuilder".question_description_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 9963
  CACHE 1;
ALTER TABLE "FormBuilder".question_description_seq OWNER TO fbdev;

CREATE TABLE "FormBuilder".form_element_description
(
   form_element_id bigint, 
   description_id bigint, 
   CONSTRAINT form_element_desc_uniq_idx UNIQUE (form_element_id, description_id)
) 
WITH (
  OIDS = FALSE
)
;
ALTER TABLE "FormBuilder".form_element_description OWNER TO fbdev;

INSERT INTO "FormBuilder".description(id,source_description_text)
SELECT nextval('question_description_seq'), description from form_element;

INSERT INTO "FormBuilder".form_element_description(form_element_id,description_id)
SELECT f.id, d.id from form_element f, description d 
where f.description = d.source_description_text;

ALTER TABLE "FormBuilder".form_element ADD COLUMN external_version real;
