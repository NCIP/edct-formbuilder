/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

CREATE TABLE "FormBuilder".category(  id bigint NOT NULL,  "name" character varying(50),  description character varying(300),  CONSTRAINT "pk_categoryId" PRIMARY KEY (id))WITH (  OIDS=FALSE);ALTER TABLE "FormBuilder".category OWNER TO fbdev;DROP TABLE IF EXISTS "FormBuilder".question_categries;CREATE TABLE "FormBuilder".question_categries(  category_id bigint NOT NULL,  question_id bigint NOT NULL,  CONSTRAINT "fk_categoryId_question_categories" FOREIGN KEY (category_id)      REFERENCES "FormBuilder".category (id) MATCH SIMPLE      ON UPDATE NO ACTION ON DELETE NO ACTION,  CONSTRAINT "fk_questionId_question_categories" FOREIGN KEY (question_id)      REFERENCES "FormBuilder".question (id) MATCH SIMPLE      ON UPDATE NO ACTION ON DELETE NO ACTION)WITH (  OIDS=FALSE);ALTER TABLE "FormBuilder".question_categries OWNER TO fbdev;