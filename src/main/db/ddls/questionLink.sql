/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE "FormBuilder".question ADD COLUMN link_id character varying(255);
ALTER TABLE "FormBuilder".question ADD COLUMN link_source character varying(30);