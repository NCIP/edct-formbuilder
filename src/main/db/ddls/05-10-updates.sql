alter table form_element drop column is_simple_table;
alter table form_element add column table_type character varying(15);