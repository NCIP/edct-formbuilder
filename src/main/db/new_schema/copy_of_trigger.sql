CREATE OR REPLACE FUNCTION "FormBuilder".upate_form()
  RETURNS trigger AS
$BODY$
DECLARE
    form_id bigint := NULL;
    BEGIN
		IF TG_RELNAME = 'form_element' THEN
			IF NEW.element_type <> 'link' THEN
				form_id := NEW.form_id;
			END IF;
		ELSE IF TG_RELNAME = 'question' THEN
			form_id := (select fe.form_id from form_element fe WHERE fe.id = NEW.parent_id limit 1);
		ELSE IF TG_RELNAME = 'answer' THEN
			form_id := (select fe.form_id from question q inner join form_element fe on fe.id = q.parent_id WHERE q.id = NEW.question_id limit 1);
		ELSE IF TG_RELNAME = 'answer_value' THEN
			form_id := (select fe.form_id from answer a inner join question q on q.id = a.question_id inner join form_element fe on fe.id = q.parent_id WHERE a.id = NEW.answer_id limit 1);
		ELSE IF TG_RELNAME = 'skip_rule' THEN
			IF NEW.parent_type = 'formElementSkip' THEN
				form_id = NEW.parent_id;
			END IF;
    	END IF;
    	END IF;
    	END IF;
    	END IF;
		END IF;

		IF TG_RELNAME = 'form' THEN
			NEW.form_library_form_id := NULL;
			NEW.update_date := NOW();
			--RAISE NOTICE 'updating form data';
		ELSE IF form_id IS NOT NULL THEN
			--RAISE NOTICE 'updating form id = %', form_id;
			UPDATE form SET form_library_form_id = NULL, update_date = NOW() WHERE id = form_id;
    	END IF;
    	END IF;
    	
        RETURN NEW;
    END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION "FormBuilder".upate_form() OWNER TO fbdev;

CREATE TRIGGER upate_form BEFORE UPDATE ON form FOR EACH ROW EXECUTE PROCEDURE upate_form();
CREATE TRIGGER upate_form BEFORE INSERT OR UPDATE OR DELETE ON form_element FOR EACH ROW EXECUTE PROCEDURE upate_form();
CREATE TRIGGER upate_form BEFORE INSERT OR UPDATE OR DELETE ON question FOR EACH ROW EXECUTE PROCEDURE upate_form();
CREATE TRIGGER upate_form BEFORE INSERT OR UPDATE OR DELETE ON answer FOR EACH ROW EXECUTE PROCEDURE upate_form();
CREATE TRIGGER upate_form BEFORE INSERT OR UPDATE OR DELETE ON answer_value FOR EACH ROW EXECUTE PROCEDURE upate_form();
CREATE TRIGGER upate_form BEFORE INSERT OR UPDATE OR DELETE ON skip_rule FOR EACH ROW EXECUTE PROCEDURE upate_form();