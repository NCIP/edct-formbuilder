/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

-- Table: "FormBuilder".skip_pattern

-- DROP TABLE "FormBuilder".skip_pattern;

CREATE TABLE "FormBuilder".skip_pattern
(
  id bigint NOT NULL,
  parent_id bigint NOT NULL,
  rule_value character varying(50) NOT NULL,
  description character varying(200) NOT NULL,
  parent_type character varying(20) NOT NULL,
  answer_value_id character varying(150) NOT NULL,
  CONSTRAINT skip_pattern_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "FormBuilder".skip_pattern OWNER TO fbdev;

-- Table: "FormBuilder".answer_value

-- DROP TABLE "FormBuilder".answer_value;

CREATE TABLE "FormBuilder".answer_value
(
  id bigint NOT NULL,
  short_name character varying(30) NOT NULL,
  "value" character varying(50) NOT NULL,
  answer_id bigint NOT NULL,
  description character varying(200),
  ord bigint NOT NULL,
  permanent_id character varying(150) NOT NULL,
  CONSTRAINT "answerValuePK" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "FormBuilder".answer_value OWNER TO fbdev;