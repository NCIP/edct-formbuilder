/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

CREATE TABLE sys_variables
(
  schema_version bigint NOT NULL DEFAULT 0
)
WITH (
  OIDS=TRUE
);
ALTER TABLE sys_variables OWNER TO fbdev;

INSERT INTO sys_variables VALUES('0');