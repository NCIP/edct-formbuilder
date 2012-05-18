
CREATE LANGUAGE plpgsql;
CREATE TEXT SEARCH CONFIGURATION "FormBuilder".ts_config ( COPY = pg_catalog.english );

ALTER TABLE "FormBuilder".question ADD COLUMN ts_data tsvector;
CREATE INDEX question_ts_data_idx ON "FormBuilder".question USING gin(ts_data);
 
CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data(qid int) RETURNS INTEGER AS $$
DECLARE
    q RECORD;
    a RECORD;
    av RECORD;
    data TSVECTOR;
begin
	SELECT * INTO q FROM "FormBuilder".question WHERE id = qid;

	if (q is NULL) then
		RETURN qid;
	end if;

	data = setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.short_name,'')), 'A') ||
		setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.description,'')), 'B') ||
		setweight(to_tsvector('"FormBuilder".ts_config', coalesce(q.learn_more,'')), 'C');

	FOR a IN SELECT * FROM "FormBuilder".answer WHERE question_id = q.id LOOP

		data = data || 
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(a.description,'')), 'C') ||
			setweight(to_tsvector('"FormBuilder".ts_config', coalesce(a.group_name,'')), 'D');
	
		FOR av IN SELECT * FROM "FormBuilder".answer_value WHERE answer_id = a.id LOOP
		
			data = data || 
				setweight(to_tsvector('"FormBuilder".ts_config', coalesce(av.description,'')), 'C') ||
				setweight(to_tsvector('"FormBuilder".ts_config', coalesce(av.short_name,'')), 'D');			
				
		END LOOP;
		
	END LOOP;

	UPDATE "FormBuilder".question set ts_data = data WHERE id = q.id;

	RETURN q.id;
end 
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION "FormBuilder".refresh_question_ts_data() RETURNS INTEGER AS $$
DECLARE
	qid INTEGER;
	count INTEGER := 0;
begin
	FOR qid IN SELECT * FROM "FormBuilder".question LOOP
		PERFORM "FormBuilder".refresh_question_ts_data(qid);		
		count := count + 1;
	END LOOP;

	RETURN count;
end 
$$ LANGUAGE plpgsql;

select refresh_question_ts_data();
