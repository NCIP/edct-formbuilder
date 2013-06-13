/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

alter table answer_value add column external_id character varying(40);
alter table form_element add column external_uuid character varying(40);