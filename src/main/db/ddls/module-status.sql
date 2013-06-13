/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE "FormBuilder".module 
	ADD COLUMN status CHARACTER VARYING(30) NOT NULL DEFAULT 'IN_PROGRESS';
