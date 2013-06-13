/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE "FormBuilder".question ADD COLUMN cadsr_public_id bigint;
ALTER TABLE "FormBuilder".question ALTER short_name TYPE character varying(250);