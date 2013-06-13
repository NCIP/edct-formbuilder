/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

-- create column with pre-populated values
alter table question add COLUMN ord SERIAL not null; 
-- change type to user-managed
ALTER TABLE question ALTER COLUMN ord DROP DEFAULT;
ALTER TABLE question ALTER ord TYPE bigint;

-- add column learn_more
ALTER TABLE "FormBuilder".question ADD COLUMN learn_more character varying(2000);
ALTER TABLE "FormBuilder".question ALTER COLUMN learn_more SET STORAGE EXTENDED;

-- add column is_required
ALTER TABLE "FormBuilder".question ADD COLUMN is_required boolean;
ALTER TABLE "FormBuilder".question ALTER COLUMN is_required SET STORAGE PLAIN;

update question set is_required = true;

