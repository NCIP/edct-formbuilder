ALTER TABLE "FormBuilder".form_element ADD COLUMN table_short_name character varying(250);
UPDATE "FormBuilder".form_element SET table_short_name='Table'||id WHERE (element_type='table');