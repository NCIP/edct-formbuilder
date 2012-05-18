-- Changed type to accomodate for larger values
ALTER TABLE "FormBuilder".question ALTER COLUMN "type" TYPE varchar(30);

-- update values of column type in Quesiton table
update question set type = 'SINGLE_ANSWER'

-- add data constraints
ALTER TABLE "FormBuilder".question ADD CONSTRAINT "uniqueQuestionOrd" UNIQUE (form_id, ord);
ALTER TABLE "FormBuilder".form ADD CONSTRAINT "uniqueFormOrd" UNIQUE (module_id, ord);

