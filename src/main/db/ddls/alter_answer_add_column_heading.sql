-- Column: answer_column_heading

ALTER TABLE "FormBuilder".answer ADD COLUMN answer_column_heading character varying(200);
ALTER TABLE "FormBuilder".answer ALTER COLUMN answer_column_heading SET STORAGE EXTENDED;