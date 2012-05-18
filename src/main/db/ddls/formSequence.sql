-- create column with pre-populated values
alter table form add COLUMN ord SERIAL not null; 
-- change type to user-managed
ALTER TABLE form ALTER COLUMN ord DROP DEFAULT;
ALTER TABLE form ALTER ord TYPE bigint;
