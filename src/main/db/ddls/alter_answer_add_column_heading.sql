/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

-- Column: answer_column_heading

ALTER TABLE "FormBuilder".answer ADD COLUMN answer_column_heading character varying(200);
ALTER TABLE "FormBuilder".answer ALTER COLUMN answer_column_heading SET STORAGE EXTENDED;