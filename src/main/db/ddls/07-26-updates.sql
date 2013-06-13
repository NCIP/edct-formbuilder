/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE "FormBuilder".form_element ADD COLUMN table_short_name character varying(250);
UPDATE "FormBuilder".form_element SET table_short_name='Table'||id WHERE (element_type='table');