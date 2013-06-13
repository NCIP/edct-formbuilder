/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE "FormBuilder".answer ADD COLUMN display_style character varying(200);
ALTER TABLE "FormBuilder".answer ALTER COLUMN display_style SET STORAGE EXTENDED;