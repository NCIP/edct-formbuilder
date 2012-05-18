
ALTER TABLE "FormBuilder".answer ADD COLUMN display_style character varying(200);
ALTER TABLE "FormBuilder".answer ALTER COLUMN display_style SET STORAGE EXTENDED;