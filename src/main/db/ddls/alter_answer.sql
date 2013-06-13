/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE answer ADD COLUMN ord bigint;
update answer a set ord = a.id;
ALTER TABLE "FormBuilder".answer ALTER COLUMN ord SET NOT NULL;
