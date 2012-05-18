ALTER TABLE "FormBuilder".form ADD COLUMN locked_by_user_id bigint;

ALTER TABLE "FormBuilder".form
    ADD CONSTRAINT fb_form_locked_by_fk FOREIGN KEY (locked_by_user_id)
      REFERENCES "FormBuilder".rpt_users (id)
      ON UPDATE NO ACTION ON DELETE NO ACTION;