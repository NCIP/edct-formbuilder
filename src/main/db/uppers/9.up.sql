CREATE OR REPLACE FUNCTION check_shortname_uniqueness() RETURNS trigger AS $check_shortname_uniqueness$
DECLARE
    record_count int;
  
    BEGIN
 
    	select  count(*) into record_count from question where lower(short_name)=lower(NEW.short_name) and id != NEW.id;
        -- Check that empname and salary are given
        IF record_count>0 THEN
            RAISE EXCEPTION 'A question with the same short name already exists in the database:[%]', NEW.short_name ;
            RETURN NULL;
        ELSE
        	select  count(*) into record_count from form_element where lower(table_short_name)=lower(NEW.short_name);
        	IF record_count>0 THEN
        		RAISE EXCEPTION 'A question with the same short name already exists in the database:[%]', NEW.short_name ;
            	RETURN NULL;
        	END IF;        
        END IF;
        RETURN NEW;
    END;
$check_shortname_uniqueness$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_shortname_uniqueness ON question;

CREATE TRIGGER check_shortname_uniqueness BEFORE INSERT OR UPDATE ON question
    FOR EACH ROW EXECUTE PROCEDURE check_shortname_uniqueness();
    
    
CREATE OR REPLACE FUNCTION check_table_shortname_uniqueness() RETURNS trigger AS $check_table_shortname_uniqueness$
DECLARE
    record_count int;
    BEGIN
    	select  count(*) into record_count from form_element where lower(table_short_name)=lower(NEW.table_short_name) and id != NEW.id;
        -- Check that empname and salary are given
        IF record_count>0 THEN
            RAISE EXCEPTION 'A table with the same short name already exists in the database:[%]', NEW.table_short_name;
        ELSE
        	select  count(*) into record_count from question where lower(short_name)=lower(NEW.table_short_name);
        	IF record_count>0 THEN
            	RAISE EXCEPTION 'A table with the same short name already exists in the database:[%]', NEW.table_short_name;
            END IF;
        END IF;
        RETURN NEW;
    END;
$check_table_shortname_uniqueness$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_table_shortname_uniqueness ON form_element;

CREATE TRIGGER check_table_shortname_uniqueness BEFORE INSERT OR UPDATE ON form_element
    FOR EACH ROW EXECUTE PROCEDURE check_table_shortname_uniqueness();