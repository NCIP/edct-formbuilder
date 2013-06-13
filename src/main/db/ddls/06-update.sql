/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

﻿delete from "FormBuilder".answer_value;
delete from "FormBuilder".answer;
delete from "FormBuilder".question_categries;
delete from "FormBuilder".question;
ALTER TABLE "FormBuilder".answer ADD COLUMN display_style character varying(200);
ALTER TABLE "FormBuilder".answer_value ADD COLUMN permanent_id character(36) NOT NULL;
--update answer_value set permanent_id = '12345678-1234-4444-4444-9876543' || id;

drop table "FormBuilder".skip_pattern;
CREATE TABLE "FormBuilder".skip_pattern
(
  id bigint NOT NULL,
  parent_id bigint NOT NULL,
  rule_value character varying(50) NOT NULL,
  description character varying(300) NOT NULL,
  parent_type character varying(20) NOT NULL,
  answer_value_id character(36) NOT NULL,
  CONSTRAINT skip_pattern_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE INDEX skip_pattern_av_id_index
  ON "FormBuilder".skip_pattern
  USING btree
  (answer_value_id);

CREATE INDEX skip_pattern_parent_idx
  ON "FormBuilder".skip_pattern
  USING btree
  (parent_id, parent_type);

update answer set type='RADIO' where type='MATRIXS';