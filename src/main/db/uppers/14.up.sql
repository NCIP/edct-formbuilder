/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

alter table form add column form_library_form_id bigint;
ALTER TABLE ONLY form ADD CONSTRAINT fb_form_library_form_fk FOREIGN KEY (form_library_form_id) REFERENCES form(id);