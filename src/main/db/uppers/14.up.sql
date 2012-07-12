alter table form add column form_library_form_id bigint;
ALTER TABLE ONLY form ADD CONSTRAINT fb_form_library_form_fk FOREIGN KEY (form_library_form_id) REFERENCES form(id);