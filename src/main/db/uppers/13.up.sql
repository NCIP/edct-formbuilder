ALTER TABLE answer ADD COLUMN _type character varying(25);
UPDATE answer SET _type = type;
ALTER TABLE answer DROP COLUMN type;
ALTER TABLE answer RENAME COLUMN _type TO type;
ALTER TABLE answer ALTER COLUMN type SET NOT NULL;