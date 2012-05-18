
ALTER TABLE "FormBuilder".MODULE ADD COLUMN update_date TIMESTAMP WITH TIME ZONE;
ALTER TABLE "FormBuilder".MODULE ADD COLUMN author_user_id BIGINT;
ALTER TABLE ONLY module
    ADD CONSTRAINT fb_module_author_user_fk FOREIGN KEY (author_user_id)
      REFERENCES "FormBuilder".rpt_users (id)
      ON UPDATE NO ACTION ON DELETE NO ACTION;