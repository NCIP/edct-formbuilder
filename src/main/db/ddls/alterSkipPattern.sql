-- add new column to table skip_pattern
alter table skip_pattern add description character varying(200) not null; 
-- increase description with on question to allow content
alter table question alter column description type varchar(2000)
