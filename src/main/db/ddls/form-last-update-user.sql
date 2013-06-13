/*L
  Copyright HealthCare IT, Inc.

  Distributed under the OSI-approved BSD 3-Clause License.
  See http://ncip.github.com/edct-formbuilder/LICENSE.txt for details.
L*/

ALTER TABLE "FormBuilder".form ADD COLUMN last_updated_by_user_id bigint;

ALTER TABLE "FormBuilder".form
    ADD CONSTRAINT fb_form_last_updated_by_user_fk FOREIGN KEY (last_updated_by_user_id)
      REFERENCES "FormBuilder".rpt_users (id)
      ON UPDATE NO ACTION ON DELETE NO ACTION;