/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

 CREATE TABLE preferences
(
  id INT PRIMARY KEY NOT NULL DEFAULT(1) CHECK (id = 1),
  show_please_select_option boolean NOT NULL DEFAULT(false)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE preferences OWNER TO fbdev;

INSERT INTO preferences(show_please_select_option) VALUES(false);

alter table "FormBuilder".module add column show_please_select_option boolean not null default(false);