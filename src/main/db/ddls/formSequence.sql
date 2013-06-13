/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

-- create column with pre-populated values
alter table form add COLUMN ord SERIAL not null; 
-- change type to user-managed
ALTER TABLE form ALTER COLUMN ord DROP DEFAULT;
ALTER TABLE form ALTER ord TYPE bigint;
