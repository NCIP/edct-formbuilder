ALTER TABLE answer ADD COLUMN ord bigint;
update answer a set ord = a.id;
ALTER TABLE "FormBuilder".answer ALTER COLUMN ord SET NOT NULL;
