ALTER TABLE "FormBuilder".form ADD COLUMN status character varying(30);
ALTER TABLE "FormBuilder".form ALTER COLUMN status SET NOT NULL;
ALTER TABLE "FormBuilder".form ALTER COLUMN status SET DEFAULT 'IN_PROGRESS'::character varying;

ALTER TABLE "FormBuilder".form ADD COLUMN update_date timestamp with time zone;

ALTER TABLE "FormBuilder".form ADD COLUMN author_user_id bigint;

ALTER TABLE "FormBuilder".form
    ADD CONSTRAINT fb_form_author_user_fk FOREIGN KEY (author_user_id)
      REFERENCES "FormBuilder".rpt_users (id)
      ON UPDATE NO ACTION ON DELETE NO ACTION;