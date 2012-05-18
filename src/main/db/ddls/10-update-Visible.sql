ALTER TABLE "FormBuilder".question ADD COLUMN is_visible boolean;
ALTER TABLE "FormBuilder".question ALTER COLUMN is_visible SET STORAGE PLAIN;
update "FormBuilder".question set is_visible = 't';
ALTER TABLE "FormBuilder".question ALTER COLUMN is_visible SET NOT NULL;