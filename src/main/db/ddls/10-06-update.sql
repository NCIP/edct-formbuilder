CREATE TABLE sys_variables
(
  schema_version bigint NOT NULL DEFAULT 0
)
WITH (
  OIDS=TRUE
);
ALTER TABLE sys_variables OWNER TO fbdev;

INSERT INTO sys_variables VALUES('0');